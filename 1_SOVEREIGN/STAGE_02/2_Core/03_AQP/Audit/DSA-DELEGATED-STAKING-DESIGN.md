# DSA — Delegated Staking Agencies — Phase-0 design notes

**Module name:** **`DSA`** (Delegated Staking Agencies). New AQP module, layered on the existing FVT two-tier
settle + the existing triplet. Custodians Vault is its first client.

**Status:** 🟡 DESIGN IN PROGRESS — v1 scope agreed with owner; not yet written as a locked doc, no code.
Build order: **(1) streamed inject** (see `STREAMED-INJECT-DESIGN.md`) → **(2) DSA**. This file captures the
design discussion so the next session resumes cleanly.

---

## 1. What it is
A delegated node-staking model (MultiversX staking-agency style) on AQP. Users stake Custodians assets to earn
**quintessence** (a score); a user with enough quintessence opens a **delegation agency** (a pool others stake
into); the operator must run **nodes** to *capture* the agency's reward units and takes a **fee** from delegators.

Custodians concretely: a collection with 3 SFT types (+fragments) — nonce1→**bronze**, nonce2→**silver**,
nonce3→**gold** quintessence (additive); **nonce4 = an anchor that boosts score +5%** (the existing
anchor/boost-class mechanism — no new work). `unit-score` (e.g. 20k) = 1 staking unit = 1 node; open gate =
`unit-score / 2`.

## 2. The architecture resolution (the key unlock)
- **An agency = a user-created MEMBER (score-entity) on the FVT.** Delegators = users within that member. The
  FVT's existing **two-tier farm settle** (global → member → user) already does the inter-agency split (by
  captured units) and the intra-agency split (by quintessence).
- **There is no single shared triplet — one triplet PER agency, all cut from one template.** The FVT owner
  defines the template once (Custodians→bronze/silver/gold mapping, reward tokens + ats-ladder, `unit-score`).
  Opening an agency creates *that operator's own* pool + bronze/silver/gold scores + triplet, registered as a
  member owned by the operator. Agencies are differentiated by pool/triplet id. The reward ladder
  (`FVT|MultipletFamily`, keyed by tokens) is **shared** by all agencies.
- **Custodians is exactly N=3 = the EXISTING triplet.** No N-multiplet generalization needed for v1 (deferred).

## 3. The one real extension to the FVT core — "earns per full units" (capture transform)
Today a member's inter-member weight is its *raw* staked value. DSA needs the member weight to be the **capture**:
```
capture-weight = min( floor(Q_p / unit-score), nodes_p ) × uptime_p / 1000
```
Minimal, deploy-order-safe extension:
- Add **`delegation:bool` + stored `capture-weight:decimal`** on the FVT member.
- At the **single** inter-member weight site (farm-split weight read), branch: normal member → raw value (today);
  delegation member → the stored `capture-weight`. Matching branch at the denominator `S = Σ capture-weight`.
- **The transform math + inputs (`unit-score`, `nodes`, `uptime`) live in `DSA`.** DSA writes `capture-weight`
  onto the member whenever quintessence changes (stake/unstake) or the oracle updates (nodes/uptime), via an
  `XE_` on FVT. FVT only ever *reads its own field* — so the dependency is **DSA → FVT** (allowed; FVT deploys
  first). Computing fresh would need FVT→DSA, a forbidden forward ref — hence the stored field.
- **Topup dilution is native**: `W_i` (inter-member) is floored to whole units, but the intra-member divisor
  stays **raw `Q_p`** — so the leftover (e.g. 5k over a 60k=3-unit capture) dilutes exactly as intended, more
  nodes captured → smaller relative dilution. This is the existing two-axis design (W_i ≠ intra-divisor), free.

## 4. Operator fee
- Flat **1–50%**, skimmed at the member level from **delegators only** (not the operator's own stake). Greenfield
  — no per-member fee/operator exists today.
- Operator is an **ownership role independent of stake**: an operator may withdraw *all* their own stake and still
  run the agency + collect fees; the pool keeps earning on the delegators' quintessence.
- Open gate `unit-score/2` is a **one-time open gate** (operator may drop below afterwards). *(CONFIRM next session —
  owner implied open-only, not a maintained minimum.)*

## 5. Reward modes (all on the triplet)
1. **Direct single-DPTF** — inject X, collect X (today's model). *Secondary gas = Ignis, type-agnostic.*
2. **Homogeneous quality split** — each lane → one token via the existing ATS ladder (bronze→Ouro, silver→Auryn
   via ats-01, gold→EliteAuryn via ats-01→ats-12). Already built (`MULTIPLET_BASE` collect).
3. **Heterogeneous quality split — NEW, in v1.** A **reward-mode flag** (homogeneous | heterogeneous) + a
   **per-type split matrix** stored per heterogeneous reward. Primary example: bronze 20/40/40, silver 40/30/30,
   gold 60/20/20 across Ouro/Auryn/EliteAuryn (rows sum 100%). At collect, the heterogeneous branch splits each
   lane's amount across the 3 tokens per the matrix, routing non-native portions through the same ATS legs. Slots
   into `XI_1|CollectRewards` `MULTIPLET_BASE` as a second branch. *(Matrix storage location — extend
   `FVT|MultipletFamily` vs sibling schema — decide in the doc.)*
- **Primary reward** = 20% of daily Ouro emission, delivered via the **streamed inject** (feature #1).

## 6. External oracle (nodes + uptime)
- Per operator/agency: **`nodes`** (integer) + **`uptime`** promile (min 0.0001, max 1000.0). Full reward needs
  1000.0; uptime scales capture pro-rata that cycle.
- Written by a daily tx (platform automaton using an **FVT-owner-delegated key** to write per-agency values).
  Validity **24-25h**; expired → captures nothing. **Optional toggle** per FVT: if off, capture = units (no node
  check) and uptime defaults 100%; if no uptime submitted while on → default 100%. *(CONFIRM exact expiry +
  auth mechanics in the doc.)*

## 7. Royalty pool
- The uptime shortfall (up to 1000.0 minus actual) does **not** pay the delegators. It accrues to the FVT
  **royalty pool** → FVT owner **withdraws** (if `capture:bool`) or it's **burned** on inject (DPDC has an
  autonomous burn role). Fuel-target redirection (below) is the deferred alternative to withdraw/burn.

## 8. DEFERRED to later iterations (provision hooks now, build later)
- **Elite-tier fee reduction + deferred-fee benefit + Vesta conversion.** Recorded curve for later:
  operator tier reduces the fee **~10%/major** (tier 7 → 70%, 1%→0.3%); the **participant's** tier further
  reduces *that* multiplicatively (2 majors → −20%, 0.3%→0.24%). Distinct from SWP's 7%/major, so a **custom
  curve**. Meaningless without the "operator benefits from the deferred %" mechanism: the deferred fee % is
  collected from the participant but **swapped into an earning token (Blessed Vesta)** and given to **both**
  operator and participant — so a high-tier operator earns *and* earns for delegators. Needs **Vesta** infra
  (upcoming: virtual-mining LP token, variants Native/Sleeping/Frozen/Blessed → Unified Mining Index → Unity).
  v1 = flat fee, collected normally; fee field + a **fuel-target hook** stubbed.
- **Fuel-target / fee-redirection** — general mechanic: an injected token may designate fuel targets; deferred
  fees + uptime-shortfall route there (swap→frozen-stakable token, or fuel a pool = add liquidity without minting
  LP). Provision the config hook; implement later.
- **Collateral / slashing** — EliteAuryn collateral burned on misbehavior (per-node? TBD). May not exist at all.
- **N-multiplet** — generalize triplet → N (positional-3 schemas/keys/lane-math/2-hop-ladder → list-valued).
  Not needed for Custodians (N=3).

## 9. v1 scope (agreed)
`DSA` module: open-agency (user-created member, `unit-score/2` open gate, operator + flat fee) · capture transform
(FVT `delegation`+`capture-weight` extension) · oracle {nodes, uptime} (daily, 24-25h expiry, optional toggle,
default 100%) · royalty pool (withdraw/burn) · reward modes: direct Ignis + homogeneous + **heterogeneous split** ·
daily Ouro via the **streamed inject**. **Deferred:** N-multiplet · elite-reduction+Vesta · fuel-targets ·
collateral.

## 10. Reuse pillars vs new-builds (grounded in code, from the 3 investigation traces)
**Reuse (confirmed):**
- Triplet: `SCR|Triplet` (3 positional score-ids), created by `C_IssueTriplet` (`02_SCORE.pact:2993`) — already
  **owner-gated** (a user who owns 3 matching scores bundles them), so user-created bundles have precedent.
- Reward ladder: `FVT|MultipletFamily` (`04_FVT.pact:345`, tokens + 2 ATS legs; `rank` field says "v1 = 3").
- Two-tier settle: `XI_1|FarmSplitInject` (`04_FVT.pact:4469`, member weight read fresh at ~`:4496`, denom
  ~`:1935-1951`) + `XI_2|BankUserTier1Pending`. **W_i and the intra-member divisor are distinct axes** → the
  capture/topup split is native.
- 4th-nonce boost = existing anchor/boost-class (+5%).
- Elite fee reduction (for the deferred phase): `URC_EliteFeeReduction` (`16_SWPI.pact:587`) →
  `UC_GasCost`/`UC_GasDiscount` (`08_U_DALOS.pact:182`), `discount% = 7*(major-1)+minor`, cap 49% — mirror pattern.

**Genuine new-builds:**
- User-created member admission (today: `score-owner == fvt-owner`, `04_FVT.pact:2722/2740/2790` — relax so member
  owner = operator).
- Per-member operator + fee (none exists today).
- Capture-weight field + branch at the FVT weight site (§3).
- Heterogeneous split branch + matrix (§5.3).
- The `DSA` module: agencies, oracle, royalty, (stubbed) fuel-targets.

## 11. Open items to confirm next session
- Half-unit open gate: one-time vs maintained minimum (§4).
- Heterogeneous matrix storage (extend `MultipletFamily` vs sibling schema).
- Oracle exact expiry window + the FVT-owner-delegated write auth.
- `capture-weight` recompute triggers (stake/unstake + oracle) and their gas.
- Interface/deploy-order for the FVT `XE_` that DSA calls to write `capture-weight`.

*Design discussion 2026-08-23. Resume: streamed inject first, then DSA Round A (agency + capture + FVT extension
+ oracle + royalty), Round B (heterogeneous split matrix).*
