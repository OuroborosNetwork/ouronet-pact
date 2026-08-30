# ROUND I — Findings (DPDC modules)

**Date:** 2026-08-19 · **Status:** FROZEN — all 11 module passes landed (append-only from here). 8
CRITICAL, 14 HIGH, 16 MEDIUM, 17 LOW numbered + 1 unnumbered doc-only LOW = 56 findings, ranked in `ISSUES-RANKED.md`. Owner verdicts recorded
separately in `ROUND-01-OWNER-FEEDBACK.md`, cross-referenced here only via the tracker in `README.md` /
`ISSUES-RANKED.md`.

**Scope:** `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` (`DPDC-UDC`), `02_DPDC.pact` (`DPDC`),
`03_DPDC-C.pact` (`DPDC-C`), `04_DPDC-I.pact` (`DPDC-I`), `05_DPDC-R.pact` (`DPDC-R`), `06_DPDC-MNG.pact`
(`DPDC-MNG`), `07_DPDC-T.pact` (`DPDC-T`), `08_DPDC-S.pact` (`DPDC-S`), `09_DPDC-F.pact` (`DPDC-F`),
`10_DPDC-N.pact` (`DPDC-N`), `11_EQUITY+.pact` (`EQUITY`) — ~8,700 lines across the 11 files, plus their
(self-hosted, except `DPDC-UDC`) interfaces and the `[2.1]_DpdcCore.repl`/`[6.1]_DPDC.repl` test suites.

**Baseline:** `cd REPL && pact Z.repl` — full pipeline run at audit start; result recorded in `README.md`.

Verification tags: **CONFIRMED** = re-read/re-derived directly against the code · **PLAUSIBLE** = strong
trace, would benefit from a REPL run to nail the exact magnitude/reach.

---

<!-- Per-module auditor passes are appended below, one `# CRITICAL` / `# HIGH` / `# MEDIUM` / `# LOW`
     section per severity, findings grouped by module within each. Each finding follows the SWP/AQP
     format: heading with module + one-line claim + verification tag, then Location / What's wrong /
     Failure scenario / Fix direction / Interface implication / Owner verdict (pending). -->

# MODULE: DPDC-R (`05_DPDC-R.pact`) — role access-control layer

**Auditor method:** every `C_Toggle*`/`C_Move*` defcap traced statement-by-statement to its
`ref-DPDC::CAP_Owner` call (→ `DALOS::CAP_EnforceAccountOwnership`) and to the exact `require-capability`
consumed by its paired `XI_*`. All 12 Toggle + Move defcaps confirmed to compose a real, non-bypassable
ownership check before any trivially-true internal cap — no SWP-C12-shaped bypass found. Move-role
duplication and self-referential-move corruption hand-simulated and cleared (see "Not found" below).

## HIGH

### DPDC-R · H1 — `DPDC|C>FRZ-ACC` gates freeze **and unfreeze** on `can-freeze`, unlike every sibling toggle; combined with `can-upgrade=false` this permanently bricks a frozen account with no recovery path `[CONFIRMED]`

**Location:** `05_DPDC-R.pact:131-142` (`DPDC|C>FRZ-ACC`); compare to the identical-shape siblings at
`157-168`/`169-180`/`181-192`/`193-204`/`205-216`, all of which call `ref-DPDC::UEV_ToggleSpecialRole id
son toggle` — direction-gated (`(if toggle (UEV_CanAddSpecialRoleON id son) true)`,
`02_DPDC.pact:786-791`), so turning a role **off** is always allowed. `DPDC|C>FRZ-ACC` instead calls
`ref-DPDC::UEV_CanFreezeON id son` **unconditionally** (no `if frozen` branch), and `UEV_CanFreezeON`
(`02_DPDC.pact:792-799`) unconditionally enforces `UR_CanFreeze id son`.

**What's wrong:** `can-freeze` is a mutable property (sole writer: `DPDC-MNG::XI_Control`, gated by
`DPDC-MNG|S>CTRL` = `CAP_Owner` + `UEV_CanUpgradeON`, itself also unconditional) with no monotonicity
enforcement. If an owner sets `can-freeze=false` while an account is frozen, and `can-upgrade=false` in
the same or a later call, `C_Control` can never restore `can-freeze=true` either.

**Failure scenario:** owner freezes `emma` on collection `id` (legal). Owner later calls
`DPDC-MNG::C_Control` with `cf=false, cu=false` (an ordinary "lock in settings" tx, fully within the
owner's own privilege). `frozen` has exactly one write path in the whole family
(`DPDC::XE_U|Frozen` ← `DPDC-R::XI_ToggleFreezeAccount` ← `DPDC|C>FRZ-ACC`). With `can-freeze=false`,
`UEV_CanFreezeON` now aborts **every** call to `C_ToggleFreezeAccount` for that id, including the unfreeze
call, and `can-upgrade=false` blocks the only path back. `emma`'s tokens under this collection are
permanently immobile — reachable via an honest owner's ordinary misconfiguration, not just malice.

**Fix direction:** condition the `can-freeze` gate on direction, e.g. new `UEV_ToggleFreeze id son frozen`
mirroring `UEV_ToggleSpecialRole`: `(if frozen (UEV_CanFreezeON id son) true)`. Consider also enforcing
`can-freeze` monotonicity (cannot re-disable while any account is currently frozen).

**Interface implication:** none — internal to `DPDC-R`'s defcap (+ a new `DPDC` core `UEV_*`); no
`DpdcRolesV1`/`DpdcV1` signature change.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-R · M1 — `DPDC|C>TG_EXEMPTION-R` is the only role-toggle that never checks the collection's `can-add-special-role` renounce flag `[PLAUSIBLE]`

**Location:** `05_DPDC-R.pact:143-156`. All six sibling toggles (Burn/Update/ModifyCreator/
ModifyRoyalties/Transfer/AddQuantity) call `ref-DPDC::UEV_ToggleSpecialRole`, which gates the *granting*
edge on `UEV_CanAddSpecialRoleON` (i.e. respects `can-add-special-role`/`casr`). Exemption's defcap only
calls `ref-DALOS::UR_AccountType` + `ref-DPDC::UEV_AccountExemptionState` + `CAP_Owner` — no
`casr` check anywhere, despite Exemption living in the same `VerumRoles`/`AccountRoles` infrastructure.

**What's wrong:** `casr` is presented as the switch that closes the entire "special roles" surface; every
other role-grant honors it. A collection that renounces `casr=false` (signalling "role surface now frozen")
can still have IGNIS-fee-exemption freely granted/revoked by its owner — undermining that renouncement
guarantee for anything downstream that assumes `casr=false` means no further role churn.

**Failure scenario:** collection sets `casr=false` post-launch to advertise a frozen role surface; owner
(or a since-compromised owner key) keeps calling `C_ToggleExemptionRole` to grant fee exemption at will —
a capability every other role-grant path is explicitly blocked from after renouncement.

**Fix direction:** add `(if toggle (ref-DPDC::UEV_CanAddSpecialRoleON id son) true)` to
`DPDC|C>TG_EXEMPTION-R`, unless the asymmetry is intentional (in which case document it in an `@doc` — the
defcap currently has none).

**Interface implication:** none — internal defcap validation only.

**Owner verdict:** _pending_

## LOW

### DPDC-R · L1 — no REPL coverage exercises the ownership gate's negative path, or full on/off round trips for most Toggle/Move functions `[CONFIRMED]`

**Location:** `REPL/Stage_02/[6.1]_DPDC.repl:116-139` (all 11 role functions invoked, always signed by
`patron`, who is also the collection owner — no non-owner attempt anywhere) and `:438-458` (freeze/
unfreeze — the only role exercised in both directions). `[6.1]_DPDC.repl:124,126,130` comment out the
toggle-off half of Burn/Update/ModifyRoyalties; `AddQuantityRole` (line 117) is only ever toggled on.
`[2.1]_DpdcCore.repl` has no `C_Toggle*`/`C_Move*` calls at all.

**What's wrong:** no test asserts `expect-failure` for a non-owner `C_Toggle*`/`C_Move*` call. This is the
single highest-value missing assertion class for this module — it would have caught H1 or a future
regression silently dropping `CAP_Owner` from one of the 12 defcaps.

**Fix direction:** add ≥1 non-owner `expect-failure` case per Toggle/Move function; un-comment the
toggle-off legs for Burn/Update/ModifyRoyalties/AddQuantityRole so every role gets a full grant→revoke
round trip.

**Interface implication:** none — test-only.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no Toggle/Move defcap composes a capability without
reaching `CAP_Owner`; `C_Move*Role` correctly clears the old holder (no dual-holder duplication possible);
self-referential moves are safely rejected (unsatisfiable double-enforce, tx aborts); the list-based
toggles are safe against double-toggling (`UEV_Account*State` reads current flag before mutation,
so `U|DALOS::UC_NewRoleList`'s own lack of a duplicate-add guard is unreachable via DPDC-R's calling
convention — worth hardening at the `U|DALOS` layer for defense-in-depth, but not exploitable here);
`C_ToggleAddQuantityRole`'s hardcoded `son=true` is intentional (SFT-only concept; a DPNF-only `id` fails
safely via a nonexistent-row read abort, not silent misattribution).

---

# MODULE: DPDC-N (`10_DPDC-N.pact`) — per-nonce metadata mutation

**Auditor method:** all 8 `C_Update*` entrypoints + defcaps individually role-cross-checked against
`DPDC-R`'s actual role names (no mismatched/overly-permissive gate found; all start with `UEV_IMC`). L7
(AQP audit's DPDC `-1.0` unscored-sentinel fix) explicitly re-verified as still correctly present and
scoped in `UEV_Score` (`10_DPDC-N.pact:329-344`), regression test still live and passing
(`[6.1]_DPDC.repl:311-314`, tag `<<DPDC L7#19>>`).

## HIGH

### DPDC-N · H1 — `C_UpdateNonceIgnisRoyalty` has no upper bound at all, unlike the already-fixed ATS precedent for the same shared-pattern validator `[CONFIRMED]`

**Location:** `10_DPDC-N.pact:384-397` (`C_UpdateNonceIgnisRoyalty`); root validator
`02_DPDC.pact:915-929` (`UEV_IgnisRoyalty`, precision-only check, no magnitude bound at all — unlike its
sibling `UEV_Royalty`, `902-914`, which delegates to `U_DALOS::UEV_Fee` and IS capped `[1.0,999.0]`);
consumer `07_DPDC-T.pact:407-430` (`URC_SummedIgnisRoyalty`, uses `ignis` as a flat per-unit multiplier:
`(* (dec amount) ignis-royalty)` — not promile-scaled, genuinely unbounded); creation path reuses the same
root (`03_DPDC-C.pact:392-397`, `UEV_NonceDataForCreation`), so the gap is systemic not update-only.
Precedent: ATS audit already found and fixed this exact class on the shared `UEV_Fee`
(`1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/` #7H/H2 — layered a `<=500.0` ceiling on top of unbounded
creator-controlled fees).

**What's wrong:** any `role-modify-royalties` holder (may be a delegate, not necessarily the owner) can set
`ignis` to an arbitrarily large value via `C_UpdateNonceIgnisRoyalty`. Since it's a flat per-unit multiplier
consumed at transfer time, this either economically freezes the nonce (nobody can afford the transfer) or,
if the collector auto-pays from a pre-funded balance, silently drains far more than a buyer priced in.

**Failure scenario:** delegate calls `C_UpdateNonceIgnisRoyalty id son account nosc nos nost 1000000000.0`
— passes (precision-only check). Any subsequent transfer of that nonce now owes `amount * 1e9` IGNIS.

**Fix direction:** add a magnitude ceiling to `UEV_IgnisRoyalty` (`02_DPDC.pact:915`) — either a flat sane
max in IGNIS-per-unit terms, or tie it to the existing `UR_UsagePrice` bands (`"ignis|small"`/`"ignis|medium"`)
so the cap tracks live IGNIS price scale. Fixing the shared root in `DPDC.pact` closes both the creation
(`DPDC-C`) and update (`DPDC-N`) paths at once.

**Interface implication:** none — fix is inside the existing `UEV_IgnisRoyalty` body, no signature change.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-N · M1 — royalty/IGNIS-royalty read live at transfer time, no snapshot or max-price guard — front-runnable by the role holder mid-flight `[CONFIRMED]`

**Location:** `10_DPDC-N.pact:370-397` (the two update entrypoints); `07_DPDC-T.pact:407-430`
(`URC_SummedIgnisRoyalty` reads live table state at collection time); `07_DPDC-T.pact:37-38,694-695`
(`C_Transfer`/`C_IgnisRoyaltyCollector` — no `max-royalty`/slippage-guard parameter exists). No
listing/escrow concept exists in `DPDC-T` (grepped, none found) — transfers are direct single-tx ops, so
the only front-run window is between off-chain fee observation and on-chain tx execution, but that window
is real and the fee has (per H1) no ceiling.

**Failure scenario:** buyer observes fee `X` off-chain, signs expecting to pay `X`; royalty-role holder
raises `ignis` before the buyer's tx lands; buyer's tx either fails (insufficient IGNIS attached) or
overpays if the collector pulls from a pre-funded balance with no hard cap.

**Fix direction:** add an optional `max-ignis-royalty`/`expected-royalty` parameter to
`C_IgnisRoyaltyCollector`/`C_Transfer`'s royalty-collecting path (a `DPDC-T` change), enforced against the
live-read value before `XI_IgnisTransfer` executes. Pairs with H1's bound — a bound alone still leaves the
TOCTOU window open, just smaller in magnitude.

**Interface implication:** adding a new optional parameter to `C_Transfer`/`C_IgnisRoyaltyCollector` would
change `DpdcTransferV1`/`DpdcTransferV2`'s signature (cascade to Talos callers) — stays on current version
pre-mainnet per repo policy.

**Owner verdict:** _pending_

### DPDC-N · M2 — `C_UpdateNonceRoyalty` mutates a field (`royalty`) with zero on-chain economic consumers anywhere in the loaded module set `[CONFIRMED]`

**Location:** `10_DPDC-N.pact:370-383`; root field `UR_N|Royalty` (`02_DPDC.pact:37,440-442`);
`03_DPDC-C.pact:396` doc comment claims the `-1.0` sentinel "enable[s] Volumetric Royalty Fee" — a real,
wired-up pattern for DPTF (`1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact:1230`, `UC_VolumetricTax`) but grep
for "Volumetric" shows no such mechanism implemented for DPDC. `grep -rln "UR_N|Royalty\b"` across
`1_SOVEREIGN/` returns only the interface + the module's own defun — no caller anywhere, unlike its sibling
`UR_N|IgnisRoyalty` (actively consumed by `URC_SummedIgnisRoyalty`).

**What's wrong:** a collection owner calling `C_UpdateNonceRoyalty` (paying the IGNIS fee to do so) has no
on-chain effect from the change — the field is validated and persisted but nothing downstream reads it.
Either an intentional off-chain/marketplace-hint field (legitimate, à la ERC-2981) or an unfinished feature
— nothing in code/doc/REPL says which.

**Fix direction:** either (a) wire `UR_N|Royalty` into `DPDC-T`'s transfer pricing (implement the promised
Volumetric Royalty Fee), or (b) if intentionally off-chain-only, document that explicitly on
`C_UpdateNonceRoyalty`/`UR_N|Royalty`/`UEV_Royalty`.

**Interface implication:** none for (b); (a) needs no signature change (existing reader).

**Owner verdict:** _pending_

## LOW

### DPDC-N · L1 — `XI|U_NonceMetaData` breaks the module's own `XI_U|*` naming convention `[CONFIRMED]`

**Location:** `10_DPDC-N.pact:562` (`XI|U_NonceMetaData`, called from `C_UpdateNonceMetaData` at line 449)
vs. siblings `XI_U|NoncesData`/`XI_U|NonceRoyalty`/`XI_U|NonceNoD`/`XI_U|NonceScore`/`XI_U|NonceUri` — all
consistently `XI_U|Name`. Cosmetic only (correctly gated, write-only body) but StoicSyntax treats naming as
load-bearing; a future `grep "XI_U|"` would miss this function.

**Fix direction:** rename to `XI_U|NonceMetaData`, update the one call site.

**Interface implication:** none — internal function.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no CRITICAL findings; no missing/mismatched capability
gate across any of the 8 `C_Update*` entrypoints; no missing `UEV_IMC`; no per-item-vs-aggregate
validation gap in `C_UpdateNonces` (batch path).

---

# MODULE: DPDC-UDC (`01_DPDC-UDC.pact`) — data-construction constructors

**Auditor method:** all 26 `UDC_*` constructors read end to end and confirmed pure (no `read`/`select`/
`enforce` anywhere — the StoicSyntax `UDC_*` purity invariant fully holds). Every `ref-DPDC-UDC::` call
site across all 10 sibling files grepped and cross-checked. Baseline `pact Z.repl` reconfirmed green
independently by this auditor.

## HIGH

### DPDC-UDC/DPDC-S · H1 — `UR_N|Score`'s "cooked" reader fails to clamp the DPDC-UDC `-1.0` unscored sentinel in 3 of its 4 arithmetic branches `[CONFIRMED]`

**Location:** sentinel produced in `01_DPDC-UDC.pact:306-309` (`UDC_MetaData`/`UDC_NoMetaData` →
`UDC_ZeroNonceData`, used at 8+ "no metadata yet" call sites across `DPDC-C`/`DPDC-S`/`DPDC-F`/`DPDC`).
Consumed and mishandled in `08_DPDC-S.pact:375-405` (`UR_N|Score`):
```pact
(if (= nonce-class 0)
    (if (< nonce 0)
        (/ raw-nonce-score 1000.0)                              ;; fragment, class-0: NO sentinel check
        (if (= raw-nonce-score -1.0) 0.0 raw-nonce-score))       ;; only this arm clamps correctly
    (let ((multiplier ...) (multiplied-score (* raw-nonce-score multiplier)))
        (if (< nonce 0)
            (/ multiplied-score 1000.0)                          ;; fragment, composite: NO sentinel check
            (if (= multiplied-score -1000.0) 0.0 multiplied-score))))  ;; wrong constant
```

**What's wrong:** `10_DPDC-N.pact`'s `UEV_Score` (post the AQP-audit L7 fix) guarantees a raw native score
is always exactly `-1.0` (unscored) or `>= 0.0`. `UR_N|Score` only detects the sentinel correctly in the
class-0, non-fragment arm. The other three arms are broken: (1) class-0 fragment nonce divides the raw
(possibly `-1.0`) score by 1000 with no check → unscored fragment yields `-0.001`, not `0.0`; (2) composite
fragment nonce — same, divides `multiplied-score` (`-1.0 × multiplier` for unscored) by 1000 unchecked;
(3) composite non-fragment nonce compares against the hardcoded literal `-1000.0` instead of the real
sentinel — true only when `multiplier = 1000.0`; for the documented-default `multiplier = 1.0`,
`multiplied-score = -1.0 ≠ -1000.0`, so the sentinel leaks through as a real negative score. The `-1000.0`
literal reads as a copy/paste artifact of the `/ 1000.0` divisor two lines below.

**Failure scenario:** any composite/Set-class nonce created without explicit metadata (the common
`UDC_ZeroNonceData`/`UDC_NoMetaData` path, 8+ call sites) read through `UR_N|Score` with a non-1000
multiplier returns a real negative score instead of "unscored = 0." A sibling audit
(`03_AQP/Audit/ROUND-02-FIXES.md:945`) already states *"DPDC's cooked reader `UR_N|Score` already maps
−1.0 → 0"* while justifying a separate AQP-side clamp — true for only 1 of 4 branches. No live production
caller today (only REPL diagnostics), but it's exported on the public `DpdcSetsV1` surface specifically as
the trusted/cooked accessor, and the false-correctness assumption is already committed to another module's
audit trail.

**Fix direction:** check `(= raw-nonce-score -1.0)` before multiplying/dividing in all three broken arms
(mirror the correct class-0 non-fragment arm), or centralize the check once at function entry and drop the
`-1000.0` literal. Consider exporting a canonical `UC_IsUnscoredSentinel:bool` predicate from DPDC-UDC so
every consumer shares one detection point.

**Interface implication:** none — `UR_N|Score`'s `DpdcSetsV1` signature is unchanged.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-UDC · M1 — `UDC_ZeroNonceData` is called cross-module through a `module{DpdcUdcV1}`-typed ref but is absent from the `DpdcUdcV1` interface it's typed against `[CONFIRMED]`

**Location:** defined `01_DPDC-UDC.pact:296-302`. `DpdcUdcV1` (`0_Interfaces/02_Core.pact:242-248`)
declares 6 sibling `UDC_*` constructors but **not** `UDC_ZeroNonceData`, despite 8 cross-module call sites
(`03_DPDC-C.pact:386,390,814,831`; `08_DPDC-S.pact:605,1052,1092,1133`; `09_DPDC-F.pact:196,199`;
`02_DPDC.pact:945`) binding a `module{DpdcUdcV1}`-typed ref and calling it directly.

**What's wrong:** StoicSyntax's premise is that a `module{Iface}`-typed ref's legal call surface *is* the
interface — this function is real, load-bearing, called from 4 sibling files, but invisible to the
documented contract. Works today only because Pact resolves `ref::fun` dynamically against the concrete
bound module rather than statically restricting to declared members — implementation-detail reliance, not
the documented architecture.

**Failure scenario:** any future stricter static-dispatch enforcement (exactly what StoicSyntax prescribes
as the intended contract) breaks all 8 call sites simultaneously. A reviewer trusting the interface as
ground truth for DPDC-UDC's public surface (per `CLAUDE.md`) would miss this function entirely.

**Fix direction:** add `(defun UDC_ZeroNonceData:object{DPDC|NonceData} ())` to `DpdcUdcV1`'s `[CUSTOM][2]`
block.

**Interface implication:** yes, but free — DPDC-UDC hasn't deployed to mainnet, so this can be added
directly to `DpdcUdcV1` without a version bump; post-mainnet it would need `V2` + a cascade across the
whole DPDC family plus AQP/Talos consumers — cheaper to fix now.

**Owner verdict:** _pending_

### DPDC-UDC/DPDC-S · M2 — `UDC_NoPrimordialSet`/`UDC_NoCompositeSet` sentinels are structurally indistinguishable from a degenerate real definition; no canonical detector is exported `[PLAUSIBLE]`

**Location:** `01_DPDC-UDC.pact:323-328` (`[(N [0])]` / `[(C -1)]`). Sole consumer:
`08_DPDC-S.pact:627-650` (`UEV_NoncesForSetClass`), classifies purely by structural equality against a
freshly-built sentinel.

**What's wrong:** nothing exports an "is this the sentinel" predicate. Detection is only *empirically* safe
today (nonce ids allocate from 1, set-classes from a positive base) but neither `UEV_PrimordialSetElement`
nor `UEV_PrimordialSetDefinition` explicitly rejects an author-supplied `allowed-nonces=[0]` /
`allowed-sclass=-1` — such a definition would pass validation, be stored, then be silently misclassified by
`UEV_NoncesForSetClass` on the next set-creation call.

**Failure scenario:** self-limiting in practice (nonce 0 never exists, so composing with a real nonce would
hit a length-mismatch `enforce` first) but depends on an implicit, undocumented cross-module invariant
holding forever with zero explicit guard near where the sentinel is defined.

**Fix direction:** either enforce `(> nonce-value 0)`/`(>= allowed-sclass 0)` per-position in the set
validators, or export `UC_IsNoPrimordialSet`/`UC_IsNoCompositeSet` predicates from DPDC-UDC.

**Interface implication:** none for the validator-side fix; predicate export would add to `DpdcUdcV1`
(same free-until-mainnet leniency as M1).

**Owner verdict:** _pending_

## LOW

### DPDC-UDC · L1 — `UDC_ScoreMetaData` is dead code; the real score-mutation path bypasses the UDC constructor entirely `[CONFIRMED]`

**Location:** declared `0_Interfaces/02_Core.pact:246`, implemented `01_DPDC-UDC.pact:310-313`. Zero
callers anywhere in `1_SOVEREIGN/STAGE_02/` or `REPL/`. The real path, `10_DPDC-N.pact:538-556`
(`XI_U|NonceScore`), builds the update via a raw object merge instead.

**Fix direction:** wire `XI_U|NonceScore` through the constructor for consistency, or remove
`UDC_ScoreMetaData` from module + interface.

**Interface implication:** removal needs a `DpdcUdcV1` surface change (same free-until-mainnet leniency).

**Owner verdict:** _pending_

### DPDC-UDC · L2 — several constructors take 5-8 same-typed positional parameters in a row, a standing transposition risk with no compiler-enforced field binding `[PLAUSIBLE]`

**Location:** `UDC_DPDC|Properties` (5 strings then 8 bools), `UDC_URI|Type`/`UDC_URI|Data` (7 bools / 7
strings each), `UDC_NonceData` (2 adjacent decimals). Every current call site audited
(`02_DPDC.pact:989-1006`, `04_DPDC-I.pact:316-322`, `11_EQUITY+.pact:377,401-446`) uses named locals
mirroring field order — **no live transposition bug found**, design-robustness note only.

**Fix direction:** no code change needed now; keep using named locals at new call sites; consider
parameter-list `@doc` comments for visibility.

**Interface implication:** none.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no CRITICAL findings; the full purity invariant holds for
all 26 constructors with zero violations.

---

# MODULE: DPDC-C (`03_DPDC-C.pact`) — credit/debit ledger primitive

**Auditor method:** numeric trace of table-state transitions across every SFT-native, SFT-fragment, and
NFT-fragment Credit/Debit path, cross-referenced against `DPDC` core's `AccountSupplies`/`XE_W|Supply` and
`DPDC-T`'s transfer-amount pre-flight check.

## CRITICAL

### DPDC-C · C1 — no floor/sign check on `amount` for any delta-based Credit or Debit path lets a caller mint SFT/fragment supply out of thin air `[CONFIRMED, numeric trace]`

**Location:** every SFT-native and every fragment (SFT+NFT) Credit/Debit capability in `03_DPDC-C.pact`:
`DPSF|C>CREDIT-NONCE` (230-232), both `*CREDIT-FRAGMENT-NONCE*` singular/plural (224-229, 248-253), both
hybrid caps (267-272), `DPDC-C|C>SINGLE-CREDIT` (237-245), `DPDC-C|C>MULTI-CREDIT`/`CX>MULTI-CREDIT`
(261-264, 277-287), and the entire Debit family (292-372). Write sink: `CreditOrDebitDPDC` (872-896) /
`MappedCreditOrDebitDPDC` (897-912) → `DPDC::XE_W|Supply` (`02_DPDC.pact:1482-1502`). Contributing gap:
`DPDC::UEV_NonceQuantityInclusion` (`02_DPDC.pact:955-978`) and `DpdcTransferV1`'s `UEV_AmountsForTransfer`
(`07_DPDC-T.pact:501-527`), the only pre-flight check on a client-facing transfer's `amounts-array`.

**What's wrong:** none of the Credit caps validate a positivity bound on `amount` — most don't even carry
`amount` as a cap parameter; only native-NFT Credit enforces `amount = 1`. The Debit family's only quantity
guard, `UEV_NonceQuantityInclusion`, is `(enforce (<= amount nonce-supply) ...)` — trivially satisfied by
**any negative `amount`**. `CreditOrDebitDPDC` then computes `new-supply = current-supply ± amount` and
writes it with **no `(>= new-supply 0)` check anywhere**. `DPDC-T`'s own guard,
`UEV_AmountsForTransfer`, only enforces `amount = 1` for **native NFT** nonces
(`(and (not son) (> nonce 0))`) — SFT-native, SFT-fragment, and NFT-fragment transfer amounts pass through
completely unchecked. (Native NFT nonces are not exploitable this way — that path hardcodes
`supply = 0`/`1` via `MappedUpdateOwnerNFT` regardless of the `amount` argument.)

**Failure scenario:** attacker controls accounts `A` and `B`, already holds ≥1 unit of some SFT nonce (e.g.
`nonce=5`). Calls `DPDC-T::C_Transfer([id],[true],A,B,[[5]],[[-1000000]],false)`.
1. `UEV_AmountsForTransfer` — no check fires for SFT, passes.
2. `XE_DebitSFT-Nonce(A,id,5,-1000000,false)` → `UEV_NonceQuantityInclusion`: `(<= -1000000 10)` → true,
   passes. `CreditOrDebitDPDC`: `new-supply = 10 - (-1000000) = 1,000,010`. **`A`'s balance jumps from 10 to
   1,000,010 — supply created from nothing, via a "debit" call.**
3. `XB_CreditSFT-Nonce(B,id,5,-1000000)` → no amount check anywhere → `current-supply=0`,
   `new-supply = 0 + (-1000000) = -1,000,000`. **`B`'s row is corrupted to a permanent negative balance**,
   bricking any future legitimate debit against it.

Step 2 alone (no need to complete step 3) mints ~1,000,000 units of a real, tradeable supply from nothing,
reachable from a public transfer entrypoint with only the attacker's own accounts and an initial non-zero
balance as prerequisites — this directly breaks the ledger's core conservation invariant.

**Fix direction:** (a) add `(enforce (> amount 0) "Amount must be positive")` to every Credit/Debit cap
that currently omits it; (b) defense-in-depth: `CreditOrDebitDPDC` itself should refuse to write a negative
`new-supply`; (c) `UEV_NonceQuantityInclusion` should reject non-positive `amount` before the `<=`
comparison; (d) `DPDC-T`'s `UEV_AmountsForTransfer` should enforce `amount > 0` unconditionally, not only
for native NFT nonces.

**Interface implication:** none — all fixes are added `enforce`s inside existing bodies; no
`DpdcCreateV1`/`DpdcV1`/`DpdcTransferV1` signature changes.

**Owner verdict:** _pending_

## HIGH

### DPDC-C · H1 — native NFT Credit never checks the nonce isn't already held; the single-holder invariant is enforced only by caller convention, not by the ledger itself `[CONFIRMED]`

**Location:** `XB_CreditNFT-Nonce`(493-498)/`Nonces`(543-548), `XE_CreditNFT-HybridNonces`(568-573) →
`XI_CreditNFT`(591-593) → `XI_CreditCollectables`(602-604) → `XI_CreditOrDebitCollectables`(609-698,
native-NFT branch 677-682) → `MappedUpdateOwnerNFT`(842-870). Contrast with Debit, which does check
current-holder identity via `DPDC::UEV_NonceQuantityInclusion` (`02_DPDC.pact:970-975`).

**What's wrong:** `MappedUpdateOwnerNFT` unconditionally overwrites `nonce-holder` and writes a fresh
`supply=1` `AccountSupplies` row for the new account, with **no check the current holder is `BAR`
(unowned)** and **no clearing of the previous holder's stale row**. None of the native-NFT Credit caps call
`UEV_NftNonceExistance` or equivalent. The "single canonical holder" invariant holds today only because
every currently-registered caller happens to be disciplined (`DPDC-T::XI_TransferNonces` always debits
before crediting; `DPDC-MNG::C_RespawnNFT` explicitly checks existence in its own cap) — `DPDC-C` itself
provides no such defense, despite `XB_CreditNFT-Nonce`/`Nonces` being `XB_` (reachable by any IMC-registered
peer, not just home callers).

**Failure scenario:** any future (or currently mis-ordered) IMC-registered caller crediting a native NFT
nonce without first debiting the existing holder leaves two accounts each showing `supply=1` for the same
NFT nonce, while `NonceHolder` names only one as canonical — a duplicate-token/phantom-balance state, one
IMC registration mistake away from reachable.

**Fix direction:** add `(ref-DPDC::UEV_NftNonceExistance id n0 false)` (single) / equivalent over
`positive-nonces` (multi/hybrid) inside the native-NFT Credit capability chain, mirroring the check
`DPDC-MNG::C_RespawnNFT` already performs at its own layer — move the invariant into the ledger primitive
itself so it can't be skipped by any caller.

**Interface implication:** none — internal validation strengthening.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-C · M1 — NFT `amount = 1` enforcement is inconsistent across Credit variants of the identical operation `[CONFIRMED]`

**Location:** `DPNF|C>CREDIT-NONCE`(233-236)/`NONCES`(257-260) enforce `amount=1`; none of the three NFT
fragment/hybrid Credit caps (227-229, 251-253, 270-272) enforce any constraint. Same root cause as C1
(fragment nonces route through the unguarded delta-based `CreditOrDebitDPDC`), recorded independently since
even absent the sign bug, a non-1 NFT-fragment credit amount is accepted with zero validation.

**Fix direction:** once C1's `amount > 0` floor is added, decide and enforce the intended NFT fragment
semantics explicitly rather than leaving it as whatever falls out of the missing check.

**Interface implication:** none.

**Owner verdict:** _pending_

### DPDC-C · M2 — `XI_CreditOrDebitCollectables`'s capability-dispatch `cond` silently no-ops (skips ALL enforcement) if no branch matches, instead of hard-failing `[PLAUSIBLE — currently unreachable given upstream invariants]`

**Location:** `XI_CreditOrDebitCollectables`(609-698), 16-branch `cond`(633-663) terminated by a bare
`true`(662) rather than an error.

**What's wrong:** this `cond` re-derives, from the actual `nonces`/`amounts` shape, which capability
*should* already be granted and asserts it via `require-capability`. The 16 branches are exhaustive given
today's upstream invariants (`UEV_NonceType`/`UEV_NonceTypeMapper`) — but if a future change weakens that
guarantee, this function falls through to the bare `true` default and executes the credit/debit write with
**no `require-capability` having fired** — silent authorization bypass instead of a loud abort.

**Fix direction:** replace the trailing `true` with `(enforce false (format "Unreachable nonce/amount shape
for {} {}" [nonces amounts]))` so a future invariant break fails closed.

**Interface implication:** none.

**Owner verdict:** _pending_

## LOW

### DPDC-C · L1 — `XI_RegisterCollectionElement` (an `XI_` tier function) returns a formatted business string instead of ending on a write, per StoicSyntax §12 `[CONFIRMED, style]`

**Location:** `XI_RegisterCollectionElement`(805-839), final expression is a `format` string(837) after two
`XE_` writes — presentation logic embedded in a write-tier function.

**Fix direction:** factor the string construction into a `UDC_*` helper called by the caller after
collecting raw data, or note it as an intentional narrow exception in `@doc`.

**Interface implication:** none.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** SFT native/fragment Debit-side holder/quantity checks are
correctly wired; `wipe-mode` debit correctly requires account ownership or collection-owner and still runs
through the same quantity check regardless of mode; `UEV_IMC` is correctly first in every `XE_`/`XB_`/`C_`
entrypoint; no raw `enforce` outside a defcap/`UEV_*`; no double-write/double-aggregate-accounting pattern
between singular and plural Credit/Debit variants.

---

# MODULE: DPDC-T (`07_DPDC-T.pact`) — transfer + IGNIS royalty collection

**Auditor method:** full call-chain trace of every capability composed on the IGNIS-royalty-debit path
(cross-module into `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact`), plus role-check and freeze-check symmetry
checks across `C_Transfer`/`C_BulkTransfer`/`C_RepurposeCollectable`. Noted: `[6.1]_DPDC.repl` (1444
lines) contains exactly **one** `expect-failure` in the whole file — negative coverage is effectively
absent, `patron` is the same fixed identity in every scenario, so `patron != actual signer` is never
exercised.

## CRITICAL

### DPDC-T · C1 — `C_IgnisRoyaltyCollector` debits `patron`'s IGNIS with no ownership/authorization check anywhere in the call chain `[CONFIRMED]`

**Location:** `07_DPDC-T.pact:694-748` (`C_IgnisRoyaltyCollector`), `275-308` (`IGNIS|C>ROYALTY`/
`C>CREDIT`/`C>DEBIT`), `847-868` (`XI_IgnisTransfer`/`Credit`/`Debit`). Cross-checked against
`1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact:605-658` (`C_Collect`), `:135-159` (`IGNIS|C>DC`/`C>COLLECT`),
`:272-286` (`UEV_Patron`), and `1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact:184-197`/
`02_TS02-C2.pact:168-181` (`P|TS`).

**What's wrong:** `C_IgnisRoyaltyCollector(patron sender ids sons nonces-array amounts-array)` computes a
royalty purely from stored `NonceData` — it never checks `sender` holds/owns the tokens involved, and
debits the result from **`patron`**, a wholly separate parameter, via
`(with-capability (IGNIS|C>ROYALTY patron creator amount) (XI_IgnisTransfer patron creator amount))`.
Tracing every composed cap: `IGNIS|C>ROYALTY` checks `sender!=receiver`, `amount>0`, precision — no
ownership check. `IGNIS|C>DEBIT` (bound to `patron`) checks balance + account-exists + account-type — **no
`CAP_EnforceAccountOwnership` call at all**. `IGNIS|C>CREDIT` only checks account-exists.
`XI_IgnisDebit → DALOS::XB_UpdateBalance` only checks `UEV_IMC` (authenticates the *calling module*, not
the account). Unlike `C_Transfer`/`C_RepurposeCollectable`, `C_IgnisRoyaltyCollector` has **no master
`DPDC-T|C>...` recipe cap** wrapping the whole function — its only gate is `(UEV_IMC)`. The only place
`patron` ownership is ever checked anywhere downstream is `IGNIS::C_Collect`'s `IGNIS|C>COLLECT` cap
(`UEV_Patron` → `CAP_EnforceAccountOwnership`) — but that check is **conditionally skipped** whenever
`patron` is a smart/"gasless" DALOS account (`iz-gassless-patron` true → unconditional `IGNIS|S>FREE`
branch, `UEV_Patron` never invoked, regardless of `ignis-sum`).

**Failure scenario:** Talos's `DPNF|C_TransferNonce(patron sender receiver nonce amount method)` is gated
only by `P|TS` (Global-Admin-Pause), **not** `patron == tx signer`. Any account can call it with
`patron = <victim smart account holding IGNIS>`, `sender = receiver = <attacker's own account>`, and any
existing royalty-bearing nonce. `C_IgnisRoyaltyCollector` runs first and unconditionally debits the royalty
from `<victim>`'s IGNIS balance, crediting the collectable's creator — no signature, no ownership check
anywhere in DPDC-T. The paired `C_Collect` call takes the smart-account free branch and never runs
`UEV_Patron`. The tx succeeds; the victim's IGNIS is drained to an arbitrary creator account, repeatably, at
zero cost to the attacker (who doesn't even need to hold the transferred token — `URC_SummedIgnisRoyalty`
only reads `NonceData`, never the caller's balance). For a non-smart `patron`, the drain is blocked only
*incidentally* by whether the paired `C_Collect`'s own transfer-cost happens to be non-zero — a protection
DPDC-T does not own or control and that is not documented as the intended access-control mechanism for this
debit.

**Fix direction:** `IGNIS|C>DEBIT`/`IGNIS|C>ROYALTY` must locally compose
`(ref-DALOS::CAP_EnforceAccountOwnership patron)` before debiting — mirroring `UEV_Patron`'s existing
pattern including its smart-account special case ("only DALOS|SC_NAME may act as smart patron"). Do not
rely on a downstream, unrelated module's cap for this module's own debit authorization. Also wrap
`C_IgnisRoyaltyCollector` in a proper master `DPDC-T|C>...` recipe cap so authorization is visible at the
same layer as `C_Transfer`/`C_RepurposeCollectable`.

**Interface implication:** internal — `C_IgnisRoyaltyCollector`'s signature is unchanged; fix strengthens
the master/`IGNIS|C>DEBIT` cap body only. No version bump.

**Owner verdict:** _pending_

## HIGH

### DPDC-T · H1 — `UEV_TransferRoles` checks the sender's transfer-role twice; the receiver-side authorization is dead code `[CONFIRMED]`

**Location:** `07_DPDC-T.pact:477-487`.
```pact
(s:bool (ref-DPDC::UR_CA|R-Transfer id son sender))
(r:bool (ref-DPDC::UR_CA|R-Transfer id son sender))   ;; should read `receiver`, reads `sender` again
```
**What's wrong:** `r` (meant to be "does the receiver hold the transfer role") is computed from `sender`,
identical to `s`. `UEV_TransferRoleChecker` gates role-restricted collectables with
`enforce-one [enforce s; enforce r]` (OR semantics — pass if either side qualifies). Because `r` always
equals `s`, the OR degenerates to `enforce s` only — there is no path through which a receiver's own
transfer-role membership can ever satisfy this check independently of the sender's.

**Failure scenario:** any role-restricted collectable whose intended semantics is "sender-authorized OR
receiver-authorized" silently degrades to "sender-authorized only." A legitimately whitelisted receiver
cannot receive from a non-whitelisted sender even when the design intends it to. Silent (no distinguishing
error) and untested (`[6.1]_DPDC.repl:131-132` toggles the role but never tests differing sender/receiver
roles) — and this runs on the highest-traffic path in the module (every transfer's per-leg `map`).

**Fix direction:** `(r:bool (ref-DPDC::UR_CA|R-Transfer id son receiver))`.

**Interface implication:** internal — function body fix only, `UEV_TransferRoles` signature unchanged.

**Owner verdict:** _pending_

### DPDC-T · H2 — `C_RepurposeCollectable` skips the frozen-account and transfer-role gates that `C_Transfer` enforces `[CONFIRMED]`

**Location:** `07_DPDC-T.pact:151-160` (`DPDC-T|C>REPURPOSE` — entire master cap is a length-parity check
only), `598-654` (`C_RepurposeCollectable`). Contrast `164-207` (`DPDC-T|C>TRANSFER`, which checks
`UEV_AccountFreezeState` both sides + `UEV_TransferRoles`).

**What's wrong:** no freeze check on `repurpose-from`/`repurpose-to`, no transfer-role check at all.
Because repurpose invokes `DPDC-C`'s debit in wipe-mode (`true`), the ownership check there switches to
"does the signer own the collectable's `owner-konto`" — an appropriately privileged actor for
supply-reallocation, but that privilege was never meant to implicitly bypass freeze/role compliance
controls that exist to stop movement regardless of who initiates it.

**Failure scenario:** an admin freezes an account via `C_ToggleFreezeAccount` specifically to halt movement
of a suspect account's holdings — `C_Transfer` correctly refuses. `C_RepurposeCollectable(id, son,
repurpose-from=<frozen account>, ...)` succeeds anyway, silently draining the frozen account's balance.
Same bypass applies to role-restricted collectables' whitelists.

**Fix direction:** add `(ref-DPDC::UEV_AccountFreezeState id son repurpose-from false)` and `...to false)`
to `DPDC-T|C>REPURPOSE`; add `(UEV_TransferRoles id son repurpose-from repurpose-to)` unless repurpose is
deliberately meant to override role restriction (then document it explicitly — current `@doc` is silent).

**Interface implication:** internal — `C_RepurposeCollectable` signature unchanged, master-cap body only.

**Owner verdict:** _pending_

## LOW

### DPDC-T · L1 — dual `implements DpdcTransferV1` + `DpdcTransferV2` deviates from the stated "latest-version-only" cascade policy, but is a deliberate, documented, non-dangling exception `[CONFIRMED]`

**Location:** `07_DPDC-T.pact:41-49` (`DpdcTransferV2` `@doc` explicitly: "Additive DPDC-T surface —
opt-in per consumer; does not replace DpdcTransferV1"), `51-55` (both `implements`). Both live: Talos still
type-refs `module{DpdcTransferV1}` for `C_Transfer`/`C_RepurposeCollectable`/`C_IgnisRoyaltyCollector` and
`module{DpdcTransferV2}` specifically for `C_BulkTransfer`.

**What's wrong:** the repo-wide "implements only the latest version" convention isn't followed here — V2
is additive-only, so both `implements` clauses are kept rather than folding V1 into a fully-replacing V2.
Explicitly documented in the V2 `@doc`, so intentional, but a real divergence from written policy worth
recording so it's a decision, not a silent gap.

**Fix direction:** either (a) formally document this "additive interface" pattern as a sanctioned
alternative in `INTERFACE_VERSIONING.md`, or (b) if `DpdcTransferV1` ever needs a true replacing bump
post-mainnet, name it `DpdcTransferV3` to avoid colliding with the existing additive `V2`.

**Interface implication:** none from this finding itself — documentation/consistency note for future
versioning work.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** balance-before-write ordering on debit is correctly
composed before any write; bulk-transfer tx atomicity holds (no partial-apply path across `C_BulkTransfer`'s
per-receiver `map`); both-sides frozen check present on `C_Transfer`/`C_BulkTransfer`; royalty debit/credit
amounts are symmetric (no split/rounding leak).

---

# MODULE: DPDC-F (`09_DPDC-F.pact`) — fragmentation (make/merge/repurpose)

**Auditor method:** multi-hop cap-by-cap trace of Make/Merge/Repurpose against `DPDC-C`'s credit/debit
primitives and `DPDC-T`'s transfer ownership gate. `pact` binary unavailable in that auditor's sandbox —
findings derived from direct code-path tracing plus the actual (not just commented) REPL test content.

## CRITICAL

### DPDC-F · C1 — `C_RepurposeCollectableFragments` moves any holder's fragment balance without their consent or the compliance gates the legitimate wipe path requires `[CONFIRMED]`

**Location:** `09_DPDC-F.pact:136-145` (`DPDC-F|C>REPURPOSE` — validation is a length-parity check only),
`229-285` (`C_RepurposeCollectableFragments`, `wipe-mode` hardcoded `true` at 258-259/271-272). Compare
the real wipe path's gates: `03_DPDC-C.pact:305-322`/`336-346` (`wipe-mode=true` swaps the check from
account-ownership to collection-ownership) and `06_DPDC-MNG.pact:222-235`/`279-292`
(`DPDC-MNG|C>WIPE-SFT`/`WIPE-NFT`, which require `UEV_AccountFreezeState ... true` **and**
`UEV_CanWipeON` before ever setting `wipe-mode=true`).

**What's wrong:** `DPDC-F|C>REPURPOSE` has no `CAP_Owner`, no `CAP_EnforceAccountOwnership
repurpose-from`, no freeze check, no `can-wipe` check — then hard-codes `wipe-mode=true` on the debit,
which flips the authorization check from "does the signer own `repurpose-from`" to "does the signer own
the collection." `DPDC-MNG`'s real wipe functions only flip that same switch after independently proving
the target account is frozen and `can-wipe` is enabled; `DPDC-F` flips it unconditionally, without going
through `DPDC-T::C_Transfer` (the only path that would require `repurpose-from`'s own signature).

**Failure scenario:** any account owning `owner-konto` of collection `id` can call
`C_RepurposeCollectableFragments id son repurpose-from repurpose-to [nonce] [amount]` with
`repurpose-from` = any other user's account, moving their fragment holdings with zero consent, no freeze
precondition, no `can-wipe` requirement. Not hypothetical — `REPL/Stage_02/[6.1]_DPDC.repl:1084` (TX015)
executes exactly this shape (`DPSF|C_RepurposeFragments lumy dhoc emma lumy [-2] [10]` moves fragment
nonce `-2` from `emma` to `lumy`; `emma` never signs) and the test passes with no assertion checking
whether this should have been rejected (see M1).

**Fix direction:** add `(ref-DALOS::CAP_EnforceAccountOwnership repurpose-from)` to `DPDC-F|C>REPURPOSE`
(mirror how Make/Merge correctly delegate sender-ownership to `DPDC-T::C_Transfer`). If an admin/compliance
"repurpose without consent" mode is genuinely intended, gate it explicitly behind `UEV_CanWipeON` **and**
`UEV_AccountFreezeState ... true`, same as `DPDC-MNG`'s wipe caps — don't silently reuse the raw
`wipe-mode=true` debit branch.

**Interface implication:** none — `DpdcFragmentsV1.C_RepurposeCollectableFragments` keeps its signature;
fix is entirely inside `DPDC-F|C>REPURPOSE`'s defcap body.

**Owner verdict:** _pending_

### DPDC-F · C2 — `amount` is never validated `>0` anywhere in the Make/Merge/Repurpose call chain; a negative amount inverts credit/debit direction and drives balances negative `[CONFIRMED]`

**Location:** `09_DPDC-F.pact:167-172` (`DPDC-F|C>NONCE`), `173-184` (`DPDC-F|C>MERGE`, only checks
`nonce<0` and `(mod amount 1000)=0` — negative multiples like `-1000` also satisfy this), `286-341`
(bodies pass `amount` straight into `DPDC-T::C_Transfer`). Downstream: `07_DPDC-T.pact:501-527`
(`UEV_AmountsForTransfer`, only bounds native-NFT `amount`), `02_DPDC.pact:955-978`
(`UEV_NonceQuantityInclusion`, trivially true for negative `amount`), `03_DPDC-C.pact:872-896`
(`CreditOrDebitDPDC`, no sign check, no `new-supply>=0` check) — the same shared gap flagged
independently by the DPDC-C and DPDC-T auditors as C1/H1-adjacent.

**What's wrong:** no layer — not DPDC-F's own defcaps, not DPDC-T's transfer cap, not DPDC-C's
debit/credit primitive — enforces `amount > 0`. Since debit computes `current-supply - amount` and credit
computes `current-supply + amount`, a negative `amount` makes "debit" *increase* the payer's balance and
"credit" *decrease* the receiver's — the operation runs backwards.

**Failure scenario:** caller who legitimately owns `account` calls
`C_MakeFragments account id true nonce -1` on a fragmentation-enabled nonce.
`DPDC-T::C_Transfer(... amount=-1)` → `XE_DebitSFT-Nonce account ... -1` → `CreditOrDebitDPDC`:
`new-supply = current-supply - (-1) = current-supply + 1` — **the caller's own balance goes up**, not
down, for a "debit." The paired credit leg on `dpdc`'s escrow drives it **negative**. Net effect: the
caller mints a free unit of the source nonce while corrupting `dpdc`'s escrow ledger, reachable from a
public, IMC-gated client entrypoint. `C_MergeFragments` shares the identical root cause, and since
`C_RepurposeCollectableFragments` routes through the same unguarded primitives, this also amplifies C1's
confiscation power into arbitrary balance corruption.

**Fix direction:** add `(enforce (> amount 0) ...)` to `DPDC-F|C>NONCE` and `DPDC-F|C>MERGE` (and to
`DPDC-F|C>REPURPOSE`'s per-element fold). The systemic root cause lives one layer down in
`DPDC-T::UEV_AmountsForTransfer` and `DPDC-C::CreditOrDebitDPDC`/`UEV_NonceQuantityInclusion`, which
should also gain the guard — this is a shared defect across DPDC-F/DPDC-T/DPDC-C, not unique to DPDC-F.

**Interface implication:** none — added `enforce`s only, no `DpdcFragmentsV1` signature change.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-F · M1 — the make+merge round trip and the repurpose scenario are executed in the REPL suite but never asserted, masking C1/C2 `[CONFIRMED]`

**Location:** `REPL/Stage_02/[6.1]_DPDC.repl:764-808` (TX008 make+merge — the body is bare reads with
**no `(expect ...)`**, expected values only exist as a comment) and `:1059-1097` (TX015 — the C1 exploit
shape, no `expect`/`expect-failure` at all).

**Fix direction:** add `expect` assertions in TX008 comparing pre/post supplies for `patron` and `dpdc`
(0 net drift after a full make+merge cycle); add an `expect-failure` in TX015 (or a new tx) proving a
non-owner-signed repurpose of another account's fragments is rejected once C1 is fixed.

**Interface implication:** none — test-only.

**Owner verdict:** _pending_

## LOW

### DPDC-F · L1 — `C_RepurposeCollectableFragments` Multi Mode has no `length>0` guard `[PLAUSIBLE]`

**Location:** `09_DPDC-F.pact:136-145` (accepts `l1=l2=0`), `267-279`. Downstream
`03_DPDC-C.pact:609-632` unconditionally computes `(at 0 nonces)` before any content-length check — an
empty repurpose call likely aborts on an unfriendly out-of-bounds error several hops later instead of a
clear gate-level message.

**Fix direction:** add `(enforce (> l1 0) "fragment-nonces must be non-empty")` to `DPDC-F|C>REPURPOSE`.

**Interface implication:** none.

**Owner verdict:** _pending_

### DPDC-F · L2 — `DPDC-F|C>MERGE` omits `id`/`son` from its capability parameters and neither `C>NONCE` nor `C>MERGE` are marked `@event`, inconsistent with sibling caps `[CONFIRMED]`

**Location:** `09_DPDC-F.pact:167-172`, `173-184` vs. `136-166` (both `@event`, full parameter set). Not
independently exploitable (downstream reads still scope correctly) but weakens the capability's own audit
trail and reads as an oversight vs. sibling caps in the same file.

**Fix direction:** add `id:string son:bool` to `DPDC-F|C>MERGE`'s parameters; mark both `@event`.

**Interface implication:** none — capability signature is internal, not part of `DpdcFragmentsV1`.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** the fragmentation-eligibility gate is correctly enforced
(no path to `C_MakeFragments` before `C_EnableNonceFragmentation` has run); the 1000x fixed-ratio
make/merge math is conservation-correct as designed, ignoring C2's sign gap; DPDC-F correctly delegates to
`DPDC-T::C_Transfer`/`DPDC-C` rather than duplicating ledger math inline — C1's divergence is a parameter
choice (`wipe-mode=true`) into a correctly-owned shared primitive, not duplicated logic.

---

# MODULE: DPDC-MNG (`06_DPDC-MNG.pact`) — pause, add-quantity, burn, respawn, wipe family

**Auditor method:** traced every mutating defcap for pause-gating and fragmentation-awareness; cross-read
`DPDC-F` (fragment collateral mechanics), `DPDC-S`/`DPDC-C` (class/nonce dispatch), `DPDC-R` (role
toggles).

## CRITICAL

### DPDC-MNG · C1 — burn/wipe has zero fragmentation-awareness: wiping the escrow account's collateral orphans all outstanding fragment claims, and `C_RespawnNFT` can re-arm them against a different asset `[CONFIRMED]`

**Location:** `06_DPDC-MNG.pact:702-736` (`XI_DecreaseClassZeroSemiFungibles`), `738-754`
(`...NonFungibles`), `222-235`/`279-292` (`DPDC-MNG|C>WIPE-SFT`/`WIPE-NFT`), `295-327`
(`...REMOVE-CLASS-ZERO-NONCES`), `238-254`/`507-521` (`...RESPAWN-NFT`/`C_RespawnNFT`). Cross-module:
`09_DPDC-F.pact:286-341` (`C_MakeFragments`/`C_MergeFragments` — escrows the native nonce at the `dpdc`
system account and mints 1000x negative-nonce fragments), `191-215` (`UEV_IzNonceFragmented`);
`05_DPDC-R.pact:131-142` (`DPDC|C>FRZ-ACC` — no protection for the system account);
`02_DPDC.pact:1233-1242` (`XE_U|NonceOrSplitData`, sole writer of the `split-data` marker).

**What's wrong:** `C_MakeFragments` transfers the native nonce's balance into escrow at the protocol's own
system account (`GOV|DPDC|SC_NAME`, aka `dpdc`) and issues 1000x negative-nonce fragment shares —
`dpdc`'s holding of positive nonce `N` is the *sole collateral* backing every outstanding `-N` fragment
balance. DPDC-MNG's entire burn/wipe family gates only on `nonce-class=0` and (for wipe) frozen+
`can-wipe`; **nothing calls `DPDC-F::UEV_IzNonceFragmented`, and nothing excludes `account = dpdc`**.
`DPDC|C>FRZ-ACC` also has no exclusion for the system escrow account — only `CAP_Owner` is required. So a
collection owner can freeze `dpdc`, then wipe/burn its holding of nonce `N` — an ordinary "freeze then wipe
a problem account" workflow with no special-casing for the fact that this account is the protocol's own
vault. The wipe succeeds silently (internal bookkeeping is self-consistent) but every third-party holder
of `-N` fragments (a separate set of `AccountSupplies` rows, untouched) is left holding a balance that can
never be honored — `C_MergeFragments` will fail on insufficient collateral for every holder after the
first (if the wipe was partial) or all of them (if total).

**Compounding half:** `split-data` (read by `UEV_IzNonceFragmented`) is written only by
`DPDC-F::XI_EnableNonceFragmentation`; burn/wipe never touches it, so it survives untouched. If the burned
nonce is later un-burned via `C_RespawnNFT` (gated only by "nonce-holder = BAR"), the respawn reattaches
the exact same nonce-data to whatever account the respawner names — again possibly `dpdc`. Stale, pre-burn
`-N` fragment holders (never made whole) can then `C_MergeFragments` and redeem/claim the respawned asset,
with no legitimate claim on it. No code path validates "this nonce was never fragmented" before burn,
wipe, or respawn.

**Failure scenario:** Alice fragments DPSF nonce 7, minting 7000 `-7` shares, moving her 7-unit balance
into `dpdc` escrow. Collection owner later freezes `dpdc` (unrelated compliance sweep) and calls
`C_WipeHeavy patron dpdc id` — the escrow's 7-unit holding is wiped. Alice's 7000 `-7` units are now
permanently unbacked but still read `7000` and remain freely transferable — she can sell them before
anyone notices `C_MergeFragments` reverts. If nonce 7 is later respawned/re-credited to `dpdc` for an
unrelated reason, Alice (or a buyer of her stale fragments) can merge and walk away with an asset she has
no legitimate claim to.

**Fix direction:** add `(enforce (not (ref-DPDC-F::UEV_IzNonceFragmented id son nonce)) ...)` for every
nonce in the batch inside `DPDC-MNG|C>WIPE-SFT`/`WIPE-NFT`/`REMOVE-CLASS-ZERO-NONCES` (and equivalent burn
caps), and/or unconditionally reject `account = GOV|DPDC|SC_NAME` as a burn/wipe target from this module
(the escrow account should only ever be debited by DPDC-F's own fragment-aware paths). On respawn,
`C_RespawnNFT` should refuse a nonce with non-zero `split-data`, or explicitly clear it back to
`UDC_ZeroNonceData` as part of the respawn write.

**Interface implication:** internal `enforce` additions — no `DpdcManagementV1` signature change. A new
cross-module ref to `DPDC-F` isn't currently present in this module but adding one isn't an
interface-version bump (no signature changes on either side).

**Owner verdict:** _pending_

## HIGH

### DPDC-MNG · H1 — pause never gates any mutating entrypoint in this module: a paused collection can still be burned, wiped, minted into, and un-burned `[CONFIRMED]`

**Location:** every mutating defcap in `06_DPDC-MNG.pact` (`C>ADD-QUANTITY:165-190`,
`C>BURN-SFT:191-203`, `C>WIPE-SFT-NONCE-*:204-211`, `C>WIPE-SFT:222-235`, `C>RESPAWN-NFT:238-254`,
`C>BURN-NFT:255-269`, `C>WIPE-NFT-*:270-292`, `C>REMOVE-CLASS-ZERO-NONCES:295-327`). `UEV_PauseState`
appears nowhere in this file except the toggle itself (`DPDC-MNG|S>TG_PAUSE:149-162`). Contrast
`07_DPDC-T.pact:195,221`, which do call `UEV_PauseState` before any transfer — establishing pause is meant
to gate collection activity generally, not just moves. Verified by grep: `UEV_PauseState`/`UR_IsPaused`
appear nowhere in `DPDC-C`/`DPDC-I`/`DPDC-R`/`DPDC-S`/`DPDC-F` or any other `DPDC-MNG` entrypoint.

**What's wrong:** `C_AddQuantity`/`C_BurnSFT`/`C_BurnNFT` are gated only by per-account roles
(delegable, not admin-only) — pausing a collection to halt activity during an incident does not stop a
role-holder from continuing to mint quantity, burn, or wipe.

**Failure scenario:** owner detects abuse (compromised Add-Quantity-role account draining value) and calls
`C_TogglePause id son true`, expecting all activity to freeze. The compromised account keeps calling
`C_AddQuantity` — it succeeds every time, since `DPDC-MNG|C>ADD-QUANTITY` never checks `UR_IsPaused`. Only
transfers actually freeze; supply-affecting mutation continues, undermining the incident-response purpose.

**Fix direction:** add `(ref-DPDC::UEV_PauseState id son false)` as an enforced precondition inside every
mutating master defcap in DPDC-MNG, mirroring `DPDC-T`'s pattern — or, if pause is deliberately
transfers-only, document that explicitly (`C_TogglePause`'s current `@doc` is silent on scope).

**Interface implication:** internal addition inside existing defcaps — no `DpdcManagementV1` signature
change.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-MNG · M1 — `C_WipeHeavy`/`C_WipeClean`/`C_WipeDirty` call `C_WipePure` directly, in-module, violating the documented "`C_` cannot be invoked from its own module" rule `[CONFIRMED]`

**Location:** `06_DPDC-MNG.pact:611,652,664` — three `C_*` functions call `C_WipePure` (also a public
`C_*`) as an ordinary function call. Rule source: `StoicSyntax-Prefixes.md`, reiterated in `CLAUDE.md`:
"`C_` is blocked from being invoked inside its own module by design." Not a fund-loss bug today (no
double IGNIS billing — the callers just return whatever cumulator `C_WipePure` built), but architectural
drift: any future capability-gate on `C_*` composition (Talos-only enforcement) would silently break this
in-module shortcut.

**Fix direction:** extract `C_WipePure`'s shared body into an `XI_*` helper both it and
`C_WipeHeavy`/`Clean`/`Dirty` call, each independently wrapping it with its own `with-capability` +
cumulator construction.

**Interface implication:** none — internal refactor only.

**Owner verdict:** _pending_

### DPDC-MNG · M2 — the "class-zero" filter that's supposed to protect fragment nonces from direct burn doesn't actually do so; real protection lives entirely in a different module `[CONFIRMED]`

**Location:** `06_DPDC-MNG.pact:702-705` (doc claims fragment protection), `328-335`/`386-399`
(`URC_FilterClassZeroNonces`, which reads `(abs nonce)` via `UR_NonceClass` — so a fragment nonce `-N`
inherits its parent `N`'s class and, if `N` is class 0, incorrectly passes as "class 0"). Actual
protection lives in `03_DPDC-C.pact:401-406` (`UEV_NonceType`, a **different module**, enforcing
`nonce > 0` before dispatch).

**What's wrong:** not independently exploitable today (`UEV_NonceType` genuinely stops the path), but
DPDC-MNG's own local safety story is false — a reviewer reading only this file would conclude the
class-zero gate is complete self-contained protection against fragment-nonce misuse, per its own doc
comment. It is not; any future refactor of `DPDC-C`'s dispatch removes the only actual guard with no
warning from this module.

**Fix direction:** either fix the doc to be honest the filter only screens Set-class nonces and add an
explicit `(enforce (> nonce 0) ...)` fold inside `DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES` for defense in
depth, or correct the `@doc` to stop claiming protection that doesn't originate here.

**Interface implication:** none — internal validation/doc fix only.

**Owner verdict:** _pending_

## LOW

### DPDC-MNG · L1 — the escalating-scope `Wipe*` family (`Heavy`/`Pure`/`Clean`/`Dirty`) has zero REPL test coverage `[CONFIRMED]`

**Location:** `REPL/Stage_02/[6.1]_DPDC.repl:488-537` — the entire "TX 005b -- Wipe Tests" body is
commented out (`C_WipeHeavy`/`C_WipePure`/`C_WipeClean`/`C_WipeDirty` all inert); only `C_WipeSlim` and
`C_WipeNonce` are exercised anywhere in the suite. `C_MakeFragments` is exercised but never in combination
with any wipe/burn of the escrowed nonce — precisely why C1 and M1 went unnoticed.

**Fix direction:** re-enable TX 005b with live assertions (positive-path for all four Wipe variants, an
`expect-failure` for `C_WipeClean` with a non-viable nonce in the batch, an `expect` for `C_WipeDirty`
silently dropping non-viable nonces), and once C1 is fixed, a regression combining `C_MakeFragments` + wipe
of the escrow account to prove the new guard rejects it.

**Interface implication:** none — test-only.

**Owner verdict:** _pending_

---

# MODULE: EQUITY (`11_EQUITY+.pact`) — shareholder-collection package shares

**Auditor method:** conservation trace across Make/Break/Convert (explicit ask) — no inflation/deflation
bug found; total nonce-1 share supply is immutable post-issuance through every EQUITY path (Make/Break
only move nonce-1 tokens between `account` and the `dpdc` escrow, and only add/burn package-tier nonces
2-8, never nonce 1). This is a genuine positive result, confirmed by direct code trace, not an omission.

## HIGH

### EQUITY · H1 — the entire financial-instrument module has zero REPL/test coverage `[CONFIRMED]`

**Location:** `REPL/Stage_02/[2.1]_DpdcCore.repl:379-391` (only place EQUITY is loaded — just a `load` +
`env-gas` echo, no client call, no assertion); `[4.0]_Sovereign-Executor.repl:80,102,123` (policy/IMC
wiring only). `grep -rln "EQUITY" REPL/Stage_02/` and `find REPL/Stage_02 -iname "*equity*"` confirm: no
`[6.x]_EQUITY*.repl` scenario file exists anywhere.

**What's wrong:** every claim about EQUITY (conservation invariants, capacity math, nonce-tier
arithmetic, role-based escrow gating) is verified only by static reading, never exercised end-to-end. A
dilution-sensitive financial instrument is going to production with the same test rigor as an untouched
stub — any regression elsewhere in the DPDC family (e.g. a `DPDC-MNG|C>ADD-QUANTITY` role-check change, or
a `DPDC-T` transfer-ownership change) would silently break EQUITY with no CI signal.

**Fix direction:** add a `[6.x]_EQUITY.repl` mirroring the canonical layout: issue a shareholder
collection, exercise Make → Convert → Break round trips with `expect`/`expect-failure` on `UR_TierSupplies`,
`URC_CombineCapacity`, and total nonce-1 supply before/after each step.

**Interface implication:** none — test-only gap.

**Owner verdict:** _pending_

## MEDIUM

### EQUITY · M1 — "shareholder collection" identity is a self-checked string prefix, not a registry EQUITY owns `[PLAUSIBLE]`

**Location:** `UEV_EquitySemiFungibleID` (`11_EQUITY+.pact:307-315`, `(take 2 id) = "E|"`), consumed by
all three master caps. `C_IssueShareholderCollection` derives the prefix via `U|VST::UC_EquityID` then
issues through the fully public, generically-callable `DPDC-I::C_IssueDigitalCollection`.

**What's wrong:** `DPDC-I::C_IssueDigitalCollection` has no knowledge of EQUITY and no restriction on
`collection-ticker`'s contents — nothing stops a caller from invoking it directly with a
self-chosen `"E|"`-prefixed ticker. EQUITY's own gate would then treat that collection as legitimate
shareholder equity. EQUITY never writes/checks a dedicated `is-equity` flag of its own — the only real
backstop is that Make/Break/Convert always act *as* the hardcoded `dpdc` account, and
`DPDC-MNG|C>ADD-QUANTITY`/`C>BURN-SFT` require `role-nft-add-quantity`/`role-nft-burn`, which only genuine
EQUITY issuances grant to `dpdc`. So the practical exploit is currently blocked by a *different module's*
role table, not by anything EQUITY itself verifies — an implicit, indirect trust chain rather than an
owned invariant.

**Failure scenario:** if a future change to `DPDC-I` (e.g. a citizen wrapping `C_IssueDigitalCollection`
with a caller-chosen `owner-account`) or to `DPDC-MNG`'s role semantics ever lets a non-`dpdc` account
acquire those roles on an `"E|"`-prefixed collection, EQUITY's gate would happily treat it as real
shareholder equity with no independent, EQUITY-owned marker to catch the regression. (Full verification of
`DALOS::UEV_SmartAccOwn`'s `enforce-one` airtightness was out of this module's scope — flagged for the
DPDC/DPDC-T auditors.)

**Fix direction:** have `C_IssueShareholderCollection` write a dedicated EQUITY-owned registry flag keyed
by `id`, and have `UEV_EquitySemiFungibleID` check that flag instead of (or in addition to) the string
prefix.

**Interface implication:** internal state addition; no `EquityV1` signature change required unless a new
reader is exposed (additive, stays V1).

**Owner verdict:** _pending_

### EQUITY · M2 — `URC_CombineCapacity`'s 50% packaging cap is an undocumented magic constant `[CONFIRMED]`

**Location:** `URC_CombineCapacity` (`11_EQUITY+.pact:265-278`), `(half-shares (/ shares 2))` at line 270.
The arithmetic is correct (properly nets out shares already packaged before comparing against a new
request) but the "at most 50% of shares may ever be packaged" business rule has zero `@doc`, zero named
constant, zero rationale comment anywhere in the file.

**Failure scenario:** a future maintainer reading `(/ shares 2)` with no context is equally likely to "fix"
it as a bug as to correctly preserve intent — either direction silently changes a cap-table invariant, with
no test (per H1) to catch the regression.

**Fix direction:** extract to a named `defconst` (e.g. `CT_MAX_PACKAGEABLE_RATIO`) with an `@doc`
explaining the rationale; add a REPL assertion pinning the boundary.

**Interface implication:** none.

**Owner verdict:** _pending_

## LOW

### EQUITY · L1 — Make/Break reimplements DPDC-S's "combine nonces / break back" pattern with a bespoke, divergent mechanism `[CONFIRMED]`

**Location:** `XI_MakePackageShares`/`XI_BreakPackageShares` (`11_EQUITY+.pact:514-586`) vs.
`DPDC-S::C_MakeSemiFungibleSet`/`C_BreakSemiFungibleSet`. Architecturally defensible (EQUITY wants
freely-transferable tier tokens, not opaque set-bundles) but the two implementations share no code and no
test surface — a correctness fix applied to one won't propagate to the other.

**Fix direction:** no code change needed now; document in `@doc`/a memories note that this is an
intentionally separate implementation, cross-linked so future `DPDC-S` invariant changes trigger a manual
EQUITY review.

**Interface implication:** none.

**Owner verdict:** _pending_

### EQUITY · L2 — `URC_SingleSharePerMillions` has no declared return type, inconsistent with every sibling `URC_*` `[CONFIRMED]`

**Location:** `11_EQUITY+.pact:261-264`; `EquityV1:17` mirrors the omission. Cosmetic/type-hygiene only.

**Fix direction:** add `:integer` to both the module `defun` and the interface declaration.

**Interface implication:** technically an interface text change (not signature-breaking in Pact's sense) —
bundle with the next V1-internal edit.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no CRITICAL inflation/deflation bug in Make/Break/Convert;
every division that actually executes is preceded by an exact-divisibility `enforce`, never truncating.

---

# MODULE: DPDC-S (`08_DPDC-S.pact`) — set mechanics (primordial/composite/hybrid make/break)

**Auditor method:** cross-checked all three set-definition validators (Primordial/Composite/Hybrid) against
each other for divergent rigor; one finding reproduced live against `pact 5.4`. Repo-wide grep confirms
**zero** REPL coverage for `C_MakeSemiFungibleSet`, `C_BreakSemiFungibleSet`, `C_MakeNonFungibleSet`,
`C_BreakNonFungibleSet`, `C_DefineHybridSet`, `C_EnableSetClassFragmentation`, `C_ToggleSet`, `C_RenameSet`,
`C_UpdateSetMultiplier` — only `C_DefinePrimordialSet`/`C_DefineCompositeSet` are exercised, and only as
genesis-content setup, not as Make/Break round-trip tests. The entire conservation-critical cycle this module
exists to protect has no test at all (see L1) — directly explains why C1/C2 below shipped undetected.

## CRITICAL

### DPDC-S · C1 — `C_UpdateSetMultiplier` cannot ever succeed: a `let` type-annotation bug crashes every call `[CONFIRMED — reproduced against pact 5.4]`

**Location:** `DPDC-S|C>MULTIPLIER` (`08_DPDC-S.pact:305-325`), offending binding at line 310:
```pact
(current-multiplier:string (UR_SetMultiplier id son set-class))   ;; UR_SetMultiplier returns :decimal
```
Reproduced directly: `(let ((x:string (foo))) ...)` where `foo` returns decimal →
`Runtime typecheck failure, argument is decimal, but expected type string`. This fires the instant the `let`
binding evaluates, before the body. Copy-paste artifact — the sibling cap `DPDC-S|C>RENAME` (line 297) has
the identical shape (`current-name:string (UR_SetName ...)`, correctly typed since `UR_SetName` returns
`:string`); `MULTIPLIER` was evidently cloned from `RENAME` and the annotation never updated.

**Failure scenario:** any collection owner calling `C_UpdateSetMultiplier` for any arguments gets an
unconditional abort. The entire multiplier-update feature is dead on arrival; the module compiles/deploys
fine (runtime-only type error), so nothing at load time flags it — matching the zero test coverage on this
entrypoint.

**Fix direction:** `current-multiplier:decimal`.

**Interface implication:** none — internal to the defcap body.

**Owner verdict:** _pending_

### DPDC-S · C2 — Composite/Hybrid SFT set-class positions with `allowed-sclass = 0` pass definition validation, then permanently strand the constituent once made `[CONFIRMED]`

**Location:** `UEV_CompositeSetDefinition` (`08_DPDC-S.pact:569-589`) only bounds the **maximum** class
referenced (`(enforce (<= max scu) ...)`), never that each individual `allowed-sclass > 0`. Set-class `0` is
the codebase's reserved sentinel for "not part of any set." A definition containing `(C 0)` passes trivially.

**What's wrong:** at **Make** time, `UEV_Composite`'s check `(= nonce-class allowed-sclass)` becomes
`(= nonce-class 0)`, satisfied by **any plain native SFT nonce** — the caller's real, valid nonce is
legitimately transferred into `dpdc` custody and the set mints successfully. At **Break** time,
`URCX|CSD_NonceList` calls `UR_NonceOfSet id 0` → a table `read` on key `id|BAR|"0"`, a row that's never
inserted (real set-classes always allocate `≥ 1`) — the `read` throws "row not found" and the tx aborts
**every time, for every holder, forever**.

**Failure scenario:** owner defines a composite/hybrid SFT set-class with one position `(C 0)` (mistake or
griefing). Any account that later `C_MakeSemiFungibleSet`s for that class succeeds and has a real nonce
moved into `dpdc` custody. `C_BreakSemiFungibleSet` for that class can never succeed — the constituent is
permanently locked, unrecoverable through any function in this module. Real user value destroyed, not just
metadata.

**Fix direction:** add a per-element `(enforce (> allowed-sclass 0) ...)` inside `UEV_CompositeSetDefinition`
(mirroring Primordial's existing per-element check), rejecting `0`/negative sentinels before persistence.

**Interface implication:** none — signature unaffected, internal enforcement only.

**Owner verdict:** _pending_

### DPDC-S/DPDC-C · C3 — `how-many-sets` is never bounded to positive values; the immediate downstream credit/debit gates don't catch it either `[PLAUSIBLE — entry-point gap CONFIRMED, terminal arithmetic not independently re-traced]`

**Location:** `C_MakeSemiFungibleSet`/`C_BreakSemiFungibleSet` (`08_DPDC-S.pact:722-775`); caps
`DPDC-S|C>MAKE`/`C>BREAK` (194-218) don't even take `how-many-sets` as a parameter — unvalidated in this
module. Downstream `DPSF|C>CREDIT-NONCE` (`03_DPDC-C.pact:230-232`) has no amount check at all;
`UEV_NonceQuantityInclusion` (`02_DPDC.pact:955-977`)'s `(<= amount nonce-supply)` is trivially satisfied by
any negative amount.

**What's wrong:** `how-many-sets` flows straight into the credit leg (mint) and the constituent debit leg
with no `(> how-many-sets 0)` check anywhere on the path from DPDC-S's own caps. (Corroborates the identical
gap independently flagged by the DPDC-C and DPDC-F auditors as their own C1/C2.)

**Fix direction:** add `(enforce (> how-many-sets 0) ...)` to `DPDC-S|C>MAKE`/`C>BREAK` (pass it as a cap
parameter so it validates at the gate); independently harden `UEV_NonceQuantityInclusion`/
`DPSF|C>CREDIT-NONCE` with an explicit floor — DPDC-S isn't the only caller of those primitives.

**Interface implication:** cap-parameter addition only — caps aren't on the interface, no `DpdcSetsV1` bump.

**Owner verdict:** _pending_

## HIGH

### DPDC-S · H1 — Set-class multiplier has no bound and no live-supply guard: once C1 is fixed, it retroactively re-prices every outstanding member instantly `[CONFIRMED]`

**Location:** `DPDC-S|C>MULTIPLIER` (`08_DPDC-S.pact:305-325`); consumer `UR_N|Score` (375-405) computes
`(* raw-nonce-score multiplier)` **at read time**, not mint time. No lower/upper bound on `new-multiplier`
(zero and negative both pass), no check the set-class has zero circulating supply first — the exact "instant,
unbounded, retroactive economic parameter change on a live position" shape as the SWP audit's
`C_ModifyWeights` finding (C7).

**Failure scenario:** owner mints a large supply at `multiplier=1.0`, holders accumulate value/stake
elsewhere (e.g. AQP), owner calls `C_UpdateSetMultiplier(..., 0.0)` — every holder's score for that class
collapses instantly, zero notice, zero time-lock, zero magnitude limit.

**Fix direction:** add a sane range (`0.0 < new-multiplier <= ceiling`), consider a time-locked/pending
mechanism or restrict updates to zero-live-supply set-classes.

**Interface implication:** range/positivity check is internal, no bump. A pending-multiplier mechanism would
add new state and require a `DpdcSetsV1` bump (same conclusion SWP's C7 reached).

**Owner verdict:** _pending_

### DPDC-S · H2 — `score-multiplier` is fully unvalidated at Define time, but the identical field is precision-checked at Update time `[CONFIRMED]`

**Location:** `C_DefinePrimordialSet`/`C_DefineCompositeSet`/`C_DefineHybridSet` (861-961) and caps
(219-250) never reference `score-multiplier`. Compare `DPDC-S|C>MULTIPLIER` (313-316), which enforces
3-decimal precision.

**What's wrong:** the initial value has no precision or sign check at Define time, while the *update* path
for the exact same field enforces a 3-decimal rule. Owner can define a set with
`score-multiplier=1.123456789` or negative, silently violating the invariant the update path pretends to
protect.

**Fix direction:** factor the precision/sign check into a shared `UEV_*` helper called from all three Define
caps and the Update cap.

**Interface implication:** none — internal validation only.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-S · M1 — Hybrid set Make-time ordering and Break-time reconstruction order are reversed; currently harmless but structurally fragile `[CONFIRMED, currently non-exploitable]`

**Location:** `UEV_NoncesForSetClass` hybrid branch (658-661) assumes `[primordial..., composite...]`
ordering; `URC_SemiFungibleConstituents` hybrid branch (465) returns `[composite..., primordial...]` — the
reverse. Harmless today only because every Primordial position maps to exactly one nonce, every Composite
position maps to a fixed `nonce-of-set`, and both Make/Break apply the same scalar `how-many-sets` uniformly
— so the set of (nonce, quantity) pairs is order-independent today. Any future non-uniform per-position
quantity would silently misattribute between legs with no enforce to catch it.

**Fix direction:** normalize both functions to the same ordering (primordial-first, the Make-time
convention), add a cross-referencing comment.

**Interface implication:** none.

**Owner verdict:** _pending_

### DPDC-S · M2 — `C_EnableSetClassFragmentation` skips the active-state gate its sibling admin caps all enforce `[PLAUSIBLE]`

**Location:** `DPDC-S|C>ENABLE-FRAGMENTATION` (262-280) vs. `C>TOGGLE`/`C>RENAME`/`C>MULTIPLIER`, all three
of which call `UEV_SetActiveState`; `ENABLE-FRAGMENTATION` doesn't. Fragmentation-enablement is the only one
of five owner-gated mutations invocable regardless of set-class state or live membership.

**Fix direction:** add the same `UEV_SetActiveState` check, or explicitly document why it's intentionally
state-independent.

**Interface implication:** none.

**Owner verdict:** _pending_

### DPDC-S · M3 — Primordial set-definition bounds also only check the running maximum, not each individual value; out-of-range (but nonzero) values silently waste the set-class slot `[CONFIRMED]`

**Location:** `UEV_PrimordialSetDefinition` (529-556) — same shape as C2's root cause, bounds only the
maximum referenced value. Unlike Composite, most out-of-range values here don't create a value-destroying
lock (negative nonces are legitimate fragment encodings) — but a value matching no real nonce or fragment
makes that position permanently unsatisfiable at Make time, silently burning a monotonic, never-reclaimed
`set-classes-used` slot forever.

**Fix direction:** for SFT primordial elements, validate the single value is either a plausible native nonce
(`0 < n <= UR_NoncesUsed`) or a plausible fragment encoding, consistent with C2's fix.

**Interface implication:** none.

**Owner verdict:** _pending_

## LOW

### DPDC-S · L1 — zero REPL coverage for the entire Make/Break round trip and every admin mutation `[CONFIRMED]`

See Auditor method above — directly explains why C1/C2 shipped undetected.

**Fix direction:** add integration REPLs mirroring `[6.2.1]_AQP-ANK.repl`'s canonical layout: Primordial SFT
make→break, Composite SFT make→break (specifically probing an invalid `allowed-sclass=0` per C2), Hybrid SFT
make→break, NFT make→break, plus dedicated single-tx tests for `C_ToggleSet`/`C_RenameSet`/
`C_UpdateSetMultiplier`/`C_EnableSetClassFragmentation`.

**Interface implication:** none — test-only.

**Owner verdict:** _pending_

### DPDC-S · L2 — empty set-definitions crash with an opaque index-out-of-bounds error instead of a clean `enforce`; no upper bound exists either `[CONFIRMED, reproduced against pact 5.4]`

**Location:** the `(enumerate 0 (- (length X) 1))` idiom used throughout. Reproduced: `(enumerate 0 -1)`
does **not** return `[]` — it returns `[0, -1]`. A zero-length `set-definition` makes the next `(at idx ...)`
throw an opaque out-of-bounds error rather than a clear message (fails closed, not exploitable, but
confusing). No upper bound on definition length either — an unreasonably large definition could push
Make/Break gas past the practical ceiling, permanently bricking that set-class for its owner.

**Fix direction:** add explicit `(enforce (> (length set-definition) 0) ...)` (and a documented upper bound)
ahead of the enumerate-based folds.

**Interface implication:** none.

**Owner verdict:** _pending_

### DPDC-S · L3 — `URC_NoncesSummedScore` sums raw constituent scores, silently discarding any set-multiplier a constituent nonce itself carries `[PLAUSIBLE]`

**Location:** `URC_NoncesSummedScore` (415-435), used by `C_MakeNonFungibleSet` (798), calls
`UR_N|RawScore`, not this module's own `UR_N|Score` (which applies a constituent's own multiplier if it's
itself a previously-made set nonce). May be intentional (avoid double-multiplication) but undocumented and
untested for nested-set composition.

**Fix direction:** document intended semantics in `@doc`; switch to `UR_N|Score` if the multiplier should
propagate.

**Interface implication:** none.

**Owner verdict:** _pending_

---

# MODULE: DPDC-I (`04_DPDC-I.pact`) — collection genesis / issuance

**Auditor method:** genesis-state correctness focus (bad initial state propagates to every nonce ever minted
under a collection). `[2.1]_DpdcCore.repl` only loads the module (no assertions); `[6.1]_DPDC.repl` never
calls the issuance entrypoints at all — the only place `C_IssueDigitalCollection` is exercised is the
genesis bootstrap `[4.0]_Sovereign-Executor.repl`, which has no per-field/per-balance assertions on the
outcome. None of the findings below are caught by any existing test.

## HIGH

### DPDC-I · H1 — NFT issuance is always billed at the (cheaper) SFT KDA price; the `if son` branch is dead code `[CONFIRMED]`

**Location:** `04_DPDC-I.pact:188-193`:
```pact
(kda-cost:decimal (if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpsf")))
```
Both branches query the same `"dpsf"` key. Genesis price table: `"dpsf"=0.4`, `"dpnf"=0.5`
(`REPL/Stage_01/[4.0]_Sovereign-Executor.repl:233-234`). Talos wrappers document the intended split
explicitly: `01_TS02-C1.pact:427-428` (`DPSF|C_Issue`, "400 KDA"), `02_TS02-C2.pact:375-376`
(`DPNF|C_Issue`, "500 KDA"). `[4.0]_Sovereign-Executor.repl:1275` independently computes the *expected* NFT
cost using `"dpnf"` when signing the `coin.TRANSFER` cap — the test author's own model disagrees with the
module under test; because signed caps are only an upper-bound allowance, the under-collection is silently
absorbed and no test fails.

**Failure scenario:** every NFT collection ever issued via the blessed path is billed the SFT price instead
of the documented NFT price — a guaranteed, silent, 20% protocol-revenue shortfall on the entire NFT product
line, with nothing in the returned `OutputCumulator` to flag it.

**Fix direction:** `(if son (ref-DALOS::UR_UsagePrice "dpsf") (ref-DALOS::UR_UsagePrice "dpnf"))`.

**Interface implication:** none — internal to `C_IssueDigitalCollection`'s body.

**Owner verdict:** _pending_

### DPDC-I · H2 — NFT genesis issuance (owner == creator) silently denies the owner the `role-modify-royalties`/`role-exemption`/`role-modify-creator` grants that VerumRoles says they have `[CONFIRMED]`

**Location:** `04_DPDC-I.pact:280-291` (NFT branch, owner==creator, `Account`-table roles written) vs.
`373-385` (VerumRoles written for the same account, claiming the opposite) vs. the symmetric, correct SFT
branch (239-251). NFT branch sets `role-modify-creator`/`role-modify-royalties`/`role-exemption` all
`false` for `owner-account` while VerumRoles lists `oa` (the owner) for those same slots.

**What's wrong:** the real enforcement path (`10_DPDC-N.pact:158-183` → `02_DPDC.pact:605-607`
`UR_CA|R-ModifyRoyalties`) gates royalty updates **exclusively** by the `Account` table's flag, not
VerumRoles (VerumRoles only feeds a writer, never gates anything). So the `Account`-table value DPDC-I
writes is the one that matters, and for a freshly issued NFT collection with owner==creator (the most common
issuance shape), that value is `false`.

**Failure scenario:** a solo creator issuing their own NFT collection cannot set royalties on any nonce they
mint until they notice and self-correct via `DPDC-R::C_ToggleModifyRoyaltiesRole` — an extra, non-obvious
paid transaction. Nothing in issuance surfaces this; the `OutputCumulator` reports success. Bad initial
state propagates to every nonce minted before the owner discovers and fixes it.

**Fix direction:** in the NFT owner==creator branch (280-291), set `role-exemption`/`role-modify-creator`/
`role-modify-royalties` to `true` for `owner-account`, mirroring the SFT branch and the VerumRoles state
already written.

**Interface implication:** none — internal to `C_IssueDigitalCollection`'s body.

**Owner verdict:** _pending_

## MEDIUM

### DPDC-I/U|DALOS · M1 — collection id is deterministic per-block, not per-tx; same-block same-ticker issuance is predictable and hard-aborts instead of being validated `[CONFIRMED]`

**Location:** `04_DPDC-I.pact:315` → `U|DALOS::UDC_Makeid` (`08_U_DALOS.pact:481-491`), built from
`ticker + "-" + (take 12 prev-block-hash)`. `prev-block-hash` is block-level, identical for every tx in the
same block — not a per-tx nonce. No existence check before returning; the only backstop is Pact's native
`insert` inside `XE_I|Collection`/`XE_I|VerumRoles`, which hard-aborts the whole tx (atomic, no partial
state) on collision with a raw "row found" error rather than a graceful message.

**Failure scenario:** two `C_IssueDigitalCollection` calls with the same ticker landing in the same block
(concurrent users, a retry-bot, or an adversary reading the mempool/current `prev-block-hash` and
deliberately submitting a matching ticker) produce byte-identical ids; the second dies on `insert` with an
opaque error rather than "ticker already used this block, retry" — a real (if not cheap) griefing/DoS
surface.

**Fix direction:** mix in a per-tx-unique component (`tx-hash`, or fold in `owner-account`/a monotonic
counter) so same-block issuances can't collide; add a pre-check `UEV_*` with a clear message ahead of the
raw `insert` abort.

**Interface implication:** none — `UDC_Makeid` is an internal Stage-1 `U|DALOS` helper, no signature change
needed.

**Owner verdict:** _pending_

## LOW

### DPDC-I · L1 — `creator-account` is bound into the collection with no ownership/consent check `[CONFIRMED]`

**Location:** `DPDC-I|C>ISSUE` (`04_DPDC-I.pact:120-133`) only validates `creator-account`'s type/prefix
(`UEV_EnforceAccountType`), never ownership — contrast `owner-account`, which goes through real
`CAP_EnforceAccountOwnership`. Any signer who owns `owner-account` can name an arbitrary third-party
`creator-account`, which then receives real collection-admin permissions (create/recreate/modify-royalties/
modify-creator/set-uri/exemption) with no consent or signature from that account.

**Failure scenario:** no direct fund loss to the named creator, but enables impersonation/reputational abuse
(naming a well-known account as "creator" of an unrelated/scam collection) and silently grants real on-chain
admin powers to an unconsenting account.

**Fix direction:** require a `creator-account` signature capability if consent is meant to matter, or
document the deliberate asymmetry with `owner-account` explicitly.

**Interface implication:** a consent-enforcement fix would add a signature-capability requirement to
`C_IssueDigitalCollection`; a documentation-only fix needs none.

**Owner verdict:** _pending_

### DPDC-I · L2 — `C_DeployAccountSFT`/`C_DeployAccountNFT` carry no `UEV_IMC`, no capability, and no `@doc` explaining the intentionally-permissionless design `[CONFIRMED, verified non-exploitable]`

**Location:** `04_DPDC-I.pact:148-165` — bare wrappers, zero local authorization, forward directly to
`XB_DeployAccountSFT`/`NFT` with all role flags hardcoded `false`. Traced the actual write path:
`XB_DeployAccountSFT`/`NFT` (`02_DPDC.pact:1077-1134`) are existence-gated (collection must already exist)
and use `with-default-read` + `write`, where the default is only used when the row is absent — if the row
exists, stored values are read back and rewritten verbatim, ignoring the new call's args. Combined with both
accounts being deployed synchronously in the same atomic tx as issuance, there's no window for a third party
to pre-seed a garbage row before the legitimate deploy. **No exploit found.**

**Fix direction:** add a one-line `@doc` on both functions documenting they're intentionally
permissionless self-registration wrappers, safe because the callee is existence-gated and idempotent. No
behavioral change required.

**Interface implication:** none — documentation only.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no royalty/supply-cap fields exist at genesis to validate
(royalty is set later, out of scope); double-issuance silently overwriting genesis state does **not** happen
(`insert` hard-aborts the whole tx on collision — see M1 for the real underlying weakness, which is
id-collision/DoS, not silent overwrite); `XI_IssueDigitalCollection`'s defcap is confirmed the sole gate, no
stray `enforce` in the body; SFT vs NFT validation is identical in the master defcap (asymmetries that exist
are in the body — H1, H2).

---

# MODULE: DPDC (`02_DPDC.pact`) — shared account/collection core (10 tables, the widest fan-out in the family)

**Auditor method:** traced all 11 registered IMC peers' actual calls into DPDC's `XE_*` write-forwarding
surface; SFT-vs-NFT symmetry checked module-wide including the branding surface most other auditors didn't
cover. `pact` binary unavailable in this auditor's sandbox — findings are static-trace-derived.

## HIGH

### DPDC · H1 — Talos's DPSF branding-update call passes 7 args to DPDC's 6-param `C_UpdatePendingBranding`; SFT branding updates are unconditionally broken, and the NFT sibling proves it `[CONFIRMED]`

**Location:** `02_DPDC.pact:1041-1056` (`C_UpdatePendingBranding`, implementing
`BrandingUsageTertiaryV1.C_UpdatePendingBranding` — 6 params: `entity-id son logo description website
social`, **no `patron`**); `3_Talos/01_TS02-C1.pact:339-351` (`DPSF|C_UpdatePendingBranding`) calls it with
**7** positional args (`patron entity-id true logo description website social`) vs. the correct NFT sibling
`3_Talos/02_TS02-C2.pact:288-301`, which passes exactly 6. Textbook SFT-vs-NFT duplication bug — almost
certainly copy-pasted from the neighboring `C_UpgradeBranding`, which genuinely does take `patron` as its
first parameter, unlike `C_UpdatePendingBranding`. Compounding: both wrappers type `ref-DPDC` as
`module{DpdcV1}`, yet `C_UpdatePendingBranding`/`C_UpgradeBranding` are declared only on
`BrandingUsageTertiaryV1` (confirmed by full read of `DpdcV1`'s interface body — zero `C_*` members) — a
separate open question about whether `::` even resolves, independent of the arity bug.

**Failure scenario:** any collection owner calling the blessed Talos path
`DPSF|C_UpdatePendingBranding` — the only supported client entrypoint — gets a hard abort on every single
invocation, 100% of the time. The feature is paid (400 IGNIS) and completely non-functional for every DPSF
collection ever issued. Never caught because `[6.1]_DPDC.repl`/`[2.1]_DpdcCore.repl` contain **zero** calls
to `C_UpdatePendingBranding`/`C_UpgradeBranding` for either class (confirmed via grep).

**Fix direction:** drop the stray `patron` from `01_TS02-C1.pact:348` to mirror `02_TS02-C2.pact:297`
exactly. Separately verify (via a real `pact` run) whether a `BrandingUsageTertiaryV1`-only member resolves
through a `module{DpdcV1}`-typed ref; if not, retype the `let` binding at both Talos call sites. Add a REPL
scenario exercising both branding client paths so this class of bug fails loudly in CI going forward.

**Interface implication:** none needed on `BrandingUsageTertiaryV1`/`DpdcV1` — caller-side arg-count bug,
not an interface defect. Any ref-retyping fix is Talos-local, doesn't cascade into DPDC's interfaces.

**Owner verdict:** _pending_

### DPDC · H2 — the shared `XE_*` write-forwarding surface (Properties/Nonces/AccountSupplies) performs zero value-level validation; every core invariant is enforced only ad-hoc by whichever of 11 registered peer modules happens to call it `[CONFIRMED]`

**Location:** `02_DPDC.pact:1169-1253` (`XE_I|Collection`, `XE_U|Specs`, `XE_U|IsPaused`,
`XE_U|NoncesUsed`, `XE_U|SetClassesUsed`, `XE_I|CollectionElement`, `XE_U|NonceSupply`,
`XE_U|NonceHolder`, `XE_U|NonceOrSplitData`, `XE_I|VerumRoles`) and `1482-1502` (`XE_W|Supply`) — all
follow `(UEV_IMC)` then a raw `insert`/`update`/`write`, no defcap, no bound-checking on the value written.

**What's wrong:** `(UEV_IMC)` only proves the caller **module** is a registered peer (11 of them:
`DPDC-C`/`-I`/`-R`/`-MNG`/`-S`/`-F`/`-N`, `EQUITY+`, `Demipad`, `TS02-C1`, `TS02-C2`) — it proves nothing
about the **value** being written. `XE_U|NoncesUsed id son new-nv` writes `{"nonces-used": new-nv}` for
*any* integer — no enforcement it equals `current+1`, is monotonic, or non-negative; only caller discipline
(today, a single caller passing the right value) keeps it correct. `XE_W|Supply` writes an **absolute**
supply value with no `>=0` check and no reconciliation against the collection-level total; its actual
sufficiency check is fully delegated to `DPDC-C`'s defcaps, which today do it correctly for every debit path
traced — but `DPDC-T`'s own `UEV_AmountsForTransfer` computes `nonce-supply` and **never uses it in any
enforce** (only checks NFT `amount=1`) — a live instance of the AQP audit's "computed but never enforced"
dead-validation class, proving DPDC-T's layer provides zero independent backstop; it's currently safe only
because DPDC-C's separately-composed cap happens to re-derive the same check.

**Failure scenario:** any future (or currently-overlooked) code path among 11 registered peers that calls
`XE_W|Supply`/`XE_U|NonceSupply`/`XE_U|NoncesUsed` without independently re-implementing the
sufficiency/monotonicity check — plausible in a 10-file, heavily-duplicated SFT/NFT codebase — silently
corrupts shared state: negative `AccountSupplies.supply`, a `nonce-supply` no longer matching the sum of
account supplies, or a colliding/skipped nonce id. Since these are the only persistence paths for these
tables and DPDC itself asserts nothing, there is no defense-in-depth — every conservation invariant for the
shared core rests entirely on caller discipline living outside this file.

**Fix direction:** for `XE_U|NoncesUsed`, enforce `new-nv = current+1` inside the function. For
`XE_W|Supply`, enforce `amount >= 0` at minimum, ideally switch to a signed-delta argument so DPDC itself
can derive and enforce `new-supply = current+delta >= 0`. For DPDC-T's dead `nonce-supply` binding: wire it
into a real enforce, or remove the unused binding so the function doesn't advertise a check it doesn't
perform.

**Interface implication:** `enforce` additions inside existing bodies don't change any `DpdcV1` signature.
Switching `XE_W|Supply` to delta-based **would** be a breaking signature change requiring the cascade rule
— doable in place under current V1-until-mainnet policy.

**Owner verdict:** _pending_

## MEDIUM

### DPDC · M1 — `URD_AccountNoncesWithSupplies` returns `[{}]` instead of `[]` on empty results, producing a wrong non-zero count and malformed rows for consumers `[CONFIRMED]`

**Location:** `02_DPDC.pact:705-724`. Sole consumer: `2_CITIZEN/Stage_Z/01_DPL-UR.pact:1963-1976`. When an
account holds zero nonces, returns `[{}]` (a one-element list of an empty object) instead of `[]` —
inconsistent with the sibling `URD_AccountNonces` (680-704), which correctly returns `[]`.

**Failure scenario:** `01_DPL-UR.pact:1968-1973` reports `"wallet-nonces-no": (length wallet-nonces)` — for
an account holding zero nonces, `length` returns `1`, not `0`; any wallet/marketplace UI built on this
dirty-read reports a phantom nonce, and the returned object lacks `"nonce"`/`"supply"` keys, throwing for
any stricter consumer indexing into it.

**Fix direction:** return `[]` for the empty case, mirroring `URD_AccountNonces`.

**Interface implication:** none — return element type on `DpdcV1` unaffected.

**Owner verdict:** _pending_

### DPDC · M2 — `XB_DeployAccountSFT`/`XB_DeployAccountNFT` never verify the caller controls `account`; combined with an unauthenticated Talos/`DPDC-I` wrapper, any signer can force any existing account to associate with any collection `[CONFIRMED chain, PLAUSIBLE impact]`

**Location:** `02_DPDC.pact:1077-1134`, gated only by `UEV_IMC` + account-exists + collection-exists
(existence, not ownership). Chain: `04_DPDC-I.pact:148-165` (`C_DeployAccountSFT`/`NFT` — zero
`with-capability`, zero `UEV_IMC`, entirely naked) ← `3_Talos/01_TS02-C1.pact:405-419`/
`02_TS02-C2.pact:353-368` (gated only by global-admin-pause, no `CAP_EnforceAccountOwnership account`).

**What's wrong:** the write itself is idempotent-safe (`with-default-read` re-persists existing values
verbatim on repeat calls — not an overwrite bug). But nowhere in `Talos → DPDC-I → DPDC` is there any check
the signer owns `account`. Any signer can call `DPSF|C_DeployAccount patron <victim> <any existing id>` for
an arbitrary victim account.

**Failure scenario:** an attacker enumerates existing ids and forces every known account to "associate"
with each one — a persistent, non-deletable `Account` row with all-false roles for a victim who never opted
in. No funds/permissions granted, but unrequested state written against a victim's identity (attacker pays
the IGNIS) — a state-bloat/griefing vector polluting any indexer built on `URD_HeldCollectables`/
`URD_ExistingCollectables`.

**Fix direction:** if self-service association is intentional, require the target account's own guard (
`CAP_EnforceAccountOwnership account` or explicit opt-in) inside a proper defcap wrapping
`XB_DeployAccountSFT`/`NFT`; give `DPDC-I`'s deploy functions real cap wiring (currently none at all).

**Interface implication:** none required on `DpdcV1` itself — fix adds authorization inside existing
bodies/callers.

**Owner verdict:** _pending_

### DPDC · M3 — `AUP_Account`/`AUP_Property` admin-migration helpers slice composite keys with hardcoded offsets instead of the BAR-delimiter split used everywhere else in the file `[PLAUSIBLE]`

**Location:** `02_DPDC.pact:1599-1605` (`AUP_Account`): fixed negative-offset slicing assuming the
`account` component is always exactly 162 characters, instead of `U|LST::UC_SplitString BAR ky` (used two
functions above it, `AUP_SFTs`/`AUP_NFTs`). Ouronet accounts aren't fixed-width; any non-standard-length
account silently produces a wrong `id`/`account` pair with no error.

**Failure scenario:** an admin migration run over keys with non-standard-length accounts corrupts those
rows' Select-Key fields silently, breaking `URD_HeldCollectables`/`URD_ExistingCollectables` filtering for
the affected rows with no failure signal at migration time.

**Fix direction:** replace fixed-offset slicing with `U|LST::UC_SplitString BAR ky`.

**Interface implication:** none — internal admin-only helper, not part of `DpdcV1`.

**Owner verdict:** _pending_

## LOW

### DPDC · L1 — `UR_AS-KEYS` performs a full table scan (`keys`) but is named with the point-read `UR_` prefix instead of `URD_` `[CONFIRMED]`

**Location:** `02_DPDC.pact:347-349` — `(keys Table)` scan named `UR_`, breaking the prefix contract
(only ever invoked manually off-chain per its own doc comment, feeding `AUP_*` admin tooling — no
execution-path/gas risk, pure naming violation).

**Fix direction:** rename to `URD_AS-Keys` to match the file's other `URD_*` scan functions.

**Interface implication:** none — not currently on `DpdcV1`.

**Owner verdict:** _pending_

### DPDC · L2 — `DPNF|AccountRoles` schema doc states the wrong composite-key field order, contradicting both `DPSF|AccountRoles`'s doc and the actual, consistently-used code `[CONFIRMED]`

**Location:** `0_Interfaces/02_Core.pact:101-102` (`DPSF|AccountRoles` doc: `<id> + BAR + <account>`) vs.
`:111-112` (`DPNF|AccountRoles` doc: `<account> + BAR + <DPNF-id>` — reversed). Actual key construction in
`02_DPDC.pact` is `(concat [id BAR account])` uniformly for **both** tables. Pure documentation defect (no
code reads the docstring to build keys) but sits in the shared interface every DPDC-* module and future
citizen integrator reads.

**Fix direction:** correct the `@doc` on `DPNF|AccountRoles` to match `DPSF|AccountRoles` and the real code.

**Interface implication:** doc-only, no cascade.

**Owner verdict:** _pending_

### DPDC · L3 — test-coverage gaps: branding functions and NFT-side duplication are essentially unexercised by the REPL suite `[CONFIRMED via grep]`

**Location:** `C_UpdatePendingBranding`/`C_UpgradeBranding` — zero calls in either DPDC REPL file (exactly
why H1 was never caught). `AUP_*` admin-migration functions — zero test coverage. SFT vs NFT coverage
starkly asymmetric: `[6.1]_DPDC.repl` exercises dozens of `DPSF|C_*` scenarios (pause, add-quantity,
freeze, exemption, burn, update, role toggles, nonce metadata/royalty updates, wipe, transfer, fragment)
while `DPNF|C_*` gets exactly **one** exercised call (`DPNF|C_TransferNonce`) plus one commented-out
(`DPNF|C_Repurpose`) — given the file's "same logic implemented twice per class" architecture (the single
most likely bug source per this audit's brief), the entire NFT-side duplicate of every SFT-tested path is
effectively unverified.

**Fix direction:** add REPL scenarios for both branding client paths (would have caught H1 immediately);
bring `DPNF|C_*` coverage up to parity with `DPSF|C_*` so SFT-vs-NFT asymmetries are caught mechanically.

**Interface implication:** none — test-only.

**Owner verdict:** _pending_

**Not found / explicitly checked and cleared:** no CRITICAL findings in `02_DPDC.pact` itself — the nearest
candidate (M2's account-deploy path) is non-destructive on correct reading of `with-default-read` semantics
(re-persists existing values verbatim on repeat calls, not an overwrite-with-defaults bug).

---

**ROUND I STATUS: all 11 module passes landed.** This file is now frozen pending `ISSUES-RANKED.md`
compilation and owner review — see `README.md` for the cycle tracker.
