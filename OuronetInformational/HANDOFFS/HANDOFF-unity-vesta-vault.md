# Unity emission + the Vesta staking vault — agreed design, not yet built

2026-11-18. Agreed over a multi-round analysis + design conversation (session dated 2026-11-17/18).
Nothing below is deployed. This supersedes the open question in
`Z:\AncientClients\StoicEngine\UNITY-VAULT-HANDOFF.md` §4 ("token, or score?") with an answer and a
concrete architecture; everything else in that document (the emission curve, the camel closed form,
the 10/90 split, the account/payment-key facts) stands and is not repeated here except where this
plan changes it.

**Source papers:** `pitch/Unity_Tokenomics.pdf` v0.6 (StoicEngine) and the public Vesta gitbook pages
(virtual mining, variants, Dominance Point, virtual-vs-physical mining —
`demiourgos-holdings-tm.gitbook.io/kadena/ouronet-services/virtual-mining-with-vesta-token`).

---

## 0. The one-line answer to the open question

**Option B — score, not token.** Not because it's theoretically nicer, but because the pattern it
needs (synchronous settle-then-reweight, pushed through one chokepoint, with generalized
multi-instance reward-per-share accounting) **already exists and is already proven** in
`AQP-SCORE`/`AQP-FVT`/`RPS`, one layer more mature than the `UrStoaVault` pattern the original
handoff proposed mirroring. Building Option A would mean a second token-ledger module *and* would
reintroduce the exact "mint a permanent token from a temporary multiplier" trap the handoff itself
flags for 20-year Sleeping positions.

---

## 1. Two separate pipelines — do not conflate them

This design has two stages chained together, and the whole conversation that produced this plan
moves between them. Keep them conceptually separate when building:

**Pipeline 1 — earning Vesta (virtual mining).** Users stake LP tokens in two Farms. Primal Vesta
is injected into those Farms as a reward lane. At collect time, the payout is classified Raw or
Condensed by the Dominance Point and credited to a ledger instead of transferred directly. A
separate Forge module converts Raw/Condensed into the four usable Vesta variants.

**Pipeline 2 — generating Unity (the actual ask of this project).** Users stake the *output* of
Pipeline 1 (Native/Sleeping/Frozen/Blessed Vesta) into Vesta-variant pool(s). That generates a
Score. If that Score is registered as the Unified Mining Index, every change to it pushes
synchronously into `UVV`, a new coin-module vault. Chain-0 coinbase mints Unity every block, 10% to
the miner, 90% into `UVV`'s pot, distributed pro-rata by UMI weight. Users collect native Unity to
their DALOS payment key.

Pipeline 1's Farms and Pipeline 2's Vesta-staking pool(s) are different AQP objects with different
scores. Nothing from Pipeline 1 is UMI. UMI is specifically the score(s) staked-Vesta-variants
produce in Pipeline 2.

---

## 2. Pipeline 1 — earning Primal Vesta

### 2.1 Two Farms, no new core logic

- **`LiquidStoaLpFarm`** — new `AQP-FVT` row, `fvt-class=0` (Farm), accepting SSTOA-based LPs.
  40% of the daily Vesta allocation.
- **`OuroLpFarm`** — existing Farm. Add Primal Vesta as a **second reward lane**
  (`FVT|RPS|Global` is already keyed `<FVT-ID>|<DPTF-ID>`, so a Farm already supports multiple
  independent reward lanes). 30% of the daily Vesta allocation.

Both are configuration on top of the existing `XB_FvtInject`/`CC_Inject` multi-lane mechanism — no
new injection logic needed.

**Open gap, not yet resolved:** the gitbook's split is 40% LKDA / 30% OURO / 30% vaults. This
conversation only settled the first two lanes. Where the remaining 30% ("vaults") goes is
unspecified — flag before implementation.

### 2.2 Dominance Point — classify at collect time, not inject time

**Not yet built anywhere in the tree.** `ANK`'s `BoostClass`/promile system is a flat per-asset
multiplier registry; there is no logarithmic, pool-size-and-Elite-tier-scaled threshold classifier
today. This needs a new pure `UC_`/`URC_` function implementing the gitbook's formula.

The classification happens at **collect time**, as a branch on the existing payout, not as a
reweighting of anyone's stake:

- Collect math is unchanged: the claimable amount is still `(current-score × diff-rps)`.
- The **payout destination** branches: compute `my-share = my-score / total-score`, compare to
  `UC_DominancePoint(total-score, my-elite-tier)`. Below → credit a Raw-Vesta ledger entry. Above →
  credit a Condensed-Vesta ledger entry. Instead of a direct DPTF transfer to the collector.
- Dominance is evaluated live, at the moment of collect — not snapshotted. A Major who drops below
  threshold and then collects gets Raw for that collection. This is a deliberate choice (dominance
  is a live fact), not an oversight — state it explicitly in the spec so it isn't a surprise later.

**Single-chokepoint constraint, confirmed and must be preserved:** the default/plain reward-kind
payout in `XI_TransferRewardDptfFromVault` is one line
(`04_RPS.pact:3570` — `ref-TFT::C_Transfer patron AQP|SC_NAME collector reward-dptf-id payout true`).
The `MULTIPLET_BASE`/triplet reward-kind instead pays out across **four scattered call sites**
(`04_RPS.pact:3499, 3557, 3560`, plus inside `XI_1|HeterogeneousLaneRoute`). **Primal Vesta's reward
lane must stay a plain reward-kind, never `MULTIPLET_BASE`**, specifically so the Dominance-Point
branch has exactly one insertion point. This must be a stated constraint in the spec, not an
accident of how it happens to be configured today — nothing stops someone reaching for the
bronze/silver/gold ladder mechanism later for an unrelated UI reason and silently reopening this
into a four-site change.

### 2.3 Raw / Condensed as plain DPTF ledger balances

Collected Raw/Condensed Vesta are ordinary DPTF tokens. No new mechanism needed for the ledger
itself.

### 2.4 Vesta Forge — the converter, kept separate from vault/farm/score architecture

A new, standalone module. Burns Raw or Condensed Vesta, mints the corresponding variant:

- Raw → Native Vesta, 1:1.
- Raw → Sleeping Vesta, multiplier scaled by Elite account tier.
- Raw → Frozen Vesta, multiplier scaled by Elite account tier.
- Condensed → Blessed Vesta, multiplier scaled by Elite account tier.

Mechanically: Forge mints Native Vesta internally, then for Sleeping/Frozen calls into VST's
existing `C_Sleep`/`C_Freeze` (confirmed: both take **plain DPTF in**, no DPOF pre-wrap required —
`C_Freeze` mints a DPTF `F|` sibling directly; `C_Sleep` mints the DPOF `Z|` nonce-batch itself,
inline, in the same call). Forge does not reimplement locking — it only calls into VST exactly as
any other caller would.

This mirrors the existing separation between VST (lock mechanics) and `SCORE` (weight mechanics) —
Forge owns conversion, nothing else needs to know it exists.

**Decided: Reserved (`R|`) is not an option for Blessed, and not just by omission.**
`03_AQP.pact:3496` — `(enforce (not (URC_DptfStakeIsReservedLeg dptf-id)) "Reserved DPTF (R|) cannot
be staked")`. This is an explicit, deliberate refusal with its own named helper. There is no
multiplier dispatch for it anywhere in `SCORE` because execution never reaches dispatch. Blessed
needs either a genuinely separate token family, or a brand-new VST special-variant prefix with its
own deliberately-carved-out stake-path admission — not a repurposing of Reserved.

**Confirmed, nothing to build for the fee's destination:** DPTF's fee-on-transfer splits into a
**secondary** component — always hardcoded to `DALOS|SC_NAME`, identical for every DPTF token,
shared code (`09_TFT.pact:1501,1513-1514`) — and a **primary** component, routed through a
per-asset-id `fee-target` field (`05_DPTF.pact:623`, settable via `DPTF|S>SET_FEE-TARGET`). Blessed's
"25%, collected to the DALOS account, same as IGNIS gas" description is the **secondary** fee,
verbatim — every DPTF token already behaves this way with zero configuration. Nothing to build for
Blessed's fee destination; only the percentage (if adjustable per-asset — unconfirmed, check at
build time) needs setting.

**Decided: Blessed is a new VST special-variant prefix, not a sibling-link of Native Vesta.** VST
mints `is-unity`-unrelated special variants (`F|`/`Z|`/`R|`) as siblings of one base DPTF; Blessed
needs the same treatment — a new link type, new prefix, new VST entrypoints
(`C_CreateBlessedLink`/`C_Bless` mirroring `C_CreateFrozenLink`/`C_Freeze`). This resolves the
earlier open fork: Blessed stays its own pool/score, pushed into `UVV` independently from the
Native/Sleeping/Frozen pool's score — not a problem, `UVV` sums across scores regardless of source
(§3.3).

### 2.5 The Blessed-creation dependency chain — must complete before any score can exist

This is sequential, not parallel, and nothing downstream can be built out of order:

1. **VST**: new `C_CreateBlessedLink`/`C_Bless` entrypoints minting the new prefix (mirrors
   `C_CreateFrozenLink`/`C_Freeze` — confirmed VST's lock functions take plain DPTF in, no DPOF
   pre-wrap needed, so this is a same-shape addition, not a new mechanism).
2. **DPTF/true-fungible layer**: a new special-link row/case for the Blessed type, same shape as the
   existing Frozen/Reserved rows.
3. **SWP**: a new exclusion enforce rejecting the Blessed prefix from pool deposit/issuance.
   **Confirmed this is genuinely new logic, not an extension of an existing gate** — a full grep of
   the SWP family (`14_SWPT.pact` through `20_MTX-SWP.pact`) found no prefix/eligibility filtering
   anywhere; `SWPI::UEV_Issue` (`16_SWPI.pact:2555-2704`) only checks weight precision and account
   ownership (`CAP_Owner`, `:2613-2619`), never a token's prefix. AQP's own `URC_DptfStakeIsReservedLeg`
   / `UEV_StakeTrueFungibleDptfLeg` (`03_AQP.pact:3490-3498`) is the ready template to mirror —
   same shape, new site, inside `SWPI::UEV_Issue` alongside the `CAP_Owner` check.
4. **AQP pool-matcher**: extend `URC_StakeTrueFungibleDptfMatchesPool` to **admit** the new Blessed
   prefix (the opposite change from step 3 — Blessed must be stakeable in AQP even though it's
   excluded from SWP).
5. Only after 1–4 land can Blessed actually be staked, and only then can a score counting it exist.

---

## 3. Pipeline 2 — generating Unity

### 3.1 The Vesta-variant staking pool(s)

One pool for Native/Sleeping/Frozen Vesta (one DPTF base asset + its VST siblings, matching AQP's
existing pool model). Multipliers for Sleeping and Frozen are set **flat at 1.0×** — sleeping and
freezing count exactly the same as holding Native. This removes the entire gaming concern the
sleeping-LP duration-multiplier engine was built to prevent (there is no reward differential to
arbitrage by sleeping briefly and unsleeping), so none of that engine's re-rate/ordering-invariant
machinery is needed here.

**Nuance to carry into the build:** the mandatory custodial-stake requirement for a `Z|` (Sleeping)
leg in an `aqp-class 0` pool is gated structurally on **(leg-type, pool-class)**, not on the current
value of the multiplier. Setting `mx-sleeping = 1.0` does not itself exempt Sleeping Vesta from
custodial staking — that check doesn't look at `mx`. Recommendation: accept the existing mandatory
custody path as-is rather than patching the check to be multiplier-conditional. It's tested,
chain-critical-adjacent code (see §4), and the cost (self-custody isn't available for a Sleeping
leg here) is low given there's no reward reason to want self-custody anyway.

Blessed Vesta's pool placement depends on the open fork in §2.4.

### 3.2 `is-unity` — a new sidecar table, not a new field

**Decided: do not add a field to the existing `SCR|T|Score` schema.** Adding a field to a deployed
table's schema does not retroactively backfill existing rows — `with-default-read` covers an absent
*row*, not an absent *field* (the same rule the deploy-round section of `CLAUDE.md` names for schema
backfills generally). Instead: a brand-new table, `SCR|T|UnityLink`, keyed by `score-id`. New tables
are cheap and safe to add in a module upgrade; this sidesteps the migration entirely.

The chokepoint check becomes a local `with-default-read (SCR|T|UnityLink score-id) {"is-unity":
false} ...` — cheap, local, no cross-module call — before ever considering calling into `UVV`. Only
when `is-unity = true` does the hook call `ref-UVV::XB_UVV|Sync`.

### 3.3 The chokepoint

`AQP-SCORE::XI_2|ApplySingularUserScoreDelta` is the **one** write leaf every stake, unstake,
vacate-nuke, re-rate sweep, and backfill sweep already funnels through, across the whole AQP family,
confirmed by direct trace of the call chains for TF/OF/collectable stake flows and the VCT vacate
unwind. One hook here, not an audit of every VST/ATS/DPTF entrypoint individually — this is what
makes Option B's "every path must push synchronously" condition answerable with a single yes rather
than a survey.

Because booster-driven changes (ANK promile recompute, e.g. KBunnies) and the existing staleness
sweep (`CCp_FvtFixSlice` / backfill) **also** write through this same leaf, Unity inherits the exact
same bounded, self-correcting staleness that every ordinary AQP farm already has today — not a new,
unaddressed risk. The correction automatically reaches `UVV` too, for free, because the chokepoint
is universal.

**Policy question for the owner, not yet decided:** because this score is now chain-wide-critical
(an over-counted weight here dilutes every Unity holder, not just one farm's co-stakers), should the
staleness-sweep cadence/incentive be tightened specifically for unity-linked scores versus ordinary
farms? The mechanism is identical either way; only the urgency differs.

If more than one score ends up feeding UMI (e.g. because the Blessed fork in §2.4 lands as its own
pool/score), **this is not a problem** — `UVV` does not need a "sum of scores" primitive from
`AQP-SCORE`. It accumulates whatever `(account, delta)` pairs arrive, regardless of source
score-entity. Two scores pushing into `UVV` is exactly as valid as one.

### 3.4 Linking / unlinking a score — the critical-score lifecycle

**Linking a score (admin-only, governance-gated):**
1. The new score-id must be **zero** (no stakers / nzs-count = 0) — mirrors the existing precedent
   `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE` uses for structural changes that are only provably harmless
   while nothing has accrued yet.
2. The new score-id must already be **employed in a pool**.
3. Both conditions hold → one governance transaction writes `SCR|T|UnityLink[score-id].is-unity =
   true` **and** inserts the matching entry into `UVV`'s own registry table in the same transaction,
   so the two sides cannot drift apart through ordinary operation.
4. Going forward, every deposit into that pool is already a delta from 0 — `UVV`'s running total
   starts correctly synced, with no backfill/catch-up operation needed.

**Retiring a linked score (admin-only, governance-gated, HEAVY):** the admin registers a
*replacement* score-id (subject to the same zero + pool-employed gate above). This makes the old
score-id no longer critical, but every account's prior contribution recorded under the old score-id
in `UVV` must be zeroed, since only the new score-id's deltas are tracked going forward. **This is a
paginated campaign, not a single transaction** — same shape as VCT's vacate campaign or the re-rate
engine: begin → chunked sweep zeroing old entries, with an in-progress latch → finalize. Not
designed in this pass; named so it isn't improvised later under pressure.

---

## 4. `UVV` — the coin-module vault

### 4.0 Unity is a full coin, not a UrStoaVault-style accounting unit

**Decided: Unity itself is modeled on STOA, not on UR-STOA.** `UrStoaVault`'s weight comes from
users converting STOA into UR-STOA by staking — UR-STOA exists purely as a vault-internal
accounting unit, not meant for ordinary chain-wide transfer. Unity has no equivalent need: its
vault weight comes entirely from the **external** UMI score push (§3.3), never from users staking
Unity itself into `UVV`. So Unity needs the **full STOA-style coin surface** — `C_CreateAccount`,
`C_Transfer`, `C_TransferAnew`, `C_TransferAcross`, `C_Transmit`, `C_RotateAccount` — and **no
UR-Unity companion token at all**. This is new infrastructure: effectively a second `stoa-v2.pact`-
shaped coin module for Unity, not a reuse of STOA's own tables.

### 4.1 Deploy-order constraint (the thing that shapes everything else)

`stoa-v2.pact` (home of `URV|UrStoaVault`/`XM_StoaCoinbase`) is layer-0 genesis infrastructure,
deployed before `1_SOVEREIGN/STAGE_01` exists — it is not part of the numbered `Deploy/1_Pure/`
round. `AQP-SCORE`/`AQP-FVT`/`RPS` are `STAGE_02`, deployed many steps later. Pact resolves module
references at deploy time: a module can only name something already deployed.

Consequence: **`UVV` must be deployed at the same early layer as `stoa-v2.pact`.** It can never call
forward into AQP. Data flows exactly one direction: AQP (deployed later) calls *down* into `UVV` via
an IMC-gated inbound push. The chain-0 coinbase mint/split must live inside `UVV` itself, computed
from a locally-maintained total weight — never fetched from Stage 2.

### 4.2 Cold start — zombie-rewards escrow, not a genesis-seed account

**Decided: do not copy `UrStoaVault`'s genesis-seed pattern** (a permanent 1.0-weight foundation row
with `vault-remaining >= 1.0` enforced at every removal path, forever). `RPS` already generalized
past this: when the denominator is zero, the undistributed amount is parked in `zombie-rewards` and
flushed on the next nonzero-total block (`04_RPS.pact:4412-4471`). Copy that instead. No permanent
fake stake to maintain, no invariant to re-check at every future removal path.

### 4.3 Precision

Carry `rps` at the same high precision `RPS` already proved necessary — `CT_FVT_RPS_PREC = 48`
(`04_RPS.pact:423`) — not `UrStoaVault`'s lossy `floor(amount/vault-score, 12)`
(`stoa-v2.pact:1202`), which floors small injections into a large total to zero. Unity injects every
block into a potentially huge total; this bug is not hypothetical here.

### 4.4 Minting discipline

**Decided: minting happens exactly once, inside the coinbase function, under the magic `COINBASE`
capability.** `C_UVV|Collect` is a pure **transfer** out of `UVV`'s already-minted pot — the same
shape as `C_URV|Collect`'s `C_Transfer URV|KONTO account amount`. Collect never mints. This keeps
mint privilege confined to one function instead of extending it to a client-facing entrypoint.

**Corrected: Collect lives in Stage 1 Talos, not Stage 2.** Collect needs exactly two things —
`UVV` (early-deployed, alongside `stoa-v2.pact`) and DALOS's `kadena-konto` (Stage 1). It has no
AQP/Stage-2 dependency at all, so placing it in Stage 2 Talos would have been an unnecessary
coupling. It belongs in a Stage 1 Talos module (alongside TS01-A/C1/C2/C3/P), deployed earlier, with
the smaller and correct dependency footprint.

### 4.5 `XB_UVV|Sync` — the single most consequential function in this plan

Confirmed risk, sharper than ordinary staleness: Pact has no exception handling. An `enforce`
failure here aborts the whole transaction — and if the failing condition is **global** state (not
per-account), every future call hits the same enforce and fails identically, forever, for every
pool employing the linked score. There is no fix-forward transaction, because any repair write would
itself go through the same broken invariant.

Three non-negotiable design rules, decided:

1. **`XB_UVV|Sync` is a single function taking an ABSOLUTE new score, not a delta, and not a
   stake/unstake pair.** No direction flag — there is no "staking Unity into the vault" concept to
   begin with (§4.0), so unlike `UrStoaVault`'s `Stake`/`Unstake`, one function suffices:
   `(account:string new-score:decimal)`. Internally: `delta = new-score - stored-old-score`,
   `vault-total-score += delta`, store `new-score` as the account's row. This matches the original
   handoff's own §4 sketch exactly (`old := user-supply; set user-supply := new-score — ABSOLUTE
   set, not a delta`). Absolute-set is also the safer property: each call re-anchors to the
   account's true current score, so a missed or double-fired call cannot compound into permanent
   drift the way an accumulating delta could. The caller (`AQP-SCORE`'s chokepoint) already has the
   new absolute value sitting in hand when it writes the row — passing it costs nothing extra.
2. **Minimize enforces to authorization only.** The numeric update itself should be unconditional —
   trust the caller, because `SCORE` already validated the value before sending it. Where a sanity
   bound feels necessary, **clamp and flag to a side table for admin review; do not
   enforce-and-abort.** An anomaly that's visible and contained beats a correctness check that can
   brick staking chain-wide.
3. **Ship a governance-gated, enforce-bypassing force-repair entrypoint from day one.** Not
   speculative — the only way to correct corrupted *data* (as opposed to buggy *code*, which an
   ordinary redeploy fixes) is a write path that doesn't itself depend on whatever invariant is
   broken. Needed before this goes anywhere near the chokepoint, not added reactively after an
   incident.

### 4.6 Payout

Pays native Unity to the account's `kadena-konto` (`DALOS|AccountSchemaV2`, confirmed at
`01_DALOS.pact:835`), read live at collect time, never cached — matches the original handoff's §5
exactly; nothing new here.

### 4.7 Unity's own per-transfer volumetric fee — new code, not inherited from STOA

STOA's own `C_Transfer` has no fee-skim step (`UrStoaVault`'s `Inject`/`Stake`/`Unstake` call
`C_Transfer`/`C_UR|Transfer` plain, no fee). Unity needs this added **fresh** to its own coin
module — there is nothing to clone from STOA here. On every native Unity transfer: compute the
volumetric fee, skim it, and **inject it into `UVV` inline, in the same transaction** — the same
`XB_UVV|Inject` the coinbase function calls once per block, just called again, immediately, from
inside Unity's own `C_Transfer`. This means `XB_UVV|Inject` must be designed from the start to be
called an arbitrary number of times per block (coinbase once, plus once per fee-bearing transfer),
not just once — each call is still O(1) (RPS math never iterates participants), so this doesn't
cost anything architecturally, it's just a design constraint to state explicitly rather than
assume.

### 4.8 Unity bulk-transfer — new, not an extension of `coin.pact`'s existing bulk-transfer

**Confirmed: the existing `C_BulkTransfer`/`C_BulkTransmit` family (`00_StoaSandbox/coin.pact:787-
848`) has zero fee concept today** — signature `(sender, receivers:[string], amounts:[decimal])`,
mechanics are one `(debit sender total)` followed by a `credit` loop (`X_BulkSpend`,
`:1061-1076`), with `UR_BulkTotal`/`UEV_BulkFoldAmounts` (`:605-639`) doing plain positive-sum
validation and nothing else. There's no existing fee-aware bulk path to extend — Unity's
bulk-transfer is new code, modeled on this debit-once/credit-loop skeleton, with fee computation
added **per leg** during the fold, net amounts credited as today, and **one** aggregate
`XB_UVV|Inject` call at the end for the summed fee — not one inject per leg. This is the same
reasoning as point 3 of the user's design: N legs, one inject, not N injects.

### 4.9 Wrapped Unity (LQD) and the DPTF-side fee — periodic sweep, by necessity not preference

**Confirmed: LQD's wrap/unwrap pairs are hardcoded per-asset, not generic.** `12_LIQUID.pact`'s
`C_WrapStoa`/`C_UnwrapStoa`/`C_WrapUrStoa`/`C_UnwrapUrStoa` (`:575-729`) each hardcode their own
native coin-module ref, DPTF-id lookup, and native-move idiom — there is no `asset-id` parameter to
reuse. Unity needs its own near-duplicate `C_WrapUnity`/`C_UnwrapUnity` pair, plus new
`LQD|C_WrapUnity`/`LQD|C_UnwrapUnity` IGNIS price entries by analogy to the existing STOA/UR-STOA
ones (`02_IGNIS.pact:959-962`). This produces wrapped Unity, a DPTF usable in Ouronet (LPs, etc.).

Wrapped Unity carries DPTF's existing default volumetric fee — nothing new there — but **why that
fee needs a periodic sweep rather than inline injection (unlike §4.7's native path) is a real
constraint, not a style choice.** DPTF's fee-on-transfer splits into two components
(`09_TFT.pact:1497-1662`):

- **Secondary fee** — always hardcoded to `DALOS|SC_NAME`, identical for every DPTF token, shared
  code. Forking this per-asset to redirect Unity's share would be a shared-code change affecting
  every DPTF asset in the system — explicitly ruled out.
- **Primary fee** — routes through a **per-asset-id configurable** `fee-target` field
  (`DPTF|S>SET_FEE-TARGET`). This is the lever: **configure wrapped-Unity's primary `fee-target` to
  a dedicated Unity-fee-collector account**, distinct from the shared default. That gives the sweep
  a clean, asset-specific pot to read, without touching code shared by every other DPTF token. The
  secondary-fee portion stays in the generic shared DALOS pot like every other token's — it is
  **not** captured by this mechanism, and shouldn't be chased without a broader (and currently
  out-of-scope) change to shared `TFT.pact` fee-routing logic.

**Decided: the dedicated fee-target account is swept and injected directly as a reward lane into
the Ouronet-side FVT that already employs the UMI score — not via a coin-module Khronoton that
unwraps and dumps into `UVV`.** Both read from the same dedicated account; the difference is
destination. Injecting directly as a `reward-dptf-id` lane keeps the value as wrapped Unity the
whole time (no unwrap step) and makes Ouronet-side mining fees visible as their own trackable
number, which was the explicit reason for preferring this over the coin-module route. This is
buildable with zero conflict against the `is-unity`/`UVV` push: `FVT|ScoreEntityLink` is keyed
`<FVT-ID>|<Score-Entity-ID>`, so the **same** score-entity can already be employed by multiple
independent FVTs simultaneously — the UMI score feeding `UVV` via the chokepoint (§3.3) and the UMI
score being paid a wrapped-Unity reward lane by an ordinary FVT are two fully orthogonal consumers
of the same number, not competing designs.

**Still a periodic job either way** — the dedicated fee-target account accumulates continuously
but nothing drains it automatically; something (a Khronoton on a daily cadence, as proposed) must
trigger the sweep-and-inject. Unlike §4.7's native path, there is no "inline, same transaction"
option here, because the fee lands in generic, asset-agnostic DPTF machinery rather than in code
Unity owns outright.

---

## 5. Build order

**Phase 0 — the Blessed-creation chain (§2.5), strictly sequential, blocks everything in Pipeline
2 that touches a UMI score containing Blessed:**

1. VST: `C_CreateBlessedLink`/`C_Bless`.
2. DPTF/true-fungible layer: new special-link row/case for Blessed.
3. SWP: new exclusion enforce in `SWPI::UEV_Issue`, mirroring AQP's `URC_DptfStakeIsReservedLeg`.
4. AQP pool-matcher: extend `URC_StakeTrueFungibleDptfMatchesPool` to admit the new Blessed prefix.

**Phase 1 — `UVV` and the Unity coin module (§4), independent of Phase 0 and of AQP generally:**

5. `UC_UnityEmission` — camel closed form (unchanged from the original handoff).
6. `URC_Emissions` — 10/90 split, time-driven period index (unchanged).
7. Unity coin module: full STOA-style surface (§4.0) — `C_CreateAccount`/`C_Transfer`/
   `C_TransferAnew`/`C_TransferAcross`/`C_Transmit`/`C_RotateAccount` — plus its own per-transfer
   volumetric fee with inline `UVV` injection (§4.7), and the Unity-specific bulk-transfer variant
   with per-leg fee aggregation and one end-of-transaction inject (§4.8).
8. `UVV` module: vault tables (zombie-escrow cold start + 48dp precision, §4.2–4.3),
   `XM_UnityCoinbase` (chain-0, O(1), magic-`COINBASE`-gated), `XB_UVV|Sync` — single function,
   absolute-set, minimal-enforce, per §4.5's three rules — `XB_UVV|Inject` (callable arbitrarily
   often per block, §4.7), the force-repair entrypoint.
9. Stage 1 Talos: `C_UVV|Collect` (transfer-only from the pre-minted pot, reads DALOS
   `kadena-konto`, §4.4/4.6).
10. LQD: `C_WrapUnity`/`C_UnwrapUnity` + new IGNIS price entries (§4.9).
11. DPTF: configure wrapped-Unity's primary `fee-target` to a dedicated collector account (§4.9).

**Phase 2 — wiring the real score in, once Phase 0 and Phase 1 both exist:**

12. `SCR|T|UnityLink` sidecar table + the chokepoint hook in `XI_2|ApplySingularUserScoreDelta`
    (§3.2–3.3).
13. The Vesta-variant pool(s) — Native/Sleeping/Frozen in one, flat 1.0× multipliers (§3.1); Blessed
    in its own pool/score once Phase 0 lands (§2.4).
14. Link the real UMI score(s) into `UVV` via the governance procedure in §3.4 (zero + pool-employed
    gate).
15. The daily sweep from wrapped-Unity's dedicated fee-target account into the Ouronet-side FVT
    reward lane employing the UMI score (§4.9) — a Khronoton, or equivalent scheduled trigger.
16. Vesta Forge module (§2.4) and the two earning-Farms + Dominance Point collect-time branch
    (§2.1–2.2) — these feed Pipeline 1, independent of exactly when Phase 2's pool goes live, but
    must exist before anyone actually holds Vesta variants to stake.

**Phase 3 — hardening and tests:**

17. The retirement/migration campaign for `UVV`-linked scores (§3.4) — design when first needed,
    same formal shape as VCT vacate / the re-rate engine.
18. Test plan: mirror `[6.2.17]_AQP-RERATE.repl` (the real cross-module integration precedent — NOT
    `[6.2.2]_AQP-SCORE.repl`, which is an intra-module unit suite and does not exercise the
    cross-module push). Needs a new suite exercising the `UVV` chokepoint end to end, plus negative
    tests for the force-repair path, the zero/pool-employed linking gate, and the SWP Blessed
    exclusion.

---

## 6. Open items register

- Where the gitbook's remaining 30% ("vaults") lane goes (§2.1).
- The Dominance Point formula itself — not yet transcribed from the gitbook into a `UC_` function.
- Whether DPTF's fee **percentage** (not just target/destination) is configurable per-asset —
  needed to confirm Blessed's 25% needs no new mechanism, only a setting (§2.4).
- Staleness-sweep cadence/incentive policy for unity-linked scores specifically (§3.3).
- The retirement/migration campaign's exact design (§3.4, §5 item 17).
- The force-repair entrypoint's exact shape and who may invoke it (§4.5).
- The exact scheduling mechanism for the wrapped-Unity fee sweep — Khronoton vs. some other
  permissionless/incentivized trigger (§4.9, §5 item 15).
- REPL coverage plan (§5 item 18).
