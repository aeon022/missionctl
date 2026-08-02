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
git submodule update --init --recursive

BUMPED=()
SKIPPED=()
for path in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
  git -C "$path" fetch origin --quiet

  # A submodule can carry local commits that were never pushed (this
  # repo's own workflow: commit locally, push only when asked). Blindly
  # doing `git submodule update --remote` here would detach HEAD onto
  # origin/main's tip regardless, silently discarding those commits from
  # the working tree — they'd still exist on the submodule's local branch,
  # but the umbrella repo would end up pointing at a rollback. Skip any
  # submodule that's currently ahead of its own origin/main instead of
  # clobbering it.
  ahead=$(git -C "$path" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  if [ "$ahead" -gt 0 ]; then
    echo "  ⚠ $path has $ahead local commit(s) not on its own origin/main — skipping, push it from within $path first."
    SKIPPED+=("$path")
    continue
  fi

  git -C "$path" checkout origin/main --quiet

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
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "⚠ skipped ${#SKIPPED[@]} submodule(s) with unpushed local commits: ${SKIPPED[*]}"
fi
