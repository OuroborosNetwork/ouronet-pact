# Deploy/PureV15 — the lane-added-after-stake collect abort

**4 transactions, STRICT ORDER, 01 through 04.** No init step, no backfill, no manual
configuration. Deploy them in order and the round is done.

## Three defects, one root cause — all fixed here

The reported symptom was a **loud** failure: every collect from a late lane aborted in gas
simulation, nothing reached the chain, no gas was spent. Chasing it surfaced a **silent** one on
the same root cause, which was strictly worse, and this round closes both.

| | symptom | fixed by |
|---|---|---|
| **1. collect aborts** | `No row found during update` in gas simulation; lane uncollectable | the two field writers now `write` |
| **2. staking wipes the accrual** | collect reports *"Successfully collected 0.0"*; entitlement gone, permanently | the stake prelude no longer ensures the user row |
| **3. a DSA operator who also stakes** | taking a delegation fee forfeited the operator's own Tier-1 accrual | the fee credit no longer pre-creates the row |

Defect 2 was measured, not inferred — on a lane added after the stake, before the fix:

```
ROW EXISTS before stake? false
READER QUOTES before stake = 300.0
<STAKE>  ->  last-rps = 0.1    lane index = 0.1
READER QUOTES after stake = 0.0   (was 300.0)
<COLLECT> => "Successfully collected 0.0 ..."
>>> PAID = 0.0
```

No abort, no refusal, no event: the holder is paid nothing and told it worked. **Had only
defect 1 been fixed, the first affected user to stake before collecting would have lost their
whole accrual** — and the "fix" would have been what enabled them to do it quietly.

`XI_1|EnsureScoreRewardRows` (phase 2.2) inserted the absent row at `last-rps = L_i`. That is
right for a **newcomer**, who must not be paid for the period before they arrived, and wrong for
a holder who is new only to the *lane* — they have been accruing since the lane's index left
zero, and phase 2.3 then banked `deb x (L_i - L_i) = 0`. The user-row ensure is now dropped
entirely: phase 2.3's `WU_RpsUser|PendingRewards` writes the row at the read-side default `0.0`
and banks the full accrual as `pending`, and phase 2.4 (`XI_CheckpointStakeRps`) advances
`last-rps` to `L_i` afterwards. **Correct for both populations** — a genuine newcomer has
`deb-old 0`, so banks 0 and is checkpointed exactly as before. The member row is still ensured.

Both are pinned, and both were negative-tested by reintroducing the defect:

| test | asserts | fails without the fix as |
|---|---|---|
| `<<TX-AQP-C02L>>` | the payout **equals what the reader quoted** while the row was absent | abort: `No row found during update` |
| `<<TX-AQP-C02S>>` | staking **did not wipe** the accrual | `got=0.0 expected=300.0` |

## There is no repair transaction, and none is needed

**`CCp_FvtFixSlice` does not do it** — tested, and it declines: *"refreshed 0 of 1 listed
staker(s) (1 were already fresh)"*. It gates on **staleness**, and these holders are not stale;
their deb is correct and only the row is missing. There is no other entrypoint that would
materialise these rows, so a repair step would need new admin Pact code — and it would buy
nothing, because collect now creates the row itself, at the same `0.0`, and staking no longer
destroys it.

An absent row is not corrupt state. It **reads** as `(0.0, 0.0)`, which is exactly right; only
the write half ever disagreed. **Affected users simply collect, and it works — in any order,
before or after staking.**

## What this round fixes

A reward lane added to an FVT **after** users had already staked was **uncollectable by every
one of those users**. Reported live 2026-10-26: a WSTOA lane opened on `SubsidiaryTreasury`,
whose holders had staked earlier. Every collect from it died in gas simulation with

```
Error during database operation: No row found during update in table ouronet-ns.RPS_FVT|T|RPS|User
```

Nothing reached the chain and no gas was spent — the simulation refused to build the
transaction. The AURYN lane on the same treasury, which existed *before* those stakes, collected
normally. That asymmetry is the whole diagnosis.

### The defect, exactly

`FVT|T|RPS|User` holds a staker's per-lane accrual checkpoint. Its **readers** go through
`UR_FVT-RU|RpsUser`, which uses `with-default-read` and reports an absent row as
`last-rps 0.0, pending-rewards 0.0`. Its two **writers** used `update`:

| | before | after |
|---|---|---|
| `WU_RpsUser|LastRps` | `update` | `write`, carrying `pending-rewards` over at its read-side default |
| `WU_RpsUser|PendingRewards` | `update` | `write`, carrying `last-rps` over at its read-side default |

The stake path creates one row per lane **enabled at that moment**. `C_AddRewardLink` does not
backfill — it cannot, being unbounded in present stakers — so a later lane has no row for
existing holders. The read side was fine with that and priced a real payout; the write side had
nothing to `update` and aborted the whole collect. **A read/write asymmetry on one table**, and
the reader's own `@doc` had been describing the correct behaviour all along.

### Why `0.0` and not the current index

Claimable is `deb x (index - last-rps)`. Materialising the row at the **current index** — which
is what `XI_2|EnsureRpsUserRow` correctly does on the *stake* path, so a newcomer is not paid for
the period before they arrived — would pay such a holder **exactly zero** and look like a
success. `0.0` is the checkpoint these users actually have; it is what every reader has been
served since the lane opened. This makes the write side agree with the read side. **It invents no
entitlement.**

That distinction is the one the regression test exists to defend:
`REPL/Stage_02/[6.3]_AQP-COMPREHENSIVE.repl` `<<TX-AQP-C02L>>` adds a lane after a stake, asserts
the row is absent, asserts the reader quotes a payout anyway, collects, and then asserts the
**payout equals what was quoted**. A fix that materialises at the current index passes the first
three and fails the fourth.

### Why the fix is in the two field writers

An earlier attempt put it at `XI_2|BankUserTier1Pending`, reasoned about as "the single choke
point for all three paths that touch Tier-1 accrual". **It is not one**, and the test found that
immediately: `AQP-FVT.CC_Collect` reaches the row through `XE_WU_RpsUser|PendingRewards` /
`XE_WU_RpsUser|LastRps` **directly** (phases 2 and 4), bypassing it entirely.

The two field writers are the **only** `update` sites on `FVT|T|RPS|User` in the module — one
`insert` (behind an existence guard) and these two. Fixing them covers every caller **by
construction** rather than by a list of call sites that was already wrong once. All five existing
callers were then checked individually:

| call site | effect |
|---|---|
| `XI_CheckpointStakeRps` | **inert** — already guards on `URC_FvtRpsUserRowExists` and skips absent rows. This is the one place where creating a row would be *wrong* (it would checkpoint a late lane at the current index and destroy the entitlement); the existing guard still prevents it. |
| DSA operator-fee credit | **inert** — already calls `XI_2|EnsureRpsUserRow` first. |
| `XI_FixUserMemberDebIn` | **fixed** — would have aborted on a late lane. |
| `XI_SweepRecomputeUserMemberIn` | **fixed** — same. |
| `AQP-FVT.CC_Collect` phases 2 + 4 | **fixed** — the reported defect. |

## Scope: 6 modules, and why it is not 1

The change is two function bodies. Signatures, return types and `AcquisitionRewardPerShareV4`
are **untouched**, so the interface cascade rule requires nothing to follow. That reasoning is
**wrong here**, and relying on it would have shipped a broken AQP family:

```
python3 REPL/tools/_dotpin.py --upgrade RPS
```

reports **5 modules that DOT-call into RPS and therefore pin its hash** — `AQP-FVT` (65 call
sites), `AQP-VCT` (72), `MTX-AQP` (13), `AQP-DSA` (25), `AQP-INFO` (27). RPS reads its **own**
tables, so a pinned caller does not go quietly stale, it **aborts with `hash not blessed`**, and
this tree blesses nothing. They ship in the same round or the AQP family stops answering.

The closure was walked to a fixed point: none of those five has a pinned caller of its own, so
**six modules is the entire round**.

## The transactions

| # | bytes | contents |
|---|---|---|
| **01** | 302,036 | `AcquisitionRewardPerShareV4` + `RPS` — **the fix** |
| **02** | 275,219 | `AcquisitionFarmsVaultsTreasuriesV4` + `AQP-FVT` |
| **03** | 268,080 | `AcquisitionVacateV4` + `AQP-VCT`, `AqpMtxV2` + `MTX-AQP`, `DsaV3` + `AQP-DSA` |
| **04** | 116,165 | `AQP-INFO` |

Measured module gas: **1,076,512** total, fullest transaction **418,402 (21% of a block)**.
Interfaces are re-emitted ahead of their modules because a module cannot load before the
interface it implements; none of them changed.

> **Transaction 01 is 302,036 bytes against the 320,000-byte cap — 17,964 bytes of headroom.**
> Earlier drafts of this round sat 34 bytes under the cap and I trimmed comments three times to
> fit. That pressure was an artefact: the round was re-emitting five interfaces that are already
> on chain. Stripping them (see below) freed ~18 KB and the squeeze is gone. RPS is still the
> largest single module in the tree and the planner cannot split a module, so this is worth
> watching — but it is no longer urgent.

## Verified against the live chain, not just the gate

**The gate cannot catch everything here, and it did not.** `_chainsim.py --round Deploy/PureV15`
makes real `/local` calls against the chain tip, and the first run **failed**:

```
batch 1  FAIL   Interface cannot be upgraded: ouronet-ns.AcquisitionRewardPerShareV4
```

Pact refuses to deploy an interface name twice — identical bytes included. This round re-emitted
five interfaces (`AcquisitionRewardPerShareV4`, `AcquisitionFarmsVaultsTreasuriesV4`,
`AcquisitionVacateV4`, `AqpMtxV2`, `DsaV3`), all shipped in V13/V14 and all unchanged here. The
gate builds a chain from scratch, where declaring them the first time is correct, so **only a
live call could see it**. Each is now pinned in `_deploybundle.py`'s `LIVE_INTERFACES` with the
md5 of its emitted block — confirmed live by a direct `describe-module` against mainnet on
2026-10-26, not inferred from a snapshot — and the hash pin makes a future local edit to any of
them fatal rather than silent.

Re-simulated: **2/2 batches succeed against the real chain tip**, 767,128 + 224,324 gas.

## Who is actually affected — measured on chain, 2026-10-26

`SubsidiaryTreasury-x_P-KU2bWWt9`, 11 present users, 5 scores, 2 lanes:

| lane | existing `RPS|User` rows | users with ≥1 collect that aborts |
|---|---|---|
| `WSTOA-8Nh-JO8JO4F5` | **0 of 11**, on every score | **11 of 11** |
| `AURYN-8Nh-JO8JO4F5` | 7–9 of 11, by score | **6 of 11** |

Two things follow, and both matter.

**Nothing has been lost.** WSTOA collect never once succeeded, so a WSTOA row could only exist if
a stake had created it — and there are **zero**. No holder has been zeroed by defect 2; all 11
still carry their full entitlement, which is why this round needs no repair step and why there is
nothing to recover.

**It was never a WSTOA problem.** AURYN is affected for **6 of 11** users too — they staked
before the AURYN lane was opened. The reporting account happened to hold all five AURYN rows,
which is exactly why its "collect all" fired 5 AURYN transactions and 0 WSTOA.

## FOLDED IN 2026-10-26 — the Coil/Coil collect ladder, and a client amount preview

**This round carries a second, independent change.** It is in the same module (`04_RPS.pact`,
shipped as `01_deploy.pact`), so it cannot be deployed separately — read both halves before
sending batch 1.

### What changed and why

A MULTIPLET_BASE triplet collect was measured at **223,956 gas** in the REPL and **222,663 on
chain** — roughly 3x a plain single-lane collect. The route paid for work it did not need:

```
AQP -> collector  token-0  raw          <- two transfers of the SAME token
AQP -> collector  token-0  fund            in the SAME direction
Coil(ats-01, token-0, silver-share)     <- transfer + mint + transfer
Curl(ats-01, ats-12, token-0, gold)     <- transfer + mint + mint + transfer
```

**A Curl is a double Coil**, so the ladder does not need `C_Curl` at all. The route now pays the
whole payout out in ONE transfer and ladders it as `Coil(silver+gold)` on `ats-01` followed by
`Coil(remainder)` on `ats-12`. Per collect that removes **one transfer leg, one DPTF mint and one
CoilData derivation**. Separately, the two ATS viability probes sat in the binding group *above*
the mode branch — Pact evaluates a whole group before taking the branch, so the HETEROGENEOUS path
was buying three derivations it then discarded; they now sit inside the branch that reads them.

| | gas |
|---|---|
| before | 223,956 |
| Coil/Coil + merged pre-fund | 193,826 |
| + probes hoisted into their branch | **189,287** |

**−34,669, or 15.5%.** Applied to BOTH routes — `XI_1|HeterogeneousLaneRoute` and the HOMOGENEOUS
branch of `XI_TransferRewardDptfFromVault` — and to both IGNIS cost mirrors, which bill one fewer
transfer and one fewer mint accordingly. **No ATSU change**: `C_Coil`/`C_Curl` are untouched, so
`ATSU|C>COIL` still fires once per hop and the coil identity is preserved by the capability that
was always going to run. `compose-capability` on an `@event` defcap emits unconditionally
(verified in the Pact 5 evaluator's `DefEvent` branch, not assumed).

### The one behavioural difference

Payouts are **byte-identical except a single ulp**, and it lands where the code already puts its
rounding. The token-1 the collector KEEPS is still derived from the silver share ALONE — the
pre-merge `Coil(silver)` figure bit for bit — so the merge's rounding falls on the remainder leg,
which the route already documents as "the dust-free remainder":

```
before:  ouro=1800.0  auryn=228.022105742724826060678857  elite=228.022105742724826060678857
after:   ouro=1800.0  auryn=228.022105742724826060678857  elite=228.022105742724826060678858
```

`URC_RewardBearingTokenAmounts` floors `input x 1/index`, and flooring is not additive — measured,
3 of 8 sampled splits differ by 1e-24. An earlier note in this work claimed the derivation WAS
additive; that was one lucky sample and is wrong.

### New: `RPS.URC_CollectLadderPreview`

A triplet lane pays in up to three tokens, so a client showing one figure in one ticker names a
denomination the collector will not receive — the UI displayed ~16.95 OURO for a collect that paid
0.9416 OURO + 3.4254 AURYN + 1.3831 ELITE-AURYN. The preview returns
`{mode, payout, token-N-id, token-N-amount}` for N in 0..2, derived **on chain** with the same
`ATS.URC_RewardBearingTokenAmounts` the collect calls, so it is byte-identical rather than
approximate.

It and its constructor `UDC_LadderPreview` return **bare objects**, so by the interface
object-return rule they are module-only — **no interface bump and no cascade** (`defun` count moved
by exactly 2; the registry surface hash `56f3f7f008117146` is unchanged against chain+repo). A
client reaches it as `ouronet-ns.RPS.URC_CollectLadderPreview`, the same way it must already reach
`URC_ComputeTripletLanes`.

It branches on reward KIND before amount, deliberately: short-circuiting on `payout <= 0` first
left a drained LADDER lane answering with BAR token ids, indistinguishable from a plain
single-token lane — and that is the branch every lane the holder is not currently owed anything on
takes. Pinned by `<<LPG-12>>`.

### Coverage — the per-score branching, which is the risky part

In HOMOGENEOUS mode bronze routes to token-0, silver to token-1 (one coil) and golden to token-2
(two coils), so **how much to coil on the second hop is decided by which scores the holder has**.
HETEROGENEOUS splits every lane across all three tokens and MASKS that branching, so heterogeneous
numbers prove nothing about it. All four cells are now pinned against real balance deltas by
`REPL/ladder-preview-groundtruth.repl` (26 assertions, a gate entrypoint):

| profile | `rbt1-keep` | `rbt1-ladder` | second coil | pinned by |
|---|---|---|---|---|
| silver only | `= rbt1-total` | exactly 0 | skipped | `[6.4]`, byte-identical pre/post |
| golden only | 0 | `= rbt1-total` | takes everything | `<<LPG-21>>` |
| silver + golden | `> 0` | `> 0` | the subtraction | `<<LPG-22>>`/`<<LPG-26>>` |
| heterogeneous | `> 0` | `> 0` | all three tokens | `<<LPG-01>>`..`<<LPG-03>>` |

`<<LPG-19>>`/`<<LPG-20>>`/`<<LPG-21>>` state the property directly: each ladder token is paid
EXACTLY WHEN the score feeding it carries weight. "token-2 was paid", "the holder has a golden
score" and "the second coil was needed" are one statement; if the second-hop amount came from
anything but the golden share, one of the three breaks.

### ALSO FIXED — a latent misbilling in the route this work rewrote

`XI_1|HeterogeneousLaneRoute` took ONE parameter named `patron` and was CALLED with `collector`,
then used that single value as **both** the IGNIS payer and the payout recipient:

```pact
(C_Transfer patron AQP|SC_NAME patron token-0 total-t0 true)   ;; heterogeneous -- one value, two roles
(C_Transfer patron AQP|SC_NAME collector token-0 amt-b  true)  ;; homogeneous   -- correctly distinct
```

So a **sponsored** collect in heterogeneous mode billed the collector for their own IGNIS, while
the cost mirror -- which receives the real patron -- disagreed with execution about who paid. The
recipient was correct either way, so it misbilled rather than missent.

It now takes `(patron collector ...)` and threads both, matching the HOMOGENEOUS sibling.
`XI_1|` is protected and module-internal with exactly one caller, and neither it nor the mirror
is an interface member, so the arity change costs **no interface bump and no cascade**.

**It was not reachable on mainnet when fixed** -- `FVT|T|QualitySplit` holds zero rows, so every
live lane is HOMOGENEOUS -- and would have gone live the first time any FVT owner called
`C_SetQualitySplit`. It was reported by
`Audit/module-audits/AQP/MULTIPLET-COLLECT-OPTIMISATION.md` §6a and deliberately left unpatched
there for a stated reason: the branch had no test coverage. That reason no longer holds --
`REPL/ladder-preview-groundtruth.repl` is the first thing in the tree to execute it.

### One thing NOT fixed here, and it is NOT a defect

**The `fund` round trip survives.** token-0 still travels `AQP -> collector -> ATS` rather than
`AQP -> ATS`, because `C_Coil` debits its executor, so the vault must fund the collector first.
That is wasted gas -- roughly two more transfer legs -- and not incorrect behaviour. Removing it
needs a new ATSU `XE_` whose defcap composes `ATSU|C>COIL`/`ATSU|C>CURL` to keep the hibernation
guard and the `@event`; owner ruled no ATSU change this round. See
`Audit/module-audits/AQP/MULTIPLET-COLLECT-OPTIMISATION.md` §4, which costs it as a 7-file round
with no hard breaks per `_dotpin.py --upgrade ATSU`.

### Size

`01_deploy.pact` is **316,406 bytes against the planner's 320,000 cap — 3,594 bytes of headroom**,
and a single Pact module cannot be split across transactions. RPS is close to full; the next thing
added to it may not be emittable.

### Where this is NOT exercised

`SubsidiaryTreasury`'s reward links are registered with `BAR` as the family id, so it is a plain
single-token lane whose collect never reaches a coil. Collecting there validates the lane
writers above and **nothing** of the ladder change. The ladder lanes are `OuroLpFarm`
(MULTIPLET_BASE, no quality split, HOMOGENEOUS) and `CustodiansVault` (HETEROGENEOUS).

## Verification

- `python3 REPL/tools/_gate.py` — **GREEN**, receipt `2026-10-26 19:54:23`, **94 entrypoints,
  29,185 assertions executed** (23,645 positive, 5,540 negative), 0 broken suites. The lane
  writers contribute +7 (`<<TX-AQP-C02L>>` 4, `<<TX-AQP-C02S>>` 3); the collect ladder adds
  `ladder-preview-groundtruth.repl` as a 94th entrypoint (26 of its own assertions, 480 counting
  the boot chain it loads).
- **Not proven: the sponsored path of the `patron`/`collector` fix.** Every ladder assertion
  collects with `patron == collector`, which is precisely the case the fix does not change, so the
  suite cannot distinguish fixed from unfixed. The fix is reasoned, compiles and demonstrably does
  not regress self-collect; proving it needs a second account with its own agency and gas-station
  caps, measuring IGNIS balance deltas on payer vs collector. Recorded here rather than implied as
  tested.
- Negative-tested, both: reverting the writers to `update` aborts `<<TX-AQP-C02L>>` with the
  **same** `No row found during update` the chain produced; restoring the phase-2.2 user-row
  ensure fails `<<TX-AQP-C02S>>` with `got=0.0 expected=300.0`. Neither test passes without its
  fix.
- `Deploy/1_Pure` is unchanged by this round and was diffed byte-for-byte after emission.
