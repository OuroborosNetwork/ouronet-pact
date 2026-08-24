# DSA — Delegated Staking Agencies — v1 LOCKED spec

**Module:** **`DSA`** (Delegated Staking Agencies). New AQP core module, layered on the existing FVT two-tier
farm settle + the existing triplet. **Custodians Vault** is its first client.

**Status:** 🟢 **LOCKED v1 (owner-approved 2026-08-24).** Dependency #1 (streamed inject) is **DONE**
(`STREAMED-INJECT-DESIGN.md`, commits f8c0749 → e4baa7c). This doc supersedes the Phase-0 notes; every §11
open item is resolved (see §13). No code yet — build order in §12.

---

## 1. What it is
A delegated node-staking model (MultiversX staking-agency style) on AQP. Users stake **Custodians** assets to
earn **quintessence** (a score); a user with enough quintessence opens a **delegation agency** (a pool others
stake into); the operator must run **nodes** to *capture* the agency's reward units and takes a **fee** from
delegators.

**Custodians** concretely: a collection with 3 SFT types (+fragments) — nonce1→**bronze**, nonce2→**silver**,
nonce3→**gold** quintessence (additive); **nonce4 = an anchor that boosts score +5%** (existing anchor/
boost-class mechanism — no new work). `unit-score` (e.g. 20 000) = 1 staking unit = 1 node; **open gate =
`unit-score / 2`**.

---

## 2. Core architecture — the load-bearing rule

> **1 agency = 1 FVT member (score-entity).** Delegators are the users *within* that member.

- The member may be a **singular score OR a triplet** — whichever the asset's scoring needs. For **Custodians it
  is a triplet** (quintessence has 3 qualities: bronze/silver/gold). The delegation/capture logic lives at the
  **member** level, so it is identical for singular and triplet members. This is the abstraction that makes the
  whole thing work: registering one member on the FVT = opening one agency.
- The FVT's existing **two-tier farm settle** already does both splits, for free:
  - **inter-agency** (global → member): which agency gets what share of an inject — by *captured units*.
  - **intra-agency** (member → user): which delegator inside an agency gets what — by *raw quintessence*.
- **One triplet per agency, cut from one template.** The FVT owner defines the template once (Custodians →
  bronze/silver/gold mapping, reward tokens + ats-ladder, `unit-score`). Opening an agency creates *that
  operator's own* pool + bronze/silver/gold scores + triplet, registered as a member owned by the operator.
  Agencies are differentiated by pool/triplet id. The reward ladder (`FVT|MultipletFamily`, keyed by tokens) is
  **shared** by all agencies.
- **Custodians is exactly N=3 = the EXISTING triplet.** No N-multiplet generalization in v1 (deferred, §11).

---

## 3. The FVT-core extension (the only change to FVT settle)

Today a member's inter-member weight is its *raw* staked score. A delegation member's inter-member weight must be
the **capture** instead. Minimal, deploy-order-safe:

**New per-member fields (on the FVT member row):**
| field | meaning | written by |
|---|---|---|
| `delegation:bool` | is this member a DSA agency? | DSA at open |
| `capture-units:decimal` | **ideal capacity** = `min(⌊Q / unit-score⌋, nodes)` | DSA on Q- or oracle-change |
| `capture-weight:decimal` | **actual** = `capture-units × uptime/1000` | DSA on Q- or oracle-change |
| `oracle-ts:time` | timestamp of the last oracle write (for 25h expiry) | DSA on oracle write |

**New per-FVT flag:** `oracle-on:bool` — if **off**, the node/uptime check is disabled: `capture-units = ⌊Q/unit-score⌋`,
`uptime ≡ 1000`, no expiry (`capture-weight = capture-units`). If **on**, the oracle governs nodes + uptime + expiry.

**Dependency direction = DSA → FVT (legal; FVT deploys first).** The transform math + its inputs (`unit-score`,
`nodes`, `uptime`) live in **DSA**; DSA writes the four fields onto the member via an **`XE_` on FVT** whenever
quintessence changes (delegator stake/unstake) or the oracle updates (nodes/uptime). **FVT only ever reads its
own fields** — computing capture fresh would need FVT→DSA (a forbidden forward ref), hence the stored fields.

**Recompute triggers (DSA writes the fields):**
1. delegator **stake / unstake** → `Q` changes → recompute `capture-units` + `capture-weight`.
2. **oracle write** → `nodes` / `uptime` / `oracle-ts` change → recompute `capture-units` + `capture-weight`.

**Topup dilution is native + free.** Inter-member weight is floored to whole units (`capture-units`), but the
**intra-member divisor stays raw `Q`** — so the leftover (e.g. 5k over a 60k = 3-unit capture) dilutes exactly as
intended; more nodes captured → smaller relative dilution. This is the existing two-axis design (`W_i ≠
intra-divisor`), no new work.

---

## 4. Inject math — ideal denominator + royalty (the uptime mechanic)

At an inject of amount `A` into a delegation FVT reward lane, over its delegation members `i`:

```
S_ideal          = Σ capture-units_i                    ; ideal capacity (whole units, uptime-blind)
effective_i      = expired_i ? 0 : capture-weight_i     ; expired (now − oracle-ts > 25h, oracle-on) ⇒ 0
distributed_i    = A × effective_i / S_ideal            ; agency i's uptime-fair share (then split intra-agency by raw Q)
royalty        +=  A − Σ distributed_i                  ; = A × (S_ideal − Σ effective_i) / S_ideal
```

**Why the ideal denominator (not `Σ capture-weight`):** the inject rewards *full capacity*; each agency earns
only its `uptime/1000` fraction of its units, and the **shortfall accrues to the royalty pool** — a well-run
agency is never handed a competitor's downtime.

*Worked:* 2 agencies, 1 unit each, `A = 100`, uptime A=1000 / B=500 → `S_ideal = 2` → A gets 50, B gets 25,
**royalty += 25**. (Contrast `Σ capture-weight = 1.5` → A 66.7 / B 33.3 / royalty 0 — rejected.)

**Edge cases (all reuse existing behaviour):**
- `S_ideal = 0` (every agency below one full unit — e.g. all drained, or none run a node): the delegation
  denominator is 0 → the inject hits the **existing ESCROW branch** in `XI_DistributeInjectAmount` → parks in the
  **zombie pool**, flushing to whoever captures next. No special-casing.
- `S_ideal > 0` but `Σ effective = 0` (all agencies have capacity but all are down/expired): nothing distributed
  → the **entire `A` → royalty** (nobody performed). Distinct from the zombie case (capacity exists).

The royalty accrual and `S_ideal`/`effective` reads all use FVT-stored fields → no FVT→DSA. The **royalty pool**
is a new per-`(fvt, reward-token)` accumulator on FVT.

---

## 5. Agency lifecycle

- **Open gate = one-time.** Opening requires `quintessence ≥ unit-score/2`. After opening there is **no maintained
  minimum**: the operator may withdraw everything — including his last asset, dropping his own score to 0 in his
  own agency. **An agency, once created, exists forever** (its member row persists at `capture = 0`; it simply
  captures nothing until it holds ≥ 1 full unit again).
- **Operator = an ownership role independent of stake.** An operator may hold zero personal stake and still run the
  agency + collect fees; the pool keeps earning on the delegators' quintessence. (Relaxes today's `member-owner ==
  fvt-owner` admission so `member-owner = operator`.)

---

## 6. Operator fee
- Flat **1–50 %**, skimmed at the member level from **delegators only** (never the operator's own stake).
  Greenfield — no per-member fee/operator exists today.
- v1 = **flat fee, collected normally.** The elite-tier fee reduction + deferred-fee/Vesta benefit is **deferred**
  (§11); v1 stubs the fee field + leaves room for the later curve.

---

## 7. Oracle (nodes + uptime)
- Per agency: **`nodes`** (integer) + **`uptime`** promile (min 0.0001, max 1000.0; full reward needs 1000.0).
- Written by a **daily** platform-automaton tx using an **FVT-owner-delegated key** (registered on the FVT), which
  writes per-agency `{nodes, uptime}` and stamps `oracle-ts`.
- **Validity = 25 h** (daily cadence + 1 h overlap, so there is never a gap between "last write expired" and "next
  write arrives"). At inject, `now − oracle-ts > 25h` ⇒ that agency's `effective = 0` (§4).
- **Per-FVT toggle `oracle-on`** (§3): off ⇒ node/uptime check disabled, `capture = units`, `uptime ≡ 1000`, no
  expiry. On but no uptime submitted for an agency yet ⇒ default **uptime = 1000** until first write.

---

## 8. Royalty pool + disposal
- The uptime shortfall (§4) accrues into a per-`(fvt, reward-token)` **royalty pool** — it does **not** pay
  delegators. Disposed **periodically** (e.g. weekly), not on every inject.
- Three **admin/owner** disposal functions (poolable weekly; optional autonomous weekly trigger, like the falls
  automation):
  ```
  A_WithdrawRoyalty(fvt-id, reward-token)          ; send the pool to the FVT owner
  A_BurnRoyalty    (fvt-id, reward-token)          ; burn it (DPDC autonomous burn role)
  A_FuelRoyalty    (fvt-id, reward-token, swpair)  ; fuel <swpair> — add liquidity WITHOUT minting LP
  ```
- **`swpair` is a per-call input** to `A_FuelRoyalty` (not stored config) → maximal flexibility, and it removes the
  §8-legacy "fuel-target config hook" entirely.
- **IGNIS normalization is universal** across all three: IGNIS cannot be withdrawn/burned/fueled as a token, so if
  a royalty leg is in **IGNIS** → an **autonomous IGNIS→OURO conversion** runs first, and the resulting **OURO**
  is what gets withdrawn / burned / fueled. (Wire against the existing IGNIS→OURO path — pin the exact primitive at
  build time.)

---

## 9. Reward modes (all on the triplet)
1. **Direct single-DPTF** — inject X, collect X (today's model). *Secondary gas = Ignis, type-agnostic.*
2. **Homogeneous quality split** — each lane → one token via the existing ATS ladder (bronze→Ouro, silver→Auryn
   via ats-01, gold→EliteAuryn via ats-01→ats-12). Already built (`MULTIPLET_BASE` collect).
3. **Heterogeneous quality split — NEW, v1 (Round B).** A **reward-mode flag** (homogeneous | heterogeneous) + a
   **per-type split matrix** stored per heterogeneous reward. Example: bronze 20/40/40, silver 40/30/30, gold
   60/20/20 across Ouro/Auryn/EliteAuryn (rows sum 100 %). At collect, the heterogeneous branch splits each lane's
   amount across the 3 tokens per the matrix, routing non-native portions through the same ATS legs. Slots into
   `XI_1|CollectRewards`'s `MULTIPLET_BASE` as a second branch. *(Matrix storage — extend `FVT|MultipletFamily`
   vs a sibling schema — decided in Round B.)*
- **Primary reward** = 20 % of daily Ouro emission, delivered via the **streamed inject** (feature #1, done).

---

## 10. Reuse vs new-build (grounded in code)
**Reuse (confirmed):**
- Triplet: `SCR|Triplet` (3 positional score-ids), `C_IssueTriplet` (`02_SCORE.pact`) — already **owner-gated**
  (a user who owns 3 matching scores bundles them) → user-created bundles have precedent.
- Reward ladder: `FVT|MultipletFamily` (`04_FVT.pact`, tokens + 2 ATS legs; `rank` "v1 = 3").
- Two-tier settle: `XI_1|FarmSplitInject` (member weight read site) + `XI_2|BankUserTier1Pending`. **`W_i` and the
  intra-member divisor are distinct axes** → capture/topup split is native.
- Zombie escrow: `XI_DistributeInjectAmount` ESCROW branch (`S = 0` → park) — the drained-agency case (§4).
- 4th-nonce boost = existing anchor/boost-class (+5 %).
- Elite fee reduction (deferred phase): `URC_EliteFeeReduction` (`16_SWPI.pact`) → `UC_GasCost/UC_GasDiscount`
  (`08_U_DALOS.pact`) — mirror pattern for the custom operator curve.

**Genuine new-builds:**
- FVT: `delegation` + `capture-units` + `capture-weight` + `oracle-ts` fields + `oracle-on` flag; the
  ideal-denominator branch at the weight site + denominator; royalty-pool accumulator + accrual at inject; the
  `XE_` DSA calls to write the member fields + the royalty-disposal writers.
- User-created member admission (`member-owner = operator`, relaxing `score-owner == fvt-owner`).
- Per-member operator + flat fee.
- Heterogeneous split branch + matrix (§9.3, Round B).
- The **`DSA`** module: agency open, capture transform, oracle write path (delegated key), royalty disposal
  (withdraw/burn/fuel + IGNIS→OURO), fee.

---

## 11. Deferred (provision hooks now, build later)
- **Elite-tier fee reduction + deferred-fee benefit + Vesta conversion.** Operator tier reduces the fee ~10 %/major
  (tier 7 → 70 %, 1 %→0.3 %); the participant's tier further reduces *that* multiplicatively (2 majors → −20 %,
  0.3 %→0.24 %) — a **custom curve** (distinct from SWP's 7 %/major). The deferred fee % is swapped into **Blessed
  Vesta** and given to both operator and participant. Needs **Vesta** infra (virtual-mining LP: Native/Sleeping/
  Frozen/Blessed → Unified Mining Index → Unity). v1 = flat fee; leave the fee field + a fee-redirection seam.
- **Non-royalty fuel-target / fee-redirection** — the general "injected token designates fuel targets" mechanic for
  *deferred fees* (distinct from royalty-fuel, which IS v1 per §8). Provision later.
- **Collateral / slashing** — EliteAuryn collateral burned on misbehavior (per-node? TBD). May not exist at all.
- **N-multiplet** — generalize triplet → N (positional-3 schemas/keys/lane-math/2-hop-ladder → list-valued). Not
  needed for Custodians (N=3).

---

## 12. Build order

**Round A — the spine (this is where we start).**
1. **FVT extension.** Add the four member fields + `oracle-on` flag + royalty-pool schema. Branch the inter-member
   weight site + denominator to the ideal-denominator model; accrue the royalty gap at inject; add the `XE_`
   writers DSA calls (member fields + royalty writers) and the royalty-disposal writers. Green-gate: existing FVT
   audit stays green (non-delegation members unchanged — the branch is `delegation ? … : today`).
2. **DSA skeleton.** Module scaffold (schemas/tables/caps in canon StoicSyntax order) + agency **open** (one-time
   gate, user-created member = operator, template instantiation) + operator/flat-fee.
3. **Oracle path.** Delegated-key registration + daily `{nodes, uptime}` write → recompute + stamp `oracle-ts`;
   25h expiry; `oracle-on` toggle + defaults.
4. **Royalty disposal.** `A_WithdrawRoyalty` / `A_BurnRoyalty` / `A_FuelRoyalty(swpair)` + universal IGNIS→OURO
   pre-normalization; weekly-poolable.
5. **Talos wiring** (open agency, oracle write, royalty disposal, delegator stake/unstake path) + tests, each
   green-gated and committed like the streamed inject / CC_UnstaleAll.

**Round B — heterogeneous split.** Reward-mode flag + per-type split matrix (storage decided here) + the collect
branch in `MULTIPLET_BASE`. Tests.

---

## 13. §11-of-Phase-0 open items — all resolved
| item | resolution |
|---|---|
| Half-unit open gate one-time vs maintained | **one-time** to open; withdraw-anything after; agency persists forever; all-drained → zombie (§5, §4). |
| Uptime — inject-time vs maintained | **both**: maintained on the member (fields, §3), applied at inject via the **ideal-denominator** split → shortfall to royalty (§4). |
| Oracle expiry + write auth | **25 h**; FVT-owner-delegated key writes daily `{nodes, uptime}` + `oracle-ts`; per-FVT `oracle-on` toggle (§7). |
| `capture-weight` recompute triggers | delegator **stake/unstake** + **oracle write** (§3). |
| Royalty destination | pool → **withdraw / burn / fuel(swpair)**, IGNIS→OURO pre-normalized, admin/weekly (§8). |
| FVT `XE_` interface/deploy order | **DSA → FVT** (FVT deploys first; DSA calls FVT `XE_` to write member fields + royalty; FVT reads its own fields only) (§3). |
| Heterogeneous matrix storage | decided in **Round B** (§9.3). |

*Locked 2026-08-24. Resume at Round A step 1 (FVT extension).*

---

## 14. BUILD LOG — FVT-core extension COMPLETE (Round A step 1)

The whole FVT side of the extension is built, committed, and green (full AQP audit, 8 suites, throughout):

| sub-step | what landed | commit |
|---|---|---|
| 1a | member fields `delegation`/`capture-units`/`capture-weight`/`oracle-ts`, FVT `oracle-on`, lane `royalty-rewards`; 3 UDC constructors → faithful params; 13 call sites | `854ec21` |
| 1b-i | readers (iface+module) `UR_FVT-SEL\|Delegation/CaptureUnits/CaptureWeight/OracleTs`, `UR_FVT\|OracleOn`, `UR_FVT-RG\|RoyaltyRewards`; writers `WU_ScoreEntityLink\|Capture/Delegation`, `WU_Fvt\|OracleOn`, `WU_RpsGlobal\|RoyaltyRewards` | `fbc7178` |
| 1b-ii | `DSA_ORACLE_TTL` (90000s=25h), `URC_MemberEffectiveCapture` (uptime + 25h expiry), `URC_FarmInjectDenominatorFresh` → Σ capture-units for delegation members, `XI_1\|FarmSplitInject` map→fold returns the royalty gap, `XI_DistributeInjectAmount` `available += eff−royalty` / `royalty += gap` | `96b05c3` |
| 1c | FVT `XE_` writers DSA calls: `XE_SetFvtOracleOn`, `XE_SetMemberDelegation`, `XE_SetMemberCapture` (UEV_IMC + SECURE) | `d7b87d7` |

**Conservation proven:** a normal member has `ideal == W_i` ⇒ gap 0 ⇒ `available += eff` exactly as before; the
royalty field is only ever touched by a delegation member with an uptime shortfall. Custody exact: `available + royalty = eff`.

## 15. CONFIRMED Custodians integration (owner, 2026-08-24)

`DEMIPAD-CUSTODIANS` (`2_Core/02_DEMIPAD/03_Custodians.pact`) **is** the collection (the existing module is the
*sale* side, `C_Acquire`). Concrete facts to build the DSA vault against:
- **Quintessence** already exists: `DEMIPAD-CUSTODIANS::UC_NonceQuintessence(nonce, validation)` →
  `-1 → 1` (bronze), `-2 → 10` (silver), else (`-3`) `→ 100` (gold). **Additive.** It scores the **fragment
  (negative) nonces**, so a whole Custodian (nonce 1/2/3, +4 = anchor boost) is **fragmented first** (via
  **`DPDC-F`**, the DPDC fragment module) into `-1/-2/-3` fragments, which are what stake for quintessence.
- Custodians is a **DPDC collectable** (uses `ref-DPDC::UR_AccountNonceSupply`).
- **Test requirement (owner):** the DSA test must **fragment nonces 1/2/3** and assert the fragments
  **`-1/-2/-3` are properly accepted** (staked → quintessence Q → capture) alongside/after fragmentation.

## 16. DSA-module build plan (Round A step 2+, phased — resume here)

Deploy order: `07_DSA.pact` loads **after** FVT (DSA→FVT), in `REPL/Stage_02/[2.3]_EarningPools.repl` after MTX-AQP.

1. **Skeleton + data model** — module scaffold (GOV/POLICY/IMC, template of MTX-AQP), schemas:
   `DSA|Template` (per vault: fvt-id, custodians-asset-id, unit-score, active), `DSA|Agency`
   (fvt-id, score-entity-id=triplet member, operator-konto, fee, nodes, uptime), `DSA|OracleAuth`
   (fvt-id → delegated oracle guard) + tables + caps + constructors + readers. Wire deploy + create-tables.
2. **Agency open** — user-created member = operator. **SCOPED (2026-08-24):**
   - A DSA agency triplet is **operator-owned + vault-like** (`swpair="|"`, `ghost-weight=0`; its inject weight is
     `capture`, not ghost-tvl), even though the DSA vault FVT is **class-0** (uses the farm split — the 1b-ii
     delegation branch reads `capture-weight`/`capture-units`, ignoring ghost-tvl). So the DSA vault FVT is
     issued **class-0 with common-denominator `"|"`**.
   - The existing LP-farm admission (`UEV_AddScoreEntityTripletContext` FVT ~`:2660`) can't be reused directly —
     it hardcodes `silver-owner == fvt-owner`, `swpair == expected-LP-swpair`, `lp-denom == common-denom`,
     `ghost-weight > 0`, all of which conflict with a vault-like operator-owned agency. **Build an isolated
     FVT-side primitive** (does NOT touch/weaken the normal admission):
     - **`XE_AdmitDelegationMember(fvt-id, triplet-id, operator)`** — `UEV_IMC` + a new
       `FVT|XE>ADMIT-DELEGATION` cap that runs the *structural* subset (triplet issued, category matches class,
       membership mode, **no** pre-existing link, silver has an aqpool, all three fvt-links BAR) **with
       `silver-owner == operator`** + `CAP_EnforceAccountOwnership operator`, and **skips** the LP-farm rules
       (swpair/lp-denom/ghost). Write path = `ref-SCR::XE_CreateFvtLink ×3` + `XI_AddScoreEntity fvt-id
       TRIPLET triplet-id "|" 0.0` (both already exist; C_AddScoreEntity ~`:5258` is the model).
   - DSA `C_OpenAgency` then: operator creates pool + bronze/silver/gold scores + triplet (`C_IssueTriplet`) →
     `XE_AdmitDelegationMember` → `XE_SetMemberDelegation true` → enforce one-time `quintessence ≥ unit-score/2`
     gate → write `DSA|Agency` (operator + flat fee). Quintessence Q = Σ over the operator's staked Custodians
     fragment nonces of `DEMIPAD-CUSTODIANS::UC_NonceQuintessence`.
   - **Security note:** the isolated primitive means the normal `C_AddScoreEntity` admission is byte-identical
     (never weakened); the operator-owned path is a separate, auditable entrypoint.
3. **Capture recompute** — on delegator stake/unstake (Q change) or oracle write: `capture-units =
   min(⌊Q/unit-score⌋, nodes)`, `capture-weight = capture-units × uptime/1000` → `XE_SetMemberCapture`.
4. **Oracle write path** — `DSA|OracleAuth` delegated guard writes daily `{nodes, uptime}` + stamps oracle-ts;
   `oracle-on` toggle via `XE_SetFvtOracleOn`; defaults uptime 1000.
5. **Royalty disposal** — `A_WithdrawRoyalty` / `A_BurnRoyalty` / `A_FuelRoyalty(swpair)`; read + zero
   `royalty-rewards`, move from AQP custody; **IGNIS→OURO** pre-normalize via the **`OUROBOROS`** module
   (interface `OuroborosV1`, `STAGE_01/2_Core/13_OUROBOROS.pact`; 98.5% efficiency / 1.5% compression fee;
   `URC_Compress` = quote, `C_Compress` = client entry). **Wire OUROBOROS DIRECTLY (core→core module ref `::`),
   NOT the Talos wrapper** — DSA composes compress *inside* a new function, so it takes the core entry (resolve
   `C_Compress` vs an internal `XE_/XB_` compress variant at build time; add one to OUROBOROS if only `C_` exists).
   The resulting OURO is then withdrawn / burned / fueled; fuel = SWP add-liquidity-no-mint.
6. **Talos + IMP** — register DSA in FVT's IMP (`P|A_Define`), Talos client/admin wrappers, gas.
7. **Tests** — Custodians fragment fixture (fragment 1/2/3 → stake −1/−2/−3 → Q → capture), inject with
   uptime shortfall → royalty, all-drained → zombie, disposal.

**Round B** — heterogeneous quality-split matrix (§9.3).

*FVT-core done 2026-08-24. Resume at §16 step 1 (DSA module skeleton).*

---

## 17. Score-entity MODEL — architecture pivot (owner-locked 2026-08-24)

**Why:** SCORE's score *definitions* (`C_Issue*ScoreDefinition`) attach to one specific `score-id` — they are
bespoke per-score, NOT reusable. For a delegation vault every agency must score **identically** (fair capture),
so we add a **first-class, reusable score-entity MODEL** that every agency instantiates. Owner decisions:

- **Delegators score in the OPERATOR's score.** An agency = ONE score entity (the operator's, issued from the
  model). Each delegator's stake is tracked as their per-user score (`SCR|UserSchema`, keyed user × operator's
  score-id) — the existing per-user tier; the two-tier settle's user-tier splits the agency's reward by those
  individual quintessence shares (minus operator fee). The *staking* side needs nothing new.
- **A delegation-FVT is the SAME construct** — a normal class-0 FVT (common-denominator `"|"`), made a
  "delegation vault" by (a) its members being delegation agencies (the member `delegation`/`capture` fields) and
  (b) a `DSA|Template` binding it to a `model-id` + unit-score + `oracle-on`. No new FVT type.

**The model — new first-class entity in `02_SCORE.pact` (ONE new table):**
- **`SCR|ScoreEntityModel`** (key `model-id`, `entity-type` = single | triplet):
  - **single**: the scoring spec — `score-class`, `collectable-id` (dpsf/dpnf), `precision`, definition data
    (`nonces` + `nonce-score-values`; NF traits later). E.g. bronze = `{SF, Custodians, [-1], [1]}`.
  - **triplet**: references **three single model-ids** (`bronze/silver/golden-model-id`); no scoring data of its own.
- **`C_IssueScoreEntityModel(...)`** — admin defines a model → `model-id` (via `U|DALOS::UDC_Makeid` on a name).
  Custodians = 4 calls (3 singles + 1 triplet combining them). Mirrors the score/triplet layering exactly.
- **`C_IssueScoreFromModel(patron, owner-konto, model-id)`** — the FACTORY. single → compose the internal writers
  `XI_Issue` (score-class 3 SF) + `XI_IssueSemiFungibleScoreDefinition` (from the model's nonces/values) under one
  cumulator; triplet → recurse over the 3 single models, then `XI_IssueTriplet`. **Compose the `XI_*` writers,
  NOT the `C_*` clients** (no nested C_/double-billing). Deterministic score-names from (model + owner) so the
  factory is idempotent per operator. Returns the (score|triplet) id. Conforming by construction.

**Building blocks confirmed (02_SCORE.pact):** `UDC_Makeid` (id from name), `XI_Issue` (used by
C_IssueSemiFungibleScore `:3473`), `XI_IssueSemiFungibleScoreDefinition` (`:3617`), `XI_IssueTriplet` (`:3597`),
`UCk_Triplet` / `UC_ComputeTripletId`.

**Revised DSA flow (supersedes §16 step 2's inline triplet issuance):**
1. `SCORE::C_IssueScoreEntityModel` ×4 → the Custodians triplet `model-id`.
2. `DSA::A_DefineDelegationVault(fvt-id, model-id, unit-score)` — class-0 + common-denom `"|"` + `oracle-on`,
   bound to the model.
3. `DSA::C_OpenAgency(operator, fvt-id)` → `SCORE::C_IssueScoreFromModel(operator, model-id)` → the operator's
   agency score entity → `XE_AdmitDelegationMember` (generalize to admit single OR triplet) → set delegation →
   record operator + fee (`quintessence ≥ unit-score/2` gate).
4. Delegators stake Custodians into the agency score as beneficiaries → per-user scores → capture recompute.

**Build order:** (17a) `SCR|ScoreEntityModel` schema + table + `C_IssueScoreEntityModel` + readers (green-gate);
(17b) `C_IssueScoreFromModel` factory (green-gate); then DSA `A_DefineDelegationVault` + `C_OpenAgency` on top.

*Model pivot locked 2026-08-24. Resume at §17 build order 17a (SCORE model schema + define).*

---

## 18. BUILD TRACKER (phased) — where we are

**Discipline per phase:** build → StoicSyntax canon-order refactor → a REPL verification flow (`.repl` scenario,
exact assertions) → green-gate that flow → commit. **After the last phase: rerun the FULL AQP audit
(`run-aqp-audit.sh`, now 8 suites) + add a DSA suite as the 9th** to prove zero regression in the shared
FVT/SCORE core.

### ✅ BUILT (committed, green)
- **FVT-core extension** — member fields + FVT `oracle-on` + lane `royalty-rewards` + faithful constructors
  (`854ec21`); readers + writers (`fbc7178`); `URC_MemberEffectiveCapture` (25h expiry) + ideal-denominator
  split + royalty accrual in `XI_1|FarmSplitInject` / `XI_DistributeInjectAmount` (`96b05c3`); XE_ writers
  `XE_SetFvtOracleOn/SetMemberDelegation/SetMemberCapture` (`d7b87d7`). *(behaviorally proven only structurally
  so far — no delegation member exists yet; first real proof = Phase 5.)*
- **DSA module skeleton** — `07_DSA.pact` scaffolding + `DSA|Template`/`Agency`/`OracleAuth` + deploy wiring (`1d2078f`).
- **`XE_AdmitDelegationMember`** + `FVT|XE>ADMIT-DELEGATION` cap — isolated operator-owned admission (`95ee657`)
  *(currently triplet-only; Phase 2 generalizes to single).*
- Design fully locked (`d4762d8`, `d6d74ec`, `d745a0a` + this).
- **Phase 1 — Score-entity MODEL (SCORE).** ✅ **DONE** — `SCR|ScoreEntityModel` + `C_IssueSingleScoreModel` /
  `C_CombineTripletScoreModel` (17a, `8d3ebaf`); `C_IssueScoreFromModel` factory + `XI_IssueOneFromModel`
  (17b, `5a297dc`); Talos wrappers; `dsa-model-tests.repl` (9th audit suite) green. Refinements: model
  precision 3..24; the operator supplies an **`agency-name`** (score-names can't embed the raw konto).

- **Phase 2 — DSA vault + agency open.** ✅ **DONE** — `A_DefineDelegationVault(patron, fvt-id, model-id,
  unit-score)` writes `DSA|Template` (model + unit-score, active) on an owner-owned **class-0 FVT**;
  `C_OpenAgency(patron, fvt-id, score-entity-id, fee-per-mille)` admits the operator's factory triplet
  (`XE_AdmitDelegationMember`) → flips it to a delegation member (`XE_SetMemberDelegation`) → writes
  `DSA|Agency`, gated by the one-time **quintessence ≥ unit-score/2** open gate + fee-range + vault-active.
  Module renamed `DSA` → **`AQP-DSA`** (family convention); canon-reordered; Talos wrappers
  `AQP-DSA|A_DefineDelegationVault` / `AQP-DSA|C_OpenAgency` + IMP registration in **both** directions
  (`TS02-C3::P|A_Define` adds Talos to AQP-DSA's IMP; executor calls `AQP-DSA::P|A_Define` to add DSA to
  AQP-FVT's IMP). *Deviation from the lock:* the vault FVT keeps a **real LP common-denom** (e.g. `OURO`),
  not `"|"` — a class-0 FVT requires a real LP denom (FVT L690); delegation **members** still bypass all
  class/LP admission rules via `XE_AdmitDelegationMember`, which is what matters. `dsa-agency-tests.repl`
  (10th audit suite) green: define + read template + owner/positive/duplicate guards + the 4 open-guard
  rejections (Q=0 gate, fee floor, fee ceiling, non-vault). *Staked happy-path open → Phase 3 (needs the
  Custodians fragment→stake fixture).*

### 🔨 TO BUILD (phases)
- **Phase 3 — Delegator staking + capture recompute.** Confirm/enable a non-owner delegator staking into the
  operator's agency score (beneficiary path; add a DSA stake wrapper if needed); `URC` for the agency's aggregate
  quintessence Q; recompute `capture-units = min(⌊Q/unit-score⌋, nodes)` + `capture-weight` → `XE_SetMemberCapture`
  on stake/unstake. *Verify:* **fragment Custodians 1/2/3 → stake −1/−2/−3 → Q (1/10/100) → capture computed.**
- **Phase 4 — Oracle.** `A_SetOracleAuth(fvt-id, guard)`; delegated-guard `A_OracleWrite` sets `{nodes, uptime}`
  per agency + recompute + stamp oracle-ts; `oracle-on` toggle. *Verify:* oracle write + 25h expiry → capture 0.
- **Phase 5 — Inject + royalty (BEHAVIORAL PROOF of the FVT-core).** Inject into a live delegation vault via the
  existing `CC_Inject`/`C_Inject`. *Verify:* split by `capture-weight / Σ capture-units`; **uptime shortfall →
  royalty pool**; all-drained → **zombie**; operator **fee** skimmed from delegators at collect.
- **Phase 6 — Royalty disposal.** `A_WithdrawRoyalty` / `A_BurnRoyalty` / `A_FuelRoyalty(swpair)` +
  `OUROBOROS::C_Compress` IGNIS→OURO (core→core) + SWP fuel (add-liq, no LP mint). *Verify:* accrue → dispose each way.
- **Phase 7 — Talos + gas full wiring.** All DSA client/admin ops into Talos + gas-station allowlist + IMP; the
  operator-fee collect path. *Verify:* end-to-end via Talos.
- **Phase 8 — Round B: heterogeneous quality split.** Reward-mode flag + per-type split matrix + the
  `MULTIPLET_BASE` collect branch (§9.3). *Verify:* heterogeneous payout.

### 🏁 FINAL — full regression gate
Rerun `run-aqp-audit.sh` (8 suites) **+ a new `dsa-*.repl` suite (9th)** — all green ⇒ the DSA feature is
complete and the shared FVT/SCORE core is regression-free.

*Tracker written 2026-08-24. Next: Phase 1 (17a).*
