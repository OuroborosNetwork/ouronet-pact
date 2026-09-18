# Audit

Everything produced by Ouronet's audit programme, in one place.

## The deliverable

**[`OURONET-AUDIT-BOOK.md`](OURONET-AUDIT-BOOK.md)** — the consolidated audit book, 24 chapters.
**[`OURONET-AUDIT-BOOK.docx`](OURONET-AUDIT-BOOK.docx)** — the same, A4, 229 pages.
**[`OURONET-AUDIT-BOOK.pdf`](OURONET-AUDIT-BOOK.pdf)** — rendered. Read or print this one; it is
produced by the same build and needs no Word.

Both are **generated**. Do not edit them; edit the sources in [`book/`](book/) and rebuild:

```bash
python3 REPL/tools/_auditbook.py --docx
```

The version number lives in `VERSION` at the top of `REPL/tools/_auditbook.py`.

### Page layout

The `.docx` is A4, **1.1 cm margins**, 10 pt body, with a running header and a **`Page N of M`**
footer. Pandoc has no command-line flags for any of that — it all comes from a reference document,
`book/reference.docx`, which is itself generated:

```bash
python3 REPL/tools/_docxref.py          # rebuild it
python3 REPL/tools/_docxref.py --check  # gate-enforced
```

It is generated rather than committed-and-hand-edited for one reason: it is a 10 KB zip of XML, so
`git diff` reports only `Binary files differ`. A layout nobody can read is a layout that drifts from
whatever it is supposed to enforce. The decisions — margin width, page size, body point size — are
constants at the top of that script.

### Page-break behaviour

Word breaks wherever the page runs out, which strands a heading alone at the foot of a page, splits
a code block across the fold, and leaves single orphaned lines mid-sentence. Four rules fix that,
all in the reference document:

| rule | effect |
|---|---|
| `widowControl` | no single line of a paragraph is left alone at the top or bottom of a page |
| `keepNext` on headings | a heading is never the last thing on a page — it moves with its first paragraph |
| `keepLines` on code + headings | a code block is never split; if it does not fit, the whole thing moves |
| `pageBreakBefore` on `Heading 1` | every chapter starts on a fresh page |

`keepLines` is deliberately **not** applied to body prose. It would forbid any paragraph from
spanning a page at all, so a long paragraph arriving near the bottom pushes a near-empty page.
Widow/orphan control is what typesetting actually uses for prose and it removes the case that
matters — a sentence broken with one line stranded behind.

Measured effect, rendered to PDF each way:

| | pages | |
|---|---:|---|
| pandoc default (no reference doc) | 384 | 2.54 cm margins, 11 pt |
| thin layout only | 216 | breaks fall wherever they fall |
| **thin layout + page-break rules** | **229** | the shipped artefact |

The 13 extra pages are the cost of not splitting things. Average density is 45 lines of text per
page, and exactly one page in the book is near-empty.

### Why there is no Word "update fields?" prompt

There are **no field codes in the document body** — `pandoc --toc` is not used.

That option inserts a Word *TOC field*, which caused two problems. It was a duplicate, since this
book writes its own contents list; and because a TOC field can pull entries from other documents
(that is what its `RD` switch is for), Word greeted every reader with *"This document contains
fields that may refer to other files. Do you want to update the fields in this document?"* before
showing them anything. That prompt cannot be suppressed from inside a document — the only fix is
not to have the field.

So the contents list is ordinary text, and its page numbers are **measured**: the build renders the
document, reads which page each chapter landed on, writes those numbers in, and renders again to
confirm they did not move. If they move, the build **fails** rather than shipping a contents list
that is off by a page. It has caught itself twice — once when the page column was too narrow for
three digits, which changed the table's height and therefore the pagination it was reporting.

The only fields left are `PAGE` and `NUMPAGES` in the footer. Those are required (a literal page
number would print the same number on every page) and they do not reflow the body.

### Protected View, and why this side cannot fix it

Protected View is **not a property of this document**. Windows tags files that arrive from the
internet, from email, or from some network and WSL locations with a *Mark of the Web*, and Word
opens anything so tagged in a read-only sandbox. Nothing that can be written inside a `.docx` turns
it off, so the generator cannot help.

It also explains the rest of what you see. **Printing is disabled in Protected View** — that is the
sandbox, not a document restriction. And the layout shifting when you click *Enable Editing* was
the TOC field finally being allowed to resolve; with the field gone, that shift should be gone too.

Three ways out, in order of least effort:

1. **Read the PDF instead.** It is built from the same source, paginated identically, and prints.
2. **Unblock the file once:** right-click → *Properties* → tick **Unblock** → *OK*.
3. **Trust the folder:** Word → *File* → *Options* → *Trust Center* → *Trust Center Settings* →
   *Trusted Locations* → add the folder. Or under *Protected View*, untick the source it is coming
   from (network / internet / Outlook).

Page size is pinned to A4 explicitly rather than left unset. Pandoc's default leaves it to the
reader's locale — Letter in the US, A4 elsewhere — and a document that repaginates depending on who
opens it cannot have a stable page count, which the footer prints.

## What is here

| path | what it holds |
|---|---|
| `OURONET-AUDIT-BOOK.md` / `.docx` | the book — the thing to read or hand to someone |
| `book/` | its 24 chapter sources. Order, numbering and version are owned by `REPL/tools/_auditbook.py` |
| `records/` | the primary records the book is written from — the defect ledger, the red-team register, the round reports, the test ledger |
| `module-audits/` | the six original per-module audit trees, as they were produced: 50 files, ~31,400 lines |
| `BOOK-DIRECTIVE.md` | the owner's 2026-08-27 directive specifying what this book must contain. The book was checked against it on 2026-09-18 and **four of its twelve required Part II findings were missing**; all four were closed in the code, so the gap was in the record. They are now in Part II |

## What is deliberately NOT here

**The attacks themselves.** All 38 red-team attacks live in `REPL/RedTeam/*.repl` (and one in
`REPL/Stage_02/[6.3]_STOAICO.repl`), because they are **executable tests that run in the gate**, not
archived evidence. Moving them here would turn a regression suite into a document. Chapter 21 of the
book is generated directly from their headers, so the book cannot describe a round different from
the one that runs.

**The measuring tools.** They live in `REPL/tools/` with the rest of the suite's tooling, because
several of them are gate checks and the gate resolves them relative to itself.

**The audit's subject.** The Pact sources under `1_SOVEREIGN/` and `2_CITIZEN/` are what was
audited, not audit output.

## Reproducing anything

Appendix A of the book (Chapter 23) is the full instruction set — set-up, expected output, and a
figure-by-figure index of which command produces which number. The short version:

```bash
python3 REPL/tools/_gate.py          # the gate: ~5-7 min, must end "GATE GREEN"
python3 REPL/tools/_auditbook.py --figures   # every live figure the book quotes
```

**If a figure in the book does not reproduce, the book is wrong and the tree is right.**

## A note on where these files used to live

`book/` was `Audit/book/`, `records/` was four files in
`OuronetInformational/ARCHITECTURE/`, and `module-audits/` was four `Audit/` directories scattered
under `1_SOVEREIGN/`, each beside the code it audited.

That adjacency was a real property and consolidating here gives it up: the DALOS audit no longer
sits next to `01_DALOS.pact`. The trade was made deliberately, for a single place to hand someone.
The book's Part I names the module each tree belongs to in its source column.

Two mechanical consequences were checked rather than assumed:

- **Nine tools filter `"/Audit/"` out of their scans.** All nine scan `.pact` files; the audit trees
  hold 49 `.md` and one `.docx` and **zero** `.pact`, so those filters were already no-ops and the
  move changes no measurement. Verified before moving.
- **`_figuresync.py` scanned every `.md` in `ARCHITECTURE/`**, so moving records out would have
  silently shrunk its denominator — the exact failure mode this project has found in its own
  instruments three times. It now scans `Audit/records/` as well, and reports its file count so a
  future drop is visible rather than silent.
