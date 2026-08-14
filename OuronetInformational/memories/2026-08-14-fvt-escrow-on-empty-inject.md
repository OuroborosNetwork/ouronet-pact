# FVT escrow-on-empty inject (zombie / limbo rewards) — 2026-08-14

**Owner-directed behavior change** to the AQP-FVT inject primitive (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_FVT.pact`).

## What changed

Previously an inject on a pool with a **zero** inject denominator (no stakers) **reverted**
(`UEV_InjectContext` required `denominator > 0` for vault/treasury; the `C_Inject` body required
`s-fresh > 0` for farms). Both guards are **removed**. A zero-total inject now **succeeds** and the
amount is **held in escrow** — physically in `AQP|SC_NAME` custody (the PHASE 1.1 transfer already runs
unconditionally), counted in a new field, and distributed later.

## The invariant

- New field: `zombie-rewards:decimal` on `FVT|RPS|Global` (key `fvt-id | reward-dptf-id`).
- **Zero inject** (denominator = 0): `zombie += amount`. `G` and `available-rewards` are **untouched**.
- **Flush** (next inject at denominator > 0): `R_eff = amount + zombie` is distributed to whoever is
  staked **at that instant** (vault: `G += R_eff / deb-sum`; farm: split-at-inject over fresh S), then
  `available-rewards += R_eff` and `zombie → 0`. **Not** the first arriver — the current cohort.
- **No owner reclaim.** Escrow only ever leaves via a normal non-zero inject.

## Why zombie is its own field (correctness pin)

The M1 (#10) last-claimant dust sweep pays the sole remaining claimant the **entire** `available-rewards`.
If the escrow were folded into `available-rewards`, a prior cohort's last claimant could sweep the pending
escrow. Keeping it in a separate `zombie-rewards` field — and only moving it into `available-rewards` at the
flush — makes that impossible. Custody always covers `available-rewards + zombie`; conservation holds.

## Both inject paths carry it

`C_Inject` (PHASE 2+3) **and** `XI_FvtInjectCore` (the shared vault/treasury core used by `CC_Inject` and the
`MTX|n|C_Inject` defpact) implement the identical escrow/flush branch. Removing the `UEV_InjectContext`
denominator guard means the enforced-fresh paths (`CC_Inject`/MTX) also escrow on an empty vault instead of
bumping `available-rewards` with an undistributed amount.

## Proof

`REPL/deb-staleness-proof.repl` `TX-AQP-DEB10` (CodingDivisionTreasury, class 1, reward Wstoa): empty the vault
(unstake ANHD + LUMY) → inject 10+15 at zero (no revert; zombie 0→25; G/available-rewards frozen) → re-stake
ANHD (sole staker, denom 500) → inject 5 flushes (zombie→0) → ANHD collects **exactly 30 Wstoa** (5 flush + 25
escrow). Gates: golden 33/0, Z 225/0, deb-proof 121/0.

Full write-up: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/ROUND-02-FIXES.md` (§ *Feature — FVT: escrow-on-empty inject*).
