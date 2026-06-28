# Git & Deploy — missionctl

Referenz für die Git-Struktur, täglichen Workflow und Deployment aller Tools.

---

## Struktur

```
missionctl/          → github.com/aeon022/missionctl  (Bundle-Docs)
├── calctl/          → github.com/aeon022/calctl       (Submodule)
├── mailctl/         → github.com/aeon022/mailctl      (Submodule)
├── budgetctl/       → github.com/aeon022/budgetctl    (Submodule)
├── notectl/         → github.com/aeon022/notectl      (Submodule)
└── taskctl/         → github.com/aeon022/taskctl      (Submodule)
```

Jedes Tool ist ein **eigenständiges Git-Repo**, das im missionctl-Repo als **Submodule** verlinkt ist.
postctl lebt separat: `github.com/aeon022/postctl`

---

## Täglicher Workflow — an einem Tool arbeiten

### 1. Im Tool-Ordner arbeiten und pushen

```bash
cd ~/Developing/Projects/missionctl/calctl

# Code ändern...

git add .
git commit -m "feat: beschreibung"
git push
```

Das reicht für die meisten Arbeitstage. missionctl zeigt dann automatisch auf den neuen Commit.

### 2. missionctl aktualisieren (Submodule-Pointer updaten)

Das missionctl-Repo speichert nur einen **Zeiger** auf den jeweiligen Commit des Tool-Repos.
Nach einem Push im Tool musst du den Pointer im Bundle-Repo manuell updaten:

```bash
cd ~/Developing/Projects/missionctl

# missionctl weiß jetzt dass calctl einen neuen Commit hat
git add calctl
git commit -m "chore: update calctl submodule"
git push
```

Wann nötig: bei Releases, Milestones, oder wenn missionctl.README auf neue Features zeigen soll.
Im Alltag kannst du das weglassen — der Code im Tool-Repo ist immer aktuell.

---

## Erstes Setup auf einem neuen Mac

```bash
# missionctl klonen + alle Submodules auf einmal holen
git clone --recurse-submodules https://github.com/aeon022/missionctl.git

cd missionctl/calctl
chmod +x setup.sh
./setup.sh
```

Oder nachträglich wenn man vergessen hat `--recurse-submodules`:

```bash
git clone https://github.com/aeon022/missionctl.git
cd missionctl
git submodule update --init --recursive
```

---

## Einzelnes Tool klonen (ohne Bundle)

```bash
git clone https://github.com/aeon022/calctl.git
cd calctl
chmod +x setup.sh
./setup.sh
```

---

## Neues Tool hinzufügen

Wenn ein neues Tool (z.B. `feedctl`) fertig ist:

```bash
# 1. GitHub Repo erstellen
gh repo create aeon022/feedctl --public --description "..."

# 2. Im Tool-Ordner init + push
cd ~/Developing/Projects/missionctl/feedctl
git init
git add .
git commit -m "feat: initial feedctl"
git remote add origin https://github.com/aeon022/feedctl.git
git push -u origin main

# 3. Als Submodule in missionctl eintragen
cd ~/Developing/Projects/missionctl
git submodule add https://github.com/aeon022/feedctl.git feedctl
git add .gitmodules feedctl
git commit -m "chore: add feedctl as submodule"
git push
```

---

## Releases & Versionierung

### Tag setzen (im Tool-Repo)

```bash
cd ~/Developing/Projects/missionctl/calctl

git tag -a v0.1.0 -m "calctl v0.1 — Apple Calendar sync, list, free, import, TUI"
git push origin v0.1.0
```

### GitHub Release mit Binary erstellen

```bash
# Binary für macOS arm64 bauen
GOOS=darwin GOARCH=arm64 go build -ldflags="-X main.Version=v0.1.0" -o calctl-macos-arm64 .

# Binary für macOS Intel
GOOS=darwin GOARCH=amd64 go build -ldflags="-X main.Version=v0.1.0" -o calctl-macos-amd64 .

# GitHub Release mit beiden Binaries erstellen
gh release create v0.1.0 calctl-macos-arm64 calctl-macos-amd64 \
  --title "calctl v0.1.0" \
  --notes "Initial release — Apple Calendar sync, list, free slots, import from Markdown, TUI."
```

Dann das Binary auf polar.sh als Download-Asset verlinken.

---

## Submodules im Alltag

### Status aller Submodules checken

```bash
cd ~/Developing/Projects/missionctl
git submodule status
```

Ausgabe: `+` = Submodule ist ahead (neuer Commit im Tool, noch nicht in missionctl eingecheckt)

### Alle Submodules auf den neuesten Stand bringen (pull)

```bash
git submodule update --remote --merge
```

### Submodule entfernen (falls nötig)

```bash
git submodule deinit feedctl
git rm feedctl
rm -rf .git/modules/feedctl
git commit -m "chore: remove feedctl submodule"
```

---

## Repos auf einen Blick

| Tool | Repo | Go Module |
|------|------|-----------|
| Bundle/Docs | github.com/aeon022/missionctl | — |
| calctl | github.com/aeon022/calctl | `github.com/aeon022/calctl` |
| mailctl | github.com/aeon022/mailctl | `github.com/aeon022/mailctl` |
| budgetctl | github.com/aeon022/budgetctl | `github.com/aeon022/budgetctl` |
| notectl | github.com/aeon022/notectl | `github.com/aeon022/notectl` |
| taskctl | github.com/aeon022/taskctl | `github.com/aeon022/taskctl` |
| postctl | github.com/aeon022/postctl | `github.com/aeon022/postctl` |

---

## Commit-Konventionen

```
feat:   neues Feature
fix:    Bug-Fix
chore:  Build, Dependencies, Submodule-Updates
docs:   README, Anleitungen
refactor: Umbau ohne Funktionsänderung
```

Beispiele:
```bash
git commit -m "feat: add calctl mcp server"
git commit -m "fix: applescript locale date parsing on german macos"
git commit -m "chore: update calctl submodule to v0.2.0"
git commit -m "docs: add polar.sh setup guide"
```

---

## Schnellreferenz — die häufigsten Befehle

```bash
# An calctl arbeiten
cd ~/Developing/Projects/missionctl/calctl
git add . && git commit -m "feat: ..." && git push

# An postctl arbeiten
cd ~/Developing/Projects/postctl
git add . && git commit -m "feat: ..." && git push

# missionctl Bundle-Docs updaten
cd ~/Developing/Projects/missionctl
git add . && git commit -m "docs: ..." && git push

# Release bauen und pushen
git tag -a v0.1.0 -m "..." && git push origin v0.1.0
gh release create v0.1.0 binary-arm64 binary-amd64 --title "..." --notes "..."

# Auf neuem Mac alles klonen
git clone --recurse-submodules https://github.com/aeon022/missionctl.git
```
