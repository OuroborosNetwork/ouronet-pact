# AQP Audit — cycle log & status tracker

Home for all audit data on the five AQP modules (`01_ANK`, `02_SCORE`, `03_AQP`/POOL,
`04_FVT`, `05_VCT`). Goal: a **comprehensive, evidence-backed sign-off that the code we ship is
correct** — for every path, "if X and Y and Z happen, the outcome is P, and P is correct."

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Frozen. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Diff summary + why. |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. New findings restart the cycle. |
| **IV+** | `ROUND-0N-*.md` | Repeat Fix → Re-verify until a re-verify round is clean. |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in
place. Module `.pact` source changes **only** during a Fixes round, one fix at a time.

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean).

## Status tracker (living)

| ID | Sev | Module | Short | Verify | Verdict / status |
|----|-----|--------|-------|--------|------------------|
| C1 | CRIT | VCT | OF/DPSF/DPNF vacate legs unbound to staked rows | CONFIRMED | **FIXED ✅ (#3)** — Z.repl green; neg-test pending R-III |
| C2 | CRIT | FVT | inject divisor `S` captured pre-sync | CONFIRMED | **FIXED ✅ (#4)** — Z.repl green; conservation neg-test pending R-III |
| H1 | HIGH | SCORE | LP base delta, no floor → negative base | PLAUSIBLE | **FIXED ✅ (#7)** — LP Level-1 now AMOUNT×mx (not value); Z.repl green; drift neg-test pending R-III |
| H2 | HIGH | POOL | stake reopen ignores `vacate-in-progress` | PLAUSIBLE | **FIXED ✅ (#5)** — Z.repl green; neg-test pending R-III |
| H3 | HIGH | VCT | `finalize` re-enables pool-wide, no remaining/stream check | PLAUSIBLE | **FIXED ✅ (#6)** — Z.repl green; TX-VCT-N03 now asserts correct behavior; LP dual-stream neg-test pending R-III |
| H4 | HIGH | ANK | revoke leaves stale user aggregate promile | CONFIRMED | **TEMP-PATCHED ✅ (#9)** — Option B lock-while-employed (`BoostClassLinkCount`); golden+Z green, lock armed (B/S/G=1). ⚠️ unwind (sweep/unlink) UNFINISHED — see `ANCHOR-STALENESS-INVENTORY.md` |
| H5 | HIGH | FVT/SCORE | triplet Tier-2 divisor = unbounded `select` | CONFIRMED | **FIXED ✅ (#8)** — maintained snapshot aggregate (`total-lane-weight`/`contrib-weight`); scan deleted; golden+Z green; multi-staker Σ proven. Discriminator corrected in #25 (true-triplet, not class). |
| S4 | HIGH | FVT | triplet reward math keyed on FVT class, not true-triplet flag (surfaced by #8) | CONFIRMED | **FIXED ✅ (#25)** — branches on `UR_SCR|TripletTrueTriplet` (any class): true→lanes, non-true→Σ-deb; class-agnostic lane precision; golden+Z green. Non-true/vault-triplet tests → Round III. |
| M1 | MED | FVT | `unclaimed-count==1` dust-sweep missing | CONFIRMED | **DONE ✅ (#10)** — two-tier dual sweep (`FVT|T|MemberVault` + global) + per-member count + precision fallback (dust lanes → token-0); **drain-proof green** (both vaults → exactly 0). golden 31/0, Z 225/0 |
| M7 | — | ATSU | ATS `C_Coil`/`C_Curl` revert when a tiny input's pool-index conversion rounds below token precision to 0 | REFUTED | **NOT A BUG (owner, by-design)** — precision artifact: amounts within ~1 ulp of max precision are unusable for Coil/Curl by design; adding a distance-to-precision wrapper was a deliberate non-goal. Impacts #10 only for *sub-precision* triplet dust (economically zero). |
| M2 | MED | FVT | vault/treasury inject `keys` scan in defcap | CONFIRMED | **DONE ✅ (#11)** — inject point-reads maintained `total-deb-score` mirror; mirror kept incrementally from live deb (stake delta + toggle/add ±), no cache; `keys`-scan deleted. golden 31/0, Z 225/0 |
| M3 | MED | SCORE | boost-class promile <1000 zeros rewards | CONFIRMED | **DONE ✅ (#12) — Part 1 + 2a–2e all built + proven** (golden 33/0, Z 225/0, deb-proof 110/0; only `N_FIX` defpact chunk calibration deferred). 2c `CC_Inject` (single-tx enforced-fresh inject), 2d `MTX-AQP` module (`MTX\|2\|C_Inject` defpact + `C\|2_Inject` + Talos wrapper, proven via continue-pact), 2e IGNIS forced-fix penalty. Detail in `ROUND-02-FIXES.md`. Older notes below. **2b collect-backstop REBUILT + PROVEN:** PHASE 6 = snapshot pre-deb → `XE_RefreshUserScoreDeb` → `XI_SyncFvtTotalDebMirrors` (resync mirror by Δdeb); true-triplets guarded out. New `REPL/deb-staleness-proof.repl` moves ANHD's live Elite-DEB 4.29→1.39 and proves collect refreshes stored-deb 4290→1390 + resyncs mirror with **Δmirror=Δstored=−2900** (conservation); negative-control confirms the test catches the desync. Also fixed a **treasury-collect regression I'd introduced in #10** (member-vault sweep now farm-only) + 2 stale tests. golden 33/0, Z 225/0, deb-proof 79/0. **Still TODO:** 2c enforced-fair inject, 2d InjectSweep defpact, 2e IGNIS penalty. Design: `M3-DEB-DESIGN.md`. |
| M4 | MED | SCORE | links/deb-boost settable after positions | CONFIRMED | **DONE ✅ (#13)** — boost-class-link/boost-link/deb-boost setters now gate on `nzs-count == 0` (one-time slot checks dropped); config is re-settable only while the score is EMPTY (vacate to reconfigure). `XI_CreateBoostClassLink` moves the H4 #9 revoke-lock count on re-point (−1 old / +1 new); new ANK `XE_UnbumpBoostClassScoreLinks`. Proven `deb-proof DEB09`: populated Bunnies (nzs=1) rejects both setters; vacated WonderCoach (nzs=0) accepts + slot moves. golden 33/0, Z 225/0, deb-proof 113/0 |
| M5 | MED | POOL | OF/collectable unstake self-key vs non-self stake | CONFIRMED | **DONE ✅ (#14)** — non-self staking (self OR foreign beneficiary) made first-class for ALL asset types. Threaded `beneficiary-id` through the OF/SF/NF unstake chain like TF; dropped the `BAR` sentinel + self-key derivation. Supply-beneficiary unstake confirmed final (reverse-index/derive model rejected: SF/NF co-ownable + splittable ⇒ one `(owner,nonce)` → many legs). **UI observability**: 8 cross-pool `select` readers `URD_AQP|{Dptf,Dpof,Dpsf,Dpnf}StakesBy{Owner,Beneficiary}` answer A(self)/B(for-others)/C(gifted) on-chain — no new tables. **Dead code removed**: the never-wired `DP{S,N}FScoreAttribution` cluster (schemas/tables/UCK/UDC/~24 readers/decls) deleted. Proven `[6.2.4]` TX-FVT-06b (OF, +reader asserts) + TX-FVT-DC-03b (SF). golden 33/0, Z 241/0, deb-proof 121/0 |
| M6 | MED | ANK | TF promile pro-rate vs doc | CONFIRMED | **DONE ✅ (#2 doc + #15 guard)** — `UEV_Promile` now enforces `anchor-precision = 3` exactly + `ank-promile ∈ [1, 10000]` (conform to prec-3); `ANK\|C>ISSUE-DPTF` adds `dptf-amount ∈ [1000, 1,000,000]`. Owner-set ceilings; fits the mainnet AQP-BOOT NF anchors (prec 3, promile ≤3500). Test anchors migrated (prec 8→3; TF promile+amount ×10 leverage-preserving). Boundary rejections proven `[6.2.1]` TX001·05b. golden 33/0, Z 241/0, deb-proof 121/0 |
| L1 | LOW | POOL | `enforce` in a `URC_` | CONFIRMED | **DONE ✅ (#16)** — `URC_OrtoStakeWholeNonceAmounts` wasn't just a misplaced `enforce`, the whole check was **tautological**: `DPOF::C_Transfer` moves WHOLE nonces (ignores amounts) and callers source `nonce-amounts` from `UR_NoncesSupplies`, so "amount == nonce supply" compared a value to its own source. Deleted the helper + `whole-nonce-ok` from both caps; whole-nonce is a structural token-layer invariant. Pattern written up in `memories/2026-08-14-tautological-validation-checks.md` (hunt for more). golden 33/0, Z 241/0, comprehensive 260/0 |
| L2 | LOW | POOL | one X writes two tables | PLAUSIBLE | **CONVENTION R2** (allowed) |
| L3 | LOW | POOL | `select`/URD on sync path | PLAUSIBLE | **CONVENTION R3** (→ `CC_`/`AA_` rename) |
| L4 | LOW | ANK | no `UEV_LiveAnchor` on revoke | CONFIRMED | **DONE ✅ (#17)** — added `(UEV_LiveAnchor anchor-id)` as the first check in `ANK|C>REVOKE` (revoke sets `State→false`, so a double-revoke now aborts early + clearly instead of deep in `UC_RemoveItemAt`; the H4 lock never reads a dead anchor). Was the unused `UEV_LiveAnchor` (finally wired). Proven `[6.2.1]` TX002·06b (re-revoke of the dead TFTEMPaa rejected). golden 33/0, Z 241/0, comprehensive 260/0 |
| L5 | LOW | ANK | XE returns OutputCumulator | PLAUSIBLE | **CONVENTION R1** (→ `X-cm_` rename) |
| L6 | LOW | ANK | SF/NF incremental promile no floor | CONFIRMED | **DONE ✅ (#18)** — floored the stored per-anchor promile at 0 in `WW_Anchors` (the SOLE write chokepoint for all TF/SF/NF, incremental+absolute paths). Owner call: the trigger IS reachable & outside AQP's control (NFT trait metadata on a trait-anchor is mutable at DPDC, even by module admin — a collectable lock is bypassable), so AQP guards its own accounting at its boundary. Floor not enforce (a hard abort would strand a staker's assets). Aggregate = Σ per-anchor promile ⇒ non-negative too. `max` isn't a Pact builtin → used `(if (< x 0.0) 0.0 x)`. golden 33/0, Z 241/0, comprehensive 260/0 |
| L7 | LOW | SCORE | negative score weight (−1.0 unscored sentinel + negative defs) | CONFIRMED | **DONE ✅ (#19)** — real root found (my first "misdiagnosis" call was wrong). The `[6.2.5]` DPNF probe's base of −1 came from the **DPDC `-1.0` "unscored" sentinel** (`UDC_MetaData` defaults score −1.0), which the model-0 weight read via the RAW reader and counted as a real negative. Fix at the **source**: (1) model-0 `URCX_DpnfModelZeroDpdcNativeRawWeight` clamps each per-nonce native score `<0 → 0` (unscored/negative ⇒ 0 contribution); (2) NF trait/set + SF score-definition validators enforce `score ≥ 0`; (3) DPDC `UEV_Score` tightened from `≥ -1.0` (which admitted all of `[-1.0,0)`) to `(= -1.0) ∨ (≥ 0)`. NOT an aggregate floor (that broke the vacate netting). Proven: `[6.2.5]` DPNF01 unscored nonce ⇒ base **0**; `[6.2.2]` negative SF def rejected; `[6.1]` negative DPDC score rejected (full-chain). golden 33/0, Z 242/0, comprehensive 260/0, deb-proof 121/0. |
| L8 | LOW | SCORE | trailing non-write X returns | PLAUSIBLE | **CONVENTION R4** (allowed + `@doc`) |
| L9 | LOW | VCT | dead `VACATE-MAX-LEGS`=16 / parity helper | CONFIRMED | **DEFERRED (#20) → fold into H4 re-score-sweep / vacate rehaul.** `URC_VacateBatchLegParityOk` (1261) has zero callers; `VACATE-MAX-LEGS`=16 is used only by it (live cap is `URC_VacateBatchNonceTotalOk`/`VACATE-MAX-NONCES`). Inert dead code — owner call (2026-08-15): don't delete standalone; the H4 unwind is "sweep/vacate-based" and will rework this machinery, so clean it up there. `VACATE-FULL-MAX-LEGS`=128 + the nonce-total helper stay. |
| L10 | LOW | FVT | redundant double member-settle | CONFIRMED | **DONE (#21).** Finding morphed: the double-settle was **already resolved by #12** (2b redesign removed C_Collect's PHASE-0 ghost-TVL sync → member now settles exactly once via the bare `XI_2|SettleMemberTier2`). That orphaned `XI_CollectRpsPreScore` + `XI_1|CollectSettleAndBank` + `URDC_BuildCollectScorePlan` — removed all three (dead code, zero behavioral change). Bank covered live by `XI_1|BankScorePendingRewards`. |
| N2 | — | FVT | enforced-fresh inject (`CC_Inject` + defpact) was farm-excluded on an incomplete rationale | NEW (owner) | **DONE ✅ (N2)** — the `class≠0` guard's rationale (*"farms use a fresh denominator"*) only covers the farm Tier-1 `S`; the Tier-2 `L_i` divisor is `SCR|ScoreTotalDebScore` (stale-able) for singular / non-true-triplet members — a **mosaic farm** hits it. Dropped the guard on `CC_Inject` + `XE_FvtInject` (fix machinery already class-agnostic; core farm-capable after R-INJECT). Added the INJECT FUNCTION MATRIX to the `@doc`s. Proven `deb-proof` DEB11 (farm CC_Inject: zero-stale-after + flush 0→50) + DEB12 (farm defpact: flush 50→70). golden 40/0, Z 267/0, comprehensive 283/0, deb-proof 146/0. ⚠️ caveat: `OuroLpFarm`'s sole member is a true-triplet (deb-independent) so the *stale→fresh farm-member fix* is proven by code-equivalence to treasuries (DEB06/08), not directly — direct mosaic-singular-member demo = test-only follow-up. |
| N1 | — | FVT | `AQP-comprehensive` C05 "negative payout" + C04/NF04 available-rewards "over-accumulate" | NEW (R2) | **RESOLVED ✅ (#12a) — NO core bug; three test-layer defects.** (1) driver double-loaded `[6.2.4]_AQP-FVT-OF/-DC` (already self-loaded) → second `[6.5]_DPOF` re-issued MVST → duplicate-insert abort — removed the redundant loads. (2) C04/NF04 asserted an **absolute** available-rewards on a treasury that carried legitimate uncollected residual (Σinjected−Σcollected) — now assert the **DELTA == inject** (C04 12.198→262.198 Δ=250; NF04 Δ=100 — proves conservation, no leak). (3) C05 measured payout across the inject debit (patron is both injector+collector) → spurious −50 — now measured **post-inject** (mirror C02): payout=50 **== claimable** (proves collect correctness). `AQP-comprehensive.repl` now **green (260/0)**. golden 33/0, Z 241/0, deb-proof 121/0. |

## New StoicSyntax rules decided (Round I) — detail in `ROUND-01-OWNER-FEEDBACK.md`
- **R1** `X-cm_` naming for X funcs that return an IGNIS cumulator (`XI-cm_`, `XE-cm_`, `XB-cm_`, `XI-cm_1|…`).
- **R2** Multi-table X functions allowed.
- **R3** `CC_`/`AA_` HEAVY prefixes for `C_`/`A_` (+deps) that unavoidably use `URD_`/scans.
- **R4** X functions document specific outputs in `@doc`; only IGNIS-cumulator output is name-reflected (R1).
- **R5** Consolidate all Ouronet-specific rules into one chapter of `StoicSyntax.md`.

## Round II — fix order (sequential; each green-lit before the next)

**Phase A — StoicSyntax + docs (no logic risk)**
1. StoicSyntax.md: add the Ouronet-specific chapter (R1–R5); + dated `memories/` note.
2. README_ANK.md:130 — TF promile is pro-rate (DOC-FIX for M6).

**Phase B — CRITICAL**
3. C1 · VCT — wire the 5 OF/collectable leg-binding validators.
4. C2 · FVT — read inject denominator AFTER the ghost-TVL sync.

**Phase C — HIGH**
5. H2 · POOL — block stake admission / `EnablePoolStake` during vacate.
6. H3 · VCT — on-chain remaining-count guard on finalize + LP dual-stream.
7. H1 · SCORE — pin stake-time LP equivalent (symmetric unstake) + floor-at-zero. *(design)*
8. H5 · FVT/SCORE — replace triplet Tier-2 `select` with a maintained aggregate weight row. *(design)*
9. H4 · ANK — revoke handling: A (epoch-stamped lazy recompute) or B (disable-if-used + vacate). *(owner picks A/B)*

**Phase D — MEDIUM**
10. M1 · FVT — implement dust sweep.
11. M2 · FVT — maintained per-FVT deb-sum aggregate (kill the defcap `keys` scan).
12. M3 · SCORE — boost additive-over-1000. *(design)*
13. M4 · SCORE — enforce `nzs==0` before boost-class-link/boost-link/deb-boost. ✅ **DONE (#13)**
14. M5 · POOL — full non-self staking (self OR foreign beneficiary) for ALL asset types; unstake threads real `beneficiary-id` (mirror TF). ✅ **DONE (#14)**
15. M6 · ANK — enforce promile [1,10000] + precision=3 + dptf-amount [1000,1M] at issue. ✅ **DONE (#15)**

**Phase E — LOW (logic)**
16. L1 · POOL — remove `enforce` from URC (turned out **tautological**; deleted whole check). ✅ **DONE (#16)**
17. L4 · ANK — add `UEV_LiveAnchor` to revoke (may fold into H4-B). ✅ **DONE (#17)**
18. L6 · ANK — hard floor on SF/NF incremental promile (floored at the `WW_Anchors` write chokepoint). ✅ **DONE (#18)**
19. L7 · SCORE — no negative score weight: clamp model-0 native score at source, forbid negative def scores, tighten DPDC `UEV_Score`. ✅ **DONE (#19)** (first-pass "misdiagnosis" corrected — real root was the DPDC −1.0 unscored sentinel leaking as a negative).
20. L9 · VCT — remove dead `VACATE-MAX-LEGS` + parity helper.
21. L10 · FVT — remove redundant double member-settle.  ✅ DONE (already resolved by #12; removed the dead scaffolding).

**Phase F — convention refactors (after logic is stable) — ⏸ DEFERRED as a batch (owner, 2026-08-15)**

> **All three DEFERRED to a single final pass, run immediately before the Round-III rescan.** Rationale: each is a
> pure rename/annotation that cascades across every call site (module defun + interface decl + Talos wrappers +
> slave callers + test REPLs + doc-comment maps). Pending logic work — the **H4 re-score-sweep / vacate rehaul**
> (which also absorbs L9/#20) — will add/modify functions that must follow the same convention; doing the renames
> now would either miss that new code or force redundant rename bookkeeping. Freeze the logic surface first, then
> do #22–#24 in one sweep. (Exception: if the R3 taint-scan surfaces a scan on a **daily-hot** path, that's a
> LOGIC red-flag to fix immediately, not a rename — track separately, don't defer.)

22. R3 · rename URD-using `C_`/`A_` (+deps) → `CC_`/`AA_` (VCT full-vacate, POOL sync, …).  ⏸ DEFERRED (batch).
23. R1 · rename IGNIS-cumulator-returning X funcs → `X-cm_` (ANK XE updates, …).  ⏸ DEFERRED (batch).
24. R4 · add `@doc` output notes to value-returning X funcs.  ⏸ DEFERRED (batch).

## Method (Round I)
One deep-read auditor per module → structured findings → the two CRITICALs + M6 lead-verified against code.
Reward-math ground truth = the proven UrStoa RPS vault (`00_StoaSandbox/coin.pact` 1520–1940).
