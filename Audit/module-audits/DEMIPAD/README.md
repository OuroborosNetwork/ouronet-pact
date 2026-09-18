# DEMIPAD Audit — scope + methodology

The last unaudited Ouronet core module set. Audited on `main` (no worktree), 2026-08-29.
Same structure as the ATS / DPDC / SWP / DALOS / AQP audits.

## Module set (6 modules, 3,664 lines — the smallest core)
| Module | Lines | Role |
|--------|------:|------|
| `00_Demipad.pact` | 1298 | Permissioned launchpad core (Demiourgos.Holdings): register asset, toggle open-for-business, define price, deposit/withdraw, transmit TF/OF/SF/NF, dollarz-raised, retrieval |
| `05_STOAICO.pact` | 739 | STOA ICO — staking vault with RPS reward distribution (inject / stake / unstake / collect; score/supply/NZS/RPS/pending) |
| `01_Spark.pact` | 543 | Spark token sale + redemption (buy, redeem-all/few, custom redemption) — bonding-curve pricing |
| `04_STOICPAY.pact` | 417 | StoicPay (KPAY) sale — per-period buy cap |
| `03_Custodians.pact` | 351 | Ouronet Custodians collection sale (acquire; quintessence price) |
| `02_Snakes.pact` | 316 | Demiourgos ShareHolder collection sale (acquire; share price) |

Handles **KDA payments** (native + non-native/wstoa), **token custody**, **bonding-curve pricing**,
and **RPS reward math** — a rich attack surface for its size.

## Methodology
1. **Round-01 — lens fan-out.** 6 independent read-only audit lenses (below), each hunting one
   dimension across the relevant modules. → candidate findings.
2. **Adversarial verification.** Each candidate finding is re-checked against the code by an
   independent validator (CONFIRMED / REFUTED / STYLISTIC) before it reaches the owner.
3. **Owner verdicts** on the ranked CONFIRMED findings → `ROUND-01-OWNER-FEEDBACK.md`.
4. **Round-02 fixes** with diffs + REPL proof → `ROUND-02-FIXES.md`; `Z.repl` + `AQP-comprehensive`
   green-gate after each.
5. **Ranked index** → `ISSUES-RANKED.md`; final consolidated report → `FINAL-AUDIT-REPORT.md`.

## Round-01 lens roster
1. **Access-control / capability / authorization** — A_/C_/XE_/XB_ gates, custody-withdraw + transmit
   ownership, buyer/redemption-payer/beneficiary signatures, defcap authorization completeness.
2. **Arithmetic / precision / rounding / payment-math** — bonding curves, KDA quotes, RPS math,
   div-by-zero, rounding-direction value leaks, cap off-by-one, dust conservation.
3. **Economic / MEV / sale-accounting** — price-update front-running, caps, dollarz-raised, refund/
   redemption fairness, native-vs-wstoa pricing, inject-then-unstake skims.
4. **STOAICO reward-distribution deep-dive** — settle-before-score ordering, inject-with-zero-stakers,
   RPS ordering, pending/NZS/unclaimed drift, last-claimant dust, post-inject stake.
5. **Custody / state-lifecycle / asset-integrity** — sale-before-register/price/open, deposit/withdraw
   accounting, fuel-or-retrieve routing, 4-kind transmit guard parity, register idempotency.
6. **StoicSyntax conformance + cross-module boundary** — XI-enforces-vs-defcap, missing UEV_IMC,
   modref vs dot-ref, near-twin sale-module divergence, OutputCumulator/gas wiring.

## Status
- [ ] Round-01 lens fan-out (in progress)
- [ ] Adversarial verification of candidates
- [ ] Owner verdicts
- [ ] Round-02 fixes + green-gate
