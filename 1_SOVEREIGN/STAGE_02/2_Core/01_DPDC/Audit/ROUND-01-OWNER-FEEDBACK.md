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

## #7C · DPDC-S · C1 — `C_UpdateSetMultiplier` crashes unconditionally, type bug

**Verdict: CONFIRMED, FIXED (2026-08-20).** `08_DPDC-S.pact:310` bound `UR_SetMultiplier`'s `:decimal`
return into a `:string`-annotated `let` variable — copy-pasted from the sibling `RENAME` cap (correctly
`:string` there) with the annotation never updated. Pact enforces `let` type annotations at runtime, so
the binding throws before any real logic runs — an unconditional crash on every call, any arguments.

**Live-chain check, owner-requested:** is this also on the deployed mainnet module? Confirmed yes — a real
dirty-read via Pythia's keyless path (`OuronetInformational/pythia-dirty-read-access.md`) against
`ouronet-ns.DPDC-S` (live hash `Qslr8IXA10HEYsiHPnjvvCy4hYNIh3bfPQvD7w5QEoU`) shows the identical broken
line. **`C_UpdateSetMultiplier` has never worked in production** — which is also exactly why no REPL test,
local or otherwise, ever caught it: the feature has been silently dead the whole time, so nothing has ever
exercised a successful call to notice its absence.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #5)** — one word, `current-multiplier:string` →
`current-multiplier:decimal`. Live-proven against a real genesis set-class (Wonder Coach, Bronze):
succeeds now (`1.0 → 1.5`, persisted correctly), and the "must differ from current" guard — which depends
on this same variable — now also works correctly. Full `Z.repl` pipeline green.

**Owner's broader question, not yet actioned:** given zero REPL coverage is why this (and several other
Round I findings — DPDC-S Make/Break, DPDC-MNG's Wipe family, EQUITY, the gas-collection-off blind spot)
went uncaught, should a comprehensive DPDC REPL test suite be built once Round I triage finishes? Agreed
this is worth doing — tracked as a planned follow-up, not started this round. See chat for the standing
proposal; to be scheduled once the CRITICAL/HIGH list is clear.

## #8C · DPDC-S/DPDC-C · C3 — `how-many-sets` unbounded

**Verdict: CONFIRMED, ALREADY CLOSED, LIVE-VERIFIED (2026-08-21).** Round I flagged this as PLAUSIBLE (entry
gap confirmed, terminal impact not re-derived). First pass at presenting it reasoned "probably already
closed by Fix #1" without checking — owner correctly pushed back: "have you checked... if it indeed works,
we have a problem."

Checked both halves live, real uncaught transactions against the real Bronze primordial set-class:
- Negative `how-many-sets=-1`: hard-rejected, full stack trace lands on `UEV_Amount` inside
  `CreditOrDebitDPDC` (`03_DPDC-C.pact:436`) — the exact Fix #1 chokepoint, reached via the mint leg
  (`XB_CreditSFT-Nonce`) before ever touching the constituent debit.
- Zero `how-many-sets=0`: not rejected (Fix #1's floor is deliberately `>=0`), but confirmed harmless —
  real constituent balance unchanged, only effect is two new empty bookkeeping rows. Genuine no-op.

**No code change — nothing left to fix.** Same outcome as #3C: the concern was real when raised, and is
now independently verified closed rather than assumed closed. All 8 Round I CRITICALs are now resolved
(5 fixed, 3 closed via Fix #1's shared chokepoint with no additional code).

## #8C correction — `how-many-sets = 0` must be rejected, not accepted as a no-op

**2026-08-21.** Owner overruled the "no code, zero is harmless" close above: an operation that claims to
*make* or *break* sets should never silently succeed while moving nothing — same category as rejecting
zero-amount transfers, already done elsewhere. A harmless no-op is still a bug if the function claims to
have done something it didn't.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #6)** — `how-many-sets` added as an explicit parameter to
`DPDC-S|C>MAKE`/`C>BREAK` with `(enforce (> how-many-sets 0) ...)`, closing exactly the gap the original
Round I fix direction named. Both negative and zero now rejected earlier and more clearly, directly at
DPDC-S's own gate. New control proves a real Make 3 → Break 3 round trip still works with exact
conservation (`1000 → 997 → 1000`). This is the true final closure of #8C — the earlier verdict correctly
identified both halves as *already blocked from doing harm*, but the owner's follow-up correctly identified
that "doesn't cause harm" and "should be allowed to run" are different questions, and the answer to the
second one was no.

## #9H · DPDC · H1 — Talos SFT branding-update arity bug

**Verdict: CONFIRMED, FIXED (2026-08-21).** `DPSF|C_UpdatePendingBranding` passed 7 args to DPDC's
6-parameter `C_UpdatePendingBranding` — a stray leading `patron` copy-pasted from the neighboring
`C_UpgradeBranding` wrapper. 100% failure rate on every call, any input, for a paid (400 IGNIS) feature.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #7)** — dropped the stray argument. Also resolved, live
rather than assumed, the secondary question the finding raised (does the cross-module call even resolve
when `ref-DPDC` is typed `module{DpdcV1}` but the function is declared on the separate
`BrandingUsageTertiaryV1` interface, which itself delegates to a *third* module, `BRD`) — it does, no
retyping needed anywhere. Live-proven: SFT branding update now succeeds and persists correctly (pending
logo/description both set and read back from real `BRD` storage); NFT sibling (already correct, used as
control) still works. Full `Z.repl` pipeline green.

## #10H · DPDC-I · H1 — NFT issuance billed at the SFT price

**Verdict: CONFIRMED, FIXED (2026-08-21).** Owner asked directly whether this had actually been verified
before agreeing to fix it — it hadn't; Round I's trace was a static source read only. Re-confirmed the bug
is real by reading the current source (`04_DPDC-I.pact:188-193`, both branches of `if son` query the
identical `"dpsf"` price key) before touching anything.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #8)** — one word, `"dpsf"` → `"dpnf"` in the NFT branch.
Genesis's own signed `coin.TRANSFER` capabilities are already generous (computed from the correct `dpnf`
price), so a signed-cap pass/fail test can't discriminate this bug — measured the real `coin` balance delta
on a freshly-issued NFT collection instead. Pre-fix: real charge `0.306` KDA. Post-fix: `0.3825` KDA —
exactly `0.306 × 1.25`, and `1.25` is exactly `0.5/0.4`, the precise `dpnf`/`dpsf` ratio. Not just "went
up" — mathematically exact confirmation the fix changed only the intended input. Full `Z.repl` green.

## #11H · DPDC-I · H2 — solo NFT owner==creator locked out of role-exemption/modify-creator/modify-royalties

**Verdict: CONFIRMED, FIXED (2026-08-21).** In the NFT issuance branch where `owner-account ==
creator-account` (a solo creator, no separate patron), `C_IssueDigitalCollection`'s final
`XB_DeployAccountNFT` call wrote `role-exemption`, `role-modify-creator`, and `role-modify-royalties` as
`false` into the `Account` table — the table actually consulted at call time — even though `VerumRoles`
claimed the owner had them. Owner confirmed this reads as a plain copy-paste slip (three flags that should
have mirrored the SFT sibling branch, which already writes `true` for the equivalent roles) and asked for
the fix → live proof → documentation sequence, same as every other finding.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #9)** — flipped the three flags `false` → `true` in the
NFT `owner==creator` branch. Live proof: issued a fresh solo NFT collection
(`SCPN-98c486052a51`, owner==creator==`KST.ANHD`), minted a real nonce, and called
`TS02-C2::DPNF|C_UpdateNonceRoyalty` as the solo owner — `Write succeeded`, royalty read back as `50.0`.
Before the fix this would have been rejected outright regardless of what `VerumRoles` claimed, since
`Account` is the table the role-gate actually reads. Full `Z.repl` pipeline green, no regressions.

## #12H · DPDC · H4 — shared `XE_*` write surface "zero value-level validation"

**Verdict: REFUTED (verified live, 2026-08-21).** Owner asked to actually check every real call site before
accepting the claim, rather than take Round I's static trace at face value. Traced `DPDC-C`'s debit path,
`DPDC-MNG`'s burn/wipe, `DPDC-S`'s set-class creation, and `DPDC-I`'s genesis specs: every value reaching
`XE_*` is either self-derived (`current + 1`, never attacker input) or pre-validated by the calling defcap
before `require-capability` allows the write (e.g. `UEV_NonceQuantityInclusion` blocks over-debiting before
`XE_W|Supply` runs). The intended architecture — checks live in the defcap, `XE_*` is write-only — holds in
every path actually traced, not just in theory. Closed as refuted, no code change needed.

## #12Hb · DPDC-C/DPDC-N · new — nonce name/description/meta-data/asset-type/uri fields had zero content
validation, anywhere, ever

**Verdict: CONFIRMED, FIXED (2026-08-21).** Found while verifying #12H, not part of its original scope —
`DpdcUdcV1.DPDC|NonceData`'s free-text fields (`name`, `description`, `meta-data.meta-data`, `asset-type`,
the three `uri-*` link bundles) had no length/content check at creation or update, ever. Owner confirmed
these were deliberately left open (arbitrary-size metadata wanted) but agreed unbounded free text is a real
storage-bloat/griefing vector once flagged. Before settling limits, traced actual consumers rather than
guessing: `meta-data.meta-data` is a real NFT trait bag consumed by AQP-ANK/AQP-SCORE for reward scoring,
not decorative; `composition` (inside the same nested object) turned out to be a different, non-free-text
field entirely — the module's own auto-derived record of which real nonces are locked in a composite NFT
set, later found to have its own separate integrity gap, logged as #12Hc. Also surfaced a genuine Pact-level
constraint before proposing a design: `(keys someObject)` throws a type error in this Pact version — there's
no way to enumerate an untyped object's keys — confirmed live, which is why `meta-data.meta-data` got a
coarse total-size ceiling instead of the originally-envisioned precise per-key/per-value cap.

Owner set `name` (≤256 chars) and `description` (≤1024 words, ≤256 chars/word) directly; the rest
(`meta-data.meta-data` ≤8192 chars serialized, `asset-type` ≥1-of-7 flags, `uri-*` ≤2048 chars/link) were
worked out jointly after the consumer trace and the Pact constraint above. Owner also clarified the
primary/secondary/tertiary URI design intent mid-discussion (three quality tiers of the *same* asset —
normal/high-res/thumbnail — not three independent asset sets), which confirmed the 7-type capacity concern
raised along the way was a non-issue: each `uri-*` slot already carries all 7 typed sub-fields on its own.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #10)** — five new validators
(`UEV_Name`/`UEV_Description`/`UEV_MetaDataBag`/`UEV_AssetType`/`UEV_UriData`) added once in `02_DPDC.pact`
next to the existing `UEV_Royalty`/`UEV_IgnisRoyalty`, wired into `DPDC-C::UEV_NonceDataForCreation`
(creation + whole-object update, since `C_UpdateNonces` already reuses that function) and each DPDC-N
per-field defcap (`SET-NAME`/`SET-DESCRIPTION`/`SET-META-DATA`/`SET-URI`) for the per-field update paths —
same shared-chokepoint pattern the royalty/ignis fields already used. Live-proven with 13 checks covering
both creation and every update entrypoint: every oversized/invalid input rejected, every boundary/legit
input accepted (`Write succeeded`), Fix #9's own probe re-verified still working once updated off the now-
forbidden all-zero asset-type sentinel. Full `Z.repl` green — confirmed no real genesis/scenario anywhere in
the pipeline relied on the all-zero pattern.

## #12Hc · DPDC-N · new — minted NFT Set instance's own data (incl. `composition`) directly editable

**Verdict: CONFIRMED, FIXED (2026-08-21).** Found while scoping #12Hb. Worked out the full model together
before any code was written — owner walked through what a "set class" vs. a "set nonce" actually means
(NFTs are individually unique, so different combinations of constituents produce genuinely different
instances, each needing its own `composition` record; SFTs are fungible, so every possible combination
produces an identical result, which is why an SFT set-class has exactly one shared nonce instead). Three
distinct pieces got disambiguated in the discussion:
1. The Set-Class *recipe* (what must be combined) — verified live: already permanently immutable, no update
   path exists at all, stricter than "locked while in use." Owner confirmed intentional (wrong recipe = 
   disable that set-class, define a new one).
2. The Set-Class *metadata template* — owner asked directly whether editing it after instances already
   exist retroactively changes those instances ("i cant remember this"). Traced the actual read path
   (`UR_NativeNonceData` is a flat table read, no live reference to the template) to answer definitively:
   no, template edits only shape future mints. Confirmed this should stay freely editable, as-is.
3. Each individual minted instance's own stored data — this is what `C_BreakNonFungibleSet` actually
   trusts, and it was directly editable via `DPDC-N::C_UpdateNonces`/the per-field update family by
   targeting the instance's nonce ID — the real gap, scoped to NFT only after owner explained the
   SFT/NFT structural difference above (confirmed live: SFT set-class nonces are never re-derived per Make
   and their Break path reads the immutable recipe, not any mutable field — nothing to protect there).

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #11)** — new `DPDC-N::UEV_NotSetInstance`, wired into
`DPDC-N|C>DATA` (the shared capability all 7 per-field update entrypoints compose through) and
`DPDC-N|C>SET-DATA` (the whole-object `C_UpdateNonces` path). Live-proven: a real Primordial NFT Set made
from 2 real constituent nonces — direct edits to the spawned instance rejected (name + meta-data both),
the Set-Class template stays editable (`Write succeeded`), an ordinary never-set-involved primordial nonce
stays editable (regression-clean), and an equivalent SFT Set's one shared nonce stays fully editable
(confirmed unaffected, exactly as scoped). Full `Z.repl` green.

**Investigation chain closed:** #12H (REFUTED) → #12Hb (FIXED, Fix #10) → #12Hc (FIXED, Fix #11). No further
open items.

## #13H · DPDC-R · H1 — unfreeze gated on `can-freeze`, brick risk

**Verdict: CONFIRMED, FIXED (2026-08-21).** Owner: "unfreeze should be like a release valve, regardless of
can-freeze" — confirming the design intent Round I inferred was correct: `can-freeze` should only ever gate
new freezes, never the ability to release an account that's already frozen.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #12)** — `DPDC|C>FRZ-ACC`'s single call to
`UEV_CanFreezeON` now only runs on the freeze direction (`frozen=true`); unfreeze (`frozen=false`) is
unconditional. Live-proven: froze a real account, renounced `can-freeze`, unfroze it anyway (`Write
succeeded`) — while freezing a *different* account in the same now-`can-freeze=false` state was still
correctly rejected, confirming the fix didn't over-broaden into a blanket bypass. Confirmed via `git stash`
that the pre-fix script genuinely hard-fails at the unfreeze step. Full `Z.repl` green.

## #14H · DPDC-MNG · H1 — pause doesn't gate mint/burn/wipe/respawn

**Verdict: REFUTED, design-intentional (2026-08-21).** Owner: pause is meant to halt transfers only, not
administrative supply operations — this architecture is drawn from MultiversX's token design, where pause
functions the same way (a trading halt, not a full freeze). Verified the implementation matches that intent
before closing: `DPDC-T` correctly enforces `UEV_PauseState id son false` on both real transfer call sites;
`DPDC-MNG`'s mint/burn/wipe/respawn functions correctly never check it. No code change needed.

## #15H · DPDC-S · H1 — `score-multiplier` unbounded at Define, unbounded magnitude at Update

**Verdict: CONFIRMED, FIXED (2026-08-21/22).** Before treating this as a simple "add a bound" fix, traced
who actually consumes the multiplier — found `UR_N|Score` (the only function that applies it) has zero
callers anywhere, and `URC_NoncesSummedScore` (Make-time set score computation) sums raw constituent
scores with no multiplier applied at all. Owner: the multiplier is *meant* to apply "when a nonce is staked
to a pool where a score is attached... using the raw score of the nonce" — i.e. in AQP, not necessarily in
DPDC-S's own Make-time math. Attempted a live mainnet check of real Bloodshed set-classes via Pythia to see
whether deployed scores reflect the multiplier — inconclusive, since local REPL genesis identities are
synthetic and collection IDs are block-derived, not matchable by guessing; left open pending the real
mainnet ID/owner. Wrote a separate investigation handoff for an AQP-focused review of whether/where the
multiplier should be wired into staking-time scoring — not yet answered, tracked independently.

Owner decision, independent of the AQP question: cap the multiplier at **100x** now, closing the original
finding (no bound existed anywhere) regardless of where the multiplier ultimately gets consumed.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #13)** — new shared `DPDC-S::UEV_ScoreMultiplier`
((0,100] + 3-decimal precision) wired into both Define (Primordial/Composite/Hybrid, previously completely
unvalidated) and Update (previously precision-only). Live-proven with 9 checks: all 4 bad-multiplier Define
attempts rejected, boundary (100.0) and ordinary (2.5) accepted; both bad-multiplier Update attempts
rejected, legit update (50.0) accepted. Full `Z.repl` green, including Bloodshed's real 1.1x genesis
multiplier still passing cleanly.

## #15H follow-up · DPDC-S · H1 — `score-multiplier` made immutable after Define

Owner asked directly whether the multiplier is stable after being set — answer: no, `C_UpdateSetMultiplier`
could be called any number of times, at any point (before or after instances exist), within the Fix #13
bound. Owner: "I want it immutable similar to how the combining nonces are immutable" — same treatment
already confirmed correct for the Set-Class recipe: no update path at all, ever; a wrong value means
disabling that Set-Class and defining a new one. Confirmed the cap (100x) therefore only needs enforcing at
Define time now, since Update no longer exists.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #14)** — removed `C_UpdateSetMultiplier` entirely:
`DPDC-S|C>MULTIPLIER`, `XI_Multiplier`, `XI_U|SetMultiplier`, and both Talos wrappers
(`DPNF`/`DPSF|C_UpdateSetMultiplier`) gone. The Fix #13 bound survives, now enforced only at Define. Checked
first that nothing in the canonical genesis/REPL suite legitimately called the update function — none did;
only two Kursan scratch probes did, both updated (one now proves immutability directly by reading the value
back with no update call available; the other's now-dead Update-path block commented out with an
explanatory note, kept as a historical record of Fix #5). Full `Z.repl` green.

## #16H · DPDC-T · H1 — `UEV_TransferRoles` receiver check silently re-tested sender

**Verdict: CONFIRMED, FIXED (2026-08-22).** Owner directed checking DPTF/DPOF's transfer-role pattern
first, fix DPDC-T to match. Found DPOF's `UEV_MoveRoleCheck` (`06_DPOF.pact:1595-1631`) already implements
this correctly — sender and receiver each read their own role via `UR_R-Transfer`, combined with
`enforce-one`; DPTF appears not to enforce `r-transfer` in its transfer path at all, so DPOF was the real
reference. DPDC-T's `URC_TransferRoleChecker` (the "is the feature active" gate) was already correct and
even improved on DPOF's version (an escrow-account exemption) — the bug was isolated to one line in
`UEV_TransferRoles`, where the receiver-side binding read `sender` a second time instead of `receiver`.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #15)** — one-line fix, `sender` → `receiver`. Live-proven:
granted the transfer role to an account other than the sender, transferred from the role-less sender to the
role-holding receiver — under the intended sender-OR-receiver semantics this must succeed, and does
post-fix (`Successfully transfered...`); the identical script hard-fails at that exact call pre-fix
(`git stash`-confirmed), proving the bug was real. Full `Z.repl` green.

## #17H · DPDC-T · H2 — `C_RepurposeCollectable` skips frozen/transfer-role gates

**Verdict: REFUTED, design-intentional (2026-08-22).** Owner: "repurpose must bypass everything." Checked
the actual code first — confirmed it's not a transfer, it's `XE_Debit*-Nonce(..., wipe-mode=true)` then
`XB_Credit*-Nonce(...)` on the *same* nonce (same metadata, new holder), matching the owner's description.
`wipe-mode=true` is a shared authorization-gate-swap primitive (owner-only vs. account-owner), not the
actual DPDC-MNG Wipe feature — confirmed and the owner agreed "wipe-like mechanic" is the precise framing,
not a real Wipe. Owner initially wanted the source account left frozen afterward (a liability), but on
reflection rejected it: doing so would route through the real freeze path, which still requires
`can-freeze=true` (#13H) — making the escape hatch's success conditional on a flag it's specifically meant
to route around. No code change; consistent with #4C's identical closure for the fragment sibling.

## #18H · DPDC-C · H1 — Native NFT Credit never checks target isn't already held

**Verdict: REFUTED, verified live (2026-08-22).** Owner: NFT ownership lives on a holder field, moved by
setting it on transfer; by the time credit runs, it's already fed correct data by design. Checked all 3
real callers of the raw credit primitive: `DPDC-T::C_Transfer` (every variant debits sender — which
validates current holdership — before crediting receiver, atomically in one call); `DPDC-C::C_CreateNewNonce`
(brand-new nonce, no prior holder possible); `DPDC-MNG::C_RespawnNFT` (explicitly enforces
`UEV_NftNonceExistance ... false`, i.e. current holder is `BAR`, before crediting). All three correctly gate
today. Owner decided to leave the primitive unchanged — no code change, matches the caller-discipline model
already confirmed correct for DPDC-T.

## #15H follow-up 2 · DPDC-S · H1 — `score-multiplier` lower bound tightened to 1.0

Surfaced while discussing #19H's sentinel bug: the multiplier is meant to boost a score, never quietly
shrink it. Owner: at Define, legal range is `1.0` to `100.0`, not `(0, 100]` — a value like `0.5` would
silently reduce every member's score below its raw value, which was never the intent.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #16)** — `UEV_ScoreMultiplier`'s magnitude check tightened
from `(0, 100]` to `[1.0, 100.0]`. Live-proven: `0.5` now correctly rejected (previously legal), `1.0`
(the new floor) correctly accepted, all prior checks still pass. Full `Z.repl` green.

## #19H · DPDC-UDC/DPDC-S · H1 — `UR_N|Score` leaks the `-1.0` unscored sentinel in 3 of 4 branches

**Verdict: CONFIRMED, FIXED (2026-08-22).** Owner: an unscored nonce must always read back as score `0.0`,
across the board, in every branch. Discussing this also clarified two related, already-actioned points:
(1) `UR_N|Score` genuinely is designed to apply the Set-Class multiplier — confirmed it's the only function
in the codebase that does, though (as established under #15H) nothing currently calls it; (2) surfaced the
[1.0,100.0] multiplier-floor tightening (Fix #16, logged separately) and the need to warn the AQP handoff
against double-applying the multiplier if it ever wires in this cooked reader.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #17)** — centralized the sentinel check once, at the top,
on the raw untouched score, closing all 3 broken branches at once (no per-branch patching). Live-proven
across 8 checks (NFT class-0 + SFT Set-member, unscored + real-score, native + fragment) — all unscored
cases now `0.0`; pre-fix (`git stash`) confirms the exact bug shape: Branch A `-0.001`, Branch D `-2.5`,
Branch C `-0.0025`. Full `Z.repl` green.

## #19H follow-up · DPDC-S · H1 — `UR_N|Score` renamed to `URC_N|Score`

Owner: by the prefix contract itself ("prefix is the contract"), this function reads several things and
derives a computed value from them — that's `URC_*` ("read + derive"), not a plain `UR_*` table read.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #18)** — renamed in the `DpdcSetsV1` interface and
implementation, moved into the module's `[URC]` section. Zero callers anywhere meant no call site needed
updating. Live-proven: the full #19H probe suite (8 checks) still passes unchanged under the new name.
Z.repl green.

## #20H · DPDC-N · H1 — `C_UpdateNonceIgnisRoyalty` has no upper bound at all

**Verdict: REFUTED, design-intentional (2026-08-23).** Proposed capping at 500.0 IGNIS ($5.00), matching
ATS's own fix for the identical bug class on `UEV_Fee`. Owner rejected: this is a flat per-unit royalty on
potentially very high-value NFTs — there's no principled magnitude ceiling any more than there's a ceiling
on what an estate could be worth. A $10M NFT could legitimately warrant a $10K movement royalty. Left to
the collection owner's discretion; the existing precision-only check in `UEV_IgnisRoyalty` stays as the
only validation. No code change. (Separately noted, not part of this decision: the compounding-with-amount
effect and the lack of a transfer-time snapshot/max-price guard remain tracked under `M1`.)

## #21H · DPDC-S · H2 — `score-multiplier` unvalidated at Define, checked at Update

**Verdict: ALREADY CLOSED by #15H's fix chain (2026-08-23).** This is the exact same underlying gap #15H's
fixes already closed: Fix #13 added precision + magnitude validation to all three Define capabilities
(previously zero validation there), Fix #14 removed the Update capability entirely (so "checked only at
Update, not Define" is now moot — Update doesn't exist), Fix #16 tightened the floor to `[1.0,100.0]`. No
separate action needed.

## #5C follow-up · DPDC-MNG · C1 — escrow-immunity check blocked EQUITY's legitimate Convert/Break

Found while building real EQUITY test coverage for #22H — the already-closed #5C fix (blanket "never
burn/wipe the `dpdc` account") turned out to block a completely legitimate, unrelated use: EQUITY's
Convert/Break flows use `dpdc` as a same-transaction escrow, never fragmentation. Owner: "you are right, we
have to unblock EQUITY functionality" — confirmed narrowing the check to fragmentation-specific is correct.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #19)** — the `dpdc`-account block now only fires when the
specific nonce being burned/wiped is currently fragmented (checked via `DPDC::UR_SplitNonceData`, since
this capability only ever handles Class-0 nonces). Live-proven: EQUITY's Convert and Break now succeed
correctly with exact conservation. Z.repl green.

## #22H · EQUITY · H1 — zero REPL/test coverage for the entire module

**Verdict: CONFIRMED gap existed, FIXED (2026-08-23).** Owner recalled testing EQUITY and believed all
functions worked correctly — asked to verify that live before accepting Round I's finding. Investigation
found the claim was partially right (test code existed) but the coverage was fully non-functional:
`[6.1]_DPDC.repl`'s "TX 014" is unreachable (file disabled in the active pipeline, and even run directly it
crashes on an earlier unrelated bug before reaching TX014; the collection id it targets is never actually
created by anything; the assertions were print-only, no `expect`). Also caught and fixed, along the way, a
regression from my own #19H rename (`[6.1]_DPDC.repl` still referenced the old `UR_N|Score` name) and
uncovered a second real bug (the #5C/EQUITY escrow collision, fixed separately, Fix #19) that was actively
preventing EQUITY's Convert/Break from working at all.

Once that was fixed, live-verified the owner's recollection was correct: every EQUITY function — Issue,
Make, Convert, Break — works exactly as designed, with exact share conservation across a full round trip,
and all validation paths (capacity, modulo, nonce range) correctly reject bad input.

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #20)** — new canonical REPL suite
`REPL/Stage_02/[6.1.1]_EQUITY.repl` (Issue baseline + Make/Convert/Break round trip with exact-value
assertions + 5 negative-path checks), wired into `Stage02_Tester.repl`'s active load chain so it now runs
on every `Z.repl` execution. 19 assertions total, all passing. Full `Z.repl` green.

## #23M · DPDC-C · M2 — dispatch `cond` fails open on an unmatched shape

**Verdict: CONFIRMED, FIXED (2026-08-23).** Owner confirmed `true` → `(enforce false ...)` is a
straightforward like-for-like swap (both boolean-typed in that position).

**FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #21)** — the `cond`'s trailing default now hard-aborts
instead of silently skipping every `require-capability` check above it. Verified honestly within the
limits of what a "currently unreachable" defense-in-depth backstop allows: full `Z.repl` (every real
credit/debit path in the entire test suite) still passes 100% clean — no legitimate call was ever wrongly
rejected. No live "used to silently pass, now aborts" reproduction is possible without deliberately
breaking a different, unrelated upstream invariant — owner accepted this scope of verification.
