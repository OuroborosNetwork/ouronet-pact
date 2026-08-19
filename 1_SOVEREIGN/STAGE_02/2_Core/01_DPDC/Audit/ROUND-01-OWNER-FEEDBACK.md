# ROUND I — Owner feedback (DPDC modules)

**Status:** living, append-only. One entry per finding, added the moment a verdict is reached (see the
HARD RULE in `README.md`). Entries are presented in `ISSUES-RANKED.md` order, one finding at a time.

## #1C · DPDC-C · C1 — mint supply from nothing via negative `amount`

**Verdict: CONFIRMED (2026-08-19)** — owner required a live REPL reproduction before accepting, per the
same discipline as SWP's C1/C2. Reproduced exactly as described: a real, signed `DPSF|C_TransferNonces`
call with one legit leg + one negative-amount leg minted 50 units into the sender's own balance and drove
the receiver's balance to -50, transaction reported success. First single-leg reproduction attempt was
blocked by an unrelated IGNIS gas-fee guard (negative fee also rejected) — not real protection, trivially
routed around by padding the tx with one legitimate leg, which is exactly what the successful repro did.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — two-layer fix, no interface changes:
`DPDC-T::UEV_AmountsForTransfer` now enforces `amount > 0` for every transfer leg (closes `C_Transfer`/
`C_BulkTransfer` and, as a side effect, DPDC-F's C2); `DPDC-C::CreditOrDebitDPDC` (the universal
credit/debit write chokepoint for all 11 peer modules) now enforces `amount >= 0` (not `>0` — a first pass
at `>0` broke EQUITY's legitimate zero-initial-supply tier-nonce genesis, caught by the test suite and
corrected). Post-fix: exact exploit call now hard-aborts, balances unchanged; a control legit transfer
still works; full `Z.repl` pipeline green. Surfaced (but did not cause, and did not fix) a pre-existing,
unrelated crash in `[6.1]_DPDC.repl`'s NFT transfer test — confirmed via `git stash` to exist identically
on unfixed code; logged for later triage, not blocking this fix.

**Bonus:** the DPDC-C-layer fix also closes the mint/return half of DPDC-S's **C8** (`how-many-sets`
unbounded) for negative values — C8 stays OPEN pending its own explicit gate at the `DPDC-S|C>MAKE`/
`C>BREAK` cap layer (defense-in-depth + a clearer error), but the underlying exploit path is already shut.
