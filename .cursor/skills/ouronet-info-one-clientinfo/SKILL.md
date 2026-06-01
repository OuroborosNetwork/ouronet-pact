---
name: ouronet-info-one-clientinfo
description: INFO-ONE+ ClientInfo previews — mirror Talos/C_* Ignis chains (SIP|URC_*, TFT UDC_* cumulators, UC_IfpFromOutputCumulator, nested VST|INFO_Hibernate), SWP UCX_AddLiquidity/UCX_Swap, ATSU/VST order. Use when adding or auditing InfoOneV1 INFO_* or UCX_* in 21_INFO-ONE+.pact.
---

# INFO-ONE+ ↔ execution pairing

**Canonical reference:** `OuronetInformational/skills/info-one-clientinfo-pairing.md`

That document now includes:

- Full **module inventory** (`InfoOneV1` vs extra defs: `UCX_*`, `VST|INFO_Awake`/`Slumber`, `LIQUID|INFO_*`, `ORBR|INFO_*`, extended `SWP|INFO_*`, `DPTF|INFO_ClearDispo`).
- **Cost patterns** (scalar `SIP|URC_*`, TFT cumulators, folded sums, CLAD/swap, nested INFO for Constrict/Brumate).
- **ATS** table: Talos → `ATSU` / `VST` → matching `ATS|INFO_*` steps vs `UDC_ConcatenateOutputCumulators` order in `10_ATSU.pact` / `11_VST.pact`.
- **SWP/MTX** liquidity flags and **`UCXX_AddLiquidityClientInfo`**.
- **Regression checklist** when editing client modules.

Always diff the target **`C_*`** (or `ATSU`/`VST` concatenate block) against the corresponding INFO `ifp` fold when changing gas.
