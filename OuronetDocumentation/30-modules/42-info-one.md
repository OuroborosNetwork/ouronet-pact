# INFO-ONE — Stage-1 previews

## What it is for

Operation previews for the Stage-1 modules — 181 of them, each answering *what will this do, and
what will it cost?* before anything is signed.

A preview does not calculate anything. It wraps a cost function that lives **in the module that
charges it**, and the billing path calls the same function — so the quote and the charge cannot
drift.

## Where it sits

A read module deployed after everything it describes. Owns no tables.

**It is the single most expensive module in the system to deploy** — about 22% of a block, running
at nearly double the tree's median gas per line. A system that can quote its own prices pays for
that ability in deploy cost, which is why most contracts cannot tell you what an operation costs
before you send it.

## What it owns, and what it exposes

<!-- @generated:module-page:INFO-ONE -->
**On chain**

| | |
|---|---|
| module hash | `JyAEdHn7uh41Uo8apC06aWsipneVZG9Fl_oUJu9DXoI` |
| deployed size | 222,145 characters |
| implements | `InfoOneV2` |
| repository source | `1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact` |

**Schemas** — 1, with no tables of its own

`HibernatedNoncesView`

**Capabilities** — 2

`GOV`, `GOV|INFO|DPTF_ADMIN`

**Functions** — 189, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 1 | named object constructors | `UDC_HibernatedNoncesView` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_GasPrice`, `UC_LiquidityTaxDeclaration`, `UC_TrimDecimalTrailingZeros` |
| *(unclassified)* | 185 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `INFO_ATS|AddHotRBT`, `INFO_ATS|AddSecondary` …+179 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|INFO|DPTF_ADMIN`

**Functions** -- 189, grouped by what the prefix promises

*Constructors* (1) — build objects

`UDC_HibernatedNoncesView`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_GasPrice`, `UC_LiquidityTaxDeclaration`, `UC_TrimDecimalTrailingZeros`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Previews* (181) — operation previews for clients

`INFO_ATS|AddHotRBT`, `INFO_ATS|AddSecondary`, `INFO_ATS|Brumate`, `INFO_ATS|Coil`, `INFO_ATS|ColdRecovery`, `INFO_ATS|Constrict`, `INFO_ATS|Control`, `INFO_ATS|ControlColdRecoveryFees`, `INFO_ATS|ControlHotRecoveryFee`, `INFO_ATS|Cull`, `INFO_ATS|Curl`, `INFO_ATS|DirectRecovery`, `INFO_ATS|Fuel`, `INFO_ATS|HOT-RBT|Repurpose`, `INFO_ATS|HOT-RBT|UpdatePendingBranding`, `INFO_ATS|HOT-RBT|UpgradeBranding`, `INFO_ATS|HotRecovery`, `INFO_ATS|Issue`, `INFO_ATS|KickStart`, `INFO_ATS|Redeem`, `INFO_ATS|RemoveSecondary`, `INFO_ATS|Reverse`, `INFO_ATS|RotateOwnership`, `INFO_ATS|SetColdRecoveryDuration`, `INFO_ATS|SetColdRecoveryFees`, `INFO_ATS|SetDirectRecoveryFee`, `INFO_ATS|SetHibernationFees`, `INFO_ATS|SetHotRecoveryFee`, `INFO_ATS|SwitchColdRecovery`, `INFO_ATS|SwitchDirectRecovery`, `INFO_ATS|SwitchHotRecovery`, `INFO_ATS|Syphon`, `INFO_ATS|ToggleElite`, `INFO_ATS|ToggleParameterLock`, `INFO_ATS|ToggleUpgrade`, `INFO_ATS|UpdatePendingBranding`, `INFO_ATS|UpdateRoyalty`, `INFO_ATS|UpdateSyphon`, `INFO_ATS|UpgradeBranding`, `INFO_ATS|VestedCoil`, `INFO_ATS|VestedCurl`, `INFO_ATS|WithdrawRoyalties`, `INFO_DALOS|ControlSmartAccount`, `INFO_DALOS|DeploySmartAccount`, `INFO_DALOS|DeployStandardAccount`, `INFO_DALOS|RotateGovernor`, `INFO_DALOS|RotateGuard`, `INFO_DALOS|RotateSovereign`, `INFO_DALOS|RotateStoa`, `INFO_DALOS|UpdateEliteAccount`, `INFO_DALOS|UpdateEliteAccountSquared`, `INFO_DPOF|AddQuantity`, `INFO_DPOF|BulkTransfer`, `INFO_DPOF|Burn`, `INFO_DPOF|Control`, `INFO_DPOF|DeployAccount`, `INFO_DPOF|Issue`, `INFO_DPOF|Mint`, `INFO_DPOF|MoveCreateRole`, `INFO_DPOF|RotateOwnership`, `INFO_DPOF|ToggleAddQuantityRole`, `INFO_DPOF|ToggleBurnRole`, `INFO_DPOF|ToggleFreezeAccount`, `INFO_DPOF|TogglePause`, `INFO_DPOF|ToggleTransferRole`, `INFO_DPOF|Transfer`, `INFO_DPOF|Transmit`, `INFO_DPOF|UpdatePendingBranding`, `INFO_DPOF|UpgradeBranding`, `INFO_DPOF|WipeClean`, `INFO_DPOF|WipeFull`, `INFO_DPOF|WipeHeavy`, `INFO_DPOF|WipePure`, `INFO_DPOF|WipeSlice`, `INFO_DPOF|WipeSlim`, `INFO_DPTF|BulkTransfer`, `INFO_DPTF|Burn`, `INFO_DPTF|ClearDispo`, `INFO_DPTF|ClearDispoForeign`, `INFO_DPTF|Control`, `INFO_DPTF|DeployAccount`, `INFO_DPTF|DonateFees`, `INFO_DPTF|Issue`, `INFO_DPTF|Mint`, `INFO_DPTF|MultiBulkTransfer`, `INFO_DPTF|MultiTransfer`, `INFO_DPTF|ResetFeeTarget`, `INFO_DPTF|RotateOwnership`, `INFO_DPTF|SetFee`, `INFO_DPTF|SetFeeTarget`, `INFO_DPTF|SetMinMove`, `INFO_DPTF|ToggleBurnRole`, `INFO_DPTF|ToggleFee`, `INFO_DPTF|ToggleFeeExemptionRole`, `INFO_DPTF|ToggleFeeLock`, `INFO_DPTF|ToggleFreezeAccount`, `INFO_DPTF|ToggleMintRole`, `INFO_DPTF|TogglePause`, `INFO_DPTF|ToggleReservation`, `INFO_DPTF|ToggleTransferRole`, `INFO_DPTF|Transfer`, `INFO_DPTF|Transmute`, `INFO_DPTF|UpdatePendingBranding`, `INFO_DPTF|UpgradeBranding`, `INFO_DPTF|Wipe`, `INFO_DPTF|WipeSlim`, `INFO_LIQUID|UnwrapStoa`, `INFO_LIQUID|UnwrapUrStoa`, `INFO_LIQUID|WrapStoa`, `INFO_LIQUID|WrapUrStoa`, `INFO_ORBR|Compress`, `INFO_ORBR|Sublimate`, `INFO_ORBR|SublimateV2`, `INFO_ORBR|WithdrawFees`, `INFO_SWP|AddFrozenLiquidity`, `INFO_SWP|AddGlacialLiquidity`, `INFO_SWP|AddIcedLiquidity`, `INFO_SWP|AddLiquidity`, `INFO_SWP|AddSleepingLiquidity`, `INFO_SWP|AddStandardLiquidity`, `INFO_SWP|ChangeOwnership`, `INFO_SWP|EnableFrozenLP`, `INFO_SWP|EnableSleepingLP`, `INFO_SWP|Firestarter`, `INFO_SWP|Fuel`, `INFO_SWP|IssueStable`, `INFO_SWP|IssueStablePool`, `INFO_SWP|IssueStandard`, `INFO_SWP|IssueStandardPool`, `INFO_SWP|IssueWeighted`, `INFO_SWP|IssueWeightedPool`, `INFO_SWP|ModifyCanChangeOwner`, `INFO_SWP|ModifyWeights`, `INFO_SWP|MultiSwapNoSlippage`, `INFO_SWP|MultiSwapWithSlippage`, `INFO_SWP|RemoveLiquidity`, `INFO_SWP|SingleSwapNoSlippage`, `INFO_SWP|SingleSwapWithSlippage`, `INFO_SWP|SmartSwapNoSlippage`, `INFO_SWP|SmartSwapNoSlippageBundle`, `INFO_SWP|SmartSwapWithSlippage`, `INFO_SWP|SmartSwapWithSlippageBundle`, `INFO_SWP|ToggleAddLiquidity`, `INFO_SWP|ToggleFeeLock`, `INFO_SWP|ToggleSwapCapability`, `INFO_SWP|UpdateAmplifier`, `INFO_SWP|UpdateFee`, `INFO_SWP|UpdatePendingBranding`, `INFO_SWP|UpdatePendingBrandingLPs`, `INFO_SWP|UpdateSpecialFeeTargets`, `INFO_SWP|UpgradeBranding`, `INFO_SWP|UpgradeBrandingLPs`, `INFO_VST|Awake`, `INFO_VST|CreateFrozenLink`, `INFO_VST|CreateHibernatingLink`, `INFO_VST|CreateReservationLink`, `INFO_VST|CreateSleepingLink`, `INFO_VST|CreateVestingLink`, `INFO_VST|Freeze`, `INFO_VST|Hibernate`, `INFO_VST|HibernatedNonceDisplay`, `INFO_VST|HibernatedNoncesDisplay`, `INFO_VST|Merge`, `INFO_VST|RepurposeFrozen`, `INFO_VST|RepurposeHibernating`, `INFO_VST|RepurposeMerge`, `INFO_VST|RepurposeReserved`, `INFO_VST|RepurposeSleeping`, `INFO_VST|RepurposeSlumber`, `INFO_VST|RepurposeVested`, `INFO_VST|Reserve`, `INFO_VST|Sleep`, `INFO_VST|Slumber`, `INFO_VST|ToggleTransferRoleFrozenDPTF`, `INFO_VST|ToggleTransferRoleHibernatingDPOF`, `INFO_VST|ToggleTransferRoleReservedDPTF`, `INFO_VST|ToggleTransferRoleSleepingDPOF`, `INFO_VST|Unreserve`, `INFO_VST|Unsleep`, `INFO_VST|Unvest`, `INFO_VST|Vest`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`
<!-- @end:module-page:INFO-ONE -->

## Traps

**Nothing on chain calls a preview.** Every one is invoked off-chain, and that is what permits the
next trap's remedy.

**Three of its functions are module-only** — defined here and deliberately absent from its
interface. That is legal (a module may exceed its interface) and it is the read layer's escape from
the cascade rule: adding a function to a *published* interface would mean a new version, and every
interface naming it plus every consumer bumping with it. For a read nothing on chain calls, that is
the wrong trade.

**A preview's parameter list usually differs from the operation's** — 414 of 427 across the system.
Bind by name; positional binding type-checks and prices a different question.

**And a copied formatter once reached mainnet with an ASCII `c` in place of a cent sign**, so prices
rendered as `0.253c`. It was found only by diffing the new module's output against the old one
field by field — which is now the standard: assert a port equals the function it replaces, on a
real input and on an absent one.
