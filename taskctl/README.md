# taskctl — Tasks from Terminal

Manage tasks across Apple Reminders, Google Tasks, and Microsoft To Do.
Go rewrite of the utask Python prototype — single binary, faster, MCP-ready.

```bash
taskctl list --json                          # All tasks
taskctl today --json                         # Today's tasks for daily briefing
taskctl add "Call dentist" --due 2026-10-15  # Add task
taskctl done <id>                            # Complete task
taskctl sync                                 # Sync all providers
taskctl mcp                                  # Run as MCP server
```

## Config

```yaml
# ~/.config/taskctl/config.yaml
providers:
  - name: apple-reminders
    list: Personal
  - name: google-tasks
    list: Work
default_provider: apple-reminders
```

## Relationship to utask

`utask` (Python) in `/Projects/TaskSync` is the prototype.
`taskctl` is the clean Go rewrite — same concept, better architecture.

## Status

Planned — see [ROADMAP.md](../ROADMAP.md) for timeline.
Tech stack: Go, Cobra, EventKit (Apple Reminders), Google Tasks API, Microsoft Graph API
