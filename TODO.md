# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` über die ganze Suite. Reihenfolge = Größe des Schnitts.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).

## Erledigt (lokal committet, nicht gepusht)

- [x] **Versionsdrift** `cobra` (timectl, diaryctl, missionctl → v1.10.2), `mcp-go` (timectl, diaryctl → v0.55.1), `fuzzy` (timectl, diaryctl, calctl, taskctl → v0.1.3). Tests in timectl/diaryctl auf `*mcp.CallToolResult` angepasst.
- [x] **notectl:** `muesli/reflow` entfernt, `ansi.Hardwrap` (aus `charmbracelet/x/ansi`, war schon Dependency) statt `wrap.String`.
- [x] `go mod tidy` in allen Tools.

## Offen — braucht Push von `missionctl-core` (Consumer ziehen Core per Pseudo-Version)

- [ ] **`truncate()` 4× dupliziert** (missionctl `cmd/dashboard.go`, timectl, habctl, calctl `internal/tui/tui.go`). Zwei Semantiken: rune-basiert (timectl/habctl/calctl) vs. breiten-basiert mit `lipgloss.Width` (missionctl). Eine breiten-basierte Version nach `missionctl-core` (z. B. `humanize`), Core pushen, Tools bumpen. `wordWrap` ebenfalls (2×, calctl + 1).
- [ ] **TUI-Hilfsfunktionen allgemein:** bei jedem Tool-Touch gemeinsame Teile (Overlay, Keymap, Palette, Hilfe-Rendering) nach Core ziehen. Die `tui.go`-Monolithen: habctl 4.4k, notectl 3.7k, budgetctl 3.6k, mailctl 2.4k, taskctl 2.4k Zeilen.

## Offen — Verhalten ändert sich, braucht Entscheidung

- [ ] **`viper` entfernen** (budgetctl 4 Dateien/30 Aufrufe + 13 Test-Aufrufe, calctl 21, mailctl 16, taskctl 12). Core hat nur `config.DataDir/ResolveDir`, keinen Loader. Zuerst kleinen YAML+Env-Loader (`yaml.v3` + `os.Getenv`, Präfix `<TOOL>_`) in Core, dann je Tool umstellen. Risiko: Env-Override-Verhalten (`AutomaticEnv`) muss 1:1 bleiben.
- [ ] **habctl `internal/ai` (271 Z.) vs. `missionctl-core/ai` (320 Z.):** nicht einfach austauschbar — habctl hat Gemini über Google-OAuth (`GOOGLE_REFRESH_TOKEN`, `internal/auth/google.go`, vom TUI genutzt). Entweder Token-Hook in Core-`ai` (`Detect(prefix, opts)`) oder OAuth-Pfad streichen. Danach `anthropic-sdk-go`, `openai-go`, ggf. `oauth2` aus habctl entfernen.
- [ ] **`google/uuid`** (11 Dateien): nur ersetzen, wenn nirgends UUID-Format nötig ist (`crypto/rand` + `hex`). Kandidat, kein sicherer Schnitt.
- [ ] **`termenv` als direkte Dependency** (5 Tools): `go mod tidy` behält sie, also wird sie importiert. Prüfen, ob lipgloss reicht.
- [ ] **Zwei Bubbletea-Generationen:** mailctl + notectl auf `charm.land/*/v2`, Rest auf `charmbracelet/*` v1. Migrationsprojekt, Rest nachziehen.

## Offen — klein / prüfen

- [ ] `themes/` im Root vs. `missionctl-core/theme`: liegen die Presets doppelt? Nicht verifiziert.
- [ ] `SESSION-2026-08-02.md` (Session-Log) archivieren oder löschen. `stage.md`, `git-deploy.md` (von `AGENTS.md` referenziert) und `go-tutorial/` bleiben.
- [ ] `SUITE_AUDIT.md` / `POSTCTL_AUDIT.md` auf Aktualität prüfen.
- [ ] Vorbestehend unformatiert (`gofmt -l`): timectl `cmd/week.go`, `internal/tui/tui.go`; diaryctl `internal/models/models.go`.
- [ ] `notectl/.claude/` ist ungetrackt — in `.gitignore` oder committen.
