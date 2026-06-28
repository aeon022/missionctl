# mailctl — Email from Terminal

Send and read email from Markdown files.
AI drafts, you approve, mailctl sends.

```bash
mailctl send draft.md               # Send email from Markdown
mailctl draft draft.md              # Save to Drafts
mailctl inbox --unread --json       # Read inbox for AI context
mailctl thread <id> --json          # Read a thread
mailctl mcp                         # Run as MCP server
```

## Email Markdown format

```markdown
---
to: [recipient@example.com]
cc: []
subject: October Newsletter
---

Hi there,

here's what's new...
```

## Status

Planned — see [ROADMAP.md](../ROADMAP.md) for timeline.
Tech stack: Go, Cobra, SMTP / Apple Mail AppleScript, Gmail OAuth2
