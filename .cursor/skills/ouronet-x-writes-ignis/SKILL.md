---
name: ouronet-x-writes-ignis
description: Ouronet X* writers vs IGNIS OutputCumulator returns — default XI/XE/XB are write-only; Talos-orchestrated stake XE_* and C_* return cumulators built from sub-parts.
---

# X* writes vs IGNIS returns

## Default rule

- **`XI_*`**, **`XE_*`**, **`XB_*`**: **`insert` / `update` / `write`** only — body **ends** on that native op (Pact types it **`string`**; ignore for control flow). **No** trailing **`true`**, **no** **`object{IgnisCollectorV1.OutputCumulator}`**.
- For **`insert`** / **`write`** payloads that create or replace full rows, use the module's **`UDC_*`** constructor for that schema instead of hand-writing object literals. If missing, add the corresponding **`UDC_*`** first. Keep **`update`** for partial-key changes.
- **`C_*`**: after **`with-capability`** and one or more **`X_*`** calls, compose **`IGNIS::UDC_*`** so the returned **`OutputCumulator`** reflects the full operation (merge when several **`X_*`** steps run).

## Talos stake/unstake exception (AQP TF path)

**Talos is orchestrator only** — no pricing URCs in Talos.

- **Stake phase writers:** cross-module **`XE_*`** return **`OutputCumulator`**; same-module **`XI_*`** (FVT settle/checkpoint) same pattern; **`C_TrueFungibleStakeFlow`** concatenates.
- **Talos** (`AQP-POOL|C_StakeTrueFungible`): **`FVT::C_TrueFungibleStakeFlow`** with **`direction`** → **`IGNIS::C_Collect patron`**.

**Capabilities:** Talos client cap composes **`P|TS` only**; recipe in **`FVT::C_TrueFungibleStakeFlow`**; phase 1 POOL validation in **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** — see **`ouronet-talos-orchestrator-events`** / **`ouronet-recipe-cap-validation`** skills.

## Why

Only the layer that owns the operation should decide IGNIS composition. Talos orders phases and collects on the patron; each module owns its step cost.

## Reference

**`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_FVT.pact`** — **`C_TrueFungibleStakeFlow`**, phase **`XE_*`**.

**`1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact`** — Talos client shell, **`IGNIS::C_Collect`** only.

**`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`** — `C_IssueTrueFungibleAnchor` (historical pattern).

**OuronetInformational/MODULE_ARCHITECTURE.md** — Client flows table.
