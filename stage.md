# missionctl — Stand 2026-08-04

Gedächtnis-Datei für zukünftige Sessions. Alles hier ist verifiziert (live getestet oder per Build/Test bestätigt), nicht nur behauptet — Pfade, Commits und Befehle sind exakt genug, um selbst nachzuprüfen, ob sie noch stimmen.

## Was heute passiert ist (chronologisch, grob)

1. postctl-Kampagne für die Feature-Updates (Command Palette, diaryctl-Facelift) fertig durchgezogen
2. Homebrew-Distribution für alle 8 Dev-Tools live geschaltet (vorher nur "clone + go build")
3. missionctl.sh: kaputte Fake-Pricing-Story ersetzt durch echte Downloads + echtes Bundle
4. missionctl.sh: Header-Overlap-Bug gefunden und gefixt, Doku massiv erweitert
5. missionctl Bundle bekommt echte AI-Gating-Features in 5 Tools (budgetctl, notectl, mailctl, calctl, habctl)
6. Dabei: echter mailctl-Bug gefunden und gefixt (AI-Fehler wurden nie angezeigt)
7. sync.sh-Verwirrung beim Nutzer aufgeklärt (kein Bug, unpushte Commits + normales Submodule-Verhalten)

## 1. postctl-Kampagne — ERLEDIGT

- Kampagne `missionctl-polish-2026-08` in postctl.db: **30 Posts, alle `scheduled`**, keine Drafts mehr.
- Zeitplan: LinkedIn/Threads/Bluesky/Facebook Mo 10.08. 09:00 → Fr 21.08. 17:30 (3 Slots/Woche, 2 Wochen). Twitter/X gestreckt 10.08.–02.09. (~3,3 Wochen).
- 6 LinkedIn-Posts verlinken zusätzlich auf missionctl.sh (nicht nur GitHub).
- Artikel fertig in `postctl/documents/articles/`: `hacker-news-missionctl.md`, `dev-to-missionctl.md` — beide **manuell** zu posten, postctl hat keine HN/dev.to-API.
- **Wichtiger Vorfall dabei:** die Kampagne kollidierte anfangs mit einer bereits am 12.07. live geposteten, gleichnamigen Kampagne (postctl generiert Post-IDs rein aus `{dateiname}-{platform}`, ignoriert Ordner/Kampagnennamen). 5 alte, echte Posted-Records wurden dabei überschrieben — auf Nutzerentscheidung hin **nicht** aus Dropbox-Historie wiederhergestellt, bewusst akzeptiert. Für neue Kampagnen: **immer eindeutige Dateinamen pro Slot verwenden**, sonst Kollisionsgefahr.
- Task #4 im Tracker kann als erledigt markiert werden.

## 2. Homebrew-Distribution — LIVE

- Alle 8 Dev-Tools (calctl, taskctl, notectl, mailctl, budgetctl, diaryctl, timectl, habctl) haben jetzt `v0.1.0`-Releases auf GitHub + Formeln in `aeon022/homebrew-tap`.
- `brew tap aeon022/tap https://github.com/aeon022/homebrew-tap && brew install aeon022/tap/<tool>` — live getestet, funktioniert.
- `HOMEBREW_TAP_TOKEN` Secret ist in allen 8 Tool-Repos gesetzt (fine-grained PAT, Zugriff auf homebrew-tap).
- postctl ist NICHT Teil dieser Pipeline (hat eigene Site/eigenen Vertrieb).

## 3. missionctl.sh Pricing — ehrlich gemacht

- Vorher: kaputte "$9/Tool, $39 Bundle"-Buttons, die auf `polar.sh/aeon022` zeigten (404, nie funktioniert).
- Jetzt: alle 8 Tools einzeln kostenlos (Download-Grid + `brew install`), plus ein echtes, funktionierendes **missionctl Bundle** — realer Polar-Checkout-Link, Launch-Code `L4uNch26` (-30%), $39 (in USD angezeigt, tatsächlich €33,89 wegen Polar/Standort).
- "Free forever"-Aussagen wurden entfernt/korrigiert, nachdem Bundle-Gating eingeführt wurde (siehe Abschnitt 5).
- Individuelle Tool-Preise (z.B. "calctl einzeln kaufen") sind laut Nutzer **bewusst noch nicht gebaut** — kommt später.

## 4. missionctl.sh Doku — Bug gefixt + stark erweitert

- **Bug (gefixt):** `#site-header` ist `position:fixed`; der Spacer-Div, der Platz für den Header reservieren sollte, lag fälschlich *innerhalb* dieses fixed-Containers und trug daher nie zur Dokument-Höhe bei. Auf `/docs` (wenig Top-Padding) überlappte der Header sichtbar den Inhalt und machte die ersten TOC-Links unklickbar. Fix: Spacer nach draußen verschoben (`Layout.astro`, außerhalb `#site-header`), plus `--ann-bar-height` CSS-Variable (wurde referenziert, aber nie gesetzt) jetzt real definiert in `global.css`.
- Neue Doku-Sektionen: **Sync Across Devices** (WAL→Rollback-Journal, flock, iCloud-Placeholder-Erkennung — technisch akkurat aus `missionctl-core/syncdir` übernommen), **Licensing (Bundle features)**, **Tutorial: First 10 Minutes**.
- Alle 9 Tools' TUI-Keybinding-Tabellen im Vergleich zum echten Code geprüft und korrigiert wo nötig.

## 5. missionctl Bundle — AI-Gating in 5 Tools

Neues gemeinsames Paket: **`missionctl-core/ai`** (`provider.go`) — Anthropic/OpenAI/Gemini/Ollama, Auto-Detection in dieser Reihenfolge. Ollama braucht keinen Key (lokal, kostenlos). Bewusst NICHT unterstützt: claude.ai/chatgpt.com Browser-Session-Wiederverwendung (ToS-Verstoß, Account-Risiko).

Gegate Features (alle mit `<tool> license activate <key>` / `<tool> license status`, gleicher echter Polar.sh-Mechanismus wie postctl):

| Tool | Feature | Ort im Code |
|---|---|---|
| budgetctl | `--ai` Kategorisierung, `budgetctl recurring` | `cmd/import.go`, `cmd/recurring.go`, MCP `detect_recurring_payments` |
| notectl | 2. benannter Vault (`notectl vault add`) | `internal/config/config.go` `VaultAdd` |
| mailctl | `a`-Taste (AI-Antwortentwurf) | `internal/tui/tui.go` case "a" |
| calctl | `calctl summarize` | `cmd/summarize.go` |
| habctl | `s` (Vorschläge), `r` (Wochen-Review) | `internal/tui/tui.go`, MCP `suggest_habits` (get_weekly_review bleibt frei — reine Daten, kein eigener AI-Call) |

**diaryctl bewusst NICHT gegated** — AI-generierte Einträge sind der Kern des Produkts, nicht ein Zusatzfeature. taskctl/timectl haben keine AI-Integration, nichts zu gaten.

Alle 5 Tools: live in isolierter Testumgebung verifiziert (Free-Pfad blockiert korrekt, `--ai`-Import fällt sauber zurück statt zu crashen). **Nicht getestet:** echter Polar-Activate-Flow mit einem echten, gültigen Bundle-Key.

### Bug dabei gefunden und gefixt: mailctl AI-Fehler unsichtbar

`internal/tui/tui.go`'s `renderDetail()` zeigte `m.status`/`m.err` nie an — nur eine statische Hilfszeile plus Spinner während `aiDrafting`. Ohne API-Key: Spinner blitzt kurz auf, Request scheitert sofort, Spinner verschwindet, nichts ersetzt ihn — der korrekt gesetzte Fehlertext ging nie auf den Bildschirm. Live reproduziert und gefixt (jetzt: `m.status`/`m.err` werden auch in der Detailansicht gerendert, wie in der Listenansicht).

Ähnlicher, kleinerer Bug bei habctl gefunden und gefixt: der Gate-Status landete in `suggestText` ohne `suggestItems`, was in die bestehende "Format not recognised"-Fehlerbehandlung lief statt die eigentliche Bundle-Meldung zu zeigen. Fix: `suggestBlocked`/`reviewBlocked`-Flags ergänzt.

## 6. Offene Punkte

- **sync.sh auf dem MacBook** — Nutzer hat es laufen lassen, "hat scheinbar nicht alles upgedated". Root Cause vermutlich: budgetctl/notectl hatten hier auf dem Mac Studio ungepushte Commits, `sync.sh` hat sie *korrekt* übersprungen (Schutzmechanismus, kein Bug). Inzwischen alles gepusht (siehe unten) — **auf dem MacBook `./sync.sh` erneut laufen lassen und Ergebnis prüfen.**
- Individuelle Tool-Preise (nicht nur Bundle) — vom Nutzer explizit auf "später" verschoben.
- Restliche kleinere Dokumentations-Lücken evtl. noch in anderen Tools (nach demselben Muster wie beim mailctl-`a`-Key-Fund: TUI-Keybindings, die im Code existieren, aber nirgends dokumentiert sind — nicht systematisch für alle 9 Tools durchgeprüft, nur mailctl/calctl/habctl im Zuge der Bundle-Arbeit).

## 7. Push-Status (Stand Ende der Session)

Alles gepusht, nichts hängt lokal:

- `missionctl-core`, `mailctl`, `calctl`, `budgetctl`, `notectl`, `habctl` — alle auf `origin/main` aktuell.
- `missionctl` Superprojekt — `origin/main` bei `69dee1b`, referenziert alle 6 oben aktualisierten Submodule korrekt.
- `missionctl.sh` Landingpage — `deploy/landing-src` und `deploy/landing` beide gepusht und live (Propagation dauert erfahrungsgemäß 90s–mehrere Minuten).
- Aufgeräumt: eine versehentlich in `postctl/` angelegte Git-Worktree (`.worktree-landing-src`) wurde entfernt — falscher Ort, die echte Landingpage-Worktree liegt im `missionctl`-Superprojekt-Root (`.worktree-landing`, `.worktree-landing-publish`).

## Wichtige Pfade

- Landingpage-Quelle: `missionctl/.worktree-landing/landing/` (Branch `deploy/landing-src`)
- Landingpage-Publish: `missionctl/.worktree-landing-publish/` (Branch `deploy/landing`), via `scripts/publish.sh` aus der Quelle gebaut
- Sync-Skript: `missionctl/sync.sh` — immer das nutzen statt rohem `git pull` fürs Superprojekt
- postctl-DB liegt auf Dropbox: `~/Dropbox/Apps/MISSIONCTL/postctl/postctl.db` (echter Ordnername auf der Platte ist **großgeschrieben** `MISSIONCTL`; die Config hier auf dem Mac Studio hat `data_dir` kleingeschrieben `missionctl` eingetragen — funktioniert nur, weil APFS case-insensitive ist. Auf einem case-sensitiven Dateisystem oder falls die Groß-/Kleinschreibung woanders abweicht, würde das brechen.)
