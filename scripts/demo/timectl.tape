Set Shell "bash"
Set FontSize 16
Set Width 1000
Set Height 560
Set Padding 12
Set TypingSpeed 40ms
Hide
Type `export PS1='$ '; timectl start seed >/dev/null; timectl stop >/dev/null; sqlite3 "$TIMECTL_DATA_DIR/time.db" "delete from entries; insert into entries(task,project,started_at,stopped_at) values ('Landing page copy','',strftime('%Y-%m-%dT07:30:00.000000000+02:00','now','localtime'),strftime('%Y-%m-%dT08:45:00.000000000+02:00','now','localtime')),('Release notes','',strftime('%Y-%m-%dT08:50:00.000000000+02:00','now','localtime'),strftime('%Y-%m-%dT09:20:00.000000000+02:00','now','localtime'));"; timectl start "Support mails" >/dev/null; clear`
Enter
Show
Type "timectl"
Enter
Sleep 2s
Down
Sleep 700ms
Tab
Sleep 1500ms
Type "q"
Sleep 500ms
