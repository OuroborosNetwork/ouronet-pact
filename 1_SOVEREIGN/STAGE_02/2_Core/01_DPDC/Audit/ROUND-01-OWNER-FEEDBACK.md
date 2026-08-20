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

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — landed first as two redundant layers; owner asked
whether a single location would have been enough, confirmed yes, and asked for the redundant layer
removed. Final fix is **one location**: `DPDC-C::CreditOrDebitDPDC` (the universal credit/debit write
chokepoint reached by all 11 peer modules — including paths like `C_RepurposeCollectable(Fragments)` that
bypass DPDC-T entirely) now calls a new, properly-prefixed `UEV_Amount` (not a bare `enforce` in an
unprefixed helper, per owner direction on "prefix is the contract") enforcing `amount >= 0` — not `>0`, a
first pass at `>0` broke EQUITY's legitimate zero-initial-supply tier-nonce genesis, caught by the test
suite and corrected. `07_DPDC-T.pact` ends up fully untouched. List-form calls (`MappedCreditOrDebitDPDC`)
need no separate handling — it's a `map` over the single-value function, so the check runs once per
element automatically.

Post-fix proof was itself corrected mid-verification: an early draft used `expect-failure` (a REPL
TEST-ONLY construct) and produced a misleading partial-write reading, since `expect-failure` catches the
error and keeps the script running rather than modeling real transaction atomicity. Caught before treating
it as real; re-proved with the exploit submitted as its own real, uncaught transaction — it throws inside
`UEV_Amount` before ever reaching `commit-tx`, and the whole script hard-fails, which is the actual proof
that nothing it attempted (including its legit-looking leg) is ever committed. Control legit transfer
still works; full `Z.repl` pipeline green. Surfaced (but did not cause, and did not fix) a pre-existing,
unrelated crash in `[6.1]_DPDC.repl`'s NFT transfer test — confirmed via `git stash` to exist identically
on unfixed code; logged for later triage, not blocking this fix.

**Bonus:** the DPDC-C-layer fix also closes the mint/return half of DPDC-S's **C8** (`how-many-sets`
unbounded) for negative values — C8 stays OPEN pending its own explicit gate at the `DPDC-S|C>MAKE`/
`C>BREAK` cap layer (defense-in-depth + a clearer error), but the underlying exploit path is already shut.

## #2C · DPDC-T · C1 — `C_IgnisRoyaltyCollector` has no ownership check of its own

**Verdict: REFUTED (2026-08-20), hardened anyway** — the original CRITICAL framing ("any account can name
an arbitrary smart-account patron and drain it") doesn't survive re-examination, walked through live with
the owner rather than accepted on the first trace:

1. Owner: "patron can't be a smart account." Checked — `IGNIS|C>DEBIT` already calls
   `UEV_EnforceAccountType sender false`, which *rejects* smart-account patrons outright. The original
   exploit shape was never reachable; a real gap in the initial trace, not a hedge — the check was sitting
   in the same defcap being examined and wasn't cross-referenced against the proposed attack shape.
2. Narrowed to standard-account patrons: does anything check ownership there? `C_Collect`'s `UEV_Patron` —
   a different function, billing a different fee (the transfer's own usage price, not the royalty) — only
   when that fee is non-zero and virtual gas is globally on.
3. Owner: "the transfer fee in IGNIS is always non-zero, unless gas collection is turned off. IGNIS
   royalty can be zero." Combined with re-reading `C_IgnisRoyaltyCollector`'s own bypass
   (`ivgz = (not virtual-gas-toggle)` exactly, not a separately-tracked flag) — royalty-nonzero and
   ownership-check-skipped key off the identical toggle and can never both hold. Whenever there's a real
   royalty to steal, gas is on, the transfer fee is (per the owner) necessarily non-zero, `UEV_Patron`
   necessarily runs in the same atomic transaction as the earlier-evaluated royalty debit, and a rejection
   there rolls back the whole transaction — royalty debit included, per the atomicity behavior already
   proven live during Fix #1.
4. No reachable state lets an attacker walk away with anything. **REFUTED.**

**Owner decision: harden anyway.** The royalty debit's safety currently rides entirely on an *external*
invariant (the toggle relationship between two unrelated functions) rather than anything it checks itself
— explicitly requested as a "just in case" fallback, same call the audit trail already made once before on
a different module (SWP's H12).

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #2)** — one line, `07_DPDC-T.pact:305`, inside
`IGNIS|C>DEBIT`: `(ref-DALOS::CAP_EnforceAccountOwnership sender)` (`sender` here is `patron` at the call
site), the same call `DPDC-T|C>TRANSFER` already uses for the real transfer sender. No test in the repo
had ever turned IGNIS gas collection on before this round (confirmed by grep) — built a probe that does:
a real owner (Emma) still collects a genuine, real 500.0 IGNIS royalty on a legitimate transfer; an
attacker naming Emma as patron without controlling her account is hard-rejected exactly at the new line
(`Keyset failure (keys-all): [PK_Emma...]`), submitted as a real uncaught transaction. Full `Z.repl`
pipeline green.

## #3C · DPDC-F · C2 — unsigned `amount` in Make/Merge Fragments

**Verdict: CONFIRMED, ALREADY CLOSED BY FIX #1 (2026-08-20)** — flagged in Round I as the identical root
defect as #1C, reached through `C_MakeFragments`/`C_MergeFragments` instead of a plain transfer, and noted
as a likely "bonus closure" of Fix #1 when that fix landed. Never independently live-tested by name until
requested this round: "prove it's closed, then close it."

Live-reproduced `DPSF|C_MakeFragments` with a negative amount, submitted as a real uncaught transaction.
Full stack trace confirms the exact mechanism predicted — `C_MakeFragments` routes its constituent debit
through `DPDC-T::C_Transfer` exactly like an ordinary transfer, landing on the identical chokepoint:
```
DPSF|C_MakeFragments → DPDC-F::C_MakeFragments → DPDC-T::C_Transfer → XI_TransferNonces
  → XE_DebitSFT-Nonce → ... → CreditOrDebitDPDC → UEV_Amount   ← rejected here
03_DPDC-C.pact:436 — "Amount cannot be negative"
```
Control case (legit fragmentation, positive amount) still works correctly: 100 units of a native nonce
converted to 100,000 fragment units (the 1000× ratio), balance zeroed exactly as expected. No new code
change — **no Fix #3 exists because there was nothing left to fix.** Closed on the strength of Fix #1's
own proof, now independently verified rather than assumed.

## #4C · DPDC-F · C1 — `C_RepurposeCollectableFragments` "no consent" gap

**Verdict: REFUTED, design-intentional (2026-08-20)** — the original framing ("no consent check on
`repurpose-from`") missed *what actually gates this instead*. Re-read `DPDC-C|C>SINGLE-DEBIT`:
`wipe-mode=true` (which `C_RepurposeCollectableFragments` always sets) swaps the check from
`CAP_EnforceAccountOwnership account` to `ref-DPDC::CAP_Owner id son` — the caller must own the
*collection*, not the source account. `UEV_NonceQuantityInclusion` (balance sufficiency) still runs either
way, and the cap is `@event`-tagged (on-chain audit trail).

Owner: this is a deliberate account-recovery tool. Real flow — an account is stolen or its holder dies,
they (or their heirs) contact the collection admin off-chain, admin verifies and repurposes the holdings
to a new account. No freeze/`can-wipe` precondition wanted — confirmed intentional, on purpose, less
friction for an already admin-gated, rare flow.

**Broader discussion, not a verdict on a bug** — owner named unprompted: this pattern (owner has complete
dominion — freeze/wipe/unfreeze/remint/burn/repurpose) exists for every token in this system, not just
fragments; every holder implicitly trusts the issuer to be fair. Considered and dead-ended: a
holder-initiated "request repurpose" on-chain event so admin only acts on registered requests — defeats
its own purpose, since a genuinely lost/compromised account can't sign a request either. Landed on: a
future **Heir System** — advance heir designation (signed while still in control) + inactivity-triggered
succession, removing admin discretion from the succession case specifically. Captured in
`HEIR-SYSTEM-PONDERING.md` as an explicit non-decision, not scheduled work — a placeholder for whenever
that's taken up, not part of this audit's fix list.

**No code change.** #4C closes as REFUTED; the design conversation continues in the pondering doc.

## #5C · DPDC-MNG · C1 — burn/wipe can destroy `dpdc`'s escrowed fragment collateral

**Verdict: CONFIRMED, FIXED (2026-08-20).** Owner proposed making `dpdc` immune to freeze+wipe. Checked
before implementing: `DPDC-MNG-C>WIPE-SFT`/`WIPE-NFT` do require `frozen=true`, so freeze-immunity alone
would have closed wipe — but `BURN-SFT`/`BURN-NFT` never check freeze at all, only the burn role, so
freeze-immunity alone would have left burn fully open (e.g. via an accidental/malicious role grant on
`dpdc`, no freeze involved anywhere). Both already compose the same shared capability,
`DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES` — one check there (`account != GOV|DPDC|SC_NAME`) closes both,
permanently, regardless of role/freeze state, rather than two separate patches.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #3)** — one line, `06_DPDC-MNG.pact:304`. Live-proven both
halves: burning `dpdc`'s escrowed collateral (with the burn role granted directly, no freeze anywhere in
the chain) rejected at the new line; wiping it (frozen + `can-wipe` enabled — the real preconditions the
legitimate path requires) rejected at the same line. Ordinary burn on a real account still works
(10,000 → 9,950). Full `Z.repl` pipeline green. The "compounding" respawn risk from the original finding
needed no separate fix — it was entirely downstream of the collateral being destroyed in the first place,
which can no longer happen.

## #6C · DPDC-S · C2 — composite set-class `allowed-sclass=0` permanently strands the constituent

**Verdict: CONFIRMED, FIXED (2026-08-20).** `UEV_CompositeSetDefinition` only bounded the *maximum* class
referenced in a definition, never that each individual position is `> 0`. Set-class `0` is the reserved
"not part of any set" sentinel — a position naming it is satisfied trivially by any ordinary native nonce
at Make time, but Break can never look up a set-class-0 row (none is ever inserted), permanently stranding
the constituent.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #4)** — one enforce, `08_DPDC-S.pact:586-589`, folding
`allowed-sclass > 0` across every position in the definition (this file's own convention for combining N
boolean checks). No sibling per-element validator existed to reuse (Primordial's analog only checks list
size). Live-proven against a real collection genesis already gave 4 real set-classes to — the exploit
(`allowed-sclass=0`) is hard-rejected exactly at the new line even though the *old* check alone would have
trivially accepted it (`0 <= 4`); the legit case needed no new setup since genesis's own composite set
definition already exercises the success path, confirmed by the full `Z.repl` pass.
