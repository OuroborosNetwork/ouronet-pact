# How to read this

132 files. Nobody reads them in order, and the order they sit in is not a reading order — it is a
reference arrangement, optimised for finding one thing later.

Pick the path that matches why you are here.

---

## If you are deciding whether this is serious — about 30 minutes

The shortest honest tour. It includes the parts that are unflattering, because a tour that omits
them is not evidence of anything.

1. `01-what-ouronet-is.md` — what the thing is
2. `02-why-it-exists.md` §3, §6, §7 — the bet, the bill, and what would show the bet was wrong
3. `../60-methodology/02-semi-self-auditing.md` — the claim most worth checking: that a naming
   discipline turned a whole class of review into a mechanical check
4. `../60-methodology/04-what-went-wrong.md` — the failure classes this project actually hit
5. `../70-comparison/03-what-the-complexity-buys.md` — the accounting, including what is missing

**Read 4 before 3 if you are sceptical**, which is the right way to be. A project that documents
its own failure classes is making a stronger claim than one that documents its successes, and it is
a claim you can check against the repository.

## If you are going to build a client — about 2 hours, then reference forever

You want the operation surface and the traps, not the internals.

1. `03-the-shape-in-one-diagram.md` — enough model to place everything else
2. `../10-architecture/06-ignis-and-the-gas-station.md` — who pays, and the
   patron/executor/executee split, which appears in **every** entrypoint signature
3. `../10-architecture/08-the-read-layer.md` — what to call for data, and what not to
4. **`docs/CHAPTER-INTEGRATION/`** in this repository — five files written for exactly this job:
   orchestration, signing and capabilities, cost preview, errors, reading data
5. `../90-reference/01-entrypoint-catalogue.md` — all 423 entrypoints, generated

**Do not skip step 4**, and read `03-cost-preview.md` in it before writing any preview code. The
single most dangerous fact in the client surface lives there: **410 of the 423 entrypoints have a
cost-preview function whose parameter list differs from their own** — different names, different
order, different arity. Only 13 match. Binding preview arguments positionally produces a confident,
wrong price rather than an error, because the values are all strings and nothing type-checks.

## If you are going to write a citizen module — half a day

You are writing sovereign-adjacent code and the conventions are not optional.

1. everything in the client path above
2. `../10-architecture/02-sovereign-and-citizen.md` — the boundary, and what you are free to do
3. `../60-methodology/01-stoicsyntax.md` — the prefix system. **Read this before writing a single
   function name.** It is the load-bearing convention of the whole codebase
4. `../25-defi/` — the pool families you will be composing against
5. the module pages in `../30-modules/` for whatever you call

The good news for step 2: **citizen modules are free to shape their own functions.** The
patron/executor/executee canon that governs every sovereign entrypoint does not reach you — owner
ruling. The consequence is that the **registry** is the only authority on how to call a citizen
function, since nothing about its shape follows from a convention.

## If you want to understand the whole system — days, and that is the honest answer

There is no shortcut, and the ordering matters because each section assumes the vocabulary of the
one before.

```
00-orientation      →  all four, in order
10-architecture     →  all eight. this is the spine
20-assets           →  the nouns. 00- first, then whichever types you care about
25-defi             →  the verbs. needs the nouns
30-modules          →  79 pages. deploy order, which is dependency order,
                       which is the order it makes sense in
40-journeys         →  what the pieces add up to
50-economics        →  why it costs. read after 30-, or it reads as excuses
60-methodology      →  how it was built, and how it was checked
70-comparison       →  against the industry
80-cryptography     →  independent of the rest; read any time
```

`30-modules/` is the bulk and is **not** meant to be read front to back. It is a reference. Read
three or four in full to learn the template, then use it as a lookup.

## Conventions in every file

- **Every figure carries its scope and its command.** `../90-reference/03-how-these-figures-were-obtained.md`
  has the command behind every number here. Re-run it rather than trusting the page — that file
  records two figures this documentation published wrongly in its first pass.
- **Facts are cited, not copied.** Where something is maintained elsewhere — the price sheet, the
  registry, the Audit Book — you get a link. A copy is a second version to keep in step.
- **Traps are named.** Where something has caused a real defect, the page says so and says what
  happened. This is deliberate: the reader this is written for does not believe a document in which
  nothing ever went wrong.
- **Pact is explained at first use.** You are not assumed to know it. Where a Pact construct
  matters — `defcap`, module references, `defpact` — it is explained once, where it first appears.
- **No file assumes you read another**, except these four.

## What this documentation is not

- **Not the audit.** `Audit/OURONET-AUDIT-BOOK.md` is a separate 28-chapter artefact making an
  adversarial argument. This describes; that interrogates.
- **Not the working memory.** `OuronetInformational/` is ~200 files of handoffs, defect ledgers and
  dated decisions, addressed to whoever is building the thing. Invaluable, and not documentation.
- **Not a website.** Every file here is source material. The website agent assembles them; nothing
  here concerns itself with navigation or styling.
- **Not maintained by hand.** See `../MAINTAINING.md` — which is a directive requirement, not
  housekeeping. It is what makes the difference between this folder and the three previous attempts
  that were abandoned as stale.

---

## Sources

- File count from `BUILD-PLAN.md` §3, which enumerates all 132.
- The 410-of-423 preview divergence: `Deploy/OURONET-REGISTRY.json`, recomputed and gate-checked by
  `REPL/tools/_chapterfigures.py`; explained in `docs/CHAPTER-INTEGRATION/03-cost-preview.md` §1.
- The citizen-freedom ruling: owner, 2026-09-26, recorded in `CLAUDE.md` under the
  patron/executor/executee canon and in `OuronetInformational/StoicSyntax-Prefixes.md` §2.2.
