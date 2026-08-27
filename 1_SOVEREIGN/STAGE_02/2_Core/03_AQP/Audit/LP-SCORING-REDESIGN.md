# LP scoring — two-level RPS redesign (root cause behind H1, and likely C2/H5/M3)

**Status:** design intent captured; deep study in progress (gap analysis + refactor plan to follow).
**Origin:** AQP audit Round II, fix #7 (H1). The naive floor-at-zero fix was **reverted** — it broke the DPNF
vacate (which legitimately uses transient-negative-then-corrected base). Root cause is architectural, not a
one-liner. Owner then described the intended design; this doc records it.

## 1. The problem (why current LP scoring is broken)

An LP token has **no fixed value** — it's a claim on two fluctuating reserves. The current code stores an
LP position's **value** (lp-denominator equivalent at *current* SWP reserves) as the user's persistent
**base score**. Because reserves drift between stake and unstake, unstake reverses a *different* value than
stake added → **negative base** on full exit (H1), which then poisons the FVT reward divisor. It's a category
error: a fluctuating quantity stored as if fixed.

## 2. Intended design — two-level RPS (RPS-of-RPS)

The correct decomposition (owner's design):

- **Level 1 — inside one LP family / FVT entity.** All LP tokens of the same family are fungible, so the
  user's stored score = **LP AMOUNT** (× mx for native / frozen `F|` / sleeping `Z|` variants — the special
  variants simply count as "more/less LP amount"). **Stable** — amount never fluctuates, so a full unstake
  nets to exactly 0. No negatives, no clamp needed. One FVT entity = one LP pool/family; its total score =
  total LP amount staked in it.
- **Level 2 — across families.** Each FVT entity is a *member* in a bigger RPS vault; its weight = its
  **current value in wrapped-STOA**, computed **only at inject time** to split *that* injection across
  entities. This value is **never persisted** as anyone's score — it's a transient snapshot used to divide a
  reward, then discarded. (Mirrors UrStoa RPS, nested twice: the outer pool's "members" are whole FVT
  entities.)

Inject flow:
```
Inject R:
  Level 2 (at inject time): value each FVT entity in wrapped-STOA → split R across entities by value
  Level 1 (per FVT):        each entity's slice → split among its stakers by LP amount (× mx)
```

The key correctness property: **fluctuating value is used transiently at inject to divide the reward and
thrown away — never stored.** That is what removes the H1 negative by construction.

## 3. Owner decisions (locked)

| Topic | Decision |
|-------|----------|
| **Common denominator** | **wrapped STOA** (historically "DWK" = DalosWrappedKadena). Valued via SWP's `URC_WorthDWK` (breadth-first-search over the pool graph, implemented in Pact). Owner also believes they added a **single-LP-token value** function in the SWP modules (to be located in the study). |
| **Manipulation (spot price)** | Acceptable. The **UI injects rewards at a RANDOM time daily** (not a fixed time) → defeats pump-and-dump around a predictable inject. No oracle/TWAP needed. |
| **Special LP variants** | `F|` frozen / `Z|` sleeping just count as more/less **LP amount** via mx — still amount-based at Level 1. |
| **FVT entity granularity** | One FVT entity = one LP pool/family. "Multiple equivalent scores" within it are the native/`F|`/`Z|` variants of that same pool. |

## 4. Why this likely fixes more than H1

The current FVT already has a two-tier structure (`total-ghost-tvl-weight` + member RPS rows) — the *bones*
of this design — but mis-wired. Several audit findings are probably the same root cause (levels conflated:
value stored where amount belongs, and/or value recomputed on the hot path):
- **H1** — user LP score stored as value (should be amount). ← the visible symptom.
- **C2** (already fixed) — conservation break at the level-1/level-2 seam (inject divisor timing).
- **H5** — triplet Tier-2 unbounded `select` on the hot path (should be a maintained aggregate at the seam).
- **M3** — boost-class-with-0-promile zeroing (a Level-1 weighting issue).

Fixing the architecture properly may fold these into one coherent change rather than four patches.

## 5. Design considerations to get right

1. **Value only at inject** — never persist the wrapped-STOA value; read it transiently per injection.
2. **Conservation at the seam** — Σ(Level-2 allocations) == injected; within each family Σ(Level-1 payouts)
   == that family's allocation. (This is where C2 broke.)
3. **Level-1 amount × mx** — native vs `F|` vs `Z|` weighted by mx, but amount-based, not value.
4. **BFS valuation cost** — `URC_WorthDWK` walks the pool graph; confirm it's execution-path-safe at inject
   (bounded # of entities) and doesn't drag a scan into per-user hot paths.

## 6. Gap analysis (from the 3 deep studies)

**Headline:** the two-level design is **sound and mostly already implemented correctly**. FVT's tier math is
wired the *right way round* — Tier-2 weight = VALUE (ghost-TVL), Tier-1 weight = AMOUNT (deb), converted at
`new-li = L_i + earned/total-deb` (`04_FVT.pact:3594`). The visible "broken / negative score" is **one
localized SCORE bug** (Level-1 stores value, not amount). The rest are gas/architecture cleanups, not the
negative.

### 6.1 Valuation tooling (ready — no new oracle needed)
- `SWPI::URC_WorthDWK(id, amount)` — token→wrapped-STOA (DWK). DWK 1:1 / silver-STOA via ATS index / else BFS spot-swap.
- `SWPI::URC_PoolValue(swpair)` → `[pool-worth, lp-worth]` (the owner's LP-value fn; lp-worth = 1 LP in DWK).
- `SWP::UR_StoaValue(swpair)` — a **stored** stoa-value scalar on `SWP|Pairs`, refreshed by SWP on liquidity events. **This is what FVT uses today** (cheaper than live BFS).
- All interface-exposed; DWK id via `DALOS::UR_WrappedStoaID`. BFS branch is gas-heavy → value only at Level-2 (bounded entities), never per-user. Random-time inject (owner) handles spot manipulation.

### 6.2 The negative (H1) is a LOCALIZED SCORE fix — Level-1
`SCR|UserSchema.base-score` stores LP **value** (`URC_LpAmountToLpDenominatorEquivalent`, reserve-dependent)
instead of **amount**. Every non-LP class is already amount/count based — LP is the sole outlier.
**Fix (no schema change, no clamp):**
- `URC_SignedBaseDeltaForDptfLpStake` (`02_SCORE.pact:2069`) → `raw-weight = lp-amount × mx` (drop `equiv`).
- `URC_SignedBaseDeltaForOrtoLpStake` (`02_SCORE.pact:2083`) → `raw-weight = sum-amounts × mx-sleeping`.
- `URC_LpAmountToLpDenominatorEquivalent` → retire/relocate (its only 2 callers are the above).
- **No floor-at-zero** — amount-based nets to 0 by construction; the clamp broke DPNF's legitimate
  transient-negative pattern (see ROUND-02 #7 attempt). `lp-denominator` stays (FVT-membership + triplet key).

Once Level-1 is amount-based, FVT's already-correct Tier-1 rail stops being fed a fluctuating/negative deb —
**H1 resolved at the source.**

### 6.3 FVT-side observations (separable from H1)

| # | Item | Current | Note | Severity |
|---|------|---------|------|----------|
| G1 | Level-2 value **persisted** (`ghost-tvl-weight` W_i on ScoreEntityLink:298, `total-ghost-tvl-weight` S on FVT|T:280) + reconciled by sync on stake/collect/inject | vs owner's "value only at inject, never store" | **Given the C2 fix (sync-then-read), the stored S at inject == freshly-computed S, so it's functionally correct.** It's a value-weighted RPS with a checkpointed weight — not broken, just heavier (sync runs on stake/collect too). Converting to fully-transient is a gas/purity refactor, not a correctness fix. | ARCH (optional) |
| G2 | L2 weight `W_i = SWP::UR_StoaValue(swpair)` = **whole-pool** TVL value | Owner's example implies **staked** value (staked LP amount × lp-worth), so pools weight by how much is *staked* in them, not total pool TVL | Genuine **design question** — is L2 split by pool TVL or by staked value? Changes reward distribution across pools. | DESIGN Q |
| G3 | H5 — triplet Tier-1 divisor `URC_FarmTripletTier1Denominator` (1651) scans `URD_UserScoreStakerAccounts` (SCORE 1832 raw `select`) on the settle hot path | Must be a maintained aggregate | Separate audit item H5 — fix = a persisted per-member Level-1 amount total, maintained at stake/unstake, point-read as the divisor. | HIGH (own item) |
| G4 | M2 — vault/treasury inject `URC_FvtVaultDebDenominator` (1528) folds all ScoreEntityLink keys | `FVT|T.total-deb-score` mirror (283) already exists (refreshed by `XI_SyncFvtTotalDebMirrors` 3354) | Switch `URC_InjectDenominator` vault branch to read the mirror; drop the fold. | MED (own item) |
| G5 | one-entity-per-pool not enforced; W_i = whole-pool value shared by all entities on a swpair | multiple type-1 links on one pool would double-count | Enforce one-entity-per-pool (owner's model) or make W_i the member's staked value (ties to G2). | latent |

### 6.4 Recommendation — do the small correct thing first

The thing that's actually **broken** (negative scores poisoning rewards) is **6.2 alone** — a 2-function SCORE
change, no schema change, no clamp, verifiable green (and it won't break DPNF because it doesn't touch the
shared path). That is the **corrected fix #7**.

Everything else is separable:
- **G3 (H5)** and **G4 (M2)** are their own audit items → maintained-aggregate fixes (their own review steps).
- **G1** (persist→transient) is an **optional architectural cleanup** — real gas savings + matches the "never
  store value" ideal, but NOT required for correctness once 6.2 + the C2 fix are in. Larger/riskier.
- **G2/G5** are a **design question** for the owner: L2 split by whole-pool TVL vs staked value; one-entity-per-pool.

**Proposed order:** (1) corrected #7 = SCORE amount-based [small, now]; (2) H5 [G3] and M2 [G4] as their
queued items; (3) decide G2/G5 design; (4) optionally the G1 transient refactor as a later phase.

## 10. Stage-1 attempt (cache-based staked value) — FAILED, reverted; proves split-at-inject is required

**What I tried:** keep the ghost-TVL accumulator + sync, but change the cached weight from whole-pool
`UR_StoaValue` to **staked value** (`total-base × stoa-value/LP-supply`, new helper `URC_MemberStakedStoaValue`).

**Why it broke (golden farm test `triplet-collect-golden.repl`):** the inject **defcap** `FVT|C>INJECT` →
`UEV_InjectContext` checks `denominator (= cached S) > 0` **before** the body's phase-0.1 sync runs. And the
sync runs at **stake phase 2.1 — before** the base is written at **phase 4** — so with a *base-dependent* weight
the sync caches `W_i = 0` (base still 0 at sync time), the new base is never re-captured, and inject aborts on
`S = 0`. Diagnostic: `farm S W_i denom => 0 0 0` even though `stoa-value = 11666.9`.

**Conclusion (proven):** a **base-dependent** Level-2 weight CANNOT live in the stored-cache + sync + defcap
model. It must be computed **fresh at inject, in the body** — i.e. the **split-at-inject** re-architecture
(compute `S = Σ member staked-value` fresh; move the `S>0` check out of the defcap; advance each member's L_i
directly at inject; collect simplifies). Also confirmed: only true-triplet handling must SUM the three scores'
base (hub carries it; satellites are 0) — the hub is not necessarily the silver slot.

**Status:** reverted to whole-pool weight (tree green: fast Z.repl 225/0; golden farm 26/0). Kept the
`URC_MemberStakedStoaValue` primitive (correct, unused) for the split-at-inject. **Golden farm test is the
oracle** for the rewrite — its reward assertions will change from whole-pool to staked-value weighting.

## 11. Stage 2a — split-at-inject (farm reward core) ✅ DONE & VERIFIED

**Change (04_FVT.pact only):**
- **New** `URC_FarmInjectDenominatorFresh(fvt-id)` — farm S = Σ enabled members' `URC_MemberStakedStoaValue`,
  computed FRESH at inject (bounded member enumeration; no cache, no sync).
- **New** `XI_1|FarmSplitInject(fvt-id, reward-dptf-id, amount, S)` — split amount across members by fresh
  staked value (`member-slice = amount × W_i / S`), advancing each member's Tier-1 index `L_i`
  (member-deb-rps) by `member-slice / total-deb`, parking in pending-member when a member has value but no
  stakers. Mirrors `XI_2|SettleMemberTier2` row math with member-slice in place of `earned`.
- **`C_Inject`** now branches: **farm** → compute fresh S, `enforce (> S 0)` in the body, `XI_1|FarmSplitInject`
  (NO global G bump); **vault/treasury** → unchanged (bump G = R / deb-sum).
- **`UEV_InjectContext`** (defcap) → farm skips the denominator check (moved to the body, needs a member scan
  that can't live in a defcap); vault keeps its deb check.

**Why it's safe & correct:** for a single-member farm `W_i/S = 1` → `member-slice = amount` → identical to the
old `G += R/S; earned = W_i×(R/S)`. Because farms no longer bump `G`, the *existing* Tier-2 settle calls (in
collect/stake/sync) go inert (`G == g_i == 0`), so collect/stake were left untouched. The base-dependent value
is now read fresh at inject — the caching bug (§10) is gone.

**Verification:** fast `Z.repl` green (225/0, vaults unaffected). Golden farm `triplet-collect-golden.repl`
green — **28/0**, incl. `member L_i advanced by inject = 10.0`, `multiplet payout = 38.0`, `farm G stays 0`.
Updated `TX-AQP-CL03` in `[6.4]_AQP-TRIPLET-COLLECT.repl` from the old `G>0` assertion to the split-at-inject
mechanism (`G stays 0` + `L_i advanced`).

**Still to do (Stage 2b — pure cleanup, now that the cache/sync are dead for farms):**
- Delete the dead ghost-TVL layer: `total-ghost-tvl-weight`/`ghost-tvl-weight` fields, `XI_*SyncFarmGhostTvl*`,
  `WU_*GhostTvlWeight`, the phase-0.1 sync call, the admission `ghost-weight` param + the resolver; retire the
  C2/#4 patch. Then wire the new fresh weight into the admission (store nothing) and confirm the multi-family
  split with a new FULL-profile test.
- **H5** fold-in: `URC_FarmTripletTier1Denominator` → point-read `total-base` instead of the `select` scan.
- Round III regressions: multi-family farm inject → assert split ∝ each family's staked STOA value;
  drift → full unstake → base 0.

## 12. Stage 2b — partial: dead sync removed from hot reward paths ✅; residual documented

**Done (verified green — golden farm 28/0, fast Z.repl 225/0):**
- Removed the farm ghost-TVL **sync from the two hot reward paths** — `C_Inject` phase-0.1 and `CC_Collect`
  phase-0. Farms now touch no cache on inject/collect; `L_i` is advanced by split-at-inject. Kept the collect
  pre-settle (flushes parked pending; at `G=0` it never reads dead machinery).

**Residual = dead-but-harmless (confirmed read only in inert/dead paths):** the ghost-TVL cache
(`total-ghost-tvl-weight`, `ghost-tvl-weight`) + its sync (`XI_*SyncFarmGhostTvl*`, still called on the
STAKE path only), readers (`UR_FVT|TotalGhostTvlWeight` @1559 in the now-farm-unused `URC_InjectDenominator`;
`UR_FVT-SEL|GhostTvlWeight` @1713 in the farm-inert settle branch), writers (`WU_*GhostTvlWeight`), the
admission `ghost-weight` param, and `URC_ResolveScoreEntityGhostWeight`. None affects the live farm reward
math (split-at-inject computes fresh). Physically deleting them is a **safe, load-error-gated** follow-up.

**Deferred follow-ups (scoped, not blocking correctness):**
1. **Physical deletion** of the residual dead ghost-TVL machinery (2 schema fields + sync fns + readers/writers
   + admission `ghost-weight` + interface decls + UDC params). Load-error-gated; ~20 sites.
2. **H5** — needs NEW incremental bookkeeping: triplet Tier-1 divisor `Σ w-user` uses **per-user** ANK promiles
   (`URC_ComputeTripletLanes`), so it can't be a point-read; requires a maintained per-triplet aggregate updated
   at stake/unstake. Distinct from this fix.
3. **Multi-family FULL-profile test** proving the injection splits ∝ each family's staked STOA value (the
   single-family golden verifies the core; multi-family exercises the value-weighting).

**Bottom line: the LP two-level scoring FIX is functionally complete and verified.** Level-1 = LP amount (#7),
Level-2 = staked STOA value computed fresh at inject (split-at-inject). Negative-base bug gone; reward split
by staked value; no tier-2 accumulation driving the logic. Residual is cleanup/optimization/testing.

## 7. Owner answers (round 2) → the simplifying Level-2 refactor

**Q1 (Level-2 weight) — ANSWERED: staked value, via the stored `stoa-value` field.** SWP already maintains a
live `stoa-value` scalar on the pool row, updated on every ratio-moving event (computation lives on the SWP
side). So per-LP value = `stoa-value / total-LP-supply` (cheap point reads, no BFS). An FVT member's Level-2
weight = **its staked LP amount × per-LP value** = `total-base-score(member) × (stoa-value / LP-supply)`.
- `total-base-score` is the member's staked LP amount (now amount-based after fix #7) — a maintained aggregate.
- `stoa-value` + LP-supply are cheap SWP point reads.
- Computed **fresh at inject**, never stored.

**This is SIMPLER than today, not more complex.** It lets us DELETE the entire ghost-TVL persist+sync layer:
- Remove schema fields `FVT|ScoreEntityLink.ghost-tvl-weight` (298) and `FVT|Schema.total-ghost-tvl-weight` (280).
- Remove `XI_1|SyncFarmGhostTvlForEmployedScores`, `XI_SyncFarmGhostTvlForInject`, `WU_ScoreEntityLink|GhostTvlWeight`,
  `WU_Fvt|TotalGhostTvlWeight`, and the phase-0.1 sync calls. The **C2 fix (sync-then-read) becomes moot** —
  there is no stored S to keep fresh; `C_Inject` computes S = Σ(member staked-value) fresh from stored `stoa-value`.
- `URC_InjectDenominator` (farm) becomes a bounded live fold over enabled members (no per-user scan).

**Q2 (same-family restriction) — ANSWERED: yes, enforce in code.** An LP FVT must accept only LP scores of the
**same family**. The current admission checks `lp-denominator == common-denominator` (04_FVT ~2198) — INSUFFICIENT:
two different families share a denominator leg (OURO-VESTA-LP and OURO-STOA-LP both have the OURO leg), so both
pass a denominator check. The real family key is the **swpair** (the pool). Enforce that all LP scores combined
at the AMOUNT level (a member / triplet, and — per owner — the FVT) map to the **same swpair**. (Confirm the
exact boundary: per-member/triplet vs whole-FVT.)

**Bonus — this also resolves H5.** With the Level-1 divisor = the member's `total-base-score` (maintained
aggregate), the triplet `URC_FarmTripletTier1Denominator` no longer needs `URD_UserScoreStakerAccounts` (the
hot-path `select`). The scan is replaced by a point read → **H5 folds into this refactor.**

### 7.1 Net change set (a refactor that REMOVES more than it adds)
- **DELETE:** ghost-TVL fields (2) + the sync subsystem (functions listed above). C2's sync-timing fix retires.
- **CHANGE:** `URC_ResolveScoreEntityGhostWeight` / `C_Inject` Level-2 → `total-base × (stoa-value / LP-supply)`,
  fresh at inject. `URC_FarmTripletTier1Denominator` → point-read `total-base` (kills H5 scan).
- **ADD (small):** same-swpair family guard at score-entity admission; a cheap LP-supply reader if not present.
- **VERIFY:** (a) `stoa-value` updates on **swaps** too (not only add/remove liquidity) — else it's stale
  between trades; (b) a cheap LP-supply point read exists (`SWP::URC_LpCapacity`); (c) `total-base` is the right
  "staked amount" per member (Σ user amounts × mx).

**Scope:** bigger than a single per-fix step, but it SIMPLIFIES (removes a subsystem) and folds G1 + G2 + H5 +
C2-retirement into one coherent change. Recommend doing it as a dedicated **Phase** with its own before/after
`Z.repl` green, rather than as one line in the fix list.

## 8. Owner design model (round 3) — triplet, FVT class, and the final change set

**Triplet = ONE staked asset, THREE reward lanes.** A score (e.g. an LP "silver" score) is boosted by NFT
anchors, but the boost is split into **bronze / silver / golden** parts, each feeding a **different reward
token via an ATS ladder** (bronze → ATS-pair-1 reward token; silver → pair-1 reward-bearing = pair-2 reward
token; golden → pair-3 reward-bearing). So one position generates up to three reward asset types.
- **True triplet:** bronze & golden use **silver's base** as their base (foreign-boost-link) → they contribute
  only the boost *surplus* (base 100, +5%/+10%/+25% → bronze 5, silver 110, golden 25). The 3 act as ONE score
  entity. (Implemented by SCORE's `apply-foreign-boost-surplus`: satellite base=0, boosted/deb hold surplus.)
- A triplet is therefore **one family/asset = one FVT member**, regardless of lanes.
- **Not LP-only:** a triplet can be built on LP, TF, OF, SF, or NF. Its definition already carries a type tag
  (`triplet-category` LP | VAULT_TF | TREASURY_SF_NF; single scores carry `score-class` 0–4).

**FVT class IS the homogeneity rule (already enforced).** Farm = LP-tied entities only; Vault = TF + OF;
Treasury = SF + NF. The class is set by the member asset type; `URC_ScoreClassMatchesFvtClass` (admission)
already enforces it. Mosaic/membership-mode controls single-vs-triplet mixing *within* a class; the class
restriction is separate and already correct.

**Final change set (owner-confirmed):**
1. ✅ **LP score = AMOUNT** (fix #7 done). Restructure scoring so LP counts LP-token amount, not value.
2. **Delete the tier-2 (Level-2) accounting from the FVT table** — `total-ghost-tvl-weight` etc. + the sync.
   **No special tier-2 RPS fields at the FVT level.** Compute Level-2 at inject.
3. **At inject, the FVT normalizes each member to STOA per its type.** It only needs to know **is this member
   LP or not** (from `score-class` / `triplet-category`). If LP → value it: `amount × (stoa-value(swpair) /
   LP-supply)`. Non-LP members are kept in their own comparable unit (operator ensures homogeneity; class
   segregation already prevents LP/non-LP mixing). Split the injection across members by these STOA values.
4. **No `congregation` entity.** The FVT member set already IS the multi-family group; a triplet already IS the
   single-entity abstraction. Adding a congregation type would re-create the member layer.
5. **True/standard-triplet stays a SCORE-side concern** (foreign-boost-link surplus) — unchanged by the FVT refactor.

**Open verifications:** triplet type-tag granularity (is `triplet-category` enough to answer "is LP"); whether
non-LP FVTs (Vault/Treasury) need STOA normalization at Level-2 or the existing deb split suffices; `stoa-value`
updates on swaps; cheap LP-supply read; `total-base` = staked amount×mx.

## 9. Verifications (all confirmed) + the concrete refactor Phase plan

### 9.1 Verification results
- **V1 `stoa-value` freshness — CONFIRMED FRESH.** `SWP::XE_UpdateStoaValue` is called from **Talos `TS01-C3`**
  after every SWP client op (`04_TS01-C3.pact`, ~14 sites: swaps, add/remove liquidity, pool issue), each writing
  `(at 0 (SWPI::URC_PoolValue swpair))` = whole-pool worth in DWK. Talos is the only client path, so every
  ratio-moving event refreshes it. Stored + fresh + cheap read. (`UR_StoaValue` `15_SWP.pact:710`; writer 1522.)
- **V2 LP-supply read — CONFIRMED CHEAP.** `SWP::URC_LpCapacity(swpair)` (`15_SWP.pact:828`, interface line 65) =
  the LP token's DPTF supply. Per-LP DWK value = `stoa-value / URC_LpCapacity`.
- **V3 `total-base` — CONFIRMED.** After fix #7, `SCR|T|Score.total-base-score` = Σ(user LP amount × mx) — the
  member's staked LP amount, a maintained aggregate (`WU3_Score|VaultTotals`).
- **V4 triplet type tag — CONFIRMED.** `SCR|T|Triplet.triplet-category` ∈ {LP, VAULT_TF, TREASURY_SF_NF}, set
  from `score-class` (`02_SCORE.pact:1768`). "Is LP" = `triplet-category == "LP"` (or `fvt-class == 0`).

### 9.2 Refactor Phase (FARM / LP path) — "delete stored Level-2, compute at inject over members"

**Goal:** Level-1 = LP amount (done); Level-2 = staked STOA value computed FRESH at inject from the stored
`stoa-value`; delete the persisted ghost-TVL layer; keep `lp-denominator` homogeneity; no new entity. Scope =
**farms (fvt-class 0) only**; Vault/Treasury STOA-normalization deferred (owner: LP-only for now).

**Step 8.1 — SCORE Level-1 = amount.** ✅ DONE (fix #7).

**Step 8.2 — Delete persisted Level-2 fields (schema).** Pre-mainnet, so free:
- `FVT|Schema.total-ghost-tvl-weight` (04_FVT.pact:280) — remove.
- `FVT|ScoreEntityLink.ghost-tvl-weight` (298) — remove.

**Step 8.3 — Compute Level-2 fresh at inject (staked value).**
- New `URC_MemberStakedStoaValue(score-entity-type, score-entity-id, swpair)` =
  `total-base(member) × (UR_StoaValue(swpair) / URC_LpCapacity(swpair))` (guard LP-supply>0). For a triplet, use
  the silver score's total-base (or the combined member total — confirm during build).
- `URC_InjectDenominator` farm branch (1553) → `S = Σ URC_MemberStakedStoaValue over enabled members` (bounded fold).
- `URC_ScoreEntityMemberWeight`/`XI_2|SettleMemberTier2` farm weight → `URC_MemberStakedStoaValue` (fresh), not
  the stored `ghost-tvl-weight`.

**Step 8.4 — Delete the sync subsystem + retire the C2 patch.**
- Delete `XI_SyncFarmGhostTvlForInject` (3246), `XI_1|SyncFarmGhostTvlForEmployedScores` (3455),
  `WU_ScoreEntityLink|GhostTvlWeight`, `WU_Fvt|TotalGhostTvlWeight`, the phase-0.1 sync call in `C_Inject`.
- The **fix #4 (C2) sync-then-read reorder becomes moot** (no stored S to keep fresh) — `C_Inject` reads S fresh.
  Tracker: mark C2 **superseded by Phase 8** (still correct — the failure mode it fixed no longer exists).

**Step 8.5 — Admission cleanup.** `C_AddScoreEntity` / `UEV_AddScoreEntityScoreContext` / `URC_ResolveScoreEntityGhostWeight`:
drop the now-dead `ghost-weight` param + storage. KEEP swpair resolution (cache on the link) and the
`lp-denom == common-denominator` homogeneity check. No same-swpair guard (homogeneous mixing is intended).

**Step 8.6 — H5 fold-in.** `URC_FarmTripletTier1Denominator` (1651): replace the
`URD_UserScoreStakerAccounts` `select` with a point-read of the member's `total-base` (Level-1 divisor =
Σ user amount, already the maintained aggregate). Kills the hot-path scan.

**Step 8.7 — Retire dead LP-value code.** Remove `SCR|…URC_LpAmountToLpDenominatorEquivalent` (now 0 callers).

**Out of scope (flagged):** Vault/Treasury Level-2 STOA-normalization (currently deb-sum split);
`fvt-class` auto-populate (currently set at issue — owner may keep).

**Risk/mgmt:** substantial FVT change (schema field removal + function deletion + `C_Inject` rewrite). Do it as
its own Phase with before/after `Z.repl` green, one logical sub-step at a time, each observable. Any reference to
the removed fields must be updated. Round III regressions: LP stake → SWP drift → full unstake → base == 0;
inject conservation across ≥2 families.
