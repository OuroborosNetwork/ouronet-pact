# IGNIS re-pricing — owner feedback resolved + open items (2026-09-05)

**Context:** continuation of a stalled conversation (recovered via
`OuronetInformational/IGNIS-PRICING/PRICING-FEEDBACK-RECOVERED.md`) revising
`OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md` (#76). This note captures the durable design
decisions the owner settled during that back-and-forth, plus what's still open.

## Durable decisions (fold into future pricing work)

1. **IGNIS is hard-pegged: 1 ignis = 1 USD/EUR cent.** Owner: "ignis is basically a sort of
   stable coin." Not a floating/market-priced unit like STOA. All `$X` directives convert as
   `X·100` ignis.
2. **Pricing is component-based, not a single flat "smallest unit."** The atomic gas unit is
   `IG|TX = 1`. A function's cost = `deter·IG|TX(1) + components` where components count
   inserts/writes (×3), updates (×1), reads (×1), scans (×1), xcalls (×1) — the existing
   worksheet formula. **The deterrence multiplier applies ONLY to the IG|TX(1) base unit, not
   to the whole computed sum** — owner explicitly corrected this ("I thought we only applied it
   to the tx unit"). Confirmed the worksheet already implements this correctly.
3a. **The whole collection machinery is exempt** (owner 2026-09-05): `C_Collect` (the IGNIS
   collector) AND the native-STOA collectors `STOA|C_Collect`, `STOA|C_CollectWT`,
   `STOA|C_CollectWTEx`. Verified in source — none of the four builds an `OutputCumulator`, so
   they were ALREADY gasless in code; the sheets had merely mis-defaulted the three STOA ones to
   the 1x usage tier. Rule in the classifier now matches `^(?:STOA\|)?C_Collect` in 02_IGNIS.pact.
   Principle: the thing that does the billing is never itself billed.
3. **All genuinely admin/GOV-gated `A_`/`AA_`/`Ap_` functions are IGNIS+STOA exempt.** Run by
   the Ouronet Admin to set up sovereign settings — never billed. Applied across 47 worksheet
   rows (verified via source that DALOS/SWP/PYTHIA/STOAICO's `A_` functions all genuinely
   compose a `GOV|*_ADMIN` capability before doing anything else — no false positives found
   there). `C_TransferDalosFuel` (basically a `coin.transfer`) is exempt too.
4. **Issuance is the anti-spam gate and must be priced meaningfully above setup/usage** (owner:
   "issuance must be more than 50x... must have a strong price"). Concrete $ tiers settled:
   - True fungible issuance (`05_DPTF.pact C_Issue`): $10 / 1000 ignis
   - Ortofungible issuance (`06_DPOF.pact C_Issue`): $10 / 1000 ignis
   - Semifungible issuance (`04_DPDC-I.pact C_IssueDigitalCollection`, `son:bool`=true): $20 / 2000 ignis
   - Nonfungible issuance (same fn, `son:bool`=false): $25 / 2500 ignis
   - Autostake pair issuance (`08_ATS.pact C_Issue`): $40 / 4000 ignis
   - Swap pair issuance (`16_SWPI.pact C_Issue` + `20_MTX-SWP.pact C_Issue{Stable,Standard,Weighted}Pool`): $50 / 5000 ignis
   - Shareholder collection (`11_EQUITY+.pact C_IssueShareholderCollection`): $100 / 10000 ignis
   - DSA delegation vault (`08_DSA.pact A_DefineDelegationVault`, pending rename — see below): $50 / 5000 ignis
   - DSA agency admission (`08_DSA.pact C_AdmitAgency`): $20 / 2000 ignis
   - Anchors (`01_ANK.pact C_Issue*Anchor` family) = **half price** of issuing their respective
     asset type (true-fungible-anchor 500ig, semifungible-anchor 1000ig, nonfungible-anchor
     1250ig). `C_IssueNonFungibleSetAnchor` assumed same tier as NonFungibleAnchor — flagged
     for owner confirm, no explicit directive given for "Sets."
   - VST link creation (`11_VST.pact C_Create{Frozen,Hibernating,Reservation,Sleeping,Vesting}Link`)
     ties to ortofungible issuance cost (1000ig) — these mint derivative ortofungible-backed
     instruments.
5. **Nonce-dependent scaling for wiping.** Ortofungible wipe (`06_DPOF.pact` `C_WipeClean` /
   `C_WipeHeavy` / `C_WipePure` / `C_WipeSlim`) costs an additional **5 ignis per nonce wiped**
   on top of the base deter tier. NOT yet applied to the analogous collectible wipe family in
   `06_DPDC-MNG.pact` (`C_WipeClean/Dirty/Heavy/Pure/Slim`) — flagged in the worksheet for
   owner confirmation since they didn't explicitly name it.
6. **Variable-scale ops keep a cheap base + scale with the runtime path, not a flat number.**
   Confirmed direction (no numeric change, just annotated in the worksheet) for: TFT
   `C_MultiTransfer`/`C_MultiBulkTransfer` (scales with receiver-list size), `C_SmartSwap`/
   `CC_SmartSwap` (scales with hop-count + special-target count), DPDC-T `C_Transfer`/
   `C_BulkTransfer` (scales with nonce-count moved; plus an ignis royalty to the collection
   creator stacks on top).
7. **Fragmentation family reclassified**: `C_EnableNonceFragmentation` is the real ISSUE gate
   (100x deterrent base + $1/100ig per nonce defined as fragmented) — NOT `C_MakeFragments`/
   `C_MergeFragments`, which are plain USAGE (1x, no deterrent). Previously the worksheet had
   this backwards.
8. **Heavy-lifting functions should be priced by the heaviness of the heavy op reached**, not a
   flat category price — general principle, not a specific formula yet (ties into the
   transitive-heavy-scan naming convention already in `StoicSyntax-Prefixes.md`).

## DSA module mistagging — confirmed, action pending

Owner suspected DSA's `A_*` functions were mistagged (should be `C_*`, since vault/agency
creation is a normal client action, not an Ouronet-Admin action). **Confirmed true by reading
source** (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact`): the defcaps behind
`A_DefineDelegationVault`, `A_SetOracleAuth`, `A_OracleWrite`, `A_WithdrawRoyalty`,
`A_BurnRoyalty`, `A_FuelRoyalty`, `A_SetAgencyFee` all call
`(ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)` — owner-gated, not GOV-gated. Only
`A_ToggleExternalOracle` and `A_SetOracleValidity` are genuinely `@doc "DSA MODULE ADMIN (GOV)"`.

`C_AdmitAgency` is already correctly `C_`-prefixed (answers owner's "is that the
C_AdmitAgency function?" — yes).

**This is a real rename, not just a worksheet edit — NOT yet executed, needs its own pass:**
blast radius confirmed via grep: `1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact` (Talos wiring),
`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact` (cost-preview reconstruction — must mirror
byte-for-byte per the AQP-INFO discipline), `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact`
(references `A_SetAgencyFee`), plus 4 REPL test files (`REPL/Kursan/dsa-*.repl`). Needs owner
go-ahead before touching source, since it also means re-wiring these into Talos as billed `C_`
paths (IGNIS collection) rather than however they're currently invoked as `A_`.

## Other loose ends resolved (no action needed)

- **`A_DeployBridgeSmartAccount`** (owner: "I'm not familiar with this, where's it from?") is
  real — lives in `2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact`, the Caduceus bridge module,
  which is **work-in-progress and not being deployed yet**. Sequencing per owner: Arweave
  integration on the Ouronet UI first, then Caduceus + Aletheia. No fix needed, just out of
  current scope.
- **Account-deploy count**: owner insisted there should be exactly 2 admin + 2 user Ouronet
  account-deploy functions, not 7. Confirmed: DALOS has exactly `A_DeploySmartAccount`,
  `A_DeployStandardAccount` (admin/free) + `C_DeploySmartAccount`, `C_DeployStandardAccount`
  (user/STOA-priced) = 4. The per-fungible-type `C_DeployAccount` in DPTF/DPOF/DPMF is a
  structurally different concept (explicit token-account creation, already correctly
  50x-deterred per the S1 constraint) and isn't part of that count — likely source of the "7"
  confusion.

## Second feedback batch (2026-09-05, same day) — decisions

1. **Per-field cost granularity: DECIDED — Option A** (per-table size classes, static).
   Every `deftable` gets a size class computed once from its `defschema`: sum field weights
   (bool/integer/decimal/time = 1, string/guard = 2, object/list = 4), bucket:
   S ≤5 pts → ×1 write / ×1 read; M 6–12 → ×2/×1; L 13–24 → ×3/×2; XL 25+ → ×5/×3.
   Cost formula: **insert/write = 3 × bucket · read = 1 × bucket · update = 1 ignis per 2
   fields in the update literal (min 1) · xcall = 2 (Talos hops excluded) · deter applies to
   the IG|TX(1) base only**. Bucket multipliers live as IGNIS defconsts (`IG|W-S` … `IG|W-XL`)
   and get sanity-checked against `env-gas` measurements at calibration (substage 7) — if
   reality says XL is ×8 not ×5, tune the defconst, not the model. The classifier computes
   buckets automatically from schemas — no per-op manual work.
2. **Talos-hop exclusion + hop price: DECIDED.** Talos-originated hops are excluded from the
   xcall count; every remaining genuine inter-module hop is priced at **2 ignis** (was 1).
   `REPL/_ignis_cost_classify.py` must be upgraded to (a) skip the Talos→core entry hop,
   (b) weight xcalls ×2, (c) match qualified op names (`STOA-PID|C_*`, `C_2|*` — the regex gap
   that silently dropped 5 SWPLC ops from the worksheet). ALL worksheet X/components/FINAL
   numbers are stale until the recompute.
3. **Deterrence constants: DECIDED — centralized in the IGNIS module** (`02_IGNIS.pact`) **as
   `defconst`s**. Owner's rationale: a single place to manage them all, instead of scattered
   constants nobody can find. (Supersedes both the earlier "Talos @doc tags" idea and the
   "each target module holds its own" idea; the registration-table alternative was presented
   and rejected in favor of defconst simplicity.) Accepted consequence: adding a new op later
   means an IGNIS module upgrade to add its constant. IGNIS is Stage-1, holding names for
   Stage-2 ops is fine — defconsts are just named integers, no forward references.
4. **DPDC-MNG collectible wipe: DECIDED — mirrors DPOF**, 5 ignis per nonce wiped.
5. **`C_IssueNonFungibleSetAnchor`: DECIDED — leave as is** (same tier as NonFungibleAnchor,
   no separate Set tier).
6. **Wipe parallelization: CONFIRMED prerequisite.** Model = the VCT vacate/drain hydra
   recipes (`06_VCT.pact` — `URH_*` preflight plan → `Cp_`/`CCp_` order-independent slices →
   finalize). Use-case the owner described: a wipe target with too many nonces for one tx —
   the UI scans the user, constructs the parallel slice transactions, and fires them at the
   blockchain all at once. Applies to both DPOF and DPDC-MNG wipe families.

## Staging — the IGNIS Cost Rehaul substage plan (owner: "has gotten suddenly more complicated")

Owner's framing: "this step with ignis repricing becomes one huge stage on its own which needs
to be properly planned, substaged." Proposed substages (order matters — deps flow downward):

1. **Wipe parallelization** (prerequisite, owner-confirmed): hydra wipe recipes for DPOF +
   DPDC-MNG modeled on the VCT vacate know-how (`URH_*` preflight → `Cp_`/`CCp_` slices →
   finalize). UI-driven: scan → construct slice txs → fire in parallel.
   **→ DONE 2026-09-05** (owner said "lets start substage 1"; built same session). Design +
   status: `OuronetInformational/IGNIS-PRICING/HYDRA-WIPE-DESIGN.md`. Key learnings captured there: wipes
   need NO begin/finalize bracket (freeze precondition + native replay-revert replace VCT's
   whole state machine); true `Cp_` achieved (VCT's slices are `CCp_`); VCT's partition math
   can emit an empty tail slice — recompute `n-final = ceil(l/per-slice)` after clamping.
   Also fixed in-pass: DPOF `XI_DebitNonces` dead `UR_NonceHolder` read; `nonces-excluded`
   hot-row batched to one `+= K` per debit call (`XI_IncrementNoncesExcludedBy` replaces
   `XI_IncrementNoncesExcluded`, which had exactly one caller).
   **Latent bug found by the hydra terminal test** (fixed): DPDC-MNG
   `URC_FilterAccountViableNonces` exploded on an EMPTY nonce list — Pact's
   `(enumerate 0 -1)` DESCENDS (yields `[0 -1]`), so the fold's `(at idx nonces)` hit
   index 0 of an empty list. Never triggered before because nothing ever re-read a
   fully-wiped account; the Hydra "re-plan from remains" flow does exactly that. Fixed
   with an empty-input short-circuit returning `(UDC_RemovableNonces [] [])`.
   RULE for future loops: never `(enumerate 0 (- (length xs) 1))` without guarding
   `xs` non-empty — enumerate descends when to < from.
2. **Classifier upgrade — DONE 2026-09-05.** The number-producing script was
   `REPL/_ignis_deter_worksheet.py` (not `_ignis_cost_classify.py`, which is only the KIND/role
   survey); it now implements the full decided model: Option-A buckets (auto-computed from
   every repo defschema → per-table write/read multipliers), per-update-call-site field
   counting (ceil(fields/2), min 1), xcall = 2, Talos-hop excluded by construction (3_Talos +
   TS02-CPAD wrappers out of scope — their cost IS the wrapped core op), qualified-name regex
   fixed (515 ops now vs 364 — the 5 SWPLC `STOA-PID|C_Add*` and other `X|C_*` ops included).
   **Crucially: the owner's whole 2026-09-05 pricing batch is now encoded IN-SCRIPT as the
   `OWNER_DECISIONS` dict** — the worksheet is fully regenerable (hand edits no longer live in
   the markdown) and that dict is the direct input for the substage-3 IGNIS defconst
   generation. Regenerate: `python3 REPL/_ignis_deter_worksheet.py > OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md`.
   Distribution after regen: 190 exempt · 70 @1x · 255 with deter>1 (tier table at worksheet foot).
3. **IGNIS module defconsts — DONE 2026-09-05 (constants live; call-site swap deferred to 5).**
   `02_IGNIS.pact` now holds two object-map defconsts in `{3.1}`: `IG|WEIGHTS` (tx=1, ins=3,
   upd-per-2f=1, xcall=2, w-s/m/l/xl=1/2/3/5, r-s/m/l/xl=1/1/2/3, wipe-nonce=5,
   frag-nonce=100) and `IG|DETER` (all owner tiers: usage/setup/auth/fee/small +
   issue-tf/of/sft/nft/ats-pair/swp-pair/shareholder/dsa-vault/dsa-agency, vst-link, lp-churn,
   anchor-tf/sf/nf, revoke-anchor/boost, combine-triplet, add/revoke-score, pool-stake-toggle,
   fvt-split-setup, fvt-link-toggle, unstale, frag-enable). Read via interface fns
   `UC_IgnisWeight` / `UC_IgnisDeter` (declared in `IgnisCollectorV2` {5.2}) — `(at key map)`
   fails fast on unknown keys, no silent default. Asserted in `[6.1]_Cumulator.repl`
   TX-IGC-001 (9 expects; note [6.1] is SKIPPED by the AQP-fast Z default — verify via a
   composite load of deploy-stage00 + deploy-stage01 + [6.1]). Object-map defconst pattern
   precedent: `GAS_EXCEPTION` list defconst in the same block.
   **Deliberately deferred to substage 5**: swapping AQP's module-local `GAS|` defconsts and
   all cumulator call sites to `ref-IGNIS::UC_IgnisDeter` reads — values change in 5 anyway,
   so each call site gets touched ONCE (rewire + reprice together), not twice.
   **Pre-existing breakage noted (not caused by this work)**: `pact Stage01_Tester.repl`
   standalone fails at `[0.0]_Starter.repl` ("Namespace not found: ouronet-ns") —
   `deploy-stage01.repl` says "Assumes Stage 00 already loaded" but `Stage01_Tester.repl`
   never loads it; CLAUDE.md still advertises the standalone entry point. Fix or re-doc later.
4. **DSA rename — DONE 2026-09-05.** All 7 mistagged fns renamed `A_`→`C_` in `08_DSA.pact`
   (`C_DefineDelegationVault`, `C_SetOracleAuth`, `C_OracleWrite`, `C_WithdrawRoyalty`,
   `C_BurnRoyalty`, `C_FuelRoyalty`, `C_SetAgencyFee`); Talos wrappers `AQP-DSA|A_*`→`AQP-DSA|C_*`
   in `04_TS02-C3.pact`; references rewired in `09_AQP-INFO.pact`, `04_RPS.pact` (doc), and the
   4 `REPL/Kursan/dsa-*.repl` suites. Only `A_ToggleExternalOracle` + `A_SetOracleValidity`
   remain `A_` (genuinely GOV). Worksheet generator: `DSA_MISTAGGED` machinery deleted, OWNER
   key → `C_DefineDelegationVault`; worksheet + MODULE-INDEX regenerated. Verified: ZALL fully
   green; Kursan dsa-fee (104 expects) + dsa-capture (151 expects) fully green — together they
   exercise all 7 renamed fns. NOTE pre-existing (unrelated, untouched by this work): Kursan
   dsa-grand-tour dies loading `Stage_02/[5.4]_PopulateBunnies.repl` ("Module KBN has no such
   member: A_Step01" — stale-module drift in that load chain) and dsa-agency-tests dies on a
   "None of the guards passed" in its Coding-Division collection-issuance tx — both failures
   are OUTSIDE any DSA call site and predate the rename; fix that drift separately.
5. **Apply pricing to source — Phase A DONE, Phase B MOSTLY DONE (2026-09-05).**
   *Phase A (AQP family):* all 43 module-local `GAS|` defconsts in SCORE/AQP/RPS/FVT/DSA now
   resolve from IGNIS `IG|DETER` at load (`(defconst GAS|X (… UC_IgnisDeter "key"))`) — zero
   call-site churn, owner repricing flows in automatically. `C_CombineTripletScoreModel` split
   off the shared `URCi_IssueScoreModel` onto its own `URCi_CombineTripletModel` (100), exec +
   INFO repointed together. NO numeric pricing constant remains anywhere in AQP.
   *Phase B (non-AQP), all exec+INFO in lockstep via the shared URCi readers:*
   - `URCi_IssueGas` repointed per module: DPTF→issue-tf (1000), DPOF→issue-of (1000),
     ATS→issue-ats-pair (4000). (Was one shared DALOS UsagePrice `ignis|token-issue`=500.)
     VST link creation inherits DPTF/DPOF IssueGas automatically → 1000, as owner directed.
   - `DPDC-I::URCi_IssueCollectionPrice` → son ? issue-sft (2000) : issue-nft (2500)
     (was token-issue×5/×10 = 2500/5000).
   - SWP pair $50: `ignis|swp-issue` (was 4000) → issue-swp-pair (5000) at all 3 code sites
     (SWPI ×2, MTX-SWP ×1) + the ground-truth REPL reconstruction in `[6.2+3]`.
   - EQUITY+ `C_IssueShareholderCollection`: new $100 premium leg (issue-shareholder) added as
     leg 2 in BOTH exec and `URCi_IssueShareholderCollection` (same position → chains stay
     byte-identical).
   - Wipe +5 ignis/nonce: DPOF `URCi_WipeCumulator` and DPDC-MNG `URCi_WipeCumulator` now read
     `UC_IgnisWeight "wipe-nonce"` (DPOF was ignis|small, DPDC was ignis|small "2 IGNIS/nonce").
     Feeds C_Wipe* AND the new Cp_WipeSlice automatically.
   - `C_EnableNonceFragmentation` → frag-enable (100 = $1/nonce; one nonce per call). Make/Merge
     Fragments needed NO code change (already usage-tier cumulators; reclassification was role-only).
   - Anchors: `URCi_IssueAnchor` parameterized with the tier key (was flat 1000) — 4 exec sites +
     4 INFO previews keyed: anchor-tf 500 / anchor-sf 1000 / anchor-nf 1250 (Set shares NF).
     `URCi_RevokeAnchor`→100, `URCi_RevokeBoostClass`→500 (were Biggest tier).
   - Token-account deploy → token-account (50). NOTE: `URCi_DeployAccount` is billed at the
     TALOS wrapper (TS01-C1), not inside core `C_DeployAccount` (which returns no cumulator) —
     so auto-creation inside a transfer never reaches it and stays FREE per the S1 constraint.
   - LP churn (1000): `C_RemoveLiquidity` ALREADY had a hardcoded `flat-ignis-lq-rm-fee 1000.0`
     in exec + a mirrored literal `1000.0` in its preview — both repointed to IG|DETER lp-churn.
     The 5 add-liquidity paths had NO churn fee: a lp-churn leg was prepended as leg 1 to all 5
     exec lists AND all 5 `URCi_Add*Liquidity` previews (same position → chains stay identical).
     NOTE: SWPLC is variant-B — exec builds its cumulator INLINE and the `URCi_` reader is a
     PARALLEL reconstruction, so both sides must always be edited together (unlike AQP/DPTF/DPOF
     where exec calls the shared reader). Watch this whenever SWPLC pricing changes.
   - Variable-scale ops need NO code change (verified): TFT `URCi_MultiTransferCumulator` folds
     over `id-lst`, DPDC-T `URCi_BulkTransferCumulator` folds over `receiver-lst`/`nonces-array`,
     SWPU `URCi_SmartSwap` prices a per-hop fold. They already scale per item by construction,
     which is exactly what the owner asked for.
   **Substage 5 COMPLETE — ZALL green after every increment.**
   *Learned:* a `"` inside a Pact `@doc` string-continuation terminates the string — write
   `central IG|DETER key issue-shareholder`, never `IG|DETER "issue-shareholder"`, in docs.
6. **Re-green + calibration — DONE 2026-09-05.** Built `REPL/Kursan/IGNIS-bucket-calibration.repl`:
   a self-contained probe module with four synthetic tables shaped like the repo's real S/M/L/XL
   classes (3 / 8 / 20 / 36 schema points, mirroring P|T, BRD|BrandingTable, DPTF|RoleTable,
   ATS|Ledger), measuring insert/read/update gas with `env-gas`. **Measured vs Option-A model:**
   - WRITE M/L/XL vs S = **1.72 / 3.28 / 5.36** vs model 2 / 3 / 5 → model GOOD, kept.
   - READ  M/L/XL vs S = **2.40 / 5.40 / 9.40** vs model 1 / 2 / 3 → model FAR TOO FLAT.
     **RETUNED to 1 / 2 / 5 / 9** in BOTH `IG|WEIGHTS` (02_IGNIS.pact) and the classifier's
     `_bucket()` (worksheet regenerated). Lesson: reading a big row costs nearly as much as
     writing it — row size dominates reads far more than the initial guess assumed.
   - write/read at S = 3.9x measured vs the model's 3x (insert=3xbucket, read=1xbucket) → good.
   - UPDATE 5-field vs 1-field = **2.08** measured vs model `ceil(fields/2)` ⇒ 3.0 → model is
     TOO STEEP (real updates have a high base + small marginal per field; measured 37 vs 77 gas).
     **RETUNED with owner approval ("use the findings to update the ignis pricing"):** divisor
     2 -> 4, i.e. `ceil(fields/4)` (1 field=1, 5 fields=2 => ratio 2.0 vs measured 2.08).
     Applied in BOTH `IG|WEIGHTS` (key renamed `upd-per-2f` -> `upd-per-4f`, no other consumer)
     and the classifier (`IG_UPD_FLDDIV`); worksheet regenerated.
     Net calibration outcome: writes unchanged (model was right), reads 1/1/2/3 -> 1/2/5/9,
     updates ceil(/2) -> ceil(/4). Only the WRITE half of the original Option-A guess survived
     contact with measurement.
   Caveat for future calibration: these are REPL `table` gasmodel numbers on string-heavy
   synthetic rows; absolute values will differ on chain, but the RATIOS are the calibration target.

This pass only updated the worksheet (documentation/proposal, `IGNIS-DETER-WORKSHEET.md`) —
no `.pact` source or REPL changes were made except this memory note. The worksheet header
still says "I green-light nothing myself" — nothing ships without owner green-light per substage.

## Related

- `OuronetInformational/IGNIS-PRICING/PRICING-FEEDBACK-RECOVERED.md` — verbatim owner feedback this note resolves.
- `OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md` — the worksheet updated in this pass (see its
  REVISION LOG section at the top, dated 2026-09-05).
- `OuronetInformational/IGNIS-PRICING/IGNIS-COST-ANALYSIS.md` — the earlier re-pricing proposal this worksheet
  refines.
- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING/memories/2026-08-27-ignis-cost-rethink.md` — the original directive that
  kicked off this whole rethink.

## Deliverables & follow-ups (2026-09-05, end of rehaul)

**Two generated sheets, one pricing brain.** `REPL/_ignis_deter_worksheet.py` was refactored so
its printing lives in `main()` (guarded by `__main__`), making it importable; the new
`REPL/_ignis_price_sheet.py` imports it and reuses `OWNER_DECISIONS` + `suggest_deter` + the
component model, so the two documents can never disagree.
  - `OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md` — every op WITH its modelled compute components.
  - `OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md` — owner ask: "the expected price of every simple
    function, and when you come to a function that is complex, just say so". Three sections:
    **FIXED** (258 ops — flat, quotable price in IGNIS + $), **COMPLEX** (67 — no single number,
    with the reason), **EXEMPT** (190 — always free). Regenerate with the command in its footer.
  - COMPLEX detection needs REAL per-item scaling evidence in the billing path (a cumulator
    multiplied by a count / summed fold), NOT merely a list-typed parameter — e.g.
    `C_IssueShareholderCollection` takes a 24-link list but charges a flat $100, while DPTF/DPOF/
    ATS `C_Issue` genuinely charge per token issued. The walk follows `URCi_/XB_/XI_/XE_` two
    levels deep because the per-item price often sits one hop down (DPTF `C_Issue` ->
    `XB_IssueFree` -> `URCi_IssueGas (* (dec token-count) tier)`).
  - Gotcha fixed while building it: a naive defun extractor that starts paren-balancing at the
    PARAMETER list only captures the signature. Balance from the defun's own paren, and skip
    string literals so parens inside `@doc` text cannot desync the count.

**WIPE-SLICE-MAX-NONCES calibrated** (`REPL/Kursan/DPOF-scale-wipe.repl`, the probe the DPOF
`@doc` already promised). Measured through the real `DPOF|Cp_WipeSlice` Talos path at widths
10/20/30: gas 13,453 / 17,491 / 21,566 => **marginal 405.6 gas per nonce wiped**, fixed per-tx
overhead 9,396. A 2,000,000-gas tx therefore fits ~**4,907** nonces — the current constant of
120 is ~40x too conservative (wipes are far cheaper per item than VCT vacate legs at ~4,000
gas/position).

**DPDC side measured too** (`REPL/Kursan/DPDC-scale-wipe.repl`, widths 8/16 through
`DPNF|Cp_WipeSlice`): gas 15,623 / 23,242 => **952.4 gas per NFT nonce**, fixed overhead 8,004,
so ~**2,091** nonces per 2,000,000-gas tx. So collectible wipes really are heavier per nonce
than ortofungible ones (2.3x) — the DPDC `@doc` prior was directionally right — but nowhere near
the ~167 it claimed; that prior most likely counted INDIVIDUAL wipe calls, which each pay the
~8k fixed overhead instead of amortizing it across a batched slice.

**Constants set on their own evidence** (each module measured separately, not one number
borrowed across families): DPOF `WIPE-SLICE-MAX-NONCES` 120 -> **1000**, DPDC-MNG 120 -> **500**.
Both deliberately ~4-5x under the measured ceiling because the probes used the LIGHTEST possible
nonces (`UDC_ZeroURI|Data` + `UDC_NoMetaData`); real nonces carry URI/metadata payload and cost
more per row. Risk is asymmetric and recoverable: too-high only means the UI's /local simulation
adds a slice (an oversized slice aborts atomically), while too-low charges users for needless
extra transactions. The seed-boundary asserts in `[6.1.6]_DPOF.repl` and
`[6.1.8]_DPDC-HYDRA-WIPE.repl` were re-anchored to the new ceilings (they hard-coded the 120
boundary at 121/241 nonces). Probe gotchas: the `COF-` fixture is issued in `[6.1.5]` and consumed
by `[6.1.6]`, so the probe must load the full Stage-02 chain and MINT a fresh nonce (DPOF mint
creates a NEW nonce rather than topping up an existing one); and Talos wipe wrappers return the
ELITE re-rank **bool**, not a cumulator (house pattern shared with the `C_WipePure` siblings).

## PRICE SHEET semantics — owner correction (2026-09-05, supersedes the v1 sheet)

**Deter is ADDITIVE, never the total.** When the owner says a function costs "$100" they mean
its DETER MULTIPLIER is 10000x — 10000 IGNIS of deterrence — and the normal IGNIS consumption
(the component cost: writes, updates, reads, scans, cross-module hops) is charged ON TOP:
`TOTAL = deter + components`. The v1 price sheet wrongly printed the deter alone as the price.
(The deter WORKSHEET always had this right — its `final` column is exactly deter + components.)

**"Simple/fixed" means fixed LOGIC, not a list-free signature.** A simple function is one whose
composition is fixed, so its cost is exactly knowable — flip a boolean, mint a true fungible,
transfer a DPTF. These are the BUILDING BLOCKS every other function is composed from, and they
are the rows worth quoting. **Complex** = composed of several simple ops in a VARYING
composition (list-driven loop, per-nonce/per-hop work, heavy scan); for those we print the FLOOR
— "COMPLEX — at least <deter+components>" — since no single total exists.

**Group by LOGICAL Talos entity, not physical file.** The `ENTITY|fn` prefix on each Talos
wrapper is the logical module: `SWP` covers ops physically spread across SWP / SWPI / SWPLC /
SWPU / MTX-SWP. Talos is the only supported client path, so the sheet now enumerates the TALOS
wrappers (what a client actually calls), resolving each to the core op it drives via
`ref-<MOD>::<C_fn>` and pricing that. 327 Talos client functions: 227 simple (exact) · 67
complex (floor) · 33 exempt.

Implementation notes for future regeneration:
  - Talos files declare each fn TWICE (interface decl + module impl) — dedupe by (entity, fn) or
    every row appears doubled.
  - `ref-IGNIS::C_Collect` inside a wrapper is billing plumbing, NOT a priced sub-op — exclude it
    when detecting composition.
  - A Talos wrapper prefixed `A_`/`AA_` is Ouronet-Admin-run and therefore EXEMPT even when the
    core op it drives is priced (e.g. `DPTF|A_DeployAccount` -> core `C_DeployAccount` 50x is
    free at the admin entrypoint). Classify from the TALOS prefix, not the core op's.
  - `×N` next to a core op = the wrapper drives N priced core ops in a FIXED composition, which
    is still exactly knowable (fixed multi-call != complex; only VARYING composition is).

## Rehaul v2 (spec-driven) — P1/P2 done, 2026-09-06

Context: the owner established that the earlier pass did NOT implement the new costs for most
functions (only ~70 call sites reach IG|DETER; the rest still bill legacy `UDC_*Cumulator`
tiers), and corrected the price semantics. Target = `IGNIS-PRICING-SPEC.md`; phases =
`IGNIS-PRICING-PLAN.md`.

**The cost architecture (decided):**
`IGNIS = deter(op) + components(op)` — deterrence AND the op's proper ignis computation.
`STOA  = dollars(deter) / stoa_price` — ISSUE functions only, so the DOLLAR value is constant
while the STOA amount floats with the oracle. All central in `02_IGNIS.pact`, keyed by the
TALOS client name `ENTITY|FN` so code and price sheet are one list:
`IG|DETER` (business numbers) · `IG|COMPONENTS` (297 generated work costs) · `IG|WEIGHTS`
(primitive weights) · helpers `UC_IgnisPrice` / `UC_IgnisPriceScaled` / `UC_IgnisComponents` /
`UC_StoaPrice`. New DALOS UsagePrice key `stoa|price` = 0.1 is the oracle placeholder.

**P2 — account-creation STOA switch:** `account-creation-stoa` flag on
`DALOS|GasManagementTable` (default OFF), `A_ToggleAccountCreationStoa` + its OWN defcap, Talos
wrapper `DALOS|A_AccountCreationStoaToggle`. Standard $5 -> 50 STOA, Smart $10 -> 100 STOA,
gated INSIDE the price readers so exec and INFO cannot drift.

**Gotchas that will recur across P3-P5 — read before bulk-editing modules:**
1. **Interface vs module placement.** A text anchor like `(defun X (args)` matches the INTERFACE
   declaration BEFORE the module implementation, so a naive `replace(...,1)` puts function
   BODIES inside the interface -> "Expected: [')']". Anchor relative to `s.index('\n(module NAME')`
   and pick anchors containing a body line (e.g. `(P|UEV_IMC)`). Bit 4 inserts in one pass.
2. **Schema change => fix every insert site.** Adding a field to a `defschema` breaks the genesis
   `insert` (Pact requires ALL fields). `with-default-read` keeps PRE-EXISTING rows readable, but
   inserts must be updated by hand (here: `[4.0]_Sovereign-Executor.repl`).
3. **Do not reuse a neighbouring defcap just because it looks similar.**
   `DALOS|C>TOGGLE-GAS-COLLECTION` validates the GLOBAL stoa state; reusing it for the new
   independent switch coupled it to the flag it must stay independent OF. Give a new toggle its
   own defcap validating its own field.
4. **Generated Pact maps need decimal literals.** A Python-int value against a `:decimal`
   signature fails the runtime typecheck — emit `26.0`, not `26`.
5. **Assert invariance, not assumed constants.** A test that hard-codes "global STOA is OFF"
   broke because the executor turns it ON; snapshotting the value and asserting it is UNCHANGED
   tests the actual property (independence) and is robust to pipeline state.

## P3 done (2026-09-06) — issue functions + dollar-pegged STOA

Every ISSUE op now charges `deter` in IGNIS and the SAME DOLLAR VALUE in STOA via
`UC_StoaPrice`: DPTF/DPOF 1000ig+100 STOA, ATS 4000+400, DPSF 2000+200, DPNF 2500+250, SWP pair
5000+500 (both the single-tx and defpact paths), `DPSF|C_IssueCompany` 10000+1000 (an equity
PREMIUM leg — the underlying SFT collection issue is charged on top, in both currencies, same
composition rule as VST links), VST links 250 deter + the token they issue. PYTHIA keeps its
500/100 STOA and NO ignis.

**New mechanism — non-discountable STOA.** The spec marks a few costs as taxed in FULL. The
Elite discount lives in `DALOS::URC_SplitSTOAPrices`, so full-taxing needed a real path, not a
constant: added `DALOS::URC_SplitSTOAPricesFull` (same 10/20/30/40 split, no discount) +
`IGNIS::STOA|C_CollectFull`, and pointed PYTHIA's deploy/rename at it. Reuse this for the
asymmetric-liquidity legs the spec also marks non-discountable.

**Raising STOA ~500x breaks the TEST HARNESS in three distinct ways — expect all three in P5:**
1. *Caps computed from legacy per-asset keys* (124 sites / 30 REPL files). Fixed at the SOURCE:
   the sovereign executor now SETS `"dptf"/"dpmf"/"dpsf"/"dpnf"/"ats"/"swp"` from
   `UC_StoaPrice`, so every cap tracks the real charge automatically and there is still one
   source of truth. 6 lines instead of 124 edits.
2. *A brand-new charge has NO cap at all* — equity previously collected zero STOA, so both its
   call sites (`Stage_02/[4.0]_Sovereign-Executor.repl`, `Stage_02/[6.1.1]_EQUITY.repl`) needed
   the cap widened to underlying + premium. Adding a charge => find every caller and re-cap.
3. *Balance* was NOT an issue — the sandbox absorbed the increase.

**Hazard confirmed again:** patching `[6.1.1]`/Talos by text failed its uniqueness assert because
the 3-line `C_Collect` sequence appears TWICE in `01_TS02-C1.pact`. A bare `replace(...,1)` would
have charged $100 to the WRONG function. For P5's ~200 rewrites: always anchor on the unique
enclosing function name and assert the match count.

## P4 done (2026-09-06) — fee-unlock is now FLAT $50 + $50

`IG|DETER "fee-unlock" = 5000` + `IGNIS::UC_FeeUnlockPrice` returning `[IGNIS STOA]` =
`[5000, 500]`. Deliberately kept the SAME 2-element shape the retired ladder returned, so all 8
consumers changed only their call expression, never their structure: DPTF x3, ATS x2, SWP x2,
`Z_Reads/02_INFO-ONE+.pact` x1, plus `[6.6]_ATS.repl`'s capability cap (sized from the same
source the module charges from).

What this replaced: `U|DEC::UC_UnlockPrice` = `base x (unlocks+1)` with **no ceiling** — DPTF's
FIRST unlock already cost $100 and each one grew without bound (the owner remembered a ceiling;
the code never had one), and its STOA leg was `ignis/100`, i.e. dollars-at-$1, 10x short of the
$0.10 peg rule.

**INCIDENT — a bulk-removal script destroyed 4 utility files; reverted.** Trying to retire the
now-dead ladder (`UC_UnlockPrice` in U_DEC/U_ATS/U_DPTF, `CT_DPTF-FeeLock`, `CT_ATS-FeeLock`) I
wrote a defun-remover whose paren balancing was wrong (it did not skip string literals on the
first pass and its slice arithmetic was broken). It deleted **624 lines** across `01_U_CT.pact`,
`07_U_DEC.pact`, `09_U_ATS.pact`, `10_U_DPTF.pact` instead of ~5 small functions; ZALL caught it
immediately (`01_U_CT.pact:90 Expected: [import, defun, ...]`). Recovered with
`git checkout --` on exactly those 4 files, which was safe ONLY because nothing else in the
session had touched them.
RULES going into P5/P6:
  * NEVER delete Pact code with a hand-rolled paren balancer. Retire dead code by commenting or
    by an exact full-text match of the known block, and diff-stat BEFORE running the pipeline.
  * `git diff --stat` after any bulk edit — 624 deletions is instantly visible, a silent
    mis-slice is not.
  * The dead ladder is STILL PRESENT (harmless dead code) and its removal is deferred to P6,
    where it belongs, to be done one exact block at a time with verification between each.

## P5 in progress (2026-09-06) — 47 readers migrated, plus two findings that RESHAPE the phase

Migrated off legacy `UDC_*Cumulator` tiers onto `UC_IgnisPrice(op-key, deter-key)`:
DPTF 15 · ATS 14 · DPOF 12 · SWP 6 = **47**, ZALL green after each tranche. Tool:
`/tmp/migrate_urci.py` — per-function anchoring, assert-unique match, skip-and-report for
anything lacking an `IG|COMPONENTS` key, never deletes code, `git diff --stat` after every run.

**FINDING 1 — the component map was missing 1/3 of the surface (fixed).** Talos wrappers call
`ref-AQP::`, but that is a LET-BINDING ALIAS; the real module is `AQP-POOL`. The price-sheet
resolver mapped only real module names, so EVERY `AQP-*` wrapper failed lookup and was silently
skipped. Fixed by resolving aliases from `(ref-X:module{Iface} REALNAME)` in the wrapper's own
file. `IG|COMPONENTS` grew **297 -> 393 ops** and 12 entities appeared that were invisible
before: the whole AQP family + ORBR, SPARK, SNAKES, CUSTODIANS, KPAY (the citizen launchpad
modules were absent from the price sheet entirely).
LESSON: in this codebase a `ref-NAME::` prefix is an alias, NOT a module name — always resolve
it before mapping.

**FINDING 2 — "~200 URCi rewrites" is really TWO populations.** Inspecting AQP showed most of
its tier calls are NOT op-level readers at all:
  * **op-level `URCi_*`** = one client op -> migrate to `UC_IgnisPrice(op, deter)`. (What P5 does.)
  * **per-leg cumulators inside `XI_*`/`XB_*` writers** (e.g. `XI_1|WriteDptfTrackerSlot`,
    `XB_SetBenDptfAnkSyncCount`) = LEGS of composed ops. They have no Talos op name, so a
    per-op deter+components price is meaningless for them. They must stay tier-based, or move
    to explicit `IG|WEIGHTS` leg constants — a separate decision, NOT part of P5's migration.
  So the real P5 population is much smaller than the 135 raw tier-call count suggests.

**FINDING 3 — auto-classification must never price ISSUE ops.** The name-based tier classifier
(usage/fee/auth/setup) labelled `AQP-POOL|C_Issue` as "setup" = 5 ignis, when pool issuance is
owner-priced at 1000. Three orders of magnitude wrong, and it would have looked plausible in a
diff. The migrator now REFUSES any `URCi_Issue*/Create*/Deploy*/Mint*/Make*/Define*/Open*/New*`
and reports it for explicit handling. Generic classifiers are safe for generic tiers ONLY.

## P5 tally (2026-09-06): 68 op-level readers migrated, ZALL green throughout

DPTF 15 · ATS 14 · DPOF 12 · SWP 6 · DPDC-R 11 · DPDC-MNG 6 · DPDC-S 3 · DPDC-F 1.
DPDC readers are `son:bool`-SPLIT — one reader serves both wrappers, so they bill
`(if son (UC_IgnisPrice "DPSF|C_X" k) (UC_IgnisPrice "DPNF|C_X" k))`.

**FINDING 4 — core reader names DO NOT always match their Talos op names.** Three skips were
name mismatches, not missing ops: `URCi_BurnSFT` -> `DPSF|C_Burn`, `URCi_BurnNFT` ->
`DPNF|C_Burn`, `URCi_WipeSlim` -> `DPSF|C_WipeNoncePartialy`. Resolve by following the WRAPPER
BODY (`grep the Talos defun, read which ref-CORE::C_x it calls`), never by assuming
`URCi_X -> ENTITY|C_X`.

**The interface-first trap bit AGAIN** (3rd time this session): `re.search(r'\(defun NAME...')`
finds the INTERFACE DECLARATION before the module implementation, so the "body" has no cumulator
and the assert fires. ALWAYS slice the file at `re.search(r'\n\(module ')` first and search only
the module region. Standing rule for any Pact edit script in this repo.

**Still open in P5 (decision-shaped, not automatable):**
  a) ISSUE ops the migrator REFUSES by design (would misprice by ~200x): `URCi_AddQuantity`,
     `URCi_RespawnNFT`, `URCi_MakeFragments`, `AQP-POOL|C_Issue` — need owner prices; the spec
     does not cover minting-more-supply ops.
  b) `XI_*/XB_*` per-leg cumulators (AQP especially) — legs of composed ops with no Talos name;
     keep tier-based or re-express as IG|WEIGHTS legs. Owner decision.
  c) `URCi_UpdateNonceField` — one reader serving many `C_UpdateNonce*` wrappers, no `son` arg.
  d) `00_DPMF.pact` (11) — historic stub, proposed to leave on legacy tiers.

## P7 gate built + sheets re-synced (2026-09-06)

**P7 acceptance gate is real and passing (34 asserts in `[6.1]_Cumulator.repl`).** The pattern:
call the actual cost reader a client op bills through, pull the IGNIS out of the returned
`OutputCumulator` (`(at "ignis" (at 0 (at "cumulator-chain" oc)))`), assert it equals
`UC_IgnisPrice(op, deter)`. Includes a FULL-MODULE SWEEP of all 15 migrated DPTF readers plus a
regression guard that `C_Control` no longer equals the legacy flat `ignis|small`. Note Pact
rejects `(fn:(function object -> decimal) (lambda ...))` type annotations — inline the extraction.
NOTE: `[6.1]_Cumulator.repl` is SKIPPED by Z.repl's AQP-fast default, so these run via a
composite loader (deploy-stage00 + deploy-stage01 + [6.1]); "IGC asserts passed: 0" in a Z.repl
summary is EXPECTED, not a failure.

**Price sheet taught to read the migrated form.** The extractor only understood tier
constructors + `UC_IgnisDeter`; the 68 migrated readers use `UC_IgnisPrice "<ENTITY|FN>" "<key>"`,
so they were showing as unresolved. It now decomposes that into `deter + components` and prints
the breakdown, e.g. `C_Control 25 = deter:setup 5 + components:DPTF|C_Control 20` — which matches
the P7 assertion exactly, so sheet and chain agree by construction.
Also fixed: an admin (`A_`/`AA_`) Talos wrapper must render EXEMPT regardless of what legs its
core op would charge (it was showing the underlying `small 2`); classify from the TALOS prefix.

Current sheet: 166 simple (exact) · 62 complex (floor) · 40 exempt · **162 unresolved** of 268
Talos functions. The unresolved bulk is the un-migrated tail — it shrinks as P5 completes.

**TOOL HYGIENE NOTE (cost several wasted calls):** launching `pact Z.repl` without
`cd REPL &&` and reusing ONE log path across concurrent background runs made them clobber each
other, so grep counts came back empty and I re-launched repeatedly. Always `cd REPL && pact
Z.repl > /tmp/<unique>.log`.

## Owner answers + findings (2026-09-06, after commit 3371ea8)

Work to date committed on branch `ignis-pricing-rehaul` (3371ea8). Owner decisions:
  1. **Minting-type ops get NO special deter/STOA** — generic tiers only. Wired:
     `URCi_AddQuantity`->`DPSF|C_AddQuantity` (setup), `URCi_RespawnNFT`->`DPNF|C_Respawn`
     (setup), `URCi_MakeFragments`->`DPSF|C_MakeFragments` (usage). ZALL green.
  4. **DPMF is dead code — leave it alone.** No migration, ever.
  2. Per-leg vs tier question: owner leans per-leg but asked for the difference first (answered;
     awaiting the call). 3. `URCi_UpdateNonceField` still unanswered.

**`AQP-POOL|C_Issue` needed NOTHING — it was a false alarm from a real migrator bug.** It bills
`GAS|ISSUE-POOL` (= `issue-pool` 1000) and has no tier call at all. The migrator "found" one
because its body regex ends a defun at `\n    )\n`, while AQP closes defuns as `        ))` on
the same line — so the body OVERRAN into the next function and matched a tier belonging to
`URCi_SyncTrueFungibleAnchorsFull`. Applying it would have rewritten the WRONG function's price.
Hazard is now documented in the tool header. **Never bulk-edit the AQP family without real paren
balancing.** (This is the 4th distinct way naive regex editing has tried to corrupt this repo:
interface-vs-module, non-unique text, hand-rolled paren deletion, and now body overrun.)

**The "162 unresolved" measured, not guessed:** ~55 are ops that COMPOSE other client ops'
cumulators (e.g. `VST|C_Freeze` = Concatenate[TFT::C_Transfer, DPTF::C_Mint, TFT::C_Transfer]) —
their price is derived, so they belong in COMPLEX, not "unresolved"; ~107 are the genuine
un-migrated tail and shrink as P5 proceeds.

**The per-leg population is only 10 sites** (all AQP): `XI_1|WriteDptfTrackerSlot`,
`XI_1|ZeroDptfTrackerSlot`, `XI_1|WriteCollectableTrackerSlot`, `XI_2|BumpBenDpsfNonceTotal`,
`XI_2|BumpBenDpnfNonceTotal`, `XI_1|BumpBenDptfTotalSlot`, `XB_SetBenDptfAnkSyncCount`,
`XB_SetBenCollectableAnkSyncCount` + 2. Mostly `Medium` (3 ignis). Option B (name them as
`IG|WEIGHTS` legs) is therefore ~10 edits, not the 20-30 first estimated.

## DEFECT I INTRODUCED AND FIXED — half-migrated son-branches (2026-09-06)

`DPDC-MNG::URCi_Control` and `URCi_WipeNonce` were ALREADY branchy before migration:
`(if son (UDC_BigCumulator owner) (UDC_BiggestCumulator owner))`. My migrator replaces the
FIRST tier call it finds, so it produced:

    (if son (UDC_ConstructOutputCumulator (if son PRICE_SFT PRICE_NFT) owner ...)
            (UDC_BiggestCumulator owner))          ;; <-- NFT branch still legacy!

i.e. son=true got the new price while **son=false silently kept the old flat tier**. The NFT ops
looked migrated and were not. **ZALL stayed green throughout** — the code is syntactically valid
and merely charges the wrong number, which no existing test asserted. Found only by noticing
those two functions still appeared in a "still on legacy tiers" scan AFTER being reported as
migrated.

Detector (run after ANY migration batch): flag any `URCi_*` whose body contains BOTH
`UC_IgnisPrice` AND a `UDC_*Cumulator` — that combination means a partially-rewritten function.
Result was exactly 2; both repaired to a single `UDC_ConstructOutputCumulator` wrapping one
`(if son ...)` price. Detector now reports 0.

LESSON: a migrator that replaces "the first match" is unsafe on any function with BRANCHES.
Either replace ALL tier calls in the body, or refuse functions containing more than one and
handle them by hand. And note what this says about the test suite: P7-style price assertions are
the ONLY thing that would have caught this — pipeline-green proves nothing about prices.


## 2026-09-07 — owner answers + three defects found while acting on them

**Owner rulings.** (1) CODEX ops are *not* free: they pay their structural IGNIS (components)
at **deterrence 1x**. (2) The DPNF/DPSF bulk-transfer and remove-nonce-score ops must pay too;
the bulk ones are composite, so their cost must come from a scaling reader. (3) The
IGNIS-PRICING folder had too many files to navigate — one front door is required.

**My earlier "CODEX is gasless" diagnostic was WRONG.** It tested the *core* `C_RotateCodexGuard`,
which returns a `string`. The cumulator comes from `URCi_RotateCodexGuard` at the **Talos hop**
(`TS01-C4`), which was already wired. Lesson: to decide whether an op charges, follow the Talos
wrapper's `IGNIS::C_Collect` argument, never the core `C_`'s return type. Applied change:
RotateCodexGuard `auth`(10) → `usage`(1) per the 1x ruling; 14 → **5**. RecordArweaveUpload was
already `usage`; unchanged at **10**. Two stale "Gasless today" `@doc`s corrected.

**The six "unpriced" ops were never unpriced.** `DPSF|`/`DPNF|` `C_BulkTransfer`,
`C_RemoveNonceScore`, `C_RemoveSetNonceScore` are **thin aliases** that delegate to a priced op,
so they carry no `C_Collect` of their own and the generator skipped them. Bulk transfer already
scales correctly — `DPDC-T::URCi_BulkTransferCumulator` folds `URC_TotalTransferPrice` over every
receiver leg. No pricing work was needed. **The general lesson: an op with no `IG|COMPONENTS`
entry is not necessarily unpriced — it may bill through a shared or delegated reader.** A
`IG|COMPONENTS`-key liveness scan reports 222/396 keys "never read"; that is expected, because
whole families (all ~20 `C_UpdateNonce*`) bill through ONE shared reader
(`DPDC-N::URCi_UpdateNonceField`) keyed on a single representative op.

**GENERATOR BUG — the price sheet under-reported 29 rows.** In `_ignis_price_sheet.py` the
`(if son ...)` DPSF/DPNF branch-picker had a positional fallback `elif len(ig) == 2:` that chose
ONE leg. But a single migrated `UC_IgnisPrice "<op>" "<deter>"` also emits exactly **two** legs —
`deter:` and `components:` — which must be **SUMMED, not chosen between**. So it kept one half
each way: DPSF rows showed `deter:setup 5`, DPNF rows showed `components 17`, where the chain
charges **5 + 17 = 22** for both. Fixed by restricting the fallback to legacy tier pairs
(`not lab.startswith(('deter:','components:'))`). 29 rows corrected; the sheet's
"components-only" row count went 14 → **0**. The 13 remaining deter-only rows are legitimate —
all are already flagged `≥`/COMPLEX composite ops. **The CODE was always right; only the
published sheet was wrong.**

**CORRECTNESS BUG (not pricing) — `C_RemoveSetNonceScore` wrote to the wrong row.** In DPDC-N,
`nost` = *NoNCe-Or-SET*: `true` → nonce data, `false` → set data. `C_UpdateSetNonceScore` passes
`nost=false`; `C_UpdateNonceScore` passes `nost=true`. But **both** `DPSF|` and `DPNF|`
`C_RemoveSetNonceScore` delegated to `C_UpdateNonceScore`, handing it a **set-class** integer down
the **nonce** path — so removing a set-nonce score targeted `UR_NativeNonceData id son set-class`
instead of the set row. Rerouted to `C_UpdateSetNonceScore` in both Talos modules. No price
change (both bill 22 via the same shared reader). Found only by tracing delegation for pricing —
`ZALL` was green with the bug present, and two REPLs exercise the path.

**Docs.** `IGNIS-PRICING/README.md` now opens with a single answer ("want a price? →
`IGNIS-PRICE-SHEET.md`, that is the only file you need") plus how to read a row (bold = exact,
`≥` = scales with item count). Four pre-rehaul/never-shipped files moved to `archive/`.

Verified with `ZALL.repl` (exit 0, "Load successful"), not `Z.repl`.

## 2026-09-07 (2) — the STOA column was blind; the chain was right

Owner: "for issuance functions that have a STOA fee, the STOA amount equals the deterrence price
in dollars, converted at the hardcoded $0.10 oracle price — 4500 IGNIS deter = $45 = 450 STOA.
This isn't properly added in the document, and probably neither in the code."

**Half right, and the important half is the good news: the CODE already implements this exactly.**
`IGNIS::UC_StoaPrice(k) = (IG|DETER[k] / 100) / stoa|price`, and every asset-issuance reader
already calls it — `DPTF/DPOF/ATS::URCi_IssueStoa`, `DPDC-I::URCi_IssueCollectionStoa` (son-branch
covering BOTH issue-sft and issue-nft), `SWPI` for issue-swp-pair, `TS02-C1` for
issue-shareholder. Their `@doc`s already spell the rule out. **Only the published sheet was
wrong** — the third time this session that the generator, not the chain, was the defect.

**Why the sheet showed `—`.** It detected STOA only via `UR_UsagePrice "<key>"`, but the issuance
readers call `UC_StoaPrice "<deter-key>"` directly, so no leg was ever found. Compounding it,
`[4.0]_Sovereign-Executor.repl` seeds the per-asset keys TWICE: stale pre-rehaul literals at
L228-237 (`dptf 0.2`, `dpnf 0.5` …), then DERIVED overrides at L258-263
(`A_UpdateUsagePrice "dptf" (UC_StoaPrice "issue-tf")`). The generator's literal-only regex read
the stale first set and never saw the overrides that actually win on chain.

**Also fixed: son-branch legs were SUMMED, not selected, on the deter side.** `DPSF|C_Issue` and
`DPNF|C_Issue` both reach `(if son ... "issue-sft" ... "issue-nft")`, and the branch-picker only
covered `components:` labels. The sheet published **4549** for both — a number no caller can ever
pay. Correct: SFT **2049**, NFT **2549**. `DPSF|C_IssueCompany` 14643 -> **12143**.

Published asset-issuance table now (deter -> dollars -> STOA @ $0.10):
`DPTF|C_Issue` 1000/$10/**100** · `DPOF|C_Issue` 1000/$10/**100** · `DPSF|C_Issue` 2000/$20/**200**
· `DPNF|C_Issue` 2500/$25/**250** · `ATS|C_Issue` 4000/$40/**400** · `SWP|C_IssueStable` and
`C_IssueWeighted` 5000/$50/**500** · `DPSF|C_IssueCompany` 12000/$120/**1200**.
The rule is now stated in `IGNIS-PRICING/README.md` with this table, so it cannot be lost again.

**OPEN — inconsistent account-creation STOA (owner decision needed, NOT changed).** Two live
sources of truth for what a deployed account costs in STOA:
  * new, gated by the `UR_AccountCreationStoa` global switch:
    `UC_StoaPrice "acct-standard"` = **50 STOA**, `"acct-smart"` = **100 STOA**;
  * legacy raw literals never re-derived: `UR_UsagePrice "standard"` = **0.01**,
    `"smart"` = **0.02** — still read directly by `AQP/03_AQP`, `05_FVT`, `02_SCORE`, `01_ANK`.
So AQP pool/FVT/score issuance charges 0.02 STOA for a smart account while the account-creation
path charges 100 — a 5000x gap that also bypasses the global switch. Left alone deliberately:
closing it is a price change, not a bug fix.

**Rule learned (three for three).** A price defect found in a generated document is far more
likely to be in the generator than in the chain. Verify against the `URCi_`/`UC_*Price` call site
before touching a `defconst`.

## 2026-09-07 (3) — every STOA price is now a DOLLAR price divided by the oracle

Owner, stating the rule a third time and closing the question I had left open: "the prices are
always in dollars and converted into STOA value following the STOA price oracle. Standard account
is $5, smart account $10 — at $0.10/STOA that's 50 and 100 respectively. Price is ALWAYS in
dollars, converted to STOA units using its price."

So the AQP `0.01`/`0.02` reads were never a pricing decision to preserve — they were raw
pre-rehaul STOA amounts that had never been dollar-denominated at all, and therefore ignored the
peg entirely. Fixed rather than flagged.

**What the reads actually were.** Not account creation. Every one of the 11 `UR_UsagePrice
"smart"/"standard"` reads sat inside an **Issue** function, borrowing the account-price keys as a
convenient small number. Four cost readers carried the price; the other seven were **dead
`smart-price` let-bindings** (verified: each name appears exactly once in its defun body, the
binding itself, while the real collection went through the `URCi_*Stoa` reader). Readers now
derive from their OWN deter key, the same way DPTF/DPOF/ATS/SWP already did; the seven dead
bindings are deleted.

| reader | now derives from | deter | $ | old STOA | new STOA |
|---|---|---:|---:|---:|---:|
| `AQP-POOL::URCi_IssueStoa` | `issue-pool` | 1000 | $10 | 0.02 | **100** |
| `AQP-FVT::URCi_IssueStoa` | `issue-fvt` | 1000 | $10 | 0.02 | **100** |
| `AQP-SCORE::URCi_IssueScoreStoa` | `issue-score` | 1000 | $10 | 0.02 | **100** |
| `ANK::URCi_IssueAnchorStoa` | `anchor` (x2 if acnoi) | 500 | $5 | 0.01 | **50** / 100 |
| account `standard` (executor) | `acct-standard` | 500 | $5 | 0.01 | **50** |
| account `smart` (executor) | `acct-smart` | 1000 | $10 | 0.02 | **100** |

The two account keys are fixed at the SEED, not the call site: `[4.0]_Sovereign-Executor.repl`
now re-seeds `standard`/`smart` from `UC_StoaPrice "acct-standard"/"acct-smart"`, so every
consumer (incl. `DPL-UR::URC_0029_AccountOverview`'s activation preview) becomes correct at once.
`UR_UsagePrice "smart"/"standard"` no longer appears anywhere in sovereign code.

**Test fallout was real and is the proof the change bit.** ZALL failed at
`AQP-POOL|C_Issue` collecting **100.0** STOA against a fixture holding 19.4 — the price moved
5000x exactly as intended. The AQP fixtures cap STOA with hardcoded `(coin.TRANSFER ... 50.0)`
allowances; 301 of them across 3 files were raised to 1000.0. Note the same fixtures compute
`split-smart` as `(* 2.0 (UR_UsagePrice "smart"))`, which auto-scaled correctly — derived fixture
values survive a re-pricing, hardcoded ones do not. Prefer derived.

**Self-inflicted break worth remembering.** My generated `@doc` appended " Doubled when <acnoi>."
AFTER the closing quote, producing `... entirely." Doubled when <acnoi>.` -> `Expected: [IDENT]`.
When templating a Pact `@doc`, the trailing text must go INSIDE the final quote. Same family as
the earlier `"`-inside-a-continuation bug.

Verified: `ZALL.repl` green, 6279 lines, "Load successful" — byte-identical length to the clean
baseline run.

**STILL OPEN (needs an owner dollar price, deliberately untouched):**
  * `blue` = **0.025** raw STOA per month, the branding upgrade price
    (`BRD::URCi_UpgradeBranding` = months x blue). It is the LAST STOA key still holding a raw
    non-dollar amount. What should a month of blue-flag branding cost in dollars?
  * `codex` = 100.0 is seeded in the executor but **read nowhere** — a dead key. Delete, or wire
    it to something?

## 2026-09-07 (4) — blue branding priced; the last raw STOA amounts identified

Owner: blue-flag branding was meant to be **$25 in STOA — 250 at the locked price**. Added
`IG|DETER "branding-blue" : 2500.0` as the dollar basis and derived the `blue` usage key from it
in the executor, so `BRD::URCi_UpgradeBranding` = months x 250 STOA at the $0.10 peg (was 0.025
raw). Found and removed a THIRD dead binding of the same shape in `BRD::XE_UpgradeBranding`
(`(blue:decimal (UR_UsagePrice "blue"))`, one occurrence in the body = the binding itself; the
real payment already went through `URCi_UpgradeBranding`). That makes 8 dead price bindings
deleted this session — the pattern is: a `let` binds a usage price, then the code bills through a
`URCi_` reader instead and the binding is never removed. Worth grepping for after any re-pricing.

Also fixed the owner's `01_DALOS.pact` missing `)` at the `ceiling-anu` binding (they had spotted
it independently on deploy); it had been blocking ZALL at load.

**The `codex` key, answered.** `[4.0]_Sovereign-Executor.repl:237` seeds
`A_UpdateUsagePrice "codex" 100.0`, and `UR_UsagePrice "codex"` is read **nowhere** in the repo —
that one seed line is the ONLY occurrence of the string. CODEX's StoicTag registration does not
use it; it charges `UC_StoicTagStoaFee` = `(dec (length tag-name))`, i.e. 1 STOA per glyph,
hardcoded. So `codex` is a dead placeholder from before glyph-pricing landed.

**Remaining raw (non-dollar-denominated) STOA amounts — the complete list.** After this session
these are the only ones left; every other STOA price derives from `IG|DETER` via `UC_StoaPrice`:
  1. `CODEX::UC_StoicTagStoaFee` = **1 STOA per glyph**, hardcoded in the function body. Under the
     dollar rule this should be $X per glyph converted at the peg (e.g. $0.10/glyph = 1 STOA/glyph
     today, which may be exactly the intent — but it is not pegged, so it drifts with the oracle).
  2. `PYTHIA|DEFAULT-DEPLOY-PRICE` = **500.0** and `PYTHIA|DEFAULT-RENAME-PRICE` = **100.0**, raw
     STOA defaults, admin-tunable via `A_UpdateDeployPrice`/`A_UpdateRenamePrice`. These match the
     owner's earlier spec ("PYTHIA 500/100 STOA, non-discountable") stated in STOA units, so they
     are $50/$10 at today's peg — but being raw, their DOLLAR value moves with the oracle, which
     is the opposite of the rule everywhere else.
  3. `codex` 100.0 — dead, see above.

Verified: `ZALL.repl` green, 6279 lines, "Load successful".
