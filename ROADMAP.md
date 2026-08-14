# missionctl — Roadmap

> Last updated: 2026-08-14 · Model: claude-sonnet-5
>
> This table had drifted badly by the previous update (2026-07-11): habctl
> and missionctl were both still marked "Building" here well after they'd
> actually shipped (habctl has its own priced landing page and GitHub
> releases; missionctl has doctor/init/status/dashboard/agenda/settings/
> license/update, not just doctor). MCP tool counts below are re-verified
> directly against each app's `internal/mcpserver/*.go` (excluding test
> files, which had silently doubled an earlier manual count for diaryctl).

## Status Overview

| Tool            | Status      | MCP Tools | Notes |
|-----------------|-------------|-----------|-------|
| mailctl         | ✅ Shipped   | 6         | Unsubscribe, templates, TUI, AI draft reply |
| calctl          | ✅ Shipped   | 7         | Free slots, event create, TUI |
| taskctl         | ✅ Shipped   | 7         | Pomodoro, daemon, batch ops |
| notectl         | ✅ Shipped   | 8         | Daily notes, Obsidian/Apple Notes/Joplin vault, delete_note |
| budgetctl       | ✅ Shipped   | 11        | Goals, recurring detection, export |
| postctl         | ✅ Shipped   | 7         | Own site: postctl.sh (live) |
| diaryctl        | ✅ Shipped   | 5         | Daemon, AI streaming, suite integration, TUI polish, notectl write-back |
| timectl         | ✅ Shipped   | 4         | Heatmap, duration bars, taskctl link, invoice export |
| habctl          | ✅ Shipped   | 12        | Habit tracker, streaks, AI weekly review, habit chains, Ollama support |
| missionctl      | ✅ Shipped   | —         | Umbrella CLI: doctor (now reports real daemon liveness), init, status, dashboard, agenda, settings, license, update |
| landing         | ✅ Live      | —         | deploy/landing branch, missionctl.sh serving |

**Total shipped: 67 MCP tools across 9 apps.**

---

## ⚡ Sofort — erledigt, Abschnitt aufgelöst

Alle vier Punkte, die hier standen (missionctl Umbrella-CLI inkl. doctor/init/status,
habctl komplett inkl. SQLite/Streaks/MCP/Diary-Integration, budgetctl `--ai`-Import,
calctl `summarize`), sind live und geshippt — siehe Status Overview oben bzw.
"Bestehende Apps" unten, wo sie bereits korrekt als `[x]` geführt werden. Waren hier
nur als Karteileiche mit `[ ]` stehen geblieben; Abschnitt entfernt statt dupliziert.

---

## 🔴 Now — Aktiv

### Landing page — Go live
- [x] Astro 6 + Tailwind v4
- [x] Alle App-Seiten (8 Apps), Docs, Privacy, Cookies
- [x] Announcement bar, scroll reveal, typewriter, FAQ, tool grid
- [x] Page transitions (glitch effect)
- [x] Deploy — live auf missionctl.sh (eigener Server via nginx, nicht Vercel/Cloudflare wie ursprünglich geplant; deploy/landing Branch)
- [x] Polar.sh Produkte + echte Checkout-Links live (5 Tools mit AI-Feature-Add-on + $39 Lifetime-Bundle, siehe Monetarisierung unten)

### diaryctl — v0.2 ✅
- [x] TUI polish: search highlight, word goal bar, markdown rendering, today summary
- [x] notectl write-back (diary entries → Obsidian vault)
- [x] `diaryctl export [--format post]` für postctl Pipeline
- [x] notectl → postctl Pipeline (`diaryctl export --format post | postctl import -`)
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
- [x] `diaryctl export --date X --format post | postctl import -` Pipeline live
- [ ] dev.to / Medium Cross-Post

### Dokumentation
- [ ] Interaktive Beispiele auf docs-Seite
- [ ] "30 Tage mit missionctl" Challenge

---

## Monetarisierung (polar.sh) — live, anderes Modell als ursprünglich geplant

Tatsächliches Modell auf missionctl.sh: alle 9 Tools sind einzeln **kostenlos**
herunterladbar; bezahlt wird für AI-Feature-Add-ons bei einzelnen Tools oder für
das Lifetime-Bundle. Kein separates $9-pro-Tool-Produkt, kein "Bundle + Diary",
kein Tutorial-Produkt — die Zeilen dazu unten waren reine Planung, nie umgesetzt.

| Produkt                        | Preis                  | Status                          |
|---------------------------------|------------------------|----------------------------------|
| mailctl — AI features           | Add-on                 | ✅ Live (Polar-Checkout-Link)   |
| calctl — AI features            | Add-on                 | ✅ Live (Polar-Checkout-Link)   |
| budgetctl — AI features         | Add-on                 | ✅ Live (Polar-Checkout-Link)   |
| notectl — 2. Vault              | Add-on                 | ✅ Live (Polar-Checkout-Link)   |
| habctl — AI features            | Add-on                 | ✅ Live (Polar-Checkout-Link)   |
| taskctl, postctl, diaryctl, timectl | —                   | Kein Add-on-Produkt derzeit     |
| **missionctl Bundle (9 Tools, lifetime)** | **$39** (Launch: -30% mit Code `L4uNch26`) | ✅ Live (Polar-Checkout-Link) |

---

## Vision

A complete suite of local-first CLI tools that form the "hands" of an AI agent.
One sentence to Claude → digital week planned, posted, scheduled, tracked — without touching a browser.

**By end of 2026:**
- [x] 10 tools (9 shipped + missionctl umbrella)
- [x] 60+ MCP tools (67 live)
- [ ] Homebrew tap
- [ ] 100+ paying users
