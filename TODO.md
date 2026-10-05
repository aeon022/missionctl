# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` über die ganze Suite. Reihenfolge = Größe des Schnitts.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).

## Erledigt (lokal committet, nicht gepusht)

- [x] **Versionsdrift** `cobra` (timectl, diaryctl, missionctl → v1.10.2), `mcp-go` (timectl, diaryctl → v0.55.1), `fuzzy` (timectl, diaryctl, calctl, taskctl → v0.1.3). Tests in timectl/diaryctl auf `*mcp.CallToolResult` angepasst.
- [x] **notectl:** `muesli/reflow` entfernt, `ansi.Hardwrap` (aus `charmbracelet/x/ansi`, war schon Dependency) statt `wrap.String`.
- [x] `go mod tidy` in allen Tools.
- [x] **Tote Funktionen entfernt** (`deadcode`): taskctl `ListNames`/`ProviderForList`; notectl `ListAppleFolders`, `RenderPlain`, `ReadJoplin`, `SearchJoplin`, `ListJoplinFolders`; postctl `TwitterLength`.

- [x] **viper entfernt** (budgetctl, calctl, mailctl, taskctl): neuer `missionctl-core/config.Store` (YAML + `<TOOL>_<KEY>`-Env, Env-Präfix erst nach `Load()` aktiv wie bei viper), Tools umgestellt, `mapstructure`- → `yaml`-Tags. Tests grün (mit lokalem `go.work`).
- [x] **Core-Bug behoben:** `keymap.Help.Text()` war als „ungenutzt“ gelöscht worden, budgetctl ruft es aber auf → Core-HEAD brach den budgetctl-Build. Wiederhergestellt.

## ⚠ Vor dem nächsten Build: `missionctl-core` pushen und Tools bumpen

Die 4 Tool-Commits brauchen den neuen Core (`config.Store`). Deren `go.mod` zeigt noch auf den alten Core-Stand → ohne Push + `go get github.com/aeon022/missionctl-core@main` + `go mod tidy` je Tool baut es dort nicht. Danach `./sync.sh`-artig die Pointer im Root bumpen.

## Offen — braucht Push von `missionctl-core` (Consumer ziehen Core per Pseudo-Version)

- [ ] **`truncate()` 4× dupliziert** (missionctl `cmd/dashboard.go`, timectl, habctl, calctl `internal/tui/tui.go`). Zwei Semantiken: rune-basiert (timectl/habctl/calctl) vs. breiten-basiert mit `lipgloss.Width` (missionctl). Eine breiten-basierte Version nach `missionctl-core` (z. B. `humanize`), Core pushen, Tools bumpen. `wordWrap` ebenfalls (2×, calctl + 1).
- [ ] **TUI-Hilfsfunktionen allgemein:** bei jedem Tool-Touch gemeinsame Teile (Overlay, Keymap, Palette, Hilfe-Rendering) nach Core ziehen. Die `tui.go`-Monolithen: habctl 4.4k, notectl 3.7k, budgetctl 3.6k, mailctl 2.4k, taskctl 2.4k Zeilen.

## Offen — Verhalten ändert sich, braucht Entscheidung

- [ ] **habctl `internal/ai` (271 Z.) vs. `missionctl-core/ai` (320 Z.):** nicht einfach austauschbar — habctl hat Gemini über Google-OAuth (`GOOGLE_REFRESH_TOKEN`, `internal/auth/google.go`, vom TUI genutzt). Entweder Token-Hook in Core-`ai` (`Detect(prefix, opts)`) oder OAuth-Pfad streichen. Danach `anthropic-sdk-go`, `openai-go`, ggf. `oauth2` aus habctl entfernen.
- [ ] **`google/uuid`** (11 Dateien): nur ersetzen, wenn nirgends UUID-Format nötig ist (`crypto/rand` + `hex`). Kandidat, kein sicherer Schnitt.
- [ ] **`termenv` als direkte Dependency** (5 Tools): `go mod tidy` behält sie, also wird sie importiert. Prüfen, ob lipgloss reicht.
- [ ] **Zwei Bubbletea-Generationen:** mailctl + notectl auf `charm.land/*/v2`, Rest auf `charmbracelet/*` v1. Migrationsprojekt, Rest nachziehen.

## Verbesserungsvorschläge für die Suite (Audit Teil 2, 2026-10-05)

Nach Wirkung sortiert. Belege stammen aus `deadcode`, `go test -cover`, grep über alle Repos.

1. **Test-Isolation (dringend).** `*_DATA_DIR` aus der Shell kann Tests auf die echte DB umleiten — ist heute bei budgetctl passiert (siehe oben). Jedes Tool bekommt ein `TestMain`, das `<TOOL>_DATA_DIR` etc. leert, oder ein `scripts/test-all.sh`, das `env -u` setzt. notectl macht das Muster schon richtig (`envEnabled` erst nach `Init()`).
2. **Core-Pins driften.** `go.mod` der Tools zeigt auf 6 verschiedene `missionctl-core`-Stände (0803 … 0821). `sync.sh` bumpt nur Submodule-Pointer, nicht den Core-Pin. Skript-Schritt: `go get missionctl-core@main && go mod tidy` je Tool. Alternativ ein eingechecktes `go.work` im Root (kein Bump-Tanz lokal, CI baut weiter mit Pins).
3. **`runAppleScript` 4× kopiert** (calctl, mailctl, notectl, taskctl) plus 4 `escapeAS`-Varianten — mailctl escaped zusätzlich `\n`/`\r`, die anderen nicht; Fehlerformat und Trimmen weichen ab. Ein `missionctl-core/applescript` (`Run`, `Escape`) mit Tests; Unterschiede bewusst festlegen, nicht blind vereinheitlichen.
4. **notectl hat einen eigenen Config-Store** (`internal/config`, ~150 Z., gleiche Semantik wie der neue `config.Store`). Auf Core umstellen, danach gibt es genau eine Implementierung.
5. **postctl ohne CI/Release** (`.github/workflows` fehlt; alle anderen haben `ci.yml` + `release.yml`). `internal/platforms` unter 20 % Abdeckung.
6. **Abdeckung:** Schnitt pro Paket — taskctl 19 %, diaryctl 19 %, missionctl 14 %, habctl 24 %, notectl 27 %. Lücken mit echtem Risiko: `calctl/internal/calendar` (<20 %, AppleScript/Parser), `taskctl/internal/nlpdate` (<20 %, Datums-Parser), `postctl/internal/platforms`. TUI-Pakete drücken den Schnitt, sind aber nicht der Hebel.
7. **MCP-Boilerplate:** je Tool 240–560 Zeilen `mcpserver`, `jsonResult`/Fehler-Wrapper mehrfach (timectl, postctl identisch). Kleiner `missionctl-core/mcpx` (Result-Helper) würde ~20 Zeilen/Tool sparen — niedrige Priorität.
8. **TUI-Monolithen** (`tui.go` je 1,6–4,4k Zeilen) in Dateien nach View teilen (list/detail/form/overlay). Kein Verhalten ändern, nur Navigierbarkeit und Review-Größe. Zusammen mit dem Bubbletea-v2-Umzug planen.
9. **Dead code:** `deadcode` (macOS-Build) ist jetzt sauber bis auf `resolveAccountCursor` (nur Tests), `*ForTest`-Hooks und das Linux-only Thunderbird-Backend in mailctl (laut README noch nicht gegen echte Installation getestet).
10. **Offene Produkt-Lücken** (aus `SUITE_AUDIT.md`, noch gültig?): mailctl-Sync ohne Lade-Feedback, Attachments/Unsubscribe/Gmail-OAuth.

## Offen — klein / prüfen

- [ ] `themes/` im Root vs. `missionctl-core/theme`: liegen die Presets doppelt? Nicht verifiziert.
- [ ] `SESSION-2026-08-02.md` (Session-Log) archivieren oder löschen. `stage.md`, `git-deploy.md` (von `AGENTS.md` referenziert) und `go-tutorial/` bleiben.
- [ ] `SUITE_AUDIT.md` / `POSTCTL_AUDIT.md` auf Aktualität prüfen.
- [ ] Vorbestehend unformatiert (`gofmt -l`): timectl `cmd/week.go`, `internal/tui/tui.go`; diaryctl `internal/models/models.go`.
- [ ] `notectl/.claude/` ist ungetrackt — in `.gitignore` oder committen.
