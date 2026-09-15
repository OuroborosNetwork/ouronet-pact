# DEFECT LEDGER — the REPL testing round

> ### VERIFICATION STATUS — read before citing any figure from this file
>
> This ledger was **compiled from the project's own records** (74 dated memory notes, the running
> handoff, `IGNIS-PRICING.md`, and the `DEFECT`/`FINDING` annotations written beside the assertions
> that pin them). Compilation is not verification, and the two must not be confused in a published
> paper.
>
> **Independently re-verified against source as of 2026-09-14** — mechanism traced in the `.pact`
> files, not taken from the notes:
>
> | id | claim | outcome |
> |---|---|---|
> | **S-01** | STOAICO vault deadlock, open | **CONFIRMED**, then FIXED. Abort path traced `C_Mint → DPTF\|C>MINT → DPTF\|C>CREDIT → UEV_Amount → (enforce (> amount 0.0))`; all three exits confirmed to share `XI_CollectFor`; `A_Inject`'s `(= unclaimed-count 0)` barrier confirmed. |
> | **M-05** | `GOV\|MIGRATE` message inverted | **CONFIRMED**, then FIXED. `UR_GAP` true = pause active; the guard requires it true and said "offline". |
> | **W-07** | `UR_NonFungible` wrong column | **CONFIRMED**, then FIXED, and the whole codebase swept for the class (`REPL/tools/_colproj.py`) — 0 further instances, sweep mutation-tested against the known one. |
> | **W-08** | two launchpad price setters dead on arrival | **CONFIRMED**, then FIXED. Capability-guard-out-of-scope mechanism traced; both now verified by positive tests. |
> | **A-08** | NOSFERATU `A_Fix01` mis-tiled rung | **CONFIRMED**, then FIXED, and the class made permanent (`REPL/tools/_ladder.py`, gate-enforced, mutation-tested). |
> | §5 | "a green `Z.repl` executes none of the pricing assertions" | **REFUTED.** `Z.repl` runs 106 pricing assertions (`[6.1.9]` 64 + `[6.2.16]` 42); it skips `[6.1]`'s 75. The rule survives, its justification did not. CLAUDE.md and `IGNIS-PRICING.md` §8 corrected. |
>
> **FIXED-CLAIM SWEEP, 2026-09-14.** All **56 entries claiming `fixed`** were independently
> re-verified against current source by three parallel agents, split by class. Result:
> **56 FIX-CONFIRMED, 0 FIX-ABSENT, 0 FIX-PARTIAL, 0 CANNOT-DETERMINE.** Every claimed repair is
> physically present, and every named pin tag still exists in `REPL/` as a live `expect` rather
> than a comment. Two were additionally **mutation-tested**: reverting X-02's `ORBR|A_Fuel` to the
> pre-fix `SECURE`-only form makes `[admin-gate-terminal]` fire, and reverting A-08's rung to
> `Legendary 1 100` makes all three of `_ladder.py`'s rules fire.
>
> Three independent CLASS sweeps were also run to rule out partial fixes, all negative: single-
> argument `format` (exactly the 2 documented DPMF sites), 3-or-more-argument `or`/`and` (0), and
> the `UC_RemoveItem` sentinel-drop shape (0 beyond A-01).
>
> **A false `fixed` is the most damaging error this document can contain** — worse than an
> unverified `open`, because it asserts a repair that may not exist. That is why this sweep was
> run before the `open` backlog was revisited.
>
> **Not yet independently verified:** the remaining entries, and in particular the **open** count.
> That count is the figure an external auditor will press hardest on, and this round has already
> produced one cautionary example: a "78 unreached `UEV_` guards" worklist carried across two
> sessions turned out to be an artefact of reading a static call-graph tool's answer to a question
> it does not answer (it cannot resolve 89 modref call sites). The tool that owns guard coverage,
> `_enforce_coverage.py`, reports **LIVE unpinned = 0**. Treat every count here as a claim with a
> named source, not as a measurement, until it has a row in the table above.
>
> §5 (internal contradictions) is the most immediately useful section for the paper: it is the list
> of places where two project documents disagree, and a paper cannot ship with both.

**What this is.** A deduplicated register of every genuine defect that the Ouronet REPL
verification round found in the Pact contract source, with the mechanism, the instrument that
surfaced it, the reason it had survived, its current status, and the assertion tag that pins it.
It is source material for the audit paper; it is not a change log and not a test inventory.

**Scope.** "The round" is the REPL-driven verification programme: the `#76` IGNIS/STOA pricing
rehaul (2026-09-05 → 09-09), the coverage gates G1–G6 and the static tool suite under `REPL/_*.py`
(2026-09-09 → 09-13), and the `INFO_` preview-versus-charge measurement phase (2026-09-14). A small
number of earlier REPL-found defects (2026-07 → 2026-09-04) are included and dated, because they
were found by the same method. The six per-module **audit rounds** (ATS, SWP, DALOS, DPDC, AQP,
DEMIPAD — Aug 2026, agent code-reading) are a **different corpus and a different method**, and are
summarised separately in §4 so the two are never conflated.

**How it was compiled.**
1. The ~74 dated notes in `OuronetInformational/memories/`, including the two long handoffs
   (`2026-09-11-HANDOFF-next-steps.md`, `2026-09-14-HANDOFF-START-HERE.md`) and the 14-part running
   status `2026-09-14-NIGHT-RUN-STATUS.md`.
2. `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md` **and** `DECISION-LOG-DETAILED.md` — the
   latter is where almost every concrete pricing defect is actually recorded.
3. The in-place annotations in the REPL suite
   (`grep -rn "DEFECT\|FINDING\|WAS A FINDING\|REGRESSION" REPL/ --include=*.repl`, ~166 hits).
   These are usually the most precise statement of a defect, because they sit beside the assertion
   that proves it.
4. **Independent re-verification against the Pact source.** Every entry whose status is `fixed` or
   `open` was checked by reading the current `.pact` file, and the static tools were re-run fresh
   rather than quoted from the notes. Where the notes and the source disagree, the source wins and
   the disagreement is listed in §5. Four claims carried in the notes were **falsified** this way
   and are recorded in §3 rather than the ledger.

**Status vocabulary.**

| status | meaning |
|---|---|
| **fixed** | repaired in source, with a regression assertion that fails if it returns |
| **open** | real, unrepaired; pinned as-behaves so the assertion flips when it is fixed |
| **owner** | real, unrepaired, and the repair is a product/pricing decision rather than a correction |
| **accepted** | deliberate behaviour, proven by measurement rather than assumed, pinned so it cannot drift |

Tags in `<<…>>` are assertion identifiers; `grep -rn "<<TAG>>" REPL/` locates the proof.

---

# 1. Contract defects

## 1.1 Pricing and billing

The largest class, and the one the round's own method was designed for. It splits into three
sub-classes that were found by three different instruments.

### 1.1a Preview-versus-charge defects — found by measurement (2026-09-14)

The owner's specification — *"`INFO_X.ignis-need` must equal the IGNIS actually collected when
`C_X` runs"* — is the only one of three candidate specs with an independent oracle. The other two
were tried and fail: `== <hardcoded>` had **already gone stale silently** (four AQP anchor costs
pinned at 1000.0 while the real price moved to a computed 574.0, and nothing caught it), and
`== URCi_X` is **tautological**, because the preview is literally built from that reader. Every
entry here was found by capturing the patron's balance, running the real op through Talos,
differencing, and comparing to the quote read beforehand.

| # | preview / op | module | mechanism | status | pin |
|---|---|---|---|---|---|
| **P-01** | `INFO_EQUITY\|IssueCompany` | `01_INFO-TWO.pact` | Returned `OI|UDC_NoStoaCosts` — a **literal zero**, rendered to the client as "Operation is free of native Stoa" — for an op that charges **918 STOA**. The charge has two legs: the Talos wrapper's `UC_StoaPrice "issue-shareholder"` (1000 raw) **and a nested `STOA|C_Collect` inside `DPDC-I::C_IssueDigitalCollection`** (200 raw), × the 0.765 patron discount. The first repair found only one leg and quoted 765. | fixed | `<<EQ-I1>>` |
| **P-02** | `INFO_SWP\|ToggleFeeLock` | `15_SWP.pact`, `02_INFO-ONE+.pact` | Same literal zero. `XI_ToggleFeeLock` returns `[0.0 0.0]` on LOCK and `UC_FeeUnlockPrice` on UNLOCK, then `STOA|C_Collect`s it — **432.5 STOA** on the unlock direction. | fixed | `<<SWP-I1>>` |
| **P-03** | `INFO_ATS\|ToggleParameterLock` | `08_ATS.pact`, `02_INFO-ONE+.pact` | Identical shape, **500 STOA** on unlock. The third sibling, `DPTF::C_ToggleFeeLock`, had already been given a read-only `URCi_ToggleFeeLockStoa` twin; SWP and ATS never were. | fixed | `<<ATS-I2>>` |
| **P-04** | `INFO_VST\|Create{Frozen,Reservation,Vesting,Sleeping,Hibernating}Link` (×5) | `11_VST.pact`, `02_INFO-ONE+.pact` | All five returned `NoStoaCosts`; all five charge **76.5 STOA** through `(ref-IGNIS::STOA|C_Collect patron stoa-costs)` inside `XI_CreateSpecial{True,Orto}FungibleLink`. | fixed | `<<VST-I1>>` |
| **P-05** | `INFO_AQP-FVT\|Inject`, `InjectStream`, `InjectFinalize`, `MTX\|2Inject` (×4) | `04_RPS.pact` | A **missing leg**, not a zero. The preview quoted `URCi_Inject` — the gas leg only — but `XI_FvtInjectCore` phase 1 is `(TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)`, a custody transfer carrying its own cumulator. Measured 276.13 quoted vs **276.66** charged, short by exactly 0.53. Fixed by adding `RPS::URCi_InjectFull`. All four members verified separately — `InjectStream` routes through `XIv_FvtAddStream`, a different code path with the same shape. | fixed | `<<TX-INFO-GT-INJECT>>` |
| **P-06** | `INFO_SWP\|Issue{Stable,Standard,Weighted}` (×3) | `16_SWPI.pact` | **Wrong source constant.** Two issuance paths price STOA differently: single-tx `SWP\|C_IssueStandard → SWPI::C_Issue → UC_StoaPrice "issue-swp-pair"` = **500**; defpact `SWP\|C_IssueStandardPool → MTX-SWP → (+ UsagePrice "dptf" "swp")` = **600**. All six previews quoted the second, so the three single-tx ones **over-quoted by 100 STOA**. | fixed | `<<SWP-ISSUE-INFO>>`, `<<SWP-I26>>`, `<<SWP-I27>>` |
| **P-07** | `SNAKES.INFO_Acquire`, `CUSTODIANS.INFO_Acquire` (×2) | `2_CITIZEN/7_Launchpad/` | `URCi_Acquire` is documented as "the Sigma of the two Talos ops" and summed exactly two legs. The second Talos op, `DPDC\|C_MultiTransfer`, runs `C_IgnisRoyaltyCollector patron sender …` **before** its own collect, paying the collection creator **out of the patron**. Measured 89.002 vs **89.004** on a 2-share buy. The gap is 0.1% here only because this fixture's royalty is small — it is a **missing term**, which grows with the royalty, not an imprecision. | fixed | `launchpad-groundtruth.repl` |
| **P-08** | `URCi_DefineHybridSet` (DPSF + DPNF) | `08_DPDC-S.pact` | Delegated to `URCi_DefinePrimordialSet`, whose `@doc` asserted an "identical cost shape". The shape is identical; the **price is not** — `02_IGNIS.pact` charges 43.0 for primordial and composite but **45.0 for hybrid**, and `C_DefineHybridSet` bills its own key. Every hybrid set-class definition was under-quoted by 2.0 raw IGNIS on **both** fungibility sides. | fixed | `<<DPDC-S-I27>>`, `<<DPDC-S-I33>>` |
| **P-09** | `URCi_RemoveLiquidity` | `18_SWPLC.pact` | The preview's flat leg read `UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn"` = **1029.0** (1000 deterrent + a 29.0 component) while the exec's `ico-flat` read the bare `UC_IgnisDeter "lp-churn"` = **1000.0**. The deeper fact the disagreement exposed: all five ADD ops bill deterrent **plus** component on both sides, and the `"SWP|C_RemoveLiquidity" : 29.0` row sat in the components table **billed by nothing at all**. | fixed — owner ruled the **exec** moves up, so removal now carries its component (+29.0 raw / +15.37 net) | `<<SWP-I25>>`, `<<SWP-I25b>>` |
| **P-10** | `VST::URCi_CreateSpecial*FungibleLink` — seven previews, one reader pair | `11_VST.pact` | The only case where **both sides were wrong, in opposite directions**, which is why it was escalated rather than repaired. The preview added a `vst-link` deterrence of 279.0 raw (~$2.50) that `XI_CreateSpecial*FungibleLink` **never charged** — so the exec had been under-collecting a designed-in fee on **every special link ever created** (a revenue bug, not a quoting one) — while the preview also modelled the transfer-role toggle as a hand-made 4.0 leg against the exec's real 59.0. Measured 719.74 quoted vs 601.02 charged. | fixed after an owner ruling; both sides now read two shared module-only readers | `<<VST-I1>>`, `<<VST-I1c>>`, `<<SWP-I8>>`, `<<SWP-I9>>`, leg shape at `<<TX-IGC-008>>` |
| **P-11** | `SWPI::URCi_Issue` | `16_SWPI.pact` | Under-previewed pool issuance by **47 IGNIS**. *The sources do not preserve a leg-level breakdown, so the mechanism below leg-count granularity cannot be established from them.* | fixed (commit `8e3d4ab`) | — |
| **P-12** | `INFO_SWP\|Add*Liquidity` — the asymmetry tax | `18_SWPLC.pact`, `02_INFO-ONE+.pact` | **Not a missing leg, and that is the finding.** A balance delta reads 1118.83 quoted vs 1318.83 charged. The 200.0 is the Asymmetric-Liquidity TAX, which moves as **principal** through the CLAD's `mt-amt` (`[GAS DLK OURO DWK]` / `[200.0 10.0 10.0 10.0]`) via `XI_AddLiqSendAndMint`, never through an `OutputCumulator`. The gas quote was correct **and incomplete**: nothing in `ClientInfo` surfaced the 200, so a client funding exactly `ignis-need` ran out of IGNIS. | fixed by **declaring** it in `pre-text` (folding it into `ignis-need` would re-discount an undiscounted tax); five new per-variant `URCi_Add*LiquidityClad` readers single-source it, because the two CLAD collection flags differ per variant | `<<SWP-I14>>`, `<<SWP-I22>>`, `<<SWP-I34>>`, `<<SWP-I23>>` |
| **P-13** | Branding-upgrade STOA collection | `02_DPDC.pact:1905`, `18_SWPLC.pact:1001`, `05_DPTF.pact:2854`, `06_DPOF.pact:2891`, `08_ATS.pact:2938`, `15_SWP.pact:2063` | Every other STOA site calls `STOA|C_Collect`, which derives its `trigger` from `(URC_IsNativeGasZero)`. These call `STOA|C_CollectWT … false` with a **hardcoded literal**, and `trigger=false` is the "collect anyway" arm — so branding upgrades charge STOA **even when native gas is switched off chain-wide**. | **fixed 2026-09-15** — see §1.1d | `<<DPDC-I41>>`, `<<SWP-I29>>` |
| **P-14** | 22 `URCi_` cost readers across AQP-SCORE / RPS / AQP-DSA | `02_SCORE.pact` (9), `04_RPS.pact` (12), `06_DSA.pact` (1+) | Every one reaches a **hard `read`** of the owner konto (`UR_SCR|ScoreOwnerKonto`, `UR_FVT|OwnerKonto`), so a **cost preview cannot price an operation until the entity already exists** — it aborts with `No value found in table … for key: SCR-x`, naming neither the preview nor the missing entity. A UI cannot render "unknown score" gracefully. The ANK group previews happily on the same placeholder ids, which is what makes this a defect and not the convention. | **fixed 2026-09-15** — see §1.1d | `<<SCR>>`, `<<FVT>>`, `<<DSA>>`, `<<MTX>>` in `[6.5]_AQP-INFO.repl` |
| **P-15** | `INFO_ATS\|WithdrawRoyalties` | `10_ATSU.pact`, `09_TFT.pact` | **Client and preview disagree about whether a state is an error.** `ATS\|C_WithdrawRoyalties` refuses a zero-accrual pair cleanly. The preview reaches `TFT::URCi_MultiTransferCumulator []` and dies on `Array index out of bounds`. Same inputs, same question, one answers and one faults. The empty list arises *because of* the fix for audit #33N, which filters legs to non-zero balances. | **fixed 2026-09-15** — see §1.1d | `<<TFT-MT2>>` |
| **P-16** | `AQP-DSA\|C_FuelRoyalty` and its preview | `06_DSA.pact`, `04_RPS.pact`, `18_SWPLC.pact` | `URCi_FuelRoyaltyCustody` builds an all-zero input vector when the vault's royalty is 0.0; `SWPLC::URCi_Fuel` filters the zeros with `UC_RemoveItem` → `[]` → handed to an indexer. **Both the exec and the preview fail**, with two different native errors, so the client cannot even quote the operation before attempting it. `DSA\|C>FUEL-ROYALTY` has three enforces and **no `royalty > 0` check**. | owner — the cap's signature is `(patron, fvt-id, swpair)` and names no reward token, while royalty is per `(fvt-id, reward-dptf-id)`; *which* royalty must be non-zero is a design question | `<<GT-DOC2>>` |
| **P-17** | `SWPLC::C_AddSleepingLiquidity` carries `tier-token-issue` 500 | `20_MTX-SWP.pact` | The last legacy tier number surviving under a new name, inside a defpact that already carries `issue-swp-pair` 5000. | owner — "keep, or fold into components?" | — |

**Counting note.** The project's running tally is *"19 preview/charge defects found and fixed"*,
which counts the five VST links, the four inject members, the three swap-pair issues and the two
citizen sales individually. **P-01 … P-12 cover those 19**; P-13 … P-17 are five further billing
defects that are not preview/charge mismatches.

**Three failure modes, worth keeping separate.** (a) a **literal zero** for a currency the op
really charges — P-01/02/03/04, now detected automatically by `REPL/tools/_infostoa.py`, which reports 0
today and has been mutation-tested so that the 0 means something; (b) a **missing leg** in a
multi-part cost — P-05/07/12; (c) the **wrong source constant** — P-06/08/09.

### 1.1b Mispriced or unbilled operations — found by the `#76` pricing rehaul (2026-09-05 → 09-09)

| # | site | mechanism | status |
|---|---|---|---|
| **B-01** | `06_DPDC-MNG.pact` `URCi_Control`, `URCi_WipeNonce` | **Half-migrated `(if son …)` branches.** Both were already branchy; the migration script replaced only the **first** tier call it found, so `son=true` got the new `deter+components` price while `son=false` silently kept the old flat tier. **The functions looked migrated and were not.** Found not by any test but by noticing they still appeared in a "still on legacy tiers" scan after being reported migrated; the purpose-built detector — flag any `URCi_*` containing **both** `UC_IgnisPrice` and a `UDC_*Cumulator` — found exactly these two. *"ZALL stayed green throughout: the code is syntactically valid and merely charges the wrong number, which no existing test asserted."* | fixed. `Stage_02/[6.1.9]_PRICE-SWEEP.repl` exists **specifically** for this defect and asserts every `son`-taking reader **twice**, once per fungibility side (`<<TX-DPP-001>>`, `<<TX-OFP-001>>`, `<<TX-SWPP-001>>`, 64 assertions) |
| **B-02** | `07_U_DEC.pact` `UC_UnlockPrice` + 8 consumers | **An unbounded escalating fee ladder.** `base × (unlocks+1)` with **no ceiling** — DPTF's *first* unlock already cost $100 and each subsequent one grew without bound. Its STOA leg was computed as `ignis/100`, i.e. dollars-at-$1, **10× short** of the $0.10 peg. The owner remembered a ceiling; the code never had one. | fixed — flat **$50 IGNIS + $50 STOA**, with the retired ladder's 2-element return shape deliberately preserved so all 8 consumers changed only the call expression |
| **B-03** | `18_SWPLC.pact` | **LP churn hardcoded in remove, entirely absent from all five add paths.** `C_RemoveLiquidity` carried a hardcoded `1000.0` in the exec *and a separately-mirrored literal `1000.0` in its preview*; the five add-liquidity paths had **no churn fee at all**. | fixed — both repointed at `IG\|DETER lp-churn`, and a churn leg prepended to all five exec lists and all five previews. **The structural hazard recorded here is the one that later produced P-09**: SWPLC is *variant-B* — the exec builds its cumulator **inline** and the `URCi_` reader is a **parallel reconstruction**, so both sides must always be edited together |
| **B-04** | `03_AQP.pact`, `05_FVT.pact`, `02_SCORE.pact`, `01_ANK.pact` | **AQP issuance borrowed the account-creation price keys as "a convenient small number".** Eleven `UR_UsagePrice "smart"/"standard"` reads sat inside Issue functions; these were raw pre-rehaul STOA amounts that had never been dollar-denominated. AQP pool / FVT / score issuance charged **0.02 STOA** where the account-creation path charged **100** — a **5000× gap** that also **bypassed the global account-creation STOA switch**. Seven of the eleven were dead `smart-price` let-bindings. First recorded as *"OPEN — owner decision needed, NOT changed … closing it is a price change, not a bug fix"*; only the owner restating the dollar rule a **third** time reclassified it as a bug. | fixed — four new `URCi_IssueStoa`/`URCi_IssueScoreStoa`/`URCi_IssueAnchorStoa` readers at 100/100/100/50. Verified: `UR_UsagePrice "smart"/"standard"` no longer appears in sovereign code. **Residual:** one read survives at `2_CITIZEN/Stage_Z/01_DPL-UR.pact:2387` (a UI price display). Proof it bit: ZALL failed at `AQP-POOL|C_Issue` collecting 100.0 against a fixture holding 19.4, and **301 hardcoded `(coin.TRANSFER … 50.0)` caps across 3 files** had to be raised by hand |
| **B-05** | `04_BRD.pact` `URCi_UpgradeBranding` | Blue-flag branding priced as a raw **0.025 STOA/month**. | fixed → **250 STOA/month** at the peg. A third dead price let-binding of the same shape was removed in `XE_UpgradeBranding`; **12 dead price bindings** were deleted across the session, all the same pattern — *a `let` binds a usage price, the code then bills through a `URCi_` reader, and the binding is never removed* |
| **B-06** | `22_PYTHIA.pact` | PYTHIA deploy/rename tolls held as **raw STOA defconsts** (500.0 / 100.0), admin-tunable — so their **dollar** value moved with the oracle, the opposite of the rule everywhere else. | fixed — dollar-denominated at $50/$10 through `UC_StoaPrice`; moved no price at today's peg |
| **B-07** | `10_ATSU.pact` | **A flat placeholder ~13× below the real computation.** `C_ColdRecovery`/`C_Cull` billed `2 × ignis\|biggest` = **10** and `C_HotRecovery` `3 × ignis\|biggest` = **15**, against ~123–125 measured components. | fixed — ColdRecovery 10→**130**, Cull 10→**132**, HotRecovery 15→**117** |
| **B-08** | `05_DPTF.pact` | `C_Burn` billed **2** ($0.02) and `C_Mint` **7** ($0.07) on flat legacy tiers. The numbers *looked* like modelling artefacts; approved only after confirming `C_Burn`'s 71 components are **11 cross-module calls plus 7 reads**. | fixed — Burn 2→**72**, Mint 7→**87** |
| **B-09** | `08_DSA.pact` + `04_TS02-C3.pact` | **Seven client operations wore an admin prefix and were therefore never billed.** `A_DefineDelegationVault`, `A_SetOracleAuth`, `A_OracleWrite`, `A_WithdrawRoyalty`, `A_BurnRoyalty`, `A_FuelRoyalty`, `A_SetAgencyFee` all call `CAP_EnforceAccountOwnership fvt-owner` — **owner-gated, not GOV-gated** — so they are client ops. Because a Talos wrapper prefixed `A_`/`AA_` is classified Ouronet-Admin-run and therefore **EXEMPT**, none of them collected anything. | fixed — all seven renamed `A_`→`C_` with their Talos wrappers, references rewired across `09_AQP-INFO.pact`, `04_RPS.pact` and four `Kursan/dsa-*.repl` suites. Only `A_ToggleExternalOracle` and `A_SetOracleValidity` remain genuinely admin |
| **B-10** | `06_DPOF.pact`, `06_DPDC-MNG.pact` `WIPE-SLICE-MAX-NONCES` | The Hydra slice ceiling was **120** in both, ~40× too conservative. Measured through the real `Cp_WipeSlice` path: DPOF **405.6 gas/nonce** (≈4907 per 2M-gas transaction), DPDC **952.4** (≈2091). *A too-low ceiling charges users for needless extra transactions.* The DPDC `@doc`'s prior estimate of ~167 was directionally right on the 2.3× ratio and nowhere near the magnitude — it had most likely counted **individual** wipe calls, each paying the ~8k fixed overhead instead of amortising it. | fixed — DPOF 120→**1000**, DPDC-MNG 120→**500**, each set on its own measurement and deliberately ~4–5× under the measured ceiling. Seed-boundary asserts re-anchored in `[6.1.6]_DPOF.repl` and `[6.1.8]_DPDC-HYDRA-WIPE.repl`, which had hard-coded 121/241 |
| **B-11** | `REPL/Stage_01/[4.0]_Sovereign-Executor.repl:237` | A `codex` usage-price key is seeded and `UR_UsagePrice "codex"` is read **nowhere** — that seed line is the only occurrence of the string. A dead placeholder from before glyph pricing landed. | open / accepted; no removal recorded |
| **B-12** | `21_CODEX.pact` `UC_StoicTagStoaFee` | 1 STOA per glyph, **fixed in STOA units**, non-discountable — so its dollar value drifts with the oracle. The **only** documented exception to the dollar rule, recorded in the function's own `@doc`. | accepted (owner, 2026-09-07) — *"do not 'correct' it"* |
| **B-13** | `DPOF::URCi_MoveCumulator`, `DPDC-T::URCi_RepurposeCollectable`, `DPDC-F::URCi_RepurposeCollectableFragments`, `DPDC-N::URCi_UpdateNonces` | **Four readers at the edge of a compounding mis-migration.** Each legacy tier read here is **multiplied by an item count**, so it is a *unit*, not a price; migrating it to `deter + components` would have replaced a unit with a whole-op price and then multiplied it by the count. Caught by individually checking each of six "group A" candidates; four turned out not to be per-op prices at all, and the classification had been *"too coarse"*. | prevented — lifted into `IG\|LEGS` at parity, no price moved. **The canonical "structurally wrong price" shape in this corpus** |

### 1.1c Defects in the generated pricing artefacts (live)

The price sheet is the input to the Chapter-2 documentation. These are defects in what it
**publishes**, not in what the chain charges — but they are live today, and a published price a
client cannot pay is an audit finding in its own right.

| # | artefact | mechanism | status |
|---|---|---|---|
| **GS-01** | `IGNIS-PRICE-SHEET.md:530–536` — all five `C_Add*Liquidity` rows | Published as **`≥ 100`** with the breakdown `"legs: literal 100"`. The source (`18_SWPLC.pact:639`, and the matching exec leg at `:1106`) charges `UC_IgnisPrice "SWP|C_AddStandardLiquidity" "lp-churn"` = a **1000 deterrent plus the op's own component**, plus the CLAD fee and an LP transfer. **The sheet publishes a $1.00 floor where the chain charges more than $10.** The `"literal 100"` breakdown is the *literal-counted-as-a-price* generator bug (the same class that once published every SWP swap as free) still live on this family. | **fixed 2026-09-15** — see §1.1d |
| **GS-02** | same rows | The rows are titled `C_AddStandardLiquidity` — a **core** function name. The actual Talos client is `SWP\|C_AddLiquidity` (`04_TS01-C3.pact:81`/`:633`), and it appears **zero times** in the sheet. So one real client entrypoint is **unpriced** in the documentation input while a non-callable name is priced in its place — against the sheet's own stated contract, *"the sheet now enumerates the TALOS wrappers (what a client actually calls)."* | **fixed 2026-09-15** — see §1.1d |
| **GS-03** | `IGNIS-DETER-WORKSHEET.md` header lines 2–7 | The generated worksheet **publishes the pre-calibration formula** — `ceil(update-fields/2)` and read multipliers `1/1/2/3` — while the code that produced every number beneath it is calibrated (`REPL/tools/_ignis_deter_worksheet.py:27` `IG_UPD_FLDDIV = 4`; `_bucket` → `(1,1)/(2,2)/(3,5)/(5,9)`). Only the `print` statements at lines 264 and 267 were never updated. The document `IGNIS-PRICING.md` §1 designates as *"the supporting working the component costs are derived from"* therefore states a formula that contradicts its own contents. | **fixed 2026-09-15** — see §1.1d |

### 1.1d GS-01 / GS-02 / GS-03 closed — and why they had survived *(2026-09-15)*

All three were symptoms. The cause was that **both generators had been dead since the tools move**
(`b97b525`): each resolved a sibling by a hard-coded `REPL/_letfix.py` /
`REPL/_ignis_deter_worksheet.py` path and raised `FileNotFoundError` **at import**, before argv was
read. A static sweep for that pattern found **eleven** broken tools, not the three the move's own
"verified by output diffing" had caught — because the diffing only covered tools that were run, and
a dead tool produces no output to diff.

While dead, the two artefacts were **hand-edited**: their `Generated by` / `Regenerate:` lines were
updated to the new `REPL/tools/...` paths. *The provenance line of a document that could not be
regenerated was corrected to name a command that crashed.*

| | what it really was | fix |
|---|---|---|
| **GS-01** | not a "literal counted as a price" bug in its own right — the symptom of the **walk stopping one hop short of the cost**. `RT-F-001`'s refactor put the charge behind `URCi_AddLiquidity*`, which the walker *can* follow, so GS-01's own rows corrected themselves the moment the generator ran again. | generator revived |
| **GS-02** | the ledger said "one entrypoint unpriced". It was **18**. `CLIENT` lacked the optional `ENTITY\|` prefix its sibling `HEAVY_PREFIX` already had, so a wrapper delegating to `ref-SWPLC::STOA-PID\|C_AddStandardLiquidity` reached no core op — and the `skipped` counter it incremented **was never printed**. The footer read "0 unresolved" while 18 live client entrypoints had no row. | `CLIENT` prefix fixed (18→12); the remaining 12 are now **published** in an `UNPRICED` section and counted in the footer |
| **GS-03** | the header **retyped** the multipliers and was left behind by the substage-6 calibration. | header now **derived from `_bucket` itself**, boundaries discovered by probing. Negative control: injecting `IG_UPD_FLDDIV=7` and `(2,6)` moved the printed header to match, and reverting restored it |

**Two further live defects were found while fixing these.**

* **GS-10 — the walker could not see three whole name classes.** `X[IEB]v_` (14 functions — the
  `v` variant prefix), `UDCx_*Cumulator`, and cost readers whose name **ends in `Ignis`** (11).
  Consequences: five ops published `?` (`C_Merge`, `C_Slumber`, `C_RepurposeMerge`,
  `C_RepurposeSlumber`, `CC_InjectStream`) purely because `XI_MergeNonces` had been renamed
  `XIv_MergeNonces`; and the whole **ATS/AQP stake family was published at a floor of 3–6 IGNIS
  while the chain charges at least 18–21**, because `URC_CheckpointStakeRpsIgnis`
  (`2.0 × tier-biggest` = 10) was invisible. The five `?` rows returned to **exactly** their
  pre-rename figures (`C_Merge ≥ 146`, `CC_InjectStream ≥ 500`), which is what shows the repair
  restored resolution rather than invented numbers.
* **GS-11 — the `RT-F-001` split was double-counted.** The text carries `LQ|INITIATION-FEE`,
  the `lp-churn` deter key, **and** a subtraction of the constant; summing only additive legs
  published **≥ 1200** for an op the chain charges ~1051. GS-01's mechanism reappearing on GS-01's
  own rows, inflating this time instead of deflating. A negative leg now nets the split (**≥ 1000**).
  Found alongside it: **four sites in `20_MTX-SWP.pact` still charged a bare `100.0`** instead of
  `LQ|INITIATION-FEE`. The three add-liquidity rollback branches were converted (behaviour
  identical, 0 assertion change); `MTX|C_Issue`'s step-2 literal at `:1058` is a different pact and
  a different charge, and was **left alone**.

**Documented, not changed** (owner ruled *"whatever behaviour it has we document it"*): on the
multi-step add-liquidity path a griefed provider pays **200**, not 100 — `LQ|INITIATION-FEE` at
step 0 *and* the same amount again on the step-1 rollback branch. Both charges land, because defpact
steps are separate committed transactions. This predates the `RT-F-001` split.

**GS-02 follow-through (same day).** Publishing the 12 was the floor, not the fix. Four further
resolution gaps were found and closed, taking the unpriced set **18 → 12 → 5**:

| gap | example | why it mattered |
|---|---|---|
| `CLIENT` missing the optional `ENTITY\|` prefix | `ref-SWPLC::STOA-PID\|C_AddStandardLiquidity` | `SWP\|C_AddLiquidity` — the second add-liquidity door, the one `RT-A-001` was about — had no row at all |
| `MODULE.fn` dot-notation calls invisible | `(STOAICO.C_Collect patron account)` in `99_TS02-CPAD.pact` | `CLAUDE.md` says cross-module calls use `::`. This one does not. It works, so nothing complained — and the op was absent from the price sheet |
| same-file Talos→Talos delegation not followed | `DPNF\|C_RemoveNonceScore` is literally `(DPNF\|C_UpdateNonceScore … -1.0)` | a wrapper that delegates to a sibling reached no core op |
| …and when it was followed, only for the **same** entity prefix | `DPSF\|C_BulkTransfer` → `DPDC\|C_BulkTransfer` | its DPNF twin resolved while it did not — *the same defect surviving in one of two symmetrical ops is the shape that hides longest* |

The **5** that remain are now honestly classified rather than lumped together: **3 admin entrypoints**
(free by owner rule — the row builder already forced `d = None` for them, so reporting "could not
resolve" stated a failure where the truth was a policy) and **2 shape-B wrappers** that bill through
their own `URCi_` reader, for which the sheet **names the authoritative reader** rather than
inventing a component cost it cannot model.

Worth recording about the guard itself: after this round of generator fixes, `_pricesync --check`
**fired unprompted** on the drift the regeneration had just created in `IGNIS-PRICING.md`. That is
the check working in the workflow rather than in a selftest.

### Twin-divergence sweep — a measured ZERO on the contracts *(2026-09-15)*

The sharpest lesson of this round was a heuristic, not a bug: **a defect surviving in one of two
symmetrical operations hides longest, because the working twin makes the family look covered.** It
had already paid out twice — `coin`'s guarded sweep against its two ports, and the price-sheet
walker resolving `DPNF|C_BulkTransfer` while dropping `DPSF|C_BulkTransfer`. So it was worth running
against the whole tree rather than leaving as a postmortem note.

`REPL/tools/_twindiverge.py` normalises twin tokens out of function names (CamelCase, UPPER-HYPHEN,
lower-hyphen and short-form spellings all together), groups the families, and compares guard sets.
**309 twin families. 23 asymmetries reported. 0 real.**

The zero is the finding: **the symmetrical families in the contracts are guard-consistent.** Every
survivor is structural (DPTF has no nonces), factored out into a composed sibling, a naming split
(`DPOF|S>X_FREEZE` vs `DPTF|C>X_FREEZE`), a thin alias whose delegate holds the gate
(`DPNF|C_BulkTransfer` → `DPDC|C_BulkTransfer`, which *does* acquire `P|TS`), or already annotated
in place by a prior audit (`DPTF|C>UPDATE-SPECIAL`, "UNREACHABLE BY CONSTRUCTION"). **The twin
divergences this round were in the tooling, not the contracts.**

**The instrument produced four confident false positives before it produced a trustworthy zero**,
and each correction is a reusable rule:

| the probe said | why it was wrong |
|---|---|
| "`DPOF\|S` is missing `CAP_Owner`" | `>` was not in the name character class, so ~15 distinct `DPOF\|S>*` defcaps merged into one pseudo-function |
| "this cap has no guards at all" | interface **declarations** (no body → empty guard set) were grouped with module **definitions** under the same name, and dict-overwrite let the empty one win |
| "`ANK\|C>ISSUE-DPNF` lost 4 guards" | no transitive closure over `compose-capability`; all four live in the `ANK\|XI>ISSUE-DPNF-COMMON` it composes. **Without closure the detector is loudest exactly where the code is best refactored** |
| "`DPTF\|C>MINT` lost 2 account-state guards" | those `UEV_`s do not exist in DPTF at all — reporting that a true fungible is not a collectable |

**It is deliberately NOT wired into `_gate.py`.** A 23-reported / 0-real instrument added as a gate
check is noise that trains people to ignore the gate. Its measured false-positive rate is written
into its own docstring, because *an instrument whose false-positive rate nobody has measured is
indistinguishable from a defect detector* — which is precisely the position `tools/canon_check.py`
was in until it was run (21 reported = 6 stale-classifier + 15 real).

### GS-12 — a second "hard gate", uninstalled and unrun *(FOUND 2026-09-15)*

Chasing the `MODULE-INDEX.md` → `coin-live.pact` pointer led to a **third tool directory**. There are
three, and `CLAUDE.md` asserted *"All 44 analysis scripts live in `REPL/tools/`"*:

| directory | contents | checked by the gate before today |
|---|---|---|
| `REPL/tools/` | the analysis suite + `_gate.py` | yes |
| `tools/` | StoicSyntax canon: `skeleton_emit`, `canon_check`, `cap_band`, `gate.sh`, `hooks/pre-commit` | **no** |
| `OuronetInformational/tools/` | `gen-module-index.mjs` | **no** |

`StoicSyntax-Prefixes.md` §7.13 documents **`tools/gate.sh` as "the hard gate … run before
committing / in CI"**. It runs `canon_check` plus **`Z.repl`** — which `CLAUDE.md` states outright
*is not the gate*. **Two live documents each named a different thing the hard gate, and the weaker,
unrun one was the one being pointed at.**

Measured, not inferred:

* **`tools/hooks/pre-commit` is not installed** in `.git/hooks`, so the canon check had never run
  on a commit.
* `canon_check.py` **failed on 21 files**.
* **6 of the 21 were not drift.** `FN_CLASS` in `tools/skeleton.py` did not know `URv_` (8
  functions), `XIv_` (8) or `XBv_` (6) — **the same three variant prefixes that were invisible to
  `_ignis_price_sheet.py` on the same day**. Two independent tools, one cause: each keeps its own
  hand-written copy of the prefix vocabulary and neither re-derives it from the source.
* **15 files remain genuinely non-canonical**, mostly `defconst` placement:
  `01_DALOS`, `04_BRD`, `06_DPOF`, `08_ATS`, `11_VST`, `15_SWP`, `16_SWPI`, `20_MTX-SWP`,
  `02_INFO-ONE+`, and AQP's `01_ANK`, `02_SCORE`, `03_AQP`, `04_RPS`, `05_FVT`, `08_DSA`.
  **Not fixed here** — `skeleton_emit.py` is a rewriter, and reformatting 15 live sovereign core
  modules is not a change to make as a side effect of a tooling audit. Recorded as a known,
  enumerated quantity with a one-command fix (`python3 tools/skeleton_emit.py <file>`) rather than
  left as an unrun tool of unknown state.

*A false positive rate nobody has measured is indistinguishable from a defect rate.* `canon_check`'s
21 was 6 parts stale-classifier and 15 parts real, and there was no way to tell without running it.

**Guards added:** `_prefixsync.py --check` (fatal) asserts every live `defun`/`defpact` prefix is
classifiable by `tools/skeleton.py`; validated against the real pre-fix classifier, where it names
exactly the three missing prefixes with file and example. `_toolpaths.py` now scans **all three**
tool directories (47 → 53 tools).

**On `MODULE-INDEX.md` → `coin-live.pact`** *(the thread that started this)*: verified rather than
assumed. The file the Stoa sandbox actually loads is `00_StoaSandbox/coin.pact`, and it **carries the
guarded dust sweep**. `coin-live.pact`, `coin-stoa.pact` and `coin-repl.pact` do **not** — a file
named *live* that is not live and holds a fixed bug. `MODULE-INDEX.md` is generated and lists every
file defining a module called `coin` (five of them); it is an inventory, not a deploy pointer. Left
as-is, documented here, because editing a generated inventory by hand is how the pricing artefacts
came to lie.

**The second guard, and the more general one:** `REPL/tools/_toolpaths.py --check`, also fatal in
the gate. The eleven dead tools were found by grepping for `REPL/_letfix.py` — a pattern already
suspected. *A targeted grep only finds the drift you went looking for.* `_toolpaths.py` instead
parses every tool's AST and resolves every hard-coded path literal, splitting them into **[IMPORT]**
(dies the moment anything loads the tool) and **[DEFERRED]** (dies when the owning function runs).
It is **deliberately static** — it executes nothing, because five of the tools it scans rewrite
`.pact` files at module level.

It is validated against the incident rather than against a fixture: run over a worktree of
`6ab8fe6`, the tree as it stood before the repair, it reports **11 of 11**. Getting there took two
corrections, both of which were the checker being too lenient — it first scanned only module level
(10/11, missing `_tighten.py`), then still allowed the tool's own directory as a fallback base for a
module that `chdir`s, which is exactly how `_tighten.py`'s stale `'_gate.py'` had survived: the file
does exist beside the tool, and does not exist where the tool actually looks.

**The guard:** `REPL/tools/_pricesync.py --check`, wired into `_gate.py` as **fatal**, regenerates
both artefacts and diffs them against the committed files. It sits *before* the 86-entrypoint run,
so drift fails in seconds. Proven by re-injecting GS-03 into the worksheet: the gate exited 1 with
`GATE FAILED: a generated pricing artefact does not match its generator.` and printed the offending
line. Its own `--check` dispatch was wrong on the first cut — it passed `write=True` and **silently
rewrote the artefacts while reporting success**; a checker that resolves drift by overwriting it is
a green light wired to nothing.

### Corrections from the fixed-claim sweep *(2026-09-14)*

None change a verdict; all change what the row asserts, which for an audit document is the same
kind of error.

| entry | correction |
|---|---|
| **S-08** | the cited pin `deb-staleness-proof.repl TX-AQP-DEB10` has **zero** occurrences of that tag. It lives in `Stage_02/[6.2.7]_AQP-DEB-MTX.repl` (10 occurrences) and does pin the claimed properties. |
| **R-05** | the stated mechanism does not describe the code. The row says "`try` + a single `read`"; source uses `with-default-read` with a `day: -1` sentinel (`22_PYTHIA.pact:1011-1015`) and there is no `try` on that path. The 80k-gas defect **is** gone — no `keys` survives on the flush path. Also: the cited pin is a **sizing harness that prints `env-gas` and asserts nothing**, so it would not fail if the scan returned. |
| **M-06** | the pin column reads "—", which **understates** it. Both arms are pinned in separate transactions with **different text each**, preceded by an assertion of the live state: `modules/DPTF.repl:342` `<<DPTF-07>>` (OPEN) and `:618` `<<DPTF-G1>>` (CLOSED). |
| **M-01** | two of its five sites have **no assertion demanding the new message** — `03_DSP+.pact:360` and `01_DPL-UR.pact:2433` (whose only `REPL/` hit is a comment). Both remain covered by the gate-enforced `format-no-arglist` structural detector, so the shape cannot regress, but the branches are never executed: **structurally guarded, behaviourally untested.** |
| **X-02 / X-04** | *(fixed in the tooling rather than the text — see below.)* The pins were described as detectors, implying gate enforcement. They were **hand-measured**: `_gate.py` byte-compiled `_conformance.py` and `_heavy.py` and ran conformance's selftest, but never ran either tool. Re-introducing X-02 — a defect **verified exploitable** before it was fixed — would have left the gate GREEN. Both now have a `--check` mode wired into the gate, fatal on VIOLATIONS only. |

**The generalisable rule, now in `_gate.py`'s own comment:** *a number quoted in an audit document as
evidence of a repair must be one the gate re-derives on every run. Otherwise it is a claim about the
past, and the repair it certifies can be undone without anything going red.*

### GS-04 — `INFO_SWP|Issue*Pool` over-quotes by ~652 raw IGNIS *(FOUND 2026-09-14, LIVE)*

Not in the original compilation; surfaced while verifying P-06/P-11, and it is **the same shape as
the red team's `RT-A-001`**: one reader serving two executions that bill differently.

`SWPI::URCi_Issue` was repaired under **P-11** to equal the **single-tx** `SWPI::C_Issue` — its own
comments say so outright (*"MUST equal what C_Issue bills"*). **Six** previews share that one reader,
and **three of them price the defpact instead**: `INFO_SWP|IssueStablePool` / `IssueStandardPool` /
`IssueWeightedPool` route `TS01-P -> MTX-SWP::C_Issue*Pool -> defpact MTX|C_Issue`, which hand-builds
its own bill and then discards `XE_IssueWrite`'s sub-cumulators.

| | legs | total |
|---|---|---|
| exec, `20_MTX-SWP.pact:957-966` | ONE: deter `issue-swp-pair` 5000 + `tier-token-issue` 500 + `tier-biggest` 5 + `tier-smallest` 1 | **5506** |
| preview, `16_SWPI.pact:2341-2359` | FOUR: `URCi_IssueGas 1` 1070 + `DPTF\|C_Mint usage` 87 + `tier-smallest` 1 + deter 5000 | **6158** |

Note the leg COUNT differs too, which matters independently: `UDC_PrimeIgnisCumulator` discounts and
quarter-splits per leg, so even equal totals could round apart.

**A dead parameter is the tell.** `op-key` is still in `URCi_Issue`'s signature and interface
declaration but appears **nowhere in its body** — the P-11 repair removed the component cost that
once consumed it. So all six previews now return the same number for executions that do not bill the
same, and the parameter that was added precisely to distinguish them (commit `e735f6d`) no longer
does anything.

**Why nothing caught it.** Every existing pin measures a single-tx issue. **Nothing measures a
`*Pool` issue against its preview**, and a defpact cannot be measured inside one `begin-tx` — which
is exactly the structural gap `REPL-ROUND-REPORT.md` §3 lists as the reason 3 of the 15 unmeasured
previews are unmeasurable. The gap in the instrument and the location of the defect are the same
place.

*Status:* **FIXED 2026-09-14**, and measured. The repair is exactly the one predicted above: a
separate `SWPI::URCi_IssuePool` reader for the defpact path, `URCi_Issue` reduced to the single-tx
path with the dead `op-key` **removed** from both its signature and its interface declaration, and
the three `INFO_SWP|Issue*Pool` previews re-pointed at the new reader. The part that stops it
recurring is that **`MTX|C_Issue` step 2 now COLLECTS THROUGH `URCi_IssuePool`** rather than building
its own cumulator inline — one source, so there is no second place for preview and exec to drift
apart again.

**Measured, both directions**, at `REPL/modules/DEFPACT-BILLING.repl` `<<DPB-02>>`:

| | quoted | charged | delta |
|---|---:|---:|---:|
| after the repair | 2920.30 | 2920.30 | **0.00** |
| negative control — one preview reverted to the old reader | 3265.86 | 2920.30 | **−345.56** |

The negative control is the part that makes the pin worth having: **345.56 net = 652 raw × the
patron's 0.53 discount**, reproducing this entry's own 652 figure to the decimal from a live balance
delta rather than from arithmetic on a price table. A new assertion that passes is not evidence until
you have seen it fail on the defect it was written for.

**The harness this needed now exists** — `REPL/modules/DEFPACT-BILLING.repl`, a gate entrypoint. The
blocking idiom turned out to be one line: `(continue-pact N)` resolves against the pact started in
the *same* transaction, so a defpact's whole billing can be bracketed by one pair of balance reads.
The existing suites drive defpacts across `commit-tx` boundaries with an explicit pact id — correct
when the point is to prove the steps are independent transactions, and useless for measuring a total,
because the `let` holding the opening balance does not survive the commit.

### GS-05 — the defpact door ignores the virtual-gas switch *(FOUND + FIXED 2026-09-14)*

Found while implementing the `RT-F-001` fee split, by reading the line either side of the one being
changed. **All seven** `UDC_ConstructOutputCumulator` calls in `20_MTX-SWP.pact` passed a hardcoded
`false` as the `trigger` argument:

```pact
(ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
```

`trigger` is the virtual-gas-zero switch: `UDC_MakeModularCumulator` returns `{"ignis": 0.0}` when it
is true. **Every other cumulator in the codebase passes `(ref-IGNIS::URC_IsVirtualGasZero)`** — a
codebase-wide grep for the literal form returned exactly these seven sites, all in this one file.

The consequence is the `RT-A-001` shape again, triggered by an admin action instead of a client
choice: with `DALOS::UR_VirtualToggle` turned **off**, every single-tx door goes free while the
defpact door keeps charging full price. The two doors to the same operation would disagree the
moment the network used a switch it is built to have.

Invisible to the suite because the toggle is **on** in every fixture, so the hardcoded `false` and
the real reader return the same value in every test that has ever run. *A constant that happens to
equal the expression it replaced is not detectable by a test that never varies the expression.*

*Status:* **fixed** — all seven now read `URC_IsVirtualGasZero`. Four were the add-liquidity /
issuance step-0 and rollback collections; three were rewritten wholesale by the `RT-F-001` split.

### GS-06 — the dust sweep tested a global and returned a per-account answer *(FOUND + FIXED 2026-09-14)*

`STOAICO::URC_ClaimableRewards` branched on one condition:

```pact
(if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
```

`UR_Global7` is `unclaimed-count`, a property of the **vault**; `UR_Global4` is the whole remaining
`wstoa-supply`. The branch asks *"is exactly one claimant left?"* and never *"is **this** account
that claimant?"* — so whenever the count happened to be 1, **every** caller was told the entire vault
was theirs. A guard on a global, producing a per-account figure.

**Reached by a legitimate admin action, not an attack.** `unclaimed-count` is set to `nzs-count` only
at inject, so recording a late contribution moves `nzs-count` and leaves `unclaimed-count` behind.
Measured at `RedTeam/[RT-E]_Sequencing.repl` `<<RT-E-001>>`:

    post-stake: unclaimed=1  nzs=3  newcomer-owed=0.000000  newcomer-OFFERED=690.525983

**No theft was possible, and that is exactly why it survived.** `A_Stake` stamps a new contributor's
`last-collected-round` to the *current* round and the collect capability enforces
`(< last-collected-round distribution-round)` — a newcomer is born already-collected for the round
they joined. The money never moved. But the reader also feeds `URCi_Collect` and `INFO_Collect`, so
the preview *told* such an account it would receive the whole vault; and the thing preventing the
theft was a stamp written in a **different function**, with nothing connecting the two.

> **A number that is wrong everywhere except where one unrelated guard happens to stop it is a
> defect, not a defence.** Owner ruling 2026-09-14: a wrong reader is an error whether or not it is
> exploitable.

*Status:* **fixed** — `URC_IzDustSweepClaimant` adds the two missing O(1) conditions (real staker;
not already collected this round). `<<RT-E-001>>` inverts to `OFFERED=0.000000` **and** pins the
non-vacuity half: the rightful last claimant still receives the whole vault, because returning `0.0`
to everyone would satisfy the repair while destroying the dust sweep it exists to perform.

### GS-07 — `P|UR_IMP` raised instead of refusing, in 61 modules *(FOUND + FIXED 2026-09-14)*

`P|UR_IMP` was a bare `read`:

```pact
(at "m-policies" (read P|MT P|I ["m-policies"]))
```

so before **any** module had registered an inter-module policy, it raised
`No value found in table <M>_P|MT for key: InterModulePolicies`. `P|UEV_IMC` is built on it, so in
that window the inter-module gate answered with a raw table error naming a row key rather than
refusing cleanly.

Surfaced by the **X-01** repair: removing the harness registration removed the side effect that had
been creating the row.

**The reader disagreed with its own writer.** `P|A_AddIMP` already seeds the row with
`[(create-capability-guard (SECURE))]` — the module's own capability guard, which no signature can
satisfy and only the owning module's code can bring into scope. The fix makes `P|UR_IMP` default to
the same thing, so the gate's answer is identical before and after the first registration.

*Status:* **fixed in all 61 modules** that hold the function. Checked for uniformity before the
sweep — 60 bodies byte-identical, one carrying an extra `@doc`; all 61 have a nullary `SECURE`; all
61 already used that exact default in `P|A_AddIMP`. The owner's choice of default was not arbitrary:
it is what the codebase already wrote.

**Deliberately NOT defaulted to `[]`.** `UEV_Any` over an empty list is conventionally false, but
that would make the safety of 61 modules rest on a utility's edge-case convention. Seeding the
module's own guard is safe by construction.

### GS-08 — the AQP-RPS dust sweep paid whoever asked *(FOUND + FIXED 2026-09-14)*

Found by the owner asking the right question: *"the audit of the STOA ICO allegedly fixed the dust
sweep following the canonical model of the coin module — can we verify this? because if this is
incorrect, the implementation in the AQP module also might be off."* It was, and worse.

`AQP-RPS::URC_CollectClaimableRewards` (`04_RPS.pact:1867`) branched on counters alone:

```pact
(if (= gc 1) (UR_FVT-RG|AvailableRewards ...)          ;; the WHOLE global vault
  (if (and (= (UR_FVT|FvtClass fvt-id) 0) (= mc 1))
      (UR_FVT-MV|AvailableRewards ...)                  ;; the WHOLE member vault
      (URC_UserTier1AvailableRewards ... deb-user)))
```

`gc`/`mc` are properties of the VAULT and the MEMBER. `deb-user` — the one value identifying the
caller — is bound one line above and **used only in the else-branch**.

**MEASURED, on the deployed stack** (`[6.4]_AQP-TRIPLET-COLLECT` wind-down, ANHD sole claimant
deb=10.0, EMMA fully exited deb=0.0):

    gc=1   emma-claimable == anhd-claimable      <- the reader could not tell them apart
    EMMA (exited) collected the sweep, vault -> 0
    ANHD (rightful sole claimant)  gained 0.0

**Strictly worse than the STOAICO twin (GS-06).** There a `last-collected-round` stamp made the
wrong number unreachable as theft, so only the preview lied. Here **no such stamp exists** —
`UEV_CollectContext` checks pool/FVT/link/ownership and never that the caller is a staker, holds a
claim, or has already collected — and `gc == 1` is a **normal end-of-life state**, not an attack
precondition.

### GS-09 — and the claimant counter could be walked by anyone *(FOUND + FIXED 2026-09-14)*

Exposed by fixing GS-08: with the reader corrected, the same run showed ANHD receiving 0 and the
dust **stranded**. `XI_1|BookCollectUnclaimed` (`04_RPS.pact:3685`) decremented on `deb == 0` alone,
with no check that the caller was ever counted — so a zero-weight account decremented the counter
for somebody else, once per call, for the price of gas. Enough calls and `gc` reaches 1 while honest
stakers are still staked, re-arming GS-08 against them.

*Fixing GS-08 alone converts theft into a fund-lock; the two must be fixed together.*

### Both are losses from a port, and the model is correct

These phases are a **line-by-line port of the Stoa `coin` UrStoa vault** — the comments still name
the steps (*"coin step 1"*, *"coin step 2"*, *"coin step 3"*). The owner's assertion that `coin` is
correct was verified and holds. Two guards were dropped in the copy:

| | `coin` | AQP-RPS (before) |
|---|---|---|
| sweep branch | `(and (= unclaimed-count 1) (> available 0.0))` | `(= gc 1)` — the caller conjunct dropped |
| step 1 on a zero amount | `C_Transmit` → **aborts** (`X_TRANSFER` → `UEV_Amount`) | `(if (<= payout 0.0) (UC_EmptyOc) ...)` → **skips** |

The second is the subtle one and it caused GS-09. In `coin` the abort at step 1 is what makes the
step-3 decrement unreachable for a caller with nothing to collect. Turning the abort into a skip
reads like making a no-op graceful; it exposed a write three steps downstream.

> **A guard can be load-bearing for code it does not mention.** Removing an abort relaxes everything
> sequenced after it.

*Status:* **both fixed.** The repairs follow `coin`'s intent but use each module's OWN counter
semantics, because identical code would have been wrong — `coin` counts users *with unclaimed
rewards* (guard `available > 0`), STOAICO counts *non-zero scores per round* (guard `score > 0 AND
not already collected`), AQP counts *claimants retired when weight hits 0* (guard `deb > 0`). Each
reader now agrees with the writer maintaining its counter — the GS-07 correction again.
`XI_1|BookCollectUnclaimed` additionally requires unsettled `pending`, and PHASE 3 is resequenced
before PHASE 2 so that value is still readable; the two phases touch disjoint state.

**Pinned by `[6.4]_AQP-TRIPLET-COLLECT` `<<TX-AQP-CL04>>`, seven assertions**, including the two a
careless repair would break: the rightful claimant must still sweep, and the vault must still drain
to 0. Returning `0.0` to everyone satisfies "the non-claimant gets nothing" while destroying the
dust sweep.

**WHY THE SUITE WAS GREEN THROUGH BOTH.** The pre-existing assertions checked that the vault
DRAINED (`ar-final`/`mv-final` → 0). **Conservation is satisfied whether the money reaches the
rightful claimant or someone who just left.** This is the third instance this round of the same
shape — `RT-C-001`'s admin gate behind a solvency check, `RT-E-001`'s theft blocked by an unrelated
stamp, and this:

> **A test that asserts an outcome does not assert who caused it.**

### The sweep audit, closed: every counter-triggered payout in the codebase

A codebase-wide scan for the shape — a branch on `(= <counter> 1)` selecting a whole-balance
reader — returns **10 sites, and every live one is now guarded**:

| site | form | status |
|---|---|---|
| `00_StoaSandbox/coin.pact:1661` | `(and (= … 1) (> available 0.0))` | **correct** — the canonical model, and the deployed sandbox copy |
| `genesis/stoa-genesis-4.pact:1521` | same | **correct** — with the pre-fix version commented out at `:1510` |
| `04_RPS.pact:1891`, `:1894` | `(and (= gc 1) (> deb-user 0.0))` | **fixed** — GS-08 |
| `05_STOAICO.pact` | `URC_IzDustSweepClaimant` | **fixed** — GS-06 |
| `0_Stoa/coin-contract/` ×5 | `(= (UR_URV|VaultUnclaimedCount) 1)` alone | **stale snapshots**, not deployed — see below |

**The coin module was audited and fixed, and the evidence is in genesis.** `stoa-genesis-4.pact`
keeps the old unguarded `URC_URV|ClaimableRewards` commented out immediately above the guarded one.
So the repair this family needed was made once, correctly, in the model — and then **not carried
into either port**.

**Five files under `0_Stoa/coin-contract/` still hold the pre-fix form**, including one named
`coin-live.pact`. `IGNIS-PRICING.md` already warned that file is behind the sandbox copy on
bulk transfers; it is also behind on this, which is worse than being behind on a feature.
`MODULE-INDEX.md` lists it as the source for `coin`. They are historical snapshots and are
deliberately NOT edited — rewriting them would falsify the record — but the hazard is now named in
`IGNIS-PRICING.md`.

*Whether STOAICO and AQP were copied from a stale snapshot is not established and is not claimed.*
What is established: the correct form existed, in the model, before both ports carried the wrong one.

### VCT and FVT — checked, clean

`06_VCT.pact` has **no sweep branch at all**; its nearest analogue (`:2550`) is account-scoped and
settles that beneficiary's own pending. `05_FVT.pact` is a facade — `URC_CollectClaimableRewards`
(`:3728`) delegates to RPS — so the RPS repair covers it. All four RPS vaults now share one rule:
**the sweep branch must test the caller, not only the counter.**

## 1.2 Guard reachability — mute, shadowed and dead guards

The single most repeated defect class in the codebase, resting on two Pact facts: **`let` binding
groups are eager**, and **`(fold (and) true […])` does not short-circuit** (verified directly:
`(enforce (fold (and) true [false (enforce false "LATER")]) "FOLD")` raises `LATER`). The
consequence, in the round's own words:

> *A guard cannot protect the expression that computes its own operands. Whether those operands
> come from a `let` above it or from a later conjunct beside it, they run first.*

The caller then receives a raw `No value found in table … for key: |` or `Array index out of
bounds`, naming the row key rather than the rule. **Every positive path works**, which is why
review does not see it: the message is the one part of a guard that no passing test ever executes.

Three sub-shapes, and the third is the one an audit for the first two walks straight past:

- **A — binding above the enforce.** The guard's subject is hard-read in the `let` above it.
- **B — binding above a `with-capability`.** The defcap holds the guard, but the client's `let`
  reads the subject before the capability is acquired.
- **C — inside the `enforce` itself.** A later conjunct of a `fold (and)` hard-reads the value an
  earlier conjunct is validating. *The cheap check IS first; the ordering IS right; the code looks
  correct.*

### 1.2.1 Repaired sites

| # | site | what the caller used to get instead | pin |
|---|---|---|---|
| **G-01** | `13_OUROBOROS.pact` `UEV_Exchange` — both "Ouroboros is not set" and "Ignis is not set" | `DPTF ID \| does not exist` — the role read consumed the very ids the guards tested. Both boot stages produced the *same* raw error, so the staged configuration was unobservable. Fixed by **splitting the binding group** (ids depend on nothing; roles depend on ids; the enforces go between). | `<<TX4.0-CONFIG>>` |
| **G-02** | `10_ATSU.pact` `ATS\|C>RECOVER` — "Invalid Hot-RBT" | `No value found in table … ATS_ATS\|Pairs for key: \|` — `UR_ColdRewardBearingToken` returns BAR, the sibling binding then looks up pair `\|`. Fixed by acquiring the capability **before** the `let`. | `<<ATS-G14>>` |
| **G-03** | `10_ATSU.pact` `ATSU\|C>REDEEM` — same message, same mechanism | Found **because fixing G-02 did not turn the test red**: `ATS-G14` drove Redeem only, so repairing Recover alone left it green. The inverse of the usual signal. | `<<ATS-G14>>` |
| **G-04** | `21_CODEX.pact` `CODEX\|A>REGISTER-IDENTITY` — the 325-char composite-id length check | `Array index out of bounds. Length (0), Index (0)`. The sharpest instance: the length test **was the first conjunct and was already false**, and saved nothing, because the `let` is eager *and* the fold does not short-circuit. | `<<CODEX-G3>>` |
| **G-05** | `00_Demipad.pact:513` `C>DEPOSIT` — "Asset … is not registered to the Demiourgos Lauchpad" | A raw Ledger table key. The clearest instance, because the fix was already in the module three lines up: `UR_CheckRegistration` deliberately wraps its read in `(try false …)`, while its three **sibling** reads of the same row were bare. All three switched to `with-default-read`. | `<<TX-DEP-02>>`, `<<DEMIPAD-G2>>` |
| **G-06** | `04_AQP-BOOT.pact:474` `C_Step6` | An index fault for a **too-short** list; the message arrived only for a too-**long** one — the one case the `at`s survive. Native index faults are recoverable by neither `try` nor `enforce-one`. | `<<DPDC-G10>>` |
| **G-07** | `04_AQP-BOOT.pact:577` `C_Step7` — four list-shape messages | Same ×4. `C_Step9` in the **same file** is the correctly-ordered twin, so the fix was demonstrated in place. | `<<DPDC-G10>>` |
| **G-08** | `11_EQUITY+.pact` `C_IssueShareholderCollection` — "24 IPFS links must be provided" | Not only a message defect: the `let`'s `ico` binding **issues the collection**, so every rejected call **paid for a full collection issuance before the argument was inspected**, and whenever the issuance failed first for its own reasons (a duplicate name, the ordinary case) that error was reported instead. | `<<EQ-G1>>` |
| **G-09** | `05_FVT.pact` `UEV_AddScoreEntityTripletContext` — "Triplet must be issued in AQP-SCORE" | Dead until 2026-09-10: the `let` hard-read `SCR\|T\|Triplet` five times on `<triplet-id>`, even though `URC_TripletExists` is a `with-default-read` written specifically to answer for a missing row. | `<<TX-AQP-FA04>>` |
| **G-10** | `06_DPDC-MNG.pact:287` `C>ADD-QUANTITY` — `(> nonce 0)` | A **partially** shadowed guard, which is why it earns its own row: nonce `0` aborted in `UR_NonceClass`'s row read and never reached the guard, while a **negative** nonce did reach it, because that reader keys on `(abs nonce)` and found a real row. Mute for one input, live for another. | `<<DPDC-G11>>` |
| **G-11** | `02_DPDC.pact` `UEV_Nonce` — all three predicates | Shadowed by `UR_NonceValue → UR_NonceElement`. Hoisted; now live. | — |
| **G-12** | `08_DPDC-S.pact` `UEV_SetClass` — both enforces | Shadowed by `UR_Set`. Hoisted; now live. | — |
| **G-13** | `06_VCT.pact` `VCT\|C>TRUE-FUNGIBLE-VACATE-BATCH` | **A guard that knew and had no voice.** `(gas-ok (URC_TfOwnerArraysGasOk …))` correctly computes `false` for an empty batch, but the sibling binding `(legs (UC_TfLegsFromParallelArrays …))` faults first. The asymmetry proves intent: the Orto and Collectable leg builders already guard `(if (> l 0) …)`; the TF one did not. Four functions made total. | `<<AQP-F6>>`, `<<TX-VCT-N01>>` |
| **G-14** | `01_TS02-C1.pact` `DPDC\|C_BulkTransfer` + `07_DPDC-T.pact` `URCi_BulkTransferCumulator` | The core cap's shape guard is correct; the **Talos wrapper** derived `ids`/`sons` eagerly via `(enumerate 0 (- l 1))`, which for `l=0` is the descending pair `[0,-1]`. Measured matrix: empty list → index fault; more receivers than nonce legs → index fault; **more legs than receivers → the written message arrives.** That asymmetry is what makes it a defect rather than a dead guard. The **cost preview** carried the same fault, so a UI quoting an empty bulk transfer crashed. Fixed by calling the core first (matching `TS01-C1::DPOF\|C_BulkTransfer`, which was always in that order and never mute) and by making the `URCi_` **total** — a `URCi_` may not `enforce`, and an empty transfer has no legs, so it has no cost. Three independent hazards fed one symptom, which is why the first two fix attempts did not clear it. | `<<DPDC-G14>>`, `<<DPOF-G12>>` |
| **G-15** | `04_RPS.pact:2981` `UEV_AddRewardLinkContext` | Sub-shape **C**. `[(!= multiplet-family-id BAR) … (UR_FVT-MF\|Active …) …]` — the third conjunct is a bare `read`, so passing `BAR`, the exact case the first conjunct exists to reject, aborts on key `\|`. Every *other* way to fail that fold does reach the message, which bounded it and hid it. | `<<AQP-G31>>`, `<<GT-12>>` |
| **G-16** | `04_RPS.pact:3028` `UEV_QualitySplitContext` | Same shape: a PLAIN link carries a BAR family id and aborts on the raw table key instead of being told it is not a MULTIPLET ladder. Both hoists **added a new guard, and both new guards were pinned in the same edit** — a hoist that leaves its new message undriven just moves the hole. | `<<AQP-G31>>` |

A related latent instance is worth recording because it is **worse in kind** than the rest:
`04_RPS.pact:3876` `XE_XI_SettleScoreRps` has the same eager-fold-operand shape **inside an `if`**,
so a settlement plan containing a BAR `fvt-id` would abort the **whole batch settle** instead of
skipping that entry — the opposite of what `(!= fvt-id BAR)` was written to do. It is latent only
because the plan builder does not emit BAR today.

### 1.2.2 Open sites

| # | site | mechanism | pin |
|---|---|---|---|
| **G-17** | `01_DALOS.pact:368` `GAS_PAYER` — "Only for transactions with code" | `iz-single` and `exec-lines` are bound in the same `let`; `(at "exec-code" (read-msg))` raises `Key "exec-code" not found in object: {}` before `iz-single` is consulted. | `<<DALOS-G1e>>`, `<<DALOS-G2e>>` |
| **G-18** | `22_PYTHIA.pact` `A>REVOKE-DUAL` | First act is `UR_DualLinkIzActive`, a hard read. An unknown dual-link key dies in the table read, not a named guard. The sibling `UR_DualLinkIzActiveOrFalse` already exists and would collapse this into the existing message at no cost. | `<<TX007d-02c>>` |
| **G-19** | `22_PYTHIA.pact` `UEV_DualPairForLink` | Degrades on an undeployed half: `(UR_Counterpart standard-apollo)` is a hard read, so a half never deployed aborts with a raw miss naming the **162-glyph row key**. The guard is live for its real case (deployed-but-taken) and useless for the case a caller most likely hits. | `<<TX007e-03>>` |
| **G-20** | `05_FVT.pact:1870` `UEV_AddScoreEntityScoreContext` | The fold contains `(!= aqpool-link BAR)`, but the `let` above binds `expected-swpair = (URC_ResolveScoreEntitySwpair …)`, which **hard-reads the pool table using that same `aqpool-link`** — so a score belonging to no pool aborts on key `"\|"` before any enforce runs. | `<<TX-BOOT-G1>>` |
| **G-21** | `03_AQP.pact:2320` `UEV_AddScorePoolAndScore` | The add-side fold's first conjunct `(= (UR_SCR\|ScoreScoreId score-id) score-id)` is meant to catch a nonexistent score, but that reader is a hard read. The named cause can never produce the named message. Fixing it needs a new `with-default-read` existence reader; `URC_TripletExists` is the in-repo precedent. | `<<AQP-G30>>` (prose) |
| **G-22** | `06_DPOF.pact:2014` `UEV_ParentOwnership` | `(parent (URCv_Parent id))` is bound eagerly and reads the properties table, so the "Sleeping LP Tokens not allowed" enforce — **moved here specifically to be reachable** — is now shielded by the very function it was extracted from. The DPTF twin enforces before its read and is pinned. | `<<DPTF-G5>>` (the working twin) |
| **G-23** | `08_ATS.pact` / `06_DPOF.pact` `UEV_RewardBearingTokenExistance`, HOT branch | The `cold-or-hot` flag routes into `DPOF::URC_IzRBTg`, which opens by asserting the id is a DPOF. A cold RBT is a DPTF, so the lookup **aborts** instead of answering `false`. Both cells of the hot column are unreachable — including the one that should legitimately succeed. | `<<ATS-G1>>` |
| **G-24** | `04_RPS.pact:3027` `UEV_QualitySplitContext` "Reward link row must exist" | A **partial** shadow that survived the G-16 repair: `UR_FVT\|OwnerKonto` still aborts for a missing FVT, so the guard is reachable only with an *existing* fvt-id that fails its own condition. Currently the single remaining hit from `_shadowed.py`. | — |
| **G-25** | `09_U_ATS.pact:649` `UEV_CRF\|FeeArray`, via `ATS\|C_SetColdRecoveryFees` | Index sub-shape: a later conjunct does `(at 0 fee-thresholds)` while an earlier one measures the length. A **length mismatch** — thresholds supplied, fee array short, far likelier than passing nothing — faults on the index instead of the sentence written for it, **which the function already contains**. *A validator returning an index fault instead of its own message is the worst version of this: rejecting bad input is its only job.* | `<<EL-5>>`, `<<EL-5b>>` |
| **G-26** | `01_DALOS.pact:397/414/425` `GAS_PAYER` exec-code folds (×3) | Same index sub-shape on `exec-lines`. | `<<DALOS-G2e>>`, `<<DALOS-G2f>>` |
| **G-27** | `04_RPS.pact:3919` | The one remaining `[read]` hit from `_foldeager.py`: a later conjunct `(= (UR_FVT\|FvtClass fvt-id) 0)` hard-reads what an earlier conjunct guards. | — |

### 1.2.3 Guards that are dead, and whose stated rule is therefore unenforced

Distinct from the class above: the input never reaches a *wrong* error, because the check is a
no-op or a duplicate.

| # | site | mechanism | status |
|---|---|---|---|
| **G-28** | `01_DALOS.pact:377` `GAS_PAYER` form count | `(>= n 1)` is enforced on the line above, and `(fold (or) false [(= n 1) (= n 2) (>= n 3)])` then covers every remaining integer. It **reads like a whitelist of accepted shapes and is a tautology.** | open, annotated |
| **G-29** | `01_DALOS.pact` `GAS_PAYER` nested `enforce-one` messages | Every `enforce`/`enforce-one` nested inside the outer `enforce-one` is **mute** — Pact discards a failed branch's message and raises the outer one, so a caller always sees "Payable Modules / form count not satisfied". Those strings document intent; they are not diagnostics. | open, annotated |
| **G-30** | `02_SCORE.pact:1110` `SCR\|XE>UPDATE-LP-STAKE-ORTO-LP` | A **tautology**: the client derives the compared value from `UR_NoncesSupplies` (total), which folds the very reader the guard compares against, so it reduces to `(= x x)`. **One word in a reader name** — `UR_AccountNoncesSupplies` vs `UR_NoncesSupplies` — is the whole difference between live and dead, and the two enforces look identical at the site. | open, annotated |
| **G-31** | `06_VCT.pact` `URC_Vacate{Collectable,Orto}LegBeneficiaryOk` (×2) | **Key-echo tautologies.** `beneficiary-id` is a *component of the lookup key*, and the reader is a `with-default-read` whose default object is built from the key — so on a present row the stored column *is* the key, and on an absent row the default echoes the argument back. The function cannot return false; confirmed live. The binding it describes is still enforced, by the balance checks. | accepted, annotated |
| **G-32** | `00_Demipad.pact:575` `DEMIPAD\|C>WITHDRAW` type enforce | Provably dead: `C_Withdraw` binds `(URv_Funds asset-id type)` before entering the capability, and that reader opens with the **identical predicate**. This is the architectural deviation (*state-dependent enforce in a reader*) being the **root cause** of a dead guard found independently by the coverage gate. | **ruled KEPT** — `<retrieval-amount>` is a parameter of the `@event` capability, so moving the read inside would change an event signature indexers consume |
| **G-33** | `09_U_ATS.pact` `UEV_AutostakeIndex` guard 2 | Two problems stacked. (a) `(contains ats aipc)` asks whether the **list** `["$" "¢" "£"]` contains the whole atspair — i.e. whether the name *is* one of those characters — while the message says "contained a prohibited character", a substring test; `"AB$CD"` sails past. (b) `¢` and `£` are non-ASCII and are eaten by the charset guard first, so **exactly one string in the universe** (`"$"`) can make guard 2 fire. | **fixed 2026-09-15** — see §1.1d | `<<UTIL-06>>` |
| **G-34** | `16_SWPI.pact` `UEV_SwapData` count guard | **Unreachable for well-formed requests** — with distinct inputs, `l2 = l3` forces the output to be an input, so the "output cannot be an input" guard fires first. What reaches it is a **duplicated** input list, because nothing in the validator rejects duplicates. The real exposure: `[a a]` into a 3-token pool — a swap naming the same token twice, **under** the bound — is accepted outright. | **fixed 2026-09-15** — see §1.1d | `<<SWP-G1>>` |
| **G-35** | `15_SWP.pact` `SWP\|S>RT_OWN` | Shadowed **by guard order**, not by a read: the Elite-tier check sits in front of the ownership flag, so `UEV_CanChangeOwnerON` is unreachable from the client until the tier is cleared. | accepted, pinned | `<<SWP-G21c>>` |
| **G-36** | `02_SCORE.pact:1282` DPNF stake amount | Shadowed cross-module: `DPDC::UEV_NonceQuantityInclusion` checks the holder identity upstream, which for an NFT is the same fact. Predicted reachable; **proved not, by running**. | accepted, annotated | `<<TX-AQP-NF01>>` |

> **Not counted as defects.** 31 further `enforce` sites carry a `;;UNREACHABLE` annotation with a
> proof at the source and are **correct fail-closed backstops** — `05_DPTF.pact:951/971/1004`,
> `03_DPDC-C.pact:279/282/840`, `02_SCORE.pact:995/1021/1122/1305` (shadowed by an upstream
> validator, kept as cross-module defence in depth), `05_FVT.pact:3656/3696` (**post-condition
> self-checks**, which no *argument* can trip), `22_PYTHIA.pact:1353/1377` (an atomicity backstop
> reading through `(try false …)`), `02_IGNIS.pact:1007` (the value is normalised by a sanitising
> constructor), `07_DPDC-T.pact:356`, `01_ANK.pact:466`, `04_STOICPAY.pact:251` (a vestigial
> sentinel branch), and others. The round's rule: **annotate only when no state could ever reach
> the guard; when it is unreachable because an *invariant* holds, drive the invariant false and
> execute it instead** — an `;;UNREACHABLE` note is a claim about today's call graph and goes stale
> silently the first time someone adds a writer (applied at `01_DALOS.pact:1215`, `<<DALOS-G8>>`).

## 1.3 Arithmetic, list handling and empty input

Three Pact facts do most of the damage, and all three are counter-intuitive:

- **`(enumerate 0 -1)` is `[0, -1]`, not `[]`.** `enumerate` counts *down* when `from > to`, so the
  idiom `(enumerate 0 (- (length xs) 1))` on an empty list yields a **two-element** index list and
  the first step does `(at 0 [])`. **153 sites** use the idiom; ~84 are safe only because this
  codebase spells "none" as a one-element `[BAR]` sentinel rather than `[]`. **The danger signal is
  a `filter` (especially `UC_RemoveItem`) or a raw caller parameter feeding the idiom** — that is
  where a list escapes the sentinel convention. `try` does **not** catch an out-of-bounds index, so
  a caller cannot defend itself; the guard has to be in the callee.
- **Pact's object `+` gives precedence to the LEFT operand** on key collisions.
- **`or` and `and` are binary.**

| # | site | mechanism | status | pin |
|---|---|---|---|---|
| **A-01** | `05_DPTF.pact` `XE_UpdateRewardToken` | **Token-bricking, permanent and un-repairable.** "None" in the `reward-token` column is `[BAR]`, never `[]`. The ADD branch understood the sentinel; the REMOVE branch used `UC_RemoveItem` = `(filter (!= item) in)`, which on the last remaining pair yields a bare `[]`. `URC_IzRT` compares against `[BAR]`, so an emptied token answers **TRUE while holding no pairs** — every transfer then routes into `TFT::URCx_CPF_RT`, hits `(enumerate 0 -1)` and faults. Un-repairable because the ADD branch opens with `(at 0 rt)`, which also faults on `[]`. Reachable through the ordinary `ATS\|C_AddSecondary` client path (verified live). The `(> rt-position 0)` guard in `ATSU\|C>X_REMOVE-SECONDARY` does **not** protect it — that guards the **ATS pair's** reward-token list, a different list from the DPTF's list of pairs. *Two lists, one guard, and the guard is on the wrong one; both are called "reward token", which is exactly why it read as covered.* | fixed | `<<ATS-F1>>` — written as an **invariant sweep** over every reward token on chain, not a replay |
| **A-02** | `01_TS02-C1.pact` + `07_DPDC-T.pact` bulk transfer | See G-14. | fixed | `<<DPDC-G14>>` |
| **A-03** | `06_VCT.pact` `UC_TfLegsFromParallelArrays` + 3 siblings | See G-13. All four zip parallel arrays, so all four need the index and all four were non-total. | fixed | `<<AQP-F6>>` |
| **A-04** | `06_VCT.pact` `UC_VacateDecimalAmountsToIntegers` | Two functions doing the identical job and agreeing on every non-empty input; on `[]` one returns `[]` and the other faults. **Not a live bug** — `UC_MergeVacateNonceRowIntoLegs` always builds ≥1 leg — but a footgun armed for whoever next changed the leg builder. Fixed as a **delegation**, collapsing the duplicate so the two cannot drift. | fixed | `<<AQP-F3>>` |
| **A-05** | `03_DPDC-C.pact` `XIv_MappedCreditOrDebitDPDC` | Two empty lists are equal, so they **pass** the arity enforce; the map below then runs over `[0,-1]` and dies. The empty call does not no-op. | open, pinned as-behaves | `<<DPDC-G19>>` |
| **A-06** | `06_DPDC-MNG.pact` `URC_FilterAccountViableNonces` | Exploded on an empty nonce list. *"Never triggered before because nothing ever re-read a fully-wiped account; the Hydra 're-plan from remains' flow does exactly that."* | fixed | — |
| **A-07** | `09_TFT.pact` `URCi_MultiTransferCumulator` (+ `MultiBulk`, `UnityBulk`) | The root of P-15. Six sibling cumulators were pinned side by side: the three **size-arithmetic** ones return 0.0 on empty; the three **index-iterating** ones fault. `URCi_BulkTransferCumulator` returns 0.0 but is a **dispatcher** — safe only because that input routed to a size-arithmetic branch; its `what-type 2` branch delegates to `UnityBulk`, which faults. | **fixed 2026-09-15** — see §1.1d | `<<TFT-MT1>>`, `<<TFT-MT3>>` |
| **A-08** | `2_CITIZEN/3_NosferatuMinter/01_NOSFERATU.pact` `A_Fix01` | **A mis-tiled mint plan.** The minter encodes its plan as literals in one-line wrappers; two ladders (`A_StepNN → C_Spawn` mints, `A_FixNN → C_Fix` rewrites) are identical rung-for-rung, 24 rungs each, **except rung 1**: `A_Fix01` read `1 100` against `A_Step01`'s `1 70`. Two consequences: Legendary 71–100 is covered **twice** (Fix totals 1530 positions against Spawn's 1500), and — the dangerous one — `C_Fix` enforces `(= (length mdm) number-of-positions)`, so the rung size *is* the caller's list size, and **70 is the per-transaction gas budget**, which is the entire reason the ladders carry split `a`/`b` rungs at rarity boundaries. `A_Fix01` was the one rung that could fail to fit in a transaction on chain. **No `.repl` could have caught it** — a REPL can only execute a rung, and nothing in the suite executes the `A_Fix` family at all; even full execution coverage of `C_Fix` would not have found it, because `C_Fix` is correct and the defect is in the arithmetic of the plan handed to it. | fixed | `REPL/tools/_ladder.py`, a static tiling check wired into `_gate.py` as a hard failure |
| **A-09** | `03_AQP.pact` `UDC_AQP\|SchemaWithScoreSlots` | `(+ pool {…seven slots…})` — Pact's object `+` gives the **LEFT** operand precedence on key collisions (verified live), and the pool row already carries all seven slot keys, so **every supplied value was discarded and the function returned its input unchanged**, flatly contradicting its own `@doc`. *"It fails the quietest way possible, by returning something that looks exactly like a valid row."* Found by writing the first test the function had ever had — aimed at an off-by-one across seven near-identical branches, it failed on the first assertion instead. A sweep of the six other `(+ <row> {…})` sites found **no other instance**; the discriminator is *does the LEFT operand already carry the key being merged in?* | fixed | `<<AQP-F10>>` |
| **A-10** | `05_FVT.pact:1936` `UEV_AddScoreEntityTripletContext` | **Pact's `or` is binary.** A three-argument `or` raises `Attempted to apply a closure to too many arguments` instead of evaluating — so the **admitting** membership modes failed identically to the refusing one, and **no non-mosaic FVT could admit a triplet in any mode**. A functional break, not a bad message. Fixed to `(fold (or) false [...])` per owner ruling; two such sites already existed in the same module. Exactly one instance codebase-wide, so no detector was added. | fixed | `<<GT-16>>` §03, which drives all four modes plus the mosaic short-circuit |

**Why A-10 survived is the general lesson of this class:** the broken expression is the second
argument of `(or (UR_FVT|Mosaic fvt-id) <this>)`, the outer `or` **short-circuits**, and every FVT
built so far is mosaic. *The defect sat behind a `true`.*

## 1.4 State machine, lifecycle and permanently-locked value

| # | site | mechanism | status | pin |
|---|---|---|---|---|
| **S-01** | `05_STOAICO.pact:496` `XI_CollectFor` | **A vault deadlock, severe, and still open.** The function mints the account's urSTOA **unconditionally** and only then guards the *delivery* with `(if (!= urSTOA-supply 0.0) …)`. `DPTF::UEV_Amount` refuses a zero-amount mint, and an account's urSTOA entitlement is zeroed by its **first** collect — so from its second collect onward the whole transaction aborts while real wSTOA rewards are still owed (probe: one staker with 0 urSTOA and ~309 claimable wSTOA, against a global urSTOA pool of 245,932 — per-account, not the ICO running dry). It is a deadlock rather than a nuisance because all three exits close at once: `C_Collect` aborts, `AA_FlushUncollected` shares `XI_CollectFor` and fails identically, and `A_Inject` is barred while `unclaimed-count != 0`. **The vault stops paying and cannot be restarted from any entrypoint.** The one-line fix is the guard the delivery already has; `IGNIS::C_TransferDalosFuel` documents exactly this lesson in its own `@doc` — it was simply not applied here. | **FIXED 2026-09-14** -- the mint moved inside the guard the delivery already had, and the wSTOA leg guarded on the same principle. Verified live: the stranded 309.474016486404 wSTOA reached the staker, and `unclaimed-count` fell, unblocking the inject barrier. | `<<TX-TAL>>` |
| **S-02** | `11_VST.pact` `VST\|C>MERGE` / `VST\|C>SLUMBER` | **Permanently unrecoverable value, and it reported success.** `XIv_MergeNonces` branches correctly on `vzh-tag` (2 = SLEEPING writes `{release-amount, release-date}`, 3 = HIBERNATING writes `{mint-time, release-date}`), but **neither cap checked what kind of DPOF it was handed** — so the metadata shape was decided by which client the caller picked. A slumber-merged sleeping nonce then fails Pact's **runtime typecheck** on the way into `C_Unsleep`, *before any `enforce` is consulted*, and `C_Unsleep` is the only release path. On the suite's own chain, `Z\|MOCKA` nonce 3 was in circulation, held by a real account, fully matured, carrying **200.0 of real value, and permanently un-unsleepable**. | fixed — kind guards on the two **minting** caps, deliberately **not** on the repurpose pair, which is the only exit for rows already minted wrong | `<<VST-G7>>`, `<<VST-09>>`, `<<VST-11>>` |
| **S-03** | `04_BRD.pact:197` `BRD\|DEFAULT` | A **`defconst` holding a single load-time timestamp**. `genesis` and `premium-until` are BRD's own *deploy* time, shared by every branding entity ever issued — so `genesis` is useless as a birth date and **every never-upgraded entity starts with premium already lapsed**. | fixed (`genesis` stamped per issuance; `premium-until` set to a `BRD\|NO_PREMIUM` sentinel of 1970-01-01) | `<<SWP-G24>>` |
| **S-04** | `04_BRD.pact:442` `XE_UpgradeBranding` | **Paid premium consumed by the past.** `(add-time premium seconds)` extends from the **stored** date, never from now — correct for a live subscription, wrong for a lapsed one, which S-03 made universal. Measured end-to-end: premium advanced by exactly 2,592,000 s and was **still in the past**, the flag was set to 1 (BLUE) so other code reads the entity as premium, and second and third paid upgrades were both allowed. Real STOA is spent (two `coin.TRANSFER` legs, ≈19.1 + ≈57.4). | fixed by clamping the extension base to `now` | `<<SWP-G24>>`, which also pins the **other** branch of the clamp so the fix cannot drift into confiscating a renewal's remaining days |
| **S-04b** | `04_BRD.pact` `BRD\|C>UPGRADE` fifth guard | A **coverage hole caused by a defect, not by a missing fixture**: while premium was always behind the clock, `remaining` was always negative and the 15-day threshold guard could never fire. Repairing S-04 made it reachable for the first time. | fixed + pinned; BRD now 5/5 guards pinned | `<<SWP-G24>>` |
| **S-05** | `08_ATS.pact:883` `ATS\|C>ADD-HOT-RBT` | The exclusion list read `["V|" "Z|" "H"]` while the tested value is `(take 2 hot-rbt)` — **always two characters**. The third entry is one character, so `H|` never matched and **hibernation tokens were not excluded at all**, contrary to the comment directly above it. Every other prefix test in the tree writes the pipe. | fixed | `<<ATS-G15>>` |
| **S-06** | `06_DPOF.pact` `XI_SwitchCreateRole` | Re-derived "who is the previous holder" via `UR_Verum4` **after** `XI_UpdateVerum4` had already overwritten it with the new holder, so the revoke targeted the new holder and **cancelled itself** — "move" only ever GRANTED. A single move cannot detect it; it takes two consecutive moves. | fixed | `<<DPOF-MCR>>` (audit #2C) |
| **S-07** | `10_DPDC-N.pact` via both Talos modules, `C_RemoveSetNonceScore` | `nost` = *NoNCe-Or-SET*. Both `DPSF\|` and `DPNF\|` `C_RemoveSetNonceScore` delegated to `C_UpdateNonceScore`, handing it a **set-class** integer down the **nonce** path — so removing a set-nonce score targeted `UR_NativeNonceData id son set-class` instead of the set row. Found only by tracing delegation **for pricing**; **`ZALL` was green with the bug present and two REPLs exercise the path.** | fixed (rerouted; no price change — both bill 22 through the same shared reader) | — |
| **S-08** | `05_FVT.pact` `UEV_InjectContext` / `C_Inject` | **Injecting into a pool with no stakers reverted**, stranding the operation: vault/treasury required `denominator > 0` and farms required `s-fresh > 0`. The revert *looked* like a correct guard ("don't distribute to nobody"); no test ever injected into an emptied pool because every fixture staked before injecting. A near-miss found in the same pass shaped the fix: had the escrowed amount been folded into `available-rewards`, the last-claimant **dust sweep** — which pays the sole remaining claimant the entire `available-rewards` — would have let a *prior* cohort's last claimant sweep rewards escrowed for a future cohort. | fixed — guards removed, `zombie-rewards` added as **its own field**, flushed on the next non-zero inject | `deb-staleness-proof.repl` `TX-AQP-DEB10` |
| **S-09** | `02_SCORE.pact` `C_EnableDebBoost` | Structurally irreversible: **no disable function exists at all.** | accepted | `@doc` IMMUTABLE tier, pinned |
| **S-10** | `02_SCORE.pact:744` `C_ControlScore` | `can-upgrade` is a **one-way door** — the operation writes its own precondition, and re-enabling control needs the control operation the flag just disabled. | accepted | `<<AQP-G39>>` |
| **S-11** | `18_SWPLC.pact` `UEV_RemoveLiquidity` | Full pool drain to zero is permitted deliberately; the `@doc` argues gating removal on the owner's switch *"isn't a safety mechanism, it's a trust violation."* The resulting empty state is reachable but **not repeatable**. | accepted | `<<STAGEZ-20>>` |

## 1.5 Authorisation and architectural boundary

| # | site | mechanism | status | pin |
|---|---|---|---|---|
| **X-01** | `01_DALOS.pact` `P\|UEV_IMC`, seeded at `Stage_01/[2.1]_Dalos.repl:220` | **FIXED 2026-09-14 — and the finding NARROWED first.** The genesis sequence registered the **master keyset itself** as a DALOS inter-module policy, so `P\|UEV_IMC` (a `UEV_Any` over that list) passed for any holder of the master key, reaching `DALOS::C_RotateStoa` directly and **unbilled**. On review, that registration appeared in exactly ONE place in the repository — `Stage_01/[2.1]_Dalos.repl` — and in **no genesis payload**: the deployed system never had the exception, so the red team's "live hole in *Talos is the only supported client path*" **overstated it**. What existed was an audit harness weaker than the system it audits, and it was load-bearing: five guard-type assertions called `ref-DALOS::C_Rotate*` directly while carrying the **Talos** entrypoint names in their labels. Owner ruling: the mechanism is correct, but RotateStoa must pass through Talos. Registration deleted; the five assertions re-homed on the Talos path at `[6.12]_DALOS-ADMIN.repl` `<<TX-DA-004>>`, where they now also cross the billing leg. Blast radius **measured before moving anything**: deleting the line produced exactly 10 failures — those 5 assertions, counted twice — and **no other failure in the 21,732 the suite executed at that moment** (the headline is now 21,511 — see below). | **fixed** — `<<CONF-01>>` and `<<RT-B-001>>` now assert the refusal, each with a non-vacuity arm proving the Talos route still works and, in `CONF-01`, that it is billed | `<<CONF-01>>`, `<<RT-B-001>>`, `<<TX-DA-004>>` |
| **X-02** | `01_TS01-A.pact` `ORBR\|A_Fuel` | Written as `(with-capability (SECURE) …)` where that module's `SECURE` is `(defcap SECURE () true)` — a trivially self-granting cap — while its own `@doc` said *"can only be used by the Admin"*. **Verified by calling it with only a non-admin key signing: it succeeded and billed her 87 IGNIS.** Every other `\|A_` entrypoint composes `P\|ADMINISTRATIVE-SUMMONER`; this was a single-identifier outlier. Not theft — the STOA reaches the Liquid Index either way — but **it lets an attacker force an index move at a timing of their choosing**, which is valuable to anyone holding a position either side. | fixed. The obvious fix (swap `SECURE` for the admin cap) **is wrong and the suite caught it** — `XI_DirectFuelSTOA` does `(require-capability (SECURE))` internally; the correct shape is *admin cap gates, `SECURE` still granted inside it* | `<<CONF-04>>`, `<<CONF-05>>`; detector `admin-gate-terminal` |
| **X-03** | `02_DPDC.pact:1365` `XE_DeployAccountWNE` | Missing `P\|UEV_IMC`, unlike its immediate neighbour `XE_U\|Rnaq` — a forward-module entrypoint with no inter-module gate. | fixed | — |
| **X-04** | 14 ops across 4 families | A **gas-model lie**: a single `C_`/`A_` prefix promises bounded cost while the call tree reaches a heavy `URH_*`/`URHC_*` scan. `DPOF::C_WipeHeavy`'s own docstring reads *"|Heavy| reffers to the usage of expensive functions like `select` or `keys` (that arent meant to be used in transactional context)"* — and it carried a single `C_`. **The prefix contradicted the docstring inside the same function.** Found by `_heavy.py` over a 15,863-edge whole-program call graph; a per-member scan cannot see it, because the doubling rule is a claim about a call *tree*. | fixed — renamed to `CC_`/`AA_`, 126 replacements across 30 files, because the names are also IGNIS price-table keys | `single-reaches-heavy` = 0 |
| **X-05** | `06_VCT.pact` neighbourhood, `URC_AqpOwnerKonto` | Maps `0→SWP, 1→DPTF, 2→DPOF, 3→DPSF, else→DPNF` with **no range check**, so class 9, 400 and -1 all silently resolve as DPNF and the owner check on the line above does not stop a corrupt row. Without the `06_VCT:537` backstop a corrupt row would be vacated as the wrong class, against the wrong tracker tables. | accepted, backstop retained and pinned | `06_VCT:537` |

## 1.6 Missing validation

| # | site | mechanism | status | pin |
|---|---|---|---|---|
| **V-01** | `00_Demipad.pact:742` `UC_SlippageFactor` / `URC_Acquire` | **Unguarded negative slippage.** `URC_Acquire` pads each signed `coin.TRANSFER` cap by `(1 + slippage/100)`, which has no non-negative guard, so a negative slippage **shrinks the ceilings below the true cost** and the transaction can only fail — at the coin layer, with "Managed capability not installed", naming neither DEMIPAD nor slippage. What makes it real: the value most likely to be passed by mistake is **-1.0**, the documented "slippage off" sentinel **for the sibling `max-cost` argument in the very same call**. | **fixed 2026-09-15** — see §1.1d | `<<TX-ACQ-02>>` |
| **V-02** | `02_IGNIS.pact` `IGNIS\|C>ROYALTY` via DPDC collectable transfer | **The creator cannot be the patron.** The transfer pays an IGNIS royalty patron → collection creator; with the creator as patron the leg becomes a self-payment and the cap rejects with "Sender and Receiver must be different", naming neither royalty nor the collection. The operational shape is ordinary: **the launchpad operator paying gas for their own sale IS the creator.** `UC_CleanseAggregatedRoyalties` already drops zero-royalty entries; dropping `creator == patron` entries the same way would close it. | **fixed 2026-09-15** — see §1.1d | `<<TX-ACQ-02>>` |
| **V-03** | `16_SWPI.pact` `UEV_SwapData` | See G-34 — duplicated input tokens under the count bound are accepted outright. | **fixed 2026-09-15** — see §1.1d | `<<SWP-G1>>` |
| **V-04** | `06_U_DALOS.pact` vs `09_U_ATS.pact` `UEV_Fee` | **Two same-named validators, opposite verdicts on one input.** `U\|ATS::UEV_Fee` accepts `0.0 ≤ fee ≤ 999.0` at 4 dp; `U\|DALOS::UEV_Fee` accepts only `-1.0` (the "no fee" sentinel), `0.0`, or `[1.0, 999.0]` — so **0.5 falls in a hole**. A caller choosing between them cannot tell from the names. | **fixed 2026-09-15** — see §1.1d | `<<UTIL-10>>` |
| **V-05** | `19_SWPU.pact` / `SWP\|C_SmartSwapWithSlippage` | The slippage guard compares the caller's floor against the **fee-less hop quote**, not the delivered amount, so the delivered output can be below the caller's floor while the swap executes. Measured on the suite's own 6-hop route: 5.0 in, fee-less quote 4.999878, caller's 1% floor 4.949879, **actually delivered 4.541454** — 0.408 below the floor, 8.2× the chosen tolerance. The shortfall is the route's fee drag, which scales with hop count, precisely what a caller choosing a percentage cannot see. Separately, a **breached** bound **returns a message, it does not revert**; state is untouched and the patron is charged no IGNIS. | accepted / design — code and quote agree, and the hazard is at the UI boundary (`UC_SlippageMinMax` returns `[min max]`, shaped exactly like "minimum you will receive"); the soft no-op and the zero billing are both pinned as desired | `<<SWP\|TX 054-02>>`, `<<SWP\|TX 054-03>>` |
| **V-06** | `05_STOAICO.pact` | Two `@doc`-claimed admin gates on **money-moving vault mutators** had never been verified by any test. Invisible because `_docclaims.py`'s AUTHORITY regex matched too few verbs — *"Can only be DONE by the Admin"* did not match. Widening it took the tier from 7 claims to 15 and surfaced these two. | closed — both verified | — |
| **V-07** | `15_SWP.pact` `SWP\|C_UpdateFee` | A documented 0.0001–320.0 promile bound with no assertion behind it. | closed — both edges pinned | `<<SWP-G20>>` |

## 1.7 Client-facing diagnostics

Easy to dismiss and should not be: two of its members **abort the transaction**, and one made a
cost preview unusable for every input. Three shapes, ordered by how loudly each fails, each now a
regression detector that must stay at 0.

| # | shape / site | mechanism | status | pin |
|---|---|---|---|---|
| **M-01** | `(format "…")` with **no argument list** — 5 live sites | Pact's `format` takes a template *and* a list; given one argument it is an arity error resolving to a closure and the caller dies with `Expected Pact Value, got closure or table reference`. Strictly worse than the others because it also appears on **success paths, where `enforce`'s lazy message cannot hide it**. Sites: `08_ATS.pact:883` (guard fired, then died on its own message); `12_LIQUID.pact:125`; `03_DSP+.pact:360` (a *return value* for "nothing to mint"); `01_DPL-UR.pact:2430` (UI stage text); and `02_INFO-ONE+.pact:2465`, `INFO_ATS\|Cull`'s description — **broken for every input, always, so the op was unpriceable by any client.** *"Every one of the five sits on a branch tests do not reach — that is the mechanism, not a coincidence."* | fixed (all five; `format` dropped, since none of the templates contained a `{}`). Two further sites in dead `00_DPMF.pact` carry a `{}` **and** no args, so dropping `format` would print the brace; deliberately left | `<<ATS-BRD>>`, `<<LQD-03pre>>`; detector `format-no-arglist` |
| **M-02** | `15_SWP.pact:466` `SWP\|S>RT_OWN` | The message was written as a bare tuple `("…{}" [args])` with the `format` call omitted, so a tier rejection surfaced as `Cannot apply value to non-closure`. Survived because **`enforce`'s message argument is lazy** — never evaluated until the guard fires, and this guard had never fired in a test. Found **by accident**, while trying to pin a different guard twelve lines below it. | fixed | `<<SWP-G21>>`; detector `enforce-msg-not-format` |
| **M-03** | `11_VST.pact:686` `ATSU\|C>BRUMATE` | A bare string carrying two `{}` placeholders and **no `format` call at all**, so the caller saw the braces verbatim. The variant that **fails safe and silent**, which is exactly why it survived longest. | fixed | `<<ATS-G18>>`; detector `enforce-msg-bare-template` |
| **M-04** | `12_LIQUID.pact:125` `GOV\|MIGRATE` | The guard enforces `gap` (pause **ON**) while the sentence said **"offline"**. Five sites elsewhere use "online" for pause-on, so the convention was unambiguous. **Found only after M-01 was fixed at the same line: defect 1 hid defect 2, because a message that never renders cannot be noticed to be wrong.** | fixed | `<<LQD-03pre>>` |
| **M-05** | `01_DALOS.pact:508` `GOV\|MIGRATE` | **The twin of M-04 is still inverted.** Rejected because the pause is OFF, by a message saying migration "can only be executed when Global Administrative Pause is offline". An operator following that text would disarm the pause and retry forever. One word. | **FIXED 2026-09-14** (offline -> online); the LOGIC was always right -- P|TS enforces (not gap), so demanding GAP ON freezes the chain for the window in which the gas station is empty. | `<<DALOS-ADMIN-03b>>` | `<<DALOS-ADMIN-03b>>` |
| **M-06** | `05_DPTF.pact:1958` `UEV_ReservationState` | Both messages inverted: the arm that fires when reservations are CLOSED reported "already open", and vice versa. | fixed | — |
| **M-07** | `10_ATSU.pact:395` `ATSU\|C>FUEL` | Enforced `(>= index 0.1)` under *"Fueling cannot take place on a negative Index"* — so an index of 0.05 is **positive and still rejected**, and that caller was told something untrue about their own pair. Resolved by keeping the bound and fixing the message; the sibling `ATSU\|C>KICKSTART` applies the same 0.1 bound in the same file and words it honestly, which is the author's own statement of intent. | fixed | `<<ATS-G17>>`, which drives **both** reachable states (the `-1.0` no-RBT-supply sentinel and a live pair at 0.05) |
| **M-08** | `01_ANK.pact:292`, 7 message sites | `E-ANK` is **not a label** — it is the empty-anchor row constructor — so all seven ANK rejections open with `{"anchor-id": "\|","ouronet-account": "\|","promile": 0.0}`. ANK has no string label constant at all, so whoever wrote these reached for the nearest `E-`-prefixed name; `DPOF`'s `(defconst OF "Orto-Fungible")` is the shape intended. Found not by reading but by **driving a guard to failure and reading the output** — *the message is code too*. | open, one-constant repair | `<<AQP-G35>>`, pinned both ways so the repair verifies itself |
| **M-09** | `08_DPDC-S.pact` `UEV_Primordial` | Its length guard reports *"Incompatible Input for `<UEV_Composite>` Validation"* — it **names its twin**. Also a live example of the coverage tool's caveat: identical messages mean one test text-pins both. | **fixed 2026-09-15** — see §1.1d | `<<DPDC-S-G1>>` |
| **M-10** | `00_Demipad.pact:538/539` `C>DEPOSIT` | The SSTOA and OURO branches carry the **identical** message: the else-branch checks `iz-ouro` and says "SSTOA Deposits must be turned on". A type-3 depositor is told to enable the wrong switch. | open, one word | `<<DEMIPAD-G2>>` |
| **M-11** | `09_U_ATS.pact` `UEV_AutostakeIndex` guard 2 | See G-33 — the message describes a substring test the code does not perform. | **fixed 2026-09-15** — see §1.1d | `<<UTIL-06>>` |
| **M-12** | `2_Snakes` sale + `99_TS02-CPAD.pact` | Snakes has **no nonce guard**: a nonce the pad never stocked reports the `-1` sentinel, so the rejection comes from the **SUPPLY cap** ("Insufficient Assets for Acquisiton"). Over-buying real stock gives the identical message, so **the two failure modes are indistinguishable**. The Custodians twin says "Invalid … Acquisition Nonce". | **fixed 2026-09-15** — see §1.1d | `<<TX-ACQ-03b>>` |
| **M-13** | `99_TS02-CPAD.pact` — `SNAKES\|C_Acquire`, `CUSTODIANS\|C_Acquire`, `SPARK\|C_BuySparks` | The wrappers **discard the sale's own result**: the last form is `(ref-TS01-A::XB_DynamicFuelSTOA)`, whose value is a bare `true`, so the caller cannot tell what was bought. Violates the Talos rule ("a clear `format` result string explaining the branch taken"), and `KPAY\|C_BuyStoicPay` **in the same file** does it correctly. 3 of the 4 refuel-carrying sale wrappers. | **fixed 2026-09-15** — see §1.1d | `<<TX-ACQ-02b>>`, `<<TX-ACQ-03b>>` |
| **M-14** | `01_DALOS.pact` `GAS_PAYER` | See G-29 — every message nested inside the outer `enforce-one` is swallowed. | open, annotated | `<<DALOS-G2c>>` |

## 1.8 Gas, performance and portability

| # | site | mechanism | status | pin |
|---|---|---|---|---|
| **R-01** | `2_CITIZEN/Stage_Z/01_DPL-UR.pact` `URC_0021_CollectablesHeader` | **Cannot fit in a Kadena transaction.** `keys` costs a **flat 40,009 gas** — measured at 10/100/400/1000 rows; the linear-scaling hypothesis was tested and is wrong, and that matters, because the linear story makes this a future problem while the flat one makes it a present fixed-size budget. This reader does four scans ≈160k gas, over the 150k per-transaction limit on its own. At 144× a point read, three scans is the hard ceiling. | accepted — this is the real reason these readers belong on `/local`, independent of any admin question | `<<STAGEZ-17>>` |
| **R-02** | `2_CITIZEN/Stage_Z/02_EXPLORER.pact`, `01_DPL-UR.pact` | Canonical Stage-Z readers **hardcode mainnet deployment-hash ids** (`Auryndex-O136CBn22ncY`), so they can never resolve on a test chain and **do not survive a redeployment** — if the ATS pairs are reissued under a new hash the landing page silently starts aborting and no test fails. The inconsistency is *inside a single `let`*: two ids above are derived chain-agnostically. | open owner decision — both files carry a "canonical; keep aligned with live net" header, so editing risks desynchronising the repo from what is deployed. The testing variant is **generated** by `_stagez_variant.py` with `--check` wired into the gate (*a copy rots; a generated file cannot*) | `<<STAGEZ-02>>` |
| **R-03** | codebase-wide — **150 dead `let` bindings** | Values computed and never read: 0 heavy scans, **95 point reads**, 55 pure compute. Gas waste on paid paths — one confirmed instance is on a **transactional** swap path — and a reliable sign that a function was edited without cleaning up behind the edit. Concentrations: 24 in `02_SCORE.pact`, 21 in `05_FVT.pact`. Four were deleted after pinning the equivalence by execution first. | open, catalogued | `_deadbind.py`, self-verifying against two hand-confirmed canaries |
| **R-04** | `18_SWPLC.pact` `URC_PoolValueFromGraph` | Same pool, same empty graph: the raw twin **faults**, this one returns **`[0.0 0.0]` silently**. A caller handing it a stale or empty graph gets a plausible-looking zero valuation rather than an error. Safe today only because `URCx_Hopper` always builds the graph immediately before use. | open — *the trap waiting for the first cached-graph caller* | recorded at the site |
| **R-05** | `22_PYTHIA.pact` `UR_PythDailyExists` (2026-07-21) | Called `(keys PYTHIA\|T\|PythDaily)` — a **full table enumeration — once per flush entry**, plus a per-entry `enforce` inside the cap guard and double reads during validation. ~80,000 gas per day-entry. Functionally correct, so nothing failed; only the *cost* was wrong, and nothing measured gas per entry until a probe was written to size the batch cap. | fixed — `try` + a single `read`, one batched `UEV_FlushEntries` fold, sealed-day check moved into the cap. Post-fix ~103 gas/day insert, ~217 seal; batch cap set at 1000 | `[6.10]_PYTHIA-flush-gas-probe.repl` |
| **R-06** | `05_FVT.pact`, `06_VCT.pact` `CC_*Chunk` batch clients (2026-08-20) | **Two accidentally-quadratic scans.** The per-user leaf called `URH_FvtEnabledScoreEntityIdsForFvt` and `URH_FVT-RG\|EnabledRewardRows` — scans whose argument is **FVT-level, never the user** — so a loop-invariant scan re-ran once per user, giving O(users × table). A 50-user inject cost **3,957,034 gas**, un-transactable. Every functional test passed: the result was always correct, only the cost scaled wrong, and there is **no small-N signal**. | fixed with `*In` twins taking the pre-scanned list — inject 3,957,034 → **276,925** (14×), finalize 2,106,332 → 146,273, sweep recompute 666,317 → 106,300. **Watch-out recorded:** one caller still used the old scanning leaf after the sweep path was hoisted, so sweep dropped and inject stayed at 1.4M — *when you hoist, grep every caller of the convenience leaf, not just the one you were measuring* | `Kursan/AQP-scale-*.repl` |

## 1.9 Deployment, wiring and dead-on-arrival defects

A class the paper should not miss: **code that compiles, loads and deploys cleanly, and does not
work.** Pact resolves `::` modref calls, table existence and object field names **at runtime**, so
none of these is a load-time error.

| # | site | mechanism | status |
|---|---|---|---|
| **W-01** | `2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact` | **Two `deftable`s declared, neither `create-table`d.** A `deftable` is only a declaration, so the module compiles, loads and deploys cleanly — and at runtime every path died on `Table ouronet-ns.CADUCEUS_CADUCEUS|ConfigTable not found`. Since every function reads or writes the config row, **nothing in the bridge worked at all.** Found by writing the module's **first-ever REPL suite**; CADUCEUS previously had zero coverage, its only prior exercise being a load-only structural check whose own header admits it is not a functional proof. *"A load is exactly what this defect survives."* | fixed (two `create-table` calls). `[table-never-created]` rule added to `_conformance.py`, verified by reverting the fix and watching it fire |
| **W-02** | `MTX-AQP` `P\|A_Define` | **MTX-AQP was never registered on RPS's inter-module policy** after the FVT→RPS module split. Its deb-fix and re-score defpacts drive `RPS::XE_FvtFixUserChunk` and `…SweepRecomputeChunk`, so **the whole deb-staleness fix path would have failed on-chain.** The split had been verified by a behaviour-preserving equivalence gate that ran the paths FVT/VCT/DSA exercise; the MTX defpact path was not in the fast gate. | fixed |
| **W-03** | `04_FVT.pact` (7,527 lines) | **Over the StoaChain deploy cliff — the module was undeployable.** Module-load gas rises roughly as the 7th power of transaction size, so the 2M cap corresponds to ≈6,635 lines. **The REPL loads modules under a different cost model than the chain**, so a file that loads fine locally can be undeployable on-chain, and nothing in the test pipeline measures deploy size. | fixed by a behaviour-preserving split into `04_RPS.pact` (5,617 ln, a pure leaf) + `05_FVT.pact` (3,878 ln, the client shell) |
| **W-04** | `06_DPOF.pact:756` `DPOF\|C>TRANSMIT` | The defcap read `(at "meta-data" td)` on an object whose declared schema field is **`meta-data-array`**. The constructor builds it correctly; only the consumer used the wrong string, so **every call crashed unconditionally** with `Key "meta-data" not found`. Pact's `at` on a missing object key is a **hard runtime error, not a static one** — object literals are not schema-validated at the call site the way typed parameters are — so it compiled and loaded cleanly, and the correct field name sits a few hundred lines away in the constructor. DPOF's own REPL suite had **zero assertions of any kind**. Found by accident, on the first ever live call, with a perfectly ordinary input. | fixed (one string) |
| **W-05** | 11 dead `::` modref calls | `::` calls resolve **at runtime against the concrete module**, so a misspelled member or wrong argument count deploys cleanly and dies only when that branch executes. Sites: `02_TS01-C1.pact:404/423` `DALOS::EliteAurynID` (real name `UR_EliteAurynID`) — **both Talos client entrypoints were entirely dead**; `15_SWP.pact` ×7 calling `ATS::DPTF\|C_Toggle{Burn,Mint,FeeExemption}Role`, which ATS has no member of (the 3-arg shape matches `DPTF::C_Toggle*Role` exactly and `ref-DPTF` is already bound in the same `let`); `12_LIQUID.pact:479` `DALOS::C_TransferDalosFuel`; `16_SWPI.pact:1278` `U\|SWP::UC_ComputedInverseWP`; and three `INFO-ONE+` previews passing `ats` to `URCi_` readers of a different arity. *"The pipeline being green proves nothing about call sites that no test exercises."* Of 442 Talos client ops, ~10 are never referenced by any REPL — **untested-and-dead is the combination to fear.** | 4 fixed (the two elite ops + the three previews). **The SWP ×7, LIQUID and SWPI calls are open owner decisions** on the intended target; the SWP one also raises a layering question (a core module calling another core's `C_`). Detector `_audit_modref_calls.py`, mutation-tested, exits 1 on any dead call or arity mismatch |
| **W-06** | `2_CITIZEN/Stage_Z/03_DSP+` `A_OuroMinterStageOne` | Declared return type `[decimal]`, actual returned `[string]` — a runtime check in Pact, and the entrypoint had never been invoked by an asserting test. | fixed (found by the exhaustive `ZALL` run) |
| **W-07** | `2_CITIZEN/1_AOZ/01_AOZ+.pact` `UR_NonFungible` | **A wrong-column projection, so the registry was write-only.** The reader projected `"sf-asset"` — the *SemiFungible* column, copy-pasted from the reader directly above — out of `AOZ\|T\|NonFungibles`, whose schema field is `nf-asset` and whose writer writes `nf-asset`. **A projecting `read` does not reject an unknown column; it returns `{}`**, so the `at` died with `Key "sf-asset" not found in object: {}` for **every position, always**, and the NonFungible registry could be written but never read through the public interface. It survived because nothing in the suite called either half. | fixed. New gate-enforced detector `REPL/tools/_colproj.py` for the class (currently 0 across the tree); pinned by `modules/AOZ.repl` `<<AOZ-06>>` |
| **W-08** | `02_Snakes.pact` `A_UpdateSharePrice`, `03_Custodians.pact` `A_UpdateQuintessencePrice` | **Dead on arrival, both of them.** `DEMIPAD::A_DefinePrice` opens with `P\|UEV_IMC`, a `UEV_Any` over the caller-policy guards DEMIPAD has registered, and the one that admits each sale module is a **capability guard** — `(create-capability-guard (P\|SNAKES\|CALLER))`. A capability guard only passes while its capability is **in scope**, and these defuns acquired nothing at all, so **every invocation died on `P\|UEV_IMC` with "None of the guards passed", admin signature and all.** Their sibling `C_Acquire` earns the same gate only because its defcap composes the policy capability. A second consequence: the operation's **actual** authorization chain — `DEMIPAD\|C>DEFINE-PRICE → C>SECURE-ADMIN → GOV\|DEMIPAD_ADMIN` — was therefore **unreachable**, and is now the gate that decides. | fixed by wrapping each in `(with-capability (P\|SECURE-CALLER) …)`, which grants no authority and only proves the call originates inside the module; pinned by `modules/LAUNCHPAD.repl` |

---

# 2. Methodology traps

Not contract defects. These are the things that cost time, produced false greens, or made a
measurement mean something other than what it appeared to mean. They belong in the paper because
several produced results that were **confidently wrong**, and the corrections are what makes the
rest of the evidence trustworthy.

## 2.1 Traps that produced a false green or a false clean

| # | trap | what happened |
|---|---|---|
| **T-01** | **A stale log at a well-known path answers a question nobody asked it.** | A gate run launched as `cd REPL && … python3 tools/_gate.py > /tmp/gate11.log` from a shell **already inside `REPL/`**: the `cd` failed, `&&` short-circuited, the gate never started — and an earlier session's log was still at that path, ending in `GATE GREEN`. A trailing `; echo "GATE rc=$?"` reported the *echo's* success. A stale green was read as a fresh green and it was hiding a real failure. The same shape had already cost two 6-minute runs when a generator step short-circuited an `&&` chain. **Fixed structurally, not by resolving to be careful**: `_gate.py` now prints `GATE RUN STARTED <timestamp> (pid N)` as its first line, flushed before any work — *a gate log without that header was never produced by a gate run.* |
| **T-02** | **A detector that reports zero has proven nothing until you have watched it fail.** | `_infostoa.py` reported "0 to review" **twice while live defects sat in the tree**, and both zeros were tool bugs: it matched **prose** (`STOA|C_Collect` appears inside a `@doc`, so it invented a call path), and it required `::` on callees, making it blind to every same-module hop — which is most of them. Caught only by **mutation testing**. The same discipline caught bugs in `_vacuous.py`, `_conformance.py`, `_docclaims.py`, `_eagerlet.py` and `_orphanmatch.py`. **A clean 0 from a new rule was wrong four separate times in one session.** Rule adopted: every tool carries a `--selftest` or a live canary, and `_gate.py` byte-compiles and self-tests all of them **before** running a single REPL — because for two runs the gate was GREEN while `_conformance.py` could not even be imported. |
| **T-03** | **A coverage tool that answers "was X called" is not a proxy for "does X equal Y".** | `_scale_report.py --untested` measures **static call-graph reachability** and counts a preview as covered if any `.repl` merely *names* it — including shape-only checks and abort-pins. The honest split from the purpose-built `_info_measured.py`: 412 declared previews, 397 named, and at the time only 366 actually **measured against a real charge**. The real remaining work was 46, not the 24 the reachability count implied. The same tool's `calls to a ref- binding this tool could not resolve: 89` line is why "78 unreached `UEV_` guards" was carried as the next major worklist item for two sessions — **it was an artefact**, and `_enforce_coverage.py`, which owns that question, had the live unpinned count at 0. |
| **T-04** | **Coverage computed over the wrong population.** Six independent disguises. | (a) The first "100%" was wrong — nine entrypoints lived only in files the gate does not run, so they were invoked and re-executed by nothing; protected figure 439/448. (b) Assertions in **orphaned** files counted as pins while never executing — 535 "pins" were really 526, so **9 guards had a pin on paper and no execution behind it**; closing that gap **raised no number, it made the existing number true**. (c) A **commented-out invocation is not coverage** — stripping comments dropped 98% → 94%, 13 entrypoints "covered" by `;` alone across 85 sites. (d) Coverage *counted* is not coverage *gated* — 51% → 95%, closed by fixing **exclusions**, not by writing tests: three whole suites were excluded **by filename prefix instead of role**. (e) `_enforce_coverage.py` counted *sites* rather than assertions, so it **grew** as duplicates were properly driven. (f) `_docclaims.py` counted a claim as touched if the function's name appeared anywhere in any `.repl` — over-counting comments, and under-counting behaviourally-exercised guards; **roughly a third of that worklist was naming, not coverage.** |
| **T-05** | **A bare-substring `expect-failure` is not a pin.** | Two assertions were green for the wrong reason: one expected `"Amount"` and matched `"Invalid Redemmption Amount"` by substring while the guard it credited was never reached; one was a **2-argument** `expect-failure`, which passes on *any* error. *"With the 2-arg form all six Stage-Z findings would have gone green against the wrong error and proved the opposite."* Current state: 1,147 sites, 1,112 strong, **35 weak — all 35 in ungated scratch files**, verified against the gate's entrypoint list. |
| **T-06** | **The author's own vacuity detector missed a vacuous assertion the author wrote.** | A no-leakage check written as `(expect "…" true (= (UR_NonceSupply X) (UR_NonceSupply X)))` — and `_vacuous.py` returned a clean 0, because its rule compared *expected* against *actual* and was blind to a self-comparison nested **inside** the actual. That is the shape a leakage check degrades into most naturally. Fixed with a depth-aware rule; the corrected assertion then **failed on its first run** — *a real value is something a test can be wrong about.* |
| **T-07** | **Two existing "proofs" were vacuous — the most valuable find of the doc-claims phase.** | `[6.3]_SWP.repl` carried two byte-identical proofs for a graph-**sourcing** refactor, both on a pool whose first token is OURO. `URC_PoolValueFromRaw` short-circuits on the `id == ouro` branch and **never reads the graph argument at all** — verified by passing an empty graph and getting the identical answer. **Both would have passed if the parameter were deleted.** *An equality between a function and its parameterised twin proves nothing until you show the parameter is consumed. Starve it and watch it break.* |
| **T-08** | **The gas meter must read the OP's patron, not the file's.** | Four measured blocks passed vacuously because the ops were paid by a different account than the one being differenced: the delta was a flat `0.0`, and the equality then passes **exactly when the quote is also zero** — silently converting every IGNIS-charging op in the family into a vacuous test. It surfaced only because two of the four had non-zero quotes. |
| **T-09** | **A zero-versus-zero equality is vacuous on its own.** | Every measured block carries a `(> real 0.0)` companion. Where zero *is* the right answer, the non-vacuity guard is the surrounding transaction, which independently pins that the op **did the work** — so the zero is a statement about the fee, not about whether anything ran. |
| **T-10** | **A test that restates what the code does converts a defect into a requirement.** | `<<ATS-BRD>>` asserted `(add-time (at "genesis" b) (days 90)) == premium-until` with a comment rationalising it — which is S-04 stated as a requirement, and it was *accurate about the old code*, so it read like deliberate design. *A test earns the right to state a rule only once somebody has checked the rule is intended.* |
| **T-11** | **When a test's doc string and its expected message describe different things, that gap is an unfiled defect report.** | `TX-VCT-N01`'s label said "gas-ok requires l>0" (the intent) while its expected string was `Array index out of bounds` (the symptom). Both were true at once, which is exactly why it survived review — the test was green, and green tests do not get re-read. The suite convention is now that a deliberate one carries a `FINDING:` marker; **that marker is the difference between documentation and camouflage.** |
| **T-12** | **A documented root cause is a hypothesis.** | The gate's EXCLUDED note claimed eight harnesses shared **one** root cause at a named line. It was **seven** harnesses, **three** branding sites, and branding was **not the only cause** — two then failed on a completely different ownership check. *"It had been recorded confidently enough that nobody re-tested it, and it kept seven files out of the gate."* Re-testing it took assertions from 11,563 to **17,178**. |

## 2.2 Pact-language and REPL semantics that cost time

| # | fact |
|---|---|
| **T-13** | **`expect-failure` does NOT roll back DB writes.** There is no savepoint; a failing call can have mutated shared fixture state before the abort. Proved directly: a bootstrap does four writes then hits a failing guard, and afterwards the row exists — *in the same transaction and after `commit-tx`*. *"The error is invisible: the assertion goes green, and the damage shows up as an unrelated suite failing later, or worse, not failing."* 22 such sites existed and `rollback-tx` was used in **exactly zero** places. Two detectors exist (`_leakaudit.py`, `_leakaudit_xmod.py`), because the write and the guard often live in different modules. Audit result: 0 of the pins sit downstream of a write. |
| **T-14** | **`try` forces read-only mode, and it is the mirror trap.** `keys`/`select` inside a `try` fail with *"Operation disallowed in read-only or sys-only mode"* — **the probe's error, not the code's** — while a plain `read` under `try` works, which is what makes it convincing. So probing a guard with `try` reports the *write* failing and the guard looks unreachable: *"the `try` probe said unreachable, the `expect-failure` probe said the guard fires. Both were telling the truth about different things."* `try` also returns its **fallback**, never the error text, and does not catch a native out-of-bounds index at all. |
| **T-15** | **Do not probe for an unusual VALUE with a `try` fallback that IS that value.** `(try [] (DPTF.UR_RewardToken t))` made two tokens look as though they already held `[]`; they were not DPTFs in that harness and the read was aborting. *"I briefly believed the bug was already live."* |
| **T-16** | **`test-capability` cannot acquire an `@event` defcap** — it routes to the install path. But it **can** acquire a plain defcap directly, with no Talos call, no account and no signing, which made whole families reachable that had been filed "needs a fixture"; a previous pass had concluded the `GOV|*_ADMIN` family unreachable because Talos's keyset check fires first — *true premise, invalid conclusion*. |
| **T-17** | **`env-module-admin` must sit at transaction top level.** Inside a `let` the write silently aborts the whole file with **no FAILURE line**. Corollary: `grep -c FAILURE` = 0 is **not** proof of a passing run — a hard load failure emits no FAILURE lines at all. Always confirm `Load successful`, and use the runner rather than `pact <file> | grep FAILURE`. |
| **T-18** | **A managed `coin.TRANSFER` cap is a per-TRANSACTION budget, not a per-call permission.** Signing for one call's worth and then driving six STOA-priced calls fails on the *second* with "STOA TRANSFER exceeded for balance 0.0" — which reads like the patron is broke. **Tell: a real funding problem fails on the FIRST call.** Separately, building the cap list with `(map (lambda (t) (coin.TRANSFER …)) targets)` installs **nothing**, silently — the values must be written out literally. |
| **T-19** | **A fix that changes two things proves nothing about either.** A companion claim to T-18 — "`env-sigs` inside a `let` does not install managed caps" — was recorded as a law and is **false**; two things were changed at once and the wrong one was credited. A long-green test installs four managed caps from inside a `let`. *Change one, re-run, then change the other, or you will write down a law that is half superstition.* |
| **T-20** | **The REPL timeline is not monotonic.** Each loaded file sets its own `env-chain-data`, so a transaction can run at a block-time *earlier* than the one at which an entity was issued. This is why the first BRD repair — stamping `premium-until` at issuance — broke three previously-working call sites; the answer was a fixed point no clock can overtake. A block that moves the clock must move it back, because `rollback-tx` does **not** undo it. Conversely, **moving the clock is often cheaper than building a fixture**: one guard filed as "needs a fixture" fired as the chain already stood, because the suite's clock is 2035 and the release dates were written for 2026. |
| **T-21** | **A REPL is always transactional; production is not.** Nodes run `--allowReadsInLocal` and UI readers are invoked via `/local`. `(env-exec-config ['FlagAllowReadInLocal])` is rejected as "Repl flags not recognized" — it is a node flag. **The REPL cannot model production here at all.** This single error is the root of both withdrawn findings in §3. Standing addition to the finding template: *"In which execution mode and which chain state did I observe this, and is production ever in it?"* |
| **T-22** | **Pact prints object keys alphabetically, not in constructor order.** Reading the printed shape to infer argument order gets it backwards. Read the `UDC_` body. |
| **T-23** | **Pact does not arity-check module-reference calls at load** (W-05), and `at` on a missing object key is a runtime error, not a static one (W-04), and a `deftable` without `create-table` loads fine (W-01). **"It compiles and deploys" carries far less information in Pact than it does elsewhere.** |
| **T-24** | **`env-module-admin` + `rollback-tx` is the technique for "unpinnable" guards — with a hard scope caveat.** Four conditions make it safe: unqualified module name; left-biased partial-row merge; `rollback-tx` **never** `commit-tx`; and a **separate no-leakage transaction**, which is not optional — a `commit-tx` typo would leave a sovereign table claiming an entity that does not exist and every downstream liveness check would silently agree. **The caveat is the important part: it pins a guard's *reaction* to a state and says nothing about whether the state is reachable in production.** Conflating those two produced both withdrawn findings. Prefer the client path where one exists — a flag the client takes as an argument is both cheaper and documents a real product property. |
| **T-25** | **Pact's `^` on decimals is computed via IEEE-754 float64**, silently, regardless of whether the exponent is typed `:integer` or `:decimal` — while `+ - * /` are exact. The repo's own semantics note documented `decimal` as "exact", and **small-magnitude sanity checks matched**, because those results fit inside float64's ~15–17 digits. The loss only appears once operands need more precision than that. |

## 2.3 Fixture and search discipline

| # | lesson |
|---|---|
| **T-26** | **"No fixture" almost always meant "not reachable from the state these files leave behind".** Twelve ops filed as unreachable fell to the same move — **issue a virgin entity instead of hunting for one**. The label is only honest when the op is **structurally** unreachable — a defpact that cannot fit one `begin-tx`, or an op whose preview credits rather than charges. Three guards additionally carried stale "unreachable" notes that were really statements about one collection; the fixture existed in a **sibling harness** every time. |
| **T-27** | **When two guards read as a contradiction, they are usually an intersection.** `DPTF\|C_ToggleFeeExemptionRole` was declared unreachable by **three** separate attempts reading `UEV_NotSmartOuronetAccount` AND `UEV_EnforceAccountType … true` as unsatisfiable. They are different predicates: the first rejects the eight hard-coded protocol contracts, the second demands a smart account. The intersection is exactly one class — a **user-deployed smart account** — and the fixture had been in the boot chain the whole time. *"I could not find a fixture" is a statement about the search, not about the code.* |
| **T-28** | **A guard's reachability is a property of its CALL SITES, not of the guard.** One cap's amount/parity guards are unreachable through the NFT client (which hardcodes `amount = 1` and derives both list lengths from the same list) and reachable through the SFT client (which takes all three from the caller). **Enumerate a guard's clients before filing it unreachable.** |
| **T-29** | **A fix plus a negative test can look complete while leaving the positive case permanently unexercised.** A repair to `VST\|C_Slumber` removed its only caller — which had been calling it **by mistake** — and never wrote a correct one, so the guard was tested, the misuse was tested, and the success path had **no test at all**, in an op whose only prior execution in the repo's history had been a bug. *When a repair deletes the only caller of something, check whether it was the only caller.* Four ops in total had never succeeded anywhere and now do. |
| **T-30** | **Choose fixture rows by predicate, not by literal.** `<<VST-G7>>` selected the first sleeping nonce with positive supply **at runtime** rather than hardcoding, and that is the only reason S-02 was found. |
| **T-31** | **Assert the state your fixture was supposed to create, not just the outcome you were after.** S-03/S-04 were found exactly this way; going straight for the refusal would have shown the upgrade "working" and recorded the guard as needing a fixture. And **assert the restore** — *"I wrote 'the 20-day shift is undone' without actually undoing it; the assertion caught it."* |
| **T-32** | **Before calling a preview/charge gap a defect, ask what else debited the patron in that transaction.** DPDC transfers debit twice — once for gas, once inside `C_IgnisRoyaltyCollector` — and the preview quotes only the gas leg. **The same observation is a fixture hazard in one place and a defect in another; what decides it is what the preview CLAIMS to cover.** The DPDC transfer preview does not claim the royalty; the launchpad sale's `URCi_Acquire`, documented as "the Sigma of the two Talos ops", does (P-07). Read the `@doc` before deciding which it is. |
| **T-33** | **When a measured gap is small, ask whether it is small because the quantity is small or because the error is small.** Those look identical at one data point, and widening the assertion to a tolerance would hide a structural omission behind a plausible epsilon. |
| **T-34** | **Before building a fixture, check whether an existing chain already builds the state** — and put a new test in the entrypoint that already loads its fixtures. Adding a suite load to get three assertions cost +450 executions and +24s; moving the same three to a harness that already had the state cost +3 and +4s. Host a citizen module's tests where it deploys **cheapest**, not where it conceptually belongs (2–7× wall-time differences for identical assertions). Six of one module's eight unpinned guards needed **no fixture at all** — a Kursan harness had already built the vault, the agency, the oracle authority and a second funded participant. |
| **T-35** | **A shared suite file can only use what its NARROWEST loader gives it.** A reader named inside a `Stage_0*/*.repl` compiled under one entrypoint and failed the gate under another with *"Module INFO-TWO has no such member"* — a message that points at the module, not at the missing loader. The fix is to add the load to the **runner**, never to the shared file. Applied three times. |
| **T-36** | **`archive/` and `_scratch_*` files are a fixture cookbook.** Ungated and assert little, but written while investigating real findings, and they contain worked recipes for states no gated suite leaves behind. |
| **T-37** | **Executed assertions are not distinct assertions.** `_gate.py` counts executions, and shared files run once per entrypoint that loads them — so **9 new preview blocks moved the headline by 345**, while a day that *added* 551 executions wrote only 13 assertions and saw the distinct count *fall* because probe scaffolding was deleted. **Always decompose a delta before publishing it.** |
| **T-38** | **A scratch loader outside the guarded glob runs as a real gate entrypoint.** `modules/*.repl` **and** `Kursan/*.repl` are both globbed into the gate; the scratch guard covered only the first, and a probe dropped in the second ran for real. A forgotten probe in `modules/` had earlier failed the gate 200 s in. |
| **T-39** | **Two operational rules with real cost.** `_prerun.sh` checks for leftover PROBE blocks and for **lost assertions** by comparing per-file counts against HEAD — but the HEAD comparison cannot see work lost *during* a session, so `--snapshot` records counts after a green gate (verified by replaying the exact accident that motivated it). And **tag collisions** are invisible to assertion counting: `grep -c '<<TAG>>' <file>` before appending. |

## 2.4 Tooling discipline

| # | lesson |
|---|---|
| **T-40** | **A static detector works when the defect is a property of ONE function; it fails when the defect is a DISAGREEMENT BETWEEN TWO computations.** `_infostoa.py` works because its signal is a literal zero. The IGNIS analogue was attempted twice (168 then 117 suspects, all noise) and **cannot work**: a composer `URCi_` is *supposed* to name a function the exec never calls, so the detector flags the architecture. The real question — does the aggregate equal the sum of the legs? — is **numeric**, and only measurement decides. `_infodrift.py` was deliberately not committed: *shipping a 117-line noise report would train everyone to ignore it.* |
| **T-41** | **Detector shipping criterion: does the syntax alone settle it?** Four rules were declined on signal-to-noise — an eager-`let` mute-guard rule (**182 hits**, nearly all benign, *and it missed the two instances that motivated it*), the `enumerate 0 -1` idiom (**244 hits**), `cross-module-scan`, and extending `admin-gate-terminal` to `C_` (8 hits, all false positives). The rules that shipped had 7, 2 and 1 hits with zero false positives. |
| **T-42** | **The interface-shadow trap: every name in this codebase resolves twice** — once as an interface declaration with an empty body, once as the real implementation. Any tool taking the **first** match reads the declaration, sees no body, and concludes "touches no table" / "has no gate" for every function in the file. **It has cost three tools**, producing "224 ungated `A_` functions" (true number **1**) and "159 pure-argument guards" (true number **69**). **Signature: an implausibly large finding count.** Corollary: *"if a scan of this codebase returns hundreds of hits, the scanner is broken, not the codebase."* |
| **T-43** | **Structure beats regex whenever the thing you are matching can wrap.** A plain grep for one-argument `format` found five sites; the structural rule found seven — two more whose templates wrap across lines with `\`-continuation. Relatedly: **always strip comments before counting hits** (a multi-arg `or` scan first returned 24; every extra one was prose), and **import `strip_comments` from `_pactlex`, never re-derive it** — it has shipped broken at least four times, because Pact `@doc` strings continue across lines and a naive escape parser desyncs on them. That desync has produced a "20 false leaks" report, a wrong root-cause diagnosis, and a scanner that went blind from the first continued `@doc` onward. |
| **T-44** | **Two tools answering two different questions, and the one whose number was easier to quote was the wrong one.** `_cheapseam.py`'s ~25 was quoted as the guard worklist; the real figure from `_enforce_coverage.py` was 74. `_cheapseam.py` also **overstated by ~30%** until dead-module and already-annotated filters were added. **An audit figure must name the tool that owns it** — which is why `_suite_stats.py` computes nothing itself and cites a source command beside every section. Two tools also disagreed about what counts as "annotated": matching `;;UNREACHABLE` on the line immediately above finds the *continuation* of a multi-line note and reports a clean 0. |
| **T-45** | **Subagent reports are evidence, not findings.** Two research agents contradicted each other on whether the gas toggles were on, each with a full, internally-consistent derivation; one had read the seed values and missed the line that flips them, and a direct probe cost one command. A report claiming a **1,429× under-quote** was off by three orders of magnitude and in the **opposite direction** — and **carried its own contradiction and said so**, noting that if the claim held, a known-green suite would already be red. *Read a finding's own caveats as load-bearing.* Five read-only research agents closed the last eleven guards; **two of the eleven hypotheses were wrong, and only execution caught it.** |
| **T-46** | **Anchor edits on function BODIES, not names.** Interfaces are co-located with modules in the same file, so `(defun INFO_VST|CreateFrozenLink:` matched the **interface stub** and the "next" match was ~1300 lines away inside an unrelated function. Five previews were silently rewritten to call a VST function. It was caught immediately, but **only by luck** — the inserted text happened to reference a modref those functions do not bind. *Had they bound it, this would have compiled and quietly reported VST's link price for five DPTF operations.* A related hazard: a 3-line anchor sequence that appears twice in one file *"would have charged $100 to the WRONG function."* |
| **T-47** | **Never use paren-depth scanning to define an edit region in Pact.** Use line-based boundaries. **This has destroyed source twice** — once deleting 624 lines across four files, once duplicating 1,780,444 lines across 19 — and both were caught only by checking `git diff --stat` afterwards. Always assert an invariant the edit must preserve: for an in-line substitution the line count cannot change; for a re-pricing refactor, *an already-priced row must not change value*, checked by regenerating and diffing the sheet after every step. |
| **T-48** | **Never `git checkout --` a file in a tree with uncommitted work.** It discarded an unstaged rename from a prior session; unstaged changes are not in git objects and `git fsck --lost-found` had nothing. Recovered by static analysis of stale modref references. **The blast radius of `checkout` is the whole file, not your change.** |
| **T-49** | **Never edit source while the gate is running**; it reads 305 files across 16 workers, and two runs failed on mid-edit files while **both looked like real regressions**. And **never `pgrep -f` for a string your own waiter command line contains** — it matches itself and spins forever (hit twice). |

## 2.5 Defects in the pricing generator — a class of its own

Twenty-two distinct blind spots were found and fixed in `REPL/tools/_ignis_price_sheet.py` during the
`#76` rehaul. The governing observation is stated in the pricing reference itself and is worth the
paper's attention as a methodological result:

> **Every defect found in the generator made the published sheet disagree with a chain that was
> already correct. When a price looks wrong, suspect the sheet first.**

The most instructive, because each is a distinct *kind* of blindness:

| blind spot | what it published |
|---|---|
| A literal `0.0` cumulator counted as a price — but a 0.0 cumulator is the **identity arm of a conditional**, not a charge | **every SWP swap published as FREE.** *"Publishing 'swaps are free' is strictly worse than publishing 'unknown'."* |
| Cumulator constructors not followed **cross-module** | the flat $50 fee-unlock **published as 2 ignis** — only the locking direction's base was visible and the entire unlock charge was invisible |
| son-branch legs **summed instead of selected** | `DPSF\|C_Issue` and `DPNF\|C_Issue` both published **4549** — *"a number no caller can ever pay"* |
| STOA detected only via `UR_UsagePrice`, while issuance readers call `UC_StoaPrice` directly — **compounded** by the executor seeding the per-asset keys **twice** (stale literals, then derived overrides) and the literal-only regex reading the **stale** set | the whole STOA column read `—` |
| Aliases read as module names (`ref-B\|DPOF` binds alias `B\|DPOF` to module `DPOF`) | every branding op; an earlier instance dropped the **entire AQP family** plus five citizen modules (297→393 ops when fixed) |
| `@doc` prose not stripped: `"(?:[^"\\]\|\\.)*"` cannot cross a newline, so **no doc string ever closed** — and the unmatched quote then **stripped real code** | functions charged to the wrong op, plus 12 phantom "regressions" that produced a **wrong root-cause diagnosis** and a refactor that was never needed |
| Routing by helper name instead of by collector | `C_ReleaseStoicTag` was about to be published as a **STOA charge it never makes** — both StoicTag ops price off the same helper, but one pays in STOA and the other in IGNIS |
| Row key `(talos_fn, core_fn)` **collides across modules** (a dozen modules have `C_Issue`) | a measurement claiming "23 rows resolved" was **fiction**; the true number was 8 |

**Two fixes were tried and rejected**, both caught by the "an already-priced row must not change
value" invariant: raising the walk depth globally (it crosses into **sibling** operations —
one op absorbed another's deterrent and its floor went 557 → 1150) and following same-module `C_*`
transitively (*"one hop captures a delegation alias; more hops capture the neighbourhood"*).

---

# 3. Candidate findings that were rejected

An audit paper is strengthened by showing which candidates did not survive. All of these were
measured correctly and concluded wrongly. The first four are the paper's best evidence that the
round's verification step works.

| # | candidate | why it was rejected |
|---|---|---|
| **RJ-01** | **"Six Stage-Z UI readers are uncallable on any chain"** — `keys` on another module's table aborts with `Module admin necessary for operation`. Filed as a runtime-fatal defect class with a fix proposal touching four sovereign modules and ten call sites. | Pact admin-gates cross-module scans **only in transactional mode**, and **a REPL is always transactional**. Nodes run `--allowReadsInLocal`; `/local` is how a UI reader is invoked. Owner ruling: *"keys can be called freely."* Also, **all six readers have zero callers in Pact code — one grep would have ended it on pass one.** Cost recorded: *"several passes, a conformance rule filed at the wrong severity, and a fix proposal put in front of the owner that would have added code for no reason."* Downgraded to a watch list with a `cross-module-scan-called` gate: if one ever acquires a `C_`/`A_` caller it becomes a real defect **at that moment**. Residue that *was* real: R-02 and R-01. |
| **RJ-02** | **"`LIQUID::UEV_IzLiquidStakingLive` reports LIVE when liquid staking is not live"** | What was measured was one transaction inside the **boot sequence**, between the tx that sets the two STOA ids and the tx that creates the ATS pair. Pairs are never deleted, so mainnet is past that window and cannot re-enter it. **Residue that was real and recorded at its true size:** `UR_RewardToken` returns a **one-element `[BAR]`** for "no pair", so a length-1 test cannot distinguish "exactly one pair" from "none" and all three deep guards pass vacuously in the boot window; the codebase already contains the fix as a precedent. **The "unpinnable" half of the claim was also wrong**, and that is the part that paid: `env-module-admin` + `rollback-tx` pinned all three. |
| **RJ-03** | **"The strongest pricing assertions in the repo are in no gate"** — the `INFO_` preview-vs-charge blocks live in `REPL/modules/*.repl`, which neither `Z.repl` nor `ZALL.repl` loads. | **False.** `_gate.py` is the gate, and its `GATE` list (line 95) is `[…] + sorted(glob.glob("modules/*.repl")) + KURSAN + SCRATCH_PROOFS`. Every one of those files runs on every gate. The `.repl` **entrypoints** do not load them, which is true and is why the claim is plausible — but the entrypoints are not the gate. |
| **RJ-04** | **"A green `Z.repl` on a pricing change executes none of the assertions written to protect it"** — the headline verification rule in `IGNIS-PRICING.md` §8. | **Materially overstated.** `Z.repl` → `Stage02_Tester.repl:60` loads `Stage_02/[6.1.9]_PRICE-SWEEP.repl` (64 assertions, the suite built specifically for defect B-01), and `Stage_02/[6.2]_AQP.repl:27` loads `[6.2.16]_AQP-PRICE-SWEEP.repl` (42 assertions). `Z.repl` runs **~106 price assertions**. What it actually skips is `[6.1]_Cumulator.repl`'s **75** — the central map asserts and the DPTF/ATS module sweeps. *The rule ("gate on ZALL") is still right; the justification as written is false and would mislead an auditor about what a green `Z.repl` proves.* |
| **RJ-05** | **"92 (or 153, or 244) `enumerate` index defects"** | The sweep's conclusion is a **convention, not a defect list**: *the client checks non-empty; the internal predicates assume it*. Most sites are shielded by it. Explicit standing instruction in the notes: **do not report the site inventory as a defect count.** The honest method is stated too: *call a list-taking internal predicate with `[]`, then its client with `[]`, and compare — the **pair** is the finding.* |
| **RJ-06** | **"`TFT::C_MultiTransfer` is a funds-path defect on an empty list"** | **Executing it says otherwise** — the client refuses cleanly. Funds are not at risk; the defect is the **asymmetry** with the preview (P-15). *"Only the 3-argument `expect-failure` caught this. The 2-arg form would have gone green on the client's deliberate refusal and I would have published 'the funds path crashes.'"* |
| **RJ-07** | **"`C_Slumber` writes the wrong metadata shape"** — the first diagnosis of S-02. | Wrong, and **acting on it would have broken the hibernation path**: `XIv_MergeNonces` branches correctly on its `vzh-tag`, and the four callers are deliberate. The real fault was one level up — neither cap checked the token kind. Caught by *applying* the proposed guard and watching the suite fail to load. *A fix that breaks the suite is information, not a setback.* |
| **RJ-08** | **"`ATS\|GOV` is a forgeable skeleton key"** — `(defcap ATS|GOV () true)` wired as a governor guard, so any caller could acquire it and drain the vault. | **Wrong.** Pact requires the **calling module's admin** before `with-capability` can acquire a capability defined in a **different** module. Verified in an isolated two-module REPL. Aggravating factor: *"a subagent lens whose empirical reproduction was flawed"* supported the wrong model. **The real, much narrower bug it was standing in front of** is that two *public functions inside ATS itself* compose `ATS|GOV` with no preceding ownership check — visible only by enumerating home-module call sites rather than judging the capability body. |
| **RJ-09** | **"Reentrancy window in `XI_Swap`"** | Guard and `enforce` evaluation runs **read-only, unconditionally, at VM level**, and the violation is **not `try`-catchable**. The owner's conclusion (no exploit) was right; the owner's *reasoning* ("callbacks are impossible in Pact") was **also wrong** and was pushed back on — `create-user-guard` + `enforce-guard` is a real callback, reachable in this codebase, executing caller-chosen code synchronously mid-transaction. *Callbacks are safe because they are read-only-sandboxed, not because they do not exist* — a distinction that matters if a future path ever invokes caller-supplied code through another channel. |
| **RJ-10** | **"`C-without-cumulator` (38 sites) means unbilled operations"** | There are **six** legitimate billing shapes, not the one CLAUDE.md describes: core-returns-cumulator, Talos-builds-cumulator, STOA-priced, billed-in-core, defpact-step, and nested-Talos — plus the collectors themselves, which cannot collect from themselves. All 38 traced. Reported as observations. |
| **RJ-11** | **"`self-C-call-citizen` (64 sites) violates the no-self-`C_` rule"** | The direction is inverted. The sovereign rule protects the **cumulator**; these citizen `C_`s return a *string* from a Talos wrapper that has already collected. Bounded to 3 families in 2 files. The one thing that still needed checking — two rungs split a 70-element mint across two `C_Spawn` calls, i.e. two collects instead of one — was settled by execution: the price has **no fixed per-call component**, so 30+40 costs exactly what 70 costs. `<<NSFR-G2>>` also pins the one non-linear branch as out of reach. |
| **RJ-12** | **"`TS01-C4::PYTHIA\|C_Link` is unbilled"** | Deliberate — but *"deliberate" is not "safe"*. What makes it safe is an **economic bound living in a different function**: linking needs two deployed Apollo halves at 500 native STOA each, and counterparts are **never cleared** (revoke only deactivates). One-shot per pair, forever. That bound was untested until `<<PYTHIA-LINK-ECON>>`. **If it ever weakens, this stops being an observation.** |
| **RJ-13** | **"Negative SCORE user base is legitimate" / "clamp the accumulator"** | Both wrong. The first reading dismissed a real defect; the second **broke a live vacate** that relied on a `−1 → 0` netting. The real root was a `-1.0` "unscored" sentinel read through the **RAW** reader instead of the cooked one. Rule extracted: *"a floor that changes any green test's outcome is flooring a value the system relied on — stop and trace it"*; floor at the **source**, never on a running accumulator. |
| **RJ-14** | **"`AQP-VCT::CC_FullVacate` blows the scan budget"** — static reach says 10 heavy readers ≈ 400,000 gas. | The function **dispatches on `aqp-class` and one call takes one branch**. Executed on a real pool it cost **43,187 gas** — about one scan. **A static upper bound can overstate by 10×, and the cheap move is to run the thing.** Converted into a standing guard requiring vacate to stay under 100,000 gas **and above 1,000**, so a no-op regression cannot pass trivially. |
| **RJ-15** | **"`keys` gas scales linearly with row count"** | Measured **flat at 40,009 gas** across 10/100/400/1000 rows. The distinction matters: the linear story makes cross-module scans a future problem; the flat one makes them a **present, fixed-size, three-per-transaction budget**. |
| **RJ-16** | **"Three of the twelve mute guards"** — i.e. the class was over-counted. | The original list conflated *"carries an `;;UNREACHABLE` annotation"* with *"is mute"*. Six sites across three modules are correctly annotated and **not** this class. *A mute guard's message is displaced by an abort that happens first — a defect. An unreachable guard never receives a failing input at all — defence in depth.* |
| **RJ-17** | **Three misreadings that were corrected before shipping** | *"`DEMIPAD-G2`'s mute guard is caused by `UR_CheckRegistration`"* — it blamed the **one reader that was already safe**. *"`URC_StakeOrtoFungiblePoolClassOk` refuses a class-1 true-fungible pool"* — it does not; **three** classes bear an OF lane. *"`URCi_TrueFungibleStakeFlow` prices direction true and false differently"* — equal prices are the **correct** answer, because the flag feeds a transfer classification that is symmetric for this pair; the assertion now pins the equality *and* the classification, because the equality alone would not distinguish "correct" from "flag dropped". |
| **RJ-18** | **`INFO_SWP\|AddLiquidity`, `AddIcedLiquidity`, `AddGlacialLiquidity` reported as missing-leg defects** | The first was a real documentation gap (P-12) but **not** a missing leg; the other two were **correct**, and were reported only because the first one's asymmetry-tax subtraction was reused by pattern. The CLAD collection flags differ per variant. *A correction applied by pattern rather than by reading turns a correct preview into a reported defect.* |
| **RJ-19** | **Two tool-generated false positives worth naming** | *"`FVT\|C>UNSTALE-ALL` is an untested AUTHORITY claim"* — **a defcap is never named by a test**; it is reached through its acquirer. *"`ATS\|C_VestedCoil`'s `@doc` authority claim is wrong"* — imprecise, not wrong: "Owner" means **holder**. |

---

# 4. Out of scope: the prior per-module audit rounds

A separate, earlier corpus: six agent-driven code-reading audits (AQP 2026-08-11, ATS and SWP
2026-08-16, DPDC 2026-08-19, DALOS 2026-08-23, DEMIPAD) with owner verdicts and a
`ROUND-02-FIXES.md` per module. The DPDC round alone records **56 findings** (8 critical, 14 high,
16 medium, 18 low). **These are not this round's discoveries** and are not counted in §6.

What the REPL round contributed to them is worth stating precisely. **15 distinct SWP findings now
carry live regression assertions** in `Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl`
(#C1, #C2, #C3, #C7, #C8, #C9, #H6, #H11, #11C, #13C, #19H, #20H, #24H, #26M) plus ATS #3C in
`[6.6]_ATS.repl` — where before, per the SWP round's own baseline note, *"none of the CRITICAL/HIGH
findings are covered by an existing assertion."* Several are worth the paper's attention as
examples of what the REPL round now protects:

- **`UC_ComputeY`'s Newton solver seeded onto the non-physical negative root**, and its inverse
  twin dividing by zero at `output == xo` and then **silently returning a plausible but meaningless
  number** past that point (asking for 5× a pool's reserve returned ~5× as the "input needed").
- **`URC_BestEdge` selecting the `argmin` among parallel pools**, executed verbatim as real
  transfers rather than as a quote.
- **Pact's `^` computed via float64**, biasing all six swap-amount formulas toward the trader with
  a repeatable fee-free round-trip profit. Fixed exactly for whole-number exponents via
  `UC_IntPow`; **accepted as a bounded language limitation for fractional exponents**, with the
  residual ~1e-16 relative and an assertion written as a regression *bound*, not "must be zero".
- **`UEV_RemoveLiquidity` reading the same `can-add` flag as the add path**, so pausing deposits
  **permanently stranded every existing LP's principal** with no escape hatch. Resolved by an owner
  decision taken after checking Curve's `kill_me` and Balancer's Recovery Mode.
- **Defpact-issued pools never receiving a `SWP|LP` row**, breaking LP-stake admission forever —
  *"two issuance paths, one bookkeeping step, only one caller remembered it"*, fixed by folding the
  insert into `XE_Issue` so every path gets it for free.
- **`UEV_Issue` checking only that weights SUM to 1.0**, so a zero-weight token div-by-zeros every
  swap that touches it, permanently.
- **`SwapTracerV1` keying the routing graph by principal identity**, so removing or rotating a
  principal orphaned every entry filed under it, system-wide, with no resync.
- **`LIQUID::C_RegisterOuronetAccountForUrstoaHoldings` taking the `guard` as a caller-supplied
  argument with no ownership check** — account hijacking. Fixed by **removal**, after establishing
  that a UI-constructed transaction already did the job more safely.
- **Three real bugs inside `INFO-ONE+` preview functions** (a doubled-prefix typo crashing a
  function outright, a copy-paste wrong-token cumulator, and a duplicate variable name silently
  dropping a cost component). These survived because `INFO_*` functions have **zero on-chain
  callers by design** — the caller is the off-chain UI, invisible to any repo grep — so a review
  lens read them as dead code. *A wrong number here ships straight to the person about to sign.*

Two other pre-round workstreams contributed defects the REPL suite now pins and that are likewise
not counted: the SWP exhaustive-path-search project (`XI_RawLiquidPump`'s unguarded index on a
no-active-route search, worked around at discovery and actually fixed later, pinned at
`SWP|TX 032z5`), and the prior fixes for the `enumerate` idiom in `U_DEC::UC_AddHybridArray`
(#20H) and the DPSF set-definitions (#47L/#51L) — **which is the point of the sweep in §1.3: the
same fact had already been established and fixed twice, and cost a whole pass to re-derive.**

---

# 5. Internal inconsistencies in the record

Flagged because the paper cannot ship two incompatible claims. Each was resolved against the
current source or a fresh tool run.

### In the engineering record

1. **"Two STOA sites collect with a HARDCODED `trigger=false`."** There are **six** live ones —
   `02_DPDC.pact:1905`, `18_SWPLC.pact:1001`, `05_DPTF.pact:2854`, `06_DPOF.pact:2891`,
   `08_ATS.pact:2938`, `15_SWP.pact:2063` (plus one in dead DPMF). All six are branding upgrades,
   so the *conclusion* is right and the *inventory* is not; only two are pinned. See **P-13**.
2. **The mute-guard class has three incompatible tallies.** One handoff says *"12 sites, 1 of 12
   done, 11 remain"*; a later re-audit says *"12 → 10 real"* after reclassifying six annotated
   sites; the source now carries **sixteen** `FIXED 2026-09-12` repairs of this shape plus at least
   **eleven** still open. The tallies were taken at different dates over a moving list and were
   never reconciled. §1.2 is built from the source, not from any of the three.
3. **`_eagerlet.py` currently reports `NOT YET ANNOTATED: 0`, and the class is not closed.** The
   tool's condition is that the *validated argument* is also a *read key named in the guard*; it
   does not see a guard whose subject is a **let-bound** value (G-20, G-21) or one that lives in a
   defcap a member away (G-17, G-18, G-19). **That 0 must be read as "the argument-named variant is
   exhausted", not "the class is closed"** — which is T-03 in a new place, and the tool's own notes
   say as much (*of the seven hand-found instances only two have that exact shape*).
4. **`AQP-G31`'s block title says "FIXED"; its body says "pinned AS IT BEHAVES … a fix has to
   update these lines deliberately."** The source shows both RPS folds hoisted on 2026-09-12; the
   body prose is retained history that now reads as a live claim.
5. **The TS02-C1 bulk-transfer mute guard is listed as an "OPEN owner decision — reorders a paid
   client"** in the 2026-09-11 handoff, while `01_TS02-C1.pact:957/971` and `07_DPDC-T.pact:596/624`
   carry `FIXED 2026-09-12` with a full rationale. Superseded, not contradicted — but the earlier
   document was never amended.
6. **"Two `URC_` sites are deliberately left un-renamed"** (`ATS::URC_RTSplitAmounts`,
   `OUROBOROS::URC_Sublimate`), pending an owner ruling on the `v` role. Both are **`URCv_` in the
   source today**; the ruling landed (commit `5c5a2c7`) and the handoff text is stale.
7. **`11_EQUITY+.pact` cites a pin that does not exist.** The fix comment says *"Pinned by
   `REPL/modules/DPDC.repl <<DPDC-G20>>`"*; there is no `DPDC-G20` anywhere in the suite. The real
   pin is `REPL/modules/EQUITY.repl <<EQ-G1>>`.
8. **`INFO_ATS|WithdrawRoyalties` is simultaneously "open, unfixed" and "measured green."** Both
   are true — `<<ATS-I39>>` measures the accrued-royalty case; `<<TFT-MT2>>` pins the zero-royalty
   crash — but neither document says so, and read alone either one is misleading.
9. **`AQP-FVT|SweepRevokeAnchor` appears in one table as structurally unmeasurable with "no
   positive exec anywhere in the tree"** and, one section later, as measured at `<<SWP1-INFO>>`
   after a single-transaction runner was written for it. The earlier tables were not amended.
10. **Gate and coverage figures are quoted at many values for what reads as the same claim** —
    19,722 / 20,142 / 20,533 / 20,690 assertions; 366 / 380 / 384 / 391 / 396 / 397 measured
    previews; 24 vs 46 previews remaining. Most are honest progress snapshots, but **one (20,533)
    was read from a log the gate never wrote** (T-01), and the document self-corrects only much
    later. Any figure the paper quotes must carry its date and its source command.
11. **The Part II findings register in `AUDIT-BOOK.md` says of its six G1 defects: "none are fixed
    yet."** True on 2026-09-09. By 2026-09-14, #2 (VST merge), #3 (one-argument `format`),
    #9 (`XE_DeployAccountWNE`) and #12 (`UEV_ReservationState`) are fixed, #6 has been ruled KEPT,
    and #4 is **half** fixed — the LIQUID twin repaired, the DALOS twin (M-05) not. Never updated.
12. **"29 state-dependent `enforce` sites in unprotected readers/writers"** was reported as a medium
    finding; the current run reports **0 violations / 114 observations**, because the sites were
    resolved by the `UCv_`/`URCv_` naming ruling rather than by moving code. **The finding was
    closed by a definition change**, which the register does not say.

### In `IGNIS-PRICING.md`, the designated authoritative reference

13. **The folder inventory is wrong.** §1 says *"there are only three files in this folder"* and
    describes `IGNIS-PRICING.md` as containing "the decision log". There are **four**;
    `DECISION-LOG-DETAILED.md` (1,142 lines) is unlisted and is where almost every concrete pricing
    defect actually lives. `CLAUDE.md` repeats the error.
14. **The headline total does not sum, and "420" is wrong.** §6 gives `182 exact · 190 floor ·
    10 STOA-only · 48 exempt` over *"all 420 Talos client functions"*. Those four sum to **430**,
    and the generated sheet has **430 data rows**. Root cause in `_ignis_price_sheet.py:569`: the
    footer computes the total as `nsimple+ncomplex+nexempt` and **omits `nstoaonly`**. So the
    sentence *"every one of the 420 … carries a price"* silently excludes 10 ops that do.
15. **§6 is already stale against its own generated artefact.** The doc says 182/190; the sheet's
    regenerated footer says **181/191**. One row moved after the reference was frozen, and the
    "regenerate after any price change" instruction has no reciprocal re-sync step.
16. **Three different counts for `IG|COMPONENTS` inside one document** — §2 says ~394, §8 says 396,
    §7 narrates 297→393. The source has **396**.
17. **"Modules that charge nothing: BRD (beyond branding), CODEX (beyond StoicTag), DEMIPAD,
    DPDC"** is contradicted by §4's own table two rows above (DPSF/DPNF issue carry 200/250 STOA
    through a DPDC core), and by the sheet for CODEX and DEMIPAD.
18. **"`URCi_` is called for billing AND served to the UI, so the two cannot drift"** is not
    architecturally true, and the document's own decision log records the exception: SWPLC is
    *variant-B*, where the exec builds its cumulator inline and the reader is a parallel
    reconstruction. That escape hatch, plus an `INFO_` layer free to hard-code
    `OI|UDC_NoStoaCosts`, produced **six of the seventeen defects in §1.1a**. The invariant should
    read *"cannot drift where the exec calls the reader."*
19. **"What is open: nothing on pricing"** (§6) is falsified by the entire 2026-09-14 wave — 17
    preview/charge defects, including a revenue bug and eight previews quoting "free" — none of
    which is recorded anywhere in the pricing folder.
20. **The `Z.repl` justification in §8 is false as written** — see RJ-04.
21. **Two live defects in the generated artefacts** — GS-01/GS-02 (the sheet publishes a $1 floor
    for an op the chain charges >$10 for, under a function name no client can call) and GS-03 (the
    worksheet header publishes the pre-calibration formula). These are §1.1c, and they matter
    because these files are the declared input to the published documentation.

---

# 6. Counts

## By class

| class | entries | fixed | **fixed 2026-09-15** — see §1.1d | owner | accepted |
|---|---:|---:|---:|---:|---:|
| 1.1a Preview-versus-charge | 17 | 12 | 3 | 2 | 0 |
| 1.1b Mispriced / unbilled operations | 13 | 10 | 1 | 0 | 2 |
| 1.1c Generated pricing artefacts | 3 | 0 | 3 | 0 | 0 |
| 1.2 Guard reachability (mute / shadowed / dead) | 36 | 16 | 16 | 0 | 4 |
| 1.3 Arithmetic, lists, empty input | 10 | 8 | 2 | 0 | 0 |
| 1.4 State machine and permanent lock | 12 | 8 | 1 | 0 | 3 |
| 1.5 Authorisation and architecture | 5 | 3 | 0 | 1 | 1 |
| 1.6 Missing validation | 7 | 2 | 4 | 0 | 1 |
| 1.7 Client-facing diagnostics | 14 | 6 | 8 | 0 | 0 |
| 1.8 Gas, performance, portability | 6 | 2 | 3 | 0 | 1 |
| 1.9 Deployment, wiring, dead-on-arrival | 8 | 7 | 0 | 1 | 0 |
| **TOTAL** | **131** | **74** | **41** | **4** | **12** |

Several entries cover more than one function. The 17 preview/charge entries span the project's
running count of **19 preview/charge defects**; P-14 alone covers 22 cost readers; the
guard-reachability entries cover roughly 45 individual `enforce` sites; W-05 covers 11 dead call
sites; W-08 covers two sale modules. Not counted anywhere above: **22 defects in the pricing generator** (§2.5) and **~15
rejected candidates** (§3), both of which are methodological results rather than contract defects.

## Instruments, by yield

| instrument | entries attributed |
|---|---|
| Measured preview-vs-charge (quote read before the op, charge differenced across it) | 17 |
| Driving a guard to failure and **reading what it actually says** | ~30 |
| The `#76` pricing rehaul's call-site tracing (deter/components migration) | 13 |
| Static conformance and message-shape rules (`_conformance.py`) | 9 |
| Idiom sweeps (`enumerate 0 -1`, object `+`, multi-arg `or`/`and`) | 10 |
| Whole-program call-graph analysis (`_heavy.py`, `_shadowed.py`, `_foldeager.py`, `_audit_modref_calls.py`) | ~14 |
| Writing the **first test a function or module ever had** | 10 |
| Invoking every client entrypoint once and asserting on the outcome (G1) | 6 |
| Gas measurement against a real transaction budget | 5 |
| `@doc` claim verification (`_docclaims.py`) | 4 |
| Purpose-built static checks for a bug class just found (`_ladder.py`, `_infostoa.py`, `[table-never-created]`) | 3 |

## Current state of the gates (fresh runs, 2026-09-14)

```
_gate.py             GREEN — 20,690 assertions (16,861 pos / 3,829 neg), 76 entrypoints, ~333 s
                     GATE list = ZALL + AQP-FULL + 5 named runners + deb-staleness-* +
                                 modules/*.repl + KURSAN + 6 named scratch proofs
_enforce_coverage.py 777 matchable enforce sites, 753 pinned (96%); LIVE unpinned 0
                     (all 24 unpinned sit in the dead 00_DPMF module)
_conformance.py      VIOLATIONS 0 · OBSERVATIONS 114
_info_measured.py    412 declared previews · 397 MEASURED · named-but-unmeasured 0 · 15 structural
_infostoa.py         0 to review  (mutation-tested, so the 0 means something)
_ladder.py           clean — every mint ladder tiles its collection once, within the 70-position budget
_vacuous.py          4,158 positive assertions · VACUOUS 0 · WEAK 12 (all documented inside the tool)
_expectfail.py       1,147 expect-failure sites · 1,112 strong · 35 weak, all in UNGATED scratch files
_shadowed.py         0 hard-read candidates · 1 partial shadow (04_RPS.pact:3027)
_eagerlet.py         0 unannotated  (see §5 item 3 — read as "argument-named variant exhausted")
_foldeager.py        1 [read] site · 4 [index] sites, all open and pinned
_deadbind.py         150 dead let-bindings (0 heavy · 95 point reads · 55 pure compute)
_colproj.py          0 — no projecting read asks for a column its own table's schema lacks
```

Scale for context: Pact source (`1_SOVEREIGN` + `2_CITIZEN`) **113,666 lines / 93 files**; REPL
tests **103,379 lines / 259 files** — roughly 1:1. `REPL/TOOLS.md` indexes **43** analysis scripts.
