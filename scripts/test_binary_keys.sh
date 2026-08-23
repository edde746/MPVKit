#!/usr/bin/env bash
# Regression test for scripts/binary_keys.py, which is what makes "pin any
# commit and get the binaries built from it" true.
#
# Most scenarios run against a synthetic repository, so the assertions can be
# exact (which key moved, which asset was renamed, which check failed) without
# a 14-minute build. Two scenarios run against this repository itself, so the
# Swift parsing and the real patch series stay covered.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$root" <<'PY'
import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

root = Path(sys.argv[1])
tool = root / "scripts" / "binary_keys.py"

failures = []


def check(condition, message):
    if not condition:
        failures.append(message)
        print(f"FAIL: {message}")


def run(repo, *args, expect=0, env=None):
    environment = dict(os.environ)
    if env:
        environment.update(env)
    result = subprocess.run(
        [sys.executable, str(repo / "scripts" / "binary_keys.py"), *args],
        capture_output=True,
        text=True,
        cwd=repo,
        env=environment,
    )
    if expect is not None and result.returncode != expect:
        failures.append(
            f"{' '.join(args)} exited {result.returncode}, expected {expect}\n"
            f"{result.stdout}{result.stderr}"
        )
        print(f"FAIL: {' '.join(args)} exited {result.returncode}, expected {expect}")
        print(result.stdout, result.stderr)
    return result


LIBRARIES = {"libass": ["libass"], "FFmpeg": ["libavcodec", "libavutil"], "libmpv": ["libmpv"]}
PLATFORMS = ("ios", "isimulator", "maccatalyst", "macos", "tvos", "tvsimulator")

MAIN_SWIFT = '''
enum Library: String, CaseIterable {
    case libmpv, FFmpeg, libass, libplacebo
    var version: String {
        switch self {
        case .libmpv:
            return "v0.41.0"
        case .FFmpeg:
            return "n8.0.1"
        case .libass:  // trailing comment before the return
            return "0.18.3"
        case .libplacebo:
            return "7.351.0"
        }
    }

    var url: String {
        switch self {
        case .libmpv:
            return "https://github.com/mpv-player/mpv"
        case .FFmpeg:
            return "https://github.com/FFmpeg/FFmpeg"
        case .libass:
            return "https://github.com/edde746/libass"
        case .libplacebo:
            return
                "https://github.com/mpvkit/libplacebo-build/releases/download/\\(self.version)/libplacebo-all.zip"
        }
    }
}
'''

PACKAGE_TEMPLATE = '''// swift-tools-version:5.9
let package = Package(
    name: "MPVKit",
    targets: [
        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.351.0/Libplacebo.xcframework.zip",
            checksum: "{placebo}"
        ),
{targets}
        //AUTO_GENERATE_TARGETS_END//
    ]
)
'''

TARGET_TEMPLATE = '''        .binaryTarget(
            name: "{name}",
            url: "https://github.com/edde746/MPVKit/releases/download/1.0.26/{name}.xcframework.zip",
            checksum: "{checksum}"
        ),
'''


def framework_name(static_lib):
    return "Lib" + static_lib[len("lib"):]


def make_repo(directory):
    """A minimal repository with the layout binary_keys.py reads."""
    repo = Path(directory)
    (repo / "scripts").mkdir(parents=True)
    shutil.copy2(tool, repo / "scripts" / "binary_keys.py")

    build_scripts = repo / "Sources" / "BuildScripts"
    (build_scripts / "XCFrameworkBuild").mkdir(parents=True)
    (build_scripts / "Package.swift").write_text("// build scripts package\n", encoding="utf-8")
    (build_scripts / "XCFrameworkBuild" / "base.swift").write_text("// base\n", encoding="utf-8")
    (build_scripts / "XCFrameworkBuild" / "main.swift").write_text(MAIN_SWIFT, encoding="utf-8")
    (build_scripts / "toolchain.txt").write_text("generation=1\n", encoding="utf-8")

    for library in LIBRARIES:
        patch_dir = build_scripts / "patch" / library
        patch_dir.mkdir(parents=True)
        (patch_dir / "0001-first.patch").write_text(f"--- {library}\n", encoding="utf-8")

    targets = "".join(
        TARGET_TEMPLATE.format(name=framework_name(static), checksum="0" * 64)
        for statics in LIBRARIES.values()
        for static in statics
    )
    (repo / "Package.swift").write_text(
        PACKAGE_TEMPLATE.format(placebo="1" * 64, targets=targets), encoding="utf-8"
    )
    return repo


def build_artifacts(repo, libraries=LIBRARIES, platforms=PLATFORMS):
    """What a `make build` leg leaves in dist/release before record-platform."""
    release = repo / "dist" / "release"
    release.mkdir(parents=True, exist_ok=True)
    for library, statics in libraries.items():
        all_zip = release / f"{library}-all.zip"
        with zipfile.ZipFile(all_zip, "w") as archive:
            for platform in platforms:
                for static in statics:
                    archive.writestr(
                        f"lib/{platform}/thin/arm64/lib/{static}.a", f"{library}-{platform}"
                    )
            archive.writestr("include/header.h", "// header")
        for static in statics:
            name = framework_name(static)
            with zipfile.ZipFile(release / f"{name}.xcframework.zip", "w") as archive:
                archive.writestr(f"{name}.xcframework/Info.plist", f"{library}:{name}")
    return release


def publish(repo, libraries=LIBRARIES, platforms=PLATFORMS):
    """One full pass: build every leg, name artifacts, record, render."""
    for platform in platforms:
        build_artifacts(repo, libraries=libraries, platforms=[platform])
        run(repo, "record-platform", "--platform", platform, "--release-dir", "dist/release")
    run(repo, "record-frameworks", "--release-dir", "dist/release")
    run(repo, "render")


def keys(repo):
    return json.loads(run(repo, "keys").stdout)


def manifest_of(repo):
    return json.loads((repo / "Sources" / "BuildScripts" / "binaries.json").read_text())


# 1. The real repository: Swift parsing and the real patch series.
real = keys(root)
check(sorted(real) == ["FFmpeg", "libass", "libmpv"], f"real repo keys: {sorted(real)}")
check(
    all(len(value) == 12 and all(c in "0123456789abcdef" for c in value) for value in real.values()),
    f"real repo keys are not 12 hex chars: {real}",
)
check(keys(root) == real, "keys must be reproducible for the same tree")
print(f"real repo: {json.dumps(real, sort_keys=True)}")

# 2. A patch edit moves exactly that library's key.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    before = keys(repo)
    patch = repo / "Sources/BuildScripts/patch/libmpv/0024-new.patch"
    patch.write_text("--- a/video/out/vo_avfoundation.m\n", encoding="utf-8")
    after = keys(repo)
    check(before["libmpv"] != after["libmpv"], "a new libmpv patch must move libmpv's key")
    check(before["FFmpeg"] == after["FFmpeg"], "a libmpv patch must not move FFmpeg's key")
    check(before["libass"] == after["libass"], "a libmpv patch must not move libass's key")
    patch.write_text("--- a/video/out/vo_avfoundation.m\n+ edited\n", encoding="utf-8")
    check(keys(repo)["libmpv"] != after["libmpv"], "editing a patch's bytes must move the key")
    print("patch edit: only the touched library's key moves")

# 3. Build-script and toolchain changes invalidate everything, by design.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    before = keys(repo)
    base = repo / "Sources/BuildScripts/XCFrameworkBuild/base.swift"
    base.write_text(base.read_text() + "// tweak\n", encoding="utf-8")
    after = keys(repo)
    check(
        all(after[library] != before[library] for library in before),
        "a build-script edit must invalidate every self-built library",
    )
    toolchain = repo / "Sources/BuildScripts/toolchain.txt"
    toolchain.write_text("generation=2\n", encoding="utf-8")
    bumped = keys(repo)
    check(
        all(bumped[library] != after[library] for library in after),
        "a toolchain generation bump must invalidate every self-built library",
    )
    print("build-script and toolchain changes invalidate all three libraries")

# 4. A full publish pass, then the steady state: nothing stale, verify passes.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    stale = run(repo, "stale").stdout.split()
    check(sorted(stale) == ["FFmpeg", "libass", "libmpv"], f"a fresh repo is all stale: {stale}")
    run(repo, "verify", expect=1)

    publish(repo)
    check(run(repo, "stale").stdout.strip() == "", "nothing may be stale after publishing")
    run(repo, "verify")

    manifest = manifest_of(repo)
    expected_key = keys(repo)["FFmpeg"]
    entry = manifest["libraries"]["FFmpeg"]
    check(entry["key"] == expected_key, "the manifest records the computed key")
    check(
        sorted(entry["frameworks"]) == ["Libavcodec", "Libavutil"],
        f"FFmpeg's frameworks come from its static libraries: {sorted(entry['frameworks'])}",
    )
    check(
        sorted(entry["prebuilt"]) == sorted(PLATFORMS),
        f"every platform is recorded: {sorted(entry['prebuilt'])}",
    )
    check(
        entry["prebuilt"]["tvos"] == f"FFmpeg-all-{expected_key}-tvos.zip",
        f"prebuilt asset name: {entry['prebuilt']['tvos']}",
    )
    asset = entry["frameworks"]["Libavcodec"]["asset"]
    check(asset == f"Libavcodec-{expected_key}.xcframework.zip", f"framework asset name: {asset}")
    check((repo / "dist/release" / asset).is_file(), f"{asset} must exist to be uploaded")

    import hashlib

    digest = hashlib.sha256((repo / "dist/release" / asset).read_bytes()).hexdigest()
    check(
        entry["frameworks"]["Libavcodec"]["checksum"] == digest,
        "the recorded checksum is the sha256 of the archive SwiftPM will fetch",
    )

    package = (repo / "Package.swift").read_text()
    check(
        f'url: "https://github.com/edde746/MPVKit/releases/download/binaries/{asset}"' in package,
        "Package.swift points at the content-addressed asset",
    )
    check(digest in package, "Package.swift carries the recorded checksum")
    check(
        "libplacebo-build/releases/download/7.351.0/Libplacebo.xcframework.zip" in package,
        "prebuilt dependencies are left alone",
    )
    check("1.0.26" not in package, "no release-version URL survives a render")

    rendered_again = run(repo, "render")
    check("already matches" in rendered_again.stdout, "render is idempotent")
    print("publish pass: manifest, asset names, checksums and Package.swift agree")

# 5. Every way the gate must fail.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    publish(repo)
    run(repo, "verify")
    package_path = repo / "Package.swift"
    good_package = package_path.read_text()
    good_manifest = (repo / "Sources/BuildScripts/binaries.json").read_text()

    # Mutate a self-built framework's checksum, not the first one in the file:
    # that belongs to a prebuilt dependency the gate deliberately ignores.
    recorded = manifest_of(repo)["libraries"]["libmpv"]["frameworks"]["Libmpv"]["checksum"]
    mutated = ("0" if recorded[0] != "0" else "1") + recorded[1:]
    package_path.write_text(good_package.replace(recorded, mutated), encoding="utf-8")
    result = run(repo, "verify", expect=1)
    check("checksum" in result.stdout, "a tampered Package.swift checksum is reported")
    package_path.write_text(good_package, encoding="utf-8")

    package_path.write_text(
        good_package.replace("/binaries/Libmpv-", "/binaries/Libmpv-stale-"), encoding="utf-8"
    )
    result = run(repo, "verify", expect=1)
    check("url" in result.stdout, "a tampered Package.swift url is reported")
    package_path.write_text(good_package, encoding="utf-8")

    # Sources moved on after the binaries were published: exactly the state a
    # commit must never be pinned in.
    (repo / "Sources/BuildScripts/patch/libmpv/0025-later.patch").write_text("x\n", encoding="utf-8")
    result = run(repo, "verify", expect=1)
    check("libmpv" in result.stdout, "a source change after publishing fails the gate")
    check(run(repo, "stale").stdout.split() == ["libmpv"], "and marks only libmpv stale")
    (repo / "Sources/BuildScripts/patch/libmpv/0025-later.patch").unlink()
    run(repo, "verify")

    # A developer's local path override must never be committed, but must not
    # get in the way of a local build either.
    package_path.write_text(
        good_package.replace(
            f'url: "https://github.com/edde746/MPVKit/releases/download/binaries/'
            f'{manifest_of(repo)["libraries"]["libmpv"]["frameworks"]["Libmpv"]["asset"]}",\n'
            f'            checksum: "{manifest_of(repo)["libraries"]["libmpv"]["frameworks"]["Libmpv"]["checksum"]}"',
            'path: "dist/release/Libmpv.xcframework.zip"',
        ),
        encoding="utf-8",
    )
    result = run(repo, "verify", expect=1)
    check("local path" in result.stdout, "a local path override fails the gate")
    result = run(repo, "verify", env={"MPVKIT_ALLOW_LOCAL_PATH": "1"})
    check("warning" in result.stdout, "and is a warning when explicitly allowed")
    result = run(repo, "render")
    check("left untouched" in result.stdout, "render leaves a local override alone")
    package_path.write_text(good_package, encoding="utf-8")
    check(
        (repo / "Sources/BuildScripts/binaries.json").read_text() == good_manifest,
        "none of the failure paths mutated the manifest",
    )
    print("gate: tampering, stale sources and local overrides all fail verify")

# 6. A build leg that did not produce every platform must not be recorded.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    for platform in ("ios", "macos"):
        build_artifacts(repo, platforms=[platform])
        run(repo, "record-platform", "--platform", platform, "--release-dir", "dist/release")
    result = run(repo, "record-frameworks", "--release-dir", "dist/release", expect=1)
    check(
        "refusing to record a partial entry" in (result.stdout + result.stderr),
        "a partial platform set is refused",
    )
    check(
        not (repo / "Sources/BuildScripts/binaries.json").exists(),
        "and nothing is written",
    )
    print("partial build: refused, manifest untouched")

# 7. Only the rebuilt libraries are re-recorded; the others keep their entries.
with tempfile.TemporaryDirectory() as tmp:
    repo = make_repo(tmp)
    publish(repo)
    before = manifest_of(repo)
    (repo / "Sources/BuildScripts/patch/libmpv/0025-later.patch").write_text("x\n", encoding="utf-8")
    check(run(repo, "stale").stdout.split() == ["libmpv"], "only libmpv is stale")
    publish(repo, libraries={"libmpv": ["libmpv"]})
    after = manifest_of(repo)
    check(
        after["libraries"]["FFmpeg"] == before["libraries"]["FFmpeg"],
        "an untouched library's entry survives a partial publish",
    )
    check(
        after["libraries"]["libmpv"] != before["libraries"]["libmpv"],
        "the rebuilt library's entry is replaced",
    )
    run(repo, "verify")
    print("incremental publish: only the stale library's entry changes")

if failures:
    print(f"\n{len(failures)} check(s) failed")
    sys.exit(1)

print("\nall checks passed")
PY
