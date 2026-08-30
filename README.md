# MPVKit

[![mpv](https://img.shields.io/badge/mpv-v0.41.0-blue.svg)](https://github.com/mpv-player/mpv)
[![ffmpeg](https://img.shields.io/badge/ffmpeg-n8.0.1-blue.svg)](https://github.com/FFmpeg/FFmpeg)
[![license](https://img.shields.io/github/license/edde746/MPVKit)](LICENSE)

> MPVKit is only suitable for learning `libmpv` and will not be maintained too frequently.

`MPVKit` is a collection of tools to use `mpv` in `iOS`, `macOS`, `tvOS` applications.

It includes scripts to build `mpv` native libraries.

Forked from [kingslay/FFmpegKit](https://github.com/kingslay/FFmpegKit)

## About Metal support

Metal support only a patch version ([#7857](https://github.com/mpv-player/mpv/pull/7857)) and does not officially support it yet. Encountering any issues is not strange. 

## Installation

### Swift Package Manager

```
https://github.com/mpvkit/MPVKit.git
```

### License

This fork is **GPL-3.0-only**, and ships a GPL build. See [LICENSING.md](LICENSING.md) for what that
covers, plus [FFmpeg details](https://github.com/FFmpeg/FFmpeg/blob/master/LICENSE.md) and
[mpv details](https://github.com/mpv-player/mpv/blob/master/Copyright).

### Pinning a commit

Every push to `main` publishes the binaries that commit needs, so a consumer can
pin any commit and get artifacts built from exactly its sources. In Xcode, add
the package with `Branch/Commit` -> the commit SHA (`kind = revision` in
`project.pbxproj`); semver tags keep working for anyone who wants them.

Binaries are content-addressed: an asset name carries a 12-character key derived
from the library's upstream version, its patch series, the build flags, the
platform set, the build scripts and the toolchain generation. Assets are
therefore immutable and all live in one rolling
[`binaries`](https://github.com/edde746/MPVKit/releases/tag/binaries) prerelease;
a semver release is a tag plus notes and carries no assets of its own.
`Sources/BuildScripts/binaries.json` records which asset belongs to which
library, and `scripts/binary_keys.py verify` is the gate that keeps every commit
on `main` pinnable:

```bash
# what this working tree needs, and whether it is already published
python3 scripts/binary_keys.py keys
python3 scripts/binary_keys.py stale
# fail if the committed manifest or Package.swift do not describe this tree
python3 scripts/binary_keys.py verify
```

A commit that touches only `Sources/BuildScripts/patch/libmpv/*` moves libmpv's
key alone, so CI compiles libmpv and restores libass and FFmpeg from their
published thin install trees. Editing any build script moves every key, on
purpose: under-invalidating would ship stale binaries. To force a full rebuild
without a source change -- a new Xcode or SDK, a miscompile -- bump the
generation in `Sources/BuildScripts/toolchain.txt`.


## How to build

```bash
make build
# specified platforms (ios,macos,tvos,tvsimulator,isimulator,maccatalyst,xros,xrsimulator)
make build platform=ios,macos
# clean all build temp files and cache
make clean
# see help
make help
```

## Make demo app using the local build version

If you want the demo app to use the local build version, you need to modify `Package.swift` to reference the local build xcframework file.

<details>
<summary>Click here for more information.</summary>
  
```
.binaryTarget(
    name: "Libmpv",
    path: "dist/release/Libmpv.xcframework.zip"
),
.binaryTarget(
    name: "Libavcodec",
    path: "dist/release/Libavcodec.xcframework.zip"
),
.binaryTarget(
    name: "Libavdevice",
    path: "dist/release/Libavdevice.xcframework.zip"
),
.binaryTarget(
    name: "Libavformat",
    path: "dist/release/Libavformat.xcframework.zip"
),
.binaryTarget(
    name: "Libavfilter",
    path: "dist/release/Libavfilter.xcframework.zip"
),
.binaryTarget(
    name: "Libavutil",
    path: "dist/release/Libavutil.xcframework.zip"
),
.binaryTarget(
    name: "Libswresample",
    path: "dist/release/Libswresample.xcframework.zip"
),
.binaryTarget(
    name: "Libswscale",
    path: "dist/release/Libswscale.xcframework.zip"
),
```

</details>

## Run default mpv player

```bash
./mpv.sh --input-commands='script-message display-stats-toggle' [url]
./mpv.sh --list-options
```

> Use <kbd>Shift</kbd>+<kbd>i</kbd> to show stats overlay

## Related Projects

* [moltenvk-build](https://github.com/mpvkit/moltenvk-build)
* [libplacebo-build](https://github.com/mpvkit/libplacebo-build)
* [libdovi-build](https://github.com/mpvkit/libdovi-build)
* [libshaderc-build](https://github.com/mpvkit/libshaderc-build)
* [libluajit-build](https://github.com/mpvkit/libluajit-build)
* [libass-build](https://github.com/mpvkit/libass-build)
* [libbluray-build](https://github.com/mpvkit/libbluray-build)

## Donation

If you appreciate my current work, you can buy me a cup of coffee ☕️.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/C0C410P7UN)

## License

This fork's own source is **GPL-3.0-only** (see [`LICENSE`](LICENSE)), and so are the patches under
`Sources/BuildScripts/patch/` that originate here. The `MPVKit` bundles (`frameworks`,
`xcframeworks`), which include both `libmpv` and `FFmpeg`, are licensed under the GPL v3.0.

Upstream [mpvkit/MPVKit](https://github.com/mpvkit/MPVKit) is LGPL-3.0; this fork removes the
additional permissions as LGPL-3.0 §2(b) and GPL-3.0 §7 allow. Full breakdown, including the
third-party patches that keep their own terms: [LICENSING.md](LICENSING.md).
