# DALOS Audit — cycle log & status tracker

Home for all audit data on **the rest of Stage 1** — every module *not* claimed by the sibling `ATS/`
and `SWP/` audits in this same `Audit/` directory. Structured as the **sibling** of those two audits and
of the AQP audit (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/`) — same cycle, same rigor, same format.
Goal: a **comprehensive, evidence-backed sign-off that the code we ship is correct** — for every path,
"if X and Y and Z happen, the outcome is P, and P is correct."

Named `DALOS` after the flagship module of this remaining surface (account/gas/fuel core), not because
the audit is limited to `01_DALOS.pact` — scope is the **entire rest of Stage 1**, per owner instruction
2026-08-22: "everything in stage 1, not related to ATS (so no ATS and ATSU) and not related to SWP
(modules from SWPT to MTX-SWP)... basically the whole of Stage 1 modules."

## Scope — enumerated from `MODULE-INDEX.md` + direct file/content reads, not guessed

**Excluded (owned by sibling audits, do not duplicate):**
- `ATS/` owns: `08_ATS.pact`, `10_ATSU.pact`, `1_Utilities/09_U_ATS.pact`, `1_Utilities/10_U_DPTF.pact`,
  the ATS/ATSU section of `3_Talos/03_TS01-C2.pact` + wiring slivers in `01_TS01-A.pact` /
  `02_TS01-C1.pact` / `05_TS01-P.pact`, interfaces `AutostakeV2`, `AutostakeUsageV1`,
  `AutostakeComputerV1`, `BrandingUsagePrimaryV1`, `UtilityAtsV2`.
- `SWP/` owns: `1_Utilities/12_U_SWP.pact`, `1_Utilities/13_U_BFS.pact`, `14_SWPT.pact`, `15_SWP.pact`,
  `16_SWPI.pact`, `17_SWPL.pact`, `18_SWPLC.pact`, `19_SWPU.pact`, `20_MTX-SWP.pact`, `3_Talos/04_TS01-C3.pact`
  (fully), `3_Talos/05_TS01-P.pact` (fully), interfaces `SwapperV3`, `SwapperIssueV3`,
  `SwapperLiquidityV1`, `SwapperLiquidityClientV1`, `SwapperUsageV2`, `SwapperMtxV3`, `SwapTracerV1`,
  `UtilitySwpV1`, `BreadthFirstSearchV1`.

**In scope for this audit (10 clusters, run as parallel Round-I lenses):**

| Cluster | Modules / files | Interface(s) | REPL coverage |
|---|---|---|---|
| 1. DALOS/IGNIS/Fuel core | `01_DALOS.pact`, `02_IGNIS.pact`, `03_INFO-ZERO.pact`, `1_Utilities/08_U_DALOS.pact` | `OuronetDalosV1`, IGNIS/INFO-ZERO members of `OuronetPolicyV1`, `UtilityDalosV1` | `[2.1]_Dalos.repl`, `[6.1]_Cumulator.repl`, `[6.4]_Admin.repl` |
| 2. Legacy/Branding/Elite | `00_DPMF.pact` (historical, migration context only), `04_BRD.pact`, `07_ELITE.pact` | `BrandingV1` (BRD only — `BrandingUsagePrimaryV1` is ATS-owned) | grepped, no dedicated file — covered incidentally in `[2.2]_Core.repl`, `[4.0]_Sovereign-Executor.repl`, `[6.4]_Admin.repl`, `[6.5]_DPOF.repl` |
| 3. True Fungibles | `05_DPTF.pact`, `09_TFT.pact` | `OuronetPolicyV1` DPTF/TFT members | `[6.2]_DPTF.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` (DPTF half) |
| 4. Orto Fungibles | `06_DPOF.pact` | `OuronetPolicyV1` DPOF members | `[6.5]_DPOF.repl` |
| 5. Vesting/Liquid/Ouroboros + Talos client wiring | `11_VST.pact`, `12_LIQUID.pact`, `13_OUROBOROS.pact`, plus `VST\|C_*`/`LQD\|C_*`/`ORBR\|C_*` sections of `3_Talos/03_TS01-C2.pact` (**skip its `ATS\|C_*` section — ATS-owned**) | `OuronetPolicyV1` VST/LIQUID/OUROBOROS members, `TalosStageOne_ClientTwoV1` (non-ATS members) | `[6.7]_VST.repl`; LIQUID/OUROBOROS incidental in `[2.2]_Core.repl`, `[4.0]_Sovereign-Executor.repl`, `[6.2]_DPTF.repl` |
| 6. Identity/Info | `21_INFO-ONE+.pact` | `OuronetPolicyV1` INFO-ONE+ members | incidental in `[2.2]_Core.repl`, `[6.6]_ATS.repl` (read-only cross-reads) |
| 7. Oracle/Codex + Talos Client-Four | `22_CODEX.pact`, `23_PYTHIA.pact`, `3_Talos/06_TS01-C4.pact` (fully in scope — no ATS/SWP content) | `OuronetPolicyV1` CODEX/PYTHIA members, `TalosStageOne_ClientFourV6BlockTime` | `[6.9]_CODEX.repl`, `[6.10]_PYTHIA.repl`, `[6.10]_PYTHIA-flush-gas-probe.repl`, `[6.10b]_PYTHIA-ledger-v2.repl` |
| 8. Utility math helpers | `1_Utilities/01_U_CT.pact`, `02_U_G.pact`, `03_U_ST.pact`, `04_U_RS.pact`, `05_U_LST.pact`, `06_U_INT.pact`, `07_U_DEC.pact`, `11_U_VST.pact` | `01_Utilities.pact` non-ATS/SWP members | `[1]_Utilities.repl` |
| 9. Talos Admin + Client-One wiring | `3_Talos/01_TS01-A.pact` (**BRD/DALOS/DPTF/LIQUID/ORBR/TALOS sections only — skip its ATS and SWP sections**), `3_Talos/02_TS01-C1.pact` (fully — DALOS/DPOF/DPTF, no ATS/SWP content at all) | `TalosStageOne_AdminV1` (non-ATS/SWP members), `TalosStageOne_ClientOneV1` | `[3]_Talos.repl`, `[6.4]_Admin.repl` |
| 10. Interfaces cascade review | `0_Interfaces/01_Utilities.pact`, `02_Core.pact`, `03_Talos.pact` (**skip ATS-family and Swapper-family interface member declarations — those belong to the sibling audits**) | — (this cluster reviews cascade correctness, not one module) | `[0.1]_Interfaces.repl` |

Baseline REPL coverage note: `[6.5]_DPOF.repl`, `[6.6]_ATS.repl`, `[6.7]_VST.repl` are **not part of the
default `Stage01_Tester.repl` pipeline** as of this writing (commented out) — same gap the ATS audit's L4
flagged. Each cluster lens must run its own module's dedicated REPL file directly (not assume it's wired
into `Z.repl`) and note if it fails to load or is stale.

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Living — C1 (NOT A BUG), C2 (FIXED), C3 (FIXED), C4 (REFUTED/NOT A BUG), C5 (FIXED), H1 (REFUTED/NOT A BUG), H2 (FIXED), H3 (FIXED), H4 (FIXED), H5 (REFUTED/NOT A BUG), H6 (FIXED), H7 (FIXED), H8 (FIXED), H9 (FIXED), H10 (FIXED), H12 (FIXED), H13 (FIXED), H14 (FIXED, interim value), H15 (FIXED), N1 (FIXED, discovered live), N2 (FIXED, cross-audit handoff from DPDC), N3 (REFUTED, discovered mid-fix) recorded; H11 DEFERRED to the main-branch INFO-function project, H16 DEFERRED to the main-branch REPL test-infrastructure phase, H17 FINALIZED (not a bug, folded into the redeploy phase), H18/H19 (FIXED) (H11/H16/H17 not closed as a fix). **All CRITICAL and HIGH findings now closed** (fixed/refuted/deferred/finalized as appropriate — H11 and H16 remain deferred to main-branch phases, H17 finalized as a status note, everything else fixed or refuted). M1 (FIXED — first MEDIUM finding, re-verified live per the
owner's standing "confirm every bug in REPL first" instruction). Remaining work: MEDIUM
(#26M–#51M), LOW (#52L–#85L). |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Living — Fix #1 (C2), Fix #2 (N1), Fix #3 (C3), Fix #4 (C5), Fix #5 (H2), Fix #6 (H3), Fix #7 (owner-requested IGNIS Compress/Prime gas optimization, not a Round-I finding — equivalence-proven, real measured gas savings), Fix #8 (H4), Fix #9 (H10), Fix #10 (H6), Fix #11 (N2), Fix #12 (H7), Fix #13 (H8), Fix #14 (H9), Fix #15 (H12), Fix #16 (H13), Fix #17 (H14), Fix #18 (H15), Fix #19 (H18), Fix #20 (H19), Fix #21 (M1), Fix #22 (M2), Fix #23 (M4), Fix #24 (M5), Fix #25 (M6), Fix #26 (M7), Fix #27 (M9, doc-only), Fix #28 (M11), Fix #29 (M20), Fix #30 (M21), Fix #31 (LOW-cleanup batch —
#53L/#56L/#58L/#61L/#68L/#72L/#73L/#74L/#75L) landed. **All Round-I findings now closed.** |

**Numbering-mixup note (2026-08-24):** while presenting findings one at a time, the agent
accidentally skipped `#11H`–`#14H` (H6–H9) and mislabeled H10 (`ATS|INFO_Coil`) as "#11H" for
several turns before catching it — the exact class of mistake the SWP audit's own HARD RULE was
written to prevent. All four affected files were corrected back to the real ranking numbers before
continuing. `#11H`–`#14H` (H6–H9) have since all been presented and closed (H6/H7/H9 FIXED, H8
FIXED via removal).
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. *(not yet created)* |
| **IV+** | `ROUND-0N-*.md` | Repeat Fix → Re-verify until a re-verify round is clean. |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in place.
Module `.pact` source changes **only** during a Fixes round, one fix at a time. **This pass is audit-and-
document only — no code is being changed** (matching the ATS/SWP audits' Round I discipline).

## HARD RULE — no finding is "settled" until it's written down here

Same rule the SWP audit adopted after catching itself skipping findings silently: a finding is presented
**one at a time**, in `ISSUES-RANKED.md` order. The moment a verdict is reached — REFUTED, DESIGN,
DOC-FIX, CONVENTION, or FIXED — **before moving to the next finding**, the same turn must: (1) append the
verdict to `ROUND-01-OWNER-FEEDBACK.md`, (2) update this README's tracker row, (3) annotate
`ISSUES-RANKED.md`, (4) if code changed, add a numbered entry to `ROUND-02-FIXES.md` with diff + REPL
proof. A finding only discussed in chat and never landed in these files **is not closed**.

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean) · `DEFERRED` confirmed real,
but explicitly folded into a larger main-branch project instead of a piecemeal fix now (e.g. the
INFO-function coverage project — see Downstream plan below).

## Status tracker (living)

Round I is complete — all 10 cluster lenses returned and were compiled into `ROUND-01-FINDINGS.md` (full
write-ups) and `ISSUES-RANKED.md` (flat #1C→#51M+ ranking, plus N-series for post-Round-I discoveries;
LOW items are individually numbered #52L–#85L). 5 CRITICAL, 19 HIGH, 27 MEDIUM, 34 LOW findings, plus
several REPL-coverage-gap findings folded in at MEDIUM/LOW per the ATS-audit precedent (a coverage gap is
itself a finding, not a footnote), plus N1 (a genuinely new bug surfaced live during Fix #3's proof — see
below). Findings are presented one at a time in `ISSUES-RANKED.md` order per the HARD RULE above.

| ID | Sev | Module | Short | Status |
|----|-----|--------|-------|--------|
| C1 | ~~CRIT~~ | DPMF | ~~Entire module non-functional — no `create-table` calls~~ — **NOT A BUG** (owner, 2026-08-23): DPMF is the retired original MetaFungible module, intentionally dead after migration to DPOF; kept only for historical reference per CLAUDE.md. See `ROUND-01-OWNER-FEEDBACK.md`. | **NOT A BUG ✅** — closed, no code change |
| C2 | ~~CRIT~~ | DPOF | ~~`C_MoveCreateRole` never revokes prior holder's create/mint role~~ — owner confirmed intended semantics ("moving IS revoking"); real bug. Fixed by reordering the two internal writer calls. See `ROUND-02-FIXES.md` Fix #1. | **FIXED ✅ AND PROVEN ✅** — adversarial pre/post-fix REPL proof, full regression clean |
| C3 | ~~CRIT~~ | DPOF | ~~No nonce-uniqueness check — supply inflation + negative-supply corruption~~ — owner confirmed nonce lists must be unique; fixed via `UC_IzUnique` gates on `DPOF|C>DEBIT`/`C>TRANSFER`/`C>BULK-TRANSFER`. See `ROUND-02-FIXES.md` Fix #3. | **FIXED ✅ AND PROVEN ✅** — both sub-mechanisms reproduced pre-fix, rejected post-fix, full regression clean |
| N1 | ~~CRIT~~ | DPOF | ~~`C_Transmit` completely non-functional for every caller~~ — discovered live while building #3C's proof (field-name typo, unrelated to nonce duplication). See `ROUND-02-FIXES.md` Fix #2. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| C4 | ~~CRIT~~ | VST | ~~`C_Unreserve` checks issuer's ownership, not reserver's — funds stuck~~ — owner clarified: Reserve/Unreserve is a one-way escrow-for-purchase mechanism, not a symmetric lock; only the Token Manager is meant to unreserve. See `ROUND-01-OWNER-FEEDBACK.md`. | **NOT A BUG ✅** — closed, no code change |
| C5 | ~~CRIT~~ | INFO-ONE | ~~`DPOF\|INFO_UpgradeBranding` calls a nonexistent function (doubled prefix)~~ — confirmed typo, fixed. See `ROUND-02-FIXES.md` Fix #4. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H1 | ~~HIGH~~ | IGNIS/DALOS | ~~4 `XE_*` writers missing `SECURE`/named-cap second gate~~ — `UEV_IMC` alone is equivalent to `require-capability(SECURE)`; the sibling wrapper is structural (protects a shared internal writer), not extra authorization. See `ROUND-01-OWNER-FEEDBACK.md`. | **NOT A BUG ✅** — closed, no code change |
| H2 | ~~HIGH~~ | U_DALOS | ~~`GLYPH\|UEV_MsDc` charset fold inverted (OR/false vs AND/true)~~ — confirmed validates a whole account body via call-site check; fixed to true/and. See `ROUND-02-FIXES.md` Fix #5. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H3 | ~~HIGH~~ | IGNIS | ~~`C_Collect` no zero-leg filter — one zero-priced leg aborts whole batch~~ — fixed, ties into existing `IGNIS\|S>FREE` event. See `ROUND-02-FIXES.md` Fix #6. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H4 | ~~HIGH~~ | DPTF | ~~3 of 5 Toggle-Verum recipes missing `(UEV_IMC)`~~ — confirmed real gap (owner: "simply forgot to add the line"), fixed. See `ROUND-02-FIXES.md` Fix #8. | **FIXED ✅ AND PROVEN ✅** — 2/3 reproduced live, 3rd by code identity, full regression clean |
| H5 | ~~HIGH~~ | TFT | ~~Zero-amount leg aborts entire Multi(Bulk)Transfer batch~~ — owner: dying in place on invalid amounts is intended design, not a bug. See `ROUND-01-OWNER-FEEDBACK.md`. | **NOT A BUG ✅** — closed, no code change |
| H6 | ~~HIGH~~ | TFT | ~~`C_MultiBulkTransfer` never refreshes sender's Elite tier~~ — owner confirmed real bug ("its suppose to refresh for both sender and receiver"); fixed via `contains-eazs`-gated sender-side `XI_DynamicUpdateEliteAccount` call, mirroring `C_MultiTransfer`. See `ROUND-02-FIXES.md` Fix #10. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H7 | ~~HIGH~~ | DPOF | ~~`UPDATE-SPECIAL` immutability bypass via duplicated `cond` branch~~ — owner confirmed typo (`vzh` = vesting/sleeping/hibernation, 1/2/3); fixed. See `ROUND-02-FIXES.md` Fix #12. | **FIXED ✅ AND PROVEN ✅** — isolated logic proof broken pre-fix/fixed post-fix; call-path nuance (not actively exploitable via the one wired caller) disclosed; full regression clean |
| H8 | ~~HIGH~~ | LIQUID | ~~`C_RegisterOuronetAccountForUrstoaHoldings` zero ownership check~~ — owner: function unnecessary, UI-constructed tx pattern already solves this more safely; removed outright. See `ROUND-02-FIXES.md` Fix #13. | **FIXED ✅ AND PROVEN ✅** — zero-caller removal confirmed via repo-wide grep, full regression clean |
| H9 | ~~HIGH~~ | U_VST | ~~`UEV_MilestoneWithTime` no lower bound — past-dated locks (2 lenses)~~ — fixed via non-negativity `enforce` on `offset`/`duration`. See `ROUND-02-FIXES.md` Fix #14. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H10 | ~~HIGH~~ | INFO-ONE | ~~`ATS\|INFO_Coil` wrong-token/reversed-direction cumulator~~ — fixed to match real execution function + correct sibling pattern. See `ROUND-02-FIXES.md` Fix #9. | **FIXED ✅ AND VERIFIED ✅** — live cost match confirmed, differential proof limitation disclosed |
| H11 | HIGH | INFO-ONE | `ATS\|INFO_ColdRecovery` duplicate `ifp3` binding drops a leg's cost — confirmed real, deferred to the INFO-function coverage project (owner, 2026-08-27). | **DEFERRED** — not fixed now, folded into the main-branch INFO-function project |
| H12 | ~~HIGH~~ | PYTHIA | ~~Admin price setters unreachable — never wired into Talos~~ — owner: "forgot to wire them"; added to TS01-C4. See `ROUND-02-FIXES.md` Fix #15. | **FIXED ✅ AND PROVEN ✅** — reproduced unreachable pre-fix, working post-fix, full regression clean |
| H13 | ~~HIGH~~ | U_VST | ~~`milestones=1` silently drops `offset` (2 lenses, MED/HIGH split)~~ — fixed (`present-time` → `first-time`). See `ROUND-02-FIXES.md` Fix #16. | **FIXED ✅ AND PROVEN ✅** — reproduced broken pre-fix, working post-fix, full regression clean |
| H14 | ~~HIGH~~ | U_CT | ~~`UR\|KDA-PID` price oracle is a hardcoded `1.0` stub~~ — owner: no oracle yet, updated placeholder to `0.1` (mainnet approx.); real oracle wiring deferred. See `ROUND-02-FIXES.md` Fix #17. | **FIXED ✅** — interim value, live-confirmed, full regression clean |
| H15 | ~~HIGH~~ | U_DEC | ~~`UC_AddHybridArray` corrupts/crashes on empty input~~ — no current caller triggers it; fixed with a purely additive guard, zero change to the existing path. See `ROUND-02-FIXES.md` Fix #18. | **FIXED ✅ AND PROVEN ✅** — exact crash reproduced pre-fix, clean output post-fix, existing behavior confirmed byte-identical |
| H16 | HIGH | Talos Admin | ~Half of admin surface untested; Admin suite asserts nothing — confirmed real, deferred to the main-branch REPL-test-backfill/test-infrastructure-refactor phase (owner, 2026-08-27). | **DEFERRED** — not fixed now, folded into the main-branch test-infrastructure project |
| H17 | ~~HIGH~~ | DPOF/TS01-C1 | ~~V2 cascade ready locally, not yet deployed live~~ — owner: expected status after a change that warranted a version bump; redeploy (DPOF before TS01-C1) folded into the already-planned StoicSyntax/version-bump/redeploy phase. | **FINALIZED — not a bug, folded into the redeploy phase** |
| H18 | ~~HIGH~~ | OUROBOROS | ~~`C_SublimateV2` live but missing from `OuroborosV1`~~ — confirmed real, added to the interface (purely additive, no bump needed). See `ROUND-02-FIXES.md` Fix #19. | **FIXED ✅ AND VERIFIED ✅** — full regression clean, no behavioral change |
| H19 | ~~HIGH~~ | CODEX | ~~4 live `C_*` functions missing from `CodexV1` entirely~~ — added all four, purely additive. See `ROUND-02-FIXES.md` Fix #20. | **FIXED ✅ AND VERIFIED ✅** — full regression clean, no behavioral change |
| M1 | ~~MED~~ | DALOS | ~~`C_RotateKadena` orphans the old kadena address's ledger row~~ — re-verified live per owner's standing instruction; fixed by reading the old address before the overwrite. See `ROUND-02-FIXES.md` Fix #21. | **FIXED ✅ AND PROVEN ✅** |
| M2 | ~~MED~~ | DALOS | ~~Smart-account deploy validation misplaced in `XI_*` writer~~ — fixed with a new admin cap composing the shared validation cap, no duplication; `XI_DeploySmartAccount` now a pure writer. See `ROUND-02-FIXES.md` Fix #22. | **FIXED ✅ AND VERIFIED ✅** |
| M3 | MED | DALOS | `GAS_PAYER` allowlist matches by string prefix — owner: intentional, every real Talos module is deliberately `TS`-prefixed by naming convention. No code change. | **NOT A BUG ✅** — closed, intentional design |
| M4 | ~~MED~~ | TFT | ~~`C_ClearDispo` unconditionally force-unfreezes the EA account~~ — re-verified live; fixed by mirroring the initial-freeze guard onto the final unfreeze. See `ROUND-02-FIXES.md` Fix #23. | **FIXED ✅ AND PROVEN ✅** |
| M5 | ~~MED~~ | TFT | ~~Stale `dispo-data` snapshot across multi-transfer legs~~ — real overdraft-inflation exploit confirmed live, more severe than ranked; fixed by recomputing per-leg in both multi-transfer functions. See `ROUND-02-FIXES.md` Fix #24. | **FIXED ✅ AND PROVEN ✅** |
| M6 | ~~MED~~ | DPTF | ~~`UR_Hibernation` read-that-writes~~ — live chain check via Pythia dirty-read confirmed zero gaps on all 18 real tokens; simplified to a pure getter, no migration needed. See `ROUND-02-FIXES.md` Fix #25. | **FIXED ✅ AND VERIFIED ✅** |
| M7 | ~~MED~~ | DPOF | ~~`URC_Parent` contains a direct `enforce`~~ — confirmed live-reachable (Sleeping LP tokens are sanctioned, not yet created); fixed by relocating the enforce to `UEV_ParentOwnership`. See `ROUND-02-FIXES.md` Fix #26. | **FIXED ✅ AND PROVEN ✅** |
| M8, M19, M26, M27 | ~~MED~~ | DPOF/U_LST/U_VST/Docs | ~~Naming/prefix/doc-convention violations (`C_WipeHeavy` not `CC_`-prefixed, `UC_*` functions enforcing, interface-versioning docs gaps)~~ — batch-deferred to the StoicSyntax sweep (owner, 2026-08-28), along with 13 similar LOW findings (#57L, #65L, #66L, #69L–#71L, #76L–#78L, #80L–#82L, #84L). See Downstream plan phase 4. | **DEFERRED to StoicSyntax sweep** |
| M9 | ~~MED~~ | DPOF | ~~`AHU`/`AUP_OrtoFungible*` hardcoded-account admin-migration path~~ — owner: intentional, completed DPMF→DPOF migration utility, same retention logic as DPMF/#1C; documented as historical, not fixed. See `ROUND-02-FIXES.md` Fix #27. | **NOT A BUG ✅ — closed, documented** |
| M10 | ~~MED~~ | Talos Admin | ~~Two dead capabilities, one a registered-but-unreachable DALOS governor slot~~ — owner: not forgotten, if it were needed it would already be used; deferred to the post-redeploy red-team pass to empirically confirm. See Downstream plan phase 6. | **DEFERRED to red-team pass** |
| M11 | ~~MED~~ | Talos C1 | ~~`DPOF|C_TogglePause`/`C_ToggleFreezeAccount` dead binding + missing message~~ — fixed, mirrors correct DPTF sibling pattern. See `ROUND-02-FIXES.md` Fix #28. | **FIXED ✅ AND VERIFIED ✅** |
| M12, M13 | ~~MED~~ | DPMF | ~~Stale duplicate Elite-Auryn accounting; malformed `format` call~~ — owner: DPMF permanently out of scope, will never be upgraded again; no landmine risk. No code change. | **NOT A BUG ✅ — closed, out of scope** |
| M14, M17, M23–M25 | ~~MED~~ | BRD/ELITE, INFO-ONE, CODEX/PYTHIA | Test-coverage-only findings — formally deferred to the REPL test-infrastructure phase (#21H/H16); previously cross-referenced only, now struck through in `ISSUES-RANKED.md` for consistency. | **DEFERRED to REPL test-infrastructure phase** |
| M15, M16 | ~~MED~~ | INFO-ONE | INFO-function-family findings — formally deferred to the INFO-function coverage project (#16H/H11). | **DEFERRED to INFO-function coverage project** |
| M18 | ~~MED~~ | U_RS | ~~`UEV_EnforceReserved` "over-blocks" legitimate non-principal names~~ — resolved: verbatim port of Kadena's own official `coin.pact` `enforce-reserved`, intended upstream behavior, not a bug; zero callers here, left as-is. | **NOT A BUG ✅ — closed** |
| M20 | ~~MED~~ | U_LST | ~~`UC_IzUnique` can never return `false`~~ — no live functional bug, but a real doc-contract-mismatch risk for future callers; renamed to `UEV_IzUnique` and doc corrected. See `ROUND-02-FIXES.md` Fix #29. | **FIXED ✅ AND VERIFIED ✅** |
| M21 | ~~MED~~ | U_INT | ~~`UC_MaxInteger` crashes uncatchably on an empty list~~ — confirmed live (not even `try`-catchable), reachable through a real Stage-2 `DPDC-S` entrypoint (out of scope to fix there); renamed to `UEV_MaxInteger` with a real `enforce` guard (same shape as #44M/M20). See `ROUND-02-FIXES.md` Fix #30. | **FIXED ✅ AND PROVEN ✅** |
| M22 | ~~MED~~ | U_INT | ~~`UEV_ContainsAll` checks set membership, not multiset containment~~ — confirmed live real; sole live caller is DPMF (`S>MULTI-BATCH-TRANSFER` nonce check), permanently out of scope per #36M/#37M. No code change. | **NOT A BUG ✅ — closed, out of scope** |
| N2 | ~~MED~~ | TFT/DPOF (Talos) | ~~`DPTF\|C_DeployAccount`/`DPOF\|C_DeployAccount` ungated public entrypoints — griefing surface.~~ Surfaced via DPDC-audit handoff (their #35M). Fixed: ownership gate on `C_DeployAccount` (self-service) + new admin-gated `A_DeployAccount` (TS01-A) for system setup, all known callers redirected. See `ROUND-02-FIXES.md` Fix #11. | **FIXED ✅ AND PROVEN ✅** |
| N3 | ~~CRIT?~~ | TS01-A | ~~`DPTF\|A_UpdateTreasuryDispoParameters`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial` gated only by bare-true `P\|TS`~~ — core layer independently enforces real `GOV\|DPTF_ADMIN` check; live-confirmed unauthenticated signer rejected. Same shape as #6H. | **REFUTED ✅ NOT A BUG** |
| L-items (13 deferred) | LOW | various | #57L, #65L, #66L, #69L–#71L, #76L–#78L, #80L–#82L, #84L — naming/prefix/style-only, batch-deferred to StoicSyntax sweep (owner, 2026-08-28), see Downstream plan phase 4. | **DEFERRED to StoicSyntax sweep** |
| #83L, #85L | ~~LOW~~ | Interfaces | ~~Dead/orphaned frozen interfaces (sanctioned by policy); `[0.1]_Interfaces.repl` is a smoke test by design~~ — Round-I's own write-up already confirmed both are non-issues; formally closed 2026-08-28, no code change. | **NOT A BUG ✅ — closed** |
| #55L, #59L, #60L, #64L, #79L | ~~LOW~~ | DALOS/IGNIS, DPTF/TFT, DPOF, VST/LIQUID/OUROBOROS, Utilities | Test-coverage-only findings — formally deferred to the REPL test-infrastructure phase; now struck through in `ISSUES-RANKED.md` for consistency. | **DEFERRED to REPL test-infrastructure phase** |
| #67L | ~~LOW~~ | INFO-ONE | INFO-function-family finding — formally deferred to the INFO-function coverage project. | **DEFERRED to INFO-function coverage project** |
| #53L, #56L, #58L, #61L, #68L, #72L, #73L, #74L, #75L | ~~LOW~~ | DALOS/ELITE/TFT/OUROBOROS/PYTHIA/U_CT/U_VST/U_LST | Nine small, independent, purely additive/subtractive/textual fixes — bound check, dead-code removal ×4, stale doc, tautology simplification, typo, message-consistency fix. Zero behavioral change to any real caller. See `ROUND-02-FIXES.md` Fix #31. | **FIXED ✅ AND VERIFIED ✅** |
| #52L | ~~LOW~~ | DALOS | `URD_AccountCounter` — undeclared, zero internal callers, same shape as the INFO-function-family bucket. | **DEFERRED to INFO-function coverage project** |
| #54L | ~~LOW~~ | DALOS | Self-referential `ref-DALOS::` call + hardcoded-account migration tool — same shape as #33M/M9, same owner verdict applied. | **NOT A BUG ✅ — closed, documented** |
| #62L | ~~LOW~~ | LIQUID | `UEV_Amount` defined but never called — ambiguous whether downstream `C_Mint`/`C_Transfer` already cover the same check; same shape as #34M/M10. | **DEFERRED to red-team pass** |
| #63L | ~~LOW~~ | LIQUID | Native KDA `install-capability` supplied externally by off-chain "JavaCode," untestable in Pact REPL — architectural limitation, not a bug. | **NOT A BUG ✅ — closed, documented limitation** |
| — | — | — | **All Round-I findings now closed.** Every CRIT/HIGH/MED/LOW item (plus N1–N3) is fixed/proven, refuted/not-a-bug, or formally deferred to a named downstream phase. | **ROUND I COMPLETE ✅** |

## Method (Round I)

One deep-read lens-auditor per module cluster (10 clusters enumerated in the scope table above), run in
parallel, each briefed with the same rigor/format contract as the ATS and SWP audits: load
`OuronetInformational/SKILL.md` → `StoicSyntax.md` first, work read-only, assume nothing is correct
despite being live on mainnet, trace every path (prefix-contract compliance, defcap/enforce placement,
cascade/interface-version correctness, math correctness, dead code, missing bounds/locks, REPL coverage
gaps), and report findings with severity (CRIT/HIGH/MED/LOW), exact file:line, failure scenario, and a
CONFIRMED/PLAUSIBLE confidence tag — same verification-tag discipline as the ATS/SWP Round I docs.

## Downstream plan (per owner, 2026-08-22, extended 2026-08-24)

Once Round I findings are compiled and the owner has ruled on each (mirroring the ATS/SWP Fix cycle),
the plan is:
1. Close out this audit's fix/re-verify rounds.
2. Merge this audit (and the in-progress SWP audit) into main.
3. **New phase, added 2026-08-24 — INFO-function coverage project** (owner-scoped, deliberately
   *not* part of this audit or the StoicSyntax sweep, big enough to warrant its own dedicated work):
   every real `C_*` user-facing function is supposed to have a matching `MODULE|INFO_*` UI-preview
   counterpart (see `OuronetInformational/memories/2026-08-24-info-functions-are-ui-facing-not-dead-code.md`
   for what these functions are and why they have no on-chain callers by design). Many are still
   missing across **both** Stage 1 and Stage 2 — owner has been writing them by hand as UI buttons
   get added, and a large number remain unwritten. This future phase needs to: enumerate every `C_*`
   across Stage 1 + Stage 2, confirm which already have a matching `INFO_*`, audit the existing ones
   for correctness against their real counterpart's actual cost/behavior (an `INFO_*` function can be
   as complex as the `C_*` it mirrors), and write the missing ones. Do this **after** both audits are
   merged to main, **before** the StoicSyntax sweep below. **Deferred findings folded in here (fix
   during this phase, not now):** H11 (`ATS|INFO_ColdRecovery` duplicate `ifp3` binding drops the
   Transfer-leg cost from the total — confirmed real, owner: "rearchitecting the whole INFO function
   architecture is part of a bigger scope to be done on main from top to bottom," 2026-08-27).
3a. **Existing main-branch phase — REPL test-infrastructure backfill/refactor** (owner, 2026-08-27):
   main already has a planned phase for filling in missing REPL tests and refactoring the test
   infrastructure as a whole. **Deferred findings folded in here:** H16 (roughly half of
   `TalosStageOne_AdminV1`'s in-scope surface — DALOS/LIQUID/DPTF migration and treasury-debt admin
   functions — has zero effective REPL exercise, and the dedicated `[6.4]_Admin.repl` suite asserts
   nothing at all; same coverage shape that let ATS's N3/C3 ship silently). Owner: "if its test
   coverage, we deffer to work on mane and filanzse, main has a phase for filling in repl tests that
   are missing and refactor the whole test infrastructure." Any future test-coverage-only finding
   from this audit should default to this same deferral unless the owner says otherwise.
3b. **New phase, added 2026-08-28 — schema-field-backfill-on-read sweep** (owner-scoped, from
   #30M/Fix #25): `DPTF::UR_Hibernation` was found to be a `UR_*` read that silently performed a
   live table `update` to backfill a `hibernation-link` field added to the schema after the module
   had already shipped with rows lacking it — a read/write-separation violation. Checked live
   StoaChain via Pythia's dirty-read relay, confirmed zero real gaps (all 18 deployed DPTF tokens
   already had the field), so no migration function was needed; simplified directly to a pure
   getter. **Owner's instruction:** "there are multiple other functions like these that are
   modified to also write when reading, only to fill new fields that are added due to a schema
   being modified... if there are similar issues to this one in our list, we defer them to the
   work on main repository, referring to this entry." Round I did not specifically search for this
   exact shape across the whole codebase — only this one instance was caught, incidentally. A
   dedicated sweep (grep for `UR_*`/`UR|*` functions containing `update`/`write`/`insert`, then
   apply the retirement playbook) is needed on main. Full methodology — how to spot instances, how
   to write this pattern correctly if genuinely still needed, and how to safely retire an existing
   instance (sample live chain via Pythia, backfill via a real one-time admin migration function
   only if gaps are found, then strip the write) — is captured durably in
   `OuronetInformational/ouronet/conventions/schema-field-backfill-on-read.md`. **Any finding in
   this audit's own list (present or future) matching this exact shape should be deferred to this
   sweep, citing this entry, rather than fixed piecemeal here.**
4. Apply the StoicSyntax discipline across the whole of Stage 1 (this audit's scope + the
   already-merged ATS work + the SWP work), issuing new interface versions where the cascade rule
   requires it. **Folded in here (from #22H/H17, finalized 2026-08-27):** `DemiourgosPactOrtoFungibleV2`
   (`06_DPOF.pact:214-227` — `C_BulkTransfer`, `UEV_EnforceSegmentationForTransmit`) and
   `TalosStageOne_ClientOneV2` (`3_Talos/02_TS01-C1.pact:87-99,1349-1364` — wires
   `DPOF|C_BulkTransfer`) are already fully cascaded and correct locally; live `describe-module`
   confirms deployed DPOF/TS01-C1 are still V1 only. Owner: "we modified stuff that warranted
   interface version bump... we are going to bump anyway the interface version across the board...
   with the work we'll be doing on main." No action needed beyond this phase's own redeploy.
   **Also folded in here — batch-deferred naming/prefix/doc-convention findings (owner, 2026-08-28):**
   after fixing #32M (`DPOF|C_WipeHeavy` not renamed to the `CC_`/`AA_` HEAVY convention despite its
   own `@doc` describing the anti-pattern — also found duplicated verbatim in Stage 2's
   `06_DPDC-MNG.pact`), owner asked for all similar findings in this audit's list to be identified and
   deferred the same way. Batch:
   - **#43M/M19** — `U_LST`/`U_VST` `UC_*` functions performing `enforce` (its own write-up recommends
     "rename to `UEV_*`/`URC_*` or a repo-wide CONVENTION verdict").
   - **#50M/M26, #51M/M27** — `INTERFACE_VERSIONING.md`/`MODULE-INDEX.md` doc gaps, naturally corrected
     alongside this same phase's interface-version bumps.
   - **13 LOW items** — #57L (stale DPMF naming), #65L (`UC_LpFuelToLpStrings` raw enforce, same shape
     as #43M), #66L (`UCX_*`/`UCXX_*` pre-migration spelling), #69L (`UR_AWT|ListByCodex` should be
     `URD_`/`URDC_`), #70L (defcap body-order deviations, style only), #71L (PYTHIA price-setters
     acquire `SECURE` inline instead of a named cap), #76L (self-referential module-ref style),
     #77L (`UR|KDA-PID` section-placement mismatch), #78L (harmless `UC_Search` `enumerate` off-by-one
     — also bound by the standing "never touch `U|LST::UC_Search`" instruction), #80L (Talos wrapper
     naming drift vs. core-module counterparts — the exact same shape as #32M), #81L (misnamed
     `GOV|MD_DPTF` constant in `04_BRD.pact`), #82L (~12 client wrappers missing the CLAUDE.md-mandated
     `format` result string), #84L (inconsistent "Frozen —" `@doc` labeling).

   **Explicitly NOT included in this batch** (already have their own, separate deferral buckets from
   earlier in this audit, not re-deferred here to avoid double-tracking): test-coverage-only findings
   (#38M/M14, #41M/M17, #47M/M23, #48M/M24, #49M/M25, #55L, #59L, #60L, #64L, #79L — see phase 3a,
   H16's REPL-test-infrastructure deferral) and INFO-function-family findings (#39M/M15, #40M/M16,
   #67L — see phase 3, H11's INFO-function-coverage-project deferral). Everything else in the
   MEDIUM/LOW list (real bugs, dead code, semantic gaps like #33M/M9, #42M/M18, #44M/M20, #45M/M21,
   #46M/M22, etc.) remains open for individual presentation, per the audit's normal one-at-a-time
   cadence.
5. Redeploy the full Stage 1 surface to StoaChain. **DPOF must redeploy before TS01-C1** (per
   #22H/H17 — TS01-C1's V2 wiring depends on DPOF's V2 already being live).
6. **New phase, added 2026-08-28 — red-team pass** (owner-scoped, happens after redeploy): a
   dedicated adversarial/security-testing pass against the live redeployed system. **Deferred here
   (from #34M/M10):** `TS01-A::P|GOVERNING-SUMMONER`/`P|SECURE-SUMMONER` are defined but never
   called anywhere in the repo; `P|GOVERNING-SUMMONER` is the only composer of `P|TRG`, whose
   capability-guard is registered as `"TS01-A|RemoteDalosGov"` and folded into DALOS's own smart
   account's governor `guard-of-any` list (alongside `TFT|RemoteDalosGov`/`ORBR|RemoteDalosGov`/
   `SWPU|RemoteDalosGov`, all three of which — confirmed via `TFT`'s `P|DALOS|REMOTE-GOV` — are
   actually wired to a real composer, unlike TS01-A's). Owner: "since its done in the TS01-A
   module, and its never used in this module, it means it isnt needed, otherwise i would have used
   it... i dont think i forgot to simply wire it in... when well be runing a red team attack at the
   end, well see if its needed or not." Not fixed now — revisit during this phase to empirically
   confirm whether DALOS's governor still resolves correctly without this path (e.g. attempt to
   exercise every entry in `dalos-sc`'s `guard-of-any` list and confirm the other three cover
   real recovery scenarios on their own). **Also deferred here (from #62L, 2026-08-29):**
   `LIQUID::UEV_Amount` is defined but never called anywhere — confirm during this phase whether
   `DPTF::C_Mint`/`TFT::C_Transfer` (LIQUID's actual downstream calls in `C_WrapStoa`/
   `C_UnwrapStoa`/etc.) already enforce the same KDA-precision check internally via each token's
   own precision setting, making this dead validation helper genuinely redundant rather than a gap.

**Other deferred item (owner, 2026-08-27, from #19H):** `U_CT::UR|KDA-PID` has no live KDA/USD
oracle wired up; it's currently hardcoded to `0.1` (mainnet's approximate value) as an interim
placeholder. Wire up the real `dia-oracle.get-value "KDA/USD"` call (already present, commented out,
at `1_Utilities/01_U_CT.pact:166`) once a live oracle is available — no target date, blocked on
oracle availability, not on any of the phases above.

This README will be updated with links to that work as each phase starts.
