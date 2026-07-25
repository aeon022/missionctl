# missionctl.sh — published site (do not edit here)

This branch (`deploy/landing`) contains only the built static site — this
is what Plesk pulls and serves directly as the domain's document root.

- Source lives on branch `deploy/landing-src` (worktree `.worktree-landing/`, Astro project in `landing/`).
- To publish a change: edit + `npm run build` in `.worktree-landing/landing`, then
  copy the fresh `landing/dist/*` into this worktree (`.worktree-landing-publish/`),
  commit, and push. Or run `.worktree-landing/landing/scripts/publish.sh`.
