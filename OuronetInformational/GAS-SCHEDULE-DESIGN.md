# Ouronet IGNIS gas schedule — parametric re-pricing design (#76)

Goal: replace the hand-picked IGNIS magic numbers with an **algorithmic gas schedule** — a small
table of named price primitives that every client/admin function's cost is *composed from*, the way a
real chain meters gas. You tune the **table** (one unit + tier multiples + per-resource units); the
whole surface re-prices coherently. STOA `UsagePrice` fees are kept as-is (they already gate issuance).

## 1. The price table (all IGNIS costs derive from these ~11 constants)

```pact
;; ── atomic unit: the ONE global scaling knob ──────────────────────────────
(defconst IG|U        10.0)                  ;; change this → everything scales

;; ── role-tier BASES (flat component), as multiples of the unit ────────────
(defconst IG|MAINT    (* 5.0   IG|U))        ;;   50  sync / maintenance
(defconst IG|USAGE    (* 10.0  IG|U))        ;;  100  legit repeated usage (base, pre-surcharge)
(defconst IG|SETUP    (* 25.0  IG|U))        ;;  250  config / setup on an existing entity
(defconst IG|SUB      (* 50.0  IG|U))        ;;  500  sub-issue (triplet/multiplet/from-model)
(defconst IG|ISSUE    (* 100.0 IG|U))        ;; 1000  GATE: create a new asset / entity

;; ── per-RESOURCE units (variable surcharge, priced per operation) ─────────
(defconst IG|W        (* 2.0   IG|U))        ;;   20  per table write (insert/update/write)
(defconst IG|H        (* 1.0   IG|U))        ;;   10  per heavy-scan item (URH_/URHC_ row touched)
(defconst IG|X        (* 0.5   IG|U))        ;;    5  per cross-module call (ref-M::)

;; ── safety backstop (block-gas-limit analogue) ───────────────────────────
(defconst IG|TX-MAX   (* 200.0 IG|U))        ;; 2000 per-tx ceiling; exceeding it = "must paginate"
```

Every knob is a multiple of `IG|U`, so the tuning surface is: **the unit** (global), **5 tier
multiples** (per role), **3 resource units** (per compute type). That's the whole dial set — no
hardcoded values anywhere else.

## 2. Cost formula, by function kind
- **Fixed (issue/setup/sync)** → `cost = <tier>` (e.g. `IG|ISSUE`). One lookup, no scaling.
- **Usage / composed** → `cost = IG|USAGE + (writes · IG|W) + (heavy-items · IG|H) + (xcalls · IG|X)`,
  capped at `IG|TX-MAX`. The variable part is what makes usage scale with real compute.
- **Batch / defpact (sweep, drain, inject-fix, mass-unstale)** → priced **per chunk**: each tx bills
  `IG|USAGE + n_items·(IG|W + IG|H)` for the ≤ N items that chunk processed.

## 3. On linear scaling vs "unpayable" — my recommendation
**Scale linearly per resource — it's safe here, because the heavy paths are already paginated.**
- A function doing "hundreds of operations" never does them in ONE tx: the sweep/drain/inject-fix/
  mass-unstale/vacate ops are **chunked defpacts / CC-batches** bounded by `N_FIX`/`N_SWEEP`/
  `DRAIN-GAS-MAX` (≤ N items per tx). So per-tx item count is already bounded → linear surcharge stays
  bounded and payable. **The pagination IS the block-gas-limit.**
- Single-tx usage (a collect/inject/stake on one entity) touches a small, structurally-bounded number
  of lanes/writes → linear is a few hundred IGNIS, fine.
- `IG|TX-MAX` is the backstop: if any op's *computed* cost would exceed it, that's the signal the op
  must be paginated (they already are) — so the cap doubles as a design invariant, not a user-facing wall.

This is exactly the blockchain model: per-op metering, bounded by a per-tx ceiling; expensive work is
split across txs rather than priced into oblivion.

## 4. Fixed (non-composed) functions → current cost → proposed tier
The 63 flat-priced ops are the ones with a single fixed number today; here are the 22 named-`GAS|`
ones (the 41 `FLAT` literal-amount ops get the same tier treatment once the schedule is chosen).
This is the list to gauge composed costs from: a composed op ≈ its role tier + the surcharge.

| op | role | current | proposed tier |
|----|------|--------:|---------------|
| `C_Issue` | ISSUE | 1000 (GAS|ISSUE-POOL) | IG|ISSUE (1000) |
| `C_Issue` | ISSUE | 1000 (GAS|ISSUE-FVT) | IG|ISSUE (1000) |
| `C_IssueLiquidityScore` | ISSUE | 1000 (GAS|ISSUE-SCORE) | IG|ISSUE (1000) |
| `C_IssueNonFungibleScore` | ISSUE | 1000 (GAS|ISSUE-SCORE) | IG|ISSUE (1000) |
| `C_IssueOrtoFungibleScore` | ISSUE | 1000 (GAS|ISSUE-SCORE) | IG|ISSUE (1000) |
| `C_IssueSemiFungibleScore` | ISSUE | 1000 (GAS|ISSUE-SCORE) | IG|ISSUE (1000) |
| `C_IssueTrueFungibleScore` | ISSUE | 1000 (GAS|ISSUE-SCORE) | IG|ISSUE (1000) |
| `A_DefineDelegationVault` | ISSUE | 500 (GAS|DEFINE-VAULT) | IG|SUB (500) |
| `C_IssueMultipletFamily` | ISSUE | 500 (GAS|ISSUE-MULTIPLET-FAMILY) | IG|SUB (500) |
| `C_IssueScoreFromModel` | ISSUE | 500 (GAS|ISSUE-SCORE-MODEL) | IG|SUB (500) |
| `C_IssueSingleScoreModel` | ISSUE | 500 (GAS|ISSUE-SCORE-MODEL) | IG|SUB (500) |
| `C_IssueTriplet` | ISSUE | 500 (GAS|ISSUE-TRIPLET) | IG|SUB (500) |
| `C_AddScore` | SETUP | 500 (GAS|ADD-SCORE) | IG|SETUP (250) |
| `C_AdmitAgency` | SETUP | 500 (GAS|OPEN-AGENCY) | IG|SETUP (250) |
| `C_CombineTripletScoreModel` | SETUP | 500 (GAS|ISSUE-SCORE-MODEL) | IG|SETUP (250) |
| `C_RevokeScore` | SETUP | 500 (GAS|REVOKE-SCORE) | IG|SETUP (250) |
| `A_SetAgencyFee` | SETUP | 300 (GAS|SET-AGENCY-FEE) | IG|SETUP (250) |
| `A_SetOracleAuth` | SETUP | 300 (GAS|SET-ORACLE-AUTH) | IG|SETUP (250) |
| `C_RecomputeCapture` | SETUP | 300 (GAS|RECOMPUTE-CAPTURE) | IG|SETUP (250) |
| `A_OracleWrite` | SETUP | 200 (GAS|ORACLE-WRITE) | IG|SETUP (250) |
| `C_DisablePoolStake` | USAGE | 500 (GAS|SET-POOL-STAKE) | IG|USAGE (100) + surcharge |
| `C_EnablePoolStake` | USAGE | 500 (GAS|SET-POOL-STAKE) | IG|USAGE (100) + surcharge |

(22 DIRECT flat-`GAS|` ops. The 41 FLAT ops carry a literal/computed amount — same tier treatment once we pick the schedule.)

## 5. What changes where (staged, ~whole-code refactor)
1. **Add the price table** (§1) to one shared place (IGNIS module constants).
2. **AQP family** (the only flat-`GAS|` users): replace each `GAS|<OP>` with its tier constant; add
   the surcharge helper to the usage/composed cost builders (collect/inject/stake/unstale/sweep).
3. **Non-AQP**: leave STOA `UsagePrice` + the COMPOSED IGNIS concatenation as-is (already algorithmic);
   optionally re-express their FLAT literal bases as tier constants for consistency.
4. **Re-green ZALL** — the INFO cost-equality ground-truths move; update expected values in lockstep.
5. **Calibrate** `IG|W`/`IG|H`/`IG|X` against measured `env-gas` on the heavy paths (round now, real later).

## 6. Open dials for you
- `IG|U` = 10 (so tiers land on today's familiar 50/100/250/500/1000). Bigger unit = coarser, cheaper to reason about.
- The 5 tier multiples (5/10/25/50/100) — is the issue-to-usage spread (20×) the gate strength you want?
- The 3 resource units (write 20 / heavy-item 10 / xcall 5) — starting guesses; calibrated in step 5.
- More tiers? (e.g. a `IG|USAGE-HEAVY` between usage and setup, or a separate `IG|GATE-HARD` above issue for
  the most spam-sensitive creates.) Easy to add — just another table row.
