# `missionctl review` — Wochenrückblick (umgesetzt 2026-10-24 als `--plain`)

> **Stand:** `missionctl review` gab es schon (KI-Rückblick). Statt eines zweiten Befehls wurde er erweitert: `--plain`/`--json` (lokal, ohne KI, ohne Netzwerk), `--days`, `--money`. Neu dafür: `habctl stats --json`, `healthctl adherence --json` (nur Summen, nie Namen). Health und Investments gehen **nie** an einen KI-Anbieter (Test sichert das). Offen aus dem Entwurf: `--month`/Trends, `--to-note` (Daily Note), MCP-Prompt `weekly_review`, Diary-Highlights im Plain-Modus.


Aus den Daten aller Tools ein Rückblick: erledigte Aufgaben, Zeit pro Projekt, Gewohnheiten, Ausgaben, (nur Anzahl) Medikamente, Belege offen, Tagebuch-Highlights. Erweitert `missionctl status`/`agenda`, kein neues Tool.

## Entscheidungen
- `missionctl review [--week|--month] [--json]`, liest nur die `--json`-Ausgaben der installierten Tools (fehlendes Tool → Abschnitt entfällt).
- **Privat:** healthctl nur Zahlen („92 % Einnahmetreue“), nie Namen; investctl/budgetctl-Beträge nur, wenn `review.show_money: true` in der Config (Standard: aus).
- MCP-Prompt `weekly_review` (zusätzlich zu den Tools): Vorlage, die die Review-Daten holt und Fragen stellt („Was lief gut? Was streichen?“).
- Ausgabe auch als Notiz: `--to-note` schreibt über notectl in die Daily Note (nie überschreiben, nur anhängen).
## Nicht in v1
Trends über mehrere Wochen, KI-Zusammenfassung (später optional im Bundle).
