# missionctl — Suite-Audit & Arbeitsplan

> Stand: 2026-07-15 · Alle Apps außer postctl (siehe POSTCTL_AUDIT.md)
> Geprüft: mailctl, calctl, taskctl, notectl, budgetctl, habctl, timectl, diaryctl, missionctl (Umbrella), landing

**Gesamtbild:** Der Zustand ist besser als die Doku vermuten lässt. Alle 8 Tools haben
TUI (Bubbletea), CLI (Cobra), MCP-Server, `AdaptiveColor` und Resize-Handling.
Die Lücken liegen bei Tests, Release-Infrastruktur, Doku-Konsistenz und TUI-Feinschliff.

**Reihenfolge:** ① Wichtigste Sachen → ② Pro App → ③ UI/UX → ④ Vorschläge → ⑤ danach Monetarisierung.

---

## 1. Die wichtigsten Sachen (zuerst abarbeiten)

Priorisiert — oben blockiert unten:

- [x] **1.1 Landing-Source klären** — ✅ Geklärt: Die Source liegt auf dem Branch
  `deploy/landing` des Root-Repos (auch auf origin gepusht). Auf `main` ist `landing/`
  untracked und enthält nur die Build-Artefakte (`dist/`, `node_modules/`), die beim
  Branch-Wechsel liegen geblieben sind. Zum Arbeiten an der Landing:
  `git checkout deploy/landing`. Offen bleibt die Frage, ob die Landing nicht besser
  ein eigenes Repo/Submodule wäre statt eines Deploy-Branches (siehe 4.3).
- [x] **1.2 Release-Infrastruktur** — ✅ Erledigt: `.goreleaser.yaml` + `release.yml` +
  `ci.yml` in allen 9 Tools; Tap-Repo [aeon022/homebrew-tap](https://github.com/aeon022/homebrew-tap)
  angelegt; getrackte Binaries entfernt, .gitignore ergänzt. Ablauf in `RELEASING.md`.
  **Noch offen (manuell):** `HOMEBREW_TAP_TOKEN`-Secret setzen + erste Tags pushen
  (siehe RELEASING.md), LICENSE-Entscheidung.
- [x] **1.3 Versioning überall** — ✅ Erledigt: einheitliche `cmd/version.go` in allen
  Tools (`<tool> version` + `--version`), ldflags-Injection getestet, in goreleaser
  verdrahtet.
- [x] **1.4 Tests** — ✅ Minimum erledigt: budgetctl CSV-Import (N26/ING/DKB/generic,
  Beträge DE/EN), taskctl nlpdate, habctl Store + Streak-Logik (inkl. Skip-Forgiveness),
  mailctl + calctl Markdown-Parser, timectl Store (Start/Stop/Summary), notectl
  Obsidian-Layer, diaryctl Entry-Builder. **Dabei Bug gefunden & gefixt:** notectl
  `List()` übersprang alle Notizen im Vault-Root. Noch offen: MCP-Handler-Smoke-Tests,
  Store-Tests für mailctl/calctl/budgetctl.
- [x] **1.5 Root-Repo aufräumen** — ✅ timectl, diaryctl, missionctl (als
  [missionctl-cli](https://github.com/aeon022/missionctl-cli), Modulpfad umbenannt) sind
  jetzt Submodule; habctl-Eintrag in .gitmodules nachgetragen (fehlte).
- [x] **1.6 Root-README aktualisiert** — ✅ Suite-Tabelle mit allen 9 Tools + Umbrella-CLI,
  MCP-Config (9 Server, 64 Tools), Cheatsheet + MCP-Referenz für habctl/timectl/diaryctl,
  neuer „End of day"-Workflow. ROADMAP.md-Überarbeitung noch offen.

---

## 2. Pro App

### mailctl
Solide: TUI 1361 Zeilen, Suche, Help, Confirm-Dialoge, 6 MCP-Tools, AI-Integration (`internal/ai/claude.go`).
- [x] ~~`--version` fehlt~~ ✅
- [x] Tests: Markdown-Draft-Parser ✅ (Store noch offen)
- [ ] Sync ohne Loading-Feedback (AppleScript blockt das TUI)
- [ ] Roadmap-Features offen: Attachments, Unsubscribe-Helper, Gmail OAuth2

### calctl
Einziges Tool **mit** Version. TUI 1070 Zeilen.
- [ ] **Keine Suche im TUI** (mailctl/notectl-Pattern übernehmen)
- [ ] Help-Overlay rudimentär (1 Treffer auf „help")
- [x] Tests: Frontmatter-Import + Duration-Parser ✅ (free-slot noch offen)
- [ ] Roadmap offen: Google Calendar Sync, Recurring Events, Timezone-Handling

### taskctl
TUI 1326 Zeilen, Suche vorhanden, Daemon (`daemon --install`) als Alleinstellungsmerkmal.
- [x] ~~`--version` fehlt~~ ✅
- [ ] Help-Overlay rudimentär
- [x] Tests: `internal/nlpdate` ✅ (DE/EN Keywords, Wochentage, in-N-Tagen/Wochen)

### notectl
Bestes TUI der Suite (1676 Zeilen): Suche, Help, Confirm. Vorbild für die anderen.
- [x] ~~`--version` fehlt~~ ✅
- [x] Tests: Vault-Layer ✅ — dabei Bug gefixt: `List()` übersprang Root-Notizen (Daily-Note-Logik noch offen)
- [ ] Roadmap offen: Apple Notes Integration

### budgetctl
Dünnstes TUI (625 Zeilen), aber CLI-seitig komplett (import, summary, goal, recurring, export).
- [x] ~~`setup.sh` fehlt~~ ✅ ergänzt (Build, Install, MCP-Registrierung)
- [ ] **Kein Confirm-Dialog** vor destruktiven Aktionen im TUI
- [ ] Help nur rudimentär
- [x] ~~`--version` fehlt~~ ✅
- [x] Tests: CSV-Import ✅ (N26/ING/DKB/generic, DE/EN-Beträge, Malformed-Row-Handling)
- [ ] TUI ausbauen: Kategorie-Breakdown, Monats-Chart (steht in ROADMAP v0.5)

### habctl
Größtes TUI (3398 Zeilen), AI-Suggest mit Gemini **und** Claude, OAuth-PKCE-Flow (`internal/auth`).
- [x] ~~README fehlt komplett~~ ✅ README geschrieben (Quick Start, Cheatsheet, TUI-Keys, AI-Provider, MCP-Tools)
- [ ] **Keine Suche im TUI**
- [ ] **Kein Confirm-Dialog** (delete ohne Rückfrage)
- [x] ~~`--version` fehlt~~ ✅
- [x] Tests: Store + Streak-Berechnung ✅ (Streak, Gap, Skip-Forgiveness, Archiv)
- [x] ~~Fehlt in Root-README / Suite-Tabelle~~ ✅

### timectl
Jüngstes Tool, schlank (TUI 1040 Zeilen). Timer, Wochenreport, Invoice-Export.
- [ ] **Kein Help-Overlay** (0 Treffer — einziges Tool ganz ohne)
- [ ] **Keine Suche im TUI**
- [x] ~~`--version` fehlt~~ ✅
- [ ] Kein `internal/config` — als einziges Tool ohne Config-Package (prüfen ob absichtlich)
- [x] Tests: Store ✅ (Start/Stop, Doppel-Start, DaySummary; Invoice-Summen noch offen)
- [x] ~~Fehlt in Root-README~~ ✅

### diaryctl
Am stärksten integriert: liest git, taskctl, calctl, timectl (`internal/suite`), AI-Daemon (launchd 17:30), Export.
- [x] ~~`--version` fehlt~~ ✅
- [ ] Help-Overlay ausbauen
- [x] Tests: Entry-Builder/Template ✅ (git-Log-Parsing noch offen)
- [x] ~~Fehlt in Root-README~~ ✅
- [ ] Abhängigkeit zu den Schwester-DBs dokumentieren (was passiert, wenn taskctl.db fehlt?)

### missionctl (Umbrella-CLI)
`doctor`, `status`, `init` vorhanden. `status` ist plain `fmt.Println`.
- [ ] `status` kennt habctl/notectl/mailctl nicht (nur Tasks, Calendar, Timer, Diary, Budget)
- [ ] Kein `missionctl update` (alle Tools auf neueste Version) — wichtig für Käufer
- [ ] Kein `missionctl install` (alles in einem Rutsch via brew/Release-Download)
- [ ] `internal/` ist leer — Logik liegt komplett in `cmd/`, ok für die Größe, aber
  Kandidat für das Shared-Package (siehe 4.1)

### landing
- [x] Source liegt auf Branch `deploy/landing` (siehe 1.1) — auf `main` nur Build-Output
- [ ] Workflow entscheiden: Deploy-Branch behalten vs. eigenes Repo/Submodule (siehe 4.3)
- [ ] dist zeigt bereits Preise ($9/$19/$39/$49) und polar-Links → Inhalt ist fertig für Phase 5

---

## 3. UI/UX-Verbesserungen

Feature-Matrix (Ist-Zustand):

| Tool      | Suche | Help-Overlay | Confirm-Dialog | Spinner/Loading |
|-----------|:-----:|:------------:|:--------------:|:---------------:|
| mailctl   | ✅    | ✅           | ✅             | ❌              |
| calctl    | ❌    | ⚠️ minimal   | ✅             | ❌              |
| taskctl   | ✅    | ⚠️ minimal   | ✅             | ❌              |
| notectl   | ✅    | ✅           | ✅             | ❌              |
| budgetctl | ✅    | ⚠️ minimal   | ❌             | ❌              |
| habctl    | ❌    | ✅           | ❌             | ❌              |
| timectl   | ❌    | ❌           | ✅             | ❌              |
| diaryctl  | ✅    | ✅           | ✅             | ❌              |

Abarbeitung:

- [ ] **3.1 Spinner bei Sync/AI-Calls (alle Tools)** — AppleScript-Syncs und AI-Requests
  blocken das TUI kommentarlos. `bubbles/spinner` + `tea.Cmd`-Pattern einmal sauber
  bauen, in alle Tools übernehmen. Größter gefühlter Qualitätssprung.
- [ ] **3.2 Suche nachrüsten**: calctl, habctl, timectl — Pattern aus notectl/mailctl
  kopieren und anpassen (`/` öffnet Filter-Input).
- [ ] **3.3 Help-Overlay vereinheitlichen**: `?` öffnet überall dasselbe Overlay-Layout;
  timectl (ganz ohne), calctl/taskctl/budgetctl (minimal) nachziehen.
- [ ] **3.4 Confirm-Dialoge**: budgetctl + habctl vor delete/destruktiven Aktionen.
- [ ] **3.5 Einheitliche Keymap über alle Tools**:
  `/` Suche · `?` Hilfe · `r` Sync/Refresh · `a` Add/AI · `d` Delete · `q`/`esc` Quit.
  Einmal dokumentieren (Root-README „TUI conventions"), dann pro Tool angleichen.
- [ ] **3.6 Empty States** prüfen: Was zeigt jedes TUI vor dem ersten Sync/Import?
  Sollte den nächsten Befehl nennen („Noch keine Daten — führe `mailctl sync` aus").
- [ ] **3.7 missionctl `status` → Dashboard-TUI** — siehe 4.2.

---

## 4. Vorschläge (Architektur & Strategie)

- [ ] **4.1 Shared-Package `missionctl-core`** (eigenes Go-Modul):
  - Lipgloss-Theme (Farben, Styles) → erzwingt visuelle Konsistenz
  - Standard-Keymap + Footer-/Help-Komponente
  - Spinner-/Sync-Pattern
  - Config-Helpers (`~/.config/missionctl/`)
  - später: License-Check (→ Monetarisierung, ein Ort statt 9)
  - Migration schrittweise: neues Tool-Release zieht Core rein, kein Big Bang.
- [ ] **4.2 missionctl Dashboard-TUI** — `missionctl` ohne Argumente öffnet ein
  Dashboard: Tasks heute, nächster Termin, laufender Timer, Budget-Monat,
  Habit-Streaks, Diary-Status. Tastendruck springt ins jeweilige Tool.
  Der „Kitt" der Suite und das beste Demo-Material (GIF für Landing/HN-Post).
- [ ] **4.3 Landing-Workflow entscheiden** — Source liegt auf `deploy/landing`-Branch
  (Astro 7). Entweder dabei bleiben und den Workflow in `git-deploy.md` dokumentieren,
  oder in ein eigenes Repo/Submodule ausgliedern — dann kann `main` sauber bleiben und
  die Landing unabhängig deployen (z.B. via Vercel/Netlify auto-deploy).
- [ ] **4.4 `missionctl doctor` ausbauen** — prüft auch: MCP-Einträge in Claude-Desktop-
  Config vorhanden? DBs vorhanden und aktuell (letzter Sync)? launchd-Daemons geladen?
- [ ] **4.5 Doku-Konsistenz** — jedes Tool: README mit gleichem Aufbau (Quick Start,
  Cheatsheet, MCP-Config, TUI-Keys). habctl-README schreiben, budgetctl-setup.sh ergänzen.
- [ ] **4.6 CI pro Repo** — GitHub Action: `go vet` + `go test` + Build auf jedem Push.
  Billig, fängt Regressions, Voraussetzung für vertrauenswürdige Releases.

---

## 5. Danach: Monetarisierung (erst wenn 1–4 fertig)

Plan laut MONETIZATION.md: polar.sh, $9/Tool, $39 Bundle, one-time. Landing-dist zeigt
die Preise bereits. Technische Umsetzung in dieser Reihenfolge:

1. **goreleaser + GitHub Releases** pro Tool (= 1.2, dann schon erledigt)
2. **License-Package in `missionctl-core`**:
   - liest `~/.config/missionctl/license.json`
   - validiert gegen polar.sh License Key API, mit Offline-Grace-Period
   - `activate <key>`-Command für jedes Tool über das Shared Package
   - Free = voll funktionsfähig, Aktivierung entfernt nur die Startup-Notice
3. **Homebrew-Tap als Free-Funnel** — `brew install aeon022/tap/...`,
   Startup-Notice verlinkt auf polar.sh-Checkout
4. **polar.sh-Produkte anlegen** (Checkliste in MONETIZATION.md)
5. **Launch**: Show HN + Demo-GIF (Dashboard-TUI aus 4.2)

**Offene Strategiefrage** (bewusst erst dann entscheiden): Startup-Notice-Modell
(aktueller Plan) vs. Open-Core („CLI/TUI/MCP frei, AI-Features + Daemons nur mit
Lizenz"). Die AI-Features (habctl suggest, diaryctl-Narrativ, mailctl AI) sind der
stärkste Kaufgrund — Open-Core würde mehr konvertieren, wäre aber eine Abkehr vom
„alles funktioniert auch frei"-Versprechen.

---

## Vorgeschlagene Abarbeitungs-Reihenfolge (kompakt)

| # | Aufgabe | Aufwand | Ref |
|---|---------|---------|-----|
| 1 | ~~Landing-Source klären~~ ✅ liegt auf Branch `deploy/landing` | erledigt | 1.1 |
| 2 | ~~Quick Wins: habctl-README, budgetctl-setup.sh, Root-README + Submodule~~ ✅ | erledigt | 1.5, 1.6, 4.5 |
| 3 | ~~Versioning in alle Tools~~ ✅ | erledigt | 1.3 |
| 4 | ~~goreleaser + CI + Homebrew-Tap~~ ✅ (Secret + Tags offen) | erledigt | 1.2, 4.6 |
| 5 | ~~Tests für Parser + Stores~~ ✅ (Minimum) | erledigt | 1.4 |
| 6 | UI/UX-Runde (Spinner, Suche, Help, Confirm, Keymap) | mittel | 3.x |
| 7 | missionctl-core + Dashboard-TUI | groß | 4.1, 4.2 |
| 8 | Monetarisierung | mittel | 5 |
