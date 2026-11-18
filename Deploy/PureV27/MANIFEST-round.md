# Ouronet deploy plan

**Generated** by `python3 REPL/tools/_deploybundle.py --write`. Do not hand-edit; regenerate.

- per-transaction gas budget: **1,700,000** (StoaChain block limit 2,000,000)
- module-deploy transactions: **9**
- modules deployed: **16**
- measured module gas: **2,274,256**

## Read this before deploying

**The gas figures are REPL figures.** They come from `env-gasmodel "table"`, the same model the chain uses, measured by running the deploy chain. They do **not** include per-transaction overhead or signature verification. The budget above leaves headroom for that, but the batches are a **proposal to validate on testnet**, not a guarantee.

**Order is the safety property.** A module may only reference modules already deployed. Nothing here has been reordered, and the numbered steps must be executed in the order given.

**The `INIT` steps are not generated.** Between runs of module deploys the chain performs initialisation -- registering inter-module policies, seeding constants, minting genesis supply. Those need signatures, keysets and transaction data that only you can supply, and some blocks in the REPL chain are sandbox fixtures that must **not** reach mainnet. Each is listed below with its source location so you can lift the real calls out of it. **Do not skip them:** a module deployed after an init step may depend on that step having run.

## ⚠ MANUAL steps -- hand-authored, NOT in the numbered sequence below

These are real transactions that must be run, but no generator can emit them: each needs data, signatures or an ordering only the owner can supply. **They do not appear in the numbered steps**, so working down that list alone will skip them. Each file states its own position in its header -- read it before deploying, not after.

- `Deploy/2_Init/00_MANUAL_backfill-drift-locked.pact` -- backfill drift-locked onto every pre-existing score  
  &nbsp;&nbsp;*RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 02_SCORE.pact,*
- `Deploy/2_Init/00_MANUAL_backfill-min-inject.pact` -- backfill min-inject-amount onto every pre-existing reward lane  
  &nbsp;&nbsp;*RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 04_RPS.pact,*
- `Deploy/2_Init/00_MANUAL_backfill-stream-eligible.pact` -- backfill stream-eligible onto every pre-existing FVT  
  &nbsp;&nbsp;*RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 05_FVT.pact,*
- `Deploy/2_Init/00_MANUAL_probe-dashboard.pact` -- 
- `Deploy/2_Init/00_MANUAL_probe-live-interfaces.pact` -- 
- `Deploy/2_Init/00_MANUAL_rotate-s2-governor.pact` -- rotate the Stage Two dispensing bucket's GOVERNOR onto DSP's capability  
  &nbsp;&nbsp;*RUN THIS AFTER Deploy/1_Pure/24_deploy.pact (the DSP module).*

## ⚠ Modules that must redeploy but are in no deploy chain

These name an interface that bumped this round, so Pact's cascade rule requires them to be redeployed -- but no deploy chain loads them, so **they are not in the files below**:

- `1_SOVEREIGN/STAGE_01/0_Interfaces/01_Utilities.pact`
- `1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact`
- `1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/01_U_CT.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/02_U_G.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/03_U_ST.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/04_U_RS.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact`
- `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/17_SWPL.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact`
- `1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/05_TS01-P.pact`
- `1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact`
- `1_SOVEREIGN/STAGE_01/Z_Reads/01_INFO-ZERO.pact`
- `1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact`
- `1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact`
- `1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact`
- `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact`
- `1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact`
- `1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact`
- `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact`
- `1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact`
- `2_CITIZEN/1_AOZ/01_AOZ+.pact`
- `2_CITIZEN/4_BunniesMinter/02_KBunnies.pact`
- `2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact`
- `2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact`
- `2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact`
- `2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact`
- `2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact`
- `2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact`
- `2_CITIZEN/Stage_Z/AppReads/00_Ids.pact`
- `2_CITIZEN/Stage_Z/AppReads/OuronetUI/04_O-UI-FOUR.pact`
- `2_CITIZEN/Stage_Z/AppReads/OuronetUI/07_O-UI-SEVEN.pact`
- `2_CITIZEN/Stage_Z/AppReads/OuronetUI/08_O-UI-EIGHT.pact`
- `2_CITIZEN/Stage_Z/AppReads/OuronetUI/09_O-UI-NINE.pact`
- `2_CITIZEN/Stage_Z/AppReads/OuronetUI/10_O-UI-TEN.pact`
- `2_CITIZEN/Stage_Z/AppReads/Pythia/01_P-UI-ONE.pact`

`01_DPL-UR.pact` is expected: Stage Z deploys from `deploy-stagezz.repl`, a separate chain that runs last.

**RESOLVED 2026-10-07, and the resolution is that this list means something narrower than it says.** It used to end: *"`09_AQP-INFO.pact` is **not** expected ... nothing deploys it ... if it is live on mainnet today, it is about to be left on a stale interface."* All three of these are LIVE and CURRENT. `09_AQP-INFO.pact` and `14_O-UI-FOURTEEN.pact` shipped in `Deploy/PureV3/08` (confirmed on chain: `URH_AQP|AllPoolIds` returns 7, and those pools exist only if Step 7 ran, which that transaction carries); `13_O-UI-THIRTEEN.pact` shipped in `Deploy/PureV2/33`; and all three are in `Deploy/PureV4` for the EquityV3 round. `01_DPL-UR.pact` is expected -- Stage Z deploys from `deploy-stagezz.repl`, a separate chain that runs last.

So read this heading as **"not in the FROM-SCRATCH chain"**, not as "not deployed". This tool globs the `deploy-stage0*.repl` loaders, which build a virgin chain; the hand-deploy rounds (`Deploy/PureV2`, `PureV3`, `PureV4`) are a different mechanism it cannot see, and `AppReads` modules load from `modules/APPREADS-OuronetUI.repl` rather than any stage loader. A warning that cannot distinguish "absent" from "shipped by another route" will cry wolf every round, and this one did for three.

## What was verified, and what was not

- **A generated batch loads.** `Deploy/06_deploy.pact` (13 utility modules) was loaded in the REPL on top of Stage 00 and succeeded, costing **183,034 gas** against the **183,286** predicted by summing the modules individually -- 0.14% apart. The concatenation is sound and the gas model is predictive.
- **The init barriers are real.** Loading batch 09 (DALOS) straight after batch 06 fails with `Cannot find keyset in database: 'ouronet-ns.dh_sc_dalos-keyset'` -- because step 7 defines it. That failure is the evidence that the numbered order must be followed and that init steps cannot be skipped or deferred.
- **Content is verbatim.** All 78 modules appear byte-for-byte in their batches; nothing was rewritten, reflowed or glued to a neighbour.
- **NOT verified: the full sequence end to end on a chain.** Only a testnet run can do that, because the init steps are not generated here.

## Modules in the tree that this plan does NOT deploy

Checked deliberately, because a deploy plan that silently omits a module is the worst possible kind:

| module | why |
|---|---|
| `STAGE_01/0_Interfaces/{01_Utilities,02_Core,03_Talos}.pact`, `STAGE_02/0_Interfaces/{02_Core,03_Talos}.pact` | **empty** -- 0 code lines. Interfaces are now embedded in the module files that implement them. Nothing to deploy. |
| `2_CITIZEN/Stage_Z/01_DPL-UR.pact`, `02_EXPLORER.pact` | deployed by `deploy-stagezz.repl`, a separate chain, deliberately last. Not in this plan. |
| `2_CITIZEN/2_BloodshedMinter/*` (5), `3_NosferatuMinter/01_NOSFERATU.pact` | citizen minters, loaded only by the `[5.x]_Populate*` fixture suites. Deploy when minting, not as part of the core chain. |
| `2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact` | bridge scaffold; loaded only by its own module test. Not ready. |
| `STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact` | **DECIDED 2026-10-07: live, and deployed by hand.** This row read *"NEEDS A DECISION ... Either the deploy chain is missing it, or it is intentionally test-only"* -- it is neither. It is 1,405 lines of `INFO_` cost-preview code, referenced by 18 `.repl` files, **on mainnet since `Deploy/PureV3/08`**, and in `Deploy/PureV4/06` for the EquityV3 round. It is absent from `deploy-stage02.repl` and that is a gap in the FROM-SCRATCH chain, which matters only for a virgin deploy (a devnet bring-up would miss it). Add it there before the next from-scratch run; nothing is pending for mainnet. |

## Tables: already in the batches

Every `.pact` file in this tree is laid out `interface(s)` -> `module` -> its own `create-table` calls, which is the same shape you would paste by hand. A batch therefore emits **A-complete, then B-complete** -- `[ifaceA][moduleA][tablesA][ifaceB][moduleB][tablesB]` -- and never "module A, module B, then the tables of both". Nothing needs separating out. Verified by loading `Deploy/01_deploy.pact` (13 modules, 4+ tables) in one transaction.

## The AQP asset tree is NOT in this plan

`AQP-BOOT` exists to build the acquisition-pool asset tree, and it defines **thirteen** steps, `C_Step0` through `C_Step12`. **The deploy chain runs only `Step0`** (sequence step 92, wiring IMC policies and rotating the vault governor). Steps 1-12 -- the bunny set, the anchor classes, the core and subsidiary scores, the OURO LP triplet, the pools, the FVT entities, the multiplet family, the farm triplet and the reward links -- are **not deployed by anything here**.

Two things make those twelve steps a separate piece of work rather than more batches:

1. **Their arguments are threaded from earlier results.** `Step6` takes `boost-class-ids` produced by `Step3`; `Step11` takes a `farm-id` and three score ids produced by `Step7` and `Step4`. They cannot be pasted as literals until the preceding step has run and its ids are known, so this is an interactive sequence, not a file.
2. **No single file runs the whole sequence.** The fullest is `Stage_02/[6.2.9]_AQP-BOOT-FULL.repl` with nine of them (1,2,3,6,8,9,10,11,12). Steps 4 and 5 run in `triplet-collect-golden.repl` and `[6.2.2]_AQP-SCORE.repl`. There is no golden end-to-end ordering to copy.

### `C_Step7_CreatePoolsAndScores` has never been run successfully

Counted across the whole suite, per step, separating calls inside an `expect-failure` from real ones:

| step | successful runs | negative-only | |
|---|---:|---:|---|
| Step0-6, 8-12 | at least 1 each | — | fine |
| **Step7** | **0** | **6** | **never executed on its happy path** |

All six `Step7` sites are in `modules/DPDC.repl` and all six are `expect-failure`, exercising its four list-length guards with deliberately wrong-length arguments. The step that creates the six DH pools, the nine DH scores and the three OURO triplet scores has been proven only to **reject bad input**. Its success path is unexecuted anywhere in 25,035 assertions.

### Investigated 2026-09-18: the hand-rolled test DIVERGES from Step7

`TX-BOOT-07` and `07b` in `[6.2.9]_AQP-BOOT-FULL.repl` do not call `C_Step7`. They reproduce it by calling `AQP-POOL\|C_Issue` and `AQP-POOL\|C_AddScore` directly. So the **operations** are covered while the **deployment function that sequences them** is not -- and comparing the two line by line found them disagreeing:

| | DHBloodshed scores attached |
|---|---|
| `C_Step7` (and its own POOL MAP doc) | `Bloodshed` **and** `SubsidiaryBloodshed` |
| `TX-BOOT-07b` (the fixture) | `SubsidiaryBloodshed` only |

`Bloodshed` is one of the four CORE scores `C_Step4` creates. So the fixture every downstream assertion runs against differs from what a real deployment would produce, and nothing can see it because `C_Step7` is never executed.

**But the fix is not mechanical, and this needs an owner decision.** Attaching `Bloodshed` to its pool breaks `TX-BOOT-G1`, a P3.3 guard probe that uses the `Bloodshed` score **precisely because it is pool-less** in the fixture: with the link added it stops aborting in a table read and hits a different guard. Both cannot be right:

- **If `C_Step7` is correct**, the probe must pick a genuinely pool-less score, and the fixture has been wrong.
- **If the probe is correct**, `C_Step7` over-attaches and would wire mainnet differently from every test.

*An attempt to add a positive `C_Step7` execution as a rolled-back block got as far as satisfying `GOV\|AQP_BOOT_ADMIN`, then needed the `coin.TRANSFER` managed caps the pool issues charge -- which is why `TX-BOOT-07` carries that elaborate `env-sigs` block. It was reverted rather than left half-finished; the suite is green.*

**Do not deploy the asset tree until that is resolved.** The cheapest resolution is to extend `[6.2.9]_AQP-BOOT-FULL.repl` to run 4, 5 and 7 in place, which would also give the end-to-end ordering this plan cannot currently provide.

## The sequence

Read top to bottom. **`step`** is the position in the full sequence; **`file`** is the deploy file to paste, numbered `01`..`9` in the order you use them. Init steps have no file -- their source is given instead.

| step | file | what | gas | source |
|---:|:---:|---|---:|---|
| 1 | **01** | DEPLOY 3 modules: 02_IGNIS, 00_AQP-SCHEMAS, 01_ANK | 249,736 | `Deploy/1_Pure/01_deploy.pact` |
| 2 | **02** | DEPLOY 1 modules: 02_SCORE | 269,902 | `Deploy/1_Pure/02_deploy.pact` |
| 3 | **03** | DEPLOY 1 modules: 03_AQP | 242,927 | `Deploy/1_Pure/03_deploy.pact` |
| 4 | **04** | DEPLOY 1 modules: 04_RPS | 328,763 | `Deploy/1_Pure/04_deploy.pact` |
| 5 | **05** | DEPLOY 1 modules: 04b_RPSC | 130,214 | `Deploy/1_Pure/05_deploy.pact` |
| 6 | **06** | DEPLOY 1 modules: 05_FVT | 309,626 | `Deploy/1_Pure/06_deploy.pact` |
| 7 | **07** | DEPLOY 3 modules: 06_VCT, 07_MTX-AQP, 08_DSA | 419,312 | `Deploy/1_Pure/07_deploy.pact` |
| 8 | **08** | DEPLOY 2 modules: 08b_EVCT, 04_TS02-C3 | 259,571 | `Deploy/1_Pure/08_deploy.pact` |
| 9 | **09** | DEPLOY 3 modules: 09_AQP-INFO, 04_AQP-BOOT, 03_DSP+ | 64,205 | `Deploy/1_Pure/09_deploy.pact` |
