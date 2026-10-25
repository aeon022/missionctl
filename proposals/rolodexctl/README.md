# rolodexctl — Kontakte (**v0.1 gebaut 2026-10-25**)

> **Status 2026-10-25: gebaut** (privates Repo aeon022/rolodexctl, Submodul): sync, list, show, touch, rhythm, note, due, scan (mailctl), doctor, MCP (find_person, due_contacts, touch_contact), Man-Pages, Dashboard-Karte. Der Apple-Contacts-Zugriff ist nur gegen Beispieldaten getestet; offen: echter Lauf, TUI, Termine aus calctl, Link zu notectl.
>
> *(Ursprünglicher Stand:)* **zurückgestellt.** Entscheidung 2026-10-24: Arbeitstitel `rolodexctl` (früher `rolodexctl`), wird nicht gebaut, bevor `missionctl review` und `invoicectl` stehen. Gründe: Kernfunktion („melde dich mal wieder“) lässt sich mit Erinnerungen/taskctl grob abdecken; Nutzen hängt an der Verknüpfung mit Mail/Kalender; AppleScript-Freigabe und Performance bei großen Adressbüchern; sensible Daten. Alternativnamen: `circlectl`, `kontaktctl`. Name vor dem Bau erneut prüfen.

Name: `contactctl` ist auf npm vergeben und hat ein GitHub-Repo; `rolodexctl` war frei, klang aber nicht nach der Suite → Arbeitstitel **`rolodexctl`** (Karteikartenbox).

Die „Person“-Ebene der Suite: Apple Kontakte lesen und mit Mails, Terminen und Notizen verbinden — „mit wem war ich lange nicht in Kontakt?“

## Entscheidungen
| Frage | Entscheidung |
|---|---|
| Quelle | Apple Kontakte per AppleScript/`osascript` (wie mailctl/calctl), **nur lesend** in v1; eigene Daten (Rhythmus, letzter Kontakt, Notiz) in lokaler SQLite |
| Kontaktrhythmus | pro Person optional „alle N Tage“; `rolodexctl due` listet Überfällige |
| Letzter Kontakt | aus mailctl (`search_email` nach Adresse) und calctl (Termine mit Teilnehmer) abgeleitet, manuell ergänzbar (`rolodexctl touch NAME`) |
| Privatsphäre | Kontaktdaten nie im Activity-Log; kein Netzwerk; Notizen 0600 |
| Dashboard | Karte „People“: „3 überfällig“, nie Namen auf dem Schirm (wie healthctl) |

## v1
`list`, `show`, `touch`, `cadence`, `due`, `doctor`, MCP (`find_person`, `due_contacts`, `touch_contact`), TUI. Phase 2: Verknüpfung in notectl (Personen-Notiz) und mailctl (Absender → Person).
## Offen
AppleScript-Zugriff auf Kontakte braucht eine einmalige Systemfreigabe; Performance bei großen Adressbüchern prüfen (Cache wie mailctl).
