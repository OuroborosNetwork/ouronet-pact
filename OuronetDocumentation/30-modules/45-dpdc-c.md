# DPDC-C — create, credit and debit

## What it is for

The mint-and-move engine: creating nonces, and crediting or debiting holdings.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

Above the state core, below everything that issues or moves a collectable.

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-C -->
**On chain**

| | |
|---|---|
| module hash | `IcLk0rRSSFFM20KIurtArOv-bhBTDGpp00Cm-YcBlHI` |
| deployed size | 57,541 characters |
| implements | `OuronetPolicyV2`, `DpdcCreateV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 35

`DPDC-C|C>MULTI-CREDIT`, `DPDC-C|C>REGISTER-MULTIPLE-NONCES`, `DPDC-C|C>REGISTER-NONCES`, `DPDC-C|C>REGISTER-SINGLE-NONCE`, `DPDC-C|C>SINGLE-CREDIT`, `DPDC-C|C>SINGLE-DEBIT`, `DPDC-C|CX>MULTI-CREDIT`, `DPDC|C>HYBRID-MULTI-CREDIT`, `DPDC|C>MULTI-DEBIT`, `DPDC|CX>MULTI-DEBIT`, `DPNF|C>CREDIT-FRAGMENT-NONCE`, `DPNF|C>CREDIT-FRAGMENT-NONCES`, `DPNF|C>CREDIT-HYBRID-NONCES`, `DPNF|C>CREDIT-NONCE`, `DPNF|C>CREDIT-NONCES`, `DPNF|C>DEBIT-FRAGMENT-NONCE`, `DPNF|C>DEBIT-FRAGMENT-NONCES`, `DPNF|C>DEBIT-HYBRID-NONCES`, `DPNF|C>DEBIT-NONCE`, `DPNF|C>DEBIT-NONCES`, `DPSF|C>CREDIT-FRAGMENT-NONCE`, `DPSF|C>CREDIT-FRAGMENT-NONCES`, `DPSF|C>CREDIT-HYBRID-NONCES`, `DPSF|C>CREDIT-NONCE`, `DPSF|C>CREDIT-NONCES`, `DPSF|C>DEBIT-FRAGMENT-NONCE`, `DPSF|C>DEBIT-FRAGMENT-NONCES`, `DPSF|C>DEBIT-HYBRID-NONCES`, `DPSF|C>DEBIT-NONCE`, `DPSF|C>DEBIT-NONCES`, `GOV`, `GOV|DPDC-C_ADMIN`, `P|DPDC-C|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 57, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_CreateNewNonces`, `URCi_RegisterCollectablesPrice` |
| `UEV_` validators | 7 | read and enforce; may abort the transaction | `UEV_Amount`, `UEV_ExecutorIsCreateRole`, `UEV_FragmentCreditAmount`, `UEV_HybridNonces`, `UEV_NonceDataForCreation`, `UEV_NonceType` …+1 |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_AndTruths` |
| `XI_` protected (internal) | 12 | this module only | `XI_CreditCollectables`, `XI_CreditNFT`, `XI_CreditOrDebitCollectables`, `XI_CreditSFT`, `XI_DebitCollectables`, `XI_DebitNFT` …+6 |
| `XE_` protected (external) | 16 | for other modules; opens with the IMC gate | `XE_CreditNFT-FragmentNonce`, `XE_CreditNFT-FragmentNonces`, `XE_CreditNFT-HybridNonces`, `XE_CreditSFT-FragmentNonce`, `XE_CreditSFT-FragmentNonces`, `XE_CreditSFT-HybridNonces` …+10 |
| `XB_` protected (both) | 4 | internal and external | `XB_CreditNFT-Nonce`, `XB_CreditNFT-Nonces`, `XB_CreditSFT-Nonce`, `XB_CreditSFT-Nonces` |
| `C_` client | 2 | reached via Talos, never called directly | `C_CreateNewNonce`, `C_CreateNewNonces` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `XIv_CreditOrDebitDPDC`, `XIv_MappedCreditOrDebitDPDC` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 35

`DPDC-C|C>MULTI-CREDIT`, `DPDC-C|C>REGISTER-MULTIPLE-NONCES`, `DPDC-C|C>REGISTER-NONCES`, `DPDC-C|C>REGISTER-SINGLE-NONCE`, `DPDC-C|C>SINGLE-CREDIT`, `DPDC-C|C>SINGLE-DEBIT`, `DPDC-C|CX>MULTI-CREDIT`, `DPDC|C>HYBRID-MULTI-CREDIT`, `DPDC|C>MULTI-DEBIT`, `DPDC|CX>MULTI-DEBIT`, `DPNF|C>CREDIT-FRAGMENT-NONCE`, `DPNF|C>CREDIT-FRAGMENT-NONCES`, `DPNF|C>CREDIT-HYBRID-NONCES`, `DPNF|C>CREDIT-NONCE`, `DPNF|C>CREDIT-NONCES`, `DPNF|C>DEBIT-FRAGMENT-NONCE`, `DPNF|C>DEBIT-FRAGMENT-NONCES`, `DPNF|C>DEBIT-HYBRID-NONCES`, `DPNF|C>DEBIT-NONCE`, `DPNF|C>DEBIT-NONCES`, `DPSF|C>CREDIT-FRAGMENT-NONCE`, `DPSF|C>CREDIT-FRAGMENT-NONCES`, `DPSF|C>CREDIT-HYBRID-NONCES`, `DPSF|C>CREDIT-NONCE`, `DPSF|C>CREDIT-NONCES`, `DPSF|C>DEBIT-FRAGMENT-NONCE`, `DPSF|C>DEBIT-FRAGMENT-NONCES`, `DPSF|C>DEBIT-HYBRID-NONCES`, `DPSF|C>DEBIT-NONCE`, `DPSF|C>DEBIT-NONCES`, `GOV`, `GOV|DPDC-C_ADMIN`, `P|DPDC-C|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 57, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_CreateNewNonces`, `URCi_RegisterCollectablesPrice`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (8) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Amount`, `UEV_ExecutorIsCreateRole`, `UEV_FragmentCreditAmount`, `UEV_HybridNonces`, `UEV_NonceDataForCreation`, `UEV_NonceType`, `UEV_NonceTypeMapper`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_AndTruths`

*Client entry* (2) — builds the bill; reachable only through Talos

`C_CreateNewNonce`, `C_CreateNewNonces`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (16) — callable by other modules only

`XE_CreditNFT-FragmentNonce`, `XE_CreditNFT-FragmentNonces`, `XE_CreditNFT-HybridNonces`, `XE_CreditSFT-FragmentNonce`, `XE_CreditSFT-FragmentNonces`, `XE_CreditSFT-HybridNonces`, `XE_DebitNFT-FragmentNonce`, `XE_DebitNFT-FragmentNonces`, `XE_DebitNFT-HybridNonces`, `XE_DebitNFT-Nonce`, `XE_DebitNFT-Nonces`, `XE_DebitSFT-FragmentNonce`, `XE_DebitSFT-FragmentNonces`, `XE_DebitSFT-HybridNonces`, `XE_DebitSFT-Nonce`, `XE_DebitSFT-Nonces`

*Internal + external* (4) — callable both ways

`XB_CreditNFT-Nonce`, `XB_CreditNFT-Nonces`, `XB_CreditSFT-Nonce`, `XB_CreditSFT-Nonces`

*Internal writes* (12) — this module only; writes under a capability

`XI_CreditCollectables`, `XI_CreditNFT`, `XI_CreditOrDebitCollectables`, `XI_CreditSFT`, `XI_DebitCollectables`, `XI_DebitNFT`, `XI_DebitSFT`, `XI_MappedUpdateOwnerNFT`, `XI_RegisterCollectables`, `XI_RegisterCollectionElement`, `XI_RegisterMultipleNonces`, `XI_RegisterSingleNonce`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (3) — no known prefix -- worth asking why

`CT_Bar`, `XIv_CreditOrDebitDPDC`, `XIv_MappedCreditOrDebitDPDC`
<!-- @end:module-page:DPDC-C -->

## Traps

**A non-fungible's quantity is locked to one in two places**, and both checks are annotated as unreachable by construction — every caller passes the literal. They are kept anyway, because the thing they guard is a *type invariant* rather than a caller convention. Deleting them would be safe today and unsafe after the next new caller.

**Fragment credits must be a positive multiple of 1,000.** That bound was once absent entirely on the non-fungible path — defence in depth, since the only live caller can produce exactly 1,000.
