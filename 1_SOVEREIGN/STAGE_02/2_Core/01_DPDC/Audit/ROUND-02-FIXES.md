# ROUND II — Fixes (DPDC modules)

**Status:** IN PROGRESS. Fixes are applied **sequentially**, one at a time, only after the owner
green-lights the specific finding in `ROUND-01-OWNER-FEEDBACK.md`. Each entry below carries: the finding
ID, the diff summary, the why, and the REPL proof (pre-fix repro + post-fix pass, adversarially reverted
and reconfirmed where feasible) — mirroring `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ROUND-02-FIXES.md`.

## Fix #1 — DPDC-C · C1 (mint supply from nothing via negative `amount`)

**Owner-approved 2026-08-19** after live REPL reproduction of the exploit (required before any code change,
per the same discipline as SWP Fix #2).

**Pre-fix reproduction:** `REPL/Kursan/_verify_finding_DPDC-C_C1_negative_amount.repl`. A real, signed
`DPSF|C_TransferNonces` call (ANHD → Emma, legs `[nonce1=100 (legit), nonce2=-50 (exploit)]`, the legit leg
included specifically to keep the transaction's own aggregate IGNIS fee positive — a single negative-only
leg is separately blocked by an *unrelated* IGNIS gas-fee guard, which is not real protection since it's
trivially routed around by padding the tx with one legitimate leg) — **succeeded** pre-fix:

| | nonce 1 | nonce 2 |
|---|---|---|
| ANHD before → after | 10,000 → 9,900 (correct) | 1,000 → **1,050** (sender gained 50 from "sending" -50) |
| Emma before → after | 0 → 100 (correct) | 0 → **-50** (receiver driven negative) |

**Root cause:** no layer between the public transfer entrypoint and the ledger write enforced
`amount > 0`. `DPDC-T::UEV_AmountsForTransfer` only bounded native-NFT amounts (`=1`); SFT/fragment amounts
passed through unchecked. `DPDC-C::CreditOrDebitDPDC` (the single function every SFT/fragment credit *and*
debit — across all 11 peer modules — funnels through before touching `AccountSupplies`) computed
`new-supply = current ± amount` with no sign check at all.

**Fix — two layers, no interface/signature changes:**
1. `07_DPDC-T.pact:518` — `UEV_AmountsForTransfer` (the per-leg validator composed into both
   `DPDC-T|C>TRANSFER` and `DPDC-T|C>BULK-TRANSFER`, i.e. every `C_Transfer`/`C_BulkTransfer` call, single
   or plural): added `(enforce (> amount 0) "Transfer amount must be a positive, non-zero integer")`.
   Closes `C_Transfer`/`C_BulkTransfer`/`C_TransferNonce(s)` — and, as a side effect, **DPDC-F's C2**
   finding too (`C_MakeFragments`/`C_MergeFragments` route their constituent leg through this exact same
   cap).
2. `03_DPDC-C.pact:890` — `CreditOrDebitDPDC` (the universal write chokepoint for every SFT/fragment
   credit or debit, reached by DPDC-T, DPDC-S, DPDC-F, DPDC-MNG, and EQUITY alike — including
   `C_RepurposeCollectable`/`C_RepurposeCollectableFragments`, which bypass DPDC-T's transfer cap entirely
   via `wipe-mode`): added `(enforce (>= amount 0) "Amount cannot be negative")`. Deliberately `>=0`, not
   `>0` — see below.

**Adjustment made mid-fix (caught by the test suite, not guessed):** the first pass used `> amount 0` in
`CreditOrDebitDPDC` and broke `EQUITY::C_IssueShareholderCollection` at genesis — it legitimately creates
several "package tier" SFT nonce *types* with **zero** initial supply (the token type exists; nothing's
minted into it until someone later packages shares into that tier). Zero is a real no-op
(`supply ± 0 = supply`, no value created or destroyed) and is unrelated to the actual exploit, which
specifically needs a *negative* number to flip the arithmetic's sign — so the DPDC-C-layer check was
narrowed to `>= 0` (blocks negative only) while the DPDC-T transfer-specific check stays at `> 0` (a
transfer of exactly 0 units is never legitimate, so it's rejected there).

**Post-fix proof (same script, updated to assert the new behavior):**
- The exact pre-fix exploit call now hard-aborts at `UEV_AmountsForTransfer` (`Transfer amount must be a
  positive, non-zero integer`), and the whole transaction rolls back — all four balances (ANHD nonce1/2,
  Emma nonce1/2) confirmed unchanged after the rejected attempt.
- A control legit transfer (ANHD → Emma, nonce1, amount=25) still succeeds and posts the correct balances
  (10,000 → 9,975 / 0 → 25) — the fix doesn't break real usage.
- `cd REPL && pact Z.repl` (full default pipeline: Kadena/Stoa sandboxes → Stage 01 → Stage 02, including
  EQUITY's zero-supply tier-nonce genesis) — clean, `Load successful`, no regressions.

**Known pre-existing, unrelated issue surfaced during regression testing (not caused by this fix, not
fixed by this fix):** `REPL/Stage_02/[6.1]_DPDC.repl` (the comprehensive DPDC suite, not part of the
default `Z.repl` pipeline) hard-aborts partway through its "TX 007 -- SFT Transfer Tests" block
(mislabeled — the failing call is actually `DPNF|C_TransferNonce` on the `DHN-98c486052a51` NFT collection)
with `No value found in table ... DPNF|T|Nonces for key: DHN-98c486052a51|1`, tracing back to
`UEV_AmountsForTransfer`'s own `nonce-supply` binding (flagged separately in Round I as dead/unused —
apparently still eagerly evaluated even though unused, so a missing row there throws regardless). Confirmed
via `git stash` that this crash is **identical on the untouched pre-fix source** — it is not a regression
from this fix and blocks a full end-to-end run of `[6.1]_DPDC.repl` independent of anything changed here.
Logged as a new item for the backlog (not yet numbered/triaged) rather than folded into this fix.

**Interface implication:** none — both changes are `enforce`s added inside existing function bodies; no
`DpdcCreateV1`/`DpdcTransferV1`/`DpdcV1` signature changes.

**Bonus closure:** this fix's DPDC-C layer also closes the credit/debit-mint half of **DPDC-S · C8**
(`how-many-sets` unbounded) for its negative-value exploit path — `C_MakeSemiFungibleSet`'s mint leg
(credit on the new set nonce) and `C_BreakSemiFungibleSet`'s constituent-return leg both route through
`CreditOrDebitDPDC`, and the constituent debit leg routes through `DPDC-T::C_Transfer`. C8 stays **OPEN**
pending its own explicit `(enforce (> how-many-sets 0) ...)` at the `DPDC-S|C>MAKE`/`C>BREAK` cap layer for
defense-in-depth and a clearer error message — this fix only closes the exploit at the lower layer, it
doesn't add the higher-layer validation the finding recommends.
