# Appendix 1 — Reproducing everything in this book

Every result in this book was produced by running something, and every one can be re-run. This
appendix is the instruction set — set-up, the commands, the expected output, and a figure-by-figure
index of which command produces which number in this book.

## What you need

| | |
|---|---|
| **Pact** | **5.4.1**. The suite uses Pact 5 semantics throughout; Pact 4 will not load it. |
| **Python** | 3.9 or newer for the tooling (developed against 3.14). No third-party packages are required for the gate. |
| **Cores** | any. 16 were used for every timing in this book. See {{ch:plant}} for how wall time scales — below 16 it is linear, above ~21 it stops improving. |
| **RAM** | a `pact` run peaks well under 1 GB; the reference machine had 62 GB and never approached it. |
| **pandoc** | only to rebuild this book's `.docx` (3.7 used). Not needed for anything else. |

**The `pact` binary is the one thing that reliably goes wrong.** It is commonly installed to
`~/.local/bin`, which is not on a non-interactive `PATH`. The gate resolves this itself and accepts
an override, but a bare `pact Z.repl` from a script will fail in a way that looks like a suite
failure and is not:

```bash
export PACT=~/.local/bin/pact      # or put ~/.local/bin on PATH
python3 REPL/tools/_gate.py
```

Relative `(load …)` paths inside the suite are written from `REPL/`, so anything invoking `pact`
directly must run from there. The gate `chdir`s itself and does not care.

## The one command that matters

```bash
python3 REPL/tools/_gate.py
```

This is the gate. It resolves its own paths, so it runs from any directory. It executes the full
suite — every deploy stage, every scenario, every red-team attack — and then runs the static checks
that guard the generated artefacts, the tool paths, the function-prefix vocabulary, cross-module
member resolution, and the assertion-vacuity scan.

Expect **five to seven minutes** on 16 cores. The last three lines are what matters:

```
wall 318.5s   executed 25035 assertions (20042 positive, 4993 negative)

GATE GREEN
```

Anything other than `GATE GREEN` on the final line is a failure, including `GATE FAILED` with zero
failing assertions — that is a **static check** refusing, and the reason is printed above it.

**A green gate is the only claim this book makes about the code as a whole.** Everything else is a
claim about a specific operation, and each of those names the assertion that proves it.

### Confirming deploy-readiness specifically

Loading the whole deploy chain, in order, is a narrower and faster question than the gate:

```bash
cd REPL && pact Z.repl ; echo "exit=$?"
```

Deploy-ready means **exit 0 with an empty stderr**. Do not grep the output for the word "error" and
conclude from it: this suite contains negative tests whose *names* contain the word, and a grep for
it returns 14 hits on a perfectly clean run.

## Running one piece

The full gate takes minutes. For iterating on a single module there are standalone testers that boot
a fresh environment and run only that module's suites:

```bash
cd REPL && pact modules/<MODULE>.repl        # DPTF, DPOF, SWP, ATS, VST, AQP, DPDC, …
cd REPL && pact "RedTeam/[RT-A]_Economics.repl"   # one red-team family, self-loading
```

Each red-team file loads its own prerequisites, so any attack family can be run alone.

## A warning that is not boilerplate

**Do not run a tool to find out what it does.** Several tools in this repository rewrite contract
sources. They now refuse without an explicit `--apply`, but that protection exists *because* a loop
that imported five of them — merely to prove they loaded — silently deleted 111 lines of schemas from
a live contract. Read the docstring, or `REPL/TOOLS.md`.

Note also that `REPL/TOOLS.md` was itself found to be wrong about 13 of 49 entries during this round
({{ch:instruments}}). It is generated now. Regenerate before trusting it.

## Reproducing the two money defects

Both were established by controlled experiment, and both experiments are reproducible from outside
the repository — no repo file needs to be created or modified. Write a probe to `/tmp`, load the
pipeline by absolute path, and run it from the `REPL/` directory:

```bash
cd REPL && pact /tmp/your_probe.repl
```

**The OURO mispricing.** Hold the primordial pool's reserves constant, move its weights through the
live client path, and read both the flagged function and its weight-aware sibling after each change.
The flagged one returns a bit-identical value across all three weightings; the sibling tracks the
weight ratio exactly. The permanent form of this experiment is assertion `SWP-G27`, which recomputes
the *removed* formula inline and asserts it disagrees — so the mutation test runs on every gate.

**The fee-before-gate defect.** Drive the permissioned issuance defpact with each step in its own
committed transaction and the pact id pinned, reading the patron's IGNIS and STOA balances between
steps. Step 1 commits; step 2 refuses. Then run the same drive with the flag off and observe a
*different* refusal message — that differential is what makes the refusal attributable to the admin
gate rather than to anything downstream. Pinned as `RT-F-002`.

## Reproducing a specific figure from this book

Every quantitative claim in the book comes from one of these. Run the command, compare the number.

| figure | command |
|---|---|
| assertions executed, positive/negative split | `python3 REPL/tools/_gate.py` |
| distinct assertions written, suite size, lines by area | `cd REPL && python3 _suite_stats.py` |
| client-facing cost previews, and how many are measured | `python3 REPL/tools/_info_measured.py` |
| `enforce` sites pinned by message, live vs dead modules | `python3 REPL/tools/_enforce_coverage.py` |
| owner-gate observed / attributed / never-observed | `python3 REPL/tools/_ownerobs.py` |
| the attack register, family counts, per-attack status | `python3 REPL/tools/_redteam.py` |
| priced operations, per-function price rows | `python3 REPL/tools/_ignis_price_sheet.py` |
| module line counts against the size bands | `python3 REPL/tools/_scale_report.py` |
| assertions that cannot fail | `python3 REPL/tools/_vacuous.py` |
| negative assertions accepting any error | `python3 REPL/tools/_expectfail.py` |
| cross-module calls to members defined nowhere | `python3 REPL/tools/_modref.py` |

If a figure in this book does not reproduce, **the book is wrong and the tree is right.** Three
times during this programme a published figure went stale while every document agreed with every
other document, because they had all been copied from one original — so cross-checking the prose
detects nothing and only re-derivation does.

## Rebuilding this book

The book is a generated artefact, and its staleness is a gate failure like any other.

```bash
python3 REPL/tools/_auditbook.py            # rebuild the .md from its chapter sources
python3 REPL/tools/_auditbook.py --docx     # ...and the .docx, via pandoc
python3 REPL/tools/_auditbook.py --check    # exit 1 if the committed .md has drifted
```

Chapter sources live under `Audit/book/`; the order, the numbering and the
version string live in `REPL/tools/_auditbook.py`. {{ch:register}} has no source file at all — it is
emitted from the `;;<<RT-*>>` headers in the attack files, so editing an attack edits the book.

## Reading the coverage numbers

```bash
python3 REPL/tools/_ownerobs.py              # the current owner-gate position
python3 REPL/tools/_ownerobs.py --census     # its own denominator and what it excludes
python3 REPL/tools/_ownerobs.py --weak       # gates credited only by proximity
python3 REPL/tools/_ownerobs.py --selftest   # does the detector actually detect?
```

**Read `--census` before reading the headline.** The headline is conditioned on a capability being
reachable from a named client operation, and a reader not told how many fail that condition cannot
distinguish *"{{fig:gates_observed}} of 167 witnessed"* from *"{{fig:gates_observed}} of
everything"*. That distinction is not academic —
{{ch:ownergates}} records the days this instrument spent reporting a ratio whose denominator
excluded a third of the tree, including the layer that stops token theft.

Two properties of the output are stated in the tool itself and bear repeating:

- **`observed` is an upper bound.** Reachability is not proof: a single refused call credits every
  gate on its path. The `depth 0` figure is the honest one — it counts gates the calling test
  actually targeted.
- **`never observed` is therefore a lower bound**, which is why it is the column that drives work.
  **Use the observed column to decide nothing.** A test written specifically to close a gap once
  moved no counts at all, because the gap had already been credited transitively.

## Checking the audit's own bookkeeping

```bash
python3 REPL/tools/_redteam.py --check   # the attack register and the defect ledger must agree
python3 REPL/tools/_pricesync.py --check # the generated price artefacts match their generator
python3 REPL/tools/_toolpaths.py --check # every tool path resolves; reports uncovered tool dirs
python3 REPL/tools/_modref.py --check    # no cross-module call to a member that does not exist
```

The first of these exists because a defect recorded in only one of the two records is one the audit
**undercounts**, and that is a failure mode with no symptom. All four are fatal inside the gate.
