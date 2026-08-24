# DPDC Audit — issues ranked, highest → lowest severity

Flat ranking of every finding in `ROUND-01-FINDINGS.md` (Round I), numbered #1 → #55 continuously from
highest to lowest severity, with the severity letter appended to the number (C = Critical, H = High,
M = Medium, L = Low). The finding ID in italics at the end of each line (e.g. *DPDC-C·C1*) is the
cross-reference to look up full detail (location, failure scenario, fix direction, interface implication)
in `ROUND-01-FINDINGS.md`.

**Totals: 8 CRITICAL · 14 HIGH · 16 MEDIUM · 17 LOW (numbered #1-#55) + 1 unnumbered doc-only LOW note
= 56 findings across 11 modules.**

## CRITICAL

#1C **[DPDC-C]** ~~No floor/sign check on `amount` in any delta-based Credit/Debit path — a negative
`amount` passed to `DPDC-T::C_Transfer` for an SFT-native, SFT-fragment, or NFT-fragment nonce inverts
credit/debit direction, letting an attacker mint arbitrary supply into their own account while corrupting
the counterparty's balance negative.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-19** (`ROUND-02-FIXES.md` Fix #1)
— live-reproduced pre-fix (real signed transfer, sender balance +50 from a -50 "debit", receiver driven to
-50). Fixed at a **single chokepoint**: new `DPDC-C::UEV_Amount` (a proper `UEV_*` validator, not a bare
`enforce`), called from `CreditOrDebitDPDC` — the sole write path for every SFT/fragment credit+debit
across all 11 peer modules, list-form calls included for free (they `map` over the same single-value
function). `DPDC-T` needed no change. Post-fix: the exploit, submitted as a real uncaught transaction,
throws before `commit-tx` and nothing it attempted persists; a control legit transfer still works; full
`Z.repl` green. Also closes DPDC-F's **C3** (same root cause) and the negative-value half of DPDC-S's
**C8** (still OPEN for its own explicit gate). — *DPDC-C·C1*

#2C **[DPDC-T]** ~~`C_IgnisRoyaltyCollector` debits the `patron` parameter's IGNIS balance with no
ownership/authorization check anywhere in the call chain; any account can name an arbitrary smart-account
`patron` holding IGNIS and drain their balance to a collectable's creator.~~ — **REFUTED 2026-08-20,
HARDENED ANYWAY** (`ROUND-02-FIXES.md` Fix #2) — the "any smart account" shape was never reachable
(`IGNIS|C>DEBIT` already rejects smart-account patrons via `UEV_EnforceAccountType`); narrowed to standard
accounts, then shown `C_IgnisRoyaltyCollector`'s own royalty-bypass and `C_Collect`'s fee-ownership-check
key off the *identical* toggle, so "royalty is nonzero" and "ownership check gets skipped" can never both
be true — no reachable drain. Owner requested `CAP_EnforceAccountOwnership` added to `IGNIS|C>DEBIT`
anyway (`07_DPDC-T.pact:305`) so the debit doesn't depend on that external invariant holding forever —
live-proven: a real owner still collects a genuine 500.0 IGNIS royalty; an attacker naming someone else's
account as patron is hard-rejected at the new line, keyset failure. — *DPDC-T·C1*

#3C **[DPDC-F]** ~~`amount` is never validated `>0` anywhere in the Make/Merge/Repurpose fragmentation call
chain (same root gap as #1C, reached via a different entrypoint) — a negative `amount` to
`C_MakeFragments`/`C_MergeFragments` inverts debit/credit direction, minting a free unit of the source
nonce for the caller while driving the protocol's own `dpdc` escrow ledger negative.~~ — **ALREADY CLOSED
BY FIX #1, LIVE-PROVEN 2026-08-20** — `C_MakeFragments`/`C_MergeFragments` route their constituent leg
through `DPDC-T::C_Transfer` → the identical `CreditOrDebitDPDC`/`UEV_Amount` chokepoint Fix #1 hardened;
no new code needed. Full stack trace confirms the exact rejection point
(`DPSF|C_MakeFragments → DPDC-F::C_MakeFragments → DPDC-T::C_Transfer → ... → CreditOrDebitDPDC →
UEV_Amount`, `03_DPDC-C.pact:436`); legit fragmentation (100 units → 100,000 fragment units, the 1000×
ratio) still works. — *DPDC-F·C2*

#4C **[DPDC-F]** ~~`C_RepurposeCollectableFragments` has no `CAP_Owner`, no
`CAP_EnforceAccountOwnership repurpose-from`, no freeze check, no `can-wipe` check — any collection-owner
account can move any other holder's fragment balance without consent by hard-coding `wipe-mode=true` on the
underlying debit, bypassing the compliance gates the legitimate wipe path requires.~~ — **REFUTED
(design-intentional) 2026-08-20** — re-read the actual gate: `wipe-mode=true` requires `CAP_Owner`
(collection-admin-only), not `repurpose-from`'s consent, by design — this is a deliberate account-recovery
tool (stolen/deceased-account flow, admin verifies off-chain then acts), balance sufficiency still
enforced, `@event`-logged. No freeze/`can-wipe` precondition wanted, intentionally. Broader trust-model
question ("token owner has complete dominion, holders trust the issuer to be fair") and a possible future
Heir System (advance heir designation + inactivity-triggered succession, removing admin discretion from
the succession case) captured in `HEIR-SYSTEM-PONDERING.md` — not a bug, not blocking, a future direction.
— *DPDC-F·C1*

#5C **[DPDC-MNG]** ~~Burn/wipe has zero fragmentation-awareness: nothing stops a collection owner from
freezing and wiping the protocol's own `dpdc` escrow account's collateral, permanently orphaning every
outstanding fragment (`-N`) claim against it; `C_RespawnNFT` can later re-attach the same nonce-data to
`dpdc` again, letting stale pre-burn fragment holders redeem/claim an asset they have no legitimate claim
to.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-20** (`ROUND-02-FIXES.md` Fix #3) — one check
(`account != GOV|DPDC|SC_NAME`) in the shared `DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES` chokepoint blocks both
burn (never freeze-gated — only the burn role) and wipe (frozen+`can-wipe`-gated) from ever touching the
escrow account; both live-proven rejected at the identical line, ordinary burn on a real account still
works, `Z.repl` green. The respawn "compounding" risk needed no separate fix — it was downstream of the
collateral being destroyed, which can no longer happen. **Follow-up (2026-08-23, Fix #19):** the blanket
`account != dpdc` block was found, while building real EQUITY test coverage (#22H), to also block EQUITY's
legitimate `Convert`/`Break` package-share flows — a same-transaction, non-fragment escrow use of `dpdc`
completely unrelated to what #5C protects. Narrowed the check to only block burning/wiping a `dpdc`-held
nonce that's *currently fragmented* (via `DPDC::UR_SplitNonceData`, since this capability only ever handles
Class-0 nonces). Live-proven: EQUITY's Convert/Break now work correctly with exact conservation; the
original fragment protection is untouched. Z.repl green. — *DPDC-MNG·C1*

#6C **[DPDC-S]** ~~Composite/Hybrid SFT set-class definitions with `allowed-sclass = 0` (the codebase's
reserved "not part of any set" sentinel) pass definition validation — Make then legitimately transfers a
real constituent nonce into `dpdc` custody, but Break can **never** succeed (`read` on a nonexistent
set-class-0 row aborts every time), permanently stranding real user value.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-20** (`ROUND-02-FIXES.md` Fix #4) — `UEV_CompositeSetDefinition` now folds `allowed-sclass > 0`
across every position; live-rejected against a real collection with 4 real, pre-existing set-classes
(where the old max-only check would have trivially passed `0<=4`), legit definitions already proven by
genesis + full `Z.repl` pass. — *DPDC-S·C2*

#7C **[DPDC-S]** ~~`C_UpdateSetMultiplier` cannot ever succeed — a copy-paste `let` type-annotation bug
(`current-multiplier:string` binding a `:decimal` return) crashes the function unconditionally on every
call, reproduced live against `pact 5.4`. The entire multiplier-update feature is dead on arrival (feature
DoS, not a fund-loss bug, but total and silent — the module deploys fine).~~ — **FIXED ✅ AND PROVEN ✅
2026-08-20** (`ROUND-02-FIXES.md` Fix #5) — one-word type fix. **Confirmed live on mainnet too** via a
keyless Pythia dirty-read against the real deployed `ouronet-ns.DPDC-S` (byte-identical bug) — this
feature has never worked in production, not just locally. Live-proven now succeeds against a real
genesis set-class, `Z.repl` green. — *DPDC-S·C1*

#8C **[DPDC-S / DPDC-C]** ~~`how-many-sets` is never bounded to a positive value anywhere on the
`C_MakeSemiFungibleSet`/`C_BreakSemiFungibleSet` path, and the one downstream gate that could theoretically
catch it (`UEV_NonceQuantityInclusion`) is trivially satisfied by any negative amount.~~ — **FIXED ✅ AND
PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #6) — negative was already blocked by Fix #1's shared
chokepoint (live-confirmed, full stack trace via the mint leg to `UEV_Amount`); zero was *not* blocked and
initially closed as "harmless no-op," but owner correctly overruled that — an operation claiming to make/
break sets shouldn't silently succeed while doing nothing, same reasoning as rejecting zero-amount
transfers elsewhere. `how-many-sets > 0` now enforced directly at `DPDC-S|C>MAKE`/`C>BREAK`; both negative
and zero rejected earlier/clearer at the new gate; real Make 3 → Break 3 round trip proven with exact
conservation (`1000 → 997 → 1000`). — *DPDC-S·C3*

## HIGH

#9H **[DPDC]** ~~Talos's `DPSF|C_UpdatePendingBranding` passes 7 positional args to DPDC's 6-parameter
`C_UpdatePendingBranding` (a stray leading `patron`, copy-pasted from the neighboring `C_UpgradeBranding`
pattern) — every SFT branding-update call hard-aborts, 100% of the time, for a paid (400 IGNIS) feature
that's never been exercised by any test.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md`
Fix #7) — stray argument dropped; also resolved live whether the cross-module/cross-interface call even
resolves (it does, no retyping needed). SFT update now succeeds and persists correctly, NFT sibling
control still works. — *DPDC·H1*

#10H **[DPDC-I]** ~~NFT issuance is always billed at the cheaper SFT KDA price — the `if son` branch in
`C_IssueDigitalCollection`'s cost computation queries the same `"dpsf"` price key on both sides, contradicting
the 400/500 KDA split explicitly documented at the Talos layer; a guaranteed, silent 20% revenue shortfall on
every NFT collection ever issued.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #8) —
one-word price-key fix (`"dpsf"` → `"dpnf"`); since genesis's own signed caps are too generous to catch this
via pass/fail, measured the real `coin` balance delta instead: `0.306` pre-fix → `0.3825` post-fix, exactly
`×1.25`, exactly `0.5/0.4` — mathematically exact confirmation, not just "went up." — *DPDC-I·H1*

#11H **[DPDC-I]** ~~NFT genesis issuance with owner==creator (the most common issuance shape) writes
`role-modify-royalties`/`role-exemption`/`role-modify-creator = false` into the `Account` table (the table
that actually gates those operations) while the parallel `VerumRoles` write claims the owner has them — a
solo NFT creator cannot set royalties on their own mints until they notice and self-correct with an extra
paid transaction.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #9) — flipped the
three flags `false` → `true` in the NFT owner==creator branch, matching the already-correct SFT sibling.
Live-proven: solo owner==creator NFT collection, fresh nonce, `DPNF|C_UpdateNonceRoyalty` now succeeds
(`Write succeeded`, read back `50.0`) where it would have been rejected before. — *DPDC-I·H2*

#12H **[DPDC]** ~~The shared `XE_*` write-forwarding surface for Properties/Nonces/AccountSupplies performs
zero value-level validation — `UEV_IMC` only authenticates the calling module, not the value being written
(no monotonicity check on `nonces-used`, no non-negativity check on `XE_W|Supply`'s absolute value); every
conservation invariant for the shared core used by all 10 sibling modules rests entirely on caller
discipline outside this file. Corroborated by a live "computed but never enforced" dead-validation instance
in `DPDC-T`'s own transfer-amount check.~~ — **REFUTED (verified live) 2026-08-21** — every real call site
traced (`DPDC-C` debit, `DPDC-MNG` burn/wipe, `DPDC-S` set-class creation, `DPDC-I` genesis specs) either
self-derives the value (`current+1`, never attacker input) or is pre-validated by the calling defcap before
the write runs (e.g. `UEV_NonceQuantityInclusion` gates `XE_W|Supply`). No code change needed. — *DPDC·H2*

#12Hb **[DPDC-C/DPDC-N]** ~~Found while verifying #12H, not part of its original scope: `DpdcUdcV1.DPDC|NonceData`'s
free-text fields — `name`, `description`, `meta-data.meta-data`, `asset-type`, `uri-primary`/`-secondary`/
`-tertiary` — had zero content validation anywhere, at creation (`DPDC-C::UEV_NonceDataForCreation` only
checked `royalty`/`ignis`) or at update (each `DPDC-N::C_Update*` wrote raw caller input unchecked). Traced
real consumers first: `meta-data.meta-data` is a live NFT trait bag read by AQP-ANK/AQP-SCORE for reward
scoring, not decorative.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #10) — 5 new
shared validators (`UEV_Name`/`Description`/`MetaDataBag`/`AssetType`/`UriData`) added once in `02_DPDC.pact`
next to `UEV_Royalty`/`UEV_IgnisRoyalty`, wired into the creation chokepoint (`UEV_NonceDataForCreation`,
which also covers the whole-object update path) and each DPDC-N per-field update defcap. Caps: `name` ≤256
chars; `description` ≤1024 words/≤256 chars-per-word; `meta-data.meta-data` ≤8192 chars serialized (coarse —
Pact cannot enumerate an untyped object's keys, confirmed live); `asset-type` ≥1-of-7 flags; `uri-*` ≤2048
chars/link. 13-check live proof covering both creation and every update entrypoint (reject + accept +
boundary), Z.repl green. — *DPDC-C/DPDC-N·H4b*

#12Hc **[DPDC-N]** ~~Found while scoping #12Hb: `meta-data.composition` — the module's own auto-derived record
of which real nonces are locked in escrow to back a composite NFT set (set by `C_MakeNonFungibleSet`, read
back by `C_BreakNonFungibleSet` to know what to return) — can currently be overwritten to arbitrary values
via `DPDC-N::C_UpdateNonces`'s whole-object replace path, completely decoupled from what's actually held in
the `dpdc` escrow account. A correctness/integrity gap, not a content-length question.~~ — **FIXED ✅ AND
PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #11) — new `DPDC-N::UEV_NotSetInstance` (NFT-only; SFT Sets
have exactly one shared nonce, never re-derived per Make, so nothing there needs protecting) wired into the
shared `DPDC-N|C>DATA` and `DPDC-N|C>SET-DATA` chokepoints, blocking any direct edit to an already-minted
NFT Set instance's own data. Live-proven: a real Primordial Set instance's direct edits rejected, its
Set-Class template stays editable, an ordinary primordial nonce stays editable, an SFT Set's shared nonce
stays editable — Z.repl green. — *DPDC-N·H4c*

#13H **[DPDC-R]** ~~`DPDC|C>FRZ-ACC` gates **both** freeze and unfreeze on the collection's `can-freeze`
switch (every sibling role toggle only gates the granting/"on" direction) — combined with `can-upgrade=false`
(both flippable in one ordinary `C_Control` call), this permanently bricks a frozen account with no recovery
path, reachable via an honest owner's routine "lock in settings" misconfiguration, not just malice.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-21** (`ROUND-02-FIXES.md` Fix #12) — `can-freeze` now gates the freeze
direction only ("unfreeze should be like a release valve, regardless of can-freeze" — owner); unfreeze
unconditional. Live-proven: real account frozen, `can-freeze` renounced, unfreeze still succeeds while
freezing a different account stays correctly rejected; `git stash` confirmed the pre-fix brick was real,
not assumed. Z.repl green. — *DPDC-R·H1*

#14H **[DPDC-MNG]** ~~Pause never gates a single mutating entrypoint in this module (`C_AddQuantity`,
`C_BurnSFT`/`NFT`, all `Wipe*`, `C_RespawnNFT`) — only `DPDC-T`'s transfers actually check
`UEV_PauseState`. An owner pausing a collection during an incident (e.g. a compromised Add-Quantity-role
account) does not stop that account from continuing to mint/burn/wipe.~~ — **REFUTED (design-intentional)
2026-08-21** — owner: pause is meant to halt transfers only, not administrative supply operations, matching
the same semantics as the MultiversX token architecture this design is drawn from. Verified `DPDC-T`
correctly enforces `UEV_PauseState id son false` on both real transfer call sites; `DPDC-MNG`'s
mint/burn/wipe/respawn functions are correctly left ungated, exactly as intended. No code change needed. —
*DPDC-MNG·H1*

#15H **[DPDC-S]** ~~Set-class `score-multiplier` has no bound and no live-supply guard — once #7C is fixed,
an owner can retroactively re-price every outstanding member of a set-class instantly and unboundedly (same
shape as the SWP audit's `C_ModifyWeights` finding), with zero time-lock.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-22** (`ROUND-02-FIXES.md` Fix #13) — new shared `UEV_ScoreMultiplier` ((0,100] + 3-decimal
precision) wired into Define (Primordial/Composite/Hybrid, previously zero validation) and Update
(previously precision-only). 9-check live proof: all bad multipliers rejected at both Define and Update,
boundary (100.0) and ordinary values accepted, Z.repl green (Bloodshed's real 1.1x genesis multiplier still
passes). Investigated first whether the multiplier is even consumed anywhere live — `UR_N|Score` (the only
function that applies it) has zero callers, and Make-time score computation (`URC_NoncesSummedScore`)
doesn't use it either; handed off a separate brief to check whether AQP staking/scoring is meant to apply
it, tracked independently, not blocking this bound-only fix. **Follow-up (2026-08-22, Fix #14):** owner
asked whether the multiplier is stable afterwards, then requested full immutability, matching the Set-Class
recipe — `C_UpdateSetMultiplier` and its capability/`XI_*`/Talos wrappers removed entirely; the multiplier
is now write-once, at Define, forever after. Live-proven (value persists with no update path able to touch
it), Z.repl green. **Follow-up 2 (2026-08-22, Fix #16):** surfaced while discussing #19H — the multiplier
is meant to boost a score, never quietly shrink it below the raw value; lower bound tightened from `(0,100]`
to `[1.0,100.0]`. Live-proven: `0.5` now correctly rejected (previously legal), `1.0` (new floor) accepted.
Z.repl green. — *DPDC-S·H1*

#16H **[DPDC-T]** ~~`UEV_TransferRoles` computes the receiver's transfer-role membership from `sender` twice
(a copy-paste variable-naming bug) — the documented sender-OR-receiver-authorized semantics for
role-restricted collectables silently degrades to sender-only, on the highest-traffic path in the module
(every transfer leg).~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-22** (`ROUND-02-FIXES.md` Fix #15) — checked
DPTF/DPOF's transfer-role pattern first (per owner direction); DPOF's `UEV_MoveRoleCheck` already does this
correctly (sender/receiver each read their own role), DPTF doesn't enforce it at all. One-line fix matching
DPOF's pattern (`sender`→`receiver`). Live-proven: role-less sender → role-holding receiver transfer now
correctly succeeds; `git stash` confirms the identical script hard-failed at that exact call pre-fix.
Z.repl green. — *DPDC-T·H1*

#17H **[DPDC-T]** ~~`C_RepurposeCollectable` skips the frozen-account and transfer-role gates that
`C_Transfer` enforces on both sender and receiver — an admin freeze intended to halt movement of a suspect
account's holdings can be silently bypassed via repurpose instead of transfer.~~ — **REFUTED
(design-intentional) 2026-08-22** — same treatment as #4C's fragment sibling: a deliberate admin
account-recovery bypass, correctly gated on `CAP_Owner` via a wipe-mode-style authorization swap (not the
actual DPDC-MNG Wipe feature — just its shared owner-override debit primitive, reused directly). Owner
considered and explicitly rejected freezing the source account afterward, since that would route through
the real freeze path and become conditional on `can-freeze=true` (#13H) — defeating the point of an
always-available escape hatch. No code change. — *DPDC-T·H2*

#18H **[DPDC-C]** ~~Native NFT Credit never checks the target nonce isn't already held by someone else — the
"single canonical holder" invariant is preserved today only by every current caller's discipline (always
debit-before-credit), not by the ledger primitive itself; one future IMC-registered caller with different
ordering creates a duplicate-token/phantom-balance state.~~ — **REFUTED (verified live) 2026-08-22** — owner
confirmed the design intent: credit trusts its caller to have already fed correct data. Checked all 3 real
callers of the raw credit primitive: `DPDC-T::C_Transfer` (every variant debits sender, validating current
holdership, before crediting receiver, atomically); `DPDC-C::C_CreateNewNonce` (brand-new nonce, no prior
holder possible); `DPDC-MNG::C_RespawnNFT` (explicitly enforces `UEV_NftNonceExistance ... false`, i.e.
current holder is `BAR`, before crediting). All three correctly gate at their own layer today. Owner
decided to leave the primitive itself unchanged — no code change. — *DPDC-C·H1*

#19H **[DPDC-UDC / DPDC-S]** ~~`UR_N|Score` (the public "cooked" score reader on `DpdcSetsV1`) fails to
clamp the DPDC `-1.0` "unscored" sentinel in 3 of its 4 arithmetic branches — a composite-class or any
fragment nonce created without explicit metadata reads a real negative score instead of the documented
"unscored = 0," and a sibling audit (AQP) has already committed a false "already fixed" assumption about
this exact function to its own audit trail.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-22** (`ROUND-02-FIXES.md`
Fix #17) — sentinel check centralized once, at function entry, on the raw untouched score, closing all 3
broken branches at once (no per-branch patching, no risk of a fifth copy-paste mistake). 8-check live proof
(NFT class-0 + SFT Set-member, unscored + real-score, native + fragment) — all unscored cases now `0.0`;
`git stash` confirms the exact pre-fix bug shape (`-0.001`/`-2.5`/`-0.0025`). Z.repl green. **Follow-up
(2026-08-23, Fix #18):** renamed `UR_N|Score`→`URC_N|Score` — "prefix is the contract": it reads
`UR_NonceClass`/`UR_N|RawScore`/`UR_SetMultiplier` then derives a computed value, the `URC_*` contract, not
a plain `UR_*` read. Zero callers anywhere, so no call site needed updating; moved into the module's
`[URC]` section. Live-proven: the full #19H probe suite still passes under the new name. Z.repl green. —
*DPDC-UDC/DPDC-S·H1*

#20H **[DPDC-N]** ~~`C_UpdateNonceIgnisRoyalty` has no upper bound at all — `UEV_IgnisRoyalty` only checks
decimal precision, unlike its sibling `UEV_Royalty` (capped `[1,999]` promile via the shared `UEV_Fee`); a
`role-modify-royalties` delegate can set an arbitrarily large flat per-unit IGNIS charge, economically
freezing the nonce or silently overcharging a buyer — the same bug class the ATS audit already found and
fixed on a sibling validator, but worse here (no bound at all vs. ATS's 999-promile ceiling).~~ — **REFUTED
(design-intentional) 2026-08-23** — owner: there's no principled magnitude ceiling here, same as there's no
ceiling on what an estate could be worth — a $10M NFT could legitimately warrant a $10K movement royalty.
Left to the collection owner's discretion; precision-only check stays, no magnitude bound added. No code
change. — *DPDC-N·H1*

#21H **[DPDC-S]** ~~`score-multiplier` is completely unvalidated at Define time (no precision, no sign check)
while the identical field is precision-checked at Update time — a set-class can be created with a
non-3-decimal or negative multiplier baked in for the rest of its life.~~ — **ALREADY CLOSED by #15H's fix
chain, 2026-08-23** — Fix #13 added exactly this Define-time validation (precision + magnitude), Fix #14
removed the Update path entirely, Fix #16 tightened the floor to `[1.0,100.0]`. No separate action needed. —
*DPDC-S·H2*

#22H **[EQUITY]** ~~The entire financial-instrument module (shareholder package shares — dilution-sensitive
by construction) has zero REPL/test coverage anywhere in the repository; every conservation claim in this
audit for EQUITY is verified only by static reading, never exercised end-to-end.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-23** (`ROUND-02-FIXES.md` Fix #20) — owner recalled testing EQUITY and believed it worked; verified
live rather than assumed. Found real test code existed (`[6.1]_DPDC.repl` "TX 014") but was fully
unreachable (file disabled, and even run directly crashes on an earlier unrelated bug before reaching it;
its target collection is never actually created; assertions were print-only). Building real coverage
surfaced and required fixing a genuine regression first (#5C follow-up, Fix #19 — EQUITY's Convert/Break
was actually broken by an earlier fix). Once fixed, added `REPL/Stage_02/[6.1.1]_EQUITY.repl` — Issue
baseline + Make/Convert/Break exact-conservation round trip + 5 negative-path checks, 19 assertions total,
wired into the active `Stage02_Tester.repl`/`Z.repl` pipeline. All passing, Z.repl green. — *EQUITY·H1*

## MEDIUM

#23M **[DPDC-C]** ~~`XI_CreditOrDebitCollectables`'s 16-branch capability-dispatch `cond` silently no-ops
(skips all authorization) on an unmatched shape instead of hard-failing — currently unreachable given
today's upstream invariants, but a future weakening of those invariants fails open, not closed.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #21) — trailing `true` replaced with
`(enforce false ...)`, fails closed instead of open. Full Z.repl (every real credit/debit path in the
suite) still 100% clean. No live before/after reachability repro is possible given the finding's own
"currently unreachable" nature — owner accepted this scope of verification. — *DPDC-C·M2*

#24M **[DPDC-C]** ~~NFT `amount=1` enforcement is present on native-NFT Credit but absent on all three
NFT-fragment/hybrid Credit variants of the identical logical operation — same root cause as #1C/#3C, worth
its own explicit fix once the sign floor lands.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23**
(`ROUND-02-FIXES.md` Fix #22) — owner corrected the framing: the real invariant is "positive multiple of
1000" (fragments are 1000 units per whole NFT), not `=1` (native-only). New shared
`UEV_FragmentCreditAmount` wired into all 3 fragment/hybrid credit capabilities. Caught and corrected a
proof-methodology mistake (an initial test "passed" only because of the pre-existing `UEV_IMC` guard, not
the new check — confirmed by a legal-amount control failing identically) before treating it as real.
Corrected proof: real Make-Fragments flow still produces exactly 1000; the validator correctly rejects
500/0/-1000/1500 and accepts 1000/2000. Z.repl green. — *DPDC-C·M1*

#25M **[DPDC-N]** ~~Royalty and IGNIS-royalty are read live at transfer time with no snapshot or max-price
guard — a `role-modify-royalties` holder can front-run a pending buyer's transfer by raising the fee
mid-flight, amplified by #20H's missing ceiling.~~ — **REFUTED (design-intentional) 2026-08-23** — weighed
3 options with the owner: a slippage-style `max-ignis-royalty` guard (real protection, but needs a
`DpdcTransferV1`/`V2` interface change and UI work to be useful), a timelock on royalty changes (protects
the hot transfer path without touching its interface, but doesn't stop the underlying scenario, just delays
it), and leaving it as-is. Owner: a lock buys nothing against the actual threat (the role holder controls
the lock too, so they'd just unlock-modify-relock in their own transaction) — and this is the same trust
model already accepted for #4C/#17H/#20H (collection owner has complete, trusted dominion over their own
token's economics). Chose to leave it as-is: royalty changes are already `@event`-logged in real time, a
well-built marketplace UI can re-read the live value immediately before signing, and as Ouronet admin the
owner can red-flag an abusive collection if reports come in. No code change. — *DPDC-N·M1*

#26M **[DPDC-N]** ~~`C_UpdateNonceRoyalty` mutates a field (`royalty`) with zero on-chain economic consumers
anywhere in the loaded module set — either an unfinished "Volumetric Royalty Fee" feature or an
undocumented off-chain-only hint; an owner paying to change it gets no on-chain effect either way.~~ —
**FIXED ✅ AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #23) — owner confirmed intentional: a
forward-looking hook for the upcoming Escrow/NFT marketplace, not yet built, which is exactly why nothing
consumes it today. Documented at the schema field, the reader (`UR_N|Royalty`), and the write entrypoint
(`C_UpdateNonceRoyalty`) — no behavior change, comment-only. Z.repl green. — *DPDC-N·M2*

#27M **[DPDC-F]** ~~The make+merge round trip and the C_RepurposeCollectableFragments-without-consent
scenario are both actually executed in the checked-in REPL suite but never asserted (`(expect ...)` absent
in both cases) — masking #3C/#4C from CI entirely.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23**
(`ROUND-02-FIXES.md` Fix #24) — the only prior test was unreachable (disabled file, crashes before this
section even standalone), so this closes real zero-coverage, not just a missing assertion. New canonical
suite `REPL/Stage_02/[6.1.2]_DPDC-FRAGMENTS.repl`, wired into `Stage02_Tester.repl`: Make→Merge exact
conservation, plus repurpose-without-consent traced to `DPDC-C|C>SINGLE-DEBIT`'s `wipe-mode=true` →
`CAP_Owner` gate (owner-only), proven directly and via an isolation control on the `patron` argument.
Z.repl green, 12/12 assertions pass. — *DPDC-F·M1*

#28M **[EQUITY]** ~~"Shareholder collection" identity is a self-checked `"E|"` string prefix, not a registry
EQUITY itself owns — the only real backstop today is a different module's role table
(`DPDC-MNG`'s `role-nft-add-quantity`/`role-nft-burn`), an implicit trust chain rather than an
EQUITY-owned invariant.~~ — **REFUTED 2026-08-23** — the "any caller can forge an `E|`-prefixed collection"
premise doesn't survive a deeper trace. Two independent, stacked walls block it: (1) collection
name/ticker characters go through `UEV_NameOrTicker` -> `UC_IzStringANC` -> `UC_IzCharacterANC`, which only
allows `|` when the internal `iz-special` flag is `true` — the only public, wallet-callable issuance path
(`TS02-C1.DPSF|C_Issue`) hardcodes `iz-special=false`, so `"|"` is structurally impossible in a
publicly-issued ticker; `"E|"` IDs can only ever originate from the handful of privileged call sites
(EQUITY's own issuance, SWP pool-pair naming) that invoke the core function directly with
`iz-special=true`. (2) Even for those privileged callers, `DPDC-I|C>ISSUE` enforces
`CAP_EnforceAccountOwnership owner-account` — since EQUITY always names `dpdc` as owner, forging a
lookalike would require already controlling `dpdc`'s own guard, not just typing the string "dpdc". No
exploitable path found; no code change. — *EQUITY·M1*

#29M **[EQUITY]** ~~`URC_CombineCapacity`'s "at most 50% of shares may ever be packaged" rule is an
undocumented magic constant (`(/ shares 2)`, no `defconst`, no `@doc`) — a permanent cap-table invariant a
future maintainer is equally likely to "fix" as a bug.~~ — **FIXED ✅ AND PROVEN ✅ 2026-08-23**
(`ROUND-02-FIXES.md` Fix #25) — extracted to a named, documented `PACKAGING_CAP_DIVISOR` constant; added
`@doc` to `URC_CombineCapacity` and 3 previously-undocumented sibling functions in the same
packaging-capacity subsystem (`UR_TierSupplies`, `URC_MakeSharePackage`, `URC_SingleSharePerMillions`).
Pure rename/doc change — the #22H EQUITY REPL suite's exact-number assertions (500,000/400,000 capacity
values, over-capacity rejection) all still pass identically. Z.repl green. — *EQUITY·M2*

#30M **[DPDC-S]** ~~`C_EnableSetClassFragmentation` is the only one of five owner-gated set mutations that
skips the `UEV_SetActiveState` gate its four siblings all enforce.~~ — **FIXED ✅ AND PROVEN ✅
2026-08-23** (`ROUND-02-FIXES.md` Fix #26) — added `(UEV_SetActiveState id son set-class true)` to
`DPDC-S|C>ENABLE-FRAGMENTATION`, matching `C>RENAME`'s requirement. Define defaults new set-classes to
active, so the normal flow is unaffected; live-proven on `DHCD-98c486052a51`: toggle-off now rejects
enable-fragmentation, toggle-on restores it. Z.repl green. — *DPDC-S·M2*

#31M **[DPDC-S]** ~~Primordial set-definition bounds (like #6C's composite-side root cause) only check the
running maximum referenced value, not each individual entry — an unsatisfiable-but-nonzero value silently
burns a monotonic, never-reclaimed set-class slot rather than value-locking a real nonce.~~ — **FIXED ✅
AND PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #27) — bug reproduced live first (a `DPSF|C_DefinePrimordialSet`
call with a garbage `-100000` value alongside legit `1`/`2` values on the real `DHCD-98c486052a51`
collection succeeded, since the old plain-max check can't see a large negative as wrong when a small
legit value is also present), then fixed with a per-element `0 < abs(n) <= nu` bound on every
`allowed-nonces` value. Re-proven post-fix: the garbage value and a `0` control case are both now
rejected; a legitimate all-real-values definition still succeeds. Z.repl green. — *DPDC-S·M3*

#32M **[DPDC-S]** ~~Hybrid set Make-time constituent ordering and Break-time reconstruction ordering are
opposite conventions in two different functions — currently harmless only because every current constraint
happens to make the (nonce, quantity) set order-independent; structurally fragile.~~ — **FIXED ✅ AND
PROVEN ✅ 2026-08-23** (`ROUND-02-FIXES.md` Fix #28) — bug reproduced live first: temporarily reverted
the fix and confirmed `URC_SemiFungibleConstituents` (Break-time) really did return `[11 5]`
(composite-first) against a real Hybrid set-class on `DHCD-98c486052a51`, opposite of Make-time's expected
`[5 11]` (primordial-first). Normalized Break-time to primordial-first, added cross-referencing comments
at both functions. Re-proven post-fix: now returns `[5 11]`, matching exactly. Z.repl green — no
active-pipeline test defines a Hybrid set today, so nothing else could regress. — *DPDC-S·M1*

#33M **[DPDC-I / U|DALOS]** Collection id generation (`UDC_Makeid`) is keyed only on `prev-block-hash`, a
block-level constant identical for every tx in the same block, with no per-tx uniqueness component — two
same-ticker issuances in the same block collide and the second hard-aborts with an opaque low-level error
instead of a graceful uniqueness message (real, if not cheap, griefing/DoS surface). — *DPDC-I·M1*

#34M **[DPDC]** `URD_AccountNoncesWithSupplies` returns `[{}]` instead of `[]` when an account holds zero
nonces of a collectable — wrong non-zero count and a malformed row for any indexer/wallet UI built on it
(sibling `URD_AccountNonces` gets this right). — *DPDC·M1*

#35M **[DPDC]** `XB_DeployAccountSFT`/`XB_DeployAccountNFT` never verify the caller controls the target
`account`, and the `DPDC-I`/Talos wrappers on top add no ownership check either — any signer can force any
existing account to "associate" with any collection (state-bloat/griefing, no direct fund/permission loss;
the write itself is confirmed idempotent-safe, not an overwrite bug). — *DPDC·M2*

#36M **[DPDC]** `AUP_Account`/`AUP_Property` admin-migration helpers slice composite keys via hardcoded
character offsets instead of the BAR-delimiter split used everywhere else in the file — silently corrupts
Select-Key fields for any non-standard-length account during a migration run. — *DPDC·M3*

#37M **[DPDC-UDC]** `UDC_ZeroNonceData` is called cross-module through a `module{DpdcUdcV1}`-typed ref from
4 sibling files but is absent from the `DpdcUdcV1` interface itself — works today only via Pact's dynamic
`ref::fun` resolution, not the documented static-interface contract; free to fix before mainnet. —
*DPDC-UDC·M1*

#38M **[DPDC-UDC / DPDC-S]** `UDC_NoPrimordialSet`/`UDC_NoCompositeSet` sentinels are structurally
indistinguishable from a degenerate real definition, detected only by ad hoc structural equality at the one
call site that needs it — self-limiting today (nonce 0 never exists) but depends on an implicit,
undocumented cross-module invariant with zero explicit guard. — *DPDC-UDC·M2*

## LOW

#39L **[DPDC-S]** Zero REPL coverage for the entire Make/Break round trip and every admin mutation in this
module — directly explains why #6C and #7C shipped undetected. — *DPDC-S·L1*

#40L **[DPDC-MNG]** The escalating-scope `Wipe*` family (`Heavy`/`Pure`/`Clean`/`Dirty`) has zero REPL test
coverage — the checked-in "TX 005b -- Wipe Tests" transaction is entirely commented out — directly explains
why #5C and the `M1` in-module `C_→C_` call pattern went unnoticed. — *DPDC-MNG·L1*

#41L **[DPDC]** Test-coverage gaps: branding functions (zero calls anywhere, exactly why #9H was never
caught) and stark SFT-vs-NFT asymmetry — `DPNF|C_*` gets one exercised call in the entire suite vs. dozens
for `DPSF|C_*`, leaving the entire NFT-side duplicate of every SFT-tested path effectively unverified. —
*DPDC·L3*

#42L **[DPDC-R]** No REPL coverage exercises the ownership gate's negative path (non-owner attempting a
role toggle/move) for any of the 12 role functions, and several toggle-off legs are commented out — the
single highest-value missing assertion class for this module; would have caught #13H. — *DPDC-R·L1*

#43L **[DPDC-C]** `XI_RegisterCollectionElement` (an `XI_` write-tier function) returns a formatted
business string instead of ending on a write, embedding presentation logic in a write-tier function —
StoicSyntax discipline deviation, not a functional bug. — *DPDC-C·L1*

#44L **[DPDC-T]** Dual `implements DpdcTransferV1` + `DpdcTransferV2` deviates from the repo's
"latest-version-only" cascade policy — deliberately documented as an additive-only exception, no functional
risk, but a process/documentation divergence worth formally recording. — *DPDC-T·L1*

#45L **[DPDC-UDC]** `UDC_ScoreMetaData` is dead code — the real score-mutation path (`XI_U|NonceScore`)
bypasses this constructor entirely via a raw object merge, violating the repo's own "prefer named
constructors over ad-hoc `object{}` literals" convention. — *DPDC-UDC·L1*

#46L **[DPDC-UDC]** Several constructors (`UDC_DPDC|Properties`, `UDC_URI|Type`/`Data`, `UDC_NonceData`)
take 5-8 same-typed positional parameters in a row — a standing transposition risk with no
compiler-enforced field binding; every current call site was audited and found safe (named locals in field
order), design-robustness note only, no live bug. — *DPDC-UDC·L2*

#47L **[DPDC-F]** `C_RepurposeCollectableFragments` Multi Mode has no `length>0` guard — an empty
nonces/amounts pair passes the cap and likely aborts several call-hops later with an opaque out-of-bounds
error instead of a clear gate-level message. — *DPDC-F·L1*

#48L **[DPDC-F]** `DPDC-F|C>MERGE` omits `id`/`son` from its capability parameters and neither `C>NONCE`
nor `C>MERGE` are marked `@event`, inconsistent with sibling caps in the same file — not independently
exploitable, weakens the module's own audit trail. — *DPDC-F·L2*

#49L **[EQUITY]** Make/Break reimplements `DPDC-S`'s "combine nonces / break back" pattern with a bespoke,
divergent mechanism sharing no code and no test surface — architecturally defensible, but a future
`DPDC-S` invariant fix won't propagate here automatically. — *EQUITY·L1*

#50L **[EQUITY]** `URC_SingleSharePerMillions` has no declared return type, inconsistent with every sibling
`URC_*`/`UC_*` in the file — cosmetic type-hygiene only. — *EQUITY·L2*

#51L **[DPDC-S]** Empty set-definitions crash with an opaque `Array index out of bounds` error instead of a
clean `enforce` message (`(enumerate 0 -1)` returns `[0,-1]`, not `[]`) — fails closed, not exploitable, but
confusing; no upper bound on definition length exists either. — *DPDC-S·L2*

#52L **[DPDC-S]** `URC_NoncesSummedScore` sums raw constituent scores via `UR_N|RawScore`, silently
discarding any set-multiplier a constituent nonce itself carries if it's a nested previously-made set —
possibly intentional (avoid double-multiplication) but undocumented and untested. — *DPDC-S·L3*

#53L **[DPDC-I]** `creator-account` is bound into a new collection with no ownership/consent check (only
`owner-account` goes through real `CAP_EnforceAccountOwnership`) — an unconsenting third party can be named
"creator" and silently granted real collection-admin permissions. — *DPDC-I·L1*

#54L **[DPDC-I]** `C_DeployAccountSFT`/`C_DeployAccountNFT` carry no `UEV_IMC`, no capability, and no
`@doc` explaining the intentionally-permissionless design — traced and confirmed non-exploitable (the
callee is existence-gated and idempotent), but reads as under-protected to a reviewer until that's traced.
— *DPDC-I·L2*

#55L **[DPDC]** `UR_AS-KEYS` performs a full table scan (`keys`) but is named with the point-read `UR_`
prefix instead of `URD_`, breaking the prefix-as-contract guarantee — no execution-path risk (manual/admin
use only), pure naming violation. — *DPDC·L1*

Also recorded, not independently numbered (documentation-only, zero functional risk):
**[DPDC]** `DPNF|AccountRoles`'s interface `@doc` states the reverse composite-key field order from what
the real, consistently-used code does — *DPDC·L2*.
