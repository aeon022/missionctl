# notectl — Notes from Terminal

Write and read notes in your Obsidian vault (and Apple Notes).
AI writes the notes, you find them where you always look.

```bash
notectl write "Meeting Notes" < content.md   # Write note to vault
notectl read "Meeting Notes" --json          # Read note
notectl search "keyword" --json              # Full-text search
notectl list --json                          # List all notes
notectl mcp                                  # Run as MCP server
```

## Config

```yaml
# ~/.config/notectl/config.yaml
vault_path: ~/Documents/Obsidian/MyVault
default_folder: AI Notes
template: daily
```

## Status

Planned — see [ROADMAP.md](../ROADMAP.md) for timeline.
Tech stack: Go, Cobra, fs/filepath, Apple Notes via AppleScript
