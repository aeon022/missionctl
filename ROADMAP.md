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
- [ ] `missionctl-core` (theme + keymap) tatsächlich adoptieren — existiert seit der
  vorigen Session, aber **kein einziges Tool importiert es bisher**. Laut eigenem
  README "adoptiert ein Tool es, wenn seine TUI ohnehin gerade angefasst wird" —
  genau das ist jetzt der Fall (alle 7 TUIs gerade für Header+Divider-Fix anfasst).
  Ersetzt die kopierte Farb-Palette + die handgerollten `key()/row()/section()`
  Help-Overlay-Helfer in mailctl/calctl/taskctl/notectl/budgetctl/timectl/diaryctl.
  habctl bleibt bewusst außen vor (eigene Palette by design).
- [ ] Bessere Ladezustände — Spinner statt reinem "Loading…"-Text dort, wo noch
  keiner läuft
- [ ] Command-Palette / `:`-Modus (wie k9s/lazygit) — schneller Aktions-Sprung statt
  Einzeltasten auswendig lernen, besonders wertvoll bei habctl (~24 Views)

### Mittel
- [ ] Fuzzy-Suche mit Highlighting der Treffer statt reinem Substring-Filter (aktuell
  bei `/` überall in der Suite)
- [ ] Transientes Help-Overlay statt Vollbild-Weg-Navigation — Kontext bleibt beim
  Öffnen von `?` erhalten
- [ ] `bubbles/table` statt handformatierter Strings für Listen (taskctl, budgetctl,
  calctl) — robusteres Spalten-Alignment quasi gratis

### Aufwendig / spekulativ
- [ ] Mausklick auf Zeilen/Tabs, nicht nur Scroll-Wheel
- [ ] Konfigurierbares Farbschema (`~/.config/missionctl/theme.yaml`), das alle Tools
  teilen — baut auf `missionctl-core/theme` auf, sobald das adoptiert ist
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
- [x] TUI: transaction list, category breakdown (Monats-Trendchart optional, nicht kritisch)
- [x] Budget goals: `budgetctl goal set "dining" 200 --monthly`

### v1.0 — MCP + AI Analysis (Q2 2027)
- [x] `budgetctl mcp` — MCP server, 66 Tools
- [ ] AI workflow: export → Claude analyzes → suggests cuts → user approves
- [ ] Year-end tax report export (CSV/PDF)
- [ ] Recurring payment detection

UI/UX (Suche, Help, Delete-Confirm, Kategorie-Breakdown) ✅ vorhanden.

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
