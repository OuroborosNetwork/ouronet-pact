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

#3C **[DPDC-F]** `amount` is never validated `>0` anywhere in the Make/Merge/Repurpose fragmentation call
chain (same root gap as #1C, reached via a different entrypoint) — a negative `amount` to
`C_MakeFragments`/`C_MergeFragments` inverts debit/credit direction, minting a free unit of the source
nonce for the caller while driving the protocol's own `dpdc` escrow ledger negative. — *DPDC-F·C2*

#4C **[DPDC-F]** `C_RepurposeCollectableFragments` has no `CAP_Owner`, no
`CAP_EnforceAccountOwnership repurpose-from`, no freeze check, no `can-wipe` check — any collection-owner
account can move any other holder's fragment balance without consent by hard-coding `wipe-mode=true` on the
underlying debit, bypassing the compliance gates the legitimate wipe path requires. Live-reproducible shape
already present, unasserted, in `[6.1]_DPDC.repl` TX015. — *DPDC-F·C1*

#5C **[DPDC-MNG]** Burn/wipe has zero fragmentation-awareness: nothing stops a collection owner from
freezing and wiping the protocol's own `dpdc` escrow account's collateral, permanently orphaning every
outstanding fragment (`-N`) claim against it; `C_RespawnNFT` can later re-attach the same nonce-data to
`dpdc` again, letting stale pre-burn fragment holders redeem/claim an asset they have no legitimate claim
to. — *DPDC-MNG·C1*

#6C **[DPDC-S]** Composite/Hybrid SFT set-class definitions with `allowed-sclass = 0` (the codebase's
reserved "not part of any set" sentinel) pass definition validation — Make then legitimately transfers a
real constituent nonce into `dpdc` custody, but Break can **never** succeed (`read` on a nonexistent
set-class-0 row aborts every time), permanently stranding real user value. — *DPDC-S·C2*

#7C **[DPDC-S]** `C_UpdateSetMultiplier` cannot ever succeed — a copy-paste `let` type-annotation bug
(`current-multiplier:string` binding a `:decimal` return) crashes the function unconditionally on every
call, reproduced live against `pact 5.4`. The entire multiplier-update feature is dead on arrival (feature
DoS, not a fund-loss bug, but total and silent — the module deploys fine). — *DPDC-S·C1*

#8C **[DPDC-S / DPDC-C]** `how-many-sets` is never bounded to a positive value anywhere on the
`C_MakeSemiFungibleSet`/`C_BreakSemiFungibleSet` path, and the one downstream gate that could theoretically
catch it (`UEV_NonceQuantityInclusion`) is trivially satisfied by any negative amount — entry-point gap
CONFIRMED, terminal mint/destroy arithmetic not independently re-derived in this pass (flag for Round III
closure). — *DPDC-S·C3*

## HIGH

#9H **[DPDC]** Talos's `DPSF|C_UpdatePendingBranding` passes 7 positional args to DPDC's 6-parameter
`C_UpdatePendingBranding` (a stray leading `patron`, copy-pasted from the neighboring `C_UpgradeBranding`
pattern) — every SFT branding-update call hard-aborts, 100% of the time, for a paid (400 IGNIS) feature
that's never been exercised by any test. — *DPDC·H1*

#10H **[DPDC-I]** NFT issuance is always billed at the cheaper SFT KDA price — the `if son` branch in
`C_IssueDigitalCollection`'s cost computation queries the same `"dpsf"` price key on both sides, contradicting
the 400/500 KDA split explicitly documented at the Talos layer; a guaranteed, silent 20% revenue shortfall on
every NFT collection ever issued. — *DPDC-I·H1*

#11H **[DPDC-I]** NFT genesis issuance with owner==creator (the most common issuance shape) writes
`role-modify-royalties`/`role-exemption`/`role-modify-creator = false` into the `Account` table (the table
that actually gates those operations) while the parallel `VerumRoles` write claims the owner has them — a
solo NFT creator cannot set royalties on their own mints until they notice and self-correct with an extra
paid transaction. — *DPDC-I·H2*

#12H **[DPDC]** The shared `XE_*` write-forwarding surface for Properties/Nonces/AccountSupplies performs
zero value-level validation — `UEV_IMC` only authenticates the calling module, not the value being written
(no monotonicity check on `nonces-used`, no non-negativity check on `XE_W|Supply`'s absolute value); every
conservation invariant for the shared core used by all 10 sibling modules rests entirely on caller
discipline outside this file. Corroborated by a live "computed but never enforced" dead-validation instance
in `DPDC-T`'s own transfer-amount check. — *DPDC·H2*

#13H **[DPDC-R]** `DPDC|C>FRZ-ACC` gates **both** freeze and unfreeze on the collection's `can-freeze`
switch (every sibling role toggle only gates the granting/"on" direction) — combined with `can-upgrade=false`
(both flippable in one ordinary `C_Control` call), this permanently bricks a frozen account with no recovery
path, reachable via an honest owner's routine "lock in settings" misconfiguration, not just malice. —
*DPDC-R·H1*

#14H **[DPDC-MNG]** Pause never gates a single mutating entrypoint in this module (`C_AddQuantity`,
`C_BurnSFT`/`NFT`, all `Wipe*`, `C_RespawnNFT`) — only `DPDC-T`'s transfers actually check
`UEV_PauseState`. An owner pausing a collection during an incident (e.g. a compromised Add-Quantity-role
account) does not stop that account from continuing to mint/burn/wipe. — *DPDC-MNG·H1*

#15H **[DPDC-S]** Set-class `score-multiplier` has no bound and no live-supply guard — once #7C is fixed,
an owner can retroactively re-price every outstanding member of a set-class instantly and unboundedly (same
shape as the SWP audit's `C_ModifyWeights` finding), with zero time-lock. — *DPDC-S·H1*

#16H **[DPDC-T]** `UEV_TransferRoles` computes the receiver's transfer-role membership from `sender` twice
(a copy-paste variable-naming bug) — the documented sender-OR-receiver-authorized semantics for
role-restricted collectables silently degrades to sender-only, on the highest-traffic path in the module
(every transfer leg). — *DPDC-T·H1*

#17H **[DPDC-T]** `C_RepurposeCollectable` skips the frozen-account and transfer-role gates that
`C_Transfer` enforces on both sender and receiver — an admin freeze intended to halt movement of a suspect
account's holdings can be silently bypassed via repurpose instead of transfer. — *DPDC-T·H2*

#18H **[DPDC-C]** Native NFT Credit never checks the target nonce isn't already held by someone else — the
"single canonical holder" invariant is preserved today only by every current caller's discipline (always
debit-before-credit), not by the ledger primitive itself; one future IMC-registered caller with different
ordering creates a duplicate-token/phantom-balance state. — *DPDC-C·H1*

#19H **[DPDC-UDC / DPDC-S]** `UR_N|Score` (the public "cooked" score reader on `DpdcSetsV1`) fails to
clamp the DPDC `-1.0` "unscored" sentinel in 3 of its 4 arithmetic branches — a composite-class or any
fragment nonce created without explicit metadata reads a real negative score instead of the documented
"unscored = 0," and a sibling audit (AQP) has already committed a false "already fixed" assumption about
this exact function to its own audit trail. — *DPDC-UDC/DPDC-S·H1*

#20H **[DPDC-N]** `C_UpdateNonceIgnisRoyalty` has no upper bound at all — `UEV_IgnisRoyalty` only checks
decimal precision, unlike its sibling `UEV_Royalty` (capped `[1,999]` promile via the shared `UEV_Fee`); a
`role-modify-royalties` delegate can set an arbitrarily large flat per-unit IGNIS charge, economically
freezing the nonce or silently overcharging a buyer — the same bug class the ATS audit already found and
fixed on a sibling validator, but worse here (no bound at all vs. ATS's 999-promile ceiling). — *DPDC-N·H1*

#21H **[DPDC-S]** `score-multiplier` is completely unvalidated at Define time (no precision, no sign check)
while the identical field is precision-checked at Update time — a set-class can be created with a
non-3-decimal or negative multiplier baked in for the rest of its life. — *DPDC-S·H2*

#22H **[EQUITY]** The entire financial-instrument module (shareholder package shares — dilution-sensitive
by construction) has zero REPL/test coverage anywhere in the repository; every conservation claim in this
audit for EQUITY is verified only by static reading, never exercised end-to-end. — *EQUITY·H1*

## MEDIUM

#23M **[DPDC-C]** `XI_CreditOrDebitCollectables`'s 16-branch capability-dispatch `cond` silently no-ops
(skips all authorization) on an unmatched shape instead of hard-failing — currently unreachable given
today's upstream invariants, but a future weakening of those invariants fails open, not closed. —
*DPDC-C·M2*

#24M **[DPDC-C]** NFT `amount=1` enforcement is present on native-NFT Credit but absent on all three
NFT-fragment/hybrid Credit variants of the identical logical operation — same root cause as #1C/#3C, worth
its own explicit fix once the sign floor lands. — *DPDC-C·M1*

#25M **[DPDC-N]** Royalty and IGNIS-royalty are read live at transfer time with no snapshot or max-price
guard — a `role-modify-royalties` holder can front-run a pending buyer's transfer by raising the fee
mid-flight, amplified by #20H's missing ceiling. — *DPDC-N·M1*

#26M **[DPDC-N]** `C_UpdateNonceRoyalty` mutates a field (`royalty`) with zero on-chain economic consumers
anywhere in the loaded module set — either an unfinished "Volumetric Royalty Fee" feature or an
undocumented off-chain-only hint; an owner paying to change it gets no on-chain effect either way. —
*DPDC-N·M2*

#27M **[DPDC-F]** The make+merge round trip and the C_RepurposeCollectableFragments-without-consent
scenario are both actually executed in the checked-in REPL suite but never asserted (`(expect ...)` absent
in both cases) — masking #3C/#4C from CI entirely. — *DPDC-F·M1*

#28M **[EQUITY]** "Shareholder collection" identity is a self-checked `"E|"` string prefix, not a registry
EQUITY itself owns — the only real backstop today is a different module's role table
(`DPDC-MNG`'s `role-nft-add-quantity`/`role-nft-burn`), an implicit trust chain rather than an
EQUITY-owned invariant. — *EQUITY·M1*

#29M **[EQUITY]** `URC_CombineCapacity`'s "at most 50% of shares may ever be packaged" rule is an
undocumented magic constant (`(/ shares 2)`, no `defconst`, no `@doc`) — a permanent cap-table invariant a
future maintainer is equally likely to "fix" as a bug. — *EQUITY·M2*

#30M **[DPDC-S]** `C_EnableSetClassFragmentation` is the only one of five owner-gated set mutations that
skips the `UEV_SetActiveState` gate its four siblings all enforce. — *DPDC-S·M2*

#31M **[DPDC-S]** Primordial set-definition bounds (like #6C's composite-side root cause) only check the
running maximum referenced value, not each individual entry — an unsatisfiable-but-nonzero value silently
burns a monotonic, never-reclaimed set-class slot rather than value-locking a real nonce. — *DPDC-S·M3*

#32M **[DPDC-S]** Hybrid set Make-time constituent ordering and Break-time reconstruction ordering are
opposite conventions in two different functions — currently harmless only because every current constraint
happens to make the (nonce, quantity) set order-independent; structurally fragile. — *DPDC-S·M1*

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
