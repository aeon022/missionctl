# TODO — bis zum Launch am 1. November 2026

Plan und Begründungen: [`docs/LAUNCH-2026-11-01.md`](docs/LAUNCH-2026-11-01.md). **Nichts wird ohne Freigabe veröffentlicht, getaggt oder gepostet.**
`[C]` = Claude legt an/erledigt (ab 19.10.) · `[N]` = Nutzer (du) · `[N+C]` = gemeinsam

## Mo 19.10. – Sa 24.10.
- [x] `[C]` **Family-Rabatt** um postctl Pro Yearly/Monthly erweitert (2026-10-18). Der alte Code stand versehentlich im Chat und wurde **ersetzt**; der neue liegt nur in `~/.config/missionctl/family-code` (0600)
- [x] `[C]` `SUPPORT.md` in allen Repos + Support-Seiten (beide Sites live, 2026-10-19; hello@abteilung83.com, 3–5 Arbeitstage); Antwortzeit ehrlich — du nennst die Adresse und Zeit
- [~] `[C]` Demo-GIFs mit `vhs` (fertig: taskctl, habctl, budgetctl, timectl, diaryctl, notectl, postctl, Dashboard; offen: mailctl, calctl — brauchen Demo-Quelle ohne Echtdaten): postctl (Kalender, Planen, Profile), Dashboard (Themes), je Tool 10–15 s
- [x] `[C]` READMEs aller Repos (GIF, brew, Releases, Support; 2026-10-19): Screenshot/GIF oben, `brew install`, 3 Sätze Nutzen, Link zur Seite, Plattform-Hinweis (macOS/Linux)
- [x] `[N]` Entschieden 2026-10-18: Bundle **ohne** postctl Pro; Bundle-Schlüssel vor dem 18.10. bleiben gültig (Besitzstand); Polar-Beschreibung des Bundles entsprechend ergänzt
- [ ] `[N]` Rechtliche Prüfung beauftragen (Bedingungen + Datenschutz postctl.sh, Abo-Klauseln, Widerruf) — Frist 28.10.
- [ ] `[N]` Brücke fragen: darf sie als Beispiel genannt werden? (nur echte Zahlen)

- [ ] `[N]` **Raiffeisen-Import (investctl)**: echten ELBA-Depotexport (CSV) lokal ablegen, Pfad nennen; vorher Namen und Kontonummern unkenntlich machen. Gebraucht: Kopfzeile, je eine Zeile Kauf/Verkauf/Ertrag, Trennzeichen, Zahlen-/Datumsformat. Gleiches für weitere AT-Banken (Erste/George, Bank Austria, BAWAG, Dadat, flatex AT). `[C]` baut danach das Format
- [ ] `[N]` Bank-Import testen: eigenen Export (Trade Republic/Scalable/Trading 212/Degiro/Revolut/Portfolio Performance) mit `investctl import DATEI --dry-run --lookup` prüfen, Abweichungen melden
- [ ] `[N]` `healthctl remind` einmal live testen (echte Benachrichtigung); investctl-/healthctl-TUIs im echten Terminal ansehen (`TESTING.md` §5)
- [ ] `[N+C]` Entscheiden: `--lookup` als Standard? investctl/healthctl nach dem Launch veröffentlichen? (Empfehlung: erst ab Woche 3–4)

## Neue Tools & Funktionen (Stand 2026-10-24) — Reihenfolge nach Wichtigkeit
Entwürfe: `proposals/{receiptctl,rolodexctl,invoicectl,review,networth}/`. Namen geprüft (GitHub/npm/Homebrew): `receiptctl`, `invoicectl` frei; `contactctl` vergeben → Arbeitstitel `rolodexctl` (zurückgestellt).
- [x] `[C]` **Vermögen**: `budgetctl balance` (Anfangsbestand pro Konto, nie geraten) + Zeile „Wealth“ in `missionctl status` (Kasse + Depot, EUR; andere Währungen aufgelistet, nicht umgerechnet). Noch offen: Dashboard-Karte (Tastenbelegung 1–9/0/p ist voll), MCP-Tool `balances`
- [~] `[C]` **receiptctl** (Belegscanner, 0.1 Vorschau): CLI, Parser (AT/DE), OCR (macOS Vision), Abgleich mit budgetctl, Export, MCP — lokal committet in `receiptctl/`, Opus-Review (22 Funde, 20 behoben). **Wartet auf:** `[N]` Okay für privates GitHub-Repo `aeon022/receiptctl` + Submodul + `setup.sh`/README-Eintrag
  - Zurückgestellt aus dem Review: Löschen ohne Papierkorb (`files/.trash`); Prüf-/Nutzungs-Race beim MCP-`add_receipt` (Datei-Handle statt Pfad weiterreichen); TUI; GIF; Raiffeisen-Beispielbelege zum Testen des Parsers mit echten Rechnungen (`[N]`: 5–10 anonymisierte PDFs)
- [x] `[C]` **`missionctl review --plain`** (2026-10-24): lokaler Wochenrückblick ohne KI (`--json`, `--days`, `--money`); neu `habctl stats --json`, `healthctl adherence --json`. Offen: `--to-note`, MCP-Prompt `weekly_review`, Monat/Trends
- [~] `[N+C]` **invoicectl** — Phase 1 gebaut (privates Repo aeon022/invoicectl, Submodul): Store + Trigger + lückenlose Nummern + Regeln + Pure-Go-PDF + CLI + Tests; Entscheidungen 2026-10-24: Kleinunternehmer (privat), Brücke USt-befreit (`exempt`, Wortlaut der Steuerberatung), Format `2026-001`, PDF rein Go, Inland + Ausland (de/en). Opus-Review durch und eingearbeitet (u. a. `INSERT OR REPLACE` umging die Trigger → `recursive_triggers`). Offen: Steuerberatung liest `internal/rules/at.go`, Phase 2: `match` mit budgetctl und `line from-time`, MCP-Server (confirm-Pflicht) Dashboard-Karte und Doppelt-Abrechnen-Schutz gebaut (2026-10-24/25), (timectl), MCP, Dashboard-Karte, E-Rechnung
- [-] **rolodexctl** (Kontakte, früher peoplectl) — Arbeitstitel, **zurückgestellt** bis review + invoicectl stehen; Gründe in `proposals/rolodexctl/README.md`
- [x] `[C]` Umbenennung **belegctl → receiptctl** (2026-10-25): alle Namen der Suite englisch; Repo, Submodul, Docs, Review, MCP umgestellt
- [ ] `[C]` Ideen 2026-10-25 (alle aufgenommen, Reihenfolge = Abarbeitung):
  - [ ] Lizenzschlüssel nicht mehr als Argument an die Tools reichen (Standardeingabe)
  - [ ] receiptctl: Papierkorb statt Sofort-Löschen, `add_receipt` ohne Pfad-Race, Dashboard-Karte
  - [ ] budgetctl: MCP `balances` + Dashboard-Karte
  - [ ] `missionctl review`: Zeilen für invoicectl (überfällig, Entwürfe) und receiptctl (ungeprüft, ohne Buchung)
  - [ ] invoicectl: Mahnentwürfe (`remind`; nur Text/Entwurf, nie automatisch senden)
  - [ ] invoicectl: wiederkehrende Rechnungen (Vorlage → monatlich ein Entwurf, Ausstellen bleibt manuell)
  - [ ] Jahrespaket für die Steuerberatung (Einnahmen invoicectl + Ausgaben receiptctl/budgetctl in einem Export)
  - [ ] receiptctl ↔ invoicectl: Belege einem Projekt/einer Rechnung zuordnen und anzeigen
  - [ ] einheitliches `--json`-Rahmenformat, Man-Pages
  - [ ] später: rolodexctl (Kontakte) — invoicectl steht, review steht; E-Rechnung/Reverse Charge erst nach Steuerberatung
- [ ] `[N+C]` Subagents `pruefer`/`go-kleinkram` liegen in `.claude/agents/` (wirken ab dem nächsten Sitzungsstart)

## Erledigt am 23.10.2026
- healthctl/investctl: Demo-GIFs (`scripts/demo/*.tape`, erfundene Daten), `SUPPORT.md`, README-Links; Tests für investctl-Store (0 → 80 %) und healthctl-Slotlogik (`ResolveSlot`, `NextOpenSlot`, `UpdateMedication`). Lokal committet, **noch nicht gepusht**

## Erledigt am 19.10.2026 (Überblick)
- Support-Seiten + Cookie-Banner/-Seite (postctl.sh), Favicons/App-Icons, README mit GIF/brew in allen Repos, Launch-Entwürfe (`docs/launch/`), `scripts/metrics.sh`
- MCP-Zahl geprüft: **67 Tools** in 9 öffentlichen Apps (notectl hat 8)
- Lizenzen **nur über Polar**: feste Dev-/Familien-Schlüssel entfernt (alle Go- und JS-Tools); JS-Tools prüfen direkt gegen Polar
- investctl: Bank-Import (6 Formate, ISIN, `--lookup`, Duplikat-Schutz) + Yahoo-Fallback (Stooq blockt Skripte); healthctl: CSV-Import
- budgetctl: Import überlappender Exporte ohne Duplikate; Bruecke-Profil mit 3 Konten aktualisiert, Konfliktkopien gelöscht
- Completions (bash/zsh/fish) in Archiv + Homebrew-Formel aller Tools (wirken ab dem nächsten Release)
- missionctl: Abdeckung 58 % → 89 %, Fehler behoben (Lizenzschlüssel maskiert, Quoting in `init`, Plist-Escaping, Notify-Rechte, Tagebuch-Datum), Willkommensbildschirm, Konfliktkopien-Warnung
- ASCIIForge/TermCast/CMS2MD: Hintertür entfernt, Polar-Produkte (9 € je Tool) + Benefits + Checkout-Links angelegt, Familien-Rabatt erweitert, Installation per GitHub, Tests

## Kleine Tools: ASCIIForge, TermCast, CMS2MD (als Nächstes)
- [ ] `[N]` Je Tool einen Schlüssel über den Checkout-Link mit dem Familien-Code holen und `license <schlüssel>` testen (Fremdschlüssel wird abgelehnt: geprüft)
- [ ] `[N]` Entscheiden: auf npm veröffentlichen? (`termcast` ist vergeben → `@abteilung83/termcast`); bis dahin Installation per `github:aeon022/<Tool>`
- [ ] `[C]` Tools weiter durchsehen: CMS2MD (Directus/Notion-Sync) gegen echte Instanz testen, TermCast GIF-Export, ASCIIForge-Optik; CI (GitHub Actions) für alle drei; README-Politur mit GIFs
- [ ] `[C]` Landing-Seite oder Abschnitt „Kleine Werkzeuge“ auf missionctl.sh

## So 25.10. – Sa 31.10.
- [ ] `[N+C]` **Testkauf Ende-zu-Ende** (bis 25.10.): Jahresabo mit Family-Code → Schlüssel → `postctl license activate` → nach 24 h Prüfung → Abo kündigen → `revoked` → Lapse-Verhalten (2 Netzwerke publizieren, Rest bleibt geplant)
- [ ] `[C]` Fallstudie Brücke (nur bei Zustimmung), Entwurf
- [x] `[C]` Beiträge als Entwurf (`docs/launch/`, 2026-10-19): Show HN, Reddit (r/commandline, r/ClaudeAI, r/selfhosted), Blogartikel (MCP-Sicherheit / Tag im Terminal)
- [x] `[C]` Verzeichnisse, Eintragsentwürfe in `docs/launch/verzeichnisse.md` (PRs erst nach Release): MCP-Listen, awesome-tui, awesome-cli-apps, awesome-go
- [~] `[C]` Messung ohne Tracking (`scripts/metrics.sh` fertig; Frage „Wie hast du uns gefunden?“ im Polar-Checkout fehlt): Skript für Stars/Downloads/Polar (read-only), Frage „Wie hast du uns gefunden?“ im Polar-Checkout
- [ ] `[C]` Landingpages: GIFs einbauen, Preise/Texte final, Geräte-Matrix, Deploy auf deine Freigabe
- [ ] `[N]` Rechtstexte nach Prüfung übernehmen (ich arbeite Änderungen ein)
- [x] `[N]` Polar-Token erneuert (2026-10-19)
- [ ] `[N]` Zugangsdaten erneuern: X-Cookies, Pretix-Token, Threads-App-Secret
- [ ] `[C]` Letzter Check (31.10.): `scripts/release.sh --check postctl v0.5.0`, Live-Test aller Seiten/Checkout-Links, `missionctl update --check`, Plesk-Header/404 prüfen

## So 1.11. — Live
- [ ] `[N+C]` **Release** `scripts/release.sh postctl v0.5.0` (nur nach deinem Okay am Tag)
- [ ] `[C]` Release-Notes: Abo, Besitzstand (Lifetime und Bundle vor 18.10.), Link zu Preisen
- [ ] `[N+C]` Beiträge freigeben und veröffentlichen (Show HN Di–Do morgens), am selben Tag Fragen beantworten
- [ ] `[N]` Postctl Scheduler-Dienste auf allen Rechnern auf v0.5.0 aktualisieren (Schlüsseldatei vorhanden!)

## Offen aus der Verbesserungsliste (nach dem Launch)
- [ ] Man-Pages, einheitlicher `--json`-Rahmen, Gesundheits-Panel/Logs-Kopf in weiteren Tools, GIFs auf den Tool-Seiten, GIFs für mailctl/calctl (Demo-Quelle nötig)
- [ ] `missionctl license activate`: Schlüssel nicht als Argument an die Tools reichen (Prozessliste), z. B. per Standardeingabe in allen Tools
- [ ] Neue Releases der Tools (Completions, Lizenz-Bereinigung); `release.sh` je Tool nach Okay
- [ ] Raiffeisen/ELBA-Format (Beispieldatei nötig); weitere AT-Banken

## notectl: Apple↔Obsidian-Mirror mit Checkboxen (nächste Tool-Überarbeitung, vor Aktivierung)
Anlass 2026-10-19: Obsidian-Notiz (`/Users/gweiher/Obsidian/Gerwin-Vault/`) erschien nicht in notectl/Apple Notes, weil `~/.config/notectl/notectl.yaml` nur `source: apple` hat (kein `vault_path`, `sync_sources`, `mirror_apple_obsidian`). **Config bewusst noch nicht geändert** — Anforderung des Nutzers: Apple-Checkboxen müssen **immer** als Checkboxen gesynct werden, keine Ausnahmen, keine Unfälle.
Befund im Code: AppleScript-`body` liefert Checklisten und Bullets identisch (`<ul><li>`); der echte Zustand steht nur in der Notes-SQLite (`notes.ChecklistState`), das der Mirror nicht nutzt. `PushToApple` ersetzt den ganzen Body → native Checkboxen gehen verloren; `TextToHTML` kann native Checkboxen nicht erzeugen (nur ☐/☑-Text).
- [x] `[C]` (2026-10-25) Apple→Obsidian: `ChecklistState` im Mirror nutzen, Checklisten als `- [ ]`/`- [x]` schreiben; schlägt das Lesen fehl → Notiz überspringen und melden, nie als Bullets schreiben
- [x] `[C]` (2026-10-25, auch `notectl write`/MCP `write_note`) Schutz: Apple-Notiz mit nativer Checkliste wird nie per `PushToApple`/`UpdateBody` überschrieben (Konflikt melden statt schreiben); Test dafür
- [x] `[C]` (entschieden: Obsidian→Apple sperrt Checklisten-Notizen, Konflikt wird gemeldet) Entscheiden/prüfen, ob native Checkboxen aus Obsidian heraus überhaupt erzeugbar sind (AppleScript wohl nein); sonst Obsidian→Apple für Notizen mit Checkboxen sperren
- [ ] `[C]` Tests: Round-Trip Apple→Obsidian→Apple, gemischte Listen, verschachtelt, Emoji; Probelauf nur mit Testnotizen/Wegwerf-Vault, vorher Backup von Vault und Notes
- [ ] `[N+C]` Danach erst in `notectl.yaml`: `vault_path`, `sync_sources: apple,obsidian`, `mirror_apple_obsidian: true`. Übergang: nur `sync_sources` (lesend, ohne Mirror) wäre risikolos

## Multi-Device-Sync über Cloud-Ordner (nächste Tool-Überarbeitung)
Anlass 2026-10-19: Lizenz für 5 Geräte, Konfliktkopien der geteilten DBs in Dropbox. Entwurf + Roadmap: [`proposals/multidevice-sync/README.md`](proposals/multidevice-sync/README.md). Leitplanke: nur Nutzer-Cloud-Ordner, **nie** Server/SaaS/Konto.
- [ ] `[N+C]` Phase 0: Format entscheiden; Cache-Tools (mailctl/calctl/notectl) aus dem geteilten Ordner nehmen; bis Phase 3 nicht mit „nahtlosem 5-Geräte-Sync“ werben; Lizenztext „5 Geräte“ klären
- [ ] `[C]` Phase 1–5 siehe Proposal (Kern in `missionctl-core/syncdir` mit Simulationstests, Pilot habctl/timectl, dann übrige Tools, Kompaktierung, Härtung)

## Danach
- [ ] Woche 1–4: täglich Issues/Mails, wöchentlich Zahlen notieren; nach 4 Wochen Review (Preis, Kanäle), erst dann bezahlte Werbung

---

# TODO — Over-Engineering-Audit (2026-10-05)

Quelle: `ponytail-audit` + `deadcode` + `go test -cover` über die ganze Suite.
Nichts hiervon ist gepusht (Regel: lokal committen, Push nur auf Zuruf).
Lokal testen ohne `setup.sh`: siehe [TESTING.md](TESTING.md).

## Stand 2026-10-08

- Alles ist **gepusht** (Core `82edca7`, alle 12 Tool-Repos + Root); CI war nach dem letzten Push in Core, den 8 Tool-Repos, postctl, healthctl und investctl grün. Für die allerletzten Pushes (Dashboard-Fix `ae3375b`, healthctl `dcc49fc`) wurde die CI nicht abgewartet — `gh run list` prüfen.
- Detaillierter Stand und Änderungsprotokoll: [stage.md](stage.md). Der Stand vom 2026-08-04 liegt in `docs/archive/stage-2026-08-04.md`.
- Offen bleibt die **Sichtprüfung im echten Terminal** (Checkliste: `TESTING.md` Abschnitt 5).

## Erledigt (lokal committet)

**Dependencies / Aufräumen**
- [x] Versionsdrift: `cobra` v1.10.2, `mcp-go` v0.55.1, `fuzzy` v0.1.3 überall.
- [x] `muesli/reflow` aus notectl (→ `ansi.Hardwrap`).
- [x] `viper` aus budgetctl/calctl/mailctl/taskctl → `missionctl-core/config.Store`.
- [x] habctl: privater LLM-Provider (271 Z.) → dünner Adapter über `missionctl-core/ai`; Google-OAuth-Gemini über Hooks `ai.GeminiAvailable/GeminiKey`.
- [x] `runAppleScript`/`escapeAS` 4× → `missionctl-core/applescript` (`Run`, `RunRaw`, `Escape`, `EscapeLine`).
- [x] `truncate()` 3× → `humanize.Truncate` (behebt nebenbei Slice-Panic bei n ≤ 1 in habctl/calctl). missionctl `dashboard.go` bleibt bei seiner breiten-basierten Variante.
- [x] Tote Funktionen entfernt (taskctl, notectl, postctl).
- [x] `themes/*.yaml` im Root gelöscht (byte-identisch zu `missionctl-core/theme/presets`); `themes/iterm` bleibt.
- [x] `SESSION-2026-08-02.md` → `docs/archive/`; Audit-Berichte als Snapshot markiert; `gofmt` in allen Tools außer postctl.
- [x] Core-Bug: `keymap.Help.Text()` war als „ungenutzt“ gelöscht, budgetctl ruft es auf → wiederhergestellt.

**Tests / CI / Tooling**
- [x] `scripts/test-all.sh` (isolierte Tests: Wegwerf-`HOME`, keine `*_DATA_DIR`/API-Keys), `scripts/dev-build.sh`, `scripts/dev-env.sh`, `scripts/bump-core.sh`, `TESTING.md`.
- [x] Neue Tests: taskctl Store (0 → 88 %), calctl `parseEvents` + Create-Script, postctl MCP-Handler (0 → 70 %), core `config.Store`, `applescript`, `Truncate`.
- [x] postctl: `ci.yml` (vet/test/build) wie bei den anderen Tools.

**Bubble Tea v2 + TUI-Aufteilung (2026-10-05)**
- [x] Alle 8 v1-Tools auf `charm.land/*/v2` (timectl, taskctl, calctl, diaryctl, budgetctl, habctl, postctl, missionctl-cli). Es gibt nur noch eine Generation (v1 bleibt nur indirekt über `missionctl-core/theme`).
- [x] `tui.go` in allen 8 Tools aufgeteilt in `tui/styles/update/view/commands/helpers` (reine Verschiebung; taskctl: Update steckt noch in `view.go`).
- [x] v2-Fallen behoben: Leertaste ist `"space"` (auch schon in mailctl/notectl kaputt gewesen), Textfeld-Breite 0 kürzt Placeholder auf 1 Zeichen, lipgloss v2 strippt ANSI nicht mehr beim Pipen (habctl-CLI, missionctl-cli über `colorprofile`), `Width/Height` schließen den Rahmen ein (postctl).
- [x] Echte Fehler, die beim Testschreiben auffielen und behoben sind:
  - diaryctl: Streak überbrückte Lücken / war um Mitternacht 0 (UTC vs. lokal) / `|` in Commit-Betreffen zerlegte den git-Reader / `suite` las fremde DBs von festen Pfaden (ignorierte `*_DATA_DIR`, Dropbox-Daten unsichtbar) und verglich „heute“ in UTC.
  - habctl: Streak stand jeden Morgen auf 0 bis zum ersten Check-in (`streak_at_risk` damit unbrauchbar); archivierte Habits verhinderten 100 %-Tage im Kalender.
  - notectl: `Vaults()` leer direkt nach `VaultAdd` (Free-Limit nie durchgesetzt); `contractHome` kürzte fremde Pfade; Leerzeile mit Spaces trennte keine Blöcke; Nicht-ASCII-Titel → Dateiname `.md` (Notizen überschrieben sich); `notes.Delete` konnte aus dem Vault ausbrechen.
  - missionctl-cli: „1 events today“.
- [x] Abdeckung: diaryctl store 0→86 %, render 27→98 %; habctl store 43→88 %, ai 16→69 %, config 0→86 %; notectl config 0→83 %, notes 47→69 %; missionctl-cli cmd 27→39 %; Leertasten-Regressionstests in taskctl, budgetctl, mailctl, habctl, notectl.
- [x] notectl: `resolveAccountCursor` gelöscht (nur Tests riefen es auf).

- [x] taskctl: `Init/Update/handleKey` nach `update.go`; postctl: `gofmt` (49 Dateien, reiner Format-Commit).

**Zweite Test-Runde (2026-10-05, nach dem v2-Push)**
- [x] postctl `platforms` 14→64 % mit HTTP-Mocks (Basis-URLs injizierbar). Fehler behoben: fällige Posts wurden bei Dev.to/Medium als Entwurf gespeichert; Discord-Posts ohne Message-ID (nie löschbar); Twitter-`Delete` war ein Stub; XSS im OAuth-Callback.
- [x] diaryctl: `suite` 21→90 % (echte Schemas der anderen Tools), TUI 25→55 %. Fehler behoben: archivierte Habits im Tagebuch, Streak morgens 0, Suche/Palette verschluckten Leerzeichen/Umlaute, Editor-Taste `a` startete KI beim Tippen (**KI jetzt auf `ctrl+g`**).
- [x] habctl: längste Wochenserie berechnet statt Platzhalter; TUI 11→25 %.
- [x] taskctl TUI 23→76 %, calctl TUI 34→83 %. Fehler behoben: Bearbeiten verlor Unteraufgaben (taskctl) bzw. Notizen/Teilnehmer/Ganztag (calctl); `firstURL` bei `İ`; Daemon-PID ≤ 0; DST-Tage (25 h/23 h) in calctl; negative Dauer; `--until` ohne letzten Tag; YAML-Kopf bei `"` im Titel; `wordWrap` bytes statt Runen.
- [x] budgetctl TUI 46→59 %, mailctl 58→75 %, notectl 58→67 %. Fehler behoben: Löschen aktualisierte nur die gefilterte Liste (Duplikate/Wiederauftauchen, mailctl+notectl); Gelesen-Status ging verloren; `runeLimit(s,0)` Absturz.
- [x] calctl: Draft-Datei über `os.CreateTemp` statt vorhersehbarem `/tmp`-Pfad; `./config.yaml` nicht mehr im Config-Suchpfad.
- [x] Geprüft: das Listenkopie-Muster (`all*` + gefilterte Liste) kommt in budgetctl/habctl/timectl nicht vor (sie laden nach Änderungen neu).

## Bewusst nicht gemacht (mit Begründung)

- **notectl-Config → Core-`Store`:** notectl braucht Mutex (TUI-Goroutinen), typisiertes `getBool` und `map[string]string`-Overrides. Der Core-Store ist absichtlich klein und nicht thread-safe; Angleichen würde ihn aufblähen. Zwei Implementierungen bleiben, bis ein zweites Tool Thread-Safety braucht.
- **`google/uuid` (11 Dateien):** nur ersetzbar, wenn nirgends das UUID-Format zählt. Kein sicherer Schnitt.
- **`termenv` als direkte Dependency:** wird nur in den `tui_test.go` importiert (Farbprofil für Tests) → korrekt direkt. Kein Handlungsbedarf.
- **MCP-Result-Helper in Core:** `jsonResult` existiert nur in 2 Tools — spart ~20 Zeilen, nicht der Aufwand.
- **`nlpdate`-Abdeckung:** meine erste Auswertung war falsch, das Paket hat 100 %.

## Aus dem postctl-Update (2026-10-16) — Übertrag auf die anderen Tools (morgen)

postctl ist gepusht (`b838b8b`), Core `f71f85d` auch. Für die übrigen Tools:

- [x] ~~**Core bumpen** auf `f71f85d`~~ — erledigt 2026-10-17 (alle Tools sind auf Core `9de8a0e`, das f71f85d enthält); ursprünglich: (live Themes: `theme.Apply/Presets/Current/OnChange/Save`): mailctl, calctl, taskctl, notectl, budgetctl, timectl, diaryctl, healthctl, investctl, missionctl-cli (habctl behält seine eigene Palette).
- [x] ~~**Live-Theme-Wechsel in allen TUIs**~~ — erledigt 2026-10-18: Taste `T` (timectl: `C`, da `T` = Task-Picker) + `:theme`, `theme.Cycle()` im Core, habctl folgt jetzt dem Suite-Theme, Onboarding-Checkliste im leeren Zustand in allen Tools; Dashboard `T`. Theme-Zeile in den Settings: habctl/budgetctl (`t`), notectl (`ctrl+t`); die übrigen Tools haben keinen Settings-Screen.
- [x] ~~**Theme-Zeile in den Settings** jedes Tools (Muster: postctl `cycleSettingDir` + `refreshStyles` über `theme.OnChange`). Achtung: Styles, die ein Tool auf Package-Ebene aus Theme-Farben baut (z. B. `dimStyle`), müssen beim Wechsel neu gebaut werden, sonst bleiben sie auf der alten Palette.
- [x] ~~**Root-Zeiger** auf `missionctl-core` anheben~~ — mit dem Sicherheits-Commit erledigt; ursprünglich: (`git add missionctl-core && git commit`) — steht gerade als `M missionctl-core` offen.
- [~] **Testregel in jedem Tool:** *teilweise* — Core `syncdir` entfernt in jedem Test-Binary die exportierten `*_DATA_DIR`-Variablen (2026-10-17). Offen: `TestMain` mit Wegwerf-`HOME` pro Paket. Ursprünglich: `TestMain` mit Wegwerf-`HOME` (Vorlage: postctl `*/testmain_test.go`). Vorfall 2026-10-16: ein Test (Enter auf eine per Zeilennummer gewählte Settings-Zeile) überschrieb die echte `~/.config/postctl/config.yaml` und rief Mastodon im Netz auf. Alle Tools prüfen: Tests, die `Save*`/Config/`exec` ohne `t.Setenv("HOME")` nutzen; Settings-Zeilen in Tests nie per Index wählen.
- [ ] **UI-Ideen aus postctl zum Übertragen:** Gesundheits-Panel (Token-/Sync-Alter), einheitliche `:`-Palette, Spinner nur während des Ladens, Logs-Kopfbereich, Settings als mehrere umrandete Bereiche, Klick-Raster mit gemeinsamem Layout für Zeichnen und Hit-Test (Kalender-Muster), Onboarding-Checkliste im leeren Dashboard (die Checklisten in den Tools sind seit 2026-10-18 da; das Dashboard hat keinen leeren Zustand).
- [x] stage.md / ROADMAP für die Suite nachziehen (erledigt 2026-10-18; postctl: Kalender-Tab, Profil-Schutz, Editor-Vorschau, Composer, Stats, Palette, Suche).

## Offen

- [x] ~~Zeitstempel `RFC3339Nano` als TEXT~~ — timectl schreibt fixed-width (`writeLayout`) mit einmaliger Migration; habctl sortiert nach `id`.

- [ ] **Sichtprüfung** (v2-Migration, drei Layout-Runden, healthctl/investctl) — gepusht ist bereits, Sichtprüfung steht aus: `TESTING.md` Abschnitt 5.
- [x] ~~diaryctl `suite`: fremde Config-Layer~~ — 2026-10-18: `config.yml` wird wie `config.yaml` gelesen; mehr Layer gibt es bei den vier Tools nicht (nur Env + eine Config-Datei).
- [ ] habctl: `skip_allowed` wird bei Weekly-Habits in der aktuellen Serie ignoriert (bewusst unverändert) — Produktentscheidung.
- [ ] Abdeckung weiter: Render-/Mauscode der TUIs, postctl `platforms` Rest (Twitter-Cookie/chromedp, Browser-Auth, Threads-Bildupload), notectl `mirror`/`syncdispatch` (brauchen Notes/Joplin), budgetctl-Import-Assistent mit Dateiwähler, AppleScript-nahe Befehle.
- [ ] Offene Beobachtungen: `budgetctl` liest weiter `./budgetctl.yaml` aus dem Arbeitsverzeichnis (spezifischer Name, bewusst belassen); postctl-OAuth-Callbacktest bindet festen Port 8753.
- [ ] **Thunderbird-Backend (Linux)** in mailctl: laut README nicht gegen echte Installation getestet.
- [x] Unsubscribe-Helper (mailctl `U`) erledigt.
- [ ] **Gmail-OAuth** (mailctl) — braucht eine Google-Cloud-Client-ID vom Nutzer; bewusst ausgenommen.
- [ ] Neu 2026-10-08: ~~habctl-Langansichten werden von `ui.Frame` auf winzigen Terminals abgeschnitten~~ (scrollen jetzt mit PgUp/PgDn/Mausrad, 2026-10-18); ~~postctl-Lade-/Fehlerbildschirme umgehen den Rahmen und fehlende `Tr()`-Texte~~ (geprüft 2026-10-18: laufen über `ui.Frame`, alle 280 Schlüssel haben DE+EN); timectl-Eingabeprompts bleiben Fußzeilen-Prompts; ~~notectl-Link-Graph scrollt nicht~~ (scrollt mit dem Cursor, 2026-10-18); ~~taskctl zeigt die Done-Zahl erst nach dem Öffnen des Done-Tabs~~ (behoben 2026-10-18); ~~Dashboard-Today-Panel ist nicht klickbar~~ (Klick öffnet die Agenda, 2026-10-18).
- [ ] Unverifiziert (braucht Live-Test): echte Stooq-Kurse (investctl), `healthctl remind`-Benachrichtigungen, Farben/Maus im echten Terminal.
- [x] ~~Invest-Karte ohne Zifferntaste~~ — 2026-10-18: `0` (investctl) und `p` (postctl). Offen: bei sehr niedrigen Terminals mit 10 Karten bleibt das Today-Panel ausgeblendet.
- [x] ~~`proposals/healthctl` und `proposals/investctl` als „umgesetzt“ markieren~~ — 2026-10-18.

- [x] ~~postctl: neue Screenshots für postctl.sh und missionctl.sh~~ — postctl.sh hat Kalender/Einstellungen-Mockups (2026-10-18); missionctl.sh zeigt das Dashboard jetzt in vier Themes mit Umschalter (2026-10-18).

## Sicherheits-Audit der Suite (2026-10-17) — Stand
Behoben (lokal committet, siehe `git log` je Tool): owner-only Dateien (Core `secure.Init`, Aktivitätslog 0600), mailctl `send_email` nur per Opt-in (`MAILCTL_MCP_ALLOW_SEND=1`), taskctl AppleScript-Escaping in der Pomodoro-Benachrichtigung, notectl `Write` nur innerhalb des Vaults, `confirm=true` für alle `delete_*`-MCP-Tools, budgetctl Import nur CSV/TSV/TXT, Lizenz-HTTP mit Timeout.
Behoben 2026-10-17 (Core `aaca411`): `syncdir.Acquire` nimmt jetzt eine *geteilte* Sperre — TUI, Daemon, CLI und MCP schließen sich nicht mehr aus (SQLite-Busy-Timeout koordiniert); `syncdir.InUse` für `doctor`. Alle Tools sind auf Core `aaca411` gebumpt.

- [x] 2026-10-18: echte TUI-Screenshots (TuiShot) auf den acht Tool-Seiten der Landingpage; mailctl-Konten-Tab heißt jetzt „All“ statt „Alle“.
- [ ] Bewusst nicht umgesetzt (2026-10-18): timectl-Eingabeprompts als Popup (Fußzeilen-Prompt ist suite-konsistent und funktioniert); Gesundheits-Panel/Logs-Kopfbereich/Klick-Raster aus postctl für die anderen Tools — Nutzen unklar, bei Bedarf einzeln beauftragen.
