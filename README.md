# missionctl

> Mission Control for your digital life.

missionctl is a suite of small, focused CLI/TUI tools for macOS power users.
Each tool does one thing well, stores data locally, and exposes a clean interface
that AI agents can call directly — no SaaS, no subscriptions, no cloud lock-in.

---

## The Idea

AI is great at planning. It's bad at *doing* — because it has no hands.
missionctl gives AI hands.

```
"Plan my October product launch"
  → calctl finds free slots
  → postctl writes and schedules 20 posts
  → mailctl drafts the newsletter
  → notectl documents the plan
  → taskctl creates follow-up reminders
```

Every tool follows the same pattern:
```
AI writes Markdown → tool imports → tool executes
```

---

## Tools

| Tool       | What it does                              | Status    |
|------------|-------------------------------------------|-----------|
| postctl    | Schedule social media posts from Markdown | Existing  |
| calctl     | Read/write Apple & Google Calendar        | Planned   |
| mailctl    | Send and read email from Markdown         | Planned   |
| budgetctl  | Track budget from bank CSV exports        | Planned   |
| notectl    | Write/read Obsidian & Apple Notes         | Planned   |
| taskctl    | Sync tasks across Apple/Google/Microsoft  | Planned   |

---

## Principles

- **Local-first**: All data in SQLite on your machine
- **Markdown-in**: AI writes Markdown, tools parse it
- **JSON-out**: All read commands return JSON for AI consumption
- **MCP-ready**: Every tool exposes an MCP server for direct AI tool use
- **No SaaS**: No accounts, no subscriptions, no cloud dependency

---

## MCP Integration

Each tool runs as an MCP server. Add to your Claude config:

```json
{
  "mcpServers": {
    "postctl":   { "command": "postctl",   "args": ["mcp"] },
    "calctl":    { "command": "calctl",    "args": ["mcp"] },
    "mailctl":   { "command": "mailctl",   "args": ["mcp"] },
    "budgetctl": { "command": "budgetctl", "args": ["mcp"] },
    "notectl":   { "command": "notectl",   "args": ["mcp"] },
    "taskctl":   { "command": "taskctl",   "args": ["mcp"] }
  }
}
```

---

## Distribution

Available on [polar.sh](https://polar.sh) — one-time purchase, no subscription.

- Individual tools: $9 each
- Full bundle: $39 (all current + future tools)
- Go Tutorial: $19 (learn Go by building these tools)

---

## Tech Stack

- Language: Go 1.23+
- TUI: [Bubble Tea](https://github.com/charmbracelet/bubbletea)
- CLI: [Cobra](https://github.com/spf13/cobra)
- Storage: SQLite via `modernc.org/sqlite` (no CGo)
- Styling: [Lip Gloss](https://github.com/charmbracelet/lipgloss)
- MCP: `github.com/mark3labs/mcp-go`
