# Deploy/PureV10 — TF reassignment, sleeping-leg multiplier, `CCp_`→`CC_` naming correction

**6 transactions, STRICT ORDER, 01 through 06.** ~1.56 MB total / ~1.03M gas (per
`_deploybundle.py --check`, the authority on emitted size — see the per-transaction table below).
Every individual transaction is well under the ~320 KB / 2.00M-gas single-transaction ceiling;
the round is 6 sends, not one, because of a real dot-pin cascade (see below) — not a batch that
has to clear atomically, but order matters: sending out of order leaves a dot-pinned caller
aborting with `"hash not blessed"` until its own re-pin catches up.

## What this round adds (three independent features)

### 1. `AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary` — new client operation

The true-fungible (native or frozen) counterpart to the OF/collectable beneficiary reassigns
already live. The owner of an already-staked TF leg can redirect part or all of its earnings to a
different beneficiary without unstaking and restaking it:

- Works on **either** leg of a pool's canonical asset — native or its `F|` frozen counterpart —
  since `dptf-id` is a free parameter, not a native-only assumption.
- **Partial by design.** A TF position carries no nonce (unlike OF/collectable, where the
  nonce IS the indivisible unit), so the owner may move any amount up to the current balance —
  splitting a position across two beneficiaries, or moving it whole.
- No asset ever moves — an ordinary TF unstake always returns the position to the owner
  regardless of who the beneficiary was, so this is pure earnings bookkeeping.
- Refuses a no-op self-reassign and an amount above the current staked/rollup balance.
- Requires the OWNER's signature, not the current beneficiary's.

**Mechanism:** `CC_TrueFungibleStakeFlow`'s phase chain (custody transfer → per-pool tracker →
cross-pool `BenDptfTotal` rollup → RPS settle prelude → ANK anchor refresh → SCORE delta →
checkpoint) is now `XI_TrueFungibleStakePhases`, taking a `move-asset` flag that gates only the
custody-transfer leg — the same extraction already done for `XI_OrtoStakePhases` and
`XI_CollectableStakePhases`. The new function runs that chain TWICE with the asset pinned: once
with `direction` false to vacate the outgoing beneficiary (settling what they earned first), once
true to credit the incoming one — `owner` fixed on both runs, never a pool account, because TF has
no custodial variant. The new `FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` defcap bounds `amount` by
BOTH the current tracker balance and the cross-pool rollup, requires `CAP_EnforceAccountOwnership`
on the owner, and validates the new beneficiary exists, is a standard account, and differs from
the current one.

**No new interface, no reader-module changes.** Neither the new function nor
`XI_TrueFungibleStakePhases` is interface-declared (matching the OF/collectable reassigns before
this round's naming fix below) — **this is flagged, not endorsed, by the interface-membership
sweep below.** `UR_AQP|DPTFTrackerBalance` / `UR_AQP|BenDptfTotalBalance` already existed and
were sufficient; no reader changes needed.

**Verification:** `TX-FVT-11` in `[6.2.4]_AQP-FVT.repl` — partial reassign, remainder reassign,
both refusal paths, no-tokens-moved, and unstake still pays the owner. Delta-based throughout
(an earlier draft that moved the pool's OBSERVED self-balance instead of just this test's own
contribution left a stray row that collided with `[6.2.5]_AQP-VCT.repl`'s later full-pool
vacate — fixed). Mutation-tested the amount bound.

### 2. `AQP-SCORE::URC_SCR|SleepingLegHeldMultiplier` — new reader, closes a UI display gap

Owner noticed sleeping legs showed no multiplier tag at all (frozen's flat `mx-frozen` showed
fine; sleeping's per-nonce, time-decayed rate had no reader that could hand it back on its own —
`URC_SCR|SleepingLegWeight`/`...HeldWeight` fold `amount × multiplier` before returning, and
amount is almost never round, so the rate can't be recovered from the result). New reader isolates
just the rate, reading the LEDGER (stamped-at-stake) clock to match what the position is actually
earning right now. Verified two ways: a REPL regression (`[6.2.17]_AQP-RERATE.repl`
`<<TX-RERATE-SAT>>`) cross-checking against `UC_MxForRemaining` called directly and against the
real credited base-score delta; then a standalone half-term-lock scenario (150 of 300 months,
mx-sleeping 1.999) run through the REAL generated TypeScript composition end-to-end, which came
back `state-mx: [1.4995]` — exactly the hand-predicted value. `poolChain.ts`'s `allPositions` now
calls it for sleeping (non-hibernating) `of` legs. No interface change (matches its direct
siblings `URC_SCR|SleepingLegWeight`/`...HeldWeight`/`UR_SCR|SleepRemainingAtStake`, none of which
are interface-declared either — again flagged by the sweep below, not endorsed).

### 3. `CCp_Reassign*` → `CC_Reassign*` — naming correction on the two already-live siblings

`CCp_ReassignOrtoStakeBeneficiary` and `CCp_ReassignCollectableStakeBeneficiary` (both live on
mainnet, confirmed `"source": "deployed"` in `Deploy/OURONET-REGISTRY.json`) renamed to
`CC_ReassignOrtoStakeBeneficiary` / `CC_ReassignCollectableStakeBeneficiary`. The `p` suffix means
one specific thing (`StoicSyntax-Prefixes.md` §2.2, "Recipe axes"): *"fed ONE SLICE of a `URH_*`
dirty-read plan, order-independent, retryable, fired in parallel"* — part of a genuine
multi-transaction Hydra sweep (preflight computes N slices → N parallel/sequential slice calls →
optional begin/finalize bracket). Neither function has that shape: no preflight, no slice object,
one `(owner, beneficiary, amount-or-nonce)` tuple per call, one atomic transaction that happens to
invoke the same underlying phase-chain helper twice. The doc names this exact failure mode: *"If a
third shape appears, give it its own letter. Overloading `p` to mean 'multi-transaction' rather
than 'parallel' is how this drifted."* The brand-new TF reassign (feature 1 above) was first
written `CCp_ReassignTrueFungibleStakeBeneficiary`, copying this same mistake from its siblings'
names without re-deriving the prefix — caught before it ever shipped, which is what prompted
fixing the two already-live ones in the same round rather than leaving three functions
inconsistently named. Renamed in `05_FVT.pact`, `04_TS02-C3.pact`, `09_AQP-INFO.pact`'s doc
strings, three REPL test files, and `REPL/tools/_registry.py`'s preflight-route table (a load-
bearing lookup keyed by entrypoint name, not just documentation). Historical references (what
PureV8 actually shipped under the old name on 2026-10-11) are left as the historical record —
only forward-looking references were updated. No defcap renamed — the C_/CC_/Cp_/CCp_ axis
applies to `defun`s only, not defcaps, which use an unrelated naming scheme.

## What ships, and why (6 transactions, in order)

| tx | module(s) | bytes | ~gas | content or re-pin? |
|---:|---|---:|---:|---|
| 01 | **AQP-SCORE** | 303,648 | 266,419 | content — feature 2 |
| 02 | **RPS** | 303,908 | 268,020 | re-pin only — dot-calls AQP-SCORE (3 call sites) |
| 03 | **AQP-FVT** | 268,166 | 111,634 | content — features 1 and 3 |
| 04 | **AQP-VCT, MTX-AQP, AQP-DSA** | 276,669 | 138,898 | re-pin only — all three dot-call RPS |
| 05 | **TS02-C3, AQP-INFO, TS02-DPAD** | 300,377 | 246,967 | content — features 1 and 3 (TS02-DPAD unchanged, co-packed) |
| 06 | **AQP-BOOT** (citizen) | 109,579 | 212 | re-pin only — dot-calls AQP-FVT (21 sites) and TS02-C3 (1 site) |

## The dot-pin cascade, in full

Walked with `_dotpin.py --upgrade <module>` from each of the three content changes (AQP-SCORE,
AQP-FVT, TS02-C3) outward until it stopped reporting new modules:

```
AQP-SCORE  --dot-pinned by-->  RPS, AQP-INFO
RPS        --dot-pinned by-->  AQP-FVT, AQP-VCT, MTX-AQP, AQP-DSA, AQP-INFO
AQP-FVT    --dot-pinned by-->  AQP-INFO, AQP-BOOT
TS02-C3    --dot-pinned by-->  AQP-INFO, AQP-BOOT
AQP-VCT, MTX-AQP, AQP-DSA  --dot-pinned by-->  AQP-INFO only (already in tx 05)
AQP-INFO, AQP-BOOT, MTX-AQP  --dot-pinned by nothing --  cascade terminates
```

`AQP-FVT`'s own dot-pin from RPS is already covered because `AQP-FVT` is itself a content change
(tx 03); its slot in the cascade just confirms tx 02 (RPS) must precede tx 03. `AQP-INFO` absorbs
re-pins from four different sources (AQP-SCORE, RPS, AQP-FVT, TS02-C3) but is itself a content
change already in tx 05, so nothing extra ships for it.

## Interface-membership sweep — found during this round, NOT included in it

Measuring this round's new functions against the owner's 2026-10-12 ruling (every user/client
function must sit in its module's own interface — see `StoicSyntax-Prefixes.md` §5 and
`HANDOFF-interface-membership-sweep.md`) found that NEITHER the new TF reassign nor the new
sleeping-multiplier reader is interface-declared — matching their direct siblings, which also
aren't. This is a real, now-documented gap, but closing it means bumping `AcquisitionFarms-
VaultsTreasuriesV1`, `TalosStageTwo_ClientThreeV2`, `AcquisitionPoolsV1` and others, each of which
cascades to every module holding a typed `module{...}` reference to it — measured at 5 MORE
modules beyond this round's 6 just for the two interfaces this round's content changes already
touch (`AQP-FVT`, `TS02-C3`), and considerably more for `AQP-POOL` alone (referenced throughout
the whole AQP family). See `HANDOFF-interface-membership-sweep.md` for the full numbers (47
sovereign RECIPE-band gaps across 7 modules) and the two paths forward. **Deliberately deferred**
rather than folded into this round — it is comparable in size to the patron/executor canon sweep
and deserves its own scoped rounds, not a same-day addition under an unrelated round's name.

## Verification

Gate green, 28,524 assertions (unchanged — the `CCp_`→`CC_` rename and the dot-pin re-pins carry
no new assertions of their own; feature 1's 6 new TF-FVT-11 assertions and feature 2's 2 new
RERATE assertions are both counted in that total already). Full regeneration cascade run after
every source change: `_pricesync.py --write`, `_docsall.py --write`, `_suite_stats.py`,
`_auditbook.py --docx`, `_deploybundle.py --write`, `_talosabi.py --write`, `_toolindex.py --write`.

Then, after sending all 6: `python3 REPL/tools/_registrylive.py --record` and
`python3 REPL/tools/_registry.py --write` (both new client-facing entrypoints — the TF reassign
and the renamed OF/collectable ones — need to reach the registry before any UI can wire a button
to them; the sleeping-multiplier reader is a dirty-read helper, not a registry entrypoint, and
needs no such step).
