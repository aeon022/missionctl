# investctl (proposal — not yet implemented)

Terminal-first stocks/funds tracker. Would be part of the **missionctl**
suite, following the same conventions as every other tool here (Cobra CLI,
Bubble Tea TUI, local SQLite, `missionctl-core` shared packages, MCP server).

Status: **design outline only**, scoped 2026-08-02 (originally deferred as
its own tool on 2026-07-30 — see the decision recorded then: investment
tracking does not belong in budgetctl's `Transaction` model, which has no
concept of holdings, quantities, or market price). No code, no repo, no
submodule yet — see "To do before implementation" below.

## Data model

```go
type Holding struct {
    Symbol    string
    Name      string
    AssetType string // stock | fund | etf
    Account   string
}

type Transaction struct {
    ID       int64
    Date     time.Time
    Symbol   string
    Type     string // buy | sell | dividend
    Quantity float64
    Price    float64 // per unit
    Fees     float64
}
```

Position quantity, cost basis, current value, and unrealized gain/loss are
all **computed**, not stored — derived from the transaction history plus
the latest cached price. Same "cache is a snapshot, not truth" philosophy
`missionctl-core/lastsync` already encodes for every syncing tool.

## CLI surface (matches budgetctl's shape)

- `investctl add-transaction` — record a buy/sell/dividend
- `investctl holdings` — current positions with gain/loss
- `investctl sync` — refresh prices (explicit, user-triggered — see below)
- `investctl summary` — portfolio total, day change, allocation by asset type
- `investctl doctor` — suite-standard healthcheck

## The one real architectural first

Every other tool in this suite is local-first, talking only to Apple's own
apps via AppleScript/EventKit — **zero third-party network dependencies**.
investctl needs live market prices, which means a third-party API
(Alpha Vantage / Stooq / similar — likely a free-tier key). That's a
genuine departure from this suite's differentiation story (see
`DIFFERENTIATION_STRATEGY.md` — "real offline AI", air-gapped mode).

To keep it honest: cache the last-fetched price locally and make `sync` an
explicit, user-triggered pull — not automatic background fetching — so the
tool still works fully offline between syncs, same as everything else here.

## To do before implementation

- [ ] Decide: build now, or park until after healthctl?
- [ ] Pick a price data API — key requirements, rate limits, free-tier
  viability for personal use
- [ ] Decide cost-basis method for gain/loss: FIFO vs. average cost
- [ ] Decide multi-currency handling, if any holdings aren't USD/EUR
- [ ] Confirm scope stays stocks/funds/ETFs only (per the original
  2026-07-30 decision) — not crypto, not real estate
- [ ] Create the real GitHub repo + add as a submodule (like every other
  tool here) — **not done yet**, this proposal lives in the superproject
  only until that decision is made
