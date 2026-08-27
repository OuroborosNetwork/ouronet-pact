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

## PHASE 2 — INFO consolidation (finishes the last 7 vacate INFO for free)
- [ ] **2.1** Gut each `INFO_*` body to a thin **composer-`URCi` call + `ClientInfo` text**
      (keep names/return shape so the UI is untouched).
- [ ] **2.2** Build the **7 vacate/drain/FullVacate INFO** as `URCi_Vacate*` callers (cost map:
      `memories/2026-08-27-aqp-info-final17-costmap.md` — the two-map concat + drain `UserUnn==0`
      subset). This completes the "final 17".
- [ ] **2.3** **Consolidate to one INFO module per stage**, deployed **last** in each stage's order.
      Delete the reconstruction bodies (now redundant). Confirm `INFO-ONE` shrinks materially.

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

## PHASE 5 — Harden: CI drift-gate + unified single-boot test
- [ ] **5.1** **CI-gate the ground-truth harness** (`aqp-info-groundtruth.repl`): exec `ignis-need`
      == real IGNIS/GAS delta. This is the exec↔info drift lock that lets Option A skip a rehaul —
      any cost change not reflected in `URCi`/INFO fails the build.
- [ ] **5.2** Finish the **unified single-boot AQP test** (tasks #71/#72/#73): hermetic fixture
      isolation for the destructive tails (give each its own disjoint NFs/accounts/anchor + delta-based
      pre-state) so they fold into `AQP-FULL.repl`; extract + fold the info/stream/DSA inline bodies
      (Phase B). Goal: one boot exercises everything. Spec: `memories/2026-08-27-aqp-full-unified-test.md`.

---

## Standing invariants
- REPL testing uses **pact 5.4.1** (`~/.local/bin/pact`; old = `pact-5.4`). Never test on 5.4.
- Commit granularity per phase; never `git add -A` (stage explicit paths).
- FVT-over-ceiling (4.1) is a **hard gate before any mainnet deploy** — cannot ship/upgrade FVT until split.

## Quick task map
#21 SWP audit · #23 ATS audit → **Phase 0**. #77 URCi → **Phase 1-2**. #74 vacate INFO → **Phase 2.2**.
#76 re-price → **Phase 3**. #75 FVT split → **Phase 4**. #71/#72/#73 unified test → **Phase 5.2**.
