# DALOS Audit — issues ranked, highest → lowest severity

Flat ranking of every finding in `ROUND-01-FINDINGS.md` (Round I), numbered #1 → continuously from highest
to lowest severity, with the severity letter appended (C = Critical, H = High, M = Medium, L = Low). The
finding ID in italics at the end of each line is the cross-reference into `ROUND-01-FINDINGS.md`. Present
these to the owner **one at a time, in this order** — per the HARD RULE in `README.md`, no finding is
settled until its verdict is written into `ROUND-01-OWNER-FEEDBACK.md`, this file's strikethrough
annotation, the README tracker row, and (if code changes) `ROUND-02-FIXES.md`, all in the same turn.

## CRITICAL

~~#1C~~ **[DPMF]** ~~The entire module has no `create-table` calls anywhere...~~ — **NOT A BUG ✅**
(owner, 2026-08-23): DPMF is the original MetaFungible module, intentionally retired after every
meta-fungible was migrated to DPOF (OrtoFungible = "MetaFungibleV2," renamed rather than version-bumped).
Kept only for historical/migration reference per CLAUDE.md's own documented note — never meant to be live.
Technical claim (no `create-table`, every function fails) stands as CONFIRMED; the bug framing is rejected.
No code change. See `ROUND-01-OWNER-FEEDBACK.md`. — *C1*

~~#2C~~ **[DPOF]** ~~`C_MoveCreateRole` never actually revokes the create/mint role from the previous
holder...~~ — **FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23): owner confirmed intended semantics ("moving
IS revoking"), confirming this as a real bug. Reordered `XI_SwitchCreateRole`/`XI_UpdateVerum4` so the
old-holder lookup runs before it's overwritten. Adversarially proven live: reproduced broken pre-fix,
confirmed correct post-fix, full `Z.repl` regression clean. See `ROUND-02-FIXES.md` Fix #1. — *C2*

~~#3C~~ **[DPOF]** ~~No nonce-uniqueness validation on batch nonce operations...~~ — **FIXED ✅ AND
PROVEN ✅** (owner, 2026-08-23): owner confirmed nonce lists must obviously be unique. Added
`UC_IzUnique` gates (mirroring the existing `BULK-MOVE` pattern) to `DPOF|C>DEBIT`, `DPOF|C>TRANSFER`, and
`DPOF|C>BULK-TRANSFER`. Adversarially proven live: both the whole-nonce-transfer inflation and the
negative-nonce-supply corruption reproduced pre-fix, both rejected post-fix, legitimate non-duplicated
transfer still works, full `Z.repl` regression clean. See `ROUND-02-FIXES.md` Fix #3. (Fixing this also
surfaced and fixed a separate, unrelated, previously-undiscovered bug — see **N1** below — `C_Transmit`
was completely broken for every caller regardless of nonce duplication.) — *C3*

~~#4C~~ **[VST]** ~~`C_Unreserve` checks the *DPTF issuer's* ownership, not the reserver's...~~ —
**REFUTED ✅ — NOT A BUG** (owner, 2026-08-23): Reserve/Unreserve is a one-way escrow-for-purchase
mechanism, not a symmetric self-serve lock — any holder can reserve their own tokens (payment escrow), and
the Token Manager (DPTF issuer) is the *intended* sole collector via `C_Unreserve`. "Alice and Bob are
never meant to be able to unreserve their tokens" — the ownership check on the issuer is correct by
design. No code change. See `ROUND-01-OWNER-FEEDBACK.md`. — *C4*

~~#5C~~ **[INFO-ONE]** ~~`DPOF|INFO_UpgradeBranding` calls a nonexistent function...~~ — **FIXED ✅ AND
PROVEN ✅** (owner, 2026-08-23): confirmed a typo ("OI typed 2 times"). Fixed (one-string change),
reproduced broken pre-fix (`Unbound free variable`), confirmed working post-fix (correctly-formed
`ClientInfo` object), full `Z.repl` regression clean. See `ROUND-02-FIXES.md` Fix #4. — *C5*

## HIGH

~~#6H~~ **[IGNIS/DALOS]** ~~Four DALOS `XE_*` writers skip the `SECURE`/named-cap second gate...~~ —
**REFUTED ✅ — NOT A BUG** (owner, 2026-08-24): `UEV_IMC` alone is functionally equivalent to
`require-capability (SECURE)` — only deploy-vetted, admin-registered peer modules can ever satisfy any of
its guards (same foreign-caller-needs-module-admin rule confirmed elsewhere in this audit program). The
sibling functions' `with-capability (SECURE)` wrapper is a structural dispatch-protection for a shared
internal writer (`XI_UpdateTF`), not a stronger authorization layer; the four flagged functions write
inline with no shared writer to protect, so nothing is missing. No code change. See
`ROUND-01-OWNER-FEEDBACK.md`. — *H1*

~~#7H~~ **[U_DALOS]** ~~`GLYPH|UEV_MsDc`'s charset-validation fold is inverted...~~ — **FIXED ✅ AND
PROVEN ✅** (owner, 2026-08-24): confirmed via call-site check that the function validates a whole
160-char account body, not a single character. Seeded `true`/`and` (mirroring `UC_IzStoicTagName`),
reproduced broken pre-fix, confirmed working post-fix (rejects mostly-garbage input, still accepts
all-valid input), full `Z.repl` regression clean. See `ROUND-02-FIXES.md` Fix #5. — *H2*

~~#8H~~ **[IGNIS]** ~~`C_Collect` has no per-leg zero/negative-amount filter...~~ — **FIXED ✅ AND
PROVEN ✅** (owner, 2026-08-24): confirmed a real gap; fixed by skipping collection and composing the
existing `IGNIS|S>FREE` event for any leg priced `<= 0.0`. Reproduced broken pre-fix (whole batch aborted
over one free leg), confirmed working post-fix, full `Z.repl` regression clean. See
`ROUND-02-FIXES.md` Fix #6. — *H3*

~~#9H~~ **[DPTF]** ~~`C_ToggleBurnRole`/`C_ToggleMintRole`/`C_ToggleFeeExemptionRole` are missing
`(UEV_IMC)`...~~ — **FIXED ✅ AND PROVEN ✅** (owner, 2026-08-24): confirmed no defcap-level check and
zero internal callers exist (only reachable via Talos) — real bug, "simply forgot to add the line."
Fixed by adding `(UEV_IMC)` to all three. Two of three reproduced live broken pre-fix / working
post-fix; third confirmed by code-structure identity; full `Z.repl` regression clean. See
`ROUND-02-FIXES.md` Fix #8. — *H4*

~~#10H~~ **[TFT]** ~~A single zero-amount leg aborts the entire `C_MultiTransfer`/`C_MultiBulkTransfer`
batch...~~ — **REFUTED ✅ — NOT A BUG, INTENDED DESIGN** (owner, 2026-08-24): dying in place on an
invalid (zero/fully-fee-consumed) amount is correct — silently skipping would hide the caller's
mistake. Percentage-based fee path mathematically can't produce a zero remainder from nonzero input
(floor always rounds down, `fee-promile` capped at 999.0); volumetric-tax mode's residual case
treated the same way per owner's "supply valid amounts" framing. No code change. See
`ROUND-01-OWNER-FEEDBACK.md`. — *H5*

~~#11H **[TFT]** `C_MultiBulkTransfer` updates the receiver's Elite tier but never the sender's, unlike
`C_Transfer`/`C_MultiTransfer` — leaves the sender's OURO overdraft bound computed from stale, pre-transfer
Elite-Auryn holdings.~~ — owner confirmed real bug ("its suppose to refresh for both sender and
receiver"); fixed by adding a `contains-eazs`-gated sender-side `XI_DynamicUpdateEliteAccount` call,
mirroring `C_MultiTransfer`'s pattern. See `ROUND-02-FIXES.md` Fix #10. — *H6* **FIXED ✅ AND PROVEN ✅**

~~#12H **[DPOF]** `DPOF|C>UPDATE-SPECIAL`'s immutability guard has a duplicated `cond` branch (`vzh-tag 2`
tested twice instead of `2` then `3`), letting an owner silently re-point an already-set
`hibernation-link`, contradicting the code's own "immutable!" enforce message.~~ — owner confirmed
typo; fixed (`2`→`3` on the Hibernation branch). Isolated-logic proof confirmed broken pre-fix,
correct post-fix; investigation also found the only wired caller (`VST`) can't reach the bypass
today (blocked by an earlier, unrelated re-issuance-collision), disclosed honestly. See
`ROUND-02-FIXES.md` Fix #12. — *H7* **FIXED ✅ AND PROVEN ✅**

~~#13H **[LIQUID]** `C_RegisterOuronetAccountForUrstoaHoldings` has zero ownership check of its own — not
even wrapped in a defcap — and relies entirely on a peer module's incidental `enforce-reserved` behavior to
stop account hijacking. Zero REPL coverage of this or the surrounding UrStoa bridge functions.~~ — owner:
function is unnecessary, a UI-constructed tx pattern (real signer's own `read-keyset`) already
solves this more safely for native Stoa unwrap; removed outright (core + Talos, interface + module),
`@doc` cross-references updated, pattern documented durably. See `ROUND-02-FIXES.md` Fix #13. —
*H8* **FIXED ✅ AND PROVEN ✅**

~~#14H **[U_VST]** `UEV_MilestoneWithTime` enforces only an upper bound on `duration`/`offset` — a negative
`duration` lets anyone mint a Sleep/Vest lock whose release date is already in the past, immediately
unlockable at mint time. Found independently by two lenses and empirically reproduced.~~ — fixed by
adding a non-negativity `enforce` for both `offset` and `duration`. See `ROUND-02-FIXES.md` Fix #14.
— *H9* **FIXED ✅ AND PROVEN ✅**

~~#15H~~ **[INFO-ONE]** ~~`ATS|INFO_Coil`'s third leg builds its IGNIS-cost cumulator from the wrong
token...~~ — **FIXED ✅ AND VERIFIED ✅** (owner, 2026-08-24): confirmed via `INFO_*`'s real role (a
UI-facing preview per user-facing button, zero on-chain callers by design — not a coverage gap).
Fixed to match the real execution function (`ATSU::C_Coil`) and the correct sibling pattern in
`ATS|INFO_Curl`. Live-verified predicted cost == real execution cost for a real Coil call; a fully
differential old-vs-new proof wasn't achieved for the available test fixture (disclosed as a
limitation, owner accepted). See `ROUND-02-FIXES.md` Fix #9. — *H10*

~~#16H **[INFO-ONE]** `ATS|INFO_ColdRecovery` binds two locals both named `ifp3` in the same `let` — the
Transfer-leg IGNIS cost is computed then silently shadowed/discarded from the displayed total.~~ —
confirmed real; owner deferred the fix to the main-branch INFO-function coverage project rather than
a piecemeal fix now ("rearchitecting the whole INFO function architecture is part of a bigger scope
to be done on main from top to bottom"). See `README.md` Downstream plan. — *H11* **DEFERRED**

~~#17H **[PYTHIA]** `A_UpdateDeployPrice`/`A_UpdateRenamePrice` are never wired into Talos and are therefore
permanently unreachable, confirmed live even for the legitimate admin key — the two default STOA prices are
frozen forever without a module redeploy. Same class as ATS's N3, confirmed here by live execution.~~ —
owner: "forgot to wire them"; added to `TS01-C4`, mirroring `PYTHIA|A_Link`'s pattern. See
`ROUND-02-FIXES.md` Fix #15. — *H12* **FIXED ✅ AND PROVEN ✅**

~~#18H **[U_VST]** `UC_MakeVestingDateList` silently drops the caller-supplied `offset` when `milestones = 1`
— a single-milestone "cliff" vest releases early by the full offset amount. Found independently by two
lenses (rated MEDIUM by one, HIGH by the other — ranked here pending owner review).~~ — fixed
(`present-time` → `first-time` in the `milestones=1` branch). See `ROUND-02-FIXES.md` Fix #16. —
*H13* **FIXED ✅ AND PROVEN ✅**

~~#19H **[U_CT]** `UR|KDA-PID`, the sole KDA/USD price oracle feed used across asymmetric-LP IGNIS taxation
and DemiPad pricing, is a hardcoded `1.0` stub with the real oracle call commented out — every dependent
computation silently assumes permanent KDA/USD parity.~~ — owner: no oracle exists yet; updated the
placeholder to `0.1` (mainnet's approximate KDA/USD price) pending real oracle wiring. See
`ROUND-02-FIXES.md` Fix #17. — *H14* **FIXED ✅ (interim value; real oracle wiring deferred)**

~~#20H **[U_DEC]** `UC_AddHybridArray` returns bogus output on an empty column list and hard-crashes
(uncatchably) on an all-empty-row list, due to Pact's bidirectional `enumerate` producing an unexpected
descending range. Empirically reproduced both failure modes.~~ — confirmed no current caller triggers
it; fixed with a purely additive `(if (= maxl 0) [] ...)` guard, zero change to the existing
non-empty path (owner's explicit don't-break-it constraint verified). See `ROUND-02-FIXES.md`
Fix #18. — *H15* **FIXED ✅ AND PROVEN ✅**

~~#21H **[Talos Admin]** Roughly half of `TalosStageOne_AdminV1`'s in-scope surface (DALOS/LIQUID/DPTF
migration and treasury-debt admin functions) has zero effective REPL exercise, and the dedicated Admin
suite itself asserts nothing at all — the exact coverage shape that let ATS's N3/C3 ship silently.~~ —
confirmed real (test-coverage gap, not a code bug); owner deferred to the main-branch REPL-test-
backfill/test-infrastructure-refactor phase rather than a piecemeal fix now. See `README.md`
Downstream plan. — *H16* **DEFERRED**

~~#22H **[DPOF/TS01-C1]** `DemiourgosPactOrtoFungibleV2`/`TalosStageOne_ClientOneV2` are fully cascaded and
correct locally but confirmed still un-deployed live — a required, already-prepared redeploy step (DPOF
before TS01-C1) before this pair can ship.~~ — **NOT A BUG, status note**: owner confirmed this is
simply the expected state after modifying code that warranted a version bump; the actual redeploy
(DPOF before TS01-C1) happens as part of the already-planned StoicSyntax/interface-version-bump/
redeploy phase, not a standalone action now. See `README.md` Downstream plan. — *H17*
**FINALIZED — folded into the redeploy phase**

~~#23H **[OuroborosV1]** The live, actively-used `C_SublimateV2` function is missing from its own interface
— confirmed already live in production this way, not just a local gap. Needs a version bump to accurately
describe the deployed module's real surface.~~ — owner confirmed real, legitimately-used (cheaper
freeze+wipe alternative to `C_Sublimate`); added to the interface, purely additive, pre-mainnet `V1`
edited freely (no bump needed). See `ROUND-02-FIXES.md` Fix #19. — *H18* **FIXED ✅ AND VERIFIED ✅**

~~#24H **[CodexV1]** Four live, actively-called `C_` functions (`RotateCodexGuard`, `RecordArweaveUpload`,
`RegisterStoicTag`, `ReleaseStoicTag`) are entirely absent from the interface, which declares no `C_`
function at all — confirmed already live in production this way.~~ — added all four, purely
additive, matching the module's real signatures. See `ROUND-02-FIXES.md` Fix #20. — *H19*
**FIXED ✅ AND VERIFIED ✅**

## MEDIUM

~~#25M **[DALOS]** `C_RotateKadena` reads the account's Kadena address after it's already been overwritten,
permanently orphaning the old address's reverse-index ledger row (currently zero live consumers of that
index).~~ — re-verified live in REPL per owner's standing instruction (confirmed real: old ledger row
kept the account forever); fixed by reading the old address before the overwrite. See
`ROUND-02-FIXES.md` Fix #21. — *M1* **FIXED ✅ AND PROVEN ✅**

~~#26M **[DALOS]** Smart-account deploy validation lives inside the internal `XI_*` writer rather than the
`C_*`/`A_*` master cap — not a bypass, but inverts the intended defcap/XI discoverability split.~~ —
re-verified live per owner's standing instruction; fixed with a new `DALOS|A>DEPLOY-SMART-OURONET-
ACCOUNT` cap that composes the existing shared validation cap (no duplication), moving validation to
both client caps; `XI_DeploySmartAccount` is now a pure writer. See `ROUND-02-FIXES.md` Fix #22. —
*M2* **FIXED ✅ AND VERIFIED ✅**

~~#27M **[DALOS]** `GAS_PAYER`'s gas-station allowlist matches module names by string prefix rather than
exact identity — fragile, bounded today by namespace deploy governance.~~ — re-verified live; owner:
intentional, every real Talos module is deliberately `TS`-prefixed by naming convention, other
exempted categories similarly scoped. No code change. — *M3* **NOT A BUG ✅ — closed, intentional
design**

~~#28M **[TFT]** `C_ClearDispo` unconditionally force-unfreezes the Elite-Auryn account even if it was frozen
for an unrelated reason beforehand.~~ — re-verified live per owner's standing instruction (confirmed
real); fixed by mirroring the initial-freeze guard onto the final unfreeze. See
`ROUND-02-FIXES.md` Fix #23. — *M4* **FIXED ✅ AND PROVEN ✅**

~~#29M **[TFT]** `dispo-data` is snapshotted once before a multi-transfer's fold and reused for every leg,
stale relative to an earlier leg in the same batch that reduces the same account's Elite-Auryn holdings.~~
— re-verified live, and this turned out to be a REAL overdraft-inflation exploit (more severe than
ranked): a single batch combining an EA-reducing leg + OURO-overdraft leg let `patron` overdraft
beyond their correct post-batch limit. Fixed by recomputing `dispo-data` fresh per leg in both
`C_MultiTransfer` and `C_MultiBulkTransfer`. See `ROUND-02-FIXES.md` Fix #24. — *M5* **FIXED ✅ AND
PROVEN ✅**

~~#30M **[DPTF]** `UR_Hibernation`, an unprotected "read," performs a live unguarded table `update`
(idempotent backfill) — a read/write-separation violation called pervasively as if it were a pure getter.~~
— confirmed intentional legacy backfill; live StoaChain check (via Pythia dirty-read, see
`OuronetInformational/memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md`)
confirmed all 18 real DPTF tokens already have the field populated (zero gaps), so simplified
directly to a pure getter, no migration needed. See `ROUND-02-FIXES.md` Fix #25. — *M6* **FIXED ✅
AND VERIFIED ✅**

~~#31M **[DPOF]** `URC_Parent` contains a direct `enforce`, violating the `URC_` no-enforce contract.~~ —
confirmed live-reachable (Sleeping links on LP tokens are explicitly sanctioned, just not yet
created); fixed by moving the enforce to `UEV_ParentOwnership` (its one real owner). See
`ROUND-02-FIXES.md` Fix #26. — *M7* **FIXED ✅ AND PROVEN ✅**

~~#32M **[DPOF]** `C_WipeHeavy` calls a table-scanning `URDC_*` helper directly from a public `C_` body,
never renamed to the `CC_`/`AA_` HEAVY convention that exists to flag exactly this pattern — the function's
own `@doc` already describes the anti-pattern it exhibits.~~ — confirmed real, purely a naming-convention
drift (function already self-documents the risk; identical pattern also found duplicated verbatim in
Stage 2's `06_DPDC-MNG.pact`). Owner: defer to the StoicSyntax sweep, along with all similar
naming/convention-only findings in this list. See `README.md` Downstream plan phase 4 and the
2026-08-28 batch-defer note. — *M8* **DEFERRED to StoicSyntax sweep**

~~#33M **[DPOF]** The `AHU`/`AUP_OrtoFungible*` admin-migration path authorizes via a hardcoded obfuscated
account literal instead of `GOV|DPOF_ADMIN` — a systemic repo-wide pattern also independently flagged by
the sibling SWP audit for its own copy.~~ — owner: intentional, a completed one-time DPMF→DPOF
migration utility (same retention logic as DPMF/#1C); documented as historical, not fixed. See
`ROUND-02-FIXES.md` Fix #27. — *M9* **NOT A BUG ✅ — closed, documented**

~~#34M **[Talos Admin]** Two dead capabilities in `01_TS01-A.pact`, one of which (`P|GOVERNING-SUMMONER`) is
the sole path to a governor slot registered on DALOS's own vault — that registered path can never actually
be satisfied by anything in the codebase.~~ — owner: not forgotten, if it were needed it would already be
used; deferred to the post-redeploy red-team pass to empirically confirm whether it's actually needed.
See `README.md` Downstream plan phase 6. — *M10* **DEFERRED to red-team pass**

~~#35M **[Talos C1]** `DPOF|C_TogglePause`/`C_ToggleFreezeAccount` bind a dead, never-called `ref-TS01-A`
reference (copy-paste leftover) and skip the mandated `format` result message.~~ — confirmed both parts
live; fixed by removing the dead binding and mirroring the correct DPTF sibling's message pattern.
See `ROUND-02-FIXES.md` Fix #28. — *M11* **FIXED ✅ AND VERIFIED ✅**

~~#36M **[DPMF]** Stale duplicate Elite-Auryn accounting logic, missing the 6th (hibernation-linked) term the
live `ELITE.pact` version adds — currently moot since DPMF is entirely unreachable (#1C), but a landmine if
DPMF is ever repaired without resyncing this fork.~~ — owner: DPMF is permanently out of scope, never to
be upgraded again — no landmine risk since it will never be touched. No code change. — *M12* **NOT A
BUG ✅ — closed, out of scope**

~~#37M **[DPMF]** A malformed `format` call (missing substitution-list arg) in `DPMF|C>UPDATE-SPECIAL`
produces a confusing internal error instead of the intended validation message — the sole caller is itself
dead code.~~ — same as #36M, DPMF permanently out of scope. No code change. — *M13* **NOT A BUG ✅ —
closed, out of scope**

~~#38M **[BRD/ELITE]** Elite-tier update functions run on essentially every transfer but are never asserted
(print-only); BRD's own admin path (`A_Live`/`A_SetFlag`) has zero exercise anywhere, commented or not.~~ —
test-coverage-only. Deferred to the main-branch REPL test-infrastructure phase (see #21H/H16). —
*M14* **DEFERRED to REPL test-infrastructure phase**

~~#39M **[INFO-ONE]** `DPTF|INFO_ClearDispo` carries a raw enforce, is undeclared in the interface, and has
zero callers.~~ — INFO-function-family finding. Deferred to the main-branch INFO-function coverage
project (see #16H/H11). — *M15* **DEFERRED to INFO-function coverage project**

~~#40M **[INFO-ONE]** Six `LIQUID|INFO_*`/`ORBR|INFO_*` functions are implemented but undeclared in the
interface and have zero callers anywhere.~~ — same bucket as #39M. — *M16* **DEFERRED to
INFO-function coverage project**

~~#41M **[INFO-ONE]** Near-total absence of test coverage (essentially none of 93 functions have an asserted
return value anywhere) is the root enabler of #15H/#16H/#5C above.~~ — test-coverage-only, same
bucket as #38M. — *M17* **DEFERRED to REPL test-infrastructure phase**

~~#42M **[U_RS]** `UEV_EnforceReserved` over-blocks legitimate non-Kadena-principal account names via an
overly broad single-char-plus-colon reserved-prefix check — empirically reproduced.~~ — resolved: this
is a verbatim port of Kadena's own official `coin.pact` `enforce-reserved`/`check-reserved` (identical
logic + doc wording), which real coin functions use to prevent an account impersonating a reserved
principal type with a mismatched guard. Not a bug — intended upstream behavior; zero callers in this
codebase, left as-is. No code change. — *M18* **NOT A BUG ✅ — closed**

~~#43M **[U_LST/U_VST]** Several `UC_*` functions perform `enforce`, violating the documented pure-compute
contract — the root-cause module for a pattern the sibling SWP/AQP audits already flagged in downstream
callers.~~ — naming/prefix-convention violation (its own write-up recommends "rename to `UEV_*`/`URC_*`
or a repo-wide CONVENTION verdict" — exactly StoicSyntax-sweep-shaped, module-wide, not a one-off).
Deferred per 2026-08-28 batch. — *M19* **DEFERRED to StoicSyntax sweep**

~~#44M **[U_LST]** `UC_IzUnique` can never return `false` (aborts via enforce instead) — its own inline
comment is misleading, and any caller branching on a `false` result has dead code.~~ — no live
functional bug (zero callers branch on a false result), but a real doc-contract-mismatch risk for
future callers; owner: "So fix it boss" — fixed standalone, not batched into #43M. Renamed
`UC_IzUnique` → `UEV_IzUnique` everywhere (definition, interface, all 6 callers incl. Stage 2's
`DPDC-T.pact`), doc corrected to state the true contract. See `ROUND-02-FIXES.md` Fix #29. — *M20*
**FIXED ✅ AND VERIFIED ✅**

~~#45M **[U_INT]** `UC_MaxInteger` crashes uncatchably on an empty list; some sibling-scope callers guard
against this, others don't.~~ — confirmed live: raw array-bounds crash, not even `try`-catchable;
`DPDC-S` (Stage 2, separate audit scope) reaches it unguarded through a real client entrypoint.
Fixed: renamed `UC_MaxInteger` → `UEV_MaxInteger` (same shape as #44M), added a real `enforce` for
non-empty input — no safe benign default exists here unlike #20H/Fix #18's HybridArray case. See
`ROUND-02-FIXES.md` Fix #30. — *M21* **FIXED ✅ AND PROVEN ✅**

~~#46M **[U_INT]** `UEV_ContainsAll` checks set membership rather than multiset containment despite its name
and its sole (historical) consumer's apparent expectation.~~ — confirmed live
(`UEV_ContainsAll [1 1] [1]` => `true`, a true multiset check would say `false`). Sole live caller is
`DPMF|S>MULTI-BATCH-TRANSFER`'s nonce-ownership check — permanently out of scope per the owner's
#36M/#37M ruling ("Dpmf is no longer in scope... we will not be upgrading that module any more").
No code change. — *M22* **NOT A BUG ✅ — closed, out of scope**

~~#47M **[CODEX/PYTHIA]** Zero `expect-failure` assertions anywhere in either module's REPL suite — every
authorization gate is exercised only on the happy path.~~ — test-coverage-only, deferred to the
REPL test-infrastructure phase (see #21H/H16). — *M23* **DEFERRED to REPL test-infrastructure phase**

~~#48M **[CODEX/PYTHIA]** Both suites are commented out of the default REPL pipeline (both pass cleanly
standalone).~~ — same bucket as #47M. — *M24* **DEFERRED to REPL test-infrastructure phase**

~~#49M **[PYTHIA]** The flush-gas-probe REPL is broken and cannot complete a run — its batch sizes predate
and now exceed the module's own `MAX-FLUSH-BATCH` cap. Orphaned, not silently failing CI.~~ — broken
test artifact, same bucket as #47M. — *M25* **DEFERRED to REPL test-infrastructure phase**

~~#50M **[Docs]** `INTERFACE_VERSIONING.md` doesn't document the "additive/opt-in" dual-implementation
pattern the codebase already relies on in at least three places — risk of a future rehaul "fixing" correct,
intentional dual-implementations.~~ — interface-versioning documentation gap, directly tied to the
StoicSyntax/version-bump sweep itself (the natural moment to correct this doc). Deferred per
2026-08-28 batch. — *M26* **DEFERRED to StoicSyntax sweep**

~~#51M **[Docs]** `MODULE-INDEX.md`'s "latest: X" label for the two interface-pack files points at
explicitly-frozen, never-deployed interfaces rather than the true current ones, which live beside their
owning modules.~~ — same bucket as #50M, doc-clarity only, tied to interface versioning. Deferred per
2026-08-28 batch. — *M27* **DEFERRED to StoicSyntax sweep**

## N — discovered during fix/verification work (ranked as CRITICAL-equivalent by impact)

~~#N1~~ **[DPOF]** ~~`C_Transmit` was completely non-functional for every caller, on every input~~ —
**FIXED ✅ AND PROVEN ✅** (owner, 2026-08-23): a field-name typo (`"meta-data"` vs. the schema's real
`"meta-data-array"`) in `DPOF|C>TRANSMIT`'s defcap made every call crash unconditionally, unrelated to
duplicated nonces. Discovered live while building #3C's REPL proof. Fixed (one-string change), proven
broken pre-fix and working post-fix via a dedicated ordinary-input REPL harness, full `Z.repl` regression
clean. See `ROUND-02-FIXES.md` Fix #2. — *N1*

~~#N2 **[TFT/DPOF (Talos)]** `TS01-C1::DPTF|C_DeployAccount`/`DPOF|C_DeployAccount` are ungated public
entrypoints (only a global-pause bare-true cap chain) — any signer can force any existing account to
associate with any token id, a persistent non-consensual junk-record griefing surface.~~ Surfaced via
handoff from the sibling DPDC audit's identical #35M. Owner confirmed the intended fix: gate
`C_DeployAccount` by target-account ownership (self-service only), and add a separate admin-gated
`A_DeployAccount` (TS01-A) for legitimate system-account setup (DemiPad's `lpad`, CADUCEUS's
`bridge-account`, and Stage-1's own `ats`/`liquid`/`swp`/`standard-dispenser` genesis flows, all
redirected). See `ROUND-02-FIXES.md` Fix #11. — *N2* **FIXED ✅ AND PROVEN ✅**

~~#N3 **[TS01-A]** `DPTF|A_UpdateTreasuryDispoParameters`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial`
are gated only by bare-true `P|TS` — every sibling admin function in the same file uses the real
admin-keyset-checking `P|ADMINISTRATIVE-SUMMONER` instead.~~ — **NOT A BUG**: core-layer
`A_UpdateTreasury`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial` independently compose
`GOV|DPTF_ADMIN`, a real keyset/account-guard check, unlike #N2's `C_DeployAccount`. Live-confirmed
an unauthenticated signer is rejected. Same shape as #6H. No code change. — *N3* **REFUTED ✅**

## LOW

~~#52L **[DALOS]** `URD_AccountCounter` — dead code, mis-sectioned ahead of the `UR_*` blocks.~~ —
confirmed undeclared in any interface, zero internal callers, same shape as the INFO-function-family
bucket (#39M/#40M/M15/M16/#67L). Deferred alongside those. — *Cluster 1* **DEFERRED to
INFO-function coverage project**
~~#53L **[DALOS]** `A_UpdateUsagePrice` has no bound check on `new-price` (contributing cause of #8H).~~ —
confirmed live; fixed with a purely additive `(enforce (> new-price 0.0) ...)` — defense-in-depth
for an already-fully-trusted admin. See `ROUND-02-FIXES.md` Fix #31. — *Cluster 1* **FIXED ✅ AND
VERIFIED ✅**
~~#54L **[DALOS]** Self-referential `ref-DALOS::` call from inside DALOS itself; narrow-blast-radius hardcoded-account migration tool noted alongside it.~~ —
same exact shape as #33M/M9's DPOF `AHU`/`AUP_*` finding, already ruled on by the owner as
intentional/historical; same verdict applied here. No code change. — *Cluster 1* **NOT A BUG ✅ —
closed, documented**
~~#55L **[DALOS/IGNIS]** REPL coverage — `[6.1]_Cumulator.repl` has zero assertions and never invokes `C_Collect`; `[6.4]_Admin.repl` comments out `C_RotateKadena` (the function containing #25M); both excluded from the default pipeline.~~ — deferred to the REPL test-infrastructure phase (#21H/H16). — *Cluster 1* **DEFERRED to REPL test-infrastructure phase**
~~#56L **[ELITE]** Two vestigial boilerplate items copied from the module sample template, never referenced.~~ —
confirmed zero references anywhere (incl. cross-module); removed (`GOV|ELITE_ADMIN-CALLER`,
`GOV|CollectiblesKey`). See `ROUND-02-FIXES.md` Fix #31. — *Cluster 2* **FIXED ✅ AND VERIFIED ✅**
~~#57L **[Talos/REPL]** Stale "DPMF" naming left over from the DPMF→DPOF rename in Talos `@doc`s and REPL labels, obscuring that DPMF's real surface has zero coverage.~~ — naming-convention drift, deferred per 2026-08-28 batch. — *Cluster 2* **DEFERRED to StoicSyntax sweep**
~~#58L **[TFT]** Dead binding in `C_ClearDispo`.~~ — confirmed dead (`account-ea-supply`, never
referenced); removed. See `ROUND-02-FIXES.md` Fix #31. — *Cluster 3* **FIXED ✅ AND VERIFIED ✅**
~~#59L **[DPTF/TFT]** REPL coverage gaps — no zero-amount-leg test for #10H, no pre-frozen-EA test for #28M, no direct-bypass test for #9H.~~ — deferred to the REPL test-infrastructure phase. — *Cluster 3* **DEFERRED to REPL test-infrastructure phase**
~~#60L **[DPOF]** REPL coverage — DPOF's own dedicated REPL has zero `expect`/`expect-failure` forms at all and is excluded from the default pipeline.~~ — deferred to the REPL test-infrastructure phase. — *Cluster 4* **DEFERRED to REPL test-infrastructure phase**
~~#61L **[OUROBOROS]** Dead/unused bindings in `URC_Compress`/`C_Compress`.~~ — `URC_Compress`'s own
bindings are all used; confirmed the one real dead binding is `C_Compress`'s `total-ouro`; removed.
See `ROUND-02-FIXES.md` Fix #31. — *Cluster 5* **FIXED ✅ AND VERIFIED ✅**
~~#62L **[LIQUID]** `UEV_Amount` defined but never called.~~ — confirmed zero callers; ambiguous
whether `DPTF::C_Mint`/`TFT::C_Transfer` (LIQUID's actual downstream calls) already cover the same
precision check internally — same shape as #34M/M10, deferred to the same red-team pass rather than
guessed at. No code change. — *Cluster 5* **DEFERRED to red-team pass**
~~#63L **[LIQUID]** Native KDA `install-capability` for unwrap payouts supplied externally by off-chain "JavaCode," untestable in Pact REPL.~~ —
architectural/testability limitation, not a logic bug; documented, no fix applicable within
Pact/REPL. — *Cluster 5* **NOT A BUG ✅ — closed, documented limitation**
~~#64L **[VST/LIQUID/OUROBOROS]** Broad REPL coverage gaps across almost every function family in this cluster.~~ — deferred to the REPL test-infrastructure phase. — *Cluster 5* **DEFERRED to REPL test-infrastructure phase**
~~#65L **[INFO-ONE]** `UC_LpFuelToLpStrings` (a `UC_`-prefixed function) contains a raw `enforce`.~~ —
same prefix-convention shape as #43M, deferred per 2026-08-28 batch. — *Cluster 6* **DEFERRED to
StoicSyntax sweep**
~~#66L **[INFO-ONE]** `UCX_*`/`UCXX_*` naming is pre-migration spelling, not true auxiliaries (convention).~~ —
deferred per 2026-08-28 batch. — *Cluster 6* **DEFERRED to StoicSyntax sweep**
~~#67L **[INFO-ONE]** `VST|INFO-HibernatedNonce(s)Display` use a hyphen instead of the file's `INFO_` convention, undeclared, zero callers.~~ — INFO-function-family finding, deferred to the INFO-function coverage project (#16H/H11). — *Cluster 6* **DEFERRED to INFO-function coverage project**
~~#68L **[PYTHIA]** Dead constant `PYTHIA|FLUSH-GAS-TARGET`.~~ — confirmed zero references
anywhere; removed. See `ROUND-02-FIXES.md` Fix #31. — *Cluster 7* **FIXED ✅ AND VERIFIED ✅**
~~#69L **[CODEX]** `UR_AWT|ListByCodex` scans but is named `UR_`, should be `URD_`/`URDC_`.~~ — deferred
per 2026-08-28 batch. — *Cluster 7* **DEFERRED to StoicSyntax sweep**
~~#70L **[CODEX]** `defcap` body-order deviations (compose-capability before local enforce) across four event caps.~~ —
style-only, deferred per 2026-08-28 batch. — *Cluster 7* **DEFERRED to StoicSyntax sweep**
~~#71L **[PYTHIA]** Two price-setters acquire `SECURE` inline instead of via a named event cap.~~ —
deferred per 2026-08-28 batch. — *Cluster 7* **DEFERRED to StoicSyntax sweep**
~~#72L **[PYTHIA]** Stale header comment on `[6.10b]_PYTHIA-ledger-v2.repl`.~~ — confirmed stale
("TX007" vs. the sibling file's real last tx, TX008); corrected. Doc-only. See
`ROUND-02-FIXES.md` Fix #31. — *Cluster 7* **FIXED ✅**
~~#73L **[U_CT]** Tautological `or` in `CT_DPTF-FeeLock`.~~ — confirmed tautological (`(NS_TEST)` is
itself `"free"`); simplified, zero behavior change. See `ROUND-02-FIXES.md` Fix #31. — *Cluster 8*
**FIXED ✅ AND VERIFIED ✅**
~~#74L **[U_VST]** Typos in enforce messages ("to small," "succesfully").~~ — fixed the isolated "to
small" → "too small" typo; **left "succesfully" alone** — confirmed it's the codebase's own
consistent 119-occurrence repo-wide spelling convention, not a typo. See `ROUND-02-FIXES.md`
Fix #31. — *Cluster 8* **FIXED ✅ (partial, by design — see write-up)**
~~#75L **[U_LST]** `UEV_StringPresence`'s `[bar]`-sentinel doesn't cover a real empty list.~~ —
confirmed live: both cases already aborted the transaction (no functional bug), just an
inconsistent message for a real `[]`; fixed so both give the specific message. See
`ROUND-02-FIXES.md` Fix #31. — *Cluster 8* **FIXED ✅ AND VERIFIED ✅**
~~#76L **[U_INT]** Self-referential module-ref call style in `UC_NonceSplitter`.~~ — style only, deferred
per 2026-08-28 batch. — *Cluster 8* **DEFERRED to StoicSyntax sweep**
~~#77L **[U_CT]** `UR|KDA-PID` section-placement mismatch (labeled `[URC]`, is a hardcoded literal).~~ —
section-placement/convention only, deferred per 2026-08-28 batch. — *Cluster 8* **DEFERRED to
StoicSyntax sweep**
~~#78L **[U_LST]** Harmless off-by-one in `UC_Search`'s `enumerate` usage.~~ — already confirmed harmless;
also, `U|LST::UC_Search` itself must never be touched (owner's explicit instruction, see the IGNIS
Compress/Prime optimization writeup) — deferred per 2026-08-28 batch, revisit only as part of a full
StoicSyntax pass if ever. — *Cluster 8* **DEFERRED to StoicSyntax sweep**
~~#79L **[Utilities]** REPL coverage — `[1]_Utilities.repl` has zero assertions for any of the 8 in-scope modules.~~ — deferred to the REPL test-infrastructure phase. — *Cluster 8* **DEFERRED to REPL test-infrastructure phase**
~~#80L **[Talos]** Naming drift between Talos wrapper names and their core-module counterparts.~~ —
exact same shape as #32M/M8, deferred per 2026-08-28 batch. — *Cluster 9* **DEFERRED to StoicSyntax
sweep**
~~#81L **[BRD]** Misnamed admin keyset constant `GOV|MD_DPTF` inside `04_BRD.pact`.~~ — naming only,
deferred per 2026-08-28 batch. — *Cluster 9* **DEFERRED to StoicSyntax sweep**
~~#82L **[Talos C1]** ~12 client wrappers across DPTF/DPOF sections end without the CLAUDE.md-mandated `format` result string.~~ —
systemic convention gap, deferred per 2026-08-28 batch. — *Cluster 9* **DEFERRED to StoicSyntax
sweep**
~~#83L **[Interfaces]** Dead/orphaned frozen interfaces, all correctly sanctioned by the historical-interfaces policy — no action needed.~~ — the Round-I write-up already confirmed this is sanctioned by
policy; formally closed 2026-08-28, no code change. — *Cluster 10* **NOT A BUG ✅ — closed**
~~#84L **[Interfaces]** Inconsistent "Frozen —" `@doc` labeling among a few historical interfaces.~~ —
doc-labeling only, deferred per 2026-08-28 batch. — *Cluster 10* **DEFERRED to StoicSyntax sweep**
~~#85L **[Interfaces]** `[0.1]_Interfaces.repl` confirmed to be a load+gas smoke test by design, not a coverage gap.~~ — the Round-I write-up already confirmed this is by design; formally closed
2026-08-28, no code change. — *Cluster 10* **NOT A BUG ✅ — closed**
