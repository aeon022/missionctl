# Differentiation Strategy — what nobody else can build

---

## Why this list exists

Feature parity with Notion/Todoist/Superhuman-style SaaS is a losing game — they have
more engineers and a web/mobile surface we don't. The moat isn't "more features," it's
the handful of things that are structurally impossible for a cloud-SaaS competitor to
copy, because copying them would break their business model (subscriptions, hosted
sync, telemetry, lock-in). Every idea below is chosen for that property: a competitor
reading this list can't just ship the same thing next sprint.

---

## 1. AI trust ledger

A searchable log of every action Claude (or any MCP client) has taken on your behalf,
across all 9 tools, with one-command rollback per entry. Not generic undo — this is
specifically accountability for autonomous AI action, which almost nothing needs
because almost nothing is AI-first enough at the protocol level to require it.

## 2. Real 100%-offline AI

habctl already supports Ollama alongside Claude/GPT/Gemini for its weekly review.
Extend that to *every* AI touchpoint in all 9 tools, so "local-first, no cloud" is true
for the AI features too, not just the data. No cloud SaaS can claim this — their AI
features are cloud API calls by construction.

## 3. Review queue instead of blind execution

AI stages proposed actions (categorized transactions, drafted replies, scheduled
posts) into a queue. The TUI lets you flip through and approve/reject per-item with a
single keystroke, batch-style — code review for life admin, instead of "AI just does
it and hopes you notice."

## 4. Git-versionable personal data

diaryctl already reads your git history. Flip it around: habit/task/note state as
diffable Markdown/YAML instead of an opaque SQLite blob, so `git log`, branching, and
syncing via your own remote become literal options — no proprietary sync service to
trust or pay for.

## 5. Unix pipes between tools

`taskctl today --json | budgetctl correlate` — real composability for power users who
want automation without an AI in the loop. Monolithic cloud apps have no CLI and can't
retrofit one without a rewrite; we get this for free from being terminal-native.

## 6. Peer-to-peer sync, no server

Multi-device (Mac + Linux box) over LAN or encrypted manual export, no cloud relay.
Every SaaS competitor's multi-device story requires their cloud — this is the one
place local-first tools usually cave, so doing it properly is a real differentiator.

## 7. Guaranteed painless exit

At any point, `<tool> export --all --format md` walks you out with 100% plain files,
no vendor format. SaaS makes exporting deliberately annoying because retention is the
business. Making leaving trivial is a confidence signal precisely because it costs the
business nothing to keep.

## 8. Automations you can code-review

Instead of opaque Zapier/IFTTT-style cloud rules: a shell script + cron/launchd entry
calling the tools' own CLI. `git diff` your automation history, put it in a PR, share
it as a gist. Automation as code, not automation as a black-box subscription feature.

## 9. First-class air-gapped mode

Explicitly document and test that the entire suite — including AI, via local Ollama —
works with zero network access. Nobody selling productivity SaaS can market to the
security-conscious/air-gapped crowd; this suite structurally can, if we commit to
testing it.

## 10. Data outlives the company

MIT-licensed, one-time purchase: if development ever stops, users keep full source +
local data forever. An explicit guarantee — "even if we disappear, you keep
everything, no subscription cutoff" — that a subscription business cannot make without
contradicting its own model.

## 11. Terminal-native "mission control" cockpit

tmux/zellij session templates laying out multiple tools in a fixed pane grid — leans
fully into "give your AI hands" without a browser tab ever entering the picture.
Cheap to build (just config), high signal for the terminal-power-user audience this
suite already targets.

## 12. Local-only behavioral correlation

"You complete 40% more habits on days you time-track >4h" — computed entirely on-device.
This is exactly the kind of insight normally reserved for surveillance-heavy SaaS
(RescueTime-style tools that phone everything home) — we can offer it specifically
*because* nothing leaves the machine.

---

## Suggested next step

Not all 12 are equally cheap. Rough triage:

- **Cheap, high-signal, ship soon:** #7 (export guarantee — mostly a marketing/docs
  claim backed by commands that likely already exist per-tool), #11 (tmux/zellij
  templates — pure config), #9 (air-gapped mode — mostly testing + a doc page)
- **Medium, real engineering:** #1 (trust ledger), #3 (review queue), #2 (Ollama
  everywhere), #12 (local correlation)
- **Bigger bets, needs its own design pass:** #4 (git-native data model — touches the
  storage layer of every tool), #6 (P2P sync), #5 (pipe-friendly JSON contracts across
  all 9 tools), #8 (automation-as-code — mostly a docs/examples effort once #5 exists)

None of this is scheduled — added to the UX/feature backlog (`project-ux-backlog`
memory) as a pointer to this document.
