# Post-audit MAIN roadmap — the master checklist

The single tracker for everything queued once the audit worktrees land on `main`.
Created 2026-08-27. Check items off as they're done. Specs are cross-referenced.

## Branch topology (as of 2026-08-27)
- **`main`** already contains this session's work: AQP-INFO (10/17 stake-unstake+finalize/abort,
  ground-truth-proven), the unified single-boot test seed (`AQP-FULL.repl`), the transitive-heavy
  reclassification (`CC_`/`CCp_`) + `C_Inject` deletion, pact-5.4.1 note, and all the design docs.
- **Audit worktrees to merge:** `dpdc`, `dptf-dpof`, `swp`, and `ats` (tasks #21 SWP, #23 ATS).

---

## PHASE 0 — Merge audits + reconcile + green-gate  ⟵ START HERE
- [ ] **0.1** Merge `dpdc`, `dptf-dpof`, `swp`, `ats` worktrees → `main` (one at a time).
- [ ] **0.2** ⚠ **Reconcile conflicts.** The DPDC / DPTF-DPOF / SWP audits touch the SAME token
      modules my on-main work references: the AQP-INFO transfer-leg reconstruction calls
      `TFT.UDC_TransferCumulator` / `URC_TransferClasses`, `DPOF.UC_MoveCumulator`,
      `DPDC-T.UDC_MultiTransferCumulator`, `DPDC.UR_AccountNoncesSupplies`, and the reclassification
      touched TFT/IGNIS `C_Collect`. If an audit renamed/re-signatured any of these, fix the
      AQP-INFO call-sites + re-run the ground-truth.
- [ ] **0.3** **Full green-gate on pact 5.4.1** after merge:
      `bash REPL/run-aqp-audit.sh` (15 suites) + `pact Z.repl` (Stage 00/01/02) +
      `pact aqp-info-groundtruth.repl` (TF/OF/SF cost-equality) + `pact AQP-FULL.repl`
      (non-destructive core). Everything must be green before touching anything else.

## PHASE 1 — URCi cost architecture (spec: `URCI-COST-ARCHITECTURE.md`; task #77)
- [ ] **1.1** Register the **`URCi_*` prefix** in `StoicSyntax-Prefixes.md` + `StoicSyntax.md`
      (pure/read-only, no `enforce`, returns cost cumulator; lives IN its module).
- [ ] **1.2** Walk modules **in deploy order, Stage-1 module #1 first**. Per module: extract each
      cost-emitting `XE_`/`XI_`'s cumulator into a **leaf `URCi_*`** the leaf returns; add a
      **composer `URCi_*`** per `C_`/`CC_`/`A_`. Token modules (TFT/DPOF/DPDC-T) already have
      cost ctors → formalize as `URCi`.
- [ ] **1.3** Keep a running line-count check per module (rule B) as `URCi`s are added.

## PHASE 2 — INFO rehaul: COMPLETE coverage + consolidate (not just AQP)
The INFO rehaul is **total** — every client/admin entrypoint across the WHOLE codebase gets an INFO
preview via its composer `URCi`. Many are currently missing (only INFO-ONE/INFO-TWO/AQP-INFO exist,
and partially). This phase both *simplifies* the existing INFO and *completes* the missing ones.
- [ ] **2.1** Gut each existing `INFO_*` body to a thin **composer-`URCi` call + `ClientInfo` text**
      (keep names/return shape so the UI is untouched).
- [ ] **2.2** Build the **7 AQP vacate/drain/FullVacate INFO** as `URCi_Vacate*` callers (cost map:
      `memories/2026-08-27-aqp-info-final17-costmap.md`). Completes the AQP "final 17".
- [ ] **2.3** **COMPLETE the missing INFO across every module/stage.** Inventory every
      `C_`/`CC_`/`A_`/`AA_` client/admin entrypoint (Stage 1 + Stage 2, all modules) and build an INFO
      preview for each that lacks one — thin composer-`URCi` callers. This is the bulk of the rehaul:
      a ton of INFO functions are currently missing. Track coverage in a checklist (mirror the
      `aqp-entrypoint-surface.md` catalog approach, extended repo-wide).
- [ ] **2.4** **Consolidate to one INFO module per stage** and **relocate to a new
      `1_SOVEREIGN/STAGE_0N/Z_Reads/` slot (after `3_Talos`), deployed LAST** — read-only presentation
      layer, leaf (nothing refs it); `Z_` sorts absolutely last regardless of future numbered layers,
      mirroring slave `Stage_Z` (`DPL-UR`/`EXPLORER`). Move out of `2_Core` (`INFO-ONE`/`AQP-INFO`);
      delete reconstruction bodies; confirm `INFO-ONE` shrinks materially.
- [ ] **2.5** **Refactor load order:** update the REPL pipeline (`Z.repl`, `Stage01/02_Tester.repl`,
      the `[x]` loaders) **and** the on-chain deploy sequence to load each stage's `Z_Reads/` modules
      last in that stage.

## PHASE 3 — Re-price IGNIS (point A; spec: `memories/2026-08-27-ignis-cost-rethink.md`; task #76)
- [ ] **3.1** **Measurement pass:** instrument real STOA gas per client op by run-shape (build on
      the ground-truth harness). Re-price against data, not guesses.
- [ ] **3.2** **Value re-price** via the `UsagePrice` tiers (auto-tracks exec + info).
- [ ] **3.3** **Heavy-read surcharge:** make `URH_/URHC_/URD_` readers emit a cost cumulator scaled
      to rows scanned (localized at the transitive-heavy functions the naming already flags).
- [ ] **3.4** Edits land on `URCi`/UsagePrice only → exec and info move together (verify via 5.1 gate).

## PHASE 4 — AQP module splits (point B; spec: `MODULE-SIZING.md`; task #75)
- [ ] **4.1** **Split `04_FVT.pact`** (6,694 lines — OVER the ~6,635 ceiling; undeployable as-is)
      along a **capability seam** (candidate: config surface vs reward-runtime surface). NOT by line
      count. Get the table→module assignment right the first time (permanent).
- [ ] **4.2** Re-audit `POOL/SCORE/ANK/VCT` (and any Stage-1) line counts once their `URCi`s are in;
      split any in Warning/Danger band along capability seams.
- [ ] **4.3** Update `MODULE-SIZING.md` applicability table with post-`URCi` measurements.

## PHASE 5 — REPL finalization + CI harden (test EVERYTHING in one run)
The audits kept surfacing functions with **zero REPL coverage** (e.g. ATS `#22L` found 12 untested
config fns — and two real bugs hid there precisely because nothing called them). Those were deferred
to main. This phase closes the coverage gap repo-wide AND lands the single-comprehensive-run refactor.
- [ ] **5.1** **CI-gate the ground-truth harness**: exec `ignis-need` == real IGNIS/GAS delta. The
      exec↔info drift lock that lets Option A skip a rehaul. Extend it to cover **every** INFO function
      (all of Phase 2's completed coverage), not just the 3 currently proven.
- [ ] **5.2** **REPL coverage completion (repo-wide).** Inventory every `C_`/`CC_`/`A_`/`AA_` across
      Stage 1 + Stage 2 with a grep-based coverage audit (the audits each flagged gaps — fold their
      lists in, e.g. ATS `#22L`, `[6.6]_ATS.repl`). Write canonical REPL suites for every untested
      entrypoint, in the required layout (`REPL_AND_TESTS.md`). Untested code ships bugs — this is
      correctness, not polish.
- [ ] **5.3** **Single comprehensive run — the whole codebase, one boot.** Generalize `AQP-FULL.repl`
      from AQP to **everything**: one hermetic run that boots once and exercises ALL Pact code (Stage 1
      + Stage 2 + slaves + `Z_Reads` INFO). Requires the hermetic fixture isolation from the AQP
      unified-test work (tasks #71/#72/#73: disjoint fixtures per destructive scenario + delta-based
      pre-state; fold info/stream/DSA inline bodies). Spec: `memories/2026-08-27-aqp-full-unified-test.md`.
      End state: **one command tests the entire system top-to-bottom.**

---

## AUDIT CARRY-OVER — deferred items each merged audit brings
**Standing rule:** every audit worktree carries its OWN deferred list (open owner-decisions,
test gaps, doc debt, live-diffs) in its `…/Audit/<MODULE>/` folder. **When an audit merges to
main, fold its deferred list into this section.** SWP / DPDC / DPTF-DPOF will each add a block
here at merge (their `ISSUES-RANKED.md` / `ROUND-02-FIXES.md` are the source).

### ATS audit — carried over (MERGED to main; source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/`)
Verified on main: the two live fixes landed — `P|A_Define` IMP registration
(`3_Talos/01_TS01-A.pact:165-166`) and `C_HOT-RBT|Repurpose` `UR_NonceMetaData` arity fix
(`08_ATS.pact:1919`). Remaining:
- [ ] **Open owner-decisions (don't close without asking):**
      - `#26L` — `C_KickStart` `rt-amounts` trusted by position, no name-match vs pool's reward list. Guard now vs defer to module rehaul?
      - `#28L` — dead StoicTag fns in `09_U_ATS.pact` (`UC_IzStoicTagIndex*`/`UEV_StoicTagIndex`) — verified dead; confirm deletion.
      - `#31L` — Talos `C_SetHotRecoveryFee` (singular) vs core `C_SetHotRecoveryFees` (plural); rename needs no interface bump — approve rename?
      - The `can-change-owner` / `syphoning` / `hibernate` + 3 recovery on/off switches — still-open findings, not ruled on.
- [ ] **`#22L` test wiring:** `[6.6]_ATS.repl` exists (ported, 159 KB) but is **commented out** of
      `Stage01_Tester.repl` (dup-MVST collision with the AQP Stage-2 path, #12a). Resolve so ATS
      config coverage actually runs in the gate (standalone ATS suite, or deconflict the MVST re-issue).
      Then update ATS `README.md` `#22L` status → FIXED.
- [ ] **New structural finding `P|A_Define`** — fixed live but **not yet logged** as its own numbered
      finding / documented in the 4 ATS audit docs. Owner: log as `#33N`-style? Then write up.
- [ ] **Scratch cleanup:** remove `REPL/_cov_draft.repl`, `_baseline_66_check.repl` (+ `_iso_check`,
      `_probe2/3` if present) — throwaway, must not ship.
- [ ] **Live-vs-local diff:** `U_ATS` + `U_DPTF` not yet diffed against live (Pythia keyless recipe in
      `OuronetInformational/pythia-dirty-read-access.md`). ATS/ATSU already diffed (live behind local on V1).
- [ ] **Final consolidated ATS audit write-up** (owner-requested) — after `#22L`/`#26L`/`#28L`/`#31L` +
      `P|A_Define` are all closed.

### SWP audit — TO FOLD AT MERGE (worktree `swp`; `…/Audit/SWP/ISSUES-RANKED.md`, `ROUND-02-FIXES.md`)
### DPDC audit — TO FOLD AT MERGE (worktree `dpdc`; `…/Audit/DPDC-*` + audit commits `#27M`–`#39L`)
### DPTF-DPOF audit — TO FOLD AT MERGE (worktree `dptf-dpof`)

---

## Standing invariants
- REPL testing uses **pact 5.4.1** (`~/.local/bin/pact`; old = `pact-5.4`). Never test on 5.4.
- Commit granularity per phase; never `git add -A` (stage explicit paths).
- FVT-over-ceiling (4.1) is a **hard gate before any mainnet deploy** — cannot ship/upgrade FVT until split.

## Quick task map
#21 SWP audit · #23 ATS audit → **Phase 0**. #77 URCi → **Phase 1-2**. #74 vacate INFO → **Phase 2.2**.
#78 complete-all-INFO → **Phase 2.3**. #76 re-price → **Phase 3**. #75 FVT split → **Phase 4**.
#79 REPL coverage completion → **Phase 5.2**. #71/#72/#73 whole-codebase single run → **Phase 5.3**.
