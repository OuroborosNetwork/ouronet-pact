# Post-audit MAIN roadmap — the master checklist

The single tracker for everything queued once the audit worktrees land on `main`.
Created 2026-08-27. Check items off as they're done. Specs are cross-referenced.

## Branch topology (as of 2026-08-27)
- **`main`** already contains this session's work: AQP-INFO (10/17 stake-unstake+finalize/abort,
  ground-truth-proven), the unified single-boot test seed (`AQP-FULL.repl`), the transitive-heavy
  reclassification (`CC_`/`CCp_`) + `C_Inject` deletion, pact-5.4.1 note, and all the design docs.
- **Audit worktrees:** ✅ ALL MERGED to main + reconciled + green — `ats`, `dpdc` (`7efe386`),
  `swp` (`cc230d5`), `dptf-dpof`/DALOS (`07556e1`). All worktrees archived (branches preserved).
  Each audit's carry-over folded into the AUDIT CARRY-OVER section + placed in its phases. **Phase 0.1
  complete.** Remaining Phase 0: 0.4 (discover live interface versions — do anytime) then start Phase 1.

---

## PRE-PHASE DECISIONS — settle before starting the list
Surfaced from the audit-folder scan. Resolve, then their outcome folds into the phases.

- [x] **D1 — AQP LP-scoring — SETTLED (names confirmed 2026-08-29).** Both modes, per-farm toggle;
      `SPLIT|STAKED` / `SPLIT|TVL` names confirmed by owner. Detail below → task #89.
  - **§6.2 negative-score fix: DONE** (Fix #7) — LP Level-1 score is now `lp-amount × mx` (amount,
    not fluctuating STOA value), so a full unstake nets to 0, no negative, no clamp. Only leftover: the
    dead `URC_LpAmountToLpDenominatorEquivalent` fn (uncalled) → **retire it in Phase 1 cleanup**. No decision.
  - **G2 — RESOLVED (owner 2026-08-29): implement BOTH reward-split modes, selectable per farm/entity.**
    They differ only in the Level-2 per-pool weight `W_i`; everything else (Level-1 = staked amount, STOA
    valuation, inject-time capture) is shared → a per-farm config flag, not a rewrite. (task #89)
    - **`SPLIT|STAKED`** (Variant 1, *participation* — the standard default): `W_i` = the pool's total
      **staked value** (Σ staked-LP-amount × lp-worth-in-STOA). Every staked STOA-unit earns equally;
      pool size irrelevant. E.g. staked 120k/140k/149k → 120/409, 140/409, 149/409.
    - **`SPLIT|TVL`** (Variant 2, *pool-size* — the Vesta/MultiversX model): `W_i` = the swpair TVL
      (`SWP::UR_StoaValue` — already stored + refreshed on pool events, captured at inject). Bigger pools
      capture bigger slices. E.g. pools 1M/250k/150k → 1.0/1.4, 0.25/1.4, 0.15/1.4.
    - **What's built (verified in code 2026-08-29):** the AQP LP-redesign audit HARD-SWITCHED the live
      inject to Variant 1 — `URC_FarmInjectDenominatorFresh` (1693) sums `URC_MemberStakedStoaValue`
      (1784) = staked-portion value, computed FRESH at inject (no cache; base-dependent). Variant 2's
      formula still exists as `URC_ResolveScoreEntityGhostWeight` (1854) = `UR_StoaValue` (whole-pool
      TVL) but is DORMANT — only seeds the legacy `total-ghost-tvl-weight` cache the defcap gate reads.
      So today = single-mode Variant 1; **no toggle was ever built.** The variants never coexisted —
      the audit *replaced* TVL to fix the negative-score bug (#7) + a cache-timing bug (S synced at
      stake-2.1, before base updated at 4 → stale defcap S).
    - **MECHANISM — settled (owner 2026-08-29):** a **per-farm (`FVT|T`) flag**, **freely mutable** via
      a setter (`C_SetSplitMode` + Talos wrapper + cap + gas + INFO), **default `SPLIT|STAKED`** (= current
      live behavior). No cooldown — switching only affects FUTURE injects (RPS is checkpoint-based; past
      rewards untouched); transparency is the mitigant (staker sees the farm's current mode in its params).
      Since W_i is fresh-at-inject, wiring is one branch in `URC_FarmInjectDenominatorFresh` + the matching
      numerator (line 2286): `(if (= split-mode SPLIT|TVL) URC_ResolveScoreEntityGhostWeight
      URC_MemberStakedStoaValue)`. Task #89 must ALSO reconcile the fresh-vs-cached-S defcap-gate wrinkle
      (NOTE 1849–1853) for BOTH modes. The reward preview (INFO) reports the mode.
    - **STATUS (2026-08-29): IMPLEMENTED + green.** `04_FVT.pact` (schema field, `URC_MemberLevel2Weight`
      routing all 3 W_i sites, `C_SetSplitMode`/cap/XI/WU/GAS), Talos `AQP-FVT|C_SetSplitMode`, INFO
      `AQP-FVT|INFO_SetSplitMode`; interface declares the reader + setter. Full `Z.repl` green (542 asserts).
      Switch-mechanism test `REPL/Stage_02/[6.2.11]_AQP-SPLIT-MODE.repl` (default pipeline): default mode,
      free bidirectional switch, invalid-mode + farm-only guards — 5 asserts green. Commits 78553c9, 1f3e3ed.
    - **Non-farm sentinel (owner 2026-08-29):** `C_Issue` takes no split-mode arg (auto-set). Farms →
      `SPLIT|STAKED` default; vaults/treasuries → `"|"` (`CT_SPLIT_MODE_NA`) sentinel — never read, and
      `C_SetSplitMode` rejects non-farms.
    - **Economic-flip proof: DONE + green** — `[6.2.9]` `TX-BOOT-13-SPLIT` on the real `OuroLpFarm` triplet
      member: same member, W_i = **0** under `SPLIT|STAKED` (no LP staked yet) vs **7920.17** under
      `SPLIT|TVL` (= whole-pool `UR_StoaValue`); restoring STAKED returns the staked weight. Unblocked by
      fixing the 0.3a citizen-drift. `AQP-comprehensive.repl` green (371+44 asserts).

- [x] **D2 — Heir System — SETTLED: DEFERRED to STAGE 3** (owner 2026-08-29). Not part of this plan;
      handled after everything here ships. See the STAGE 3 section below. Background retained:
      `repurpose` moves a
  holder's tokens to a new account **without their signature** — a deliberate account-recovery tool
  (stolen account / owner death → admin moves holdings to an account the owner/heirs control; admin-gated
  + event-logged, by design). The tension: every token-owner power (freeze/wipe/unfreeze/remint/burn/
  repurpose) is total dominion; holders trust the issuer. The proposed **Heir System**: an account
  **proactively designates an heir while in control** (signed in advance — trustless) + a **dead-man's
  switch** (no activity for a set duration → the heir can claim/repurpose), shifting trust from "admin
  fairness" to "owner's advance designation + an objective on-chain inactivity timer." Open sub-qs:
  DALOS-account-layer (any account, all token types) vs per-collection; what counts as "activity";
  coexist with admin-discretion repurpose; could it be a DALOS **guard** rather than new DPDC machinery.
  **DECIDE: schedule it (new feature — likely its own phase + UI surface) or keep as a captured future
  idea (post-launch)?**

---

## PHASE 0 — Merge audits + reconcile + green-gate  ⟵ START HERE
- [x] **0.1** Merge `dpdc`, `dptf-dpof`, `swp`, `ats` worktrees → `main` (one at a time). ✅ ALL DONE.
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
- [x] **0.3a ✅ FIXED (2026-08-29): full-boot-suite drift from DPDC audit renames.** Two pre-existing
      citizen/test drifts that blocked every `OuroLpFarm` boot, found + fixed during task #89:
      (1) **Bloodshed** called `DPDC-UDC::UDC_ScoreMetaData`, which **DPDC #45L removed** — but the audit
      wrongly believed it had zero callers (it missed the 4 citizen callers). Fix is behavior-identical:
      inline its old one-liner `UDC_NonceMetaData score [0] meta` at
      `2_SLAVE/Stage_02/1_Bloodshed/{01_BSD-L, 02_BSD-E, 03_BSD-R, 04_BSD-C}.pact` (audit-respecting: the
      `composition=[0]` footgun stays out of sovereign; `[0]` is correct for Bloodshed's mint path).
      (2) **`[5.2]_PopulateBloodshed.repl`** called `DPDC-S::UR_N|Score`, renamed to `URC_N|Score` by
      DPDC #19H (2 active refs). `AQP-comprehensive.repl` now green (371+44 asserts). **Lesson for the
      citizen-migration work (Phase 1.5): DPDC audits only checked sovereign callers — sweep 2_SLAVE +
      test files for every renamed/removed DPDC symbol.**
- [ ] **0.4 Discover LIVE interface versions (early — informs the Phase 7 bump).** Read the currently
      **deployed** Ouronet modules on-chain (Pythia keyless dirty-read —
      `OuronetInformational/pythia-dirty-read-access.md`) and record which interface version each live
      module implements. The next version for any interface that changes = **live + 1** (so we know if
      a new interface is V2 or V3). Record the **live→target(+1) map**. NB: local dev has already moved
      ahead of live for some (e.g. ATS on `V2` while live is `V1`) — target is relative to **live**, not local.
- [x] **0.5a Checkpoint push** — all merges + session work pushed to `origin/main` (`3cf31ae`). ✅
- [ ] **0.5 DEMIPAD audit (on main — the LAST unaudited module).** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/`
      (DEMIPAD, Spark, Snakes, Custodians, StoicPay, STOAICO) is the only Stage-1/2 surface no audit
      covered. Do it **here on main** (no worktree — nothing to parallelize). Mirror the other audits'
      rigor (findings → owner verdicts → fixes-with-proof → tracker); produces its own carry-over to
      fold + becomes part of Audit Book Part I. Green-gate after.

## PHASE 1 — URCi cost architecture (spec: `URCI-COST-ARCHITECTURE.md`; task #77)
- [ ] **1.0 DECISION (settle before the walk): interface-richness policy.** Fully informed now by the
      modref tests (`memories/2026-08-29-modref-*`): `::` calls resolve dynamically AND upgrade live
      regardless of interface membership, so declaring a function is a **choice**, not a requirement:
      **rich** (declare cross-module fns → enumeration + module-side drift-catch, but a changed
      interface bumps at Phase 7) vs **marker-lean** (stable minimal interface → zero cascade from fn
      adds, but no interface-level enumeration; the Phase-2.3 catalog + Talos + tests cover
      enumeration/safety). Pick and apply consistently through the URCi/INFO walk. *Suggested default:*
      keep interfaces at the stable public contract; don't force churn just to declare — the catalog is
      the enumeration source, and `::` makes upgrades bless-free either way.
- [ ] **1.1** Register the **`URCi_*` prefix** in `StoicSyntax-Prefixes.md` + `StoicSyntax.md`
      (pure/read-only, no `enforce`, returns cost cumulator; lives IN its module).
- [ ] **1.2** Walk modules **in deploy order, Stage-1 module #1 first**. Per module: extract each
      cost-emitting `XE_`/`XI_`'s cumulator into a **leaf `URCi_*`** the leaf returns; add a
      **composer `URCi_*`** per `C_`/`CC_`/`A_`. Token modules (TFT/DPOF/DPDC-T) already have
      cost ctors → formalize as `URCi`. **Any `URCi_*` called CROSS-MODULE gets an interface declaration in the same edit** (modref
      resolution is dynamic — undeclared works but loses load-time safety; see memories/2026-08-29-
      modref-interface-semantics.md). Internal-only leaves stay out.
- [ ] **1.3** Keep a running line-count check per module (rule B) as `URCi`s are added.
- [ ] **1.5 Rename `2_SLAVE` → `2_CITIZEN` (terminology alignment with the website).** Ouronet's site
      names the two module classes **Sovereign** (canonical core) and **Citizen** (built by anyone, on
      top of sovereign public APIs — never adds core capabilities). "Slave" is the old internal name for
      the same thing. Rename the folder + update every reference: `../2_SLAVE/` load paths in the REPL
      pipeline, `CLAUDE.md`, `MODULE-INDEX.md`, docs, deploy sequence, and "sovereign vs slave" wording
      → "sovereign vs citizen". Mechanical; do it as one coordinated sweep. (task #88)
- [ ] **1.4 StoicSyntax renames carried over from audits** (do during the per-module walk):
      **DPDC #40L** — `Wipe*` family (Heavy/Pure/Clean/Dirty) rename/rethink; **ATS #31L** — Talos
      `C_SetHotRecoveryFee` (singular) vs core `C_SetHotRecoveryFees` (plural), rename (no interface
      bump needed, pre-mainnet); **SWP** — `KDA-PID`→`STOA-PID` (L58), `URC_Swap`/`URC_InverseSwap`→
      `URCv_Swap`/`URCv_InverseSwap` (L64), `UC_ComputeInverseY`→`v`-specialization, and rename the
      existing `AHU`/`AUP_*` instances to the new `AU_` prefix (the audit added `AU_` to StoicSyntax).
      **DALOS** — a repeated shape flagged for a dedicated sweep (Audit/DALOS README "Downstream plan" phase 3b).

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
- [ ] **2.6 Write-tier/read-layer fixes carried over from audits:** **DPDC #43L** — a write-tier fn
      returns a display string instead of ending on a write; move the "what it did/costs" display into
      the INFO/read layer (`XI_`/`XB_` end on write, no return). Add more as SWP/DPTF-DPOF land.

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
      correctness, not polish. **Carried-over coverage gaps to fold in:** ATS `#22L` (12 config
      `C_`/`A_` fns; wire `[6.6]_ATS.repl` past the #12a dup-MVST block), DPDC `#41L/#42L` (branding +
      ownership-gate); DALOS **H16** + PYTHIA `#49M` (flush-gas-probe broken batch sizes) + other DALOS ROUND-02 coverage gaps.
- [ ] **5.3** **Single comprehensive run — the whole codebase, one boot.** Generalize `AQP-FULL.repl`
      from AQP to **everything**: one hermetic run that boots once and exercises ALL Pact code (Stage 1
      + Stage 2 + slaves + `Z_Reads` INFO). Requires the hermetic fixture isolation from the AQP
      unified-test work (tasks #71/#72/#73: disjoint fixtures per destructive scenario + delta-based
      pre-state; fold info/stream/DSA inline bodies). Spec: `memories/2026-08-27-aqp-full-unified-test.md`.
      End state: **one command tests the entire system top-to-bottom.**

## PHASE 6 — Red team attack + Audit Book (BEFORE redeploy; tasks #81, #82)
With the code in its **final shape**, just before redeploy: a comprehensive **multi-agent red-team
attack on ALL modules** to expose vulnerabilities. Its findings + fixes become Part III of the book.
- [ ] **6.1 Red team attack (all modules).** Multi-agent adversarial security audit: fan out
      attackers per module / attack-surface — capability & auth bypass (module-boundary guard,
      composed caps), arithmetic/rounding/precision, economic & MEV (front-run, sandwich, ratio
      extremes), ordering/reentrancy-like, cross-module boundary abuse, defpact/Hydra-slice races,
      gas-station exploitation, sentinel/collision. Synthesize + **adversarially verify** each
      candidate finding against code (CONFIRMED/REFUTED), fix, re-test. Same rigor as the initial
      audits, adversarial framing.
- [ ] **6.1a Carried-over leads for the red team** (audits explicitly filed these for main's red-team pass):
      **SWP `#32bM`** (M11/M12 reachability — MTX-SWP fee-before-gate ordering / no-TTL rollback; verdicts
      unchanged, re-examine now that TS01-CP wiring is known-reachable); **SWP `URC_OuroPrimordialPrice`**
      (16_SWPI.pact — likely the same weight-omission bug fixed on the WSTOA side #73C; unconfirmed,
      15-min trace + live check); **SWP Round III re-verify** (systematic re-check of every closed SWP
      finding — the adversarial pass subsumes it). Fold DPTF-DPOF leads in at merge.
- [ ] **6.2 Assemble the Audit Book** (expected hundreds of pages) — spec: `AUDIT-BOOK.md`:
      - **Part I** — initial module audits (ATS, SWP, DPDC, DPTF-DPOF, AQP) — the `…/Audit/*` trees.
      - **Part II** — the whole main-work round (Phases 1-5): every URCi/INFO/re-price/split/REPL
        modification + fix, documented audit-style. **Document main-work AS IT LANDS — it IS Part II.**
      - **Part III** — the red-team attack audit (6.1): vulnerabilities sought, found, fixed.
      One consolidated, publishable book telling the whole story end to end.

## PHASE 7 — Interface version bump + cascade + deploy-ready gate + redeploy (tasks #83, #85)
Almost EVERY interface will carry new code by now (audits + URCi + INFO + re-price + splits +
red-team fixes), so each changed interface must become its **next version**. Do this ONCE, here,
after all code is final — never repeatedly. Spec: `ARCHITECTURE/INTERFACE_VERSIONING.md`.
NB (upgrade semantics, tested — `memories/2026-08-29-modref-live-dispatch-*`): `::` modref dispatch is
LIVE — an in-place sovereign upgrade reaches ALL `::` callers with no `bless` (this is why the repo has
never needed it). So this redeploy is bless-free for `::`-using sovereign code; the ONLY hash-pin
exposure is a `2_SLAVE/` third-party calling sovereign via `.` (a deliberate integrator version-pin) —
if we upgrade a core they `.`-reference in place, we'd have to `bless` their old hash for them.
- [ ] **7.1 Interface version bump.** For every interface whose code changed, bump its suffix to
      **live + 1** using the Phase-0.4 live→target map (`V1`→`V2`, or `V2`→`V3` where local already moved).
- [ ] **7.2 Cascade refactor (BIG — whole codebase; task #85).** Per the cascade rule: every interface
      that names a bumped one (`module{B}` / `object{B.Schema}`) must itself bump, and EVERY consumer
      updates its `ref-`/`implements` to the new version, **in lockstep**. Interfaces are pervasive, so
      this touches most of the codebase — a distinct large refactor. (NB the cascade is triggered by
      interface CHANGES — added members + interface-owned schema/type refs — NOT by every function; a
      modref call resolves dynamically. Policy: declare per cross-module fn, bump per interface, ONCE
      here. See memories/2026-08-29-modref-interface-semantics.md.) Mechanical (rename + rewire), so it
      lands after the red team (logic is final); do it, then re-gate.
- [ ] **7.3 Deploy-ready gate:** whole-codebase single run (5.3) green + all audits closed + book
      assembled + every module within the deploy ceiling (rule B; FVT split done) + version bump green.
- [ ] **7.4 Fresh top-to-bottom redeploy** of Stage 1 + Stage 2 (+ slaves). This finalized
      entrypoint set is the shape the UI enumerates.

## PHASE 8 — UI incorporation (CAPSTONE; workstream #2; spec: `UI-INCORPORATION-PLAN.md`; task #80)
The second major workstream: a **document of incorporation** an AI agent (OuronetUI) follows to
implement the ENTIRE Ouronet functionality onto the web UI — an **intelligent UX blueprint**, NOT a
brain-dead button listing (see the plan doc).
- [ ] **8.0 Hard dependency:** Phases 1-7 done (final shape redeployed).
- [ ] **8.1** Extend the **repo-wide entrypoint-surface catalog** (from Phase 2.3) into UI input: per
      entrypoint → role + asset-type + domain + INFO fn + readers + input form. The machine-readable
      substrate (every action, its cost, its state) — the *raw material*, not the design.
- [ ] **8.2 Study the existing "pantheonic architecture."** The UI is NOT greenfield — it recently
      migrated to the owner's pantheonic architecture + has real partial implementation. Learn its
      conventions + what's already built from the current OuronetUI codebase; the derived design
      **grafts onto it**, extending its patterns — not a parallel structure.
- [ ] **8.3 (Stage 8A — desktop) Write the incorporation document as an INTELLIGENT architecture**
      grafted onto the pantheonic patterns: role-based control panels, role-grant-driven (permission-
      aware) surfaces, workflow/journey flows — grouped by user intent, not mechanical fn→button.
      The examples in the plan doc are ILLUSTRATIONS of caliber, not a spec — derive the full
      structure from the code. Miss nothing built. Then hand to the OuronetUI agent to implement.
- [ ] **8.4 (Stage 8B — mobile) Secondary refinement: lossless mobile translation.** Bring the entire
      desktop implementation into a mobile-friendly format — everything visible/doable on desktop
      translated **without loss** to the smallest screen. Driven by the existing OuronetUI dashboard's
      **custom responsive port** as the blueprint. A colossal effort in its own right; a distinct
      stage, not an afterthought. (task #84)

**Why #1 enables #2:** the completed INFO surface + entrypoint catalog is ~80% of the *substrate*
(button = client fn; preview = INFO; metrics = readers; form = wrapper sig). Phase 2.3 is the bridge.
But 8.2 is where **intelligence** turns that substrate into the best possible UX. Manual build:
10-20 yrs solo / 2-4 yrs human+AI; scoped to an agent following an intelligent plan: **weeks**.

## PHASE 9 — Comprehensive Documentation + website publication (capstone #3; spec: `DOCUMENTATION-PLAN.md`; task #86)
A FULL written documentation of everything the code does — every module, function, shape, purpose;
why it's complex; why it costs so much; advantages vs industry standards; what a user can achieve —
so a brand-new reader understands what Ouronet is. Published with the Audit Book in the site's
**Documentation + Audit region**. Can run in parallel with Phase 8 (both need the final shape).
- [ ] **9.0 Hard dependency:** Phase 7 done (final shape redeployed) — every prior piecemeal attempt
      failed because new code kept arriving; this only works on the settled shape.
- [ ] **9.1 Observe the existing website** at `d:\_Claude\OuroborosNetwork\websites\ouronetwork-website\`
      to see first-hand how incomplete the current docs are vs. what's required. Do NOT trust them.
- [ ] **9.2 Write the comprehensive documentation** — walk the final codebase module-by-module
      (purpose, schemas/tables, every function's role/how/why), grouped for a reader; the 7 asset
      types + what users achieve; the cost story (from INFO/`URCi`); advantages vs industry standards;
      and a first-class **StoicSyntax methodology** chapter (how the prefix discipline made the code
      semi-self-auditing — "half-audited code"). Cross-ref the entrypoint catalog so nothing is missed.
- [ ] **9.3 Publish** the documentation + the Audit Book into the site's Documentation + Audit region.

---

## STAGE 3 — future development (AFTER this entire plan ships)
Beyond the scope of this roadmap (which finalizes + deploys Stage 1 + 2 and builds the UI/docs).
Stage 3 is the next development stage, taken up **after everything here is done**. Owner-named scope:
- **Heir System** — proactive heir designation + dead-man's inactivity switch (the D2 deferral;
  detail in `01_DPDC/Audit/HEIR-SYSTEM-PONDERING.md`; consider DALOS-account-layer + guard-based).
- **NFT Marketplace** — trade collectables (DPSF/DPNF) on Ouronet.
- **Order-based exchange** — an order-book DEX (complements the AMM SWP pools).
- **Lending Platform** — borrow/lend against Ouronet assets.
Each is a new sovereign feature-set built on the finalized Stage-1/2 primitives; they'll get their own
plans when Stage 3 begins. Captured here so the horizon isn't lost.

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

### DPDC audit — carried over (MERGED to main, `7efe386`; source: `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/Audit/`)
All 11 DPDC modules, 58 tracked items ALL closed (35 fixed+live-verified, 13 refuted, 4 already-closed,
2 no-bug, 4 deferred). 3 new canonical REPL suites wired in (`[6.1.1]_EQUITY`, `[6.1.2]_DPDC-FRAGMENTS`,
`[6.1.3]_DPDC-S`). Interface changes pre-mainnet, no bump. Signatures my AQP-INFO calls
(`UDC_MultiTransferCumulator`, `UR_AccountNoncesSupplies`, `URD_AccountNonces`) verified intact.
Remaining (4 deferred LOW — map onto our phases):
- [ ] **#40L** — `Wipe*` family (Heavy/Pure/Clean/Dirty) rename/rethink → a **StoicSyntax pass**
      (fold into the Phase 1 module-by-module walk, or a standalone StoicSyntax cleanup).
- [ ] **#41L/#42L** — branding + ownership-gate **test-coverage gaps** → **Phase 5.2** (repo-wide REPL
      coverage completion).
- [ ] **#43L** — a write-tier fn returns a display string instead of ending on a write → **Phase 2**
      (INFO/URCi rearchitecture — the `XI_`/`XB_` "end on write, no return" rule; the display belongs
      in the INFO/read layer).
- [ ] FYI (non-blocking): an AQP-side investigation (does the DPDC-S score-multiplier apply at staking
      time?) was handed off and is pending independently. The DPTF/DPOF "no-ownership-check DeployAccount"
      shape was confirmed to exist there too → fold into the DPTF-DPOF audit at merge.
- [ ] Optional cleanup: the `REPL/Kursan/_verify_finding_*` scratch files came in with the merge
      (audit evidence) — keep or prune per owner.

### SWP audit — carried over (MERGED to main, `cc230d5`; source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/`)
Full SWP family (SWP/SWPI/SWPT/SWPL/SWPLC/SWPU/MTX-SWP + U|SWP). ALL closed: 13 CRIT, 12 HIGH,
14 MED, 32 LOW + the `#65bL` gas master-issue (worst-case now under the 2M ceiling, ~74% cold-cache
reduction). Big structural fixes: SwapTracer `V1→V2` (H3 principal-orphan redesign), ClientThree/
ClientPacts `→V2` (M14), `SwapperV3` gained `URC_ActiveSwpairs`, DWK/DLK→WSTOA/SSTOA rename (#65gL).
The audit **introduced the `AU_` (Admin Update) prefix** — already merged into `StoicSyntax-Prefixes.md`.
Signatures Stage-2 (DSA `A_Fuel(swpair)`) calls into SWP verified intact (11/11 resolve). Deferred:
- [ ] **StoicSyntax naming sweep → Phase 1.4:** `KDA-PID`→`STOA-PID` (L58), `URC_Swap`/`URC_InverseSwap`
      →`URCv_Swap`/`URCv_InverseSwap` (L64), `UC_ComputeInverseY`→`v`-specialization, and rename the
      existing `AHU`/`AUP_*` instances to the new `AU_` prefix.
- [ ] **`#32bM` → Phase 6.1 (red team):** M11/M12 reachability correction (MTX-SWP fee-before-gate
      ordering, no-TTL rollback) — verdicts left as-is; owner filed it explicitly for main's red-team pass.
- [ ] **Round III re-verify → Phase 6.1:** systematic re-check of every closed finding (owner: this
      branch's job was the initial fix; re-verify is main's — the adversarial red-team pass covers it).
- [ ] **⚠ `URC_OuroPrimordialPrice` lead → Phase 6.1 (15-min trace):** `16_SWPI.pact` dollar-denominated
      math *likely* carries the same weight-omission bug just fixed on the WSTOA side (#73C) — NOT
      confirmed, shares the exact math shape. Worth a trace + live check before the red team assumes it's fine.
- [ ] **Interface versions (informs Phase 0.4/7):** SWP is on `SwapperV3` / `SwapTracerV2` /
      `ClientThreeV2` / `ClientPactsV2` → live-version map inputs; a `SwapperV3`→`V4` bump was left as a
      separate decision (ROUND-02-FIXES.md).
- [ ] Optional (unscheduled): router direct-pair fast-path — `URC_HopperActive` builds the full graph
      even when a direct A→B pool exists (Kaddex short-circuits); pure gas optimization, not a bug.
- [ ] Moot: live-vs-local Pythia diff — ruled moot by owner (full redeploy planned anyway).
### DALOS / "rest of Stage 1" audit (the `dptf-dpof` worktree) — carried over (MERGED, `07556e1`; source: `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/`)
Broad audit of **everything in Stage 1 not claimed by ATS/SWP** — DALOS, DPTF/DPOF/TFT, IGNIS,
ELITE, DPMF, ELITE, utilities (U_CT/LST/INT/DEC/DALOS/VST), OUROBOROS, CODEX/PYTHIA, TS01 Talos,
+ the interface cascade. All CRIT/HIGH/MED/LOW closed (fixed/refuted/finalized) except the deferrals
below. Added `DPTF|A_DeployAccount` / `DPOF|A_DeployAccount` admin variants (no ownership check on
`<account>`, for system-account deploys). Seam (TFT/DPOF/DPTF/IGNIS signatures my AQP-INFO calls)
verified intact. Deferrals:
- [ ] **⚠ REVIEW: TS02-DPAD DeployAccount reconciliation** — the merge combined *two* audits' fixes
      (dptf-dpof `#N2` admin-variant for tf/of + DPDC `#35M` direct-`XB` for sf/nf). Correct by my
      analysis (alternatives unbound / wrong-ownership) but it's a judgment merge — worth an owner glance.
- [ ] **H11 → Phase 2 (INFO):** deferred to the main-branch INFO-function project. **The audit
      independently scoped OUR Phase 2** (its README "INFO-function coverage project" downstream phase +
      `memories/2026-08-24-info-functions-are-ui-facing-not-dead-code.md`) — strong validation of task #78.
- [ ] **H16 + REPL-coverage gaps → Phase 5.2:** deferred to the main-branch REPL test-infra phase
      (e.g. PYTHIA `#49M` flush-gas-probe broken batch sizes; other coverage gaps flagged in ROUND-02).
- [ ] **H17 → Phase 7 (redeploy):** finalized as a status note, folded into the redeploy phase.
- [ ] **Pattern sweep → Phase 1:** a repeated shape flagged for a dedicated main-branch sweep
      (README "Downstream plan" phase 3b) rather than piecemeal fixes.
- [ ] Note: oracle (Aletheia) wiring explicitly deferred until an oracle is available (future feature;
      ties to SWP's `KDA-PID`→`STOA-PID`). DALOS-family interfaces are pre-mainnet V1/V7, edited freely
      (no bump) — informs the Phase 0.4/7 version map (ATS/SWP interface versions were out of this audit's scope).

---

## Standing invariants
- REPL testing uses **pact 5.4.1** (`~/.local/bin/pact`; old = `pact-5.4`). Never test on 5.4.
- Commit granularity per phase; never `git add -A` (stage explicit paths).
- FVT-over-ceiling (4.1) is a **hard gate before any mainnet deploy** — cannot ship/upgrade FVT until split.

## Quick task map
#87 DEMIPAD audit → **Phase 0.5**. #88 Slave→Citizen rename → **Phase 1.5**. #21 SWP · #23 ATS audit → **Phase 0** (done). #77 URCi → **Phase 1-2**. #74 vacate INFO → **Phase 2.2**.
#78 complete-all-INFO → **Phase 2.3**. #76 re-price → **Phase 3**. #75 FVT split → **Phase 4**.
#79 REPL coverage completion → **Phase 5.2**. #71/#72/#73 whole-codebase single run → **Phase 5.3**.
#81 red team attack → **Phase 6.1**. #82 Audit Book → **Phase 6.2**. #85 interface version bump +
cascade → **Phase 7.1-7.2**. #83 redeploy → **Phase 7.3-7.4**.
#80 UI incorporation desktop (grafted onto pantheonic) → **Phase 8A**. #84 mobile translation → **Phase 8B**.
#86 comprehensive documentation + website publication → **Phase 9**.
