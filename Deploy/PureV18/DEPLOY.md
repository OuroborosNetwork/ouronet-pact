# Deploy/PureV18 — DEPLOY CARD

**Everything needed to send this round is in THIS folder. It is EIGHT transactions plus ONE init
transaction, in order.** Nothing from `Deploy/1_Pure`, `2_Init`, `3_Assets` or `MANIFEST.md`.
Ignore the `see Deploy/MANIFEST.md` and `Steps 1-N must have run first` lines inside the
transaction headers — boilerplate the planner emits for the from-scratch pipeline, which does not
apply to an upgrade round. This round has **no** preceding steps.

## What it is

**Reward eviction in three shapes**, and the two structural changes it forced. An FVT owner can now collect on
behalf of every staker with a positive claimable — the owner's ask, 2026-10-29: *"Evicts the
Rewards to their beneficiaries, effectively stripping all the reward tokens in the score
aggregator, by sending them to their beneficiaries."*

Two new modules: `AQP-EVCT` (reward eviction) and `AQP-RPSC` (the cost-preview surface the reward
engine had to shed to make room). Four bumped interfaces reaching 17 modules.

THE EVICTION SURFACE IS SIX ENTRYPOINTS — three shapes, each in a paid and a gasless flavour.
They differ only in how many legs one transaction carries, and the payout rule is identical:

| | legs per transaction | the client's use |
|---|---|---|
| `CC_/AA_FullEvictRewards` | all of them | tried first; the gas meter decides |
| `CC_/AA_EvictSingleReward` | exactly one | the fallback, and what a large FVT is evicted with |
| `CCp_/AAp_EvictMultiRewards` | as many as fit ~2M | fewer transactions, behind a toggle |

Owner ruling, 2026-10-30. The Single shape is the interesting one: the plan reader emits one
object per leg, so the transaction count IS the leg count — 120 transactions means 120 legs, with
no packing loop — and because one leg is one drip plus one payment, no transaction in the campaign
can approach the ceiling. Proved equal to the other two by execution: all three pay
`28.800000000000000000000000` for the same leg, and the Single cost quote equals the Multi quote
for the same one leg.

## Send these nine, in this order, and stop

| # | file | deploys | new interface | exec gas (REPL) | bytes | size gas (est.) | total (est.) | of 2M |
|---|---|---|---|---:|---:|---:|---:|---:|
| 1 | `01_deploy.pact` | ATSU + OUROBOROS + TS01-A + TS01-C2 | `AutostakeUsageV4` | 386,723 | 298,208 | ~234,800 | **~621,500** | 31%|
| 2 | `02_deploy.pact` | INFO-ONE | — | 442,754 | 223,357 | ~31,000 | **~473,800** | 24%|
| 3 | `03_deploy.pact` | RPS | `AcquisitionRewardPerShareV5` | 328,763 | 302,905 | ~261,900 | **~590,700** | 30%|
| 4 | `04_deploy.pact` | O-UI-FOURTEEN + AQP-RPSC | `AcquisitionRewardCostsV1` **(new)** | 130,214 | 77,037 | ~0 | **~130,200** | 7%|
| 5 | `05_deploy.pact` | AQP-FVT | `AcquisitionFarmsVaultsTreasuriesV5` | 309,626 | 317,569 | ~364,600 | **~674,200** | 34%|
| 6 | `06_deploy.pact` | AQP-VCT + MTX-AQP + AQP-DSA | — | 419,312 | 268,305 | ~112,000 | **~531,400** | 27%|
| 7 | `07_deploy.pact` | AQP-EVCT + TS02-C3 | `AcquisitionRewardEvictionV1` **(new)** + `TalosStageTwo_ClientThreeV6` | 259,571 | 235,473 | ~44,900 | **~304,500** | 15%|
| 8 | `08_deploy.pact` | AQP-INFO + AQP-BOOT + DSP | — | 64,205 | 294,818 | ~216,700 | **~280,900** | 14%|
| 9 | `09_init.pact` | — two IMC registrations | — | small | 1,805 | ~0 | **small** | <1% |

**Exec gas is MEASURED** in the REPL gas model by `_deploybundle.py`. **Size gas is ESTIMATED**
from the fitted law in `CLAUDE.md`, `gas_size(S) ≈ 95,225 × (S_KB/256)^7`. The seventh power is why
file 4 at 75 KB costs effectively nothing in size while file 5 at 310 KB costs more in size than in
execution. Set a limit with headroom; the fullest transaction is **34% of a block**.

## File 9 is NOT optional

```
(ouronet-ns.AQP-EVCT.P|A_AddIMP (create-capability-guard (ouronet-ns.TS02-C3.P|TALOS-SUMMONER)))
(ouronet-ns.AQP-FVT.P|A_AddIMP (create-capability-guard (ouronet-ns.AQP-EVCT.SECURE)))
```

Both halves are missing from the chain **by construction** — `AQP-EVCT` has never been deployed, so
there is nothing to re-measure. Without the first line every `AQP-EVCT|*` Talos wrapper dies on
*"None of the guards passed"* (that is `U|G::UEV_Any`, i.e. `P|UEV_IMC`). Without the second,
eviction cannot reach `AQP-FVT::XE_EvictDrip` / `XE_EvictPay`, which is where every one of its
writes actually happens.

Each line needs the **target** module's admin key: `P|A_AddIMP` opens with
`(with-capability (GOV|<TARGET>_ADMIN) …)`.

## Why the order matters

It is dependency order and three of the edges are load-bearing:

- **RPS (3) before AQP-RPSC (4)**, and both before AQP-FVT (5): AQP-FVT names
  `AcquisitionRewardCostsV1`.
- **AQP-EVCT before TS02-C3** — they share transaction 7, in that order inside the file. TS02-C3's
  four new wrappers bind `module{AcquisitionRewardEvictionV1}`.
- **AQP-INFO after TS02-C3**, which is why it sits in transaction 8 and not alongside the AQP core.
  `09_AQP-INFO.pact` calls `TS02-C3.URCi_IssueGenericEarningVault` as a **direct module
  reference**, and a direct reference resolves at DEPLOY time — unlike `ref-X::`, which resolves at
  runtime. This exact ordering killed a live round once ("Module TS02-C3 has no such member"); it is
  pinned by the round's `extra` anchor, not by luck.

## Table mode, and the one exception

All nine files are in **UPGRADE MODE**: `create-table` forms are commented out, because the tables
exist and `create-table` on an existing table ABORTS the whole transaction.

**`AQP-EVCT` is the exception and its two `create-table` calls are ACTIVE** (transaction 7, lines
~697–698). It is a genuinely new module — `_livemodules.py --check` reports it NEVER PROBED because
the source did not exist before 2026-10-29 — so its two policy tables must be created.

> **After this round ships, remove `"new": ["08b_EVCT.pact"]` from the `2026-10-v18-eviction` entry
> in `_deploybundle.py`.** Leaving it in makes the NEXT round abort transaction 1 with *"Creation of
> user table ouronet-ns.AQP-EVCT_P|T failed because the table already exists"* — which is exactly
> how the 2026-10-24 incident went.

`AQP-RPSC` needs no such exception: it declares **zero** `deftable`s.

## Five interfaces are deliberately ABSENT, and that is not an omission

Transactions 1, 2 and 8 carry modules whose files also co-host interfaces that are **already live
and unchanged**: `OuroborosV3`, `TalosStageOne_ClientTwoV3`, `InfoOneV3`, `AcquisitionPoolBootV2`,
`DispenserV3`. Pact refuses to deploy an interface name twice — identical bytes included
(*"Interface cannot be upgraded"*) — so re-emitting one aborts the transaction that carries it.

They are stripped by `_deploybundle.py`'s `LIVE_INTERFACES` registry, which **pins the md5 of each
interface block**: if one of them had changed locally, the tool refuses the round rather than
shipping a module against a contract the chain does not have. All five were confirmed live the way
that registry's own rule requires — each appears in an already-deployed module's `interfaces` list
in `Deploy/LIVE-MODULES.json`, which Pact populated from `describe-module`.

Six interfaces DO ship, and they are the four bumps plus the two new ones listed in the table.

## Verify before sending

```bash
cd "$(git rev-parse --show-toplevel)"

# 1 — exactly six interfaces across the round, and they are the right six
grep -h '^(interface ' Deploy/PureV18/0*_deploy.pact | sort      # => the 6 in the table, nothing else

# 2 — reward eviction reached the client surface: THREE shapes x paid/gasless = 6 wrappers
grep -c 'defun AQP-EVCT|' Deploy/PureV18/07_deploy.pact          # => 12 (6 declarations + 6 bodies)

# 2b — and all three shapes are present in the core, not just renamed
for n in CC_EvictSingleReward CCp_EvictMultiRewards CC_FullEvictRewards; do
  printf '%s %s\n' "$(grep -c "defun $n" Deploy/PureV18/07_deploy.pact)" "$n"   # => 2 each
done

# 3 — the gasless pair is admin-gated, not merely P|TS
grep -c 'P|ADMINISTRATIVE-SUMMONER' Deploy/PureV18/07_deploy.pact   # => 9  (defcap + 3 uses + doc refs)

# 4 — AQP-EVCT's tables are CREATED, everything else is upgrade mode
grep -c '^(create-table' Deploy/PureV18/07_deploy.pact           # => 2
grep -c '^(create-table' Deploy/PureV18/05_deploy.pact           # => 0

# 5 — the ladder coils from the pool account, not the beneficiary
grep -c 'XB_Coil' Deploy/PureV18/01_deploy.pact                  # => >=2  (ATSU: declaration + body)
grep -c 'C_Coil' Deploy/PureV18/03_deploy.pact                   # => 0    (RPS has none left)

# 6 — the cost readers really did move out of RPS. Match the DEFINITION, not the string: RPS
#     still carries one COMMENT naming the reader (module-qualified, so it resolves), and a bare
#     string grep here reported 1 and read as a leftover.
grep -c 'defun URC_CollectLadderPreview' Deploy/PureV18/03_deploy.pact # => 0
grep -c 'defun URC_CollectLadderPreview' Deploy/PureV18/04_deploy.pact # => 2  (interface + body)

# 7 — no transaction exceeds the evidence-backed byte cap
for f in Deploy/PureV18/0*_deploy.pact; do printf '%8d %s\n' "$(stat -c%s "$f")" "$f"; done | sort -rn | head -1
#   => 317,569 — under the 320,000 cap; the planner's "OVER BUDGET ALONE" warning is on the
#      SOURCE-byte proxy (AQP-FVT's source is 320,863), and upgrade mode strips enough
#      create-table to bring the EMITTED file under. Nothing was waived.
```

If any count is wrong the artefacts predate a fix. Regenerate with
`python3 REPL/tools/_deploybundle.py --round 2026-10-v18-eviction --write`, then re-copy
`01..08_deploy.pact` from `Deploy/1_Pure/` and `01_init.pact` to `09_init.pact`, and **restore
`Deploy/1_Pure` and `Deploy/2_Init` with `python3 REPL/tools/_deploybundle.py --write`** — a
`--round` run overwrites them with the round's subset, and the gate checks them against the
from-scratch pipeline.

## What was verified before this round was built

- **Gate green at 29,473 assertions** (23,854 positive, 5,619 negative).
- **The eviction differential**: `REPL/Stage_02/[6.2.18]_AQP-EVICT.repl` runs prime,
  inject+collect, inject+evict in **one transaction** on one account and asserts EXACT equality of
  the payout (`28.800000000000000000000000` both ways), the reward-per-share checkpoint, the pending
  drain and both available-reward aggregates. One transaction matters: block time does not advance
  inside it, so a live reward stream vests identically across the rounds.
- **No dust**: a whole-FVT eviction lands the lane on exactly `0.000000` — the owner's stated
  requirement, measured rather than argued.
- **The gasless pair is owner-gated as well as admin-gated**, isolated by a fixture that satisfies
  the admin gate and fails ownership.
- **The ladder restructure is amount-preserving**: 190,641 → 208,674 gas (+9.5%) with the payouts
  identical to 24 decimal places, then 208,611 after the collect core was extracted.

## After sending

```bash
python3 REPL/tools/_registrylive.py --record     # refresh the chain-confirmation sidecar
python3 REPL/tools/_livemodules.py  --probe      # refresh the deployed-source snapshot
python3 REPL/tools/_liveinventory.py --probe     # confirm AQP-EVCT's two tables now exist
```

### Then AUTHOR the two partition blocks — this one is load-bearing and nothing will remind you

`Deploy/OURONET-REGISTRY.authored.json` carries the hand-written answer to *"may this call be split,
and along which parameter"*, and **absence means DO NOT SPLIT**. So until these two blocks exist, the
one eviction entrypoint whose entire purpose is to be sliced reads as unclassified, and a correct
consumer will refuse to cut it — forcing a whole FVT's legs into one transaction, which the node gas
meter then refuses.

**They cannot be pre-authored.** This was tried: `_registry.py --check` carries an ORPHAN check on
that file and refuses a block whose key is not an entrypoint yet
(`ORPHAN -- no such entrypoint`). That check is right — the lesson `_patronslots.py` paid for is that
an authored entry outliving (or preceding) its site is an unverified claim sitting in an
authoritative file. So the blocks live here, in prose, until the chain can confirm them.

Paste into the `partition` map, keys sorted:

```json
"TS02-C3.AQP-EVCT|CCp_EvictRewards": {
  "kind": "list",
  "shape": "partition",
  "axis": "beneficiaries",
  "lockstep": ["score-entity-types", "score-entity-ids", "reward-dptf-ids"],
  "reason": "A Hydra FED SLICE, and the one entrypoint in the eviction surface whose purpose is to be cut: the client dirty-reads AQP-EVCT::URHC_BuildEvictSlicePlan, splits its output into gas-bounded slices and submits them at once. WHY ANY SUBSET IS A VALID SLICE: a leg is one beneficiary's collect on one (score-entity, reward-lane) pair, priced and paid per leg -- URCi_EvictRewards is a plain fold of AQP-RPSC::URCi_CollectFull over the legs with no cross-leg term. Proved by execution rather than read off the source: [6.2.18]_AQP-EVICT shows an evicted leg paying exactly what a self-collect pays for the same beneficiary, to 24 decimal places. PARTIAL COMPLETION IS BENIGN HERE in a way it is not for a vacate: every leg is a payout to its own beneficiary, a refused slice leaves some stakers not yet paid, and re-reading the plan returns only what is left. FOUR PARALLEL ARRAYS, SO THE LOCKSTEP IS THE SAFETY PROPERTY: cutting one and not the others is refused by UEV_EvictSliceShape, but cutting all four at DIFFERENT offsets keeps the lengths equal while every leg names the wrong combination -- paying one staker against another's score entity and reward lane, with no error."
},
"TS02-C3.AQP-EVCT|AAp_EvictRewards": { ... same block, same axis, same lockstep ... }
```

Declare the admin twin **separately rather than by cross-reference** — a consumer reads one entry and
absence means do not split, so a pointer another tool has to follow is a pointer that gets missed.
And it is the variant the daily automaton drives.

**The whole-FVT variants get NO block, and that is the answer rather than a gap.**
`AQP-EVCT|CC_FullEvictRewards` and `|AA_FullEvictRewards` take `(patron, executor, fvt-id)` — no list
argument exists to cut, so `kind=list` cannot apply; they scan and spend in the same transaction, so
they are not a chain-state cursor; and they have no ordered phases, so nothing is architectural. The
split route for a large FVT is the **sliced twin**, which is a different entrypoint rather than a
different way of calling this one. Saying nothing is that file's own convention for exactly this.

Confirm with `python3 REPL/tools/_registry.py --check` — both keys must report merged, and
`execution` should read **16** indirect-parallel rather than 14.

Then three things become possible that are blocked until the chain moves:

1. **`Deploy/OURONET-REGISTRY.json`** picks up the four new entrypoints and the four new previews,
   which unblocks `@ouronet/talos-registry` and OuronetUI. Note that
   **`INFO_AQP-FVT|Collect` gained a sixth parameter** (`collector`) — the UI's collect preview spec
   needs it or the call fails on arity.
2. **`_docspages.py --write`** generates reference pages for `AQP-EVCT` and `AQP-RPSC`. It enumerates
   DEPLOYED modules only, so the pages cannot exist before the deploy — by design, not by omission.
3. **Drop `"new": ["08b_EVCT.pact"]`** from the round entry. See the warning above.
