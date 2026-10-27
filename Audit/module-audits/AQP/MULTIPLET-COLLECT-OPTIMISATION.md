# Multiplet collect: is de-composing the Coil/Curl ladder feasible?

**Status: ANALYSIS ONLY. No rewrite proposed for execution.** Requested 2026-10-26 after a live
OuroLpFarm triplet collect measured **222,663 gas** against roughly **75,000** for a plain
single-lane collect. The maths is correct; the question is whether the ~3x is structural or
avoidable.

**Verdict in one line: the waste is real, it is almost exactly what the owner guessed, and the
clean fix is cheap in ONE module and expensive in the other. Do the cheap half.**

## 1. What the ladder actually executes, and why

`04_RPS.pact:3645-3653`, the homogeneous MULTIPLET_BASE branch of the collect payout:

```pact
(ref-IGNIS::UDC_ConcatenateOutputCumulators
    [
        (if (> amt-b 0.0)   (ref-TFT::C_Transfer patron AQP|SC_NAME collector token-0 amt-b true)   (UC_EmptyOc))
        (if (> fund-sg 0.0) (ref-TFT::C_Transfer patron AQP|SC_NAME collector token-0 fund-sg true) (UC_EmptyOc))
        (if coil-s-ok (ref-ATSU::C_Coil patron collector ats-01 token-0 amt-s)         (UC_EmptyOc))
        (if curl-g-ok (ref-ATSU::C_Curl patron collector ats-01 ats-12 token-0 amt-g)  (UC_EmptyOc))
    ]
    [])
```

That maps one-for-one onto the trace observed on chain:

| observed | source |
|---|---|
| transfer 0.9416 OURO → me | `C_Transfer ... amt-b` (bronze stays token-0) |
| transfer 16.0066 OURO → me | `C_Transfer ... fund-sg` |
| 10.3572 OURO me → ATS, mint 3.4254 AURYN, AURYN → me | `C_Coil` |
| 5.6494 OURO me → ATS, mint 1.8684 AURYN + 1.3831 ELITE-AURYN, → me | `C_Curl` |

**`fund-sg` is the tell.** `04_RPS.pact:3620`:

```pact
(fund-sg:decimal (+ amt-s amt-g))
```

It is a transfer of `silver + gold` from the vault to the user **whose only purpose is to let
`C_Coil` / `C_Curl` take it straight back**, because those functions are written to debit the
*executor*. 16.0066 OURO makes a round trip through the collector's account to end up where the
vault could have sent it directly. The owner's reading — *"presumably because we used directly the
Coil and Curl functions"* — is exactly right, and the source names the workaround.

## 2. Where the gas goes

Per full homogeneous ladder (all three tiers non-zero), the collect makes **nine client-entrypoint
calls**: 6 × `TFT::C_Transfer` and 3 × `DPTF::C_Mint`. Each one is a `C_`, so each one
independently runs `P|UEV_IMC`, acquires its own `defcap` (with that cap's own ownership / balance
/ dispo validation), and **builds its own `OutputCumulator`**, which is then concatenated — a
4-element concat whose elements are themselves 3- and 4-element concats.

Three distinct classes of avoidable cost, in descending order of confidence:

**(a) IGNIS collection runs three times, not once.** Observed directly: `IGNIS|C>COLLECT` fires
3× — once with `AQP|SC_NAME` as interactor and twice with `|`. One logical user operation, three
billing passes over the IGNIS ledger.

**(b) `URC_RewardBearingTokenAmounts` is computed SIX times where three would do.** Counted in
source: once in the `coil-s-ok` guard, twice in the `curl-g-ok` guard (`h1`, then the `ats-12`
leg), once more inside `C_Coil`, twice more inside `C_Curl`. The guards exist only to decide
whether the ladder leg is viable, and they throw the derivation away.

**(c) One wholly redundant transfer.** `fund-sg` out, then two pull-backs — three transfers to
achieve what two vault→ATS transfers would.

Note (b) and (c) are *modest*; (a) plus the nine cumulator constructions are where the bulk sits.
**This is not a measured split.** A clean before/after needs a fixture with non-zero claimable on
a multiplet lane; `triplet-collect-golden.repl` drains its own, and a no-op collect there measures
63,256 gas — i.e. ~63k is the fixed overhead before any payout work at all. **Measure before
committing to a rewrite**; the structure says the win is real, it does not say it is 100k.

## 3. The drift problem is not hypothetical — it already exists, three ways

The owner's concern was that duplicating Coil/Curl logic would let the copies drift. That has
already happened, by composition rather than by copying:

1. `ATSU::C_Coil` / `C_Curl` — the executors.
2. `ATSU::URCi_Coil` / `URCi_Curl` — hand-maintained IGNIS cost mirrors.
3. `04_RPS.pact:2634-2738` — `XI_1|HeterogeneousLaneRoute`'s own ifp mirror, which re-derives the
   whole ladder a third time to price it (`URCi_Coil`/`URCi_Curl` called per leg).

So the ladder's shape is encoded in three places that must agree, and nothing enforces it. A
shared core **reduces** this surface; it does not create it.

## 4. Is it feasible? Two halves, very different prices

The right shape is the one the owner described: a common base that both the client function and
the collect call, with the accounts parameterised.

```
XB_CoilCore  (from, to, ats,       rt, amount) -> {rbt-id, rbt-amount}
XB_CurlCore  (from, to, ats1, ats2, rt, amount) -> {rbt-id, rbt-amount}
```

- `C_Coil`        = `XB_CoilCore(executor, executor, …)` + cumulator
- `C_VestedCoil`  = `XB_CoilCore(executor, vest-target, …)` + cumulator
- collect ladder  = `XB_CoilCore(AQP|SC_NAME, collector, …)` — **no `fund-sg`, no round trip**

**Half one — ATSU: CHEAP, and worth doing.** `AutostakeUsageV3` appears in **7** files, and
`_dotpin.py --upgrade ATSU` reports **no module dot-calls it**, so there are no `hash not blessed`
hard breaks. Extracting the core, collapsing the 6 redundant `URC_RewardBearingTokenAmounts` to 3,
and killing `fund-sg` is a contained change behind a single interface bump. The vested variants
fold in for free, which is the owner's point about `C_VestedCoil` / `C_VestedCurl`.

**Half two — TFT: EXPENSIVE, and the blocker.** The deeper win (one cumulator, one IGNIS pass)
needs the moves to stop being `C_` calls. And:

- **`09_TFT.pact` exposes NO `XE_`/`XB_` functions at all** — verified, zero matches. `C_Transfer`
  is its entire external surface. Its internals (`XI_SimpleTransfer`, `XI_ComplexTransfer`) are
  module-private.
- `05_DPTF.pact` *does* expose `XB_DebitTrueFungible` / `XB_CreditTrueFungible`, so raw ledger
  moves are reachable — but using those means **reimplementing** what `C_Transfer` wraps
  (dispo-data, hibernation, the `method` flag, royalty), which is the drift the exercise is meant
  to avoid, now in the highest-traffic path in the system.
- The honest route is adding `XE_Transfer` to TFT. `TrueFungibleTransferV3` appears in **23**
  files and `_dotpin.py --upgrade TFT` reports **2 hard breaks**.

## 5. Recommendation

**Do half one, skip half two for now.** Half one is a 7-file round with no hard breaks, removes
the `fund-sg` round trip, halves the duplicated derivation, unifies Coil/Curl/VestedCoil/VestedCurl
on one core, and shrinks the three-way drift surface to two. Half two buys the remaining IGNIS and
cumulator overhead at the price of touching the module every token movement in Ouronet goes
through — not worth it until someone has **measured** what fraction of the 222,663 that overhead
actually is.

Prerequisite for either: a gas fixture with non-zero claimable on a multiplet lane, so the
before/after is a number rather than an argument.

## 6. Two defects found while tracing this (neither is the optimisation)

### 6a. HETEROGENEOUS mode bills the collector instead of the patron — LATENT

`04_RPS.pact:3644` calls

```pact
(XI_1|HeterogeneousLaneRoute collector fvt-id reward-dptf-id mf-id amt-b amt-s amt-g prec)
```

but that function's first parameter is named **`patron`** (`:5004`), and its body uses the one value
as **both the IGNIS payer and the payout recipient**:

```pact
(if (> total-t0 0.0) (ref-TFT::C_Transfer patron AQP|SC_NAME patron token-0 total-t0 true) …)
(if coil-ok (ref-ATSU::C_Coil patron patron ats-01 token-0 total-t1) …)
```

The HOMOGENEOUS sibling keeps them distinct — `C_Transfer patron AQP|SC_NAME collector …`. So under
a **sponsored** collect in heterogeneous mode the collector pays their own IGNIS, and the cost mirror
`URC_HeterogeneousLaneRouteIgnis` — called with the real `patron` — disagrees with execution about
who is billed. The recipient is correct either way, so this misbills rather than missends.

**Not reachable on mainnet today, confirmed:** `FVT|T|QualitySplit` holds **zero rows** and
`UR_FVT-QS|Mode` defaults to `HOMOGENEOUS` (`:2229-2232`). It becomes live the first time any FVT
owner calls `C_SetQualitySplit`. RPS is already being redeployed in V15, so this is the cheap moment
to fix it — but the branch has **no test coverage at all**, which is why it is reported rather than
quietly patched.

### 6b. The UI suppresses the ladder on a measurement that has expired

`StandardAggregatorsTab.tsx`'s `RewardLadder` refuses to fetch the ladder, justified by
*"`FVT|T|MultipletFamily` holds ZERO rows on mainnet (measured 2026-10-05)"*. The same stale claim is
repeated in `src/routes/logged-in/aqp/shared/nav.tsx` and `src/lib/aqp/types.ts`.

**Measured 2026-10-26 against mainnet, it is now false:**

```
(keys ouronet-ns.RPS.FVT|T|MultipletFamily)
  => ["F|OURO-8Nh-JO8JO4F5|AURYN-8Nh-JO8JO4F5|ELITEAURYN-8Nh-JO8JO4F5"]
(ouronet-ns.AQP-FVT.UR_FVT-RG|RewardKind "OuroLpFarm-x_P-KU2bWWt9" "OURO-8Nh-JO8JO4F5")
  => "MULTIPLET_BASE"
```

AQP-BOOT Steps 10 and 11 have run since that measurement. A dated measurement used as a permanent
justification is the failure mode here — the comment was true when written and nothing re-checked it.

## 7. What the UI must show instead of one number

The client currently renders a single figure labelled **"in {lane ticker}"**
(`StandardAggregatorsTab.tsx:675-688`), which for a MULTIPLET_BASE lane asserts a denomination the
user will not receive. For the observed collect it said ~16.95 OURO; the user received
**0.9416 OURO + 3.4254 AURYN + 1.3831 ELITE-AURYN**.

**No new Pact reader is needed.** Every input is an existing unprotected reader:

| need | reader |
|---|---|
| the three lane weights + total | `RPS.URC_ComputeTripletLanes(user, pool-id, triplet-id)` |
| ladder tokens + ATS pairs | `UR_FVT-MF|Token0Id/Token1Id/Token2Id/Ats01Id/Ats12Id` |
| per-leg conversion AND the precision-skip test | `ATS.URC_RewardBearingTokenAmounts(ats, token, amount)` |
| mode + matrix | `UR_FVT-QS|Mode / BronzeSplit / SilverSplit / GoldSplit` |

`URC_RewardBearingTokenAmounts` is the function the contract itself calls for both the conversion and
the skip decision, so a preview built on it is byte-identical rather than approximate. Note
`URC_ComputeTripletLanes` returns a bare `object` and so is correctly absent from
`AcquisitionRewardPerShareV4`; a `local` read must address `ouronet-ns.RPS.…` directly.

**Separately, the UI is reading the wrong claimable function.** It calls
`URC_UserTier1AvailableRewards`; the collect pays `URC_CollectClaimableRewards`, which adds two
last-claimant dust-sweep branches, and neither includes stream vesting. The contract names the right
one for a UI — `URC_LiveClaimable` (`:1902`), *"Read-only PROJECTION … including stream time vested
up to now"*. On any lane with a live stream the displayed figure is **low**.
