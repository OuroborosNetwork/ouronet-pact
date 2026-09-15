# The figure checker covered 3 of 9 sites — and the 4 it didn't were wrong

*2026-09-15. Found while syncing figures for the fourth time in one session.*

## The trigger

Hand-syncing `REPL-ROUND-REPORT.md` after every gate run is repetitive, and repetition is a signal.
`_figuresync.py` *detects* drift but had no `--write`, so a human retyped the numbers each round —
and a human reaches for the nearest number of the right magnitude.

## What was actually wrong

The three canonical figures appear in **nine** places in `REPL-ROUND-REPORT.md`. The tool checked
**three** — the `| label | number |` rows. Of the six it did not check:

- **`| positive (expect) | 17,048 |`** — stale by **926**
- **`| negative (expect-failure) | 3,873 |`** — stale by **175**

Those two sit **directly beneath** two rows the tool *was* checking. Nothing had ever compared them,
and their position is exactly what made that invisible: **a checker that covers some rows of a table
reads, to anyone glancing at it, as covering the table.**

- **`plus all 5,495 per-function rows`** — the generated file has **5,446**. This cell had been
  hand-synced to the *distinct assertions written* value for several rounds, because both are
  ~5.5k and only one of them was checked.

## Fixes

1. **`_suite_stats.py` now emits `| per-function rows | N |`** as a labelled figure instead of only
   printing it to stdout. A figure that exists only in a generator's console output cannot be
   checked by anything.
2. **`_figuresync.py` CANON gained the two sub-rows and `per-function rows`.**
3. **`_figuresync.py --write`** rewrites every canonical row, preserving that row's own formatting
   (leading `&nbsp;` indent, `**` bolding). No more hand-retyping.
4. The uncheckable cell lost its number: *"plus every per-function row"*. **An uncheckable figure is
   a liability** — maintaining it wrong is worse than not stating it.

## The prose check I tried to add and correctly abandoned

The obvious next step — check figures written in prose (`"N assertions"`, `"N entrypoints"`) — was
dry-run first. Most matches are **frozen historical record**:

```
DEFECT-LEDGER.md:238           "86 entrypoints, 21,527 assertions, still GREEN"   dated result
REPL_TEST_ARCHITECTURE.md:262  "9209 assertions in 166 seconds"                   parallel run
RED-TEAM-REPORT.md:850         "gate green at 21,588 assertions"                  that stage
REPL-ROUND-REPORT.md:69,82     "21,732 -> 21,511"                                 worked example
```

> **A prose rewriter would have destroyed the audit trail.**

The last line is the one that settles it: a frozen historical figure sits inside the
*current-state* document, so not even a per-document opt-in separates live from frozen. The safe
boundary is a **labelled table row**, whose label asserts it is the current value. Prose is
human-maintained, and `_figuresync`'s header now says so explicitly with these four examples,
so the next person does not "fix the oversight".

## The protection is the LABEL WHITELIST, not the regex

A summary row like `| gate | GREEN — 90 entrypoints, 22,022 assertions, 0 failures |` can match a
row regex. What spares it is that its label is not in CANON. The selftest asserts that directly —
a non-canonical row ending in a number must be left alone — and the control proves it fires:
removing the whitelist check makes the selftest report *"changed 3 rows, expected 2"*.

Selftest is now 6 cases: match, drift, prose-exempt, write-fixes, write-keeps-format,
write-spares-prose-and-non-canonical-rows.
