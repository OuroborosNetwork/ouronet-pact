---
name: ouronet-x-writes-ignis
description: Ouronet protected X* writers (XI/XE/XB) — database writes only; never return IgnisCollectorV1.OutputCumulator. C_ or forward orchestrator builds UDC_* cumulators.
---

# X* writes vs C_* IGNIS returns

## Rule

- **`XI_*`**, **`XE_*`**, **`XB_*`**: **`insert` / `update` / `write`** only — body **ends** on that native op (Pact types it **`string`**; ignore for control flow). **No** trailing **`true`**, **no** **`object{IgnisCollectorV1.OutputCumulator}`**.
- For **`insert`** / **`write`** payloads that create or replace full rows, use the module's **`UDC_*`** constructor for that schema instead of hand-writing object literals. If missing, add the corresponding **`UDC_*`** first. Keep **`update`** for partial-key changes.
- **`C_*`** (and forward modules orchestrating **`XE_*`**): after **`with-capability`** and one or more **`X_*`** calls, compose **`IGNIS::UDC_*`** so the returned **`OutputCumulator`** reflects the full operation (merge when several **`X_*`** steps run).

## Why

Only the client layer should decide how to merge or order IGNIS when one **`C_*`** chains multiple **`X_*`**.

## Reference

**`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`** — **`XI_Issue`**, **`C_Issue*`**, **`XE_CreateAqpoolLink`**.

**OuronetInformational/MODULE_ARCHITECTURE.md** — Client flows table.
