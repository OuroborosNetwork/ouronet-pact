# M3 — DEB / boost score model + deb-staleness architecture (locked design)

Owner-decided across the M3 design thread (2026-08). This is the spec M3 is implemented against, plus the
deb-staleness subsystem it depends on (built as a follow-on, shares infra with the H4 anchor sweep).

--------------------------------------------------------------------------------
## PART 1 — The score model (M3 core, implement now)

### 1.1 The bug
Today `nominal-boosted-score = bcl==BAR ? base : floor(base × promile/1000, p)` — when a boost class is linked,
the boost part **replaces** the base, so a linked-but-under-1000-promile score is cannibalized (base dropped),
and at promile 0 it earns nothing. `deb-score = boosted × deb` further drops the base.

### 1.2 Corrected model (owner-locked)
- **boost-part** = `base × promile/1000` (a *bonus*, not a replacement). promile 850 ⇒ +0.85·base.
- **pre-deb total** = `base + boost-part`.
- **deb (Elite-DEB, `UR_Elite-DEB`) is an alpha-omega end multiplier on the *sum***: `final = (base + boost) × deb`.
  - deb ≥ 1.0 always (an elite bonus; never below 1.0).
  - Confirmed necessary by the triplet/pure-boost case: a base-0-boost-N score would vanish under deb-on-base-only.

### 1.3 Fields (owner-locked)
**Score-level totals (5, stored, maintained incrementally at settle):**
`total-base`, `total-boost`, `total-base-deb (Σ base×deb)`, `total-boost-deb (Σ boost×deb)`,
`total-deb-score (= total-base-deb + total-boost-deb)` — the reward denominator (#11 reads this).
The two post-deb totals are **not** derivable from the pre-deb totals (deb is per-user), so they must be stored.

**User-level (store 2, derive 3):** store `base`, `boost`; derive `base-deb = base×deb`, `boost-deb = boost×deb`,
`final` on read for the UI (a `URC_UserScoreDecomposition`). Per-user post-deb values are derivable from the 2
stored fields + live deb, and deriving is *more* correct (no deb-drift staleness on the display).

### 1.4 Rewards use the SNAPSHOT, not live
Reward weight (numerator) = **stored** `deb-score`; denominator = **stored** `total-deb-score`. Both on the same
stored basis ⇒ conservation always holds. The deb snapshot is written at stake (already) and refreshed at collect
(new — the collector's own scores only, ≤ his scores in that entity; cheap). **UI derives live for display only.**

--------------------------------------------------------------------------------
## PART 2 — Deb-staleness (the hard problem, follow-on subsystem)

### 2.1 The property
A deb change happens via **EliteAuryn events** (transfer / coil / curl / uncoil) which *know nothing of the
scores*. So they cannot touch stored scores or totals — which is what keeps things **consistent** (numerator and
denominator both on stored snapshots ⇒ R always fully distributed; no leak, ever). Staleness is therefore a
**fairness** problem, not a conservation problem.

- deb **up** → user under-earns until they settle → self-correcting incentive.
- deb **down** → user over-earns at the stale-high weight, AND their inflated weight in the denominator dilutes
  ("robs") other stakers at every inject until the user next settles. This is the vulnerability to bound.

### 2.2 What we CANNOT do (proven dead ends)
- **Eager propagation** (settle all a user's deb-enabled scores at the EliteAuryn event): the per-score update is
  cheap, but *enumerating* the scores is a `select`/scan — an EliteAuryn transfer touching a 200-score user would
  blow 2M gas and kill bulk transfers. Rejected.
- **Per-(fvt/reward-lane) "is-stale" counter for a glance-check:** impossible to maintain cheaply — staleness is
  born on the EliteAuryn side, which can't reach the lane without the same enumeration. So there is **no cheap
  on-chain "is this lane stale?"** and **no cheap on-chain proof of freshness** except scanning everyone.
- **Exact per-period pricing** (4.5× for the month, then 1.2×): needs a checkpoint at the deb-change moment =
  the enumeration above. Rejected. So the residual is one settle-cycle of old-deb — bounded, never zeroed.

### 2.3 The substrate (cheap, build first) — STAGE-2 ONLY, no epoch
**No `deb-epoch`, no EliteAuryn-path changes, no Stage-1 modification.** Staleness of one (user, score) is a
direct equality check against the live deb (which DALOS already maintains and exposes read-only):

```
stale?  ⇔  stored-deb-score ≠ floor((base + boost) × UR_Elite-DEB(account), p)
```

- **Live deb** = `UR_Elite-DEB(account)` — existing DALOS read; DALOS already updates it on every EliteAuryn
  event, so we only *read* it. Nothing to bump on transfer/coil/curl/uncoil.
- **Baked-in deb** = derivable from the Part-1 fields (`deb-score / (base+boost)`), or store `deb-at-last-settle`
  as one small **SCORE (Stage-2)** field if you prefer to avoid floor-edge ambiguity.
- Checkpoint (rewrite the stored deb-score from the current live deb) at **every stake / unstake / collect**.
- H4/anchors is the same shape: `stored-promile ≠ live-promile`, both ANK (Stage-2).

**Scope:** the entire subsystem is SCORE + FVT + ANK + Talos (Stage-2), depending on Stage-1 only via existing
read-only calls (`UR_Elite-DEB`, IGNIS constructors). No Stage-1 module is modified.

### 2.4 The three fairness layers
1. **Collect-backstop (trustless, per-user, cheap).** At collect, refresh the collector's own stale scores in
   that entity (settle at old deb, refresh to live). Caps a user's *realized* over-earn at "since last collect."
   Works with zero admin cooperation. This is the trustless floor.
2. **Inject-checked (enforced, protects OTHERS).** The inject restores the *denominator* so no one is robbed.
   Trustless because the freshness proof is inside the inject transaction (see 2.5). Bounds staleness to one
   inject cycle for everyone, including never-collecting "stake-and-forget" users.
3. **Penalty = IGNIS surcharge on collect (owner-locked — replaces the earlier reward-cut model).**
   - State: `forced-fix-count` per **(fvt-id, reward-lane, user)** — bumped each time an inject un-stales one of
     that user's scores. He sees "the last inject did N fixes for me." (No `penalty-pool`, no reward-cut.)
   - **At collect** (per fvt/reward-lane): the collect already builds an IGNIS cumulator (Talos collects IGNIS
     after every `C_`). Add **`forced-fix-count × RATE`** IGNIS to it, **non-discountable**, and **zero**
     `forced-fix-count`. The reward paid is untouched — he keeps 100% of his reward and simply pays extra IGNIS
     to collect.
   - **Why this model:** reward stays intact ⇒ no disproportionality / no nuking / no formula / no token-unit
     issues, and **linear is fine** because IGNIS is a small fixed unit (~1¢). `107 fixes × 10 IGNIS ≈ $10.70` —
     a real gas-reimbursement (the inject did N fixes for him), never a reward loss. Breadth is safe.
   - **`RATE`** (IGNIS/fix, governance param) ≥ the IGNIS cost of self-fixing one score (a small premium above it)
     so self-fixing is always the cheaper choice. Start ~10 IGNIS/fix; pin against the fix-gas measurement.
   - **Trade-off vs the old model:** the penalty now funds the **gas station** (virtual gas), not the pool's
     honest stakers. Accepted — simpler, reward-intact, and the harm is only ~1 cycle (enforced inject) so
     repaying specific stakers isn't worth the plumbing.
   - **Edge:** a user with a large `forced-fix-count` and low IGNIS can't collect until he tops up IGNIS or
     self-fixes (cheaper, and clears the count). Not a hard lock — self-fix is always the cheaper path. Surface
     it in the UI ("collect now costs +N·RATE IGNIS; fix your scores to avoid it").
   - **Non-discount = CONFIRMED Stage-2-constructible (no Stage-1 mod).** The IGNIS discount is a per-account
     multiplier (`URC_IgnisGasDiscount`, 1.0 = no discount) applied uniformly to the cumulator's prices. The
     existing non-discount pattern is a **separate full-price charge against `UC_FeeDiscountAnchor`** (see PYTHIA
     deploy/rename fees, `TS01-C4`/`23_PYTHIA`). Two options for the penalty, both using existing Stage-1 reads:
     (a) a **non-discounted STOA fee** à la PYTHIA (cleanest, proven), or (b) a **grossed-up IGNIS** amount
     (`count × RATE / patron-discount`) so it survives the discount and lands at full price (keeps the ~1¢ IGNIS
     unit, slightly hackier). Pick at build; both are Stage-2-only.

### 2.5-PRE — ENUMERATION BLOCKER (discovered during build; owner decision required)
Building 2c revealed the hard constraint the earlier design under-specified. To make the inject **denominator**
fresh, the checked-inject must refresh **every stale (user, score) position** in the FVT — deb is per-user, so a
member aggregate cannot be re-derived without touching each user. But:
- **The FVT module has ZERO `select`s over `FVT|T|RPS|User`** — deliberately (StoicSyntax: no scans on the execution
  path; #11 even deleted the last `keys` scan). No position enumerator exists.
- `FVT|T|RPS|User` is keyed `User-ID | FVT-ID | Score-Entity-ID | DPTF-ID` → `fvt-id` is not index-leading, so
  enumerating one FVT's positions is a **full-table `select` over the largest table**, not a bounded per-fvt read.
- Pact `select` does not paginate cheaply (no cursor) → the `InjectSweep` defpact's `take N` chunking does **not**
  avoid materialising the whole select each step. Chunking bounds the *fix* work, not the *scan* cost.
- A per-FVT stale COUNTER is impossible (proven, §2.2): the deb-change happens in DALOS on an EliteAuryn move that
  knows nothing of which FVTs/scores the account is in, so it cannot bump a per-FVT counter.

**⇒ Two viable shapes, owner picks:**
- **(A) Position-index table** — add `FVT|T|MemberUserIndex` (or reuse the existing `MemberUserWeight` rows, which
  are ALREADY keyed `User-ID | FVT-ID | Score-Entity-ID` and written at every stake — extend them to non-triplet
  members) so `C_InjectChecked` iterates a **bounded, point-read** position list per FVT. Scan-free, StoicSyntax-
  clean, but requires maintaining the index in **every** TF/OF/DC stake AND unstake path (insert on first stake,
  delete on full unstake). This is the "serious remodelling" — the correct long-term shape.
- **(B) `CC_`/`AA_` HEAVY full-table select** (R3 convention) — accept one full-table `select` over `RPS|User` on
  the (admin-only, daily, gas-station-paid) inject path, explicitly named `CC_InjectChecked` to flag the scan. No
  schema change; simplest to ship; cost grows with total stakers across ALL fvts (not just this one).

Given conservation already holds unconditionally (snapshot) and 2b bounds per-user staleness trustlessly, 2c is a
FAIRNESS enhancement — (B) is a legitimate pragmatic first cut (inject is infrequent + admin-paid), (A) is the clean
end state. **NOT YET BUILT pending this pick.**

### 2.5 The inject (enforced freshness) — `C_InjectChecked` + `InjectSweep` defpact
Because "is the pool fresh?" cannot be answered cheaply, the inject **proves** it by scanning: `scan-all → fix any
stale (settle-old-deb, refresh-to-live, to the REAL deb — NOT 1.0×) → re-scan → assert zero → inject`, **atomic**.
The re-scan-before-inject catches anyone who re-staled mid-operation.

- **Primary path `C_InjectChecked` (one normal tx):** on a mostly-fresh pool (everyone collected recently) the
  scan finds ~0 stale, fixes ~nothing, injects — **one enforced transaction**, the common daily case.
- **Spike fallback `InjectSweep` defpact:** when a big EliteAuryn event left more staleness than `scan + fix`
  fits in 2M gas. Each step = `scan → fix (take N, N a coded constant) → re-scan → inject-if-zero`, and relays a
  `{injected:true}` flag via `yield`/`resume` so later steps no-op. Variants tiered by **pool size** (start with
  2-step; add a bigger one only if a spike ever proves it insufficient). A defpact that ends without injecting
  (staleness > capacity) has still committed its fixes → retry converges.
- **Idempotency:** tie the inject to a `reward-injection-id` / an `injected` flag so a retry after a
  partial/abandoned sweep cannot double-inject. Fixes are naturally idempotent (refreshing a fresh score = no-op).

### 2.5.1 Scaling + self-heal — SHIPPED 2026-08-19 (#FP4.2/#FP4.3)

Two follow-ons built on top of the single-tx `CC_Inject` + the `MTX|2|C_Inject` defpact (both kept as
comparison oracles):

- **Inject CC-batch (defun+gate)** — the scalable twin of the fixed 2-step defpact, for stale sets exceeding
  one tx. No cursor needed (unlike the sweep): the stale set *shrinks* as it is fixed, so
  **`CCp_InjectFixChunk(patron, fvt, reward-dptf, chunk)`** force-refreshes up to `chunk` currently-stale users
  (penalized, same 2e as the defpact) — repeat until `URH_FvtStalePresentUsers` is empty — then
  **`CC_InjectFinalize(patron, fvt, reward-dptf, amount)`** enforces zero-stale and injects on the fresh
  divisor via the shared `XI_FvtInjectCore` (identical outcome to `CC_Inject`). Loose `INJECT-FIX-CHUNK-MAX`
  backstop. Each Talos call is its own tx (real pagination = one gas-station settlement per tx). Talos:
  `AQP-FVT|CCp_InjectFixChunk` / `AQP-FVT|CC_InjectFinalize`.
- **User self-service unstale** — **`C_UnstaleMyScores(patron, fvt-ids)`**: the caller refreshes THEIR OWN
  stale scores across the listed FVTs (settle at old deb → refresh to live → resync mirror), auth =
  `CAP_EnforceAccountOwnership(patron)`. **NON-penalized** — only inject-*forced* fixes bill the 2e count, so
  self-service is deliberately the cheap path (an incentive to self-heal proactively). The UI finds the FVT
  list via the now-interface-exposed `URC_FvtUserHasStaleMember` / `URC_FvtUserStaleMemberCount`. Single-tx,
  bounded (a user's own FVT set is small — no pagination). Talos: `AQP-FVT|C_UnstaleMyScores`.

### 2.6 Accepted residuals / limits (explicit)
- **Bounded, never zero:** staleness bounded to one settle/inject cycle (≈ a day). The un-checkpointed span pays
  at the stored deb (honest holders keep their real/high deb — **never nuked to 1.0×**; the error direction is a
  small deb-drop over-earn → absorbed by the #10 dust sweep).
- **Trustless-freshness costs O(stakers) scan per inject** (split across defpact steps on spikes). This is
  inherent — the cheap counter is impossible. Inject is daily, admin-paid, no rush (multi-block OK).
- **A few-block window** during a multi-step sweep where a mid-sweep EliteAuryn re-stales an already-fixed score.
  Tiny; not worth a global EliteAuryn lock.

### 2.7 Pact capability notes (verify before implementing the defpact)
- No unbounded loops → fixed `take N` batch per step, sized by off-chain simulation.
- **No gas introspection** in-contract → cannot dynamically size N from the previous step's cost; N is a constant.
- **No native early-terminate** in defpact → relay an `injected` flag (`yield`/`resume`); later steps no-op.
- **Verify:** `yield`/`resume` object semantics, and whether an abandoned (un-continued) pact-id is harmless for
  the next day's fresh-id inject. Also model a **stuck-pact** recovery (a half-run inject is worse than a failed
  single-tx inject; keep steps near-unfailable — pure math + point-writes, no revertable external calls).
- **CONFIRMED (2026-08-19, #FP4.3):** a `select` (e.g. the `URH_FvtStalePresentUsers` zero-stale scan) is
  **disallowed inside an `enforce` predicate** — Pact evaluates an enforce condition in read-only/sys-only mode,
  where `select` aborts with *"Operation disallowed in read-only or sys-only mode."* Compute the scan in a `let`
  first, then `enforce` on the resulting value. `CC_InjectFinalize` does exactly this.

--------------------------------------------------------------------------------
## 2.8 — Inject architecture & naming (owner-specified 2026-08-14)

### Modules & names
- **`CC_Inject`** — the single-transaction enforced-fair inject. `CC_` = R3 HEAVY (it does one `select` over the
  presence table). Lives in **AQP-FVT** (it's the FVT inject, just the checked variant). Composed in TALOS.
- **`MTX|n|C_Inject`** — the n-step **defpact** (`n` = number of steps: `MTX|2|C_Inject`, `MTX|3|C_Inject`, …),
  tiered by pool size. Lives in a **new `MTX-AQP` module**.
- **`C|n_Inject`** — the **defun wrapper** that *acquires the capability* (`with-capability`) and calls
  `MTX|n|C_Inject`. **The capability protecting the whole multistep flow sits here, at the `C|n_Inject` defun level**
  (mirrors MTX-SWP: the wrapper grants the cap, and step 0 does `require-capability`). Lives in `MTX-AQP`. Composed
  in TALOS.
- Both `CC_Inject` and `C|n_Inject` are what TALOS composes (client + gas semantics).

### New module `MTX-AQP` (model on `1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact`)
Holds ALL AQP multi-transaction (defpact) functions. Must be a full Ouronet module:
- Its **own interface** (like `SwapperMtxV3`) declaring the `C|n_Inject` client defuns.
- `(implements OuronetPolicyV1)` + the interface.
- **GOVERNANCE** block (`GOV`, `GOV|MTX-AQP_ADMIN`, `GOV|Demiurgoi`, SC-name).
- **`;;POLICY` / IMC block** ({P1}-{P4}): `P|T`/`P|MT` tables, `P|MTX-AQP|CALLER`, `P|SECURE-CALLER`
  (`compose SECURE`), `P|DT`, `P|Info`, `P|UR`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define` — copy the MTX-SWP shape so the
  module is registered in inter-module communication exactly like every other core module. **Read the `;;POLICY`
  section at the top of an existing module before wiring this.**
- FVT exposes the reusable building blocks (scan / per-user settle+refresh+mirror-resync / inject-core) as `XE_`
  entrypoints so both `CC_Inject` (FVT-local) and the `MTX|n|C_Inject` steps (cross-module from MTX-AQP) call the
  same code.

### `CC_Inject` (single tx) — scan-cut = collapses to ONE scan
Because the whole thing is atomic, no external deb change can occur mid-tx, so:
1. **scan** the FVT's present users (`URH_FvtPresentUsers`) for staleness.
2. if **none stale** → **direct inject** (nothing to fix).
3. if **stale** → **fix every stale user** (settle-at-old-deb → refresh → mirror-resync) — unbounded, one tx does all.
4. **inject.** No second scan: we fixed exactly the scanned set atomically, so zero stale is guaranteed.

### `MTX|n|C_Inject` (defpact) — the scan-cut generalised (owner-confirmed, I concur)
Naive would be scan→fix→scan-again→inject. Instead, per step, the **opening scan doubles as the pre-inject proof**:
- **each step:** `scan` → get stale count `S`; step's fix capacity = coded constant `N` (e.g. 400).
  - if `S ≤ N` → **fix all `S`, then inject** (terminal). Sound because: fixing the entire scanned set in this atomic
    step leaves **zero** stale (nothing external re-stales mid-step), so the opening `S ≤ N` scan already proves the
    post-fix state is clean — **no separate re-scan needed**.
  - if `S > N` → **fix `N`**, `yield {injected:false, …}`, continue to next step.
- Worked example (owner): step 1 scans 750, N=400 → fix 400, staleness remains → step 2. Step 2 scans ~351 ≤ 400 →
  fix all 351 → **inject** (the scan itself is the "≤ capacity ⟹ clean-after-fix" proof).
- Relay an `injected` flag via `yield`/`resume` so once a terminal step injects, later steps no-op (see §2.7).
- Tier `n` by pool size (start 2-step; add larger only if a spike ever needs it). `N` is calibration-gated (§ below).
- Across-step window: between steps (separate txs) an external deb change *can* re-stale a fixed score; each step's
  opening scan re-detects it, so convergence still holds — this is the one place a re-scan (the next step's opening
  scan) legitimately re-checks. Within a step there is never a second scan.

### IGNIS penalty (2e) still applies
Each fix increments a `forced-fix-count`; charged at the responsible party's next collect as `count × RATE`,
non-discountable (`UC_FeeDiscountAnchor` pattern), then zeroed. Orthogonal to CC_ vs MTX shape.

--------------------------------------------------------------------------------
## Shared with H4 (anchor staleness)
The staleness-compare substrate (§2.3), the checkpoint-at-settle, and the scan-fix sweep are the **same machinery** the anchor
re-score sweep (H4/#9) needs — anchors and deb are two triggers of one staleness class. Build the sweep once.

## Pre-build calibration (defpact only)
Before the defpact variants can be *coded*, we must **measure the gas of one fix** and one scan on a realistic
state, to derive `N = max fixes per 2M-gas step` (with headroom for the O(stakers) scan that shares the step).
Only then do we know how many steps each variant needs. This calibration is a required step before finalizing
the defpact shapes. It does **not** apply to `C_InjectChecked` (the single tx just folds over all found legs and
either fits or fails → fall back to defpact).

## Build order & STATUS
1. **M3 core (Part 1) — ✅ DONE (#12).** Score model + 5 score-level totals + snapshot rewards + collect refreshes
   own scores. Changed reward weights; boost-linked test values updated. golden 33/0, Z 225/0.
2. **Deb-staleness (Part 2):**
   - **2a substrate — ✅ DONE.** `URC_U-SCR|UserScoreDebStale` (point-read compare; Stage-2-only, no epoch).
   - **2b collect-backstop — 🔧 WRITTEN, DEFECTIVE, REBUILDING.** SCORE `XE_RefreshUserScoreDeb` + FVT `C_Collect`
     PHASE 6 exist, but the refresh mutates SCORE deb-score WITHOUT resyncing the FVT `total-deb-score` mirror →
     desyncs the vault/treasury divisor → breaks conservation on a *real* deb change. Passed the suites only because
     deb is static there (refresh = permanent no-op → the branch was never executed). Correct refresh must:
     settle-at-old-weight → refresh SCORE deb → **resync FVT aggregate(s)** (vault mirror ±Δdeb; farm-triplet
     contrib-weight + total-lane-weight). Needs a REPL scenario that moves Elite-DEB (EliteAuryn coil/curl).
   - **2c `C_InjectChecked` / `CC_InjectChecked` — ⏸ NOT BUILT.** Enforced-fair denominator. **Cost fact:** trustless
     per-inject freshness = full-table `select` over `FVT|T|RPS|User` (`User-ID`-leading key → `fvt-id` not
     indexable); heavier than the farm member scan.
   - **2d `InjectSweep` defpact — ⏸ NOT BUILT.** Chunked spike fallback; `take N` sized by the *Pre-build
     calibration* below (real-state gas).
   - **2e IGNIS-surcharge penalty — ⏸ NOT BUILT.** `forced-fix-count × RATE`, non-discountable, charged at collect
     and zeroed (2.4.3). Depends on 2c/2d producing the forced-fix count.
   Shares the H4 anchor sweep. #12 stays OPEN until 2b is proven (deb-moving test) and 2c–2e are built.
