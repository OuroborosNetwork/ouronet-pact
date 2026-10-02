# AQP-BOOT — acquisition bootstrap

## What it is for

Wires up the initial acquisition-pool entities.

A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the acquisition family.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-BOOT -->
**On chain**

| | |
|---|---|
| module hash | `QBNir0wfvGM5X04IKerkiwXPUyaR2GLy-MZOtISUzzc` |
| deployed size | 78,485 characters |
| implements | `AcquisitionPoolBootV1` |
| repository source | `2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact` |

**Capabilities** — 2

`GOV`, `GOV|AQP_BOOT_ADMIN`

**Functions** — 17, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_Step14_OpenCustodiansAgency` |
| `C_` client | 15 | reached via Talos, never called directly | `C_IssueGenericEarningVault`, `C_Step0_WireImcAndGovernor`, `C_Step10_IssueMultipletFamily`, `C_Step11_WireFarmTriplet`, `C_Step12_AddFvtRewardLinks`, `C_Step13_CreateCustodiansVault` …+9 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** in the repository only: `UEV_BootStepState`

**Capabilities** -- 2

`GOV`, `GOV|AQP_BOOT_ADMIN`

**Functions** -- 17, grouped by what the prefix promises

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_Step14_OpenCustodiansAgency`

*Client entry* (15) — builds the bill; reachable only through Talos

`C_IssueGenericEarningVault`, `C_Step0_WireImcAndGovernor`, `C_Step10_IssueMultipletFamily`, `C_Step11_WireFarmTriplet`, `C_Step12_AddFvtRewardLinks`, `C_Step13_CreateCustodiansVault`, `C_Step1_CreateBunnySet`, `C_Step2_CreateSnakePowerAnchorClasses`, `C_Step3_CreateBoosterAnchorClasses`, `C_Step4_CreateCoreScores`, `C_Step5_CreateSubsidiaryScores`, `C_Step6_CreateOuroLpTriplet`, `C_Step7_CreatePoolsAndScores`, `C_Step8_IssueFvtEntities`, `C_Step9_AddFvtScoreEntities`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:AQP-BOOT -->

## Traps

**Its naming masked a real defect for some time.** It issued four entities *named* Treasury at the vault class — which was exactly what the inverted admission rule permitted. When the rule was corrected, the fixture had to change with it. A fixture that matches a bug is indistinguishable from a fixture that matches the spec.
