# The modules

One page per deployed module — **96 of them** — in **deploy order**, which
is also dependency order: a module may only call what is already deployed, so reading
downward is reading foundations first.

Each page carries a generated enumeration (schemas, tables, capabilities, functions
grouped by prefix, client entrypoints) and hand-written prose (what it is for, where it
sits, what has bitten people). The enumeration is re-rendered from the chain; the prose
is not touched by that.

## Utilities

| | module | role |
|---:|---|---|
| 1 | [`U|CT`](01-u-ct.md) | constants, and the price oracle |
| 2 | [`U|G`](02-u-g.md) | guard combinators |
| 3 | [`U|ST`](03-u-st.md) | gas-station helpers |
| 4 | [`U|RS`](04-u-rs.md) | reserved account prefixes |
| 5 | [`U|LST`](05-u-lst.md) | list and string processing |
| 6 | [`U|INT`](06-u-int.md) | integer mathematics |
| 7 | [`U|DEC`](07-u-dec.md) | decimal mathematics |
| 8 | [`U|DALOS`](08-u-dalos.md) | the account alphabet and format |
| 9 | [`U|ATS`](09-u-ats.md) | autostake bounds and position records |
| 10 | [`U|DPTF`](10-u-dptf.md) | the volumetric tax |
| 11 | [`U|VST`](11-u-vst.md) | the special-variant prefixes |
| 12 | [`U|SWP`](12-u-swp.md) | the three swap curves |
| 13 | [`U|BFS`](13-u-bfs.md) | breadth-first search |

## Core — Stage 1

| | module | role |
|---:|---|---|
| 14 | [`DALOS`](14-dalos.md) | the account and identity core |
| 15 | [`IGNIS`](15-ignis.md) | virtual gas and the cost model |
| 16 | [`BRD`](16-brd.md) | branding, shared across entity types |
| 17 | [`DPTF`](17-dptf.md) | the true-fungible token core |
| 18 | [`DPOF`](18-dpof.md) | the orto-fungible token core |
| 19 | [`ELITE`](19-elite.md) | account tiers and discounts |
| 20 | [`ATS`](20-ats.md) | the autostake pool core |
| 21 | [`TFT`](21-tft.md) | the transfer layer |
| 22 | [`ATSU`](22-atsu.md) | autostake usage |
| 23 | [`VST`](23-vst.md) | vesting, locking and the special variants |
| 24 | [`LIQUID`](24-liquid.md) | liquid staking |
| 25 | [`OUROBOROS`](25-ouroboros.md) | the OURO token and the IGNIS exchange |
| 26 | [`SWPT`](26-swpt.md) | the pool graph and route cache |
| 27 | [`SWP`](27-swp.md) | the pool registry |
| 28 | [`SWPI`](28-swpi.md) | issuance and the swap engine |
| 29 | [`SWPL`](29-swpl.md) | liquidity mathematics |
| 30 | [`SWPLC`](30-swplc.md) | the liquidity client |
| 31 | [`SWPU`](31-swpu.md) | swaps and routing |
| 32 | [`MTX-SWP`](32-mtx-swp.md) | multi-step pool operations |
| 33 | [`CODEX`](33-codex.md) | name registration |
| 34 | [`PYTHIA`](34-pythia.md) | external data lanes |

## Talos — Stage 1

| | module | role |
|---:|---|---|
| 35 | [`TS01-A`](35-ts01-a.md) | Stage-1 admin orchestration |
| 36 | [`TS01-C1`](36-ts01-c1.md) | Stage-1 client orchestration — accounts and fungibles |
| 37 | [`TS01-C2`](37-ts01-c2.md) | Stage-1 client orchestration — orto-fungibles and autostake |
| 38 | [`TS01-C3`](38-ts01-c3.md) | Stage-1 client orchestration — swaps |
| 39 | [`TS01-CP`](39-ts01-cp.md) | Stage-1 multi-step client orchestration |
| 40 | [`TS01-C4`](40-ts01-c4.md) | Stage-1 client orchestration — identity services |

## Reads — Stage 1

| | module | role |
|---:|---|---|
| 41 | [`INFO-ZERO`](41-info-zero.md) | an empty tombstone |
| 42 | [`INFO-ONE`](42-info-one.md) | Stage-1 previews |

## Core — Stage 2

| | module | role |
|---:|---|---|
| 43 | [`DPDC-UDC`](43-dpdc-udc.md) | collectable schemas and constructors |
| 44 | [`DPDC`](44-dpdc.md) | the collectables state core |
| 45 | [`DPDC-C`](45-dpdc-c.md) | create, credit and debit |
| 46 | [`DPDC-I`](46-dpdc-i.md) | collection issuance |
| 47 | [`DPDC-R`](47-dpdc-r.md) | collectable roles |
| 48 | [`DPDC-MNG`](48-dpdc-mng.md) | collectable management |
| 49 | [`DPDC-T`](49-dpdc-t.md) | collectable transfers |
| 50 | [`DPDC-S`](50-dpdc-s.md) | sets |
| 51 | [`DPDC-F`](51-dpdc-f.md) | fragments |
| 52 | [`DPDC-N`](52-dpdc-n.md) | nonce metadata |
| 53 | [`EQUITY`](53-equity.md) | tokenised companies |
| 54 | [`DEMIPAD`](54-demipad.md) | the launchpad venue |
| 55 | [`AQP-ANK`](55-aqp-ank.md) | anchors |
| 56 | [`AQP-SCORE`](56-aqp-score.md) | scoring |
| 57 | [`AQP-POOL`](57-aqp-pool.md) | the pools |
| 58 | [`RPS`](58-rps.md) | the reward engine |
| 59 | [`AQP-FVT`](59-aqp-fvt.md) | farms, vaults and treasuries |
| 60 | [`AQP-VCT`](60-aqp-vct.md) | vacating |
| 61 | [`MTX-AQP`](61-mtx-aqp.md) | multi-step acquisition operations |
| 62 | [`AQP-DSA`](62-aqp-dsa.md) | delegated staking agencies |
| 63 | [`AQP-INFO`](63-aqp-info.md) | acquisition previews |

## Talos — Stage 2

| | module | role |
|---:|---|---|
| 64 | [`TS02-C1`](64-ts02-c1.md) | Stage-2 client orchestration — semi-fungibles |
| 65 | [`TS02-C2`](65-ts02-c2.md) | Stage-2 client orchestration — non-fungibles |
| 66 | [`TS02-C3`](66-ts02-c3.md) | Stage-2 client orchestration — acquisition pools |
| 67 | [`TS02-DPAD`](67-ts02-dpad.md) | the sovereign launchpad orchestration |

## Reads — Stage 2

| | module | role |
|---:|---|---|
| 68 | [`INFO-TWO`](68-info-two.md) | Stage-2 previews |

## Citizen

| | module | role |
|---:|---|---|
| 69 | [`AOZ`](69-aoz.md) | the primal-asset registrar |
| 70 | [`BLOODSHED-L`](70-bloodshed-l.md) | Bloodshed — ledger |
| 71 | [`BLOODSHED-E`](71-bloodshed-e.md) | Bloodshed — elements |
| 72 | [`BLOODSHED-R`](72-bloodshed-r.md) | Bloodshed — roles |
| 73 | [`BLOODSHED-C`](73-bloodshed-c.md) | Bloodshed — composition |
| 74 | [`BLOODSHED-SETS`](74-bloodshed-sets.md) | Bloodshed — sets |
| 75 | [`NOSFERATU`](75-nosferatu.md) | a citizen minter |
| 76 | [`KBN`](76-kbn.md) | a citizen minter |
| 77 | [`AQP-BOOT`](77-aqp-boot.md) | acquisition bootstrap |
| 78 | [`DEMIPAD-SPARK`](78-demipad-spark.md) | the Spark sale |
| 79 | [`DEMIPAD-SNAKES`](79-demipad-snakes.md) | the Snakes sale |
| 80 | [`DEMIPAD-CUSTODIANS`](80-demipad-custodians.md) | the Custodians sale |
| 81 | [`DEMIPAD-STOICPAY`](81-demipad-stoicpay.md) | the StoicPay sale |
| 82 | [`STOAICO`](82-stoaico.md) | the distribution vault |
| 83 | [`TS02-CPAD`](83-ts02-cpad.md) | the citizen launchpad orchestration |
| 84 | [`DPL-UR`](84-dpl-ur.md) | an emptied read module |
| 85 | [`EXPLORER`](85-explorer.md) | block-explorer reads |
| 86 | [`DSP`](86-dsp.md) | the dispenser automaton |
| 87 | [`O-UI-ONE`](87-o-ui-one.md) | the dashboard header |
| 88 | [`O-UI-TWO`](88-o-ui-two.md) | dashboard reads |
| 89 | [`O-UI-THREE`](89-o-ui-three.md) | account standing and recovery |
| 90 | [`O-UI-FOUR`](90-o-ui-four.md) | distribution-vault reads |
| 91 | [`O-UI-SEVEN`](91-o-ui-seven.md) | account reads |
| 92 | [`O-UI-EIGHT`](92-o-ui-eight.md) | true-fungible reads |
| 93 | [`O-UI-NINE`](93-o-ui-nine.md) | orto-fungible reads |
| 94 | [`O-UI-TEN`](94-o-ui-ten.md) | collectable reads |
| 95 | [`O-UI-TWELVE`](95-o-ui-twelve.md) | pool reads |
| 96 | [`P-UI-ONE`](96-p-ui-one.md) | external-data reads |
