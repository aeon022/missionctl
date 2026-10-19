# Show HN (Entwurf)

**Titel (max. 80 Zeichen), Varianten:**
1. `Show HN: postctl – schedule social posts from Markdown, in the terminal`
2. `Show HN: postctl – a terminal social media scheduler with an MCP server`

**URL:** https://postctl.sh (alternativ https://github.com/aeon022/postctl)

**Erster Kommentar (selbst posten):**

Hi HN, I'm Gerwin. I built postctl because I run social media for a small non-profit and got tired of web dashboards for what is really a queue of text files.

What it is: a Go CLI/TUI. You write posts as Markdown with a bit of frontmatter, import them, and a scheduler service publishes at the right time to Instagram, Facebook, Threads, X, LinkedIn, Bluesky and Mastodon. Data stays in a local SQLite file; there are several profiles (we use one per organisation), a calendar view in the TUI, and a safety layer against account bans (rate limits per platform, minimum gaps between posts).

It also ships an MCP server so an AI assistant can draft and schedule posts. One decision I'd like feedback on: publishing and scheduling through MCP is **off by default** and needs an explicit environment variable, because an agent that reads untrusted text (mail, web pages) could be talked into posting. Without the opt-in it saves drafts only.

Pricing, since it comes up: the core is MIT and free for up to two connected networks. Pro (more networks, updates, API upkeep) is €4.90/month or €39/year. I know subscriptions for a CLI tool are a tradeoff; the reason is that platform APIs break regularly and keeping up is the actual work. Existing lifetime and bundle licences stay valid.

What I'd love to hear: what is missing for your workflow, and how you would handle the "agent reads untrusted input" problem.

Repo: https://github.com/aeon022/postctl · Docs: https://postctl.sh/docs

**Antwortbausteine:**
- *Why not Buffer/Hootsuite?* — They are great if you want a team web app. This is for people who already live in a terminal, want files in git, and want an assistant to be able to draft without a browser session.
- *Is it open source?* — Core is MIT. Pro features are gated by a licence key checked daily against Polar (offline grace period 21 days).
- *Does it scrape?* — Official APIs for all platforms; X also has an opt-in cookie mode, off by default, because X's API is expensive. State that plainly and don't oversell it.
- *Security of tokens?* — Tokens are encrypted at rest with a key file (0600); logs redact secrets. Nothing is sent to our servers except the daily licence check for Pro users.
