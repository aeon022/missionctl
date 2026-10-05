# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` + `deadcode` + `go test -cover` über die ganze Suite.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).
Lokal testen ohne `setup.sh`: siehe [TESTING.md](TESTING.md).

## ⚠ Stand vor dem Push

- `missionctl-core` ist **gepusht** (`5936b00`), alle Tools sind darauf gepinnt (`scripts/bump-core.sh`).
- Alle **Tool-Repos sind lokal committet, aber nicht gepusht** (4–12 Commits vor `origin/main`), ebenso der Root.
- Vor dem Push einmal **von Hand im Terminal prüfen** (nicht headless testbar): Rendering, Maus (Klick/Doppelklick/Hover/Rad), Alt-Screen, Hell/Dunkel-Farben, budgetctl-Dateiwähler, postctl-Boxen (`StyleBox` `+2`), diaryctl-Vim-Modus der Textfelder.
- Reihenfolge: Tool-Repos pushen, dann Root (`git submodule`-Pointer sind committet).

## Erledigt (lokal committet)

**Dependencies / Aufräumen**
- [x] Versionsdrift: `cobra` v1.10.2, `mcp-go` v0.55.1, `fuzzy` v0.1.3 überall.
- [x] `muesli/reflow` aus notectl (→ `ansi.Hardwrap`).
- [x] `viper` aus budgetctl/calctl/mailctl/taskctl → `missionctl-core/config.Store`.
- [x] habctl: privater LLM-Provider (271 Z.) → dünner Adapter über `missionctl-core/ai`; Google-OAuth-Gemini über Hooks `ai.GeminiAvailable/GeminiKey`.
- [x] `runAppleScript`/`escapeAS` 4× → `missionctl-core/applescript` (`Run`, `RunRaw`, `Escape`, `EscapeLine`).
- [x] `truncate()` 3× → `humanize.Truncate` (behebt nebenbei Slice-Panic bei n ≤ 1 in habctl/calctl). missionctl `dashboard.go` bleibt bei seiner breiten-basierten Variante.
- [x] Tote Funktionen entfernt (taskctl, notectl, postctl).
- [x] `themes/*.yaml` im Root gelöscht (byte-identisch zu `missionctl-core/theme/presets`); `themes/iterm` bleibt.
- [x] `SESSION-2026-08-02.md` → `docs/archive/`; Audit-Berichte als Snapshot markiert; `gofmt` in allen Tools außer postctl.
- [x] Core-Bug: `keymap.Help.Text()` war als „ungenutzt“ gelöscht, budgetctl ruft es auf → wiederhergestellt.

**Tests / CI / Tooling**
- [x] `scripts/test-all.sh` (isolierte Tests: Wegwerf-`HOME`, keine `*_DATA_DIR`/API-Keys), `scripts/dev-build.sh`, `scripts/dev-env.sh`, `scripts/bump-core.sh`, `TESTING.md`.
- [x] Neue Tests: taskctl Store (0 → 88 %), calctl `parseEvents` + Create-Script, postctl MCP-Handler (0 → 70 %), core `config.Store`, `applescript`, `Truncate`.
- [x] postctl: `ci.yml` (vet/test/build) wie bei den anderen Tools.

**Bubble Tea v2 + TUI-Aufteilung (2026-10-05)**
- [x] Alle 8 v1-Tools auf `charm.land/*/v2` (timectl, taskctl, calctl, diaryctl, budgetctl, habctl, postctl, missionctl-cli). Es gibt nur noch eine Generation (v1 bleibt nur indirekt über `missionctl-core/theme`).
- [x] `tui.go` in allen 8 Tools aufgeteilt in `tui/styles/update/view/commands/helpers` (reine Verschiebung; taskctl: Update steckt noch in `view.go`).
- [x] v2-Fallen behoben: Leertaste ist `"space"` (auch schon in mailctl/notectl kaputt gewesen), Textfeld-Breite 0 kürzt Placeholder auf 1 Zeichen, lipgloss v2 strippt ANSI nicht mehr beim Pipen (habctl-CLI, missionctl-cli über `colorprofile`), `Width/Height` schließen den Rahmen ein (postctl).
- [x] Echte Fehler, die beim Testschreiben auffielen und behoben sind:
  - diaryctl: Streak überbrückte Lücken / war um Mitternacht 0 (UTC vs. lokal) / `|` in Commit-Betreffen zerlegte den git-Reader / `suite` las fremde DBs von festen Pfaden (ignorierte `*_DATA_DIR`, Dropbox-Daten unsichtbar) und verglich „heute“ in UTC.
  - habctl: Streak stand jeden Morgen auf 0 bis zum ersten Check-in (`streak_at_risk` damit unbrauchbar); archivierte Habits verhinderten 100 %-Tage im Kalender.
  - notectl: `Vaults()` leer direkt nach `VaultAdd` (Free-Limit nie durchgesetzt); `contractHome` kürzte fremde Pfade; Leerzeile mit Spaces trennte keine Blöcke; Nicht-ASCII-Titel → Dateiname `.md` (Notizen überschrieben sich); `notes.Delete` konnte aus dem Vault ausbrechen.
  - missionctl-cli: „1 events today“.
- [x] Abdeckung: diaryctl store 0→86 %, render 27→98 %; habctl store 43→88 %, ai 16→69 %, config 0→86 %; notectl config 0→83 %, notes 47→69 %; missionctl-cli cmd 27→39 %; Leertasten-Regressionstests in taskctl, budgetctl, mailctl, habctl, notectl.
- [x] notectl: `resolveAccountCursor` gelöscht (nur Tests riefen es auf).

- [x] taskctl: `Init/Update/handleKey` nach `update.go`; postctl: `gofmt` (49 Dateien, reiner Format-Commit).

**Zweite Test-Runde (2026-10-05, nach dem v2-Push)**
- [x] postctl `platforms` 14→64 % mit HTTP-Mocks (Basis-URLs injizierbar). Fehler behoben: fällige Posts wurden bei Dev.to/Medium als Entwurf gespeichert; Discord-Posts ohne Message-ID (nie löschbar); Twitter-`Delete` war ein Stub; XSS im OAuth-Callback.
- [x] diaryctl: `suite` 21→90 % (echte Schemas der anderen Tools), TUI 25→55 %. Fehler behoben: archivierte Habits im Tagebuch, Streak morgens 0, Suche/Palette verschluckten Leerzeichen/Umlaute, Editor-Taste `a` startete KI beim Tippen (**KI jetzt auf `ctrl+g`**).
- [x] habctl: längste Wochenserie berechnet statt Platzhalter; TUI 11→25 %.
- [x] taskctl TUI 23→76 %, calctl TUI 34→83 %. Fehler behoben: Bearbeiten verlor Unteraufgaben (taskctl) bzw. Notizen/Teilnehmer/Ganztag (calctl); `firstURL` bei `İ`; Daemon-PID ≤ 0; DST-Tage (25 h/23 h) in calctl; negative Dauer; `--until` ohne letzten Tag; YAML-Kopf bei `"` im Titel; `wordWrap` bytes statt Runen.
- [x] budgetctl TUI 46→59 %, mailctl 58→75 %, notectl 58→67 %. Fehler behoben: Löschen aktualisierte nur die gefilterte Liste (Duplikate/Wiederauftauchen, mailctl+notectl); Gelesen-Status ging verloren; `runeLimit(s,0)` Absturz.
- [x] calctl: Draft-Datei über `os.CreateTemp` statt vorhersehbarem `/tmp`-Pfad; `./config.yaml` nicht mehr im Config-Suchpfad.
- [x] Geprüft: das Listenkopie-Muster (`all*` + gefilterte Liste) kommt in budgetctl/habctl/timectl nicht vor (sie laden nach Änderungen neu).

## Bewusst nicht gemacht (mit Begründung)

- **notectl-Config → Core-`Store`:** notectl braucht Mutex (TUI-Goroutinen), typisiertes `getBool` und `map[string]string`-Overrides. Der Core-Store ist absichtlich klein und nicht thread-safe; Angleichen würde ihn aufblähen. Zwei Implementierungen bleiben, bis ein zweites Tool Thread-Safety braucht.
- **`google/uuid` (11 Dateien):** nur ersetzbar, wenn nirgends das UUID-Format zählt. Kein sicherer Schnitt.
- **`termenv` als direkte Dependency:** wird nur in den `tui_test.go` importiert (Farbprofil für Tests) → korrekt direkt. Kein Handlungsbedarf.
- **MCP-Result-Helper in Core:** `jsonResult` existiert nur in 2 Tools — spart ~20 Zeilen, nicht der Aufwand.
- **`nlpdate`-Abdeckung:** meine erste Auswertung war falsch, das Paket hat 100 %.

## Offen

- [ ] **Zeitstempel-Format `RFC3339Nano` als TEXT sortiert/verglichen** (habctl: behoben, Sortierung nach `id`; **timectl**: `started_at`-Sortierung/Bereiche haben dasselbe Risiko, praktisch nur relevant bei Einträgen im selben Sekundenbruchteil auf UTC-Rechnern, `Z` sortiert hinter Ziffern). Falls nötig: Fixed-Width-Layout (`.000000000`) fürs Schreiben.

- [ ] **Sichtprüfung der v2-Migration** (siehe oben) — danach pushen.
- [ ] diaryctl `suite`: fremde Config-Layer außer `data_dir` werden nicht gelesen.
- [ ] habctl: `skip_allowed` wird bei Weekly-Habits in der aktuellen Serie ignoriert (bewusst unverändert) — Produktentscheidung.
- [ ] Abdeckung weiter: Render-/Mauscode der TUIs, postctl `platforms` Rest (Twitter-Cookie/chromedp, Browser-Auth, Threads-Bildupload), notectl `mirror`/`syncdispatch` (brauchen Notes/Joplin), budgetctl-Import-Assistent mit Dateiwähler, AppleScript-nahe Befehle.
- [ ] Offene Beobachtungen: `budgetctl` liest weiter `./budgetctl.yaml` aus dem Arbeitsverzeichnis (spezifischer Name, bewusst belassen); postctl-OAuth-Callbacktest bindet festen Port 8753.
- [ ] **Thunderbird-Backend (Linux)** in mailctl: laut README nicht gegen echte Installation getestet.
- [ ] Produkt-Features aus `SUITE_AUDIT.md` (Snapshot): Unsubscribe-Helper, Gmail-OAuth.
