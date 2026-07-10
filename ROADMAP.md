# missionctl — Roadmap

> Last updated: 2026-07-10 · Model: claude-sonnet-4-6

---

## Status Overview

| Tool       | Status     | MCP Tools | Notes |
|------------|-----------|-----------|-------|
| mailctl    | ✅ Shipped  | 6         | Unsubscribe, templates, TUI, AI draft reply |
| calctl     | ✅ Shipped  | 7         | Free slots, event create, TUI |
| taskctl    | ✅ Shipped  | 7         | Pomodoro, daemon, batch ops |
| notectl    | ✅ Shipped  | 7         | Daily notes, Obsidian vault |
| budgetctl  | ✅ Shipped  | 9         | Goals, recurring detection, export |
| postctl    | ✅ Shipped  | 7         | Own site: postctl.sh |
| diaryctl   | ✅ Shipped  | 5         | Daemon, AI streaming, suite integration, TUI polish |
| timectl    | ✅ Shipped  | 4         | 30-day heatmap, duration bars, animated timer |
| landing    | ✅ Built    | —         | deploy/landing branch, not live yet |

**Total shipped: 52 MCP tools across 8 apps.**

---

## 🔴 Now — Active

### Landing page — Go live
Built and tested locally. Waiting for user to deploy.

- [x] Astro 6 + Tailwind v4
- [x] All app pages (8 apps), docs, privacy, cookies
- [x] Announcement bar, scroll reveal, typewriter, FAQ, tool grid
- [x] Back-to-top with progress ring
- [x] Page transitions (glitch effect)
- [ ] **Deploy to Vercel / Cloudflare Pages** (user action)
- [ ] **Polar.sh products anlegen + echte Links einsetzen** (user action)

### diaryctl — v0.2
- [x] Project scaffold, git reader, SQLite, MCP (5 tools)
- [x] TUI with heatmap, in-TUI editor, vim mode, AI streaming (`a` key)
- [x] Daemon (launchd, auto-generates + Claude-fills at 17:30)
- [x] Suite integration: taskctl, calctl, timectl
- [x] TUI polish: search highlight, word goal bar, markdown rendering, today summary
- [ ] notectl write-back (diary entries → Obsidian vault)
- [ ] diaryctl → postctl pipeline (best entries → social posts)

### timectl — v0.2
- [x] CLI: start, stop, today, week, stats
- [x] MCP server (4 tools)
- [x] TUI: 30-day heatmap, duration bars, animated running timer, panel layout
- [ ] taskctl integration (timer an Task-ID)
- [ ] Stundensatz + Rechnungs-Export

---

## 🟡 Next

**Konzept:** Zeit auf Tasks tracken. Brücke zwischen taskctl (was soll ich tun) und diaryctl (was hab ich gemacht).

```
timectl start "Bugfix Auth"    # startet Timer
timectl stop                   # stoppt, speichert
timectl today                  # Zeitlog heute
timectl week                   # Woche
timectl mcp                    # MCP server
```

**TUI:** laufender Timer in der Statusbar, Tages-Zeitleiste, Wochen-Barchart.

**MCP Tools (4):**
- `start_timer` — Task-Name, startet Timer
- `stop_timer` — stoppt laufenden Timer, gibt Dauer zurück
- `get_time_log` — Log für einen Tag/Zeitraum
- `get_time_stats` — Breakdown nach Task/Projekt, Wochensumme

**Integration:**
- `taskctl` — Timer an existierende Tasks koppeln
- `diaryctl` — "Du hast 3.5h an diaryctl gearbeitet" im Tageseintrag
- `budgetctl` — optionaler Stundensatz → Projekt-Wert berechnen

**Roadmap:**
- [ ] v0.1: `start`, `stop`, `today`, `week`, SQLite, TUI
- [ ] v0.2: taskctl-Integration (Timer an Task-ID)
- [ ] v0.3: MCP Server
- [ ] v0.4: diaryctl-Integration
- [ ] v0.5: Stundensatz + Rechnungs-Export

---

## 🟡 Existing Apps — Improvements

### mailctl
- [x] **AI Draft in TUI** — `a`-Taste im Detail-View: Claude generiert Reply-Entwurf, öffnet Compose
- [ ] Gmail OAuth2 als zweite Datenquelle (neben Apple Mail)
- [ ] Attachment-Preview im TUI

### budgetctl
- [ ] **Auto-Kategorisierung** — neue Transaktionen beim Import via Claude kategorisieren lassen (MCP-Aufruf)
- [ ] Multi-Währung (EUR/CHF/USD)
- [ ] Jahresbericht als PDF-Export

### calctl
- [ ] **Recurring Event Templates** — `.md`-Datei als Event-Vorlage, einmalig definieren
- [ ] Timezone-Awareness bei Event-Erstellung
- [ ] Meeting-Zusammenfassung via mailctl (Nach-Meeting E-Mail auto-draft)

### taskctl
- [ ] **Abhängigkeiten** — Task A blockiert Task B
- [ ] Google Tasks als zweite Datenquelle
- [ ] Projekt-Gruppierung

### notectl
- [ ] **Bidirektionaler Sync** — Änderungen in Obsidian werden in SQLite zurückgeschrieben (Watcher via `fsnotify`)
- [ ] Bear Notes Support
- [ ] Tägliche Note automatisch via Daemon erstellen

### diaryctl (v0.2+)
- [ ] Stimmungs-Tracker (1-5 Skala, im TUI)
- [ ] Wöchentliche Narrative (Freitag-Zusammenfassung)
- [ ] Code-Qualitäts-Hinweise (AI kommentiert interessante Diff-Muster)
- [ ] Streak-Notifications via macOS

---

## 🟢 Distribution

### Homebrew Tap
```bash
brew install aeon022/tap/missionctl-bundle
```
- [ ] GitHub repo `homebrew-tap` erstellen
- [ ] Formulae für alle 7 Tools
- [ ] CI: Build + Release auf GitHub Actions
- [ ] Automatische Updates via `brew upgrade`

### `missionctl` Umbrella-CLI
Ein Binary, alle Tools:
```bash
missionctl mail           # → mailctl TUI
missionctl cal today      # → calctl list --today
missionctl task add "X"   # → taskctl add "X"
missionctl update-all     # → alle Tools updaten
```
- [ ] Cobra Root-Command mit Sub-Commands die andere Binaries aufrufen
- [ ] `missionctl doctor` — prüft ob alle Tools installiert sind
- [ ] `missionctl update` — `git pull && setup.sh` für alle

### Setup-All Script
```bash
curl -s https://missionctl.sh/install.sh | bash
```
- [ ] Erkennt fehlende Tools, installiert nur was fehlt
- [ ] PATH-Setup automatisch

---

## 🔵 Content & Marketing

### Asciinema Recordings
- [ ] 15-Sek Terminal-Recording pro App
- [ ] In Landing Page eingebettet (ersetzt statische Terminal-Mock)
- [ ] Auf YouTube als "Getting Started" Playlist

### Blog via diaryctl + postctl
- [ ] Interessante Diary-Einträge → polierter Blog-Post
- [ ] `diaryctl export --best-of --month 2026-07 | postctl import -` Pipeline
- [ ] dev.to / Medium Cross-Post

### Dokumentation erweitern
- [ ] Interaktive Beispiele auf docs-Seite
- [ ] "30 Tage mit missionctl" — Challenge-Dokumentation
- [ ] Video-Tutorial (Screen recording)

---

## Monetarisierung (polar.sh)

| Produkt               | Preis  | Status |
|-----------------------|--------|--------|
| mailctl               | $9     | ⬜ Anlegen |
| calctl                | $9     | ⬜ Anlegen |
| taskctl               | $9     | ⬜ Anlegen |
| notectl               | $9     | ⬜ Anlegen |
| budgetctl             | $9     | ⬜ Anlegen |
| postctl               | $9     | ⬜ Anlegen |
| diaryctl              | $9     | ⬜ Nach v0.1 |
| timectl               | $9     | ⬜ Nach v0.1 |
| **missionctl Bundle** | **$39**| ⬜ Anlegen (8 Tools) |
| **Bundle + Diary**    | **$49**| ⬜ Anlegen |
| Go Tutorial           | $19    | ⬜ Anlegen |
| Tutorial + Bundle     | $49    | ⬜ Anlegen |

---

## Vision

A complete suite of local-first CLI tools that form the "hands" of an AI agent.
One sentence to Claude → digital week planned, posted, scheduled, tracked — without touching a browser.

**By end of 2026:**
- 10 tools (8 shipped + 2 planned)
- 60+ MCP tools
- Homebrew tap
- 100+ paying users
