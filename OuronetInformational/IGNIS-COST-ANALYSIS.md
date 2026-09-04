# IGNIS cost analysis & re-pricing proposal (#76)

Built from `REPL/_ignis_cost_classify.py` (DPMF excluded — historic stub). Classifies every
client/admin **core** entrypoint by how its charge is built and its role, then measures the current
structure against the gate philosophy: **issue > setup > usage, and usage scales with compute.**

## Two cost currencies (the thing to hold in mind)
1. **IGNIS** — the virtual-chain gas Talos collects after every `C_`. Built two ways:
   - **DIRECT** — a flat named `GAS|<OP>` constant (`UDC_ConstructOutputCumulator GAS|X`). AQP only.
   - **FLAT** — `UDC_ConstructOutputCumulator <amount>` where the amount is a literal/computed value, not a named constant.
   - **COMPOSED** — `UDC_ConcatenateOutputCumulators` over several sub-ops = **fixed base + variable** part that scales with the runtime path (how many lanes/nonces/stakers touched).
2. **STOA** — a *native-token* fee via `UR_UsagePrice` / `STOA|C_Collect`. This is the real
   spam-gate on issuance in the non-AQP modules (DPTF/DPOF/DPNF/DPSF issue → a STOA fee).

("free" below = the core builds no cumulator itself; its cost is inherited from a **cross-module**
callee — facades/delegators — so its price lives in that other module, not here.)

## Current structure (469 core ops)
## By KIND
 {'free': 307, 'FLAT': 41, 'STOA': 6, 'COMPOSED': 93, 'DIRECT': 22}

## ROLE x KIND (op counts)

| role | DIRECT | FLAT | COMPOSED | STOA | free |
|------|-------:|----:|--------:|----:|----:|
| ISSUE | 12 | 14 | 15 | 0 | 17 |
| SETUP | 8 | 20 | 39 | 6 | 227 |
| USAGE | 2 | 7 | 39 | 0 | 63 |


## Does the structure already follow "issue > setup > usage"?

**Non-AQP world — largely YES, by construction:**
- **Issue** → a STOA `UsagePrice` fee (real token) = the anti-spam gate. ✔
- **Usage** → mostly **COMPOSED** (39 usage ops) — the stake/collect/transfer/fuel/liquidity flows
  concatenate per-leg sub-costs, so they already **scale with the operation**. ✔
- **Setup** → mostly cheap/free (227 of 300 setup ops are `free`/`FLAT`). ✔

**AQP world — NO, this is where re-pricing is needed:**
AQP is the only family on flat `GAS|` constants, and they are almost all **500 or 1000 regardless of
role or work**:

```
```

The mismatches, concretely:
- **Usage priced like setup, and flat.** `C_Collect`/`CC_Inject`/`CC_UnstaleMyScores` (ongoing legit
  usage) sit at **500** — the same as setup ops (`C_AddScore`, `C_RevokeScore` = 500) and half of
  issue (1000). Per the philosophy, usage should be the *cheapest base* and **scale with compute**;
  today it's a flat mid-tier charge that punishes frequent legit use and ignores how many
  lanes/stakers a collect/inject actually touches.
- **Heavy paths don't carry a surcharge.** The doubled `CC_`/`AA_`/defpact ops (sweep, batch inject,
  mass-unstale) walk `URH_` scans over N items but bill the same flat base as a single-item op.

## Proposed re-pricing (for your review — nothing applied yet)

A tiered base by role, with usage cheapest + a compute surcharge, keeping issuance as the gate:

| tier | role | proposed IGNIS base | rationale |
|------|------|--------------------:|-----------|
| **Gate** | ISSUE (new asset/entity: FVT, Pool, Score, Anchor, Vault, Agency) | **1000** (keep) | highest — anti-spam on creation |
| **Sub-issue** | issue *within* a family (Triplet, Multiplet, Score-from-Model) | **500** (keep) | cheaper than a fresh top-level issue |
| **Setup** | Set/Toggle/Rotate/Add/Link/Control/Oracle | **250** (↓ from 500) | below issue; config on already-paid-for entities |
| **Usage base** | Collect/Inject/Stake/Unstake/Unstale | **100** (↓ from 500) | cheapest base — legit repeated use |
| **Usage surcharge** | (added to usage base) | **+ k·writes + m·(heavy-read items)** | makes usage scale with real compute (mirrors how COMPOSED non-AQP ops already work) |
| **Maintenance** | Sync anchors | **50** (keep) | trivial upkeep |
| **Heavy batch** | CC_/AA_/defpact over N items | **base + per-item·N** | price ≥ work on the scan |

Suggested surcharge constants to start (tunable): **k = 25 / write**, **m = 5 / heavy-read item**,
per-item batch = **10 / item**. These are round numbers to react to, not derived from measured gas —
the next step (if you approve the shape) is to calibrate them against `env-gas` on the heavy paths.

**On the STOA issue fees (non-AQP):** these are the real creation gate. Recommend a quick pass to
confirm each `UsagePrice` issue tier is meaningfully above trivial usage (so cheap spam-issuance
stays gated), but the mechanism is already right — no structural change needed there.

## What I need to proceed
Approve/adjust the **tier table + surcharge shape**. Then I: (1) add the tiered `GAS|` bases +
surcharge helper to the AQP modules, (2) leave the non-AQP STOA/COMPOSED model as-is (it already
fits), (3) re-green ZALL (the cost-equality INFO ground-truths will move — I'll update expected
values in lockstep), and (4) calibrate k/m/per-item against measured gas on the heavy paths.
