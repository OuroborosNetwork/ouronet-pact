# DEMIPAD — the launchpad venue

## What it is for

A **permissioned venue** where assets are sold for one of three tokens while the protocol retains a decreasing royalty — from 15% down to 0.3% as volume accumulates.

It is generic over all four asset types, and stores each sale's price as an **open object** it never interprets. That is the extension point: one venue hosts a flat price, a share-based price, a weight-based price and a time curve without knowing any of them.

Full treatment: `25-defi/04-the-launchpad.md`.

## Where it sits

A Stage-2 core. Five citizen sales compose it; none can reach inside it.

## What it owns, and what it exposes

<!-- @generated:module-page:DEMIPAD -->
**On chain**

| | |
|---|---|
| module hash | `ZP7Db3x-kc-pJFF_TwhYc7HLXIz2E1TyHnL26gSFYOo` |
| deployed size | 80,440 characters |
| implements | `OuronetPolicyV2`, `DemiourgosLaunchpadV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` |

**Tables it owns** — 4

`DEMIPAD|T|Ledger`, `DEMIPAD|T|Properties`, `P|MT`, `P|T`

**Capabilities** — 24

`DEMIPAD|C>DEFINE-PRICE`, `DEMIPAD|C>DEPOSIT`, `DEMIPAD|C>FUEL-NON-FUNGIBLE`, `DEMIPAD|C>FUEL-ORTO-FUNGIBLE`, `DEMIPAD|C>FUEL-SEMI-FUNGIBLE`, `DEMIPAD|C>FUEL-TRUE-FUNGIBLE`, `DEMIPAD|C>REGISTER`, `DEMIPAD|C>REGISTERED-ACCESS`, `DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE`, `DEMIPAD|C>RETRIEVAL-GATE`, `DEMIPAD|C>RETRIEVE-NON-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE`, `DEMIPAD|C>SECURE-ADMIN`, `DEMIPAD|C>TOGGLE-RETRIEVAL`, `DEMIPAD|C>TOGGLE-SALE`, `DEMIPAD|C>WITHDRAW`, `DEMIPAD|GOV`, `GOV`, `GOV|DEMIPAD_ADMIN`, `P|DEMIPAD|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 90, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 4 | returns what an operation will charge | `URCi_Deposit`, `URCi_TransmitCollectables`, `URCi_TransmitNonFungibles`, `URCi_TransmitSemiFungibles` |
| `URC_` derived reads | 2 | read and derive; no enforce | `URC_Acquire`, `URC_Prices` |
| `UEV_` validators | 5 | read and enforce; may abort the transaction | `UEV_AssetFungibility`, `UEV_DepositDollarAmount`, `UEV_DirectInjection`, `UEV_Fungibility`, `UEV_SlippageCost` |
| `UDC_` constructors | 2 | named object constructors | `UDC_Costs`, `UDC_LaunchpadPrices` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_ComputeDepositRoyalty` |
| `UC_` pure compute | 4 | arguments only -- no reads, no enforce | `UC_GenerateRoyaltyIntervals`, `UC_LaunchpadEnviromentSplit`, `UC_SlippageFactor`, `UC_Type` |
| `UR_` readers | 17 | table reads; no enforce, no writes | `UR_AssetState`, `UR_CheckRegistration`, `UR_DirectInjection`, `UR_Fungibility`, `UR_IzOURO`, `UR_IzSSTOA` …+11 |
| `CAP_` ownership gates | 2 | account-ownership enforcement | `CAP_Acquire`, `CAP_Owner` |
| `XI_` protected (internal) | 5 | this module only | `XI_DepositForAsset`, `XI_DepositResidents`, `XI_RegisterAsset`, `XI_SatisfyEnviroment`, `XI_TransmitCollectables` |
| `A_` admin | 4 | admin-key mutations | `A_DefinePrice`, `A_RegisterAssetToLaunchpad`, `A_ToggleOpenForBusiness`, `A_ToggleRetrieval` |
| `C_` client | 6 | reached via Talos, never called directly | `C_Deposit`, `C_TransmitNonFungibles`, `C_TransmitOrtoFungible`, `C_TransmitSemiFungibles`, `C_TransmitTrueFungible`, `C_Withdraw` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 29 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `CT_Namespace`, `GOV|DEMIPAD|PBL`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi` …+23 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `Costs`, `DEMIPAD|Holdings`, `DEMIPAD|Prices`, `DEMIPAD|Properties`, `RoyaltyInterval`

**Capabilities** -- 24

`DEMIPAD|C>DEFINE-PRICE`, `DEMIPAD|C>DEPOSIT`, `DEMIPAD|C>FUEL-NON-FUNGIBLE`, `DEMIPAD|C>FUEL-ORTO-FUNGIBLE`, `DEMIPAD|C>FUEL-SEMI-FUNGIBLE`, `DEMIPAD|C>FUEL-TRUE-FUNGIBLE`, `DEMIPAD|C>REGISTER`, `DEMIPAD|C>REGISTERED-ACCESS`, `DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE`, `DEMIPAD|C>RETRIEVAL-GATE`, `DEMIPAD|C>RETRIEVE-NON-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE`, `DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE`, `DEMIPAD|C>SECURE-ADMIN`, `DEMIPAD|C>TOGGLE-RETRIEVAL`, `DEMIPAD|C>TOGGLE-SALE`, `DEMIPAD|C>WITHDRAW`, `DEMIPAD|GOV`, `GOV`, `GOV|DEMIPAD_ADMIN`, `P|DEMIPAD|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 90, grouped by what the prefix promises

*Cost readers* (4) — price an operation; the exec path and the preview both call these

`URCi_Deposit`, `URCi_TransmitCollectables`, `URCi_TransmitNonFungibles`, `URCi_TransmitSemiFungibles`

*Derived reads* (2) — read and compute; no enforce

`URC_Acquire`, `URC_Prices`

*Point reads* (21) — one row or field by key

`P|UR_IMP`, `UR_AssetState`, `UR_CheckRegistration`, `UR_DirectInjection`, `UR_Fungibility`, `UR_IzOURO`, `UR_IzSSTOA`, `UR_LaunchpadState`, `UR_OURO`, `UR_OURO|Funds`, `UR_OpenForBusiness`, `UR_Price`, `UR_Retrieval`, `UR_SSTOA`, `UR_SSTOA|Funds`, `UR_TotalDollarzRaised`, `UR_TotalOURORaised`, `UR_TotalSSTOARaised`, `UR_TotalWSTOARaised`, `UR_WSTOA`, `UR_WSTOA|Funds`

*Validators* (6) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AssetFungibility`, `UEV_DepositDollarAmount`, `UEV_DirectInjection`, `UEV_Fungibility`, `UEV_SlippageCost`

*Constructors* (3) — build objects

`UDC_Costs`, `UDC_DEMIPAD|Holdings`, `UDC_LaunchpadPrices`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_ComputeDepositRoyalty`

*Pure compute* (4) — arguments only; no reads, no enforce

`UC_GenerateRoyaltyIntervals`, `UC_LaunchpadEnviromentSplit`, `UC_SlippageFactor`, `UC_Type`

*Ownership checks* (2) — account-ownership enforcement

`CAP_Acquire`, `CAP_Owner`

*Client entry* (6) — builds the bill; reachable only through Talos

`C_Deposit`, `C_TransmitNonFungibles`, `C_TransmitOrtoFungible`, `C_TransmitSemiFungibles`, `C_TransmitTrueFungible`, `C_Withdraw`

*Admin* (9) — admin-key mutations

`A_DefinePrice`, `A_RegisterAssetToLaunchpad`, `A_ToggleOpenForBusiness`, `A_ToggleRetrieval`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (21) — this module only; writes under a capability

`XI_DepositForAsset`, `XI_DepositResidents`, `XI_RegisterAsset`, `XI_SatisfyEnviroment`, `XI_TransmitCollectables`, `XI_U|Funds`, `XI_U|FundsOURO`, `XI_U|FundsSSTOA`, `XI_U|FundsWSTOA`, `XI_U|OURO`, `XI_U|OpenForBusiness`, `XI_U|Price`, `XI_U|Retrieval`, `XI_U|SSTOA`, `XI_U|TotalDollarzRaised`, `XI_U|TotalOURORaised`, `XI_U|TotalRaised`, `XI_U|TotalSSTOARaised`, `XI_U|TotalWSTOARaised`, `XI_U|WSTOA`, `XI_W|DirectInjection`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (4) — keysets and protocol constants

`GOV|DEMIPAD|PBL`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`, `GOV|LaunchpadKey`

*Unclassified* (5) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `CT_Namespace`, `URv_Funds`, `URv_TotalRaised`
<!-- @end:module-page:DEMIPAD -->

## Traps

**The royalty is marginal, not tiered.** A deposit spanning a boundary is integrated across the intervals it crosses, so a large buyer is never penalised for the size of a single purchase.

**Its revenue split is NOT the protocol's.** Both go four ways as 10/20/30/40 through the same helper, but **the first two destinations are swapped** — gas station 10% and holding company 20% here, the reverse for protocol fees. Reusing the protocol's table to describe this one attributes the wrong shares to the wrong accounts.

**There is no protocol fee on a launchpad operation.** What a buyer pays is a price, not a charge, and every sale's preview says so explicitly.
