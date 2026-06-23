---
name: ouronet-talos-orchestrator-events
description: Talos client shell for multi-module flows — AQP @event cap (compose P|TS only), sovereign C_* recipe with direction in home module (e.g. FVT), per-phase XE_* + component caps. Use for TF stake/unstake and similar orchestrated flows.
---

# Talos client shell + sovereign recipe architecture

## When this applies

Multi-module client flows where the **sovereign home module** owns the **`C_*` recipe** (e.g. TF stake/unstake in **FVT**), and **Talos** is a thin client shell (event cap + IGNIS collect + result text).

Reference: **`AQP-POOL|C_StakeTrueFungible`** / **`C_UnstakeTrueFungible`** in **`04_TS02-C3.pact`** → **`FVT::C_TrueFungibleStakeFlow`** with **`direction`**.

---

## Layer 1 — Talos (client shell)

| Rule | Detail |
|------|--------|
| **Client `@event` cap** | Core-entity prefix (e.g. **`AQP|C>STAKE-TRUE-FUNGIBLE`**) — **not** **`TS02-Cn`**. Separate caps for stake vs unstake when explorer must distinguish. |
| **Args** | Every public Talos arg, incl. **`patron`**. |
| **Cap body** | **`(compose-capability (P|TS))` only**. **Never** compose caps from other modules. |
| **Client function** | One **`with-capability`** on the client cap → **`IGNIS::C_Collect patron (sovereign C_* …)`** → format result. |

```pact
(with-capability (AQP|C>STAKE-TRUE-FUNGIBLE patron pool-id owner-id beneficiary-id dptf-id amount)
    (ref-IGNIS::C_Collect patron
        (ref-FVT::C_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true)
    )
    (UC_FormatStakeTrueFungibleResult …)
)
```

---

## Layer 2 — Sovereign recipe (`C_*` with direction)

Home module (e.g. **FVT**) owns **`C_TrueFungibleStakeFlow`**: **`direction=true`** stake, **`false`** unstake.

| Step | Detail |
|------|--------|
| 1 | **`UEV_IMC`** on **`C_*` entry** |
| 2 | **`with-capability (FVT|C>TRUE-FUNGIBLE-STAKE-FLOW … direction)`** — **all input validation here** + **`compose-capability (SECURE)`** |
| 3 | Call cross-module **`XE_*`** (POOL / ANK / SCR) and same-module **`XI_*`** (FVT phases); concat **`OutputCumulator`**s |

Category in module: **`;;stake-Unstake`** under **`{F6} [C]`**.

### Single validation site (recipe cap)

**All validation for the flow lives in the module that defines the recipe cap** — e.g. **`FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`**.

| Do | Don't |
|----|-------|
| Call **`UEV_*`** / **`CAP_*`** from any module needed (AQP pool/owner, SCR, ANK, …) inside the recipe cap | Duplicate validation on phase **`XE_*`** or **`XI_*`** component caps |
| After cap passes, components are “pulled” with minimal protection only | Add per-phase **`MODULE\|XE>…`** caps whose only job is validation |

**Component protection after validation:**

| Writer | Protection |
|--------|------------|
| **`XE_*`** (cross-module) | **`UEV_IMC`** only |
| **`XI_*`** (same-module internal) | **`require-capability (SECURE)`** |
| **`XB_*`** | **`UEV_IMC`** |

**Why:** one checklist in the recipe cap — no gaps, no redundant UEV scattered across modules.

### POOL custody exception (transfer + ownership)

**`XE_TrueFungiblePoolCustody`** carries TFT transfer to/from **`AQP|SC_NAME`**, so validation + **`CAP_StakeOwner`** live in **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** (not the FVT recipe cap):

| Entry | Guard |
|-------|--------|
| **`XE_TrueFungiblePoolCustody`** | **`UEV_IMC`** + **`with-capability (AQP\|XE>TRUE-FUNGIBLE-POOL-CUSTODY …)`** |
| Cap body | pool/dptf/beneficiary/amount checks, **`CAP_StakeOwner`**, **`compose-capability (SECURE)`** |
| **`XI_*`** writers | **`require-capability (SECURE)`** |

Other phases: validation in recipe cap or their own **`MODULE|XE>…`** caps as wired.

Example (**`FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`**): composes **`SECURE`** for FVT **`XI_*`**; phase 1 validates inside **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** when **`XE_TrueFungiblePoolCustody`** runs.

---

## X* naming

| Prefix | Callable from | UEV_IMC | On interface |
|--------|---------------|---------|--------------|
| **`C_*`** | Talos (client shell) | yes | yes (home module) |
| **`XE_*`** | Other sovereign modules | yes (on entry) | yes |
| **`XI_*`** | Same module only (`C_*`, `XE_*`, `XI_*`) | no (caller holds IMC) | no |
| **`XH_*`** | Same module helpers (ANK) | no | no |

---

## Layer 3 — Phase entry (`XE_*` cross-module, `XI_*` internal)

**No component validation caps** — validation already ran in **`FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`**.

| Phase | Module | Entry | Protection |
|-------|--------|--------|------------|
| 1] Custody | AQP-POOL | `XE_TrueFungiblePoolCustody` | **`UEV_IMC`** + **`AQP\|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** (validation + **`SECURE`**) |
| 2.1] Settle | AQP-FVT | `XI_SettleStakePendingRewards` | **`require-capability (SECURE)`** |
| 2.2] ANK | AQP-ANK | `XE_RefreshTrueFungibleStakeAnchors` | **`UEV_IMC`** only |
| 2.3] SCORE | AQP-SCORE | `XE_ApplyTrueFungibleStakeDelta` | **`UEV_IMC`** → **`XI_Apply*`** under **`SECURE`** |
| 2.4] Checkpoint | AQP-FVT | `XI_CheckpointStakeRps` | **`require-capability (SECURE)`** |

**ANK:** `XE_UpdateTrueFungibleUserAnchorValues` = cross-module (C_Sync); body delegates to **`XI_UpdateTrueFungibleUserAnchorValues`**. **`XE_Refresh*`** calls **`XI_Update*`** when wired (no double IMC).

**AQP-POOL** keeps lifecycle **`C_Issue` / `C_AddScore` / `C_RevokeScore`** and phase-1 **`XE_TrueFungiblePoolCustody`**. OF/DPDC stake, **`C_SyncTrueFungibleAnchors`**, **`C_VacatePool`** — comment-only placeholders until home module is chosen (see **`03_AQP.pact`**).

### OrtoFungible (DPOF) — Transfer vs Transmit

Talos exposes two shells: **`C_StakeOrtoFungible`**, **`C_UnstakeOrtoFungible`**. Sovereign recipe **`FVT::C_OrtoFungibleStakeFlow`** — whole-nonce **`DPOF::C_Transfer` only** (no Transmit on stake). Resolve supplies via **`DPOF::UR_NoncesSupplies`** before the Talos `@event` cap. Z|/H| SCORE multiplier is derived from `dpof-id` prefix in SCR (not a client flag).

**No ANK phase** — anchors are DPTF / DPSF / DPNF only; OF stake does not call `XE_Update*UserAnchorValues`.

---

## Layer 4 — Internal writers (`XI_*`)

**`require-capability (SECURE)`** only — caller already holds composed **`SECURE`** from recipe cap. Writes + IGNIS pricing inside module. **No** extra **`MODULE|XI>…`** caps unless they add non-validation policy (rare).

---

## Do not

- Orchestrate five **`XE_*`** phases directly in Talos when a sovereign **`C_*`** recipe exists.
- **`compose-capability`** on another module's caps from Talos.
- Add sovereign **`C_StakeTrueFungible`** on AQP-POOL when FVT owns the recipe.

---

## Reference files

- **`1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact`** — Talos client shell
- **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_FVT.pact`** — **`C_TrueFungibleStakeFlow`**, **`XI_Settle*`**, **`XI_Checkpoint*`**
- **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact`** — **`XE_TrueFungiblePoolCustody`** (phase 1 only)
- **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README_AQP.md`**
