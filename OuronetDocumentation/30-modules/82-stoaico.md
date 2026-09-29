# STOAICO

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:STOAICO -->
**On chain**

| | |
|---|---|
| module hash | `Dnke_sFhj34abRwvKeuo2dkN9ltxwxZizVBCDB5RLIg` |
| deployed size | 51,629 characters |
| implements | `OuronetPolicyV2` |
| repository source | `2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact` |

**Tables it owns** — 4

`P|MT`, `P|T`, `STOAICO|T|General`, `STOAICO|T|User`

**Schemas** — 2

`GeneralContributionSchema`, `UserContributionSchema`

**Capabilities** — 13

`GOV`, `GOV|STOAICO_ADMIN`, `INIT-ICO-DISTRIBUTION`, `P|PAD-STOAICO|REMOTE-GOV`, `P|SECURE-CALLER`, `P|STOAICO|CALLER`, `SECURE`, `STOAICO|ADD-CONTRIBUTION`, `STOAICO|ADMIN`, `STOAICO|FLUSH`, `STOAICO|INJECT`, `STOAICO|REDEEM-CONTRIBUTION`, `STOAICO|REMOVE-CONTRIBUTION`

**Functions** — 67, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 1 | returns what an operation will charge | `URCi_Collect` |
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_UncollectedAccounts` |
| `URC_` derived reads | 3 | read and derive; no enforce | `URC_AvailableRewards`, `URC_ClaimableRewards`, `URC_IzDustSweepClaimant` |
| `UDC_` constructors | 1 | named object constructors | `UDC_UserData` |
| `UR_` readers | 20 | table reads; no enforce, no writes | `UR_Global0`, `UR_Global1`, `UR_Global10`, `UR_Global11`, `UR_Global12`, `UR_Global2` …+14 |
| `INFO_` cost previews | 1 | client-facing price preview | `INFO_Collect` |
| `XI_` protected (internal) | 17 | this module only | `XI_CollectFor`, `XI_IncrementDistributionRound`, `XI_InitialiseDistributionVault`, `XI_MarkCollected`, `XI_ResetPendingRewards`, `XI_ResetUnclaimedCount` …+11 |
| `AA_` admin (heavy) | 1 | admin key; reaches a scan somewhere in its tree | `AA_FlushUncollected` |
| `Ap_` admin recipe | 1 | multi-transaction | `Ap_FlushUncollectedSlice` |
| `A_` admin | 4 | admin-key mutations | `A_InitialiseDistributionVault`, `A_Inject`, `A_Stake`, `A_Unstake` |
| `C_` client | 1 | reached via Talos, never called directly | `C_Collect` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `CT_Namespace`, `GOV|DEMIPAD|PBL`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi` …+1 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 13

`GOV`, `GOV|STOAICO_ADMIN`, `INIT-ICO-DISTRIBUTION`, `P|PAD-STOAICO|REMOTE-GOV`, `P|SECURE-CALLER`, `P|STOAICO|CALLER`, `SECURE`, `STOAICO|ADD-CONTRIBUTION`, `STOAICO|ADMIN`, `STOAICO|FLUSH`, `STOAICO|INJECT`, `STOAICO|REDEEM-CONTRIBUTION`, `STOAICO|REMOVE-CONTRIBUTION`

**Functions** -- 67, grouped by what the prefix promises

*Cost readers* (1) — price an operation; the exec path and the preview both call these

`URCi_Collect`

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_UncollectedAccounts`

*Derived reads* (3) — read and compute; no enforce

`URC_AvailableRewards`, `URC_ClaimableRewards`, `URC_IzDustSweepClaimant`

*Point reads* (21) — one row or field by key

`P|UR_IMP`, `UR_Global0`, `UR_Global1`, `UR_Global10`, `UR_Global11`, `UR_Global12`, `UR_Global2`, `UR_Global3`, `UR_Global4`, `UR_Global5`, `UR_Global6`, `UR_Global7`, `UR_Global8`, `UR_Global9`, `UR_IzAccount`, `UR_User0`, `UR_User1`, `UR_User2`, `UR_User3`, `UR_User4`, `UR_User5`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Constructors* (1) — build objects

`UDC_UserData`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_Collect`

*Admin (heavy)* (1) — admin mutation reaching a heavy read

`AA_FlushUncollected`

*Admin* (9) — admin-key mutations

`A_InitialiseDistributionVault`, `A_Inject`, `A_Stake`, `A_Unstake`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (17) — this module only; writes under a capability

`XI_CollectFor`, `XI_IncrementDistributionRound`, `XI_InitialiseDistributionVault`, `XI_MarkCollected`, `XI_ResetPendingRewards`, `XI_ResetUnclaimedCount`, `XI_ResetUrstoaEarned`, `XI_SetZombieRewards`, `XI_UpdateNZS`, `XI_UpdatePendingRewards`, `XI_UpdateUnclaimedCount`, `XI_UpdateUrstoaEarned`, `XI_UpdateUserRPS`, `XI_UpdateUserScore`, `XI_UpdateVaultRPS`, `XI_UpdateVaultScore`, `XI_UpdateVaultSupply`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (4) — keysets and protocol constants

`GOV|DEMIPAD|PBL`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`, `GOV|LaunchpadKey`

*Previews* (1) — operation previews for clients

`INFO_Collect`

*Unclassified* (4) — no known prefix -- worth asking why

`Ap_FlushUncollectedSlice`, `CT_Bar`, `CT_Info`, `CT_Namespace`
<!-- @end:module-page:STOAICO -->

## Traps

_To be written._
