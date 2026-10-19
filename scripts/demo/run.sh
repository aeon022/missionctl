#!/usr/bin/env bash
# Renders a demo GIF per tool from scripts/demo/<tool>.tape with throwaway data.
# Usage: scripts/demo/run.sh <tool> [outdir]   (needs vhs; never touches real data)
set -euo pipefail
tool=${1:?tool}; out=${2:-$(cd "$(dirname "$0")" && pwd)/out}
here=$(cd "$(dirname "$0")" && pwd); mkdir -p "$out"
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
mkdir -p "$D/home" "$D/data"
export HOME="$D/home" XDG_CONFIG_HOME="$D/home/.config"
for v in MAIL CAL TASK NOTE BUDGET HAB TIME DIARY; do export "${v}CTL_DATA_DIR=$D/data"; done
export DEMO_DIR="$here"
cd "$D" && vhs "$here/$tool.tape" -o "$out/$tool.gif"
