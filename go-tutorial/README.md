# Build CLI/TUI Tools in Go — The missionctl Way

**Learn Go by building real, sellable tools.**

This tutorial teaches Go from zero by building the exact tools in the missionctl suite.
No toy examples. No "hello world" that goes nowhere. Every chapter ships something real.

---

## Who this is for

- Developers who know another language (Python, JS, Swift) and want to learn Go
- Builders who want to create local-first CLI/TUI tools
- Anyone who wants to sell small developer tools as indie products

---

## What you'll build

By the end of this tutorial you'll have built a working, shippable CLI tool that:
- Reads and writes local files
- Stores data in SQLite
- Has a terminal UI with keyboard navigation
- Exposes an MCP server (usable directly by Claude)
- Can be distributed as a single binary

---

## Chapters

### Chapter 1 — Why Go for CLI Tools
- Go vs. Python/Node for CLI: single binary, fast startup, easy distribution
- Go toolchain setup: `brew install go`, VS Code + gopls
- `go mod init`, `go run`, `go build`
- Your first program: `hello, missionctl`

### Chapter 2 — Go Basics (the parts you actually need)
- Types: `string`, `int`, `bool`, slices, maps
- Functions and multiple return values
- Structs and methods
- Error handling: `if err != nil` and why it's good
- Packages and imports
- Interfaces (just enough)

### Chapter 3 — Your First CLI with Cobra
- What is Cobra and why everyone uses it
- Root command + subcommands
- Flags: `--json`, `--date`, `--output`
- Reading from stdin and files
- Building and running: `go build -o myctl`

*Exercise: build a `myctl` that reads a Markdown file and prints its frontmatter*

### Chapter 4 — Parsing Markdown & Frontmatter
- Reading files with `os.ReadFile`
- Parsing YAML frontmatter with `gopkg.in/yaml.v3`
- Structs as schemas: map frontmatter fields to Go types
- Validating input (character limits, date formats)
- Writing Markdown files

*Exercise: import a post.md and validate it for Twitter's 280-char limit*

### Chapter 5 — SQLite: Local Storage Without a Server
- Why SQLite for CLI tools
- `modernc.org/sqlite` — pure Go, no CGo, single binary
- Creating tables, inserting rows, querying
- Migrations: keeping your schema up to date
- CRUD operations for your tool's data model

*Exercise: store imported posts in a local `myctl.db` with status tracking*

### Chapter 6 — JSON Output for AI
- `encoding/json` — marshaling structs to JSON
- Consistent output format: `{"tool": "...", "data": [...], "count": N}`
- Pretty-print vs. compact output
- Reading JSON input (for AI-to-tool pipelines)
- Piping: `myctl list --json | jq '.data[0].title'`

*Exercise: add `--json` flag to all commands in your tool*

### Chapter 7 — Terminal UI with Bubble Tea
- The Elm architecture: Model, Update, View
- Your first Bubble Tea program: a list of items
- Keyboard navigation: arrow keys, enter, escape, q
- Styling with Lip Gloss: colors, borders, padding
- Tables, spinners, text inputs

*Exercise: build a TUI list view for your posts with keyboard navigation*

### Chapter 8 — Calling External APIs
- `net/http` — making GET and POST requests
- Setting headers, reading response bodies
- Parsing JSON responses into structs
- OAuth2 flow: storing tokens securely in macOS Keychain
- Error handling for network calls

*Exercise: fetch your calendar events from a real API*

### Chapter 9 — MCP Server in Go
- What is MCP (Model Context Protocol) and why it matters
- `github.com/mark3labs/mcp-go` library
- Defining tools: name, description, parameters
- Handling tool calls: parse args, execute, return result
- Running as `myctl mcp` — stdio transport
- Testing with Claude Desktop

*Exercise: expose your tool's `list` and `add` commands as MCP tools*

### Chapter 10 — Packaging & Distribution
- Cross-compilation: `GOOS=darwin GOARCH=arm64 go build`
- Single binary: embedding assets with `//go:embed`
- Homebrew tap: create a formula for your tool
- License key check: simple HTTP validation on activation
- GitHub Actions: build + release on tag push
- polar.sh: create a product and link the binary

*Exercise: release v0.1 of your tool with a Homebrew formula*

---

## Prerequisites

- Basic programming knowledge in any language
- macOS (some chapters use macOS-specific APIs)
- Go 1.23+ installed
- VS Code with the Go extension

---

## Code Repository

Each chapter has a complete, working example in `go-tutorial/chapterN/`.
You can run any chapter standalone:

```bash
cd go-tutorial/chapter03
go run main.go --help
```

---

## Buy the full tutorial

Available on [polar.sh](https://polar.sh) for $19 — includes PDF, all code examples,
and future chapter updates.

Buying the missionctl Bundle ($39) includes the tutorial.
