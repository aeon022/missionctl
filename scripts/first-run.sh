#!/bin/bash
# First-run check: every tool must answer a plain read command in a brand-new
# HOME (no data dir, no config) without an error. Catches "works on my machine"
# bugs like a missing data directory. Uses ./.dev/bin (scripts/dev-build.sh).
cd "$(dirname "$0")/.."
BIN=.dev/bin
[ -d "$BIN" ] || { echo "run scripts/dev-build.sh first"; exit 2; }
fail=0
while read -r tool args; do
  H=$(mktemp -d)
  out=$(env -i PATH=/usr/bin:/bin HOME="$H" "$BIN/$tool" $args 2>&1); rc=$?
  rm -rf "$H"
  if [ $rc -ne 0 ] || grep -qE '^Error:|panic:' <<<"$out"; then
    echo "✗ $tool $args  (rc=$rc): $(head -1 <<<"$out" | cut -c1-120)"; fail=1
  else
    echo "✓ $tool $args"
  fi
done <<'LIST'
taskctl list --json
calctl list --today
notectl list
mailctl inbox
budgetctl list --json
habctl list
timectl log --json
diaryctl list --json
postctl list
missionctl status
missionctl search test
LIST
exit $fail
