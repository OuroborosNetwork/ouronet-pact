wrote OuronetInformational/ARCHITECTURE/AUTH-SURFACE.md  (1196 entrypoints, 863 enforcing ownership)
rface.py`. Do not edit.
> For each `C_`/`A_`, the accounts whose ownership is enforced ANYWHERE in its call tree.
> The gate requires this set to only ever GROW: an entrypoint that stops enforcing something it used to enforce is an authorisation regression, and nothing else here would catch it.

| metric | value |
|---|---|
| entrypoints scanned | 1196 |
| reaching at least one ownership enforce | 863 |
| reaching NONE | 333 |

## Per entrypoint

| module | entrypoint | enforced ownership on |
|---|---|---|
| `01_DALOS` | `A_DeploySmartAccount` | — |
| `01_DALOS` | `A_DeployStandardAccount` | — |
| `01_DALOS` | `A_MigrateLiquidFunds` | `account:string`, `executor` |
| `01_DALOS` | `A_SetAutoFueling` | `account:string`, `executor` |
| `01_DALOS` | `A_SetIgnisSourcePrice` | `account:string`, `executor` |
| `01_DALOS` | `A_ToggleAccountCreationStoa` | `account:string`, `executor` |
| `01_DALOS` | `A_ToggleGAP` | `account:string`, `executor` |
| `01_DALOS` | `A_ToggleGasCollection` | `account:string`, `executor` |
| `01_DALOS` | `A_ToggleOAPU` | `account:string`, `executor` |
| `01_DALOS` | `A_UpdatePublicKey` | — |
| `01_DALOS` | `A_UpdateUsagePrice` | `account:string`, `executor` |
| `01_DALOS` | `C_ControlSmartAccount` | `account`, `account:string` |
| `01_DALOS` | `C_DeploySmartAccount` | — |
| `01_DALOS` | `C_DeployStandardAccount` | — |
| `01_DALOS` | `C_RotateGovernor` | `account`, `account:string` |
| `01_DALOS` | `C_RotateGuard` | `account`, `account:string` |
| `01_DALOS` | `C_RotateSovereign` | `account`, `account:string` |
| `01_DALOS` | `C_RotateStoa` | `account`, `account:string` |
| `01_DALOS` | `P|A_Add` | — |
| `01_DALOS` | `P|A_AddIMP` | — |
| `01_DALOS` | `P|A_Define` | — |
| `01_DALOS` | `P|A_RemoveIMP` | — |
| `01_DALOS` | `P|A_SetIMP` | — |
| `02_IGNIS` | `C_DonateStoa` | — |
| `02_IGNIS` | `P|A_Add` | — |
| `02_IGNIS` | `P|A_AddIMP` | — |
| `02_IGNIS` | `P|A_Define` | — |
| `02_IGNIS` | `P|A_RemoveIMP` | — |
| `02_IGNIS` | `P|A_SetIMP` | — |
| `04_BRD` | `A_Live` | `account:string`, `executor` |
| `04_BRD` | `A_SetFlag` | `account:string`, `executor` |
| `04_BRD` | `P|A_Add` | — |
| `04_BRD` | `P|A_AddIMP` | — |
| `04_BRD` | `P|A_Define` | — |
| `04_BRD` | `P|A_RemoveIMP` | — |
| `04_BRD` | `P|A_SetIMP` | — |
| `05_DPTF` | `A_UpdateTreasury` | `account:string`, `executor` |
| `05_DPTF` | `A_WipeTreasuryDebt` | `UR_Konto`, `account:string`, `client`, `executor`, `id`, `id:string` |
| `05_DPTF` | `A_WipeTreasuryDebtPartial` | `UR_Konto`, `account:string`, `client`, `executor`, `id`, `id:string` |
| `05_DPTF` | `C_Burn` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_Control` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_Issue` | `account`, `account:string` |
| `05_DPTF` | `C_Mint` | `UR_Konto`, `account:string`, `client`, `id`, `id:string` |
| `05_DPTF` | `C_RotateOwnership` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_SetFee` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_SetFeeTarget` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_SetMinMove` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleBurnRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleFee` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleFeeExemptionRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleFeeLock` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleFreezeAccount` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleMintRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_TogglePause` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleReservation` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_ToggleTransferRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_UpdatePendingBranding` | `URCv_Parent`, `UR_Konto`, `account:string`, `id:string` |
| `05_DPTF` | `C_UpgradeBranding` | `URCv_Parent`, `UR_Konto`, `account:string`, `entity-owner-account`, `id:string` |
| `05_DPTF` | `C_Wipe` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `C_WipeSlim` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `05_DPTF` | `P|A_Add` | — |
| `05_DPTF` | `P|A_AddIMP` | — |
| `05_DPTF` | `P|A_Define` | — |
| `05_DPTF` | `P|A_RemoveIMP` | — |
| `05_DPTF` | `P|A_SetIMP` | — |
| `06_DPOF` | `CC_WipeHeavy` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_AddQuantity` | `account:string`, `client` |
| `06_DPOF` | `C_BulkTransfer` | `account:string`, `sender` |
| `06_DPOF` | `C_Burn` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_Control` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_Issue` | `account`, `account:string` |
| `06_DPOF` | `C_Mint` | `account:string`, `client` |
| `06_DPOF` | `C_MoveCreateRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_RotateOwnership` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_ToggleAddQuantityRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_ToggleBurnRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_ToggleFreezeAccount` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_TogglePause` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_ToggleTransferRole` | `UR_Konto`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_Transfer` | `account:string`, `receiver`, `sender` |
| `06_DPOF` | `C_Transmit` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver` |
| `06_DPOF` | `C_UpdatePendingBranding` | `UR_Konto`, `account:string`, `id`, `id:string`, `parent` |
| `06_DPOF` | `C_UpgradeBranding` | `UR_Konto`, `account:string`, `entity-owner-account`, `id`, `id:string`, `parent` |
| `06_DPOF` | `C_WipeClean` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_WipePure` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `C_WipeSlim` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPOF` | `P|A_Add` | — |
| `06_DPOF` | `P|A_AddIMP` | — |
| `06_DPOF` | `P|A_Define` | — |
| `06_DPOF` | `P|A_RemoveIMP` | — |
| `06_DPOF` | `P|A_SetIMP` | — |
| `07_ELITE` | `P|A_Add` | — |
| `07_ELITE` | `P|A_AddIMP` | — |
| `07_ELITE` | `P|A_Define` | — |
| `07_ELITE` | `P|A_RemoveIMP` | — |
| `07_ELITE` | `P|A_SetIMP` | — |
| `08_ATS` | `C_AddHotRBT` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `hot-rbt`, `id`, `id:string` |
| `08_ATS` | `C_AddSecondary` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `reward-token` |
| `08_ATS` | `C_Control` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_ControlColdRecoveryFees` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_ControlHotRecoveryFee` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_Issue` | `UR_Konto`, `account`, `account:string`, `id:string`, `reward-bearing-token`, `reward-token` |
| `08_ATS` | `C_RotateOwnership` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SetColdRecoveryDuration` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SetColdRecoveryFees` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SetDirectRecoveryFee` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SetHibernationFees` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SetHotRecoveryFees` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SwitchColdRecovery` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SwitchDirectRecovery` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_SwitchHotRecovery` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_ToggleElite` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_ToggleParameterLock` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_ToggleUpgrade` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_UpdatePendingBranding` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_UpdateRoyalty` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_UpdateSyphon` | `UR_OwnerKonto`, `account:string`, `atspair`, `id:string` |
| `08_ATS` | `C_UpgradeBranding` | `UR_OwnerKonto`, `account:string`, `atspair`, `entity-owner-account`, `id:string` |
| `08_ATS` | `HOT-RBT|C_Repurpose` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `atspair`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `08_ATS` | `HOT-RBT|C_UpdatePendingBranding` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `id`, `id:string`, `parent` |
| `08_ATS` | `HOT-RBT|C_UpgradeBranding` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `entity-owner-account`, `id`, `id:string`, `parent` |
| `08_ATS` | `P|A_Add` | — |
| `08_ATS` | `P|A_AddIMP` | — |
| `08_ATS` | `P|A_Define` | — |
| `08_ATS` | `P|A_RemoveIMP` | — |
| `08_ATS` | `P|A_SetIMP` | — |
| `09_TFT` | `C_ClearDispo` | `UR_Konto`, `account`, `account:string`, `executee`, `executor`, `id`, `id:string` |
| `09_TFT` | `C_MultiBulkTransfer` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `09_TFT` | `C_MultiTransfer` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver` |
| `09_TFT` | `C_Transfer` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `09_TFT` | `C_Transmute` | `UR_Konto`, `account`, `account:string`, `id`, `id:string` |
| `09_TFT` | `P|A_Add` | — |
| `09_TFT` | `P|A_AddIMP` | — |
| `09_TFT` | `P|A_Define` | — |
| `09_TFT` | `P|A_RemoveIMP` | — |
| `09_TFT` | `P|A_SetIMP` | — |
| `10_ATSU` | `AA_RemoveSecondary` | `UR_Konto`, `account`, `account:string`, `executor`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `A_KickStart` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `CC_RemoveSecondary` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_Coil` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_ColdRecovery` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_Cull` | `UR_Konto`, `account`, `account:string`, `culler`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_Curl` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_DirectRecovery` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_Fuel` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_HotRecovery` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_KickStart` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_Recover` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_Redeem` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_Syphon` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `receiver`, `sender` |
| `10_ATSU` | `C_WithdrawRoyalties` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `receiver` |
| `10_ATSU` | `P|A_Add` | — |
| `10_ATSU` | `P|A_AddIMP` | — |
| `10_ATSU` | `P|A_Define` | — |
| `10_ATSU` | `P|A_RemoveIMP` | — |
| `10_ATSU` | `P|A_SetIMP` | — |
| `11_VST` | `C_Awake` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Brumate` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Constrict` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_CreateFrozenLink` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dptf` |
| `11_VST` | `C_CreateHibernatingLink` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dpof` |
| `11_VST` | `C_CreateReservationLink` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dptf` |
| `11_VST` | `C_CreateSleepingLink` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dpof` |
| `11_VST` | `C_CreateVestingLink` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dpof` |
| `11_VST` | `C_Freeze` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Hibernate` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Merge` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `merger`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeFrozen` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeHibernating` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeMerge` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeReserved` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeSleeping` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeSlumber` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeVested` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Reserve` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Sleep` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Slumber` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `merger`, `receiver`, `sender` |
| `11_VST` | `C_ToggleTransferRoleFrozenDPTF` | `URCv_Parent`, `UR_Konto`, `account:string`, `id`, `id:string` |
| `11_VST` | `C_ToggleTransferRoleHibernatingDPOF` | `UR_Konto`, `account:string`, `id`, `id:string`, `parent`, `ref-DPOF::UR_Sleeping` |
| `11_VST` | `C_ToggleTransferRoleReservedDPTF` | `URCv_Parent`, `UR_Konto`, `account:string`, `id`, `id:string` |
| `11_VST` | `C_ToggleTransferRoleSleepingDPOF` | `UR_Konto`, `account:string`, `id`, `id:string`, `parent`, `ref-DPOF::UR_Sleeping` |
| `11_VST` | `C_Unreserve` | `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Unsleep` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Unvest` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `C_Vest` | `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `receiver`, `sender` |
| `11_VST` | `P|A_Add` | — |
| `11_VST` | `P|A_AddIMP` | — |
| `11_VST` | `P|A_Define` | — |
| `11_VST` | `P|A_RemoveIMP` | — |
| `11_VST` | `P|A_SetIMP` | — |
| `12_LIQUID` | `A_MigrateLiquidFunds` | `account:string`, `executor` |
| `12_LIQUID` | `C_UnwrapStoa` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `12_LIQUID` | `C_UnwrapUrStoa` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `12_LIQUID` | `C_WrapStoa` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `12_LIQUID` | `C_WrapUrStoa` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `12_LIQUID` | `P|A_Add` | — |
| `12_LIQUID` | `P|A_AddIMP` | — |
| `12_LIQUID` | `P|A_Define` | — |
| `12_LIQUID` | `P|A_RemoveIMP` | — |
| `12_LIQUID` | `P|A_SetIMP` | — |
| `13_OUROBOROS` | `C_Compress` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_Fuel` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_Sublimate` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_SublimateV2` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_WithdrawFees` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `13_OUROBOROS` | `P|A_Add` | — |
| `13_OUROBOROS` | `P|A_AddIMP` | — |
| `13_OUROBOROS` | `P|A_Define` | — |
| `13_OUROBOROS` | `P|A_RemoveIMP` | — |
| `13_OUROBOROS` | `P|A_SetIMP` | — |
| `14_SWPT` | `P|A_Add` | — |
| `14_SWPT` | `P|A_AddIMP` | — |
| `14_SWPT` | `P|A_Define` | — |
| `14_SWPT` | `P|A_RemoveIMP` | — |
| `14_SWPT` | `P|A_SetIMP` | — |
| `15_SWP` | `A_DefinePrimordialPool` | `account:string`, `executor` |
| `15_SWP` | `A_RotatePrincipal` | `account:string`, `executor` |
| `15_SWP` | `A_ToggleAsymetricLiquidityAddition` | `UR_Konto`, `account:string`, `executor`, `id`, `id:string` |
| `15_SWP` | `A_UpdateLimit` | `account:string`, `executor` |
| `15_SWP` | `A_UpdateLiquidBoost` | `account:string`, `executor` |
| `15_SWP` | `A_UpdatePrincipal` | `account:string`, `executor` |
| `15_SWP` | `C_ChangeOwnership` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_EnableFrozenLP` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dptf`, `swpair`, `swpair:string` |
| `15_SWP` | `C_EnableSleepingLP` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `main-dptf`, `secondary-dpof`, `swpair`, `swpair:string` |
| `15_SWP` | `C_ModifyCanChangeOwner` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_ModifyWeights` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_ToggleAddOrSwap` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_ToggleFeeLock` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_UpdateAmplifier` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_UpdateFee` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_UpdatePendingBranding` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_UpdateSpecialFeeTargets` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `15_SWP` | `C_UpgradeBranding` | `UR_OwnerKonto`, `account:string`, `entity-owner-account`, `swpair`, `swpair:string` |
| `15_SWP` | `P|A_Add` | — |
| `15_SWP` | `P|A_AddIMP` | — |
| `15_SWP` | `P|A_Define` | — |
| `15_SWP` | `P|A_RemoveIMP` | — |
| `15_SWP` | `P|A_SetIMP` | — |
| `16_SWPI` | `A_RebuildGraph` | `account:string`, `executor` |
| `16_SWPI` | `C_Issue` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `16_SWPI` | `P|A_Add` | — |
| `16_SWPI` | `P|A_AddIMP` | — |
| `16_SWPI` | `P|A_Define` | — |
| `16_SWPI` | `P|A_RemoveIMP` | — |
| `16_SWPI` | `P|A_SetIMP` | — |
| `17_SWPL` | `P|A_Add` | — |
| `17_SWPL` | `P|A_AddIMP` | — |
| `17_SWPL` | `P|A_Define` | — |
| `17_SWPL` | `P|A_RemoveIMP` | — |
| `17_SWPL` | `P|A_SetIMP` | — |
| `18_SWPLC` | `C_Fuel` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver` |
| `18_SWPLC` | `C_RemoveLiquidity` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `18_SWPLC` | `C_ToggleAddLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `swpair`, `swpair:string` |
| `18_SWPLC` | `C_UpdatePendingBrandingLPs` | `UR_OwnerKonto`, `account:string`, `swpair`, `swpair:string` |
| `18_SWPLC` | `C_UpgradeBrandingLPs` | `UR_OwnerKonto`, `account:string`, `entity-owner-account`, `swpair`, `swpair:string` |
| `18_SWPLC` | `P|A_Add` | — |
| `18_SWPLC` | `P|A_AddIMP` | — |
| `18_SWPLC` | `P|A_Define` | — |
| `18_SWPLC` | `P|A_RemoveIMP` | — |
| `18_SWPLC` | `P|A_SetIMP` | — |
| `18_SWPLC` | `STOA-PID|C_AddFrozenLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `18_SWPLC` | `STOA-PID|C_AddGlacialLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `18_SWPLC` | `STOA-PID|C_AddIcedLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `18_SWPLC` | `STOA-PID|C_AddSleepingLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `18_SWPLC` | `STOA-PID|C_AddStandardLiquidity` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `19_SWPU` | `CC_SmartSwap` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `19_SWPU` | `C_SmartSwap` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `19_SWPU` | `C_Swap` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `19_SWPU` | `C_ToggleSwapCapability` | `UR_Konto`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `swpair`, `swpair:string` |
| `19_SWPU` | `P|A_Add` | — |
| `19_SWPU` | `P|A_AddIMP` | — |
| `19_SWPU` | `P|A_Define` | — |
| `19_SWPU` | `P|A_RemoveIMP` | — |
| `19_SWPU` | `P|A_SetIMP` | — |
| `20_MTX-SWP` | `C_AddFrozenLiquidity` | — |
| `20_MTX-SWP` | `C_AddGlacialLiquidity` | — |
| `20_MTX-SWP` | `C_AddIcedLiquidity` | — |
| `20_MTX-SWP` | `C_AddSleepingLiquidity` | — |
| `20_MTX-SWP` | `C_AddStandardLiquidity` | — |
| `20_MTX-SWP` | `C_IssueStablePool` | — |
| `20_MTX-SWP` | `C_IssueStandardPool` | — |
| `20_MTX-SWP` | `C_IssueWeightedPool` | — |
| `20_MTX-SWP` | `P|A_Add` | — |
| `20_MTX-SWP` | `P|A_AddIMP` | — |
| `20_MTX-SWP` | `P|A_Define` | — |
| `20_MTX-SWP` | `P|A_RemoveIMP` | — |
| `20_MTX-SWP` | `P|A_SetIMP` | — |
| `21_CODEX` | `A_RegisterCodexIdentity` | `account:string`, `executor` |
| `21_CODEX` | `C_RecordArweaveUpload` | `account:string`, `executor` |
| `21_CODEX` | `C_RegisterStoicTag` | `account-address`, `account:string` |
| `21_CODEX` | `C_ReleaseStoicTag` | `account-address`, `account:string` |
| `21_CODEX` | `C_RotateCodexGuard` | `account:string`, `executor` |
| `21_CODEX` | `P|A_Add` | — |
| `21_CODEX` | `P|A_AddIMP` | — |
| `21_CODEX` | `P|A_Define` | — |
| `21_CODEX` | `P|A_RemoveIMP` | — |
| `21_CODEX` | `P|A_SetIMP` | — |
| `22_PYTHIA` | `A_Flush` | `account:string`, `executor` |
| `22_PYTHIA` | `A_LinkDualApiKey` | `account:string`, `executor` |
| `22_PYTHIA` | `A_RevokeDualLink` | `account:string`, `executor` |
| `22_PYTHIA` | `A_UpdateDeployPrice` | `account:string`, `executor` |
| `22_PYTHIA` | `A_UpdateRenamePrice` | `account:string`, `executor` |
| `22_PYTHIA` | `C_DeployApolloPythiaApiKey` | `account:string`, `owner-account` |
| `22_PYTHIA` | `C_LinkDualApiKey` | `account:string`, `owner-account` |
| `22_PYTHIA` | `C_RevokeDualLink` | `account:string`, `owner-account` |
| `22_PYTHIA` | `C_UpdateDualConsumerLane` | `account:string`, `owner-account` |
| `22_PYTHIA` | `P|A_Add` | — |
| `22_PYTHIA` | `P|A_AddIMP` | — |
| `22_PYTHIA` | `P|A_Define` | — |
| `22_PYTHIA` | `P|A_RemoveIMP` | — |
| `22_PYTHIA` | `P|A_SetIMP` | — |
| `01_TS01-A` | `ATS|AA_RemoveSecondary` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS01-A` | `ATS|A_KickStart` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS01-A` | `BRD|A_Live` | `account:string`, `executor` |
| `01_TS01-A` | `BRD|A_SetFlag` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_AccountCreationStoaToggle` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_DeploySmartAccount` | — |
| `01_TS01-A` | `DALOS|A_DeployStandardAccount` | — |
| `01_TS01-A` | `DALOS|A_IgnisToggle` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_MigrateLiquidFunds` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_SetAutoFueling` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_SetIgnisSourcePrice` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_ToggleGAP` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_ToggleOAPU` | `account:string`, `executor` |
| `01_TS01-A` | `DALOS|A_UpdatePublicKey` | — |
| `01_TS01-A` | `DALOS|A_UpdateUsagePrice` | `account:string`, `executor` |
| `01_TS01-A` | `DPOF|A_DeployAccount` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `01_TS01-A` | `DPTF|A_DeployAccount` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `01_TS01-A` | `DPTF|A_UpdateTreasuryDispoParameters` | `account:string`, `executor` |
| `01_TS01-A` | `DPTF|A_WipeTreasuryDebt` | `UR_Konto`, `account:string`, `client`, `executor`, `id`, `id:string` |
| `01_TS01-A` | `DPTF|A_WipeTreasuryDebtPartial` | `UR_Konto`, `account:string`, `client`, `executor`, `id`, `id:string` |
| `01_TS01-A` | `LIQUID|A_MigrateLiquidFunds` | `account:string`, `executor` |
| `01_TS01-A` | `ORBR|A_Fuel` | `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `receiver`, `sender` |
| `01_TS01-A` | `P|A_Add` | — |
| `01_TS01-A` | `P|A_AddIMP` | — |
| `01_TS01-A` | `P|A_Define` | — |
| `01_TS01-A` | `P|A_RemoveIMP` | — |
| `01_TS01-A` | `P|A_SetIMP` | — |
| `01_TS01-A` | `SWP|A_DefinePrimordialPool` | `account:string`, `executor` |
| `01_TS01-A` | `SWP|A_RotatePrincipal` | `account:string`, `executor` |
| `01_TS01-A` | `SWP|A_ToggleAsymetricLiquidityAddition` | `UR_Konto`, `account:string`, `executor`, `id`, `id:string` |
| `01_TS01-A` | `SWP|A_UpdateLimit` | `account:string`, `executor` |
| `01_TS01-A` | `SWP|A_UpdateLiquidBoost` | `account:string`, `executor` |
| `01_TS01-A` | `SWP|A_UpdatePrincipal` | `account:string`, `executor` |
| `02_TS01-C1` | `DALOS|C_ControlSmartAccount` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_DeploySmartAccount` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `02_TS01-C1` | `DALOS|C_DeployStandardAccount` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `02_TS01-C1` | `DALOS|C_RotateGovernor` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateGuard` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateSovereign` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateStoa` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_UpdateEliteAccount` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `02_TS01-C1` | `DALOS|C_UpdateEliteAccountSquared` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `02_TS01-C1` | `DPOF|CC_WipeHeavy` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_AddQuantity` | `DALOS|SC_NAME`, `account:string`, `client`, `patron` |
| `02_TS01-C1` | `DPOF|C_BulkTransfer` | `DALOS|SC_NAME`, `account:string`, `patron`, `sender` |
| `02_TS01-C1` | `DPOF|C_Burn` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_Control` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_DeployAccount` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `02_TS01-C1` | `DPOF|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_Mint` | `DALOS|SC_NAME`, `account:string`, `client`, `patron` |
| `02_TS01-C1` | `DPOF|C_MoveCreateRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_RotateOwnership` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleAddQuantityRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_TogglePause` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_Transfer` | `DALOS|SC_NAME`, `account:string`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_Transmit` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver` |
| `02_TS01-C1` | `DPOF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `parent`, `patron` |
| `02_TS01-C1` | `DPOF|C_UpgradeBranding` | `UR_Konto`, `account`, `account:string`, `client`, `entity-owner-account`, `id`, `id:string`, `parent`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_WipeClean` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_WipePure` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPOF|C_WipeSlim` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_BulkTransfer` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_Burn` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ClearDispo` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `executee`, `executor`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ClearDispoForeign` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `executee`, `executor`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_Control` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_DeployAccount` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `02_TS01-C1` | `DPTF|C_DonateFees` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Mint` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `client`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_MultiBulkTransfer` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_MultiTransfer` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver` |
| `02_TS01-C1` | `DPTF|C_ResetFeeTarget` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_RotateOwnership` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetFee` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetFeeTarget` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetMinMove` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFee` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFeeExemptionRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFeeLock` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleMintRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_TogglePause` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleReservation` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_Transfer` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Transmute` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `URCv_Parent`, `UR_Konto`, `account:string`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_UpgradeBranding` | `URCv_Parent`, `UR_Konto`, `account`, `account:string`, `client`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Wipe` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `DPTF|C_WipeSlim` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS01-C1` | `P|A_Add` | — |
| `02_TS01-C1` | `P|A_AddIMP` | — |
| `02_TS01-C1` | `P|A_Define` | — |
| `02_TS01-C1` | `P|A_RemoveIMP` | — |
| `02_TS01-C1` | `P|A_SetIMP` | — |
| `03_TS01-C2` | `ATS|CC_RemoveSecondary` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_AddHotRBT` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `hot-rbt`, `id`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_AddSecondary` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron`, `reward-token` |
| `03_TS01-C2` | `ATS|C_Brumate` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Coil` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ColdRecovery` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Constrict` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Control` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_ControlColdRecoveryFees` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_ControlHotRecoveryFee` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_Cull` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `culler`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Curl` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_DirectRecovery` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Fuel` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_HotRecovery` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `reward-bearing-token`, `reward-token`, `sender` |
| `03_TS01-C2` | `ATS|C_KickStart` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Redeem` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Reverse` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_RotateOwnership` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SetColdRecoveryDuration` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SetColdRecoveryFees` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SetDirectRecoveryFee` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SetHibernationFees` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SetHotRecoveryFee` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchColdRecovery` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchDirectRecovery` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchHotRecovery` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_Syphon` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ToggleElite` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_ToggleParameterLock` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `atspair`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ToggleUpgrade` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdateRoyalty` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdateSyphon` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `atspair`, `id:string`, `patron` |
| `03_TS01-C2` | `ATS|C_UpgradeBranding` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `atspair`, `client`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_VestedCoil` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_VestedCurl` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_WithdrawRoyalties` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `ats`, `id`, `id:string`, `patron`, `receiver` |
| `03_TS01-C2` | `LQD|C_UnwrapStoa` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_UnwrapUrStoa` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_WrapStoa` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_WrapUrStoa` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_Compress` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_Sublimate` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_SublimateV2` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_WithdrawFees` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `P|A_Add` | — |
| `03_TS01-C2` | `P|A_AddIMP` | — |
| `03_TS01-C2` | `P|A_Define` | — |
| `03_TS01-C2` | `P|A_RemoveIMP` | — |
| `03_TS01-C2` | `P|A_SetIMP` | — |
| `03_TS01-C2` | `VST|C_Awake` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateFrozenLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dptf`, `sender` |
| `03_TS01-C2` | `VST|C_CreateHibernatingLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dpof`, `sender` |
| `03_TS01-C2` | `VST|C_CreateReservationLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dptf`, `sender` |
| `03_TS01-C2` | `VST|C_CreateSleepingLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dpof`, `sender` |
| `03_TS01-C2` | `VST|C_CreateVestingLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dpof`, `sender` |
| `03_TS01-C2` | `VST|C_Freeze` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Hibernate` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Merge` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `merger`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeFrozen` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeHibernating` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeMerge` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeReserved` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeSleeping` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeSlumber` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeVested` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Reserve` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Sleep` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Slumber` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `merger`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleFrozenDPTF` | `DALOS|SC_NAME`, `URCv_Parent`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleHibernatingDPOF` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `parent`, `patron`, `ref-DPOF::UR_Sleeping` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleReservedDPTF` | `DALOS|SC_NAME`, `URCv_Parent`, `UR_Konto`, `account:string`, `id`, `id:string`, `patron` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleSleepingDPOF` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `id`, `id:string`, `parent`, `patron`, `ref-DPOF::UR_Sleeping` |
| `03_TS01-C2` | `VST|C_Unreserve` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Unsleep` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Unvest` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Vest` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `P|A_Add` | — |
| `04_TS01-C3` | `P|A_AddIMP` | — |
| `04_TS01-C3` | `P|A_Define` | — |
| `04_TS01-C3` | `P|A_RemoveIMP` | — |
| `04_TS01-C3` | `P|A_SetIMP` | — |
| `04_TS01-C3` | `SWP|CC_SmartSwapNoSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|CC_SmartSwapWithSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddFrozenLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_AddGlacialLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_AddIcedLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_AddLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_AddSleepingLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_ChangeOwnership` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_EnableFrozenLP` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dptf`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_EnableSleepingLP` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `dptf`, `id`, `id:string`, `main-dptf`, `patron`, `receiver`, `secondary-dpof`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_Firestarter` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_Fuel` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver` |
| `04_TS01-C3` | `SWP|C_IssueStable` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_IssueStandard` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_IssueWeighted` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ModifyCanChangeOwner` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_ModifyWeights` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_MultiSwapNoSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_MultiSwapWithSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_RemoveLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SingleSwapNoSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SingleSwapWithSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SmartSwapNoSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SmartSwapWithSlippage` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ToggleAddLiquidity` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_ToggleFeeLock` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_ToggleSwapCapability` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpdateAmplifier` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpdateFee` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpdatePendingBrandingLPs` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpdateSpecialFeeTargets` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `patron`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpgradeBranding` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `04_TS01-C3` | `SWP|C_UpgradeBrandingLPs` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender`, `swpair`, `swpair:string` |
| `05_TS01-P` | `P|A_Add` | — |
| `05_TS01-P` | `P|A_AddIMP` | — |
| `05_TS01-P` | `P|A_Define` | — |
| `05_TS01-P` | `P|A_RemoveIMP` | — |
| `05_TS01-P` | `P|A_SetIMP` | — |
| `05_TS01-P` | `SWP|C_AddFrozenLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddGlacialLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddIcedLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddSleepingLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddStandardLiquidity` | — |
| `05_TS01-P` | `SWP|C_IssueStablePool` | — |
| `05_TS01-P` | `SWP|C_IssueStandardPool` | — |
| `05_TS01-P` | `SWP|C_IssueWeightedPool` | — |
| `06_TS01-C4` | `CODEX|A_RegisterCodexIdentity` | `account:string`, `executor` |
| `06_TS01-C4` | `CODEX|C_RecordArweaveUpload` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `06_TS01-C4` | `CODEX|C_RegisterStoicTag` | `account-address`, `account:string` |
| `06_TS01-C4` | `CODEX|C_ReleaseStoicTag` | `DALOS|SC_NAME`, `account-address`, `account:string`, `patron` |
| `06_TS01-C4` | `CODEX|C_RotateCodexGuard` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `06_TS01-C4` | `PYTHIA|A_Flush` | `account:string`, `executor` |
| `06_TS01-C4` | `PYTHIA|A_Link` | `account:string`, `executor` |
| `06_TS01-C4` | `PYTHIA|A_RevokeLink` | `account:string`, `executor` |
| `06_TS01-C4` | `PYTHIA|A_UpdateDeployPrice` | `account:string`, `executor` |
| `06_TS01-C4` | `PYTHIA|A_UpdateRenamePrice` | `account:string`, `executor` |
| `06_TS01-C4` | `PYTHIA|C_DeployApiKey` | `account:string`, `owner-account` |
| `06_TS01-C4` | `PYTHIA|C_Link` | `account:string`, `owner-account` |
| `06_TS01-C4` | `PYTHIA|C_RevokeLink` | `DALOS|SC_NAME`, `account:string`, `owner-account`, `patron` |
| `06_TS01-C4` | `PYTHIA|C_UpdateDualConsumerLane` | `account:string`, `owner-account` |
| `06_TS01-C4` | `P|A_Add` | — |
| `06_TS01-C4` | `P|A_AddIMP` | — |
| `06_TS01-C4` | `P|A_Define` | — |
| `06_TS01-C4` | `P|A_RemoveIMP` | — |
| `06_TS01-C4` | `P|A_SetIMP` | — |
| `01_DPDC-UDC` | `P|A_Add` | — |
| `01_DPDC-UDC` | `P|A_AddIMP` | — |
| `01_DPDC-UDC` | `P|A_Define` | — |
| `01_DPDC-UDC` | `P|A_RemoveIMP` | — |
| `01_DPDC-UDC` | `P|A_SetIMP` | — |
| `02_DPDC` | `C_UpdatePendingBranding` | `UR_OwnerKonto`, `account:string`, `entity-id`, `id:string` |
| `02_DPDC` | `C_UpgradeBranding` | `UR_OwnerKonto`, `account:string`, `entity-id`, `entity-owner-account`, `id:string` |
| `02_DPDC` | `P|A_Add` | — |
| `02_DPDC` | `P|A_AddIMP` | — |
| `02_DPDC` | `P|A_Define` | — |
| `02_DPDC` | `P|A_RemoveIMP` | — |
| `02_DPDC` | `P|A_SetIMP` | — |
| `03_DPDC-C` | `C_CreateNewNonce` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account` |
| `03_DPDC-C` | `C_CreateNewNonces` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account` |
| `03_DPDC-C` | `P|A_Add` | — |
| `03_DPDC-C` | `P|A_AddIMP` | — |
| `03_DPDC-C` | `P|A_Define` | — |
| `03_DPDC-C` | `P|A_RemoveIMP` | — |
| `03_DPDC-C` | `P|A_SetIMP` | — |
| `04_DPDC-I` | `C_IssueDigitalCollection` | `account:string`, `owner-account` |
| `04_DPDC-I` | `P|A_Add` | — |
| `04_DPDC-I` | `P|A_AddIMP` | — |
| `04_DPDC-I` | `P|A_Define` | — |
| `04_DPDC-I` | `P|A_RemoveIMP` | — |
| `04_DPDC-I` | `P|A_SetIMP` | — |
| `05_DPDC-R` | `C_MoveCreateRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_MoveRecreateRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_MoveSetUriRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleAddQuantityRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleBurnRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleExemptionRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleFreezeAccount` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleModifyCreatorRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleModifyRoyaltiesRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleTransferRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `C_ToggleUpdateRole` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `05_DPDC-R` | `P|A_Add` | — |
| `05_DPDC-R` | `P|A_AddIMP` | — |
| `05_DPDC-R` | `P|A_Define` | — |
| `05_DPDC-R` | `P|A_RemoveIMP` | — |
| `05_DPDC-R` | `P|A_SetIMP` | — |
| `06_DPDC-MNG` | `CC_WipeHeavy` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_AddQuantity` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_BurnNFT` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_BurnSFT` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_Control` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_RespawnNFT` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_TogglePause` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_WipeClean` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_WipeDirty` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_WipeNonce` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_WipePure` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `C_WipeSlim` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `06_DPDC-MNG` | `P|A_Add` | — |
| `06_DPDC-MNG` | `P|A_AddIMP` | — |
| `06_DPDC-MNG` | `P|A_Define` | — |
| `06_DPDC-MNG` | `P|A_RemoveIMP` | — |
| `06_DPDC-MNG` | `P|A_SetIMP` | — |
| `07_DPDC-T` | `C_BulkTransfer` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `sender` |
| `07_DPDC-T` | `C_IgnisRoyaltyCollector` | `account:string`, `executor`, `sender` |
| `07_DPDC-T` | `C_RepurposeCollectable` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `07_DPDC-T` | `C_Transfer` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `07_DPDC-T` | `P|A_Add` | — |
| `07_DPDC-T` | `P|A_AddIMP` | — |
| `07_DPDC-T` | `P|A_Define` | — |
| `07_DPDC-T` | `P|A_RemoveIMP` | — |
| `07_DPDC-T` | `P|A_SetIMP` | — |
| `08_DPDC-S` | `CC_BreakSemiFungibleSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `08_DPDC-S` | `C_BreakNonFungibleSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `08_DPDC-S` | `C_DefineCompositeSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account` |
| `08_DPDC-S` | `C_DefineHybridSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account` |
| `08_DPDC-S` | `C_DefinePrimordialSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account` |
| `08_DPDC-S` | `C_EnableSetClassFragmentation` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `08_DPDC-S` | `C_MakeNonFungibleSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `r-nft-create-account`, `receiver`, `sender` |
| `08_DPDC-S` | `C_MakeSemiFungibleSet` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `08_DPDC-S` | `C_RenameSet` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `08_DPDC-S` | `C_ToggleSet` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `08_DPDC-S` | `P|A_Add` | — |
| `08_DPDC-S` | `P|A_AddIMP` | — |
| `08_DPDC-S` | `P|A_Define` | — |
| `08_DPDC-S` | `P|A_RemoveIMP` | — |
| `08_DPDC-S` | `P|A_SetIMP` | — |
| `09_DPDC-F` | `C_EnableNonceFragmentation` | `UR_OwnerKonto`, `account:string`, `id`, `id:string` |
| `09_DPDC-F` | `C_MakeFragments` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `09_DPDC-F` | `C_MergeFragments` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `09_DPDC-F` | `C_RepurposeCollectableFragments` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string` |
| `09_DPDC-F` | `P|A_Add` | — |
| `09_DPDC-F` | `P|A_AddIMP` | — |
| `09_DPDC-F` | `P|A_Define` | — |
| `09_DPDC-F` | `P|A_RemoveIMP` | — |
| `09_DPDC-F` | `P|A_SetIMP` | — |
| `10_DPDC-N` | `C_UpdateNonceDescription` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceIgnisRoyalty` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceMetaData` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceName` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceRoyalty` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceScore` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonceURI` | `account`, `account:string` |
| `10_DPDC-N` | `C_UpdateNonces` | `account`, `account:string` |
| `10_DPDC-N` | `P|A_Add` | — |
| `10_DPDC-N` | `P|A_AddIMP` | — |
| `10_DPDC-N` | `P|A_Define` | — |
| `10_DPDC-N` | `P|A_RemoveIMP` | — |
| `10_DPDC-N` | `P|A_SetIMP` | — |
| `11_EQUITY+` | `C_IssueShareholderCollection` | `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `owner-account`, `r-nft-create-account` |
| `11_EQUITY+` | `C_MorphPackageShares` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `11_EQUITY+` | `P|A_Add` | — |
| `11_EQUITY+` | `P|A_AddIMP` | — |
| `11_EQUITY+` | `P|A_Define` | — |
| `11_EQUITY+` | `P|A_RemoveIMP` | — |
| `11_EQUITY+` | `P|A_SetIMP` | — |
| `00_Demipad` | `A_DefinePrice` | `account:string`, `executor` |
| `00_Demipad` | `A_RegisterAssetToLaunchpad` | `account:string`, `executor` |
| `00_Demipad` | `A_ToggleOpenForBusiness` | `account:string`, `executor` |
| `00_Demipad` | `A_ToggleRetrieval` | `account:string`, `executor` |
| `00_Demipad` | `C_Deposit` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitNonFungibles` | `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitOrtoFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitSemiFungibles` | `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitTrueFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `C_Withdraw` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `P|A_Add` | — |
| `00_Demipad` | `P|A_AddIMP` | — |
| `00_Demipad` | `P|A_Define` | — |
| `00_Demipad` | `P|A_RemoveIMP` | — |
| `00_Demipad` | `P|A_SetIMP` | — |
| `01_ANK` | `C_IssueNonFungibleAnchor` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `at`, `id`, `id:string` |
| `01_ANK` | `C_IssueNonFungibleSetAnchor` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `at`, `id`, `id:string` |
| `01_ANK` | `C_IssueSemiFungibleAnchor` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `at`, `id`, `id:string` |
| `01_ANK` | `C_IssueTrueFungibleAnchor` | `account:string`, `at`, `dptf-id`, `dptf-id:string`, `owner` |
| `01_ANK` | `C_RevokeAnchor` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `dptf-id:string`, `id`, `id:string`, `owner` |
| `01_ANK` | `C_RevokeBoostClass` | `account:string`, `co` |
| `01_ANK` | `P|A_Add` | — |
| `01_ANK` | `P|A_AddIMP` | — |
| `01_ANK` | `P|A_Define` | — |
| `01_ANK` | `P|A_RemoveIMP` | — |
| `01_ANK` | `P|A_SetIMP` | — |
| `02_SCORE` | `C_CombineTripletScoreModel` | `account:string`, `executor` |
| `02_SCORE` | `C_Control` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_CreateBoostClassLink` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_CreateBoostLink` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_EnableDebBoost` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueLiquidityScore` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleScore` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleScoreDefinition` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleSetScoreDefinition` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueOrtoFungibleScore` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueScoreFromModel` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueSemiFungibleScore` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueSemiFungibleScoreDefinition` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueSingleScoreModel` | `account:string`, `executor` |
| `02_SCORE` | `C_IssueTriplet` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_IssueTrueFungibleScore` | `account:string`, `owner-konto` |
| `02_SCORE` | `C_RotateOwnership` | `account:string`, `owner-now` |
| `02_SCORE` | `P|A_Add` | — |
| `02_SCORE` | `P|A_AddIMP` | — |
| `02_SCORE` | `P|A_Define` | — |
| `02_SCORE` | `P|A_RemoveIMP` | — |
| `02_SCORE` | `P|A_SetIMP` | — |
| `03_AQP` | `C_AddScore` | `URC_AqpOwnerKonto`, `account:string`, `owner-konto`, `pool-id`, `pool-id:string` |
| `03_AQP` | `C_DisablePoolStake` | `URC_AqpOwnerKonto`, `account:string`, `pool-id`, `pool-id:string` |
| `03_AQP` | `C_EnablePoolStake` | `URC_AqpOwnerKonto`, `account:string`, `pool-id`, `pool-id:string` |
| `03_AQP` | `C_Issue` | `URC_AqpOwnerKontoFromClassAndAsset`, `account:string`, `aqp-class`, `aqp-class:integer` |
| `03_AQP` | `C_RevokeScore` | `URC_AqpOwnerKonto`, `account:string`, `owner-konto`, `pool-id`, `pool-id:string` |
| `03_AQP` | `C_SyncCollectableAnchors` | — |
| `03_AQP` | `C_SyncTrueFungibleAnchors` | — |
| `03_AQP` | `P|A_Add` | — |
| `03_AQP` | `P|A_AddIMP` | — |
| `03_AQP` | `P|A_Define` | — |
| `03_AQP` | `P|A_RemoveIMP` | — |
| `03_AQP` | `P|A_SetIMP` | — |
| `04_RPS` | `P|A_Add` | — |
| `04_RPS` | `P|A_AddIMP` | — |
| `04_RPS` | `P|A_Define` | — |
| `04_RPS` | `P|A_RemoveIMP` | — |
| `04_RPS` | `P|A_SetIMP` | — |
| `05_FVT` | `CC_Collect` | `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_FVT` | `CC_CollectableStakeFlow` | `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_Inject` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_InjectFinalize` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_InjectStream` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_OrtoFungibleStakeFlow` | `account:string`, `owner-id`, `owner-id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_SweepBegin` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `dptf-id:string`, `id`, `id:string`, `owner` |
| `05_FVT` | `CC_SweepRevokeAnchor` | `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `dptf-id:string`, `id`, `id:string`, `owner` |
| `05_FVT` | `CC_TrueFungibleStakeFlow` | `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `receiver`, `sender` |
| `05_FVT` | `CC_UnstaleMyScores` | `account:string`, `executor` |
| `05_FVT` | `C_AddRewardLink` | `account:string`, `owner-konto` |
| `05_FVT` | `C_AddScoreEntity` | `account:string`, `fvt-owner`, `owner-konto` |
| `05_FVT` | `C_Control` | `account:string`, `owner-konto` |
| `05_FVT` | `C_Issue` | `account:string`, `owner-konto` |
| `05_FVT` | `C_IssueMultipletFamily` | `account:string`, `executor` |
| `05_FVT` | `C_RotateOwnership` | `account:string`, `owner-now` |
| `05_FVT` | `C_SetCommonDenominator` | `account:string`, `owner-konto` |
| `05_FVT` | `C_SetMosaic` | `account:string`, `owner-konto` |
| `05_FVT` | `C_SetQualitySplit` | `account:string`, `owner-konto` |
| `05_FVT` | `C_SetSplitMode` | `account:string`, `owner-konto` |
| `05_FVT` | `C_ToggleRewardLink` | `account:string`, `owner-konto` |
| `05_FVT` | `C_ToggleScoreEntityLink` | `account:string`, `owner-konto` |
| `05_FVT` | `P|A_Add` | — |
| `05_FVT` | `P|A_AddIMP` | — |
| `05_FVT` | `P|A_Define` | — |
| `05_FVT` | `P|A_RemoveIMP` | — |
| `05_FVT` | `P|A_SetIMP` | — |
| `06_VCT` | `CC_FullVacate` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto`, `sender` |
| `06_VCT` | `C_AbortVacate` | `account:string`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto` |
| `06_VCT` | `C_FinalizeVacate` | `account:string`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto` |
| `06_VCT` | `P|A_Add` | — |
| `06_VCT` | `P|A_AddIMP` | — |
| `06_VCT` | `P|A_Define` | — |
| `06_VCT` | `P|A_RemoveIMP` | — |
| `06_VCT` | `P|A_SetIMP` | — |
| `07_MTX-AQP` | `C_2|Inject` | — |
| `07_MTX-AQP` | `C_2|SweepRevokeAnchor` | — |
| `07_MTX-AQP` | `P|A_Add` | — |
| `07_MTX-AQP` | `P|A_AddIMP` | — |
| `07_MTX-AQP` | `P|A_Define` | — |
| `07_MTX-AQP` | `P|A_RemoveIMP` | — |
| `07_MTX-AQP` | `P|A_SetIMP` | — |
| `08_DSA` | `A_SetOracleValidity` | `account:string`, `executor` |
| `08_DSA` | `A_ToggleExternalOracle` | `account:string`, `executor` |
| `08_DSA` | `C_AdmitAgency` | `account:string`, `operator`, `owner-konto` |
| `08_DSA` | `C_BurnRoyalty` | `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `receiver`, `sender` |
| `08_DSA` | `C_DefineDelegationVault` | `account:string`, `fvt-owner` |
| `08_DSA` | `C_FuelRoyalty` | `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `receiver`, `sender` |
| `08_DSA` | `C_OracleWrite` | — |
| `08_DSA` | `C_RecomputeCapture` | — |
| `08_DSA` | `C_SetAgencyFee` | `account:string`, `fvt-owner` |
| `08_DSA` | `C_SetOracleAuth` | `account:string`, `fvt-owner` |
| `08_DSA` | `C_WithdrawRoyalty` | `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `receiver`, `sender` |
| `08_DSA` | `P|A_Add` | — |
| `08_DSA` | `P|A_AddIMP` | — |
| `08_DSA` | `P|A_Define` | — |
| `08_DSA` | `P|A_RemoveIMP` | — |
| `08_DSA` | `P|A_SetIMP` | — |
| `01_TS02-C1` | `DPDC|C_BulkTransfer` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `sender` |
| `01_TS02-C1` | `DPDC|C_MultiTransfer` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|CC_Break` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|CC_WipeHeavy` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_AddQuantity` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_BulkTransfer` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `sender` |
| `01_TS02-C1` | `DPSF|C_Burn` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_Control` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_Create` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefineCompositeSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefineHybridSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefinePrimordialSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_EnableNonceFragmentation` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_EnableSetClassFragmentation` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_IssueCompany` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `owner-account`, `patron`, `r-nft-create-account`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_Make` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MakeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MergeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MorphEquity` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MoveCreateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_MoveRecreateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_MoveSetUriRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_RemoveNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_RemoveSetNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_RenameSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_Repurpose` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_RepurposeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleAddQuantityRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleExemptionRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleModifyCreatorRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleModifyRoyaltiesRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_TogglePause` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleUpdateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_TransferNonce` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_TransferNonces` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_UpdateNonce` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceDescription` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceMetaData` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceName` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceURI` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonces` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `entity-id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonce` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceDescription` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceMetaData` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceName` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceURI` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonces` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpgradeBranding` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `entity-id`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_WipeClean` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeDirty` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeNonce` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeNoncePartialy` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipePure` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `01_TS02-C1` | `P|A_Add` | — |
| `01_TS02-C1` | `P|A_AddIMP` | — |
| `01_TS02-C1` | `P|A_Define` | — |
| `01_TS02-C1` | `P|A_RemoveIMP` | — |
| `01_TS02-C1` | `P|A_SetIMP` | — |
| `02_TS02-C2` | `DPNF|CC_WipeHeavy` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Break` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_BulkTransfer` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `sender` |
| `02_TS02-C2` | `DPNF|C_Burn` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Control` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Create` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefineCompositeSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefineHybridSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefinePrimordialSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_EnableNonceFragmentation` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_EnableSetClassFragmentation` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_Make` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MakeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MergeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MoveCreateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_MoveRecreateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_MoveSetUriRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_RemoveNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_RemoveSetNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_RenameSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Repurpose` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_RepurposeFragments` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_Respawn` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleExemptionRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleModifyCreatorRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleModifyRoyaltiesRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_TogglePause` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleUpdateRole` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_TransferNonce` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_TransferNonces` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_UpdateNonce` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceDescription` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceMetaData` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceName` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceURI` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonces` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account:string`, `entity-id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonce` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceDescription` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceMetaData` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceName` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceRoyalty` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceScore` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceURI` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonces` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpgradeBranding` | `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `entity-id`, `entity-owner-account`, `id`, `id:string`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_WipeClean` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipeDirty` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipeNonce` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipePure` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `02_TS02-C2` | `P|A_Add` | — |
| `02_TS02-C2` | `P|A_AddIMP` | — |
| `02_TS02-C2` | `P|A_Define` | — |
| `02_TS02-C2` | `P|A_RemoveIMP` | — |
| `02_TS02-C2` | `P|A_SetIMP` | — |
| `04_TS02-C3` | `AQP-ANK|C_IssueNonFungibleAnchor` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `at`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueNonFungibleSetAnchor` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `at`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueSemiFungibleAnchor` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `at`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueTrueFungibleAnchor` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `at`, `client`, `dptf-id`, `dptf-id:string`, `id`, `id:string`, `owner`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_RevokeAnchor` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_OwnerKonto`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `dptf-id:string`, `id`, `id:string`, `owner`, `patron` |
| `04_TS02-C3` | `AQP-ANK|C_RevokeBoostClass` | `DALOS|SC_NAME`, `account:string`, `co`, `patron` |
| `04_TS02-C3` | `AQP-DSA|A_SetOracleValidity` | `account:string`, `executor` |
| `04_TS02-C3` | `AQP-DSA|A_ToggleExternalOracle` | `account:string`, `executor` |
| `04_TS02-C3` | `AQP-DSA|CC_OpenAgency` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `operator`, `owner-id`, `owner-id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_BurnRoyalty` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_DefineDelegationVault` | `DALOS|SC_NAME`, `account:string`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_FuelRoyalty` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_OracleWrite` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_RecomputeCapture` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_SetAgencyFee` | `DALOS|SC_NAME`, `account:string`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_SetOracleAuth` | `DALOS|SC_NAME`, `account:string`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_WithdrawRoyalty` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_Collect` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_Inject` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_InjectFinalize` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_InjectStream` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_SweepBegin` | `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `client`, `dptf-id:string`, `id`, `id:string`, `owner`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_SweepRevokeAnchor` | `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `anchor-id`, `anchor-id:string`, `ank-asset`, `client`, `dptf-id:string`, `id`, `id:string`, `owner`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_UnstaleMyScores` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_AddRewardLink` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_AddScoreEntity` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_Control` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_IssueGenericEarningVault` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `URC_AqpOwnerKontoFromClassAndAsset`, `UR_Konto`, `account`, `account:string`, `aqp-class`, `aqp-class:integer`, `client`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_IssueMultipletFamily` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_RotateOwnership` | `DALOS|SC_NAME`, `account:string`, `owner-now`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetCommonDenominator` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_SetMosaic` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetQualitySplit` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetSplitMode` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_ToggleRewardLink` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_ToggleScoreEntityLink` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-POOL|CC_FullVacate` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeNonFungibleCollectable` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeOrtoFungible` | `DALOS|SC_NAME`, `account:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeSemiFungibleCollectable` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeTrueFungible` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeNonFungibleCollectable` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeOrtoFungible` | `DALOS|SC_NAME`, `account:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeSemiFungibleCollectable` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeTrueFungible` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `owner-id`, `owner-id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_AbortVacate` | `DALOS|SC_NAME`, `account:string`, `patron`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto` |
| `04_TS02-C3` | `AQP-POOL|C_AddScore` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_DisablePoolStake` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_EnablePoolStake` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_FinalizeVacate` | `DALOS|SC_NAME`, `account:string`, `patron`, `pool-id`, `pool-id:string`, `ref-AQP::URC_AqpOwnerKonto` |
| `04_TS02-C3` | `AQP-POOL|C_Issue` | `DALOS|SC_NAME`, `URC_AqpOwnerKontoFromClassAndAsset`, `UR_Konto`, `account`, `account:string`, `aqp-class`, `aqp-class:integer`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_RevokeScore` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_SyncNonFungibleAnchors` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_SyncSemiFungibleAnchors` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_SyncTrueFungibleAnchors` | `DALOS|SC_NAME`, `account:string`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CombineTripletScoreModel` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_ControlScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CreateScoreBoostClassLink` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CreateScoreBoostLink` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_EnableDebBoost` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueLiquidityScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleScoreDefinition` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleSetScoreDefinition` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueOrtoFungibleScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueScoreFromModel` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSemiFungibleScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSemiFungibleScoreDefinition` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSingleScoreModel` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueTriplet` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueTrueFungibleScore` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_RotateScoreOwnership` | `DALOS|SC_NAME`, `account:string`, `owner-now`, `patron` |
| `04_TS02-C3` | `P|A_Add` | — |
| `04_TS02-C3` | `P|A_AddIMP` | — |
| `04_TS02-C3` | `P|A_Define` | — |
| `04_TS02-C3` | `P|A_RemoveIMP` | — |
| `04_TS02-C3` | `P|A_SetIMP` | — |
| `05_TS02-DPAD` | `A_DefinePrice` | `account:string`, `executor` |
| `05_TS02-DPAD` | `A_RegisterAssetToLaunchpad` | `DALOS|SC_NAME`, `account:string`, `executor`, `patron` |
| `05_TS02-DPAD` | `A_ToggleOpenForBusiness` | `account:string`, `executor` |
| `05_TS02-DPAD` | `A_ToggleRetrieval` | `account:string`, `executor` |
| `05_TS02-DPAD` | `DEMIPAD|C_Deposit` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelNonFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelOrtoFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelSemiFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelTrueFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveNonFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveOrtoFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveSemiFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveTrueFungible` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_Withdraw` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `asset-id`, `asset-id:string`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `P|A_Add` | — |
| `05_TS02-DPAD` | `P|A_AddIMP` | — |
| `05_TS02-DPAD` | `P|A_Define` | — |
| `05_TS02-DPAD` | `P|A_RemoveIMP` | — |
| `05_TS02-DPAD` | `P|A_SetIMP` | — |
| `01_AOZ+` | `A_InitialiseCounters` | — |
| `01_AOZ+` | `A_RegisterAutostakePair` | — |
| `01_AOZ+` | `A_RegisterNonFungible` | — |
| `01_AOZ+` | `A_RegisterOrtoFungible` | — |
| `01_AOZ+` | `A_RegisterPrimalOrtoFungible` | — |
| `01_AOZ+` | `A_RegisterPrimalTrueFungible` | — |
| `01_AOZ+` | `A_RegisterSemiFungible` | — |
| `01_AOZ+` | `A_RegisterTrueFungible` | — |
| `01_AOZ+` | `C_SetupKosonicATS` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account:string`, `atspair`, `hot-rbt`, `id`, `id:string`, `patron`, `reward-token` |
| `01_BSD-L` | `A_Issue` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-account`, `patron`, `receiver`, `sender` |
| `01_BSD-L` | `A_Legendary` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_BSD-E` | `A_Epic` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `03_BSD-R` | `A_Rare` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `04_BSD-C` | `A_Common` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Fix01` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix02a` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix02b` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix03` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix04` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix05a` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix05b` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix06` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix07` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix08` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix09` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix10` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix11` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix12` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix13` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix14` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix15` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix16` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix17` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix18` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix19` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix20` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix21` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Fix22` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `A_Step01` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step02` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step03` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step04` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step05` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step06` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step07` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step08` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step09` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step10` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step11` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step12` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step13` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step14` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step15` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step16` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step17` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step18` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step19` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step20` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step21` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step22` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `C_Fix` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `01_NOSFERATU` | `C_Spawn` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_BunnyRGBSet` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step01` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step02` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step03` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step04` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step05` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step06` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step07` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step08` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step09` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step10` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step11` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step12` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step13` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step14` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step15` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step16` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `C_Spawn` | `DALOS|SC_NAME`, `UR_OwnerKonto`, `account`, `account:string`, `id`, `id:string`, `patron`, `r-nft-create-account` |
| `04_AQP-BOOT` | `CC_Step14_OpenCustodiansAgency` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `id`, `id:string`, `operator`, `owner-id`, `owner-id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_IssueGenericEarningVault` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `URC_AqpOwnerKontoFromClassAndAsset`, `UR_Konto`, `account`, `account:string`, `aqp-class`, `aqp-class:integer`, `client`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step0_WireImcAndGovernor` | `DALOS|SC_NAME`, `account`, `account:string`, `patron` |
| `04_AQP-BOOT` | `C_Step10_IssueMultipletFamily` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step11_WireFarmTriplet` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step12_AddFvtRewardLinks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step13_CreateCustodiansVault` | `DALOS|SC_NAME`, `URC_AqpOwnerKontoFromClassAndAsset`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `aqp-class`, `aqp-class:integer`, `at`, `client`, `executor`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step1_CreateBunnySet` | — |
| `04_AQP-BOOT` | `C_Step2_CreateSnakePowerAnchorClasses` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `at`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step3_CreateBoosterAnchorClasses` | `DALOS|SC_NAME`, `UR_CreatorKonto`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `at`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step4_CreateCoreScores` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step5_CreateSubsidiaryScores` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step6_CreateOuroLpTriplet` | `DALOS|SC_NAME`, `account:string`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step7_CreatePoolsAndScores` | `DALOS|SC_NAME`, `URC_AqpOwnerKonto`, `URC_AqpOwnerKontoFromClassAndAsset`, `UR_Konto`, `account`, `account:string`, `aqp-class`, `aqp-class:integer`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `pool-id`, `pool-id:string`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step8_IssueFvtEntities` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step9_AddFvtScoreEntities` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `fvt-owner`, `id`, `id:string`, `owner-konto`, `patron`, `receiver`, `sender` |
| `03_CADUCEUS` | `A_DeployBridgeSmartAccount` | `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `receiver`, `sender` |
| `03_CADUCEUS` | `A_ProvisionBridgeDptfRoles` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `executor`, `id`, `id:string`, `patron` |
| `03_CADUCEUS` | `A_SetBridgeActive` | — |
| `03_CADUCEUS` | `A_SetBridgeConfig` | — |
| `03_CADUCEUS` | `C_BurnFromBridgeSignal` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `03_CADUCEUS` | `C_MintToUserFromBridgeSignal` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_BuySparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_CustomRedemAllSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `01_Spark` | `C_CustomRedemFewSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `01_Spark` | `C_RedemAllSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `01_Spark` | `C_RedemFewSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `01_Spark` | `P|A_Add` | — |
| `01_Spark` | `P|A_AddIMP` | — |
| `01_Spark` | `P|A_Define` | — |
| `01_Spark` | `P|A_RemoveIMP` | — |
| `01_Spark` | `P|A_SetIMP` | — |
| `02_Snakes` | `A_UpdateSharePrice` | `account:string`, `executor` |
| `02_Snakes` | `C_Acquire` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `02_Snakes` | `P|A_Add` | — |
| `02_Snakes` | `P|A_AddIMP` | — |
| `02_Snakes` | `P|A_Define` | — |
| `02_Snakes` | `P|A_RemoveIMP` | — |
| `02_Snakes` | `P|A_SetIMP` | — |
| `03_Custodians` | `A_UpdateQuintessencePrice` | `account:string`, `executor` |
| `03_Custodians` | `C_Acquire` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_Custodians` | `P|A_Add` | — |
| `03_Custodians` | `P|A_AddIMP` | — |
| `03_Custodians` | `P|A_Define` | — |
| `03_Custodians` | `P|A_RemoveIMP` | — |
| `03_Custodians` | `P|A_SetIMP` | — |
| `04_STOICPAY` | `C_BuyStoicPay` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `04_STOICPAY` | `P|A_Add` | — |
| `04_STOICPAY` | `P|A_AddIMP` | — |
| `04_STOICPAY` | `P|A_Define` | — |
| `04_STOICPAY` | `P|A_RemoveIMP` | — |
| `04_STOICPAY` | `P|A_SetIMP` | — |
| `05_STOAICO` | `AA_FlushUncollected` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_InitialiseDistributionVault` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_Inject` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_Stake` | `DALOS|SC_NAME`, `UR_Konto`, `account:string`, `client`, `id`, `id:string`, `patron` |
| `05_STOAICO` | `A_Unstake` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron` |
| `05_STOAICO` | `C_Collect` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `P|A_Add` | — |
| `05_STOAICO` | `P|A_AddIMP` | — |
| `05_STOAICO` | `P|A_Define` | — |
| `05_STOAICO` | `P|A_RemoveIMP` | — |
| `05_STOAICO` | `P|A_SetIMP` | — |
| `99_TS02-CPAD` | `CUSTODIANS|C_Acquire` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `KPAY|C_BuyStoicPay` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `P|A_Add` | — |
| `99_TS02-CPAD` | `P|A_AddIMP` | — |
| `99_TS02-CPAD` | `P|A_Define` | — |
| `99_TS02-CPAD` | `P|A_RemoveIMP` | — |
| `99_TS02-CPAD` | `P|A_SetIMP` | — |
| `99_TS02-CPAD` | `SNAKES|C_Acquire` | `DALOS|SC_NAME`, `UR_Konto`, `UR_OwnerKonto`, `account`, `account:string`, `client`, `executor`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `SPARK|C_BuySparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `SPARK|C_RedemAllSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `99_TS02-CPAD` | `SPARK|C_RedemFewSparks` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender`, `spark-id` |
| `99_TS02-CPAD` | `STOAICO|C_Collect` | — |
| `03_DSP+` | `AA_OuroMinterStageTwo` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `AA_OuroMinterStageTwo_InjectLeg` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `AA_OuroMinterStageTwo_InjectLegFinalize` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_1of3` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_2of3` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_3of3` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_OuroMinterStageOne` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_OuroMinterStageTwo_Flat` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_StoicismMinter` | `DALOS|SC_NAME`, `UR_Konto`, `account`, `account:string`, `client`, `id`, `id:string`, `patron` |
| `03_DSP+` | `P|A_Add` | — |
| `03_DSP+` | `P|A_AddIMP` | — |
| `03_DSP+` | `P|A_Define` | — |
| `03_DSP+` | `P|A_RemoveIMP` | — |
| `03_DSP+` | `P|A_SetIMP` | — |

