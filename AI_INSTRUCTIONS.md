# AI Instructions — missionctl

How to configure and use the missionctl tool suite with AI assistants.

For the full command reference and MCP tool list, see [README.md](README.md) —
this file covers setup + the parts README doesn't: a copy-paste system
prompt, Markdown import formats, and shell-only automation for clients
without MCP support.

---

## Quick Setup (MCP)

Add all nine servers to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mailctl":   { "command": "mailctl",   "args": ["mcp"], "description": "Read and send email via Apple Mail" },
    "calctl":    { "command": "calctl",    "args": ["mcp"], "description": "Read and write calendar events" },
    "taskctl":   { "command": "taskctl",   "args": ["mcp"], "description": "Manage tasks via Apple Reminders" },
    "notectl":   { "command": "notectl",   "args": ["mcp"], "description": "Read and write Obsidian vault notes" },
    "budgetctl": { "command": "budgetctl", "args": ["mcp"], "description": "Read budget, transactions, goals" },
    "habctl":    { "command": "habctl",    "args": ["mcp"], "description": "Track habits and streaks" },
    "timectl":   { "command": "timectl",   "args": ["mcp"], "description": "Time tracking and invoicing" },
    "diaryctl":  { "command": "diaryctl",  "args": ["mcp"], "description": "Developer diary from git history" },
    "postctl":   { "command": "postctl",   "args": ["mcp"], "description": "Schedule and publish social posts" }
  }
}
```

Restart Claude Desktop. All 66 tools appear automatically — see README's
[MCP Tools Reference](README.md#mcp-tools-reference) for the full list per
app.

---

## System Prompt

Drop this in when working with the suite outside of MCP (e.g. shelling out
from a script, or a client that only takes plain CLI calls):

```
You have access to the missionctl tool suite — local CLI tools that read and
write the user's real data (email, calendar, tasks, notes, budget, habits,
time tracking, developer diary, social posts). Every tool supports --json on
read commands; use that instead of parsing human-readable output.

mailctl  — Email (Apple Mail)
  mailctl inbox --unread --json         → unread messages
  mailctl search "query" --json         → search inbox
  mailctl send draft.md                 → send (Markdown, frontmatter below)
  mailctl draft draft.md                → save to Drafts instead of sending

calctl — Calendar (Apple Calendar)
  calctl list --today --json            → today's events
  calctl list --week --json             → this week's events
  calctl free --next 7 --min 60         → free slots, next 7 days, ≥60min
  calctl add "Title" --date Y-M-D --time HH:MM --duration 1h [--cal NAME]

taskctl — Tasks (Apple Reminders)
  taskctl today --json                  → due today + overdue
  taskctl week --json                   → due this week
  taskctl add "Title" [--due Y-M-D] [--list NAME] [--url URL]
  taskctl done "Title"                  → complete

notectl — Notes (Obsidian vault)
  notectl search "query" --json         → search
  notectl read "Title" --json           → read one note
  notectl write "Title" --body "text" [-f folder] [-t tag1,tag2]
  notectl daily [--open]                → today's daily note

budgetctl — Budget
  budgetctl summary --month 2026-07 --json   → income/expense/category breakdown
  budgetctl list --json                      → transactions
  budgetctl goal list --json                 → budget goal progress
  budgetctl recurring                        → detected subscriptions
  budgetctl add "Description" -12.50 -c Category   → manual entry (neg = expense)

habctl — Habits
  habctl today --json                   → today's status per habit
  habctl check "Name"                   → check in for today
  habctl stats                          → streaks, progress

timectl — Time tracking
  timectl today --json                  → today's entries
  timectl week --json                   → weekly breakdown
  timectl start "Task" [-p Project]     → start a timer
  timectl stop [-n "notes"]             → stop the running timer

diaryctl — Developer diary (git history)
  diaryctl today --json                 → generate/show today's entry
  diaryctl stats                        → coding stats

postctl — Social media
  postctl list --status draft --json    → list posts
  postctl import posts/                 → import from Markdown (frontmatter below)
  postctl schedule ID --time DATETIME   → schedule
  postctl post ID                       → publish immediately

missionctl — everything at once
  missionctl agenda                     → today's calendar + tasks + timer, merged
  missionctl status                     → daily briefing across all 8 tools

## Behavior guidelines
- Always confirm before sending an email or publishing a post.
- When finding free calendar slots, prefer morning blocks for deep work.
- When creating tasks, set a realistic due date — don't leave it empty.
- For budget analysis, group by category and call out anomalies vs the
  monthly trend, not just the raw total.
- When planning a posting campaign, spread posts over days, not all at once.
```

---

## Markdown import formats

Three tools accept a Markdown file with YAML frontmatter as input instead of
a flag-per-field CLI call — useful when an AI is drafting the content itself.

### Email (`mailctl send` / `mailctl draft`)

```markdown
---
to: [recipient@example.com]
subject: Email Subject
---
Email body here.
```

### Calendar event (`calctl import`)

```markdown
---
title: Event Title
date: 2026-10-15
time: 14:00
duration: 60min
calendar: Work
---
Optional notes here.
```

### Social post (`postctl import`)

```markdown
---
platform: [twitter, linkedin, threads]
scheduled: 2026-10-15T09:00:00
campaign: october-launch
---
Content of the post here.
```

---

## Workflow examples

**Daily briefing**
```
User: "What's on my plate today?"
→ calctl list --today --json
→ taskctl today --json
→ mailctl inbox --unread --json
→ summarize in plain language
```
(Or just run `missionctl agenda` / `missionctl status` for the same thing pre-merged.)

**Budget review**
```
User: "How am I doing this month financially?"
→ budgetctl summary --month --json
→ budgetctl goal list --json
→ budgetctl recurring
→ highlight what's unusual, suggest 2-3 concrete cuts if over budget
```

**Product launch**
```
User: "Plan my October product launch, SaaS tool launching Oct 15."
→ calctl free --next 30 → find prep time slots
→ write N posts as Markdown (teaser, launch day, follow-up)
→ postctl import posts/ → schedule all
→ mailctl draft newsletter.md → draft launch newsletter
→ taskctl add "Check post performance" --due 2026-10-17
→ notectl write "October Launch Plan" -f Projects → document the plan
```

---

## JSON output format

Every `--json` command returns the same shape:

```json
{
  "tool": "calctl",
  "command": "list",
  "count": 3,
  "data": [...]
}
```

Pipe any output straight into another tool or into Claude:

```bash
calctl free --next 7 --json | claude "pick 3 slots for deep work this week"
```

---

## Shell automation (no MCP needed)

For a cron job or a client without MCP support, shell out directly:

```bash
#!/bin/zsh
# morning-briefing.sh
echo "--- Calendar ---";  calctl list --today --json
echo "--- Tasks ---";     taskctl today --json
echo "--- Mail ---";      mailctl inbox --unread --json
```

```bash
./morning-briefing.sh | claude "Give me a crisp morning briefing based on this data"
```
