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
# Deliberately NOT `git submodule update [--remote] --init --recursive` here:
# that command checks each submodule out to whatever SHA the umbrella
# repo's own index currently records for it, full stop — with or without
# --remote, regardless of what's actually checked out. A submodule sitting
# on local commits that were never pushed (this repo's own standing
# workflow: commit locally, push only when asked) would get silently
# detached back to the umbrella's stale recorded SHA, discarding that work
# from the working tree (the commits themselves would survive on the
# submodule's own local branch, but the umbrella would end up pointing at
# a rollback — this happened in practice before this loop was written).
# So each submodule is driven directly instead: init only if truly
# missing, then fetch+checkout its own origin/main — but only when it has
# no unpushed local commits to lose.
BUMPED=()
SKIPPED=()
for submod in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
  if [ ! -e "$submod/.git" ]; then
    git submodule update --init -- "$submod"
  fi

  git -C "$submod" fetch origin --quiet

  ahead=$(git -C "$submod" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  if [ "$ahead" -gt 0 ]; then
    echo "  ⚠ $submod has $ahead local commit(s) not on its own origin/main — skipping, push it from within $submod first."
    SKIPPED+=("$submod")
    continue
  fi

  # checkout main (creating it tracking origin/main on a fresh --init) then
  # fast-forward it — never `checkout origin/main` directly, which detaches
  # HEAD. Safe because the `ahead` check above already proved HEAD has
  # nothing origin/main lacks.
  git -C "$submod" checkout main --quiet 2>/dev/null || git -C "$submod" checkout -B main --track origin/main --quiet
  git -C "$submod" merge --ff-only origin/main --quiet

  if ! git diff --quiet -- "$submod"; then
    subject=$(git -C "$submod" log -1 --format=%s)
    git add "$submod"
    git commit -m "chore: bump $submod submodule — $subject" >/dev/null
    BUMPED+=("$submod")
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
