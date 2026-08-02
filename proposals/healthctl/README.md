# healthctl (proposal — not yet implemented)

Terminal-first medication planner. Would be part of the **missionctl** suite,
following the same conventions as every other tool here (Cobra CLI, Bubble
Tea TUI, local SQLite, `missionctl-core` shared packages, MCP server).

Status: **design outline only**, scoped 2026-08-02. No code, no repo, no
submodule yet — see "To do before implementation" below.

---

## Why this name, not medctl

`medctl` would fit the v1 scope (medication-specific) more literally.
`healthctl` is the broader name, chosen deliberately to leave room for
general health metrics (weight, sleep, steps) later without a rename —
but that broader scope is explicitly **not** part of v1. v1 is a
medication planner, nothing more.

## Data model

```go
type Medication struct {
    ID        int64
    Name      string
    Dosage    string
    Schedule  string // e.g. daily times — exact shape TBD, see open questions
    StartDate time.Time
    EndDate   time.Time // zero value = ongoing
    Notes     string
}

type DoseLog struct {
    ID            int64
    MedicationID  int64
    ScheduledTime time.Time
    TakenAt       time.Time // zero value = not yet taken
    Skipped       bool
}

// Reserved for a possible post-v1 scope broadening — not built in v1.
type Metric struct {
    Type       string // weight | sleep | steps | custom
    Value      float64
    Unit       string
    RecordedAt time.Time
}
```

## CLI surface (matches suite conventions)

- `healthctl add` — new medication
- `healthctl list` — all medications
- `healthctl today` — doses due today
- `healthctl take <id>` — log a dose taken
- `healthctl skip <id>` — log a dose skipped
- `healthctl remind` — `osascript display notification` for doses due soon,
  same pattern as taskctl/calctl/timectl/habctl's existing `remind` commands
- `healthctl doctor` — suite-standard healthcheck

## TUI

- Today-checklist view — habctl's daily check-in UX is the right template
  (space to toggle taken/skipped, same interaction shape)
- Adherence streak/history view — habctl's heatmap pattern applies directly:
  "was this dose taken on schedule" is structurally the same question as
  "was this habit done today"

## The constraint that matters: Apple Health sync

HealthKit has **no AppleScript/EventKit-style shell bridge** — unlike
Calendar, Reminders, Notes, and Mail (every Apple integration this suite
already has), HealthKit is only reachable from a signed native app with
HealthKit entitlements and explicit user authorization. None of this
suite's existing automation patterns (osascript, the Swift/EventKit
shell-out calctl uses) reach it.

Three options if/when sync is wanted:

1. **v1 ships fully local, no Health sync.** The planner + reminders +
   adherence tracking is real standalone value on its own. **Recommended
   starting point** — sync is a follow-up spike, not a launch blocker.
2. **macOS Shortcuts bridge** — `shortcuts run <name>` is CLI-scriptable on
   modern macOS, and Shortcuts has some Health actions. Whether medication
   logging specifically is exposed this way is **unconfirmed** — needs a
   throwaway spike before committing to this path.
3. **One-way import** from Apple Health's manual "Export All Health Data"
   XML dump — read-only history backfill, no live sync, user-triggered
   each time.

## To do before implementation

- [ ] Decide: build v1 now, or park until after investctl?
- [ ] Nail down `Schedule` representation — simple "times per day" list vs.
  an RRULE-like string (calctl's `Recurrence` field is the closest existing
  precedent in this codebase)
- [ ] Confirm reminder cadence/threshold defaults (mirror the `remind`
  flags other tools already use: e.g. `--within Nm`)
- [ ] Create the real GitHub repo + add as a submodule (like every other
  tool here) — **not done yet**, this proposal lives in the superproject
  only until that decision is made
- [ ] If pursuing the Shortcuts bridge (option 2 above): spike it in
  isolation first, confirm medication-logging is actually reachable,
  before designing `sync` around it
