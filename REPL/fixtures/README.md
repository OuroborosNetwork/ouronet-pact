# REPL/fixtures/ — minimal mock assets

**A fixture builds the smallest asset that exercises the logic (RULE 2). It is NOT a test.**

| fixture | provides | needs | cost (incl. boot) |
|---|---|---|---|
| `mock-tf.repl` | 2 DPTFs — MOCKA, MOCKB | stage00+01 | ~3.1 s |
| `mock-of.repl` | 1 DPOF — MOCKO | stage00+01 | ~3.2 s |
| `mock-tf-supply.repl` | 1,000,000 each of MOCKA/MOCKB | stage00+01 + `mock-tf` | ~3.2 s |
| `mock-collections.repl` | NFT MOCKN + SFT MOCKS, 3 nonces each | stage00+01+02 | ~5.0 s |

**Ids derive from the TICKER, not the name**: `MOCKA-98c486052a51`. Resolve with
`(U|DALOS::UDC_Makeid "MOCKA")`.

## Rules

1. **A fixture asserts only its OWN postcondition.** It must fail loudly and be blamed for its own
   breakage — never carry tests for the module under test.
2. **LOAD ONCE per process** (RULE 5). Re-loading re-issues assets and corrupts balances.
3. **Costs are DERIVED, never hardcoded** — `(UR_UsagePrice "dptf")`, not `100.0`. The existing
   derived fixtures survived a 5000x re-pricing untouched; the hardcoded ones needed 301 hand edits.
4. **Use a real/live-shaped collection only when SCALE or the live set definition IS the subject** —
   set composition, fragments, make/break, gas ladders. Everything else uses these.

## There is deliberately NO mock-pool — pools are economically bootstrapped

Attempted and abandoned, because the dependency is circular by design:

1. `SWPI::UEV_Issue` requires the pool's **first token to be a Principal** — solvable, via the
   admin `TS01-A::SWP|A_UpdatePrincipal`.
2. It then requires the pool's initial worth to clear `SWP::UR_SpawnLimit` (**1000 wSTOA**) —
   and worth is priced **through existing pools**. A freshly-issued token has no price path, and
   after boot there is no pool to provide one. Even anchoring on OURO (already a principal, 1.5M
   held by the patron) fails: with no pool, OURO itself has no wSTOA valuation.

**The first pool is the thing that creates the price path every later pool needs.** So the real
`Stage_01/[6.3]_SWP.repl` suite IS the bootstrap and cannot be replaced by a fixture — SWP and
ADMIN testers keep loading it. This is a genuine exception to RULE 2, recorded rather than
worked around.

Worth knowing for red teaming (P6): the spawn-limit check is a **price-path dependency**, which
is exactly the shape that oracle-manipulation attacks exploit.

## Why these exist

`Stage_01/[6.2]_DPTF.repl` is **1,493 lines with ZERO assertions** — a fixture builder that
module testers were loading and counting as a test suite. 15 of the 45 files the old runner
executed are like that: 11,260 lines of setup with no assertion in them. Fixtures make the
distinction explicit: setup lives here, assertions live in the tester.

## Usage price keys (easy to get wrong)

`dptf` = DPTF · **`dpmf` = DPOF** (historical DPMF→DPOF rename) · `dpsf` = SFT · `dpnf` = NFT ·
`ats` = ATS pair · `swp` = SWP pool. All derived from `IG|DETER` via `UC_StoaPrice`.
