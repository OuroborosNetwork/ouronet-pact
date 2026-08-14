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
| M5 | MED | POOL | OF/collectable unstake self-key vs non-self stake | PLAUSIBLE | **CONFIRMED** |
| M6 | MED | ANK | TF promile pro-rate vs doc | CONFIRMED | **DOC-FIX ✅ done (#2)** · guard still pending (#15) |
| L1 | LOW | POOL | `enforce` in a `URC_` | PLAUSIBLE | **CONFIRMED** (→ UEV/bool) |
| L2 | LOW | POOL | one X writes two tables | PLAUSIBLE | **CONVENTION R2** (allowed) |
| L3 | LOW | POOL | `select`/URD on sync path | PLAUSIBLE | **CONVENTION R3** (→ `CC_`/`AA_` rename) |
| L4 | LOW | ANK | no `UEV_LiveAnchor` on revoke | PLAUSIBLE | **CONFIRMED** |
| L5 | LOW | ANK | XE returns OutputCumulator | PLAUSIBLE | **CONVENTION R1** (→ `X-cm_` rename) |
| L6 | LOW | ANK | SF/NF incremental promile no floor | PLAUSIBLE | **CONFIRMED** |
| L7 | LOW | SCORE | mutable defs → asymmetric delta | PLAUSIBLE | **CONFIRMED / INVESTIGATE** |
| L8 | LOW | SCORE | trailing non-write X returns | PLAUSIBLE | **CONVENTION R4** (allowed + `@doc`) |
| L9 | LOW | VCT | dead `VACATE-MAX-LEGS`=16 / parity helper | PLAUSIBLE | **CONFIRMED** (remove) |
| L10 | LOW | FVT | redundant double member-settle | CONFIRMED | **CONFIRMED** (remove) |
| N1 | ? | FVT | `AQP-comprehensive` C05 **negative payout (−50)** + C04/NF04 available-rewards over-accumulate | NEW (R2) | **OPEN — pre-existing on `main`** (not introduced by this round). Surfaced while proving #12: `[6.3]_AQP-COMPREHENSIVE` TX-AQP-C04/C05 (avail 262 vs 250; payout −50) + `[6.4]_EXHAUSTIVE-DPNF` NF04 (avail 362 vs 100), plus an MVST duplicate-insert ordering abort. Looks like the #10/#11 available-rewards family; negative payout is reward-critical. Needs its own finding + fix. `AQP-comprehensive.repl` is NOT green on main — treat as an unmaintained kitchen-sink until N1 is resolved. |

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
14. M5 · POOL — restrict OF/collectable stake to `beneficiary==owner` (or per-nonce unstake lookup). *(design)*
15. M6 · ANK — enforce promile≤1000 + dptf-amount≤1,000,000 at issue (if absent).

**Phase E — LOW (logic)**
16. L1 · POOL — remove `enforce` from URC.
17. L4 · ANK — add `UEV_LiveAnchor` to revoke (may fold into H4-B).
18. L6 · ANK — hard floor on SF/NF incremental promile.
19. L7 · SCORE — verify stop-stake closes mutable-def asymmetry; guard if not.
20. L9 · VCT — remove dead `VACATE-MAX-LEGS` + parity helper.
21. L10 · FVT — remove redundant double member-settle.

**Phase F — convention refactors (after logic is stable)**
22. R3 · rename URD-using `C_`/`A_` (+deps) → `CC_`/`AA_` (VCT full-vacate, POOL sync, …).
23. R1 · rename IGNIS-cumulator-returning X funcs → `X-cm_` (ANK XE updates, …).
24. R4 · add `@doc` output notes to value-returning X funcs.

## Method (Round I)
One deep-read auditor per module → structured findings → the two CRITICALs + M6 lead-verified against code.
Reward-math ground truth = the proven UrStoa RPS vault (`00_StoaSandbox/coin.pact` 1520–1940).
