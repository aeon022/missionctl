# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` + `deadcode` + `go test -cover` über die ganze Suite.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).
Lokal testen ohne `setup.sh`: siehe [TESTING.md](TESTING.md).

## Stand 2026-10-08

- Alles ist **gepusht** (Core `82edca7`, alle 12 Tool-Repos + Root); CI war nach dem letzten Push in Core, den 8 Tool-Repos, postctl, healthctl und investctl grün. Für die allerletzten Pushes (Dashboard-Fix `ae3375b`, healthctl `dcc49fc`) wurde die CI nicht abgewartet — `gh run list` prüfen.
- Detaillierter Stand und Änderungsprotokoll: [stage.md](stage.md). Der Stand vom 2026-08-04 liegt in `docs/archive/stage-2026-08-04.md`.
- Offen bleibt die **Sichtprüfung im echten Terminal** (Checkliste: `TESTING.md` Abschnitt 5).

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

## Aus dem postctl-Update (2026-10-16) — Übertrag auf die anderen Tools (morgen)

postctl ist gepusht (`b838b8b`), Core `f71f85d` auch. Für die übrigen Tools:

- [x] ~~**Core bumpen** auf `f71f85d`~~ — erledigt 2026-10-17 (alle Tools sind auf Core `9de8a0e`, das f71f85d enthält); ursprünglich: (live Themes: `theme.Apply/Presets/Current/OnChange/Save`): mailctl, calctl, taskctl, notectl, budgetctl, timectl, diaryctl, healthctl, investctl, missionctl-cli (habctl behält seine eigene Palette).
- [x] ~~**Live-Theme-Wechsel in allen TUIs**~~ — erledigt 2026-10-18: Taste `T` (timectl: `C`, da `T` = Task-Picker) + `:theme`, `theme.Cycle()` im Core, habctl folgt jetzt dem Suite-Theme, Onboarding-Checkliste im leeren Zustand in allen Tools; Dashboard `T`. Offen: eigene Theme-Zeile in den Settings.
- [ ] **Theme-Zeile in den Settings** jedes Tools (Muster: postctl `cycleSettingDir` + `refreshStyles` über `theme.OnChange`). Achtung: Styles, die ein Tool auf Package-Ebene aus Theme-Farben baut (z. B. `dimStyle`), müssen beim Wechsel neu gebaut werden, sonst bleiben sie auf der alten Palette.
- [x] ~~**Root-Zeiger** auf `missionctl-core` anheben~~ — mit dem Sicherheits-Commit erledigt; ursprünglich: (`git add missionctl-core && git commit`) — steht gerade als `M missionctl-core` offen.
- [~] **Testregel in jedem Tool:** *teilweise* — Core `syncdir` entfernt in jedem Test-Binary die exportierten `*_DATA_DIR`-Variablen (2026-10-17). Offen: `TestMain` mit Wegwerf-`HOME` pro Paket. Ursprünglich: `TestMain` mit Wegwerf-`HOME` (Vorlage: postctl `*/testmain_test.go`). Vorfall 2026-10-16: ein Test (Enter auf eine per Zeilennummer gewählte Settings-Zeile) überschrieb die echte `~/.config/postctl/config.yaml` und rief Mastodon im Netz auf. Alle Tools prüfen: Tests, die `Save*`/Config/`exec` ohne `t.Setenv("HOME")` nutzen; Settings-Zeilen in Tests nie per Index wählen.
- [ ] **UI-Ideen aus postctl zum Übertragen:** Gesundheits-Panel (Token-/Sync-Alter), einheitliche `:`-Palette, Spinner nur während des Ladens, Logs-Kopfbereich, Settings als mehrere umrandete Bereiche, Klick-Raster mit gemeinsamem Layout für Zeichnen und Hit-Test (Kalender-Muster), Onboarding-Checkliste im leeren Dashboard.
- [ ] stage.md / ROADMAP für die Suite nachziehen (postctl: Kalender-Tab, Profil-Schutz, Editor-Vorschau, Composer, Stats, Palette, Suche).

## Offen

- [x] ~~Zeitstempel `RFC3339Nano` als TEXT~~ — timectl schreibt fixed-width (`writeLayout`) mit einmaliger Migration; habctl sortiert nach `id`.

- [ ] **Sichtprüfung** (v2-Migration, drei Layout-Runden, healthctl/investctl) — gepusht ist bereits, Sichtprüfung steht aus: `TESTING.md` Abschnitt 5.
- [ ] diaryctl `suite`: fremde Config-Layer außer `data_dir` werden nicht gelesen.
- [ ] habctl: `skip_allowed` wird bei Weekly-Habits in der aktuellen Serie ignoriert (bewusst unverändert) — Produktentscheidung.
- [ ] Abdeckung weiter: Render-/Mauscode der TUIs, postctl `platforms` Rest (Twitter-Cookie/chromedp, Browser-Auth, Threads-Bildupload), notectl `mirror`/`syncdispatch` (brauchen Notes/Joplin), budgetctl-Import-Assistent mit Dateiwähler, AppleScript-nahe Befehle.
- [ ] Offene Beobachtungen: `budgetctl` liest weiter `./budgetctl.yaml` aus dem Arbeitsverzeichnis (spezifischer Name, bewusst belassen); postctl-OAuth-Callbacktest bindet festen Port 8753.
- [ ] **Thunderbird-Backend (Linux)** in mailctl: laut README nicht gegen echte Installation getestet.
- [x] Unsubscribe-Helper (mailctl `U`) erledigt.
- [ ] **Gmail-OAuth** (mailctl) — braucht eine Google-Cloud-Client-ID vom Nutzer; bewusst ausgenommen.
- [ ] Neu 2026-10-08: habctl-Langansichten werden von `ui.Frame` auf winzigen Terminals abgeschnitten; postctl-Lade-/Fehlerbildschirme umgehen den Rahmen und einige deutsche `statusMessage`-Texte fehlen in `Tr()`; timectl-Eingabeprompts bleiben Fußzeilen-Prompts; notectl-Link-Graph scrollt nicht; taskctl zeigt die Done-Zahl erst nach dem Öffnen des Done-Tabs; Dashboard-Today-Panel ist nicht klickbar.
- [ ] Unverifiziert (braucht Live-Test): echte Stooq-Kurse (investctl), `healthctl remind`-Benachrichtigungen, Farben/Maus im echten Terminal.
- [ ] Dashboard-Raster: Invest-Karte hat keine Zifferntaste (nur 1–9); bei sehr niedrigen Terminals mit 10 Karten bleibt das Today-Panel ausgeblendet.
- [ ] `proposals/healthctl` und `proposals/investctl` als „umgesetzt“ markieren.

- [ ] postctl: neue Screenshots für postctl.sh und missionctl.sh (neue TUI: Kalender, Profile, Themes) — morgen

## Sicherheits-Audit der Suite (2026-10-17) — Stand
Behoben (lokal committet, siehe `git log` je Tool): owner-only Dateien (Core `secure.Init`, Aktivitätslog 0600), mailctl `send_email` nur per Opt-in (`MAILCTL_MCP_ALLOW_SEND=1`), taskctl AppleScript-Escaping in der Pomodoro-Benachrichtigung, notectl `Write` nur innerhalb des Vaults, `confirm=true` für alle `delete_*`-MCP-Tools, budgetctl Import nur CSV/TSV/TXT, Lizenz-HTTP mit Timeout.
Behoben 2026-10-17 (Core `aaca411`): `syncdir.Acquire` nimmt jetzt eine *geteilte* Sperre — TUI, Daemon, CLI und MCP schließen sich nicht mehr aus (SQLite-Busy-Timeout koordiniert); `syncdir.InUse` für `doctor`. Alle Tools sind auf Core `aaca411` gebumpt.
