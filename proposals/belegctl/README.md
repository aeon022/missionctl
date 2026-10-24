# belegctl — Belegscanner (Entwurf, 2026-10-24)

Terminal-first Belegerfassung für die missionctl-Suite: Rechnungen/Quittungen (PDF, Foto) einlesen, Felder auslesen,
prüfen, mit Buchungen aus budgetctl abgleichen und für Steuerberatung/Förderabrechnung exportieren.
Name geprüft: `belegctl` ist auf GitHub, npm und Homebrew frei (2026-10-24). Anzeigename: **Belegscanner**.

## Entscheidungen

| Frage | Entscheidung | Warum |
|---|---|---|
| Wohin mit den Dateien? | Kopie nach `<data>/files/JJJJ/`, Original bleibt unberührt, Dedupe per SHA-256 | Verlustfrei; Quelle der Wahrheit bleibt dein Ordner (z. B. OneDrive) |
| Texterkennung | PDF-Textebene in reinem Go (`ledongthuc/pdf`); Fotos über macOS Vision (kleines Swift-Skript, optional); sonst „unklar“ | Kein Cloud-OCR, keine KI-Pflicht, keine Pflicht-Abhängigkeit |
| Auslesen | Regeln für AT/DE (Datum, Brutto, USt 20/10/13 %, Rechnungsnr., UID, IBAN, Lieferant) mit Status `ok`/`unklar` | Ehrlich statt geraten: Unsicheres wird markiert und von dir bestätigt |
| Geld | Ganzzahl in Cent | keine Rundungsfehler |
| Abgleich | `belegctl match` liest `budgetctl list --json`: gleicher Betrag, ±7 Tage, eindeutig; Mehrdeutiges wird gemeldet, nicht geraten | budgetctl bleibt unverändert, lose Kopplung wie im Dashboard |
| Privatsphäre | DB 0600, kein Netzwerk, Activity-Log nur „a receipt“ (nie Lieferant/Betrag), MCP liefert Felder, nie Dateipfade außerhalb des Datenordners | Beleg- und Geschäftsdaten |
| Export | CSV + nummerierte Dateikopien (ZIP-fähiger Ordner) nach Zeitraum/Projekt/Kostenposition | Förderabrechnung, Steuerberatung |

## Umfang v1 (diese Runde)
`add` (Datei/Ordner), `list`, `show`, `edit`, `delete`, `match`, `export`, `doctor`, `version`; Store + Parser + Tests.
Phase 2: MCP-Server (`list_receipts`, `add_receipt`, `search_receipts`, `unmatched_receipts`, `export_receipts`), TUI, README/GIF, goreleaser/CI.

## Bewusst nicht in v1
Cloud-OCR, E-Mail-Postfach-Import, Auto-Kategorisierung per KI (später optional im Bundle), Mehrwährungs-Umrechnung, E-Rechnung (XRechnung/ZUGFeRD) — Letzteres ist ein guter Phase-3-Kandidat, weil die Felder dort maschinenlesbar sind.

## Offen für dich
GitHub-Repo `aeon022/belegctl` (privat) anlegen und als Submodul einhängen — erst nach deinem Okay.
