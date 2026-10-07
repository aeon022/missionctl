#!/bin/bash
# Build every tool from the current checkout into ./.dev/bin — nothing is
# installed, ~/.local/bin and ~/.claude.json are untouched. See TESTING.md.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .dev/bin
for t in mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl healthctl investctl postctl missionctl; do
  (cd "$t" && go build -o "../.dev/bin/$t" .) && echo "✓ $t"
done
