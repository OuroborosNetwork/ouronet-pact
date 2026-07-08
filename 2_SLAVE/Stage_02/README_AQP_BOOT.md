# AQP-BOOT — bootstrap handoff guide

Module: `04_AQP-BOOT.pact` | Interface: `AcquisitionPoolBootV1`

**Purpose:** This slave module is the **mainnet runbook** and **REPL test backbone** for AQP provisioning. Each step is one (or few) on-chain transactions. Steps are **separate** so you can pause, verify, and pass **explicit ids** into the next step.

**Canonical flow docs:** [README.md § OURO LP onboarding](../../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README.md#ouro-lp-onboarding-flow-per-lp-line) (LP + farm user path).

---

## Design rules

1. **Deterministic ids from names** — Pool, score, anchor, and BoostClass ids come from `U|DALOS::UDC_Makeid "<Name>"`. Same name ⇒ same id on REPL and mainnet (hash suffix comes from chain deploy, not from this module).

2. **Collection asset ids are inputs** — DPSF/DPNF/LP/DPTF ids (`DHCD-…`, `DHB-…`, `OURO-…`, `W|…|LP-…`) are **passed in** by the operator. REPL and mainnet use different suffixes; **never hardcode them in boot code** — only in `;;` examples.

3. **Every step returns a formatted string** — Copy ids from the tx result / `(print …)` into the next step's arguments. Field names are stable: `anchor-ids`, `boost-class-ids`, `score-ids`, `pool-ids`, etc.

4. **REPL = same code path as mainnet** — REPL runs the same `C_StepN_*` functions; only **inputs** (patron, kbn-id, collection ids) differ.

5. **One tx per step (typical)** — Mainnet: run Step N, read output, run Step N+1 with those ids. REPL: same, wrapped in `begin-tx` / `commit-tx` per `[6.2.*].repl` file.

---

## Step chain (what feeds what)

| Step | Function | Inputs (you pass) | Creates / writes | Output string includes | Next step needs |
|------|----------|-------------------|------------------|------------------------|-----------------|
| **0** | `C_Step0_WireImcAndGovernor` | `patron` | FVT + VCT `P\|A_Define`; AQP-POOL TFT IMC; `C_RotateGovernor` on `AQP\|SC_NAME` (`AQP-ANK.AQP\|GOV` + `VCT\|RemoteAqpGov`) | `aqp-sc` | Stake/unstake / vacate client txs, or **1** |
| **1** | `C_Step1_CreateBunnySet` | `patron`, `kbn-id` | KBN bunny set | `kbn-id` | **2**, **3** — same `kbn-id` |
| **2** | `C_Step2_CreateSnakePowerAnchorClasses` | `patron`, `kbn-id` | 4 anchors + 3 BoostClasses | `anchor-ids`, `boost-class-ids` (Bronze, Silver, Golden) | **6** — `boost-class-ids` = `[Silver Bronze Golden]` order |
| **3** | `C_Step3_CreateBoosterAnchorClasses` | `patron`, `kbn-id` | 11 anchors + 3 BoostClasses | `anchor-ids`, `boost-class-ids` (Unity, Stoa, Vesta) | ANK / user boosting (not required for Step 6–7) |
| **4** | `C_Step4_CreateCoreScores` | `patron`, `owner-konto` | 4 scores | `score-ids` ×4 | **7** — `dh-score-ids` slots 0,2,4,5 |
| **5** | `C_Step5_CreateSubsidiaryScores` | `patron`, `owner-konto` | 5 scores | `score-ids` ×5 | **7** — `dh-score-ids` slots 1,3,6,7,8 |
| **6** | `C_Step6_CreateOuroLpTriplet` | `patron`, `owner-konto`, `lp-denominator`, `boost-class-ids`[3] | 3 class-0 LP scores + links | `score-ids` ×3, `boost-class-ids` echo | **7** — `ouro-triplet-score-ids`; **9** — farm `C_AddScoreLink` |
| **7** | `C_Step7_CreatePoolsAndScores` | `patron`, `dh-asset-ids`[6], `ouro-lp-asset-id`, `dh-pool-ids`[6], `ouro-lp-pool-id`, `dh-score-ids`[9], `ouro-triplet-score-ids`[3] | 7 pools + 12 score slots | `pool-ids` ×7, asset echo | **8** |
| **8** | `C_Step8_IssueFvtEntities` | `patron`, `owner-konto`, `lp-denominator` (empty skips farm) | 5 FVT `C_Issue` (farm optional) | `fvt-ids` ×5 | **9**, **10** — pass `fvt-ids` |
| **9** | `C_Step9_AddFvtScoreLinks` | `patron`, `fvt-ids` ×5, triplet/subsidiary/core score ids | 11 `C_AddScoreLink` | score-link counts echo | **10** |
| **10** | `C_Step10_AddFvtRewardLinks` | `patron`, `fvt-ids` ×5, reward DPTF ids ×3 | 5 `C_AddRewardLink` | reward echo | Inject / stake / collect |

### Steps 8–10 FVT map

| FVT name | Class | Score links | Reward token |
|----------|-------|-------------|--------------|
| `OuroLpFarm` | 0 farm | SilverSnakePower, BronzeSnakePower, GoldenSnakePower | Auryn |
| `SubsidiaryTreasury` | 1 vault | SubsidiaryCodingDivision, SubsidiaryBloodshed, SubsidiaryNosferatu, SubsidiaryBunnies, SubsidiaryWonderCoach | Auryn |
| `CodingDivisionTreasury` | 1 vault | TheCodingDivision | Wstoa (`DALOS::UR_WrappedStoaID`) |
| `SnakesTreasury` | 1 vault | DemiourgosSnakes | Auryn |
| `CompanySharesTreasury` | 1 vault | DemiourgosShareholder | Ouroboros (`DALOS::UR_OuroborosID`) |

Farm `common-denominator` at issue = `lp-denominator` (full OURO DPTF id, same as Step 6). Vault entities use `"|"` at issue. Product UX names these vaults “Treasury”; FVT class 2 remains OF-only per `URC_ScoreClassMatchesFvtClass`.

### Step 9 `subsidiary-score-ids` (recommended order)

| Index | Score name |
|-------|------------|
| 0 | SubsidiaryCodingDivision |
| 1 | SubsidiaryBloodshed |
| 2 | SubsidiaryNosferatu |
| 3 | SubsidiaryBunnies |
| 4 | SubsidiaryWonderCoach |

### Step 7 `dh-score-ids` index map (from Steps 4–5)

| Index | Score name | From step |
|-------|------------|-----------|
| 0 | TheCodingDivision | 4 |
| 1 | SubsidiaryCodingDivision | 5 |
| 2 | Bloodshed | 4 |
| 3 | SubsidiaryBloodshed | 5 |
| 4 | DemiourgosShareholder | 4 |
| 5 | DemiourgosSnakes | 4 |
| 6 | SubsidiaryWonderCoach | 5 |
| 7 | SubsidiaryNosferatu | 5 |
| 8 | SubsidiaryBunnies | 5 |

### Step 7 `dh-asset-ids` (collection ids — **not** from UDC_Makeid)

| Index | Pool | aqp-class | REPL example |
|-------|------|-----------|--------------|
| 0 | DHCodingDivision | 3 DPSF | `DHCD-98c486052a51` |
| 1 | DHBloodshed | 4 DPNF | `DHB-98c486052a51` |
| 2 | DHCompany | 3 DPSF | `E\|DH-98c486052a51` |
| 3 | DHWonderCoach | 3 DPSF | `DHWC-98c486052a51` |
| 4 | DHNosferatu | 4 DPNF | `DHN-98c486052a51` |
| 5 | DHBunnies | 4 DPNF | `KBN-98c486052a51` |

Plus `ouro-lp-asset-id` — native LP id for `DHOuroLp` (class 0).

---

## REPL integration

| REPL file | Boot steps exercised |
|-----------|---------------------|
| `[6.2.1]_AQP-ANK.repl` | TX006 = Step 2, TX007 = Step 3 |
| `[6.2.2]_AQP-SCORE.repl` | TX-SCORE-08 = Step 4, 09 = Step 5, 10 = Step 6, 11 = score defs (after 4–5) |
| `[6.2.3]_AQP-POOL.repl` | *(planned)* Step 7 |
| `[6.2.9]_AQP-BOOT-FULL.repl` | Steps 2–3, 6–10 (FULL chain; needs KBN + Steps 4–5) |
| `[6.3]_AQP-COMPREHENSIVE.repl` | Boot FVT wiring + RPS inject/stake/collect on Steps 8–10 entities |
| `REPL/AQP-comprehensive.repl` | Master loader: population + boot 0–10 + `[6.2]_AQP` + `[6.3]` + `[6.4]` exhaustive |

Load order: `Stage02_Tester.repl` deploys `04_AQP-BOOT.pact` before `[6.2]_AQP.repl`. See [REPL_AND_TESTS.md](../../OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md).

---

## Mainnet operator checklist

1. Deploy AQP sovereign modules (ANK → SCR → AQP-POOL → FVT → **VCT**) + Talos + AQP-BOOT.
2. **Step 0** — `C_Step0_WireImcAndGovernor`: IMC + `AQP|SC_NAME` governor (REPL: `Stage02_Tester` TX-02 [5.6]).
3. Run Steps **1 → 3** (anchors; save `boost-class-ids` from Step 2 for Step 6).
4. Run Steps **4 → 6** (scores; save all `score-ids`).
5. Gather **collection asset ids** from live chain (DPDC / SWP deploy — not from boot output).
6. Precompute **pool ids** via `U|DALOS::UDC_Makeid` pool names (or read from Step 7 output after run).
7. Run **Step 7** with explicit lists (see `;;` block in pact file).
8. Run **Step 8** — issue five FVT entities (`C_Issue` only).
9. Run **Step 9** — `C_AddScoreLink` per § Steps 8–10 FVT map (pass `fvt-ids` from Step 8).
10. Run **Step 10** — `C_AddRewardLink` per entity (pass same `fvt-ids` + live reward DPTF ids).

**After each tx:** copy the function's return string to your runbook / env file before continuing.

---

## Related

- [AQP system guide](../../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README.md)
- [OURO LP onboarding flow](../../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README.md#ouro-lp-onboarding-flow-per-lp-line)
- [REPL_AND_TESTS.md § AQP-BOOT](../../OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md)
