# FVT-SPLIT-DESIGN — 2-module split (`RPS` + `FVT`)

**Task #75.** `04_FVT.pact` (module `AQP-FVT`, interface `AcquisitionFarmsVaultsTreasuriesV2`)
is **7,501 lines** — past StoaChain's deploy cliff. Split it into **two** deployable modules
along the capability seam, pre-mainnet (cheap now; structurally hard after first deploy because
Pact tables are module-scoped). Owner-approved shape: **two modules**, the leaf carrying its own
`SECURE`.

Supersedes the earlier 3-module draft. Names are **owner-locked**: `RPS` (the extracted leaf) and
`FVT` (keeps its name).

---

## 1. Feasibility under the real gas model (not a byte wall)

Per `MODULE-SIZING.md`, the deploy limit is **module-load gas**, and the Chainweb **size charge
grows as the 7th power** of transaction size, against **StoaChain's 2,000,000-gas block limit**.
The "cannot deploy at all" cliff sits at **~6,635 lines**.

| | lines | ≈ load gas | % of 2M budget |
|---|---|---|---|
| FVT today | 7,501 | > 2,006,661 | **> 100% — undeployable** |
| each half after split | ~3,700–3,850 | ~199–230 K | **~10–11%** |

Because the charge is a 7th power, **halving a module divides its size charge by 2⁷ = 128**. Two
~3,750-line modules deploy with ~88% headroom each. **2 modules is sufficient** — the earlier
"need 3" used a 150 KB byte-wall framing that does not match StoaChain's gas model. Power stays
**7** (the 7→5 idea was set aside).

> Caveat: the canon §7.16 let-staircase pass added ~800 whitespace lines to FVT (6,694 → 7,501),
> nudging each half from the `<3,500` *target* band into the `3,500–4,000` *acceptable-with-a-plan*
> band. Still ~11% of budget. If both halves must be `<3,500`, bias the split RPS-heavy (the reward
> math is the denser half) or trim.

---

## 2. The seam — an **accountant** (`RPS`) and an **estate registrar** (`FVT`)

Cut at the **authorization boundary** (`MODULE-SIZING.md` §4: split by capability, never by line
count), following the **reward-settlement pipeline**. Measured coupling is tiny: only **7 functions
/ 34 lines (0.5%)** have names touching both reward-tables and structure-tables.

### `RPS` — reward-per-share ledger / accountant  *(leaf, deploys FIRST, own `SECURE`)*
The yield ledger and all the math that moves it. Pure leaf: inputs in, ledger writes out.

### `FVT` — the estates + governance + client surface  *(deploys SECOND, keeps the name)*
The farms/vaults/treasuries themselves, their ownership/config/topology, vacate/sweep, and **every
client entrypoint**. Orchestrates coarsely: reads its own structure, then drives `RPS` through one
`XE_` call per phase.

---

## 3. Table assignment (the 16 tables — partition anchors)

**REVISED after P1 measurement (2026-09-03).** The first cut (ledger-only → RPS) left FVT at
6,435 lines / ~84% gas — deployable but no headroom — because the reward-settlement orchestration
(67% of the mass) reads **`ScoreEntityLink`** throughout (36 fns). So the reward-*distribution
topology* moves with the ledger: RPS becomes the reward **engine**, FVT the entity/config/client
shell. Measured result: **RPS ≈ 3,288 / FVT ≈ 2,765 lines, 0 DAG hazards.**

| → `RPS` (reward engine: ledger + distribution topology) | → `FVT` (entity + config + client) |
|---|---|
| `FVT\|T\|RPS\|Global/Member/User/Stream` | `FVT\|T` (entity: class/owner/denominator) |
| `FVT\|T\|MemberVault`, `FVT\|T\|MemberUserWeight` | `FVT\|T\|AgencyFee` |
| `FVT\|T\|ForcedFixCount` | `FVT\|T\|QualitySplit` |
| `FVT\|T\|ScoreEntityLink` (reward topology) | `FVT\|T\|DsaOracleConfig` |
| `FVT\|T\|UserPresence` (per-user reward presence) | `FVT\|T\|VacateFreeze` |
| `FVT\|T\|MultipletFamily` (reward multiplet chains) | `FVT\|T\|SweepProgress` |
| shared policy tables `P\|T`, `P\|MT` **duplicated** (IMC plumbing, not domain data) | |

`FVT|T` (the entity identity row) stays in FVT — its config fields (denominator/class/owner/
mosaic/vacate-frozen) are read once per op and **arg-passed** into the RPS phase entrypoints.

**FVT|T reward-aggregate split (required for a clean DAG).** Measurement (195-fn move-set)
shows the orchestration also *writes* 5 `FVT|T` fields — `total-deb-score`,
`total-ghost-tvl-weight`, `member-link-count`, `enabled-reward-count`, `membership-mode`. If the
orchestration lives in RPS those writes would be RPS→FVT (a cycle). Fix: move these 5 aggregate
fields out of `FVT|T` into a **new RPS-owned table `FVT|T|RewardAggregate`** (key = `<FVT-ID>`).
`FVT|T` then holds only identity/config; the orchestration writes only RPS tables → RPS stays a
pure leaf. This is a small pre-mainnet data-model refinement (no live data). The 24-reader
arg-pass surface (denominator/class/owner/mosaic/vacate + QualitySplit/AgencyFee/Oracle config)
is read by FVT and threaded into the RPS phase entrypoints.

---

## 4. Function allocation

**Principle:** a function follows the **tables it mutates**, not its name. Reward-math functions go
to `RPS` even when named `FVT|…` (e.g. `XI_FvtInjectCore`, `UR_FVT|TotalDebScore`,
`WU_Fvt|TotalDebScore`); structure functions stay in `FVT`.

### → `RPS` (~150 reward fns + the settle/inject/deb math, ~3,000 lines)
- **Ledger readers/writers by table-family:** `*FVT-RG|*` (27), `*FVT-RM|*` (13), `*FVT-RU|*` (13),
  `*FVT-RS|*` (1), `*FVT-MV|*` (2), `*FVT-MUW|*` (1), `*ForcedFix*` (4), plus their `WU_Rps*` writers
  (subset of the 33 `WU_`).
- **The math / hot loops (run entirely inside `RPS`):** `XI_1|FarmSplitInject`,
  `XI_2|SettleMemberTier2`, `XI_DistributeInjectAmount`, `XI_FvtInjectCore`, `XI_FixUser*Deb*` (all
  variants), `XI_FixUserMemberDeb*`, `XI_SyncFvtTotalDebMirrors`, `XI_SyncFarmGhostTvlForInject`,
  `XI_ReleaseStream`, `XI_BookCollectUnclaimed`, `XI_1|BookCollectUnclaimed`,
  `XB_FvtInject`, and the RPS-side of `XI_RefreshCollectableStakeAnchors`.
- **Derivers:** `URC_Settle*`, `URC_*Inject*`, `URC_CollectClaimableRewards`, `URC_*Deb*`,
  `URC_ProjectedIndexAdvance`, `URC_LiveClaimable`, `URC_StreamStatus`, `UC_ComputeInjectGainedRps`,
  and the index-advance compute.
- **Own `SECURE`** + `XE_` forward-entrypoints (§5) + the `URCi_*` cost readers for reward ops.

### → `FVT` (estates + lifecycle + client surface, ~3,500–3,700 lines)
- **Structure by family:** `*FVT|*` entity readers/writers (the structural subset of the 84),
  `*FVT-SEL|*` (22), `*FVT-MF|*` (17), `*FVT-UP|*` (1), `*FVT-AF|*` (2), `*FVT-QS|*` (4),
  DSA-oracle-config, `Vacate*`/`Sweep*` (28).
- **Entity lifecycle A_/C_:** `C_Issue`, `C_AddRewardLink`, `C_AddScoreEntity`, `C_RotateOwnership`,
  `C_SetCommonDenominator`, `C_SetQualitySplit`, `C_SetSplitMode`, `C_SetMosaic`, `C_Control`,
  `C_ToggleRewardLink`, `C_ToggleScoreEntityLink`, `C_IssueMultipletFamily`.
- **All client orchestrators:** `CC_Collect`, `CC_Inject`, `CC_InjectFinalize`, `CC_InjectStream`,
  `CC_*StakeFlow` (TrueFungible/OrtoFungible/Collectable), `CC_UnstaleMyScores`, `CC_SweepBegin`,
  `CC_SweepRevokeAnchor`, `CCp_InjectFixChunk`, `CCp_UnstaleAll`. These **build the plan/slice**
  (`URHC_BuildInjectScorePlans`, `URH_FVT|SettleFvtRewardBundle`, `URHC_BuildStakeSettleBundle`) and
  make **one `RPS::XE_` call per phase**.
- Registered as an **IMC caller-guard** on `RPS`.

---

## 5. Capability model & cycle-freedom

- **`RPS` owns its own `SECURE`.** Its `WU_Rps*` writers `require-capability` an `RPS`-local cap
  composing that `SECURE`. This is the "second secure."
- **`XE_` forward-entrypoints** are the only way `FVT` mutates the ledger. Each: `P|UEV_IMC` →
  `with-capability (RPS|XE>… )` (composing the local `SECURE`) → writes only. No `enforce`/`UEV_*`
  after `UEV_IMC`; no `OutputCumulator` (FVT's `C_` composes IGNIS).
- **Loops live inside `RPS`.** A settle/inject/collect pass crosses the module boundary **once per
  phase**, never once per user — `FVT` hands `RPS` the whole plan/slice and `RPS` iterates
  internally. This neutralizes the gas-per-hop risk on the hot paths.
- **No back-reference → clean DAG.** `RPS` never reads `FVT`'s tables. The few structure fields the
  math needs (denominator, class, owner, split-mode) are **computed by `FVT` and passed as
  arguments** into `RPS::XE_`. Dependency graph: `RPS → {IGNIS, DALOS, DPTF, SCORE-reads}`;
  `FVT → RPS::XE_`. No cycle, so `RPS` deploys first. Same idiom already proven by DSA and SCORE→FVT.

### The seam-crossers (each splits into an FVT orchestration part + an RPS `XE_`)
`CC_Collect`, `CC_Inject`/`CC_InjectFinalize`/`CC_InjectStream`, `CC_*StakeFlow`,
`CC_UnstaleMyScores`, `XI_1|FarmSplitInject`, `XI_2|SettleMemberTier2`, `XI_FixUserFvtDebIn`,
`WI_QualitySplit`, `C_IssueMultipletFamily`, `C_SetQualitySplit`, `UR_FVT`, `URH_FvtPresentUsers`,
`UEV_AddRewardLinkContext`, `P|A_Define`, and the two `REPL_Bootstrap*` helpers. The RPS-write half
of each becomes an `XE_`; the read/validate/structure half stays in `FVT`.

---

## 6. Interfaces, deploy order, cascade

- **New interface `AcquisitionRewardPerShareV1`** for `RPS` (carries the ledger API + `XE_` + `URCi_`
  + reader members). `FVT` keeps **`AcquisitionFarmsVaultsTreasuriesV2`**, edited **in-place**
  (drop the moved RPS members, add references to `AcquisitionRewardPerShareV1`) — pre-mainnet, so no
  version bump per repo policy.
- **Deploy order (interface-first, leaf-first):**
  `AcquisitionRewardPerShareV1` → `RPS` → `AcquisitionFarmsVaultsTreasuriesV2` → `FVT`.
- **File renumber in `2_Core/03_AQP/`:** `04_RPS.pact`, `05_FVT.pact`, then `06_VCT`, `07_MTX-AQP`,
  `08_DSA`, `09_AQP-INFO`. Update the Sovereign-Executor `[2.3]_EarningPools` deploy list + IMP/IMC
  "Define IMC Policies" TX (register `FVT` as caller-guard on `RPS`).
- **Cascade is small** — only 5 files name `AcquisitionFarmsVaultsTreasuriesV2` today (`TS02-C3`,
  `MTX-AQP`, `DSA`, `VCT`, FVT). They keep referencing it (= `FVT`); only the consumers that read
  reward-ledger state directly add an `AcquisitionRewardPerShareV1` / `RPS::` reference
  (VCT reads vacate-drain RPS state; MTX-AQP reads inject/sweep RPS state — confirm at P1).

---

## 7. Risks

1. **Hot-path gas (the real one).** Cross-module `XE_` costs gas per call. Mitigated structurally by
   keeping loops inside `RPS` (§5): one hop per phase. Measure against the `[6.2.6]` GAS probe after
   P1; if any per-iteration hop remains, move that loop wholly into `RPS`.
2. **Deploy-order cycle.** If any `RPS` function is found to read an `FVT` table, the seam is
   misplaced — convert it to an argument passed from `FVT`. P1 re-checks the dependency direction.
3. **Line balance.** If `FVT` lands over ~3,900 lines, shift the `UC_` compute helpers (pure, no
   table access) into `RPS` or a tiny shared util — they have no capability coupling.

---

## 8. Phased execution plan (post-approval)

- **P0 — this doc (done).**
- **P1 — extract `RPS`:** new interface + module; move the ledger tables + schemas + reward
  math + own `SECURE` + `XE_` writers; rewrite the seam-crossers to `FVT`-orchestration + `RPS::XE_`;
  wire IMC; renumber files + executor. Green-gate `Z.repl` + the `[6.2.4]` FVT/`[6.2.5]` VCT suites.
  **Re-measure both modules' lines** (the go/no-go).
- **P2 — rebalance** if either half is out of band (move `UC_` helpers per Risk 3). Re-measure.
- **P3 — gas check:** `[6.2.6]` GAS probe on collect/inject/stake hot paths vs pre-split baseline.
- **P4 — full green-gate + fresh top-to-bottom redeploy dry-run** (feeds #83).

**Status: DESIGN COMPLETE — awaiting owner GO to start P1.**

---

## Stage 1 field-set (LOCKED) — `FVT|T|RewardAggregate` (key = `<FVT-ID>`)

Move these 7 reward-computation aggregates out of `FVT|Schema` (all written by the reward /
link / refresh orchestration that moves to RPS in Stage 3):
- `total-ghost-tvl-weight`  (Farm inject denominator S; writer `WU_Fvt|TotalGhostTvlWeight`)
- `total-deb-score`         (Vault/Treasury inject denominator; `WU_Fvt|TotalDebScore`)
- `total-base-score`        (SCORE mirror; written via the 2b full-row refresh)
- `total-boosted-score`     (SCORE mirror; refresh)
- `total-nzs-count`         (SCORE mirror; refresh)
- `enabled-reward-count`    (`WU_Fvt|EnabledRewardCount`; AddRewardLink/ToggleRewardLink)
- `member-link-count`       (`WU_Fvt|MemberLinkCount`; AddScoreEntity)

STAY in `FVT|Schema` (identity/config): `fvt-class`, `owner-konto`, `can-upgrade`,
`can-change-owner`, `common-denominator`, `mosaic`, `membership-mode`, `oracle-on`, `split-mode`,
`fvt-id`.

Stage-1 edit surface (atomic, in-module, green-gated by the reward suites which assert these
numbers): new schema+table+create-table; repoint the per-field `WU_Fvt|*`/`UR_FVT|*` for the 5
writer-backed fields to the new table; repoint the 3 refresh-mirror writes + their `UR_FVT|*`
readers; split `WI_Fvt`/`UDC_FVT|Schema` row construction into identity-row + aggregate-row; fix
any `(at "<field>" (read FVT|T ...))` sites. `Z.repl` + `[6.2.4]/[6.2.5]/[6.2.8]` must stay green
AND match pre-change numbers (behavioral-equivalence gate).
