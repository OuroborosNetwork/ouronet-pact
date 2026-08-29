# DEMIPAD Audit — Ranked Issue List

Worked **one at a time**: discuss → agree fix → implement + REPL-prove → green-gate → next.
No batch fixing. IDs are stable. Full detail per issue in `ROUND-01-FINDINGS.md` (D# cross-ref).

Status: `OPEN` (not yet discussed) · `DISCUSSING` · `AGREED` (fix locked, not yet coded) ·
`FIXED` (implemented + proven) · `WONTFIX` (owner declined) · `INTENT` (needs owner decision first).

| # | Sev | Module | Issue | D# | Status |
|---|-----|--------|-------|----|--------|
| **#1C** | CRITICAL | STOAICO | `C_Collect` is drainable — non-idempotent + `unclaimed-count==1` pays the whole vault | D#1 | **FIXED** |
| **#2H** | HIGH | Demipad | `retrieval` toggle is dead state — the anti-rug lock is never enforced | D#2 | **FIXED** |
| **#3H** | HIGH | Custodians | `C_Acquire` never opens `CUSTODIANS|ACQUIRE` — supply cap + policy caps dropped | D#3 | **FIXED** |
| **#4H** | HIGH | Custodians | calls non-existent `GOV|LAUNCHPAD|SC_NAME` → runtime unbound (should be `GOV|DEMIPAD|SC_NAME`) | D#4 | **FIXED** |
| **#5M** | MEDIUM | STOAICO | `A_Inject` div-by-`vault-score` no zero-guard (+ floor-to-0 under-distribution) | D#5 | **FIXED** |
| **#6M** | MEDIUM | STOAICO | urSTOA double-credited across stake rounds (re-mints claimed urSTOA, over-spends cap) | D#7 | OPEN |
| **#7M** | MEDIUM | Demipad | NF transmit guarded by the SF cap (NF can't move; SF-as-NF type mismatch) | D#8 | OPEN |
| **#8M** | MEDIUM | Demipad | `direct-injection` credits withdrawable funds with no tokens in (phantom funds; latent) | D#9 | INTENT |
| **#9M** | MEDIUM | Custodians | `UC_NonceQuintessence` (declared pure) enforces | D#10 | OPEN |
| **#10M** | MEDIUM | Custodians | `UR_NonceSaleAvailability` enforces (twin Snakes does not) | D#11 | OPEN |
| **#11M** | MEDIUM | STOICPAY | 2× KPAY out per sale vs `sold = 100M − 0.4·resident` accounting | D#6 | INTENT |
| **#12M** | MEDIUM | all sales | no on-chain slippage/max-cost bound on buys | D#12 | INTENT |
| **#13L** | LOW | STOAICO | `unclaimed-count`/`nzs-count` no lower bound (mostly subsumed by #1C) | D#13 | OPEN |
| **#14L** | LOW | STOICPAY | fractional team-split for buys not divisible by 4 (KPAY-decimals dependent) | D#14 | OPEN |
| **#15L** | LOW | Snakes/Cust/STOAICO/Spark | missing `UEV_IMC` on several `C_` entrypoints | D#15 | INTENT |
| **#16L** | LOW | Demipad | `open-for-business` reject `format` has a placeholder but no arg | D#16 | OPEN |
| **#17L** | LOW | Demipad | interface omits `URC_Acquire`/`URCI_Acquire` (refuted as blocker) + `URCI_` mis-prefix | D#17 | OPEN |

**Total: 17 issues — 1 Critical · 3 High · 8 Medium · 5 Low.**

Cross-cutting theme: **Custodians (#3H, #4H, #9M, #10M) is a half-wired copy of Snakes** — likely to be
reconciled as one coherent pass once its individual issues are agreed.
