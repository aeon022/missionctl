#!/usr/bin/env bash
# Release one suite tool: preflight → tag → watch the release workflow → verify assets and the Homebrew formula.
#   scripts/release.sh mailctl v0.2.0           # preflight, asks before tagging
#   scripts/release.sh --check mailctl v0.2.0   # preflight only, changes nothing
#   scripts/release.sh --yes mailctl v0.2.0     # no confirmation prompt
# The tag push publishes a PUBLIC GitHub release (goreleaser) and updates aeon022/homebrew-tap. Not undoable cleanly.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mode=run; yes=0
while [[ "${1:-}" == --* ]]; do case "$1" in --check) mode=check;; --yes) yes=1;; *) echo "unknown flag $1"; exit 2;; esac; shift; done
tool="${1:?tool}"; ver="${2:?version like v0.2.0}"
[[ "$ver" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "version must look like v0.2.0"; exit 2; }
dir="$ROOT/$tool"; repo="aeon022/$tool"; [[ "$tool" == missionctl ]] && repo="aeon022/missionctl-cli"
[ -d "$dir/.git" ] || [ -f "$dir/.git" ] || { echo "no checkout $dir"; exit 1; }
fail=0; ok() { echo "  ✓ $*"; }; bad() { echo "  ✗ $*"; fail=1; }

echo "== $tool $ver — preflight"
cd "$dir"
[ -z "$(git status --porcelain)" ] && ok "working tree clean" || bad "uncommitted changes"
git fetch -q --tags
[ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ] && ok "HEAD == origin ($(git rev-parse --short HEAD))" || bad "HEAD differs from origin — push first"
git rev-parse -q --verify "refs/tags/$ver" >/dev/null && bad "tag $ver already exists" || ok "tag $ver is free"
prev="$(git tag --sort=-v:refname | head -1 || true)"; [ -n "$prev" ] && ok "previous tag $prev" || ok "first release"
[ -f .goreleaser.yaml ] && ok ".goreleaser.yaml present" || bad "no .goreleaser.yaml"
[ -f .github/workflows/release.yml ] && ok "release workflow present" || bad "no release workflow"
(go vet ./... >/dev/null 2>&1 && ok "go vet") || bad "go vet fails"
(HOME="$(mktemp -d)" go test ./... >/dev/null 2>&1 && ok "go test (throw-away HOME)") || bad "go test fails"
for t in linux darwin; do for a in amd64 arm64; do GOOS=$t GOARCH=$a CGO_ENABLED=0 go build -o /dev/null . 2>/dev/null && : || bad "build $t/$a fails"; done; done; ok "cross-builds linux/darwin × amd64/arm64"
st="$(gh run list --repo "$repo" --branch main --workflow ci --limit 1 --json conclusion,status -q '.[0] | "\(.status)/\(.conclusion)"' 2>/dev/null || true)"
[[ "$st" == completed/success ]] && ok "CI on main: success" || bad "CI on main: ${st:-unknown}"
gh secret list --repo "$repo" 2>/dev/null | grep -q HOMEBREW_TAP_TOKEN && ok "HOMEBREW_TAP_TOKEN set" || bad "HOMEBREW_TAP_TOKEN missing in $repo (the release still works, the Homebrew formula does not update)"
[ $fail -eq 0 ] || { echo "preflight failed"; exit 1; }
[ "$mode" = check ] && { echo "preflight ok (--check: nothing changed)"; exit 0; }

if [ $yes -eq 0 ]; then read -r -p "Tag $ver on $repo and publish a PUBLIC release? [y/N] " a; [[ "$a" == y* ]] || { echo aborted; exit 1; }; fi
git tag -a "$ver" -m "$tool $ver"; git push -q origin "$ver"; echo "tag pushed — waiting for the release workflow"
sleep 8; id="$(gh run list --repo "$repo" --workflow release --limit 1 --json databaseId -q '.[0].databaseId')"
gh run watch "$id" --repo "$repo" --exit-status >/dev/null && ok "release workflow finished" || { bad "release workflow failed: gh run view $id --repo $repo --log-failed"; exit 1; }

echo "== verify"
assets="$(gh release view "$ver" --repo "$repo" --json assets -q '.assets[].name')"
for want in darwin_arm64 darwin_amd64 linux_arm64 linux_amd64; do echo "$assets" | grep -q "${tool}_${ver#v}_${want}.tar.gz" && ok "asset $want" || bad "asset $want missing"; done
echo "$assets" | grep -q checksums.txt && ok "checksums.txt" || bad "checksums.txt missing"
f="$(gh api "repos/aeon022/homebrew-tap/contents/Formula/$tool.rb" -q .content 2>/dev/null | base64 -d || true)"
echo "$f" | grep -q "version \"${ver#v}\"" && ok "Homebrew formula is at ${ver#v}" || bad "formula not at ${ver#v} yet (tap token? re-check in a minute)"
echo "try it: brew update && brew install aeon022/tap/$tool && $tool --version"
exit $fail
