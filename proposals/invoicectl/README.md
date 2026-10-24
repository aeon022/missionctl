# invoicectl — Ausgangsrechnungen (Entwurf, 2026-10-24)

timectl exportiert Rechnungen, danach endet der Faden. invoicectl führt ihn weiter: Rechnung erzeugen, Status offen/bezahlt, Zahlungseingang aus budgetctl erkennen, Erinnerung bei Verzug. Name `invoicectl` frei (geprüft 2026-10-24).

## Entscheidungen
| Frage | Entscheidung |
|---|---|
| Nummernkreis | fortlaufend `JJJJ-NNN`, lückenlos, nie wiederverwendet (AT: Pflicht) — gelöschte Rechnungen werden **storniert**, nicht gelöscht |
| Pflichtangaben AT (§ 11 UStG) | Prüfliste vor dem Erzeugen: Name/Anschrift beider Seiten, UID, Datum, Leistung, Entgelt, USt-Satz/-Betrag; fehlt etwas → Fehler, keine Rechnung |
| Ausgabe | Markdown/HTML → PDF; E-Rechnung (XRechnung/ZUGFeRD) als Phase 2 |
| Zahlungseingang | `match` gegen `budgetctl list --json` (Betrag + Rechnungsnummer im Verwendungszweck), nur eindeutig |
| Quelle der Positionen | `timectl`-Zeiten (`invoicectl from-time PROJEKT --month`) oder manuell |
| Haftung | Hilfsmittel, **keine Steuerberatung**; Hinweis im README |

## v1
`new`, `list`, `show`, `send` (PDF erzeugen, **nicht** versenden), `paid`, `cancel`, `match`, `overdue`, MCP, `doctor`. Abhängigkeit: timectl-JSON, budgetctl-JSON.
## Offen
PDF-Erzeugung ohne Fremdabhängigkeit (HTML → `cupsfilter`/WebKit?) klären; Rechtstexte durch Steuerberatung prüfen lassen.
