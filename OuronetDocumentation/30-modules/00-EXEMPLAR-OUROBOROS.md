# OUROBOROS — the OURO token and its conversions

> **This page is an EXEMPLAR.** It exists to show the shape every module page will take, so the
> format can be judged before seventy-nine of them are written. The prose below is deliberately
> thin — enough to demonstrate what a human contributes and what is emitted.

## What it is for

*(hand-written: what this module exists to do, in a paragraph a non-Pact reader can follow)*

OUROBOROS owns **OURO**, Ouronet's native economic token, and the conversions between it and
IGNIS — the virtual gas everything else is priced in. Sublimation turns OURO into IGNIS;
compression turns IGNIS back into OURO. It is the join between what a user holds and what they
spend.

## Where it sits

*(hand-written: layer, and what depends on it)*

Stage-1 Core. Reached only through Talos — `TS01-C2` carries its client wrappers — and depended on
by anything that prices an operation, because IGNIS is the unit those prices are in.

---

<!-- @generated:module:OUROBOROS -- do not edit; run REPL/tools/_docsmodules.py --write -->
**On chain**

| | |
|---|---|
| module hash | `6kA1wWQkFddog57qbeG86xkHz8wv1MwqjZpaKuGb7_0` |
| deployed size | 40,209 characters |
| implements | `OuronetPolicyV2`, `OuroborosV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 14

`GOV`, `GOV|ORBR_ADMIN`, `IGNIS|C>COMPRESS`, `IGNIS|C>CONVERT`, `IGNIS|C>SUBLIMATE`, `IGNIS|XB>COMPRESS`, `IGNIS|XB>CONVERT`, `LIQUIDFUEL|C>ADMIN_FUEL`, `ORBR|GOV`, `ORBR|NATIVE-AUTOMATIC`, `OUROBOROS|C>WITHDRAW`, `P|DALOS|REMOTE-GOV`, `P|ORBR|CALLER`, `SECURE`

**Functions** — 31, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 5 | returns what an operation will charge | `URCi_Compress`, `URCi_Fuel`, `URCi_Sublimate`, `URCi_SublimateV2`, `URCi_WithdrawFees` |
| `URCv_` derived reads (validating) | 2 | read + derive, with an intrinsic guard | `URCv_Compress`, `URCv_Sublimate` |
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_ProjectedStoaLiquindex` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_Exchange` |
| `XB_` protected (both) | 1 | internal and external | `XB_Compress` |
| `C_` client | 5 | reached via Talos, never called directly | `C_Compress`, `C_Fuel`, `C_Sublimate`, `C_SublimateV2`, `C_WithdrawFees` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|ORBR|GUARD`, `GOV|ORBR|SC_NAME`, `GOV|ORBR|SC_STOA-NAME` …+1 |

> Repository and chain agree on every declared shape.
<!-- @end:module:OUROBOROS -->

---

## How it works

*(hand-written: the mechanism. Formulas, ordering, why it is shaped this way.)*

## Traps

*(hand-written: anything that has actually bitten someone. This section is why the page is worth
writing rather than generating — a generator cannot know what went wrong.)*

## Sources

Generated block: `REPL/tools/_docsmodules.py --write`, reading `Deploy/LIVE-MODULES.json`, which
is what `describe-module` returned from mainnet. Refresh with
`python3 REPL/tools/_livemodules.py --probe`.
