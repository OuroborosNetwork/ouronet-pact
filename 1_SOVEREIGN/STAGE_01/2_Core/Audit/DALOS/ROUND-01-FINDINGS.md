# ROUND I — Findings (DALOS-audit modules: the rest of Stage 1)

**Date:** 2026-08-23 · **Status:** frozen (append-only). Owner verdicts recorded inline as they arrive, per
the HARD RULE in `README.md`.

**Scope:** the 10 clusters enumerated in `README.md`'s scope table — everything in Stage 1 except the
ATS/ATSU family and the SWPT-through-MTX-SWP family, which are owned by the sibling `ATS/`/`SWP/` audits.
Ten independent deep-read lens agents ran in parallel, each briefed with the same rigor/format contract as
the ATS and SWP audits: load `StoicSyntax.md` first, work read-only, assume nothing is correct despite
being live/near-live, trace every public entrypoint, and tag each finding **CONFIRMED** (code path traced
end-to-end, and where possible empirically reproduced against the repo's pinned Pact 5.4 binary or a live
`describe-module` cross-check) or **PLAUSIBLE** (strong evidence from reading, not yet reproduced).

**Cross-cluster note on tooling:** several lenses had `pact` available in their sandbox and empirically
reproduced findings live (Clusters 2, 3, 7, 8, 10 all ran real REPL/`describe-module` checks); Clusters 1,
4, 5 reported no `pact` binary in their environment and rely on deterministic code-trace reasoning only
(Pact's read-after-write / enforce-arity / fold semantics are unambiguous enough that this is still
reliable, but live re-confirmation is recommended before the fix round for anything tagged PLAUSIBLE from
those three clusters).

**Cross-corroboration:** two findings below were independently discovered by two different lenses working
on different clusters, converging on the same root cause from different angles — this is treated as
stronger evidence, not double-counted (same pattern the ATS/SWP audits used): **H9** (VST/U_VST negative
`duration`/`offset`, found by both Cluster 5 and Cluster 8) and **H13** (`milestones=1` drops `offset`,
found by both Cluster 5 and Cluster 8, rated MEDIUM by one and HIGH by the other — ranked at the higher
severity pending owner review).

---

# CRITICAL

## C1 · DPMF — the entire module is non-functional: no `(create-table ...)` calls anywhere in the file [Cluster 2 · CONFIRMED, empirically reproduced]

**Location:** `1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact` — the file ends at line 2205 with just the
module's closing `)`. There is no trailing `(create-table P|T)` / `(create-table P|MT)` /
`(create-table DPMF|PropertiesTable)` / `(create-table DPMF|BalanceTable)` /
`(create-table DPMF|RoleTable)` block. Every sibling module has this boilerplate (`04_BRD.pact:375-377`,
`07_ELITE.pact:253-254`). `grep -n "create-table" 00_DPMF.pact` returns zero matches.

The module compiles and loads cleanly (all typechecks pass), so genesis shows "Load successful" with no
visible error — but since none of DPMF's five tables are ever created in the backing store, **every
function that touches any DPMF table fails at first use** with a database-level `Table ... not found`
error. This includes `UEV_IMC` itself (reads `P|MT`), the mandatory first statement of every
`C_*`/`XE_*`/`XB_*` entrypoint — so the entire module is unreachable, including its own reads.

Empirically reproduced: a scratch REPL loading the real genesis chain right after DPMF's own deploy tx and
calling `(DPMF.P|UR_IMP)` fails with `Table ouronet-ns.DPMF_P|MT not found`, while the identical call
against `DALOS`/`BRD`/`DPTF`/`ELITE` succeeds. A minimal isolated repro confirmed Pact 5.4's message for a
missing **row** reads differently ("No value found in table...") — this is unambiguously a missing
**table**.

DPMF is deployed on-chain (consumes real deploy gas) and is registered as a trusted IMP peer on
DALOS/BRD/DPTF (`P|A_Define`, `00_DPMF.pact:201-213`), yet cannot execute a single one of its own
functions. It is also confirmed outside the blessed Talos path (zero `DPMF|C_*`/`DPMF|A_*` wiring anywhere
in `3_Talos/`). This was invisible to the whole-pipeline "Load successful" signal because no REPL file
ever exercises DPMF's own tables — `[6.5]_DPOF.repl`'s "Issue DPMF Test"/"STEP 002 DPMF Tests" labels are
stale copy-paste; every call in that file targets `DPOF|C_*`, not DPMF (see L-item in Cluster 2 below).
This also means DPMF cannot serve its stated historical/migration purpose (CLAUDE.md: "kept for
historical/migration context") — there is currently no way to even read legacy DPMF balances through this
deployed instance.

**Fix direction (owner decision):** either add the missing `create-table` block mirroring BRD/ELITE, or —
given confirmed zero live callers and zero Talos wiring — formally retire DPMF instead of repairing it.

---

## C2 · DPOF — `C_MoveCreateRole` never actually revokes the create/mint role from the previous holder [Cluster 4 · CONFIRMED, code trace]

**Location:** `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact:1894-1913` (`C_MoveCreateRole`) calls, in order,
`(XI_UpdateVerum4 id receiver)` (line 1906, updates `DPOF|T|VerumRoles.r-oft-create` to the new
`receiver`) **then** `(XI_SwitchCreateRole id receiver)` (line 1908). `XI_SwitchCreateRole` (`:2617-2625`)
re-derives "the old holder" via `(UR_Verum4 id)` — but because `XI_UpdateVerum4` already ran, this now
resolves to `receiver`, not the actual previous holder. Both `update`s in `XI_SwitchCreateRole` therefore
hit the **same** (`receiver`) row — set false, then immediately true (a no-op) — and the **real previous
holder's `role-oft-create` flag is never cleared**. The correct "old holder" value was already computed
correctly inside the master defcap (`DPOF|S>X_SWITCH-CREATE-ROLE:443`, evaluated *before* any writes) but
is never threaded through to `XI_SwitchCreateRole`, which re-derives it, incorrectly, from post-mutation
state.

`UR_R-Create` (`:1190-1209`) is a fold-`or` over `{per-account flag, account==owner-konto, autonomic
override}`, so every past holder of the create role keeps mint access (`C_Mint`'s `UEV_AccountCreateState`
check, `:1554-1561`) forever, even after the DPOF owner believes they revoked it via `C_MoveCreateRole`.
This is a real, sequential-write-order bug — deterministic Pact read-after-write semantics make it
unambiguous even without a live REPL repro.

---

## C3 · DPOF — missing nonce-uniqueness validation on batch nonce operations enables both fabricated account-supply and negative nonce-supply corruption [Cluster 4 · CONFIRMED, code trace]

**Location:** none of `DPOF|C>TRANSFER` (`:758-770`), `DPOF|C>BULK-TRANSFER` (`:771-798`), or
`DPOF|C>DEBIT` (`:634-674`) validate that the caller-supplied `nonces:[integer]` list contains no
duplicates — contrast `DPOF|S>BULK-MOVE` (`:495-524`), which *does* call `(ref-U|LST::UC_IzUnique
receiver-lst)`, showing the uniqueness pattern is known and used elsewhere in this same file, just
omitted for nonce lists.

**(a) Whole-nonce transfer inflation:** `XI_TransferWholeNonces` (`:2135-2157`, shared by
`C_Transfer`/`C_BulkTransfer`) sums `nonces-supplies` over the (possibly duplicated) `nonces` list and
applies the sum once to `sender`/`receiver` `total-account-supply`, but only calls `XI_UpdateNonceHolder`
(idempotent) per nonce. Calling `C_Transfer id [N N] sender receiver method` for an owned, circulating
nonce `N` moves nonce `N` once but debits/credits `total-account-supply` by **2×** `N`'s value — with no
cap on repetition, this is unbounded self-service inflation/deflation of a DPOF `total-account-supply`,
achievable by any nonce holder. `07_ELITE.pact:162,168,174` consumes this exact field directly for
Elite-tier eligibility, making this a real privilege/economic-value fabrication vector.

**(b) Negative nonce-supply corruption via Debit:** `DPOF|C>DEBIT`'s validation loop checks, per index,
`amount <= nonce-supply` against **pre-write** state; if the same nonce is repeated with amounts that
individually satisfy the check but cumulatively exceed it, both checks pass, and `XI_DebitNonces`
(`:2339-2376`) — re-reading `nonce-supply` per iteration with no floor check — can drive the nonce's
`supply` field **negative**, directly violating the code's own enforce message "Cannot Debit into the
Negatives." `C_Transmit` (wipe-mode `false`, gated only by ordinary account ownership — not the DPOF
owner) reaches this path with fully caller-supplied `nonces`/`amounts`, making this the broadest-reach
manifestation.

Both (a) and (b) share one root cause: no per-batch nonce-uniqueness/accumulation check.

---

## C4 · VST — `C_Unreserve` requires the DPTF *issuer's* signature, not the reserver's — reserved funds are permanently stuck for anyone who isn't the token's own Konto owner [Cluster 5 · CONFIRMED, code trace]

**Location:** `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact:253-266` (`VST|C>UNRESERVE`), contrasted with
`:239-252` (`VST|C>RESERVE`, no ownership check at all) and every other release-side cap in the module
(Cull, Unsleep, Awake — none compose `CAP_Owner`). `VST|C>RESERVE` lets any DPTF holder self-serve-lock
their own tokens (no `CAP_Owner`). But `VST|C>UNRESERVE` adds `(ref-DPTF::CAP_Owner dptf)` where `dptf` is
the **original base token**, not the reserved-representation token the caller actually holds — i.e. it
enforces that the signer controls the *token issuer's* Konto account, not the account that holds the
reserved balance being released.

**Failure scenario:** Alice (not the token's issuer) reserves 100 of her own `VST-xyz` via `C_Reserve`
(legitimate, no gate). She later calls `C_Unreserve` to get it back — this **always fails** unless the
project team (the DPTF issuer) co-signs the exact same transaction, which is not part of any documented
flow and has no admin escape hatch (`C_RepurposeReserved` requires the same issuer-gate). Her 100
`VST-xyz` are permanently locked with no self-serve recovery. Every sibling lock type (Vest/Unvest,
Sleep/Unsleep, Hibernate/Awake) is symmetric self-serve — Reserve/Unreserve is the sole asymmetric pair,
and Reserve's own missing ownership check proves the intended design was self-serve. Reads as a
copy-paste artifact from the `CAP_Owner`-gated caps into `UNRESERVE` by mistake. REPL coverage: zero —
`C_Reserve`/`C_Unreserve` are never called anywhere in the repo's REPL suite.

---

## C5 · INFO-ONE — `DPOF|INFO_UpgradeBranding` calls a nonexistent function, a doubled-prefix typo [Cluster 6 · CONFIRMED defect / PLAUSIBLE blast radius]

**Location:** `1_SOVEREIGN/STAGE_01/2_Core/21_INFO-ONE+.pact:1328` —
`(ref-I|OURONET::OI|OI|UDC_DynamicKadenaCost patron ...)`. `ref-I|OURONET` is typed
`module{OuronetInfoV1}`; that interface declares `OI|UDC_DynamicKadenaCost` (single prefix) — there is no
`OI|OI|UDC_DynamicKadenaCost` member. Every other ~40 call site in this file uses the correct single-prefix
name (e.g. `DPTF|INFO_UpgradeBranding:667` calls it correctly). Calling `DPOF|INFO_UpgradeBranding` will
fail — either at module-load/typecheck time or at call time.

**Context that narrows current real-world impact (does not change the defect):** INFO-ONE has **zero**
callers anywhere in the codebase except one discarded, never-asserted call in `[6.6]_ATS.repl:154` to a
*different* function (`ATS|INFO_Coil`) — no Talos module wires any `INFO-ONE::` call at all. This function
is broken exactly because nothing has ever exercised it. It would matter the moment this module is wired
to a real client/UI, which is its documented purpose.

---

# HIGH

## H1 · IGNIS — several DALOS `XE_*` writers have no `SECURE`/named-cap gate at all — only coarse `(UEV_IMC)` [Cluster 1 · CONFIRMED]
`01_DALOS.pact:1353-1394` — `XE_UpdateTreasury`, `XE_IgnisIncrement`, `XE_IncrementOuronetAccountNonce`,
`XE_UpdateElite` go straight from `(UEV_IMC)` to a raw `update`, unlike sibling `XB_UpdateBalance` /
`XE_UpdateFreeze` / etc. in the same file, which correctly add `(with-capability (SECURE) ...)`. Since
essentially every Stage-1 core module registers as a DALOS implementer, **any** already-registered peer
module can call these four functions directly to rewrite treasury parameters, inflate/deflate gas-spent
counters, bump any account's nonce, or alter any account's Elite tier — with zero function-specific
authorization.

## H2 · U_DALOS — `GLYPH|UEV_MsDc` uses an OR/false-seeded fold instead of AND/true-seeded — charset validation is nearly a no-op [Cluster 1 · CONFIRMED]
`1_Utilities/08_U_DALOS.pact:368-388` — the fold starts at `false`/`or`, so it returns `true` as soon as
**any single character** is in-charset, instead of requiring **every** character to be (the doc's stated
intent, and the pattern used correctly two functions below it, `UC_IzStoicTagName`). Backs
`GLYPH|UEV_DalosAccount` (gates every account-deployment address format) and Codex/Pythia's
`GLYPH|UEV_ApolloAccount(Check)`. Almost any string will contain at least one in-charset character, so the
"every character must conform" invariant is effectively defeated.

## H3 · IGNIS — `C_Collect` unconditionally processes every primed leg, but a zero/negative-priced leg hard-aborts the whole bundled transaction [Cluster 1 · PLAUSIBLE, not empirically reproduced (no `pact` binary in that lens's environment)]
`02_IGNIS.pact:605-658` loops over every primed `(interactor, amount)` pair unconditionally;
`IGNIS|C>TRANSFER` (`:168-174`) hard-enforces `amount > 0.0`. `01_DALOS.pact:1135-1148`
(`A_UpdateUsagePrice`) has no lower-bound check, so an admin can legitimately set any action's price to
`0.0`. If a bundled multi-leg `OutputCumulator` chain includes a zero-priced leg alongside a different,
nonzero-priced leg addressed to a different interactor, the whole transaction reverts — denying an
otherwise-valid multi-leg client operation.

## H4 · DPTF — three of five "Toggle Verum" client recipes silently drop `(UEV_IMC)`, bypassing Talos-only path, Global Administrative Pause, and IGNIS fee collection [Cluster 3 · CONFIRMED]
`05_DPTF.pact:1895,1917,1940` — `C_ToggleBurnRole`, `C_ToggleMintRole`, `C_ToggleFeeExemptionRole` are
missing the `(UEV_IMC)` call every other `C_*` in the file has first, unlike sibling
`C_ToggleFreezeAccount`/`C_ToggleTransferRole` which get it right. `UR_GAP` (Global Administrative Pause)
is never checked inside DPTF/TFT at all — it's only checked in the Talos wrapper. The DPTF token owner can
call these three directly (bypassing Talos, GAP, and IGNIS billing) since their own defcap validation is
satisfied purely from home-module checks.

## H5 · TFT — a single zero-amount leg aborts the entire `C_MultiTransfer` / `C_MultiBulkTransfer` batch [Cluster 3 · CONFIRMED — same bug class as ATS audit's N2]
`09_TFT.pact:1336-1474`, root cause `05_DPTF.pact:742-789`'s `UEV_Amount` unconditionally enforcing
`amount > 0.0` on every leg. A single `0.0` entry (client bug, stale UI row, or a legitimately-derived
`0.0` fee remainder from `XI_ComplexCredit`'s fee split) reverts the entire batch, including all other
valid legs.

## H6 · TFT — `C_MultiBulkTransfer` never refreshes the sender's Elite-Tier account, unlike `C_Transfer`/`C_MultiTransfer` [Cluster 3 · CONFIRMED]
`09_TFT.pact:1390-1474` updates the **receiver's** Elite tier for elite-classified transfer types but never
calls `XI_DynamicUpdateEliteAccount`/`XI_DirectUpdateEliteAccount` for `sender` — unlike `C_Transfer`/
`C_MultiTransfer`, which correctly update both parties. Leaves the sender's dispo/overdraft bound computed
from a stale (pre-transfer, higher) Elite-Auryn balance.

## H7 · DPOF — `DPOF|C>UPDATE-SPECIAL`'s immutability guard is bypassed for Hibernation links via a duplicated `cond` branch [Cluster 4 · CONFIRMED]
`06_DPOF.pact:799-857` — the `main-special-id` `cond` has `((= vzh-tag 2) (ref-DPTF::UR_Hibernation
main-dptf))` where it should test `(= vzh-tag 3)` (a literal duplicate of the preceding branch). For
Hibernation, `main-special-id` always falls through to `BAR`, so the "immutable!" enforce only checks the
secondary side — letting `main-dptf`'s owner silently re-point an already-set `hibernation-link`,
orphaning the previously-linked DPOF.

## H8 · LIQUID — `C_RegisterOuronetAccountForUrstoaHoldings` has zero ownership check; protection depends entirely on a downstream module's incidental behavior [Cluster 5 · CONFIRMED missing check / PLAUSIBLE exploitability]
`12_LIQUID.pact:366-378` takes an arbitrary `ouronet-account` and caller-supplied `guard` with **no
`CAP_EnforceAccountOwnership`, no cap at all** — not even wrapped in a defcap. The Talos wrapper's own
`@doc` states the guard "must match" the account's Kadena principal, but nothing enforces this in LIQUID or
the wrapper. Currently rescued only by Kadena's own `enforce-reserved` inside the external `ur-coin`
callee, for reserved-principal account names — a peer module's incidental behavior, not LIQUID's own
validation. Zero REPL coverage of this function anywhere.

## H9 · U_VST — `UEV_MilestoneWithTime` has no lower bound on `duration`/`offset`; Sleep/Vest locks can be created with a release date already in the past [Clusters 5 & 8 · CONFIRMED, cross-corroborated by two independent lenses]
`1_Utilities/11_U_VST.pact:143-152` enforces only an **upper** bound on `milestones*duration+offset`;
`duration`/`offset` may be negative. Gates both `C_Sleep` (no `CAP_Owner` — callable by anyone) and
`C_Vest`. A negative `duration` makes `UC_MakeVestingDateList` compute a `release-date` already in the
past, so a "Sleeping"/"Vesting" position is immediately unlockable at mint time — defeating the entire
point of the lock. Empirically reproduced by Cluster 8: `(UC_MakeVestingDateList 0 -500000 3)` returns a
strictly *decreasing* timestamp list, with milestones 2 and 3 already in the past.

## H10 · INFO-ONE — `ATS|INFO_Coil`'s third leg builds its IGNIS cumulator from the wrong token and reversed direction [Cluster 6 · CONFIRMED]
`21_INFO-ONE+.pact:1739-1744` — the transfer-classify call correctly uses `c-rbt`/`ats-sc`/`coiler`, but the
cumulator built from it uses `rt` (the original input token, wrong) with sender/receiver reversed — a
copy-paste of the first leg's line with only the class-index variable updated. Proven a copy-paste bug (not
a design quirk) by comparison with the structurally identical, correctly-implemented leg in
`ATS|INFO_Curl:1874`. Display-only (see C5's framing note on this module's current lack of live callers),
but a silently-wrong quote the moment it's wired to a UI.

## H11 · INFO-ONE — `ATS|INFO_ColdRecovery` binds two locals both named `ifp3` in the same `let`, silently dropping the Transfer-leg cost from the total [Cluster 6 · CONFIRMED]
`21_INFO-ONE+.pact:2041-2058` — the Transfer leg and the Burn leg are both mislabeled "Operation 3" and
both bind a local `ifp3`; Pact's sequential `let` means the second binding shadows the first, so the
Transfer-leg IGNIS estimate is computed then silently discarded from the final total.

## H12 · PYTHIA — `A_UpdateDeployPrice` / `A_UpdateRenamePrice` are wired nowhere and are permanently unreachable, even by the legitimate admin [Cluster 7 · CONFIRMED, empirically reproduced live]
`23_PYTHIA.pact:1288-1305` gate on `(UEV_IMC)` before the admin keyset check, but the only registered PYTHIA
implementer guard is TS01-C4's, and TS01-C4 (`3_Talos/06_TS01-C4.pact`) never wraps either function — grep
confirms zero hits across every historical Talos Client-Four interface version, so this was never wired,
not a regression. Empirically reproduced: a direct call signed with the real Demiurgoi admin key still
fails `UEV_IMC`. `PYTHIA|DEFAULT-DEPLOY-PRICE`/`DEFAULT-RENAME-PRICE` are permanently frozen at their
hardcoded defaults with no on-chain path to change them, for anyone, without a redeploy — same class as
ATS's N3 finding, here confirmed by live execution.

## H13 · U_VST — `UC_MakeVestingDateList` silently drops the caller-supplied `offset` when `milestones = 1` [Clusters 5 & 8 · CONFIRMED, cross-corroborated — Cluster 5 rated MEDIUM, Cluster 8 rated HIGH, ranked at the higher tier pending owner review]
`1_Utilities/11_U_VST.pact:46-73` — for `milestones > 1` the schedule correctly starts at
`present-time + offset`; for `milestones = 1` it returns `present-time + duration`, dropping `offset`
entirely. Empirically reproduced by Cluster 8: `(UC_MakeVestingDateList 100000 500000 1)` and
`(UC_MakeVestingDateList 0 500000 1)` return the identical result. A `C_Vest` call with `milestones=1` and
a nonzero `offset` (e.g. a cliff before a lump-sum release) releases funds earlier than specified.
`C_Sleep` is unaffected (always calls with `offset=0`).

## H14 · U_CT — `UR|KDA-PID` is a hardcoded stub (`1.0`) wired live into pricing across two stages [Cluster 8 · CONFIRMED call graph]
`1_Utilities/01_U_CT.pact:165-168` — the oracle call is commented out; the function unconditionally returns
`1.0`. Called live from `03_INFO-ZERO.pact`, `16_SWPI.pact` (sibling scope), `3_Talos/04_TS01-C3.pact`
(×12), `3_Talos/05_TS01-P.pact` (×5), and Stage-2 DemiPad modules — the sole KDA/USD price feed for
asymmetric-LP IGNIS taxation and USD-denominated fee math across the protocol. The sibling SWP audit's own
owner-feedback doc reasons about `kda-pid` as if it were a live oracle-priced conversion; that reasoning
currently rests on a frozen constant. Any KDA/USD divergence from parity makes every dependent computation
silently wrong.

## H15 · U_DEC — `UC_AddHybridArray` corrupts or crashes on empty/all-empty-row input [Cluster 8 · CONFIRMED, empirically reproduced]
`1_Utilities/07_U_DEC.pact:57-93` — when all input rows are empty, `maxl=0` and `(enumerate 0 (- maxl 1))`
= `(enumerate 0 -1)`, which Pact's bidirectional `enumerate` returns as `[0 -1]`, not `[]`. Reproduced two
failure modes: `(UC_AddHybridArray [])` returns a bogus `[0.0 0.0]`; `(UC_AddHybridArray [[]])` hard-crashes
with an uncatchable (not `try`-able) array-index-out-of-bounds abort.

## H16 · Talos Admin — roughly half of `TalosStageOne_AdminV1`'s in-scope surface has zero effective REPL exercise, and the dedicated Admin suite asserts nothing [Cluster 9 · CONFIRMED]
`[6.4]_Admin.repl` is commented out of the default pipeline and itself contains zero `expect`/
`expect-failure` calls anywhere. Repo-wide grep confirms several in-scope admin wrappers
(`DALOS|A_MigrateLiquidFunds`, `A_ToggleOAPU`, `A_ToggleGAP`, `LIQUID|A_MigrateLiquidFunds`,
`DPTF|A_WipeTreasuryDebt(Partial)`, `A_UpdateTreasuryDispoParameters`, `ORBR|A_Fuel`) have zero or only
commented-out/non-default-pipeline exercise anywhere in the repo. Manual wiring trace found no live bug in
these specific paths, but this is exactly the coverage shape that let ATS's N3/C3 ship silently.

## H17 · DPOF/TS01-C1 — `DemiourgosPactOrtoFungibleV2` + `TalosStageOne_ClientOneV2` are fully cascaded locally but not yet deployed — redeploy prerequisite [Cluster 10 · CONFIRMED, live diff]
`06_DPOF.pact:214-227` adds `DemiourgosPactOrtoFungibleV2` (`C_BulkTransfer`,
`UEV_EnforceSegmentationForTransmit`); `3_Talos/02_TS01-C1.pact:87-99,1349-1364` correspondingly adds
`TalosStageOne_ClientOneV2` and wires `DPOF|C_BulkTransfer`. Live `describe-module` confirms deployed DPOF
and TS01-C1 are both still on V1 only — the local cascade was done correctly in tandem, it just hasn't
shipped. Both must redeploy together, DPOF first.

## H18 · `OuroborosV1` — live/local `C_SublimateV2` is a real, actively-used public function never added to the interface [Cluster 10 · CONFIRMED, live diff — already live in production]
`13_OUROBOROS.pact:440` defines `C_SublimateV2`, called cross-module from both Talos client-two and
client-three (`03_TS01-C2.pact:1748-1760`, `04_TS01-C3.pact:768`) via a `module{OuroborosV1}`-typed ref —
but `OuroborosV1` (`:5-20`) never declares it. Confirmed via live `describe-module` this is already the
case in production, not just locally. `OuroborosV1` needs a version bump to accurately describe the
module's real public surface.

## H19 · `CodexV1` — four live public `C_` functions are missing from the interface entirely [Cluster 10 · CONFIRMED, live diff — already live in production]
`22_CODEX.pact:7-66` (`CodexV1`) declares no `C_` function at all, but the module defines and
`3_Talos/06_TS01-C4.pact:196-244` actively calls `C_RotateCodexGuard`, `C_RecordArweaveUpload`,
`C_RegisterStoicTag`, `C_ReleaseStoicTag` through a `module{CodexV1}`-typed ref. Confirmed already live in
production via `describe-module`. Same class of gap as H18.

**Cross-cutting methodological note from Cluster 10, relevant to the whole audit program:** because both
H18 and H19 are already live and functioning in production despite incomplete interface member lists, this
is direct empirical proof that Pact's `(ref:module{Iface} X)` + `ref::fn` dispatch on StoaChain does **not**
restrict the callable surface to `Iface`'s declared members — it dispatches by name against the concrete
module; the interface annotation only requires `implements` conformance, not a call-time cap. This bears
directly on the ATS audit's own "separately observed, unverified" concern that `ATSU.X_RemoveSecondary`'s
stale `module{AutostakeV1}` typing might be unable to execute on mainnet — the mechanism in question
empirically does **not** block execution, per two independent live examples here. Recommend the ATS audit
fold this into its closure note. (Cluster 10 separately confirmed the literal string `module{AutostakeV1}`
no longer appears anywhere in current source — that specific concern may already be moot.)

---

# MEDIUM

## M1 · DALOS — `C_RotateKadena` reads the account's Kadena address *after* it has already been overwritten, permanently orphaning the old `DALOS|KadenaLedger` reverse-index entry [Cluster 1 · CONFIRMED]
`01_DALOS.pact:1183-1191,1297-1345` — `XI_RotateKadena` writes the new kadena address first; the very next
line's `(UR_AccountKadena account)` (intended to fetch the *old* address to clean up its ledger row) now
reads the *new* one instead, due to Pact's read-after-write visibility within one execution. The old
address's ledger row is never cleaned up. Mitigated: `UR_KadenaLedger` currently has zero external callers.

## M2 · DALOS — deploy validation lives inside the `XI_*` internal writer, not the `C_*`/`A_*` master cap — inverts the intended defcap/XI split [Cluster 1 · CONFIRMED]
`01_DALOS.pact:559-599,1094-1103,1157-1168,1203-1250` — `C_DeploySmartAccount`/`A_DeploySmartAccount`
(and Standard variants) only acquire a bare `SECURE`/admin cap, then all real validation (guard protocol,
`UEV_Glyph`, account-type, guard-satisfiability) happens inside the "internal-only" `XI_*` tier. Not an
auth bypass (checks still run), but a discoverability/conformance defect against StoicSyntax's defcap/XI
split.

## M3 · DALOS — `GAS_PAYER` gas-station allowlist matches module names by string prefix, not exact identity [Cluster 1 · PLAUSIBLE]
`01_DALOS.pact:199-269` — checks only that exec-code's first N characters match a literal prefix
(`"(ouronet-ns.TS"` etc.), not exact module identity. Bounded by `ouronet-ns` deploy governance, but fragile.

## M4 · TFT — `C_ClearDispo` unconditionally unfreezes the Elite-Auryn account, even if it was frozen for an unrelated reason beforehand [Cluster 3 · CONFIRMED]
`09_TFT.pact:1194-1265` — the freeze-then-unfreeze pair is asymmetric: freeze only happens if not already
frozen, but unfreeze always forces `false` regardless of the pre-existing state.

## M5 · TFT — `dispo-data` snapshot computed once and reused across every leg of a multi-transfer, stale relative to earlier legs in the same batch [Cluster 3 · PLAUSIBLE]
`09_TFT.pact:1345,1398` — the sender's Elite-Auryn snapshot for OURO overdraft bound purposes is taken once
before the fold; an earlier leg in the same batch that reduces Elite-Auryn holdings doesn't refresh the
bound used by a later OURO leg in the same atomic transaction.

## M6 · DPTF — `UR_Hibernation` is a "read" that performs an unguarded table `update` [Cluster 3 · CONFIRMED]
`05_DPTF.pact:974-990` — a `UR_*` function (unprotected, callable by anyone, called extensively as if a
pure getter across ELITE/VST/INFO-ONE/DPOF) performs a live `update` with no capability gate. Idempotent
(backfills a sentinel once), so not directly fund-threatening, but a read/write-separation violation and a
latent hazard if copied elsewhere with a less-idempotent payload.

## M7 · DPOF — `URC_Parent` violates its own prefix contract by calling `enforce` [Cluster 4 · CONFIRMED]
`06_DPOF.pact:1297-1317` — a direct `enforce` inside a `URC_*` function, which per StoicSyntax must not
enforce.

## M8 · DPOF — `C_WipeHeavy` calls a `URDC_*` scan directly from a public `C_` body, unmarked as HEAVY [Cluster 4 · CONFIRMED, convention]
`06_DPOF.pact:2020-2028` — the function's own `@doc` already acknowledges the anti-pattern it exhibits
(using `select`/table-scan helpers "not meant to be used in transactional context") but was never renamed
per the `CC_`/`AA_` HEAVY-prefix convention that exists to flag exactly this.

## M9 · DPOF — `AHU`/`AUP_OrtoFungible(s)`/`AUP_OrtoFungibleAccount(s)` admin-migration path bypasses `GOV|DPOF_ADMIN` via a hardcoded obfuscated account literal [Cluster 4 · CONFIRMED — systemic repo-wide pattern, also flagged independently by the sibling SWP audit for `15_SWP.pact`'s copy]
`06_DPOF.pact:2641-2675` — authorization is "whoever controls this one hardcoded account name" rather than
the module's own keyset band. Identical pattern present across `01_DALOS.pact`, `05_DPTF.pact`,
`08_ATS.pact`, `15_SWP.pact`, and Stage-2 `02_DPDC-S.pact`.

## M10 · TS01-A — two dead capabilities, one of which is a registered-but-unreachable remote-governor slot on DALOS's own vault [Cluster 9 · CONFIRMED]
`01_TS01-A.pact:92-99` — `P|GOVERNING-SUMMONER`/`P|SECURE-SUMMONER` are never composed anywhere.
`P|GOVERNING-SUMMONER` is the only composer of `P|TRG`, whose capability-guard is registered on DALOS's own
policy table as `"TS01-A|RemoteDalosGov"` and actively folded into DALOS's smart-account governor's
guard-of-any list — a registered governor path that can never actually be satisfied. Fails toward "never
usable," not "forgeable."

## M11 · TS01-C1 — `DPOF|C_TogglePause`/`C_ToggleFreezeAccount` bind a dead `ref-TS01-A` module reference and are missing their result message [Cluster 9 · CONFIRMED]
`02_TS01-C1.pact:1056-1070,1090-1104` — bind but never call `ref-TS01-A` (leftover from a copy-pasted
sibling whose fueling call was trimmed but binding wasn't); both also end by returning a raw
`ref-IGNIS::C_Collect` result instead of a `format` string, unlike their DPTF counterparts.

## M12 · DPMF — stale duplicate Elite-Auryn accounting, incomplete relative to the live `ELITE.pact` version [Cluster 2 · CONFIRMED, impact currently moot per C1]
`00_DPMF.pact:913-958,1002-1015,1629-1671` — sums only 5 terms via DPMF's own balance table, missing the
hibernation-linked 6th term ELITE's live version adds via DPOF. Currently unreachable (C1), but relevant if
DPMF is ever repaired without also resyncing this fork.

## M13 · DPMF — broken `format` call in `DPMF|C>UPDATE-SPECIAL` produces the wrong (confusing) error instead of the intended validation message [Cluster 2 · CONFIRMED, empirically reproduced]
`00_DPMF.pact:567-578` — `format` called with a `{}` template but no substitution-list argument; fails with
an opaque internal error instead of the intended message when the enforce condition is false. The sole
caller (`XE_UpdateSpecialMetaFungible`) is itself dead code.

## M14 · BRD/ELITE — mutation paths executed pervasively but never asserted (format/print only) [Cluster 2 · CONFIRMED]
`07_ELITE.pact`'s `XE_UpdateElite`/`XE_UpdateEliteSingle` run constantly via Talos/TFT but are only ever
surfaced via print, never `expect`. `04_BRD.pact`'s admin path (`A_Live`/`A_SetFlag`) has zero exercise
anywhere in the repo, commented or not.

## M15 · INFO-ONE — `DPTF|INFO_ClearDispo` carries a raw `enforce`, is undeclared in the interface, and is fully dead code [Cluster 6 · CONFIRMED]
`21_INFO-ONE+.pact:1240-1301` — prefix-contract violation (enforce inside an `INFO_`-class function) plus
an interface-completeness gap (return type is interface-owned, so it should be declared); zero callers
anywhere.

## M16 · INFO-ONE — `LIQUID|INFO_*` (4 functions) and `ORBR|INFO_*` (2 functions) are defined but never declared in `InfoOneV1`, and have zero callers anywhere [Cluster 6 · CONFIRMED]
`21_INFO-ONE+.pact:2204-2399` — same interface-membership gap as M15, fully dead/orphaned by grep.

## M17 · INFO-ONE — near-total absence of test coverage is the root enabler for H10/H11/C5 above [Cluster 6 · CONFIRMED]
Of 93 `defun`s / 64 interface members, essentially none have their return value asserted anywhere. Directly
why the `OI|OI|` typo, the wrong-cumulator bug, and the duplicate-binding bug could ship unnoticed.

## M18 · U_RS — `UEV_EnforceReserved` over-blocks legitimate non-principal account names [Cluster 8 · CONFIRMED, empirically reproduced]
`1_Utilities/04_U_RS.pact:46-80` — treats any single-character-then-colon prefix as reserved, not just
Kadena's actual principal set; reproduced rejecting a legitimate custom account name.

## M19 · U_LST / U_VST — several `UC_*` functions perform `enforce` (directly or via `UEV_*`), violating the documented `UC_` contract [Cluster 8 · CONFIRMED — root-cause module for a pattern the sibling SWP/AQP audits already flagged in callers]
`1_Utilities/05_U_LST.pact` (`UC_FE`, `UC_LE`, `UC_SecondListElement`, `UC_IzUnique`, `UC_RemoveItemAt`,
`UC_ReplaceAt`) and `11_U_VST.pact` (`UC_SplitBalanceForVesting`). Repeated, module-wide pattern, not an
isolated typo. Recommend rename to `UEV_*`/`URC_*` or a repo-wide CONVENTION verdict.

## M20 · U_LST — `UC_IzUnique` can never return `false`; its own inline comment is misleading [Cluster 8 · CONFIRMED, empirically reproduced]
`05_U_LST.pact:64-85` — a duplicate aborts the transaction via `enforce` rather than returning `false` as
the comment implies; any `(if (UC_IzUnique lst) A B)` caller has a dead `B` branch.

## M21 · U_INT — `UC_MaxInteger` crashes uncatchably on an empty list; inconsistently guarded by callers [Cluster 8 · CONFIRMED crash / PLAUSIBLE caller reachability]
`06_U_INT.pact:43-52` — some callers guard against empty input, several sibling-audit-scope callers don't.

## M22 · U_INT — `UEV_ContainsAll` checks set membership, not multiset containment [Cluster 8 · CONFIRMED semantic gap / PLAUSIBLE impact]
`06_U_INT.pact:98-120` — `(UEV_ContainsAll [1 1] [1])` → `true`; sole live consumer is DPMF (historical).

## M23 · CODEX/PYTHIA — zero `expect-failure` assertions in the two primary REPL suites for this cluster [Cluster 7 · CONFIRMED]
Every ownership/authorization gate (StoicTag, Codex, Cronoton) is exercised only on the happy path — no
non-owner-rejection test anywhere for either module.

## M24 · CODEX/PYTHIA suites are not wired into the default REPL pipeline [Cluster 7 · CONFIRMED]
`Stage01_Tester.repl:64,66` — both `[6.9]_CODEX.repl`/`[6.10]_PYTHIA.repl` commented out; both pass cleanly
standalone.

## M25 · PYTHIA — `[6.10]_PYTHIA-flush-gas-probe.repl` is broken and cannot complete a run against current code [Cluster 7 · CONFIRMED, reproduced live]
Probe batch sizes exceed `PYTHIA|MAX-FLUSH-BATCH=1000`, a cap added after the probe file was written and
never updated in the probe; ~18 of ~48 probe transactions are now permanently dead. Orphaned (not referenced
by any driver), so not silently failing CI, but a broken artifact.

## M26 · `INTERFACE_VERSIONING.md` doesn't document the "additive/opt-in" versioning pattern the codebase already relies on [Cluster 10 · CONFIRMED]
At least three legitimate dual-implementation exceptions exist (`IgnisCollectorV1`+`V2`,
`DemiourgosPactOrtoFungibleV1`+`V2`, `TalosStageOne_ClientOneV1`+`V2`) but the top-level policy doc only
describes the superseding-bump model — risk that a future rehaul "fixes" these correct, intentional
dual-implementations.

## M27 · MODULE-INDEX's "latest: X" label for the interface-pack files is misleading relative to true current state [Cluster 10 · CONFIRMED, doc-clarity only]
The index's "latest" entries for `02_Core.pact`/`03_Talos.pact` are both explicitly `@doc "Frozen — never
deployed"` in source; the true current interfaces live in the owning module files per the documented
convention. Not a functional bug, but misleads a reader relying on MODULE-INDEX alone.

---

# LOW

Grouped by cluster; see each cluster's scratch file (`_scratch-cluster-NN-*.md`, pre-compilation) or the
file:line references below for full detail. All confirmed unless noted.

- **Cluster 1 (DALOS/IGNIS):** `URD_AccountCounter` dead code, mis-sectioned (`01_DALOS.pact:628-632`); `A_UpdateUsagePrice` no bound check on `new-price`, contributing to H3 (`:1135-1148`); self-referential `ref-DALOS::` call from inside DALOS itself, and a narrow-blast-radius hardcoded-account migration tool (`:1487-1496`); REPL coverage gaps — `[6.1]_Cumulator.repl` has zero assertions and never invokes `C_Collect`, `[6.4]_Admin.repl` explicitly comments out `C_RotateKadena` (the exact function containing M1), both excluded from the default pipeline.
- **Cluster 2 (DPMF/BRD/ELITE):** two vestigial boilerplate items copied from the module sample template, never referenced (`07_ELITE.pact:31-34,39-40`); stale "DPMF" naming left over from the DPMF→DPOF rename in Talos `@doc`s and REPL labels, obscuring that DPMF's real surface has zero coverage (`3_Talos/02_TS01-C1.pact:1106,1120,1134`; `[6.5]_DPOF.repl`).
- **Cluster 3 (DPTF/TFT):** dead binding in `C_ClearDispo` (`09_TFT.pact:1209`); REPL coverage gaps — no zero-amount-leg test for H5, no pre-frozen-EA test for M4, no direct-bypass test for H4.
- **Cluster 4 (DPOF):** REPL coverage — DPOF's own dedicated REPL has zero `expect`/`expect-failure` forms at all and is excluded from the default pipeline; none of DPOF's ~45 public entrypoints have regression protection in DPOF's own suite.
- **Cluster 5 (VST/LIQUID/OUROBOROS):** dead/unused bindings in `URC_Compress`/`C_Compress` (`13_OUROBOROS.pact:249-273,331-363`); `UEV_Amount` defined but never called in LIQUID (`12_LIQUID.pact:261-273`); native KDA `install-capability` for unwrap payouts supplied externally by off-chain "JavaCode," untestable in Pact REPL (`12_LIQUID.pact:324,412`); broad REPL coverage gaps across almost every VST/LIQUID/OUROBOROS function family (see cluster scratch file table).
- **Cluster 6 (INFO-ONE):** `UC_LpFuelToLpStrings` (a `UC_`-prefixed function) contains a raw `enforce` (`:398-425`); `UCX_*`/`UCXX_*` naming is pre-migration spelling, not true auxiliaries (convention); `VST|INFO-HibernatedNonce(s)Display` use a hyphen instead of the file's `INFO_` convention, undeclared, zero callers (`:1658-1712`).
- **Cluster 7 (CODEX/PYTHIA):** dead constant `PYTHIA|FLUSH-GAS-TARGET` (`:309`); `UR_AWT|ListByCodex` scans but is named `UR_`, should be `URD_`/`URDC_` (`22_CODEX.pact:477-483,535-555`); `defcap` body-order deviations (compose-capability before local enforce) across four CODEX event caps (style only); PYTHIA's two price-setters acquire `SECURE` inline instead of via a named event cap; stale header comment on `[6.10b]_PYTHIA-ledger-v2.repl`.
- **Cluster 8 (Utility math):** tautological `or` in `CT_DPTF-FeeLock` (`01_U_CT.pact:32-41`); typos in `U_VST` enforce messages (`:83,89`); `UEV_StringPresence`'s `[bar]`-sentinel doesn't cover a real empty list (`05_U_LST.pact:161-171`); self-referential module-ref call style in `UC_NonceSplitter` (`06_U_INT.pact:76-94`); `UR|KDA-PID` section-placement mismatch; harmless off-by-one in `UC_Search`'s `enumerate` usage; REPL coverage — `[1]_Utilities.repl` has zero assertions for any of the 8 in-scope modules.
- **Cluster 9 (Talos Admin/C1):** naming drift between Talos wrapper names and their core-module counterparts (`DALOS|A_IgnisToggle`→`A_ToggleGasCollection`, `DPTF|A_UpdateTreasuryDispoParameters`→`A_UpdateTreasury`); misnamed admin keyset constant `GOV|MD_DPTF` inside `04_BRD.pact:9`; ~12 client wrappers across DPTF/DPOF sections of `02_TS01-C1.pact` end without the CLAUDE.md-mandated `format` result string.
- **Cluster 10 (Interfaces):** dead/orphaned frozen interfaces, all correctly sanctioned by the historical-interfaces policy, no action needed; inconsistent "Frozen —" `@doc` labeling among a few historical interfaces; `[0.1]_Interfaces.repl` confirmed to be a load+gas smoke test by design, not a coverage gap.

---

# N — Discovered during fix/verification work (not found by the original Round-I lenses)

Per the SWP audit's HARD RULE precedent, a finding is a finding regardless of when it surfaces — logged
here, ranked, and closed through the same discipline as everything else.

## N1 · DPOF — `C_Transmit` was completely non-functional for every caller, on every input [CONFIRMED, empirically reproduced live]

**Location:** `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact:756`, inside `DPOF|C>TRANSMIT`'s defcap:
`(meta-data-array:[[object]] (at "meta-data" td))`. The `TransmitData` defschema (`:319-324`) declares
the field as `meta-data-array`, and the object constructor that builds `td` (`UDCX_TransmitData`,
`:1683-1689`) correctly builds it with that same key — only the defcap's own read used the wrong key
string (`"meta-data"` instead of `"meta-data-array"`).

**Discovered while building the #3C REPL proof** — the very first attempt to call `C_Transmit` at all
(via the real Talos `TS01-C1::DPOF|C_Transmit` wrapper, with a completely ordinary, single-nonce,
non-duplicated input) crashed immediately with `Key "meta-data" not found in object: {...}`. This has
nothing to do with #3C's duplicated-nonce bug — it fires on every call, unconditionally, for anyone,
which is exactly why it was never caught by Cluster 4's static/code-trace-only audit pass (no `pact`
binary was available in that environment) — this is a live-execution-only discovery.

**Impact:** `DPOF|C_Transmit` (the Talos client entrypoint) and `DPOF.C_Transmit` (the core function) have
never worked, for any input, since this code was written — the segmentation/partial-nonce-transmit
feature the module's own `@doc` describes ("Transfer DPOF `<id>` `<nonces>` from `<sender>` to `<receiver>`
by a specific `<amount>`... Requires `<segmentation>` set to `<true>`") has been entirely dead on arrival.

**Confidence:** CONFIRMED — reproduced live twice (pre-fix crash, post-fix success) against the repo's
pinned Pact 5.4 binary; see `ROUND-02-FIXES.md` Fix #2.

## N2 · TFT/DPOF (Talos) — `TS01-C1::DPTF|C_DeployAccount` / `DPOF|C_DeployAccount` let any signer force any existing account to associate with any token id [CONFIRMED, cross-audit handoff — MEDIUM]

**Surfaced via a handoff from the sibling DPDC audit**, which found the identical shape at
`DPSF|C_DeployAccount`/`DPNF|C_DeployAccount` (its own #35M) and flagged that DALOS's Stage 1
equivalents should be checked.

**Location:** `1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact:659` (`DPTF|C_DeployAccount`) and `:1072`
(`DPOF|C_DeployAccount`). Both are gated only by `(with-capability (P|TS))` (`:118`), which enforces
the global pause flag and then `(compose-capability (P|TALOS-SUMMONER))` — a bare
`(defcap () true)` (`:128-131`). Because these two `defun`s are public entrypoints of TS01-C1 itself
(not foreign callers reaching in), the "Simple vault is safe by construction" reasoning from
`StoicSyntax.md` does **not** apply here — that reasoning only protects a bare-true cap from *foreign*
callers, who'd need to already hold the target module's own admin. Here the acquisition happens
from within TS01-C1's own public defun, so any external signer can call
`(TS01-C1.DPTF|C_DeployAccount patron id account)` for an arbitrary, pre-existing `account` they do
not control. Underneath, `DPTF::C_DeployAccount`/`DPOF::C_DeployAccount` (`05_DPTF.pact:1845`,
`06_DPOF.pact:1813`) only check `(UEV_IMC)` (module-to-module gate) and
`(ref-DALOS::UEV_EnforceAccountExists account)` (existence, not ownership) — no ownership check on
`account` anywhere in either chain.

**Impact:** low direct harm (the write is idempotent and grants no funds, roles, or permissions —
it only inserts a zero-balance `DPTF|BalanceTable`/`DPOF|...Table` row for `id`/`account` if absent),
but real griefing/state-bloat surface: an attacker can force a persistent, non-deletable junk
token-association row onto any victim account for any deployed `id`, without the victim's consent
and with no way for the victim to remove it.

**Important nuance vs. the DPDC precedent:** unlike DPDC's #35M — where the sibling audit found
nothing else needed the public Talos wrapper and it could likely be removed outright — DALOS's
`TS01-C1::DPTF|C_DeployAccount` **is** a real, live dependency:
- `1_SOVEREIGN/STAGE_02/3_Talos/03_TS02-DPAD.pact:194-195`, inside `A_RegisterAssetToLaunchpad`
  (gated by `(with-capability (P|TALOS-SUMMONER))` at the DPAD layer), deploys DEMIPAD's own
  launchpad smart account (`lpad`, `GOV|DEMIPAD|SC_NAME`) — not an arbitrary account.
- `2_CITIZEN/Stage_02/03_CADUCEUS.pact:241`, inside `A_ProvisionBridgeDptfRoles` (gated by
  `(with-capability (GOV|CADUCEUS_ADMIN))`), deploys CADUCEUS's own bridge account
  (`bridge-account`, `UR_BridgeAccount`) — again its own infrastructure account, not a victim's.

Both real production callers are already admin-gated one layer up and only ever target an account
the calling module itself owns/governs — so simply removing the public wrapper would break both.
The vulnerable surface is that the wrapper itself has **no gate at all** stopping an arbitrary
third party from calling it directly against someone else's account — the two legitimate callers
just happen never to misuse that missing gate. A fix would need to add scoped protection at the
Talos-wrapper layer (e.g. require caller-owns-`account` OR an explicit allow-list/elevated-cap
bypass for the two known internal callers) without breaking either of them — a real design
decision, not a one-line patch, hence flagged for owner review rather than fixed unilaterally.

**Confidence:** CONFIRMED (code-path traced end-to-end: public entrypoint → bare-true cap chain →
no ownership check anywhere in the call chain; both legitimate callers independently confirmed to
be admin-gated and self-account-targeting, so the gap is real but not yet observed to be exploited
by any in-repo caller).

## N3 · TS01-A — `DPTF|A_UpdateTreasuryDispoParameters`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial` gated only by bare-true `P|TS`, not `P|ADMINISTRATIVE-SUMMONER` [CONFIRMED, discovered while implementing #N2's fix — NOT YET DEEPLY ANALYZED]

**Location:** `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact:390-429`. Every other admin-mutation
function in this same file (`ORBR|A_Fuel`-adjacent `A_MigrateLiquidFunds`, `ATS|A_RemoveSecondary`,
`ATS|A_KickStart`, `LIQUID|A_MigrateLiquidFunds`, all `SWP|A_Update*`) is gated by
`(with-capability (P|ADMINISTRATIVE-SUMMONER) ...)`, which composes a real admin-keyset check
(`GOV|TS01-A_ADMIN` → `(enforce-guard GOV|MD_TS01-A)`). These three DPTF treasury functions instead
use plain `(with-capability (P|TS) ...)` — the same bare-true `P|TALOS-SUMMONER` chain responsible
for #N2's vulnerability. Their core-layer counterpart, `ref-DPTF::A_UpdateTreasury` (`05_DPTF.pact:1618`),
is also `(UEV_IMC)`-only, mirroring the exact shape that made #N2 exploitable.

**Potential impact (not yet verified live):** if this holds up, any signer may be able to call
`DPTF|A_UpdateTreasuryDispoParameters`/`A_WipeTreasuryDebt`/`A_WipeTreasuryDebtPartial` directly,
which per their own `@doc` strings control how much OURO debt the Treasury may incur and can "wipe
all Treasury Debt, increasing OURO supply." If genuinely unauthenticated, this would be a
CRITICAL-severity supply-integrity bug, not a griefing-only one like #N2.

**Status:** REFUTED — NOT A BUG. Investigated further: `A_UpdateTreasury`/`A_WipeTreasuryDebt`/
`A_WipeTreasuryDebtPartial` (`05_DPTF.pact:1618-1657`) each `with-capability` a dedicated defcap
(`GOV|SET_TREASURY-DISPO`/`GOV|WIPE_ALL-TREASURY-DEBT`/`GOV|WIPE_PARTIAL-TREASURY-DEBT`) that
composes `GOV|DPTF_ADMIN` (`:216-230`) — a real `enforce-one [enforce-guard GOV|MD_DPTF, enforce-guard
master-account-guard]` check (DPTF's own module-definition keyset OR patron's personal account
guard), not a rubber stamp. Unlike `C_DeployAccount` (whose core layer had zero ownership/admin
enforcement beyond `UEV_IMC`), these three functions are genuinely protected at the core layer
regardless of how weak the outer `TS01-A::P|TS` Talos gate is. Confirmed live: an unrelated,
unauthenticated signer (`lumy`, no DPTF module-def key, no patron account guard) calling
`TS01-A::DPTF|A_WipeTreasuryDebtPartial` is rejected — see
`REPL/_scratch_ts01a_n3_treasury_gate_check.repl`. Same resolution shape as #6H (an outer bare-true
Talos gate is safe when a real check exists one layer deeper). No code change.
