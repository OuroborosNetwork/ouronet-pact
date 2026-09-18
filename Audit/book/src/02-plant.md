Everything asserted in this book was established by running something. This chapter is about the
machine that does the running — its size, how it is organised, why a full verification takes five
minutes instead of eighty, and what the procedure actually is. It is placed before the audit
chapters because every one of them cites it.

## The corpus, measured

| | |
|---|---:|
| `.repl` files, live | **207** |
| `.repl` files, archived | 68 |
| total lines of REPL, live | **137,733** |
| &nbsp;&nbsp;code | 103,405 |
| &nbsp;&nbsp;comment | 32,219 |
| &nbsp;&nbsp;blank | 2,109 |
| sandbox bootstrap `.repl` (outside `REPL/`) | 16 files, 567 lines |
| analysis tools (`REPL/tools/*.py`) | 53 files, 12,099 lines |

**Lines by area:**

| area | lines | what lives there |
|---|---:|---|
| `modules/` | 44,304 | one tester per module — the per-module functional suites |
| `Stage_02/` | 42,605 | Stage 2 deploys and the scenario suites (DPDC, DemiPad, AQP, Talos) |
| `Stage_01/` | 31,242 | Stage 1 deploys and scenarios (DALOS, DPTF, DPOF, ATS, VST, SWP) |
| `Kursan/` | 9,333 | finding-verification harnesses — one per audit finding that needed a standing proof |
| `RedTeam/` | 5,067 | the attack files |
| `(root)` | 4,414 | the stage loaders, `Z.repl`, `ZALL.repl`, the golden-path drivers |
| `fixtures/` | 768 | shared minimal fixtures (`mock-tf`, `mock-of`, `mock-pair`, …) |

The archived 68 are kept for provenance and are excluded from every count by the measuring tool —
named as an exclusion rather than silently dropped, because a denominator that quietly shrinks is
how three of this programme's own instruments came to report tidier numbers than the truth.

For scale, the code under test is **93 Pact modules**. The suite is therefore larger than a
one-to-one relationship with the subject; roughly speaking, there is more test than there is system.

## Two assertion counts, and which one to quote

This distinction matters enough that the generated statistics file leads with it, because quoting
the wrong one overstates the suite by more than four times.

| | |
|---|---:|
| **distinct assertions written** | **5,873** |
| **assertions executed** per full gate run | **25,035** |
| &nbsp;&nbsp;positive (`expect`) | 20,042 |
| &nbsp;&nbsp;negative (`expect-failure`) | 4,993 |

*Executed* exceeds *distinct* because a shared file runs once for **every entrypoint that loads
it** — 92 entrypoints reach 321 distinct files, and the overlap is deliberate: a Stage-1 deploy
chain is a prerequisite for dozens of suites and is re-executed by each.

**Quote 5,873 for "how many tests exist". Quote 25,035 for "how much ran".** This book uses 25,035
when describing a gate run and says so each time.

The **negative** count is the one to look at for a security audit. Roughly one assertion in five
asserts that an operation was *refused*, and of those, **1,296 check the refusal's message** rather
than accepting any error at all. That last figure is the load-bearing one: an `expect-failure` that
accepts any error cannot distinguish the gate under test from an unrelated check that happened to
fire first, and in a language with eager `let` bindings, an unrelated check firing first is the
normal case, not the exotic one. Exactly **one** message-free negative assertion remains in the
tree, and it sits in an ungated scratch file.

## One runner, and why that is a rule

> **RULE 4 — there is exactly ONE authoritative runner: `python3 REPL/tools/_gate.py`.**

This is stated as a rule because it was once violated. A second runner existed —
`regressions/run.sh` — which ran a set of files the gate excluded. Two runners with different
inclusion lists means the honest answer to "is the suite green?" is "which one did you run?", and
the `Kursan/` harnesses sat in exactly that gap: **343 assertions**, including two suites of 68 and
69, excluded wholesale from the gate as "one-off finding-verification harnesses" while the second
runner's own manifest listed them as runnable. They are gate entrypoints now and `run.sh` is
deleted.

The gate resolves its own paths, so it runs from any directory:

```bash
python3 REPL/tools/_gate.py          # the gate. ~5-7 minutes.
python3 REPL/tools/_gate.py -j 8     # fewer workers
python3 REPL/tools/_gate.py --audit-only   # orphan check only, run nothing
```

It also resolves the `pact` binary itself, with a `PACT=` environment override, because a `PATH`
missing `~/.local/bin` is a common way for the gate to "fail" for reasons that have nothing to do
with the suite.

Two faster paths exist and neither is the gate:

- `cd REPL && pact Z.repl` — the fast pipeline. It **deliberately skips** `[6.1]_Cumulator.repl`
  and the Stage-1 scenario tail. It does run 106 pricing assertions, but the 75 it skips are the
  **leg-level** ones, and on one occasion a leg-level assertion was the only thing in the suite
  that caught a preview leg-split which every total-level assertion passed straight through.
- `cd REPL && pact ZALL.repl` — every suite, but serially, in one process, as a single gate
  entrypoint. It is the largest single entrypoint and therefore sets the floor described below.

## Why it runs in parallel, and why that is safe

**Verified with `strace`: a `pact <file>.repl` run opens ZERO files for writing.**

That single observation is what the whole execution model rests on. Each run is a separate OS
process holding its own **in-memory** database. Source files are read-only and shared. There is no
shared mutable state for concurrent runs to corrupt, no lock to take, no temp directory to collide
in, and no ordering requirement between entrypoints.

The consequence is that parallelism here requires **no support from Pact and no test-framework
infrastructure**. The operating system provides it. The gate uses a thread pool of `os.cpu_count()`
workers dispatching subprocesses; the equivalent with no Python at all is:

```bash
cd REPL && ls modules/*.repl | xargs -P 16 -I{} pact {}
```

The only shared resources are CPU, RAM (a run peaks well under 1 GB, against 62 GB available) and
the read-only tree.

This is worth stating plainly because "run the tests in parallel" is usually a project with a
database-isolation problem attached. Here it is free, and it is free because of a property that was
*measured* rather than assumed — the `strace` run is the reason the claim is in this book at all.

## The arithmetic of the speedup

From the most recent green run, on 16 cores:

| | |
|---|---:|
| entrypoints | 92 |
| distinct files reached | 321 |
| **serial cost** (sum of all entrypoint times) | **4,700.7 s** ≈ 78 min |
| **wall time** | **318.5 s** ≈ 5.3 min |
| speedup | **14.8×** on 16 workers |

A 14.8× speedup on 16 workers is 92% efficiency. The residual 8% is scheduling tail: towards the
end of a run the remaining long entrypoints cannot fill 16 workers, so cores idle. It is **not** a
single dominant file — see the next section, where that turns out to matter.

## Why more cores would not help

The testers are independent, which is what gives the parallelism. But **one file can only use one
core**, so a single long entrypoint is a hard floor:

```
wall time = max( longest single entrypoint , total work / cores )
```

For the run above: total work / 16 = **294 s**, and the longest entrypoint — `ZALL.repl` — is
**226.8 s**. The work bound is the larger of the two, so this suite is currently **work-bound, not
file-bound**: the formula's floor is 294 s and the measured wall was 318.5 s, the 24 s difference
being the scheduling tail.

That is the healthy state and it is worth being precise about, because the intuitive story — "one
huge file dominates" — is what RULE 1 exists to prevent and is **not** what the numbers say here.
The practical consequence is the opposite of the intuitive one: adding cores *would* help this
suite today, up to the point where the work bound drops below `ZALL`'s 226.8 s. That happens at
about 21 workers. Past 21, extra cores buy nothing until `ZALL` is split.

| workers | work bound (4,700.7 / n) | longest entrypoint | ⇒ floor |
|---:|---:|---:|---:|
| 8 | 587.6 s | 226.8 s | **587.6 s** |
| 16 | 293.8 s | 226.8 s | **293.8 s** *(measured wall 318.5 s)* |
| 21 | 223.8 s | 226.8 s | **226.8 s** ← crossover |
| 32 | 146.9 s | 226.8 s | **226.8 s** |

> **RULE 1 — balance the split: aim for `longest_entrypoint ≈ total_work / cores`.**
>
> Not a fixed minute count — the target moves as the suite grows. Splitting a file already below
> the work bound wastes effort; leaving one far above it wastes hardware. **Whatever the longest
> entrypoint costs is what the whole suite costs.**

This is the reason the suite is organised as 92 entrypoints rather than one. The structure is not
aesthetic; it is the direct consequence of that formula. When a suite grows past the bound, the fix
is to split the entrypoint, and the rule tells you which one and by how much.

## The half of the gate that matters more

The gate has two jobs, and running the tests is the first one.

> **Job 2: prove that no asserting file is orphaned.**

Every `.repl` carrying assertions must be reachable from a gate entrypoint, or be explicitly and
justifiably excluded in a list that states its reason. Anything else fails the gate.

This exists because it was missing. Four `deb-staleness-*` driver files were archived on an
"assertion-free" heuristic — true of the drivers themselves, false of what they **load**. They were
the only path to an entire family of suites, and moving them also broke their relative `(load …)`
paths, so they could not have run even where they were put. **About 125 assertions silently left
the suite, and the ledger did not notice, because a ledger counts files and not execution.**

An assertion nothing executes is not coverage. It is decoration that reads as coverage — to a
tracker, to a reviewer, and to the person who wrote it. The orphan check is the only thing in this
system that can tell the difference, and it is why `--audit-only` exists as a mode: you can ask
that question in seconds without running anything.

Exclusions carry their reason in the source, and a **wrong** reason is treated as worse than none.
One exclusion note read "fails inside its own probe module — same known breakage as the sibling",
which was never checked and is not what happens: the file dies at its very first `load`, before any
Ouronet code runs, because it was moved into a subdirectory and its relative paths were never
fixed. A wrong exclusion reason sends the next person to debug a module that is never reached.

## Fixtures: mock by default

> **RULE 2 — a module tester builds the SMALLEST fixture that exercises its logic.**

Shared minimal fixtures live in `REPL/fixtures/`: `mock-tf`, `mock-of`, `mock-sft`, `mock-nft`,
`mock-pair`, `mock-pool`, `mock-accounts`. A large, live-shaped fixture is used only when the
test's subject **is** scale or the live definition — set composition, fragments, make/break,
gas-ladder probes — and the file header must say so.

The cost of getting this wrong is direct: one populate step spends 28 seconds minting a full
live-shaped collection. That collection is correct for the tests that need a real set definition
and wrong as a default, because nothing about burning a single token needs 500 nonces. Under RULE 1,
a 28-second fixture in the wrong file is 28 seconds added to the floor of the entire suite.

## Assertion discipline

Five rules govern what an assertion must do to count. Each was written after a violation.

> **RULE 3 — an `enforce` you cannot write a failing test for is DEAD CODE. Delete it.**

This is the rule that turns "we should test the guards" into a finite, checkable task. It is
measured by `_enforce_coverage.py`, and the live unpinned count is **0 of 790**.

> **RULE 8 — an `expect-failure` MUST assert the expected error message.**

Without the message, the assertion proves only that *something* refused. With eager `let` bindings
that something is routinely a hard read several lines above the guard under test. This is the single
most important rule in the suite and the one this book returns to most often.

> **RULE 9 — an `expect-failure` on a state-mutating operation needs its own `(rollback-tx)`.**

`expect-failure` does **not** roll back REPL writes. An attack that expects a refusal, gets one,
and does not roll back leaves partial state behind for whatever runs next. This was learned by
turning the gate red: one attack used `commit-tx` and consumed a fixture another attack depended on.

> **RULE 10 — a commented-out invocation is not coverage. Measure with comments stripped.**

> **RULE 11 — coverage counted is not coverage GATED. Measure both.**

RULE 11 is the subtlest and it caught its own author: a coverage figure of 448/448 was published
when the *gated* figure — how much of that coverage a red build would actually protect — was
439/448. A test that exists but that no gate entrypoint reaches is RULE 11's failure mode, and the
orphan check above is its enforcement.

## The checks that are not tests

A tree can pass all 25,035 assertions and still fail the gate. These static checks are **fatal**:

| check | what it enforces |
|---|---|
| orphan check | every asserting file is reachable from an entrypoint |
| `_pricesync --check` | the generated price sheet matches the price tables in source |
| `_figuresync --check` | the figures in the architecture documents match the tree |
| `_toolpaths --check` | every hard-coded path literal in every tool still resolves — across **all four** tool directories, plus a discovery pass that reports any directory of `.py` files the list does not cover |
| `_redteam` | every attack header parses; the register matches the defect ledger |
| `_modref --check` | no module-reference call names a member that exists nowhere |
| `_booktables --check` | this book's headline tables sum to their totals, and its defects chapter names every attack the register marks fixed |
| `_auditbook --check` | this book is not stale against its chapter sources |

`_toolpaths` earns its place: a directory move once killed eleven tools that died at **import**, so
every check that consumed their output silently stopped checking anything. A tool that fails to load
produces no output, and no output is indistinguishable from clean output to anything downstream.

## The procedure, end to end

1. **Change something.**
2. **Run the affected module tester** — `cd REPL && pact modules/ATS.repl`. Seconds to a minute.
3. **If the change touches pricing, STOA collection or IGNIS billing, do not trust `Z.repl`.** Run
   the gate. A quarter of the pricing assertions — every leg-level one — are outside the fast path.
4. **Run the gate before committing.** Five to seven minutes.
5. **Compare the assertion count against the previous green run.** This is the step most easily
   skipped and the most informative. A refactor that is supposed to be behaviour-preserving must
   leave the count *exactly* unchanged; the seven-interface version bump touching 3,333 references
   across 116 files landed at 25,035, the same figure as before it, and that identity is the
   evidence the bump changed names and nothing else. A count that moved when it should not have is a
   finding.
6. **If a fix closes a finding, the finding gets a named assertion tag** that goes red if the fix is
   reverted. RULE 7: a red-team finding closes with a regression test named for the finding, not
   with a note.

## What the suite does not do

- **It is not a fuzzer.** Every input is chosen. Adversarial cases are *derived from the source* —
  enumerate the `enforce`s, write the input that trips each — rather than discovered by search.
- **It does not test the deployed chain.** Everything runs against sandboxes that reproduce
  StoaChain's genesis ordering. The suite proves the tree behaves; it cannot prove the chain holds
  the tree.
- **It does not measure gas against a real node.** IGNIS is the virtual gas and is fully modelled
  and asserted; the underlying StoaChain gas is not what these assertions are about.
- **Coverage is entrypoint coverage, not branch coverage.** The worklists in {{ch:state}} count
  functions, previews, enforce sites and gates — each driven to zero — but no claim is made that
  every branch of every function has been executed.
