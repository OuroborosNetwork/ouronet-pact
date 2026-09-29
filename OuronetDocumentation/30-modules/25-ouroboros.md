# OUROBOROS — the OURO token and the IGNIS exchange

## What it is for

The protocol's own token, and the two conversions that make the gas economy work: **sublimate** turns OURO into IGNIS, **compress** turns IGNIS back into OURO.

Both directions are **free**. Charging for the act of acquiring the means to pay would be a bootstrapping problem.

## Where it sits

At the top of the Stage-1 stack, above everything it prices against.

## What it owns, and what it exposes

<!-- @generated:module-page:OUROBOROS -->
**On chain**

| | |
|---|---|
| module hash | `6kA1wWQkFddog57qbeG86xkHz8wv1MwqjZpaKuGb7_0` |
| deployed size | 40,209 characters |
| implements | `OuronetPolicyV2`, `OuroborosV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 14

`GOV`, `GOV|ORBR_ADMIN`, `IGNIS|C>COMPRESS`, `IGNIS|C>CONVERT`, `IGNIS|C>SUBLIMATE`, `IGNIS|XB>COMPRESS`, `IGNIS|XB>CONVERT`, `LIQUIDFUEL|C>ADMIN_FUEL`, `ORBR|GOV`, `ORBR|NATIVE-AUTOMATIC`, `OUROBOROS|C>WITHDRAW`, `P|DALOS|REMOTE-GOV`, `P|ORBR|CALLER`, `SECURE`

**Functions** — 31, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 5 | returns what an operation will charge | `URCi_Compress`, `URCi_Fuel`, `URCi_Sublimate`, `URCi_SublimateV2`, `URCi_WithdrawFees` |
| `URCv_` derived reads (validating) | 2 | read + derive, with an intrinsic guard | `URCv_Compress`, `URCv_Sublimate` |
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_ProjectedStoaLiquindex` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_Exchange` |
| `XB_` protected (both) | 1 | internal and external | `XB_Compress` |
| `C_` client | 5 | reached via Talos, never called directly | `C_Compress`, `C_Fuel`, `C_Sublimate`, `C_SublimateV2`, `C_WithdrawFees` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|ORBR|GUARD`, `GOV|ORBR|SC_NAME`, `GOV|ORBR|SC_STOA-NAME` …+1 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 14

`GOV`, `GOV|ORBR_ADMIN`, `IGNIS|C>COMPRESS`, `IGNIS|C>CONVERT`, `IGNIS|C>SUBLIMATE`, `IGNIS|XB>COMPRESS`, `IGNIS|XB>CONVERT`, `LIQUIDFUEL|C>ADMIN_FUEL`, `ORBR|GOV`, `ORBR|NATIVE-AUTOMATIC`, `OUROBOROS|C>WITHDRAW`, `P|DALOS|REMOTE-GOV`, `P|ORBR|CALLER`, `SECURE`

**Functions** -- 31, grouped by what the prefix promises

*Cost readers* (5) — price an operation; the exec path and the preview both call these

`URCi_Compress`, `URCi_Fuel`, `URCi_Sublimate`, `URCi_SublimateV2`, `URCi_WithdrawFees`

*Derived reads* (1) — read and compute; no enforce

`URC_ProjectedStoaLiquindex`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Exchange`

*Client entry* (5) — builds the bill; reachable only through Talos

`C_Compress`, `C_Fuel`, `C_Sublimate`, `C_SublimateV2`, `C_WithdrawFees`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal + external* (1) — callable both ways

`XB_Compress`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (5) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|ORBR|GUARD`, `GOV|ORBR|SC_NAME`, `GOV|ORBR|SC_STOA-NAME`, `GOV|OuroborosKey`

*Unclassified* (4) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `URCv_Compress`, `URCv_Sublimate`
<!-- @end:module-page:OUROBOROS -->

## Traps

**Compress takes a fee; sublimate does not** — 15 per mille, split. The asymmetry is deliberate: entering the gas economy should be frictionless, leaving it need not be.

**The conversion rate is the OURO dollar price times one hundred**, which is exactly the peg restated: one IGNIS is one cent, so one OURO at price *p* yields 100*p* IGNIS. If the peg ever changed, this is the function that would have to change with it.
