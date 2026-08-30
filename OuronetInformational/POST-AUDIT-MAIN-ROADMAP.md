# Post-audit MAIN roadmap — the master checklist

The single tracker for everything queued once the audit worktrees land on `main`.
Created 2026-08-27 · last reorganised 2026-08-30 (4-level numbering). Specs are cross-referenced.

### How to read the numbering — `Chapter.Phase.Subphase.Step`
Every element carries a dotted address so you can point at it exactly. Header size drops one step per level.

| Level | Format | Header | Example |
|-------|--------|--------|---------|
| **Chapter** | `N` | `##` (biggest) | `1` — Code Finalization |
| **Phase** | `N.P` | `###` | `1.1` — URCi cost architecture |
| **Subphase** | `N.P.S` | `####` | `1.1.2` — Per-module URCi walk |
| **Step** | `N.P.S.T` | list item | `1.1.2.1` — walk modules in deploy order |

> The **phase digit is the familiar global Phase 0–9** everyone already references — the leading chapter
> digit only *groups* them (Chapter 1 = Phases 0–7, Chapter 2 = Phases 8–9). So "Phase 7" is `1.7`,
> "Phase 8" is `2.8`. Nothing renumbers; the address just gets a chapter prefix and a subphase middle.

---

## 📊 DASHBOARD — the whole arc at a glance

**Legend:** ✅ done · ❌ not done · ⚠ open decision (blocks its phase) · 🔒 hard dependency on earlier phases · — future/out-of-scope.
**Progress (2026-08-30): 10 ✅ / 70 ❌.** Chapter 1 · Phase 0 fully closed; Phase 1 is next.

**The shape of the work.** **Chapter 1** is one long **code-finalization spine** (Phases 0→7) that ends in
a fresh redeploy. **Chapter 2** is the **two capstones** that hang off the final deployed shape — the **UI**
(Phase 8) and the **Documentation + Audit Book** (Phase 9). Everything in Chapter 2 needs the code frozen
first. **Chapter 3** is Stage-3 future work; **Chapter 4** is standing reference (decisions, carry-over, invariants).

| Ch | Phase | Goal (one line) | Status |
|----|-------|-----------------|--------|
| **1** | **1.0** Merge audits + reconcile + green-gate | Land all 4 audits + DEMIPAD on `main`, reconcile, snapshot live interface versions, all-green | ✅ **COMPLETE** |
| **1** | **1.1** `URCi` cost architecture | A per-function cost reader (`URCi_`) on every client op so exec + info move together | ❌ **NEXT** — ⚠ gated on **1.1.1.1** decision |
| **1** | **1.2** INFO rehaul (complete + consolidate) | An INFO preview for **every** entrypoint (repo-wide), one `Z_Reads` INFO module per stage | ❌ |
| **1** | **1.3** Re-price IGNIS | Measure real STOA gas, re-price via `UsagePrice` tiers + heavy-read surcharge | ❌ |
| **1** | **1.4** AQP module splits | Split `04_FVT` (over the deploy ceiling) along capability seams; re-check the rest | ❌ |
| **1** | **1.5** REPL finalization + CI harden | Repo-wide coverage of every `C_`/`A_`; one-boot whole-system test; CI exec↔info gate | ❌ |
| **1** | **1.6** Red team + Audit Book | Adversarial multi-agent attack on all modules; assemble the book (Parts I/II/III) | ❌ |
| **1** | **1.7** Interface bump + cascade + redeploy | Version-bump every changed interface (live+1), cascade, deploy-ready gate, fresh redeploy | ❌ 🔒 1.0–1.6 |
| **2** | **2.8** UI incorporation (capstone) | Intelligent UX blueprint → OuronetUI agent (desktop then mobile) | ❌ 🔒 Ch.1 |
| **2** | **2.9** Documentation + publish | Full written docs + the Audit Book, published on the website | ❌ 🔒 1.7 |
| **3** | **3.1** Stage 3 (future) | Heir System · NFT Marketplace · Order-book DEX · Lending · launchpad direct-injection | — future |
| **4** | **4.1–4.3** Reference | Settled pre-phase decisions · audit carry-over · standing invariants · task map | (reference) |

---

## 1 · CHAPTER — CODE FINALIZATION
The spine. Phases 0→7 take the merged codebase to a deploy-ready, fully-tested, red-teamed shape and
redeploy it fresh. Everything downstream (the UI and the docs) hangs off the frozen shape this chapter produces.

**Branch topology (as of 2026-08-27).** `main` already contains this session's work: AQP-INFO (10/17
stake-unstake+finalize/abort, ground-truth-proven), the unified single-boot test seed (`AQP-FULL.repl`),
the transitive-heavy reclassification (`CC_`/`CCp_`) + `C_Inject` deletion, pact-5.4.1 note, and all the
design docs. **Audit worktrees:** ✅ ALL MERGED to main + reconciled + green — `ats`, `dpdc` (`7efe386`),
`swp` (`cc230d5`), `dptf-dpof`/DALOS (`07556e1`). All worktrees archived (branches preserved). Each audit's
carry-over folded into Chapter 4 + placed in its phases.

---

### 1.0 · Phase — Merge audits + reconcile + green-gate  ✅ COMPLETE
Land all four audit worktrees + the DEMIPAD audit on `main`, reconcile the seams, prove the whole system
green on pact 5.4.1, and snapshot the live interface versions. **PHASE COMPLETE (2026-08-30).**

#### 1.0.1 · Subphase — Merge & reconcile
- [x] ✅ **1.0.1.1** Merge `dpdc`, `dptf-dpof`, `swp`, `ats` worktrees → `main` (one at a time). ✅ ALL DONE.
- [x] ✅ **1.0.1.2 Reconcile conflicts — DONE (verified 2026-08-30).** The AQP-INFO call-sites against the
      DPDC/DPTF-DPOF/SWP renames were reconciled (the DPDC-drift half was `1.0.1.3`; the rest confirmed by the
      ground-truth + full green-gate passing clean). `aqp-info-groundtruth.repl` (TF/OF/SF cost-equality)
      exit 0, 0 load-failed.
- [x] ✅ **1.0.1.3 FIXED (2026-08-29): full-boot-suite drift from DPDC audit renames.** Two pre-existing
      citizen/test drifts that blocked every `OuroLpFarm` boot, found + fixed during task #89:
      (1) **Bloodshed** called `DPDC-UDC::UDC_ScoreMetaData`, which **DPDC #45L removed** — but the audit
      wrongly believed it had zero callers (it missed the 4 citizen callers). Fix is behavior-identical:
      inline its old one-liner `UDC_NonceMetaData score [0] meta` at
      `2_CITIZEN/Stage_02/1_Bloodshed/{01_BSD-L, 02_BSD-E, 03_BSD-R, 04_BSD-C}.pact` (audit-respecting: the
      `composition=[0]` footgun stays out of sovereign; `[0]` is correct for Bloodshed's mint path).
      (2) **`[5.2]_PopulateBloodshed.repl`** called `DPDC-S::UR_N|Score`, renamed to `URC_N|Score` by
      DPDC #19H (2 active refs). `AQP-comprehensive.repl` now green (371+44 asserts). **Lesson for the
      citizen-migration work (1.1.4): DPDC audits only checked sovereign callers — sweep 2_CITIZEN +
      test files for every renamed/removed DPDC symbol.**

#### 1.0.2 · Subphase — Green-gate
- [x] ✅ **1.0.2.1 Full green-gate on pact 5.4.1 — DONE + ALL GREEN (2026-08-30)**, post-DEMIPAD-audit +
      post-`2_CITIZEN` restructure. `run-aqp-audit.sh` (15 suites, ~3,100 asserts, **0 fails, "ALL
      GREEN ✓"**) + `Z.repl` (Stage 00/01/02, 0 load-fail) + `aqp-info-groundtruth.repl` (exit 0) +
      `AQP-FULL.repl` (exit 0). Everything green before proceeding.

#### 1.0.3 · Subphase — Live-version discovery & checkpoint
- [x] ✅ **1.0.3.1 Discover LIVE interface versions — DONE (2026-08-30).** Full snapshot of every deployed
      `ouronet-ns` module's implemented interface version, via the Pythia keyless dirty-read
      (`describe-module → interfaces` over `list-modules`). **57 modules with versioned interfaces →
      `OuronetInformational/LIVE-INTERFACE-VERSIONS.md`** (the live→target map; target for any changed
      interface = **live + 1**). Highlights: most cores at `…V1`; already-high live suffixes —
      `SWP`/`MTX-SWP`/`TS01-C3`/`TS01-CP` on V3, `TS01-C4` **V7**, `PYTHIA` V4, `IGNIS` V1+V2,
      `ATS` **AutostakeV2** (live is already V2, not V1 as previously assumed), `DEMIPAD-STOICPAY` V2,
      `DPL-UR` DeployerReads V7+V8. Consult this file when bumping at Phase 1.7.
- [x] ✅ **1.0.3.2 Checkpoint push** — all merges + session work pushed to `origin/main` (`3cf31ae`). ✅

#### 1.0.4 · Subphase — DEMIPAD audit
- [x] ✅ **1.0.4.1 DEMIPAD audit — DONE (2026-08-30). All 17 findings closed, one at a time, each
      REPL-proven + committed.** Tracker `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/Audit/` (README,
      ROUND-01-FINDINGS, ISSUES-RANKED, ROUND-02-FIXES). Tally: 1 Critical (#1C STOAICO drain), 3 High
      (#2H retrieval-gate, #3H/#4H Custodians), 8 Medium (#5M–#12M), 5 Low (#13L–#17L). #13L/#14L verified
      WONTFIX (canonical AQP no-clamp / KPAY 24-dec exact); the rest fixed + proven. **Three structural
      wins beyond bug fixes:** (i) **#12M launchpad slippage subsystem** — SWP-mirrored, uniform across
      all sale paths, both variants (signed padded caps `URC_Acquire` + on-chain `UEV_SlippageCost` ·
      install-path `URCcap_Acquire`); (ii) **#15M launchpad-sales-are-CITIZEN reclassification** — the
      per-asset sales moved out of sovereign core to `2_CITIZEN/6_Launchpad/`, `2_SLAVE→2_CITIZEN`
      restructure + folder scheme, "slave" term retired codebase-wide (closes #88 / subphase 1.1.4); (iii)
      **#17L StoicSyntax `URCcap_` formalization** — new `cap` marker + CAP-INSTALL colour family + flat
      prefix index (§6) for the highlighter + `URCi_` reserved. Full `Z.repl` green throughout. Carry-over
      folded into Chapter 4 (§4.2.5). Feeds Audit Book Part I (task #82).

---

### 1.1 · Phase — URCi cost architecture  ❌
Spec: `URCI-COST-ARCHITECTURE.md`; task #77. A per-function cost reader (`URCi_`) on every client op so
execution cost and INFO preview move together, module by module in deploy order.

#### 1.1.1 · Subphase — Decide & register
- [ ] ❌ **1.1.1.1 DECISION (settle before the walk): interface-richness policy.** ⚠ Fully informed now by
      the modref tests (`memories/2026-08-29-modref-*`): `::` calls resolve dynamically AND upgrade live
      regardless of interface membership, so declaring a function is a **choice**, not a requirement:
      **rich** (declare cross-module fns → enumeration + module-side drift-catch, but a changed
      interface bumps at Phase 1.7) vs **marker-lean** (stable minimal interface → zero cascade from fn
      adds, but no interface-level enumeration; the `1.2.1.3` catalog + Talos + tests cover
      enumeration/safety). Pick and apply consistently through the URCi/INFO walk. *Suggested default:*
      keep interfaces at the stable public contract; don't force churn just to declare — the catalog is
      the enumeration source, and `::` makes upgrades bless-free either way.
- [x] ✅ **1.1.1.2 DONE (2026-08-30)** — `URCi_` registered in `StoicSyntax-Prefixes.md`: §1 `i` marker,
      §2 registry row, §4 + §6 own **COST** colour family (gold, distinct from HEAVY-READ). Pure/read-only,
      no `enforce`, returns a cost cumulator (leaf) or totals a `C_`/`CC_`/`A_` (composer); the single
      source billing + preview share. Lives in-module (or IGNIS for sub-IGNIS DALOS).

#### 1.1.2 · Subphase — Per-module URCi walk
- [x] ✅ **Foundational pass DONE (2026-08-30) — DALOS-via-IGNIS + `Z_Reads` skeleton.** The walk's
      first module. Because DALOS deploys below IGNIS, its cost readers live in IGNIS (the pre-Talos
      cost hub): (A1–A3) relocated the shared `OI|*` cost/format vocabulary INFO-ZERO → IGNIS (233
      bindings repointed); (A4) added `DALOS|URCi_*` single-sourcing the tier choice for all 9 DALOS
      client ops (Talos bills through them, INFO previews from the same call — proven == prior billing);
      (A5) severed the sole Talos→INFO coupling (9 wrappers return own `format` string), moved INFO-ZERO
      → `1_SOVEREIGN/STAGE_01/Z_Reads/` deployed last via `[Z]_Reads.repl`. Commits `6f322dd`, `204cfbb`,
      `015ef68`; full `Z.repl` green throughout.
- [x] ✅ **DPTF (05) — DONE (2026-08-30). Full cost surface on URCi (23 in-module readers).** In-module URCi
      (DPTF is above IGNIS). **Group A+B (19, `e4c1433`):** 17 single-tier (Small/Medium/Big/Biggest/Branding)
      + 2 construct-pure (Burn/Mint), each `C_`/`XE_` rewired to return its `URCi`, interface-declared,
      **proven == prior inline cumulator**. **Group C (4, `937185b`):** the write-coupled trio single-sourced —
      `URCi_IssueGas`/`URCi_IssueKda` (`:decimal`, XB_IssueFree/C_Issue bill via them, cumulator output=created
      IDs stays in the write); `URCi_ToggleFeeLock` (`:OutputCumulator`, re-derived from fee-unlocks, computed
      PRE-increment in `C_`); `URCi_UpgradeBranding` (`:decimal` = months×"blue"). All proven, `Z.repl` green.
      **Next cost module in deploy order: DPMF (00) / DPOF (06).**
- [x] ✅ **DPOF (06) — DONE (2026-08-30). Full cost surface on URCi (19 readers, commit `01bf762`).**
      Live OrtoFungible (nonce/metadata-rich). 13 single-tier composers (Branding ×1.5; `UpdateSpecial`
      via `ref-DPTF::UR_Konto`) + `URCi_Mint` (Medium, C_Mint concatenates the created-nonce output) +
      3 `:decimal` price rails (`IssueGas`=token-issue, `IssueKda`=**"dpmf"**, `UpgradeBranding`=blue).
      Formalized 2 pre-existing mis-prefixed cost helpers `UC_→URCi_WipeCumulator`/`URCi_MoveCumulator`
      (+ aux `UCX_→URCix_NoncesCumulator`). All 17 new proven == prior; `Z.repl` green.
      (**DPMF (00) skipped** — legacy MetaFungible, migration-only.) **Next: ELITE(07, no cost) → ATS (08).**
- [x] ✅ **ATS (08) — DONE (2026-08-30). 22 URCi (commit `5ed0c17`).** 16 single-tier (Branding×5, UR_OwnerKonto)
      + 2 construct-price (`AddSecondary` token-issue [reused for `AddHotRBT` ico0] · `SetColdRecoveryFees`
      biggest×20) + `ToggleParameterLock` (pre-increment) + Issue gas/kda + UpgradeBranding. HOT-RBT
      branding/Repurpose forward DPOF costs. All 22 proven; `Z.repl` green.
- [x] ✅ **TFT (09) — DONE (2026-08-30). Family rename UDC_→URCi_ (commit `7c02291`).** TFT's cost is a
      transfer-cumulator family (`UDC_*Transfer/Transmute/BulkTransferCumulator`, reads UsagePrice → genuine
      cost readers). Renamed the 14-fn family **cross-module** (90 sites, 7 files incl. Stage-2
      INFO-ONE/INFO-TWO/AQP-INFO/DPDC-T + SWPL/MTX-SWP). C_ entrypoints already return them → single-sourced.
      Pure rename, `Z.repl` green (exercises transfers + all callers).
- [ ] ❌ **Remaining Stage-1 cost modules (triaged 2026-08-30) — NEXT SESSION.** **No cost (skip):** SWPT(14),
      CODEX(22), PYTHIA(23). **Have cost:** ATSU(10, ~67 returns/20 ctor — big) · VST(11, ~75/21 — big) ·
      LIQUID(12, ~12/4 — small) · OUROBOROS(13, ~12/7 — small) · SWP(15, ~26/14) · SWPI(16, ~11/2 — small) ·
      SWPL(17, ~11/11; 3 URCi already from TFT rename) · SWPLC(18, ~39/8) · SWPU(19, ~26/7) · MTX-SWP(20,
      ~13/12; 1 URCi already). The SWP family (15–20) is the most intricate (swap-math cumulators) — do with
      fresh context. Pattern & tooling proven across all cost shapes; each is index→build→prove→commit like above.
- [ ] ❌ **1.1.2.1** Walk modules **in deploy order, Stage-1 module #1 first**. Per module: extract each
      cost-emitting `XE_`/`XI_`'s cumulator into a **leaf `URCi_*`** the leaf returns; add a
      **composer `URCi_*`** per `C_`/`CC_`/`A_`. Token modules (TFT/DPOF/DPDC-T) already have
      cost ctors → formalize as `URCi`. **Any `URCi_*` called CROSS-MODULE gets an interface declaration
      in the same edit** (modref resolution is dynamic — undeclared works but loses load-time safety; see
      `memories/2026-08-29-modref-interface-semantics.md`). Internal-only leaves stay out.
- [ ] ❌ **1.1.2.2** Keep a running line-count check per module (rule B) as `URCi`s are added.

#### 1.1.3 · Subphase — Carried-over StoicSyntax renames (do during the walk)
- [ ] ❌ **1.1.3.1 StoicSyntax renames carried over from audits:**
      **DPDC #40L** — `Wipe*` family (Heavy/Pure/Clean/Dirty) rename/rethink; **ATS #31L** — Talos
      `C_SetHotRecoveryFee` (singular) vs core `C_SetHotRecoveryFees` (plural), rename (no interface
      bump needed, pre-mainnet); **SWP** — `KDA-PID`→`STOA-PID` (L58), `URC_Swap`/`URC_InverseSwap`→
      `URCv_Swap`/`URCv_InverseSwap` (L64), `UC_ComputeInverseY`→`v`-specialization, and rename the
      existing `AHU`/`AUP_*` instances to the new `AU_` prefix (the audit added `AU_` to StoicSyntax).
      **DALOS** — a repeated shape flagged for a dedicated sweep (Audit/DALOS README "Downstream plan" phase 3b).

#### 1.1.4 · Subphase — Citizen tree alignment  ✅ DONE (2026-08-30)
- [x] ✅ **1.1.4.1 Adopt `2_CITIZEN` as the citizen extension tree (terminology alignment with the website).**
      Ouronet's site names the two module classes **Sovereign** (canonical core) and **Citizen** (built by
      anyone, on top of sovereign public APIs — never adds core capabilities). Done as part of the DEMIPAD
      audit #15L restructure: folder renamed + reorganised into numbered citizen folders, the launchpad
      sales relocated to `2_CITIZEN/6_Launchpad/`, and the legacy terminology retired codebase-wide (word +
      `2_CITIZEN` path token across all `.md`/`.repl`/`.pact` + the `CITIZEN_AND_SAMPLES.md` doc rename).
      `Z.repl` green, 0 load failures. (task #88)

---

### 1.2 · Phase — INFO rehaul: COMPLETE coverage + consolidate (not just AQP)  ❌
The INFO rehaul is **total** — every client/admin entrypoint across the WHOLE codebase gets an INFO
preview via its composer `URCi`. Many are currently missing (only INFO-ONE/INFO-TWO/AQP-INFO exist,
and partially). This phase both *simplifies* the existing INFO and *completes* the missing ones.

#### 1.2.1 · Subphase — Simplify & complete coverage
- [ ] ❌ **1.2.1.1** Gut each existing `INFO_*` body to a thin **composer-`URCi` call + `ClientInfo` text**
      (keep names/return shape so the UI is untouched).
- [ ] ❌ **1.2.1.2** Build the **7 AQP vacate/drain/FullVacate INFO** as `URCi_Vacate*` callers (cost map:
      `memories/2026-08-27-aqp-info-final17-costmap.md`). Completes the AQP "final 17".
- [ ] ❌ **1.2.1.3 COMPLETE the missing INFO across every module/stage.** Inventory every
      `C_`/`CC_`/`A_`/`AA_` client/admin entrypoint (Stage 1 + Stage 2, all modules) and build an INFO
      preview for each that lacks one — thin composer-`URCi` callers. This is the bulk of the rehaul:
      a ton of INFO functions are currently missing. Track coverage in a checklist (mirror the
      `aqp-entrypoint-surface.md` catalog approach, extended repo-wide).

#### 1.2.2 · Subphase — Consolidate & relocate
- [ ] ❌ **1.2.2.1 Consolidate to one INFO module per stage** and **relocate to a new
      `1_SOVEREIGN/STAGE_0N/Z_Reads/` slot (after `3_Talos`), deployed LAST** — read-only presentation
      layer, leaf (nothing refs it); `Z_` sorts absolutely last regardless of future numbered layers,
      mirroring citizen `Stage_Z` (`DPL-UR`/`EXPLORER`). Move out of `2_Core` (`INFO-ONE`/`AQP-INFO`);
      delete reconstruction bodies; confirm `INFO-ONE` shrinks materially.
- [ ] ❌ **1.2.2.2 Refactor load order:** update the REPL pipeline (`Z.repl`, `Stage01/02_Tester.repl`,
      the `[x]` loaders) **and** the on-chain deploy sequence to load each stage's `Z_Reads/` modules
      last in that stage.

#### 1.2.3 · Subphase — Write-tier / read-layer fixes carried over from audits
- [ ] ❌ **1.2.3.1 DPDC #43L** — a write-tier fn returns a display string instead of ending on a write;
      move the "what it did/costs" display into the INFO/read layer (`XI_`/`XB_` end on write, no return).
      Add more as SWP/DPTF-DPOF land.

---

### 1.3 · Phase — Re-price IGNIS  ❌
Point A; spec: `memories/2026-08-27-ignis-cost-rethink.md`; task #76.

#### 1.3.1 · Subphase — Measure, re-price, surcharge
- [ ] ❌ **1.3.1.1 Measurement pass:** instrument real STOA gas per client op by run-shape (build on
      the ground-truth harness). Re-price against data, not guesses.
- [ ] ❌ **1.3.1.2 Value re-price** via the `UsagePrice` tiers (auto-tracks exec + info).
- [ ] ❌ **1.3.1.3 Heavy-read surcharge:** make `URH_/URHC_/URD_` readers emit a cost cumulator scaled
      to rows scanned (localized at the transitive-heavy functions the naming already flags).
- [ ] ❌ **1.3.1.4** Edits land on `URCi`/UsagePrice only → exec and info move together (verify via `1.5.1.1` gate).

---

### 1.4 · Phase — AQP module splits  ❌
Point B; spec: `MODULE-SIZING.md`; task #75.

#### 1.4.1 · Subphase — Split & re-measure
- [ ] ❌ **1.4.1.1 Split `04_FVT.pact`** (6,694 lines — OVER the ~6,635 ceiling; undeployable as-is)
      along a **capability seam** (candidate: config surface vs reward-runtime surface). NOT by line
      count. Get the table→module assignment right the first time (permanent).
- [ ] ❌ **1.4.1.2** Re-audit `POOL/SCORE/ANK/VCT` (and any Stage-1) line counts once their `URCi`s are in;
      split any in Warning/Danger band along capability seams.
- [ ] ❌ **1.4.1.3** Update `MODULE-SIZING.md` applicability table with post-`URCi` measurements.

---

### 1.5 · Phase — REPL finalization + CI harden (test EVERYTHING in one run)  ❌
The audits kept surfacing functions with **zero REPL coverage** (e.g. ATS `#22L` found 12 untested
config fns — and two real bugs hid there precisely because nothing called them). Those were deferred
to main. This phase closes the coverage gap repo-wide AND lands the single-comprehensive-run refactor.

#### 1.5.1 · Subphase — Coverage completion + CI gate
- [ ] ❌ **1.5.1.1 CI-gate the ground-truth harness**: exec `ignis-need` == real IGNIS/GAS delta. The
      exec↔info drift lock that lets Option A skip a rehaul. Extend it to cover **every** INFO function
      (all of Phase 1.2's completed coverage), not just the 3 currently proven.
- [ ] ❌ **1.5.1.2 REPL coverage completion (repo-wide).** Inventory every `C_`/`CC_`/`A_`/`AA_` across
      Stage 1 + Stage 2 with a grep-based coverage audit (the audits each flagged gaps — fold their
      lists in, e.g. ATS `#22L`, `[6.6]_ATS.repl`). Write canonical REPL suites for every untested
      entrypoint, in the required layout (`REPL_AND_TESTS.md`). Untested code ships bugs — this is
      correctness, not polish. **Carried-over coverage gaps to fold in:** ATS `#22L` (12 config
      `C_`/`A_` fns; wire `[6.6]_ATS.repl` past the #12a dup-MVST block), DPDC `#41L/#42L` (branding +
      ownership-gate); DALOS **H16** + PYTHIA `#49M` (flush-gas-probe broken batch sizes) + other DALOS ROUND-02 coverage gaps.
- [ ] ❌ **1.5.1.3 Single comprehensive run — the whole codebase, one boot.** Generalize `AQP-FULL.repl`
      from AQP to **everything**: one hermetic run that boots once and exercises ALL Pact code (Stage 1
      + Stage 2 + citizens + `Z_Reads` INFO). Requires the hermetic fixture isolation from the AQP
      unified-test work (tasks #71/#72/#73: disjoint fixtures per destructive scenario + delta-based
      pre-state; fold info/stream/DSA inline bodies). Spec: `memories/2026-08-27-aqp-full-unified-test.md`.
      End state: **one command tests the entire system top-to-bottom.**

---

### 1.6 · Phase — Red team attack + Audit Book (BEFORE redeploy)  ❌
Tasks #81, #82. With the code in its **final shape**, just before redeploy: a comprehensive **multi-agent
red-team attack on ALL modules** to expose vulnerabilities. Its findings + fixes become Part III of the book.

#### 1.6.1 · Subphase — Red team attack (all modules)
- [ ] ❌ **1.6.1.1 Red team attack (all modules).** Multi-agent adversarial security audit: fan out
      attackers per module / attack-surface — capability & auth bypass (module-boundary guard,
      composed caps), arithmetic/rounding/precision, economic & MEV (front-run, sandwich, ratio
      extremes), ordering/reentrancy-like, cross-module boundary abuse, defpact/Hydra-slice races,
      gas-station exploitation, sentinel/collision. Synthesize + **adversarially verify** each
      candidate finding against code (CONFIRMED/REFUTED), fix, re-test. Same rigor as the initial
      audits, adversarial framing.
- [ ] ❌ **1.6.1.2 Carried-over leads for the red team** (audits explicitly filed these for main's red-team pass):
      **SWP `#32bM`** (M11/M12 reachability — MTX-SWP fee-before-gate ordering / no-TTL rollback; verdicts
      unchanged, re-examine now that TS01-CP wiring is known-reachable); **SWP `URC_OuroPrimordialPrice`**
      (16_SWPI.pact — likely the same weight-omission bug fixed on the WSTOA side #73C; unconfirmed,
      15-min trace + live check); **SWP Round III re-verify** (systematic re-check of every closed SWP
      finding — the adversarial pass subsumes it). Fold DPTF-DPOF leads in at merge.

#### 1.6.2 · Subphase — Assemble the Audit Book
- [ ] ❌ **1.6.2.1 Assemble the Audit Book** (expected hundreds of pages) — spec: `AUDIT-BOOK.md`:
      - **Part I** — initial module audits (ATS, SWP, DPDC, DPTF-DPOF, AQP) — the `…/Audit/*` trees.
      - **Part II** — the whole main-work round (Phases 1.1–1.5): every URCi/INFO/re-price/split/REPL
        modification + fix, documented audit-style. **Document main-work AS IT LANDS — it IS Part II.**
      - **Part III** — the red-team attack audit (1.6.1): vulnerabilities sought, found, fixed.
      One consolidated, publishable book telling the whole story end to end.

---

### 1.7 · Phase — Interface version bump + cascade + deploy-ready gate + redeploy  ❌ 🔒 1.0–1.6
Tasks #83, #85. Almost EVERY interface will carry new code by now (audits + URCi + INFO + re-price +
splits + red-team fixes), so each changed interface must become its **next version**. Do this ONCE, here,
after all code is final — never repeatedly. Spec: `ARCHITECTURE/INTERFACE_VERSIONING.md`.
NB (upgrade semantics, tested — `memories/2026-08-29-modref-live-dispatch-*`): `::` modref dispatch is
LIVE — an in-place sovereign upgrade reaches ALL `::` callers with no `bless` (this is why the repo has
never needed it). So this redeploy is bless-free for `::`-using sovereign code; the ONLY hash-pin
exposure is a `2_CITIZEN/` third-party calling sovereign via `.` (a deliberate integrator version-pin) —
if we upgrade a core they `.`-reference in place, we'd have to `bless` their old hash for them.

#### 1.7.1 · Subphase — Version bump + cascade refactor
- [ ] ❌ **1.7.1.1 Interface version bump.** For every interface whose code changed, bump its suffix to
      **live + 1** using the Phase-1.0.3.1 live→target map (`V1`→`V2`, or `V2`→`V3` where local already moved).
- [ ] ❌ **1.7.1.2 Cascade refactor (BIG — whole codebase; task #85).** Per the cascade rule: every interface
      that names a bumped one (`module{B}` / `object{B.Schema}`) must itself bump, and EVERY consumer
      updates its `ref-`/`implements` to the new version, **in lockstep**. Interfaces are pervasive, so
      this touches most of the codebase — a distinct large refactor. (NB the cascade is triggered by
      interface CHANGES — added members + interface-owned schema/type refs — NOT by every function; a
      modref call resolves dynamically. Policy: declare per cross-module fn, bump per interface, ONCE
      here. See `memories/2026-08-29-modref-interface-semantics.md`.) Mechanical (rename + rewire), so it
      lands after the red team (logic is final); do it, then re-gate.

#### 1.7.2 · Subphase — Deploy-ready gate + fresh redeploy
- [ ] ❌ **1.7.2.1 Deploy-ready gate:** whole-codebase single run (1.5.1.3) green + all audits closed + book
      assembled + every module within the deploy ceiling (rule B; FVT split done) + version bump green.
- [ ] ❌ **1.7.2.2 Fresh top-to-bottom redeploy** of Stage 1 + Stage 2 (+ citizens). This finalized
      entrypoint set is the shape the UI enumerates.

---

## 2 · CHAPTER — CAPSTONES
The two major deliverables that hang off Chapter 1's frozen, redeployed shape: the **UI** (Phase 2.8) and
the **Documentation + Audit Book** (Phase 2.9). Both are hard-blocked until the code is final — every prior
piecemeal attempt failed because new code kept arriving.

---

### 2.8 · Phase — UI incorporation (CAPSTONE)  ❌ 🔒 Ch.1
Workstream #2; spec: `UI-INCORPORATION-PLAN.md`; task #80. A **document of incorporation** an AI agent
(OuronetUI) follows to implement the ENTIRE Ouronet functionality onto the web UI — an **intelligent UX
blueprint**, NOT a brain-dead button listing (see the plan doc).

**Why Chapter 1 enables this:** the completed INFO surface + entrypoint catalog is ~80% of the *substrate*
(button = client fn; preview = INFO; metrics = readers; form = wrapper sig). Subphase 1.2.1.3 is the bridge.
But `2.8.1.3` is where **intelligence** turns that substrate into the best possible UX. Manual build:
10-20 yrs solo / 2-4 yrs human+AI; scoped to an agent following an intelligent plan: **weeks**.

#### 2.8.1 · Subphase — Substrate & study
- [ ] ❌ **2.8.1.1 Hard dependency:** Phases 1.0–1.7 done (final shape redeployed).
- [ ] ❌ **2.8.1.2** Extend the **repo-wide entrypoint-surface catalog** (from 1.2.1.3) into UI input: per
      entrypoint → role + asset-type + domain + INFO fn + readers + input form. The machine-readable
      substrate (every action, its cost, its state) — the *raw material*, not the design.
- [ ] ❌ **2.8.1.3 Study the existing "pantheonic architecture."** The UI is NOT greenfield — it recently
      migrated to the owner's pantheonic architecture + has real partial implementation. Learn its
      conventions + what's already built from the current OuronetUI codebase; the derived design
      **grafts onto it**, extending its patterns — not a parallel structure.

#### 2.8.2 · Subphase — Desktop (Stage 8A)
- [ ] ❌ **2.8.2.1 Write the incorporation document as an INTELLIGENT architecture** grafted onto the
      pantheonic patterns: role-based control panels, role-grant-driven (permission-aware) surfaces,
      workflow/journey flows — grouped by user intent, not mechanical fn→button. The examples in the plan
      doc are ILLUSTRATIONS of caliber, not a spec — derive the full structure from the code. Miss nothing
      built. Then hand to the OuronetUI agent to implement.

#### 2.8.3 · Subphase — Mobile (Stage 8B)
- [ ] ❌ **2.8.3.1 Lossless mobile translation.** Bring the entire desktop implementation into a
      mobile-friendly format — everything visible/doable on desktop translated **without loss** to the
      smallest screen. Driven by the existing OuronetUI dashboard's **custom responsive port** as the
      blueprint. A colossal effort in its own right; a distinct stage, not an afterthought. (task #84)

---

### 2.9 · Phase — Comprehensive Documentation + website publication (CAPSTONE)  ❌ 🔒 1.7
Spec: `DOCUMENTATION-PLAN.md`; task #86. A FULL written documentation of everything the code does — every
module, function, shape, purpose; why it's complex; why it costs so much; advantages vs industry standards;
what a user can achieve — so a brand-new reader understands what Ouronet is. Published with the Audit Book
in the site's **Documentation + Audit region**. Can run in parallel with Phase 2.8 (both need the final shape).

#### 2.9.1 · Subphase — Write & publish
- [ ] ❌ **2.9.1.1 Hard dependency:** Phase 1.7 done (final shape redeployed) — every prior piecemeal attempt
      failed because new code kept arriving; this only works on the settled shape.
- [ ] ❌ **2.9.1.2 Observe the existing website** at `d:\_Claude\OuroborosNetwork\websites\ouronetwork-website\`
      to see first-hand how incomplete the current docs are vs. what's required. Do NOT trust them.
- [ ] ❌ **2.9.1.3 Write the comprehensive documentation** — walk the final codebase module-by-module
      (purpose, schemas/tables, every function's role/how/why), grouped for a reader; the 7 asset
      types + what users achieve; the cost story (from INFO/`URCi`); advantages vs industry standards;
      and a first-class **StoicSyntax methodology** chapter (how the prefix discipline made the code
      semi-self-auditing — "half-audited code"). Cross-ref the entrypoint catalog so nothing is missed.
- [ ] ❌ **2.9.1.4 Publish** the documentation + the Audit Book into the site's Documentation + Audit region.

---

## 3 · CHAPTER — STAGE 3 · FUTURE (after this entire plan ships)
Beyond the scope of this roadmap (which finalizes + deploys Stage 1 + 2 and builds the UI/docs).
Stage 3 is the next development stage, taken up **after everything in Chapters 1–2 is done**. Each is a new
sovereign feature-set built on the finalized Stage-1/2 primitives; they'll get their own plans when Stage 3
begins. Captured here so the horizon isn't lost.

### 3.1 · Phase — Owner-named Stage-3 scope
#### 3.1.1 · Subphase — Feature backlog
- [ ] ❌ **3.1.1.1 Heir System** — proactive heir designation + dead-man's inactivity switch (the D2
      deferral; detail in `01_DPDC/Audit/HEIR-SYSTEM-PONDERING.md`; consider DALOS-account-layer + guard-based).
- [ ] ❌ **3.1.1.2 NFT Marketplace** — trade collectables (DPSF/DPNF) on Ouronet.
- [ ] ❌ **3.1.1.3 Order-based exchange** — an order-book DEX (complements the AMM SWP pools).
- [ ] ❌ **3.1.1.4 Lending Platform** — borrow/lend against Ouronet assets.
- [ ] ❌ **3.1.1.5 Launchpad direct-injection (royalty → AQP profile)** — DEMIPAD audit #8M follow-up. Build
      the real `direct-injection` deposit path: route the `cod` (royalty) portion of each buy into an
      *injection profile* rather than local residents. Owner design: a profile is a split, not one vault —
      e.g. 100 `cod` → 50% Demiurgos Holdings (shareholders vault) + 50% Coding-Division **score** (1 pt/node,
      no set bonus, single treasury); both targets are Deb-free so injection is simple. Two viable modes:
      (a) **live** inject with each user contribution, or (b) keep collecting `cod` locally and have a
      **daily automaton drip-inject** it once/day (preferred given inject cost). `rem` (seller proceeds)
      always transfers in + credits regardless. Build sequence: finalize+redeploy rehaul → deploy the
      profile vaults → rewrite `C_Deposit` to a forward-module/profile inject + re-enable the seller credit →
      redeploy. Until then the feature is **hard-blocked** (`UEV_DirectInjection`), `UR_DirectInjection`
      state reserved. Non-direct mode + the automaton already delivers full functionality.

---

## 4 · CHAPTER — REFERENCE (non-sequential)
Standing material the phases draw on: settled pre-phase decisions, the deferred items each merged audit
brought, protocol invariants, and the task-map. Not a work sequence — a lookup.

---

### 4.1 · Phase — Pre-phase decisions (settled)
Surfaced from the audit-folder scan, resolved, their outcome already folded into the phases.

#### 4.1.1 · Subphase — Settled decisions
- [x] ✅ **4.1.1.1 D1 — AQP LP-scoring dual split-mode — SETTLED + BUILT + GREEN (task #89, 2026-08-30).** Two
      per-pool reward-split modes, a **freely-mutable per-farm flag** (default `SPLIT|STAKED`), differing
      only in the Level-2 weight `W_i`:
    - **`SPLIT|STAKED`** (default, *participation*): `W_i` = the pool's total **staked value** — every
      staked STOA-unit earns equally, pool size irrelevant.
    - **`SPLIT|TVL`** (*pool-size*, Vesta/MultiversX model): `W_i` = the swpair **TVL** (`SWP::UR_StoaValue`) —
      bigger pools capture bigger slices.
    - Built in `04_FVT.pact` (`URC_MemberLevel2Weight` routes all 3 W_i sites, `C_SetSplitMode`/cap/XI/WU/GAS
      + Talos + INFO); non-farms get the `"|"` (`CT_SPLIT_MODE_NA`) sentinel; switching only affects future
      injects (RPS checkpoint-based). Proven: `[6.2.11]_AQP-SPLIT-MODE.repl` + economic-flip in `[6.2.9]`
      (W_i 0 vs 7920.17 on the real `OuroLpFarm`). Commits `78553c9`, `1f3e3ed`. Also fixed the §6.2
      negative-score bug (LP L1 = `lp-amount × mx`, nets to 0 on full unstake). Cleanup leftover → Phase 1.1:
      retire the dead `URC_LpAmountToLpDenominatorEquivalent`.
- [x] ✅ **4.1.1.2 D2 — Heir System — DEFERRED to Stage 3** (owner 2026-08-29). A proactive heir designation +
      dead-man's inactivity switch (trust from "admin fairness" → "owner's advance designation + on-chain
      inactivity timer") — a new feature-set, not part of this plan. Full detail in Chapter 3 (§3.1.1.1)
      + `01_DPDC/Audit/HEIR-SYSTEM-PONDERING.md`.

---

### 4.2 · Phase — Audit carry-over (deferred items each merged audit brings)
**Standing rule:** every audit worktree carries its OWN deferred list (open owner-decisions, test gaps,
doc debt, live-diffs) in its `…/Audit/<MODULE>/` folder. **When an audit merges to main, fold its deferred
list into this section.** SWP / DPDC / DPTF-DPOF each added a block here at merge (their `ISSUES-RANKED.md`
/ `ROUND-02-FIXES.md` are the source).

#### 4.2.1 · Subphase — ATS audit carry-over
Source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/` (MERGED to main). Verified on main: the two live fixes
landed — `P|A_Define` IMP registration (`3_Talos/01_TS01-A.pact:165-166`) and `C_HOT-RBT|Repurpose`
`UR_NonceMetaData` arity fix (`08_ATS.pact:1919`). Remaining:
- [ ] ❌ **Open owner-decisions (don't close without asking):**
      - `#26L` — `C_KickStart` `rt-amounts` trusted by position, no name-match vs pool's reward list. Guard now vs defer to module rehaul?
      - `#28L` — dead StoicTag fns in `09_U_ATS.pact` (`UC_IzStoicTagIndex*`/`UEV_StoicTagIndex`) — verified dead; confirm deletion.
      - `#31L` — Talos `C_SetHotRecoveryFee` (singular) vs core `C_SetHotRecoveryFees` (plural); rename needs no interface bump — approve rename? (→ 1.1.3.1)
      - The `can-change-owner` / `syphoning` / `hibernate` + 3 recovery on/off switches — still-open findings, not ruled on.
- [ ] ❌ **`#22L` test wiring:** `[6.6]_ATS.repl` exists (ported, 159 KB) but is **commented out** of
      `Stage01_Tester.repl` (dup-MVST collision with the AQP Stage-2 path, #12a). Resolve so ATS
      config coverage actually runs in the gate (standalone ATS suite, or deconflict the MVST re-issue).
      Then update ATS `README.md` `#22L` status → FIXED. (→ 1.5.1.2)
- [ ] ❌ **New structural finding `P|A_Define`** — fixed live but **not yet logged** as its own numbered
      finding / documented in the 4 ATS audit docs. Owner: log as `#33N`-style? Then write up.
- [ ] ❌ **Scratch cleanup:** remove `REPL/_cov_draft.repl`, `_baseline_66_check.repl` (+ `_iso_check`,
      `_probe2/3` if present) — throwaway, must not ship.
- [ ] ❌ **Live-vs-local diff:** `U_ATS` + `U_DPTF` not yet diffed against live (Pythia keyless recipe in
      `OuronetInformational/pythia-dirty-read-access.md`). ATS/ATSU already diffed (live behind local on V1).
- [ ] ❌ **Final consolidated ATS audit write-up** (owner-requested) — after `#22L`/`#26L`/`#28L`/`#31L` +
      `P|A_Define` are all closed.

#### 4.2.2 · Subphase — DPDC audit carry-over
Source: `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/Audit/` (MERGED to main, `7efe386`). All 11 DPDC modules, 58
tracked items ALL closed (35 fixed+live-verified, 13 refuted, 4 already-closed, 2 no-bug, 4 deferred). 3 new
canonical REPL suites wired in (`[6.1.1]_EQUITY`, `[6.1.2]_DPDC-FRAGMENTS`, `[6.1.3]_DPDC-S`). Interface
changes pre-mainnet, no bump. Signatures my AQP-INFO calls (`UDC_MultiTransferCumulator`,
`UR_AccountNoncesSupplies`, `URD_AccountNonces`) verified intact. Remaining (4 deferred LOW):
- [ ] ❌ **#40L** — `Wipe*` family (Heavy/Pure/Clean/Dirty) rename/rethink → a **StoicSyntax pass**
      (fold into the 1.1.2 module-by-module walk, or a standalone StoicSyntax cleanup).
- [ ] ❌ **#41L/#42L** — branding + ownership-gate **test-coverage gaps** → **1.5.1.2** (repo-wide REPL
      coverage completion).
- [ ] ❌ **#43L** — a write-tier fn returns a display string instead of ending on a write → **1.2.3.1**
      (INFO/URCi rearchitecture — the `XI_`/`XB_` "end on write, no return" rule; the display belongs
      in the INFO/read layer).
- [ ] ❌ FYI (non-blocking): an AQP-side investigation (does the DPDC-S score-multiplier apply at staking
      time?) was handed off and is pending independently. The DPTF/DPOF "no-ownership-check DeployAccount"
      shape was confirmed to exist there too → fold into the DPTF-DPOF audit at merge.
- [ ] ❌ Optional cleanup: the `REPL/Kursan/_verify_finding_*` scratch files came in with the merge
      (audit evidence) — keep or prune per owner.

#### 4.2.3 · Subphase — SWP audit carry-over
Source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/` (MERGED to main, `cc230d5`). Full SWP family
(SWP/SWPI/SWPT/SWPL/SWPLC/SWPU/MTX-SWP + U|SWP). ALL closed: 13 CRIT, 12 HIGH, 14 MED, 32 LOW + the `#65bL`
gas master-issue (worst-case now under the 2M ceiling, ~74% cold-cache reduction). Big structural fixes:
SwapTracer `V1→V2` (H3 principal-orphan redesign), ClientThree/ClientPacts `→V2` (M14), `SwapperV3` gained
`URC_ActiveSwpairs`, DWK/DLK→WSTOA/SSTOA rename (#65gL). The audit **introduced the `AU_` (Admin Update)
prefix** — already merged into `StoicSyntax-Prefixes.md`. Signatures Stage-2 (DSA `A_Fuel(swpair)`) calls
into SWP verified intact (11/11 resolve). Deferred:
- [ ] ❌ **StoicSyntax naming sweep → 1.1.3.1:** `URC_Swap`/`URC_InverseSwap`
      →`URCv_Swap`/`URCv_InverseSwap` (L64), `UC_ComputeInverseY`→`v`-specialization, and rename the
      existing `AHU`/`AUP_*` instances to the new `AU_` prefix.
- [ ] ❌ **Kadena → STOA rename (codebase-wide) → 1.1.3.1:** owner (2026-08-29): *"there is no Kadena
      anymore, there is STOA — remove all Kadena naming and move to STOA."* Everything was priced/named
      in KDA pre-migration; the payment token is now STOA (wrapped-STOA), and the `KDA-PID` oracle is
      already the STOA price **hardcoded at $0.10** (pending the future **Aletheia Oracle** for real STOA
      pricing) — so this is a **pure naming rename, zero logic change**. Scope (~1,097 `kda`/`kadena`
      refs in `1_SOVEREIGN`; the SWP L58 count was 308 `KDA-PID` across 17 files incl. the whole DemiPad
      family): `KDA-PID`→`STOA-PID`, local `kda-pid`/`wkda-id`/`wkda-prec`→`stoa-pid`/`wstoa-id`/`wstoa-prec`,
      the `WKDA`/`LKDA` labels + type discriminators, and all "Native KDA / WKDA" comments/@doc.
      **Owner-established sequencing: ONE dedicated protocol-wide pass AFTER all audits — never piecemeal
      mid-audit** (so the DEMIPAD audit fixes #3H/#4H/etc leave the KDA naming untouched; it's swept here).
- [ ] ❌ **`#32bM` → 1.6.1.2 (red team):** M11/M12 reachability correction (MTX-SWP fee-before-gate
      ordering, no-TTL rollback) — verdicts left as-is; owner filed it explicitly for main's red-team pass.
- [ ] ❌ **Round III re-verify → 1.6.1.2:** systematic re-check of every closed finding (owner: this
      branch's job was the initial fix; re-verify is main's — the adversarial red-team pass covers it).
- [ ] ❌ **⚠ `URC_OuroPrimordialPrice` lead → 1.6.1.2 (15-min trace):** `16_SWPI.pact` dollar-denominated
      math *likely* carries the same weight-omission bug just fixed on the WSTOA side (#73C) — NOT
      confirmed, shares the exact math shape. Worth a trace + live check before the red team assumes it's fine.
- [ ] ❌ **Interface versions (informs 1.0.3.1/1.7):** SWP is on `SwapperV3` / `SwapTracerV2` /
      `ClientThreeV2` / `ClientPactsV2` → live-version map inputs; a `SwapperV3`→`V4` bump was left as a
      separate decision (ROUND-02-FIXES.md).
- [ ] ❌ Optional (unscheduled): router direct-pair fast-path — `URC_HopperActive` builds the full graph
      even when a direct A→B pool exists (Kaddex short-circuits); pure gas optimization, not a bug.
- [ ] ❌ Moot: live-vs-local Pythia diff — ruled moot by owner (full redeploy planned anyway).

#### 4.2.4 · Subphase — DALOS / "rest of Stage 1" audit carry-over
Source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/` (the `dptf-dpof` worktree; MERGED, `07556e1`). Broad
audit of **everything in Stage 1 not claimed by ATS/SWP** — DALOS, DPTF/DPOF/TFT, IGNIS, ELITE, DPMF,
utilities (U_CT/LST/INT/DEC/DALOS/VST), OUROBOROS, CODEX/PYTHIA, TS01 Talos, + the interface cascade. All
CRIT/HIGH/MED/LOW closed (fixed/refuted/finalized) except the deferrals below. Added
`DPTF|A_DeployAccount` / `DPOF|A_DeployAccount` admin variants (no ownership check on `<account>`, for
system-account deploys). Seam (TFT/DPOF/DPTF/IGNIS signatures my AQP-INFO calls) verified intact. Deferrals:
- [ ] ❌ **⚠ REVIEW: TS02-DPAD DeployAccount reconciliation** — the merge combined *two* audits' fixes
      (dptf-dpof `#N2` admin-variant for tf/of + DPDC `#35M` direct-`XB` for sf/nf). Correct by my
      analysis (alternatives unbound / wrong-ownership) but it's a judgment merge — worth an owner glance.
- [ ] ❌ **H11 → 1.2 (INFO):** deferred to the main-branch INFO-function project. **The audit
      independently scoped OUR Phase 1.2** (its README "INFO-function coverage project" downstream phase +
      `memories/2026-08-24-info-functions-are-ui-facing-not-dead-code.md`) — strong validation of task #78.
- [ ] ❌ **H16 + REPL-coverage gaps → 1.5.1.2:** deferred to the main-branch REPL test-infra phase
      (e.g. PYTHIA `#49M` flush-gas-probe broken batch sizes; other coverage gaps flagged in ROUND-02).
- [ ] ❌ **H17 → 1.7 (redeploy):** finalized as a status note, folded into the redeploy phase.
- [ ] ❌ **Pattern sweep → 1.1:** a repeated shape flagged for a dedicated main-branch sweep
      (README "Downstream plan" phase 3b) rather than piecemeal fixes.
- [ ] ❌ Note: oracle (Aletheia) wiring explicitly deferred until an oracle is available (future feature;
      ties to SWP's `KDA-PID`→`STOA-PID`). DALOS-family interfaces are pre-mainnet V1/V7, edited freely
      (no bump) — informs the 1.0.3.1/1.7 version map (ATS/SWP interface versions were out of this audit's scope).

#### 4.2.5 · Subphase — DEMIPAD audit carry-over
Source: `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/Audit/` (DONE on main 2026-08-30).
- [ ] ❌ **STOAICO folder placement (open sub-decision).** Placed under `2_CITIZEN/6_Launchpad/5_StoicIco/`
      (staking-ICO alongside the KPAY sale). Confirm that vs a standalone citizen folder — owner call.
- [ ] ❌ **AOZ+/DSP+ + DPL-UR/EXPLORER naming.** Kept in `2_CITIZEN/Stage_01/` + `Stage_Z/` (outside the
      numbered `N_XMinter` scheme). Rename into the scheme later if wanted (cosmetic).
- [ ] ❌ **AQP-royalty direct-injection (#8M follow-up) — POST-AQP feature.** `direct-injection` is
      hard-blocked (`UEV_DirectInjection`) until built: route the `cod` royalty into an AQP injection
      **profile** (owner design: 50% Demiurgos Holdings / 50% Coding-Division score, both Deb-free) —
      **live inject** OR **collect-locally + daily-automaton drip**. Needs finalized redeploy → deploy the
      profile vaults → rewrite `C_Deposit` to a forward-module/profile inject. Logged in Chapter 3 (§3.1.1.5).
- [ ] ❌ **#11M deploy-gate re-sync (verify at redeploy).** Workspace `04_STOICPAY` now byte-matches the live
      5-address / 1.5× team split (40/60); StoicPay **sale is suspended** — whether/how to resume is a
      separate product decision. At the deploy-ready gate (1.7.2.1 / task #83) re-confirm the split.
- [ ] ❌ **#12M slippage follow-ups (INFO pass, 1.2).** Optional `…WithSlippage`/`…NoSlippage` named
      Talos sugar (the single `max-cost` value already selects the variant); INFO functions returning the
      **per-leg** cost breakdown so the UI can pad each `coin.TRANSFER` cap → task #78.
- [ ] ❌ **#1C STOAICO wiring (1.5 / task #79).** `[6.3]_STOAICO.repl` not yet in the default `Z.repl`
      pipeline; STOAICO INFO surface (`INFO_FlushFull`/`Slice`) deferred to the INFO pass (task #78).
- [ ] ❌ **#2H/#7M transmit path.** The collectable transmit functions are `UEV_IMC`-gated + marked "after
      Upgrade"; the `RETRIEVE-NON-FUNGIBLE` gate is correct once the NF transmit is Talos-wired (#7M fix
      routes NF→NON cap). Finalize with the transmit Talos wiring.
- [ ] ❌ **KDA→STOA naming.** DEMIPAD/StoicPay carry `kda-pid`/`wkda` naming too — part of the settled
      protocol-wide `Kadena→STOA` sweep (1.1.3.1), never piecemeal.

---

### 4.3 · Phase — Standing invariants + task map

#### 4.3.1 · Subphase — Standing invariants
- REPL testing uses **pact 5.4.1** (`~/.local/bin/pact`; old = `pact-5.4`). Never test on 5.4.
- Commit granularity per phase; never `git add -A` (stage explicit paths).
- FVT-over-ceiling (1.4.1.1) is a **hard gate before any mainnet deploy** — cannot ship/upgrade FVT until split.

#### 4.3.2 · Subphase — Quick task map (task # → address)
- #87 DEMIPAD audit → **1.0.4.1**. #88 Slave→Citizen rename → **1.1.4.1**. #21 SWP · #23 ATS audit → **1.0** (done).
- #77 URCi → **1.1–1.2**. #74 vacate INFO → **1.2.1.2**. #78 complete-all-INFO → **1.2.1.3**. #76 re-price → **1.3**.
- #75 FVT split → **1.4.1.1**. #79 REPL coverage completion → **1.5.1.2**. #71/#72/#73 whole-codebase single run → **1.5.1.3**.
- #81 red team attack → **1.6.1.1**. #82 Audit Book → **1.6.2.1**. #85 interface version bump + cascade → **1.7.1**. #83 redeploy → **1.7.2**.
- #80 UI incorporation desktop (grafted onto pantheonic) → **2.8.2.1**. #84 mobile translation → **2.8.3.1**.
- #86 comprehensive documentation + website publication → **2.9**.
