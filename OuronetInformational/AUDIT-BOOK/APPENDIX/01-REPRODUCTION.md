# Appendix 1 — Reproducing everything in this book

Every result in this book was produced by running something, and every one can be re-run. This
appendix is the instruction set. It assumes a working `pact` binary and a checkout of the repository.

## The one command that matters

```bash
python3 REPL/tools/_gate.py
```

This is the gate. It resolves its own paths, so it runs from any directory. It executes the full
suite — every deploy stage, every scenario, every red-team attack — and then runs the static checks
that guard the generated artefacts, the tool paths, the function-prefix vocabulary, cross-module
member resolution, and the assertion-vacuity scan.

**A green gate is the only claim this book makes about the code as a whole.** Everything else is a
claim about a specific operation, and each of those names the assertion that proves it.

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
(Part III, Chapter 4). It is generated now. Regenerate before trusting it.

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

## Reading the coverage numbers

```bash
python3 REPL/tools/_ownerobs.py              # the current owner-gate position
python3 REPL/tools/_ownerobs.py --census     # its own denominator and what it excludes
python3 REPL/tools/_ownerobs.py --weak       # gates credited only by proximity
python3 REPL/tools/_ownerobs.py --selftest   # does the detector actually detect?
```

**Read `--census` before reading the headline.** The headline is conditioned on a capability being
reachable from a named client operation, and a reader not told how many fail that condition cannot
distinguish *"82 of 167 witnessed"* from *"82 of everything"*. That distinction is not academic —
Part III, Chapter 2 records the days this instrument spent reporting a ratio whose denominator
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
