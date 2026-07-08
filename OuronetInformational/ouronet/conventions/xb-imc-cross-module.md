
# XB + IMC cross-module writes

Use when the **same table write** is invoked from:
- the **home module** (`C_*` with owner/event caps + IGNIS), and
- a **peer module** (e.g. FVT vacate recipe) without a second public API or forward-only cap.

## Pattern

| Layer | Home module (e.g. AQP-POOL) | Caller module (e.g. AQP-FVT) |
|-------|----------------------------|------------------------------|
| Write | **`XB_SetFoo`** — `(UEV_IMC)` then `update`/`write` | Calls `ref-HOME::XB_SetFoo …` inside its own `UEV_IMC` + recipe cap |
| Public | **`C_SetFoo`** — `with-capability (OWNER-CAP …)` → **`XB_SetFoo`** → IGNIS | Does **not** duplicate XB; optional idempotent guard before call |
| IMC wire | **`P|UR_IMP`** / **`UEV_IMC`** via `U\|G::UEV_Any` | **`P\|A_Define`**: `create-capability-guard (SECURE)` → **`ref-P\|HOME::P\|A_AddIMP dg`** |
| Deploy | — | **`AQP-BOOT` Step 0** (or peer boot) must run caller **`P\|A_Define`** after both modules load |

## Naming

- **`XI_*`** — same-module only (compose **`SECURE`** from home `C_*` caps).
- **`XB_*`** — **bidirectional**: home `C_*` **and** at least one other module call it; **IMC replaces SECURE** on the write entry.
- Do **not** add a parallel **`XE_*` + `@event` cap** when IMC + existing recipe cap (e.g. vacate **`CAP_PoolOwner`**) already authorizes the orchestrator.

## Checklist

1. Add **`XB_*`** on home module + **interface** surface.
2. Home **`C_*`** keeps validation caps; body calls **`XB_*`**.
3. Caller **`P\|A_Define`** registers on **target** `P\|A_AddIMP` (mirror FVT→SCR and FVT→AQP-POOL).
4. Caller recipe: idempotent read + **`XB_*`** (no patron IGNIS for the write itself).
5. Document in home README; run **`AQP-BOOT` Step 0** in REPL after redeploy.

## Reference (canonical)

- **`AQP-POOL::XB_SetPoolStakeEnabled`** — `03_AQP.pact`
- **`AQP-FVT::P\|A_Define`** — registers on AQP-SCORE + AQP-POOL
- **`FVT::C_Vacate*`** — idempotent disable via **`XB_SetPoolStakeEnabled`**
- **`AQP-SCORE::XE_CreateFvtLink`** — older **`XE_` + IMC** pattern (forward module, single direction)

## Related

- `OuronetInformational/ouronet/conventions/x-writes-no-cumulator.md` — XB returns write only, no OutputCumulator
- `OuronetInformational/ouronet/conventions/x-function-guards.md` — SECURE / bare UEV_IMC / named cap; no enforce in X* bodies
- `OuronetInformational/ouronet/conventions/module-load-order-and-pact-refs.md` — load order + **`P\|A_Define`**
- `OuronetInformational/modules/aqp/score-links.md` — when to use **`XE_` + SCR cap** vs home **`XB_`**
