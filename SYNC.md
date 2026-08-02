# Geräte-Sync — Kurzanleitung

Wie du die Daten eines missionctl-Tools zwischen zwei Rechnern (z.B. MacBook ↔ hier) synchronisierst — über einen Ordner, den du selbst schon syncst (iCloud Drive, Dropbox). Kein eigener Cloud-Dienst, keine Abos — das Tool zeigt einfach auf einen Ordner, den iCloud/Dropbox sowieso schon spiegelt.

---

## Das Prinzip (einmal verstehen, gilt für alle 9 Tools)

Jedes Tool speichert seine Daten normalerweise lokal in einer SQLite-Datei (`~/.local/share/<tool>/...` oder `~/.config/<tool>/...` je nach Tool). Trägst du `data_dir` (Config-Datei) oder `<TOOL>_DATA_DIR` (Env-Var) ein, zeigt das Tool stattdessen auf einen Ordner deiner Wahl — z.B. innerhalb von iCloud Drive oder Dropbox.

Dabei automatisch mit abgesichert:
- **Journal-Modus wechselt automatisch** von WAL auf Rollback-Journal, sobald ein `data_dir` gesetzt ist — WAL verteilt die echten Daten auf mehrere Dateien (`.db`, `.db-wal`, `.db-shm`), die ein Sync-Client nicht atomar zusammen hochladen kann. Rollback-Journal bleibt praktisch immer eine einzige Datei.
- **Lock-Datei** verhindert, dass zwei Prozesse auf demselben Rechner gleichzeitig schreiben.
- **iCloud-Platzhalter-Erkennung**: Wenn eine Datei noch nicht heruntergeladen ist ("Optimize Mac Storage"), bekommst du eine klare Fehlermeldung statt eines stillen leeren Zustands.

**Was das NICHT abdeckt:** Zwei Rechner, die im selben Sekundenbruchteil gleichzeitig schreiben. Das brauchst du bei privater Nutzung praktisch nie, aber es ist kein Wunder-Mergen — es ist "sicher machen, was iCloud/Dropbox sowieso schon tun".

---

## Einmalig pro Rechner: Voraussetzung

Auf **jedem** Rechner (MacBook + hier) muss das Binary die Sync-Funktion schon kennen:

```bash
cd ~/Developing/Projects/missionctl   # oder wo auch immer das Repo liegt
git pull
./setup.sh
```

Falls `./setup.sh` schon vor der Sync-Funktion gelaufen ist, einfach nochmal ausführen — baut alle Binaries neu.

---

## Schritt 1: Sync-Ordner wählen

Einen Ordner aussuchen, den beide Rechner über denselben Cloud-Dienst sehen. Empfehlung: ein Unterordner pro Tool, damit nichts vermischt wird.

### iCloud Drive
- Voraussetzung: iCloud Drive ist aktiv (Systemeinstellungen → Apple-ID → iCloud → iCloud Drive)
- Pfad ist auf **beiden Macs automatisch identisch**:
  ```
  ~/Library/Mobile Documents/com~apple~CloudDocs/<tool>
  ```
- Ordner muss nicht manuell angelegt werden — das Tool macht das selbst beim ersten Schreiben.

### Dropbox
- Dropbox-App installiert und eingeloggt, synct bereits
- Pfad ist ebenfalls auf beiden Rechnern gleich (Standard-Installation):
  ```
  ~/Dropbox/<tool>
  ```
- Falls du einen eigenen Dropbox-Installationsort gewählt hast: auf beiden Rechnern denselben Pfad verwenden.

---

## Schritt 2: Tool auf den Ordner zeigen lassen

### budgetctl — am einfachsten über die TUI
In der TUI: `o` (Settings) → `b` (Ordner durchsuchen) → mit Pfeiltasten/Enter zum Zielordner navigieren (auch **Drag & Drop eines Finder-Ordners aufs Terminalfenster** funktioniert hier) → `s` (diesen Ordner syncen) → `y` bestätigen.
→ Bestehende lokale Daten werden automatisch dorthin verschoben.

Alternativ Env-Var oder Config:
```bash
export BUDGETCTL_DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/budgetctl"
```

### Alle anderen Tools — Env-Var oder Config-Datei

| Tool | Env-Var | Config-Datei + Key |
|---|---|---|
| calctl | `CALCTL_DATA_DIR` | `~/Library/Application Support/calctl/config.yaml` → `data_dir:` |
| taskctl | `TASKCTL_DATA_DIR` | `~/.config/taskctl/config.yaml` → `data_dir:` |
| notectl | `NOTECTL_DATA_DIR` | `~/.config/notectl/notectl.yaml` → `data_dir:` |
| mailctl | `MAILCTL_DATA_DIR` | `~/.config/mailctl/config.yaml` → `data_dir:` |
| habctl | `HABCTL_DATA_DIR` | *(nur Env-Var, kein Config-File dafür)* |
| timectl | `TIMECTL_DATA_DIR` | *(nur Env-Var)* |
| diaryctl | `DIARYCTL_DATA_DIR` | *(nur Env-Var)* |
| postctl | *(kein Env-Var)* | `~/.config/postctl/config.yaml` → `data_dir:` (bzw. `~/.config/postctl/profiles/<name>/config.yaml`, falls Profile genutzt werden) |

**Env-Var dauerhaft machen:** in `~/.zshrc` eintragen, sonst gilt es nur für die aktuelle Terminal-Session:
```bash
echo 'export CALCTL_DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/calctl"' >> ~/.zshrc
source ~/.zshrc
```

**Config-Datei-Variante** (Beispiel notectl):
```yaml
data_dir: "~/Library/Mobile Documents/com~apple~CloudDocs/notectl"
```

**Wichtig:** Auf beiden Rechnern denselben Ordner eintragen — sonst syncen sie an zwei verschiedenen Stellen vorbei.

---

## Schritt 3: Prüfen, ob's funktioniert hat

```bash
<tool> doctor
```

Erwartete Ausgabe u.a.:
```
✓ Data directory   /Users/.../calctl (shared)
```
`shared` = Sync ist aktiv und der Pfad stimmt. `local` = noch nicht konfiguriert.

Danach kurz im Finder nachsehen: die Datei sollte das Sync-Symbol zeigen (Wolke bei iCloud, Häkchen bei Dropbox).

---

## Mehrere Accounts/Profile (aktuell nur postctl)

Falls du z.B. Privat/Arbeit getrennt halten willst:
```bash
postctl --profile work config set twitter.client_id "..."
postctl --profile work tui

postctl profile list       # zeigt alle Profile, aktives markiert
```
Jedes Profil hat eigene Config **und** eigene Datenbank — kann also auch unabhängig auf einen eigenen Sync-Ordner zeigen (z.B. Arbeit → Firmen-Dropbox, Privat → eigenes iCloud).

---

## Kurz-Checkliste zum Abhaken

- [ ] `./setup.sh` auf beiden Rechnern aktuell
- [ ] Gleicher Sync-Ordner-Pfad auf beiden Rechnern eingetragen
- [ ] `<tool> doctor` zeigt `shared` + korrekten Pfad
- [ ] Datei im Finder zeigt Sync-Symbol
