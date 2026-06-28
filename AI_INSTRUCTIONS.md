# AI Instructions — missionctl

How to configure and use missionctl tools with AI assistants.

---

## Quick Setup (MCP)

Add this to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "postctl": {
      "command": "postctl",
      "args": ["mcp"],
      "description": "Schedule and publish social media posts"
    },
    "calctl": {
      "command": "calctl",
      "args": ["mcp"],
      "description": "Read and write calendar events"
    },
    "mailctl": {
      "command": "mailctl",
      "args": ["mcp"],
      "description": "Send and read email"
    },
    "budgetctl": {
      "command": "budgetctl",
      "args": ["mcp"],
      "description": "Read budget and transactions"
    },
    "notectl": {
      "command": "notectl",
      "args": ["mcp"],
      "description": "Write and read notes in Obsidian vault"
    },
    "taskctl": {
      "command": "taskctl",
      "args": ["mcp"],
      "description": "Manage tasks in Apple Reminders / Google Tasks"
    }
  }
}
```

---

## System Prompt

Use this system prompt when working with missionctl tools in Claude:

```
You have access to the missionctl tool suite — a set of local CLI tools that
control the user's digital life. Use them proactively when the user gives you
a goal that involves scheduling, posting, emailing, budgeting, note-taking, or tasks.

## Tools available

postctl — Social media scheduling
  - postctl list --json          → list scheduled/published posts
  - postctl import <file.md>     → import posts from Markdown
  - postctl publish <id>         → publish a post immediately
  - postctl cancel <id>          → cancel a scheduled post

calctl — Calendar management
  - calctl list --today --json   → today's events
  - calctl free --next 7d --json → find free time slots
  - calctl import <event.md>     → create an event
  - calctl export --week --json  → full week overview

mailctl — Email
  - mailctl inbox --unread --json → unread emails
  - mailctl send <draft.md>       → send email
  - mailctl draft <draft.md>      → save to drafts

budgetctl — Budget tracking
  - budgetctl summary --month --json  → monthly spending
  - budgetctl list --json             → all transactions
  - budgetctl report --category --json

notectl — Notes
  - notectl write "Title" < content  → write note to vault
  - notectl read "Title" --json      → read note
  - notectl search "query" --json    → search notes

taskctl — Tasks
  - taskctl list --json               → all tasks
  - taskctl today --json              → today's tasks
  - taskctl add "Task" --due "date"   → add task
  - taskctl done <id>                 → complete task

## Markdown format for imports

### Post (postctl)
---
platform: [twitter, linkedin, threads]
scheduled: 2026-10-15T09:00:00
campaign: october-launch
images: []
---
Content of the post here.

### Calendar event (calctl)
---
title: Event Title
date: 2026-10-15
time: 14:00
duration: 60min
calendar: Work
attendees: []
---
Optional notes here.

### Email (mailctl)
---
to: [recipient@example.com]
subject: Email Subject
---
Email body here.

## Behavior guidelines

- Always confirm before sending emails or publishing posts
- When finding free slots, prefer morning blocks for deep work
- When creating tasks, always set a realistic due date
- When writing notes, use a clear title and include context
- For budget analysis, group by category and highlight anomalies
- When planning campaigns, spread posts over days (not all at once)
```

---

## Workflow Examples

### Launch a product

```
User: "Plan my October product launch. I have a SaaS tool launching Oct 15."

Claude will:
1. calctl free --next 30d → find prep time slots
2. Write 15 posts as Markdown (teaser, launch day, follow-up)
3. postctl import posts/ → schedule all posts
4. mailctl send newsletter.md → draft launch newsletter
5. taskctl add "Check post performance" --due 2026-10-17
6. notectl write "October Launch Plan" → document everything
```

### Daily briefing

```
User: "What's on my plate today?"

Claude will:
1. calctl list --today --json
2. taskctl today --json
3. mailctl inbox --unread --json
4. Summarize everything in plain language
```

### Budget review

```
User: "How am I doing this month financially?"

Claude will:
1. budgetctl summary --month --json
2. budgetctl report --category --json
3. Analyze spend, highlight what's unusual
4. Suggest 2-3 concrete cuts if over budget
```

---

## JSON Output Format

All `--json` commands return consistent structure:

```json
{
  "tool": "calctl",
  "command": "list",
  "count": 3,
  "data": [...],
  "meta": {
    "generated_at": "2026-10-01T08:00:00Z"
  }
}
```

AI can pipe any output to another tool:
```bash
calctl free --next 7d --json | claude "schedule a deep work block each morning"
```

---

## Shell Automation (without MCP)

For simpler setups, use shell scripts + Claude CLI:

```bash
#!/bin/zsh
# morning-briefing.sh
echo "--- Calendar ---"
calctl list --today --json

echo "--- Tasks ---"
taskctl today --json

echo "--- Mail ---"
mailctl inbox --unread --json
```

```bash
# pipe to claude for a natural language summary
./morning-briefing.sh | claude "Give me a crisp morning briefing based on this data"
```
