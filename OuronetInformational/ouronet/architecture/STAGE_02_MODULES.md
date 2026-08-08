# Stage 2 — modules (individual scan)

Stage 2 adds **collectables (DPDC)**, **DemiPad** (launchpad ecosystem), **AQP** (acquisition / earning pools), and **INFO-TWO** for richer client views. **Talos** stage-two modules orchestrate DPDC + DemiPad with the same policy + IGNIS patterns as Stage 1.

## `2_Core/01_DPDC/` — collectables vertical slice

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_DPDC-UDC.pact` | `DPDC-UDC` | **UDC schemas** and policy wiring; implements `DpdcUdcV1` |
| `02_DPDC.pact` | `DPDC` | **Core ledger**: SFT vs NFT (`son`), properties, nonces, reads |
| `03_DPDC-C.pact` | `DPDC-C` | **Create** / collection lifecycle |
| `04_DPDC-I.pact` | `DPDC-I` | **Issue** / minting paths |
| `05_DPDC-R.pact` | `DPDC-R` | **Roles** |
| `06_DPDC-MNG.pact` | `DPDC-MNG` | **Management** |
| `07_DPDC-T.pact` | `DPDC-T` | **Transfers** (incl. IGNIS royalty aggregation helpers used from Talos) |
| `08_DPDC-S.pact` | `DPDC-S` | **Sets** / composite nonces |
| `09_DPDC-F.pact` | `DPDC-F` | **Fragments** |
| `10_DPDC-N.pact` | `DPDC-N` | **Nonce** specialized ops |
| `11_EQUITY+.pact` | `EQUITY` | **Equity** interface + module (`EquityV1`) |

**Intricacy:** Table prefixes **`DPSF|`** (semi-fungible) vs **`DPNF|`** (non-fungible) and `son:bool` route ledger paths.

## `2_Core/02_DEMIPAD/` — launchpad ecosystem

| Path | Module | Interface (if separate) | Role (summary) |
|------|--------|---------------------------|----------------|
| `00_Demipad.pact` | `DEMIPAD` | `DemiourgosLaunchpadV1` | **Launchpad hub**: assets, prices, deposits, royalty helpers |
| `01_Spark.pact` | `DEMIPAD-SPARK` | `SparksV1` | Sparks mechanics |
| `02_Snakes.pact` | `DEMIPAD-SNAKES` | `SaleSnakesV1` | Snakes sale path |
| `03_Custodians.pact` | `DEMIPAD-CUSTODIANS` | `SaleCustodiansV1` | Custodians |
| `04_STOICPAY.pact` | `DEMIPAD-STOICPAY` | `StoicPayV2` | StoicPay sale mechanics (UI aggregate may live in DPL-UR) |
| `05_STOAICO.pact` | `STOAICO` | — | STOAICO integration |

## `2_Core/03_AQP/` — acquisition pools

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_ANK.pact` | `AQP-ANK` | **Anchors** + BoostClasses |
| `02_SCORE.pact` | `AQP-SCORE` | Scores, links, user triples |
| `03_AQP.pact` | `AQP-POOL` | Pools, trackers, stake/unstake orchestration |
| `04_FVT.pact` | `AQP-FVT` | Farms / Vaults / Treasuries, inject/collect, stake recipes |
| `05_VCT.pact` | `AQP-VCT` | Pool-owner vacate (Full + Legs) |

**Docs:** `README_GLOBAL.md` (architecture), `README_TALOS_CATALOGUE.md` (Talos `C_*`), `README_HOWTO_FVT.md` (build Farm/Vault/Treasury), plus per-module READMEs under `03_AQP/`.

## Other Stage 2 core

| Path | Module | Role (summary) |
|------|--------|----------------|
| `INFO-TWO.pact` | `INFO-TWO` | **Client info** layer v2 (`InfoTwoV1`); DPDC-oriented `DPSF|INFO_*` / `DPNF|INFO_*` builders |

## `3_Talos/` — Stage 2 orchestration

| Path | Module | Role (summary) |
|------|--------|----------------|
| `01_TS02-C1.pact` | `TS02-C1` | **Client 1** (DPDC-heavy flows, multi-transfer + IGNIS sequencing) |
| `02_TS02-C2.pact` | `TS02-C2` | **Client 2** (extended DPDC / DemiPad client ops) |
| `03_TS02-DPAD.pact` | `TS02-DPAD` | **DemiPad** Talos: `DEMIPAD`, sparks, snakes, custodians, stoicpay registration |
| `04_TS02-C3.pact` | `TS02-C3` | **Client 3** (remaining Stage 2 client surface) |

## Intricacies (how Stage 2 fits together)

1. **DPDC** is intentionally **sharded** across many modules to respect deploy size; **DpdcUdcV1** centralizes schemas so typed tables stay consistent.
2. **DEMIPAD** is a **hub**; satellites (**SPARK**, **SNAKES**, **CUSTODIANS**, **STOICPAY**) reuse `GOV|DEMIPAD|SC_NAME` and policy patterns.
3. **Talos** registers **summoner** guards on each satellite via `P|A_Define` / `P|A_AddIMP` (same pattern as Stage 1).
4. **INFO-TWO** composes reads from **DPDC** / **DPDC-S** / **DPDC-T** into `OuronetInfoV1.ClientInfo` for constrained client execution.
5. **AQP multi-LP farms:** one Farm FVT + shared `common-denominator`; each LP line → own pool + own score set + ScoreEntity links. Guides: `03_AQP/README_GLOBAL.md`, `README_HOWTO_FVT.md`, hub `03_AQP/README.md`.

## Deep-dive placeholders

- [ ] DPDC deploy order graph (which module must deploy before which)
- [ ] Royalty + IGNIS path: `DPDC-T::C_IgnisRoyaltyCollector` → `IGNIS::C_Collect` → `C_Transfer`
- [ ] DemiPad pricing: `UC_ComputeDepositRoyalty`, `URC_Prices`, StoicPay costs
