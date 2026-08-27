# Unified single-boot AQP test — AQP-FULL.repl (2026-08-27)

## Goal (owner's vision)
ONE run that deploys once and exercises everything top-to-bottom — eventually all of Stage 2,
then Stage 1, then the whole system in a single process. Today's `run-aqp-audit.sh` runs 15
**separate** pact processes; each re-runs the identical full boot (Stage 00→01→02 + population +
AQP-BOOT Steps 0-12). That redundant boot — not the assertions — is ~90% of the audit wall-clock.
The unified test collapses those 15 boots into ONE.

## What shipped: `REPL/AQP-FULL.repl`
One shared boot → the **entire non-destructive AQP core** in dependency order:
ANK/SCORE/POOL, BOOT-FULL, all EXHAUSTIVE (prep/boot-pools/RPS/collect), FVT stake suites,
[6.3] golden paths, DPNF, ANK-LP, triplet-diag, FVT-admin.

**Result: 424 asserts, 0 failures — GREEN.** The whole non-destructive surface composes
perfectly under one boot. This is the committed seed of the whole-system single test.

## Why the 5 destructive tails are DEFERRED (not yet folded in)
Proven empirically (Phase A run): after the 424 green core asserts, concatenating the destructive
tails produced 9 failures + 1 hard load-fail, all **cross-scenario state bleed** — three classes:

1. **Absolute pre-state asserts.** `[6.2.8b/d]` unstale assert "no forced-fix penalty yet:
   expected 0" but `[6.2.8c]` inject-cc ran first and left 3. The assert encodes a pristine ledger.
2. **Freshness-dependent behavior.** `[6.2.7]` deb-mtx asserts "live Elite-DEB dropped: expected
   true" but inject-cc already freshened that staleness → nothing to observe.
3. **Physical fixture contention (hard abort).** `[6.2.7]` stakes `DHBunnies-98` NFs that the
   non-destructive `[6.4]_EXHAUSTIVE-DPNF` already staked → double-stake load-fail.

Root cause: every destructive tail was authored as if it owns a fresh post-COLLECT world. They
contend for the SAME shared fixtures (DHBunnies NFs, EMMA, the OURO-LP triplet) with the core and
with each other.

## The deferred work: hermetic fixture isolation (TEST-CODE ONLY)
No module/interface/cap change — pure test refactoring. For each destructive tail:
- give it its **own disjoint fixture** — dedicated account(s), DEB entity, NFs (own nonces, not
  DHBunnies-98), and where needed its own anchor — provisioned inside the scenario;
- convert **absolute** pre-state asserts to **delta-based** (measure before → act → assert the
  change), so a non-pristine starting world no longer breaks them.
Do it one tail at a time in freshen→drain→retire order, uncommenting its `(load ...)` in
AQP-FULL.repl (see the DEFERRED block there) and re-running after each.

Order to fold (load-bearing): `[6.2.8c]` inject-cc → `[6.2.8b]` unstale → `[6.2.8d]` unstale-all
→ `[6.2.7]` deb-mtx → `[6.4]` triplet-collect → `[6.2.5]` vct vacate → `[6.2.8]` sweep-cc (LAST,
retires AurynRain).

## Phase B (also deferred): fold the inline-body suites
info / stream / 6×DSA carry inline post-boot bodies (not `[6.x]` files). Extract each into a
loadable `Stage_02/[6.x]` scenario, then load after the non-destructive core. Already staged:
`Stage_02/[6.5]_AQP-INFO.repl` (read-only cost-preview asserts + AQP-INFO add-on deploy; its one
internal load path `../../1_SOVEREIGN/...` resolves identically from Stage_02/ and Kursan/).
Known fold-in risks: stream re-deploys KBN (already live in the full boot — strip that line) and
drives `env-chain-data` block-time; DSA suites define score models whose ids must not collide with
AQP-BOOT's or each other's.

## Path relativity gotcha (for whoever folds Phase B)
`Kursan/` and `Stage_02/` both sit one level under `REPL/`, so `../../<x>` resolves the SAME from
either. But a scenario in `Stage_02/` loaded from `REPL/` (AQP-FULL) sees paths relative to
`Stage_02/`; a Kursan suite loading that scenario uses `../Stage_02/<file>`. Keep scenario-internal
loads written relative to `Stage_02/`.

## Status
- AQP-FULL.repl = non-destructive core, GREEN, committed. Individual suites unchanged (fast
  spot-checks). run-aqp-audit.sh remains the full 15-suite gate until the tails are folded.
- Tasks: #71 (unified test), #72 (Phase A tails), #73 (Phase B bodies) — deferred, tracked.
- This is NOT a blocker for the remaining AQP info functions (module work, independent).
