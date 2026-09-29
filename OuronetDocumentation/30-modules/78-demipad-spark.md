# DEMIPAD-SPARK — the Spark sale

## What it is for

Sells a **redeemable** token at a flat dollar price.

A **pure-citizen sale** on the sovereign launchpad venue. It owns what a unit costs and what is available; the venue owns custody, the money-in leg and the royalty. Billed Σ-wise — once per sovereign operation it composes. Full treatment: `25-defi/04-the-launchpad.md`.

## Where it sits

A citizen module above the launchpad venue.

## What it owns, and what it exposes

<!-- @generated:module-page:DEMIPAD-SPARK -->
**On chain**

| | |
|---|---|
| module hash | `1SZJcKAoE7JZhNWn4MFIfO-dHxv9FcovmE0e7ju8soA` |
| deployed size | 32,823 characters |
| implements | `OuronetPolicyV2`, `SparksV2` |
| repository source | `2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact` |

**Tables it owns** — 3

`P|MT`, `P|T`, `SPARK|T|Properties`

**Schemas** — 1

`SPARK|PropertiesSchema`

**Capabilities** — 10

`GOV`, `GOV|SPARK_ADMIN`, `P|PAD-SPARK|REMOTE-GOV`, `P|SECURE-CALLER`, `P|SPARK|CALLER`, `SECURE`, `SPARK|C>BUY`, `SPARK|C>REEDEM-ALL`, `SPARK|C>REEDEM-FEW`, `SPARK|C>X_REEDEM`

**Functions** — 37, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_BuySparks`, `URCi_RedeemSparks` |
| `URC_` derived reads | 7 | read and derive; no enforce | `URC_AccountRedemptionAmount`, `URC_Acquire`, `URC_CustomSparkRedemptionCost`, `URC_GetMaxBuy`, `URC_SparkAmountCosts`, `URC_SparkCost` …+1 |
| `UR_` readers | 5 | table reads; no enforce, no writes | `UR_BoostPromille`, `UR_FrozenSparkID`, `UR_IzOpenForBusiness`, `UR_SparkID`, `UR_Sparks` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Acquire` |
| `INFO_` cost previews | 2 | client-facing price preview | `INFO_BuySparks`, `INFO_RedeemSparks` |
| `XI_` protected (internal) | 2 | this module only | `XI_CustomRedeemSparks`, `XI_RedeemSparks` |
| `C_` client | 5 | reached via Talos, never called directly | `C_BuySparks`, `C_CustomRedemAllSparks`, `C_CustomRedemFewSparks`, `C_RedemAllSparks`, `C_RedemFewSparks` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 10

`GOV`, `GOV|SPARK_ADMIN`, `P|PAD-SPARK|REMOTE-GOV`, `P|SECURE-CALLER`, `P|SPARK|CALLER`, `SECURE`, `SPARK|C>BUY`, `SPARK|C>REEDEM-ALL`, `SPARK|C>REEDEM-FEW`, `SPARK|C>X_REEDEM`

**Functions** -- 37, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_BuySparks`, `URCi_RedeemSparks`

*Derived reads* (7) — read and compute; no enforce

`URC_AccountRedemptionAmount`, `URC_Acquire`, `URC_CustomSparkRedemptionCost`, `URC_GetMaxBuy`, `URC_SparkAmountCosts`, `URC_SparkCost`, `URC_SparkRedemptionCost`

*Point reads* (6) — one row or field by key

`P|UR_IMP`, `UR_BoostPromille`, `UR_FrozenSparkID`, `UR_IzOpenForBusiness`, `UR_SparkID`, `UR_Sparks`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Acquire`

*Client entry* (5) — builds the bill; reachable only through Talos

`C_BuySparks`, `C_CustomRedemAllSparks`, `C_CustomRedemFewSparks`, `C_RedemAllSparks`, `C_RedemFewSparks`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (2) — this module only; writes under a capability

`XI_CustomRedeemSparks`, `XI_RedeemSparks`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`

*Previews* (2) — operation previews for clients

`INFO_BuySparks`, `INFO_RedeemSparks`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Info`
<!-- @end:module-page:DEMIPAD-SPARK -->

## Traps

**Redemption does not burn — it recycles.** Six sovereign operations: transfer, freeze, wipe, unfreeze, re-mint into the venue, and re-freeze to the redeemer. Six operations means six separate charges, which is Σ-billing made concrete.
