# PYTHIA — external data lanes

## What it is for

The bridge to off-chain data: registering consumer lanes, and authorising an external writer to
publish into them.

It is how the protocol reaches information it cannot compute — prices, external state — without
trusting any single caller by default.

## Where it sits

A Stage-1 core near the top, below its Talos wrapper.

## What it owns, and what it exposes

<!-- @generated:module-page:PYTHIA -->
**On chain**

| | |
|---|---|
| module hash | `KPTmyuIIismmZ0cHaYWDdsmydKMVNGNR4ylzCMbIsiQ` |
| deployed size | 75,563 characters |
| implements | `PythiaV5`, `PythiaLedgerV3`, `OuronetPolicyV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact` |

**Tables it owns** — 8

`PYTHIA|T|ApiKeys`, `PYTHIA|T|Config`, `PYTHIA|T|DualLinks`, `PYTHIA|T|PythDaily`, `PYTHIA|T|PythTotal`, `PYTHIA|T|Revocation`, `P|MT`, `P|T`

**Schemas** — 4

`PYTHIA|S|ApiKey`, `PYTHIA|S|Config`, `PYTHIA|S|DualLink`, `PYTHIA|S|Revocation`

**Capabilities** — 13

`GOV`, `GOV|PYTHIA_ADMIN`, `PYTHIA|A>FLUSH`, `PYTHIA|A>LINK-DUAL`, `PYTHIA|A>REVOKE-DUAL`, `PYTHIA|C>DEPLOY-API-KEY`, `PYTHIA|C>LINK-DUAL`, `PYTHIA|C>REVOKE-DUAL`, `PYTHIA|C>UPDATE-DUAL-LANE`, `PYTHIA|CRONOTON`, `PYTHIA|OWNER`, `P|PYTHIA|CALLER`, `SECURE`

**Functions** — 116, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 3 | returns what an operation will charge | `URCi_DeployApiKey`, `URCi_RevokeLink`, `URCi_UpdateDualConsumerLane` |
| `URH_` heavy reads | 10 | a scan -- expensive by construction | `URH_ActiveDualLinkSet`, `URH_ApiKeyByConsumer`, `URH_ApiKeyCount`, `URH_ApiKeyCountStr`, `URH_DualLinkCount`, `URH_ListActiveDualLinks` …+4 |
| `UEV_` validators | 5 | read and enforce; may abort the transaction | `UEV_DualPairForLink`, `UEV_DualPairReadyForActivate`, `UEV_ExecutorIsHalfOwner`, `UEV_FlushEntries`, `UEV_ValidateCompositeDualLinkKey` |
| `UDC_` constructors | 5 | named object constructors | `UDC_DualLinkView`, `UDC_PythDaily`, `UDC_PythFlushEntry`, `UDC_PythMetrics`, `UDC_PythTotal` |
| `UCk_` pure compute (key) | 1 | builds a composite table key | `UCk_PythDaily` |
| `UC_` pure compute | 16 | arguments only -- no reads, no enforce | `UC_AddPythMetrics`, `UC_AutonomousConsumerLane`, `UC_ChainEpoch`, `UC_CurrentChainEpoch`, `UC_DeployPrice`, `UC_DualLinkKey` …+10 |
| `UR_` readers | 22 | table reads; no enforce, no writes | `UR_ApiKeyBySlot`, `UR_ApiKeyRowOrNull`, `UR_Config`, `UR_Counterpart`, `UR_DeployPrice`, `UR_DualLinkConsumerLane` …+16 |
| `WI_` writers (insert) | 3 | one write site each | `WI_ApiKey`, `WI_DualLink`, `WI_PythDaily` |
| `WW_` writers (upsert) | 3 | one write site each | `WW_Config`, `WW_PythTotal`, `WW_Revocation` |
| `XI_` protected (internal) | 3 | this module only | `XI_ApplyDualCounterparts`, `XI_FlushPythLedger`, `XI_RecordRevocationAtHeight` |
| `A_` admin | 5 | admin-key mutations | `A_Flush`, `A_LinkDualApiKey`, `A_RevokeDualLink`, `A_UpdateDeployPrice`, `A_UpdateRenamePrice` |
| `C_` client | 4 | reached via Talos, never called directly | `C_DeployApolloPythiaApiKey`, `C_LinkDualApiKey`, `C_RevokeDualLink`, `C_UpdateDualConsumerLane` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 27 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|CronotonKey`, `GOV|Demiurgoi`, `INFO_PYTHIA|DeployApiKey`, `INFO_PYTHIA|Link` …+21 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `PYTHIA|S|PythDaily`, `PYTHIA|S|PythFlushAcc`, `PYTHIA|S|PythFlushEntry`, `PYTHIA|S|PythMetrics`, `PYTHIA|S|PythTotal`

**Capabilities** -- 13

`GOV`, `GOV|PYTHIA_ADMIN`, `PYTHIA|A>FLUSH`, `PYTHIA|A>LINK-DUAL`, `PYTHIA|A>REVOKE-DUAL`, `PYTHIA|C>DEPLOY-API-KEY`, `PYTHIA|C>LINK-DUAL`, `PYTHIA|C>REVOKE-DUAL`, `PYTHIA|C>UPDATE-DUAL-LANE`, `PYTHIA|CRONOTON`, `PYTHIA|OWNER`, `P|PYTHIA|CALLER`, `SECURE`

**Functions** -- 116, grouped by what the prefix promises

*Cost readers* (3) — price an operation; the exec path and the preview both call these

`URCi_DeployApiKey`, `URCi_RevokeLink`, `URCi_UpdateDualConsumerLane`

*Heavy reads* (10) — scan a table -- OFF the execution path, cost grows with data

`URH_ActiveDualLinkSet`, `URH_ApiKeyByConsumer`, `URH_ApiKeyCount`, `URH_ApiKeyCountStr`, `URH_DualLinkCount`, `URH_ListActiveDualLinks`, `URH_ListAllApiKeys`, `URH_ListAllDualLinks`, `URH_ListInactiveDualLinks`, `URH_ListPythDaily`

*Point reads* (27) — one row or field by key

`P|UR_IMP`, `UR_AKY|Data`, `UR_ApiKeyBySlot`, `UR_ApiKeyRowOrNull`, `UR_Config`, `UR_Counterpart`, `UR_DLK|Data`, `UR_DeployPrice`, `UR_DualLinkConsumerLane`, `UR_DualLinkIzActive`, `UR_DualLinkIzActiveOrFalse`, `UR_DualLinkRowOrNull`, `UR_OwnerAccount`, `UR_Public`, `UR_PythCurrentDay`, `UR_PythDailyExists`, `UR_PythDay`, `UR_PythLedgerEpochStart`, `UR_PythMaxFlushBatch`, `UR_PythTotal`, `UR_PythTotal|LastDay`, `UR_PythTotal|TotalMetrics`, `UR_RegisteredAt`, `UR_RenamePrice`, `UR_RevocationAtHeight`, `UR_RevocationEpoch`, `UR_UpdatedAt`

*Validators* (6) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_DualPairForLink`, `UEV_DualPairReadyForActivate`, `UEV_ExecutorIsHalfOwner`, `UEV_FlushEntries`, `UEV_ValidateCompositeDualLinkKey`

*Constructors* (13) — build objects

`UDC_AKY|ApiKey`, `UDC_AKY|Unregistered`, `UDC_AKY|WithRegisteredFlag`, `UDC_DLK|DualLink`, `UDC_DLK|Unregistered`, `UDC_DLK|WithRegisteredFlag`, `UDC_DualLinkView`, `UDC_PythDaily`, `UDC_PythFlushEntry`, `UDC_PythMetrics`, `UDC_PythMetrics|Zero`, `UDC_PythTotal`, `UDC_PythTotal|Zero`

*Pure compute* (16) — arguments only; no reads, no enforce

`UC_AddPythMetrics`, `UC_AutonomousConsumerLane`, `UC_ChainEpoch`, `UC_CurrentChainEpoch`, `UC_DeployPrice`, `UC_DualLinkKey`, `UC_DualLinkSmart`, `UC_DualLinkStandard`, `UC_FeeDiscountAnchor`, `UC_FlushAccFromTotal`, `UC_FlushEntryMetrics`, `UC_IsStandardApollo`, `UC_MaxDay`, `UC_PythDayOrdinal`, `UC_RenamePrice`, `UC_RevokeIgnisFee`

*Client entry* (4) — builds the bill; reachable only through Talos

`C_DeployApolloPythiaApiKey`, `C_LinkDualApiKey`, `C_RevokeDualLink`, `C_UpdateDualConsumerLane`

*Admin* (10) — admin-key mutations

`A_Flush`, `A_LinkDualApiKey`, `A_RevokeDualLink`, `A_UpdateDeployPrice`, `A_UpdateRenamePrice`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (4) — this module only; writes under a capability

`XI_1|ApplyOneFlushEntry`, `XI_ApplyDualCounterparts`, `XI_FlushPythLedger`, `XI_RecordRevocationAtHeight`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|CronotonKey`, `GOV|Demiurgoi`

*Previews* (4) — operation previews for clients

`INFO_PYTHIA|DeployApiKey`, `INFO_PYTHIA|Link`, `INFO_PYTHIA|RevokeLink`, `INFO_PYTHIA|UpdateDualConsumerLane`

*Unclassified* (15) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`, `UCk_PythDaily`, `WI_ApiKey`, `WI_DualLink`, `WI_PythDaily`, `WU_ApiKey|Counterpart`, `WU_DualLink|ConsumerLane`, `WU_DualLink|IzActive`, `WU_PythDaily|FlushedAt`, `WU_PythDaily|IzSealed`, `WU_PythDaily|Metrics`, `WW_Config`, `WW_PythTotal`, `WW_Revocation`
<!-- @end:module-page:PYTHIA -->

## Traps

**Its fees are non-discountable.** An account's elite tier reduces almost everything; it does not
reduce these.

**One of its operations is free, and safe because it is bounded rather than cheap.** Linking takes
no payer and collects nothing, while its three siblings all charge. It is safe because linking
requires two already-deployed halves at real cost, and **counterparts are never cleared** — revoke
only deactivates — so it is one-shot per pair, forever. That bound is pinned by a test. **If
counterparts ever become clearable, the operation stops being safe.**

**Its identities use a different curve from Ouronet accounts** — same 162-character geometry, same
glyph alphabet, different mathematics and a less-reviewed curve. See
`80-cryptography/01-why-custom-cryptography.md`.
