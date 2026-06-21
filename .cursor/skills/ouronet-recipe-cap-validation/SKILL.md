---
name: ouronet-recipe-cap-validation
description: Validation for multi-module C_* recipes — recipe-module defcap for most phases; XE component caps when transfer/ownership needs module-local validation. XE=UEV_IMC+component cap, XI=SECURE.
---

# Recipe-cap validation

## Default rule

When a sovereign module owns a **`C_*` recipe** (e.g. **`FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`**):

1. Put **flow-level validation** in the **recipe capability** (phases 2.x as wired).
2. Recipe cap **`compose-capability (SECURE)`** for same-module **`XI_*`** writers.
3. Cross-module **`XE_*`** use **`UEV_IMC`** only unless a component cap is required (below).

## Component cap exception (transfer + ownership)

When an **`XE_*`** moves DPTF via **`TFT::C_Transfer`** to/from **`MODULE|SC_NAME`**, see **`ouronet-tft-vault-imc`** — compose **`P|MODULE-TFT`** (includes **`MODULE|GOV`**) in the component cap; do not duplicate TFT token/amount/debit UEVs.

- Put **all validation** in **`MODULE|XE>…`** on the **owning module**.
- **`XE_*`**: **`UEV_IMC`** + **`with-capability (MODULE|XE>…)`** — cap composes **`SECURE`**.
- **No separate `UEV_*` on interface** for that XE; cap body calls internal **`UEV_*`** / **`CAP_*`** helpers.

Reference: **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`** ↔ **`XE_TrueFungiblePoolCustody`**.

## Component protection

| Prefix | Default | With component cap |
|--------|---------|-------------------|
| **`XE_*`** | **`UEV_IMC`** | **`UEV_IMC`** + **`with-capability (MODULE\|XE>…)`** |
| **`XI_*`** | **`require-capability (SECURE)`** | same (SECURE from XE cap or recipe cap) |
| **`XB_*`** | **`UEV_IMC`** | same pattern as XE |

## Pattern (TF stake/unstake)

**Recipe cap** — composes **`SECURE`** for FVT **`XI_*`**; phase 1 comment only:

```pact
(defcap FVT|C>TRUE-FUNGIBLE-STAKE-FLOW (pool-id … direction:bool)
  ;; phase 1: AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (on XE call)
  ;; phase 2.x: add validation here as wired
  (compose-capability (SECURE)))
```

**POOL XE cap** — `03_AQP.pact`:

```pact
(defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (pool-id … direction:bool)
  … pool/beneficiary/tracker …
  (CAP_StakeOwner owner-id)
  (compose-capability (P|AQP|CALLER))
  (if (not direction) (compose-capability (AQP|GOV)))
  (compose-capability (SECURE)))

(defun XE_TrueFungiblePoolCustody …
  (UEV_IMC)
  (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY …)
    … XI_* …))
```

## When adding validation

- Phase with **transfer/ownership** on owning module → **`MODULE|XE>…`** cap on that module.
- Other phases → recipe cap **`;;--- phase N]`** zones, or future **`MODULE|XE>…`** as needed.
- Internal **`UEV_*`** helpers stay **off interface** unless another module must call them.

## Related skills

- **`ouronet-tft-vault-imc`** — TFT IMC + vault governor setup
- **`ouronet-talos-orchestrator-events`** — full TF stake layer map
- **`ouronet-x-writes-ignis`** — OutputCumulator returns

## Reference files

- **`04_FVT.pact`** — **`FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`**, **`C_TrueFungibleStakeFlow`**
- **`03_AQP.pact`** — **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**, **`XE_TrueFungiblePoolCustody`**
