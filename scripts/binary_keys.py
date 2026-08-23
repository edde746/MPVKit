#!/usr/bin/env python3
"""Content-addressed binaries for the libraries this repository builds itself.

Every push to main publishes the artifacts that commit needs, and Package.swift
on that commit points at them, so any commit can be pinned by a consumer and
gets binaries built from exactly its sources.

The mechanism is a content key per library: the first 12 hex characters of a
sha256 over that library's upstream version and URL, its patch series, the
build flags, the canonical platform set, the build scripts, and the toolchain
generation. Assets carry the key in their name, which makes them immutable --
a name that already exists on the rolling `binaries` prerelease is the same
bytes by construction, so it is never re-uploaded and never clobbered.

Two artifact kinds per library:

  <Framework>-<key>.xcframework.zip   what Package.swift links against
  <library>-all-<key>-<platform>.zip  the thin install tree, restored by a
                                      later build instead of recompiling
                                      (the exact layout ZipBaseBuild already
                                      consumes for prebuilt dependencies)

Deliberately coarse: the key hashes ALL of the build scripts, so editing any of
them -- including bumping one library's version, since the versions live in
main.swift -- invalidates every self-built library. Under-invalidation would
mean silently shipping stale binaries; over-invalidation only costs a build.
The fast path that matters is preserved: a commit that only touches
patch/libmpv/* changes libmpv's key alone.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

SCHEMA = 1

# Libraries this repository compiles and publishes. Everything else in
# Package.swift is a prebuilt zip from the mpvkit/*-build releases and is left
# alone.
SELF_BUILT = ("libass", "FFmpeg", "libmpv")

# The six platforms the publish workflow builds. Part of the key: artifacts for
# a different platform set are different artifacts.
CANONICAL_PLATFORMS = ("ios", "isimulator", "maccatalyst", "macos", "tvos", "tvsimulator")

DEFAULT_ASSET_BASE = "https://github.com/edde746/MPVKit/releases/download/binaries"

MANIFEST_PATH = Path("Sources/BuildScripts/binaries.json")
TOOLCHAIN_PATH = Path("Sources/BuildScripts/toolchain.txt")
PACKAGE_PATH = Path("Package.swift")
MAIN_SWIFT = Path("Sources/BuildScripts/XCFrameworkBuild/main.swift")
SCRIPT_SOURCES = (
    Path("Sources/BuildScripts/Package.swift"),
    Path("Sources/BuildScripts/XCFrameworkBuild/base.swift"),
    Path("Sources/BuildScripts/XCFrameworkBuild/main.swift"),
)

CHECKSUM_RE = re.compile(r"\A[0-9a-f]{64}\Z")


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


# ---- swift parsing --------------------------------------------------------
#
# Only two fields are read out of main.swift: each library's version and URL.
# The framework names come from the built artifacts instead of the Swift
# sources, because BuildFFMPEG.frameworks() derives them at runtime from the
# static libraries it produced.


def _property_block(source: str, name: str) -> str:
    marker = f"var {name}: String {{"
    start = source.find(marker)
    if start < 0:
        raise SystemExit(f"{MAIN_SWIFT}: no `{marker}` found")

    depth = 0
    for index in range(start + len(marker) - 1, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[start:index]
    raise SystemExit(f"{MAIN_SWIFT}: unterminated `{marker}` block")


def _parse_cases(block: str) -> dict[str, str]:
    # No comment stripping: `//` also starts every URL in the `url` switch. A
    # `case .libshaderc:  // ...` trailer is skipped by anchoring on `return`
    # instead, which sits after any comment on the label's line.
    values: dict[str, str] = {}
    labels = list(re.finditer(r"case\s+\.(\w+)\s*:", block))
    for index, label in enumerate(labels):
        end = labels[index + 1].start() if index + 1 < len(labels) else len(block)
        chunk = block[label.end() : end]
        match = re.search(r'return\s*"([^"]*)"', chunk)
        if match:
            values[label.group(1)] = match.group(1)
    return values


def library_fields(root: Path) -> dict[str, dict[str, str]]:
    source = (root / MAIN_SWIFT).read_text(encoding="utf-8")
    versions = _parse_cases(_property_block(source, "version"))
    urls = _parse_cases(_property_block(source, "url"))

    fields: dict[str, dict[str, str]] = {}
    for library in SELF_BUILT:
        if library not in versions:
            raise SystemExit(f"{MAIN_SWIFT}: no version for {library}")
        if library not in urls:
            raise SystemExit(f"{MAIN_SWIFT}: no url for {library}")
        url = urls[library]
        # Prebuilt dependencies interpolate their version into the URL; the
        # self-built ones are plain git remotes, but resolve it anyway so the
        # key never hashes a literal "\(self.version)".
        url = url.replace("\\(self.version)", versions[library]).replace(
            "\\(version)", versions[library]
        )
        fields[library] = {"version": versions[library], "url": url}
    return fields


# ---- keys -----------------------------------------------------------------


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def scripts_digest(root: Path) -> str:
    digest = hashlib.sha256()
    for relative in SCRIPT_SOURCES:
        path = root / relative
        if not path.is_file():
            raise SystemExit(f"missing build script: {relative}")
        digest.update(f"{relative}\n".encode())
        digest.update(_sha256_file(path).encode())
        digest.update(b"\n")
    return digest.hexdigest()


def patch_entries(root: Path, library: str) -> list[tuple[str, str]]:
    directory = root / "Sources/BuildScripts/patch" / library
    if not directory.is_dir():
        return []
    return [
        (path.name, _sha256_file(path))
        for path in sorted(directory.glob("*.patch"), key=lambda item: item.name)
    ]


def key_inputs(root: Path, library: str, *, gpl: bool, debug: bool) -> str:
    fields = library_fields(root)[library]
    toolchain = (root / TOOLCHAIN_PATH).read_bytes()

    text = [
        f"schema={SCHEMA}",
        f"library={library}",
        f"version={fields['version']}",
        f"url={fields['url']}",
        f"gpl={int(gpl)}",
        f"debug={int(debug)}",
        f"platforms={','.join(CANONICAL_PLATFORMS)}",
        f"scripts={scripts_digest(root)}",
        f"toolchain={_sha256_bytes(toolchain)}",
    ]
    for name, digest in patch_entries(root, library):
        text.append(f"patch={name}:{digest}")
    return "\n".join(text) + "\n"


def library_key(root: Path, library: str, *, gpl: bool, debug: bool) -> str:
    return _sha256_bytes(key_inputs(root, library, gpl=gpl, debug=debug).encode())[:12]


def all_keys(root: Path, *, gpl: bool, debug: bool) -> dict[str, str]:
    return {library: library_key(root, library, gpl=gpl, debug=debug) for library in SELF_BUILT}


# ---- manifest -------------------------------------------------------------


def prebuilt_asset(library: str, key: str, platform: str) -> str:
    return f"{library}-all-{key}-{platform}.zip"


def framework_asset(framework: str, key: str) -> str:
    return f"{framework}-{key}.xcframework.zip"


def load_manifest(root: Path) -> dict:
    path = root / MANIFEST_PATH
    if not path.is_file():
        return {"schema": SCHEMA, "assetBase": DEFAULT_ASSET_BASE, "libraries": {}}
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("schema") != SCHEMA:
        raise SystemExit(f"{MANIFEST_PATH}: unsupported schema {manifest.get('schema')!r}")
    manifest.setdefault("assetBase", DEFAULT_ASSET_BASE)
    manifest.setdefault("libraries", {})
    return manifest


def save_manifest(root: Path, manifest: dict) -> None:
    path = root / MANIFEST_PATH
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def entry_problems(entry: dict | None, key: str, library: str) -> list[str]:
    """Why this library's manifest entry cannot be trusted for `key`."""
    if not entry:
        return ["no manifest entry"]

    problems = []
    if entry.get("key") != key:
        problems.append(f"key {entry.get('key')!r} != {key!r}")

    prebuilt = entry.get("prebuilt") or {}
    for platform in CANONICAL_PLATFORMS:
        asset = prebuilt.get(platform)
        if not asset:
            problems.append(f"no prebuilt asset for {platform}")
        elif asset != prebuilt_asset(library, key, platform):
            problems.append(f"prebuilt {platform} asset {asset!r} does not match the key")

    frameworks = entry.get("frameworks") or {}
    if not frameworks:
        problems.append("no frameworks recorded")
    for name, framework in sorted(frameworks.items()):
        asset = framework.get("asset")
        checksum = framework.get("checksum", "")
        if asset != framework_asset(name, key):
            problems.append(f"{name}: asset {asset!r} does not match the key")
        if not CHECKSUM_RE.match(checksum):
            problems.append(f"{name}: checksum {checksum!r} is not a sha256")
    return problems


# ---- recording ------------------------------------------------------------


def swiftpm_checksum(path: Path) -> str:
    """SwiftPM's archive checksum, which is the sha256 of the file.

    Cross-checked against `swift package compute-checksum` when a toolchain is
    on PATH, so a future SwiftPM change to the algorithm cannot slip through.
    """
    digest = _sha256_file(path)
    if shutil.which("swift"):
        try:
            reference = subprocess.run(
                ["swift", "package", "compute-checksum", str(path)],
                capture_output=True,
                text=True,
                timeout=180,
            )
        except (OSError, subprocess.TimeoutExpired):
            return digest
        if reference.returncode == 0:
            reference_digest = reference.stdout.strip()
            if reference_digest and reference_digest != digest:
                raise SystemExit(
                    f"{path.name}: sha256 {digest} disagrees with "
                    f"`swift package compute-checksum` {reference_digest}"
                )
    return digest


def frameworks_in_prebuilt(zip_path: Path) -> list[str]:
    """Framework names a library produced, read out of its thin install tree.

    Mirrors BaseBuild.packageRelease(): a `lib<name>.a` static library becomes
    the `Lib<name>` framework. Reading the artifact rather than the Swift
    sources keeps this correct when a library's output set changes, because
    BuildFFMPEG.frameworks() itself derives the list from the built libraries.
    """
    names = set()
    with zipfile.ZipFile(zip_path) as archive:
        for info in archive.infolist():
            name = Path(info.filename).name
            if not name.endswith(".a") or not name.startswith("lib"):
                continue
            names.add("Lib" + name[len("lib") : -len(".a")])
    return sorted(names)


def cmd_record_platform(args, root: Path) -> int:
    release = root / args.release_dir
    keys = all_keys(root, gpl=args.gpl, debug=args.debug)

    renamed = 0
    for library in SELF_BUILT:
        source = release / f"{library}-all.zip"
        if not source.is_file():
            continue
        destination = release / prebuilt_asset(library, keys[library], args.platform)
        if destination.exists():
            destination.unlink()
        source.rename(destination)
        print(f"{source.name} -> {destination.name}")
        renamed += 1

    if renamed == 0:
        print("no per-platform artifacts to name (nothing was compiled)")
    return 0


def cmd_record_frameworks(args, root: Path) -> int:
    release = root / args.release_dir
    keys = all_keys(root, gpl=args.gpl, debug=args.debug)
    manifest = load_manifest(root)
    manifest["assetBase"] = manifest.get("assetBase") or DEFAULT_ASSET_BASE

    for library in SELF_BUILT:
        key = keys[library]
        prebuilt = {}
        for platform in CANONICAL_PLATFORMS:
            asset = prebuilt_asset(library, key, platform)
            if (release / asset).is_file():
                prebuilt[platform] = asset

        if not prebuilt:
            # Not compiled in this run: it was restored from its published
            # artifacts, so its existing entry is still the right one.
            print(f"{library}: not rebuilt, keeping the recorded entry")
            continue

        missing = [platform for platform in CANONICAL_PLATFORMS if platform not in prebuilt]
        if missing:
            raise SystemExit(
                f"{library}: rebuilt but missing per-platform artifacts for "
                f"{', '.join(missing)}; refusing to record a partial entry"
            )

        reference = release / prebuilt[CANONICAL_PLATFORMS[0]]
        frameworks = {}
        for name in frameworks_in_prebuilt(reference):
            built = release / f"{name}.xcframework.zip"
            addressed = release / framework_asset(name, key)
            if built.is_file():
                if addressed.exists():
                    addressed.unlink()
                built.rename(addressed)
            elif not addressed.is_file():
                raise SystemExit(f"{library}: {built.name} was not produced by this build")
            frameworks[name] = {
                "asset": addressed.name,
                "checksum": swiftpm_checksum(addressed),
            }

        if not frameworks:
            raise SystemExit(f"{library}: no static libraries found in {reference.name}")

        manifest["libraries"][library] = {
            "key": key,
            "prebuilt": prebuilt,
            "frameworks": frameworks,
        }
        print(f"{library}: key {key}, {len(frameworks)} framework(s), {len(prebuilt)} platform(s)")
        for name, framework in sorted(frameworks.items()):
            print(f"  {name} -> {framework['asset']} {framework['checksum'][:12]}")

    save_manifest(root, manifest)
    print(f"wrote {MANIFEST_PATH}")
    return 0


# ---- Package.swift --------------------------------------------------------


def _target_block(text: str, name: str) -> re.Match | None:
    pattern = re.compile(
        r'(name:\s*"' + re.escape(name) + r'",\s*\n\s*)'
        r'url:\s*"(?P<url>[^"]*)",(\s*\n\s*)'
        r'checksum:\s*"(?P<checksum>[^"]*)"'
    )
    return pattern.search(text)


def _has_local_path_target(text: str, name: str) -> bool:
    pattern = re.compile(r'name:\s*"' + re.escape(name) + r'",\s*\n\s*path:\s*"')
    return bool(pattern.search(text))


def cmd_render(args, root: Path) -> int:
    manifest = load_manifest(root)
    asset_base = manifest["assetBase"]
    path = root / PACKAGE_PATH
    text = path.read_text(encoding="utf-8")
    original = text
    skipped = []

    for library in SELF_BUILT:
        entry = manifest["libraries"].get(library)
        if not entry:
            continue
        for name, framework in sorted((entry.get("frameworks") or {}).items()):
            url = f"{asset_base}/{framework['asset']}"
            checksum = framework["checksum"]
            match = _target_block(text, name)
            if not match:
                if _has_local_path_target(text, name):
                    skipped.append(name)
                    continue
                raise SystemExit(f"{PACKAGE_PATH}: no url/checksum target named {name}")
            replacement = (
                f'{match.group(1)}url: "{url}",{match.group(3)}checksum: "{checksum}"'
            )
            text = text[: match.start()] + replacement + text[match.end() :]

    if text != original:
        path.write_text(text, encoding="utf-8")
        print(f"rendered {PACKAGE_PATH}")
    else:
        print(f"{PACKAGE_PATH} already matches the manifest")

    for name in skipped:
        print(f"{name}: pinned to a local path, left untouched")
    return 0


# ---- queries and gate -----------------------------------------------------


def cmd_keys(args, root: Path) -> int:
    keys = all_keys(root, gpl=args.gpl, debug=args.debug)
    if args.show_inputs:
        for library in SELF_BUILT:
            print(f"# {library} -> {keys[library]}")
            print(key_inputs(root, library, gpl=args.gpl, debug=args.debug), end="")
        return 0
    print(json.dumps(keys, indent=2, sort_keys=True))
    return 0


def cmd_stale(args, root: Path) -> int:
    keys = all_keys(root, gpl=args.gpl, debug=args.debug)
    manifest = load_manifest(root)
    for library in SELF_BUILT:
        entry = manifest["libraries"].get(library)
        if entry_problems(entry, keys[library], library):
            print(library)
    return 0


def cmd_verify(args, root: Path) -> int:
    keys = all_keys(root, gpl=args.gpl, debug=args.debug)
    manifest_path = root / MANIFEST_PATH
    failures: list[str] = []

    if not manifest_path.is_file():
        print(f"FAIL: {MANIFEST_PATH} does not exist, so this commit is not pinnable")
        return 1

    manifest = load_manifest(root)
    asset_base = manifest["assetBase"]
    text = (root / PACKAGE_PATH).read_text(encoding="utf-8")
    allow_local = os.environ.get("MPVKIT_ALLOW_LOCAL_PATH") == "1"

    for library in SELF_BUILT:
        entry = manifest["libraries"].get(library)
        for problem in entry_problems(entry, keys[library], library):
            failures.append(f"{library}: {problem}")
        if not entry:
            continue

        for name, framework in sorted((entry.get("frameworks") or {}).items()):
            expected_url = f"{asset_base}/{framework['asset']}"
            match = _target_block(text, name)
            if not match:
                if _has_local_path_target(text, name):
                    message = f"{name}: Package.swift pins a local path instead of {expected_url}"
                    if allow_local:
                        print(f"warning: {message} (MPVKIT_ALLOW_LOCAL_PATH=1)")
                    else:
                        failures.append(message)
                else:
                    failures.append(f"{name}: no url/checksum target in Package.swift")
                continue
            if match.group("url") != expected_url:
                failures.append(
                    f"{name}: Package.swift url {match.group('url')} != {expected_url}"
                )
            if match.group("checksum") != framework["checksum"]:
                failures.append(
                    f"{name}: Package.swift checksum {match.group('checksum')} "
                    f"!= {framework['checksum']}"
                )

    if failures:
        print("FAIL: the published binaries do not describe this commit")
        for failure in failures:
            print(f"  {failure}")
        print("\nRun the publish workflow (or `make build` + record/render) to refresh them.")
        return 1

    for library in SELF_BUILT:
        print(f"{library}: {keys[library]} ok")
    print("every self-built library is published and pinned for this commit")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--no-gpl", dest="gpl", action="store_false", help="key the non-GPL build (CI builds GPL)"
    )
    parser.add_argument("--debug", action="store_true", help="key a debug build")
    parser.set_defaults(gpl=True)
    subparsers = parser.add_subparsers(dest="command", required=True)

    keys = subparsers.add_parser("keys", help="print the content key of every self-built library")
    keys.add_argument("--show-inputs", action="store_true", help="print what each key hashes")
    keys.set_defaults(func=cmd_keys)

    stale = subparsers.add_parser("stale", help="list libraries whose binaries need building")
    stale.set_defaults(func=cmd_stale)

    record_platform = subparsers.add_parser(
        "record-platform", help="name a build leg's thin install trees by content"
    )
    record_platform.add_argument("--platform", required=True, choices=CANONICAL_PLATFORMS)
    record_platform.add_argument("--release-dir", default="dist/release")
    record_platform.set_defaults(func=cmd_record_platform)

    record_frameworks = subparsers.add_parser(
        "record-frameworks", help="name the merged xcframeworks by content and write the manifest"
    )
    record_frameworks.add_argument("--release-dir", default="dist/release")
    record_frameworks.set_defaults(func=cmd_record_frameworks)

    render = subparsers.add_parser("render", help="point Package.swift at the manifest's assets")
    render.set_defaults(func=cmd_render)

    verify = subparsers.add_parser(
        "verify", help="fail unless the manifest and Package.swift describe this commit"
    )
    verify.set_defaults(func=cmd_verify)

    args = parser.parse_args(argv)
    return args.func(args, repo_root())


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
