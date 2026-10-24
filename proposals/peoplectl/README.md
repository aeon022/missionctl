# peoplectl — Kontakte (Entwurf, 2026-10-24)

Name: `contactctl` ist auf npm vergeben und hat ein GitHub-Repo → **`peoplectl`** (frei auf GitHub, npm, Homebrew; geprüft 2026-10-24).

Die „Person“-Ebene der Suite: Apple Kontakte lesen und mit Mails, Terminen und Notizen verbinden — „mit wem war ich lange nicht in Kontakt?“

## Entscheidungen
| Frage | Entscheidung |
|---|---|
| Quelle | Apple Kontakte per AppleScript/`osascript` (wie mailctl/calctl), **nur lesend** in v1; eigene Daten (Rhythmus, letzter Kontakt, Notiz) in lokaler SQLite |
| Kontaktrhythmus | pro Person optional „alle N Tage“; `peoplectl due` listet Überfällige |
| Letzter Kontakt | aus mailctl (`search_email` nach Adresse) und calctl (Termine mit Teilnehmer) abgeleitet, manuell ergänzbar (`peoplectl touch NAME`) |
| Privatsphäre | Kontaktdaten nie im Activity-Log; kein Netzwerk; Notizen 0600 |
| Dashboard | Karte „People“: „3 überfällig“, nie Namen auf dem Schirm (wie healthctl) |

## v1
`list`, `show`, `touch`, `cadence`, `due`, `doctor`, MCP (`find_person`, `due_contacts`, `touch_contact`), TUI. Phase 2: Verknüpfung in notectl (Personen-Notiz) und mailctl (Absender → Person).
## Offen
AppleScript-Zugriff auf Kontakte braucht eine einmalige Systemfreigabe; Performance bei großen Adressbüchern prüfen (Cache wie mailctl).
