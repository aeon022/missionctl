#!/usr/bin/env bash
# Demo Obsidian vault for the notectl GIF (runs inside the throwaway HOME).
set -e
v="$HOME/vault"; mkdir -p "$v/Projects" "$v/Daily" "$v/Ideas"
cat > "$v/Projects/Launch plan.md" <<'N'
# Launch plan

Ship v0.5.0 on 1 November. See [[Release checklist]] and [[Support mails]].

- [ ] Final check of the live pages
- [ ] Release notes
N
cat > "$v/Projects/Release checklist.md" <<'N'
# Release checklist

1. Tag the release
2. Verify the Homebrew formula
3. Update the changelog

Back to [[Launch plan]].
N
cat > "$v/Projects/Support mails.md" <<'N'
# Support mails

Answer within 3 to 5 working days. Template replies live in [[Ideas/Reply templates]].
N
cat > "$v/Ideas/Reply templates.md" <<'N'
# Reply templates

Thanks for the report. Could you share the version and the exact steps?
N
printf '# %s\n\n- Planned the launch week\n- Reviewed [[Launch plan]]\n' "$(date +%F)" > "$v/Daily/$(date +%F).md"
