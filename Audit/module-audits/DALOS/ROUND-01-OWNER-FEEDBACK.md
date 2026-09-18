# DALOS Audit — Round I Owner Feedback (append-only)

Owner's verdict per finding, recorded the same turn the verdict is reached, per the HARD RULE in
`README.md`. Findings are presented one at a time in `ISSUES-RANKED.md` order. Never edit past entries —
corrections get a new, dated entry that supersedes the old one.

---

## #1C · DPMF — entire module non-functional (no `create-table` calls) — **NOT A BUG ✅** (owner, 2026-08-23)

**Owner's correction:** DPMF is the original MetaFungible module. It evolved into DPOF (OrtoFungible) —
per the owner, DPOF is functionally "MetaFungibleV2," just renamed OrtoFungible rather than kept as a
MetaFungible version bump. Every meta-fungible was migrated to DPOF. DPMF is intentionally retired —
kept in the tree only for historical/migration reference, exactly as CLAUDE.md's own "Historical note:
DPMF → DPOF" already documents. It was never meant to be a live, callable module post-migration.

**Disposition:** the finding's *technical* claim stands (DPMF genuinely has no `create-table` calls and
every function fails at first use) — that part is CONFIRMED, not retracted. What's rejected is the
*bug* framing: this isn't an oversight that broke a module that was supposed to work, it's consistent
with DPMF being deliberately dead weight. No fix needed, no retirement action needed beyond what's
already true today (it doesn't work, and it isn't supposed to). Closed, no code change.

**Downstream notes (not re-opened as separate findings, just flagged for the eventual StoicSyntax pass):**
- #12M (`AHU`/`AUP_OrtoFungible*` hardcoded-account pattern) is DPOF-side, unaffected by this.
- #36M (DPMF's stale duplicate Elite-Auryn accounting) and #37M (DPMF's malformed `format` call) remain
  correctly logged as MEDIUM — both already noted as "moot while DPMF is unreachable," which is now the
  permanent state, not a temporary one. No action needed on either; leaving them in the record as-is as
  historical/documentation value (mirrors the ATS audit's practice of not deleting a written-up finding
  just because it's inert).
- #57L (stale "DPMF" naming in Talos `@doc`s / REPL labels, actually calling DPOF) stays open as a real,
  independent doc-hygiene item — worth cleaning up during the eventual StoicSyntax pass since it actively
  misleads a reader searching for DPMF test coverage.
- Whether DPMF should keep its `P|A_Define` registration as a trusted IMP peer on DALOS/BRD/DPTF (since a
  permanently-broken module doesn't need peer trust) is a candidate cleanup item for the StoicSyntax pass,
  not a Round-I bug — not separately numbered.

---

## #2C · DPOF — `C_MoveCreateRole` never revoked the previous holder — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23)

**Owner confirmed the intended semantics before ruling:** "the moving itself is the revoking for the old
user. At least that's how it should function, isn't it?" — yes, confirmed as the intended design (one
atomic grant-and-revoke, not grant-only), which made this a real bug, not a misunderstanding of intent.

**Disposition:** CONFIRMED as a genuine implementation bug (write-order defect in `XI_SwitchCreateRole`'s
internal old-holder lookup, which re-read `UR_Verum4` *after* `XI_UpdateVerum4` had already overwritten it
to the new holder). Owner asked for the fix to be applied and adversarially proven in REPL — both broken
(pre-fix) and working (post-fix) — before moving on, matching the established ATS/SWP audit discipline.

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #1 for the full diff, root-cause explanation, and
adversarial pre/post-fix REPL proof (`REPL/_scratch_dpof_c2_moverole.repl`, kept as a re-runnable artifact).
Summary: reordered `C_MoveCreateRole`'s two internal calls so the old-holder lookup happens before it's
overwritten. Pre-fix: reproduced live (previous holder incorrectly retained the role). Post-fix: previous
holder correctly loses it, new holder correctly gains it, full `Z.repl` regression suite green.

No further action needed on #2C — closed.

---

## #3C · DPOF — missing nonce-uniqueness validation — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23)

**Owner's direction:** "let's fix this with the recommended modification. obviously the list of nonces
must be unique." Confirmed the fix should mirror the existing `BULK-MOVE` uniqueness pattern
(`UC_IzUnique`), applied to `DPOF|C>DEBIT`, `DPOF|C>TRANSFER`, and `DPOF|C>BULK-TRANSFER`.

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #3 for the full diff and adversarial pre/post-fix
REPL proof (`REPL/_scratch_dpof_c3_noncedupe.repl`, kept as a re-runnable artifact). Both sub-mechanisms
(whole-nonce transfer inflation, negative nonce-supply corruption) reproduced live pre-fix and rejected
outright post-fix; a legitimate non-duplicated transfer still works; full `Z.repl` regression clean.

No further action needed on #3C — closed.

---

## N1 · DPOF — `C_Transmit` completely non-functional (discovered live, not a Round-I lens finding) — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23)

**Discovery context:** surfaced while building #3C's REPL proof — the very first attempt to call
`C_Transmit` at all (an entirely ordinary, non-duplicated, single-nonce call) crashed with `Key
"meta-data" not found`, unrelated to nonce duplication. Root cause: `DPOF|C>TRANSMIT`'s defcap read the
wrong object key (`"meta-data"` instead of the schema's real `"meta-data-array"`). This function has
never worked, for any caller, on any input, since it was written.

**Owner's direction:** "yes, fix the transmit bug, if you can confirm via repl that it is indeed broken,
and after fixing you gotta confirm via repl that it is now working as intended."

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #2 for the full diff and pre/post-fix REPL proof
(`REPL/_scratch_dpof_transmit_metadata_bug.repl`, kept as a re-runnable artifact, deliberately using a
plain non-duplicated input to isolate this bug from #3C). Pre-fix: reproduced live, hard crash. Post-fix:
succeeds, correctly splits the nonce and credits the receiver; full `Z.repl` regression clean.

No further action needed on N1 — closed. Logged here (not in the original Round-I findings, discovered
during fix/verification work) per the SWP audit's own HARD RULE precedent: a finding is a finding
regardless of when it surfaces, and gets the same write-down discipline as everything else.

---

## #4C · VST — `C_Unreserve` checks the DPTF issuer's ownership, not the reserver's — **REFUTED ✅ — NOT A BUG** (owner, 2026-08-23)

**Owner's correction:** Reserve/Unreserve is **not** a symmetric self-serve lock like Vest/Sleep/Hibernate
— it's a one-way escrow-for-purchase mechanism. Any holder (Alice, Bob, ...) can reserve their own tokens
freely (no gate on `C_Reserve`, correctly) — this is meant to be used when buying something the **Token
Manager** (the DPTF's issuer/owner) has put up for sale: the buyer reserves their payment tokens, and the
Token Manager is the one who then calls `C_Unreserve` to **collect** the reserved tokens as the completed
payment. "Alice and Bob are never meant to be able to unreserve their tokens" — only the Token Manager can,
by design. `CAP_Owner dptf` in `VST|C>UNRESERVE` (checking the *base token's* issuer, not the reserving
holder) is therefore exactly correct, not a wrong-variable bug.

**Disposition:** REFUTED. The original framing ("reserved funds are permanently stuck for anyone who isn't
the token's own Konto owner") mischaracterized intended one-way escrow semantics as broken symmetric
lock/unlock. No code change. `C_RepurposeReserved`'s identical gate is correct for the same reason (only
the Token Manager may redirect reserved-fund flows). The asymmetry against Vest/Sleep/Hibernate (which
genuinely are self-serve both ways) is real but intentional — Reserve is architecturally a different
primitive (payment escrow), not another member of the self-serve lock family.

**Residual note (not re-opened as a separate finding):** `C_Reserve`/`C_Unreserve` still have zero REPL
coverage anywhere in the repo (correctly noted in the original finding as supporting evidence, still true
now that the finding itself is refuted) — worth adding real assertion coverage for this escrow flow during
the eventual test-coverage sweep, precisely because it's the kind of asymmetric-by-design gate that's easy
to misjudge (as this finding itself demonstrates) without a test proving the intended behavior on both
sides (buyer can reserve, cannot unreserve; Token Manager can unreserve).

No further action needed on #4C — closed.

---

## #5C · INFO-ONE — `DPOF|INFO_UpgradeBranding` doubled-prefix typo — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23)

**Owner's read:** "most likely a typo, OI typed 2 times." Confirmed as a real, straightforward bug.

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #4 for the full diff and pre/post-fix REPL proof
(`REPL/_scratch_infoone_c5_upgradebranding.repl`, kept as a re-runnable artifact). Pre-fix: reproduced
live, `Unbound free variable` crash. Post-fix: returns a correctly-formed `ClientInfo` object; full
`Z.repl` regression clean.

No further action needed on #5C — closed.

---

## #6H · IGNIS/DALOS — 4 `XE_*` writers missing the `SECURE`/named-cap second gate — **REFUTED ✅ — NOT A BUG** (owner, 2026-08-24)

**Owner's correction:** "`(UEV_IMC)` means it similar to `(require-capability (SECURE))`, but also
protected from outside, so unless something is missing, this should be correct." Verified this in full:

`P|UR_IMP` returns a list of capability-guards — DALOS's own `create-capability-guard (SECURE)` plus each
registered peer module's own `create-capability-guard (P|<MODULE>|CALLER)`, each pointing at a bare
`(defcap ... () true)` defined **inside that peer module**. Per the same Pact rule confirmed repeatedly
elsewhere in this audit program (ATS's C1, SWP's C13/H9 — a foreign caller cannot acquire a capability
defined in module M via `with-capability` without already holding M's own module admin), the *only* code
that can ever make any of those guards active is code physically running inside one of the specific,
deploy-vetted, admin-registered peer modules — never an arbitrary external caller or unregistered module.
`UEV_IMC` alone is therefore functionally equivalent in strength to `require-capability (SECURE)`, not a
weaker "any registered module, no further check" gate.

**What the `with-capability (SECURE)` wrapper on the sibling functions actually does:** traced all six
siblings that have it (`XB_UpdateBalance`, `XE_UpdateFreeze`, `XE_UpdateBurnRole`, `XE_UpdateMintRole`,
`XE_UpdateFeeExemptionRole`, `XE_UpdateTransferRole`) — every one of them delegates its actual write to a
single shared internal function, `XI_UpdateTF`, which is itself gated by `(require-capability (SECURE))`
purely so that shared writer (called from six different places) can't be invoked directly, bypassing
whichever of the six entrypoints was supposed to front it. That's a structural dispatch-protection
mechanism, not a second authorization layer — `SECURE` is unconditionally `true`.

The four flagged functions write **directly inline** (no shared internal writer to protect), so there is
nothing for a `with-capability (SECURE)` wrapper to structurally guard — adding it would be inert
boilerplate, not a missing check. The apparent inconsistency is fully explained by "does this function
delegate to a shared internal writer," not by an authorization gap.

**Disposition:** REFUTED. No code change.

No further action needed on #6H — closed.

---

## #7H · U_DALOS — `GLYPH|UEV_MsDc` charset-validation fold inverted — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-24)

**Owner's direction:** "check where its called, perhaps this function was meant to check one singular
character. if it is indeed a function that is suppose to check a whole string, and it is proven it doesnt
do it properly (in repl), then we'd need to fix it indeed to work to check the whole string."

**Investigation:** checked all 4 call sites (`GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_DalosAccount`,
`GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_ApolloAccount`) — every one passes the entire 160-character
account body in one call and either `enforce`s the result directly or folds it with other whole-string
checks (length=162, prefix match, separator). Confirmed: this is genuinely meant to validate the whole
string, not a single character.

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #5 for the full diff and pre/post-fix REPL proof
(`REPL/_scratch_udalos_h1_msdc.repl`, kept as a re-runnable artifact). Pre-fix: reproduced live — an
18-garbage-character-plus-one-valid-digit string incorrectly returned `true`. Post-fix: the same string
correctly returns `false`, and a genuinely all-valid string still returns `true` (regression guard); full
`Z.repl` regression clean.

No further action needed on #7H — closed.

---

## #8H · IGNIS — `C_Collect` no per-leg zero/negative filter — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-24)

**Owner's direction:** confirmed the architecture (every client function emits an `OutputCumulator`;
composing functions concatenate cumulators; Talos collects once via `C_Collect`, specifically to avoid
paying the ~4-5k gas cost of collection multiple times per transaction) and confirmed: "if that is 0, then
it should not crush, failing the transaction. however if such a thing were to be the case, no ignis
collection would need to occur, and this would need the event ignis free or something, there is a special
event designed for exactly such a case... perhaps it should also some how tie into this situation."

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #6 for the full diff and adversarial pre/post-fix
REPL proof (`REPL/_scratch_ignis_h3_zeroleg.repl`, kept as a re-runnable artifact). Per-leg zero/negative
amounts now skip collection and compose the existing `IGNIS|S>FREE` event instead of crashing. Reproduced
broken pre-fix (whole batch aborted over one free leg), confirmed working post-fix (free leg skipped,
paid leg still collects normally), full `Z.repl` regression clean.

No further action needed on #8H — closed.

---

## #9H · DPTF — three "Toggle Verum" client recipes missing `(UEV_IMC)` — **CONFIRMED ✅ AND FIXED ✅ AND PROVEN ✅** (owner, 2026-08-24)

**Owner's process (away from a computer, correctly refused to assume a bug without checking for a
legitimate reason first):** raised two specific tests before agreeing this was a bug — (1) "UEV_IMC
has no place within a capability" (confirmed: none of the five relevant defcaps reference it), and
(2) "are they `C_` functions? If they are they must be able to be called from the module but only
from talos orchestration. If that doesn't hold, it's then a bug that needs fixing." Repo-wide grep
confirmed zero internal/home-module calls to the three flagged functions exist — they are only ever
reached via Talos, exactly like their two correctly-gated siblings. Both tests pointed the same
direction, and owner concluded: "it seems I simply forgot to add the line."

**Fix applied and proven:** see `ROUND-02-FIXES.md` Fix #8 for the full diff and pre/post-fix REPL
proof (`REPL/_scratch_dptf_h4_missing_imc.repl`, kept as a re-runnable artifact). Two of the three
functions' direct-bypass reproduced live pre-fix (role state flipped with zero Talos involvement);
the third confirmed missing the identical check by direct code read (its defcap has an unrelated
smart-account-target precondition that made live pre-fix reproduction impractical with available
fixtures). Post-fix: all three correctly rejected, legitimate Talos path still works, full `Z.repl`
regression clean.

No further action needed on #9H — closed.

---

## #10H · TFT — `C_MultiTransfer`/`C_MultiBulkTransfer` no per-leg zero/negative filter — **REFUTED ✅ — NOT A BUG, INTENDED DESIGN** (owner, 2026-08-24)

**Owner's direction:** "I don't think skipping is a good idea, I think dying in place is a better way
of you seeing you added some invalid transfer numbers... This means you have to supply valid
amounts." Unlike #8H (IGNIS `C_Collect`, where a per-leg free amount is a normal, expected outcome of
the pricing architecture and skipping-with-observability was the right fix), here a zero/negative
leg in a caller-supplied transfer batch is treated as invalid input the caller should correct, not a
routine case to silently paper over.

**Both sub-mechanisms closed under this reasoning:**
1. **Caller-supplied literal `0.0`:** dying in place with a clear rejection is correct — silently
   dropping the leg would let the rest of the batch through without the caller noticing their mistake.
2. **Fee-split remainder computes to exactly `0.0` from a valid nonzero input:** investigated the
   actual math before accepting this as the same case, not just assuming it — confirmed the
   percentage-based fee path (`fee-promile`, capped at 999.0/99.9% by `U|DALOS::UEV_Fee`) can
   **never** produce a zero remainder from a nonzero input, since `floor()` only rounds down (fee
   taken is mathematically guaranteed to stay below 100% of amount). The volumetric/flat-tax mode
   (`fee-promile = -1.0`) uses a more complex digit-weighted formula where a zero remainder wasn't
   fully ruled out mathematically — but per the owner's own framing, an amount that fully consumes
   itself as fee under the token's *current* configuration is just as much "an invalid amount for
   this configuration" as a literal zero, so the same die-in-place logic applies without needing a
   special case.

**Disposition:** REFUTED. No code change. A smaller, separate observation was raised (the crash
message reads `"0.0 is not a valid transaction amount"`, which could be confusing in the
fee-remainder case since the caller's actual input was nonzero — the `0.0` is an internal derived
value they never typed) — owner declined to pursue this as a follow-up; not tracked as a separate
item.

No further action needed on #10H — closed.

---

## #15H · INFO-ONE — `ATS|INFO_Coil` wrong-token/reversed-direction cumulator — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-24)

**Owner's context first, which reframes this whole cluster:** `INFO_*` functions are UI-facing
preview endpoints, one per user-facing `C_*` button, called directly by the frontend — that's why
they have zero on-chain callers (expected, not a coverage gap). Captured durably in
`OuronetInformational/memories/2026-08-24-info-functions-are-ui-facing-not-dead-code.md`. Owner also
raised a large separate future project (every `C_*` needs a matching `INFO_*`, many still missing
across Stage 1 and Stage 2, owner has hand-written the existing ones) — explicitly deferred to a
dedicated phase after both audits merge to main, before the StoicSyntax sweep; tracked in this
README's "Downstream plan" section, not part of this audit's scope.

**Owner's verification requirement for the actual bug:** "it has to be verified against the
execution function to output the same cost. If there is something wrong within it, it must be
fixed."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #9 for the full diff and verification,
including an honest disclosure of a limitation (the specific test ATS pair's reward token and
reward-bearing token happen to share the same fee class, so a differential old-vs-new live proof
wasn't achieved — the fix is still confirmed correct via ground-truth comparison against the real
execution function and the correctly-implemented sibling pattern). Owner reviewed this evidence and
accepted it as sufficient: "Let's consider it closed for now."

Closed on #15H.

---

## #11H · TFT — `C_MultiBulkTransfer` never refreshes sender's Elite tier — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-24)

Owner's verdict, given while away from a computer, based on the diagnosed code structure and the
architectural intent: "if its missing, it is indeed a bug, as its suppose to refresh for both sender
and receiver."

**Root cause:** `C_MultiBulkTransfer` refreshes the *receiver's* Elite tier per-leg (via
`XI_BulkCredit`'s `elite` flag → `XI_BulkUpdateElite` → `XI_DirectUpdateEliteAccount` mapped over
`receiver-lst`), but never touches the *sender's* Elite tier anywhere in the function — unlike its
siblings `C_Transfer` (inline `XI_DynamicUpdateEliteAccount` on both sender and receiver for
elite-classified types 5/6) and `C_MultiTransfer` (a `contains-eazs`-gated `(do (XI_DynamicUpdateEliteAccount
sender) (XI_DynamicUpdateEliteAccount receiver))` after the fold).

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #10 for the full diff and REPL proof —
reproduced live (patron's Elite tier stayed byte-identical after losing half their real
ELITEAURYN balance via a bulk transfer), fixed by mirroring `C_MultiTransfer`'s pattern
(`contains-eazs`-gated sender-side `XI_DynamicUpdateEliteAccount` call), then reproduced correct
(patron's tier dropped from DEMIURG/7.5 to TYCOON/6.6, reflecting the reduced balance) with the
same harness. Full `Z.repl` regression clean.

Closed on #11H.

---

## #N2 · TS01-C1 — DPTF|C_DeployAccount/DPOF|C_DeployAccount ungated public entrypoints — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-25)

Surfaced via a handoff from the sibling DPDC audit (their #35M, identical shape). Owner's first
instruction was "the same fix we did on dpdc" (remove the entrypoint). Live-testing that broke the
default `Z.repl` pipeline (patron setting up `ats`/`liquid`/`swp`/`standard-dispenser` system smart
accounts through this exact entrypoint) — reported back with concrete evidence before proceeding
further, per the "investigate before concluding" discipline.

Owner's refined verdict once shown the breakage: "the ownership that must be asked, must be for the
ouronet account, the dptf/dpof account is being added. so I can add a dptf/dpof account for a given
dptf/dpof only for my ouronet account, not for bob's ouronet account. thats how I expect it to be."
— i.e. gate `C_DeployAccount` by target-account ownership (not remove it), and give system/admin
setup a separate path.

A reverse-handoff was also sent back to the DPDC audit: their "remove the entrypoint" fix may have
the same blast-radius problem if DPDC has an equivalent genesis/system-account-setup flow that isn't
a registerable sovereign Talos module (their one found caller, `TS02-DPAD`, happened to be one, so
"redirect + register as IMC peer" worked for them) — asked them to check, and to consider whether
DPTF/DPOF's confirmed genuine self-service use case (opting one's own account into a token) should
change their calculus on removing DPSF/DPNF's equivalent entirely.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #11 for the full diff and verification —
`C_DeployAccount` (TS01-C1) gained the ownership gate exactly as specified; a new admin-gated
`A_DeployAccount` (TS01-A, real admin-keyset check, already a registered DPTF/DPOF IMC peer) was
added for system-account setup; every known system-setup call site (Sovereign-Executor, Dispenser+,
TS02-DPAD's DemiPad registration, CADUCEUS's bridge provisioning) was redirected to it. Griefing
case reproduced broken pre-fix, rejected post-fix; self-service case (including the pre-existing
`smart-patron` call site, left untouched) confirmed still works; DemiPad's real Launchpad scenario
live-proven; CADUCEUS structurally proven only (zero REPL coverage exists for it anywhere in the
repo — disclosed as a real limitation, not glossed over); full `Z.repl` regression clean.

Closed on #N2.

---

## #N3 · TS01-A — treasury A_ functions gated only by bare-true P|TS — **REFUTED, NOT A BUG** (investigated 2026-08-26)

Self-raised while implementing #N2's fix (same superficial shape: an admin function gated only by
the bare-true `P|TS`/`P|TALOS-SUMMONER` chain, unlike its siblings which use the real
`P|ADMINISTRATIVE-SUMMONER` check). Investigated before presenting a verdict, per the "investigate
thoroughly, don't assume 'looks like a bug' is sufficient" discipline.

Found the core layer (`05_DPTF.pact::A_UpdateTreasury`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial`)
independently composes `GOV|DPTF_ADMIN`, a real `enforce-one [DPTF module-def keyset, patron's own
account guard]` check — genuine authorization, not the bare-true/`UEV_IMC`-only shape that made
`C_DeployAccount` (#N2) exploitable. Confirmed live: an unrelated, unauthenticated signer is rejected
when calling through the weak Talos wrapper. Same resolution shape as #6H — a weak outer Talos gate
is harmless when the core layer independently enforces real authorization.

No code change. Closed on #N3.

---

## #12H · DPOF — `C>UPDATE-SPECIAL` duplicated `cond` branch — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "i think its clearily wrong and a typo. vzh is vesting-sleeping-hibernating, and thats what
vzh 1 2 3 is for. lets fix it and move on, i dont think any further tests are needed."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #12 — one-line correction
(`(= vzh-tag 2)` → `(= vzh-tag 3)` on the Hibernation branch of `main-special-id`'s `cond`).
Investigation surfaced and disclosed a real nuance before the fix: the only currently-wired caller
(`VST|C_CreateHibernatingLink`) can't actually reach the bypass on a second call, because re-issuing
the special DPOF token collides on its deterministic name/ticker first — so this wasn't actively
exploitable today, only a latent risk for any other/future direct caller of the `XE_`-prefixed
`UPDATE-SPECIAL` path. Owner accepted the isolated logic proof as sufficient, no further live
exploit-path proof requested. Full `Z.repl` regression clean.

Closed on #12H.

---

## #13H · LIQUID — `C_RegisterOuronetAccountForUrstoaHoldings` zero ownership check — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner explained the function's original purpose (registering a StoaICO contributor's Kadena address
in the native UrStoa ledger before their first unwrap), then pointed out it's actually unnecessary —
a UI-constructed transaction pattern (shown working, captured from a real explorer tx for native
Stoa unwrap) already solves the same problem more safely, by creating the account with the real
signer's own `(read-keyset "ks")` directly in the wrap/unwrap transaction. Owner: "so perhaps the
`C_RegisterOuronetAccountForUrstoaHoldings` isnt really neeed, but if we remove it we have to update
the next two functions, becuase in the doc they make refference to it, and we gotta make proper
documetnation that its being handled byu the UI constructing special pact code for this."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #13 — removed the function (core +
Talos wrapper, interface + module in both), updated `C_UnwrapUrStoa`/`C_WrapUrStoa`/
`LQD|C_UnwrapUrStoa`/`LQD|C_WrapUrStoa`'s `@doc` cross-references, kept the read-only
`UR_IzOuronetAccountRegisteredForUrstoaHoldings` checker, and captured the UI-constructed pattern
durably in `OuronetInformational/memories/2026-08-27-urstoa-account-creation-is-ui-constructed.md`.
Confirmed via repo-wide grep that zero REPL/test coverage referenced the removed function anywhere
before removing it. Full `Z.repl` regression clean.

Closed on #13H.

---

## #14H · U_VST — `UEV_MilestoneWithTime` no lower bound on `duration`/`offset` — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "yes, lets fix this."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #14 — added
`(enforce (and (>= offset 0) (>= duration 0)) "Offset and Duration cannot be negative")` to
`UEV_MilestoneWithTime`. Reproduced live: negative duration/offset both succeeded pre-fix (and
`UC_MakeVestingDateList` was shown to compute a decreasing/past-dated schedule as the consequence),
both correctly rejected post-fix, ordinary valid inputs unaffected. Full `Z.repl` regression clean.

Closed on #14H.

---

## #16H · INFO-ONE — `ATS|INFO_ColdRecovery` duplicate `ifp3` binding — **CONFIRMED, DEFERRED** (owner, 2026-08-27)

Owner: "rearchitechting the whole INFO function architecture is part of a bigger scope to be done on
main from top to bottom. so file the issue, and we deffer it to main."

Confirmed real (Transfer-leg IGNIS cost is computed at `21_INFO-ONE+.pact:2046` then immediately
shadowed by a second binding of the same name `ifp3` at `:2048`, silently dropping it from the final
quoted total) — but not fixed piecemeal here. Folded into the "INFO-function coverage project" phase
of the Downstream plan (`README.md`), which will audit every `INFO_*` function's correctness against
its real counterpart as a single dedicated pass after both audits merge to main. No code change in
this audit.

Deferred, not closed — tracked as `DEFERRED` in the status tracker, not struck through as done.

---

## #17H · PYTHIA — `A_UpdateDeployPrice`/`A_UpdateRenamePrice` never wired into Talos — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "yes, forgot to wire them. add them in."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #15 — added both functions to
`06_TS01-C4.pact`'s interface and module, mirroring the existing `PYTHIA|A_Link`/`A_RevokeLink`
pattern. Reproduced live: calling the Talos wrapper failed with "Unbound free variable" pre-fix
(genuinely unreachable, not just untested), succeeded post-fix with the real price values changing
as expected. Full `Z.repl` regression clean.

Closed on #17H.

---

## #18H · U_VST — `UC_MakeVestingDateList` drops `offset` when `milestones=1` — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "proceed" (fast-format review).

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #16 — one-line change
(`present-time` → `first-time` in the `milestones=1` branch). Reproduced live: both calls returned
identical timestamps regardless of `offset` pre-fix; post-fix they differ by exactly the offset;
`offset=0` case unaffected. Full `Z.repl` regression clean.

Closed on #18H.

---

## #19H · U_CT — `UR|KDA-PID` hardcoded oracle stub — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "yes, because we dont have an oracle yet, on mainnet is 0.1 once an oracle is available, wel
lfix that. for now make it 0.1 and go next issue."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #17 — changed the hardcoded stub from
`1.0` to `0.1` (interim mainnet placeholder), commented as pending the real oracle wire-up. Full
`Z.repl` regression clean; live-confirmed the new value.

Closed on #19H (as an interim value fix — the underlying "wire up a real oracle" work remains
explicitly deferred until one is available, not tracked as a separate open item since the owner
framed it as a future, not-yet-actionable step).

---

## #20H · U_DEC — `UC_AddHybridArray` crashes/misbehaves on empty input — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "yes, but i think where its used, it works, due to what type of input its passed in to it.
ive never seen it crash. so what ever you do to fix it makes sure you dont break it."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #18 — checked every real caller first
(confirmed the owner's observation: none currently pass an empty/all-empty input), then added a
purely additive `(if (= maxl 0) [] ...)` guard around the existing, unmodified body. Reproduced the
exact crash live pre-fix (`Array index out of bounds. Length (0), Index (-1)`), confirmed clean `[]`
output post-fix for empty input, and confirmed two realistic non-empty inputs (including the exact
8-column ATSU shape) are byte-identical before and after — satisfying the "don't break it"
constraint. Full `Z.repl` regression clean.

Closed on #20H.

---

## #21H · Talos Admin — ~Half the admin surface untested, Admin suite asserts nothing — **CONFIRMED, DEFERRED** (owner, 2026-08-27)

Owner: "if its test coverage, we deffer to work on mane and filanzse, main has a phase for filling
in repl tests that are missing and refactor the whole test infrastructure."

Confirmed real (test-coverage gap, not a code bug) — deferred to an existing main-branch phase for
REPL test backfill and test-infrastructure refactor, per the owner. Tracked in `README.md`'s
Downstream plan alongside H11. No code change in this audit. Established as the default deferral
for any future test-coverage-only finding unless the owner says otherwise.

Deferred, not closed — tracked as `DEFERRED` in the status tracker, not struck through as done.

---

## #22H · DPOF/TS01-C1 — V2 cascade ready locally, not yet deployed — **FINALIZED, not a bug** (owner, 2026-08-27)

Owner: "yes, it means we modified stuff that warranted interface version bump, and that is simply
stated. we are going to bump anyway the interface version across the board, for everything with the
work well be doing on main. so i think we should finalize the issue, write down how so."

Confirmed as expected status, not a defect: `DemiourgosPactOrtoFungibleV2`/`TalosStageOne_ClientOneV2`
are correctly cascaded and prepared locally (`06_DPOF.pact:214-227`, `3_Talos/02_TS01-C1.pact:87-99,
1349-1364`), just not yet deployed live. Folded into the already-planned StoicSyntax/interface-
version-bump/redeploy phase in `README.md`'s Downstream plan, with the DPOF-before-TS01-C1 ordering
requirement carried forward there. No code change, no separate fix needed.

Closed on #22H (finalized as a status note, not a bug).

---

## #23H · OUROBOROS — `C_SublimateV2` missing from `OuroborosV1` — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "i think its only used in a few places, due to how stuff is erased making it a bit cheaper.
but it should be in the interface i think."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #19 — added `C_SublimateV2` to
`OuroborosV1`, purely additive (the module already implemented this exact signature and it was
already live via `TS01-C2`'s wrapper and `TS01-C3`'s Firestarter path). Full `Z.repl` regression
clean, confirming no behavioral change.

Closed on #23H.

---

## #24H · CODEX — four `C_*` functions missing from `CodexV1` — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner: "Yes add them and tell me about next issue."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #20 — added `C_RotateCodexGuard`,
`C_RecordArweaveUpload`, `C_RegisterStoicTag`, `C_ReleaseStoicTag` to `CodexV1`, matching the
module's real signatures exactly, purely additive (all four already implemented and live via
TS01-C4). Full `Z.repl` regression clean.

Closed on #24H. **This closes out the entire HIGH tier of findings** (H1-H19: fixed/refuted/
deferred/finalized as appropriate — none remain open).

---

## #25M · DALOS — `C_RotateKadena` orphans the old kadena address's ledger row — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner pushed back on the first presentation, correctly: "jezes kryst, whats with this bug, are you
sure about it, have you verified it in repl? everytime you give me a bug i want you to confirm it
otme in repl." — re-verified live before recommending anything, confirmed the finding was real (not
just relayed from Round I), then proceeded once the owner said "proceed."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #21 — read the old kadena address into a
`let` binding before `XI_RotateKadena` overwrites it. Reproduced the exact leak live pre-fix (old
address's ledger row kept listing the account forever after rotation), confirmed clean post-fix
(old row correctly emptied), full `Z.repl` regression clean.

**New standing instruction from this exchange:** every bug presented from here on must be
independently re-verified live in REPL before being presented as confirmed — not just relayed from
the Round-I write-up.

Closed on #25M.

---

## #26M · DALOS — smart-account deploy validation misplaced in `XI_*` writer — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-27)

Owner explained the original reason for the structure (sharing validation between the admin
fee-free path and the client paying path without duplication) and asked for a StoicSyntax-compliant
fix only if one existed that preserved the sharing: "if you think you can do it using our syntax
definition, lets do it, otherwise it could be left as is."

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #22 — added a new
`DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT` cap that composes both `GOV|DALOS_ADMIN` and the existing
shared `DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT` validation cap (defined once, reused by both paths,
no duplication); `A_DeploySmartAccount` and `C_DeploySmartAccount` now compose their respective
client caps directly, and `XI_DeploySmartAccount` is now a pure `require-capability` writer.
Verified both paths remain behaviorally identical (valid input succeeds, malformed input rejected)
via a dedicated REPL harness plus the full `Z.repl` regression. Also surfaced and flagged (not
fixed, out of scope): `C_DeploySmartAccount`'s success path has zero coverage in the default
pipeline — noted for the deferred REPL test-infrastructure phase (see #21H).

Closed on #26M.

---

## #27M · DALOS — `GAS_PAYER` gas-station allowlist matches by string prefix — **CONFIRMED, NOT A BUG / INTENTIONAL DESIGN** (owner, 2026-08-27)

Re-verified live before presenting (per the standing instruction): confirmed
`(= "(ouronet-ns.TS" (take 14 ...))` would equally match a hypothetical non-Talos module also
starting with `TS`, not just the real Talos modules.

Owner: "no, id liek to leave as is, all talos modules start wit TS, and other exempted modules are
scoped like this. so close issue and tell me about next." — the prefix convention is intentional:
every real Talos module is deliberately named with the `TS` prefix (and the other exempted
categories similarly scoped), so the prefix check is by design, not an accidental looseness. No code
change.

Closed on #27M — not a bug, intentional naming-convention-based design.

---

## #28M · TFT — `C_ClearDispo` unconditionally unfroze the EA account — **CONFIRMED ✅ AND FIXED ✅** (2026-08-27)

Re-verified live before presenting, per the standing instruction: froze `emma`'s Elite-Auryn account
for an unrelated reason, then called `C_ClearDispo`, and confirmed the freeze was silently lifted
regardless.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #23 — mirrored the existing initial-freeze
guard onto the final unfreeze step, so `C_ClearDispo` only unfreezes if it was the one that froze
the account. Reproduced broken pre-fix, working post-fix (unrelated freeze preserved), and confirmed
the common/not-pre-frozen case is unaffected via the real `[6.2]_DPTF.repl` fixture. Full `Z.repl`
regression clean.

Closed on #28M.

---

## #29M · TFT — stale `dispo-data` snapshot across multi-transfer legs — **CONFIRMED ✅ AND FIXED ✅ — real exploit, more severe than ranked** (2026-08-27)

Re-verified live before presenting, per the standing instruction — and this one turned out to be a
genuine overdraft-inflation exploit, not just a stylistic staleness issue: a single
`C_MultiTransfer` batch combining an Elite-Auryn-reducing leg with an OURO-overdraft leg let
`patron` overdraft OURO to -33335.0016 when their real (post-batch) Elite status should only have
allowed -22223.33 — because the dispo/overdraft-limit snapshot was taken once before the whole
batch, not refreshed per leg.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #24 — `dispo-data` is now recomputed
fresh inside each leg of the fold, in both `C_MultiTransfer` and `C_MultiBulkTransfer`. Reproduced
the exploit live pre-fix, confirmed it's correctly rejected post-fix (same amounts), and confirmed a
legitimate overdraft within the correct limit still succeeds normally. Full `Z.repl` regression
clean.

Closed on #29M.

---

## #30M · DPTF — `UR_Hibernation` read-that-writes — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-28)

Owner confirmed the write was a deliberate backfill for legacy tokens, then asked: "can you check
on chain if there is anything else that needs filling? we could run the function to fill all the
gaps, and remove it... that would be the best fix, right?" — pointed at Pythia
(`pythia.ancientholdings.eu`) and its local website repo as the way to query live StoaChain state
for free, without a connector API key.

Found the free/keyless path myself by reading Pythia's own source (the browser UI's dirty-read
works because same-origin browser fetches carry `Sec-Fetch-Site: same-origin`, which Pythia's own
first-party-key middleware treats as authorized — explicitly documented in that codebase as
intentional/acceptable to forge from a non-browser client, since it only grants public read access).
Queried all 18 real DPTF tokens live on StoaChain chain 0: **every one already has
`hibernation-link` populated — zero gaps.** So no migration/backfill function was needed; simplified
`UR_Hibernation` directly to a pure getter.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #25. Confirmed the return value is
byte-identical for real tokens; full `Z.repl` regression clean. Also durably documented the Pythia
dirty-read querying method in `OuronetInformational/memories/2026-08-28-querying-live-stoachain-
via-pythia-dirty-read.md`, per the owner's explicit request, so future agents don't have to
rediscover it.

Closed on #30M.

---

## Addendum to #30M — general pattern + main-branch sweep instruction (owner, 2026-08-28)

Owner: "here is what i want you to add in the audit result papaer, that is going to be captured by
the main worktree agent, when we incorporate what we do on this work tree. that there are multiple
other functions like these that are modified to also write when reading, only to fill new fields
that are added due to a schema being modified. such modified read functions would have to be
treated in the same manner we did, across the code. sample the live chain, see if there is still a
need for the modified function to exist, and if there isnt, modify it back to the default read
variant. write down in skill how such functions would need to be modified, should we need this
functionality in the future, namely to update/fill new fields of tables due to schema being
expanded. also if there are similar issues to this one in our list, we deffer the to the work on
main repository, refefering to this entry in the audit paper, regarding this."

Searched the full Round-I findings list (all remaining MEDIUM/LOW entries) for this exact shape
(a `UR_*`/read function silently writing to backfill a newer schema field) — **none of the other
already-ranked findings match this pattern**; `UR_Hibernation` (#30M) was the only instance caught,
and only incidentally (Round I wasn't specifically searching for this shape). This means the
"defer similar list entries" instruction currently has nothing to act on within the existing
ranked list, but the broader instruction — write down the methodology, and flag that other
instances may exist elsewhere in the codebase, unfound by this Round-I pass — still stands and is
captured durably:

- **Methodology + retirement playbook:** `OuronetInformational/ouronet/conventions/schema-field-
  backfill-on-read.md` — the anti-pattern, the correct way to write this if genuinely needed, and
  the exact live-chain-sampling-then-retire procedure used for #30M.
- **Tracking entry for the main-branch sweep:** `README.md`'s Downstream plan, new phase 3b
  (added 2026-08-28) — a dedicated grep-based sweep for this shape across Stage 1 + Stage 2,
  to be done on main. Any future finding in this audit matching this shape should be deferred
  there, citing this addendum and the phase 3b entry, per the owner's instruction, rather than
  fixed piecemeal in this audit.

---

## #31M · DPOF — `URC_Parent` direct `enforce` — **CONFIRMED ✅ AND FIXED ✅** (owner, 2026-08-28)

Owner: "if i didnt add that in the parent function, it means it wouldnt be needed otherwiise i
would have added it. check where the URC_Parent is used, and youll see there is probably no need
for knowing what the function returns for a sleeping LP." — pointed directly at the fix: check the
real callers, confirm none of them need a meaningful return value for the Sleeping-LP case, then
just move the enforce to wherever it's actually needed.

Investigated further first (live chain confirmed this is a reachable, sanctioned combination —
`DPOF|C>UPDATE-SPECIAL` explicitly allows Sleeping links on LP tokens — just not yet exercised on
any of the 5 real DPOF tokens live today), then traced the one real read-context caller
(`DPL-UR::URC_0009a_OrtoFungibleEntryMapper`) and confirmed the `URC_Parent` result there is only
used for a best-effort, already-defensive price lookup and never appears in the returned display
object — exactly matching the owner's prediction.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #26 — removed the enforce from
`URC_Parent` (now a pure derive), added it directly to `UEV_ParentOwnership` (the one caller whose
own `@doc` already documents this requirement). Reproduced the abort pre-fix, confirmed
non-aborting post-fix with the enforce correctly relocated. Full `Z.repl` regression clean.

Closed on #31M.

---

## #32M · DPOF — `C_WipeHeavy` not renamed to `CC_`/`AA_` HEAVY convention, plus batch defer for all similar findings — **CONFIRMED ✅, DEFERRED** (owner, 2026-08-28)

Owner: "yes, and do this for all similar issues that may exist, deffer them to main worktree and
mention this in the audit paper of this audit."

Confirmed #32M is real but purely a naming-convention drift — `C_WipeHeavy`'s own `@doc` already
warns of the table-scan cost, and the identical pattern (same `@doc` text) exists duplicated in
Stage 2's `06_DPDC-MNG.pact`, confirming this predates the `CC_`-prefix convention rather than being
an isolated DPOF slip. Fixing it means renaming a Talos wrapper too — StoicSyntax-sweep-shaped work,
not a piecemeal fix.

Searched the remaining MEDIUM (#33M–#51M) and LOW (#52L–#85L) findings for the same shape (naming/
prefix/doc-convention drift, no functional impact) and batch-deferred every genuine match to the
StoicSyntax sweep, citing this entry:
- **MEDIUM:** #43M/M19 (`UC_*` functions enforcing — its own text recommends a rename/CONVENTION
  verdict), #50M/M26 and #51M/M27 (interface-versioning doc gaps).
- **LOW:** #57L, #65L, #66L, #69L, #70L, #71L, #76L, #77L, #78L, #80L, #81L, #82L, #84L.

Deliberately did **not** fold in the test-coverage-only findings (already deferred separately under
#21H/H16's REPL-test-infrastructure bucket: #38M/M14, #41M/M17, #47M/M23, #48M/M24, #49M/M25, #55L,
#59L, #60L, #64L, #79L) or the INFO-function-family findings (already under #16H/H11's INFO-function
project: #39M/M15, #40M/M16, #67L) — those have their own, earlier-established homes and are
cross-referenced, not re-deferred here, to avoid double-tracking. Everything else in the remaining
MEDIUM/LOW list (real bugs, dead code, semantic gaps) stays open for individual presentation.

Full batch list, reasoning, and explicit exclusions are captured in `README.md`'s Downstream plan,
phase 4 (the StoicSyntax sweep entry). `ISSUES-RANKED.md` has each deferred item struck through and
tagged `DEFERRED to StoicSyntax sweep`.

Deferred, not closed as fixed — tracked as `DEFERRED` in the status tracker.

---

## #83L, #85L · Interfaces — trivial formal closes — **NOT A BUG ✅** (owner, 2026-08-28)

Owner: "yes, knock those 2 out." Both items' own Round-I write-up already concluded "no action
needed"/"confirmed... not a coverage gap" — formally struck through and closed in `ISSUES-RANKED.md`
and `README.md`, no code change, no further investigation needed.

Closed on #83L and #85L.

---

## #33M · DPOF — `AHU`/`AUP_OrtoFungible*` hardcoded-account admin-migration path — **NOT A BUG / INTENTIONAL DESIGN, documented** (owner, 2026-08-28)

Owner: "It's that way by design, and I think everything is migrated anyway. So basically there is
nothing to fix this was used when migrating form meta to orto fungible. So I think we can even
remove it. But should be updated and kept for historical purposes I think."

Confirmed: this is the DPMF→DPOF migration's own completed, one-time key-repair utility — same
retention logic as DPMF itself (#1C). Owner declined removal (kept for historical reference) but
wanted it clearly documented so it isn't mistaken for a live admin path or general backdoor.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #27 — documentation-only comment block
added, no logic changed. Full `Z.repl` regression clean.

Flagged (not relayed as a formal handoff, since not requested): the sibling SWP audit independently
found its own copy of this pattern in `15_SWP.pact` — this verdict is specific to DPOF's completed
migration context and shouldn't be assumed to transfer automatically.

Closed on #33M.

---

## #34M · Talos Admin — two dead capabilities, one an unreachable DALOS governor slot — **CONFIRMED, DEFERRED to red-team pass** (owner, 2026-08-28)

Investigated first: confirmed `P|GOVERNING-SUMMONER`/`P|SECURE-SUMMONER` (`01_TS01-A.pact:96-103`)
are defined but never called anywhere in the repo; `P|GOVERNING-SUMMONER` is the sole composer of
`P|TRG`, whose capability-guard is registered as `"TS01-A|RemoteDalosGov"` and folded into DALOS's
own smart account's governor `guard-of-any` list (confirmed live in `[4.0]_Sovereign-Executor.repl`).
Checked the three sibling registrations in the same list (`TFT`/`ORBR`/`SWPU`'s own
`*|RemoteDalosGov` entries) — `TFT`'s equivalent (`P|DALOS|REMOTE-GOV`) *is* composed by a real
function elsewhere in `09_TFT.pact`, unlike TS01-A's, which initially read to me like a "forgot to
wire it" gap (same shape as #17H).

Owner: "well to answer this wed really need to observe what the dalos account is meant to hold, but
the thing is, since its done in the TS01-A module, and its never used in this module, it means it
isnt needed, otherwise i would have used it. i dont think i forgot to simpyl wire it in... so if it
isnt used anywhere, it means it isnt needed. when well be runing a red team attack at the end, well
see if its needed or not."

Not fixed now. Deferred to a new post-redeploy phase — **red-team pass** — added to `README.md`'s
Downstream plan as phase 6. No code change.

Deferred, not closed — tracked as `DEFERRED` in the status tracker.

---

## #35M · TS01-C1 — `DPOF|C_TogglePause`/`C_ToggleFreezeAccount` dead binding + missing message — **CONFIRMED ✅ AND FIXED ✅** (2026-08-28)

Confirmed both parts live before fixing: a dead, never-used `ref-TS01-A` binding in both
functions, and both ending with a raw `OutputCumulator` object instead of the CLAUDE.md-mandated
`format` result string — unlike the correctly-implemented DPTF siblings in the same file.

**Fix applied and verified:** see `ROUND-02-FIXES.md` Fix #28 — removed the dead binding, added the
DPTF siblings' exact message pattern to both functions. Confirmed live: real, clear messages now
returned. Full `Z.repl` regression clean.

Closed on #35M.

---

## #36M, #37M · DPMF — stale accounting logic, malformed `format` call — **NOT A BUG / OUT OF SCOPE** (owner, 2026-08-28)

Owner: "Dpmf is no longer in scope. So nothing from it ever matter, we will not be upgrading that
module any more."

Both findings' own Round-I text already noted they're "currently moot" (#36M) / "the sole caller is
itself dead code" (#37M), contingent on DPMF staying unreachable (#1C). Owner confirmed that's
permanent, not just "currently" — no landmine risk since DPMF will never be touched again. No code
change. Closed on #36M and #37M.

**Housekeeping (same turn):** noticed while closing these that the test-coverage-only findings
(#38M/M14, #41M/M17, #47M/M23, #48M/M24, #49M/M25, #55L, #59L, #60L, #64L, #79L) and INFO-function-
family findings (#39M/M15, #40M/M16, #67L) were cross-referenced in `README.md`'s Downstream plan
earlier but never formally struck through in `ISSUES-RANKED.md` itself — an inconsistency. Fixed:
all now struck through and tagged `DEFERRED to REPL test-infrastructure phase` /
`DEFERRED to INFO-function coverage project` respectively, matching their established deferral
buckets. No verdict changed, just bookkeeping brought in sync.

---

## #42M · U_RS — `UEV_EnforceReserved` "over-blocks" — **NOT A BUG, resolved mystery** (owner, 2026-08-29)

Re-verified live before presenting (per the standing instruction): confirmed `UEV_EnforceReserved`
does reject a legitimate non-principal custom account name (`z:legit-custom-name`) shaped like a
principal, and confirmed zero callers anywhere in the repo.

Owner: "that the thing with this function, it was talked from Kaden's coin module, and I have
absolutely no idea why it exists, what was it's purpose, and what it tried to achieve... Perhaps you
can understand what's it used for, but as I said we probably should leave it as is, since it's not
used anywhere."

**Resolved the mystery:** `U_RS::UEV_CheckReserved`/`UEV_EnforceReserved` is a verbatim port of
Kadena's own official `coin.pact` `check-reserved`/`enforce-reserved` (identical logic, identical
doc-comment wording). In the real coin contract this guards `credit`/`transfer-create`-style
functions against an account being named like a reserved principal (e.g. `k:...`) while carrying a
guard that doesn't actually derive to that principal — preventing an account from masquerading as a
"validated single-key account" (or other principal type) to wallets/explorers/tooling that trust the
naming convention. What Round I called "over-blocking legitimate non-principal names" is actually
the intended upstream behavior: Kadena's own convention says don't name a custom account with a
single-char-plus-colon prefix unless it genuinely is that principal type.

Not a logic bug — a faithful port of real, audited upstream security logic. Currently unused in this
codebase (zero callers), kept as-is per the owner's direction — available if principal-protected
account creation is ever wired up here, matching the same pattern Kadena's own contract uses. No
code change.

Closed on #42M.

---

## #44M · U_LST — `UC_IzUnique` can never return `false` — **FIXED ✅** (owner, 2026-08-29)

Presented as a `UC_`-prefix-enforces contract violation, same root cause as the already-deferred
#43M batch — proposed folding it in as another StoicSyntax-sweep defer item.

Owner pushed back with a sharper question first: "But is there a problem that it can never return
false?"

Direct answer given: yes, in effect. There's no "not unique" case that gracefully returns
`false` — a duplicate always aborts the whole transaction via `enforce` instead. No caller in this
repo currently branches on a `false` result (checked all six call sites, zero live functional
bug today), but the function's own inline comment ("If all items are unique, the function returns
true") implies a real two-valued predicate contract that never existed — a real latent risk for
any future caller who trusts that comment and writes unreachable `false`-branch logic.

Owner: "So fix it boss" — overriding the batch-defer proposal, fixed immediately and standalone.

**Fix:** renamed `UC_IzUnique` → `UEV_IzUnique` (definition, interface `[UEV]` group, and all six
caller files including one Stage 2 file, `DPDC-T.pact`), rewrote the misleading comment/`@doc` to
state the true contract. See `ROUND-02-FIXES.md` Fix #29 for the full file list and verification.

Verified live post-fix (`REPL/_scratch_ulst_m20_uev_izunique.repl`): unique list → `true`,
duplicate list → still aborts via `enforce`, byte-identical behavior to the pre-rename function.
Full `Z.repl` regression (Stage 1 + Stage 2) clean.

Closed on #44M.

---

## #45M · U_INT — `UC_MaxInteger` crashes uncatchably on an empty list — **FIXED ✅** (2026-08-29)

Re-verified live before presenting, per the standing instruction. Confirmed the crash is real and
worse than a normal Pact failure: `UC_MaxInteger([])` throws a raw `Array index out of bounds`
runtime error at `(at 0 lst)`, and wrapping the call in `(try ...)` does **not** catch it — the
whole REPL load aborts. Also checked all four real call sites for reachability: `AQP::SCORE`
guards it (`(if (> l1 0) ... 0)`), but `DPDC-S`'s `UEV_PrimordialSetDefinition`/
`UEV_CompositeSetDefinition` take a client-supplied `set-definition` list with no non-empty guard
before folding into `UC_MaxInteger` — a genuinely live-reachable crash path through a real public
entrypoint elsewhere in the codebase (DPDC is a separate audit's ownership, out of scope to fix
here, but it rules out "purely theoretical").

Applied the same fix pattern the owner already approved for the identical failure shape at
#20H/Fix #18 (`U_DEC::UC_AddHybridArray`, "purely additive, don't break the existing path") and the
same rename-for-enforcing shape just approved at #44M ("So fix it boss"): unlike HybridArray, there
is no safe benign default for "max of nothing" here (a silent `0` could corrupt downstream
precision/index math), so the fix is a real `enforce`, requiring the `UC_` → `UEV_` rename.
Renamed `UC_MaxInteger` → `UEV_MaxInteger` (definition, interface, and all four caller files —
`U_ATS`/`ATS` [sibling ATS-audit scope], `SCORE`/`DPDC-S` [Stage 2, separate DPDC-audit scope] —
mechanical rename only in each, no change to their own logic), added
`(enforce (> (length lst) 0) "UEV_MaxInteger: list cannot be empty")` as the function's first
statement, original fold logic below it byte-for-byte unchanged. See `ROUND-02-FIXES.md` Fix #30
for the full write-up.

Verified live (`REPL/_scratch_uint_m21_maxinteger_empty.repl`): pre-fix crash reproduced and
confirmed not even `try`-catchable; post-fix, non-empty input still returns the identical result,
empty input now fails cleanly via `expect-failure` instead of crashing. Full `Z.repl` regression
(Stage 1 + Stage 2) clean.

Closed on #45M.

---

## #46M · U_INT — `UEV_ContainsAll` checks set membership, not multiset containment — **NOT A BUG ✅, out of scope** (2026-08-29)

Re-verified live before presenting: `UEV_ContainsAll [1 1] [1]` returns `true`; a true
multiset-containment check (l2 must cover every occurrence in l1, not just each distinct value)
would return `false`. The gap is real.

Checked every caller: the only two call sites anywhere in the repo are both in
`DPMF|S>MULTI-BATCH-TRANSFER`'s `contains-all` nonce-ownership check (`00_DPMF.pact:335,1039`),
validating that a caller-supplied `nonces` list is fully owned by `sender`'s `account-nonces`. If
`nonces` contains a duplicate, this check would wrongly pass even though the account only holds one
instance of that nonce.

Per the owner's already-established, explicit standing ruling on this exact module (#36M/#37M,
2026-08-28): "Dpmf is no longer in scope. So nothing from it ever matter, we will not be upgrading
that module any more." Since DPMF is the sole live caller and will never be upgraded again, this
closes the same way — confirmed real, permanently out of scope, no code change.

Closed on #46M.

---

## Remaining LOW findings (#52L–#75L) — final housekeeping sweep (2026-08-29)

All MEDIUM findings are now closed. The 13 remaining open LOW findings were swept in one pass:
nine safe, independent, purely additive/subtractive/textual fixes (batched as Fix #31 — see
`ROUND-02-FIXES.md` for the full per-item write-up), and four closed/deferred with no code change.

**Fixed (Fix #31):** #53L (DALOS `A_UpdateUsagePrice` bound check), #56L (ELITE two vestigial
template items removed), #58L (TFT `C_ClearDispo` dead binding removed), #61L (OUROBOROS
`C_Compress` dead binding removed), #68L (PYTHIA dead constant removed), #72L (stale REPL header
comment corrected), #73L (U_CT tautological `or` simplified), #74L (U_VST isolated "to small" typo
fixed — "succesfully" deliberately left alone, confirmed to be the codebase's own consistent
119-occurrence spelling convention, not a typo), #75L (U_LST `UEV_StringPresence` now gives the
same specific "Empty List detected!" message for a real `[]`, not just the `[bar]` sentinel — no
functional bug either way, message-quality only).

**Closed, no code change:**
- **#52L** (`DALOS::URD_AccountCounter` dead code/mis-sectioned) — confirmed undeclared in any
  interface, zero internal callers, same shape as the already-established INFO-function-family
  bucket (#39M/#40M/M15/M16/#67L: an external-facing informational read with no internal callers
  by design). Deferred to the INFO-function coverage project alongside those.
- **#54L** (`DALOS`'s own self-referential `ref-DALOS::` call inside an `AHU` cap + hardcoded-garbled-account
  migration tool, `01_DALOS.pact:1512-1520`) — same exact shape as #33M/M9's DPOF `AHU`/`AUP_*`
  finding, already ruled on by the owner as an intentional, completed, narrow-blast-radius
  migration utility kept for historical purposes. Applying the same verdict here: documented,
  not restructured, no code change.
- **#62L** (`LIQUID::UEV_Amount` defined but never called) — real dead validation helper (zero
  callers anywhere), but ambiguous whether `DPTF::C_Mint`/`TFT::C_Transfer` (LIQUID's actual
  downstream calls in `C_WrapStoa`/`C_UnwrapStoa`/etc.) already enforce the same KDA-precision
  check internally via each token's own precision setting — establishing that definitively needs
  deeper live tracing than this pass affords. Same shape as #34M/M10 (a dead-looking slot whose
  real necessity can't be settled without deeper live tracing) — deferred to the same post-redeploy
  red-team pass (Downstream plan phase 6) rather than guessed at.
- **#63L** (`LIQUID`'s native KDA `install-capability` for unwrap payouts, supplied externally by
  off-chain "JavaCode," untestable in Pact REPL) — an architectural/testability limitation, not a
  logic bug; documented as a known limitation, no fix applicable within Pact/REPL.

Full `Z.repl` regression (Stage 1 + Stage 2) clean after all nine Fix #31 sub-fixes.

**All 27 MEDIUM findings and all remaining LOW findings are now closed.** Round I's ranked list
(#1C–#27C for CRIT, #1H–#19H for HIGH, #38M–#48M for MEDIUM plus M1–M22, #52L–#85L for LOW, plus
N1–N3 discovered mid-fix) is fully resolved: fixed/proven, refuted/not-a-bug, or formally deferred
to one of the named downstream phases (StoicSyntax sweep, REPL test-infrastructure phase,
INFO-function coverage project, schema-field-backfill sweep, red-team pass, redeploy phase).
