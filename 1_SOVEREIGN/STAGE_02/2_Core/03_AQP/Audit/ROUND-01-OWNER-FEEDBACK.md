# ROUND I — Owner feedback & verdicts

**Date:** 2026-08-11 · Captures Mihai's Round I verdicts on `ROUND-01-FINDINGS.md`, plus the **new
StoicSyntax rules** decided during feedback. Append-only. Fixes happen in Round II, sequentially,
one at a time, each green-lit before the next.

## Per-finding verdicts

### ANK
- **H4 (revoke → stale aggregate)** — **CONFIRMED, needs design.** Cannot mass-update 10k users on revoke.
  Two acceptable directions: **(A)** a lazy method that is *still mathematically correct* (no mass update),
  or **(B)** disallow revoking an anchor that's used by ≥1 score — to truly revoke you must first flush all
  stakers via the Vacate module (which updates scores correctly; that's why vacate is expensive + UI-built +
  multi-tx). Owner asked for a better way if one exists. → **Lead to propose A vs B when we reach it.**
- **M6 (TF promile pro-rate)** — **CODE IS CORRECT; README IS WRONG.** 500 promile / 1000 dptf, stake 2500
  → 500+500+250 = **1250** is the intended result (pro-rate). SF/NF are whole-step because they're nonce-count
  based — different asset model, both correct. → **DOC-FIX README_ANK:130.** Separately: the "1000 cap" is
  about the **definable promile** (owner shouldn't set e.g. 1230). Owner: *there shouldn't be caps on results,
  but sane definition limits are fine.* → **NEW GUARD:** cap anchor **promile ≤ 1000** and **dptf-amount ≤ 1,000,000**
  at issue **if not already enforced** (verify first).
- **L4 (revoke liveness gate)** — **CONFIRMED.** Add `UEV_LiveAnchor` to the revoke cap.
- **L5 (XE returns IGNIS cumulator)** — **NOT A BUG → new convention.** X functions may return IGNIS
  cumulators when flow complexity makes it the clean choice. Mark such functions with `<cm>` after the first
  capital: `XI-cm_`, `XE-cm_`, `XB-cm_` (with tier: `XI-cm_1|Name`). → StoicSyntax rule **R1** + rename refactor.
- **L6 (SF/NF no negative floor)** — **CONFIRMED.** Implicitly protected (can't take out more than brought in),
  but add a hard `enforce`/floor to be safe.
- **Invariants OK** — confirmed.

### POOL
- **H2 (mid-vacate stake reopen)** — **CONFIRMED.** Owner must not re-open stakes during vacate.
- **M5 (OF/collectable non-self stake stuck)** — **CONFIRMED, must fix.**
- **L1 (`enforce` in a `URC_`)** — **CONFIRMED.** URC = read+compute only; if it enforces it must become a `UEV_`.
- **L2 (one X writes two tables)** — **NOT A BUG → allowed.** → StoicSyntax rule **R2** (multi-table X permitted).
- **L3 (`select`/URD on sync path)** — **CONFIRMED as principle** (no URD in C_/A_ or their deps), **but** some
  constructions genuinely can't avoid it (e.g. a full-vacate meant to fit one tx). Must be avoided at all costs
  and never on a daily-hot path. When unavoidable, the `C_`/`A_` (and deps) are **HEAVY** and must be renamed
  `CC_`/`AA_` for instant observability. → StoicSyntax rule **R3** + rename refactor.
- **Invariants OK** — concur.

### SCORE (SCR)
- **H1 (LP base delta → negative)** — **CONFIRMED, bad.** Owner asks for a fix approach. → **Lead proposal:**
  pin the **stake-time lp-denominator equivalent** per position so unstake subtracts exactly what stake added
  (symmetric → base returns to 0), + floor-at-zero as a safety net.
- **M3 (boost-class promile <1000 zeros rewards)** — **CONFIRMED, must fix.** Owner asks how. → **Lead proposal:**
  make boost **additive over 1000**: `boosted = floor(base·(1000+prom)/1000, p)` so 0 anchor promile → boosted=base
  (anchors add on top), instead of `base·(prom/1000)` which zeros at prom=0.
- **M4 (links/deb-boost settable after positions)** — **CONFIRMED, needs fixing.** Enforce `nzs-count==0`
  (or totals==0) in the link/deb-boost caps.
- **H5 (URD select on settle hot path)** — **CONFIRMED, absolute no-go.** Stake/unstake/collect/inject cost must
  NOT scale with pool size. Replace with an equivalent maintained-aggregate logic path.
- **L7 (mutable defs → asymmetric delta)** — **CONFIRMED, bad, shouldn't occur.** There's a manager
  stop-stake→define→enable mechanism; owner unsure if it fully protects. → **Investigate** whether stop-stake
  closes it; add a guard if not.
- **L8 (X trailing returns)** — **NOT A BUG → allowed.** X may end in whatever it outputs; if it outputs
  something specific, **document it in `@doc`**; only IGNIS-cumulator output is reflected in the name (via `-cm`,
  R1). → StoicSyntax rule **R4**.
- **Invariants OK** — concur.

### FVT
- **C2 (inject conservation / insolvency)** — **CONFIRMED CRITICAL, highest order.** Must fix the ordering.
- **M1 (dust sweep missing)** — **CONFIRMED.** Make it dust-proof (implement the `unclaimed-count==1` sweep).
- **H5/#3 (triplet select on hot path)** — **CONFIRMED** (same as SCR H5). No URD on stake/unstake/inject/collect.
- **M2 (vault/treasury inject keys-scan in defcap)** — **CONFIRMED, no-go.** Fix while preserving inject logic
  (maintain a per-FVT deb-sum aggregate; point-read it).
- **L10 (double member-settle)** — **CONFIRMED.** Remove the redundant settle (needless cost).
- **Invariants OK** — concur.

### VCT
- **C1 (unbound OF/DPSF/DPNF vacate legs)** — **CONFIRMED CRITICAL, absolutely needs fixing.**
- **H3 (finalize re-enables pool-wide, no cross-stream check)** — **CONFIRMED.** LP dual-stream (TF-LP + OF-LP)
  needs an on-chain guard.
- **H3b (write-only finalize with remaining inventory)** — **CONFIRMED, must be fixed** (on-chain remaining-count check).
- **L9 (dead `VACATE-MAX-LEGS`=16 + unused parity helper)** — **CONFIRMED.** Remove vestigial/misleading code.

## New StoicSyntax rules decided (to add — Ouronet-specific)

Owner wants all Ouronet-specific rules consolidated into **one chapter** in `StoicSyntax.md` (gather any that
are currently scattered), then refactor the code to honor them.

- **R1 · `X-cm_` naming.** X functions (`XI`/`XE`/`XB`) that return an IGNIS `OutputCumulator` (allowed when
  it simplifies a complex flow) are named with `<cm>` after the first capital: `XI-cm_`, `XE-cm_`, `XB-cm_`,
  tiered `XI-cm_1|Name`. The name signals "this X emits an IGNIS cumulator."
- **R2 · Multi-table X allowed.** A single X function may write to more than one table.
- **R3 · `CC_`/`AA_` HEAVY prefixes.** A `C_`/`A_` (or any of its deps) that unavoidably uses a `URD_`/scan is
  HEAVY and must be renamed `CC_`/`AA_` for instant observability. Avoid at all costs; never on a daily-hot path;
  allowed only where genuinely unavoidable (e.g. a single-tx full-vacate attempt).
- **R4 · X `@doc` output rule.** X functions that return a specific value must document what they output in
  `@doc`; only IGNIS-cumulator output is additionally reflected in the name (R1).
- **R5 · Consolidate** all Ouronet-specific rules into a single dedicated chapter in `StoicSyntax.md`.

## Owner's meta-note (captured)

Pact is auditable by reading: a careful reader can predict failure events (negative deltas, vault insolvency,
reward-conservation breaks) from the written logic alone — REPL testing confirms but only catches these *if all
possibilities are actually exercised*. The AQP modules grew too complex to hold entirely in one human's head,
which is why this audit was delegated. Implication for the final sign-off: the Round III re-verify must
**enumerate the possibility space per path** (do X→Y→Z → result P, correct because …), not just rely on green tests.
