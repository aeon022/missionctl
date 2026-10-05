# Lokal testen — ohne `setup.sh`

`setup.sh` baut **und installiert** (`~/.local/bin`, MCP-Registrierung in `~/.claude.json`).
Zum Testen von Änderungen ist das unnötig und riskant. Stattdessen: bauen in `./.dev/`,
in einem Sandbox-`HOME` laufen lassen. Nichts davon ist im Repo getrackt (`.gitignore`).

## 0. Einmalig: Workspace, damit lokale Core-Änderungen greifen

Die Tools pinnen `missionctl-core` per Version aus dem Netz. Solange Core-Änderungen nicht
gepusht sind, braucht es ein `go.work` im Repo-Root:

```sh
cd ~/Developing/Projects/missionctl
cat > go.work <<'W'
go 1.26.5

use (
	./missionctl-core ./budgetctl ./calctl ./mailctl ./taskctl
	./notectl ./habctl ./timectl ./diaryctl ./missionctl ./postctl
)
W
```

(Ist in `.gitignore`. Löschen = zurück auf die gepinnten, gepushten Core-Versionen — so
baut es dann auch CI.)

## 1. Automatische Tests (isoliert)

```sh
scripts/test-all.sh              # alle: vet + test, ~1 Minute
scripts/test-all.sh budgetctl    # nur ein Tool
```

Das Skript tauscht `HOME` gegen ein Wegwerf-Verzeichnis und löscht `*_DATA_DIR`,
`*_PROVIDER`, `*_API_KEY` usw. aus der Umgebung. Grund: dein `BUDGETCTL_DATA_DIR`
zeigt auf die echte Dropbox-Datenbank — ein normaler `go test` kann dort schreiben.
**Tests immer über das Skript starten**, nicht per nacktem `go test` in der Shell.

## 2. Von Hand ausprobieren (TUI, CLI, MCP)

```sh
scripts/dev-build.sh             # baut alle 10 Tools nach .dev/bin (installiert nichts)
source scripts/dev-env.sh        # DIESE Shell: Sandbox-HOME + dev-Binaries vorn im PATH

budgetctl                        # startet die dev-Version, leere Sandbox-Daten
calctl today
which budgetctl                  # → .../missionctl/.dev/bin/budgetctl
```

Zurück zur normalen Shell: Terminal-Tab schließen oder `exec zsh`.

- Eine einzelne Änderung: `cd budgetctl && go run . ` (mit `source scripts/dev-env.sh`
  davor, sonst läuft es auf deinen echten Daten).
- Frische Daten: `rm -rf .dev/home`.
- **Echte Apple-Daten:** Tools wie calctl/notectl/taskctl/mailctl sprechen per
  AppleScript mit den *echten* Apps (Kalender, Notizen, Erinnerungen, Mail) — die Sandbox
  schützt nur die tooleigenen Datenbanken und Configs, nicht diese Apps. `sync`/`add`/
  `delete` also mit Bedacht.
- MCP testen ohne Registrierung: `.dev/bin/budgetctl mcp` redet über stdio; zum Anschließen
  an Claude Code einen *temporären* Eintrag in einer Projekt-`.mcp.json` mit dem
  absoluten Pfad `…/.dev/bin/<tool>` setzen statt `~/.claude.json` anzufassen.

## 3. Danach installieren (wenn alles passt)

`./setup.sh` aus einer normalen Shell (nicht der Sandbox-Shell!).

## 4. Core-Änderungen veröffentlichen

1. `missionctl-core` pushen (manuell, bewusst).
2. `scripts/bump-core.sh` — pinnt jedes Tool auf Core-`main`, tidy, build+test, committet pro
   Tool (kein Push).
3. `./sync.sh` bzw. Pointer im Root committen, danach pushen.
