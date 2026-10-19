#!/usr/bin/env bash
# Weekly numbers, read-only, aggregated: GitHub stars and release downloads per repo.
# Usage: scripts/metrics.sh [--csv]   (--csv appends one line per repo to docs/metrics.csv)
# Polar sales are not read here: the API token has no orders scope, check the Polar dashboard.
set -euo pipefail
repos="mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl missionctl-cli postctl homebrew-tap"
day=$(date +%F); csv=${1:-}; out="$(cd "$(dirname "$0")/.." && pwd)/docs/metrics.csv"
if [ "$csv" = "--csv" ] && [ ! -f "$out" ]; then echo "date,repo,stars,forks,downloads" > "$out"; fi
printf "%-16s %6s %6s %10s\n" repo stars forks downloads
for r in $repos; do
  info=$(gh api "repos/aeon022/$r" --jq '"\(.stargazers_count) \(.forks_count)"' 2>/dev/null || echo "0 0")
  dl=$(gh api "repos/aeon022/$r/releases" --paginate --jq '[.[].assets[].download_count] | add // 0' 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo 0)
  set -- $info
  printf "%-16s %6s %6s %10s\n" "$r" "$1" "$2" "${dl:-0}"
  if [ "$csv" = "--csv" ]; then echo "$day,$r,$1,$2,${dl:-0}" >> "$out"; fi
done
