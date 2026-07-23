# missionctl — Roadmap

> AI Model used for planning & assistance: **claude-sonnet-4-6**
> Zuletzt aktualisiert: 2026-07-20. `SUITE_AUDIT.md` §2 (Stand 2026-07-15) war an mehreren
> Stellen bereits veraltet — sie wurde vor der "UI/UX-Runde" (Suche/Help/Confirm/Spinner,
> Commit `5dff9ce`) geschrieben und danach nicht mehr nachgezogen. Diese Roadmap spiegelt
> den Stand nach direkter Code-Verifikation (grep über alle TUIs), nicht mehr den Audit-Text.

---

## Vision

A complete suite of local-first CLI tools that form the "hands" of an AI agent.
By Q2 2027, a user should be able to give Claude one sentence and have their
entire digital week planned, posted, scheduled, and tracked — without touching a browser.

---

## Aktueller Fahrplan (Stand 2026-07-20)

**Fertig:** Bündel-Infrastruktur (Tests, Release-Config, Versioning, LICENSE), alle
Pro-Tool-UI/UX-Lücken (Suche/Help/Confirm/Spinner/Empty-States — die meisten waren
schon da, diaryctl-Help-Overlay + Empty-States in calctl/taskctl neu ergänzt), alle
Architektur-Vorschläge (`missionctl-core` Shared-Package, missionctl Dashboard-TUI,
`doctor`-Ausbau, README-Konsistenz, Landing-Workflow-Entscheidung, CI pro Repo),
MCP-Handler-Smoke-Tests + restliche Store-Tests über alle 8 MCP-Tools.

**Bewusst offen/zurückgestellt:**
1. **Homebrew-Tap-Secret + erste Tags** — `HOMEBREW_TAP_TOKEN` ist in keinem Repo
   gesetzt (per `gh secret list` geprüft), und das erste Tag-Push macht Releases
   öffentlich sichtbar. Braucht eine bewusste Freigabe, wird nicht ungefragt gemacht.
2. **postctl** — zurückgestellt, wird separat nachgezogen (siehe `POSTCTL_AUDIT.md`).
3. **Monetarisierung** — startet erst, wenn 1–2 (Homebrew-Tap, postctl) entschieden
   sind, siehe `MONETIZATION.md`. Hängt außerdem an externen Accounts (polar.sh), die
   nur der Nutzer selbst anlegen kann.

Laufender Fortschritt wird über die Task-Liste dieser Session getrackt (Tasks #1–27).

---

## UI/UX-Optimierungsideen (2026-07-23)

Ausgangspunkt: der `colorSubtle`-Kontrastbug (Divider unsichtbar auf dunklen Themes),
identisch kopiert in 7 Tools — Anlass für eine breitere Bestandsaufnahme, was polierte
TUIs (k9s, lazygit, yazi, btop) haben, was die Suite (noch) nicht hat. Wird der Reihe
nach abgearbeitet: erst Schnell, dann Mittel, dann Aufwendig.

### Schnell
- [x] `missionctl-core/theme.Subtle` Kontrastbug gefixt (`239`→`244`, synchron zum
  Einzeltool-Fix)
- [x] `missionctl-core/theme` in mailctl/calctl/taskctl/notectl/budgetctl/timectl/
  diaryctl adoptiert — lokale Farb-Vars zeigen jetzt auf `theme.X` statt die
  Literale zu duplizieren, null visuelle Änderung, ein Ort für künftige
  Palette-Fixes. habctl bleibt bewusst außen vor (eigene Palette by design),
  postctl hat eigene Design-Sprache.
- [ ] `missionctl-core/keymap` (Help-Overlay-Builder) adoptieren — ersetzt die
  handgerollten `key()/row()/section()`-Helfer, noch offen
- [x] Bessere Ladezustände — animierter Spinner statt reinem "Loading…"-Text beim
  initialen Laden in calctl, taskctl, mailctl, notectl (alle AppleScript-/
  netzwerkgestützt, Ladezeit spürbar). mailctl + notectl hatten dabei einen
  echten Bug: kein `loading`-Flag, "keine Nachrichten/Notizen"-Leerzustand
  konnte kurz aufblitzen, bevor die erste Ladung durch war — jetzt korrekt
  unterschieden. budgetctl/timectl bewusst ausgelassen — rein lokale
  SQLite-Reads, Ladezeit nicht wahrnehmbar, kein Spinner-Unterbau vorhanden.
- [~] Command-Palette / `:`-Modus (wie k9s/lazygit) — **Prototyp in habctl fertig**,
  wartet auf Feedback vor Rollout auf die restliche Suite. `:` öffnet, Tippen
  filtert live (Präfix-Treffer zuerst), ↑/↓ wählt, Enter führt aus. Dispatcht
  über `handleList` (dieselbe Funktion wie jeder normale Tastendruck) statt
  eigener Logik. Bisher nur aus der Haupt-Listenansicht erreichbar.

### Mittel
- [~] Fuzzy-Suche mit Highlighting der Treffer statt reinem Substring-Filter —
  **Prototyp in habctl fertig** (sahilm/fuzzy, Präfix-Ranking wie fzf/k9s,
  Fallback auf Beschreibungs-Substring). Dabei einen echten Lipgloss-Bug
  gefunden und gefixt: verschachtelte `Render()`-Aufrufe löschen den äußeren
  Style nach dem ersten hervorgehobenen Zeichen (jeder `Render()`-Call setzt
  am Ende einen vollen SGR-Reset) — empirisch mit erzwungenem Color-Profile
  verifiziert vor dem Ausrollen. `highlightMatches` rendert jetzt pro Zeichen
  statt zu verschachteln. Derselbe Bug lauert vermutlich überall sonst in der
  Suite, wo Styles verschachtelt gerendert werden — beim Rollout mitprüfen.
- [x] Transientes Help-Overlay statt Vollbild-Weg-Navigation — ausgerollt auf
  habctl (Prototyp), budgetctl, calctl, taskctl, timectl, diaryctl (Konvertierung
  bestehender Vollbild-Help-Screens). Logik lebt in
  `missionctl-core/overlay.Center(bg, popup, w, h, inset)`, von habctl dorthin
  extrahiert und seither von allen geteilt. notectl und mailctl hatten nie einen
  eigenen Vollbild-Help-Screen (nur eine permanente Ein-Zeilen-Hinweisleiste, die
  nur ~12 von ~24 Tasten dokumentierte) — dort stattdessen ein komplett neues
  `?`-Overlay ergänzt (permanente Leiste bleibt zusätzlich bestehen). Damit haben
  jetzt alle 8 Tools mit TUI ein `?`-Overlay.
  Zwei echte Bugs unterwegs gefunden und am Ursprung (im shared Package)
  gefixt, nicht nur pro Tool umschifft:
  1. Border-Kollision (habctl) — Hintergrund ist selbst eine bildschirmfüllende
     Border-Box, Popup kollidierte sichtbar mit deren Rand ("╭──╭──╮──╮").
     Gefixt via `inset`-Parameter (hält Popup strikt innerhalb des Rands).
  2. Spalten-Versatz bei kurzen Hintergrund-Zeilen (calctl) — `ansi.Cut` füllt
     zu kurze Zeilen nicht auf, wodurch das Popup auf genau der Zeile mit z.B.
     "No events yet" einen Spalten-Versatz bekam. Gefixt durch Zeilen-Padding
     auf volle Breite vor dem Schneiden.
  Popup-Größe wird immer aus der TATSÄCHLICHEN Hintergrund-Höhe berechnet
  (nicht der Terminal-Höhe), Inhalt scrollt per `bubbles/viewport` statt
  abgeschnitten zu werden. timectl hatte zusätzlich einen eigenständigen Bug:
  `?` ist dort aus 3 Views erreichbar (nicht nur der Hauptliste), Schließen
  landete aber immer fix auf der Hauptview statt der Ursprungsview zurück —
  mitgefixt (`helpReturnTo`). Alles mit erzwungenem ANSI-Color-Profile
  verifiziert, nicht nur am reinen Text-Output — die Bugs waren dort
  unsichtbar.
- [x] ~~`bubbles/table` statt handformatierter Strings für Listen~~ — **geprüft und
  verworfen**. `bubbles/table` truncated Zellwerte über `runewidth.Truncate`,
  BEVOR sie gestylt werden, und rendert jede Zeile am Ende in einem einzigen
  Style. Konkret getestet: ein grün gefärbter Betrag `"+42.50€"` wird bei
  Truncation zu `"\x1b[32m…"` — Escape-Code bleibt offen, kein Reset, Inhalt
  weg. Verträgt sich nicht mit Pro-Zelle-Farbcodierung (Beträge in budgetctl,
  Priorität/Fälligkeit in taskctl, Kategorien in calctl). "Robusteres
  Alignment quasi gratis" war die falsche Prämisse — der Preis wäre der
  Verlust aller Farbcodierung gewesen. Aktuelle handformatierte Darstellung
  bleibt.

### Aufwendig / spekulativ
- [~] Mausklick auf Zeilen/Tabs, nicht nur Scroll-Wheel — **Prototyp in budgetctl
  fertig**. `WithMouseCellMotion()` + Scroll-Wheel liefen überall schon, Klick auf
  Zeilen/Tabs nirgends (notectl hatte nur Editor-Cursor-Klicks). Klick auf
  Monats-Tab wechselt Monat, Klick auf Transaktionszeile bewegt Cursor dorthin.
  Hit-Testing nutzt exakt dieselbe Zeilen-Layout- und Scroll-Fenster-Logik wie
  `renderList()` (`listStartRow()`), damit ein Klick immer auf die Zeile trifft,
  die visuell darunter liegt — gegen den echten Render-Output verifiziert, nicht
  nur isoliert getestet.
- [ ] Mehrere Themes zur Auswahl (wie btop/starship) — aktuell nur EINE feste Palette
  in `missionctl-core/theme`. Idee: benannte Presets (Default, Dracula, Nord,
  Gruvbox, Solarized, …) + `~/.config/missionctl/theme.yaml` mit `name:`-Feld,
  optional eigene Farb-Overrides. Jetzt entsperrt, da `theme` bereits in 7
  Tools adoptiert ist (siehe "Schnell") — ein Preset-Wechsel würde automatisch
  überall greifen.
- [ ] Mehrstufiges Undo statt Einzel-Undo (aktuell nur taskctl mit `u`)

---

## postctl — Social Media from Terminal

**Status: Existing (Go, Bubble Tea) — zurückgestellt, Details in `POSTCTL_AUDIT.md`**

### v1.0 — Polish & MCP (Q3 2026)
- [x] Twitter/X, LinkedIn, Threads Integration — alle 3 Plattformen vollständig
- [x] `postctl mcp` — MCP-Server, 7 Tools (list/get/create/publish/schedule/campaign list+get)
- [x] `postctl list --json` — machine-readable output
- [x] Robust error handling & retry logic — zentrales Retry-Middleware (`platforms.WithRetry`,
  exponential Backoff + Jitter, nur transiente Fehler: Netzwerk/429/5xx) für alle Publish-Pfade
  (CLI, MCP, TUI single/bulk)
- [ ] Brew formula via tap — einziger Blocker für Distribution

### v1.1 — Campaigns (Q4 2026)
- [x] Campaign grouping: tag posts to a campaign, schedule as a series
- [x] Thread support (Twitter threads from a single Markdown file)
- [~] Basic analytics — Struktur + SQLite vorhanden, API-Creds pro Plattform nötig
- [ ] `postctl campaign plan --topic "launch" --days 30 --json` — AI planning hook

### v2.0 — Team Mode (Q2 2027)
- [x] Bluesky & Mastodon support — ahead of schedule, beide voll implementiert
- [ ] Shared SQLite over iCloud Drive (like utask pattern)
- [ ] Approval workflow: draft → review → scheduled

---

## calctl — Calendar from Terminal

**Status: Grundfunktionen vorhanden (TUI, CLI, MCP) — offene Punkte siehe unten**

### v0.1 — Read & Write (Q3 2026)
- [x] Apple Calendar read via EventKit
- [x] `calctl list --today --json`
- [x] `calctl import event.md` — create event from Markdown frontmatter
- [ ] `calctl free --next 7d --json` — Tests für free-slot-Logik noch offen

### v0.5 — Google Calendar (Q4 2026)
- [ ] Google Calendar OAuth2 integration
- [ ] Two-way sync: Apple ↔ Google
- [ ] `calctl export --week --json`
- [x] TUI: week view, event creation, quick navigation

### v1.0 — MCP + AI Scheduling (Q1 2027)
- [x] `calctl mcp` — MCP server
- [ ] Natural language scheduling via MCP
- [ ] Recurring event support
- [ ] Time zone awareness

UI/UX (Suche, Help-Overlay, Empty States) ✅ vorhanden/nachgezogen.

---

## mailctl — Email from Terminal

**Status: Solide (TUI 1361 Zeilen, Suche, Help, Confirm, 6 MCP-Tools, AI-Draft-Integration)**

### v0.1 — Send (Q4 2026)
- [x] `mailctl send draft.md` — send from Markdown
- [x] `mailctl draft draft.md` — save to Drafts folder
- [ ] Template variables: `{{name}}`, `{{date}}` etc.

### v0.5 — Read & Context (Q4 2026)
- [x] `mailctl inbox --unread --json`
- [x] `mailctl thread <id> --json`
- [x] `mailctl search "invoice" --json`
- [x] Apple Mail integration via AppleScript
- [ ] Gmail via OAuth2

### v1.0 — MCP (Q1 2027)
- [x] `mailctl mcp` — MCP server
- [x] AI workflow: Claude reads inbox → drafts replies → user approves → mailctl sends
- [ ] Attachment support (local file → attach)
- [ ] Unsubscribe helper: detect newsletter patterns

UI/UX (Suche, Help, Confirm, Sync-Spinner) ✅ vorhanden.

---

## budgetctl — Budget from Terminal

**Status: CLI-seitig komplett (import, summary, goal, recurring, export), TUI dünn (625 Zeilen)**

### v0.1 — Import & Report (Q4 2026)
- [x] `budgetctl import bank.csv` — N26/ING/DKB/generic
- [x] `budgetctl summary --month --json`
- [x] `budgetctl list --json`
- [x] Auto-categorization rules (regex-based, config file)
- [x] Local SQLite storage

### v0.5 — Categories & TUI (Q1 2027)
- [x] `budgetctl tag "Netflix" --category streaming`
- [x] `budgetctl report --category --year 2026 --json`
- [x] TUI: transaction list, category breakdown, 6-Monats-Trend-Sparkline (Store.MonthlyTrend)
- [x] Budget goals: `budgetctl goal set "dining" 200 --monthly`

### v1.0 — MCP + AI Analysis (Q2 2027)
- [x] `budgetctl mcp` — MCP server, 66 Tools
- [ ] AI workflow: export → Claude analyzes → suggests cuts → user approves
- [ ] Year-end tax report export (CSV/PDF)
- [ ] Recurring payment detection

### v1.1 — Import-Assistent & Mehrkonten (Q3 2026)
- [x] In-TUI CSV-Import-Assistent (`i`): Filepicker → Vorschau (Datumsbereich,
  Income/Expense, Sample-Zeilen) → optionales AI-Categorize → Import. CLI-
  und TUI-Import-Pfad teilen sich jetzt `budget.ImportFile` statt duplizierter
  Upsert/Categorize/AI-Logik.
- [x] Dabei gefunden und gefixt: `parseGeneric` nahm bei mehreren
  "amount"-artigen Spalten (z.B. N26-Header mit "Amount (EUR)" UND "Amount
  (Foreign Currency)") die LETZTE statt die ERSTE Übereinstimmung — bei
  Dateien ohne bankspezifischen Dateinamen (also über den generischen Parser)
  landete man so auf der leeren Fremdwährungsspalte und JEDE Zeile wurde
  stillschweigend verworfen ("Imported 0 transactions", kein Fehler). Nur
  gefunden, weil ein echter End-to-End-CLI-Import gegen eine isolierte DB
  gefahren wurde statt sich auf Unit-Tests zu verlassen.
- [x] Mehrere Bankkonten: Konto-Tab-Reihe unter den Monats-Tabs (sichtbar ab
  1 getaggtem Konto — ursprünglich erst ab 2+, aber damit gab es nach dem
  ersten Import keine sichtbare Bestätigung, dass das Tagging überhaupt
  gegriffen hat), `[`/`]` zum Durchschalten (auch per Mausklick), sowohl in
  der Transaktionsliste als auch in der Summary-View. `Store.Summary`,
  `budgetctl summary --account`, und das MCP-Tool `summary` filtern jetzt
  optional auf ein Konto. Import-Vorschau zeigt das erkannte Konto (N26/ING/
  DKB/leer bei generisch) und erlaubt Umbenennen vor dem Import (`t`-Taste).
  Statusleiste zeigte fälschlich "[/]:account" direkt neben "/:search" —
  echte gemeldete Verwechslung — jetzt nur noch "]:account" (ein Key, wie
  "tab:month" auch shift+tab nicht extra zeigt).
- [x] `budgetctl reset [--account NAME] [--yes]` — alle (oder nur die eines
  Kontos) Transaktionen löschen, um einen Import sauber neu zu machen.
  Fragt interaktiv nach getipptem "yes" außer bei `--yes`. Bewusst NICHT
  als MCP-Tool exponiert — Bulk-Löschung der Finanzdaten per Agent-Tool-Call
  ohne sichtbaren Bestätigungsschritt ist ein anderes Risikoprofil als das
  bestehende `delete_transaction` (löscht nur eine einzelne Transaktion).
- [x] Drei echte Bugs gefunden über einen echten österreichischen Bank-CSV-
  Import (Steiermärkische Sparkasse "Umsatzliste", keine Header-Zeile, ';'-
  getrennt, UTF-8-BOM): (1) neuer dedizierter Parser dafür, da
  `parseGeneric`s Header-Keyword-Erkennung bei fehlender Header-Zeile
  grundsätzlich nicht greifen kann; (2) ING-Erkennung matchte fälschlich auf
  "ing " als Substring irgendwo im Dateiinhalt (traf z.B. den Namen
  "Wanting" in einer Buchungsbeschreibung) — jetzt spezifisch auf die
  echte `Bank;ING`-Präambelzeile eingeschränkt; (3) `Store.Summary` nettete
  Income/Expenses PRO KATEGORIE bevor klassifiziert wurde — eine Kategorie
  mit gemischtem Vorzeichen (fast immer "" uncategorized bei frischem
  Import) konnte so Einkommen komplett verschlucken, wenn die Ausgaben in
  derselben Kategorie überwogen. Jetzt pro Transaktion summiert.
- [x] Zwei Overflow-Bugs über echte Screenshots gefunden: `renderList()` gab
  `m.height+1` Zeilen aus (listH-Budget vergaß die Trenner-Zeile vor der
  Statusleiste) — in Terminals ohne Reflow schob das den Header oben aus
  dem sichtbaren Bereich. Der Import-Filepicker überlief sein Popup, weil
  `bubbles/filepicker` lange Dateinamen nie kürzt und das äußere
  `lipgloss.Width()` sie stattdessen umbrach (mehr physische Zeilen als
  budgetiert) — jetzt vorab mit `ansi.Truncate` gekürzt, Footer zeigt jetzt
  auch Navigations-Tasten (↑/↓, enter, esc) statt nur "esc: cancel".
- [x] 6-Monats-Trend-Sparkline in der Summary-View (`Store.MonthlyTrend`,
  farbcodierter Unicode-Block-Chart) — Nutzer-Feedback, dass die Summary
  neben den bestehenden Kategorie-/Goal-Balken sonst "nicht fancy" wirkte.
- [x] `enter` auf einer Zeile öffnet ein Detail-Popup (volle, ungekürzte
  Description + Account/Category/Source/Raw) — `formatTxRow` kürzt die
  Description auf Zeilenbreite, und echte Bank-Exports (v.a. die
  österreichische "Umsatzliste") haben oft hunderte Zeichen Verwendungs-
  zweck-Text. `e` im Popup springt direkt ins Edit-Formular. Feldlängen
  werden von der echten Terminal-Höhe budgetiert (gleiche Fix-Klasse wie
  der Import-Popup-Overflow).
- [x] Neue `Payee`-Spalte, getrennt von der Description/"Zweck" — Nutzer-
  Wunsch, Buchungen "wie Tabelle: Name, Verwendungszweck" statt als ein
  langer Blob. N26/ING/DKB bekommen Payee/Zweck bereits als getrennte
  CSV-Spalten (wurden bisher nur zusammengeklebt) — direkt aufgeteilt,
  kein Parsing nötig. Die österreichische "Umsatzliste" packt alles in
  EINEN gelabelten Blob ("Zahlungsempfänger: X Verwendungszweck: Y IBAN
  ..."), dafür ein neuer Best-Effort-Regex-Splitter (`splitATFields`),
  IBAN/BIC/Mandat-Rauschen fällt raus (bleibt komplett im Raw-Feld /
  Detail-Popup). Regel-Matching (`Categorize`/`ApplyRules`) prüft jetzt
  Payee+Description zusammen, sonst hätten Regeln wie "rewe" aufgehört zu
  greifen, sobald der Händlername in Payee statt Description landete.
  Nebenbei einen latenten Bug gefixt: Spalten-Padding/-Truncation nutzte
  Byte-Länge (`fmt`s `%-*s`, rohes String-Slicing) statt Rune-Anzahl — bei
  einem Umlaut in Payee/Category (in diesen Daten die Regel, nicht die
  Ausnahme) wären Spalten verrutscht bzw. UTF-8 hätte mitten im Rune
  geschnitten werden können.
- [x] Bug gefixt: `Store.List()`s SELECT hatte die `raw`-Spalte nie
  abgefragt — jede über die TUI geladene Buchung hatte `Raw=""`, obwohl
  beim Import korrekt gespeichert (an allen 84 echten Zeilen verifiziert).
  Das Raw-Fallback im Detail-Popup war dadurch faktisch tot — genau die
  Stelle, an der man bei einer knappen Buchung wie "Zahlungsreferenz:
  Nicht-Durchführung elektronisch" hätte nachsehen können, ob wirklich
  nichts fehlt.
- [x] Merchant-Namen aus AT-Umsatzliste-Kartenzahlungen extrahiert
  (`extractMerchant`) — Kartenzahlungen (POS/ePayment) haben in diesem
  Format KEIN Zahlungsempfänger-/Auftraggeber-Label, der Händlername
  steckt nur im Verwendungszweck-Text ("APPLE.COM/BILL CORK UNKNOWN
  Zahlungsreferenz: ePAYMENT ... Kartenfolge-Nr.: 1"), daher vorher immer
  "—". "Kartenfolge-Nr." als zuverlässiges Gate: erscheint bei JEDER
  Kartenzahlung, aber nie bei echten Bankgebühren (Sollzinsen,
  Kontoführung, ...) — verhindert, dass Gebührenzeilen fälschlich einen
  Händlernamen bekommen. Alias-Tabelle für bekannte Marken (Apple, Amazon,
  PayPal, Google, McDonald's, Klarna, Audible, MoonPay) + generisches
  Abschneiden von Referenznummern/Kartenterminal-Codes/Datum/Zeit für den
  Rest. An allen 84 echten Buchungen verifiziert: 80 bekommen jetzt einen
  sauberen Namen, die 4 echten Gebühren bleiben korrekt leer.

UI/UX (Suche, Help, Delete-Confirm, Kategorie-Breakdown, Detail-Popup) ✅ vorhanden.

---

## notectl — Notes from Terminal

**Status: Bestes TUI der Suite (1676 Zeilen) — Vorbild für die anderen**

### v0.1 — Obsidian Integration (Q1 2027)
- [x] `notectl write "Note Title" < content.md`
- [x] `notectl read "Note Title" --json`
- [x] `notectl search "keyword" --json`
- [x] `notectl list --json`
- [x] Config: `vault_path` pointing to Obsidian directory

### v0.5 — Apple Notes (Q1 2027)
- [x] Apple Notes read/write via AppleScript — Markdown-Round-Trip, Editor-Preview + Mouse
- [ ] `notectl sync` — sync between Obsidian and Apple Notes
- [ ] Tag support, folder organization

### v1.0 — MCP (Q2 2027)
- [x] `notectl mcp` — MCP server
- [ ] AI workflow: Claude writes meeting notes → notectl saves to vault → linked to calendar event
- [ ] Bear Notes support
- [ ] Daily note template automation

---

## taskctl — Tasks from Terminal

**Status: TUI 1326 Zeilen, Suche vorhanden, Daemon (`daemon --install`) als Alleinstellungsmerkmal**

### v0.1 — Apple Reminders (Q1 2027)
- [x] `taskctl list --json`
- [x] `taskctl add "Call dentist" --due "2026-10-15" --list "Personal"`
- [x] `taskctl done <id>`
- [x] `taskctl today --json`
- [x] EventKit bridge for Apple Reminders

### v0.5 — Multi-Provider (Q2 2027)
- [ ] Google Tasks OAuth2
- [ ] Microsoft To Do OAuth2
- [x] `taskctl sync` — bidirectional sync
- [x] TUI: task list, quick add, priority management

### v1.0 — MCP (Q2 2027)
- [x] `taskctl mcp` — MCP server
- [ ] AI workflow: Claude reviews your week → creates follow-up tasks → assigns due dates
- [ ] Project grouping, dependencies
- [ ] Integration with calctl: task with due date → calendar block

UI/UX (Suche, Help, Empty-State-Hinweis) ✅ vorhanden/nachgezogen.

---

## habctl — Habits from Terminal

*(nicht Teil der ursprünglichen ROADMAP-Planung, aber Teil der Suite)*

**Status: Größtes TUI (3398 Zeilen), AI-Suggest mit Gemini und Claude, OAuth-PKCE-Flow**
- [x] Store + Streak-Logik (inkl. Skip-Forgiveness), Archiv
- [x] README, Versioning, MCP-Tools
- [x] Suche im TUI (`/`-Filter über Name/Beschreibung)
- [x] Confirm-Dialog vor allen vier Delete-Aktionen (generischer y/esc-Dialog)

---

## timectl — Time Tracking from Terminal

*(nicht Teil der ursprünglichen ROADMAP-Planung, aber Teil der Suite)*

**Status: Schlank (TUI 1040 Zeilen), Timer, Wochenreport, Invoice-Export**
- [x] Store-Tests (Start/Stop, Doppel-Start, DaySummary)
- [x] Help-Overlay vorhanden
- [x] Suche im TUI vorhanden (Task/Projekt/Notizen)
- [x] Kein `internal/config` — bewusst so: Konfiguration läuft über Env-Vars
  (`TIMECTL_GOAL_HOURS`, `TIMECTL_HOURLY_RATE`), Tool ist bewusst schlank gehalten,
  kein Config-File nötig

---

## diaryctl — Daily Journal from Terminal

*(nicht Teil der ursprünglichen ROADMAP-Planung, aber Teil der Suite)*

**Status: Am stärksten integriert — liest git, taskctl, calctl, timectl; AI-Daemon (launchd 17:30)**
- [x] Entry-Builder/Template-Tests
- [x] Help-Overlay (`?`) — war komplett unbelegt, jetzt ergänzt
- [x] Schwester-DB-Abhängigkeit (taskctl/calctl/timectl) dokumentiert im README:
  read-only SQLite-Zugriff, fehlende DB wird still übersprungen, kein Fehler

---

## missionctl — Umbrella CLI

- [x] `doctor`, `status`, `init` vorhanden
- [x] `status` kennt jetzt auch habctl/notectl/mailctl
- [x] `missionctl update` — git pull + setup.sh je Tool
- [x] `missionctl install` — setup.sh für fehlende Tools, `--all` für Reinstall
- [x] `doctor` erweitert — MCP-Registrierung (~/.claude.json), DB-Aktualität, launchd-Status
- [x] `missionctl-core` Shared-Package — theme, keymap (inkl. Standard-Keys), Spinner,
  Config-Helper. Migration bestehender Tools bewusst schrittweise, nichts erzwungen.
- [x] Dashboard-TUI ohne Argumente — `missionctl` zeigt Briefing wie `status`, 1-8/Enter
  springt per `tea.ExecProcess` ins jeweilige Tool
- [x] README ergänzt (fehlte komplett)
- [x] Bug gefixt: `doctor`s MCP-Check sah nur user-scope-Registrierungen
  (top-level `mcpServers` in `~/.claude.json`). `claude mcp add` registriert
  standardmäßig aber project-scoped unter `projects[cwd].mcpServers` — 6 von
  9 Tools waren so registriert und zeigten trotzdem "not registered". Check
  schaut jetzt auch im project-scope-Eintrag für das aktuelle `cwd` nach.

---

## Bundle Launch Timeline

```
Q3 2026  postctl v1.0 + MCP           (feature-complete, Brew-Tap offen)
         calctl v0.1                  (im Kern erledigt)

Q4 2026  calctl v0.5
         mailctl v0.1 + v0.5          (im Kern erledigt)
         budgetctl v0.1               (erledigt)
         → Bundle Alpha auf polar.sh (postctl + calctl) — nach Monetarisierungs-Gate

Q1 2027  mailctl v1.0 + MCP           (im Kern erledigt)
         budgetctl v0.5
         notectl v0.1 + v0.5          (im Kern erledigt)
         taskctl v0.1                 (erledigt)
         Go Tutorial launch
         → Full Bundle v1.0 auf polar.sh

Q2 2027  Alle Tools v1.0 + MCP
         budgetctl v1.0
         notectl v1.0
         taskctl v1.0
         → Complete MCP Suite
```

---

## Monetization (polar.sh)

> Startet erst nach Abschluss von Bündel-Infrastruktur, Pro-Tool-Lücken und
> Architektur-Vorschlägen (siehe „Aktueller Fahrplan" oben). Details in `MONETIZATION.md`.

| Product               | Price  | Type         |
|------------------------|--------|--------------|
| postctl               | $9     | One-time     |
| calctl                | $9     | One-time     |
| mailctl               | $9     | One-time     |
| budgetctl             | $9     | One-time     |
| notectl               | $9     | One-time     |
| taskctl               | $9     | One-time     |
| **missionctl Bundle** | **$39**| One-time     |
| Go Tutorial           | $19    | One-time     |
| Tutorial + Bundle     | $49    | One-time     |

---

## AI Stack

Tools are designed to work with:
- **Claude** (claude-sonnet-4-6 / claude-opus-4-8) via MCP or CLI piping
- Any MCP-compatible AI client
- Shell scripts + `jq` for lightweight automation

Recommended model for missionctl workflows: **claude-sonnet-4-6** — fast enough for
real-time tool use, smart enough for complex planning tasks.
