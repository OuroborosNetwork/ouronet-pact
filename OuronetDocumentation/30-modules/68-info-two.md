# INFO-TWO

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:INFO-TWO -->
**On chain**

| | |
|---|---|
| module hash | `LI_UBB66mCnjNl9QU0TLU5QjJYF7BSzdQQ9nxhhBF80` |
| deployed size | 73,464 characters |
| implements | — |
| repository source | `1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact` |

**Capabilities** — 2

`GOV`, `GOV|INFO|DPTF_ADMIN`

**Functions** — 153, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 153 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|SWP|SC_NAME`, `INFO_DEMIPAD|Deposit`, `INFO_DEMIPAD|FuelNonFungible` …+147 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|INFO|DPTF_ADMIN`

**Functions** -- 153, grouped by what the prefix promises

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|SWP|SC_NAME`

*Previews* (149) — operation previews for clients

`INFO_DEMIPAD|Deposit`, `INFO_DEMIPAD|FuelNonFungible`, `INFO_DEMIPAD|FuelOrtoFungible`, `INFO_DEMIPAD|FuelSemiFungible`, `INFO_DEMIPAD|FuelTrueFungible`, `INFO_DEMIPAD|RetrieveNonFungible`, `INFO_DEMIPAD|RetrieveOrtoFungible`, `INFO_DEMIPAD|RetrieveSemiFungible`, `INFO_DEMIPAD|RetrieveTrueFungible`, `INFO_DEMIPAD|Withdraw`, `INFO_DPDC-I|Issue`, `INFO_DPDC-MNG|Simple`, `INFO_DPDC-MNG|WipeFull`, `INFO_DPDC-MNG|WipeMulti`, `INFO_DPDC-N|Bulk`, `INFO_DPDC-N|Field`, `INFO_DPDC-R|Move`, `INFO_DPDC-R|Toggle`, `INFO_DPDC|BulkTransfer`, `INFO_DPDC|MultiTransfer`, `INFO_DPDC|UpgradeBranding`, `INFO_DPNF|Break`, `INFO_DPNF|BulkTransfer`, `INFO_DPNF|Burn`, `INFO_DPNF|Control`, `INFO_DPNF|Create`, `INFO_DPNF|DefineCompositeSet`, `INFO_DPNF|DefineHybridSet`, `INFO_DPNF|DefinePrimordialSet`, `INFO_DPNF|EnableNonceFragmentation`, `INFO_DPNF|EnableSetClassFragmentation`, `INFO_DPNF|Issue`, `INFO_DPNF|Make`, `INFO_DPNF|MakeFragments`, `INFO_DPNF|MergeFragments`, `INFO_DPNF|MoveCreateRole`, `INFO_DPNF|MoveRecreateRole`, `INFO_DPNF|MoveSetUriRole`, `INFO_DPNF|RemoveNonceScore`, `INFO_DPNF|RemoveSetNonceScore`, `INFO_DPNF|RenameSet`, `INFO_DPNF|Repurpose`, `INFO_DPNF|RepurposeFragments`, `INFO_DPNF|Respawn`, `INFO_DPNF|ToggleBurnRole`, `INFO_DPNF|ToggleExemptionRole`, `INFO_DPNF|ToggleFreezeAccount`, `INFO_DPNF|ToggleModifyCreatorRole`, `INFO_DPNF|ToggleModifyRoyaltiesRole`, `INFO_DPNF|TogglePause`, `INFO_DPNF|ToggleSet`, `INFO_DPNF|ToggleTransferRole`, `INFO_DPNF|ToggleUpdateRole`, `INFO_DPNF|TransferNonce`, `INFO_DPNF|TransferNonces`, `INFO_DPNF|UpdateNonce`, `INFO_DPNF|UpdateNonceDescription`, `INFO_DPNF|UpdateNonceIgnisRoyalty`, `INFO_DPNF|UpdateNonceMetaData`, `INFO_DPNF|UpdateNonceName`, `INFO_DPNF|UpdateNonceRoyalty`, `INFO_DPNF|UpdateNonceScore`, `INFO_DPNF|UpdateNonceURI`, `INFO_DPNF|UpdateNonces`, `INFO_DPNF|UpdatePendingBranding`, `INFO_DPNF|UpdateSetNonce`, `INFO_DPNF|UpdateSetNonceDescription`, `INFO_DPNF|UpdateSetNonceIgnisRoyalty`, `INFO_DPNF|UpdateSetNonceMetaData`, `INFO_DPNF|UpdateSetNonceName`, `INFO_DPNF|UpdateSetNonceRoyalty`, `INFO_DPNF|UpdateSetNonceScore`, `INFO_DPNF|UpdateSetNonceURI`, `INFO_DPNF|UpdateSetNonces`, `INFO_DPNF|UpgradeBranding`, `INFO_DPNF|WipeClean`, `INFO_DPNF|WipeDirty`, `INFO_DPNF|WipeFull`, `INFO_DPNF|WipeHeavy`, `INFO_DPNF|WipeNonce`, `INFO_DPNF|WipePure`, `INFO_DPNF|WipeSlice`, `INFO_DPSF|AddQuantity`, `INFO_DPSF|Break`, `INFO_DPSF|BulkTransfer`, `INFO_DPSF|Burn`, `INFO_DPSF|Control`, `INFO_DPSF|Create`, `INFO_DPSF|DefineCompositeSet`, `INFO_DPSF|DefineHybridSet`, `INFO_DPSF|DefinePrimordialSet`, `INFO_DPSF|EnableNonceFragmentation`, `INFO_DPSF|EnableSetClassFragmentation`, `INFO_DPSF|Issue`, `INFO_DPSF|IssueCompany`, `INFO_DPSF|Make`, `INFO_DPSF|MakeFragments`, `INFO_DPSF|MergeFragments`, `INFO_DPSF|MorphEquity`, `INFO_DPSF|MoveCreateRole`, `INFO_DPSF|MoveRecreateRole`, `INFO_DPSF|MoveSetUriRole`, `INFO_DPSF|RemoveNonceScore`, `INFO_DPSF|RemoveSetNonceScore`, `INFO_DPSF|RenameSet`, `INFO_DPSF|Repurpose`, `INFO_DPSF|RepurposeFragments`, `INFO_DPSF|ToggleAddQuantityRole`, `INFO_DPSF|ToggleBurnRole`, `INFO_DPSF|ToggleExemptionRole`, `INFO_DPSF|ToggleFreezeAccount`, `INFO_DPSF|ToggleModifyCreatorRole`, `INFO_DPSF|ToggleModifyRoyaltiesRole`, `INFO_DPSF|TogglePause`, `INFO_DPSF|ToggleSet`, `INFO_DPSF|ToggleTransferRole`, `INFO_DPSF|ToggleUpdateRole`, `INFO_DPSF|TransferNonce`, `INFO_DPSF|TransferNonces`, `INFO_DPSF|UpdateNonce`, `INFO_DPSF|UpdateNonceDescription`, `INFO_DPSF|UpdateNonceIgnisRoyalty`, `INFO_DPSF|UpdateNonceMetaData`, `INFO_DPSF|UpdateNonceName`, `INFO_DPSF|UpdateNonceRoyalty`, `INFO_DPSF|UpdateNonceScore`, `INFO_DPSF|UpdateNonceURI`, `INFO_DPSF|UpdateNonces`, `INFO_DPSF|UpdatePendingBranding`, `INFO_DPSF|UpdateSetNonce`, `INFO_DPSF|UpdateSetNonceDescription`, `INFO_DPSF|UpdateSetNonceIgnisRoyalty`, `INFO_DPSF|UpdateSetNonceMetaData`, `INFO_DPSF|UpdateSetNonceName`, `INFO_DPSF|UpdateSetNonceRoyalty`, `INFO_DPSF|UpdateSetNonceScore`, `INFO_DPSF|UpdateSetNonceURI`, `INFO_DPSF|UpdateSetNonces`, `INFO_DPSF|UpgradeBranding`, `INFO_DPSF|WipeClean`, `INFO_DPSF|WipeDirty`, `INFO_DPSF|WipeFull`, `INFO_DPSF|WipeHeavy`, `INFO_DPSF|WipeNonce`, `INFO_DPSF|WipeNoncePartialy`, `INFO_DPSF|WipePure`, `INFO_DPSF|WipeSlice`, `INFO_EQUITY|IssueCompany`, `INFO_EQUITY|MorphEquity`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`
<!-- @end:module-page:INFO-TWO -->

## Traps

_To be written._
