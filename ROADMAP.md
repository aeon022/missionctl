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

## Neue Tools (Vorschläge, 2026-08-02)

Zwei neue Tool-Ideen wurden ausgeschrieben, nachdem der komplette "Reste"-Backlog
(calctl Conflict-Detection+Timezone, notectl Link-Graph, diaryctl HTML/PDF-Export,
timectl Invoice-Refinement, habctl Yearly-Heatmap+Correlations) fertig war. Beide sind
**reine Design-Outlines, noch nicht implementiert** — kein Code, kein Repo, kein
Submodule. Volle Ausschreibung liegt in `proposals/<name>/README.md`.

- [ ] **healthctl** — Terminal-first Medikamenten-Planer (`proposals/healthctl/`).
  Kernfrage: HealthKit hat *keine* AppleScript/EventKit-Bridge wie Calendar/
  Reminders/Notes/Mail — Apple-Health-Sync braucht entweder eine native App, einen
  Shortcuts-CLI-Spike, oder bleibt v1 ganz außen vor (empfohlen: v1 lokal-only,
  Planer+Reminder+Adherence-Tracking steht als eigenständiger Wert). Name bewusst
  breiter als "medctl" gewählt, falls später allgemeines Health-Tracking dazukommt —
  das ist aber explizit nicht Teil von v1.
- [ ] **investctl** — Aktien/Fonds-Tracking (`proposals/investctl/`), am
  2026-07-30 bewusst von budgetctl abgegrenzt (kein Holdings/Kurs-Konzept im
  `Transaction`-Modell). Kernfrage: erstes Tool der Suite mit echter
  Drittanbieter-Netzwerk-Abhängigkeit (Kursdaten-API) — bricht bewusst mit dem
  "local-first, nur Apple-Automation"-Muster aller anderen Tools. Empfehlung:
  gecachte Preise, `sync` explizit nutzergetriggert statt Hintergrund-Polling.

**Wie weiter:** beide brauchen vor Implementierung noch offene Entscheidungen (siehe
Checklisten in den jeweiligen `proposals/`-READMEs) — insbesondere ob/wann ein
echtes GitHub-Repo + Submodule angelegt wird. Keins von beiden ist aktuell
priorisiert vor dem Homebrew-Tap/postctl-Track unten.

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
- [x] `missionctl-core/keymap` (Help-Overlay-Builder) adoptieren — ersetzt die
  handgerollten `key()/row()/section()`-Helfer. Ausgerollt auf dieselben 7
  Tools wie der Theme-Rollout (mailctl/calctl/taskctl/notectl/budgetctl/
  timectl/diaryctl) — habctl bleibt bewusst außen vor (eigene Palette,
  26-Zeichen-Key-Spalte, vorgestylte Key-Strings), postctl eigene
  Design-Sprache. Paket um `Bare()` (kein Auto-Titel, für budgetctl mit
  eigenem `renderHeader`) und `Text()` (Freitext-Zeilen, für budgetctl
  "Accounts"-Absatz) ergänzt.
- [x] Bessere Ladezustände — animierter Spinner statt reinem "Loading…"-Text beim
  initialen Laden in calctl, taskctl, mailctl, notectl (alle AppleScript-/
  netzwerkgestützt, Ladezeit spürbar). mailctl + notectl hatten dabei einen
  echten Bug: kein `loading`-Flag, "keine Nachrichten/Notizen"-Leerzustand
  konnte kurz aufblitzen, bevor die erste Ladung durch war — jetzt korrekt
  unterschieden. budgetctl/timectl bewusst ausgelassen — rein lokale
  SQLite-Reads, Ladezeit nicht wahrnehmbar, kein Spinner-Unterbau vorhanden.
  diaryctl war ursprünglich auch ausgelassen (git-history-basiert, hätte
  einen eigenen Spinner gebraucht) — am 2026-08-04 nachgezogen, hatte
  bis dahin gar keinen Ladezustand (kein "Loading…"-Text, keine
  Unterscheidung von "noch am Laden" vs. "wirklich leer").
- [x] Command-Palette / `:`-Modus (wie k9s/lazygit) — Prototyp in habctl,
  ausgerollt auf alle 7 anderen Tools (mailctl/calctl/taskctl/notectl/
  budgetctl/timectl/diaryctl). `:` öffnet, Tippen filtert live (Präfix-
  Treffer zuerst), ↑/↓ wählt, Enter führt aus. Dispatcht über den
  bestehenden Key-Handler des jeweiligen Tools (kein separater
  Action-Dispatch), Matching-Logik zentral in neuem
  `missionctl-core/palette`. Zwei echte Bugs unterwegs gefunden und
  gefixt: (1) taskctl/notectl/mailctl/budgetctl/calctl — die Liste
  darunter wurde beim Öffnen der Palette nicht verkleinert, konnte bei
  vollem Terminal die Eingabezeile selbst nach oben aus dem Bild
  schieben. (2) calctl zusätzlich: Fensterung nach Zeilen-Anzahl statt
  physischer Zeilen — Datums-Header kosten 2 Zeilen, nicht 1, das
  Budget konnte trotz "richtiger" Kürzung überlaufen. Live mit tmux
  gegen echte Terminals verifiziert, nicht nur Unit-Tests. habctl
  bleibt der Prototyp (unverändert), postctl eigene Design-Sprache.
  Nur aus der Haupt-Listenansicht erreichbar.

### Mittel
- [x] Fuzzy-Suche mit Highlighting der Treffer statt reinem Substring-Filter —
  **auf alle 8 Tools mit Suche ausgerollt** (habctl-Prototyp + timectl,
  taskctl, calctl, diaryctl, budgetctl, mailctl, notectl). sahilm/fuzzy,
  Treffer-Highlighting via `highlightMatches` (pro Zeichen gerendert statt
  verschachtelt — siehe Lipgloss-Bug unten).
  - **4 direkte Ports** (timectl, taskctl, calctl, diaryctl): filterten
    bereits eine im Speicher gehaltene Liste — 1:1 wie habctl. taskctl und
    calctl gruppieren aber nach Liste/Tag ("isHeader"-Zeilen) — anders als
    habctl wird dort NICHT nach Match-Qualität umsortiert, sonst würde eine
    einzelne Gruppe über nicht-zusammenhängende Positionen verstreut.
    diaryctl fuzzy-matcht nur einzelne WÖRTER im Body, nicht den ganzen
    Fließtext als eine Sequenz — sonst hätte praktisch jede kurze Anfrage
    irgendeine Teilfolge im Absatz gefunden und alles gematcht.
  - **3 Tools mit DB-Query-Suche** (budgetctl, mailctl, notectl — notectl
    am schlimmsten: SQL-`LIKE`-Query bei JEDEM Tastendruck): umgebaut auf
    denselben clientseitigen Ansatz. `loadCmd`/`loadMsgsCmd`/`loadNotesCmd`
    laden jetzt ungefiltert (neues `allTxs`/`allMsgs`/`allNotes`-Feld),
    Fuzzy-Filter läuft live im Speicher bei jedem Tastendruck — kein
    DB-Roundtrip mehr, kein Enter zum Bestätigen nötig. `Store.Filter.Query`
    (SQL `LIKE`) bleibt unangetastet und bedient weiterhin CLI/MCP
    (`budgetctl list --query`, `mailctl search`, `notectl search`).
  - Dabei **zwei echte, unabhängige Bugs gefunden und gefixt** (nicht nur
    umschifft): (1) der ursprüngliche Lipgloss-Nesting-Bug aus dem
    habctl-Prototyp — verschachtelte `Render()`-Aufrufe löschen den äußeren
    Style nach dem ersten hervorgehobenen Zeichen. (2) In mailctl UND
    notectl: die ganze zusammengesetzte Zeile wurde in EINEN äußeren
    `styleSelected/styleRead/styleUnread.Render()`-Aufruf gewickelt, obwohl
    sie bereits unabhängig gefärbte Segmente (Datum, Absender, Ordner/Tag)
    enthielt — deren eigene Resets haben den äußeren Style für alles danach
    gelöscht. Mit erzwungenem ANSI-Profil verifiziert: bei mailctl verlor
    der Betreff seine Formatierung UND der Selected-Hintergrund endete
    vorzeitig; bei notectl dasselbe. Beide Renderer bauen die Zeile jetzt
    pro Segment, kein äußerer Wrap mehr — dadurch ist Highlighting jetzt
    auch auf der Cursor-Zeile sicher (kein äußerer Wrap mehr, der geklaut
    werden könnte).
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
- [x] Mausklick auf Zeilen/Tabs, nicht nur Scroll-Wheel — Prototyp in budgetctl,
  **war bei Prüfung 2026-08-04 bereits auf alle 6 anderen Tools ausgerollt**
  (eigene "feat: click-to-select..."-Commits pro Tool, unabhängig von dieser
  Roadmap-Zeile — nur die Doku hier war stehen geblieben). `WithMouseCellMotion()`
  + Scroll-Wheel liefen überall schon, Klick auf Zeilen/Tabs ebenfalls überall
  vorhanden: `rowHitTest`, `hoverRow`, Doppelklick-Erkennung. Klick auf
  Monats-Tab wechselt Monat, Klick auf Transaktionszeile bewegt Cursor dorthin.
  Hit-Testing nutzt exakt dieselbe Zeilen-Layout- und Scroll-Fenster-Logik wie
  `renderList()` (`listStartRow()`), damit ein Klick immer auf die Zeile trifft,
  die visuell darunter liegt — gegen den echten Render-Output verifiziert, nicht
  nur isoliert getestet.
- [x] Mehrere Themes zur Auswahl (wie btop/starship) — umgesetzt 2026-08-22:
  `theme.yaml` unterstützt jetzt `preset: <name>` (catppuccin, dracula, gruvbox,
  nord, one-dark, solarized, tokyo-night — die 7 YAMLs aus `themes/` in
  missionctl-core eingebettet), Auflösung defaults → Preset → Farbe-für-Farbe-
  Override (Override gewinnt immer). Automatisch in allen 7 Tools mit
  `missionctl-core/theme` wirksam, kein Tool-seitiger Code nötig.
- [~] Mehrstufiges Undo statt Einzel-Undo — Stand 2026-08-21: Einzel-Undo (5s-Fenster,
  nur Delete) ist inzwischen in 7 von 8 Tools (calctl, taskctl, notectl, budgetctl,
  habctl, timectl, diaryctl — nicht mehr nur taskctl, Roadmap-Text war hier
  veraltet), aber überall weiterhin EIN Schritt zurück, keine Historie. Nur mailctl
  hat noch kein Undo. Mehrstufig ist nirgends umgesetzt.

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
- [ ] Echtes `Delete()` für facebook, linkedin, devto, hashnode, medium, reddit — bislang
  unimplementierte Stubs, die immer `nil` zurückgaben (löschten also nie wirklich etwas auf der
  Plattform). Am 2026-08-06 gefunden und auf einen ehrlichen "not implemented"-Fehler umgestellt,
  damit der lokale Post-Datensatz beim Löschen nicht mehr fälschlich mitgelöscht wird — die
  eigentliche API-Implementierung für diese 6 Plattformen fehlt aber noch. Twitter/X, Bluesky,
  Mastodon, Threads, Discord, Telegram haben Delete bereits vollständig implementiert.
- [ ] Brew formula via tap — einziger Blocker für Distribution

### v1.1 — Campaigns (Q4 2026)
- [x] Campaign grouping: tag posts to a campaign, schedule as a series
- [x] Thread support (Twitter threads from a single Markdown file)
- [~] Basic analytics — Struktur + SQLite vorhanden, API-Creds pro Plattform nötig
- [ ] `postctl campaign plan --topic "launch" --days 30 --json` — AI planning hook

### v2.0 — Team Mode (Q2 2027)
- [x] Bluesky & Mastodon support — ahead of schedule, beide voll implementiert
- [x] Shared SQLite over iCloud Drive (like utask pattern) — mechanism now in place suite-wide via missionctl-core/syncdir; approval workflow below remains a separate, later feature
- [ ] Approval workflow: draft → review → scheduled

---

## calctl — Calendar from Terminal

**Status: Grundfunktionen vorhanden (TUI, CLI, MCP) — offene Punkte siehe unten**

### v0.1 — Read & Write (Q3 2026)
- [x] Apple Calendar read via EventKit
- [x] `calctl list --today --json`
- [x] `calctl import event.md` — create event from Markdown frontmatter
- [x] `calctl free --next 7d --json` — war bei Prüfung 2026-08-21 bereits fertig:
  `--next` (Tage) existiert, `internal/calendar/free_test.go` hat 5 dedizierte Tests
  (leerer Tag, Lücken, Mindestdauer-Filter, Ganztags-Termine ignoriert,
  Überlappungs-Zusammenfassung) — nur die Doku hier war stehen geblieben.

### v0.5 — Google Calendar (Q4 2026)
- [ ] Google Calendar OAuth2 integration
- [ ] Two-way sync: Apple ↔ Google
- [x] `calctl export --week --json` — umgesetzt 2026-08-22: `calctl export
  [--week | --from/--to] [--output/-o <pfad>]`, nutzt das bestehende globale
  `--format human|json` statt ein eigenes zu erfinden. Schreibt in eine Datei
  statt stdout — das war der eigentliche Mehrwert gegenüber `list`, das schon
  vorher `--week --format json` konnte.
- [x] TUI: week view, event creation, quick navigation

### v1.0 — MCP + AI Scheduling (Q1 2027)
- [x] `calctl mcp` — MCP server
- [ ] Natural language scheduling via MCP — `dateutil.ParseDateArg` (CLI und MCP
  identisch) akzeptiert nur strikt `YYYY-MM-DD`, kein "nächsten Dienstag" o.ä.
- [x] Recurring event support — war bei Prüfung 2026-08-21 bereits fertig, Ende-zu-Ende
  verifiziert: `buildCreateScriptIndexed` (`internal/calendar/apple.go`) baut die
  Recurrence-Zeile aus `--repeat`/`--count`/`--until` und splict sie tatsächlich ins
  ausgeführte AppleScript ein, wird nicht nur gebaut und verworfen.
- [~] Time zone awareness — Stand 2026-08-21: `Event.Timezone` wird beim Sync aus
  EventKit übernommen und gespeichert, aber `StartTime`/`EndTime` laufen überall
  fest über `time.Local` (kein `--timezone`-Flag bei `add`, keine Umrechnung in
  Free-Slot-/List-Logik) — reine Metadaten-Erfassung, noch keine echte
  Zeitzonen-Behandlung.

UI/UX (Suche, Help-Overlay, Empty States) ✅ vorhanden/nachgezogen.

---

## mailctl — Email from Terminal

**Status: Solide (TUI 1361 Zeilen, Suche, Help, Confirm, 6 MCP-Tools, AI-Draft-Integration)**

### v0.1 — Send (Q4 2026)
- [x] `mailctl send draft.md` — send from Markdown
- [x] `mailctl draft draft.md` — save to Drafts folder
- [x] Template variables — war bei Prüfung 2026-08-21 bereits fertig:
  `internal/markdown/parse.go` baut eine vars-Map (`date`, `year`, plus Frontmatter-
  Custom-Vars) und expandiert per Go `text/template`. Syntax ist `{{.name}}`
  (Go-Template, Punkt-Präfix), nicht `{{name}}` wie hier ursprünglich notiert —
  rein kosmetischer Unterschied zur Roadmap-Formulierung.

### v0.5 — Read & Context (Q4 2026)
- [x] `mailctl inbox --unread --json`
- [x] `mailctl thread <id> --json`
- [x] `mailctl search "invoice" --json`
- [x] Apple Mail integration via AppleScript
- [ ] Gmail via OAuth2

### v1.0 — MCP (Q1 2027)
- [x] `mailctl mcp` — MCP server
- [x] AI workflow: Claude reads inbox → drafts replies → user approves → mailctl sends
- [x] Attachment support — war bei Prüfung 2026-08-21 bereits fertig:
  `Draft.Attachments []string` (Frontmatter `attachments:`) baut AppleScript
  `make new attachment`-Zeilen fürs Senden/Drafts; TUI hat ein eigenes,
  kommagetrenntes Attach-Feld.
- [x] Unsubscribe helper — war bei Prüfung 2026-08-21 bereits fertig, aber enger als
  hier formuliert: `findUnsubscribeURL` erkennt "unsubscribe" + einen nahen
  `https://`-Link in der GEÖFFNETEN Nachricht (`U`-Taste in der Detailansicht) —
  Einzel-Nachricht, Einzel-URL. Kein Cross-Inbox-"Newsletter-Pattern"-Scan
  (keine Absender-/Frequenz-Heuristik, kein Bulk-Scan über die ganze Inbox).

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
- [~] AI workflow: export → Claude analyzes → suggests cuts → user approves —
  Stand 2026-08-22: kein dedizierter Code, aber schon heute vollständig über
  bestehende MCP-Tools machbar (`budget_summary` für Kategorie-Aufschlüsselung,
  `set_budget_goal` fürs Umsetzen genehmigter Kürzungen) — braucht keine neue
  "AI-Orchestrierung", nur eine Chat-Session mit Claude, die diese Tools nutzt.
  Bleibt offen als eigener Punkt nur falls ein dediziertes CLI-Kommando
  (`budgetctl suggest-cuts`) gewünscht ist statt Chat-getrieben.
- [x] Year-end tax report export — umgesetzt 2026-08-22: `budgetctl export --summary`
  (mit `--year`, `--format csv|json`, `--output`) aggregiert auf Kategorie-Summen
  (Betrag + Anzahl), sortiert. PDF bewusst ausgelassen (keine PDF-Dependency im
  Repo, kein Mehrwert für ein paar Zeilen Code) — `// ponytail:`-Kommentar im
  Code markiert das als Nachrüst-Option, falls je gebraucht.
- [x] Recurring payment detection — war bei Prüfung 2026-08-21 bereits fertig:
  `internal/budget/recurring.go`, `cmd/recurring.go`, MCP-Tool
  `detect_recurring_payments`

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
- [x] Bug gefixt: Monats-Tab-Leiste überlief bei vielen Monaten — mit 18
  Monaten (Jan 2025 bis Jun 2026, echte Nutzerdaten) wurde die Tab-Zeile
  unbedingt gerendert (~200 Spalten), ohne Möglichkeit, Monate zu
  erreichen, die nicht in die Terminalbreite passten. `monthTabWindow`
  scrollt das sichtbare Fenster jetzt so, dass `activeTab` immer sichtbar
  bleibt (gleiche Technik wie das bestehende Scroll-Fenster der
  Transaktionsliste), mit `‹`/`›`-Indikator auf der Seite mit
  ausgeblendeten Monaten. `tabHitTest` spiegelt exakt dasselbe
  Fenster-Layout, damit ein Klick auch im gescrollten Zustand auf den
  richtigen Monat trifft.
- [x] Jahres-Sprung (`y`/`Y`) und Kategorie-Filter (`f`) — direkte Folge
  aus dem 18-Monats-Fund oben: einzelne Monate durchtabben wurde über 2
  Jahre hinweg mühsam. `y`/`Y` springen zum nächsten/vorherigen
  Jahreswechsel in den vorhandenen Daten (`adjacentYearTab`), in
  Transaktionsliste UND Summary-View. `f` öffnet einen Fuzzy-Picker-Popup
  über alle genutzten Kategorien (neues `Store.ListCategories`) —
  „All categories" immer zuerst als Filter-Reset. Anders als bei
  `filterTxs`/taskctl/calctl wird hier NACH Match-Qualität umsortiert
  (fzf-Style) — der Picker ist eine Einmal-Auswahl, keine dauerhaft
  chronologisch geordnete Liste, Umsortieren stört hier also nicht.

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
- [x] `notectl sync` — war bei Prüfung 2026-08-21 bereits fertig, echte bidirektionale
  Synchronisierung: bei aktiviertem `mirror_apple_obsidian` diffed `internal/mirror`
  beide Seiten gegen eine persistierte Link-Tabelle und pusht Creates/Updates zur
  jeweils veralteten Seite; Deletes werden über `--apply-deletes` angewendet.
- [x] Tag support, folder organization — Tags umgesetzt 2026-08-22 (Ordner-Organisation
  war schon fertig): `--tag` bei `list`/`search` (exakt, case-insensitive, kein
  Substring-Leck — `--tag dai` matched nicht "daily"), MCP `list_notes`/`search_notes`
  bekamen denselben `tag`-Parameter. TUI-Filter bewusst ausgelassen — Tags würden
  keinen kleinen Hook in die bestehende Ordner-Tab-UI/Fuzzy-Filter-Infrastruktur finden.

### v1.0 — MCP (Q2 2027)
- [x] `notectl mcp` — MCP server
- [x] AI workflow: Claude writes meeting notes → notectl saves to vault → linked to
  calendar event — umgesetzt 2026-08-22: `Note.EventID` (Frontmatter `event_id`),
  `notectl write --event-id <id>`, `notectl list --event <id>` (exakter,
  case-sensitiver Match, kein Case-Folding wie bei Tags — ist eine opake ID, kein
  getipptes Wort), MCP `write_note`/`list_notes` bekamen denselben Parameter. Reine
  Speicher-/Filter-Plumbing — die "AI"-Seite läuft schon heute über eine
  Chat-Session, die calctls `create_event` + notectls `write_note` kombiniert,
  keine neue Orchestrierung nötig.
- [ ] Bear Notes support
- [x] Daily note template automation — war bei Prüfung 2026-08-21 bereits fertig:
  `notectl daily` erstellt die heutige Notiz aus einem festen Template
  (Focus/Tasks/Notes/Log), Tag `daily`, `--folder`/`--open`-Flags, nutzt eine
  vorhandene Notiz wieder statt zu duplizieren.

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
- [~] AI workflow: Claude reviews your week → creates follow-up tasks → assigns
  due dates — Stand 2026-08-22: kein dedizierter Code, aber schon heute vollständig
  über bestehende MCP-Tools machbar (`week_tasks` zum Review, `create_task` inkl.
  Fälligkeitsdatum fürs Anlegen) — braucht keine neue "AI-Orchestrierung", nur eine
  Chat-Session mit Claude, die diese Tools nutzt.
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
