# missionctl — Roadmap

> AI Model used for planning & assistance: **claude-sonnet-4-6**

---

## Vision

A complete suite of local-first CLI tools that form the "hands" of an AI agent.
By Q2 2027, a user should be able to give Claude one sentence and have their
entire digital week planned, posted, scheduled, and tracked — without touching a browser.

---

## postctl — Social Media from Terminal

**Status: Existing (Go, Bubble Tea)**

### v1.0 — Polish & MCP (Q3 2026)
- [ ] Stabilize existing Twitter/X, LinkedIn, Threads integration
- [ ] Robust error handling & retry logic for API failures
- [ ] `postctl mcp` — MCP server exposing all commands as tools
- [ ] `postctl list --json` — machine-readable output for AI
- [ ] Brew formula via tap

### v1.1 — Campaigns (Q4 2026)
- [ ] Campaign grouping: tag posts to a campaign, schedule as a series
- [ ] `postctl campaign plan --topic "launch" --days 30 --json` — AI planning hook
- [ ] Basic analytics: post reach pulled from APIs, stored locally
- [ ] Thread support (Twitter threads from a single Markdown file)

### v2.0 — Team Mode (Q2 2027)
- [ ] Shared SQLite over iCloud Drive (like utask pattern)
- [ ] Approval workflow: draft → review → scheduled
- [ ] Bluesky & Mastodon support

---

## calctl — Calendar from Terminal

**Status: Planned — Priority #1 after postctl v1.0**

### v0.1 — Read & Write (Q3 2026)
- [ ] Apple Calendar read via EventKit (Swift bridge or AppleScript)
- [ ] `calctl list --today --json` — list today's events as JSON
- [ ] `calctl free --next 7d --json` — find free slots, AI-consumable
- [ ] `calctl import event.md` — create event from Markdown frontmatter

```markdown
---
title: Product Launch Call
date: 2026-10-15
time: 14:00
duration: 60min
calendar: Work
attendees: [jan@example.com, lisa@example.com]
notes: |
  Discuss Q4 strategy
---
```

### v0.5 — Google Calendar (Q4 2026)
- [ ] Google Calendar OAuth2 integration
- [ ] Two-way sync: Apple ↔ Google
- [ ] `calctl export --week --json` — full week overview for AI planning
- [ ] TUI: week view, event creation, quick navigation

### v1.0 — MCP + AI Scheduling (Q1 2027)
- [ ] `calctl mcp` — MCP server
- [ ] Natural language scheduling via MCP: "find a 1h slot next week for a deep work session"
- [ ] Recurring event support
- [ ] Time zone awareness

---

## mailctl — Email from Terminal

**Status: Planned**

### v0.1 — Send (Q4 2026)
- [ ] Send email from Markdown file via SMTP or Apple Mail AppleScript
- [ ] `mailctl send draft.md` — send from Markdown
- [ ] `mailctl draft draft.md` — save to Drafts folder
- [ ] Template variables: `{{name}}`, `{{date}}` etc.

```markdown
---
to: [jan@example.com]
cc: []
subject: "October Newsletter"
from: me@example.com
---

Hi {{name}},

here's what's new this month...
```

### v0.5 — Read & Context (Q4 2026)
- [ ] `mailctl inbox --unread --json` — read inbox as JSON for AI context
- [ ] `mailctl thread <id> --json` — read a thread
- [ ] `mailctl search "invoice" --json`
- [ ] Apple Mail integration via AppleScript
- [ ] Gmail via OAuth2

### v1.0 — MCP (Q1 2027)
- [ ] `mailctl mcp` — MCP server
- [ ] AI workflow: Claude reads inbox → drafts replies → user approves → mailctl sends
- [ ] Attachment support (local file → attach)
- [ ] Unsubscribe helper: detect newsletter patterns

---

## budgetctl — Budget from Terminal

**Status: Planned**

### v0.1 — Import & Report (Q4 2026)
- [ ] `budgetctl import bank.csv` — import bank CSV (N26, ING, Deutsche Bank formats)
- [ ] `budgetctl summary --month --json` — monthly summary as JSON
- [ ] `budgetctl list --json` — all transactions
- [ ] Auto-categorization rules (regex-based, config file)
- [ ] Local SQLite storage

### v0.5 — Categories & TUI (Q1 2027)
- [ ] `budgetctl tag "Netflix" --category streaming`
- [ ] `budgetctl report --category --year 2026 --json`
- [ ] TUI: transaction list, category breakdown, monthly chart
- [ ] Budget goals: `budgetctl goal set "dining" 200 --monthly`

### v1.0 — MCP + AI Analysis (Q2 2027)
- [ ] `budgetctl mcp` — MCP server
- [ ] AI workflow: export → Claude analyzes → suggests cuts → user approves
- [ ] Year-end tax report export (CSV/PDF)
- [ ] Recurring payment detection

---

## notectl — Notes from Terminal

**Status: Planned**

### v0.1 — Obsidian Integration (Q1 2027)
- [ ] `notectl write "Note Title" < content.md` — write to Obsidian vault
- [ ] `notectl read "Note Title" --json` — read note
- [ ] `notectl search "keyword" --json` — full-text search in vault
- [ ] `notectl list --json` — list all notes with metadata
- [ ] Config: `vault_path` pointing to Obsidian directory

### v0.5 — Apple Notes (Q1 2027)
- [ ] Apple Notes read/write via AppleScript
- [ ] `notectl sync` — sync between Obsidian and Apple Notes
- [ ] Tag support, folder organization

### v1.0 — MCP (Q2 2027)
- [ ] `notectl mcp` — MCP server
- [ ] AI workflow: Claude writes meeting notes → notectl saves to vault → linked to calendar event
- [ ] Bear Notes support
- [ ] Daily note template automation

---

## taskctl — Tasks from Terminal

**Status: Planned (rewrite utask in Go)**

utask exists as a Python prototype. taskctl is the Go rewrite — faster, single binary, same vision.

### v0.1 — Apple Reminders (Q1 2027)
- [ ] `taskctl list --json` — all tasks as JSON
- [ ] `taskctl add "Call dentist" --due "2026-10-15" --list "Personal"`
- [ ] `taskctl done <id>`
- [ ] `taskctl today --json` — today's tasks for AI daily briefing
- [ ] EventKit bridge for Apple Reminders

### v0.5 — Multi-Provider (Q2 2027)
- [ ] Google Tasks OAuth2
- [ ] Microsoft To Do OAuth2
- [ ] `taskctl sync` — bidirectional sync
- [ ] TUI: task list, quick add, priority management

### v1.0 — MCP (Q2 2027)
- [ ] `taskctl mcp` — MCP server
- [ ] AI workflow: Claude reviews your week → creates follow-up tasks → assigns due dates
- [ ] Project grouping, dependencies
- [ ] Integration with calctl: task with due date → calendar block

---

## Bundle Launch Timeline

```
Q3 2026  postctl v1.0 + MCP
         calctl v0.1

Q4 2026  calctl v0.5
         mailctl v0.1 + v0.5
         budgetctl v0.1
         → Bundle Alpha on polar.sh (postctl + calctl)

Q1 2027  mailctl v1.0 + MCP
         budgetctl v0.5
         notectl v0.1 + v0.5
         taskctl v0.1
         Go Tutorial launch
         → Full Bundle v1.0 on polar.sh

Q2 2027  All tools v1.0 + MCP
         budgetctl v1.0
         notectl v1.0
         taskctl v1.0
         → Complete MCP Suite
```

---

## Monetization (polar.sh)

| Product               | Price  | Type         |
|-----------------------|--------|--------------|
| postctl               | $9     | One-time     |
| calctl                | $9     | One-time     |
| mailctl               | $9     | One-time     |
| budgetctl             | $9     | One-time     |
| notectl               | $9     | One-time     |
| taskctl               | $9     | One-time     |
| **missionctl Bundle** | **$39**| One-time     |
| Go Tutorial           | $19    | One-time     |
| Tutorial + Bundle     | $49    | One-time     |

---

## AI Stack

Tools are designed to work with:
- **Claude** (claude-sonnet-4-6 / claude-opus-4-8) via MCP or CLI piping
- Any MCP-compatible AI client
- Shell scripts + `jq` for lightweight automation

Recommended model for missionctl workflows: **claude-sonnet-4-6** — fast enough for
real-time tool use, smart enough for complex planning tasks.
