# budgetctl — Budget from Terminal

Import bank exports, track spending, let AI analyze your finances.
Local SQLite, no cloud, no bank API access required.

```bash
budgetctl import bank.csv           # Import bank CSV export
budgetctl summary --month --json    # Monthly summary
budgetctl list --json               # All transactions
budgetctl report --category --json  # Spending by category
budgetctl tag "Netflix" --category streaming
budgetctl mcp                       # Run as MCP server
```

## Supported CSV formats

- N26 (German)
- ING (German)
- Deutsche Bank
- Generic: date, amount, description columns

## Status

Planned — see [ROADMAP.md](../ROADMAP.md) for timeline.
Tech stack: Go, Cobra, modernc.org/sqlite, encoding/csv
