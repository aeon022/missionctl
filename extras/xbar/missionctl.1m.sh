#!/usr/bin/env bash
# <xbar.title>missionctl: timer + habits</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>abteilung83</xbar.author>
# <xbar.desc>Menu bar view of timectl (running timer, stop) and habctl (today's habits, check them off).</xbar.desc>
# <xbar.dependencies>timectl,habctl</xbar.dependencies>
# <xbar.abouturl>https://missionctl.sh</xbar.abouturl>
#
# Works in xbar and SwiftBar. Copy to the plugin folder (name = refresh rate: .1m = every minute):
#   cp missionctl.1m.sh ~/Library/Application\ Support/xbar/plugins/ && chmod +x ~/Library/Application\ Support/xbar/plugins/missionctl.1m.sh

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
T=$(command -v timectl) H=$(command -v habctl)
[ -z "$T$H" ] && { echo "missionctl: not installed"; echo "---"; echo "Install: https://missionctl.sh | href=https://missionctl.sh"; exit 0; }

status=$([ -n "$T" ] && "$T" status 2>/dev/null)
open=0 done=0
habits=$([ -n "$H" ] && "$H" today --json 2>/dev/null | python3 -c '
import json, sys
try: items = json.load(sys.stdin).get("data") or []
except Exception: items = []
for h in items: print(("1" if h.get("checked_today") else "0") + "\t" + str(h.get("streak", 0)) + "\t" + h.get("name", ""))
')
total=$(printf '%s' "$habits" | grep -c .) ; done=$(printf '%s' "$habits" | grep -c '^1')

# menu bar line: the running timer wins, otherwise the habit count
case "$status" in
  "▶"*) echo "${status%% — *} | color=#22c55e" ;;
  *)    [ "$total" -gt 0 ] && echo "◔ $done/$total" || echo "◔" ;;
esac
echo "---"

if [ -n "$T" ]; then
  echo "TIMER | size=11 color=gray"
  case "$status" in
    "▶"*) echo "$status"; echo "Stop timer | shell=$T param1=stop terminal=false refresh=true" ;;
    *)    echo "No timer running" ;;
  esac
  echo "Open timectl | shell=$T terminal=true"
  echo "---"
fi

if [ -n "$H" ] && [ "$total" -gt 0 ]; then
  echo "HABITS TODAY | size=11 color=gray"
  printf '%s\n' "$habits" | while IFS=$'\t' read -r checked streak name; do
    [ -z "$name" ] && continue
    if [ "$checked" = 1 ]; then echo "✓ $name  ·  ${streak}d | color=gray"
    else echo "○ $name  ·  ${streak}d | shell=$H param1=check param2=\"$name\" terminal=false refresh=true"; fi
  done
  echo "Open habctl | shell=$H terminal=true"
fi
