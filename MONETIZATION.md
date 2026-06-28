# Monetization — polar.sh

---

## Why polar.sh

- One-time purchases (no forced subscriptions)
- Built-in license key system for CLI tools
- GitHub Sponsors integration
- Clean checkout, developer-friendly
- Low fees compared to alternatives
- Free tier for open-source + paid products side-by-side

---

## Products to create on polar.sh

### 1. Individual Tools ($9 each)

Create one product per tool. Each includes:
- Binary download (macOS arm64 + amd64)
- License key for activation
- Future updates included

Products:
- postctl — Social Media from Terminal
- calctl — Calendar from Terminal
- mailctl — Email from Terminal
- budgetctl — Budget from Terminal
- notectl — Notes from Terminal
- taskctl — Tasks from Terminal

### 2. missionctl Bundle ($39)

All 6 tools. One license key activates all.
Pitch: "Give your AI hands. One-time, runs locally, no subscriptions."

Include in bundle page:
- Short demo GIF of AI → postctl workflow
- List of all MCP tools
- Link to AI_INSTRUCTIONS.md as public doc

### 3. Go Tutorial ($19)

"Build CLI/TUI tools in Go — the missionctl way"

Standalone product, not tied to the bundle.
Pitch: "Learn Go by building the exact tools in this suite."

PDF + code examples + video walkthrough (optional later).

### 4. Tutorial + Bundle ($49)

Combo deal. $9 savings vs. buying separately.

---

## Launch Strategy

### Phase 1: postctl + calctl (Q4 2026)

1. Polish postctl, add MCP server
2. Ship calctl v0.5
3. Create polar.sh page for both + bundle (postctl + calctl for $19 bundle)
4. Post on HN "Show HN: I built postctl — schedule social posts from Markdown"
5. Post on Twitter/X developer communities

### Phase 2: Full Bundle (Q1 2027)

1. All 6 tools at v0.5+
2. Launch full $39 bundle
3. Go Tutorial release at same time
4. Post on HN again with the full story

### Phase 3: Grow

- GitHub Sponsors for open-source work
- Affiliate: if another tool recommends missionctl, 20% cut
- Content: YouTube/blog "building Go CLI tools" → drives tutorial sales

---

## License Key Integration

Each binary checks a license key on first run:

```
$ calctl activate <license-key>
✓ License activated. Welcome to calctl.
```

Key stored in `~/.config/missionctl/license.json`.

Bundle key activates all tools automatically.

For open-source version: all features work, activation just removes a startup notice.

---

## Revenue Targets

| Month      | Goal       | How                                      |
|------------|------------|------------------------------------------|
| Oct 2026   | $200       | postctl + calctl early buyers            |
| Dec 2026   | $500/mo    | Bundle launch, HN post                   |
| Mar 2027   | $1.000/mo  | Full suite + tutorial                    |
| Jun 2027   | $2.000/mo  | Word of mouth, content marketing         |

Realistic for an indie dev product with zero ads, SEO-only growth.

---

## polar.sh Setup Checklist

- [ ] Create polar.sh account at polar.sh
- [ ] Connect GitHub repo (missionctl)
- [ ] Create product: "postctl" — $9
- [ ] Create product: "missionctl Bundle" — $39
- [ ] Add benefit: License Key (for binary activation)
- [ ] Add benefit: GitHub Repo Access (for source buyers)
- [ ] Write product descriptions (use AI_INSTRUCTIONS.md as source)
- [ ] Create simple landing page (README as product page)
- [ ] Set up Homebrew tap for free trial (limited features)
