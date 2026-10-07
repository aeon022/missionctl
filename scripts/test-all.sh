#!/bin/bash
# Run vet + tests for every tool in an isolated environment, so nothing in the
# developer's shell (BUDGETCTL_DATA_DIR, API keys, ...) or real $HOME can
# redirect a test onto real data. Uses ./go.work if present (see TESTING.md).
# Usage: scripts/test-all.sh [tool ...]   (default: all)
set -uo pipefail
cd "$(dirname "$0")/.."

ALL=(missionctl-core mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl healthctl investctl postctl missionctl)
TOOLS=("${@:-${ALL[@]}}")

# Go's caches live under the real HOME — pin them before HOME is swapped.
export GOCACHE="$(go env GOCACHE)" GOMODCACHE="$(go env GOMODCACHE)" GOPATH="$(go env GOPATH)"
export HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT

# Anything that can point a tool at real data or a real account.
for v in $(env | cut -d= -f1 | grep -E '_(DATA_DIR|PROVIDER|API_KEY|REFRESH_TOKEN|HOST)$|^(OLLAMA_MODEL)$'); do unset "$v"; done

FAILED=()
for t in "${TOOLS[@]}"; do
  echo "══ $t"
  out=$( (cd "$t" && go vet ./... && go test -count=1 ./...) 2>&1 ); rc=$?
  grep -v 'no test files' <<<"$out" || true
  [ $rc -eq 0 ] || FAILED+=("$t")
done

echo
if [ ${#FAILED[@]} -eq 0 ]; then echo "✓ all green"; else echo "✗ failed: ${FAILED[*]}"; exit 1; fi
