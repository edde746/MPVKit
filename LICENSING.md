# Licensing

This fork is **GPL-3.0-only**, from the commit that added this file onward. Upstream
[mpvkit/MPVKit](https://github.com/mpvkit/MPVKit) is LGPL-3.0; LGPL-3.0 is GPL-3.0 plus additional
permissions, and LGPL-3.0 §2(b) together with GPL-3.0 §7 ¶2 allow a recipient to convey the material
with those permissions removed. That is what this fork does.

The change is prospective. Every commit up to and including `b8b922ec74b84ac3a496e29e226a3a3e91491045`
was published under LGPL-3.0, and those versions remain available under those terms.

---

## Which licence covers what

| | Licence |
|---|---|
| **This fork's own source** — Swift package wrapper, build scripts, CI, tooling, docs | **GPL-3.0-only.** See [`LICENSE`](LICENSE). |
| **Patches under `Sources/BuildScripts/patch/` that originate here** | **GPL-3.0-only**, except the three listed below. |
| **The build output** — the `Libmpv`, `Libav*` and `Libsw*` xcframeworks | **GPL-3.0.** FFmpeg is configured `--enable-gpl --enable-version3` and mpv `-Dgpl=true`. |

Upstream-derived files keep their copyright — © cxfksword and the mpvkit contributors — and are
conveyed here under GPL-3.0 with the LGPL's additional permissions removed. Their upstream copies
remain available from mpvkit/MPVKit under LGPL-3.0; nothing here restricts that.

### Patches that keep their own terms

Not ours to relicense:

| Patch | Origin | Licence |
|---|---|---|
| `libmpv/0001-player-add-moltenvk-context.patch` | cxfksword (upstream mpvkit) | LGPL-3.0, as received |
| `libmpv/0002-revert-build-static.patch` | cxfksword (upstream mpvkit) | LGPL-3.0, as received |
| `libmpv/0004-avfoundation-video-output.patch` | Alex Kim | LGPL-2.1-or-later, per the mpv header the patch installs in `video/out/vo_avfoundation.m` |

Every other patch in `Sources/BuildScripts/patch/` is original work of this fork and carries an
`SPDX-License-Identifier: GPL-3.0-only` notice.

### Why GPL-3.0-only is available for patches to LGPL files

The mpv and FFmpeg files these patches modify carry LGPL-2.1-or-later headers, and LGPL-2.1 §3
permits conveying a copy under the GNU GPL version 2 or any later version. Our modifications are
therefore offered under GPL-3.0-only, and the patched files are GPL-3.0 as a whole. The unmodified
upstream files are unaffected and remain available from mpv and FFmpeg under their own terms.

Practical consequence: **there is no LGPL build of this patch series.** Applying these patches
produces a GPL-3.0 libmpv/FFmpeg, which cannot be linked into a proprietary application.

### What this does not cover

The build scripts are a tool, not a component of what they build: no code from
`Sources/BuildScripts/XCFrameworkBuild/` is linked into the resulting libraries. A fork that removes
the patches listed as ours can still use this recipe to produce an LGPL library, and the GPL applies
only to its copy of the recipe.

---

## Bundled third-party libraries

Each keeps its own licence, unchanged by any of this, and all are GPL-3.0-compatible: libass (ISC),
libdav1d and libuavs3d (BSD), libplacebo, libfribidi, libuchardet and libbluray (LGPL-2.1+), libdovi,
lcms2 and harfbuzz (MIT), MoltenVK, libshaderc and OpenSSL 3.x (Apache-2.0), libunibreak (zlib),
freetype (FTL or GPLv2).

---

## Obtaining the source

Everything needed to reproduce the libraries is in this repository: the build scripts fetch upstream
mpv and FFmpeg at pinned versions, and every local modification is a patch file under
`Sources/BuildScripts/patch/`. `make build` reproduces the output.

If you received a binary built from this repository and want the corresponding source, the commit it
was built from is the authoritative answer — release assets are content-addressed per commit. Open an
issue if a build is not identified.
