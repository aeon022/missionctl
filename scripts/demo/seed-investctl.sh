#!/usr/bin/env bash
# Fictional portfolio for the investctl GIF (runs inside the throwaway HOME; no network).
set -e
investctl add-holding VWCE --name "World ETF" --type etf --currency EUR >/dev/null
investctl add-holding SAP --name "SAP SE" --type stock --currency EUR >/dev/null
investctl add-holding AGGH --name "Global Bond ETF" --type etf --currency EUR >/dev/null
investctl add-transaction VWCE buy --qty 40 --price 98.20 --date 2025-11-03 >/dev/null
investctl add-transaction VWCE buy --qty 25 --price 109.40 --date 2026-04-07 >/dev/null
investctl add-transaction SAP buy --qty 12 --price 212.00 --date 2026-01-12 >/dev/null
investctl add-transaction AGGH buy --qty 150 --price 4.86 --date 2026-02-02 >/dev/null
investctl add-transaction SAP dividend --qty 12 --price 2.35 --date 2026-06-01 >/dev/null
db="$INVESTCTL_DATA_DIR/investctl.db"
for p in "VWCE 112.80 111.90" "SAP 236.40 233.10" "AGGH 4.79 4.80"; do
  set -- $p
  sqlite3 "$db" "insert or replace into prices(symbol,date,close) values ('$1',date('now','-1 day'),$3),('$1',date('now'),$2);"
done
