# Chapter 6 — AQP, the acquisition pools

> **Source tree:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/` (13 files, 4,112 lines)
> **Audited:** 2026-08-11 → 2026-08-24, with follow-on hardening to 2026-08-30
> **Scope at the time:** 5 modules, ~15,300 lines — the largest core family in Ouronet
> **Findings:** 33 tracked rows · **Design documents produced:** 8
> **Verification pass for this chapter:** 2026-09-17.

---

## 1. What AQP is, and what breaks if it breaks

AQP is Ouronet's **staking and reward engine**. A user stakes an asset — a fungible token, an LP
token, an ortofungible, a semi-fungible or an NFT — into a *pool*; the stake is converted into a
*score*; the score becomes a *weight*; rewards injected into a *vault* are divided among weights.
That sentence hides five modules and two nested layers of RPS accounting, which is why this audit
produced more design documentation than findings.

| module | what it owns |
|---|---|
| `01_ANK` (Anchors) | *boosts*. An **anchor** says "holding this asset raises your score by N promile". Anchors group into **boost classes**; a user's holdings across a class fold into one `aggregate-promile`. |
| `02_SCORE` | the **score ledger**. Per-user and per-score-total `base`, `boost` and `deb` (Elite-DEB) columns, one write path, and the definitions that convert an asset into a weight. |
| `03_AQP` (POOL) | the **pools**: custody, the stake tracker, the rollup, and which of ≤7 scores a pool employs. |
| `04_RPS` + `05_FVT` | the **reward vaults** — Farms, Vaults and Treasuries. Two-tier RPS: Tier 1 splits an injection across *members*, Tier 2 splits a member's share across its *users*. |
| `06_VCT` (Vacate) | the **exit**: unwind every position in a pool, return every asset, zero every aggregate. |

Two structural facts drive nearly every finding.

**It is an accounting system, and accounting systems fail conservatively or catastrophically.** The
invariant that has to hold is that the sum of what everyone can claim equals what was injected. A
divisor read one instruction too early, a weight stored as a fluctuating value rather than a stable
quantity, a "last claimant takes the remainder" branch that tests the wrong thing — each of those
breaks conservation, and the symptom is either *rewards stranded forever* or *the vault drained by
whoever asks first*. Both happened.

**Gas is a correctness property here, not a performance one.** A reward settle runs on every stake,
every unstake, every collect and every inject. If its cost scales with the number of stakers in the
pool, the pool has a size beyond which nobody can transact — a denial of service that arrives by
success. Two findings (H5, M2) are scans on that hot path, and the owner's verdict on both was the
same three words: *absolute no-go.*

The reward math has a ground truth, and the audit used it: the **UrStoa RPS vault** in
`00_StoaSandbox/coin.pact` lines 1520–1940, a proven implementation of the same model. Several
findings are literally *"the port dropped a guard the model has"*. Several more, found a month later
by a different round, are the same thing again.

---

## 2. How it was audited

### The declared cycle, and the one round that did not happen

`README.md` lays out an append-only cycle: **Round I findings** (frozen) → **Round I owner feedback**
(frozen) → **Round II fixes** (sequential, one at a time, each green-lit) → **Round III re-verify**
(re-read fixed code cold, enumerate every path, prove correctness; new findings restart the cycle) →
repeat until a re-verify round is clean.

Rounds I and II happened. **`ROUND-03-REVERIFY.md` does not exist.** Like DPDC and DEMIPAD, AQP is a
two-round audit that specified a third.

This matters more here than in the sibling chapters, because Round II's fix entries are littered with
a field labelled **"Not yet covered (Round III regression)"** — a list of the regression tests each
fix *should* have and does not. Fix #7 (H1) names two. Fix #8 (H5) names two. Fix #9 (H4) names the
full negative test for its own lock. Those are not oversights; they are a deliberately maintained
backlog for a round that was never run.

### Round I

One deep-read auditor per module, five modules, ~15,300 lines. The two CRITICALs and M6 were
**lead-verified against code** before being written up, which is why `ROUND-01-FINDINGS.md` tags each
finding `[CONFIRMED]` (the lead re-read it) or `[PLAUSIBLE]` (auditor-reported, to be confirmed in a
REPL round). Three of the five HIGHs went in as PLAUSIBLE. All three were real.

The findings document also contains something the DPDC tree does not: a **"What is VERIFIED CORRECT"**
section, enumerating the invariants that were checked and hold — ANK's insert-once issuance and
idempotent aggregate recompute; SCORE's single weight-mutation path and exact `Σuser == vault-total`;
POOL's custody↔tracker↔rollup sign consistency; FVT's RPS ordering (bank at the **old** rps before the
score changes, checkpoint **after**); VCT's fully-bound TF vacate and on-chain gas ceilings. That
section is the sign-off backbone, and it is where the audit stated, of VCT, that *"discipline
[is] exemplary"*. Section 5 of this chapter records what a later round found in VCT.

### Round I feedback — where the owner changed the work

`ROUND-01-OWNER-FEEDBACK.md` is 97 lines and unusually consequential. Five findings were converted
from bugs into **StoicSyntax rules** (`R1`–`R5`) rather than fixed:

- **R1** `X-cm_` naming for `X` functions that return an IGNIS cumulator — L5 was not a bug, it was an
  unnamed convention.
- **R2** an `X` function may write more than one table — L2 dismissed.
- **R3** a `C_`/`A_` (or any dependency) that unavoidably uses a scan is **HEAVY** and must be renamed
  `CC_`/`AA_` *for instant observability*. L3 was confirmed as a principle and softened in practice:
  *avoid at all costs, never on a daily-hot path, allowed where genuinely unavoidable.*
- **R4** `X` functions returning a specific value document it in `@doc`.
- **R5** consolidate all Ouronet-specific rules into one chapter.

That is an audit changing a language convention rather than patching five call sites, and `CC_`/`AA_`
is now a load-bearing part of how the whole codebase is read.

The feedback file closes with an owner note that is the most honest thing in the tree:

> Pact is auditable by reading: a careful reader can predict failure events … from the written logic
> alone — REPL testing confirms but only catches these *if all possibilities are actually exercised*.
> **The AQP modules grew too complex to hold entirely in one human's head, which is why this audit was
> delegated.**

### Round II — 25 numbered fixes, plus the design documents

`ROUND-02-FIXES.md` is 1,057 lines and 25 entries. What distinguishes it from the DPDC tree is that
**five findings were too large to fix and produced a specification instead**. Eight design documents
live alongside the round files:

| document | what it specifies | landed? |
|---|---|---|
| `LP-SCORING-REDESIGN.md` | two-level RPS: Level-1 = stable LP **amount**, Level-2 = wrapped-STOA **value** at inject only | **partly** — the Level-1 fix shipped (Fix #7); Level-2 refinements deferred |
| `M3-DEB-DESIGN.md` | the corrected boost/deb score model + the deb-staleness subsystem | **yes** |
| `SWEEP-VACATE-DESIGN.md` | the on-chain re-score sweep that lets an employed anchor be retired | **yes** |
| `ANCHOR-STALENESS-INVENTORY.md` | the map of every place the "stale-until-restake" property bites | (an inventory, not a build) |
| `STREAMED-INJECT-DESIGN.md` | linear-vesting reward release over a duration | **yes** |
| `VACATE-V2-DESIGN.md` | "fast vacate" — separate the cheap transfer work from the expensive accounting work | **partly** |
| `FVT-SPLIT-DESIGN.md` + `FVT-SPLIT-MANIFEST.md` | split the 7,501-line FVT past StoaChain's deploy cliff | **yes** |

That is the real shape of this audit: **a third of it is architecture, not repair.** Section 6 reports
which claims in those documents are still true.

### The proof standard

The tree records green-gates at three levels: a **golden** triplet-collect suite, the fast `Z.repl`,
and — unique to AQP — `bash REPL/run-aqp-audit.sh`, a six-suite comprehensive run (comprehensive,
core-vct, deb-staleness-proof, sweep-cc, inject-cc, triplet-collect-golden) reported at **1,384
assertions**.

Running it surfaced three things worth keeping, all recorded in `README.md`:

- an **MVST double-load** regression from an ATS merge;
- a **coincidental test** (`A04`) that asserted an arbitrary-nonce stake landed a specific bunny and
  passed by luck — made deterministic by filtering on `URC_ConformNonces`;
- a measured gas fact that contradicts intuition: **NF-stake cost is O(anchors defined on the
  collectable), flat per stake** — 5-anchor stake 92,552 gas vs single-anchor 92,486, Δ 66, 0.07 %.
  *"The gas lever is how many anchors a collectable defines, not how many a given NFT hits."*

And one Pact gotcha that cost time and is worth passing on: **`select` is disallowed inside an
`enforce` predicate** (read-only/sys-only mode). Compute the scan in a `let`, enforce on the value.

---

## 3. The findings

33 tracked rows. Severity as recorded; evidence as verified 2026-09-17. Note that `04_FVT.pact` was
split into `04_RPS.pact` + `05_FVT.pact` and `05_VCT.pact` renumbered to `06_VCT.pact` after this
audit, so the audit's own file references no longer resolve.

### CRITICAL (2)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **C1** | OF/DPSF/DPNF vacate legs are not bound to staked rows — five validators defined and never wired; a pool owner could name any victim's nonce | **FIXED** | `06_VCT.pact` — all five now appear 2–4× (definition **plus** call sites): `URC_VacateOrtoLegBeneficiaryOk`, `…OrtoNoncesSufficient`, `…CollectableLegBeneficiaryOk`, `…CollectableNoncesSufficient`, `…CollectableRollupSufficient`. [VERIFIED by command] |
| **C2** | Farm inject divisor captured **before** the in-transaction ghost-TVL sync → over- or under-distribution, vault insolvency | **FIXED** | `04_RPS.pact:4477-4483` — the denominator is bound *inside* `XI_DistributeInjectAmount`, after the sync, via `URC_FarmInjectDenominatorFresh` for farms. [VERIFIED by reading] |

### HIGH (6, including one discovered mid-fix)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **H1** | LP base weight marked to market by delta with no floor → **negative base** on a full exit, poisoning the reward divisor | **FIXED** (after one reverted attempt) | `02_SCORE.pact` — LP Level-1 raw weight is `lp-amount × mx`, not a reserve-derived value. No clamp needed. See §4.2. |
| **H2** | Stake re-open ignores `vacate-in-progress` — a stake landing mid-vacate strands funds | **FIXED** | `03_AQP.pact:1694-1707` — `URC_PoolStakeAdmissionOk`'s `@doc` names the vacate guard and the audit finding; a separate unstake-direction predicate at `:1707`. [VERIFIED by reading] |
| **H3** | `finalize=true` re-enables pool-wide stake with no remaining-inventory check; LP pools have two independent streams | **FIXED** | `06_VCT.pact:536` — `(enforce (URC_PoolFullyVacated pool-id) "Finalize: pool not fully drained (nns != 0)")`. [VERIFIED by reading] |
| **H4** | Anchor revoke leaves every holder's aggregate promile stale — a dead anchor keeps paying | **TEMP-PATCHED, then completed** | Lock: `01_ANK.pact:682-685` — revoke refused while `UR_BC|ScoreLinkCount > 0`. Unwind: `05_FVT.pact:3092` `CC_SweepRevokeAnchor` + `:3142` paginated twin → `01_ANK.pact:2158` `XE_SweepRevokeAnchor`; decrement at `:131` `XE_UnbumpBoostClassScoreLinks`. **Both halves live.** [VERIFIED by reading] |
| **H5** | Triplet Tier-2 divisor runs an unbounded `select` on the hot path — O(stakers) per stake/collect/inject | **FIXED** | `04_RPS.pact:431` `total-lane-weight` (the maintained divisor) and `:386` `contrib-weight` (the matching per-user snapshot); `URD_UserScoreStakerAccounts` deleted from SCORE. [VERIFIED by reading] |
| **S4** | *(surfaced by H5)* triplet reward math branches on **FVT class** instead of the true-triplet flag → numerator/divisor basis mismatch | **FIXED** | Branches on `UR_SCR|TripletTrueTriplet` (any class): true → lanes, non-true → Σ-deb. |

### MEDIUM (7)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **M1** | `unclaimed-count == 1` dust sweep never implemented — residual locked in the vault | **DONE** | Two-tier dual sweep built (`FVT|T|MemberVault` + global). **Later found exploitable — see §5.1.** |
| **M2** | Vault/treasury inject denominator runs a `keys` scan **inside a defcap** — cross-tenant gas coupling | **DONE** | `URD_FvtScoreEntityLinkKeysForFvt` gone; the divisor point-reads a maintained `total-deb-score` mirror (`02_SCORE.pact:411`). [VERIFIED by command — 0 hits for the deleted reader] |
| **M3** | A boost-class link with aggregate promile < 1000 **zeroes** rewards — adding a boost reduces effective weight to 0 | **DONE** | `02_SCORE.pact:2455/2464/2471` — boost is now the **additive part** (`base × promile/1000`), not a replacement, with the comment *"M3: boost is ADDITIVE"*. [VERIFIED by reading] |
| **M4** | Boost-class / boost / deb-boost links settable **after** positions exist → previously-staked base erased | **DONE** | `02_SCORE.pact:777`, `:933`, `:968` — all three caps enforce `nzs-count = 0`, message *"vacate to reconfigure"*. [VERIFIED by reading] |
| **M5** | OF/collectable unstake recovers the beneficiary from a **self key** while stake writes a caller-supplied one → non-self stakes unrecoverable | **DONE** | `03_AQP.pact:1773/1808/1847` — *"beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation"*; both self-key readers deleted. [VERIFIED by command] |
| **M6** | TF anchor promile is pro-rated; the README documents a whole-step model with a 1000 cap | **DOC-FIX + new guard** | Code was right. `01_ANK.pact:1617-1619` `UEV_Promile` — precision exactly 3, promile in `[1, 10000]`. [VERIFIED by reading] |
| **M7** | *(ATSU)* `C_Coil`/`C_Curl` revert when a tiny input's pool-index conversion rounds below token precision | **REFUTED — by design** | A precision artefact; amounts within ~1 ulp of maximum precision are unusable for Coil/Curl by design. |

### LOW (10)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **L1** | An `enforce` inside a `URC_` | **DONE — and the whole check was tautological** | `03_AQP.pact:721` records the deletion: `DPOF::C_Transfer` moves *whole* nonces and ignores amounts, and callers sourced `nonce-amounts` from the very reader the check compared against. [VERIFIED by reading] |
| **L2** | One `X` function writes two tables | **CONVENTION R2** — allowed |
| **L3** | `select`/`URD` on a sync path | **CONVENTION R3** — `CC_`/`AA_` rename |
| **L4** | `ANK|C>REVOKE` has no liveness gate; `UEV_LiveAnchor` exists and is unused | **DONE** | `01_ANK.pact:679` — `(UEV_LiveAnchor anchor-id)` is the first form in the capability. **The validator itself was later found mute — see §5.2.** [VERIFIED by reading] |
| **L5** | `XE_` returns an `OutputCumulator` | **CONVENTION R1** |
| **L6** | SF/NF incremental promile has no floor → negative promile | **DONE** | `01_ANK.pact:1815-1824` — floored at the `WW_Anchors` write chokepoint, the sole write path for TF/SF/NF, incremental and absolute. [VERIFIED by reading] |
| **L7** | Negative score weight | **DONE** — after a **wrong** first close. See §4.5 | `02_SCORE.pact:2116-2133` (clamp at source), `:841` (definition validators), `10_DPDC-N.pact` `UEV_Score` tightened. [VERIFIED by reading] |
| **L8** | Trailing non-write `X` returns | **CONVENTION R4** — allowed, document in `@doc` |
| **L9** | Dead `VACATE-MAX-LEGS = 16` + an unused parity helper | **DEFERRED, then removed** | Both gone. [VERIFIED by command — 0 hits tree-wide] |
| **L10** | `CC_Collect` settles the member Tier-2 twice | **DONE** | Already resolved by M3's redesign; three orphaned functions deleted. [VERIFIED by command — `XI_CollectRpsPreScore`, `XI_1|CollectSettleAndBank`, `URDC_BuildCollectScorePlan` all absent] |

### New findings raised during Round II (2)

| id | summary | verdict |
|---|---|---|
| **N1** | The comprehensive suite's "negative payout" and "over-accumulate" failures | **RESOLVED — no core bug, three *test-layer* defects**: a driver double-loading a suite that self-loads, two assertions testing an absolute value where a delta was meant, and one coincidental pass |
| **N2** | The enforced-fresh inject was excluded from farms on an incomplete rationale | **DONE** — the `class ≠ 0` guard's reasoning (*"farms use a fresh denominator"*) covered only the farm Tier-1 `S`; the Tier-2 `L_i` divisor is stale-able for singular and non-true-triplet members, which a **mosaic farm** hits |

### The vacate rehaul's own findings (6)

Raised by an owner-requested adversarial review *after* the single-transaction agnostic vacate shipped.
They sit inside H4 phase 4 and change no verdict above.

| id | sev | summary | verdict | evidence today |
|---|---|---|---|---|
| **V1** | CRIT | `CC_FullVacate` orphans the class-0 `Z\|` sleeping-LP satellite (satellites wrongly gated to `class == 1`) | **FIXED** | `06_VCT.pact:1569-1574` `URC_VacatePoolOfIds` — class 0 → `Z\|`, class 1 → `Z\|` **and** `H\|`. [VERIFIED by reading] |
| **V2** | HIGH | `CC_FullVacate` orphans the `F\|` frozen-TF lane (the scan was native-only) | **FIXED** | `06_VCT.pact:1551-1567` `URC_VacatePoolTfIds` — native asset-id **plus** its `F\|` counterpart when one exists. [VERIFIED by reading] |
| **V3** | CRIT | An empty scan aborts the whole vacate (`enumerate 0 -1` → out of bounds; a `0.0` TF debit → `UEV_Amount`) → satellite-only or empty pools unvacatable | **FIXED** | Empty-guards no-op each lane; pinned `[6.2.5]` `TX-VCT-CC02`. |
| **V4** | HIGH | The multi-transaction `C_Vacate*Legs` path is **not parallel-safe** — per-leg unwind writes shared Tier-2 aggregates, so two disjoint slices write-conflict | **OPEN at the time — since SHIPPED** | `06_VCT.pact:71-76` `CCp_BatchVacate{TrueFungible,OrtoFungible,Collectables}` — the begin → parallel drain → finalize shape. [VERIFIED by reading] |
| **V5** | LOW | Collectable amount uses `round` where `floor` was proven | **FIXED** | |
| **V6** | — | `VCT\|C>VACATE` drops the `R\|` reserved-asset gate | **REFUTED** | The stake path already rejects `R\|` legs, so no `R\|` stake row can exist to vacate. `UEV_TrueFungibleStakeNotReserved` remains at `06_VCT.pact:2230`. [VERIFIED by reading] |

---

## 4. Seven findings worth the retelling

### 4.1 C1 — five validators, written, correct, and connected to nothing

The TF vacate path binds every leg to a real staked row: `URC_VacateTfLegsOk` →
`URC_VacateTfLegBalancesOk` enforces `amount > 0`, `amount == staked-bal(owner, beneficiary)`, and
`rollup-bal >= amount`. The OF and collectable paths validate only that the asset matches the pool,
that the arrays are the same length, that the gas and nonce totals are under the ceiling, and that the
caller owns the pool.

**Nothing tied the supplied `owner-ids` / `beneficiary-ids` / `nonces` to any actual staked row.**

The five validators that would have closed it existed. The auditor found them by counting
occurrences: each appeared **exactly once** in the file — the definition — against the TF validator's
two. A defined-and-never-called function is invisible to every kind of review except a call-graph
count, and it looks *more* reassuring than an absent one, because grep finds it.

The exploit is fund theft by the pool owner, and the shape is worth spelling out because it is not the
obvious one. The OF vault transfer is **whole-nonce and receiver-directed**: the pool owner signs a
vacate with `owner-ids = [attacker]` and `nonces = [[victim's staked nonce]]`. The amount resolver
reads the *attacker's* empty tracker key and returns `[[0.0]]`. Every check passes, because every
check is about shape. The bulk transfer then moves the **victim's** whole nonce from the vault to the
attacker, and the unwind — at amount `0` — leaves the victim's tracker, score and RPS position
completely intact. Stolen inventory plus pool insolvency at the next honest unstake.

DPSF and DPNF are worse: the amount is caller-controlled and the balance write has no `>= 0` floor and
no sufficiency check on the vacate path.

The fix is exactly what the finding said: wire the five, as TF already does.

**Verified 2026-09-17** by the same method that found it — an occurrence count. All five now appear
2–4 times in `06_VCT.pact`, and `URC_VacateTfLegsOk` still appears twice. [VERIFIED by command]

### 4.2 H1 — the fix that broke the exit, and the redesign that replaced it

The finding: an LP position's **value** — its lp-denominator equivalent at *current* SWP reserves — is
stored as the user's persistent base score, and reversed on unstake at the *then*-current reserves.
Stake 1,000 LP when it is worth 100; reserves drift so it is worth 105; unstake and the base goes to
**−5** after a full exit that should be 0. FVT then reads that as a Tier-2 weight — a negative in the
reward divisor.

**Attempt 1 was the obvious one and it was wrong.** Clamp the base at 0. It broke three DPNF vacate
assertions immediately, and instrumenting the base explained why: the DPNF vacate legitimately drives
base **transiently negative and then corrects it** in a later step. A per-step clamp destroyed the
correction, and the pool never registered as fully vacated. Reverted.

The lesson the fix entry records is the transferable part:

> A blanket floor cannot distinguish a *final* bad negative (LP) from a *transient* legitimate one
> (DPNF).

Three readers then went at the architecture rather than the symptom, producing
`LP-SCORING-REDESIGN.md`. The diagnosis is a **category error**: an LP token has no fixed value — it
is a claim on two fluctuating reserves — and the code stored a fluctuating quantity as if it were
fixed.

The intended design is a **two-level RPS**:

- **Level 1, within one LP family.** All LP tokens of a family are fungible, so the user's stored score
  is **LP amount × mx** (the frozen/sleeping variants simply count as more or less amount). Stable. A
  full unstake nets to exactly 0 **by construction** — no clamp required.
- **Level 2, across families.** Each FVT entity's weight is its current wrapped-STOA value, computed
  **only at inject time** to split *that* injection, and **never persisted as anyone's score**.

The striking result of the study is that FVT's Level-2 side **already did this correctly**
(`ghost-tvl-weight = SWP::UR_StoaValue`, consumed transiently at inject). The bug was one decision in
one module: SCORE storing value at Level 1.

The corrected fix is three lines and no schema change: two raw-weight expressions switch from
`equiv(reserves) × mx` to `amount × mx`, and the now-callerless
`URC_LpAmountToLpDenominatorEquivalent` is retired. The shared delta path is untouched, so DPNF's
legitimate transient negatives survive.

**Verified 2026-09-17:** the LP Level-1 weight is amount-based. [VERIFIED by reading]

**Still open, and recorded as such in the design document:** whether Level 2 should split by
*whole-pool TVL* (what it does) or by *staked value*; and whether FVT's Level-2 persist-and-sync
should become fully transient. Both are gas/purity questions, not correctness ones — the C2 fix
already makes the current shape conserve.

### 4.3 H5 — deleting a scan without breaking conservation

`URC_FarmTripletTier1Denominator` ran a full `select` over `SCR|T|UserScore`, mapped over **every**
staker in the pool, and re-derived each staker's lane weight **live** — on every stake, every collect
and every inject touching a triplet farm member. O(stakers) on the hot path, and the owner's verdict
was *absolute no-go*.

Replacing a scan with a cached number is where reward systems get quietly broken, because the
numerator and the divisor must always come from the **same basis**. Cache the divisor and keep a live
numerator and you have created a slow leak.

The design is careful about exactly that. The farm triplet was the **only** score-entity that
recomputed live; singular scores and vault triplets already point-read maintained totals. So:

- each user's lane weight is **stored** as `contrib-weight` in a new `FVT|T|MemberUserWeight` table;
- the per-member sum is **maintained** as `total-lane-weight` on the `ScoreEntityLink` row;
- the **numerator** switches from live derivation to the stored `contrib-weight`;
- the **divisor** switches from the scan to a point read of `total-lane-weight`;
- a new `XI_SyncFarmTripletLaneWeights` at **phase 4.6** advances both by delta — placed after the
  existing phase-4.5 mirror sync, mirroring its read-old-at-2.3 / write-after-SCORE ordering.

The conservation argument is structural rather than empirical: at stake, phase 2.3 banks the user's
pending at the **old** stored contribution and settles against the **old** stored total — both before
4.6 — and 4.6 then advances both together. Numerator and divisor always share one snapshot, so
`Σ contrib-weight ≡ total-lane-weight` **by construction**.

`URD_UserScoreStakerAccounts` was then deleted from SCORE entirely, which is the part that makes this
a real fix rather than a faster path: the scan cannot come back by accident.

The proof asserts the invariant directly rather than a total: at `[6.4]_AQP-TRIPLET-COLLECT`
`<<TX-AQP-CL04>>`, ANHD has `w-user = 10`, EMMA has `w-user = 4`, and the **maintained divisor reads
14**.

The cost is honestly stated: the farm triplet now accepts the same **eventual consistency** as every
other deb-based score — a user's weight is a snapshot from their last stake, stale until they restake.
That property was already system-wide, and cataloguing it is what produced
`ANCHOR-STALENESS-INVENTORY.md`.

**Verified 2026-09-17:** `04_RPS.pact:431` and `:386`; the deleted reader has zero hits.
[VERIFIED by command]

### 4.4 H4 — the fix that admits it is temporary, in the source

Revoking an anchor deactivates it and strips it from the boost-class and asset bookkeeping. It never
decrements any holder's stored `aggregate-promile`, and it never zeroes the per-user anchor promile.
SCORE reads the stored aggregate directly. **So a revoked anchor keeps paying its boost** until each
user happens to trigger an update on some *other* live anchor in the same class.

There is no O(1) correction. You cannot enumerate 10,000 holders on revoke. The owner offered two
directions: **(A)** a lazy method that is still mathematically correct, or **(B)** disallow revoking an
anchor used by ≥1 score — to truly revoke, first flush all stakers through Vacate.

**B was chosen, and only half of B was built.** Fix #9 is the lock: a new `ANK|T|BoostClassLinkCount`
table (forced onto ANK by deploy order — ANK deploys before SCORE and cannot read it at revoke time),
incremented by SCORE at the single link-creation site through a forward entrypoint, and enforced in
`ANK|C>REVOKE`. The other half — freeze, run an on-chain re-score sweep, unlink, then revoke — did not
exist.

The consequence is stated bluntly in the inventory and in the fix entry: **once a boost-class is
linked to a score, its anchors are locked forever.** Intentionally conservative. Safe, and stricter
than the final design.

This is the right way to ship half a fix: the lock is correct on its own, the gap is named in two
documents and in the source, and the constraint it imposes is described in terms of user-visible
behaviour rather than internal state.

**The other half has since landed**, which neither document records. `CC_SweepRevokeAnchor`
(`05_FVT.pact:3092`) is the single-transaction re-score sweep, with a paginated defun+gate twin at
`:3142` for sets that exceed one transaction; both terminate in `ANK::XE_SweepRevokeAnchor`
(`01_ANK.pact:2158`), whose capability deliberately enforces liveness and ownership but **not** the
`#9` link lock — *"the sweep has already refreshed every affected holder, so no staleness remains"*.
The decrement exists as `XE_UnbumpBoostClassScoreLinks`. [VERIFIED by reading]

`ANCHOR-STALENESS-INVENTORY.md` still says **"NOT BUILT YET."** See §6.

### 4.5 L7 — the audit closed it as a misdiagnosis, and the close was the misdiagnosis

This one is included because it is the only finding in Part I where the audit **wrote a formal "no
fix, the finding's premise is wrong" entry and then had to supersede it**, and both entries are still
in the file.

L7 reported that negative score weight was reachable. The obvious fix — floor the base-delta
chokepoint at 0, the analogue of L6's fix — broke three DPNF vacate assertions. Instrumenting the base
showed the probe stakes an NFT whose trait-score definition is **−1**: on stake the user base goes to
−1, on unstake back to 0, a correct round trip. The auditor concluded that **SCORE base is a sum of
trait-score values, trait scores can be negative by design** (a trait that *reduces* weight), and
therefore a negative user base is legitimate. Fix #19 was written as `NO FIX — misdiagnosis`, with a
careful L6-versus-L7 distinction:

> #18's floor was correct because ANK promile is `count × ank-promile` with `ank-promile ∈ [1,10000]`
> and `count ≥ 0` ⇒ promile is always ≥ 0 … SCORE base has no such lower bound, so the same floor
> corrupts valid data. **Before flooring any accumulator, confirm the negative is actually invalid.**

That is good reasoning from a false premise. **The owner flagged that negative scores are not a
designed feature**, which forced a trace of where the −1 actually came from.

It came from DPDC. The probe mints a **metadata-less** nonce, and `UDC_NoMetaData → UDC_MetaData {} →
UDC_NonceMetaData -1.0` defaults an unscored nonce's native score to the **`-1.0` unscored sentinel**.
SCORE's model-0 weight path read the **raw** score and counted the sentinel as a real negative. DPDC's
*cooked* reader already maps `-1.0 → 0` — and the weight path bypassed it. Compounding it, DPDC's
`UEV_Score` enforced only `>= -1.0`, so genuine negatives in `[-1.0, 0)` were settable too.

The corrected fix is at the source, in three places, with no aggregate floor anywhere: clamp each
per-nonce native score at the model-0 weight reader; make the SF and NF definition validators enforce
`score >= 0` so negatives cannot be authored; and tighten DPDC's `UEV_Score` to
`(or (= score -1.0) (>= score 0.0))` — the exact sentinel, or a non-negative value, and nothing
between.

**Three things make this the most instructive entry in the tree.** The wrong close was *carefully
argued*, and its careful argument is what made it convincing. It was caught by the owner contradicting
a premise, not by any test — the suite was green under both closes. And the audit **kept the wrong
entry in the file**, marked superseded, rather than editing it away. A correction with the error
deleted teaches nobody anything.

There is a fourth thing. This is the **same `-1.0` DPDC sentinel** that DPDC's own audit found leaking
through three of four branches of `UR_N|Score` (#19H, {{ch:dpdc}} §4.6), found independently, in a
different module, by a different team, weeks apart. And DPDC's finding notes that *a sibling audit
(AQP) had already committed a false "already fixed" assumption about this exact function to its own
audit trail.* One sentinel, two audits, three wrong conclusions between them.

**Verified 2026-09-17:** `02_SCORE.pact:2116-2133` carries the clamp and the `L7 #19` reference; the
definition validators are at `:841`. [VERIFIED by reading]

### 4.6 M3 — the footgun where adding a boost removed your rewards

`nominal-boosted = floor(base × promile/1000, p)`, where `promile` is the user's aggregate across the
boost class and **defaults to 0.0** with no 1000 baseline.

Link a boost class and hold none of its anchors, and `boosted = deb = 0`. A real stake earns
**nothing**. Adding a boost class *reduced* effective weight to zero. The code matched the README
formula literally, which is what made it survive.

The owner's model, locked in `M3-DEB-DESIGN.md`, is that boost is a **bonus, not a replacement**:

- **boost-part** = `base × promile/1000`
- **pre-deb total** = `base + boost-part`
- **deb** (Elite-DEB) is an **end multiplier on the sum**, `final = (base + boost) × deb`, and is
  always ≥ 1.0

The last of those was not obvious and the document records why it is necessary: a **base-0,
boost-N** score — a pure-boost position, which the triplet case produces — would vanish entirely under
a deb applied to base only.

The consequence is five stored score-level totals rather than two, because the two post-deb totals are
**not derivable** from the pre-deb ones (deb is per-user): `total-base`, `total-boost`,
`total-base-deb`, `total-boost-deb`, and `total-deb-score` — the reward denominator. At user level,
store two and derive three.

The design then grew a whole subsystem, because a per-user `deb` that can change means a stored
`deb-score` can go **stale**, and a stale numerator against a fresh divisor breaks conservation. Part
2 is the deb-staleness architecture: a staleness detector, a collect-time backstop, an enforced-fresh
inject, a chunked fallback for spikes, and an IGNIS surcharge so a user who forces someone else's
inject to fix their staleness pays for it.

**Verified 2026-09-17:** the additive model is live at `02_SCORE.pact:2455-2471`, the five totals at
`:411-413`. [VERIFIED by reading]

**And 2b was found defective by the audit itself, in writing.** `M3-DEB-DESIGN.md` records the
collect-time backstop as *"WRITTEN, DEFECTIVE, REBUILDING"*: the refresh mutated SCORE's `deb-score`
**without resyncing FVT's `total-deb-score` mirror**, desyncing the divisor and breaking conservation
on a real deb change. The sentence explaining why the suites stayed green is the best one-line summary
of this entire audit's method:

> Passed the suites only because deb is static there (refresh = permanent no-op → the branch was never
> executed).

### 4.7 L1 — the misplaced `enforce` that was not a misplaced `enforce`

Reported as discipline: `URC_OrtoStakeWholeNonceAmounts` contains an `enforce`, and a `URC_` must not.
Move it to a `UEV_` or return a bool. A ten-minute fix.

Investigating it found that the **whole check was tautological**. `DPOF::C_Transfer` moves *whole*
nonces and ignores the amounts array entirely, and every caller sourced `nonce-amounts` from
`UR_NoncesSupplies` — so the check compared a value against its own source. It could not fail.

The helper was deleted rather than relocated.

This is the pattern the codebase later named and hunted systematically:
`DEFECT-LEDGER.md` §1.2.3 catalogues **tautologies and key-echo checks** — `G-30` in this same
`02_SCORE.pact`, where one word in a reader name (`UR_AccountNoncesSupplies` versus
`UR_NoncesSupplies`) is the entire difference between a live guard and a dead one, *and the two
enforces look identical at the site*; and `G-31`, two VCT beneficiary checks where the beneficiary is
a **component of the lookup key** and the reader is a `with-default-read` whose default is built from
that key, so the function cannot return false in either direction.

L1 is the first instance in the programme of a class that turned out to be common. A prefix violation
is often a **symptom**: the check is in the wrong place because nobody could work out what it was
for — including, sometimes, its author.

---

## 5. What later rounds found in AQP

### 5.1 M1 — the audit built the dust sweep, and wrote the test that hid the bug

M1 reported that the `unclaimed-count == 1` full-supply branch from the canonical vault was never
implemented in AQP, so residual dust accumulated locked in the vault. Fix #10 built it, as a **dual**
sweep: per-member Tier 1 plus global Tier 2, the mathematically complete port extended to both tiers.
It shipped drain-proof green.

The fix entry states its own verification target:

> a wind-down test — last user in a member sweeps `member.available`; last user globally sweeps the
> Tier-2 remainder; **both vaults drain to exactly 0**.

And it states the decrement condition it implemented:

> Collect decrement added to `XI_1|BookCollectUnclaimed` at the same `deb == 0` condition.

On 2026-09-14 the red-team round found both of those sentences to be the defect. `DEFECT-LEDGER.md`
§1.1d records it as **GS-08** and **GS-09**, and the owner asked the question that found it: *"the
audit of the STOA ICO allegedly fixed the dust sweep following the canonical model of the coin module
— can we verify this? because if this is incorrect, the implementation in the AQP module also might be
off."*

**GS-08.** `URC_CollectClaimableRewards` branched on **counters alone**:

```pact
(if (= gc 1) (UR_FVT-RG|AvailableRewards ...)             ;; the WHOLE global vault
  (if (and (= (UR_FVT|FvtClass fvt-id) 0) (= mc 1))
      (UR_FVT-MV|AvailableRewards ...)                    ;; the WHOLE member vault
      (URC_UserTier1AvailableRewards ... deb-user)))
```

`gc` is a property of the **vault**; `mc` of the **member**. `deb-user` — the one value identifying
the caller — is bound one line above and used **only in the else-branch**. Measured on the deployed
stack, driving `[6.4]_AQP-TRIPLET-COLLECT` to its wind-down with ANHD the sole real claimant
(`deb = 10.0`) and EMMA fully exited (`deb = 0.0`):

```
gc=1   emma-claimable == anhd-claimable      <- the reader could not tell them apart
EMMA (exited) collected the sweep, vault -> 0
ANHD (rightful sole claimant) gained 0.0
```

`UEV_CollectContext` checks pool, FVT, link and ownership, and never that the caller is a staker, holds
a claim, or has already collected. And `gc == 1` is a **normal end-of-life state**, not an attack
precondition.

**GS-09**, exposed by fixing GS-08. With the reader corrected, ANHD received 0 and the dust was
*stranded* — because `XI_1|BookCollectUnclaimed` decremented on `deb == 0` alone, with no check that
the caller had ever been counted. A zero-weight account decremented the counter **for somebody else**,
once per call, for the price of gas. Enough calls and `gc` reaches 1 while honest stakers are still
staked, re-arming GS-08 against them. *Fixing GS-08 alone converts theft into a fund-lock; the two must
be fixed together.*

**Why the suite was green through both.** The audit's own assertions checked that the vault **drained**
(`ar-final` → 0). The ledger's sentence:

> **Conservation is satisfied whether the money reaches the rightful claimant or someone who just
> left.**
>
> A test that asserts an outcome does not assert who caused it.

Both are ports of the Stoa `coin` UrStoa vault — the AQP comments still name the steps
(*"coin step 1"*, *"coin step 2"*). `coin` is correct: its guard is
`(and (= unclaimed-count 1) (> available 0.0))`, and its own repair is preserved in
`genesis/stoa-genesis-4.pact` with the pre-fix version commented out immediately above. **The caller
conjunct was dropped in the copy — in AQP and, separately, in STOAICO ({{ch:demipad}} §5).**

The second dropped guard is the subtler one and it caused GS-09. In `coin`, a zero-amount payout
**aborts** at step 1 (`C_Transmit` → `UEV_Amount`). AQP turned that abort into a **skip**
(`(if (<= payout 0.0) (UC_EmptyOc) …)`). That reads like making a no-op graceful; it exposed a write
three steps downstream.

> **A guard can be load-bearing for code it does not mention.** Removing an abort relaxes everything
> sequenced after it.

**Both fixed and verified 2026-09-17.** `04_RPS.pact:1891` and `:1894` now read
`(and (= gc 1) (> deb-user 0.0))` and `(fold (and) true [(= class 0) (= mc 1) (> deb-user 0.0)])`
respectively, with a 25-line source comment carrying the measurement. `XI_1|BookCollectUnclaimed`
additionally requires unsettled `pending`, and PHASE 3 was resequenced before PHASE 2 so that value is
still readable. Pinned by `[6.4]_AQP-TRIPLET-COLLECT` `<<TX-AQP-CL04>>`, seven assertions — including
the two a careless repair would break: the rightful claimant must still sweep, **and** the vault must
still drain to 0. Returning `0.0` to everyone satisfies "the non-claimant gets nothing" while
destroying the sweep. [VERIFIED by reading]

A codebase-wide scan for the shape — *a branch on `(= <counter> 1)` selecting a whole-balance reader* —
returned **10 sites, and every live one is now guarded.** `06_VCT.pact` has no sweep branch at all;
`05_FVT.pact` is a facade delegating to RPS, so the RPS repair covers it.

### 5.2 L4 — the audit wired in a validator that could never speak

Fix #17 closed L4 by adding `(UEV_LiveAnchor anchor-id)` as the first check in `ANK|C>REVOKE`. The
validator already existed and was unused; wiring it in means a double-revoke aborts cleanly at the top
instead of deep inside a list utility. Correct fix, correct placement, proven at `[6.2.1]` TX002·06b.

**RT-K-007** found that `UEV_LiveAnchor` had never been able to deliver its own message.

```pact
(defun UEV_LiveAnchor (anchor-id:string)
  (let ((iz-anchor-active:bool (UR_ANK|State anchor-id)))
    (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))))
```

`UR_ANK|State` was a bare `read`. Pact evaluates `let` bindings before the body, so for the one input
that most needs the message — an anchor that does not exist — the raw table error
`No value found in table … ANK|T|Anchor for key: <id>` fired **one line earlier, every time.**

The ledger records this as the **third instance of one shape and the first where the obstruction was a
READER rather than an eager `let` in the caller**. `C_Recover` and `C_HotRecovery` had their capability
below the bindings; `C_DeployAccount` had its check below the bindings; here the check sits in exactly
the right place and *the value it reads raises before it can be tested*.

> **A guard being present is not a guard being reachable, and `grep` cannot tell the two apart.**

Fixed by defaulting `UR_ANK|State` — an anchor that does not exist is not active, which is what both
callers mean by the question. The source comment at `01_ANK.pact:1055-1066` records the whole thing,
including the DPTF precedent it follows. [VERIFIED by reading]

**And it exposed a test that was vacuous about the gate it named.**
`[6.2.10]_AQP-NEGATIVES.repl` `<<TX-AQP-NEG-OWNER2>>` was labelled *"anchor-owner gate"* while
actually pinning the raw missing-row error, because its `anchor-id` was derived from a block hash and
no such anchor had ever existed. **Delete the owner gate and the line would still have passed.**
RT-K-007 surfaced it by changing the message it was matching. It now pins the **liveness** gate, which
is what that input actually tests.

### 5.3 Six more mute guards in AQP, and the count is the finding

`DEFECT-LEDGER.md` §1.2 catalogues the guard-reachability class across the codebase. AQP holds a
disproportionate share, and several sit directly on top of this audit's work:

- **G-09** `05_FVT.pact` `UEV_AddScoreEntityTripletContext` — *"Triplet must be issued in AQP-SCORE"*
  was dead until 2026-09-10: the `let` hard-read the triplet table **five times**, even though
  `URC_TripletExists` is a `with-default-read` written specifically to answer for a missing row.
- **G-13** `06_VCT.pact` `TRUE-FUNGIBLE-VACATE-BATCH` — **a guard that knew and had no voice.**
  `(gas-ok (URC_TfOwnerArraysGasOk …))` correctly computes `false` for an empty batch, but the sibling
  binding `(legs (UC_TfLegsFromParallelArrays …))` faults first. The asymmetry proves intent: the Orto
  and Collectable leg builders already guard `(if (> l 0) …)`; the TF one did not.
- **G-15 / G-16** `04_RPS.pact` — sub-shape **C**, the one an audit for the other two walks straight
  past: a later conjunct of a `fold (and)` hard-reads the value an earlier conjunct is validating.
  `(fold (and) true)` **does not short-circuit** (verified directly), so passing `BAR` — the exact case
  the first conjunct exists to reject — aborts on key `|`. *The cheap check IS first; the ordering IS
  right; the code looks correct.*
- **G-20 / G-21 / G-37 … G-41** — seven sites in `02_SCORE.pact`, `03_AQP.pact` and `05_FVT.pact` whose
  messages claim *"score must exist"* while the bindings above them bare-read the score row.

The last group carries the most useful methodological point in the ledger. **G-20 and G-21 were found
by hand and recorded as two sites. The class is seven**, and five were invisible because the
instrument reading them truncated its window at 300 characters and the messages sat past it. One of
the five is the direct twin of an already-ledgered site in the same file — *which is the strongest
available evidence that hand-finding had been sampling this class, not enumerating it.*

### 5.4 The owner gates that had never refused anybody

`DEFECT-LEDGER.md` §7.2h asked a measurable question: **which owner-ownership capabilities has no test
ever shown refusing anybody?** Four AQP gates sit behind a **latched** flag — once false it is
irreversible, so the gate behind it is permanently unreachable for that entity. Exactly one had ever
been reached by a non-owner:

| defcap | shadowing enforce | non-owner test before 2026-09-16 |
|---|---|---|
| `FVT\|C>CONTROL-FVT` | `can-upgrade` | **yes** |
| `SCR\|C>CONTROL-SCORE` | `can-upgrade` | none |
| `FVT\|C>ROTATE-OWNERSHIP-FVT` | `can-change-owner` ∧ distinct | none |
| `SCR\|C>ROTATE-OWNERSHIP-SCORE` | `can-change-owner` ∧ distinct | none |

Every `expect-failure` on the latter three signed **as the owner**, so their
`CAP_EnforceAccountOwnership` had never once been shown refusing anybody.

The remedy is worth reading because the obvious one is wrong. The 2026-09-14 owner ruling says
authorisation precedes validation inside a `defcap`, and a naive reading says hoist all of them. **Two
AQP suites deliberately depend on the current order** to reach an argument guard *without a
signature* — `[6.2.10]` `TX-AQP-NEG-SCRCTL` and `[6.4]` `<<TX-AQP-FA01>>`. Hoisting the ownership gate
there would make the *distinctness* clause unreachable instead: one unobservable guard traded for
another.

> **Ordering can expose only ONE of two state-dependent guards at a time. A fixture that satisfies the
> first guard exposes BOTH.**

Closed **additively** in `<<TX-AQP-NEG-OWNER2>>`, using fixtures whose latched flag is still `true` so
ownership is the only thing left that can refuse — and, for rotation, passing a foreign account as the
*new* owner, so distinctness is satisfied by the same fact that makes her a non-owner. Each refusal is
preceded by an `expect` pinning the flag it depends on, so a future suite that latches a flag early
turns the **precondition** red rather than letting the refusal go quietly vacuous.

### 5.5 A bare-called `defcap` that silently no-opped the entire vacate owner gate

Not in either ledger — recorded only in the source, at `06_VCT.pact:2214`:

> `CAP_VctVacatePoolOwner` … MUST be a defun (not a defcap): every `VCT|C>*` vacate/abort cap calls it
> BARE — `(CAP_VctVacatePoolOwner pool-id)` — as an inline enforce. **A defcap bare-called that way
> does NOT run its body**, which silently no-opped the owner gate on the WHOLE vacate surface
> (`CC_FullVacate` / `XB_Vacate*` / `Cp_BatchVacate*` / `C_AbortVacate`) — any non-owner could vacate
> or abort.

It is a `defun` today and the enforce runs [VERIFIED by reading]. Round I's finding C1 was about
*which legs* a pool owner may vacate; this was about **whether the caller had to be the pool owner at
all**, across every entry point in the module — and it is in the module Round I signed off as
*"discipline exemplary"*.

This chapter did **not** establish when the defcap-versus-defun shape was introduced, or whether it
predated the audit. `git log -S` on the current definition returns only the file-renumbering commit
from the FVT split, which tells us nothing about the earlier form. *(not verified)*

---

## 6. What remains open

### The design documents: what landed

Each of these was checked against current source on 2026-09-17.

| design | claim | status today |
|---|---|---|
| **FVT split** (`FVT-SPLIT-DESIGN.md`, `-MANIFEST.md`) | `04_FVT.pact` at 7,501 lines is **past StoaChain's deploy cliff** (~6,635 lines, because the size charge grows as the **7th power** of transaction size against a 2,000,000-gas block limit). Split into `RPS` + `FVT` along the capability seam. | **SHIPPED.** `04_RPS.pact` and `05_FVT.pact` both exist; RPS owns the 7 reward tables and its own `SECURE`; FVT is a facade (`URC_InjectDenominator` at `05_FVT.pact:3769` delegates to `RPS`). The manifest's key result — *"0 functions directly touch both domains"* — is what made the seam clean. [VERIFIED by reading] The design document's own footer still reads *"awaiting owner GO to start P1"*; the manifest's does not. |
| **Streamed inject** (`STREAMED-INJECT-DESIGN.md`) | rewards may vest linearly over a duration; late stakers earn the portion released after they join; independent overlapping streams, no merge; slots capped by the owner's Elite tier | **SHIPPED.** `FVT|RPS|Stream` schema at `04_RPS.pact:349`, table at `:548`, `URC_ReleasableToNow` at `:1902`. The instant and streamed paths share one distribution core (`XI_DistributeInjectAmount`), so *"a streamed release is IDENTICAL to an instant inject of the same amount"*. [VERIFIED by reading] |
| **DSA — delegated staking** (`DSA-DELEGATED-STAKING-DESIGN.md`) | a MultiversX-style delegation layer: 1 agency = 1 FVT member; operators run nodes to capture reward units and take a fee | **BUILT, PARTIAL.** `08_DSA.pact` exists and its header states the phasing: data model + vault define + agency open (Phase 2), capture recompute + delegated oracle (Phase 3), **royalty disposal + collect (later)**. The document's own §11 defers elite-tier fee reduction and the Vesta conversion. **Not a shipped feature end to end.** [VERIFIED by reading] |
| **Sweep/vacate** (`SWEEP-VACATE-DESIGN.md`) | the re-score sweep that lets an employed anchor be retired; freeze stake **and** collect on affected pools while it runs | **SHIPPED.** See §4.4. |
| **Vacate v2** (`VACATE-V2-DESIGN.md`) | separate the cheap transfer work from the expensive accounting work; *"~95 % of each batch's per-position gas is reward overhead, not the transfer"*; 13k NFTs at 30/tx ≈ **433 transactions**, versus ~17 at the transfer floor | **PARTLY.** The parallel-safe `CCp_BatchVacate*` family is live (this is V4's fix) and the `vacate-generation` field the document specifies is implemented. Whether the full drain/finalize separation is complete was **not established by this chapter.** *(not verified)* |
| **LP scoring** (`LP-SCORING-REDESIGN.md`) | two-level RPS | **Level 1 shipped** (Fix #7). The document's own §6 leaves `G1` (make Level 2 fully transient) and `G2` (split by whole-pool TVL vs staked value) open, and notes Vault/Treasury STOA-normalisation is deferred — *"LP-only for now"*. |
| **M3-DEB** (`M3-DEB-DESIGN.md`) | the score model plus the deb-staleness subsystem | **SHIPPED, and the document says otherwise.** See below. |
| **Anchor staleness** (`ANCHOR-STALENESS-INVENTORY.md`) | a map, not a build | Its `S2/H4` row is stale. See below. |

### Two design documents contradict the code, in the safe-looking direction

This is the only place where this chapter's verification disagrees with the audit tree, and in both
cases the **document is behind the code**, not the other way round:

1. **`M3-DEB-DESIGN.md` §"Build order & STATUS"** marks `2b` as *"WRITTEN, DEFECTIVE, REBUILDING"* and
   `2c` / `2d` / `2e` as **"⏸ NOT BUILT"**. The audit's own `README.md` tracker says the opposite —
   *"#12 — Part 1 + 2a–2e all built + proven"* — and the code agrees with the tracker: `CC_Inject`
   exists (`05_FVT.pact:2926`), `MTX-AQP` exists as its own module (`07_MTX-AQP.pact`), and the IGNIS
   surcharge's `FVT|T|ForcedFixCount` table and `UCk_ForcedFixCount` key builder are live
   (`05_FVT.pact:1444`). [VERIFIED by reading]

2. **`ANCHOR-STALENESS-INVENTORY.md` §Status** says H4's half 2 is *"NOT BUILT YET"* and warns that a
   linked boost-class locks its anchors **forever**. That has not been true since the sweep shipped.
   The README tracker records *"half-2 sweep BUILT + PROVEN ✅ (phase 3 done)"* and the code carries
   the full path. [VERIFIED by reading]

Neither is a correctness problem. Both are the failure mode this book's third rule is about: **a true
record whose coverage stopped.** A reader who trusts these two documents will believe two shipped
subsystems do not exist, and — in the anchor case — will believe a permanent operational lock is in
force when it is not.

### Genuinely open

| what | why |
|---|---|
| **Round III** | Never run. Each Round II fix entry names its own missing regressions under *"Not yet covered (Round III regression)"*: the LP reserve-drift round trip asserting base returns to **exactly 0**; the ≥3-staker triplet with a mid-life unstake; the anchor-promile-change-between-stakes eventual-consistency test; and the full negative test for H4's own revoke lock. |
| **LP Level-2 basis (`G2`)** | Whole-pool TVL or staked value. A design question, not a correctness one. |
| **The AQP shared-reader question (G-37…G-41)** | **DECIDED 2026-09-17, and the decided remedy is not the one proposed.** Defaulting the shared `UR_SCR|Score*` readers changes nothing a caller sees — the caller never reaches those guards — while turning three *deliberate* pins in `[6.5]_AQP-INFO.repl` red. The caller-visible defect is real and sits at the **first raiser**, which was guessed wrong **three times in a row** from reading the call chain. *On an eager-`let` path, the first raiser is found by executing, not by reading.* Actionable, with the wrong remedy ruled out. |
| **`INFO_AQP-ANK|RevokeAnchor` still quotes a revoke of an anchor that never existed** | Guarding it is two lines and it **breaks `[6.5]_AQP-INFO.repl`**, a *deliberately fixture-free* cost-shape suite that passes arbitrary ids to all **83** AQP readers on the sound principle that AQP prices are argument-independent. Making AQP previews validate ids needs anchor, score and boost-class fixtures for every one of the 83 — real work with a real design question inside it. |
| **`04_RPS.pact:3876` `XE_XI_SettleScoreRps`** | The eager-fold-operand shape **inside an `if`**, so a settlement plan containing a `BAR` fvt-id would abort the **whole batch settle** instead of skipping that entry — the opposite of what the guard was written to do. **Latent only because the plan builder does not emit `BAR` today.** |
| **`04_RPS.pact:3919` and `:3027`** | `G-27` and `G-24`: one remaining eager-fold read, and a *partial* shadow that survived the `G-16` repair. |
| **The `M7` refutation's scope** | ATSU precision artefacts are by design, but the fix entry notes the interaction: M1's dust sweep cannot recover **sub-precision** triplet dust, because the ATS ladder cannot move it. Economically negligible, structurally permanent. |

### One accepted property that a reader should understand as a property, not a bug

**Stale-until-restake.** A user's stored score is a snapshot taken at their last stake or unstake, and
nothing recomputes it when the *anchor* side changes. That is deliberate — you cannot re-price N
stakers cheaply — and `ANCHOR-STALENESS-INVENTORY.md` exists precisely so every place relying on it is
known rather than assumed. H5's fix explicitly **adopts** this property for the farm triplet in
exchange for deleting an O(stakers) scan, and the trade was made with the owner's eyes open. The
mitigations are the collect-time backstop, the self-service `CC_UnstaleMyScores`, and the
enforced-fresh inject.

---

## 7. Verification result for this chapter

Every finding recorded as fixed was searched for in current source on 2026-09-17.

**Nothing was found missing.** All fixes are present, including the ones whose surrounding code was
substantially rewritten afterwards — the two CRITICALs both survived the FVT→RPS split, which moved
C2's entire inject path into a different module and a different file.

**Five things a reader should weigh against that result:**

1. **Two of the audit's own design documents are stale in the direction of understating what
   shipped** (§6). This chapter's most concrete finding is documentary, not technical.

2. **The audit's proof standard was high and its coverage question was left open by design.** Round III
   was specified, its regressions were enumerated fix by fix, and it was not run. Everything in the
   *"Not yet covered"* fields of `ROUND-02-FIXES.md` is still not covered by anything this chapter
   found.

3. **The single most serious defect in AQP was introduced by this audit's own fix** and found a month
   later by a different method (§5.1). M1 was a real finding, its fix was a faithful port, and the two
   guards it dropped were dropped from a model the audit had explicitly adopted as ground truth. The
   audit's verification target — *both vaults drain to exactly 0* — was met, and was satisfied by the
   defect.

4. **The `Z.repl` numbers quoted throughout the tree are not the gate.** They range from 225 to 242
   assertions; `REPL/tools/_gate.py` — which globs `modules/*.repl`, `RedTeam/*` and `ZALL.repl` — runs
   the order of 20,000. Where this chapter quotes a suite figure it is the audit's, from the time.

5. **`04_RPS.pact` is 304 KB and `05_FVT.pact` is 225 KB.** On 2026-09-15 five source-rewriting tools
   fired on a bare import and **silently deleted 111 lines of schemas from `05_FVT.pact`**; the tools
   now refuse without `--apply` (`DEFECT-LEDGER.md` §7.2i, `CLAUDE.md`). The file is intact today —
   `05_FVT.pact` holds 14 `defschema` and `04_RPS.pact` 19 [VERIFIED by command] — but *"the tree was
   committed"* is not a safety property, and this family is the one that proved it.

The practice that made this chapter possible is the same one {{ch:dpdc}} recommends, applied less
consistently here: **fixes that left a finding id in a source comment could be found after the module
was split in two and renumbered.** Counted 2026-09-17: `01_ANK.pact` 9, `02_SCORE.pact` 9,
`05_FVT.pact` 7, `04_RPS.pact` 3, `07_MTX-AQP.pact` 1, `03_AQP.pact` 1 — and **`06_VCT.pact` 0**, in
the module that carried three of the six vacate findings. Every VCT fix was verified here by reading
its behaviour rather than by finding its marker, which took an order of magnitude longer and is the
only reason this chapter can say *"not verified"* about the one VCT question it could not settle
(§5.5).

---

*End of Part I. Part II documents the main-work round — the systematic construction of the
preview and pricing surface across every module in the tree.*
