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

```sh
scripts/dev-build.sh && scripts/first-run.sh   # jedes Tool in einem brandneuen HOME
```

`first-run.sh` fängt „funktioniert nur auf meinem Rechner“-Fehler (z. B. fehlendes Datenverzeichnis).

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

## 5. Sichtprüfung im Terminal (das, was kein Test kann)

Alles hier ist headless nicht prüfbar. Dauer: ca. 30 Minuten. Am besten erst in der Sandbox
(`scripts/dev-build.sh && source scripts/dev-env.sh`, dann ein paar Testdaten anlegen), die
riskanten Punkte danach einmal mit den echten Daten.

**Vorher:** `./setup.sh` aus einer normalen Shell installiert alles neu nach `~/.local/bin` (baut aus
dem Checkout). In der Sandbox reicht `scripts/dev-build.sh`.

| # | Was | Wie prüfen | Erwartung |
|---|---|---|---|
| 1 | **Alle 9 TUIs starten** | `taskctl`, `calctl`, `mailctl`, `notectl`, `budgetctl`, `habctl`, `timectl`, `diaryctl`, `postctl` | Kein Flackern, keine doppelten Zeilen, Farben lesbar |
| 2 | **Fenstergröße** | Fenster auf ~60 Spalten ziehen, dann sehr breit | Fußzeile bleibt **eine** Zeile (letzte Hinweise fallen weg), nichts läuft über |
| 3 | **Hell/Dunkel** | Terminal-Profil umschalten, TUI neu starten | Text/Rahmen in beiden gut lesbar |
| 4 | **Leertaste** | In taskctl/habctl/mailctl/budgetctl auswählen | Auswahl/Check-in reagiert (nicht ignoriert) |
| 5 | **Eingabefelder** | `/` (Suche), `:` (Palette), Neu-Formulare | Placeholder voll sichtbar (nicht nur 1 Zeichen) |
| 6 | **Hilfe-Popup** | `?` | Hintergrund abgedunkelt, Popup scharf; beliebige Taste schließt |
| 7 | **Leere Listen** | Sandbox ohne Daten | Zentrierter Text + Hinweis, was zu drücken ist |
| 8 | **Maus** | Klick auf Zeile, Doppelklick, Hover, Mausrad (Liste und Detail), Tabs in mailctl/notectl | Auswahl, Öffnen, Hover-Hervorhebung, Scrollen |
| 9 | **Fokus-Reload** | In Tool A etwas anzeigen, in Tool B etwas ändern, ≥ 6 s warten, zurückwechseln | Liste in A aktualisiert sich selbst. **Nicht**, während man in einem Formular/Editor tippt |
| 10 | **Clipboard (OSC 52)** | `y` (Kopieren), in anderer App einfügen. Zusätzlich über `ssh` oder in tmux | Lokal klappt immer (`pbcopy`); über SSH/tmux nur, wenn das Terminal OSC 52 erlaubt (iTerm2: Einstellung „Applications in terminal may access clipboard“) |
| 11 | **Dashboard** | `missionctl` | Startet ohne Einfrieren, Karten sagen kurz „loading…“; Klick wählt, Doppelklick öffnet, Hover = Doppelrahmen, `?` Hilfe, `d` Peek, `/` Suche, `x` Schnellaktion, `s` Sync, Sparklines bei Tasks/Timer, `[1]`-Etikett steht in der Titelzeile |
| 12 | **Dashboard-Konfig** | `~/.config/missionctl/dashboard.yaml` mit `cards: [tasks, habits]` | Nur diese Karten, Ziffern passen |
| 13 | **postctl-Boxen** | `postctl` durch alle Tabs | Boxen nicht 2 Zeichen zu breit/schmal (`+2`-Ausgleich) |
| 14 | **budgetctl-Dateiwähler** | Settings (`o`) → Datenordner wählen | Dateiwähler öffnet, navigierbar |
| 15 | **diaryctl Editor** | Eintrag bearbeiten, Vim-Modus (Esc/`i`/`h`/`l`), `ctrl+g` (KI) | Cursor/Vim wie erwartet; `a` tippt ein „a“ |
| 16 | **Activity im Tagebuch** | Etwas tun (Aufgabe abhaken …), `missionctl log`, dann `diaryctl activity` | Einträge sichtbar; Block „Activity“ im Tageseintrag. Nach 18 Uhr im `ask`-Modus fragt diaryctl beim Öffnen (y/n/a/x) |
| 17 | **mailctl Unsubscribe** | Newsletter öffnen → `U` | Popup nennt Absender + Methode; erst nach `enter`/`y` passiert etwas. **Apple Mail:** Header-Abruf ist ungetestet — prüfen, ob Header ankommen |
| 18 | **notify** | `missionctl notify --dry-run`; `missionctl notify --install` + `launchctl load …` | Banner erscheint einmal pro Ereignis |
| 19 | **plan / review** | `missionctl plan --show-prompt`, dann mit Key (`ANTHROPIC_API_KEY` o. Ä.) `missionctl plan` | Prompt enthält deine Daten; Antwort streamt |
| 20 | **Apple-Sync** | `calctl sync`, `taskctl sync`, `notectl sync`, `mailctl sync` | Läuft wie vorher (die AppleScript-Funktionen kommen jetzt aus Core) |

Findest du etwas Schiefes: Tool + Schritt + Terminal-Programm (Terminal.app/iTerm2/…) notieren.
