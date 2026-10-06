# Testing a Bubble Tea v2 TUI Without a Terminal

A TUI is a state machine: `Update(msg)` turns the old state plus a message into a new
state, `View()` draws it. That makes it very testable — you don't need a terminal, a pty or
screenshots. This chapter is the testing companion to Chapter 7. It uses the helper package
`missionctl-core/tuitest` and the patterns that found real bugs in the missionctl suite
(a dead space key, lists that lost entries on delete, a crash on a fresh machine).

The examples use Bubble Tea **v2** (`charm.land/bubbletea/v2`).

---

## 1. Drive `Update`, assert state

The rule that pays off most: **feed real messages into `Update` and assert on the model**,
not on what the screen looks like. Rendered output changes whenever you touch a style; state
doesn't.

`tuitest` builds the exact messages a terminal delivers:

```go
tuitest.Key("j")            // a character
tuitest.Key("space")        // "enter" "esc" "tab" "shift+tab" "up" "down" "pgdown" "f1".."f12"
tuitest.Key("ctrl+c")       // "alt+x", "shift+tab"
tuitest.Click(3, 5)         // left click at column 3, row 5
tuitest.Motion(3, 6)        // mouse move
tuitest.Wheel(true, 3, 6)   // wheel up (false = down)
tuitest.Resize(100, 30)     // tea.WindowSizeMsg

m, cmds := tuitest.Send(m, msg1, msg2)  // any messages, in order
m, cmds = tuitest.Keys(m, "j", "j", "space") // same, from key names
tuitest.Text(m)             // View().Content with all ANSI styling stripped
```

`Send` and `Keys` return the final model and **every command `Update` produced** — they never
run them (see section 3). An unknown key name such as `tuitest.Key("nope")` panics, so a typo
fails loudly instead of testing nothing.

---

## 2. A complete worked example

A small to-do list: `j`/`k` move, `space` toggles done, `d` then `y` deletes, and when the
terminal window regains focus the list reloads — unless a delete confirmation is open.

`todo.go`:

```go
package todo

import (
	"fmt"
	"strings"

	tea "charm.land/bubbletea/v2"
)

type item struct {
	title string
	done  bool
}

type reloadedMsg struct{ items []item }

type model struct {
	items         []item
	cursor        int
	confirmDelete bool
	width, height int
}

func (m model) Init() tea.Cmd { return nil }

// reload stands in for "read the database again".
func reload() tea.Msg { return reloadedMsg{items: []item{{title: "fresh"}}} }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case reloadedMsg:
		m.items = msg.items
		m.cursor = min(m.cursor, max(len(m.items)-1, 0))
	case tea.FocusMsg:
		if !m.confirmDelete { // never reload underneath an open confirmation
			return m, reload
		}
	case tea.KeyPressMsg:
		if m.confirmDelete {
			if msg.String() == "y" && len(m.items) > 0 {
				m.items = append(m.items[:m.cursor], m.items[m.cursor+1:]...)
				m.cursor = min(m.cursor, max(len(m.items)-1, 0))
			}
			m.confirmDelete = false // y, n, esc — anything closes the prompt
			return m, nil
		}
		switch msg.String() {
		case "j", "down":
			m.cursor = min(m.cursor+1, len(m.items)-1)
		case "k", "up":
			m.cursor = max(m.cursor-1, 0)
		case "space": // v2: the space bar stringifies as "space", not " "
			if len(m.items) > 0 {
				m.items[m.cursor].done = !m.items[m.cursor].done
			}
		case "d":
			m.confirmDelete = len(m.items) > 0
		}
	}
	return m, nil
}

func (m model) View() tea.View {
	if len(m.items) == 0 {
		return tea.NewView("No items\npress n to add one")
	}
	var b strings.Builder
	for i, it := range m.items {
		mark, cur := "[ ]", " "
		if it.done {
			mark = "[x]"
		}
		if i == m.cursor {
			cur = ">"
		}
		fmt.Fprintf(&b, "%s %s %s\n", cur, mark, it.title)
	}
	if m.confirmDelete {
		b.WriteString("delete? y/n\n")
	}
	return tea.NewView(b.String())
}
```

`todo_test.go`:

```go
package todo

import (
	"strings"
	"testing"

	tea "charm.land/bubbletea/v2"
	"github.com/aeon022/missionctl-core/tuitest"
)

func newTestModel() model {
	return model{items: []item{{title: "a"}, {title: "b"}, {title: "c"}}}
}

// Regression test for the v2 space-key trap: a `case " ":` handler written for
// v1 never matches. Drive the real key event and check the state changed.
func TestSpaceTogglesDone(t *testing.T) {
	if got := tuitest.Key("space").String(); got != "space" {
		t.Fatalf("v2 space key String() = %q", got)
	}
	mi, _ := tuitest.Keys(newTestModel(), "j", "space")
	m := mi.(model)
	if !m.items[1].done || m.items[0].done {
		t.Errorf("space must toggle the row under the cursor: %+v", m.items)
	}
	mi, _ = tuitest.Keys(m, "space") // second press undoes it
	if mi.(model).items[1].done {
		t.Error("second space should untoggle")
	}
}

func TestDeleteNeedsConfirmation(t *testing.T) {
	mi, _ := tuitest.Keys(newTestModel(), "j", "d")
	m := mi.(model)
	if !m.confirmDelete || len(m.items) != 3 {
		t.Fatalf("d only asks: confirm=%v items=%d", m.confirmDelete, len(m.items))
	}
	if !strings.Contains(tuitest.Text(m), "delete? y/n") {
		t.Error("the prompt must be visible")
	}
	// anything but y cancels
	if mi, _ = tuitest.Keys(m, "n"); len(mi.(model).items) != 3 || mi.(model).confirmDelete {
		t.Error("n must cancel without deleting")
	}
	mi, _ = tuitest.Keys(m, "y")
	if got := mi.(model).items; len(got) != 2 || got[1].title != "c" {
		t.Errorf("y deletes row b: %+v", got)
	}
}

// Commands are returned, not run: assert that one WAS produced (or wasn't).
func TestFocusReloadsOnlyWhenIdle(t *testing.T) {
	_, cmds := tuitest.Send(newTestModel(), tea.FocusMsg{})
	if len(cmds) != 1 {
		t.Errorf("idle focus must start a reload, got %d cmds", len(cmds))
	}
	mi, _ := tuitest.Keys(newTestModel(), "d") // confirmation open
	if _, cmds = tuitest.Send(mi, tea.FocusMsg{}); len(cmds) != 0 {
		t.Error("focus must not reload while a delete confirmation is open")
	}
}

// Smoke test: press everything, at two terminal sizes, plus empty data.
// Fails on a panic or an empty frame.
func TestSmoke(t *testing.T) {
	keys := []string{"j", "k", "down", "up", "space", "d", "n", "d", "esc", "?", "esc"}
	tuitest.Smoke(t, newTestModel(), keys...)             // 100x30
	tuitest.SmokeSize(t, newTestModel(), 60, 15, keys...) // narrow and short
	tuitest.Smoke(t, model{}, keys...)                    // empty data
}
```

Run it with `go test ./...`. Every test here would fail against a buggy handler: change
`case "space"` back to `case " "` and `TestSpaceTogglesDone` breaks at once.

---

## 3. Commands: collected, not executed

`Update` returns a `tea.Cmd` for anything that touches the outside world — a database read,
an AppleScript call, `pbcopy`. `tuitest.Send` gives you those commands but **never runs
them**, so a test can't write to your real data, talk to Apple Calendar or overwrite your
clipboard by accident. What you assert instead:

- **Was a command produced at all?** (`len(cmds) == 1`, or `0` when it must not be). The
  focus-reload test above, and the real ones in `taskctl/internal/tui/focus_test.go`, work
  this way.
- **Feed the result message back in** when you need the follow-up state: construct the
  message the command would have produced (here `reloadedMsg{…}`) and `Send` it. That tests
  your `Update` branch without running any I/O.

Executing a command inside a test is fine **only** if everything it touches is a throwaway
resource. `habctl/internal/tui/space_test.go` runs the check-in command, but against a store
in `t.TempDir()`, and then reads the result back from that store.

---

## 4. Isolation: never touch real data

Tests must not be able to reach your real database, config or clipboard.

- **Temp directories:** `t.TempDir()` for databases, `t.Setenv("HOME", t.TempDir())` so
  anything resolved from `$HOME` lands in the temp dir.
- **Data-dir variables:** the suite lets you point a tool at a synced folder with
  `<TOOL>_DATA_DIR`. If that variable is set in *your* shell, a test that opens "the default
  database" opens your real one. Use `t.Setenv("HABCTL_DATA_DIR", "")` in the test, and run
  the whole suite through `scripts/test-all.sh`, which swaps `HOME` for a throwaway
  directory and unsets every `*_DATA_DIR`, `*_PROVIDER`, `*_API_KEY`, `*_REFRESH_TOKEN` and
  `*_HOST` variable before calling `go vet` and `go test`.
- **Config stores load env overrides only after `Load()`** (`config.Store.SetEnvPrefix`), so a
  model built without loading config isn't redirected by your shell.
- **Never trigger real side effects:** don't run commands that call AppleScript, the network
  or `pbcopy`; stub or avoid them.

A model factory in the real tests looks like this (habctl):

```go
func flow(t *testing.T, names ...string) (model, *store.Store) {
	t.Helper()
	t.Setenv("HOME", t.TempDir())
	t.Setenv("HABCTL_DATA_DIR", "")
	s, err := store.Open(filepath.Join(t.TempDir(), "habits.db"), false)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = s.Close() })
	for _, n := range names {
		if _, err := s.AddHabit(n, "", ""); err != nil {
			t.Fatal(err)
		}
	}
	m := newTestModel()
	m.s = s
	return reload(t, m), s
}
```

---

## 5. The smoke test pattern

A smoke test answers one cheap question: *does every screen still render without a panic or
an empty frame?* `tuitest.Smoke` sizes the model to 100×30, renders, presses each key and
renders again; `tuitest.SmokeSize(t, m, w, h, keys...)` does the same at any size.

Build one key list that **visits every view and mode and leaves it again with `esc`**, and
run it three ways:

```go
var smokeKeys = []string{
	"j", "k", "enter", "esc", // detail
	"n", "tab", "esc", // create form
	"?", "j", "esc", // help
	"/", "a", "esc", // search
	":", "esc", // command palette
	// … every other view the tool has
}

func TestSmokeWideAndPopulated(t *testing.T) { tuitest.Smoke(t, loaded(t), smokeKeys...) }
func TestSmokeSmall(t *testing.T)            { tuitest.SmokeSize(t, loaded(t), 60, 15, smokeKeys...) }
func TestSmokeEmptyData(t *testing.T)        { tuitest.Smoke(t, emptyModel(t), smokeKeys...) }
```

(`taskctl/internal/tui/smoke_test.go` is the real version.) The small size catches
narrow-terminal panics (slicing with a negative width); the empty-data run catches
"index out of range on an empty list". Add targeted checks on top, e.g. that the footer is
never wider than the terminal:

```go
for _, w := range []int{40, 60, 80, 100, 140} {
	m, _ := tuitest.Send(loaded(t), tuitest.Resize(w, 30))
	for _, line := range strings.Split(tuitest.Text(m), "\n") {
		if lipgloss.Width(line) > w {
			t.Errorf("width %d: line is %d cells wide: %q", w, lipgloss.Width(line), line)
		}
	}
}
```

---

## 6. Regression tests for the traps we hit

When a bug costs you an afternoon, leave a test that fails on it.

| Trap (Bubble Tea v2) | Test |
|---|---|
| The space bar is `"space"`, not `" "` — `case " "` never matches | Drive `tuitest.Key("space")` through `Update` and assert the state change (section 2). Check once that `tuitest.Key("space").String() == "space"`. |
| `textinput` with no `SetWidth` clips its placeholder to one character | Render and assert the full placeholder text appears via `tuitest.Text`. |
| Deleting from a filtered list corrupted the unfiltered list | Delete while a search filter is active, clear the filter, assert the entry is really gone and nothing is duplicated. |

---

## Checklist

- [ ] Assert on model state; use `tuitest.Text` only for "this text is visible".
- [ ] Drive real messages (`tuitest.Key`, `Click`, `Resize`) through `Update`.
- [ ] Don't run returned commands unless they only touch temp resources.
- [ ] `t.TempDir()`, `t.Setenv("HOME", …)` and the tool's `*_DATA_DIR` set to `""`.
- [ ] One smoke test that visits every view: wide, small (60×15) and with empty data.
- [ ] Run everything with `scripts/test-all.sh`.
