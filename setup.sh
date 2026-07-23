#!/bin/bash
# missionctl suite — builds and installs every tool into ~/.local/bin
# in one pass by running each subproject's own setup.sh in turn. Those
# scripts also create config dirs, prompt for optional permissions
# (Full Disk Access, MCP registration), so run this in an interactive
# terminal for the full experience.

cd "$(dirname "$0")"

TOOLS=(mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl postctl missionctl)
FAILED=()

for t in "${TOOLS[@]}"; do
  echo ""
  echo "════════════════════════════════════════"
  echo "  $t"
  echo "════════════════════════════════════════"
  if [ ! -f "$t/setup.sh" ]; then
    echo "⚠ no setup.sh in $t/, skipping"
    FAILED+=("$t (no setup.sh)")
    continue
  fi
  if ! (cd "$t" && ./setup.sh); then
    echo "✗ $t setup failed"
    FAILED+=("$t")
  fi
done

echo ""
echo "════════════════════════════════════════"
if [ ${#FAILED[@]} -eq 0 ]; then
  echo "✓ All ${#TOOLS[@]} tools installed."
else
  echo "✗ ${#FAILED[@]} tool(s) failed: ${FAILED[*]}"
fi
echo "════════════════════════════════════════"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    echo ""
    echo "⚠ ~/.local/bin is not on your \$PATH. Add this to your shell profile:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

if command -v missionctl >/dev/null 2>&1; then
  echo ""
  missionctl doctor
fi
