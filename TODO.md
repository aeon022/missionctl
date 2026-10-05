# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` + `deadcode` + `go test -cover` über die ganze Suite.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).
Lokal testen ohne `setup.sh`: siehe [TESTING.md](TESTING.md).

## ⚠ Vor dem Push: Reihenfolge

Mehrere Tool-Commits brauchen neuen `missionctl-core`-Code (`config.Store`, `applescript`,
`humanize.Truncate`, `ai`-Hooks). Deren `go.mod` zeigt noch auf den alten Core-Stand, sie bauen
lokal nur über das (ungetrackte) `go.work`.

1. `missionctl-core` pushen.
2. `scripts/bump-core.sh` — pinnt jedes Tool auf Core-`main`, tidy, build+test, committet.
3. Tool-Repos pushen, danach Root (`./sync.sh` bzw. Pointer committen).

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

## Bewusst nicht gemacht (mit Begründung)

- **notectl-Config → Core-`Store`:** notectl braucht Mutex (TUI-Goroutinen), typisiertes `getBool` und `map[string]string`-Overrides. Der Core-Store ist absichtlich klein und nicht thread-safe; Angleichen würde ihn aufblähen. Zwei Implementierungen bleiben, bis ein zweites Tool Thread-Safety braucht.
- **`google/uuid` (11 Dateien):** nur ersetzbar, wenn nirgends das UUID-Format zählt. Kein sicherer Schnitt.
- **`termenv` als direkte Dependency:** wird nur in den `tui_test.go` importiert (Farbprofil für Tests) → korrekt direkt. Kein Handlungsbedarf.
- **MCP-Result-Helper in Core:** `jsonResult` existiert nur in 2 Tools — spart ~20 Zeilen, nicht der Aufwand.
- **`nlpdate`-Abdeckung:** meine erste Auswertung war falsch, das Paket hat 100 %.
- **postctl `internal/platforms` (14 %):** fast nur Live-API-Calls für 10 Dienste; sinnvolle Tests brauchen pro Dienst einen HTTP-Mock — eigenes Projekt, bei Bedarf pro Plattform.
- **postctl `gofmt`:** ~45 Dateien betroffen → riesiger Format-Diff, bewusst separat.

## Offen — eigene Projekte (nicht „mal eben“)

- [ ] **Bubbletea v1 → v2** für die 7 Tools, die noch auf `charmbracelet/*` v1 sind (mailctl + notectl sind auf `charm.land/*/v2`). Danach nur noch eine Generation.
- [ ] **TUI-Monolithen aufteilen** (`tui.go` je 1,6–4,4k Zeilen: habctl, notectl, budgetctl, mailctl, taskctl …) nach Views; am besten zusammen mit dem v2-Umzug.
- [ ] **Abdeckung** weiter heben: diaryctl 19 %, missionctl 14 %, habctl 24 %, notectl 27 % (Paket-Schnitt; TUI-Pakete drücken ihn).
- [ ] **Thunderbird-Backend (Linux)** in mailctl: laut README noch nicht gegen echte Installation getestet; `deadcode` unter macOS sieht es als ungenutzt, ist es aber nicht.
- [ ] **Produkt-Lücken** aus `SUITE_AUDIT.md` (Snapshot, ggf. veraltet): mailctl-Sync ohne Lade-Feedback, Attachments/Unsubscribe/Gmail-OAuth.
- [ ] `resolveAccountCursor` (notectl) wird nur von Tests genutzt — Funktion + Test streichen oder verdrahten.
