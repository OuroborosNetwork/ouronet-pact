# SWPLC

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:SWPLC -->
**On chain**

| | |
|---|---|
| module hash | `UrpNTeCvu3iR8m-H_xcLgbu3wBDUujwd4-aN4ofYTnE` |
| deployed size | 74,171 characters |
| implements | `OuronetPolicyV2`, `BrandingUsageSecondaryV2`, `SwapperLiquidityClientV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 20

`GOV`, `GOV|SWPLC_ADMIN`, `P|DT`, `P|SECURE-CALLER`, `P|SWPLC|CALLER`, `P|SWPLC|REMOTE-GOV`, `SECURE`, `SWPLC|C-ADD-CHILLED-LQ`, `SWPLC|C-ADD-DORMANT-LQ`, `SWPLC|C>ADD-FROZEN-LQ`, `SWPLC|C>ADD-GLACIAL-LQ`, `SWPLC|C>ADD-ICED-LQ`, `SWPLC|C>ADD-SLEEPING-LQ`, `SWPLC|C>ADD-STANDARD-LQ`, `SWPLC|C>DIRECT-FUEL`, `SWPLC|C>INDIRECT-FUEL`, `SWPLC|C>REMOVE_LQ`, `SWPLC|C>UPDATE-BRD`, `SWPLC|C>UPGRADE-BRD`, `SWPLC|C>X-ADD-LQ`

**Functions** — 46, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 15 | returns what an operation will charge | `URCi_AddFrozenLiquidity`, `URCi_AddFrozenLiquidityClad`, `URCi_AddGlacialLiquidity`, `URCi_AddGlacialLiquidityClad`, `URCi_AddIcedLiquidity`, `URCi_AddIcedLiquidityClad` …+9 |
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_EntityPosToID` |
| `UEV_` validators | 7 | read and enforce; may abort the transaction | `UEV_AddChilledLiquidity`, `UEV_AddDormantLiquidity`, `UEV_AddFrozenLiquidity`, `UEV_AddLiquidity`, `UEV_AddSleepingLiquidity`, `UEV_InputsForLP` …+1 |
| `C_` client | 10 | reached via Talos, never called directly | `C_Fuel`, `C_RemoveLiquidity`, `C_ToggleAddLiquidity`, `C_UpdatePendingBrandingLPs`, `C_UpgradeBrandingLPs`, `STOA-PID|C_AddFrozenLiquidity` …+4 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 20

`GOV`, `GOV|SWPLC_ADMIN`, `P|DT`, `P|SECURE-CALLER`, `P|SWPLC|CALLER`, `P|SWPLC|REMOTE-GOV`, `SECURE`, `SWPLC|C-ADD-CHILLED-LQ`, `SWPLC|C-ADD-DORMANT-LQ`, `SWPLC|C>ADD-FROZEN-LQ`, `SWPLC|C>ADD-GLACIAL-LQ`, `SWPLC|C>ADD-ICED-LQ`, `SWPLC|C>ADD-SLEEPING-LQ`, `SWPLC|C>ADD-STANDARD-LQ`, `SWPLC|C>DIRECT-FUEL`, `SWPLC|C>INDIRECT-FUEL`, `SWPLC|C>REMOVE_LQ`, `SWPLC|C>UPDATE-BRD`, `SWPLC|C>UPGRADE-BRD`, `SWPLC|C>X-ADD-LQ`

**Functions** -- 46, grouped by what the prefix promises

*Cost readers* (15) — price an operation; the exec path and the preview both call these

`URCi_AddFrozenLiquidity`, `URCi_AddFrozenLiquidityClad`, `URCi_AddGlacialLiquidity`, `URCi_AddGlacialLiquidityClad`, `URCi_AddIcedLiquidity`, `URCi_AddIcedLiquidityClad`, `URCi_AddSleepingLiquidity`, `URCi_AddSleepingLiquidityClad`, `URCi_AddStandardLiquidity`, `URCi_AddStandardLiquidityClad`, `URCi_Fuel`, `URCi_RemoveLiquidity`, `URCi_ToggleAddLiquidity`, `URCi_UpdatePendingBrandingLPs`, `URCi_UpgradeBrandingLPs`

*Derived reads* (1) — read and compute; no enforce

`URC_EntityPosToID`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (8) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AddChilledLiquidity`, `UEV_AddDormantLiquidity`, `UEV_AddFrozenLiquidity`, `UEV_AddLiquidity`, `UEV_AddSleepingLiquidity`, `UEV_InputsForLP`, `UEV_RemoveLiquidity`

*Client entry* (10) — builds the bill; reachable only through Talos

`C_Fuel`, `C_RemoveLiquidity`, `C_ToggleAddLiquidity`, `C_UpdatePendingBrandingLPs`, `C_UpgradeBrandingLPs`, `STOA-PID|C_AddFrozenLiquidity`, `STOA-PID|C_AddGlacialLiquidity`, `STOA-PID|C_AddIcedLiquidity`, `STOA-PID|C_AddSleepingLiquidity`, `STOA-PID|C_AddStandardLiquidity`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`

**Client entrypoints** -- 5

| entrypoint | preview |
|---|---|
| `SWPLC.STOA-PID|C_AddFrozenLiquidity` | `INFO-ONE.INFO_SWP|AddFrozenLiquidity` |
| `SWPLC.STOA-PID|C_AddGlacialLiquidity` | `INFO-ONE.INFO_SWP|AddGlacialLiquidity` |
| `SWPLC.STOA-PID|C_AddIcedLiquidity` | `INFO-ONE.INFO_SWP|AddIcedLiquidity` |
| `SWPLC.STOA-PID|C_AddSleepingLiquidity` | `INFO-ONE.INFO_SWP|AddSleepingLiquidity` |
| `SWPLC.STOA-PID|C_AddStandardLiquidity` | `INFO-ONE.INFO_SWP|AddStandardLiquidity` |
<!-- @end:module-page:SWPLC -->

## Traps

_To be written._
