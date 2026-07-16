# missionctl

Terminal tools for people who want AI to actually do things, not just talk about them.

missionctl is a suite of nine focused CLI/TUI tools for macOS. Each manages one domain — email, calendar, tasks, notes, budget, habits, time tracking, developer diary, social media — stores everything locally in SQLite, and exposes a clean MCP server so AI agents can read and write your real data.

No SaaS. No cloud. No subscriptions. Your data stays on your machine.

---

## The Suite

| Tool | What it does | MCP tools | Data source |
|------|-------------|-----------|-------------|
| [mailctl](mailctl/) | Read inbox, compose and send email | 6 | Apple Mail (AppleScript) |
| [calctl](calctl/) | Browse calendar, create events, find free slots | 7 | Apple Calendar (AppleScript) |
| [taskctl](taskctl/) | Manage tasks, sync with Apple Reminders | 7 | Apple Reminders (EventKit) |
| [notectl](notectl/) | Read and write Obsidian vault notes, daily notes | 7 | Obsidian vault (.md files) |
| [budgetctl](budgetctl/) | Track income & expenses, import bank CSVs, goals, subscriptions | 11 | Manual entries + bank CSV |
| [habctl](habctl/) | Track habits, streaks, AI coaching reviews | 12 | Local SQLite |
| [timectl](timectl/) | Start/stop timers, weekly breakdown, invoice export | 4 | Local SQLite |
| [diaryctl](diaryctl/) | Developer diary from git history, AI-written narrative | 5 | git repos + suite DBs |
| [postctl](https://github.com/aeon022/postctl) | Schedule and publish social media posts | 7 | Local SQLite + platform APIs |

Plus [missionctl](missionctl/), the umbrella CLI: `missionctl doctor` (installation check), `missionctl status` (daily briefing across all tool databases), `missionctl init` (setup wizard).

All tools share the same design: a Bubbletea TUI as the default command, a Cobra CLI for scripting, JSON output on every read command, and an MCP server over stdio for AI integration.

---

## Quick Start

### Install all tools

Each tool is a standalone Go binary with no runtime dependencies.

```bash
for repo in mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl; do
  git clone https://github.com/aeon022/$repo && cd $repo && ./setup.sh && cd ..
done
```

`setup.sh` builds the binary and installs it to `~/.local/bin/`. Make sure that directory is on your `$PATH`.

### Initial sync

Pull your existing data into the local SQLite caches:

```bash
mailctl sync        # inbox from Apple Mail
calctl sync         # events from Apple Calendar
taskctl sync        # tasks from Apple Reminders
notectl sync        # index your Obsidian vault
```

budgetctl needs no sync — add entries manually (`budgetctl add` or `n` in the TUI) or import a CSV export with `budgetctl import bank.csv`. postctl is self-contained.

### Wire up Claude Desktop

Add all nine servers to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mailctl":   { "command": "mailctl",   "args": ["mcp"] },
    "calctl":    { "command": "calctl",    "args": ["mcp"] },
    "taskctl":   { "command": "taskctl",   "args": ["mcp"] },
    "notectl":   { "command": "notectl",   "args": ["mcp"] },
    "budgetctl": { "command": "budgetctl", "args": ["mcp"] },
    "habctl":    { "command": "habctl",    "args": ["mcp"] },
    "timectl":   { "command": "timectl",   "args": ["mcp"] },
    "diaryctl":  { "command": "diaryctl",  "args": ["mcp"] },
    "postctl":   { "command": "postctl",   "args": ["mcp"] }
  }
}
```

Restart Claude Desktop. All 66 tools appear automatically.

---

## Cheatsheet

```
# Email
mailctl                                       Open TUI
mailctl sync                                  Sync inbox from Apple Mail
mailctl inbox [--unread] [--json]             List messages
mailctl send draft.md                         Send from Markdown file
mailctl search QUERY [--json]                 Search inbox

# Calendar
calctl                                        Open TUI
calctl sync [--days N]                        Sync from Apple Calendar
calctl list [--today] [--week] [--json]       List events
calctl add TITLE --start DT --end DT          Create event
calctl free [--from D] [--to D]               Find free slots

# Tasks
taskctl                                       Open TUI
taskctl sync                                  Sync from Apple Reminders
taskctl today [--json]                        Tasks due today + overdue
taskctl week  [--json]                        Tasks due this week
taskctl add TITLE [--due DATE] [--list NAME]  Create task
taskctl done TITLE                            Complete task
taskctl daemon --install                      Install background sync daemon

# Notes
notectl                                       Open TUI
notectl sync                                  Index Obsidian vault
notectl daily [--open]                        Open/create today's note
notectl write TITLE [--body TEXT] [-f FOLDER] Create or update a note
notectl read  TITLE [--json]                  Read a note
notectl search QUERY [--json]                 Search notes

# Budget
budgetctl                                     Open TUI
budgetctl add DESC AMOUNT [-c CAT]            Add manual entry (neg = expense)
budgetctl import FILE [--account NAME]        Import bank CSV
budgetctl summary [--month 2026-07] [--json]  Monthly summary
budgetctl tag PATTERN --category NAME [--apply]  Create category rule
budgetctl goal set CATEGORY AMOUNT            Set monthly budget goal
budgetctl goal list [--month 2026-07]         Show goal progress
budgetctl recurring                           Detect recurring payments
budgetctl export [--year 2026] [-o FILE]      Export to CSV/JSON

# Habits
habctl                                        Open TUI
habctl add NAME [--desc TEXT]                 Add a habit
habctl check NAME                             Check in for today
habctl today                                  Today's status
habctl stats                                  Streaks & progress bars
habctl review                                 AI weekly coaching review

# Time
timectl                                       Open TUI
timectl start TASK [-p PROJECT]               Start a timer
timectl stop [-n NOTES]                       Stop running timer
timectl today [--json]                        Today's entries
timectl week [--json]                         Weekly breakdown
timectl invoice [-p PROJECT]                  Invoice export

# Diary
diaryctl                                      Open TUI (heatmap + editor)
diaryctl init PATH --name NAME                Register a git repo
diaryctl today                                Generate today's entry
diaryctl daemon start                         Auto-write daily at 17:30
diaryctl stats                                Coding stats

# Social
postctl                                       Open TUI
postctl list [--status draft] [--json]        List posts
postctl post ID [--dry-run]                   Publish immediately
postctl schedule ID --time DATETIME           Schedule a post
postctl campaign list                         List campaigns
postctl import FILE.md                        Import from Markdown
```

---

## MCP Tools Reference

66 tools across all nine apps, available to Claude once all servers are configured.

### mailctl (6)

| Tool | Description |
|------|-------------|
| `inbox` | List recent inbox messages with sender, subject, preview |
| `search_email` | Search by keyword across subject, sender, body |
| `email_thread` | Get all messages in a thread matched by subject |
| `send_email` | Send an email via Apple Mail |
| `draft_email` | Save a composed message to Apple Mail Drafts |
| `sync_inbox` | Sync from Apple Mail into local cache |

### calctl (7)

| Tool | Description |
|------|-------------|
| `list_events` | List events between two dates |
| `today` | Today's events |
| `this_week` | This week's events (Monday to Sunday) |
| `sync` | Sync from Apple Calendar |
| `find_free_slots` | Find free time within working hours |
| `create_event` | Create a calendar event |
| `delete_event` | Delete an event by title and date |

### taskctl (7)

| Tool | Description |
|------|-------------|
| `today_tasks` | Tasks due today or overdue |
| `week_tasks` | Tasks due this week |
| `list_tasks` | List tasks, filter by list or status |
| `sync` | Sync from Apple Reminders |
| `create_task` | Create task with title, list, due date, notes |
| `complete_task` | Mark a task completed |
| `delete_task` | Delete a task |

### notectl (7)

| Tool | Description |
|------|-------------|
| `list_notes` | List notes from cache (filter: folder, source) |
| `read_note` | Read full note content by title |
| `write_note` | Create or update a note in the vault |
| `search_notes` | Keyword search across title and content |
| `sync_notes` | Sync Obsidian vault into cache |
| `get_daily_note` | Get today's daily note (creates from template if missing) |
| `append_daily_note` | Append content under a named section |

### budgetctl (11)

| Tool | Description |
|------|-------------|
| `list_transactions` | List transactions, filter by month/category/query |
| `add_transaction` | Add a manual income/expense entry |
| `delete_transaction` | Delete a transaction by ID |
| `budget_summary` | Monthly income/expenses/net with category breakdown |
| `import_transactions` | Import from a bank CSV file |
| `tag_transactions` | Create a category rule (pattern → category) |
| `apply_category_rules` | Re-apply all rules to all transactions |
| `list_budget_goals` | Goals with current-month spending progress |
| `set_budget_goal` | Set a monthly spending limit for a category |
| `delete_budget_goal` | Remove a goal |
| `detect_recurring_payments` | Detect subscriptions and recurring charges |

### habctl (12)

| Tool | Description |
|------|-------------|
| `list_habits` | All habits with today's status and streaks |
| `check_habit` | Check in a habit for today |
| `uncheck_habit` | Undo a check-in |
| `add_habit` | Create a new habit |
| `delete_habit` | Delete a habit and its history |
| `get_habit_stats` | Streaks, completion rate, last-7-days for one habit |
| `streak_at_risk` | Habits whose streak breaks if not checked today |
| `get_weekly_summary` | Check-ins per habit for the current week |
| `get_weekly_review` | Data briefing for AI coaching review |
| `suggest_habits` | AI-powered habit suggestions |
| `add_checkin_note` | Attach a note to today's check-in |
| `list_chains` | Habit chains (habit → follow-up habit) |

### timectl (4)

| Tool | Description |
|------|-------------|
| `start_timer` | Start a timer (errors if one is running) |
| `stop_timer` | Stop the running timer |
| `get_time_log` | Entries for a date, optionally by project |
| `get_time_stats` | Aggregated statistics over the last N days |

### diaryctl (5)

| Tool | Description |
|------|-------------|
| `get_today_stats` | Today's git commit stats across registered repos |
| `get_diary_entry` | Diary entry body for a date |
| `write_diary_entry` | Save or overwrite an entry |
| `get_coding_stats` | Aggregate coding stats for the last N days |
| `list_diary_entries` | List entries with date and preview |

### postctl (7)

| Tool | Description |
|------|-------------|
| `list_posts` | List posts, filter by platform/status/campaign |
| `get_post` | Get a single post by ID with full content |
| `create_post` | Create a draft or scheduled post |
| `publish_post` | Publish a post immediately |
| `schedule_post` | Update a post's scheduled time |
| `list_campaigns` | List campaigns with post counts and status breakdown |
| `get_campaign` | Get all posts in a campaign with full content |

---

## AI Workflows

Things you can ask Claude once all nine MCP servers are connected.

**Morning briefing**

> "Summarize my unread emails, today's calendar, and tasks due today. Flag anything urgent."

`sync_inbox` → `inbox` → `today` → `today_tasks` → summary across all three.

---

**Weekly planning**

> "Review my tasks for this week, find gaps in my calendar, and suggest which tasks to slot in where."

`week_tasks` → `this_week` → `find_free_slots` → proposed schedule → optionally `create_event` per task.

---

**Meeting capture**

> "I just had a product meeting. Here are my notes: [paste]. Create tasks for all action items, write a meeting note to my vault, and draft the follow-up email."

`create_task` × N → `write_note` → `draft_email`.

---

**Launch campaign**

> "Plan a two-week Twitter campaign for our product launch on July 15. Write 10 posts and schedule them across the two weeks."

`create_post` × 10 → `schedule_post` × 10.

---

**Monthly financial review**

> "Break down last month's spending by category, compare to my budget goals, and list any subscriptions worth cancelling."

`budget_summary` → `list_budget_goals` → `detect_recurring_payments` → summary.

---

**Inbox zero**

> "Go through my unread emails. For each one, draft a reply, create a follow-up task, or flag it as safe to delete."

`inbox` → `email_thread` per message → `draft_email` or `create_task` per message.

---

**End of day**

> "Which of my streaks are at risk? Check in what I told you I did, stop my timer, and write today's diary entry."

`streak_at_risk` → `check_habit` × N → `stop_timer` → `get_today_stats` → `write_diary_entry`.

---

## Design Principles

**Local-first.** All data lives in SQLite on your machine. Nothing is sent to external servers except when you explicitly publish (postctl) or send (mailctl).

**Markdown in, JSON out.** AI writes Markdown; tools parse and execute it. Every read command returns JSON so AI can process the output directly.

**One binary per tool.** Each tool compiles to a single static Go binary with no runtime dependencies — no Docker, no Node, no Python. Copy it anywhere and it works.

**MCP-native.** Every tool implements the Model Context Protocol over stdio. Plug into Claude Desktop, any MCP-compatible client, or your own pipelines.

**Consistent UX.** All TUIs share the same color palette, key conventions (`j/k` navigate, `/` search, `s` sync, `d` delete, `q` quit), and helpbar layout. Learn one, know all nine.

---

## Tech Stack

| Component | Library |
|-----------|---------|
| Language | Go 1.21+ |
| TUI | [Bubble Tea](https://github.com/charmbracelet/bubbletea) |
| CLI | [Cobra](https://github.com/spf13/cobra) |
| Styling | [Lip Gloss](https://github.com/charmbracelet/lipgloss) |
| Storage | SQLite via `modernc.org/sqlite` (pure Go, no CGo) |
| MCP | `github.com/mark3labs/mcp-go` |
| macOS bridge | AppleScript + Swift EventKit |

**Requirements:** macOS for mailctl, calctl, taskctl (AppleScript/EventKit) and the notification/daemon features of habctl and diaryctl. notectl, budgetctl, timectl also work on Linux.

---

## Architecture

```
Apple Mail / Calendar / Reminders
        │ AppleScript / EventKit
        ▼
   Local SQLite cache  ◄──── bank CSV (budgetctl)
        │                    Obsidian vault (notectl)
   ┌────┴──────────┐         Markdown files (postctl)
   │               │
  TUI           MCP server (stdio)
(Bubble Tea)        │
                    ▼
             Claude Desktop /
             any MCP client
```

Each tool maintains its own SQLite database. The TUI and MCP server share the same file via WAL mode — both can run simultaneously without conflicts.
