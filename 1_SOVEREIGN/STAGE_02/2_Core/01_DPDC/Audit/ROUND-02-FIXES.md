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
`amount > 0`. `DPDC-C::CreditOrDebitDPDC` — the single function every SFT/fragment credit *and* debit
across all 11 peer modules funnels through before touching `AccountSupplies` (confirmed: it's the only
caller of `XE_W|Supply`) — computed `new-supply = current ± amount` with no sign check at all.

**Design decision (owner):** originally landed as two redundant layers (this chokepoint plus a duplicate
check in `DPDC-T::UEV_AmountsForTransfer`). Owner asked whether a single location would have been
sufficient and, once confirmed yes, asked for the redundant layer removed — **the fix is the single
chokepoint below, nothing in `07_DPDC-T.pact` was touched.**

**Fix — one location, no interface/signature change:**

`03_DPDC-C.pact` — new `UEV_Amount` function, grouped with the file's other `UEV_*` validators (right
after `UEV_HybridNonces`), called as the first statement of `CreditOrDebitDPDC`'s body:

```pact
(defun UEV_Amount (amount:integer)
    @doc "Floor for every SFT/fragment credit or debit quantity. Zero is legal (nonce-creation \
        \ genesis supply, e.g. EQUITY's zero-initial-supply tier nonces) — negative is never legal, \
        \ it inverts the credit/debit direction in CreditOrDebitDPDC. See DPDC Audit #1C."
    (enforce (>= amount 0) "Amount cannot be negative")
)
```
```pact
;; inside CreditOrDebitDPDC, replacing what was previously a bare inline `enforce`:
(UEV_Amount amount)
```

Placed in a proper `UEV_*` function (not a bare `enforce` sitting in an unprefixed helper) per owner
direction — "prefix is the contract" per StoicSyntax; a raw `enforce` inside `CreditOrDebitDPDC` (which
carries no `UC_`/`UEV_`/`XI_`/etc. prefix at all) doesn't self-document as a validation point the way a
named `UEV_*` call does.

**Why one location is enough, including for the list form:** `MappedCreditOrDebitDPDC` (the plural
entrypoint, `amounts:[integer]`) is a `map` over `CreditOrDebitDPDC` — one call per list element, no
separate code path. `UEV_Amount` runs once per element automatically; no additional plumbing was needed
for the list case. And because `CreditOrDebitDPDC` is the *only* path to `XE_W|Supply` for every SFT/
fragment credit or debit — reached by DPDC-T transfers, DPDC-S set-make/break, DPDC-F fragment make/
merge/repurpose, DPDC-MNG wipes, and EQUITY package shares alike, including paths like
`C_RepurposeCollectable(Fragments)` that bypass DPDC-T's transfer cap entirely via `wipe-mode` — a check
here closes the exploit for every caller, present and future, with no per-module duplication required.
(Native NFT credit/debit never reaches this function at all — it hardcodes supply to 0/1 via a separate
function regardless of `amount`, so it was never part of this vulnerability and needs no check.)

**Adjustment made mid-fix (caught by the test suite, not guessed):** the first pass used `> amount 0` and
broke `EQUITY::C_IssueShareholderCollection` at genesis — it legitimately creates several "package tier"
SFT nonce *types* with **zero** initial supply (the token type exists; nothing's minted into it until
someone later packages shares into that tier). Zero is a real no-op (`supply ± 0 = supply`, no value
created or destroyed) and is unrelated to the actual exploit, which specifically needs a *negative* number
to flip the arithmetic's sign — narrowed to `>= 0` (blocks negative only, allows the legitimate zero case).

**Post-fix proof, methodology note:** the first proof draft wrapped the exploit call in `expect-failure`
(a Pact REPL TEST-ONLY construct) inside a larger transaction that continued afterward. That produced a
misleading intermediate reading — `expect-failure` catches the error so the script can keep running, but
does **not** model real transaction atomicity, and left the exploit's legit-looking first leg's write
sitting in state even though the call as a whole had "failed." Caught this before treating it as real and
corrected the proof: the exploit is now submitted as its **own, real, uncaught transaction** (its own
`begin-tx`/`commit-tx`, exactly how an attacker would actually submit it) —
1. Baseline read: ANHD nonce1/2 = 10,000 / 1,000; Emma nonce1/2 = nonexistent.
2. Control legit transfer (ANHD → Emma, nonce1, amount=25) in its own transaction — succeeds, correct
   balances (9,975 / 25), commits normally.
3. The exploit transaction — throws inside `UEV_Amount` (`03_DPDC-C.pact:436`) before ever reaching
   `commit-tx`. **The whole script terminates with `Load failed` / a non-zero exit code — that hard
   failure, not a printed result, is the proof.** Nothing after the throw runs, so nothing the malicious
   transaction attempted (including its legit-looking nonce1 leg) is ever committed — real transaction
   atomicity, not a REPL-testing artifact.
- `cd REPL && pact Z.repl` (full default pipeline: Kadena/Stoa sandboxes → Stage 01 → Stage 02, including
  EQUITY's zero-supply tier-nonce genesis) — clean, `Load successful`, no regressions.

**Known pre-existing, unrelated issue surfaced during regression testing (not caused by this fix, not
fixed by this fix):** `REPL/Stage_02/[6.1]_DPDC.repl` (the comprehensive DPDC suite, not part of the
default `Z.repl` pipeline) hard-aborts partway through its "TX 007 -- SFT Transfer Tests" block
(mislabeled — the failing call is actually `DPNF|C_TransferNonce` on the `DHN-98c486052a51` NFT collection)
with `No value found in table ... DPNF|T|Nonces for key: DHN-98c486052a51|1`, tracing back to
`DPDC-T::UEV_AmountsForTransfer`'s own `nonce-supply` binding (flagged separately in Round I as
dead/unused — apparently still eagerly evaluated even though unused, so a missing row there throws
regardless). Confirmed via `git stash` that this crash is **identical on the untouched pre-fix source** —
not a regression from this fix, and unrelated to the (now fully reverted, untouched) `07_DPDC-T.pact`.
Logged as a new item for the backlog (not yet numbered/triaged) rather than folded into this fix.

**Interface implication:** none — `UEV_Amount` is a new internal (undeclared-on-interface) helper, matching
`CreditOrDebitDPDC` itself already being internal; no `DpdcCreateV1` signature change.

**Bonus closure:** this fix also closes **DPDC-F's C2** (`C_MakeFragments`/`C_MergeFragments` route their
constituent leg through `DPDC-T::C_Transfer` → the same `CreditOrDebitDPDC`) and the credit/debit-mint half
of **DPDC-S's C8** (`how-many-sets` unbounded — both `C_MakeSemiFungibleSet`'s mint leg and
`C_BreakSemiFungibleSet`'s constituent-return leg route through the same function). C8 stays **OPEN**
pending its own explicit `(enforce (> how-many-sets 0) ...)` at the `DPDC-S|C>MAKE`/`C>BREAK` cap layer for
a clearer, earlier error message — this fix closes the exploit itself but doesn't add the higher-layer
validation that finding separately recommends for defense-in-depth.
