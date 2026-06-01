# Stage 1 — modules (individual scan)

Deploy order in production follows dependency edges (earlier modules first). **Utilities** are Stage 1 only; **core** implements domain logic; **Talos** exposes orchestrated `A_` / `C_` paths.

## `0_Interfaces/` (spec only, no `module`)

| File | Role |
|------|------|
| `01_Utilities.pact` | Interfaces for `U|*` utilities: constants, guards, strings, decimals, integers, DALOS/DPTF/VST/SWP/ATS helpers, BFS |
| `02_Core.pact` | Large interface bundle: `OuronetPolicyV1`, `IgnisCollectorV1`, `OuronetDalosV1`, branding, DPTF/DPMF/DPOF, ATS, VST, SWP family, OUROBOROS, etc. |
| `03_Talos.pact` | `TalosStageOne_*` interfaces (Admin, ClientOne/Two/Three, ClientPacts) |

## `1_Utilities/` — implementation modules

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_U\|CT.pact` | `U\|CT` | Constants exposed as functions (`CT_*`) |
| `02_U\|G.pact` | `U\|G` | Guard helpers (`OuronetGuardsV1`) |
| `03_U\|ST.pact` | `U\|ST` | String processing utilities |
| `04_U\|RS.pact` | `U\|RS` | Reserved-accounts helpers |
| `05_U\|LST.pact` | `U\|LST` | List / string-list operations (`StringProcessorV1`) |
| `06_U\|INT.pact` | `U\|INT` | Integer utilities |
| `07_U\|DEC.pact` | `U\|DEC` | Decimal utilities |
| `08_U\|DALOS.pact` | `U\|DALOS` | DALOS-specific utility (`UtilityDalosV1` / glyphs) |
| `09_U\|ATS.pact` | `U\|ATS` | ATS math/helpers (`UtilityAtsV1`) |
| `10_U\|DPTF.pact` | `U\|DPTF` | DPTF-oriented utilities (`UtilityDptfV1`) |
| `11_U\|VST.pact` | `U\|VST` | Vesting utilities (`UtilityVstV1`) |
| `12_U\|SWP.pact` | `U\|SWP` | Swapper math / helpers (`UtilitySwpV1`) |
| `13_U\|BFS.pact` | `U\|BFS` | Breadth-first search (`BreadthFirstSearchV1`) |

## `2_Core/` — sovereign core

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_DALOS.pact` | `DALOS` | **Account registry**, KDA mapping, GAP, pricing, smart accounts; hub for many policies |
| `00_DPMF.pact` | `DPMF` | **Demiourgos Pact Meta Fungible** (legacy) — retained for historical/migration context, not the active live meta-token path |
| `03_INFO-ZERO.pact` | `INFO-ZERO` | Early **client-info** / primordial read layer for Talos |
| `04_BRD.pact` | `BRD` | **Branding** registry and updates |
| `05_DPTF.pact` | `DPTF` | **True fungible** token (balances, roles, transfers) |
| `06_DPOF.pact` | `DPOF` | **Orto fungible** (batch metadata) — active live path for meta-token style assets |
| `07_ELITE.pact` | `ELITE` | **Elite** tier mechanics |
| `09_TFT.pact` | `TFT` | **True fungible transfer** orchestration / cross-token paths |
| `08_ATS.pact` | `ATS` | **Autostake** pools |
| `10_ATSU.pact` | `ATSU` | **Autostake usage** / user-facing ATS operations |
| `11_VST.pact` | `VST` | **Vesting** |
| `12_LIQUID.pact` | `LIQUID` | **Liquid staking** (wrap/unwrap Stoa, etc.) |
| `13_OUROBOROS.pact` | `OUROBOROS` | **Ouroboros** economics / fuel / sublimation hooks |
| `02_IGNIS.pact` | `IGNIS` | **Virtual gas (IGNIS)** collection, cumulators, pricing hooks |
| `14_SWPT.pact` | `SWPT` | **Swap tracer** |
| `15_SWP.pact` | `SWP` | **Swapper** pool core |
| `16_SWPI.pact` | `SWPI` | **Swapper issue** / pool creation and issuance |
| `17_SWPL.pact` | `SWPL` | **Swapper liquidity** |
| `18_SWPLC.pact` | `SWPLC` | **Swapper liquidity client** |
| `19_SWPU.pact` | `SWPU` | **Swapper usage** (slippage, swap UX) |
| `20_MTX-SWP.pact` | `MTX-SWP` | **Matrix swapper** |
| `21_INFO-ONE+.pact` | `INFO-ONE` | **Aggregated info** (`InfoOneV1`) — richer client-info for Talos |

## `3_Talos/` — orchestration

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_TS01-A.pact` | `TS01-A` | **Admin** Talos: admin `A_` flows, internal **X** fuel helpers (`XB_*`, `XI_*`) |
| `02_TS01-C1.pact` | `TS01-C1` | **Client 1**: DALOS-heavy client flows + deploy + fuel sequencing |
| `03_TS01-C2.pact` | `TS01-C2` | **Client 2**: DPTF, VST, ORBR, ATS, etc. |
| `04_TS01-C3.pact` | `TS01-C3` | **Client 3**: SWP family, branding, swaps |
| `05_TS01-P.pact` | `TS01-CP` | **Pooled / ATS-gated** client pacts (`P|ATS` patterns) |

## Intricacies (how Stage 1 fits together)

1. **DALOS** holds account truth; **IGNIS** prices operations via cumulators; **Talos** wraps domain `C_` with `P|TS` (GAP) and `IGNIS::C_Collect` where applicable.
2. **DPTF / DPMF / DPOF** separate true fungible, legacy meta framework, and active orto fungible concerns under deploy limits.
3. `DPMF` remains in-tree for historical traceability; `DPOF` is the module used for live network metadata-rich fungible behavior.
3. **SWP*** modules split swapper into trace, pool, issue, liquidity, usage, and matrix layers.
4. **INFO-ZERO / INFO-ONE** lift signer and account constraints into structured objects consumed by Talos before calling core `C_`.

## Deep-dive placeholders (expand per whitepaper section)

- [ ] End-to-end IGNIS path: `IGNIS` + `TS01-*` + `DALOS` pricing keys
- [ ] SWP family data flow: `SWP` ↔ `SWPI` ↔ `SWPL` ↔ `SWPU`
- [ ] ATS: `ATS` vs `ATSU` vs `TS01-P`
