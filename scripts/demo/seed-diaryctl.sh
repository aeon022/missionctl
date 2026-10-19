#!/usr/bin/env bash
# Demo entries for the diaryctl GIF (runs inside the throwaway HOME).
set -e
diaryctl today >/dev/null 2>&1 || true
db="$DIARYCTL_DATA_DIR/diary.db"
bodies=("Fixed the scheduler timeout and wrote the release notes." "Quiet day. Reviewed pull requests, tidied the backlog." "Shipped the theme picker. Long walk in the evening." "Support mails, two small bug fixes, a good run." "Planned next week; drafted the launch post.")
for i in 0 1 2 3 4 5 6 8 9 10 12 13 15; do
  b=${bodies[$((i % 5))]}
  sqlite3 "$db" "insert or replace into entries(date,body,generated) values (date('now','-$((i+1)) day','localtime'),'$b',0);"
done
