# The Ouronet Audit Book — sources

**The book itself is [`OURONET-AUDIT-BOOK.md`](OURONET-AUDIT-BOOK.md)** (and its `.docx`
equivalent). That file is **generated**. Do not edit it.

## Building

```bash
python3 REPL/tools/_auditbook.py            # rebuild the .md
python3 REPL/tools/_auditbook.py --docx     # ...and convert to .docx via pandoc
python3 REPL/tools/_auditbook.py --check    # exit 1 if the .md is stale -- this runs in the gate
```

The version number lives in `VERSION` at the top of `REPL/tools/_auditbook.py`. Bump it there.

## Why it is generated

The book quotes roughly two hundred figures that move whenever the suite does. Three separate times
in this programme a published figure went stale while every document agreed with every other
document — because they had all been copied from the same original, so cross-checking them detected
nothing. A book assembled by hand is a snapshot nobody can re-derive.

Two things follow, and both are enforced by `_gate.py`:

- **`_auditbook.py --check`** fails the gate if the published `.md` has drifted from these sources.
- **`_booktables.py --check`** fails the gate if a headline table stops summing to its own total, or
  if the defects chapter stops naming every attack the register marks FIXED.

## Layout

| source | becomes |
|---|---|
| `src/00-front.md` | how to read the book |
| `src/01-system.md` | the system under audit — architecture orientation |
| `PART-I/*` | the six per-module audit chapters |
| `PART-II/*` | the main-work round |
| `PART-III/README.md`, `src/30-design.md`, `PART-III/01…03` | the red team |
| *generated from `REPL/**/*.repl`* | `src/34-register.md` — the full attack register |
| `PART-III/04-INSTRUMENTS.md` | the instruments |
| `APPENDIX/01-REPRODUCTION.md`, `src/90-state.md` | the appendices |

Chapter **order and numbering** are owned by the `CHAPTERS` list in `_auditbook.py`.

## Cross-references

A chapter source may **not** write a chapter number literally. Write `{{ch:register}}` (→ "Chapter
20") or `{{n:register}}` (→ "20", for ranges). `--check` rejects any literal `Chapter <n>` in a
source.

This rule exists because consolidating per-part numbering ("Part III, Chapter 2") into one volume
invalidated 45 cross-references at once. With the macro, reordering `CHAPTERS` renumbers the whole
book automatically; without it, every reorder silently leaves a dozen references pointing at the
wrong chapter.

The keys are the first element of each `CHAPTERS` row: `front`, `system`, `part1`, `dalos`, `ats`,
`swp`, `dpdc`, `demipad`, `aqp`, `part2`, `previews`, `pricing`, `splits`, `suite`, `part3`,
`design`, `method`, `ownergates`, `defects`, `register`, `instruments`, `repro`, `state`.

## The register chapter

`src/34-register.md` has no file on disk. It is emitted by `chapter_register()` from the
`;;<<RT-*>>` headers in the attack `.repl` files themselves — the same text each attack carries in
source. Editing an attack changes the book; there is no second copy to drift.

## Live figures

A chapter source may **not** hard-code a volatile number. Write `{{fig:assertions}}` and the
assembler substitutes what it **measures at build time** by running the tool that owns that figure.

```bash
python3 REPL/tools/_auditbook.py --figures   # list every key and its current value
```

This exists because a re-derivation sweep on 2026-09-18 found **124 stale figures** in these
chapters against ~516 that still held. None had been written carelessly; every one was correct when
typed and the tree moved. Hand-correcting 124 numbers resets the clock and changes no mechanism.

Rules:
- An unknown `{{fig:key}}` is a **build error**, not a blank.
- A figure the tool cannot produce is a **build error**, not a fallback to the last value. A default
  would be a stale figure with extra steps — which is the thing this replaces.
- Keep a literal only where the number is deliberately **historical** — "it rose from 22,939 to
  `{{fig:assertions}}` during the round" is correct: the first is a fact about the past.
