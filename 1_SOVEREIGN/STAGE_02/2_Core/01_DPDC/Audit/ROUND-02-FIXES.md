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

**DPDC-F/C2 closure independently verified, 2026-08-20** (owner: "prove it's closed, then close it") —
see the #3C entry in `ROUND-01-OWNER-FEEDBACK.md` for the live reproduction
(`REPL/Kursan/_verify_finding_DPDC-F_C2_negative_amount.repl`). No code change; this note just upgrades
the bonus-closure claim above from "should close it" to "confirmed closes it, full stack trace on file."

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

## Fix #3 — DPDC-MNG · C1 (burn/wipe can destroy the `dpdc` escrow account's fragment collateral)

**Owner-approved 2026-08-20.** Owner proposed making the `dpdc` escrow account immune to freeze+wipe;
checked the actual preconditions before implementing and found that alone wouldn't fully close it —
`DPDC-MNG|C>WIPE-SFT`/`WIPE-NFT` genuinely require `frozen=true` first, so freeze-immunity *would* have
made wipe unreachable, but `DPDC-MNG|C>BURN-SFT`/`BURN-NFT` never check freeze at all — only the burn
*role*. Freeze-immunity alone would have left burn (via an accidental or malicious role grant on `dpdc`)
completely open. Both burn and wipe already compose the same shared capability before touching anything —
`DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES` — so one check there, rather than two separate patches, closes both
paths permanently regardless of role grants or freeze state.

**Fix — one line, `06_DPDC-MNG.pact:304`, inside `DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES`:**
```pact
(enforce (= l1 l2) "Invalid Nonces and Amount for Class Zero Nonce Removal")
(enforce (!= account (ref-DPDC::GOV|DPDC|SC_NAME)) "Not allowed for the DPDC system account")
```

**Post-fix proof, both halves:**
- `REPL/Kursan/_verify_finding_DPDC-MNG_C1_escrow_immunity.repl`: fragmented a real nonce (100 units
  escrowed at `dpdc`), granted `dpdc` the burn role directly (simulating an accidental/malicious role
  grant — no freeze involved anywhere), then attempted to burn `dpdc`'s escrowed collateral as a real
  uncaught transaction. Hard-rejected at the new line. Control case (ordinary burn on ANHD's own balance,
  10,000 → 9,950) still works correctly.
- `REPL/Kursan/_verify_finding_DPDC-MNG_C1_wipe_half.repl`: fragmented a nonce, enabled `can-wipe` on the
  collection, froze `dpdc` — the two real preconditions the legitimate wipe path requires — then attempted
  to wipe `dpdc`'s escrowed collateral. Rejected at the exact same line, confirming one check closes both
  the freeze-gated wipe path and the freeze-independent burn path.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Why nothing else was needed:** the "compounding half" of the original finding (a stale-fragmented nonce
later respawned and reclaimed by pre-wipe fragment holders) was entirely downstream of the escrow
collateral being destroyed in the first place — with `dpdc` now immune to burn/wipe outright, that
precondition can never occur, so there's nothing left for a respawn to reattach to that could ever go
stale. Closing the front door closes the back door that depended on it.

**Interface implication:** none — internal to the defcap body, no signature change.
**Interface implication:** none — internal to the defcap body, no signature change.

## Fix #4 — DPDC-S · C2 (composite set-class with `allowed-sclass=0` permanently strands the constituent)

**Owner-approved 2026-08-20.** Owner asked for confirmation it's a quick fix that doesn't break anything
before greenlighting.

**Root cause:** `UEV_CompositeSetDefinition` (`08_DPDC-S.pact:569-589`) only bounded the *maximum* class
referenced across a definition (`max <= scu`) — it never checked each individual position is `> 0`.
Set-class `0` is the codebase's reserved "not part of any set" sentinel; a position naming it is satisfied
trivially by any ordinary native nonce at Make time, but Break can never look it up (no set-class-0 row
ever exists), permanently stranding the constituent.

**Fix — one enforce, `08_DPDC-S.pact:586-589`, mirroring this file's own convention for combining N
boolean checks:**
```pact
(enforce
    (fold (and) true (map (lambda (sc:integer) (> sc 0)) set-classes-used-in-set-definition))
    "Invalid Set-Definition: allowed-sclass must be greater than 0 for every position (0 is reserved)"
)
```
No existing sibling per-element validator to reuse (the Primordial-set analog only checks list *size*, not
value bounds), so this is a direct, minimal addition rather than a refactor.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-S_C2_zero_sclass.repl`):** the legit case needed no new
setup — genesis (`REPL/Stage_02/[4.0]_Sovereign-Executor.repl`) already defines three real primordial
set-classes (Bronze/Silver/Golden, classes 1-3) and a real composite set-class referencing them (Movie,
class 4) on the "Wonder Coach" collection (`DHWC-98c486052a51`); `pact Z.repl`'s full pass already proves
that legitimate definition still succeeds post-fix. This probe added only the exploit case: against that
same real collection (`set-classes-used=4`, confirmed live — so the *old* check alone would have trivially
accepted `0 <= 4`), a new composite set-class naming `allowed-sclass=0` is now hard-rejected, submitted as
a real uncaught transaction, landing exactly on the new line (`08_DPDC-S.pact:587`).

**Interface implication:** none — internal validation only, no signature change.

## Fix #5 — DPDC-S · C1 (`C_UpdateSetMultiplier` crashes unconditionally — copy-paste type bug)

**Owner-approved 2026-08-20**, plus a live-chain check the owner specifically asked for: is this bug also
on the deployed mainnet module (which would mean no REPL test ever caught it there either)?

**Confirmed live, not just local.** Real dirty-read against the actual deployed contract via Pythia
(`OuronetInformational/pythia-dirty-read-access.md`, keyless path):
```bash
curl -s -X POST https://pythia.ancientholdings.eu/stoachain/read \
  -H "Content-Type: application/json" -H "Sec-Fetch-Site: same-origin" \
  -d '{"chainId": 0, "code": "(describe-module \"ouronet-ns.DPDC-S\")"}'
```
Live module hash `Qslr8IXA10HEYsiHPnjvvCy4hYNIh3bfPQvD7w5QEoU`, `DPDC-S|C>MULTIPLIER` byte-identical to the
pre-fix local source: `(current-multiplier:string (UR_SetMultiplier id son set-class))`. **This confirms
`C_UpdateSetMultiplier` has never worked on mainnet since it was deployed** — not a local-only bug, and
exactly why no REPL test ever caught it either: the feature has been silently dead in production the whole
time, so nothing (local or live) has ever exercised a successful call.

**Root cause:** `08_DPDC-S.pact:310` — `UR_SetMultiplier` returns `:decimal`; the `let` binding reading it
was annotated `:string`. Pact enforces `let` type annotations at runtime, so the binding throws the moment
it's evaluated, before any of the function's real logic runs. Copy-paste artifact from the sibling
`DPDC-S|C>RENAME` cap directly above it, which has the identical shape and is correctly typed (`UR_SetName`
really does return `:string`) — the annotation on this one line was never updated after cloning.

**Fix — one word:**
```pact
-(current-multiplier:string (UR_SetMultiplier id son set-class))
+(current-multiplier:decimal (UR_SetMultiplier id son set-class))
```

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-S_C1_update_multiplier.repl`):** against a real,
genesis-defined set-class (Wonder Coach, Bronze = set-class 1, multiplier `1.0`) —
`C_UpdateSetMultiplier` now succeeds (`1.0 → 1.5`, persisted, read back correctly); the "must differ from
current" guard (which depends on `current-multiplier` being a real decimal to compare against) now also
works correctly, rejecting a same-value re-update. Full `pact Z.repl` pipeline green.

**Interface implication:** none — internal to the defcap body.

**SUPERSEDED by Fix #14 (2026-08-22, DPDC Audit #15H immutability follow-up):** `C_UpdateSetMultiplier`
(along with `DPDC-S|C>MULTIPLIER`, `XI_Multiplier`, `XI_U|SetMultiplier`, and the `DPNF`/`DPSF` Talos
wrappers) was removed entirely — the owner decided `score-multiplier` should be immutable after Define,
same as the Set-Class recipe, so it can never go stale. This fix (making the update function actually work)
is preserved here for the audit trail, but the function it fixed no longer exists in the live module.

## DPDC-S/DPDC-C · C3 (#8C) closure — no new code, both halves live-verified

**2026-08-21.** Owner pushed back on the Round I "probably already closed" framing and asked for it to be
checked directly, not assumed — same discipline as #3C. Checked both halves of `how-many-sets`, live,
against the real "Bronze" primordial set-class on the Wonder Coach collection:

- **Negative (`-1`):** `DPSF|C_Make` with `how-many-sets=-1`, submitted as a real uncaught transaction.
  Full stack trace: `DPSF|C_Make → DPDC-S::C_MakeSemiFungibleSet → XB_CreditSFT-Nonce (the mint leg)
  → ... → CreditOrDebitDPDC → UEV_Amount`, rejected at `03_DPDC-C.pact:436` — the identical chokepoint
  Fix #1 hardened. Confirmed closed.
  (`REPL/Kursan/_verify_finding_DPDC-S_C3_negative_how_many_sets.repl`)
- **Zero (`0`):** Fix #1's floor is deliberately `>=0`, not `>0` (see Fix #1's EQUITY zero-supply
  rationale), so this is *not* rejected — checked whether it does anything harmful instead. It doesn't:
  `DPSF|C_Make ... 0` succeeds, ANHD's real constituent balance (1,000 units) is completely unchanged, and
  the only effect is two new `0`-supply bookkeeping rows (the set-nonce itself, and the escrow slot) that
  didn't exist before. No value created, moved, or destroyed — a genuine no-op, just a wasted transaction.
  (`REPL/Kursan/_verify_finding_DPDC-S_C3_zero_how_many_sets.repl`)

**No code change.** Both concerns raised in the original finding are live-confirmed non-issues — the
negative case via Fix #1's shared chokepoint, the zero case by direct proof it moves nothing. The Round I
fix direction's suggestion (an explicit `(enforce (> how-many-sets 0) ...)` at the `DPDC-S|C>MAKE`/`C>BREAK`
cap layer) remains available as a pure UX nicety — a clearer, earlier error message instead of the current
generic one from three call-frames deeper — but is no longer a security requirement.

## Fix #6 — DPDC-S/DPDC-C · C3 (#8C), corrected: `how-many-sets = 0` must be rejected, not silently no-op

**Owner-approved 2026-08-21**, overruling the earlier "no code change, zero is harmless" close. Owner's
point: "make zero sets" completing successfully is the same category of nonsense as "transfer zero units"
completing successfully — which was already rejected outright for ordinary transfers (`DPDC-T`'s own
`amount > 0` reasoning). An operation that claims to *do* something should never silently succeed while
doing nothing; that's not a harmless no-op, it's a degenerate input that should be refused.

**Fix:** added `how-many-sets:integer` as an explicit parameter to `DPDC-S|C>MAKE`/`C>BREAK` (previously
neither cap even looked at it — this was the original Round I fix direction, not a new idea), with
`(enforce (> how-many-sets 0) "How-Many-Sets must be a positive, non-zero integer")` in both. Both SFT
call sites (`C_MakeSemiFungibleSet`/`C_BreakSemiFungibleSet`) now pass their real `how-many-sets`
parameter through to the cap; both NFT call sites (`C_MakeNonFungibleSet`/`C_BreakNonFungibleSet`, which
never had this concept — NFT sets are structurally always exactly one) now pass a literal `1`. Confirmed
no other caller of either capability exists anywhere in the codebase (capabilities are module-private).

**Post-fix proof:**
- Re-ran the existing negative (`-1`) and zero (`0`) probes
  (`REPL/Kursan/_verify_finding_DPDC-S_C3_{negative,zero}_how_many_sets.repl`) — both now rejected
  *earlier and more clearly* than before, directly at `08_DPDC-S.pact:201`
  (`"How-Many-Sets must be a positive, non-zero integer"`), rather than negative alone reaching
  `UEV_Amount` three call-frames deeper.
- New control (`REPL/Kursan/_verify_finding_DPDC-S_C3_legit_make_break.repl`): a real Make 3 → Break 3
  round trip on the Bronze set-class. Constituent nonce1: `1000 → 997 (Make) → 1000 (Break)` — exact
  conservation, back to the original value. Set-nonce balance: `0 → 3 (Make) → 0 (Break)`. `pact Z.repl`
  full pipeline confirmed still green, though note genesis never actually calls `C_Make*Set` at all (only
  defines set-classes) — this control test is the only real coverage of the positive-value path either
  way, local or live.

**Interface implication:** none — capability signatures aren't part of the versioned interface, matching
the original Round I finding's own assessment.

## Fix #7 — DPDC · H1 (Talos SFT branding-update arity bug — feature 100% broken)

**Owner-approved 2026-08-21.**

**Root cause:** `01_TS02-C1.pact:339-351`'s `DPSF|C_UpdatePendingBranding`
called the real `DPDC::C_UpdatePendingBranding` (6 params: `entity-id son logo description website
social`) with **7** positional args — a stray leading `patron`, almost certainly copy-pasted from the
neighboring `C_UpgradeBranding` wrapper, which genuinely does take `patron` first. The NFT sibling,
`DPNF|C_UpdatePendingBranding` (`02_TS02-C2.pact`), calls the same underlying function correctly with 6
args — confirming this was specifically an SFT-side copy-paste slip, not a defect in the real function.

**Fix — one word removed, `01_TS02-C1.pact:346`:**
```pact
-(ref-DPDC::C_UpdatePendingBranding patron entity-id true logo description website social)
+(ref-DPDC::C_UpdatePendingBranding entity-id true logo description website social)
```

**Secondary question resolved empirically, not just fixed and hoped:** the finding also flagged that
`ref-DPDC` is typed `module{DpdcV1}` while `C_UpdatePendingBranding` is declared on the separate
`BrandingUsageTertiaryV1` interface — unclear whether that cross-module call would even resolve. Traced
the real function body and found it delegates to a *third* module, `ref-BRD:module{BrandingV1} BRD`
(Stage 1's dedicated Branding module — `04_BRD.pact`) via `XE_UpdatePendingBranding`. Live-tested rather
than assumed: the call resolves and executes cleanly, no retyping needed anywhere.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC_H1_branding_update.repl`):**
- SFT: `DPSF|C_UpdatePendingBranding` against the real `DHOC-98c486052a51` collection — succeeds (never
  did before, on any input), pending logo `| → https://example.com/logo.png`, pending description set
  correctly too, both read back from the real `BRD` module storage.
- NFT (control, already-correct sibling): `DPNF|C_UpdatePendingBranding` against the real
  `DHN-98c486052a51` collection (owned by a different account, `LUMY`, than the SFT test — caught and
  corrected a wrong-signer mistake in the probe itself along the way) — still succeeds, pending logo set
  correctly.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — caller-side argument-count bug in Talos, not a DPDC interface defect.

## Fix #8 — DPDC-I · H1 (NFT issuance billed at the cheaper SFT KDA price)

**Owner-approved 2026-08-21.** Round I's trace was a static source read only, never reproduced running —
owner asked directly whether it had actually been verified before agreeing to fix it.

**Root cause:** `04_DPDC-I.pact:188-193` — `C_IssueDigitalCollection`'s KDA cost computation:
```pact
(kda-cost:decimal (if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpsf")))
```
Both branches of the `if son` query the identical `"dpsf"` price key — the `if` is dead code. Genesis
price table: `"dpsf"=0.4`, `"dpnf"=0.5`.

**Fix — one word:**
```pact
-(kda-cost:decimal (if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpsf")))
+(kda-cost:decimal (if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpnf")))
```

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-I_H1_nft_kda_price.repl`):** genesis's own NFT
issuances already sign `coin.TRANSFER` capabilities generously (computed from the *correct* `dpnf` price),
so a signed-cap pass/fail test can't discriminate the bug — a capability is only an upper bound, and the
under-collection is silently absorbed, exactly why no existing test ever caught this. Measured the real
`coin` balance delta instead, on a freshly-issued NFT collection (never issued before, to avoid
double-issuance interference):
- **Pre-fix:** real charge = `0.306` KDA (some constant account-level discount is layered on top of the
  0.4 base — irrelevant to the bug itself, since it's applied uniformly).
- **Post-fix:** real charge = `0.3825` KDA — exactly `0.306 × 1.25`, and `1.25` is exactly `0.5 / 0.4`,
  the precise `dpnf`/`dpsf` price ratio. Not merely "higher" — mathematically exact confirmation the fix
  changed the base price input and nothing else.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — internal to `C_IssueDigitalCollection`'s body.

## Fix #9 — DPDC-I · H2 (solo NFT owner==creator locked out of role-exemption/modify-creator/modify-royalties)

**Owner-approved 2026-08-21.** Owner confirmed this was a one-word-per-flag fix — `false` written where `true`
was intended — and asked for the same fix → verify-live → document sequence as every prior finding.

**Root cause:** `04_DPDC-I.pact` — in `C_IssueDigitalCollection`'s NFT branch, when `owner-account ==
creator-account` (the solo-creator case), the final `XB_DeployAccountNFT owner-account id ...` call wrote
`role-exemption`, `role-modify-creator`, and `role-modify-royalties` as `false` into the `Account` table —
the table that actually gates those operations (the `VerumRoles` record claimed the owner had them, but
`Account` is what's checked at call time). A solo creator could never exempt itself from role-caps, change
its own creator address, or set a royalty on its own mint. The parallel SFT branch already wrote `true` for
the equivalent flags — this was an NFT-branch-only oversight.

**Fix — three flags, `false` → `true`, matching the already-correct SFT sibling:**
```pact
 (ref-DPDC::XB_DeployAccountNFT owner-account id
     false   ;;frozen
-    false   ;;role-exemption
+    true    ;;role-exemption
     true    ;;role-nft-burn
     true    ;;role-nft-create
     true    ;;role-nft-recreate
     true    ;;role-nft-update
-    false   ;;role-modify-creator
+    true    ;;role-modify-creator
-    false   ;;role-modify-royalties
+    true    ;;role-modify-royalties
     true    ;;role-set-new-uri
     false   ;;role-transfer
 )
```

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-I_H2_nft_owner_creator_roles.repl`):** issued a fresh
solo NFT collection (`SCPN-98c486052a51`, owner==creator==`KST.ANHD`, never issued before), minted a real
nonce, then called `TS02-C2::DPNF|C_UpdateNonceRoyalty` on it as the solo owner:
- Confirmed the role write directly: `role-modify-royalties on owner BEFORE would-be-check: true`.
- `SET ROYALTY RESULT = Write succeeded`, and reading it back: `royalty after set = 50.0`. Before the fix
  this call would have been rejected — role was `false` in the `Account` table regardless of what
  `VerumRoles` claimed.
- Note on the underlying call shape: `DPNF|C_UpdateNonceRoyalty`'s `nos:bool` argument must be `true`
  ("native", i.e. not a fragmented/split nonce) for a plain never-fragmented mint — `false` routes into
  `DPDC-F::UEV_Fragmentation`, which requires the nonce to already be fragmented and is unrelated to this
  bug; that's a probe-construction detail, not part of the fix.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — internal to `C_IssueDigitalCollection`'s NFT branch.

## Fix #10 — DPDC · #12H (REFUTED/verified) + #12Hb (new) — nonce free-text/metadata fields had zero content validation

**Owner-approved 2026-08-21.** Round I's `DPDC · H2` claimed the shared `XE_*` write-forwarding surface
performs "zero value-level validation." Investigating that claim live, before accepting or rejecting it,
found two different things:

**#12H itself — REFUTED.** Every real call site (`DPDC-C` credit/debit, `DPDC-MNG` burn/wipe,
`DPDC-S` set-class creation, `DPDC-I` genesis specs) either self-derives the value it writes
(`nonces-used`/`set-class` are always `current + 1`, never attacker input) or is pre-validated by the
calling defcap before `require-capability` even lets the write run (e.g. `DPDC-C|C>SINGLE-DEBIT`'s defcap
calls `UEV_NonceQuantityInclusion`, enforcing `amount <= current-supply`, *before* `XE_W|Supply` is ever
reached). The architecture's own rule — checks live in the defcap, `XE_*` is write-only — holds in every
traced path, not just in theory.

**#12Hb — CONFIRMED, new finding, found while verifying #12H.** `DpdcUdcV1.DPDC|NonceData`'s free-text
fields — `name`, `description`, the nested trait bag `meta-data.meta-data`, `asset-type`, and the three
`uri-primary`/`-secondary`/`-tertiary` link bundles — had **no content validation anywhere**, at creation
(`DPDC-C::UEV_NonceDataForCreation` only checked `royalty`/`ignis`) or at update
(`DPDC-N`'s per-field `C_Update*` entrypoints wrote raw caller input with no check at all). Traced actual
consumers before assuming severity: `meta-data.meta-data` is not decorative — AQP-ANK/AQP-SCORE read it as
a real `key -> string value` trait bag for reward scoring (`01_ANK.pact:459,989`, `02_SCORE.pact:2113,2701`),
and AQP's own scoring-definition validator already assumes trait values are `2-256` chars
(`02_SCORE.pact:2729`) — a mismatch nothing enforced on the write side. Owner confirmed the fields were
deliberately left open by design (arbitrary-size metadata was wanted) but agreed unbounded free text is a
real storage-bloat/griefing vector worth capping. Owner set two caps directly (`name` ≤256 chars;
`description` ≤1024 words, ≤256 chars/word); the rest (`meta-data.meta-data`, `asset-type`, `uri-*`) were
worked out jointly after tracing real consumers and an actual Pact-level constraint (no builtin can
enumerate an untyped object's keys — confirmed live: `(keys {"a":1})` throws `Type error: ... object` —
so `meta-data.meta-data` gets a coarse total-serialized-size ceiling instead of a precise per-key check).

**Where the enforcement lives — single validator per field, called from every path that touches it:**
new validators `UEV_Name`/`UEV_Description`/`UEV_MetaDataBag`/`UEV_AssetType`/`UEV_UriData` added once in
`02_DPDC.pact`, right next to the existing `UEV_Royalty`/`UEV_IgnisRoyalty` (same shared-root pattern), each
wired into exactly two call sites:
1. `DPDC-C::UEV_NonceDataForCreation` (`03_DPDC-C.pact:382`) — covers both creation *and* whole-object
   update, since `DPDC-N::C_UpdateNonces`'s defcap already reuses this same function for its per-index
   `new-nonces-data`.
2. The matching `DPDC-N` per-field defcap — `SET-NAME`/`SET-DESCRIPTION`/`SET-META-DATA`/`SET-URI`
   (`10_DPDC-N.pact:184-243`) — mirrors how `SET-ROYALTY`/`SET-IGNIS-ROYALTY` already call
   `UEV_Royalty`/`UEV_IgnisRoyalty` today; each defcap gained the value as a new parameter so it can be
   validated *before* `compose-capability` allows the write.

**Caps implemented:**
| Field | Cap |
|---|---|
| `name` | ≤ 256 chars |
| `description` | ≤ 1024 words, ≤ 256 chars/word (via existing `U|LST::UC_SplitString " " description`) |
| `meta-data.meta-data` | ≤ 8192 chars total serialized size (`(length (format "{}" [meta-data]))`) — coarse ceiling, not per-key, per the Pact object-key-enumeration constraint above |
| `asset-type` | at least 1 of the 7 flags must be `true`; any combination up to all 7 is valid |
| `uri-primary`/`-secondary`/`-tertiary` (21 strings total) | ≤ 2048 chars each, no content restriction |

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC_12Hb_metadata_caps.repl`):** issued a fresh NFT
collection (`MCPN-98c486052a51`) and ran 13 checks covering both the creation path and every per-field
update path:
- Rejected: 257-char name, all-false asset-type, 2049-char URI string (all 3 at **creation**); 257-char
  name, a single 257-char description word, an 8200-char meta-data value, all-false asset-type, and a
  2049-char URI string (all 5 at **update**, via `C_UpdateNonceName`/`Description`/`MetaData`/`URI`).
- Accepted: creation at the exact boundary (name=256 chars, uri=2048 chars); legit updates for name
  (256 chars), description ("a short legit description"), meta-data (`{"rarity":"legendary"}`), and URI
  (two real asset types with real IPFS links) — all returned `Write succeeded`.
- Also re-ran `_verify_finding_DPDC-I_H2_nft_owner_creator_roles.repl` (Fix #9's probe), which originally
  used the all-zero `UDC_ZeroURI|Type`/`UDC_ZeroURI|Data` sentinel for its test nonce — now correctly
  rejected by the new `asset-type` cap; updated the probe to a real asset-type + IPFS link and confirmed
  Fix #9's own proof (`Write succeeded`, `royalty after set = 50.0`) still holds together with this fix.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions; confirmed no genesis/scenario REPL
  anywhere in the loaded pipeline relies on the now-forbidden all-zero `asset-type` pattern (grepped, none
  found) — every real collection already sets at least one real media flag.

**Interface implication:** new `UEV_Name`/`UEV_Description`/`UEV_MetaDataBag`/`UEV_AssetType`/`UEV_UriData`
functions added to `DpdcV1` (additive, no existing signature changed); `DPDC-N|C>SET-NAME`/`SET-DESCRIPTION`/
`SET-META-DATA`/`SET-URI` defcap parameter lists grew (internal to `DPDC-N`, not part of any interface) —
stays on current V1 per repo's pre-mainnet policy.

**Deferred, not part of this fix — #12Hc:** while tracing `meta-data.composition` (the NFT-Set constituent
list, read by `URC_NonFungibleConstituents`/`C_BreakNonFungibleSet`) to decide whether it needed a cap too,
found it can currently be overwritten to arbitrary values via `DPDC-N::C_UpdateNonces`'s whole-object
replace path — decoupled from what's actually held in `dpdc` escrow. That's a correctness/integrity gap,
not a content-length question, logged separately as #12Hc, owner verdict pending.

## Fix #11 — DPDC-N · #12Hc — a minted NFT Set instance's own data (including `composition`) was directly editable

**Owner-approved 2026-08-21.** Worked out the exact model together before writing any code — three separate
things needed disambiguating first:

1. **The Set-Class recipe** (`primordial-set-definition`/`composite-set-definition` — which nonces/classes
   are allowed to combine) — checked live: no function anywhere ever updates it after `XI_PrimordialSet`/
   `XI_CompositeSet`/`XI_HybridSet` first define it. Already permanently immutable, stricter than needed.
   No change. (Owner confirmed this is intentional: a wrong recipe means disabling that set-class and
   defining a new one, not editing the old one.)
2. **The Set-Class metadata template** (`DPDC|Set.nonce-data` — royalty/name/description/asset-type/uri,
   editable via `DPNF|C_UpdateSetNonce*`/`nost=false`) — confirmed via code trace it only shapes *future*
   mints (`C_MakeNonFungibleSet` copies it once into `spawned-nd` at Make time; nothing re-reads the
   template afterward for an existing instance — `UR_NativeNonceData` is a flat table read, no live
   reference back to the template). Owner asked to confirm this directly ("is it automatically captured on
   existing set nonces?") — no. Stays freely editable; explicitly not what needed locking.
3. **Each individual minted instance's own stored data** — this is what `C_BreakNonFungibleSet` actually
   reads (`URC_NonFungibleConstituents` → `UR_NativeNonceData`), and it was reachable and overwritable via
   `DPDC-N::C_UpdateNonces`/the per-field `C_Update*` family (Nonce path, `nost=true`) by targeting the
   instance's nonce ID directly — this is the real gap.

**NFT-only scope, confirmed with the owner:** NFT Set instances are individually unique (different
combinations of constituent nonces produce different instances, so each needs its own `composition`
record) — SFT Sets are not: a set-class has exactly **one** shared nonce, created once at Define time,
never re-derived per Make (`C_MakeSemiFungibleSet` only credits balance onto the existing nonce), and
`C_BreakSemiFungibleSet` reads constituents from the immutable recipe via `URC_SemiFungibleConstituents`,
never from a mutable per-instance field. Locking SFT set-nonce edits would remove the only way to ever
adjust an SFT set's data, for zero security benefit. Scoped the fix to `son=false` only.

**Fix — one shared validator, two call sites (the same pattern `UEV_Royalty`/`UEV_IgnisRoyalty`/#12Hb's
validators already use):** new `DPDC-N::UEV_NotSetInstance (id son nosc nost)` — when `nost=true` (Nonce
path) and `son=false` (NFT), enforces `(= (UR_NonceClass id son nosc) 0)`, i.e. the target must be a
primordial (class-0) nonce, not a Set instance. Wired into:
1. `DPDC-N|C>DATA` (`10_DPDC-N.pact:255`) — the shared capability every per-field update composes through
   (`SET-ROYALTY`/`SET-IGNIS-ROYALTY`/`SET-NAME`/`SET-DESCRIPTION`/`SET-SCORE`/`SET-META-DATA`/`SET-URI`).
2. `DPDC-N|C>SET-DATA` (`10_DPDC-N.pact:131`) — the whole-object `C_UpdateNonces` path, checked per index
   inside its existing `map`/`lambda`.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`):**
- NFT: defined a real Primordial Set (2 positions, each with 2 allowed alternatives — `N([1,3])`/`N([2,4])`
  — Pact's own `> 1 allowed element` requirement caught an earlier single-choice attempt), made an instance
  from nonces 1+2 (spawned nonce 6, `nonce-class = 1`). `C_UpdateNonceName`/`C_UpdateNonceMetaData` on
  nonce 6 directly: both rejected. `C_UpdateSetNonceName` on the Set-Class (1) template: `Write succeeded`
  — stays editable. `C_UpdateNonceName` on an ordinary, never-set-involved primordial nonce (5): `Write
  succeeded` — regression-clean, the block is scoped exactly to Set instances, not primordial nonces.
- SFT: defined and made a Primordial Set the same way; `C_UpdateNonceName` directly on the SFT set-class's
  one shared nonce: `Write succeeded` — confirmed unaffected, exactly as scoped.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — `UEV_NotSetInstance` is internal to `DPDC-N`, not exported via
`DpdcNonceV1`; no existing signature changed.

**#12Hc closed.** No further open items from this investigation chain (#12H → #12Hb → #12Hc).

## Fix #12 — DPDC-R · H1 (#13H) — unfreeze gated on `can-freeze`, bricking already-frozen accounts

**Owner-approved 2026-08-21.** Owner: "unfreeze should be like a release valve, regardless of can-freeze."

**Root cause:** `05_DPDC-R.pact:131-141` — `DPDC|C>FRZ-ACC (id son account frozen)` called
`(ref-DPDC::UEV_CanFreezeON id son)` unconditionally, for both directions (`frozen=true` = freeze,
`frozen=false` = unfreeze — confirmed via `XI_ToggleFreezeAccount`'s write, `XE_U|Frozen id son account
toggle`). Once a collection renounces `can-freeze` (sets it `false`), any account frozen *before* that point
can never be unfrozen again — combined with `can-upgrade=false` (also renounceable), permanently bricked
with no recovery path. Confirmed `UEV_CanFreezeON` has exactly one call site in `DPDC-R` (this one).

**Fix — one location, direction-gated:**
```pact
-(ref-DPDC::UEV_CanFreezeON id son)
+(if frozen
+    (ref-DPDC::UEV_CanFreezeON id son)
+    true
+)
```
`can-freeze` now gates new freezes only; unfreeze is unconditional.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl`):** froze a real
account (`KST.LUMY`) on a fresh NFT collection while `can-freeze=true`, renounced `can-freeze` via
`DPNF|C_Control`, then:
- `<<13H-1>>` unfroze Lumy — `Write succeeded`, confirmed `frozen? false` — release valve works even with
  `can-freeze=false`.
- `<<13H-2>>` attempted to freeze a *different* account while still `can-freeze=false` — correctly
  rejected, confirming the fix is scoped to unfreeze only, not a blanket bypass of the flag.
- **Pre-fix confirmation via `git stash`:** ran the identical script against unfixed source — hard-fails
  exactly at the unfreeze step (right after the `RENOUNCE can-freeze` line), proving the brick was real
  before this fix, not assumed.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — internal to `DPDC|C>FRZ-ACC`'s body, no signature change.

## Fix #13 — DPDC-S · H1 (#15H) — `score-multiplier` unbounded at Define, unbounded magnitude at Update

**Owner-approved 2026-08-21/22.** Owner: cap the multiplier at 100x.

**Investigation detour first (per owner's own questions, before touching code):**
- Traced who actually consumes the multiplier before deciding this was purely a "needs a bound" fix.
  Found `DPDC-S::UR_N|Score` — the only function anywhere that multiplies a nonce's raw score by
  `UR_SetMultiplier` — has **zero callers** in the whole loaded codebase. And `URC_NoncesSummedScore`
  (the function that bakes a score into a newly-Made set instance) sums constituent raw scores with no
  multiplier applied at all. AQP-SCORE reads `UR_N|RawScore` directly, bypassing both.
- Live-checked mainnet Bloodshed (real deployed `2_SLAVE/Stage_02/1_Bloodshed` set-classes, one with a
  live 1.1x multiplier) via Pythia to see whether real on-chain scores reflect it — inconclusive from
  this side: the local REPL genesis's collection ID/owner are synthetic sandbox fixtures, not the real
  mainnet identity, and collection IDs are block-hash-derived (DPDC-I·M1), so guessing the real ID failed
  as expected. Owner to supply the real ID/owner if this angle is worth finishing.
- Wrote and handed off a separate investigation brief to an AQP-focused reviewer: is the multiplier meant
  to be applied when a nonce is staked into an AQP pool and scored there, and if so, is it actually wired
  up anywhere in AQP-ANK/AQP-SCORE/AQP-POOL/AQP-FVT? **Not yet answered — tracked separately, this fix
  does not depend on or block that answer.**
- Owner decision, independent of the above: cap the multiplier at 100x now regardless of where it ends up
  being consumed (DPDC-S's own Make-time computation, and/or AQP's staking-time scoring, once wired) —
  this closes the original #15H finding (no bound anywhere) on its own terms.

**Root cause:** `08_DPDC-S.pact` — `DPDC-S|C>DEFINE-PRIMORDIAL`/`DEFINE-COMPOSITE`/`DEFINE-HYBRID` never
took `score-multiplier` as a parameter at all, so Define-time had **zero** validation on it. At Update
time, `DPDC-S|C>MULTIPLIER` only checked 3-decimal precision — no magnitude bound, positive or negative.

**Fix — one shared validator, wired into both Define and Update (same pattern as every prior
shared-chokepoint fix this round):**
```pact
(defun UEV_ScoreMultiplier (new-multiplier:decimal)
    (enforce (= (floor new-multiplier 3) new-multiplier) "...3 decimals...")
    (enforce (and (> new-multiplier 0.0) (<= new-multiplier 100.0)) "...greater than 0 and no more than 100x...")
)
```
- `DPDC-S|C>DEFINE-PRIMORDIAL`/`DEFINE-COMPOSITE`/`DEFINE-HYBRID` gained `score-multiplier:decimal` as a
  new capability parameter, validated via `UEV_ScoreMultiplier` — all 6 call sites (`with-capability` in
  `C_DefinePrimordialSet`/`CompositeSet`/`HybridSet`, `require-capability` in
  `XI_PrimordialSet`/`CompositeSet`/`HybridSet`) updated to thread it through.
- `DPDC-S|C>MULTIPLIER`'s inline precision-only check replaced with a call to the same
  `UEV_ScoreMultiplier`; the pre-existing "must differ from current value" business rule is unrelated and
  left untouched.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-S_15H_multiplier_bound.repl`):** 9 checks on a fresh
NFT collection with 4 real primordial nonces (so every Define fails/succeeds specifically on the
multiplier, not on an unrelated set-definition error):
- Define rejected: `100.001` (>100x), `0.0`, `-1.0`, `1.2345` (4-decimal precision) — all 4.
- Define accepted: exactly `100.0` (boundary) and `2.5` (ordinary) — both `Write succeeded`-equivalent.
- Update rejected: `250.0` (>100x), `-5.0` — both.
- Update accepted: `50.0` — succeeds normally.
- `cd REPL && pact Z.repl` — clean, `Load successful`, including Bloodshed's real genesis multipliers
  (e.g. `1.1`) still passing cleanly (well within the new bound).

**Interface implication:** `DPDC-S|C>DEFINE-PRIMORDIAL`/`DEFINE-COMPOSITE`/`DEFINE-HYBRID` are internal
capabilities, not part of `DpdcSetsV1` — no interface signature changed; `UEV_ScoreMultiplier` is a new
internal (non-interface) function.

**SUPERSEDED (partially) by Fix #14 (2026-08-22):** the Update-side bound described above (`DPDC-S|C>MULTIPLIER`
now calling `UEV_ScoreMultiplier`) was removed along with the rest of the Update path — `score-multiplier`
is now immutable after Define. `UEV_ScoreMultiplier` itself survives, now called only at Define time.

## Fix #14 — DPDC-S · H1 (#15H follow-up) — `score-multiplier` made immutable after Define

**Owner-approved 2026-08-22.** Owner: "I want it immutable similar to how the combining nonces are
immutable" — i.e. the same treatment already confirmed correct for the Set-Class recipe
(`primordial-set-definition`/`composite-set-definition`, #12Hc discussion): no update path at all, ever: if
a value turns out wrong, disable that Set-Class and define a new one. Direct follow-up question asked and
answered first — "is the multiplier stable afterwards?" — no, `C_UpdateSetMultiplier` could be called any
number of times, at any point, within the Fix #13 bound; nothing locked it once instances existed.

**Fix — remove the entire Update path, not just tighten it further:**
- `DPDC-S::C_UpdateSetMultiplier` (function + its `DpdcSetsV1` interface declaration) — removed.
- `DPDC-S|C>MULTIPLIER` (capability) — removed.
- `DPDC-S::XI_Multiplier` / `XI_U|SetMultiplier` (XI wrapper + low-level table write) — removed.
- `DPNF|C_UpdateSetMultiplier` (`02_TS02-C2.pact`) / `DPSF|C_UpdateSetMultiplier` (`01_TS02-C1.pact`) —
  removed, interface declarations and implementations both.
- The Fix #13 bound (`UEV_ScoreMultiplier`, `(0,100]` + 3-decimal precision) survives unchanged, now
  enforced only at Define time (Primordial/Composite/Hybrid) — the only place the multiplier is ever set.
- `UR_SetMultiplier` (the reader) is untouched — the value stays fully readable, just never rewritable.

Checked first that nothing legitimate breaks: grepped the entire canonical genesis/REPL suite for real
callers of `C_UpdateSetMultiplier` — none found; only two `REPL/Kursan/` scratch probes exercised it (this
fix's own Fix #13 proof, and Fix #5's original type-bug proof), both updated to match (see below). Also
worth noting: Fix #5's `C_UpdateSetMultiplier` type-bug fix (the very first fix landed in this whole audit)
made the function work *at all* for the first time — it had never successfully executed even once on
mainnet before that. Nobody was relying on it working, since it never had.

**Post-fix proof:** `REPL/Kursan/_verify_finding_DPDC-S_15H_multiplier_bound.repl` updated — replaced the
now-nonexistent Update-path checks (`<<15H-7/8/9>>`) with a direct immutability read: defined a fresh
set-class at `2.5x`, then read `UR_SetMultiplier` back with no update call in between (there is no update
call left to make) — confirmed `2.5` persists with zero code path able to change it.
`REPL/Kursan/_verify_finding_DPDC-S_C1_update_multiplier.repl` (Fix #5's original proof) — its baseline read
(`UR_SetMultiplier`) still works; its Update-path block is now commented out with a note explaining why,
so the file still loads cleanly end-to-end as a historical record.
`cd REPL && pact Z.repl` — clean, `Load successful`, no regressions from removing the function/capability.

**Interface implication:** `C_UpdateSetMultiplier` removed from `DpdcSetsV1` (interface shrink);
`DPNF|C_UpdateSetMultiplier`/`DPSF|C_UpdateSetMultiplier` removed from the Talos client interfaces. Per
repo policy, V1 stays freely editable pre-mainnet-adjustment — no version bump; matches how Fix #5 itself
already edited this same function's body in place with no version bump.

## Fix #15 — DPDC-T · H1 (#16H) — `UEV_TransferRoles` receiver check silently re-tested sender

**Owner-approved 2026-08-22.** Owner: check how DPTF/DPOF do transfer-role checks, fix DPDC-T to match.

**Reference pattern found in DPOF (`1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact:1595-1631`,
`UEV_MoveRoleCheck`):**
```pact
(sender-transfer-role:bool (UR_R-Transfer id sender))
(receiver-transfer-role:bool (UR_R-Transfer id receiver))
(enforce-one ... [(enforce sender-transfer-role ...) (enforce receiver-transfer-role ...)])
```
Correctly parameterized — each side reads its own account. Also gated behind an "are transfer roles even
active" flag (if nobody holds the role, the feature is inactive and transfers proceed unconditionally).
DPTF was checked too but doesn't appear to enforce `r-transfer` anywhere in its transfer path at all (no
reader consumes it) — DPOF is the real reference implementation here.

**Root cause:** `07_DPDC-T.pact:478-488` (`UEV_TransferRoles`) — `s` correctly read `UR_CA|R-Transfer id son
sender`, but `r` also read `... sender` (copy-paste), never `receiver`. `URC_TransferRoleChecker` (the
"is the feature active" gate, `trc`) was already correct and even had a DPDC-specific improvement DPOF
doesn't need (an escrow-account exemption) — the bug was isolated to this one line.

**Fix — one line:**
```pact
-(r:bool (ref-DPDC::UR_CA|R-Transfer id son sender))
+(r:bool (ref-DPDC::UR_CA|R-Transfer id son receiver))
```

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-T_16H_transfer_role_receiver.repl`):** granted the
transfer role to `KST.LUMY` only (owner/sender `KST.ANHD` never gets it, activating the role-restriction
gate via `>=1` holder), then transferred a real nonce from ANHD (no role) to Lumy (has role) — under the
intended sender-OR-receiver semantics this must succeed, since the receiver satisfies it:
- **Post-fix:** `Successfully transfered NFT ...` — correct.
- **Pre-fix (`git stash`):** the identical script hard-fails exactly at the transfer call — confirms the
  bug was real (wrongly rejected a receiver-authorized transfer), not assumed.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — internal to `UEV_TransferRoles`'s body, no signature change.

## Fix #16 — DPDC-S · H1 (#15H follow-up 2) — `score-multiplier` lower bound tightened to 1.0

**Owner-approved 2026-08-22.** Surfaced while working through #19H (`UR_N|Score`'s sentinel bug): the
multiplier is meant to boost a nonce's score, never quietly reduce it. Owner: at Define, the multiplier
must be `1.0` to `100.0`, not `(0, 100]` — a value below `1.0` would silently shrink the raw score, which
was never the intent.

**Fix — one comparison operator, same shared validator:**
```pact
-(and (> new-multiplier 0.0) (<= new-multiplier 100.0))
+(and (>= new-multiplier 1.0) (<= new-multiplier 100.0))
```
`UEV_ScoreMultiplier` (added in Fix #13, now Define-only per Fix #14) — no new call sites, same two
properties (precision + magnitude) checked in the same place.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-S_15H_multiplier_bound.repl`, extended):** added
`<<15H-4b>>` (`0.5` — below the new floor, previously legal under `(0,100]`, now correctly rejected) and
`<<15H-5b>>` (`1.0` — the new floor, the neutral no-op multiplier, correctly accepted). All prior checks
(`100.001`/`0.0`/`-1.0`/`1.2345` rejected; `100.0`/`2.5` accepted; immutability read) still pass unchanged.
`cd REPL && pact Z.repl` — clean, `Load successful`, Bloodshed's real `1.1x` genesis multiplier still well
within the new, narrower range.

**Interface implication:** none.

## Fix #17 — DPDC-UDC/DPDC-S · H1 (#19H) — `UR_N|Score` leaks the `-1.0` unscored sentinel in 3 of 4 branches

**Owner-approved 2026-08-22.** Owner: an unscored nonce's raw `-1.0` must always read back as `0.0`, in
every shape (plain vs. Set-member, whole vs. fragment) — this must be fixed across the board.

**Root cause:** `08_DPDC-S.pact:361-390` (`UR_N|Score`) — 4 branches (class-0 × native/fragment, Set-member
× native/fragment), only the class-0/native branch checked `raw-nonce-score = -1.0` before returning it.
The other three either never checked at all (fragment arms — multiplied/divided the sentinel directly,
`-1.0 / 1000.0 = -0.001`) or checked against the wrong literal (`-1000.0` instead of `-1.0`, a copy-paste
leftover of the `1000.0` divisor two lines below — only accidentally correct when `multiplier = 1000.0`).

**Fix — centralize the check once, at function entry, on the untouched raw value:**
```pact
-(if (= nonce-class 0)
-    (if (< nonce 0) (/ raw-nonce-score 1000.0) (if (= raw-nonce-score -1.0) 0.0 raw-nonce-score))
-    (let (...) (if (< nonce 0) (/ multiplied-score 1000.0) (if (= multiplied-score -1000.0) 0.0 multiplied-score))))
+(if (= raw-nonce-score -1.0)
+    0.0
+    (if (= nonce-class 0)
+        (if (< nonce 0) (/ raw-nonce-score 1000.0) raw-nonce-score)
+        (let (...) (if (< nonce 0) (/ multiplied-score 1000.0) multiplied-score))))
```
Checking the sentinel on the raw value before any multiply/divide is both simpler and correct for every
branch at once — no per-branch patching, no risk of a fifth copy-paste mistake.

**Post-fix proof (`REPL/Kursan/_verify_finding_DPDC-S_19H_score_sentinel.repl`):** 8 checks across both
NFT (class-0) and SFT (Set-member — SFT sets share one persistent, freely-editable nonce, letting the
Set-member branches be tested directly) collections:
- All 4 branches, unscored: `0.0` in every case (`<<19H-1/2/5/6>>`).
- All 4 branches, a real score (`40.0`, multiplier `2.5`): native `40.0`/`100.0`, fragment `0.04`/`0.1` —
  ordinary math unaffected (`<<19H-3/4/7/8>>`).
- **Pre-fix (`git stash`):** identical script — Branch A `-0.001`, Branch D `-2.5`, Branch C `-0.0025`,
  Branch B already correct at `0.0` — confirms the exact 3-of-4 pattern the finding described, not assumed.
- `cd REPL && pact Z.repl` — clean, `Load successful`, no regressions.

**Interface implication:** none — `UR_N|Score`'s `DpdcSetsV1` signature is unchanged.

## Fix #18 — DPDC-S · H1 (#19H follow-up) — `UR_N|Score` renamed to `URC_N|Score` (prefix-contract violation)

**Owner-approved 2026-08-23.** Surfaced while closing #19H: "prefix is the contract" (the same principle
behind #1C's `UEV_Amount` placement) — `UR_*` is a table read; this function reads `UR_NonceClass`,
`UR_N|RawScore`, and (conditionally) `UR_SetMultiplier`, then *derives* a computed value from them
(sentinel check, multiply, fragment-divide). That's the `URC_*` ("read + derive") contract by definition,
not `UR_*`. Owner: rename it — the upcoming full redeploy will bump interfaces across the board anyway.

**Fix:** `UR_N|Score` → `URC_N|Score`, in both the `DpdcSetsV1` interface declaration and the
implementation — moved from the module's `[UR]` section into `[URC]` (now the first function there,
immediately after the `;;{F1} [URC]` marker) to match its new prefix. Zero callers anywhere in the
codebase (confirmed during #19H itself), so the rename touches no call site — purely the declaration +
implementation + the probe script that exercises it.

**Post-fix proof:** `REPL/Kursan/_verify_finding_DPDC-S_19H_score_sentinel.repl` updated (`UR_N|Score` →
`URC_N|Score` throughout) — all 8 checks from Fix #17 still pass unchanged under the new name.
`cd REPL && pact Z.repl` — clean, `Load successful`.

**Interface implication:** `DpdcSetsV1` — a function is renamed (not just added/removed). Per repo policy,
V1 stays freely editable pre-mainnet-adjustment; owner explicitly noted the upcoming full redeploy will
bump interfaces across the board regardless, so this rename doesn't need special handling now.

## Fix #19 — DPDC-MNG · C1 (#5C follow-up) — escrow-immunity check blocked EQUITY's legitimate Convert/Break

**Owner-approved 2026-08-23.** Found while building real EQUITY test coverage for #22H (owner recalled
testing EQUITY and believed the functions worked correctly — investigating that claim surfaced this).

**Root cause:** Fix #3 (#5C, already closed CRITICAL) added a blanket rule to
`DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES`: nothing can ever be burned/wiped from the `dpdc` system account —
correct for what #5C protected (fragment collateral held in escrow, orphaned if burned out from under
fragment holders). But `EQUITY::XI_ConvertPackageShares`/`XI_BreakPackageShares` legitimately use `dpdc` as
a **same-transaction, non-fragment escrow** (transfer share-tier in, burn the old tier, credit the new
tier, transfer back out) — completely unrelated to fragmentation. The blanket rule blocked both paths
outright: confirmed live, `EQUITY::XI_ConvertPackageShares → DPDC-MNG::C_BurnSFT` threw `"Not allowed for
the DPDC system account"` on a real Convert call; Break would hit the identical wall (it also burns from
`dpdc`).

**Fix — narrow the check to the actual invariant #5C cares about:** only block burn/wipe of a `dpdc`-held
nonce when that specific nonce is **currently fragmented** — not any use of the `dpdc` account name at all.
```pact
-(enforce (!= account (ref-DPDC::GOV|DPDC|SC_NAME)) "Not allowed for the DPDC system account")
+(if (= account (ref-DPDC::GOV|DPDC|SC_NAME))
+    (enforce
+        (not (fold (or) false (map (lambda (n:integer) (!= (ref-DPDC::UR_SplitNonceData id son n) zd)) nonces)))
+        "Not allowed for the DPDC system account when backing outstanding fragments"
+    )
+    true
+)
```
Implementation note: this capability only ever handles Class-0 nonces (enforced by the sibling composed
capability `DPDC-MNG|C>IZ-CLASS-ZERO`), so "is it fragmented" reduces to "does it have non-zero split-data"
— checked directly via `DPDC::UR_SplitNonceData` (already safely referenceable — same module, `02_DPDC.pact`,
deployed well before `06_DPDC-MNG.pact`). First attempt used `DPDC-F::UEV_IzNonceFragmented` directly, which
is more general (also handles Set-class fragmentation) — but `DpdcFragmentsV1` is declared inside
`09_DPDC-F.pact`, deployed *after* `06_DPDC-MNG.pact`; confirmed live that referencing it throws `"Cannot
find module: ouronet-ns.DpdcFragmentsV1"` at DPDC-MNG's own deploy step. Corrected to the DPDC-only
approach once the class-0-only guarantee made the simpler check exactly equivalent for this call site.

**Post-fix proof:** re-ran the exact EQUITY Make → Convert → Break round trip live (see Fix #20 / the new
`[6.1.1]_EQUITY.repl` suite) — Convert and Break now succeed correctly, with exact share conservation
(1,000,000 → 900,000 → [Convert] → 1,000,000 restored). `cd REPL && pact Z.repl` — clean, `Load successful`.

**Interface implication:** none — internal to the defcap body, no signature change.

## Fix #20 — EQUITY · H1 (#22H) — real, reachable, asserted REPL coverage added

**Owner-approved 2026-08-23.** Owner recalled testing EQUITY and believed the functions worked correctly —
asked to verify that recollection live before accepting or rejecting Round I's "zero coverage" finding.

**What was actually found (not assumed):**
- Real test code for EQUITY *does* exist — `REPL/Stage_02/[6.1]_DPDC.repl` "TX 014 -- Equity Collection
  Tests" calls `DPSF|C_MorphEquity` and prints nonce supplies. Round I's "zero coverage" framing was too
  strong at the literal "does test code exist" level.
- But it never actually runs: (1) `[6.1]_DPDC.repl` is commented out of `Stage02_Tester.repl` and not
  loaded by `Z.repl`; (2) even loaded directly (built the full dependency chain and ran it), it crashes on
  an earlier, already-known, unrelated bug (the dead `nonce-supply` binding in
  `DPDC-T::UEV_AmountsForTransfer`, flagged during Fix #1) before ever reaching TX014; (3) TX014 operates
  on a collection id (`"E|DH-98c486052a51"`) that nothing in the repo — genesis included — ever actually
  creates (`C_IssueShareholderCollection`/`DPSF|C_IssueCompany` have zero callers anywhere); (4) the test
  only `print`s values, no `expect` assertions, so even historically it relied on manual eyeballing.
- Along the way, caught and fixed a regression my own Fix #18 (rename) caused: `[6.1]_DPDC.repl:364,384`
  called the old `UR_N|Score` name — my "zero callers" check for that rename only grepped `.pact` files,
  missing this `.repl` reference. Updated both call sites to `URC_N|Score`.
- Building a real test then surfaced Fix #19 (the #5C/EQUITY escrow collision, logged separately) — fixing
  that was a prerequisite for EQUITY's Convert/Break paths to work at all.

**Once Fix #19 was in place, live-verified the owner's recollection was correct** — every EQUITY function
works exactly as designed: Issue creates the 8-nonce structure correctly (1,000,000 barebone shares,
7 zero-supply package tiers, `SharesPerMillion`/`CombineCapacity` computed correctly); Make/Convert/Break
round-trip with exact conservation (1,000,000 → 900,000 → ... → 1,000,000 restored, `CombineCapacity`
500,000 → 400,000 → 500,000); every validation path (50% capacity cap, modulo-divisibility, same-nonce
morph, out-of-range nonce) correctly rejects.

**Fix — new canonical REPL suite, wired into the real pipeline:**
`REPL/Stage_02/[6.1.1]_EQUITY.repl` — follows the canonical integration layout (file header/Legend/Source/
REPL-tests banners, `;;==== TXnnn · mm · <slug> ====` groups, `expect`/`expect-failure` with a single
`format` doc string each, batched via `map print`), three transactions:
- `TX-EQUITY-001` — Issue, assert owner/creator/initial-supply/`SharesPerMillion`/`CombineCapacity`/
  `TierSupplies` are all correct at genesis.
- `TX-EQUITY-002` — Make → Convert → Break round trip, asserting exact supply/capacity values at every
  step (not just "it didn't crash").
- `TX-EQUITY-003` — 5 negative-path checks: over-capacity Make, non-divisible Make, same-nonce morph,
  nonce `9` and `0` (out of the valid `1..8` range).

Wired into `Stage02_Tester.repl` (loaded right after `[4.0]_Sovereign-Executor.repl`, uncommented/active —
not the disabled `[6.1]_DPDC.repl` path), which `Z.repl` already includes — this suite now runs on every
default pipeline execution.

**Post-fix proof:** all 6 `expect` assertions in TX-EQUITY-001, 8 in TX-EQUITY-002, and 5 `expect-failure`
in TX-EQUITY-003 pass — `"Expect: success"` / `"Expect failure: Success"` on every line, none silently
skipped. Full `cd REPL && pact Z.repl` — clean, `Load successful`, no interference with the rest of the
pipeline (confirmed no id/ticker collisions).

**Interface implication:** none — new REPL file only; `[6.1]_DPDC.repl` left disabled as before (its own
unrelated pre-existing crash is a separate, already-logged backlog item, not fixed by this).

## Fix #21 — DPDC-C · M2 (#23M) — `XI_CreditOrDebitCollectables`'s dispatch `cond` fails open, not closed

**Owner-approved 2026-08-23.** Owner: `true` and `(enforce false ...)` are both boolean-typed in that
position, so the swap is a straightforward like-for-like replacement.

**Root cause:** `03_DPDC-C.pact` — `XI_CreditOrDebitCollectables`'s 16-branch `cond` re-derives, from the
actual `nonces`/`amounts` shape, which capability *should* already be granted, and asserts it via
`require-capability`. The trailing default (reached if no branch matches) was a bare `true` — meaning any
future input shape that isn't one of today's 16 exhaustive cases would silently skip every authorization
check and fall through straight to the credit/debit write.

**Fix — one line:**
```pact
-true
+(enforce false (format "Unreachable nonce/amount shape for {} {}" [nonces amounts]))
```

**Verification, and its honest limits:** this is a defense-in-depth backstop Round I itself flagged as
*currently unreachable* — the 16 branches are exhaustive over every real input shape the upstream
invariants (`UEV_NonceType`/`UEV_NonceTypeMapper`) allow today. That means there is no legitimate call that
reaches this fallback to reproduce a before/after — doing so would require deliberately breaking an
upstream invariant elsewhere, which would be a different bug. What was verified: `cd REPL && pact Z.repl`
— clean, `Load successful` — the entire existing test suite (every real credit/debit/create/transfer/burn/
wipe/set/fragment operation across every module, including the new EQUITY suite) still passes 100%,
confirming the change doesn't wrongly reject anything real. Owner accepted this scope of verification as
sufficient given the finding's own "currently unreachable" framing — no synthetic/mocked reachability test
was requested.

**Interface implication:** none — internal to the function body.

## Fix #22 — DPDC-C · M1 (#24M) — NFT fragment/hybrid credit had no amount bound at all

**Owner-approved 2026-08-23.** Owner corrected the finding's original framing: the invariant isn't
"amount=1" (that's native-NFT-only, since a whole NFT is always quantity 1) — an NFT's fragments exist in
units of **1000 per whole NFT**, so the correct bound for fragment credit is "a positive multiple of
1000". Confirmed by tracing `DPDC-F::C_MakeFragments`: it transfers the whole NFT first (forcing
`amount=1` via the already-hardened native rule), then computes `f-amount = 1000 * amount`, so today's
only caller can only ever produce exactly 1000.

**Root cause:** `03_DPDC-C.pact` — `DPNF|C>CREDIT-FRAGMENT-NONCE` (no `amount` param at all),
`DPNF|C>CREDIT-FRAGMENT-NONCES`, and `DPNF|C>CREDIT-HYBRID-NONCES`'s fragment legs enforced nothing on the
credited amount — unlike native `DPNF|C>CREDIT-NONCE`/`NONCES`, which correctly enforce `=1`.

**Fix — shared validator, wired into all three:**
```pact
(defun UEV_FragmentCreditAmount (amount:integer)
    (enforce (and (> amount 0) (= (mod amount 1000) 0))
        (format "NFT fragment credit amount of {} must be a positive multiple of 1000" [amount]))
)
```
- `DPNF|C>CREDIT-FRAGMENT-NONCE` — gained an `amount:integer` parameter (previously had none), validated;
  both call sites (`XE_CreditNFT-FragmentNonce`, and the single-fragment dispatch branch in
  `XI_CreditOrDebitCollectables`) updated to thread `amount`/`a0` through.
- `DPNF|C>CREDIT-FRAGMENT-NONCES` — validates every element of `amounts` (every entry in this call is
  already a fragment, by dispatch).
- `DPNF|C>CREDIT-HYBRID-NONCES` — validates only the fragment (negative-nonce) legs; native (positive)
  legs are untouched, since `MappedUpdateOwnerNFT` hardcodes native NFT credit supply to `1` regardless of
  any `amounts` value, making the native side of a hybrid credit already safe by construction.

**Proof — and a methodology mistake caught and corrected before it stood:** the first proof attempt called
`XE_CreditNFT-FragmentNonce` directly from a bare REPL top level with a bad amount, expecting rejection.
It "passed" (`expect-failure` succeeded) — but a control case with the *legal* amount 2000 failed
identically (`"None of the guards passed"`, from `UEV_IMC`), proving the rejections were **not** from the
new amount check at all — `XE_` functions are IMC-gated and reject *any* direct top-level call regardless
of amount. Caught this before treating it as real proof (same class of mistake as Fix #1's original
`expect-failure` pitfall). Since `C_MakeFragments` is the only registered caller and can only ever produce
exactly 1000, there is no reachable path — legitimate or otherwise — to exercise the new check through the
real capability chain. Corrected to test the validator function itself directly (`UEV_FragmentCreditAmount`
is a plain `enforce`-only function, not capability/IMC-gated):
`REPL/Kursan/_verify_finding_DPDC-C_24M_fragment_credit_amount.repl` —
- Real `C_MakeFragments` flow (enable fragmentation, fragment 1 NFT) still works, producing exactly `1000`
  fragment balance — confirms the fix doesn't touch the legitimate path.
- `UEV_FragmentCreditAmount` rejects `500`, `0`, `-1000`, `1500`; accepts `1000`, `2000`.
- `cd REPL && pact Z.repl` — clean, `Load successful`.

**Interface implication:** `DPNF|C>CREDIT-FRAGMENT-NONCE` is an internal capability, not part of any
interface — no signature change to `DpdcCreateV1`.

## Fix #23 — DPDC-N · M2 (#26M) — `royalty` field documented as an intentional forward-looking hook

**Owner-approved 2026-08-23.** Owner: the `royalty` field is designed for the upcoming Escrow/NFT
marketplace, which isn't built yet — that's exactly why nothing consumes it today. Confirmed intentional,
not dead/unfinished code, matching fix direction (b) from Round I ("if intentionally off-chain-only,
document that explicitly").

**Fix — documentation only, no behavior change:** added `@doc`/comment notes at the three places someone
would reasonably look to understand this field, cross-referencing each other and #26M:
- `0_Interfaces/02_Core.pact` — `DPDC|NonceData.royalty` schema field comment.
- `02_DPDC.pact::UR_N|Royalty` — the reader, contrasted explicitly with its actively-consumed sibling
  `UR_N|IgnisRoyalty`.
- `10_DPDC-N.pact::C_UpdateNonceRoyalty` — the write entrypoint.

**Post-fix proof:** `cd REPL && pact Z.repl` — clean, `Load successful`; comment-only changes to an
interface schema and function docs, no behavior/type change possible to regress.

**Interface implication:** none — comments only, no signature or schema shape change.

## Fix #24 — DPDC-F · M5 (#27M) — new canonical REPL suite for Make/Merge + Repurpose-without-consent

**Owner-approved 2026-08-23.** Owner initially believed EQUITY-style coverage already existed for
DPDC-F ("I think I did test it somewhere ... I think all the functions work as intended"), same shape
as the #22H discussion. Re-confirmed the only prior DPDC-F test lives in
`REPL/Stage_02/[6.1]_DPDC.repl`, which is commented out of `Stage02_Tester.repl` and, even loaded
standalone, crashes before reaching its DPDC-F section (pre-existing, logged during Fix #1) — so there
was no reachable coverage anywhere in the active pipeline. Owner: "no, you are right, we have to unblock
[this] ... yes, add the tests into the DPDC test flow properly."

**What the finding asked for, and what this closes:**
1. A real Make → Merge round trip with exact-conservation assertions (an NFT/SFT's native units and its
   1000-per-unit fragments must net to zero drift across a full round trip).
2. A real `C_RepurposeCollectableFragments`-without-consent negative path: `DPDC-F|C>REPURPOSE`'s own
   defcap only checks `length fragment-nonces = length fragment-amounts` — it does **not** check who is
   allowed to move the fragments. Traced the real gate down through
   `C_RepurposeCollectableFragments` → `XE_DebitSFT-FragmentNonce ... wipe-mode=true` →
   `DPDC-C|C>SINGLE-DEBIT`'s `(if wipe-mode (ref-DPDC::CAP_Owner id son) (ref-DALOS::CAP_EnforceAccountOwnership account))`
   branch (`03_DPDC-C.pact:321-330`) — repurpose always passes `wipe-mode=true`, so the actual authority
   check is "does the transaction's signer control the **collection owner-konto**", not "does the signer
   control `repurpose-from`". This is the same mechanism already understood from #4C.

**New file:** `REPL/Stage_02/[6.1.2]_DPDC-FRAGMENTS.repl` (canonical layout, mirrors
`[6.1.1]_EQUITY.repl`/`[6.2.1]_AQP-ANK.repl`), 3 transactions:
- `TX-FRAG-001` — Issue a fresh SFT collection + `DPSF|C_Create` a fragmentable nonce (1000 native units,
  owner=creator=ANHD). 1 `expect`.
- `TX-FRAG-002` — ANHD enables fragmentation on nonce 1, transfers 100 native units to LUMY; LUMY (a mere
  holder, not the collection owner) self-fragments her own 100 units into 100,000 fragment units
  (`DPSF|C_MakeFragments`), then merges them straight back (`DPSF|C_MergeFragments`). 5 `expect`s prove
  exact conservation at every step: native 100 → 0 → (100,000 fragments) → 0 → native 100 again.
- `TX-FRAG-003` — LUMY re-fragments her restored 100 units. EMMA (a non-owner, non-holder third party)
  attempts `DPSF|C_RepurposeFragments` to move LUMY's fragments to herself — `expect-failure`. A second
  isolation-control call keeps `patron` set to the real owner-konto (the correct IGNIS billing account)
  but still signs only with EMMA's key — also `expect-failure`, proving the rejection tracks **who signed
  the transaction** against the owner-konto guard, not the `patron` argument. A final assertion confirms
  LUMY's balance is untouched by both rejected attempts. Then ANHD (the real owner) makes the identical
  call and it succeeds, draining LUMY's fragments to 0 and crediting EMMA the full 100,000 — `expect`s on
  both balances.

**Wired into the active pipeline:** `REPL/Stage02_Tester.repl` — one new line,
`(load "Stage_02/[6.1.2]_DPDC-FRAGMENTS.repl")`, right after the EQUITY suite load.

**Proof:** built and iterated in a Kursan scratch probe first (deleted once ported to the canonical file).
`cd REPL && pact Z.repl` — clean, `Load successful`. All 12 `expect`/`expect-failure` assertions in the
new file print `"Expect: success ..."` / `"Expect failure: Success: ..."` in the full-pipeline run — none
silently skipped, no regressions elsewhere in the ~3000-line log.

**Interface implication:** none — new REPL test file only, no `.pact` source changed.
