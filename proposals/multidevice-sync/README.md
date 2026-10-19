# Multi-Device-Sync über einen Cloud-Ordner (Outline + Roadmap)

Status: **Entwurf, nicht begonnen** (2026-10-19). Auslöser: Lizenzen gelten für 5 Geräte; Konfliktkopien der geteilten SQLite-Dateien (`... in Konflikt stehende Kopie ...db`) in Dropbox zeigen, dass „eine DB-Datei im Cloud-Ordner“ nicht nahtlos funktioniert. Siehe auch `SYNC.md` (heutiger Stand) und `missionctl-core/syncdir`.

## Leitplanken (nicht verhandelbar)
- **Nur der Cloud-Ordner des Nutzers** (iCloud Drive, Dropbox, OneDrive, Syncthing, NAS …). Kein Server, **kein SaaS, kein Konto, kein Relay — auch nicht später und nicht optional.**
- Die Tools müssen mit **jedem** Ordner-Sync-Client laufen; wir verlassen uns nur auf „Dateien erscheinen irgendwann auf den anderen Geräten, vollständig oder gar nicht“-Semantik, nicht auf Zeitpunkt, Reihenfolge oder Atomarität über mehrere Dateien.
- Offline-first: jedes Gerät arbeitet ohne Netz, Abgleich geschieht nachträglich.
- Kein Datenverlust, auch nicht bei falsch gehenden Uhren oder gleichzeitigen Änderungen — im Zweifel Änderung **behalten** und den Nutzer informieren, nie still verwerfen.
- Bestehende Nutzer-DBs werden migriert, nie ohne Backup.

## Nutzungsprofil (Entscheidung 2026-10-19)
- „5 Geräte“ im Lizenztext = **Aktivierungen** (Polar), **keine** Sync-Zusage. Der Sync wird nicht für fünf gleichzeitige Schreiber verkauft.
- Typischer Alltag: **zwei Geräte, zeitversetzt.** Zu Hause läuft ein Rechner weiter (TUI, Dashboard, Scheduler), unterwegs wird am Laptop etwas geändert; die Änderung muss zu Hause **von selbst** ankommen. Echt gleichzeitiges Schreiben ist der seltene Randfall: korrekt gelöst (Merge + Konfliktprotokoll), aber nicht das Optimierungsziel. Auslegen auf 2 Geräte, testen bis 5.
- **Live-Übernahme:** ein laufendes Tool beobachtet fremde Protokolle (Dateiwächter, Polling als Rückfall) und übernimmt neue Zeilen binnen Sekunden; die TUI aktualisiert sich ohne Neustart.
- **postctl-Scheduler:** liest unmittelbar vor jedem Veröffentlichen die fremden Protokolle neu. Da Dateien verspätet ankommen können, gilt eine Karenz: ist ein anderes Gerät kürzlich aktiv gewesen, wird frühestens 1–2 Minuten nach Fälligkeit veröffentlicht (Wert konfigurierbar). Wer unterwegs einen Post löscht oder verschiebt, soll nicht vom Home-Rechner überholt werden.

## Warum die jetzige Lösung nicht reicht
Heute zeigen die Tools per `data_dir` auf **eine** gemeinsame `.db` im Cloud-Ordner. Der Sync-Client kann zwei gleichzeitig geänderte Fassungen nicht mergen und legt Konfliktkopien an; die Datei-Sperre in `syncdir` gilt nur auf einem Rechner. Journal-Wechsel auf DELETE und iCloud-Platzhalter-Erkennung bleiben sinnvoll, lösen aber nicht den Mehrgeräte-Fall.

## Prinzip: pro Gerät ein eigenes Änderungsprotokoll
```
<Sync-Ordner>/<tool>/
  device-<id>.log      ← nur dieses Gerät schreibt (append-only, JSON Lines)
  device-<id2>.log     ← Gerät 2 …
  snapshot-<ts>.db.gz  ← optional, siehe Phase 4
  meta.json            ← Format-Version, Geräteliste (jede Fassung nur vom Gerät selbst geschrieben, siehe unten)
```
- **Jede Datei hat genau einen Schreiber** → der Sync-Client kann keine Konflikte erzeugen. Das ist der Kern der Lösung.
- Lokal hat jedes Gerät seine eigene SQLite (Standard-Datenordner, WAL ok), die **nicht** synchronisiert wird. Sie ist Cache + Arbeitskopie; der Zustand ergibt sich aus allen Protokollen.
- Schreibt der Nutzer, wird die Änderung lokal übernommen **und** als Zeile an das eigene Protokoll angehängt. Beim Start und im Hintergrund (Dateiwächter oder Polling) liest das Gerät fremde Protokolle ab dem letzten bekannten Offset und spielt sie ein.
- Eine Änderung: `{id, device, hlc, table, row_id, op: upsert|delete, fields…}`.
- **Merge pro Feld bzw. Zeile, „letzte Änderung gewinnt“** anhand einer **hybriden logischen Uhr (HLC)**: Zeitstempel + Zähler + Geräte-ID als Tiebreaker. Falsch gehende Uhren können die Reihenfolge nicht umdrehen; gleichzeitige Änderungen am selben Feld sind deterministisch aufgelöst (auf allen Geräten gleich).
- **Löschungen = Löschmarker (Tombstones)**; sie werden erst nach Kompaktierung (Phase 4) entfernt.
- **Teilweise geschriebene Zeilen** (Sync-Client hat eine Datei halb geliefert): jede Zeile trägt Länge/Prüfsumme; unvollständige Schwanzzeile wird ignoriert und beim nächsten Lauf neu gelesen.

## Was sich dafür in den Tools ändern muss
- **Globale IDs.** `habctl` und `timectl` (u. a.) nutzen `INTEGER AUTOINCREMENT`; zwei Geräte würden dieselben IDs vergeben. Nötig: pro Zeile eine UUID/ULID als stabile Identität (die Integer-ID bleibt lokal für die Anzeige). `budgetctl`, `taskctl` haben schon `TEXT`-IDs.
- **Gerätelokale Zustände** gehören nicht ins Protokoll: Lock-Dateien, UI-Zustand, Lizenz-Cache, API-Tokens, `last_synced`.
- **Abgeleitete Daten** (Streaks, Summen, Statistiken) werden nach dem Einspielen neu berechnet, nicht synchronisiert.
- **Tools mit Fremdquelle sind ausgenommen** (`mailctl`, `calctl`, `notectl`): Das sind Caches von Mail.app / Apple Calendar / Apple Notes und bauen sich pro Gerät selbst neu auf. Sie liegen lokal, nicht im Cloud-Ordner; das beendet auch deren Konfliktkopien. Notectl-Eigenes (Vault-Dateien, Mirror-Links) bleibt gerätelokal bzw. liegt ohnehin als Dateien im Vault.
- **Sonderfälle:** `postctl` (geplante Posts dürfen **nie doppelt** veröffentlicht werden → ein „Veröffentlichen“-Anspruch pro Post über `claimed_by` + HLC; Scheduler nur auf einem Gerät aktiv oder Anspruch gewinnt deterministisch), `taskctl` (Spiegel zu Apple Reminders, Dubletten-Gefahr), `budgetctl` (Import desselben CSV auf zwei Geräten darf keine Dubletten erzeugen — vorhandene Dubletten-Prüfung wiederverwenden), `healthctl` (Dosen „genommen“ nicht doppelt zählen).

## Betrieb / Nutzersicht
- Geräte-ID wird beim ersten Start erzeugt (`~/.config/missionctl/device`). Neues Gerät: Ordner wählen → Tool baut Zustand aus Protokollen (und ggf. Snapshot) auf.
- `doctor` zeigt: Geräte, letzter Abgleich je Gerät, ausstehende Zeilen, Alter des ältesten fremden Protokolls, unvollständige Dateien, „Gerät X hat seit N Tagen nichts geschrieben“.
- **Kein stilles Verwerfen:** Kollidierende gleichzeitige Änderungen am selben Feld → Gewinner nach HLC, Verlierer in einem Konfliktprotokoll (`conflicts.log`, lokal) sichtbar in `doctor`/TUI mit „wiederherstellen“.
- Backup-/Export-Befehle bleiben; `export` liest aus dem lokalen Zustand.

## Roadmap
**Phase 0 – Entscheidungen und Sofortmaßnahmen (klein)**
- Entscheiden: Protokollformat (JSONL vs. SQLite-Changeset je Gerät), HLC-Details, Zeilen- vs. Feld-Merge je Tabelle.
- `mailctl`/`calctl`/`notectl` aus dem geteilten Ordner nehmen (Cache lokal, kein `data_dir` nötig); `doctor`-Warnung zu Konfliktkopien vorerst beibehalten. `SYNC.md`/Landing: „nahtlos auf 5 Geräten“ **erst bewerben, wenn Phase 3 steht**; bis dahin ehrlich „ein Gerät schreibt gleichzeitig“.

**Phase 1 – Kern in `missionctl-core/syncdir` (ohne Tool-Anbindung)**
- Geräte-ID, HLC, Protokoll-Schreiber/-Leser (Prüfsumme, Offsets, Teilzeilen), Einspiel-Schleife, Tombstones.
- **Simulationstests mit N virtuellen Geräten** auf einem Wegwerf-Ordner: zufällige Änderungen, Umordnung, Verzögerung, doppelte und abgeschnittene Dateien, Uhrenabweichung ±Stunden, Konvergenz-Beweis (alle Geräte haben am Ende denselben Zustand). Property-/Fuzz-Test. Wegwerf-`HOME` und eigene Go-Caches (Regel aus Memory).

**Phase 2 – Pilot an einem unkritischen Tool: `habctl` oder `timectl`**
- Globale IDs + Migration der bestehenden DB (Backup vorher), Anbindung an den Store, `doctor`-Anzeige, Konfliktprotokoll.
- Echtlauf mit zwei Rechnern und echtem Dropbox **und** iCloud eine Woche lang (Checkliste in `TESTING.md`).

**Phase 3 – Übrige Eigendaten-Tools**
- Reihenfolge: `diaryctl`, `budgetctl`, `investctl`, `healthctl`, `taskctl`, zuletzt `postctl` (Doppelveröffentlichungsschutz zuerst).
- Je Tool: Migration, Dubletten-Regeln, Tests, Doku. Danach `missionctl`-Dashboard: Sync-Zustand je Tool statt Konfliktwarnung.
- **Erst hier** Marketing-Aussage „bis zu 5 Geräte, ein Ordner Ihrer Wahl“.

**Phase 4 – Kompaktierung und neue Geräte**
- Snapshots (`snapshot-<ts>.db.gz`) + Abschneiden alter Protokolle, Tombstone-Bereinigung erst wenn alle bekannten Geräte den Stand haben (Gerät gilt nach z. B. 90 Tagen ohne Meldung als „abgemeldet“).
- „Gerät entfernen“ im `doctor`/Settings (Lizenz-Slots getrennt davon: Aktivierungen laufen über Polar, nicht über den Sync).

**Phase 5 – Härtung**
- Verschlüsselung der Protokolle im Cloud-Ordner (optional, Schlüssel nur lokal/vom Nutzer; Verlust = Daten weg, klar dokumentieren). Das ergänzt nur; es ist kein Dienst.
- Sync-Client-Eigenheiten testen: iCloud „Speicher optimieren“ (Platzhalter), Dropbox „Smart Sync“, OneDrive Files-on-Demand, Syncthing-Versionierung.
- Rückfall-Tool `missionctl sync repair` (Zustand aus allen Protokollen neu aufbauen, Konfliktkopien alter Versionen einlesen und ablegen).

## Offene Fragen
- Feldweise oder zeilenweise mergen (Text-Notizen in `diaryctl` brauchen evtl. echtes Text-Merge oder zumindest „beide behalten“)?
- ~~Was heißt „5 Geräte“?~~ Geklärt 2026-10-19: nur Aktivierungen. Offen: Lizenztext/Landing so formulieren, dass daraus keine Sync-Zusage für fünf gleichzeitige Geräte wird.
- Wie lang darf die Karenz des postctl-Schedulers sein, ohne dass sich pünktliches Posten falsch anfühlt?
- Wie viele parallele Schreiber pro Tool sind realistisch (Tests auf 5 auslegen)?
- Migration von Nutzern, die heute schon `data_dir` auf eine gemeinsame DB gesetzt haben: automatisch beim ersten Start, mit Backup, oder ausdrücklicher Befehl?
