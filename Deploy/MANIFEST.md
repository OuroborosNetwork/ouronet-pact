# Ouronet deploy plan

**Generated** by `python3 REPL/tools/_deploybundle.py --write`. Do not hand-edit; regenerate.

- per-transaction gas budget: **1,700,000** (StoaChain block limit 2,000,000)
- module-deploy transactions: **20**
- modules deployed: **52**
- measured module gas: **5,753,676**

## Read this before deploying

**The gas figures are REPL figures.** They come from `env-gasmodel "table"`, the same model the chain uses, measured by running the deploy chain. They do **not** include per-transaction overhead or signature verification. The budget above leaves headroom for that, but the batches are a **proposal to validate on testnet**, not a guarantee.

**Order is the safety property.** A module may only reference modules already deployed. Nothing here has been reordered, and the numbered steps must be executed in the order given.

**The `INIT` steps are not generated.** Between runs of module deploys the chain performs initialisation -- registering inter-module policies, seeding constants, minting genesis supply. Those need signatures, keysets and transaction data that only you can supply, and some blocks in the REPL chain are sandbox fixtures that must **not** reach mainnet. Each is listed below with its source location so you can lift the real calls out of it. **Do not skip them:** a module deployed after an init step may depend on that step having run.

## ⚠ Modules that must redeploy but are in no deploy chain

These name an interface that bumped this round, so Pact's cascade rule requires them to be redeployed -- but no deploy chain loads them, so **they are not in the files below**:

- `2_CITIZEN/Stage_Z/01_DPL-UR.pact`

`01_DPL-UR.pact` is expected: Stage Z deploys from `deploy-stagezz.repl`, a separate chain that runs last.

`09_AQP-INFO.pact` is **not** expected and is the same module flagged earlier as absent from `deploy-stage02.repl`. It is 1,405 lines of cost-preview code referenced by 18 test files, it names a bumped interface, and nothing deploys it. Either the chain is missing it or it is test-only -- and if it is live on mainnet today, it is about to be left on a stale interface.

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
| **`STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact`** | **NEEDS A DECISION.** 1,405 lines of code, referenced by **18** `.repl` files including its own suite `Stage_02/[6.5]_AQP-INFO.repl`, and it is an `INFO_` cost-preview module whose previews are counted among the audited client-facing surface -- but it is **not loaded by `deploy-stage02.repl`**. Either the deploy chain is missing it, or it is intentionally test-only. Resolve before deploying. |

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

Read top to bottom. **`step`** is the position in the full sequence; **`file`** is the deploy file to paste, numbered `01`..`20` in the order you use them. Init steps have no file -- their source is given instead.

| step | file | what | gas | source |
|---:|:---:|---|---:|---|
| 1 | **01** | DEPLOY 2 modules: 02_IGNIS, 05_DPTF | 234,294 | `Deploy/1_Pure/01_deploy.pact` |
| 2 | **02** | DEPLOY 2 modules: 00_DPMF, 06_DPOF | 289,772 | `Deploy/1_Pure/02_deploy.pact` |
| 3 | **03** | DEPLOY 2 modules: 08_ATS, 09_TFT | 285,032 | `Deploy/1_Pure/03_deploy.pact` |
| 4 | **04** | DEPLOY 4 modules: 10_ATSU, 11_VST, 12_LIQUID, 13_OUROBOROS | 397,481 | `Deploy/1_Pure/04_deploy.pact` |
| 5 | **05** | DEPLOY 2 modules: 15_SWP, 16_SWPI | 254,885 | `Deploy/1_Pure/05_deploy.pact` |
| 6 | **06** | DEPLOY 3 modules: 17_SWPL, 18_SWPLC, 19_SWPU | 358,201 | `Deploy/1_Pure/06_deploy.pact` |
| 7 | **07** | DEPLOY 5 modules: 20_MTX-SWP, 21_CODEX, 22_PYTHIA, 01_TS01-A, 02_TS01-C1 | 321,972 | `Deploy/1_Pure/07_deploy.pact` |
| 8 | **08** | DEPLOY 3 modules: 03_TS01-C2, 04_TS01-C3, 06_TS01-C4 | 215,823 | `Deploy/1_Pure/08_deploy.pact` |
| 9 | **09** | DEPLOY 1 modules: 02_INFO-ONE+ | 436,246 | `Deploy/1_Pure/09_deploy.pact` |
| 10 | **10** | DEPLOY 6 modules: 02_DPDC, 03_DPDC-C, 04_DPDC-I, 05_DPDC-R, 06_DPDC-MNG, 07_DPDC-T | 411,410 | `Deploy/1_Pure/10_deploy.pact` |
| 11 | **11** | DEPLOY 5 modules: 08_DPDC-S, 09_DPDC-F, 10_DPDC-N, 11_EQUITY+, 00_Demipad | 358,069 | `Deploy/1_Pure/11_deploy.pact` |
| 12 | **12** | DEPLOY 1 modules: 01_ANK | 151,366 | `Deploy/1_Pure/12_deploy.pact` |
| 13 | **13** | DEPLOY 1 modules: 02_SCORE | 229,502 | `Deploy/1_Pure/13_deploy.pact` |
| 14 | **14** | DEPLOY 1 modules: 03_AQP | 203,548 | `Deploy/1_Pure/14_deploy.pact` |
| 15 | **15** | DEPLOY 1 modules: 04_RPS | 353,658 | `Deploy/1_Pure/15_deploy.pact` |
| 16 | **16** | DEPLOY 1 modules: 05_FVT | 252,465 | `Deploy/1_Pure/16_deploy.pact` |
| 17 | **17** | DEPLOY 3 modules: 06_VCT, 07_MTX-AQP, 08_DSA | 392,563 | `Deploy/1_Pure/17_deploy.pact` |
| 18 | **18** | DEPLOY 3 modules: 09_AQP-INFO, 01_TS02-C1, 02_TS02-C2 | 221,896 | `Deploy/1_Pure/18_deploy.pact` |
| 19 | **19** | DEPLOY 5 modules: 04_TS02-C3, 05_TS02-DPAD, 02_Snakes, 03_Custodians, 01_INFO-TWO | 385,493 | `Deploy/1_Pure/19_deploy.pact` |
| 20 | **20** | DEPLOY 1 modules: 04_AQP-BOOT | 0 | `Deploy/1_Pure/20_deploy.pact` |
| 21 | — | *init* — deploy-stage02 · AQP-BOOT Step0 WireImcAndGovernor | — | `Deploy/2_Init/` · `REPL/deploy-stage02.repl:63` |
