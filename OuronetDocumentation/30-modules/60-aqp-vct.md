# AQP-VCT — vacating

## What it is for

Force-unstaking an entire pool and returning every position to its owner.

It has its own module because it unwinds in a **different order** than staking: staking transfers custody first, vacating transfers it **last**, after trackers, scores and checkpoints are settled.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

Above the pools and the reward engine, coordinating both.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-VCT -->
**On chain**

| | |
|---|---|
| module hash | `smsG7xxn2xG4dRds4n7On64_mX_FaXhcgtw-XWLRcbU` |
| deployed size | 173,220 characters |
| implements | `OuronetPolicyV2`, `AcquisitionVacateV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 15

`GOV`, `GOV|VCT_ADMIN`, `P|VCT|CALLER`, `P|VCT|RECIPE`, `P|VCT|REMOTE-GOV`, `SECURE`, `VCT|C>ABORT-VACATE-POOL`, `VCT|C>COLLECTABLE-VACATE-BATCH`, `VCT|C>FINALIZE-VACATE`, `VCT|C>LEGS-COLLECTABLE-VACATE`, `VCT|C>LEGS-ORTO-FUNGIBLE-VACATE`, `VCT|C>LEGS-TRUE-FUNGIBLE-VACATE`, `VCT|C>ORTO-FUNGIBLE-VACATE-BATCH`, `VCT|C>TRUE-FUNGIBLE-VACATE`, `VCT|C>VACATE`

**Functions** — 137, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 8 | returns what an operation will charge | `URCi_BatchDrainCollectable`, `URCi_BatchDrainOrtoFungible`, `URCi_BatchDrainTrueFungible`, `URCi_BatchVacateCollectables`, `URCi_BatchVacateOrtoFungible`, `URCi_BatchVacateTrueFungible` …+2 |
| `URHC_` heavy derived reads | 7 | a scan, then derivation | `URHC_BuildVacateSlicePlan`, `URHC_VacateNonceOwnerRows`, `URHC_VacateNonceOwnerRowsRaw`, `URHC_VacateNonceTotalForKind`, `URHC_VacateOwnerCountForKind`, `URHC_VacateTfOwnerRows` …+1 |
| `URH_` heavy reads | 8 | a scan -- expensive by construction | `URH_VacateCollectableInventory`, `URH_VacateCollectableNonceRows`, `URH_VacateCollectablesPoolLegs`, `URH_VacateOfInventory`, `URH_VacateOfNonceRows`, `URH_VacateOrtoFungiblePoolLegs` …+2 |
| `URC_` derived reads | 19 | read and derive; no enforce | `URC_BatchOwnerArraysGasOk`, `URC_NonceAmountsAreZeroSentinel`, `URC_PoolFullyVacated`, `URC_ResolveOfDecimalAmountsFromTracker`, `URC_TfOwnerArraysGasOk`, `URC_VacateBatchNonceTotalOk` …+13 |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_ExecutorIzVacatePoolOwner`, `UEV_TrueFungibleStakeNotReserved` |
| `UDC_` constructors | 10 | named object constructors | `UDC_NonceSlicePayload`, `UDC_TfSlicePayload`, `UDC_VacateNonceLane`, `UDC_VacateNonceLeg`, `UDC_VacateNonceLegInventory`, `UDC_VacateNonceRow` …+4 |
| `UC_` pure compute | 29 | arguments only -- no reads, no enforce | `UC_BatchNonceTotal`, `UC_BuildNonceVacateSlicePlanFromOwnerRows`, `UC_BuildTfVacateSlicePlanFromOwnerRows`, `UC_CeilDiv`, `UC_ComputeMinSliceCount`, `UC_DecimalAmountsMatrixToInt` …+23 |
| `UR_` readers | 2 | table reads; no enforce, no writes | `UR_VacateInProgress`, `UR_VacateSessionFields` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_VctVacatePoolOwner` |
| `XI_` protected (internal) | 15 | this module only | `XI_ClearVacateInProgress`, `XI_DrainCollectableBatch`, `XI_DrainOrtoFungibleBatch`, `XI_DrainTrueFungibleFromLegs`, `XI_EnsureVacateBegun`, `XI_MaybeFinalizeVacate` …+9 |
| `XB_` protected (both) | 4 | internal and external | `XB_VacateNonFungible`, `XB_VacateOrtoFungible`, `XB_VacateSemiFungible`, `XB_VacateTrueFungible` |
| `CCp_` client recipe (heavy) | 6 | multi-transaction, reaches a scan | `CCp_BatchDrainCollectable`, `CCp_BatchDrainOrtoFungible`, `CCp_BatchDrainTrueFungible`, `CCp_BatchVacateCollectables`, `CCp_BatchVacateOrtoFungible`, `CCp_BatchVacateTrueFungible` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_FullVacate` |
| `C_` client | 2 | reached via Talos, never called directly | `C_AbortVacate`, `C_FinalizeVacate` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 14 | carries no StoicSyntax prefix | `CT_AqpScName`, `CT_Bar`, `GOV|Demiurgoi`, `XI_1|DrainCollectableUnwindBatch`, `XI_1|DrainOrtoFungibleUnwindBatch`, `XI_1|DrainTrueFungibleFromLegs` …+8 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** in the repository only: `UC_VacateOrtoDestinations`, `URCi_VacateNonFungible`, `URCi_VacateOrtoFungible`, `URCi_VacateSemiFungible`, `URCi_VacateTrueFungible`

**Capabilities** -- 15

`GOV`, `GOV|VCT_ADMIN`, `P|VCT|CALLER`, `P|VCT|RECIPE`, `P|VCT|REMOTE-GOV`, `SECURE`, `VCT|C>ABORT-VACATE-POOL`, `VCT|C>COLLECTABLE-VACATE-BATCH`, `VCT|C>FINALIZE-VACATE`, `VCT|C>LEGS-COLLECTABLE-VACATE`, `VCT|C>LEGS-ORTO-FUNGIBLE-VACATE`, `VCT|C>LEGS-TRUE-FUNGIBLE-VACATE`, `VCT|C>ORTO-FUNGIBLE-VACATE-BATCH`, `VCT|C>TRUE-FUNGIBLE-VACATE`, `VCT|C>VACATE`

**Functions** -- 137, grouped by what the prefix promises

*Cost readers* (8) — price an operation; the exec path and the preview both call these

`URCi_BatchDrainCollectable`, `URCi_BatchDrainOrtoFungible`, `URCi_BatchDrainTrueFungible`, `URCi_BatchVacateCollectables`, `URCi_BatchVacateOrtoFungible`, `URCi_BatchVacateTrueFungible`, `URCi_FinalizeVacate`, `URCi_FullVacate`

*Heavy derived reads* (7) — scan and derive -- OFF the execution path

`URHC_BuildVacateSlicePlan`, `URHC_VacateNonceOwnerRows`, `URHC_VacateNonceOwnerRowsRaw`, `URHC_VacateNonceTotalForKind`, `URHC_VacateOwnerCountForKind`, `URHC_VacateTfOwnerRows`, `URHC_VacateUnitCountForKind`

*Heavy reads* (8) — scan a table -- OFF the execution path, cost grows with data

`URH_VacateCollectableInventory`, `URH_VacateCollectableNonceRows`, `URH_VacateCollectablesPoolLegs`, `URH_VacateOfInventory`, `URH_VacateOfNonceRows`, `URH_VacateOrtoFungiblePoolLegs`, `URH_VacateTfInventory`, `URH_VacateTrueFungiblePoolLegs`

*Derived reads* (19) — read and compute; no enforce

`URC_BatchOwnerArraysGasOk`, `URC_NonceAmountsAreZeroSentinel`, `URC_PoolFullyVacated`, `URC_ResolveOfDecimalAmountsFromTracker`, `URC_TfOwnerArraysGasOk`, `URC_VacateBatchNonceTotalOk`, `URC_VacateCollectableLegBeneficiaryOk`, `URC_VacateCollectableLegsOk`, `URC_VacateCollectableNoncesSufficient`, `URC_VacateCollectableRollupSufficient`, `URC_VacateKindAssetOk`, `URC_VacateOrtoLegBeneficiaryOk`, `URC_VacateOrtoLegsOk`, `URC_VacateOrtoNoncesSufficient`, `URC_VacatePoolCollectableIds`, `URC_VacatePoolOfIds`, `URC_VacatePoolTfIds`, `URC_VacateTfLegBalancesOk`, `URC_VacateTfLegsOk`

*Point reads* (3) — one row or field by key

`P|UR_IMP`, `UR_VacateInProgress`, `UR_VacateSessionFields`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_ExecutorIzVacatePoolOwner`, `UEV_TrueFungibleStakeNotReserved`

*Constructors* (10) — build objects

`UDC_NonceSlicePayload`, `UDC_TfSlicePayload`, `UDC_VacateNonceLane`, `UDC_VacateNonceLeg`, `UDC_VacateNonceLegInventory`, `UDC_VacateNonceRow`, `UDC_VacateSlicePlan`, `UDC_VacateTfInventory`, `UDC_VacateTfLane`, `UDC_VacateTfLeg`

*Pure compute* (29) — arguments only; no reads, no enforce

`UC_BatchNonceTotal`, `UC_BuildNonceVacateSlicePlanFromOwnerRows`, `UC_BuildTfVacateSlicePlanFromOwnerRows`, `UC_CeilDiv`, `UC_ComputeMinSliceCount`, `UC_DecimalAmountsMatrixToInt`, `UC_DecimalAmountsRowToInt`, `UC_EmptyOc`, `UC_ExpandNonceOwnerRowsForGasMax`, `UC_GasMaxForKind`, `UC_MergeVacateCollectableRowIntoLegs`, `UC_MergeVacateNonceRowIntoLegs`, `UC_NonceSlicePayloadFromOwnerRows`, `UC_OwnerRowNonceTotal`, `UC_SplitNonceOwnerRowToMax`, `UC_TfLegsFromParallelArrays`, `UC_TfSlicePayloadFromOwnerRows`, `UC_VacateCollectableLegsToVacateArrays`, `UC_VacateDecimalAmountsToIntegers`, `UC_VacateKindSon`, `UC_VacateMergeDecimalNonceRowsForBeneficiary`, `UC_VacateMergeIntNonceRowsForBeneficiary`, `UC_VacateOfLegsToVacateArrays`, `UC_VacateSumAmountForBeneficiaryFromLegs`, `UC_VacateTfLegsToTftBulkArrays`, `UC_VacateUniqueBeneficiaries`, `UC_VacateUniqueBeneficiariesFromLegs`, `UC_ZeroIntAmountsMatrix`, `UC_ZeroIntAmountsRow`

*Ownership checks* (1) — account-ownership enforcement

`CAP_VctVacatePoolOwner`

*Heavy recipes* (6) — multi-transaction, reaches a heavy read

`CCp_BatchDrainCollectable`, `CCp_BatchDrainOrtoFungible`, `CCp_BatchDrainTrueFungible`, `CCp_BatchVacateCollectables`, `CCp_BatchVacateOrtoFungible`, `CCp_BatchVacateTrueFungible`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_FullVacate`

*Client entry* (2) — builds the bill; reachable only through Talos

`C_AbortVacate`, `C_FinalizeVacate`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal + external* (4) — callable both ways

`XB_VacateNonFungible`, `XB_VacateOrtoFungible`, `XB_VacateSemiFungible`, `XB_VacateTrueFungible`

*Internal writes* (26) — this module only; writes under a capability

`XI_1|DrainCollectableUnwindBatch`, `XI_1|DrainOrtoFungibleUnwindBatch`, `XI_1|DrainTrueFungibleFromLegs`, `XI_1|VacateCollectableUnwindBatch`, `XI_1|VacateOrtoFungibleUnwindBatch`, `XI_1|VacateTrueFungibleUnwindFromLegs`, `XI_2|SettleBeneficiaryRewardsOnly`, `XI_2|VacateCollectableScoreUnwind`, `XI_2|VacateOrtoFungibleScoreUnwind`, `XI_2|VacateTrueFungibleBeneficiaryUnwind`, `XI_3|RpsVacatePreZero`, `XI_ClearVacateInProgress`, `XI_DrainCollectableBatch`, `XI_DrainOrtoFungibleBatch`, `XI_DrainTrueFungibleFromLegs`, `XI_EnsureVacateBegun`, `XI_MaybeFinalizeVacate`, `XI_SetPoolFvtsVacateFrozen`, `XI_VacateCollectableBatch`, `XI_VacateCollectablesFromLegs`, `XI_VacateCollectablesPoolLegs`, `XI_VacateOrtoFungibleBatch`, `XI_VacateOrtoFungibleFromLegs`, `XI_VacateOrtoFungiblePoolLegs`, `XI_VacateTrueFungibleFromLegs`, `XI_VacateTrueFungiblePoolLegs`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_AqpScName`, `CT_Bar`
<!-- @end:module-page:AQP-VCT -->

## Traps

**It is a gas-planning problem, not a logic problem.** The cost model is measured — roughly 75,000 per beneficiary plus 4,000 per position against a 2,000,000 ceiling, so about 481 positions concentrated or 25 spread.

**There is no finalise flag.** The batch that empties the pool finishes the job, which is safe because the chain executes serially.

**The on-chain check is a backstop, not the optimizer** — the source says so: the interface sizes real batches by simulating against true gas, and the node's meter is the real enforcement. An aborted oversized batch rolls back at the submitter's cost.
