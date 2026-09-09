# REPL Test Architecture — the canonical model

**This is the standard for how Ouronet is tested, and the best-practice reference for any module
written from here on.** Rewritten 2026-09-09 after measuring the real state of the suite.

---

# 1. The three suites

Testing splits into three kinds. They answer different questions, have different completion
criteria, and must not be conflated.

| suite | asks | derived from | can it be "complete"? |
|---|---|---|---|
| **NORMAL** | does the specified behaviour work? | the spec / the op list | **yes** — every entrypoint, exercised |
| **ADVERSARIAL** | is every door we built actually locked? | **the code itself** — every `enforce`, every defcap | **yes** — it is ENUMERABLE |
| **RED TEAM** | is there a door we forgot to build? | attack hypotheses | **no** — open-ended, grows forever |

## Why red teaming is not just "more adversarial tests"

The adversarial suite is **enumerable from the source**: list every `enforce`, write an
`expect-failure` proving it rejects. When the count matches, that suite is provably finished.

Red teaming cannot be enumerated that way, because the bug it looks for is an **absence** —
a missing `enforce`, a capability that composes wrongly, a value that should have been bounded
and wasn't. You cannot derive "what we forgot" from the code that forgot it.

**Red-team FINDINGS become REPL tests** (that is the durable artifact, and it is why the two feel
alike). But the *activity* is hypothesis generation, and some of its attack classes cannot live in
a REPL at all:

* **cross-block ordering** — front-running, MEV, transaction reordering
* **economic griefing** — gas-station exhaustion, dust-spam, fee-market attacks
* **`defpact` interruption** — abandoning a multi-step flow at an adversarial step boundary
* **multi-signer keyset composition** — real network signature semantics

So: build the adversarial suite now (it is enumerable and finishable), and treat red teaming as a
separate activity that **feeds a third suite**. Reaching 100% adversarial coverage does NOT mean
the code is secure — it means every lock we installed has been tested. It says nothing about the
doors we never built.

---

# 2. The parallelism rule (the thing that shapes everything)

Verified 2026-09-09 on this machine: **16 cores, 62 GB RAM.** 26 module testers totalling
**326 s serial** completed in **~50 s wall** at `-P 8`. Each `pact` process holds its own
in-memory DB, so testers share nothing and parallelise perfectly.

**But wall time = the SLOWEST SINGLE TESTER, not total/cores.** With enough cores, a suite of
40 testers where one takes 30 minutes still takes 30 minutes.

### Parallel execution is safe — Pact needs no support for it

**Verified 2026-09-09 with `strace`: a `pact <file>.repl` run opens ZERO files for writing.**
Every run is a separate OS process holding its own in-memory database; source files are read-only
and shared. Parallelism therefore comes from the operating system, not from Pact, and there is no
shared mutable state for runs to corrupt. `xargs -P 16` is all the infrastructure required:

```bash
cd REPL && ls modules/*.repl entities/*.repl | xargs -P 16 -I{} pact {}
```

The only shared resources are CPU, RAM (62 GB here — a run peaks well under 1 GB) and the
read-only source tree.

### Why independence does not make it faster than the slowest file

The testers ARE independent — that is what gives us parallelism. But **one file can only use one
core**, so a single long file is a hard floor:

```
wall time = max( longest single file , total work / cores )
```

Our measured case: 26 testers, **326 s total**, longest = ADMIN at **49.3 s**.

| cores | work bound (326/n) | longest file | => wall |
|---:|---:|---:|---:|
| 8 | 41 s | 49 s | **49 s** (measured ~50 s) |
| 16 | 20 s | 49 s | **49 s** |
| 32 | 10 s | 49 s | **49 s** |

Past ~7 cores, extra cores buy NOTHING here, because ADMIN alone cannot be split.

> ## RULE 1 — balance the split: aim for `longest_file ≈ total_work / cores`.
> Not a fixed minute count — the target moves with the suite. If the full suite grows to 60 min
> of work on 16 cores, the ideal is ~4 min per file and nothing should exceed it. Splitting files
> that are already below the work bound wastes effort; leaving one file far above it wastes
> hardware. **Whatever the longest file costs is what the whole suite costs.**

Run the matrix with:
```bash
cd REPL && ls modules/*.repl | xargs -P 16 -I{} pact {}
```

---

# 3. Fixtures — mock by default, real only when the test IS the realism

Today `POPULATE-BLOODSHED` spends 28 s minting a full live-shaped collection. That collection
exists because it mirrors the **live** setup, and set/fragment/make-break tests genuinely needed a
large collection with a real set definition. That was the right call at the time and those tests
stay.

But it is the wrong default for localised testing: nothing about `C_BurnSFT` needs 500 nonces.

> ## RULE 2 — a module tester builds the SMALLEST fixture that exercises its logic.
> Shared minimal fixtures live in `REPL/fixtures/`: `mock-tf`, `mock-of`, `mock-sft`, `mock-nft`,
> `mock-pair`, `mock-pool`, `mock-accounts`. Use a large/live-shaped collection only when the
> test's subject IS scale or the live set definition (set composition, fragments, make/break,
> gas-ladder probes) — and say so in the file header.

---

# 4. The three coverage gates

Every gate is a number anyone can recompute with `REPL/_coverage.py`. No gate is a matter of
opinion.

### G1 — Surface
**Every Talos entrypoint is invoked inside its own module tester.**
`Measured 2026-09-09: ~65%` (VST 37%, DPSF-UPDATES 39%, DPTF 50%, ATS 88%, AQP 100%).
Note 95% of entrypoints are called *somewhere* in the tree — that is not the same thing, and the
difference is exactly why a module tester cannot currently be trusted on its own.

### G2 — Adversarial
**Every `enforce` and every defcap rejection has an `expect-failure` proving it rejects.**
`Measured 2026-09-09: 293 negative tests against 1,015 enforce sites = 29%.`

> ## RULE 3 — an `enforce` you cannot write a failing test for is DEAD CODE. Delete it.
> There is no "unreachable, skip it" category. Either a caller can violate the condition — in
> which case write the test — or no caller can, in which case the `enforce` is noise and its
> removal makes the module smaller and the guarantee clearer. This turns the awkward tail of G2
> into code cleanup instead of an excuse, and it is why the target is **100%, with no exemptions**.

### G3 — Determinism
**Every test passes standalone AND inside the full run.** A test that only passes in one context is
depending on fixture contamination and is not proving what it claims.

### The ledger — the evidence base

`REPL/_test_ledger.py` generates `ARCHITECTURE/REPL-TEST-LEDGER.md` (+ a `.json` twin): **every
client entrypoint, how many times it is invoked, how many positive and adversarial assertions
surround it, and which test files touch it.** This is what a later audit or documentation agent
reads to write the testing paper from evidence instead of recollection, and it doubles as the
worklist for G1 and G2.

Assertions are attributed **by transaction block** — credited to every op invoked in the same
`(begin-tx … commit-tx)`. That is a stated approximation: it measures how well an op's
*neighbourhood* is asserted, not that an assertion targets that op. **Invocation counts are exact.**

The pattern it exists to catch: `ATS|C_ColdRecovery` is invoked **275 times with zero
assertions** — heavily exercised, never actually checked. Raw invocation counts hide that; the
ledger makes it the first thing you see.

> ## RULE 6 — regenerate the ledger with the suite.
> A test that is not in the ledger does not count, and an op with invocations but no assertions is
> a gap, not coverage.

---

# 4b. How to write tests for things nobody thought of

The obvious objection: *"adversarial and red-team testing means thinking of what we didn't think
of — that is paradoxical."* It is paradoxical for one of them and not the other, and the
difference is the whole reason they are separate suites.

## Adversarial needs NO creativity — it is derived from the source

The code contains **1,015 `enforce` sites**. Each one is a claim: *this must be true*. The test
writes itself: construct the state that makes it false, assert rejection. The worklist is
generated, not invented, and it is finished when the counts match. Same for the 998 defcaps:
the right caller succeeds, every wrong caller is rejected.

**Nothing is being thought of here.** If a rejection test cannot be written, RULE 3 applies — the
`enforce` is dead code and gets deleted.

## Red team IS the paradox — so do not rely on inspiration, use generators

Mature practice does not ask people to be clever on demand. It applies techniques that
**produce hypotheses systematically**. Each is auditable: you can state the coverage claim.

| technique | what it generates | why it needs no inspiration |
|---|---|---|
| **Invariants + fuzzing** | violations of properties that must ALWAYS hold — supply conservation, no negative balance, Σ shares = total, nonce monotonicity | you assert the property and let random valid input search for the counterexample |
| **Metamorphic / differential** | disagreements between paths that must agree — transfer 100 once vs 50 twice, bulk vs individual, **INFO preview vs actual charge** | divergence IS the bug; no attack needs imagining |
| **Attack taxonomy** | one hypothesis per (module x known attack class): access control, rounding/precision, overflow, composition order, oracle manipulation, economic griefing, governance capture, front-running | you walk a checklist, you do not invent it |
| **State machines** | illegal transitions — every lifecycle state x every op that should be refused in it | enumerable from the state set |
| **Cross-role** | every defcap x every wrong caller | enumerable from the cap list |
| **Mutation testing** | proof that the tests themselves are weak | corrupt the code; if NO test fails, that is a hole, demonstrated |

**Mutation testing is the answer to "how do we know we didn't miss anything?"** It converts the
philosophical question into a measurement: flip a `>=` to `>`, delete an `enforce`, weaken a cap —
then run the suite. A surviving mutation is a proven gap, not a suspicion. It is fully
automatable and it is the only technique here that grades the tests rather than the code.

**What red teaming still cannot reach**, and must be stated as a limit rather than quietly
skipped: cross-block ordering and front-running, gas-station economic exhaustion, `defpact`
interruption at adversarial step boundaries, and real multi-signer keyset semantics. These need a
devnet or a formal model, not a REPL.

---

# 4c. The audit document is GENERATED, not written

The end product — the testing chapter of the audit book — must be reproducible from artifacts, so
that a reader can recompute every number in it. Sources, in order:

1. **`REPL-TEST-LEDGER.md`** — every entrypoint, invocations, positive/adversarial assertions,
   which files. The evidence base.
2. **`_coverage.py`** — G1 / G2 / G3 as numbers, with the untested lists.
3. **Findings log** — each red-team finding: hypothesis, technique that generated it, outcome,
   and the regression test that now pins it. A finding with no test is not closed.
4. **Mutation report** — mutations killed vs survived, per module.
5. **The limits section** — what REPL cannot test (above), stated plainly.

> ## RULE 7 — every red-team finding closes with a regression test, named for the finding.
> The existing `_verify_finding_*` / `_scratch_*` files are exactly this pattern from the earlier
> audits — ~32 of them, currently run by nothing. Rescuing them is P1.

---

# 5. Layout

```
REPL/
  fixtures/        mock-tf · mock-of · mock-sft · mock-nft · mock-pair · mock-pool · mock-accounts
  boot/            sandbox · stage1 · stage2 · stagezz        (deploy cores, no tests)
  modules/         one tester per MODULE          — normal + adversarial for that module
  entities/        one tester per LOGICAL ENTITY  — e.g. SWP = SWP+SWPI+SWPL+SWPLC+SWPU+MTX-SWP
  redteam/         attack suites: invariants · metamorphic · taxonomy · state-machine · cross-role
  mutation/        mutation-testing harness (grades the TESTS, not the code)
  archive/         scratch and superseded probes — never run, kept for history
  Z.repl           the single "run everything" endpoint (serial, for the published number)
  _coverage.py     prints G1 / G2 / G3 and fails on regression
  _test_ledger.py  generates the per-entrypoint test ledger (md + json)
```

> ## RULE 4 — ONE authoritative runner.
> `Z.repl` runs everything. There is no second runner with a different subset. Two gates that
> disagree is how a pricing change once passed green while executing none of the assertions
> written to protect it (`Z.repl` skipped the suite holding them).

> ## RULE 5 — every test file belongs to exactly one tester.
> No file is loaded twice in one process. Double-loading re-issues fixtures and corrupts state;
> that hazard is why the old entry points carried 24 commented-out `(load …)` lines.

---

# 6. What to write for a NEW module (the checklist)

1. **Fixtures first** — the minimum assets the module needs, from `REPL/fixtures/`.
2. **One positive test per entrypoint.** Assert the *observable outcome* (a table read, a returned
   value), never just that it did not crash.
3. **One `expect-failure` per `enforce` and per defcap rejection.** Name the assertion after the
   condition it proves, so a failure names the guarantee that broke.
4. **Boundaries** — empty list, zero amount, single element, max element, self-transfer,
   duplicate entries, and the value one past each declared bound.
5. **Authorisation** — for each defcap: the right caller succeeds, the wrong caller is rejected.
6. **Composition** — if the op composes others, assert the composite outcome, not just the legs.
7. **Cost** — if it bills, assert the charged IGNIS/STOA equals the published price
   (`IGNIS-PRICING/IGNIS-PRICE-SHEET.md`).
8. **Keep it under 2 minutes** (Rule 1). Split by concern if it grows.

> ## RULE 8 — an `expect-failure` MUST assert the expected error message.
> `(expect-failure "doc" "the expected error text" expr)`, never the two-argument form.
>
> **Measured 2026-09-09: 137 of 234 `expect-failure` assertions accept ANY failure.** Those pass if
> the code rejects for a completely different reason — a typo in the test, a wrong argument count,
> a missing capability, an unrelated guard firing first. A test that passes for the wrong reason is
> worse than no test, because it is counted as coverage. This is the single biggest quality defect
> in the current suite, and it is in the TESTS, not the code. Every one of the 137 must be
> tightened before any adversarial coverage number is published.

## Assertion style
* `(expect (format "…" [vals]) expected actual)` — one `format` for the doc string, never wrapping
  the whole `expect`.
* Batch with `(map print [ (expect …) … ])` so every line prints.
* The message states the GUARANTEE, not the mechanics: *"non-owner cannot enable Frozen LP"*, not
  *"call 3 returns false"*.

---

# 7. Status and plan

**Measured 2026-09-09.** 241 `.repl` files; `ZALL.repl` executed **66 of them (27%)** in 54 s. Its
own previous spec called for "every suite we have ever built, ~an hour" — that was never
assembled. 175 files never ran, including **~32 audit-finding regression tests**, 7 DSA suites
(155 assertions), and the whole `AQP-EXHAUSTIVE-*` family.

| phase | work | gate |
|---|---|---|
| **P0** | `fixtures/` + `boot/` extraction | — |
| **P1** | rescue the ~32 audit regressions + DSA + AQP-scale into real testers | G3 |
| **P2** | fill every module tester to its full entrypoint surface | **G1 = 100%** |
| **P3** | write the ~722 missing rejection tests; delete every `enforce` that cannot fail | **G2 = 100%** |
| **P4** | `entities/` logical-entity testers; assemble `Z.repl` | G3 |
| **P5** | `_coverage.py` in CI, failing on any regression | all |
| **P6** | red-team campaign → `redteam/` suite | (open-ended) |

P3 is the bulk and is embarrassingly parallel — one agent per module, each enumerating its own
`enforce` sites. P0–P2 are the prerequisite.

## Tooling that does not exist yet and must be built

Pact ships no test-quality tooling, so two small harnesses are part of the plan rather than
assumed:

* **Mutation harness** (`REPL/mutation/`) — apply a catalogue of source mutations (`>=` -> `>`,
  `and` -> `or`, delete an `enforce`, weaken a cap, off-by-one a bound), run the affected module
  tester, record killed vs survived. Pure scripting over `sed` + `pact`; it needs no Pact support.
* **Fuzz generator** (`REPL/redteam/_fuzz.py`) — emit `.repl` files with randomised valid inputs
  against stated invariants. The REPL is deterministic, so randomness lives in the GENERATOR and
  every generated case is reproducible from its seed. Record the seed in the file header.

## The feedback loop — G2's denominator is not fixed

The likeliest and most valuable red-team outcome is not "an attack succeeded" but **"there should
have been an `enforce` here and there isn't."** That closes as: add the guard, and the guard is a
new rejection path that needs its own test.

```
red team finds a missing guard
   -> add the enforce            (G2 denominator +1, coverage DROPS below 100%)
   -> write its rejection test   (G2 back to 100%)
   -> re-run the FULL suite      (a new enforce can legitimately break passing tests)
```

Three consequences worth stating before anyone reads a coverage number:

1. **G2 = 100% is an invariant to hold, not a milestone to reach once.** It will be re-broken by
   every productive red-team campaign, and that is the system working.
2. **A DROP in G2 after a campaign is a GOOD signal** — it means real gaps were found. A campaign
   that leaves G2 untouched found nothing, and should be read with suspicion rather than relief.
3. **Adding an `enforce` is a behaviour change.** An operation that used to succeed may now be
   rejected — correctly, because it was a bug — so every added guard requires a full-suite re-run
   and possibly a fixture correction. Budget for that; do not treat a newly-red test as a
   regression without checking which side was wrong.

The same loop applies to `IG|DETER`/`IG|COMPONENTS`: a new guard can change an op's compute cost,
so the price sheet regenerates too (`IGNIS-PRICING/IGNIS-PRICING.md`).

## Known limits of this plan

* REPL cannot reach cross-block ordering, gas-station economics, `defpact` interruption across
  blocks, or real multi-signer keyset semantics (section 4b). Those need a devnet or a formal
  model and are explicitly out of scope for the REPL suite.
* Assertion attribution in the ledger is per transaction block, not per op (section 4b note).
* G2 counts `enforce` SITES, not reachable paths: one `enforce` inside a branch may need several
  tests to cover every way of reaching it. G2 = 100% is a floor on adversarial coverage, not a
  ceiling.
