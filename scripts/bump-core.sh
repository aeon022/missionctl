#!/bin/bash
# Point every tool at the current missionctl-core origin/main, tidy, verify
# (build + test) and commit "chore: bump missionctl-core" per tool. Refuses
# to run while missionctl-core has commits that aren't pushed — a pin to an
# unpushed commit can't resolve for anyone else. Never pushes.
set -euo pipefail
cd "$(dirname "$0")/.."

git -C missionctl-core fetch -q
if [ "$(git -C missionctl-core rev-list --count origin/main..HEAD)" -gt 0 ]; then
  echo "✗ missionctl-core has unpushed commits — push it first."; exit 1
fi

# Resolve against the real module proxy, not a local go.work; direct, so a
# just-pushed commit doesn't have to wait for proxy.golang.org to see it.
export GOWORK=off GOPROXY=direct GOFLAGS=-mod=mod
# Same isolation as scripts/test-all.sh: tests must never see real data dirs.
export GOCACHE="$(go env GOCACHE)" GOMODCACHE="$(go env GOMODCACHE)" GOPATH="$(go env GOPATH)"
REAL_HOME="$HOME"; export HOME="$(mktemp -d)"; trap 'rm -rf "$HOME"' EXIT
export GIT_CONFIG_GLOBAL="$REAL_HOME/.gitconfig"
for v in $(env | cut -d= -f1 | grep -E '_(DATA_DIR|PROVIDER|API_KEY|REFRESH_TOKEN|HOST)$'); do unset "$v"; done
for t in mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl postctl missionctl; do
  (
    cd "$t"
    go get github.com/aeon022/missionctl-core@main >/dev/null
    go mod tidy
    if git diff --quiet -- go.mod go.sum; then echo "· $t already current"; exit 0; fi
    go build ./... && go test ./... >/dev/null
    git add go.mod go.sum
    git commit -q -m "chore: bump missionctl-core" -m "Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
    echo "✓ $t bumped"
  )
done
echo "Now: ./sync.sh (or git add <tools> && commit) to record the new pointers in the umbrella repo."
