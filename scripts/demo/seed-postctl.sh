#!/usr/bin/env bash
# Demo posts for the postctl GIF (runs inside the throwaway HOME).
set -e
mkdir -p posts && cd posts
d() { date -v+"$1"d -v"$2"H -v0M -v0S +%Y-%m-%dT%H:%M:%S%z | sed 's/\(..\)$/:\1/'; }
mk() { printf -- '---\nplatform: %s\ntitle: %s\ncampaign: launch\nschedule: %s\n---\n\n%s\n' "$1" "$2" "$3" "$4" > "$2.md"; }
mk mastodon "Release day" "$(d 1 9)" "postctl v0.5.0 is out: schedule once, publish everywhere, from the terminal."
mk bluesky "Release day bsky" "$(d 1 9)" "postctl v0.5.0 is out. Markdown in, scheduled posts out."
mk linkedin "Why a terminal" "$(d 2 11)" "Why I manage social media from the terminal: plain files, no tabs, one queue."
mk threads "Tip of the week" "$(d 3 17)" "Tip: postctl list shows everything that is scheduled, across platforms."
mk mastodon "Behind the scenes" "$(d 5 10)" "Behind the scenes: how the scheduler daemon keeps going when the laptop sleeps."
for f in *.md; do postctl import "$f" >/dev/null; done
