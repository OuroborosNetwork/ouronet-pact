# `UEV_IzLiquidStakingLive` cannot tell "no ATS pair yet" from "exactly one pair"

**Date:** 2026-09-11 · **RE-FRAMED 2026-09-12** — the original title and severity were wrong
**Status:** boot-window robustness gap, NOT a live defect. All three deep guards now pinned
(`modules/LIQUID.repl <<LQD-G1>>`); the boot-window state pinned at `[4.0] <<TX4.0-CONFIG>>`
**Site:** `1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact`, `UEV_IzLiquidStakingLive`

## CORRECTION (2026-09-12) — read this first

This note was titled *"reports LIVE when liquid staking is not live"* and filed as an open defect.
Owner ruling: **"liquid staking is live on mainnet, i dont know what you mean by saying it without
an ATS pair?"** Right on both counts, and the question is the more useful half.

**What I actually measured:** one transaction inside the **boot sequence** of `[4.0]`, at the moment
both STOA ids are set and the Autostake pair does not exist yet. **What I then wrote:** that the
function reports liveness on a chain where liquid staking is not live — phrased as a property of the
function rather than of that one transient state.

Verified on the fully deployed chain (same shape as mainnet):

| state | result | which guard |
|---|---|---|
| pair exists (`StoaLiquindex-98c486052a51`) | **`true`, correctly** | — |
| wrapped and liquid in **different** pairs | refused | 3rd: *"…not part of the same ASTS Pair"* |
| wrapped STOA in **two** pairs | refused | 1st: *"Wrapped-Stoa cannot ever be part of another…"* |
| liquid STOA in **two** pairs | refused | 2nd: *"Liquid-Stoa cannot ever be part of another…"* |
| both fields at the `[BAR]` sentinel | `true` — the gap | all three pass vacuously |

So the function is correct on a configured chain and correctly rejects every misconfiguration that
*has* a pair. The single state it cannot see is "ids set, no pair", reachable only between the tx
that sets the two STOA ids and the tx that creates the pair. **Pairs are not deleted, so mainnet is
past that window and cannot re-enter it.** Worst outcome inside the window: a downstream abort with
a less clear message than this guard's own. A boot/misconfiguration robustness gap — recorded, not
escalated.

## The second correction: "the deep guards are unpinnable" was also wrong

I wrote that the two *"another ATS-Pair"* guards were unpinnable because pointing an id at a
non-pair token does not trip them, and that reaching them would need a token genuinely in two pairs.
The premise was right; the conclusion was a failure of imagination.

**`env-module-admin` grants another module's admin inside a REPL.** So DPTF's two role fields can be
driven to any state directly, `rollback-tx` discards every write, and a follow-up transaction
(`<<LQD-G2>>`) proves nothing leaked into later suites. **Three guards came off the unreachable
list** and are now pinned with their exact messages.

Generalisable: when a guard looks unreachable because no legitimate flow produces its input, ask
**"can I write the state directly and roll it back?"** before writing it off. `env-module-admin` +
`rollback-tx` + a leakage-check transaction is a reusable pattern for state-driven (as opposed to
argument-driven) guard coverage. It is test-only — it grants in the REPL what a signer could not
grant on chain — which is exactly why the rollback and the leakage check are not optional.

## What remains true, and is the real content of this note

## Cause: a 1-element sentinel tested with a length-1 check

`DPTF::UR_RewardToken` returns **`[BAR]`** — a *one-element* list — for "not part of any pair".
The three deep guards are:

```pact
(enforce (= (length w-stoa-as-rt) 1)  "Wrapped-Stoa cannot ever be part of another ATS-Pair")
(enforce (= (length l-stoa-as-rbt) 1) "Liquid-Stoa cannot ever be part of another ATS-Pair")
(enforce (= (at 0 w-stoa-as-rt) (at 0 l-stoa-as-rbt)) "…not part of the same ASTS Pair")
```

A length-1 test **cannot distinguish "exactly one pair" from "no pair at all"**. Both sentinels pass,
and the third guard then compares `BAR` to `BAR` and agrees. All three pass vacuously.

Consequence for pinning: the two *"cannot ever be part of another ATS-Pair"* guards are not
reachable by the obvious route — pointing an id at a token with no pair does not trip them. Reaching
them needs a token genuinely in **two** pairs, which `<<LQD-G1>>` arranges with `env-module-admin`
plus `rollback-tx` (see the second correction above).

## The codebase already contains the fix

`DPOF::UEV_MoveRoleCheck` meets the identical sentinel on `UR_Verum5` and normalises it *before*
testing length:

```pact
(transfer-roles:integer (if (and (= lvf 1) (= verum-five [BAR])) 0 lvf))
```

The same normalisation here makes all three guards mean what they say. So this is a one-expression
fix with a working precedent in the same repo — not a design question.

## How it was found

Not by reading. I was trying to *pin* the two "another ATS-Pair" guards and assumed pointing an id
at a non-pair token would trip them. It did not — the call returned `true`. Printing the four role
reads showed all of them were `[BAR]`, including the **real** wrapped/silver ids, which is when the
liveness claim itself became the finding.

**The failed pinning attempt was the detection mechanism.** A guard that refuses to fire for an
input that should obviously trip it is worth one print before moving on.

## Pinned as-behaves

`<<TX4.0-CONFIG>>` asserts the boot-window `true`, plus that all four role reads are the sentinel —
so the cause is recorded next to the symptom. When the sentinel is normalised, that assertion flips
to an `expect-failure` naming whichever guard then fires. `<<LQD-G1>>` carries the other five states,
`<<LQD-G2>>` carries the no-leakage check.

## Scope: bounded by scan, and the scan took three tries

The obvious worry is that this sentinel-vs-length confusion is everywhere. **It is not — the LIQUID
pair is the only real instance.** Establishing that needed three attempts, and the first two
returned a confident clean 0:

1. *"readers whose body mentions BAR"* — found `UR_ANK|AnchorsForAsset` and flagged two AQP sites
   RISK. **False positives**: that reader returns `[]`, not `[BAR]`, so its `length` is correct.
2. *"length taken directly on the reader call"* — **0 hits**, because the real shape binds the list
   in a `let` first and takes the length of the NAME.
3. *"let-bound list from a known sentinel reader, then `(length name)`"* — 9 sites, which is the
   shape that actually occurs.

Of those 9: **3 HANDLED** (`DPOF:2213`, `TFT:1312`, `SWP:678` — all normalise the sentinel before
testing), **2 real** (the LIQUID pair), and **4 not defects**:

- `TFT:856/857` — `length-rt` / `length-rbt` are bound and **never used**. Dead bindings, not a
  miscount. Worth removing, but nothing computes on them.
- `TFT:909/925` — window-bleed in my scan: the `length` there is taken on a `UC_Search` result, not
  on the bound list. False positives.

**Method note:** a scan that returns 0 on a class you have already reproduced is wrong, not
reassuring. Both early attempts did exactly that. The shape only became visible after writing out
the real code pattern rather than the one I imagined.
