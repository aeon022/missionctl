# missionctl — Roadmap

> Last updated: 2026-07-11 · Model: claude-sonnet-4-6

---

## Status Overview

| Tool            | Status      | MCP Tools | Notes |
|-----------------|-------------|-----------|-------|
| mailctl         | ✅ Shipped   | 6         | Unsubscribe, templates, TUI, AI draft reply |
| calctl          | ✅ Shipped   | 7         | Free slots, event create, TUI |
| taskctl         | ✅ Shipped   | 7         | Pomodoro, daemon, batch ops |
| notectl         | ✅ Shipped   | 7         | Daily notes, Obsidian vault |
| budgetctl       | ✅ Shipped   | 9         | Goals, recurring detection, export |
| postctl         | ✅ Shipped   | 7         | Own site: postctl.sh |
| diaryctl        | ✅ Shipped   | 5         | Daemon, AI streaming, suite integration, TUI polish, notectl write-back |
| timectl         | ✅ Shipped   | 4         | Heatmap, duration bars, taskctl link, invoice export |
| habctl          | 🔨 Building  | 3         | Habit tracker, streak integration with diaryctl |
| missionctl      | 🔨 Building  | —         | Umbrella CLI: doctor, init, status |
| landing         | ✅ Built     | —         | deploy/landing branch, not live yet |

**Total shipped: 52 MCP tools across 8 apps.**

---

## ⚡ Sofort — Wird gerade umgesetzt

### ⚡ missionctl — Umbrella CLI
Einstiegspunkt für die gesamte Suite. Höchste Priorität.

- [ ] `missionctl doctor` — prüft ob alle Tools installiert + konfiguriert sind
- [ ] `missionctl init` — interaktiver Setup-Wizard (registriert repos, vault, APIs)
- [ ] `missionctl status` — Tages-Briefing: offene Tasks, nächster Termin, laufender Timer, Budget-Stand, Diary-Streak
- [ ] Cobra Root mit Sub-Commands
- [ ] Registriert in PATH via setup.sh

### ⚡ habctl — Habit Tracker (vor Go-Live)
Einfach, täglich nützlich, natürlich mit diaryctl verknüpft.

```bash
habctl check "Sport"        # heute abhaken
habctl list                 # alle Habits + Streaks
habctl stats [--days 30]    # Balkendiagramm + Streak-History
habctl mcp                  # MCP Server
```

- [ ] SQLite store (`~/.local/share/habctl/habits.db`)
- [ ] Habits + daily check-ins
- [ ] Streak-Berechnung (wie diaryctl)
- [ ] MCP Tools: `check_habit`, `get_habit_stats`, `list_habits`
- [ ] Diary-Integration: offene Habits erscheinen im Diary-Template

### ⚡ budgetctl — Auto-Kategorisierung via Claude
- [ ] `budgetctl import <file.csv> --ai` — Claude kategorisiert alle Transaktionen ohne Kategorie
- [ ] Lernend: bestehende Kategorien als Few-Shot-Beispiele mitgeben
- [ ] Neue Kategorie-Vorschläge werden bestätigt bevor gespeichert

### ⚡ calctl — Meeting-Zusammenfassung
- [ ] `calctl summarize [--event-title "..."] [--date YYYY-MM-DD]`
- [ ] Claude generiert strukturierte Zusammenfassung (Beschlüsse, Todos, Nächste Schritte)
- [ ] `--email` Flag → mailctl draftet Zusammenfassung an Teilnehmer

---

## 🔴 Now — Aktiv

### Landing page — Go live
- [x] Astro 6 + Tailwind v4
- [x] Alle App-Seiten (8 Apps), Docs, Privacy, Cookies
- [x] Announcement bar, scroll reveal, typewriter, FAQ, tool grid
- [x] Page transitions (glitch effect)
- [ ] **⚡ Deploy zu Vercel / Cloudflare Pages** (User-Action)
- [ ] **⚡ Polar.sh Produkte anlegen + echte Links** (User-Action)

### diaryctl — v0.2 ✅
- [x] TUI polish: search highlight, word goal bar, markdown rendering, today summary
- [x] notectl write-back (diary entries → Obsidian vault)
- [x] `diaryctl export [--format post]` für postctl Pipeline
- [ ] notectl → postctl Pipeline (best entries → social posts)
- [ ] Stimmungs-Tracker (1-5 Skala)

### timectl — v0.2 ✅
- [x] TUI: 30-day heatmap, duration bars, animated timer, cyan theme
- [x] Day-Navigation (←/→/t), daily goal bar, copy/restart
- [x] taskctl Integration (Timer an Task verlinken via T-Key)
- [x] Stundensatz + `timectl invoice --month YYYY-MM`
- [ ] Stundensatz + Rechnungs-Export (PDF)

---

## 🟡 Nächste Woche — KI-Layer

### ⭐ Wöchentliches AI-Briefing (Morgen)
Jeden Sonntag automatisch — das stärkste Argument für die Suite als Ganzes.

```
Claude liest: commits (diaryctl) + tasks (taskctl) + time (timectl)
            + events (calctl) + spending (budgetctl) + diary entries
→ Generiert: "Week of July 7 — was gut lief, was nicht, Empfehlung"
→ Speichert in notectl vault + macOS Notification
```

- [ ] `missionctl briefing` — manuell auslösen
- [ ] `missionctl briefing --schedule` — launchd, jeden Sonntag 18:00
- [ ] Liest von allen MCP-Servern oder direkt aus den SQLite-DBs

### mailctl — Gmail OAuth2
Öffnet den Markt für alle Gmail-Nutzer (aktuell nur Apple Mail).

- [ ] Google OAuth2 Flow (Consent Screen, Token-Storage in Keychain)
- [ ] IMAP via OAuth2 Bearer Token
- [ ] Source-Switching: `--source gmail` / `--source apple`
- [ ] Unified inbox (beide Quellen gemischt)

---

## 🟢 Distribution

### Homebrew Tap
```bash
brew install aeon022/tap/missionctl-bundle
```
- [ ] GitHub repo `homebrew-tap` erstellen
- [ ] Formulae für alle Tools (mailctl, calctl, taskctl, notectl, budgetctl, postctl, diaryctl, timectl, habctl)
- [ ] CI: Build + Release auf GitHub Actions

### Setup-All Script
```bash
curl -s https://missionctl.sh/install.sh | bash
```
- [ ] Erkennt fehlende Tools, installiert nur was fehlt
- [ ] PATH-Setup automatisch
- [ ] Konfiguriert `missionctl init` nach Installation

---

## 🟡 Bestehende Apps — Weitere Verbesserungen

### mailctl
- [x] AI Draft in TUI (`a`-Taste: Claude generiert Reply-Entwurf)
- [ ] Gmail OAuth2 als zweite Datenquelle
- [ ] Attachment-Preview im TUI

### budgetctl
- [x] Auto-Kategorisierung via Claude (`--ai` Flag bei import)
- [ ] Multi-Währung (EUR/CHF/USD)
- [ ] Jahresbericht als PDF-Export

### calctl
- [x] Meeting-Zusammenfassung via Claude (`calctl summarize`)
- [ ] Recurring Event Templates
- [ ] Timezone-Awareness bei Event-Erstellung

### taskctl
- [ ] Abhängigkeiten — Task A blockiert Task B
- [ ] Google Tasks als zweite Datenquelle
- [ ] Projekt-Gruppierung

### notectl
- [ ] Bidirektionaler Sync (fsnotify Watcher)
- [ ] Bear Notes Support
- [ ] Tägliche Note automatisch via Daemon

### diaryctl (v0.3+)
- [ ] Stimmungs-Tracker (1-5 Skala, im TUI)
- [ ] Wöchentliche Narrative (Freitag-Zusammenfassung)
- [ ] Code-Qualitäts-Hinweise (AI kommentiert Diff-Muster)
- [ ] Streak-Notifications via macOS

### timectl (v0.3+)
- [ ] Stundensatz Rechnungs-Export als PDF
- [ ] taskctl Integration (Timer an Task-ID, nicht nur Name)

---

## 🔵 Content & Marketing

### Asciinema Recordings
- [ ] 15-Sek Terminal-Recording pro App
- [ ] In Landing Page eingebettet (ersetzt statische Terminal-Mock)

### Blog via diaryctl + postctl
- [ ] `diaryctl export --date X | postctl import -` Pipeline live
- [ ] dev.to / Medium Cross-Post

### Dokumentation
- [ ] Interaktive Beispiele auf docs-Seite
- [ ] "30 Tage mit missionctl" Challenge

---

## Monetarisierung (polar.sh)

| Produkt               | Preis   | Status         |
|-----------------------|---------|----------------|
| mailctl               | $9      | ⬜ Anlegen      |
| calctl                | $9      | ⬜ Anlegen      |
| taskctl               | $9      | ⬜ Anlegen      |
| notectl               | $9      | ⬜ Anlegen      |
| budgetctl             | $9      | ⬜ Anlegen      |
| postctl               | $9      | ⬜ Anlegen      |
| diaryctl              | $9      | ⬜ Anlegen      |
| timectl               | $9      | ⬜ Anlegen      |
| habctl                | $9      | ⬜ Nach v0.1    |
| **missionctl Bundle** | **$39** | ⬜ Anlegen (9 Tools) |
| **Bundle + Diary**    | **$49** | ⬜ Anlegen      |
| Go Tutorial           | $19     | ⬜ Anlegen      |
| Tutorial + Bundle     | $49     | ⬜ Anlegen      |

---

## Vision

A complete suite of local-first CLI tools that form the "hands" of an AI agent.
One sentence to Claude → digital week planned, posted, scheduled, tracked — without touching a browser.

**By end of 2026:**
- 10 tools (9 shipped + missionctl umbrella)
- 60+ MCP tools
- Homebrew tap
- 100+ paying users
