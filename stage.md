# missionctl — Stand 2026-10-08

Gedächtnis-Datei für zukünftige Sessions. Pfade, Commits und Befehle sind so genau, dass man nachprüfen kann, ob sie noch stimmen. Der ältere Stand (2026-08-04: postctl-Kampagne, Homebrew, Landing-Page, AI-Gating) steht unverändert in [`docs/archive/stage-2026-08-04.md`](docs/archive/stage-2026-08-04.md) und gilt dort weiter.

**Wiederkehrender Fehler, siehe [AGENTS.md](AGENTS.md) / [CLAUDE.md](CLAUDE.md):** `deploy/landing-src` pushen deployt nichts — die Live-Seite hängt an `deploy/landing`. Immer beide Schritte.

Regeln aus Memory/CLAUDE.md, die weiter gelten: lokal committen, **pushen nur auf Zuruf** (der Nutzer hat im Verlauf dieser Arbeit Pushes freigegeben); vor Vergleichen `git fetch`; Geheimnisse nie in den Chat; echte Budget-DB nie anfassen; Antworten auf Deutsch.

---

## 1. Überblick

Die Suite besteht jetzt aus **12 Go-Projekten**:

| Repo | Rolle | Head (2026-10-08) |
|---|---|---|
| `missionctl-core` | geteilte Bibliothek (config, ai, applescript, activity, syncdir, ui, theme, tuitest, …) | `82edca7` |
| `mailctl` `calctl` `taskctl` `notectl` `budgetctl` `habctl` `timectl` `diaryctl` | die acht Kern-TUIs/CLIs/MCP-Server | `d95257a` `39e4b98` `a2e364f` `1606f35` `fa04387` `c44d817` `5f6de5a` `80d4342` |
| `postctl` | Social-Media-Tool, eigener Checkout (im Root gitignored) | `b613b4d` |
| `missionctl` (= `missionctl-cli`) | Umbrella-CLI + Dashboard | `ae3375b` |
| `healthctl` **neu** | Medikamenten-Planer (privat) | `dcc49fc` |
| `investctl` **neu** | Aktien/Fonds/ETF-Depot (privat) | `092f2f7` |

Alle sind auf Core `82edca7` gepinnt. Root-Repo `aeon022/missionctl` trägt die Submodule-Pointer (healthctl und investctl sind seit `d8244f7` Submodule).

---

## 2. Änderungsprotokoll (2026-10-05 → 2026-10-08)

### 2026-10-05 — Aufräumen, Bubble Tea v2, Tests
- **Ponytail-Audit** → `TODO.md`; Versionsdrift beseitigt (cobra v1.10.2, mcp-go v0.55.1, fuzzy v0.1.3).
- **viper** aus budgetctl/calctl/mailctl/taskctl → `missionctl-core/config.Store` (YAML + Env, `SetEnvPrefix` opt-in).
- Gemeinsame Pakete: `applescript` (4× Duplikat), `humanize.Truncate` (3×), `ai` mit Gemini-Hooks (habctl-Provider 271 Z. → Adapter).
- **Bubble Tea v2** in allen Tools (`charm.land/*/v2`); `tui.go` in tui/styles/update/view/commands/helpers aufgeteilt. v2-Fallen: Leertaste = `"space"`, Textfeld-Breite 0, lipgloss v2 emittiert immer ANSI (CLI-Ausgabe über `colorprofile`), `Width/Height` schließen den Rahmen ein.
- **Tests/Tooling:** `scripts/test-all.sh` (isoliertes `HOME`, `*_DATA_DIR`/API-Keys entfernt), `dev-build.sh`, `dev-env.sh`, `first-run.sh`, `bump-core.sh`, `TESTING.md`; `tuitest`-Paket (Key/Click/Motion/Wheel/Resize/Smoke) in Core; zwei Test-Runden mit vielen echten Fehlerbehebungen (Streaks, Löschen mit Listenkopie, Dev.to/Medium-Drafts, Twitter-`Delete`, XSS im OAuth-Callback, DST in calctl, …; Details in `TODO.md`).
- Features: Focus-Reload, OSC 52, Dashboard-Karten konfigurierbar (`~/.config/missionctl/dashboard.yaml`), Suche `/`, Sparklines, Peek `d`; Umbrella-Befehle `search`, `plan`, `review`, `notify`, `log`, `ui-demo`, `doctor`, `status`.

### 2026-10-06 — Aktivitätslog, Design-System, Runde 1
- **Activity-Log** (`missionctl-core/activity`): nur Titel, `~/.local/share/missionctl/activity.jsonl`, Einstellungen `~/.config/missionctl/activity.yaml`; diaryctl-Tagesabschluss `ask|auto|off`; `missionctl log`. budgetctl loggt nur Zähler.
- **mailctl:** Unsubscribe-Helper (`U`, `mailctl unsubscribe`; One-Click/Link/mailto, immer mit Bestätigung).
- **Design-System `ui`** in Core: Pill, KeyCap/Hint, Bar, Spark, Heat, Toast, Header, Divider, Row/HoverRow, RelTime, MidEllipsis, Money, Icon (Unicode, optional Nerd Font), Panel (`MISSIONCTL_BORDERS=rounded|sharp|none`), Tabs, Duration, Frame; dazu `statusbar`, `emptystate`, `overlay.CenterDim`. Showcase: `missionctl ui-demo`.
- **Runde 1 (Screenshot-Feedback):** Gruppenabstände, ruhigere Pills, `ui.Tabs`, durchgehende Auswahlzeile, diaryctl-`[AI]`-Umbruch, habctl-Kopfbalken, `ago()`-Fix im Dashboard.
- **Theme `terminal` wird Standard** (nur ANSI 0–15, folgt dem Terminal-Theme); `preset: classic` stellt die alte 256-Farben-Palette wieder her; Presets catppuccin, dracula, gruvbox, nord, one-dark, solarized, tokyo-night.
- Fehler: postctl zeigte rohe Schlüssel (`stats_posted0`) → Test, der jeden `Tr()`-Schlüssel prüft; calctl `00:00–00:00` an leeren Tagen.

### 2026-10-07 — Runde 2 und 3, Redesigns, neue Tools
- **Runde 2:** taskctl-Ansichten als Tabs mit Zählern, Filter-Chips, Übersicht im Detail; Dashboard mit 3 Spalten und „Today“-Panel (Agenda + letzte Aktivitäten).
- **Runde 3:** diaryctl, calctl, mailctl, notectl, timectl, postctl aufs neue Layout (Header, Row, Panel, einzeilige Fußzeile, Detail ab 120 Spalten); einheitliches Datumsformat `Tue 06 Oct`.
- **Redesigns nach Screenshots:** budgetctl luftiger Kopf (Kennzahlen-Streifen), calctl neu (Pill-Wochenleiste, Kalenderpunkte, Jetzt-Linie, Monats-Minikalender), notectl-Kopf/Menü, Dashboard-Titel und Kartenfarben themenfähig, gedimmter Text auf Auswahlzeilen lesbar (`ui.Row` hebt Subtle→Muted).
- **Nebenansichten-Chrome** (Detail/Editor/Formular/Statistik) in allen 10 Alt-Tools vereinheitlicht; **`ui.TabsLayout`** (exakte Klickbereiche) in Core, notectl und mailctl nutzen es und haben ihre duplizierten Hit-Test-Helfer verloren; notectl-Hover behält Datum-/Pfadfarbe (`ui.HoverRow`); taskctl-README-Tastentabellen auf Code-Stand.
- **healthctl** gebaut (Medikamente, Schedules, Dosis-Log, `remind`, MCP, TUI; DB `0600`; Aktivitätslog nur „a dose“).
- **investctl** gebaut (Holdings/Transaktionen, Stooq-Kurse, Summary/Allocation, Doctor, MCP, TUI; Aktivitätslog nur Zähler).

### 2026-10-08 (bis ~00:30) — Integration und Fixes
- Private Repos `aeon022/healthctl` und `aeon022/investctl` angelegt und gepusht; als Submodule im Root (`d8244f7`).
- `setup.sh`, `scripts/dev-build.sh`, `bump-core.sh`, `test-all.sh` kennen die neuen Tools; README-Tabelle ergänzt; ROADMAP abgehakt.
- `missionctl doctor` listet beide Tools samt DB-Pfaden (`healthctl.db`, `investctl.db`).
- **Dashboard-Karten** „Health“ (Zähler, nie Namen) und „Invest“ (Depotwert, Tagesänderung), nur sichtbar, wenn das Binary installiert ist (`hideUninstalled`); `healthctl today --json` neu.
- **`missionctl notify`:** generisches Banner „medication due“ (einmal je Tag und Anzahl fälliger Dosen).
- **Fix postctl:** zwei Tests hingen von der Uhrzeit ab (ab 22 Uhr lag „jetzt + 26 h“ übermorgen) → Fixture auf „morgen 12:00“.
- **Fix Dashboard (Nutzer-Feedback):** `esc` beendete das Dashboard → beendet nur noch `q`/`ctrl+c` (in der Agenda schließt `esc` sie); mit 10 Karten verschwand das Today-Panel → 3 Spalten ab 120 statt 150 Zellen; Invest-Karte zeigte `[]` → Kürzel nur, wenn vorhanden. Tests von den Schwellen und der Kartenzahl entkoppelt.
- Vorfall: Ein fehlgeschlagener Befehl führte dazu, dass die CLI-Änderungen mit der Commit-Nachricht „chore: bump healthctl, missionctl (dashboard cards, notify)“ gepusht wurden. Inhalt korrekt, Historie nicht umgeschrieben; Test-Fix folgte als eigener Commit.

---

## 3. Privatsphäre-Regeln (bewusst, nicht aufweichen)

- Activity-Log: nur Titel. budgetctl und investctl loggen nur Zähler, healthctl nur „a dose“.
- Gesundheitsdaten tauchen **nicht** in `search`, `plan`, `review` und Activity auf; Dashboard und `notify` zeigen nur Zahlen bzw. „medication due“.
- healthctl-DB mit `0600`. `~/.config/polar/token` bleibt außerhalb von Repos und Chat.
- Tests laufen immer mit Wegwerf-`HOME`; die echte `budget.db` darf nie gelesen werden (Prüfung: mtime unverändert).

---

## 4. Arbeitsweise / Befehle

```bash
scripts/test-all.sh [tools]     # isolierte Tests (alle 13 Module)
scripts/dev-build.sh            # Binaries nach .dev/bin
scripts/dev-env.sh              # Sandbox-Shell mit Wegwerf-HOME
scripts/first-run.sh            # Erststart-Szenario
scripts/bump-core.sh            # Tools auf gepushten Core heben (verweigert bei unpushed Core)
./sync.sh                       # pull + Submodule-Bump + Commit
```
- Lokale Core-Änderungen ungepusht testen: untracked `go.work`.
- Push-Reihenfolge: Core → `bump-core.sh` → Tests → Tool-Repos → Root → `gh run list -R aeon022/<repo>` für alle.
- Forks/Subagenten arbeiten je in einem Repo und committen nur lokal; bei Usage-Limit per `SendMessage` fortsetzen.
- zsh: bei `grep --include=*.go` Anführungszeichen setzen (`--include='*.go'`), sonst bricht die Schleife ab.

---

## 5. Offen (Details in [TODO.md](TODO.md) und [ROADMAP.md](ROADMAP.md))

**Bewusst ausgenommen:** Gmail-OAuth in mailctl (braucht Google-Cloud-Client-ID vom Nutzer).

**Nicht live geprüft:** Farben/Maus im echten Terminal (Checkliste `TESTING.md` §5, 20 Punkte), echte Stooq-Abfragen, `healthctl remind`-Benachrichtigungen, Dashboard bei sehr niedrigen Terminals.

**Bekannte kleine Punkte:** habctl-Langansichten werden von `ui.Frame` auf winzigen Terminals abgeschnitten; postctl-Lade-/Fehlerbildschirme ohne Rahmen und einige deutsche `statusMessage` nicht in `Tr()`; timectl-Eingabeprompts als Fußzeilen-Prompts; notectl-Link-Graph scrollt nicht; taskctl-Done-Zahl erst nach Öffnen des Done-Tabs; Today-Panel nicht klickbar; Invest-Karte ohne Zifferntaste.

**Roadmap, noch offen:** Abschnitt C (je Tool Feinschliff: taskctl-Pills/Prioritätspunkte, habctl-Heatmap, calctl-Wochenraster, notectl-Markdown, mailctl-Symbole, timectl-Tagesband, diaryctl-Kalenderband, postctl-Markenfarben), D (Themes live durchschalten, Willkommensbildschirm, Animationen mit `reduce_motion`), budgetctl-UX-Ideen (Monatsbilanz-Kopf, Spaltenköpfe, Insights, Vorlagen auf Zifferntasten, Jump-Modus, Drill-down, Teilbuchungen), Fuzzy-Suche mit Hervorhebung, `:`-Befehlszeile mit Verlauf, Vorschau-Panel in mailctl/notectl/taskctl/diaryctl, Maus ausbauen, konfliktfreie Kürzel; postctl-`Delete()` für sechs Plattformen; kleinere Tool-Ideen (Kontakte, Linkliste, Fokus-Timer). Teile von C wurden in den Layout-Runden bereits umgesetzt (Spalten/Tabs/Pills), sind aber nicht einzeln abgehakt — vor dem Abhaken im Code prüfen.

**Produkt/Monetarisierung:** zurückgestellt (Memory „Monetization deferred“), bis der Nutzer Polish/Test für abgeschlossen erklärt.

---

## 6. Nächste sinnvolle Schritte

1. Sichtprüfung im echten Terminal nach `TESTING.md` §5 (v. a. Dashboard bei der eigenen Fenstergröße).
2. CI des CLI-Repos (Submodule `missionctl`) nach `ae3375b` prüfen; healthctl (`dcc49fc`) und postctl (`b613b4d`) sind grün.
3. `proposals/healthctl` und `proposals/investctl` als „umgesetzt“ markieren.
4. Entscheiden, welche Roadmap-Punkte aus C/D als Nächstes drankommen.
