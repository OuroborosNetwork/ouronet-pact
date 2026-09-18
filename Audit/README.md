# Audit

Everything produced by Ouronet's audit programme, in one place.

## The deliverable

**[`OURONET-AUDIT-BOOK.md`](OURONET-AUDIT-BOOK.md)** — the consolidated audit book, 24 chapters.
**[`OURONET-AUDIT-BOOK.docx`](OURONET-AUDIT-BOOK.docx)** — the same, for conversion to PDF.

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

Measured effect, rendered to PDF both ways:

| | pages |
|---|---:|
| pandoc default (no reference doc) | 384 |
| **this layout** | **216** |

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
