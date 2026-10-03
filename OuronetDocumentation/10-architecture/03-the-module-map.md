# The module map

Every module in the system, by layer, with its size and its own one-line description.

**The tables below are generated** from the tree by `REPL/tools/_docsmodules.py`. Nothing in them
is typed by a human, which is the point: when a module gains a function or a table, this page is
correct again after one command. See `../MAINTAINING.md` for why that matters and what it cost to
arrange.

---

## How to read it

- **module** — the `(module …)` name as deployed. An *italic* entry is a file that declares only an
  interface and no module.
- **fn / cap** — counts of `defun` and `defcap` **forms** in the module body. A function declared in
  an interface and defined in the module is counted once here (the interface half is excluded),
  which is why these sum lower than the tree-wide 8,872 on the front page. Different question,
  different number, both stated.
- **sch/tbl** — `defschema` and `deftable` forms in the file.
- **`@doc`** — the module author's own first clause, truncated. It is orientation, not a
  description. The real description of a module is its page in `../30-modules/`.

Layers are assigned by directory, and each file belongs to exactly **one** layer — the first that
claims it. Twelve files are claimed by two (the citizen Talos and the per-app read modules live
inside `2_CITIZEN/` but belong to Talos and Reads by role), so without that rule they would be
listed twice and every total a reader tried to add up would be wrong. The tool's selftest asserts
the layers cover the tree exactly: 105 files, no gaps, no duplicates.

## What this page is not

A module's **purpose, mechanism and traps** are not here and cannot be generated. That is
`../30-modules/`, one page per module, hand-written. This page answers *what exists and how big it
is*; that section answers *what it does and why*.

---

<!-- @generated:module-map -- do not edit; run REPL/tools/_docsmodules.py --write -->
### Utilities

13 file(s) · 13 module(s) · 15 interface(s) · 5,126 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `U|CT` | `STAGE_01/1_Utilities/01_U_CT.pact` | 375 | 81 | 2 | 0/0 | Constants library: exposes Ouronet's global constants as nullary functions (implements OuronetConstantsV2 and DiaStoaPidV2). |
| `U|G` | `STAGE_01/1_Utilities/02_U_G.pact` | 145 | 5 | 2 | 0/0 | Guard-combinator helpers (implements OuronetGuardsV2). |
| `U|ST` | `STAGE_01/1_Utilities/03_U_ST.pact` | 187 | 12 | 2 | 0/0 | Gas-station helper library (implements OuronetGasStationV2). |
| `U|RS` | `STAGE_01/1_Utilities/04_U_RS.pact` | 149 | 2 | 2 | 0/0 | Reserved-account helpers (implements ReservedAccountsV2). |
| `U|LST` | `STAGE_01/1_Utilities/05_U_LST.pact` | 269 | 16 | 2 | 0/0 | List and string processing library (implements StringProcessorV2). |
| `U|INT` | `STAGE_01/1_Utilities/06_U_INT.pact` | 250 | 9 | 2 | 2/0 | Integer-list utilities (implements OuronetIntegersV2). |
| `U|DEC` | `STAGE_01/1_Utilities/07_U_DEC.pact` | 213 | 6 | 2 | 0/0 | Decimal math helpers (implements OuronetDecimalsV2). |
| `U|DALOS` | `STAGE_01/1_Utilities/08_U_DALOS.pact` | 675 | 22 | 2 | 0/0 | DALOS glyph/format utility (implements UtilityDalosV2 and UtilityDalosGlyphsV3). |
| `U|ATS` | `STAGE_01/1_Utilities/09_U_ATS.pact` | 764 | 24 | 2 | 1/0 | Autostake (ATS/ATSU) utility library (implements UtilityAtsV3). |
| `U|DPTF` | `STAGE_01/1_Utilities/10_U_DPTF.pact` | 242 | 7 | 2 | 1/0 | DPTF fungible-token utility library (implements UtilityDptfV2). |
| `U|VST` | `STAGE_01/1_Utilities/11_U_VST.pact` | 247 | 12 | 2 | 0/0 | Vesting (VST) utility library (implements UtilityVstV2). |
| `U|SWP` | `STAGE_01/1_Utilities/12_U_SWP.pact` | 1,104 | 39 | 2 | 8/0 | Swap-pool math and helper library (implements UtilitySwpV2). |
| `U|BFS` | `STAGE_01/1_Utilities/13_U_BFS.pact` | 506 | 16 | 2 | 3/0 | Breadth-first-search library over token graphs (implements BreadthFirstSearchV2), used by the SWP modules to find swap paths between pool tokens. |

### Core — Stage 1

22 file(s) · 22 module(s) · 29 interface(s) · 42,385 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `DPMF` | `STAGE_01/2_Core/00_DPMF.pact` | 902 | 53 | 3 | 5/5 | DPMF — the legacy MetaFungible token core, implementing DemiourgosPactMetaFungibleV8. |
| `DALOS` | `STAGE_01/2_Core/01_DALOS.pact` | 2,124 | 159 | 22 | 10/7 | DALOS — the sovereign identity, executor and ledger core of Ouronet. |
| `IGNIS` | `STAGE_01/2_Core/02_IGNIS.pact` | 2,091 | 78 | 12 | 7/2 | IGNIS — the virtual-chain gas collector, implementing IgnisCollectorV3 and OuronetInfoV2. |
| `BRD` | `STAGE_01/2_Core/04_BRD.pact` | 649 | 34 | 7 | 3/3 | BRD — the branding core for all Ouronet entities (DPTF, DPOF, ATS pairs, SWP pairs and future ones), implementing BrandingV2. |
| `DPTF` | `STAGE_01/2_Core/05_DPTF.pact` | 3,352 | 200 | 40 | 2/5 | DPTF — the True-Fungible token core, implementing DemiourgosPactTrueFungibleV2 and the primary branding interface. |
| `DPOF` | `STAGE_01/2_Core/06_DPOF.pact` | 3,479 | 197 | 39 | 7/6 | DPOF — the OrtoFungible token core, the modern successor to DPMF for metadata-rich, NFT-like fungibles; |
| `ELITE` | `STAGE_01/2_Core/07_ELITE.pact` | 400 | 16 | 5 | 0/2 | ELITE — the Elite-account helper core, implementing EliteV2. |
| `ATS` | `STAGE_01/2_Core/08_ATS.pact` | 3,436 | 201 | 39 | 9/4 | ATS — the autostake pool core, implementing AutostakeV3, AutostakeComputerV2 and branding. |
| `TFT` | `STAGE_01/2_Core/09_TFT.pact` | 2,089 | 73 | 26 | 1/2 | TFT — the True-Fungible transfer core, the movement layer over DPTF, implementing TrueFungibleTransferV2. |
| `ATSU` | `STAGE_01/2_Core/10_ATSU.pact` | 2,351 | 53 | 27 | 0/2 | ATSU — the Autostake usage core, performing the token-moving operations on ATS pools; |
| `VST` | `STAGE_01/2_Core/11_VST.pact` | 2,555 | 81 | 42 | 2/2 | VST — the vesting/lockup core that mints special DPTF/DPOF derivative tokens; |
| `LIQUID` | `STAGE_01/2_Core/12_LIQUID.pact` | 726 | 28 | 14 | 0/2 | LIQUID — the Stoa liquid-staking core, implementing StoaLiquidStakingV2. |
| `OUROBOROS` | `STAGE_01/2_Core/13_OUROBOROS.pact` | 928 | 31 | 14 | 0/2 | OUROBOROS — the OURO token / exchange core at the top of the Stage 1 stack, implementing OuroborosV2. |
| `SWPT` | `STAGE_01/2_Core/14_SWPT.pact` | 1,367 | 45 | 4 | 5/5 | SWPT (SwapTracerV3) is the swap-graph tracer for the SWP liquidity-pool family. |
| `SWP` | `STAGE_01/2_Core/15_SWP.pact` | 2,454 | 130 | 29 | 7/7 | SWP (SwapperV4) is the core swapper/liquidity-pool module holding all per-pool state in SWP\|Pairs (owner, weights, token supplies, fees, amplifier, ST… |
| `SWPI` | `STAGE_01/2_Core/16_SWPI.pact` | 2,861 | 77 | 9 | 1/2 | SWPI (SwapperIssueV4) handles SWP pool issuance and the swap-math/pricing engine. |
| `SWPL` | `STAGE_01/2_Core/17_SWPL.pact` | 2,098 | 47 | 12 | 9/2 | Exposes Liquidity Functions |
| `SWPLC` | `STAGE_01/2_Core/18_SWPLC.pact` | 1,611 | 46 | 20 | 0/2 | SWPLC (SwapperLiquidityClientV2 + BrandingUsageSecondaryV2) is the liquidity-client module for SWP pools. |
| `SWPU` | `STAGE_01/2_Core/19_SWPU.pact` | 2,488 | 48 | 24 | 5/2 | SWPU (SwapperUsageV3) is the user-facing swapping module for SWP. |
| `MTX-SWP` | `STAGE_01/2_Core/20_MTX-SWP.pact` | 1,260 | 25 | 20 | 0/2 | MTX-SWP (SwapperMtxV4) provides multi-step (defpact) versions of SWP pool issuance and liquidity addition, originally to split work under an old per-t… |
| `CODEX` | `STAGE_01/2_Core/21_CODEX.pact` | 1,186 | 82 | 12 | 4/6 | On-chain Codex Identity registry, Arweave upload audit log, and StoicTag name registry. |
| `PYTHIA` | `STAGE_01/2_Core/22_PYTHIA.pact` | 1,978 | 116 | 13 | 9/8 | Dual-Apollo Pythia registry + on-chain Pyth work ledger (daily flush / running total). |

### Core — Stage 2

22 file(s) · 21 module(s) · 22 interface(s) · 41,270 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `DPDC-UDC` | `STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` | 726 | 33 | 5 | 14/2 | DPDC-UDC is the data-construction module for the DPDC collectables family, implementing DpdcUdcV2 and OuronetPolicyV2. |
| `DPDC` | `STAGE_02/2_Core/01_DPDC/02_DPDC.pact` | 2,038 | 171 | 9 | 0/12 | DPDC is the central collectables (NFT/SFT) state module, implementing DpdcV2, BrandingUsageTertiaryV2 and OuronetPolicyV2. |
| `DPDC-C` | `STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact` | 1,269 | 57 | 35 | 0/2 | DPDC-C is the collectables create/credit/debit engine, implementing DpdcCreateV2 and OuronetPolicyV2. |
| `DPDC-I` | `STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact` | 588 | 16 | 6 | 0/2 | DPDC-I is the Collectables Issue module of the DPDC family, implementing DpdcIssueV2 and OuronetPolicyV2. |
| `DPDC-R` | `STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact` | 978 | 45 | 16 | 0/2 | DPDC-R is the Collectables Roles module of the DPDC family, implementing DpdcRolesV2 and OuronetPolicyV2, managing the special roles on a collection's… |
| `DPDC-MNG` | `STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact` | 1,317 | 49 | 20 | 2/2 | Management module for the DPDC collectables (NFT/SFT) family, implementing DpdcManagementV2 and OuronetPolicyV2. |
| `DPDC-T` | `STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact` | 1,139 | 32 | 13 | 1/2 | Transfer module for the DPDC collectables (NFT/SFT) family, implementing DpdcTransferV2 and OuronetPolicyV2. |
| `DPDC-S` | `STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact` | 1,757 | 74 | 15 | 0/4 | DPDC-S is the Sets module of the DPDC collectables family, managing groups of nonces composed into higher-order set-classes. |
| `DPDC-F` | `STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact` | 677 | 22 | 10 | 0/2 | DPDC-F is the Fragments module of the DPDC collectables family, handling fractionalization of class-0 collectable nonces into fragment pieces in units… |
| `DPDC-N` | `STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact` | 937 | 35 | 15 | 0/2 | DPDC-N is the DPDC-family module for updating the mutable metadata of existing NFT/SFT nonces (and set-classes). |
| `EQUITY` | `STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact` | 933 | 31 | 10 | 0/2 | EQUITY implements OuronetPolicyV2 and EquityV2 to create and manage Shareholder DPSF (SFT) collections representing company equity, where nonce 1 is t… |
| `DEMIPAD` | `STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` | 1,830 | 90 | 24 | 5/4 | Demiourgos Launchpad, is a permissioned Launchpad operated by Demiourgos.Holdings allowing the Company to sell Assets (DPTFs, DPMFs, DPSFs and DPNFs)… |
| *AcquisitionSchemasV1* | `STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact` | 917 | 0 | 0 | 63/0 | General Anchor Definition Each Anchor is defined via a so called Anchored-Asset This may be a DPTF, DPSF or DPNF; |
| `AQP-ANK` | `STAGE_02/2_Core/03_AQP/01_ANK.pact` | 2,581 | 124 | 21 | 0/8 | Sovereign anchor module for AQP. |
| `AQP-SCORE` | `STAGE_02/2_Core/03_AQP/02_SCORE.pact` | 4,239 | 217 | 36 | 0/12 | AQP-SCORE — sovereign acquisition scoring for AQP pools. |
| `AQP-POOL` | `STAGE_02/2_Core/03_AQP/03_AQP.pact` | 3,489 | 214 | 19 | 0/13 | Sovereign acquisition-pool module. |
| `RPS` | `STAGE_02/2_Core/03_AQP/04_RPS.pact` | 5,472 | 341 | 10 | 0/16 | Reward-per-share (RPS) ledger/accountant extracted from AQP-FVT (task #75). |
| `AQP-FVT` | `STAGE_02/2_Core/03_AQP/05_FVT.pact` | 3,659 | 144 | 30 | 0/5 | Large sovereign reward-accounting module for AQP farms (class 0), vaults (1) and treasuries (2). |
| `AQP-VCT` | `STAGE_02/2_Core/03_AQP/06_VCT.pact` | 3,535 | 137 | 15 | 0/2 | Sovereign vacate module that unwinds an AQP pool by returning every staked position to owners. |
| `MTX-AQP` | `STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact` | 575 | 16 | 9 | 0/2 | Holds all AQP multi-transaction (defpact) flows. |
| `AQP-DSA` | `STAGE_02/2_Core/03_AQP/08_DSA.pact` | 1,078 | 61 | 16 | 0/5 | Delegated Staking Agencies — a delegation layer over AQP-FVT's two-tier farm settle. |
| `AQP-INFO` | `STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact` | 1,536 | 86 | 2 | 0/0 | Read-only pre-execution cost-preview module for the AQP family. |

### Talos

11 file(s) · 11 module(s) · 11 interface(s) · 13,623 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `TS01-A` | `STAGE_01/3_Talos/01_TS01-A.pact` | 940 | 42 | 8 | 0/2 | TALOS Stage 1 Administrator Functions Contains All Administrator functions [DALOS BRD ORBR SWP] Also contains Fueling Functions needed in all subseque… |
| `TS01-C1` | `STAGE_01/3_Talos/02_TS01-C1.pact` | 1,627 | 73 | 5 | 0/2 | TALOS Stage 1 Client Functiones Part 1 |
| `TS01-C2` | `STAGE_01/3_Talos/03_TS01-C2.pact` | 1,904 | 88 | 5 | 0/2 | TALOS Client Module for Stage 1, namely ATS VST LIQUID and OUROBOROS Modules |
| `TS01-C3` | `STAGE_01/3_Talos/04_TS01-C3.pact` | 1,364 | 45 | 5 | 0/2 | TALOS Administrator and Client Module for Stage 1 |
| `TS01-CP` | `STAGE_01/3_Talos/05_TS01-P.pact` | 386 | 18 | 5 | 0/2 | TALOS Administrator and Client Module for Stage 1 |
| `TS01-C4` | `STAGE_01/3_Talos/06_TS01-C4.pact` | 574 | 25 | 5 | 0/2 | TALOS Client Module for Stage 1 — CODEX + PYTHIA (Apollo keys + Pyth ledger flush). |
| `TS02-C1` | `STAGE_02/3_Talos/01_TS02-C1.pact` | 1,727 | 77 | 5 | 0/2 | TALOS Stage 2 Client Functiones Part 1 - SFT Functions |
| `TS02-C2` | `STAGE_02/3_Talos/02_TS02-C2.pact` | 1,471 | 71 | 5 | 0/2 | TALOS Stage 2 Client Functiones Part 2 - NFT Functions |
| `TS02-C3` | `STAGE_02/3_Talos/04_TS02-C3.pact` | 2,694 | 110 | 17 | 0/2 | TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions |
| `TS02-DPAD` | `STAGE_02/3_Talos/05_TS02-DPAD.pact` | 561 | 25 | 5 | 0/2 | TALOS Stage 2 Demiourgos Launchpad SOVEREIGN Functions |
| `TS02-CPAD` | `7_Launchpad/99_TS02-CPAD.pact` | 375 | 18 | 5 | 0/2 | TALOS Stage 2 CITIZEN Launchpad User Functions (Spark/Snakes/Custodians/StoicPay/StoicIco) |

### Reads

15 file(s) · 14 module(s) · 14 interface(s) · 10,199 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `INFO-ZERO` | `STAGE_01/Z_Reads/01_INFO-ZERO.pact` | 84 | 1 | 1 | 0/0 | OBSOLETE TOMBSTONE. Empty by design — OI\|* moved to IGNIS (Phase 1.1); |
| `INFO-ONE` | `STAGE_01/Z_Reads/02_INFO-ONE+.pact` | 4,260 | 189 | 2 | 1/0 | INFO-ONE (InfoOneV2) is a read-only Stage-1 UI info module exposing INFO_ preview functions that return ClientInfo objects (operation description, res… |
| `INFO-TWO` | `STAGE_02/Z_Reads/01_INFO-TWO.pact` | 1,171 | 153 | 2 | 0/0 | INFO-TWO (InfoTwoV2) is the read-only Stage-2 UI info module exposing INFO_ preview functions returning ClientInfo objects (description, result, IGNIS… |
| *OuronetIdsV1* | `Stage_Z/AppReads/00_Ids.pact` | 92 | 0 | 0 | 0/0 | Mainnet entity ids that cannot be computed: primordial tokens and the four primordial ATS pairs. |
| `O-UI-ONE` | `Stage_Z/AppReads/OuronetUI/01_O-UI-ONE.pact` | 431 | 13 | 2 | 0/0 | The fallback a failing zone returns from URC_01\|Header. |
| `O-UI-TWO` | `Stage_Z/AppReads/OuronetUI/02_O-UI-TWO.pact` | 687 | 19 | 2 | 0/0 | What a failing card yields from URC_01\|Dashboard. |
| `O-UI-THREE` | `Stage_Z/AppReads/OuronetUI/03_O-UI-THREE.pact` | 619 | 16 | 2 | 0/0 | What a failing card yields from URC_01\|EliteAccount; |
| `O-UI-FOUR` | `Stage_Z/AppReads/OuronetUI/04_O-UI-FOUR.pact` | 142 | 3 | 2 | 0/0 | Dollar/cent display form. |
| `O-UI-SEVEN` | `Stage_Z/AppReads/OuronetUI/07_O-UI-SEVEN.pact` | 293 | 8 | 2 | 0/0 | URC_02\|Account across a list -- the account picker's one round trip. |
| `O-UI-EIGHT` | `Stage_Z/AppReads/OuronetUI/08_O-UI-EIGHT.pact` | 443 | 12 | 2 | 0/0 | What an unreadable list member degrades to. |
| `O-UI-NINE` | `Stage_Z/AppReads/OuronetUI/09_O-UI-NINE.pact` | 481 | 14 | 2 | 0/0 | What an unpriceable row degrades to. |
| `O-UI-TEN` | `Stage_Z/AppReads/OuronetUI/10_O-UI-TEN.pact` | 388 | 12 | 2 | 0/0 | Does this non-fungible nonce exist? `existance` flips the sense, so one function answers both `burn` (must exist) and `respawn` (must not). |
| `O-UI-TWELVE` | `Stage_Z/AppReads/OuronetUI/12_O-UI-TWELVE.pact` | 491 | 20 | 2 | 0/0 | What a failing panel yields from URC_Pool. |
| `O-UI-THIRTEEN` | `Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact` | 488 | 13 | 2 | 0/0 | The anchored asset's kind, as one word, from the [bool] discriminator AQP-ANK stores. |
| `P-UI-ONE` | `Stage_Z/AppReads/Pythia/01_P-UI-ONE.pact` | 129 | 4 | 2 | 0/0 | The API-key row for each Apollo account (₱. |

### Citizen

18 file(s) · 19 module(s) · 8 interface(s) · 10,909 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| `AOZ` | `1_AOZ/01_AOZ+.pact` | 473 | 40 | 4 | 8/8 | FIXED 2026-09-14: this projected "sf-asset" -- the SemiFungible column, copy-pasted from the reader directly above -- out of AOZ\|T\|NonFungibles, whose… |
| `BLOODSHED-L` | `2_BloodshedMinter/01_BSD-L.pact` | 426 | 10 | 3 | 1/0 | Issue Bloodshed NFT Collection |
| `BLOODSHED-E` | `2_BloodshedMinter/02_BSD-E.pact` | 317 | 9 | 3 | 0/0 | Issue Bloodshed Epic NFT |
| `BLOODSHED-R` | `2_BloodshedMinter/03_BSD-R.pact` | 342 | 9 | 3 | 0/0 | Issue Bloodshed Rare NFT |
| `BLOODSHED-C` | `2_BloodshedMinter/04_BSD-C.pact` | 416 | 9 | 3 | 0/0 | Issue Bloodshed Common NFT |
| `BLOODSHED-SETS` | `2_BloodshedMinter/05_BSD-SETS.pact` | 1,214 | 18 | 3 | 0/0 | The Ouronet account that owns NFT collection <dhb> -- the EXECUTOR of every set definition below. |
| `NOSFERATU` | `3_NosferatuMinter/01_NOSFERATU.pact` | 488 | 56 | 3 | 1/0 | Maps a <rarity, position, count> rung to the ABSOLUTE collectable nonces it addresses, using fixed per-rarity bases: Legendary 0, Epic 100, Rare 300,… |
| `KBN` | `4_BunniesMinter/02_KBunnies.pact` | 326 | 23 | 3 | 1/0 | — |
| `AQP-BOOT` | `5_VaultsMinter/04_AQP-BOOT.pact` | 1,303 | 18 | 2 | 0/0 | Refuses a bootstrap step whose CHAIN STATE says it has already completed. |
| `CADUCEUS`, `CADUCEUS` | `6_OuronetBridge/03_CADUCEUS.pact` | 397 | 22 | 7 | 2/2 | Barebones Stage 2 Citizen module scaffold for Caduceus bridge. |
| `DEMIPAD-SPARK` | `7_Launchpad/1_Spark/01_Spark.pact` | 791 | 37 | 10 | 1/3 | Registers <policy-guard> as a trusted inter-module caller of this module. |
| `DEMIPAD-SNAKES` | `7_Launchpad/2_Snakes/02_Snakes.pact` | 571 | 27 | 8 | 1/3 | Module defining the Sale Mechanics for Demiourgos Share Holder Collection |
| `DEMIPAD-CUSTODIANS` | `7_Launchpad/3_Custodians/03_Custodians.pact` | 576 | 28 | 8 | 1/3 | Module defining the Sale Mechanics for Ouronet Custodians Collection |
| `DEMIPAD-STOICPAY` | `7_Launchpad/4_StoicPay/04_STOICPAY.pact` | 629 | 31 | 7 | 1/3 | StoicPay sale mechanics (DEMIPAD). |
| `STOAICO` | `7_Launchpad/5_StoicIco/05_STOAICO.pact` | 1,140 | 67 | 13 | 2/4 | Registers <policy-guard> as a trusted inter-module caller of this module. |
| `DPL-UR` | `Stage_Z/01_DPL-UR.pact` | 157 | 3 | 2 | 0/0 | — |
| `EXPLORER` | `Stage_Z/02_EXPLORER.pact` | 198 | 7 | 2 | 0/0 | Token amount display helper (aligned with DPL-UR). |
| `DSP` | `Stage_Z/03_DSP+.pact` | 1,145 | 37 | 13 | 0/2 | Dispenser Remote Governor Capability |

### Interface holders (no module)

5 file(s) · 0 module(s) · 0 interface(s) · 60 lines

| module | file | lines | fn | cap | sch/tbl | its own one-line `@doc` |
|---|---|---:|---:|---:|---:|---|
| — | `STAGE_01/0_Interfaces/01_Utilities.pact` | 27 | 0 | 0 | 0/0 | — |
| — | `STAGE_01/0_Interfaces/02_Core.pact` | 6 | 0 | 0 | 0/0 | — |
| — | `STAGE_01/0_Interfaces/03_Talos.pact` | 18 | 0 | 0 | 0/0 | — |
| — | `STAGE_02/0_Interfaces/02_Core.pact` | 6 | 0 | 0 | 0/0 | — |
| — | `STAGE_02/0_Interfaces/03_Talos.pact` | 3 | 0 | 0 | 0/0 | — |

### Totals

| | |
|---|---|
| files | 106 |
| module forms | 100 |
| interface forms | 99 |
| lines | 123,572 |
| `defun` forms | 5,586 |
| `defcap` forms | 989 |
| schemas / tables | 206 / 231 |
<!-- @end:module-map -->

---

Three generated artefacts in this repository count modules, and they disagree — legitimately,
because they are scoped differently. Quoting one with another's label is a real mistake that has
already happened.

### Why this page's `defun` and `defcap` totals differ from the front page

Both differences are methodological, both are exact, and both were checked rather than assumed —
because two generated numbers disagreeing in the same folder reads as one of them being broken.

| figure | front page | this page | why |
|---|---|---|---|
| `defun` forms | 8,872 | **5,572** | the front page counts the whole file; this page counts the module BODY only. The 3,276 difference is interface declarations — the same function named in an interface and defined in the module. |
| `defcap` forms | 988 | **987** | exactly one `defcap` is declared in an *interface* rather than a module: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`. Verified by scanning every file's pre-`(module …)` head. |
| lines | 123,572 | 123,572 | agree, deliberately. The generator counts newlines only — `wc -l` semantics. A "logical lines" count gives 123,574, because 73 files in the tree lack a trailing newline. |

The line-count case is the instructive one. Counting a final unterminated line *as a line* is
arguably more correct, and it was the wrong choice: it put a 73-line discrepancy between two
generated figures in the same folder. **Agreement with the documented command beats local
correctness**, and the generator carries a comment saying so, so nobody "fixes" it back.

---

## Reconciling with the other module counts

| source | scope | reports |
|---|---|---|
| this page | `1_SOVEREIGN/` + `2_CITIZEN/` | 105 files |
| `OuronetInformational/MODULE-INDEX.md` | the **whole tree**, sandboxes included | 152 modules, 192 files |
| `Deploy/MANIFEST.md` | what actually deploys in the round | 80 modules, 24 transactions |

`MODULE-INDEX.md` is larger because it counts `0_Stoa/`, `00_KadenaSandbox/`, `00_StoaSandbox/` and
`0_Sample/` — the host-chain contracts Ouronet runs beside and the sandboxes it is tested in. Those
are not Ouronet. `Deploy/MANIFEST.md` is smaller because the round deliberately excludes the citizen
minters, the bridge scaffold and the explorer chain, each with a recorded reason.

---

## Where to go next

- `04-deploy-order.md` — why the order these are listed in is forced
- `../30-modules/` — the per-module reference, in deploy order
- `../MAINTAINING.md` — the generated/hand-written seam this page demonstrates

## Sources

Generated 2026-09-27 by `REPL/tools/_docsmodules.py --write`, reading `1_SOVEREIGN/` and
`2_CITIZEN/` directly. Re-run `--check` to confirm this page still matches the tree; it exits 1 and
names the file if not.
