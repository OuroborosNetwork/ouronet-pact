
# TFT vault IMC + smart-account governor

## When this applies

A core module holds staked tokens on **`MODULE|SC_NAME`** (smart DALOS account) and calls **`TFT::C_Transfer`** from an **`XI_*`** / **`XE_*`** under a component cap (e.g. **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**).

Reference: **`11_VST.pact`** (`VST|GOV`, `P|TT`, `P|A_Define`), **`03_AQP.pact`** (`AQP|GOV`, inline compose in **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**).

## Checklist (module)

1. **`MODULE|GOV`** — `@doc` governor for the smart account; body `true`.
2. **Component cap** (e.g. **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**) — compose inline (no shared **`P|MODULE-TFT`** unless reused):
   - Pool/business rules + **`CAP_StakeOwner`**
   - **`compose-capability (P|MODULE|CALLER)`** for TFT IMC at call time
   - **`compose-capability (MODULE|GOV)`** whenever **`MODULE|SC_NAME`** is TFT sender **or** receiver (smart account is not free-receive) — compose **`AQP|GOV`** on **AQP-POOL** only; client never signs **`MODULE|GOV`** from another module
   - **`compose-capability (SECURE)`** for **`XI_*`**
3. **`P|A_Define`**:
   - **`ref-P|TFT::P|A_AddIMP`** `(create-capability-guard (P|MODULE|CALLER))` — required for **`TFT::C_Transfer`**
   - DALOS **`P|A_AddIMP`** only if the module calls DALOS paths protected by **`UEV_IMC`** (AQP sibling modules do not today)
4. **`AQP|SC_NAME`** / **`GOV|AQP|PBL`** canonical on **AQP-POOL** only (deploy order: ANK → SCR → AQP → FVT; siblings ref **`AQP-POOL.AQP|SC_NAME`** at runtime, not load-time defconst)

## Validation: keep vs delegate to TFT

| Keep in component cap | Delegate to **`TFT::C_Transfer`** |
|-----------------------|-----------------------------------|
| Pool class, employed scores | **`DPTF::UEV_id`** / reserved leg |
| Beneficiary account type | **`UEV_Amount`** / min-move |
| **`dptf-id` ↔ pool asset-id** | Owner wallet balance (stake debit) |
| **Unstake: `DPTFTracker` row ≥ amount** | Pause/freeze/transfer-role on token |

Unstake amount: **never** check only vault balance — use per-beneficiary tracker (subset of pool custody).

## Deploy / REPL (after module load)

```pact
(ref-AQP-POOL::P|A_Define)
(ref-TS01-C1::DALOS|C_RotateGovernor patron aqp-sc
  (create-capability-guard (AQP-POOL.AQP|GOV)))
```

Smart account must exist (**`DALOS|A_DeploySmartAccount`**) with **`AQP|SC_NAME`** before governor rotate.

REPL: **`REPL/Stage_02/[2.3]_EarningPools.repl`** — post-load tx after AQP-POOL deploy.

Deploy order sovereign modules: **ANK → SCR → AQP-POOL → FVT**. **`GOV|AQP|SC_NAME`** / **`AQP|SC_NAME`** defined only on **AQP-POOL**; ANK Ignis paths ref **`AQP-POOL.AQP|SC_NAME`** at runtime (no load-time defconst). Post-deploy wiring: **`AQP-BOOT.C_Step0_WireImcAndGovernor`** (REPL: **`Stage02_Tester`** TX-02 [5.6]).

## FVT inject/collect on AQP|SC_NAME (forward / RemoteGov)

FVT **`C>INJECT`** / **`C>COLLECT`** TFT legs use **`P|FVT|REMOTE-GOV`** (same-module compose only — never **`AQP-ANK.AQP|GOV`**).

1. **`P|FVT|REMOTE-GOV`** in **FVT** — inject/collect caps compose **`(compose-capability (P|FVT|REMOTE-GOV))`**.
2. **`FVT::P|A_Define`** — **`ref-P|AQP::P|A_Add "FVT|RemoteAqpGov"`** `(create-capability-guard (P|FVT|REMOTE-GOV))` on **AQP-POOL** `P|T`.
3. **`AQP-BOOT` Step 0** — **`C_RotateGovernor`** includes **`ref-P|AQP::P|UR "FVT|RemoteAqpGov"`** in **`UEV_GuardOfAny`**.

Vacate vault legs use **`VCT|RemoteAqpGov`** (same pattern on **AQP-VCT**).

Stake/unstake composes **`AQP-POOL.AQP|GOV`** inside **AQP-POOL** custody caps only.

## XI transfer pattern

```pact
(let ((sender (if direction owner-id vault))
      (receiver (if direction vault owner-id)))
  (ref-TFT::C_Transfer dptf-id sender receiver amount true))
```

Parent **`XE_*`** passes **`direction`** through to **`XI_*`** writers (tracker delta uses same bool).

## Related skills

- **`ouronet-recipe-cap-validation`** — component cap vs recipe cap
- **`ouronet-module-load-order`** — deploy + **`P|A_Define`** order
