# postctl — Roadmap Audit
> Stand: 2026-07-21 (Retry-Standardisierung erledigt; Rest unverändert seit 2026-07-15)

---

## v1.0 — Polish & MCP (Q3 2026)

| Item | Status | Notiz |
|------|--------|-------|
| Twitter/X, LinkedIn, Threads | ✓ fertig | Alle 3 Plattformen vollständig implementiert |
| MCP-Server (`postctl mcp`) | ✓ fertig | 7 Tools: list, get, create, publish, schedule, campaign list/get |
| `postctl list --json` | ✓ fertig | FormatFlag, strukturierte JSON-Schemas |
| Error handling / Retry | ✓ fertig | Zentrales `platforms.WithRetry` (2026-07-21): exponential Backoff + Jitter, max. 3 Versuche, nur bei transienten Fehlern (Netzwerk, HTTP 429/5xx); 4xx schlägt sofort fehl. Einziger Call-Path für alle Publish-Aufrufe (`scheduler.PublishPost`), Threads' eigene Container-Indexing-Retry-Loop bleibt unverändert bestehen (anderes Problem, liegt darunter) |
| Brew formula / tap | ✗ fehlt | Keine .rb-Datei, kein Tap-Repo |

**Fazit v1.0:** Feature-complete. Einziger Blocker für Distribution: Brew tap.

---

## v1.1 — Campaigns (Q4 2026)

| Item | Status | Notiz |
|------|--------|-------|
| Campaign grouping (`postctl campaign`) | ✓ fertig | CRUD, Frontmatter `campaign:` Feld, `postctl campaign list/post` |
| Twitter Threads (Markdown → Thread) | ✓ fertig | `Post.Type == "thread"`, `---` Separator pro Tweet |
| Analytics (Likes, Shares, Impressions) | ~ partial | Struktur + SQLite vorhanden; API-Creds pro Plattform nötig |
| `postctl campaign plan --topic --days --json` | ✗ fehlt | Kein `plan`-Subcommand, kein AI-Hook |

**Fazit v1.1:** ~75% fertig. Fehlender AI-Planning-Hook ist die einzige größere Lücke.

---

## v2.0 — Team Mode (Q2 2027)

| Item | Status | Notiz |
|------|--------|-------|
| Bluesky + Mastodon | ✓ fertig | Ahead of schedule — beide voll implementiert (Auth, Post, Analytics) |
| Approval workflow (draft → review → scheduled) | ✗ fehlt | Post-Status: draft/scheduled/posted/failed — kein `review`-Step |
| Shared SQLite / iCloud Drive | ✗ fehlt | SQLite lokal unter `~/.local/share/postctl/` |

---

## Offene Punkte nach Priorität

1. **Brew formula / tap** — Blocker für öffentlichen Release
2. **`postctl campaign plan`** — AI-Planning-Hook für v1.1
3. **Approval workflow** — für v2.0 / Team-Nutzung

~~Retry-Standardisierung~~ — erledigt am 2026-07-21, siehe v1.0-Tabelle oben.
