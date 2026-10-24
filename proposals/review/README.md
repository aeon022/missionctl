# `missionctl review` — Wochen-/Monatsrückblick (Entwurf, 2026-10-24)

Aus den Daten aller Tools ein Rückblick: erledigte Aufgaben, Zeit pro Projekt, Gewohnheiten, Ausgaben, (nur Anzahl) Medikamente, Belege offen, Tagebuch-Highlights. Erweitert `missionctl status`/`agenda`, kein neues Tool.

## Entscheidungen
- `missionctl review [--week|--month] [--json]`, liest nur die `--json`-Ausgaben der installierten Tools (fehlendes Tool → Abschnitt entfällt).
- **Privat:** healthctl nur Zahlen („92 % Einnahmetreue“), nie Namen; investctl/budgetctl-Beträge nur, wenn `review.show_money: true` in der Config (Standard: aus).
- MCP-Prompt `weekly_review` (zusätzlich zu den Tools): Vorlage, die die Review-Daten holt und Fragen stellt („Was lief gut? Was streichen?“).
- Ausgabe auch als Notiz: `--to-note` schreibt über notectl in die Daily Note (nie überschreiben, nur anhängen).
## Nicht in v1
Trends über mehrere Wochen, KI-Zusammenfassung (später optional im Bundle).
