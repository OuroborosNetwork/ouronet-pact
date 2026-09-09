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

> ## RULE 1 — no single tester may exceed ~2 minutes.
> If it does, split it. This is what makes an exhaustive suite affordable: 200 testers of 60 s
> each finish in ~2 minutes wall on 16 cores. The same tests as one serial run would be 3+ hours.

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

# 5. Layout

```
REPL/
  fixtures/        mock-tf · mock-of · mock-sft · mock-nft · mock-pair · mock-pool · mock-accounts
  boot/            sandbox · stage1 · stage2 · stagezz        (deploy cores, no tests)
  modules/         one tester per MODULE          — normal + adversarial for that module
  entities/        one tester per LOGICAL ENTITY  — e.g. SWP = SWP+SWPI+SWPL+SWPLC+SWPU+MTX-SWP
  redteam/         attack suites (the third suite; grows with each campaign)
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
