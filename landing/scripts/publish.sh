#!/usr/bin/env bash
# Builds the landing page from source (deploy/landing-src) and syncs the
# output into the site-only publish worktree (deploy/landing). Does not
# push — review the diff in the publish worktree and push manually.
set -euo pipefail

SRC_DIR="/Users/gweiher/Developing/Projects/missionctl/.worktree-landing/landing"
PUBLISH_DIR="/Users/gweiher/Developing/Projects/missionctl/.worktree-landing-publish"

cd "$SRC_DIR"
npm run build

rsync -a --delete \
  --exclude '.git' \
  --exclude 'README.md' \
  "$SRC_DIR/dist/" "$PUBLISH_DIR/"

cd "$PUBLISH_DIR"
git add -A
git status --short

echo ""
echo "Review the diff above. Then:"
echo "  cd $PUBLISH_DIR && git commit -m '...' && git push origin deploy/landing"
