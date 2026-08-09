# TODO: `missionctl license activate` überschreibt postctl-Key mit Bundle-Fehlschlag

Aufgetreten: 2026-08-09, beim Aktivieren des Bundle-Keys
`A83-MIS-60908355-F09B-4370-8DB6-982097D28878` auf einem frisch
aufgesetzten MacBook.

## Was passiert ist

`missionctl license activate <bundle-key>` läuft den Key gegen **alle**
installierten Tools inkl. postctl. postctl ist nie Teil des missionctl
Bundles gewesen (eigenes Produkt, eigene Lizenzierung) — die Aktivierung
schlug dort erwartungsgemäß mit `403 NotPermitted` fehl.

Der Fehlerpfad hat den Fehlschlag aber trotzdem als
`license_status: invalid` in `~/.config/postctl/config.yaml` gespeichert
und dabei den echten, gültigen `license_key: PCTL-DEV-FAMILY-2026`
(Status `active`) überschrieben. postctl zeigte danach
"INVALID / EXPIRED" statt "PRO DEVELOPMENT/FAMILY BYPASS".

Wiederhergestellt aus dem age-verschlüsselten Dropbox-Backup
(`postctl-lock`/`postctl-unlock`, Stand 3. Aug.) — nur die zwei
license_*-Felder in config.yaml gepatcht, `postctl.db` unangetastet.

## Root cause

- Aktivierungs-Loop: `missionctl/cmd/license.go` (`licenseActivateCmd`),
  ruft pro Tool dessen eigenes `<tool> license activate <key>` auf —
  postctl wird dabei nicht ausgenommen, obwohl es (anders als die 6
  Bundle-Tools) kein Bundle-Produkt ist.
- Overwrite-on-failure: jedes Tool-eigene `cmd/license.go`
  (z.B. `habctl/cmd/license.go:44`, analog in budgetctl/notectl/mailctl/
  calctl/**postctl**) ruft bei nicht-transientem Fehlschlag
  unbedingt `config.SetLicense(key, "invalid", "")` — überschreibt damit
  jeden vorher gespeicherten, ggf. gültigen, andersartigen Key.

## Vereinbarter Fix (nächste Session)

postctl aus dem Bundle-Aktivierungs-Loop in `missionctl/cmd/license.go`
ausschließen (sowohl `license activate` als auch `license status` sollten
es dort separat behandeln, wie schon in der Statusausgabe informell der
Fall). Nicht angefasst: der generische Overwrite-on-failure-Bug in
`missionctl-core` bzw. den einzelnen `cmd/license.go`-Dateien — falls der
auch gefixt werden soll, extra draufschauen.
