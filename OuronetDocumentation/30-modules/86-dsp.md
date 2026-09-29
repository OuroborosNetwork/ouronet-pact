# DSP

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DSP -->
**On chain**

| | |
|---|---|
| module hash | `otPjv-z6iIQKqMILhC1E8z0G29ItCaiR2I0CtkkFSfM` |
| deployed size | 61,738 characters |
| implements | `OuronetPolicyV2`, `DispenserV2` |
| repository source | `2_CITIZEN/Stage_Z/03_DSP+.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 13

`DSP|GOV`, `DSP|S2-GOV`, `DSP|STAGE-ONE-MINTER`, `DSP|STAGE-TWO-FLAT`, `DSP|STAGE-TWO-INJECT`, `DSP|STAGE-TWO-INJECT-FINALIZE`, `DSP|STAGE-TWO-MINTER`, `DSP|STOICISM-MINTER`, `GOV`, `GOV|DSP_ADMIN`, `P|DRG`, `P|DSP|CALLER`, `SECURE`

**Functions** — 37, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URHC_` heavy derived reads | 1 | a scan, then derivation | `URHC_StageTwoPlan` |
| `URC_` derived reads | 4 | read and derive; no enforce | `URC_DailyKOSON`, `URC_DailyOURO`, `URC_Gassless`, `URC_StageTwoResidual` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_KosonicAutostakeSplit` |
| `AA_` admin (heavy) | 3 | admin key; reaches a scan somewhere in its tree | `AA_OuroMinterStageTwo`, `AA_OuroMinterStageTwo_InjectLeg`, `AA_OuroMinterStageTwo_InjectLegFinalize` |
| `A_` admin | 7 | admin-key mutations | `A_KosonMinterStageOne`, `A_KosonMinterStageOne_1of3`, `A_KosonMinterStageOne_2of3`, `A_KosonMinterStageOne_3of3`, `A_OuroMinterStageOne`, `A_OuroMinterStageTwo_Flat` …+1 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 12 | carries no StoicSyntax prefix | `CT_Namespace`, `GOV|CST1|SC_NAME`, `GOV|CST2|SC_NAME`, `GOV|CSTKey`, `GOV|CST|PBL`, `GOV|DSP-S2|PBL` …+6 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 13

`DSP|GOV`, `DSP|S2-GOV`, `DSP|STAGE-ONE-MINTER`, `DSP|STAGE-TWO-FLAT`, `DSP|STAGE-TWO-INJECT`, `DSP|STAGE-TWO-INJECT-FINALIZE`, `DSP|STAGE-TWO-MINTER`, `DSP|STOICISM-MINTER`, `GOV`, `GOV|DSP_ADMIN`, `P|DRG`, `P|DSP|CALLER`, `SECURE`

**Functions** -- 37, grouped by what the prefix promises

*Heavy derived reads* (1) — scan and derive -- OFF the execution path

`URHC_StageTwoPlan`

*Derived reads* (4) — read and compute; no enforce

`URC_DailyKOSON`, `URC_DailyOURO`, `URC_Gassless`, `URC_StageTwoResidual`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_KosonicAutostakeSplit`

*Admin (heavy)* (3) — admin mutation reaching a heavy read

`AA_OuroMinterStageTwo`, `AA_OuroMinterStageTwo_InjectLeg`, `AA_OuroMinterStageTwo_InjectLegFinalize`

*Admin* (12) — admin-key mutations

`A_KosonMinterStageOne`, `A_KosonMinterStageOne_1of3`, `A_KosonMinterStageOne_2of3`, `A_KosonMinterStageOne_3of3`, `A_OuroMinterStageOne`, `A_OuroMinterStageTwo_Flat`, `A_StoicismMinter`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (11) — keysets and protocol constants

`GOV|CST1|SC_NAME`, `GOV|CST2|SC_NAME`, `GOV|CSTKey`, `GOV|CST|PBL`, `GOV|DSP-S2|PBL`, `GOV|DSP-S2|SC_NAME`, `GOV|DSP1|SC_NAME`, `GOV|DSP2|SC_NAME`, `GOV|DSPKey`, `GOV|DSP|PBL`, `GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Namespace`
<!-- @end:module-page:DSP -->

## Traps

_To be written._
