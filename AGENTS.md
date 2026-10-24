# Agent Instructions — missionctl

## Landing page: pushing `deploy/landing-src` alone does NOT deploy anything

`missionctl.sh` is served from the **`deploy/landing`** branch (the built
static output, pulled by Plesk). `deploy/landing-src` is only the Astro
*source* — pushing it changes nothing live. This has been forgotten
repeatedly; it is not optional or a "usually" — every landing-page content
change needs **both** steps below, always:

1. Edit in `.worktree-landing/landing/` (branch `deploy/landing-src`), commit + push there.
2. Build and publish the output:
   ```bash
   .worktree-landing/landing/scripts/publish.sh
   cd .worktree-landing-publish
   # review the diff the script printed
   git commit -m "build: ..." && git push origin deploy/landing
   ```

Full structural rules (worktree layout, branch purpose, cleanup) are in
[git-deploy.md](git-deploy.md) — read that before any landing-page work,
not just this summary. If a session only pushes `deploy/landing-src` and
reports the site as "updated", that report is wrong — verify step 2
actually happened (check `git log origin/deploy/landing` or the live
page) before telling the user it's live.

## Submodule pointers

Pushing inside a tool's own repo (e.g. `mailctl/`) does not update
`missionctl`'s tracked pointer to it. If the user cares about the bundle
repo reflecting the new commit, that needs its own `git add <tool> && git
commit && git push` from the `missionctl` root — see
[git-deploy.md](git-deploy.md) for the full daily workflow.

## notectl mirror: do NOT enable until checkbox sync is fixed

Do not set `mirror_apple_obsidian` / `sync_sources: apple,obsidian` for the
user's vault (`/Users/gweiher/Obsidian/Gerwin-Vault/`) before the TODO.md
section "notectl: Apple↔Obsidian-Mirror mit Checkboxen" is done. Apple
checklists must always sync as real checkboxes (user requirement, no
exceptions); the mirror currently loses them (`mirror.go` PushToApple
overwrites the body, Apple→Obsidian ignores `notes.ChecklistState`).
Details in stage.md (Nachtrag 2026-10-19).

## Modellwahl (Skill `modell-wahl`)
- Neues Tool: Entwurf und Datenmodell mit Opus, Umsetzung mit Sonnet, Kleinkram an `go-kleinkram` (Haiku).
- Vor jedem Push eines neuen Tools `pruefer` (Opus) aufrufen.
- Nur betroffene Dateien lesen; pro Tool ein Proposal unter `proposals/<name>/`.
