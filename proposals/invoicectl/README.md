# invoicectl — Ausgangsrechnungen (Entwurf v2, 2026-10-24)

timectl exportiert Rechnungen als Markdown, danach endet der Faden. invoicectl führt ihn weiter:
Rechnung erzeugen → ausstellen (lückenlos nummeriert, danach unveränderlich) → Zahlungseingang aus budgetctl erkennen → Verzug melden.
Name `invoicectl` ist auf GitHub, npm und Homebrew frei (geprüft 2026-10-24).

> **Haftung:** Hilfsmittel, **keine Steuer- oder Rechtsberatung.** Alle Aussagen zu österreichischem Recht unten sind mein Kenntnisstand und
> **von der Steuerberatung zu bestätigen**, bevor das Tool für echte Rechnungen genutzt wird (Punkt „Rechtliche Prüfung“ im TODO läuft ohnehin).

---

## 1. Grundsätze (nicht verhandelbar)

1. **Eine ausgestellte Rechnung ist unveränderlich.** Korrektur nur per **Storno** (eigene Rechnung mit eigener Nummer, negative Positionen, Verweis auf das Original) und ggf. neue Rechnung. Nichts wird gelöscht oder überschrieben. Durchgesetzt **in der Datenbank** (SQLite-Trigger), nicht nur im Code.
2. **Nummern sind lückenlos.** Entwürfe haben **keine** Nummer. Die Nummer wird erst beim Ausstellen vergeben, in derselben Transaktion, die den Status ändert: scheitert etwas, wird keine Nummer verbraucht.
3. **Nichts Unvollständiges wird ausgestellt.** `issue` läuft zuerst die Prüfliste (Abschnitt 4) und listet **alle** Fehler auf; ohne Fehler keine Nummer.
4. **Nie raten.** Zahlungszuordnung nur eindeutig (wie bei belegctl); Mehrdeutiges wird gemeldet.
5. **Lokal.** Kein Netzwerk, DB und Dateien 0600, Activity-Log nur „an invoice“ (nie Kunde oder Betrag).
6. **Kein Versand.** invoicectl erzeugt das PDF; verschicken tust du.

## 2. Datenmodell (SQLite)

Geld in **Cent** (Ganzzahl), Mengen in **Tausendstel**, Steuersätze in **Basispunkten** (2000 = 20 %). Datum `YYYY-MM-DD`.

```sql
issuers (                       -- ein Profil je Aussteller (z. B. "abteilung83", "bruecke"), wie budgetctl-Profile
  id, key UNIQUE, name, address, country, uid, register_no,   -- UID, FN-/ZVR-Nr.
  iban, bic, email, phone, website,
  vat_regime,                   -- 'standard' | 'small_business' (Kleinunternehmer)
  default_vat_bp, payment_days, number_format,  -- z. B. '{YYYY}-{NNN}'
  footer_text, currency DEFAULT 'EUR'
)
customers (
  id, issuer_id, name, address, country, uid, email, is_business, notes
)
invoices (
  id, issuer_id,
  number,                       -- NULL bis zum Ausstellen; UNIQUE(issuer_id, number)
  series,                       -- z. B. '2026' (Nummernkreis)
  status,                       -- 'draft' | 'issued'   (bezahlt/überfällig/storniert sind ABGELEITET, nicht gespeichert)
  customer_id,
  -- Momentaufnahme des Kunden beim Ausstellen (unveränderlich, auch wenn der Kunde später geändert wird):
  c_name, c_address, c_country, c_uid,
  issue_date, service_from, service_to,     -- Leistungszeitpunkt bzw. -zeitraum (Pflicht)
  due_date, currency, payment_ref, notes,
  vat_note,                     -- Pflichttext bei 0 % (Kleinunternehmer, Reverse Charge, Ausfuhr …)
  net_cents, vat_cents, gross_cents,        -- beim Ausstellen berechnet und eingefroren
  cancels_id,                   -- Storno: verweist auf das Original
  issued_at, pdf_sha256, created_at
)
invoice_lines (
  invoice_id, pos, description, qty_milli, unit, unit_net_cents, vat_bp,
  source_ref                    -- z. B. 'timectl:12,13' (woher die Zeile stammt)
)
payments (
  id, invoice_id, date, amount_cents, txn_ref, source   -- 'manual' | 'match'; Teilzahlungen möglich
)
counters ( issuer_id, series, last_number, PRIMARY KEY(issuer_id, series) )
audit    ( id, invoice_id, at, action, detail )          -- nur anhängen: created, line_added, issued, paid, cancelled …
```

**Unveränderlichkeit:** Trigger auf `invoices` und `invoice_lines` brechen `UPDATE`/`DELETE` ab, sobald `status='issued'` (erlaubt bleiben nur `payments` und `audit`). Ein Test versucht jeden Weg (direktes SQL, Löschen, Nummer ändern, Betrag ändern).

**Rundung:** Zeilen-Netto = `round(qty × Einzelpreis)`; **USt je Steuersatz auf der Summe** der Netto-Zeilen dieses Satzes (nicht je Zeile); Brutto = Netto + USt. Eine Regel, im README dokumentiert, mit Tests (Cent-Fälle).

## 3. Lebenszyklus

```
 new ─▶ DRAFT ──(check)──▶ issue ─▶ ISSUED ──▶ (paid ⟷ partial ⟷ open ⟷ overdue)   ← abgeleitet aus payments + due_date
                                       └──cancel──▶ STORNO-Rechnung (eigene Nummer, negative Zeilen, cancels_id)
```

- **paid/partial/open/overdue** werden aus `payments` und `due_date` berechnet — nie gespeichert, daher nie widersprüchlich.
- **Storno:** `cancel INV` erzeugt eine neue ausgestellte Rechnung mit negativen Zeilen und `cancels_id`. Das Original gilt danach als „storniert“ (abgeleitet). Eine Ersatzrechnung ist ein normaler neuer Entwurf (`new --copy INV`).
- **Nummernformat:** konfigurierbar, Vorschlag `{YYYY}-{NNN}` (2026-001). Ein Nummernkreis je Aussteller und Jahr.

## 4. Prüfliste vor dem Ausstellen (`invoicectl check` / `issue`)

Nach meinem Kenntnisstand (§ 11 UStG, **Steuerberatung bestätigt**):

| Pflichtangabe | Prüfung |
|---|---|
| Name und Anschrift des Ausstellers | Issuer vollständig |
| Name und Anschrift des Empfängers | Kunde vollständig |
| UID des Ausstellers | Pflicht bei `standard`; bei `small_business` entfällt sie, dafür Pflichttext |
| Menge und handelsübliche Bezeichnung | jede Zeile: Beschreibung, Menge > 0 |
| Zeitpunkt/Zeitraum der Leistung | `service_from` (und `service_to`) gesetzt |
| Entgelt, Steuersatz, Steuerbetrag | berechnet; bei 0 % Pflichttext (`vat_note`) |
| Ausstellungsdatum | gesetzt; **Warnung**, wenn früher als die vorige ausgestellte Rechnung des Kreises |
| Fortlaufende Nummer | automatisch beim Ausstellen |
| UID des Empfängers | **Pflicht** bei hohen Beträgen und bei Reverse Charge (Schwellenwert in der Konfiguration, **Wert steuerlich bestätigen**) |
| Kleinbetragsrechnung | bis zum gesetzlichen Grenzbetrag sind weniger Angaben nötig; v1 stellt **immer die volle Rechnung** aus (einfacher, nie falsch) |
| Kleinunternehmer | Pflichttext „umsatzsteuerbefreit … § 6 Abs 1 Z 27 UStG“ (genauer Wortlaut bestätigen), USt = 0 |
| Reverse Charge / innergemeinschaftlich / Drittland | v1: **nicht automatisch**; nur per `--vat-note` und 0 % mit Pflicht-UID, sonst Fehler |

Alles Rechtliche steht in **einer** Datei (`internal/rules/at.go`) mit Tests, damit die Steuerberatung sie lesen und ändern lassen kann.

## 5. Befehle

```
invoicectl issuer set [--profile KEY] --name … --address … --uid … --iban … --vat-regime standard|small_business …
invoicectl customer add|list|edit …
invoicectl new CUSTOMER [--due 14d] [--copy INV]        # Entwurf ohne Nummer
invoicectl line add INV "Beratung" 8h 80,00 [--vat 20] [--unit h]
invoicectl from-time INV --project PROJEKT --month 2026-10 --rate 80,00 [--round 15m]   # liest timectl log --json
invoicectl show INV | list [--status draft|open|overdue|paid] | check INV
invoicectl issue INV [--yes]                              # prüft, vergibt Nummer, friert ein, erzeugt PDF
invoicectl pdf INV [--out FILE]                           # nur ausgestellte; PDF-Hash wird gespeichert
invoicectl paid INV [--date D] [--amount A]               # Teilzahlung erlaubt
invoicectl match [--dry-run] [--profile P]                # Zahlungseingang aus budgetctl
invoicectl overdue                                        # offen, Fälligkeit überschritten
invoicectl cancel INV --yes                               # erzeugt Storno
invoicectl export --from --to --out FOLDER                # Rechnungsausgangsbuch (CSV, Excel-tauglich) + PDFs
invoicectl doctor | mcp
```

**Zahlungszuordnung (`match`):** nur Buchungen mit **positivem** Betrag ab Ausstellungsdatum. *Starker* Treffer: Rechnungsnummer steht im Verwendungszweck **und** Betrag = offener Betrag. *Schwacher* Treffer: nur Betrag, eindeutig (genau eine Rechnung, genau eine Buchung). Alles andere wird aufgelistet, nicht verknüpft. Buchungs-IDs mit Profil-Präfix (`firma:id`) wie bei belegctl. Liste ≥ Limit = Fehler, nicht still abschneiden.

**Zeitquelle:** `timectl log --json` je Projekt/Monat; eine Zeile je Aufgabe (Stunden, optional auf 15 min aufgerundet); `source_ref` merkt die Einträge, damit dieselbe Zeit **nicht doppelt** abgerechnet wird (Warnung, wenn Einträge schon auf einer ausgestellten Rechnung stehen).

## 6. PDF — Entscheidung nötig

| Option | Pro | Contra |
|---|---|---|
| **A. Reines Go** (`go-pdf/fpdf` + eingebettete Schrift) | läuft auch unter Linux, deterministisch, keine Hilfsprogramme, Hash stabil | Layout von Hand; Schrift (Umlaute) muss eingebettet werden (~300 KB, Lizenz prüfen) |
| B. WebKit-Helfer (Swift, wie beim OCR) | HTML/CSS-Layout, schöner | nur macOS, braucht Xcode-Tools, Hilfsprogramm wie bei belegctl absichern, PDF-Hash schwankt |
| C. Nur HTML, du druckst „Als PDF sichern“ | am einfachsten | Hash/Unveränderlichkeit nicht prüfbar, kein echtes Archiv-PDF |

**Empfehlung: A** (die Suite liefert auch Linux-Builds, und ein stabiler Hash passt zur Unveränderlichkeit). Eine Rechnung ist ein einfaches Layout.
**Phase 2:** E-Rechnung — **ebInterface** (öst. Standard; für Rechnungen an den Bund verpflichtend, nach meinem Kenntnisstand) bzw. XRechnung/ZUGFeRD (PDF/A-3 mit eingebettetem XML). Ob/wann B2B-E-Rechnung Pflicht wird, mit der Steuerberatung klären.

## 7. MCP & Dashboard

- Tools: `list_invoices`, `get_invoice`, `receivables_summary` (offen/überfällig, Summen), `overdue_invoices`, `create_draft`, `add_line`, `check_invoice`, `mark_paid` (**confirm**), `issue_invoice` (**confirm**: das ist deine Unterschrift unter die Rechnung — ein Modell darf sie nie ohne ausdrückliche Bestätigung auslösen), `cancel_invoice` (**confirm**). Kein Tool liefert Dateipfade; Kundendaten nur, was der Nutzer dem Client erlaubt hat.
- Dashboard-Karte „Invoices“: „2 open · €3.400 · 1 overdue“ (Beträge wie in der Budget-Karte); Zeile im `missionctl review --plain --money` und im Rückblick „Wealth“: offene Forderungen **getrennt** ausweisen, nicht ins Vermögen mischen.

## 8. Tests (vor dem ersten Ausstellen Pflicht)

Lückenlosigkeit (Fehlschlag verbraucht keine Nummer, parallele `issue`-Aufrufe vergeben nie dieselbe Nummer), Unveränderlichkeit auf SQL-Ebene, Storno-Summen, Rundungsfälle (mehrere Sätze), Prüfliste je Regime, Matching (stark/schwach/mehrdeutig), CSV-Escaping (wie belegctl), Zeit-Doppelabrechnung. Danach **Opus-Review** (`pruefer`) und **Steuerberatung liest `rules/at.go`** — erst dann echte Rechnungen.

## 9. Offene Entscheidungen für dich

1. **Aussteller:** Welche Profile zuerst — Abteilung 83, Brücke, beide? Sind sie **Kleinunternehmer** oder regelbesteuert (UID vorhanden)? Das bestimmt Standard-Regime und Pflichttexte.
2. **Nummernformat:** `2026-001` (Vorschlag) oder z. B. `RE-2026-0001`; ein Kreis je Jahr oder durchgehend?
3. **PDF:** Option A (Empfehlung), B oder C?
4. **Umfang v1:** nur Inlandsrechnungen mit 20/10/13 % bzw. Kleinunternehmer (Empfehlung), oder gleich innergemeinschaftlich/Reverse Charge?
5. **Wer prüft:** Steuerberatung für `rules/at.go` — wer ist Ansprechperson, und bis wann (Launch am 1.11. hängt **nicht** davon ab)?

## 10. Aufwand (grob, nach Freigabe)

Store + Trigger + Nummernvergabe + Tests ▸ Prüfliste/Regeln ▸ CLI ▸ PDF ▸ Matching + timectl ▸ MCP ▸ README/GIF ▸ Review. Vorschlag: Phase 1 ohne PDF-Layout-Feinschliff und ohne Matching, aber **mit** Unveränderlichkeit und Lückenlosigkeit; die sind der Kern und später nicht nachrüstbar.
