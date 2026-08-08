#!/usr/bin/env bash
# Simulation test for the vo_avfoundation timebase servo
# (patch/libmpv/0016-avfoundation-timebase-rate-servo.patch).
#
# The servo decision function is extracted VERBATIM from the patched mpv
# source (the marked "avf sync servo core" region, which is deliberately
# freestanding C) and compiled into a harness that models the CMTimebase and
# mpv's audio-slaved frame schedule under realistic clock disturbances. See
# test_avf_timebase_servo.c for the scenarios and invariants.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$root/dist/libmpv-v0.41.0/video/out/vo_avfoundation.m"

if [[ ! -f "$src" ]]; then
    echo "skip: $src not present (run a build first to materialize dist/)" >&2
    exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

sed -n '/--- avf sync servo core/,/--- end avf sync servo core/p' "$src" \
    > "$workdir/servo_core.inc"

if ! grep -q "avf_servo_rate" "$workdir/servo_core.inc"; then
    echo "FAIL: servo core region not found in $src" >&2
    exit 1
fi

cc -O2 -std=c11 -Wall -Wextra -Werror -I"$workdir" \
    -o "$workdir/test" "$root/scripts/test_avf_timebase_servo.c" -lm

"$workdir/test"
