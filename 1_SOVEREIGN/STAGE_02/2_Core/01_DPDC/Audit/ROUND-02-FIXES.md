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

## Fix #2 — DPDC-T · C1 (`C_IgnisRoyaltyCollector` has no ownership check of its own) — REFUTED, hardened anyway

**Owner-approved 2026-08-20**, after the finding was re-examined and downgraded from CRITICAL to REFUTED
through owner-supplied context, then hardened anyway as a deliberate "just in case" call — same shape as
the SWP audit's H12.

**Original trace (Round I):** `IGNIS|C>DEBIT` (the cap gating the royalty debit inside
`C_IgnisRoyaltyCollector`) checks balance sufficiency, account existence, and account type — never
ownership. Framed as CRITICAL: "any account can name an arbitrary smart-account patron and drain their
IGNIS."

**Re-examination (owner-led, this round):**
1. Owner: "patron can't be a smart account." Checked — `IGNIS|C>DEBIT` already calls
   `(ref-DALOS::UEV_EnforceAccountType sender false)`, which *rejects* smart accounts outright. The
   original "any smart account" exploit shape was never reachable — a real analysis error, not a hedge.
2. Narrowed to: can a *standard*-account patron be drained? `C_Collect`'s own `UEV_Patron` (a different
   function, billing a different fee — the transfer's own usage price, not the royalty) only runs when
   that fee is non-zero and virtual gas is globally on.
3. Owner: "the transfer fee in IGNIS is always non-zero, unless gas collection is turned off. IGNIS
   royalty can be zero." Combined with tracing `C_IgnisRoyaltyCollector`'s own bypass condition
   (`ivgz = (not virtual-gas-toggle)`) — royalty-nonzero and gas-off are mutually exclusive, because both
   key off the identical toggle (`ivgz` *is* `not virtual-gas-toggle`, not a separately-tracked flag).
   So "royalty is nonzero" and "ownership check gets skipped" can never both be true: whenever there's a
   real royalty to steal, gas is necessarily on, which (per the owner's fact) means the transfer fee is
   necessarily non-zero, which means `C_Collect`'s `UEV_Patron` necessarily runs in the same atomic
   transaction as the (earlier-evaluated) royalty debit — and a rejection there rolls back the whole
   transaction, royalty debit included, per the same atomicity behavior proven empirically during Fix #1.
4. **Verdict: REFUTED.** No reachable state lets an attacker walk away with anything.

**Owner decision:** harden anyway. The royalty debit's safety currently depends entirely on an *external*
invariant (the toggle relationship between `C_Collect`'s fee and `C_IgnisRoyaltyCollector`'s own bypass)
holding forever, not on anything it checks itself — a future, unrelated change to pricing or the toggle
logic could silently reopen this with zero local signal. Requested a direct, local ownership check so the
royalty debit doesn't rely on borrowed safety from a different function billing a different fee.

**Fix — one line, `07_DPDC-T.pact:305`, inside `IGNIS|C>DEBIT`:**
```pact
(defcap IGNIS|C>DEBIT (sender:string ta:decimal)
    (let (...)
        (enforce (<= ta read-gas) "Insufficient IGNIS for Debiting")
        (ref-DALOS::UEV_EnforceAccountExists sender)
        (ref-DALOS::UEV_EnforceAccountType sender false)
        (ref-DALOS::CAP_EnforceAccountOwnership sender)   ;; new
        (compose-capability (P|DPDC-T|CALLER))
    )
)
```
(`sender` here is bound to `patron` at the call site — `IGNIS|C>ROYALTY` composes
`(IGNIS|C>DEBIT sender ta)` where `sender` is `C_IgnisRoyaltyCollector`'s own `patron` parameter.) Same
call already used by `DPDC-T|C>TRANSFER` for the real transfer `sender`, applied where it was missing.

**Post-fix proof:** `REPL/Kursan/_verify_finding_DPDC-T_C1_ignis_royalty_ownership.repl`. No existing test
in the repo ever turns IGNIS gas collection on (confirmed by grep) — the entire royalty-debit path had
zero real exercise before this probe, old code or new. Built one that does, using the collection genesis
already turns gas on via `REPL/Stage_01/[4.0]_Sovereign-Executor.repl`):
- Confirmed `URC_SummedIgnisRoyalty` exempts the creator from paying themselves (`if sender=creator, 0.0`)
  — a same-account self-transfer never exercises the debit path at all, so the setup transfer (ANHD, the
  creator, → Emma) legitimately shows no royalty, and a second transfer (Emma, not the creator, → Lumy)
  was needed to get a genuinely non-zero royalty.
- **Legit:** Emma (real owner, signs for herself) transfers 10 units of a 50.0/unit-royalty nonce to Lumy
  as her own patron — succeeds, correctly collects **500.0 IGNIS** royalty (Emma 99,000 → 98,480; creator
  ANHD +500.0 exactly). The fix doesn't touch legitimate usage.
- **Illegitimate:** Lumy signs a transfer but names Emma (whose account he doesn't control) as `patron` —
  submitted as its own real, uncaught transaction. Hard-rejected:
  ```
  1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact:305 — CAP_EnforceAccountOwnership
  Keyset failure (keys-all): [PK_Emma...]
  ```
  Lands exactly on the new line, demanding Emma's own key — which the attacker's transaction doesn't have.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — internal to the defcap body, no signature change.

**Regression sweep (owner-requested — "are you sure this doesn't break anything else?"):** `IGNIS|C>DEBIT`
composing the new check is DPDC-T's own module-private capability with exactly one caller anywhere in the
codebase (`IGNIS|C>ROYALTY`); a same-named capability exists in Stage 1's `02_IGNIS.pact` but Pact
capabilities are module-scoped, so that's a coincidentally-named, entirely separate capability, unaffected
by this edit. Enumerated every real call site of `C_IgnisRoyaltyCollector` in the repo (7 total, across
`TS02-C1.pact`/`TS02-C2.pact`: `DPSF|C_TransferNonce(s)`, `DPNF|C_TransferNonce(s)`,
`DPDC|C_MultiTransfer`, `DPDC|C_BulkTransfer`, `DPSF|C_MorphEquity`) — all share the same shape (`patron`/
`sender`|`account` as separate parameters) and every real usage found in the repo's own fixtures binds
them to the same account; no sponsored/third-party-pays design exists anywhere. Checked whether the
system's "gas station" (`DALOS::GAS_PAYER`) could be a legitimate sponsor path — it only allow-lists which
call shapes get their Kadena network fee subsidized; it doesn't touch signatures or exempt anything from
in-function ownership checks, different layer entirely, no conflict. Live-tested `DPSF|C_MorphEquity`
(not exercised by the default `Z.repl` run) against the real `E|DH-98c486052a51` equity collection,
patron=account=real owner — succeeded cleanly, no rejection
(`REPL/Kursan/_verify_fix2_no_regression_morphequity.repl`).

**Known gap, not closed:** `DPDC|C_MultiTransfer` and `DPDC|C_BulkTransfer` were confirmed by source
inspection only (their one real test usage in `[6.1]_DPDC.repl` passes `patron` and `sender` as the
identical variable, same shape as everything else verified live) — not by a live run, because that call
sits later in `[6.1]_DPDC.repl`, which hard-crashes earlier in the same file on the pre-existing, unrelated
bug already logged under Fix #1 (confirmed via `git stash` to exist independent of this or any other change
made this round). Logged as a follow-up rather than chased further this round.

**Backlog note:** the fact that no existing test ever exercises real IGNIS gas collection is itself worth a
follow-up test-coverage item — logged, not fixed here.
