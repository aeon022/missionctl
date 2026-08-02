#!/bin/bash
# missionctl sync — pulls the umbrella repo, updates every submodule to its
# own origin/main, and records each pointer bump as its own commit. Never
# pushes; that stays a manual step.

set -euo pipefail
cd "$(dirname "$0")"

if ! git diff --quiet --ignore-submodules HEAD || ! git diff --quiet --cached --ignore-submodules HEAD; then
  echo "✗ working tree has uncommitted changes outside submodules — commit or stash first."
  exit 1
fi

echo "↳ pulling missionctl..."
git pull --ff-only

echo "↳ updating submodules to their origin/main..."
git submodule update --remote --init --recursive

BUMPED=()
for path in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
  if ! git diff --quiet -- "$path"; then
    subject=$(git -C "$path" log -1 --format=%s)
    git add "$path"
    git commit -m "chore: bump $path submodule — $subject" >/dev/null
    BUMPED+=("$path")
  fi
done

echo ""
if [ ${#BUMPED[@]} -eq 0 ]; then
  echo "✓ everything already up to date."
else
  echo "✓ bumped ${#BUMPED[@]} submodule(s): ${BUMPED[*]}"
  echo "  (committed locally — not pushed)"
fi
