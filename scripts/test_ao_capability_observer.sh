#!/usr/bin/env bash
# Regression test for the compressed-audio capability observer in
# patch/libmpv/0010-avfoundation-eac3-joc-dec3.patch.
#
# ao_avfoundation.m only exists after the patches are applied to an mpv
# checkout, and MPVKit vends prebuilt xcframeworks rather than compiling from
# source, so there is no target a normal unit test could link against. Instead
# this extracts the real spdif_reevaluate_capabilities() text out of the patch
# and compiles it against stubs, so the shipped decision logic is what runs.
#
# Guards the edge-triggered contract: capability loss falls back to PCM exactly
# once, regained capability retries native audio exactly once, unchanged
# capability does nothing, and flapping cannot produce a reload loop.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
patch_file="$root/Sources/BuildScripts/patch/libmpv/0010-avfoundation-eac3-joc-dec3.patch"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

python3 - "$patch_file" "$work/extracted.inc" <<'PY'
import re, sys
patch = open(sys.argv[1], encoding="utf-8").read()
# Added lines in a unified diff are prefixed with '+'.
added = "\n".join(l[1:] for l in patch.splitlines() if l.startswith("+") and not l.startswith("+++"))
m = re.search(r"static void spdif_reevaluate_capabilities\(struct ao \*ao, const char \*reason\)\n\{.*?\n\}\n",
              added, re.S)
if not m:
    sys.exit("spdif_reevaluate_capabilities() not found in the patch; "
             "update this test if the function was renamed or removed")
open(sys.argv[2], "w", encoding="utf-8").write(m.group(0))
PY

cp "$root/scripts/test_ao_capability_observer.c" "$work/harness.c"
cc -std=c11 -Wall -Wextra -Werror -I"$work" -o "$work/harness" "$work/harness.c"
"$work/harness"
