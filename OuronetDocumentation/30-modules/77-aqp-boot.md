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
| module hash | `Rjsr0zQWkVaqo3Et1rtMqIhAjkt-jyJdFTH49_LGWgg` |
| deployed size | 100,776 characters |
| implements | `AcquisitionPoolBootV2` |
| repository source | `2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact` |

**Capabilities** — 2

`GOV`, `GOV|AQP_BOOT_ADMIN`

**Functions** — 22, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_BootStepState` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_Step14_OpenCustodiansAgency` |
| `C_` client | 19 | reached via Talos, never called directly | `C_IssueGenericEarningVault`, `C_Step0_WireImcAndGovernor`, `C_Step10_IssueMultipletFamily`, `C_Step11_WireFarmTriplet`, `C_Step12_AddFvtRewardLinks`, `C_Step12b_AddLateFvtRewardLinks` …+13 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|AQP_BOOT_ADMIN`

**Functions** -- 22, grouped by what the prefix promises

*Validators* (1) — read and enforce; failure aborts

`UEV_BootStepState`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_Step14_OpenCustodiansAgency`

*Client entry* (19) — builds the bill; reachable only through Talos

`C_IssueGenericEarningVault`, `C_Step0_WireImcAndGovernor`, `C_Step10_IssueMultipletFamily`, `C_Step11_WireFarmTriplet`, `C_Step12_AddFvtRewardLinks`, `C_Step12b_AddLateFvtRewardLinks`, `C_Step13_CreateCustodiansVault`, `C_Step1_CreateBunnySet`, `C_Step2_CreateSnakePowerAnchorClasses`, `C_Step3_CreateBoosterAnchorClasses`, `C_Step4_CreateCoreScores`, `C_Step5_CreateSubsidiaryScores`, `C_Step6_CreateOuroLpTriplet`, `C_Step7_CreatePoolsAndScores`, `C_Step7b_CreateStoicismPool`, `C_Step8_IssueFvtEntities`, `C_Step8b_IssueLateFvtEntities`, `C_Step9_AddFvtScoreEntities`, `C_Step9b_AddLateFvtScoreEntities`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:AQP-BOOT -->

## Traps

**Its naming masked a real defect for some time.** It issued four entities *named* Treasury at the vault class — which was exactly what the inverted admission rule permitted. When the rule was corrected, the fixture had to change with it. A fixture that matches a bug is indistinguishable from a fixture that matches the spec.
