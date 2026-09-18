# ROUND II — Fixes (DALOS-audit modules)

One entry per fix, applied sequentially, owner green-lit before landing. Diff summary + why + REPL proof.

## Fix #1 — #2C: `DPOF|C_MoveCreateRole` never revoked the create role from the previous holder

**What it was:** `C_MoveCreateRole` (`06_DPOF.pact:1894-1913`) called `XI_UpdateVerum4` (writes the new
"current holder of record") **before** `XI_SwitchCreateRole` (which is supposed to set the old holder's
`role-oft-create` flag to `false` and the new holder's to `true`). `XI_SwitchCreateRole` derives "who is
the old holder" itself, internally, via `(UR_Verum4 id)` — but by the time it ran, that read already
reflected the *new* holder (because `XI_UpdateVerum4` had already overwritten it), so both of
`XI_SwitchCreateRole`'s writes landed on the new holder's own row (set false, then immediately true — a
no-op), and the real previous holder's flag was never touched. Every past holder of a DPOF's create role
kept mint access forever, regardless of how many times the role was "moved" away from them.

**Owner confirmed the intended semantics before this fix landed:** "the moving itself is the revoking for
the old user... that's how it should function" — i.e. `C_MoveCreateRole` is meant to be one atomic
grant-and-revoke, not grant-only. This matches what the master defcap (`DPOF|S>X_SWITCH-CREATE-ROLE`)
already does correctly — it computes `current` (the real old holder) from pre-write state — but that
correct value was never threaded through to the `XI_` writer, which re-derived (incorrectly) its own copy.

**Fix:** reordered the two calls inside `C_MoveCreateRole` — `XI_SwitchCreateRole` now runs *before*
`XI_UpdateVerum4`, so its internal `(UR_Verum4 id)` read still sees the real old holder when it computes
which account's flag to clear. No signature changes, no interface changes; both functions are called from
exactly one place each (`C_MoveCreateRole`), confirmed by grep, so the reorder is fully self-contained.

```pact
;;Deploy WNE
(XB_DeployAccountWNE receiver id)
;;Update Account Roles — MUST run before Verum Roles below: XI_SwitchCreateRole
;;reads the CURRENT (pre-write) Verum4 internally to find the account to revoke.
;;Running XI_UpdateVerum4 first would overwrite that value to <receiver> before
;;XI_SwitchCreateRole ever reads it, so the real previous holder would never be
;;revoked (DALOS audit #2C).
(XI_SwitchCreateRole id receiver)
;;Update Verum Roles
(XI_UpdateVerum4 id receiver)
;;Output
(ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
```

**Verification methodology (adversarial, per the ATS/SWP-audit discipline):**
1. Built a standalone scratch REPL harness, `REPL/_scratch_dpof_c2_moverole.repl` (Stage00 sandboxes →
   Stage01 prefix through `[5.1]_Aoz+.repl`, real Pact 5.4, kept in the repo as a re-runnable proof
   artifact, mirroring `_audit_ats_baseline.repl`'s precedent).
2. Issued a fresh DPOF id (`AC2T-98c486052a51`) owned by `emma`, with `can-transfer-oft-create-role=true`.
3. Moved the create role twice: `emma` (owner) → `aoz`, then `aoz` → `patron` (ANHD). The second move is
   the real test — `aoz` is a genuine non-owner previous holder, so `UR_R-Create`'s
   `account == owner-konto` OR-clause can't mask the result the way it would for the owner account itself.
4. **Pre-fix run:** `UR_R-Create(id, aoz)` after the second move printed `true` (should be `false`) and the
   REPL's own `(expect false ...)` assertion failed live:
   `FAILURE: aoz (previous holder, non-owner, moved AWAY from) must NOT retain create role - #2C expected: false, received: true`
5. Applied the fix (reorder above).
6. **Post-fix run, identical harness, unmodified:** `UR_R-Create(id, aoz)` now printed `false`, every
   `expect` in the file passed, and the file reported `Load successful`. Both the granting behavior (new
   holder correctly gets the role after each move) and the revoking behavior (old holder correctly loses
   it) are proven in the same run.
7. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures anywhere in the whole Stage 1 + Stage 2 suite (grepped for `FAILURE`
   outside of intentional `expect-failure` doc-string labels — none found).

**Status:** FIXED ✅ AND PROVEN ✅ (adversarial pre/post-fix repro, full-suite regression clean).

## Fix #2 — N1 (discovered live while building Fix #3's proof): `C_Transmit` completely non-functional

**What it was:** `DPOF|C>TRANSMIT`'s defcap (`06_DPOF.pact:756`) read `(at "meta-data" td)`, but the
`TransmitData` schema's real field is `meta-data-array` (confirmed in both the `defschema` and the object
constructor `UDCX_TransmitData`, which correctly builds `"meta-data-array"`). Every call to `C_Transmit`
— core or via the Talos `TS01-C1::DPOF|C_Transmit` wrapper — crashed unconditionally with `Key "meta-data"
not found`, for any input, unrelated to nonce duplication. This has nothing to do with #3C's bug; it was
discovered purely because building #3C's REPL proof required a *working* `C_Transmit` call to test
duplicated nonces against, and the very first ordinary, non-duplicated call already crashed.

**Fix:** one-string change — `"meta-data"` → `"meta-data-array"`.

```pact
(meta-data-array:[[object]] (at "meta-data-array" td))
```

**Verification methodology:**
1. Built a dedicated scratch harness, `REPL/_scratch_dpof_transmit_metadata_bug.repl` (same
   Stage00/Stage01 prefix), issuing a fresh DPOF id and minting one ordinary, non-duplicated nonce, then
   calling `C_Transmit` with a single plain (non-duplicated) nonce/amount — deliberately isolated from
   #3C's duplicated-nonce scenario.
2. **Pre-fix run:** crashed exactly as diagnosed — `Key "meta-data" not found in object: {...}`, `Load
   failed`.
3. Applied the fix.
4. **Post-fix run, identical harness, unmodified:** `Load successful` — the Transmit correctly split
   nonce 1 (100.0 → 60.0 remaining + a new 40.0 nonce credited to the receiver), all three balance
   assertions matched exactly.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (broken pre-fix, working post-fix, full-suite regression clean).

## Fix #3 — #3C: DPOF nonce-uniqueness gap (whole-nonce transfer inflation + negative nonce-supply corruption)

**What it was:** none of `DPOF|C>TRANSFER`, `DPOF|C>BULK-TRANSFER`, or `DPOF|C>DEBIT` validated that a
caller-supplied `nonces:[integer]` list contained no duplicates, despite a sibling capability
(`DPOF|S>BULK-MOVE`) already using exactly this pattern (`UC_IzUnique`) for its receiver list. This
enabled two independent corruption mechanisms:
- **(a) Whole-nonce transfer inflation:** `XI_TransferWholeNonces` sums a nonce's supply once per list
  entry but only moves the nonce once, so `C_Transfer id [N,N] sender receiver method` fabricates 2×
  the nonce's real value into `total-account-supply` — a field `07_ELITE.pact` reads directly for
  Elite-tier eligibility.
- **(b) Negative nonce-supply corruption:** `DPOF|C>DEBIT`'s per-index `(<= amount nonce-supply)` checks
  run before any writes (against the same stale value for every repeated index), but `XI_DebitNonces`
  writes sequentially and re-reads `nonce-supply` per iteration — so a repeated nonce with amounts that
  each individually pass but cumulatively exceed the real supply drives that nonce's stored `supply`
  negative, directly violating the code's own "Cannot Debit into the Negatives" enforce message.

**Owner confirmed the fix direction:** nonce lists must obviously be unique.

**Fix:** added `(ref-U|LST::UC_IzUnique ...)` gates, mirroring `BULK-MOVE`'s existing convention, to all
three defcaps — `DPOF|C>DEBIT` (covers `C_Transmit`/`C_WipePure`/`C_WipeClean`/etc. uniformly, since all
of them compose this one shared gate), `DPOF|C>TRANSFER`, and `DPOF|C>BULK-TRANSFER` (checked against the
**full flattened** nonce set across all receiver legs, not just per-leg, since the same nonce appearing
in two different legs is an equally real fabrication vector). `UC_IzUnique` is `[string]`-typed, so each
integer nonce list is stringified first (`(map (lambda (n:integer) (int-to-str 10 n)) nonces)`).

```pact
;;DPOF|C>DEBIT, after the length-parity enforce:
(ref-U|LST::UC_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))

;;DPOF|C>TRANSFER, after CAP_EnforceAccountOwnership:
(ref-U|LST::UC_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))

;;DPOF|C>BULK-TRANSFER, after the leg-count enforce, against the flattened set:
(ref-U|LST::UC_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) all-nonces))
```

**Verification methodology (adversarial):**
1. Built `REPL/_scratch_dpof_c3_noncedupe.repl`. While constructing test (b) against `C_Transmit`,
   surfaced the unrelated N1 bug above (fixed first, separately, so it wouldn't block this proof).
2. Issued a fresh DPOF id, minted nonce 1 (100.0) and nonce 2 (50.0) to the owner.
3. **Pre-fix run** (both `UC_IzUnique` gates temporarily commented out by hand — never via git
   stash/reset, per the SWP audit's own documented lesson about shared-worktree data loss): (a)
   `C_Transfer id [1,1] ...` succeeded and fabricated the sender's balance to **-50.0** and the
   receiver's to **200.0** (real nonce value was 100.0); (b) `C_Transmit id [2,2] [30.0,30.0] ...`
   succeeded and drove nonce 2's supply to **-10.0** (real supply was 50.0). Both reproduced exactly as
   diagnosed.
4. Restored both gates (removed the temporary comments — confirmed via grep no `TEMP-REVERT-FOR-PROOF`
   markers remained).
5. **Post-fix run, identical harness, unmodified:** both duplicated-nonce calls now rejected outright
   (`expect-failure` passes), both balances/supply unchanged from their pre-attempt values, and a
   regression check confirmed a legitimate **non-duplicated** `C_Transfer [1]` still works correctly
   (real 100.0 credited, not fabricated).
6. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures anywhere in the whole Stage 1 + Stage 2 suite.

**Status:** FIXED ✅ AND PROVEN ✅ (adversarial pre/post-fix repro for both sub-mechanisms, full-suite
regression clean).

## Fix #4 — #5C: INFO-ONE `DPOF|INFO_UpgradeBranding` doubled-prefix typo

**What it was:** `21_INFO-ONE+.pact:1328` called `ref-I|OURONET::OI|OI|UDC_DynamicKadenaCost` — a doubled
`OI|` prefix. `OuronetInfoV1` only declares `OI|UDC_DynamicKadenaCost` (single prefix); every other ~40
call site in the file, including the structurally identical `DPTF|INFO_UpgradeBranding` right above it,
uses the correct single-prefix name. Owner confirmed: "most likely a typo, OI typed 2 times."

**Fix:** one-string change.

```pact
(ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_UpgradeBranding months))
```

**Verification methodology:**
1. Built `REPL/_scratch_infoone_c5_upgradebranding.repl` — INFO-ONE has no capabilities/tables, so the
   broken function could be called directly with no setup beyond genesis price seeding.
2. **Pre-fix run:** `Load failed` — `Fatal execution error, invariant violated: Unbound free variable
   ouronet-ns.INFO-ZERO.OI|OI|UDC_DynamicKadenaCost`, exactly as diagnosed.
3. Applied the fix.
4. **Post-fix run, identical harness, unmodified:** `Load successful` — returns a correctly-formed
   `ClientInfo` object with the right pre-text, post-text, and Kadena cost breakdown.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (broken pre-fix, working post-fix, full-suite regression clean).

## Fix #5 — #7H: `GLYPH|UEV_MsDc` charset-validation fold inverted (OR/false instead of AND/true)

**What it was:** `1_Utilities/08_U_DALOS.pact:368-388` — the fold combining per-character
`DALOS|CHARSET` membership was seeded `false` and combined with `or`, so it returned `true` as soon as
**any single character** matched, instead of requiring **every** character to. All four call sites
(`GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_DalosAccount`, `GLYPH|UEV_ApolloAccountCheck`,
`GLYPH|UEV_ApolloAccount`) pass it the entire 160-character account body and either `enforce` the result
directly or fold it with other whole-string checks (length=162, prefix, separator) — confirming the
intended contract really is "every character of this whole string must be in-charset," not a per-character
helper. `DALOS|CHARSET` is broad (digits + currency symbols + Latin/Greek/Cyrillic upper+lower), so in
practice almost any string contains at least one matching character — the intended "every character
conforms" invariant was close to a no-op.

**Fix:** seed `true`, combine with `and` — mirroring the already-correct sibling `UC_IzStoicTagName` in
the same file.

```pact
(and acc checkup)
;; ...
true
(enumerate 0 (- (length str-lst) 1))
```

**Verification methodology:**
1. Built `REPL/_scratch_udalos_h1_msdc.repl`.
2. **Pre-fix run:** `(GLYPH|UEV_MsDc "!@#$%^&*()_+-=[]{}5")` (18 garbage characters + one real digit)
   returned `true` — reproduced live, exactly as diagnosed.
3. Applied the fix.
4. **Post-fix run, identical harness, unmodified:** the same mostly-garbage input now correctly returns
   `false`; a genuinely all-valid string (`"Abc123XYZ"`) still returns `true` (regression guard) —
   `Load successful`.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (broken pre-fix, working post-fix, full-suite regression clean).

## Fix #6 — #8H: IGNIS `C_Collect` no per-leg zero/negative filter — one free leg aborted an otherwise-valid bundle

**What it was:** `02_IGNIS.pact` `C_Collect` compresses/primes a multi-leg `OutputCumulator` chain into
per-interactor `(interactor, amount)` pairs, then loops over every pair unconditionally, calling
`IGNIS|C>COLLECT` → `XI_IgnisCollector` → ultimately `IGNIS|C>TRANSFER`, which hard-enforces
`(> ta 0.0)`. Since an admin can legitimately price any billable action at `0.0` (no lower bound on
`A_UpdateUsagePrice`, a separate low-severity gap already on record), a bundled transaction containing one
free leg (to interactor A) alongside a normally-priced leg (to a *different* interactor B, so compression
can't merge them) would abort in full — the free leg's `0.0` amount hits the transfer enforce and takes
the whole batch down with it, including the legitimate paid leg.

**Owner confirmed the fix direction and the underlying architecture:** individual client functions each
emit their own `OutputCumulator`; functions composing several of them concatenate the cumulators; the
final combined cumulator is collected exactly once by the Talos layer via `C_Collect` — this is
deliberate, to avoid paying the ~4-5k gas cost of `C_Collect` multiple times per transaction. Given that
architecture, a per-leg free amount is a normal, expected case that must not crash the batch — and the
codebase already has a dedicated `IGNIS|S>FREE` event for "nothing to collect," which should extend to
this per-leg case too, not just the all-free case.

**Fix:** inside `C_Collect`'s per-leg loop, skip collection when `amount <= 0.0` and compose `IGNIS|S>FREE`
instead of `IGNIS|C>COLLECT`/`XI_IgnisCollector` for that leg — ties the per-leg free case into the same
event already used for the whole-transaction free case, so it's still observable on-chain, and uses `>`
(not `!=`) so a hypothetical negative amount is also treated as free rather than crashing.

```pact
(if (> amount 0.0)
    (with-capability (IGNIS|C>COLLECT patron interactor amount)
        (XI_IgnisCollector patron interactor amount)
    )
    (with-capability (IGNIS|S>FREE) true)
)
```

**Verification methodology (adversarial):**
1. Built `REPL/_scratch_ignis_h3_zeroleg.repl`, calling `IGNIS.C_Collect` directly with a manually
   constructed two-leg `OutputCumulator`: one leg priced `0.0` to one smart-account interactor, one leg
   priced `5.0` to a *different* smart-account interactor (two distinct non-`BAR` interactors, chosen
   specifically so priming's smart/tanker fee-split redistribution couldn't cross-contaminate the zero
   leg back to non-zero and accidentally mask the bug).
2. **Pre-fix run** (the `if` wrapper temporarily commented out by hand — never via git stash/reset):
   reproduced live — `Cannot debit|credit 0.0 or negative GAS amounts`, `Load failed`, the whole
   transaction aborted even though only one of its two legs was actually invalid.
3. Restored the fix (confirmed via grep no `TEMP-REVERT-FOR-PROOF` markers remained).
4. **Post-fix run, identical harness, unmodified:** `Load successful` — the patron was charged exactly
   the real leg's amount, the zero-priced interactor's balance was untouched (`0.0` delta), and the real
   interactor still received its normal fee-split cut.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`, exit
   code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (adversarial pre/post-fix repro, full-suite regression clean).

## Fix #7 — Optimization (owner-requested, not a Round-I finding): IGNIS Compress/Prime gas reduction

**Context:** raised by the owner while discussing #8H's fix, given the compress/prime/collect
pipeline runs on every billed transaction in the system (client functions each emit an
`OutputCumulator`; composing functions concatenate them; Talos collects exactly once via
`C_Collect`, specifically to avoid paying collection gas multiple times per transaction). Owner
asked whether `UDC_CompressOutputCumulator`/`UDC_PrimeIgnisCumulator` (the ~4-5k-gas-per-collect
functions) could be made cheaper, on the explicit condition that the output must be provably
identical to the original and the actual gas saving must be measured before landing — not a
correctness fix, no Round-I finding number.

**What was inefficient (not incorrect):**
1. Both functions used `U|LST::UC_Search` to answer "does this interactor/BAR key already exist in
   the accumulator, and at what index" — `UC_Search`'s actual contract (per its own doc, "returns a
   list of index") is to return **every** matching index via four full list passes (a `contains`
   scan, then unconditionally an `enumerate` + `zip` + another `contains`-based filter pass). Both
   call sites only ever needed the *first* index or "not found," never the full match list.
2. Both functions wrapped their running accumulator in a throwaway 1-element list purely to have a
   slot for `fold`'s accumulator, then called `U|LST::UC_ReplaceAt acc 0 (...)` every single
   iteration just to unwrap-and-rewrap that one element.

**Owner's explicit constraint, honored:** `U|LST::UC_Search` itself was **not** touched — it's a
long-standing utility ("taken from the util modules written by Kadena coders") whose real contract
(all matching indices) can't be safely narrowed without auditing every other caller in the codebase.
Instead, a new, small, local-only helper was added:

```pact
(defun UC_FindKeyIndex:integer (key-lst:[string] key:string)
    @doc "First index of key in key-lst, or -1 if absent. Single linear scan, local to the \
        \ compress/prime pipeline below ... NOT a general-purpose replacement for U|LST::UC_Search \
        \ ... which is different and untouched by this helper."
    (if (= (length key-lst) 0)
        -1
        (fold
            (lambda (found:integer idx:integer)
                (if (and (= found -1) (= (at idx key-lst) key)) idx found))
            -1
            (enumerate 0 (- (length key-lst) 1))
        )
    )
)
```

(Caught two real bugs while building this tiny helper, before it ever touched production code: a
parameter literally named `keys` fails to load — shadows a native Pact function of the same name —
and `(enumerate 0 (- (length key-lst) 1))` on an empty list evaluates to `(enumerate 0 -1)` = `[0,
-1]`, not `[]` — the exact same footgun class as #20H — so the empty-list case is explicitly
guarded rather than left to crash.)

`UDC_CompressOutputCumulator`/`UDC_PrimeIgnisCumulator` were then rewritten to use
`UC_FindKeyIndex` instead of `UC_Search`, and to fold the accumulator as a bare object instead of a
1-element list (removing the per-iteration `UC_ReplaceAt acc 0 (...)` unwrap/rewrap). Every branch
of the original logic (the four-way principal-exists × is-principal split in Prime, the
new-vs-merge split in Compress) was preserved exactly — only the search mechanism and the
accumulator shape changed.

**Verification methodology (equivalence + gas, per owner's explicit ask):**
1. Kept verbatim copies of the pre-optimization implementations, `UDC_CompressOutputCumulator_OLD`/
   `UDC_PrimeIgnisCumulator_OLD`, as temporary scaffolding alongside the new versions.
2. Built a scratch harness calling both old and new on identical inputs across a battery of
   realistic scenarios: single leg, 3 legs merging into one interactor, 8 legs across 5 distinct
   interactors (including `BAR`-routed legs and repeats), and a larger 20-leg/10-interactor batch.
   Every scenario: **byte-for-byte identical output**, confirmed via `expect`.
   (A genuinely-empty cumulator-chain was explicitly excluded from this battery — confirmed via a
   direct isolated check that both old and new crash on it identically, a pre-existing gap in the
   original code that no real caller ever triggers, not a regression from this change.)
3. Measured `env-gas` before/after for the compress+prime portion only (not the full `C_Collect`
   pipeline) on two batch sizes:

   | Batch | Old | New | Saved |
   |---|---|---|---|
   | 8 legs, 5 interactors | 596 | 561 | 35 (~6%) |
   | 20 legs, 10 interactors | 886 | 801 | 85 (~10%) |

   Savings scale up with batch size, consistent with the lower constant-factor cost per merge-check.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) — this is a meaningful check
   here specifically because Compress/Prime run on every billed operation in the whole suite;
   `Load successful`, exit code 0, no unexpected failures.
5. Removed the temporary `_OLD` scaffolding functions once the proof was complete and owner
   green-lit landing it; re-ran the full regression suite again post-removal — clean.

**Status:** LANDED ✅ AND PROVEN ✅ (owner-approved optimization, equivalence proven across multiple
scenarios and batch sizes, real measured gas savings, full-suite regression clean before and after
scaffolding removal).

## Fix #8 — #9H: DPTF `C_ToggleBurnRole`/`C_ToggleMintRole`/`C_ToggleFeeExemptionRole` missing `(UEV_IMC)`

**What it was:** three of the five "Toggle Verum" client recipes in `05_DPTF.pact` were missing
`(UEV_IMC)` as their first statement — unlike their two siblings (`C_ToggleFreezeAccount`,
`C_ToggleTransferRole`) and unlike every other `C_*` in the file. Confirmed via full repo-wide grep:
zero internal/home-module calls to these three exist anywhere — the only callers anywhere in the
codebase are cross-module `ref-DPTF::C_Toggle*Role` calls from the Talos wrapper
(`02_TS01-C1.pact`), exactly like their two correctly-gated siblings. Since neither DPTF nor TFT
independently check Global Administrative Pause (that only happens in the Talos wrapper), and IGNIS
billing also only happens there, a direct core-module call — signed only by the token owner —
bypassed Talos entirely: no pause check, no gas billing, nothing but plain `CAP_Owner`.

**Owner's process, before agreeing this was a bug (not just "different from siblings," per the
lesson from #6H):** confirmed neither of the two candidate "maybe intentional" explanations held —
(1) `UEV_IMC` has no place inside a capability in this codebase (confirmed: none of the five
`DPTF|C>TOGGLE-*`/`DPTF|C>FREEZE`/`DPTF|C>TOGGLE_TRANSFER-ROLE` defcaps reference it internally,
consistent across all five); (2) these are `C_*` functions meant to be reachable **only** via Talos
orchestration, never called from within DPTF's own module — confirmed by the grep above. Since
neither escape hatch applied, owner concluded: "it seems I simply forgot to add the line."

**Fix:** added `(UEV_IMC)` as the first statement of all three functions, matching their two
siblings exactly.

```pact
(defun C_ToggleBurnRole:object{IgnisCollectorV1.OutputCumulator}
    (id:string account:string toggle:bool)
    @doc "Toggle Verum 2"
    (UEV_IMC)
    (with-capability (DPTF|C>TOGGLE-BURN-ROLE id account toggle)
        ...
```
(same one-line addition to `C_ToggleMintRole` and `C_ToggleFeeExemptionRole`)

**Verification methodology (adversarial):**
1. Built `REPL/_scratch_dptf_h4_missing_imc.repl`, issuing a fresh DPTF id owned by `emma`.
2. **Pre-fix run:** direct core-module calls `(DPTF.C_ToggleBurnRole id emma true)` and
   `(DPTF.C_ToggleMintRole id emma true)` — bare calls, no Talos, no `ref-TS01-C1` involved at all —
   both succeeded outright, flipping the respective role states to `true`. Reproduced live.
   (`C_ToggleFeeExemptionRole`'s defcap separately requires its target account to be a
   genuinely-deployed Smart DALOS account, an unrelated precondition not part of this bug and not
   readily reproducible with this harness's fixtures — confirmed missing `UEV_IMC` by direct code
   read instead, byte-for-byte identical structure to its two live-reproduced siblings.)
3. Applied the fix (added `(UEV_IMC)` to all three).
4. **Post-fix run, identical harness (bare calls converted to `expect-failure` so the same file
   serves as a permanent regression artifact):** all three direct calls now correctly rejected
   before reaching any other check; role states left unchanged; the real Talos-routed path
   (`ref-TS01-C1::DPTF|C_ToggleBurnRole`/`C_ToggleMintRole`) still works normally.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (adversarial pre/post-fix repro for two of three functions live,
third confirmed by code-structure identity, full-suite regression clean).

## Fix #9 — #15H: INFO-ONE `ATS|INFO_Coil` third-leg wrong-token/reversed-direction cumulator

**What it was:** `21_INFO-ONE+.pact:1740-1744` — the third leg's classify call correctly computed
`wt3` from `(c-rbt ats-sc coiler c-rbt-amount)`, but the cumulator built from it used `rt` (the
original input token, wrong) with `coiler`/`ats-sc` reversed — a copy-paste of the first leg's line
with only the class-index variable updated. Proven a copy-paste bug (not intentional) by comparison
with the structurally identical, correctly-implemented fourth leg in the sibling function
`ATS|INFO_Curl` (`ref-TFT::UDC_TransferCumulator wt4 c-rbt2 ats-sc curler`).

**Owner context that reframed this cluster's whole "zero callers" observation:** `INFO_*` functions
are UI-facing preview endpoints called directly by the frontend, one per user-facing button — zero
on-chain callers is the expected, healthy state for this entire module, not evidence of dead code
(captured durably in `OuronetInformational/memories/2026-08-24-info-functions-are-ui-facing-not-dead-code.md`).
Owner's explicit verification requirement: "it has to be verified against the execution function to
output the same cost."

**Fix:** one-line correction to match the classify call and the correct sibling pattern.

```pact
(ref-TFT::UDC_TransferCumulator wt3 c-rbt ats-sc coiler)
```

**Verification methodology:**
1. Read the real execution function (`10_ATSU.pact::C_Coil`) directly to confirm the ground truth:
   its third leg really does `(ref-TFT::C_Transfer c-rbt ATS|SC_NAME coiler c-rbt-amount true)` —
   token `c-rbt`, sender `ats-sc`, receiver `coiler` — exactly matching the fix.
2. Built `REPL/_scratch_infoone_h6_coil_cost.repl`: computed the fixed INFO function's predicted
   `ignis-need` for a real `(aoz, ps, PKOSON, 10.0)` Coil, then executed the actual
   `ATS|C_Coil` via the real Talos path and measured `aoz`'s real IGNIS balance delta. Both: `4.0`,
   exact match.
3. **Honest limitation, disclosed rather than glossed over:** directly checked via
   `TFT::URC_TransferClasses` that this ATS pair's reward token (`PKOSON`) and reward-bearing token
   (`PDKOSON`) resolve to the *same* transfer-fee class — reverting the fix by hand and re-running
   produced the identical `4.0 == 4.0` match, so this specific scenario doesn't numerically
   distinguish broken from fixed. The fix remains objectively correct (confirmed independently via
   the sibling-pattern comparison in step 1), but a fully differential live proof would need an ATS
   pair whose reward-bearing token has a genuinely different fee class, not available in this
   harness's existing fixtures without a separate setup. Owner accepted this evidence as sufficient
   and closed the finding.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND VERIFIED ✅ (structural match against ground-truth execution function +
correct sibling pattern; live cost match confirmed; differential old-vs-new proof not achieved for
the available test fixture, disclosed as a limitation; full-suite regression clean).

---

## Fix #10 — #11H — TFT `C_MultiBulkTransfer` never refreshed sender's Elite tier

**Owner's verdict** (given away from a computer, based on the diagnosed code structure): "if its
missing, it is indeed a bug, as its suppose to refresh for both sender and receiver."

**Root cause:** `09_TFT.pact::C_MultiBulkTransfer` refreshes the *receiver's* Elite tier per-leg —
`XI_BulkCredit`'s `elite` boolean (true for `what-type` 5/6) drives `XI_BulkUpdateElite` →
`XI_DirectUpdateEliteAccount` mapped over `receiver-lst` — but never calls any Elite-refresh
function for `sender` anywhere in the function body. Its siblings both refresh both parties:
`C_Transfer` does it inline per elite-classified type (5/6); `C_MultiTransfer` computes
`(contains-eazs:bool (UC_ContainsEliteAurynz id-lst))` once, then after its fold:
`(if contains-eazs (do (XI_DynamicUpdateEliteAccount sender) (XI_DynamicUpdateEliteAccount receiver)) true)`.

**Fix:** mirrored `C_MultiTransfer`'s pattern — added `contains-eazs` to `C_MultiBulkTransfer`'s
`let` bindings, and inserted a sender-only refresh (the receiver side is already correct) right
before the function's final `UDC_ConcatenateOutputCumulators` return:

```pact
(contains-eazs:bool (UC_ContainsEliteAurynz id-lst))   ;; added to the let bindings
...
;;Refresh the sender's own Elite tier once, if any leg touched an Elite-Auryn
;;class token — the receiver side is already refreshed per-leg inside
;;XI_BulkCredit (via its `elite` flag -> XI_BulkUpdateElite).
(if contains-eazs
    (XI_DynamicUpdateEliteAccount sender)
    true
)
(ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
```

**Verification methodology (`REPL/_scratch_tft_h6_bulktransfer_elite.repl`):**
1. Used `patron` (`KST.ANHD`), who already holds a real genesis `ELITEAURYN-98c486052a51` balance
   (`114907.2904`), as both sender and Elite-tier subject — no synthetic minting needed.
2. Read `patron`'s DALOS `elite` object (`{"class": "DEMIURG", "deb": 4.29, "name": "Elite Demiurg",
   "tier": "7.5"}`) before the transfer.
3. Bulk-transferred half of `patron`'s ELITEAURYN balance to `emma` via
   `ref-TS01-C1::DPTF|C_MultiBulkTransfer` (the legitimate Talos entry point, since
   `TFT.C_MultiBulkTransfer` requires `(UEV_IMC)` and can't be called bare).
4. **Pre-fix run:** `patron`'s `elite` object came back byte-identical to the pre-transfer value
   (`DEMIURG`/`4.29`/`7.5`) despite losing half their EA holdings — live reproduction of the bug.
5. Applied the fix above.
6. **Post-fix run, same harness:** `patron`'s `elite` object correctly dropped to
   `{"class": "TYCOON", "deb": 3.11, "name": "Master Tycoon", "tier": "6.6"}`, reflecting the halved
   balance — live proof the fix works.
7. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures (only expected `expect-failure` banner lines matched, no bare
   `Failure:` results).

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced broken pre-fix, working post-fix, same harness; full
regression clean).

---

## Fix #11 — #N2 — TS01-C1::DPTF|C_DeployAccount/DPOF|C_DeployAccount ungated public entrypoints

**Owner's verdict and refinement:** initial instinct was "same fix as DPDC" (remove the entrypoint
entirely). Live-tested first — that broke the *default* `Z.repl` pipeline itself (see below), because
the dominant real use of this Talos entrypoint turned out to be admin/patron setting up brand-new
SYSTEM smart accounts, not end-user self-service. Owner then clarified the actual intended semantics:
"the ownership that must be asked, must be for the ouronet account, the dptf/dpof account is being
added. so I can add a dptf/dpof account for a given dptf/dpof only for my ouronet account, not for
bob's ouronet account." — i.e. gate by target-*account* ownership, not remove the entrypoint, and add
a separate admin path for legitimate system-account setup.

**Root cause (recap of #N2):** `TS01-C1::DPTF|C_DeployAccount`/`DPOF|C_DeployAccount` were gated only
by `(with-capability (P|TS))` — a bare-true cap chain (global pause check + `P|TALOS-SUMMONER`,
`(defcap () true)`) — with no check that the caller controls `account`. Any signer could force any
existing account to associate with any token id.

**First attempt (reverted after live-testing):** added `(ref-DALOS::CAP_EnforceAccountOwnership
account)` directly to both functions with no companion path. This correctly blocked the griefing
case, but also broke real, default-pipeline flows: `[4.0]_Sovereign-Executor.repl` (patron deploying
onto `ats`/`liquid`/`swp` system smart accounts) and `[5.2]_Dispenser+.repl` (patron deploying onto
`standard-dispenser`) — both loaded by `Stage01_Tester.repl`/`Z.repl` by default. Traced why: these
targets are all "Simple vault"-pattern smart accounts governed by a bare-true capability guard on
their *own* module (e.g. `(create-capability-guard (DEMIPAD|GOV))`), which `patron` never holds when
calling the Talos wrapper — `CAP_EnforceAccountOwnership` correctly reports "you don't own this,"
but the call is legitimate system setup, not griefing. Manually reverted (confirmed `git diff` clean)
before re-designing.

**Final fix — split self-service vs. admin paths:**
1. `TS01-C1::DPTF|C_DeployAccount`/`DPOF|C_DeployAccount` keep `(ref-DALOS::CAP_EnforceAccountOwnership
   account)` — self-service only, matching the owner's stated semantics exactly.
2. New `DPTF|A_DeployAccount`/`DPOF|A_DeployAccount` added to `01_TS01-A.pact` (interface
   `TalosStageOne_AdminV1` + module), gated by `(with-capability (P|ADMINISTRATIVE-SUMMONER) ...)` —
   a real admin-keyset check (`GOV|TS01-A_ADMIN` → `enforce-guard GOV|MD_TS01-A`), not a bare-true
   chain. No new IMC peer registration needed: `01_TS01-A.pact` is already a registered IMC peer of
   both DPTF and DPOF (confirmed via `P|A_AddIMP` grep), unlike DPDC's `TS02-DPAD` case.
3. Redirected every known system-setup call site from the self-service `C_` to the new admin `A_`:
   - `REPL/Stage_01/[4.0]_Sovereign-Executor.repl` — `ats`/`liquid` (×4) and `swp` (×2).
   - `REPL/Stage_01/[5.2]_Dispenser+.repl` — `standard-dispenser` (×3); added the missing
     `ref-TS01-A` binding to that `let`.
   - `1_SOVEREIGN/STAGE_02/3_Talos/03_TS02-DPAD.pact::A_RegisterAssetToLaunchpad` — `lpad`
     (DEMIPAD's own smart account); `tf`/`of` branches only (`sf`/`nf` branches, DPDC's domain, left
     untouched).
   - `2_CITIZEN/Stage_02/03_CADUCEUS.pact::A_ProvisionBridgeDptfRoles` — `bridge-account`. Note this
     still respects the sovereign/citizen boundary: CADUCEUS isn't registered as a DPTF IMC peer;
     running this now requires holding *both* `GOV|CADUCEUS_ADMIN` and TS01-A's own admin keyset.
4. Left `REPL/Stage_01/[6.3]_SWP.repl:2143`'s `(ref-TS01-C1::DPTF|C_DeployAccount patron ROuroID
   smart-patron)` untouched — `smart-patron` is `patron`'s own smart-account variant (identical
   underlying principal string, `"Σ."` prefix instead of `"Ѻ."`), a genuine self-service case;
   confirmed this passes the new ownership gate without any redirect (see proof below).

**Verification methodology:**
1. `REPL/_scratch_tft_n2_deployaccount_ownership.repl` — `patron` (unrelated to the target) attempts
   to force-deploy `AurynID` onto `lumy` (never touched it, never signed). Pre-fix: succeeded,
   `DPTF.UR_IzAccount AurynID lumy` flipped `false → true` with zero consent. Post-fix: rejected
   (`Keyset failure (keys-all): [PK_Lumy...]`), account association stays `false`.
2. `REPL/_scratch_n2_demipad_launchpad_regression.repl` — full real `[5.3]_Launchpad.repl` scenario
   (normally commented out of the default profile), exercising `TS02-DPAD::A_RegisterAssetToLaunchpad`
   on a real TF asset (Spark) via the redirected `TS01-A::DPTF|A_DeployAccount` path: `Load successful`.
3. `REPL/_scratch_n2_swp_smartpatron_regression.repl` — full `[6.2]_DPTF.repl` + `[6.3]_SWP.repl` run
   (not in the default profile either), confirming the untouched `smart-patron` self-deploy call still
   passes the ownership gate naturally: `Load successful`.
4. `REPL/_scratch_n2_caduceus_compile_check.repl` — structural-only check (CADUCEUS has zero REPL
   coverage anywhere in the repo, confirmed via grep; a full live functional proof of
   `A_ProvisionBridgeDptfRoles` would need a whole new harness built from scratch — disclosed as a
   real limitation, not glossed over). Confirms the redirected module deploys/parses cleanly against
   the new `TS01-A::DPTF|A_DeployAccount` signature.
5. Full `cd REPL && pact Z.repl`: `Load successful`, exit code 0, no unexpected failures (only the
   same known `expect-failure` banner-line matches as every prior clean run).

**Status:** FIXED ✅ AND PROVEN ✅ (griefing case reproduced broken pre-fix, rejected post-fix;
self-service case confirmed still works; both known real system-setup callers (DemiPad live-proven,
CADUCEUS structurally-proven with the live-proof gap disclosed) redirected to the new admin path and
verified; full-suite regression clean).

---

## Fix #12 — #12H — DPOF `C>UPDATE-SPECIAL` duplicated `cond` branch bypassed Hibernation immutability

**Owner's verdict:** "i think its clearily wrong and a typo. vzh is vesting-sleeping-hibernating,
and thats what vzh 1 2 3 is for. lets fix it and move on, i dont think any further tests are needed."

**Root cause:** `06_DPOF.pact:816-828`, defcap `DPOF|C>UPDATE-SPECIAL`'s `main-special-id` `cond`
tested `(= vzh-tag 2)` twice (Sleeping, then a copy-paste of the same condition intended for
Hibernation) instead of `(= vzh-tag 2)` then `(= vzh-tag 3)`. For `vzh-tag = 3` (Hibernation), no
branch ever matched, so `main-special-id` always fell through to the default `BAR` — bypassing the
immutability `enforce (and (= main-special-id BAR) (= secondary-special-id BAR)) "... immutable !"`
on the main token's side, regardless of whether `main-dptf` already had a real hibernation-link set.
The parallel `secondary-special-id` `cond` (lines 830-835) was already correct (`1`/`2`/`3`, no
duplicate).

**Fix:** one-line correction, `((= vzh-tag 2) (ref-DPTF::UR_Hibernation main-dptf))` →
`((= vzh-tag 3) (ref-DPTF::UR_Hibernation main-dptf))`.

**Verification methodology:**
1. Isolated the exact buggy expression in a throwaway snippet (`/tmp/cond_check.repl`, not part of
   the repo): confirmed `vzh-tag=3` through the buggy `cond` resolves to the default (`"BAR"`
   stand-in) instead of the Hibernation branch; through the corrected `cond`, resolves correctly.
2. Attempted a full end-to-end reproduction via the only currently-wired caller,
   `REPL/_scratch_dpof_h7_hibernation_immutability.repl` (issues a fresh DPTF, calls
   `VST|C_CreateHibernatingLink` on it twice). Discovered and disclosed a real nuance: the *second*
   call crashes before ever reaching the buggy immutability check, because the special DPOF's
   name/ticker are derived deterministically from `main-dptf`'s own name/ticker (no nonce) —
   re-issuing collides on `insert` at the token-creation step, independent of the `cond` bug. This
   means the bypass was not actively exploitable through the one wired caller (`VST`) — but
   `XE_UpdateSpecialOrtoFungible`/`UPDATE-SPECIAL` is an `XE_`-prefixed function (Ouronet's
   "callable directly by other core modules" convention), so any other/future caller supplying an
   arbitrary pre-existing `secondary-dpof` (not a freshly-issued one) would have hit the real bypass.
   Owner confirmed the typo is clear regardless and declined further exploit-path proof.
3. Re-ran the isolated `cond` check against the fix (confirms the corrected logic); re-ran the
   `VST|C_CreateHibernatingLink` harness post-fix — the single legitimate call still succeeds
   (reaches the same later, unrelated re-issuance-collision point as pre-fix on the second call, so
   the fix introduces no regression to the one real call path).
4. Full `cd REPL && pact Z.repl`: `Load successful`, exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (logic defect isolated and confirmed both broken and fixed; real
call-path nuance investigated and honestly disclosed rather than overclaimed; full regression
clean).

---

## Fix #13 — #13H — LIQUID `C_RegisterOuronetAccountForUrstoaHoldings` removed (no ownership check; UI-constructed replacement already exists)

**Owner's context and verdict:** `C_RegisterOuronetAccountForUrstoaHoldings` exists so a StoaICO
contributor who only ever held *wrapped* UrStoa (never native) can register their Kadena address in
the native UrStoa ledger before unwrapping. Owner pointed out this is unnecessary as an on-chain
function — the same problem is already solved by a UI-constructed transaction pattern (proven
working, captured from a real explorer tx for native Stoa unwrap): the UI detects whether the target
address exists in the destination ledger, and if not, prepends a `coin.C_CreateAccount`/
`coin.C_UR|CreateAccount` call using the real signer's own `(read-keyset "ks")` before the real
unwrap/wrap call. Owner: "perhaps the `C_RegisterOuronetAccountForUrstoaHoldings` isnt really
needed... but if we remove it we have to update the next two functions, because in the doc they make
reference to it, and we gotta make proper documentation that its being handled by the UI
constructing special pact code for this."

**Root cause (the original #13H finding):** `C_RegisterOuronetAccountForUrstoaHoldings`
(`12_LIQUID.pact`) took a caller-supplied `guard` for an arbitrary `ouronet-account`, gated only by
`(UEV_IMC)` — no ownership check at all. Any signer could register someone else's Kadena address in
the UrStoa ledger under an attacker-controlled guard (account-hijacking risk). Confirmed zero REPL
coverage anywhere in the repo for this function or its Talos wrapper.

**Fix — removed outright, not patched** (matches the DPDC `#35M`/`C_UpdateSetMultiplier`-removal
precedent: since a superior, already-proven mechanism exists, patching an ownership check onto the
removed function would just be defending a redundant, strictly-worse code path):
1. `12_LIQUID.pact`: removed `C_RegisterOuronetAccountForUrstoaHoldings` from the
   `StoaLiquidStakingV1` interface and its module implementation. Updated `C_UnwrapUrStoa`'s and
   `C_WrapUrStoa`'s `@doc` to point at the UI-constructed pattern instead of the removed function.
2. `03_TS01-C2.pact`: removed `LQD|C_RegisterOuronetAccountForUrstoaHoldings` from the
   `TalosStageOne_ClientTwoV1` interface and its module implementation. Updated
   `LQD|C_UnwrapUrStoa`'s and `LQD|C_WrapUrStoa`'s `@doc` the same way.
3. Left `LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings` untouched — it's a pure read-only
   checker (no risk), and the UI needs it to decide whether the create-account step is required at
   all.
4. Captured the UI-constructed pattern and the reasoning durably in
   `OuronetInformational/memories/2026-08-27-urstoa-account-creation-is-ui-constructed.md`, per the
   owner's explicit request for "proper documentation."

**Verification methodology:**
1. Confirmed via repo-wide grep, before touching anything, that zero `.repl` file anywhere
   references `C_RegisterOuronetAccountForUrstoaHoldings`/`LQD|C_RegisterOuronetAccountForUrstoaHoldings`
   — the only two references in the entire codebase were the function's own declaration/
   implementation in `12_LIQUID.pact` and its Talos wrapper in `03_TS01-C2.pact`. Removal carries no
   regression risk to any existing test.
2. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-removal: `Load
   successful`, exit code 0, no unexpected failures.

**Interface implication:** `StoaLiquidStakingV1` loses `C_RegisterOuronetAccountForUrstoaHoldings`;
`TalosStageOne_ClientTwoV1` loses `LQD|C_RegisterOuronetAccountForUrstoaHoldings`. Both interfaces
are pre-mainnet `V1`, edited freely per policy — no version bump needed.

**Status:** FIXED ✅ AND PROVEN ✅ (zero-caller removal confirmed safe via repo-wide grep before the
edit; full regression clean; durable documentation captured per the owner's request).

---

## Fix #14 — #14H — U_VST `UEV_MilestoneWithTime` no lower bound on `duration`/`offset`

**Root cause:** `1_Utilities/11_U_VST.pact:143-152` enforced only an upper bound on
`(milestones * duration) + offset`, with no check that `duration`/`offset` are non-negative. Both
`VST|C>VEST` (`11_VST.pact:280`) and `VST|C>SLEEP` (`:315`) rely on this as their only bound check.
A negative `duration` makes `UC_MakeVestingDateList` (`11_U_VST.pact:46-73`, `add-time present-time
offset`/`add-time first-time (* idx duration)`) compute a release-date already in the past — a
Sleep/Vest lock immediately unlockable at mint time, defeating the entire point of the lock.

**Fix:** added an explicit non-negativity check before the existing upper-bound check:
```pact
(enforce
    (and (>= offset 0) (>= duration 0))
    "Offset and Duration cannot be negative"
)
```

**Verification methodology (`REPL/_scratch_uvst_h9_milestone_lowerbound.repl`):** both
`UEV_MilestoneWithTime` and `UC_MakeVestingDateList` are plain `U|VST` module functions with no
capability gating, so they're directly callable without needing the full `C_Sleep`/`C_Vest`
token-issuance setup — this exercises the real validated logic and the real date-computation
function, just below the Talos/`C_` entrypoint layer.
1. Showed the consequence first: `UC_MakeVestingDateList(0, -500000, 3)` returns a *decreasing*
   timestamp list (`2026-08-27` → `2026-08-21` → `2026-08-15`), milestones 2 and 3 landing before
   milestone 1.
2. **Pre-fix run:** `UEV_MilestoneWithTime(0, -500000, 3, 788400000)` and
   `UEV_MilestoneWithTime(-100, 500000, 1, 788400000)` both succeeded when they should have failed
   — live reproduction of the bug.
3. Applied the fix above.
4. **Post-fix run, same harness:** both negative-input calls are correctly rejected
   (`"Offset and Duration cannot be negative"`); an ordinary valid-input call
   (`UEV_MilestoneWithTime(100, 500000, 3, 788400000)`) still succeeds — no regression to the
   legitimate case.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced broken pre-fix, working post-fix, same harness;
legitimate valid-input case unaffected; full regression clean).

---

## Fix #15 — #17H — PYTHIA `A_UpdateDeployPrice`/`A_UpdateRenamePrice` never wired into Talos

**Owner's verdict:** "yes, forgot to wire them. add them in."

**Root cause:** `23_PYTHIA.pact:1288-1303` — `A_UpdateDeployPrice`/`A_UpdateRenamePrice` are real,
correctly-gated core functions (`with-capability (GOV|PYTHIA_ADMIN) ...` — a genuine keyset check,
same shape as `#N3`'s reasoning), but the only registered PYTHIA implementer, `TS01-C4`, never
wrapped either function. Even the legitimate admin, signing with the real Demiurgoi key, had no
reachable client path — permanently frozen at their hardcoded defaults short of a module redeploy.

**Fix:** added `PYTHIA|A_UpdateDeployPrice`/`PYTHIA|A_UpdateRenamePrice` to
`06_TS01-C4.pact`'s `TalosStageOne_ClientFourV7` interface and module, mirroring the existing
`PYTHIA|A_Link`/`A_RevokeLink` pattern exactly (`(with-capability (P|TS) (let ((ref-PYTHIA:module{PythiaV4}
PYTHIA)) (ref-PYTHIA::A_UpdateDeployPrice/A_UpdateRenamePrice new-price)))` — no fee, no ownership
check needed at the Talos layer since the core layer already enforces the real admin keyset).
Pre-mainnet `V7`, edited freely per policy — no version bump.

**Verification methodology (`REPL/_scratch_pythia_h12_price_wiring.repl`):**
1. **Pre-fix run** (temporarily reverted both the interface decls and module implementations):
   calling `ref-TS01-C4::PYTHIA|A_UpdateDeployPrice` failed with `Fatal execution error, invariant
   violated: Unbound free variable ouronet-ns.TS01-C4.PYTHIA|A_UpdateDeployPrice` — live confirmation
   the function was genuinely unreachable, not just untested.
2. Manually restored the fix (confirmed `git diff` clean of the temp-revert markers).
3. **Post-fix run, same harness:** `ref-TS01-C4::PYTHIA|A_UpdateDeployPrice 999.0` and
   `PYTHIA|A_UpdateRenamePrice 888.0` both succeed; `ref-PYTHIA::UR_DeployPrice`/`UR_RenamePrice`
   correctly reflect the new values (`500.0 → 999.0`, `100.0 → 888.0`) afterward.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced unreachable pre-fix, working post-fix with real price
changes observed, same harness; full regression clean).

---

## Fix #16 — #18H — U_VST `UC_MakeVestingDateList` silently dropped `offset` when `milestones=1`

**Root cause:** `1_Utilities/11_U_VST.pact:46-73` — for `milestones > 1` the schedule correctly
starts folding from `first-time = present-time + offset`; for `milestones = 1` it instead returned
`[(add-time present-time duration)]` — using `present-time` directly, silently dropping `offset`.
A `C_Vest` call with `milestones=1` and a nonzero `offset` (e.g. a 30-day cliff before a lump-sum
release) released `offset` seconds earlier than specified. `C_Sleep` is unaffected (always calls
with `offset=0`).

**Fix:** one-line change, `[(add-time present-time duration)]` → `[(add-time first-time duration)]`
— reuses the already-computed `first-time` binding, consistent with the `milestones > 1` branch.

**Verification methodology (`REPL/_scratch_uvst_h13_milestone1_offset.repl`):**
1. `UC_MakeVestingDateList` is a plain `U|VST` module function with no capability gating, directly
   callable without the full `C_Vest` token-issuance setup.
2. **Pre-fix run:** `UC_MakeVestingDateList(100000, 500000, 1)` (with a cliff) and
   `UC_MakeVestingDateList(0, 500000, 1)` (no cliff) returned the **identical** timestamp —
   `diff-time` between them was `0`, not the expected `100000` — live reproduction of the bug.
3. Applied the fix above.
4. **Post-fix run, same harness:** the two calls now differ by exactly `100000` seconds (the
   offset), and the `offset=0` case is unchanged from before (no regression to the common
   `C_Sleep`-equivalent path).
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced broken pre-fix — identical timestamps regardless of
offset — working post-fix with the correct time delta; `offset=0` case unaffected; full regression
clean).

---

## Fix #17 — #19H — U_CT `UR|KDA-PID` hardcoded oracle stub updated to the interim mainnet value

**Owner's context and verdict:** no live KDA/USD oracle exists yet; the real `dia-oracle.get-value`
call is commented out and the function is hardcoded. Owner: "yes, because we dont have an oracle
yet, on mainnet is 0.1 once an oracle is available, wel lfix that. for now make it 0.1 and go next
issue." This is not a code-logic bug (the stub does exactly what it says) — it's an unfinished
oracle integration with wide blast radius (`03_INFO-ZERO.pact`, `16_SWPI.pact`, `3_Talos/04_TS01-C3.pact`
×12, `3_Talos/05_TS01-P.pact` ×5, Stage-2 DemiPad), so the value itself needed an owner call, not a
unilateral guess.

**Fix:** `1_Utilities/01_U_CT.pact:165-168` — changed the hardcoded return from `1.0` to `0.1`
(mainnet's approximate KDA/USD price), with a comment marking it as an interim placeholder pending
the real oracle wire-up.

**Verification methodology:**
1. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-change: `Load
   successful`, exit code 0, no unexpected failures — no existing test hardcodes an expectation
   tied to the old `1.0` value.
2. `REPL/_scratch_uct_h14_kdapid_check.repl`: confirmed `U|CT::UR|KDA-PID` now returns `0.1` live.

**Status:** FIXED ✅ AND VERIFIED ✅ (value change confirmed live; full regression clean; real oracle
wiring explicitly deferred until one is available, not part of this fix).

---

## Fix #18 — #20H — U_DEC `UC_AddHybridArray` crashes/misbehaves on empty input

**Owner's constraint:** "i think where its used, it works, due to what type of input its passed in
to it. ive never seen it crash. so what ever you do to fix it makes sure you dont break it." — the
fix had to be purely additive/defensive, with zero behavioral change to the existing (always
non-empty, per every real caller) path.

**Root cause:** `1_Utilities/07_U_DEC.pact:57-93` — `maxl` is computed as the max inner-list length
across `lists`. When `lists` is empty, or every inner list in it is empty, `maxl = 0`, and
`(enumerate 0 (- maxl 1))` becomes `(enumerate 0 -1)`, which Pact returns as `[0 -1]` (bidirectional
`enumerate`, not `[]`) — the same footgun class as `#N2`'s `IGNIS::UC_FindKeyIndex` fix. The
resulting `map` then evaluates the inner lambda for `i = -1`, and — for a genuinely empty inner
list — hits `(at -1 inner-lst)` on a zero-length list.

**Verified this is a real gap, not a design choice, by checking every real caller** (`10_ATSU.pact:559`,
`:985`, `21_INFO-ONE+.pact:2115`, `2_CITIZEN/Stage_Z/01_DPL-UR.pact:1449`): every one always constructs
an 8-column (`c0..c7`) or otherwise non-empty outer list, and per-column contents are only empty when
individual reward-token slots are unused (never *all* of them at once in the observed ATS-pair
shapes) — matching the owner's own observation that it's never actually crashed in production. The
theoretical empty-input case is real but currently unreachable through any wired caller.

**Fix:** wrapped the existing (unmodified) body in an explicit `(if (= maxl 0) [] ...)` guard — pure
addition, zero characters changed inside the original `map`/`fold`/`at` logic.

**Verification methodology (`REPL/_scratch_udec_h15_hybridarray_emptyinput.repl`):**
1. **Pre-fix run** (temporarily reverted the guard, restored the bare original body):
   `UC_AddHybridArray([[] [] []])` crashed with `Array index out of bounds. Length (0), Index (-1)` —
   live reproduction of the exact failure mode.
2. Manually restored the fix (confirmed via `git diff` that only the guard wrapper was added, the
   original logic inside is byte-for-byte unchanged).
3. **Post-fix run, same harness:** `UC_AddHybridArray([])` and `UC_AddHybridArray([[] [] []])` both
   return `[]` cleanly; two realistic non-empty inputs (an unequal-length pair, and an 8-column
   ATSU-shaped input matching the real callers' exact pattern) return the identical, correct sums as
   before the fix — no behavioral change to the path every real caller actually exercises.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced the exact crash pre-fix, clean `[]` output post-fix;
realistic non-empty inputs confirmed byte-identical before/after per the owner's explicit
don't-break-it constraint; full regression clean).

---

## Fix #19 — #23H — OUROBOROS `C_SublimateV2` added to its own `OuroborosV1` interface

**Owner's context:** "i think its only used in a few places, due to how stuff is erased making it a
bit cheaper. but it should be in the interface i think."

**Root cause:** `13_OUROBOROS.pact:440-479` implements `C_SublimateV2` — a cheaper alternative to
`C_Sublimate` that freezes the client's OURO account, wipes the required amount via
`ref-DPTF::C_WipeSlim`, then unfreezes (skipping the transfer-to-smart-account + burn steps
`C_Sublimate` uses) — and it's already live, actively called from `TS01-C2::ORBR|C_SublimateV2`
(its own dedicated Talos wrapper) and directly module-to-module from `TS01-C3`'s Firestarter path.
Despite this, `C_SublimateV2` was never added to `OuroborosV1`, the interface `OUROBOROS`
`(implements)`. Both call sites bind `(ref-ORBR:module{OuroborosV1} OUROBOROS)` and still call
`ref-ORBR::C_SublimateV2` successfully — Pact doesn't enforce that a module-ref call site's
function must appear in the bound interface type, so this was a real interface-declaration gap, not
a broken runtime path.

**Fix:** added `(defun C_SublimateV2:object{IgnisCollectorV1.OutputCumulator} (client:string
target:string ouro-amount:decimal))` to `OuroborosV1`. Purely additive — the module already
implements this exact signature, so no other change was needed. Pre-mainnet `V1`, edited freely per
policy — no version bump.

**Verification methodology:** ran the full default regression pipeline (`cd REPL && pact Z.repl`)
post-fix: `Load successful`, exit code 0, no unexpected failures — confirms `OUROBOROS`'s
`(implements OuroborosV1)` still typechecks cleanly with the new member present, and the existing
live call sites (`TS01-C2`'s wrapper, `TS01-C3`'s Firestarter path, both exercised by the suite)
continue to work.

**Status:** FIXED ✅ AND VERIFIED ✅ (interface now accurately reflects the deployed module's real
surface; full regression clean; no behavioral change since the function already existed and worked).

---

## Fix #20 — #24H — CODEX four missing `C_*` functions added to `CodexV1`

**Owner's verdict:** "Yes add them and tell me about next issue."

**Root cause:** `22_CODEX.pact` implements and actively serves `C_RotateCodexGuard`,
`C_RecordArweaveUpload`, `C_RegisterStoicTag`, `C_ReleaseStoicTag` (lines 671-706ish), all four
already live and called from `3_Talos/06_TS01-C4.pact:196-244` through a `module{CodexV1}`-typed
ref — but `CodexV1` declared zero `C_` functions at all. Same class of gap as `#23H`: Pact's
`(ref:module{Iface} X) / ref::fn` dispatch resolves by name against the concrete deployed module,
not restricted to `Iface`'s declared members, so this worked in production despite the omission.

**Fix:** added all four to `CodexV1`, matching the module's real signatures exactly:
```pact
(defun C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
(defun C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
(defun C_RegisterStoicTag:string (tag-name:string account-address:string))
(defun C_ReleaseStoicTag:string (tag-name:string))
```
Purely additive, placed in a new `;; [C]` section right before the existing `[INFO]` section (whose
two functions are the UI previews for `C_RegisterStoicTag`/`C_ReleaseStoicTag`). Pre-mainnet `V1`,
edited freely per policy — no version bump.

**Verification methodology:** ran the full default regression pipeline (`cd REPL && pact Z.repl`)
post-fix: `Load successful`, exit code 0, no unexpected failures — confirms `CODEX`'s `(implements
CodexV1)` still typechecks cleanly with all four new members present.

**Status:** FIXED ✅ AND VERIFIED ✅ (interface now accurately reflects the deployed module's real
surface; full regression clean; no behavioral change).

**Note (Cluster 10, carried forward from Round I):** both `#23H` and `#24H` are direct empirical
proof that Pact's `(ref:module{Iface} X) / ref::fn` dispatch on StoaChain does not restrict the
callable surface to `Iface`'s declared members — relevant to the sibling ATS audit's own
"unverified" concern about `ATSU.X_RemoveSecondary`'s stale `module{AutostakeV1}` typing; worth
relaying if not already closed there.

---

## Fix #21 — #25M — DALOS `C_RotateKadena` orphans the old kadena address's ledger row

**Owner's explicit instruction (applies going forward, not just this finding):** "everytime you
give me a bug i want you to confirm it to me in repl" — re-verified this finding live before
presenting a recommendation, rather than relaying the Round-I write-up as-is.

**Root cause:** `01_DALOS.pact:1183-1191` — `C_RotateKadena` called `XI_RotateKadena account kadena`
(which overwrites `DALOS|AccountTable[account].kadena-konto` with the new address) *before* calling
`(UR_AccountKadena account)` to find the old address to clean up from `DALOS|KadenaLedger`. Since
`UR_AccountKadena` reads the just-overwritten field, it returned the *new* address, not the old one
— so the ledger-cleanup call operated on the wrong key, and the old address's `dalos` list in
`DALOS|KadenaLedger` was never touched, permanently retaining `account`.

**Live pre-fix reproduction (`REPL/_scratch_dalos_m1_rotatekadena_orphan.repl`):** rotated `patron`'s
kadena address via the real Talos path (`TS01-C1::DALOS|C_RotateKadena`), then inspected
`DALOS.UR_KadenaLedger` for both addresses:
```
OLD kadena's ledger row BEFORE rotation: [patron]
NEW kadena's ledger row AFTER rotation:  [patron]   <- correct
OLD kadena's ledger row AFTER rotation:  [patron]   <- BUG: never cleaned up
```
Also confirmed via repo-wide grep that `UR_KadenaLedger` has zero callers anywhere else — no live
functional breakage today, a pure data-integrity leak (an orphaned reverse-index row, never read).

**Fix:** read the old address into a `let` binding *before* calling `XI_RotateKadena`:
```pact
(let
    (
        (old-kadena:string (UR_AccountKadena account))
    )
    (XI_RotateKadena account kadena)
    (XI_UpdateKadenaLedger old-kadena account false)
    (XI_UpdateKadenaLedger kadena account true)
)
```

**Verification methodology:**
1. **Pre-fix run:** confirmed broken as shown above.
2. Applied the fix.
3. **Post-fix run, same harness:** old kadena's ledger row now correctly shows `[BAR]` (empty)
   after rotation; new kadena's row is unaffected (still correctly `[patron]`).
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced the exact leak pre-fix, confirmed clean post-fix,
same harness; zero live consumers of the affected index confirmed via repo-wide grep; full
regression clean).

---

## Fix #22 — #26M — DALOS smart-account deploy validation moved from `XI_*` writer to client caps

**Owner's context and constraint:** "i did it this way, i think because there is an admin mode that
can make accounts without paying for the fee, deployment in admin mode, if you think you can do it
using our syntax definition, lets do it, otherwise it could be left as is." — the original structure
existed to share validation logic between the admin (fee-free) and client (paying) deploy paths
without duplicating it; the fix had to preserve that sharing while moving the validation to the
correct StoicSyntax layer.

**Root cause:** `01_DALOS.pact` — `A_DeploySmartAccount` composed bare `SECURE-ADMIN`,
`C_DeploySmartAccount` composed bare `SECURE`, and the real validation (guard-or-GOV enforcement,
`Σ`-prefix format check, glyph charset check, sovereign/guard-protocol checks) lived inside the
internal writer `XI_DeploySmartAccount`'s own composed capability
(`DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT`) — backwards relative to this codebase's convention that
`XI_*` writers hold no validation of their own; everything belongs in the client-facing defcap.
Confirmed via code reading this was not a security bypass (the validation still fired on every
call) — purely a discoverability/StoicSyntax-placement issue.

**Fix — added a new client cap for the admin path, reusing the existing shared validation cap
rather than duplicating it:**
```pact
(defcap DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT (account:string guard:guard kadena:string sovereign:string)
    @event
    (compose-capability (GOV|DALOS_ADMIN))
    (compose-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard kadena sovereign))
)
```
- `A_DeploySmartAccount` now composes `DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT` instead of bare
  `SECURE-ADMIN` — keeps the admin-only gate (`GOV|DALOS_ADMIN`) distinct, while pulling in the
  shared validation via composition (defined exactly once, no duplication).
- `C_DeploySmartAccount` now composes `DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT` directly instead of
  bare `SECURE` (which that cap already composes internally, so this is a strict superset).
- `XI_DeploySmartAccount` is now a pure writer: `(require-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT
  account guard kadena sovereign))` replaces its old `(require-capability (SECURE))` +
  internal `with-capability` wrapper — no validation of its own, matching the `XI_*` convention.

**Verification methodology (`REPL/_scratch_dalos_m2_deploysmart_capsplit.repl`):** since this is a
refactor (not a behavior-changing bug fix), the proof is behavioral *equivalence* — both paths must
still succeed for valid input and still reject invalid input, exactly as before.
1. Admin path (`TS01-A::DALOS|A_DeploySmartAccount`): a well-formed `Σ`-prefixed account with a
   matching keyset guard succeeds; a malformed (non-`Σ`-prefixed) account is still rejected.
2. Client path (`TS01-C1::DALOS|C_DeploySmartAccount`): same two cases, including the real KDA fee
   collection (funded via `coin.TRANSFER` capability grants) — succeeds for valid input, rejects
   malformed input.
3. Noted while building this proof: `C_DeploySmartAccount`'s success path has **zero** coverage in
   the default `Z.repl` pipeline (`[6.3]_SWP.repl`, its only real caller, is excluded from the
   default profile) — this scratch harness is currently the only live proof of that path's success
   case; flagged as a REPL-coverage gap for the deferred main-branch test-infrastructure phase.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures — this does exercise `A_DeploySmartAccount` extensively
   (dozens of real smart-account deployments during genesis setup).

**Status:** FIXED ✅ AND VERIFIED ✅ (both admin and client paths confirmed behaviorally identical
before/after for both success and rejection cases; full regression clean).

---

## Fix #23 — #28M — TFT `C_ClearDispo` unconditionally unfroze the account's Elite-Auryn balance

**Root cause:** `09_TFT.pact:1194-1263` — `C_ClearDispo` correctly guards the *initial* freeze
(`ico1`: `(if (not frozen-state) (C_ToggleFreezeAccount ea-id account true) EOC)` — skip if already
frozen), but unconditionally unfroze at the end (`ico3`:
`(ref-DPTF::C_ToggleFreezeAccount ea-id account false)`, no guard). So if the account's Elite-Auryn
balance was already frozen for an unrelated reason before `C_ClearDispo` was ever called, this
function would still force-unfreeze it — silently lifting a freeze it never applied and had no
business touching.

**Live pre-fix reproduction (`REPL/_scratch_tft_m4_cleardispo_unfreeze.repl`):** mirrored the only
existing fixture that exercises `C_ClearDispo` (`[6.2]_DPTF.repl`'s "Dispo 2|x Clear Dispo Test" on
`emma`: transfer EA, sublimate OURO against a zero balance to go negative), then froze `emma`'s EA
for an unrelated reason immediately before calling `C_ClearDispo`:
```
Emma's OURO balance (negative, dispo-clearable): -8.0
Emma's EA frozen-state BEFORE ClearDispo (unrelated freeze applied): true
Emma's EA frozen-state AFTER ClearDispo: false   <- BUG: unrelated freeze silently lifted
```

**Fix:** mirrored `ico1`'s exact condition on `ico3`:
```pact
(ico3:object{IgnisCollectorV1.OutputCumulator}
    (if (not frozen-state)
        (ref-DPTF::C_ToggleFreezeAccount ea-id account false)
        EOC
    )
)
```

**Verification methodology:**
1. **Pre-fix run:** confirmed broken as shown above.
2. Applied the fix.
3. **Post-fix run, same harness:** `emma`'s EA frozen-state stays `true` after `C_ClearDispo` — the
   unrelated freeze is now correctly preserved.
4. **Common-case regression check** (`REPL/_scratch_m4_full_dptf_commoncase_check.repl`): ran the
   real, unmodified `[6.2]_DPTF.repl` fixture (not part of the default `Z.repl` profile, so this is
   the only coverage of `C_ClearDispo`'s common/not-pre-frozen case) — `emma`'s EA still correctly
   ends up unfrozen (`false`) afterward, confirming no regression to the intended common-path
   behavior.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced the exact bug pre-fix, confirmed clean post-fix, same
harness; common/not-pre-frozen case confirmed unaffected via the real existing fixture; full
regression clean).

---

## Fix #24 — #29M — TFT `C_MultiTransfer`/`C_MultiBulkTransfer` stale `dispo-data` snapshot enabled real OURO-overdraft inflation

**Severity note:** this finding turned out more serious than its MEDIUM rank suggests once verified
live — it's a genuine overdraft-inflation exploit, not just a code-organization issue. Flagging this
explicitly since the ranked tier undersells it.

**Root cause:** `09_TFT.pact` — both `C_MultiTransfer` and `C_MultiBulkTransfer` computed
`(dispo-data:object{UtilityDptfV1.DispoData} (UDC_GetDispoData sender))` **once**, before the `fold`
over `id-lst`, and reused that same snapshot for every leg's `XB_DebitTrueFungible` call. Since
`UDC_GetDispoData` captures the sender's *current* Elite-Auryn holdings (`UR_AccountSupply ea-id
sender`), and `UC_OuroDispo` (the max-allowed-OURO-overdraft formula) is directly proportional to
that amount, a single multi-transfer batch that includes **both** an Elite-Auryn-reducing leg and an
OURO-overdraft leg lets the overdraft leg be checked against the sender's *pre-batch* (higher) EA
holdings, regardless of the legs' order in `id-lst` (the snapshot is taken before any leg runs
either way).

**Live pre-fix exploit reproduction (`REPL/_scratch_tft_m5_staledispo_exploit.repl`):** a single
`C_MultiTransfer` batch — `id-lst = [ea-id, ouro-id]`, transferring away half of `patron`'s real EA
holdings *and* overdrafting OURO in the same call:
```
patron EA before: 114907.2904 / half transferred away: 57453.6452
max overdraft under STALE (pre-batch, full-EA) dispo:    44446.6688...
max overdraft under CORRECT (post-halving) dispo:        22223.3344...
chosen overdraft amount: 33335.0016   (> correct limit, <= stale limit)
BATCH SUCCEEDED. patron's OURO balance after: -33335.0016
```
The batch succeeded, driving `patron`'s OURO balance to -33335.0016 — more negative than the
correct post-halving limit (-22223.33) allows, only possible because the debit check used the
stale, pre-batch dispo limit (-44446.67).

**Fix:** moved `(dispo-data:object{UtilityDptfV1.DispoData} (UDC_GetDispoData sender))` from the
outer `let` (computed once) into the inner per-leg `let` inside each `fold`'s lambda (recomputed
fresh for every leg), in both `C_MultiTransfer` and `C_MultiBulkTransfer` — so each leg's debit
check reflects every prior leg's effect on the sender's real Elite-Auryn holdings within the same
batch.

**Verification methodology:**
1. **Pre-fix run:** confirmed the exploit succeeds as shown above.
2. Applied the fix to both functions.
3. **Post-fix run, exact same harness/amounts:** the identical batch now correctly fails —
   `Cannot Debit OURO from <patron>, dispo capabilities exceeded!` — the fresh per-leg dispo-data
   correctly reflects the EA reduction from the earlier leg in the same batch.
4. **Legitimate-case check:** re-ran with an overdraft amount safely within the *correct*
   post-halving limit (half of it) — the batch still succeeds normally, confirming the fix isn't
   overly strict and doesn't break ordinary multi-transfer usage.
5. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (live exploit reproduced and confirmed closed, same harness;
legitimate overdraft within the correct limit confirmed still works; full regression clean).

---

## Fix #25 — #30M — DPTF `UR_Hibernation` simplified to a pure getter (live chain check first)

**Owner's direction:** "can you check on chain if there is anything else that needs filling ? we
could run the function to fill all the gaps, and remove it (in the sense we morph it to its default
shape). that would be the best fix, right ?" — check live state first, backfill if needed, then
simplify.

**Root cause:** `05_DPTF.pact:974-990` — `UR_Hibernation`, a plain unprotected `UR_*` read, silently
performed a live `update` on `DPTF|PropertiesTable` to backfill a missing `hibernation-link` field —
a read/write-separation violation, called pervasively as if it were a pure getter.

**Live chain check (2026-08-28), using Pythia's dirty-read relay** (durably documented — see
`OuronetInformational/memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md` for the
full method, since this capability didn't exist as written-down knowledge before now):
```pact
(namespace "ouronet-ns")
(let ((ids (keys DPTF.DPTF|PropertiesTable)))
  (map (lambda (id) {"id": id, "has-hibernation-link": (!= (read DPTF.DPTF|PropertiesTable id ["hibernation-link"]) {})}) ids))
```
All 18 real, currently-deployed DPTF tokens on StoaChain chain 0 already have `hibernation-link`
populated — zero gaps. The backfill branch was confirmed fully dead code on the live chain, so no
migration function was needed before simplifying.

**Fix:** removed the `update` call entirely; kept the exact same in-memory `needs-populate`/
`default-value` fallback logic, so the return value is byte-identical for every caller:
```pact
(defun UR_Hibernation:string (id:string)
    (let
        (
            (default-value:string BAR)
            (temp (read DPTF|PropertiesTable id ["hibernation-link"]))
            (needs-populate:bool (= temp {}))
        )
        (if needs-populate default-value (at "hibernation-link" temp))
    )
)
```

**Verification methodology:**
1. Live chain check (above) confirmed zero real gaps exist — no migration function needed.
2. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.
3. `REPL/_scratch_dptf_m6_urhibernation_purefetch.repl`: confirmed `UR_Hibernation` still returns
   the identical value (`BAR`) for a real, normally-issued token — no behavioral change.

**Status:** FIXED ✅ AND VERIFIED ✅ (live on-chain state checked before deciding the fix shape, per
the owner's request; zero gaps found; function simplified to a genuine pure getter with a
confirmed-identical return value; full regression clean).

**Follow-up (owner, 2026-08-28):** this is a general pattern ("read functions modified to also
write, to fill new fields added by a schema change"), not unique to `UR_Hibernation`. The
methodology used here (sample live chain via Pythia, retire if zero gaps, otherwise migrate first)
and the correct way to write this pattern if genuinely needed in the future are captured in
`OuronetInformational/ouronet/conventions/schema-field-backfill-on-read.md`. Any other instance of
this shape found anywhere in this audit's remaining scope should be deferred to a dedicated
main-branch sweep for this pattern (see `README.md`'s Downstream plan, phase 3b) rather than fixed
piecemeal — see `ROUND-01-OWNER-FEEDBACK.md`'s addendum to #30M for the full instruction.

---

## Fix #26 — #31M — DPOF `URC_Parent` direct `enforce` moved to its one real caller that needs it

**Root cause:** `06_DPOF.pact:1314-1334` — `URC_Parent` (a `URC_*`, contractually never allowed to
`enforce`) contained `(enforce (!= fourth BAR) "Sleeping LP Tokens not allowed for this
operation")` — rejecting any dpof id whose 4th character is `|` (the shape produced by a
"Sleeping"-linked LP token, e.g. `Z|W|...`). This enforce genuinely belonged to
`UEV_ParentOwnership` (whose own `@doc` already says "While ensuring a Sleeping LP cant be used for
this operation") but was placed in the shared helper instead, so *every* caller of `URC_Parent` paid
for a rejection only one of them needed.

**Confirmed via live-chain investigation this was reachable, not just theoretical:**
`DPOF|C>UPDATE-SPECIAL` (`:857-862`) explicitly *allows* creating a Sleeping link on a `"W|"`
(LP-prefixed) token ("But can be an LP Token") — a Sleeping-LP token is a fully sanctioned
combination, just not yet exercised: querying live StoaChain (Pythia dirty-read) showed none of the
5 real DPOF tokens deployed today have this shape, but the very first time one is created (via the
normal, intended flow), any caller relying on `URC_Parent` staying non-aborting would break.

**The one real impact this protected against turning into a live bug:**
`2_CITIZEN/Stage_Z/01_DPL-UR.pact::URC_0009a_OrtoFungibleEntryMapper` — a wallet/portfolio-listing
helper that folds `URC_Parent` (via `URC_0009a_OrtoFungibleEntry`) over every DPOF token an account
holds, with no `try`/error-handling. Checked its actual use of the result: `dptf-id` (the
`URC_Parent` output) is only fed into a best-effort price lookup (`SWPI::URC_TokenDollarPrice`,
already defensively handling a `0.0`/unpriceable result) and is never included in the returned
display object at all — confirming (per the owner's steer: "check where its used, and you'll see
there's probably no need for knowing what the function returns for a sleeping LP") that no special
return value was needed for this case; the existing `"Z|"` cond branch already handles it exactly
like any other Sleeping token once the enforce is out of the way.

**Fix:**
1. `URC_Parent` — removed the enforce entirely; the existing `cond` (dispatch by `first-two`) is
   now the whole function body, unchanged otherwise.
2. `UEV_ParentOwnership` — added the same enforce directly (computes `fourth` itself), since this
   is the one caller whose own documented contract requires it.

**Verification methodology (`REPL/_scratch_dpof_m7_urcparent_enforce.repl`):**
1. **Pre-fix run:** confirmed `URC_Parent` hard-aborts on a 4th-char-BAR id (`ABC|restofid`, chosen
   to fall through to the existing default branch without needing a real backing row).
2. Applied the fix.
3. **Post-fix run, same harness:** `URC_Parent` now succeeds (returns the id unchanged, via the
   pre-existing default branch); `UEV_ParentOwnership` still correctly rejects the identical input
   — the enforce moved, it wasn't lost.
4. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (reproduced the abort pre-fix, confirmed non-aborting post-fix
with the enforce correctly relocated to its real owner; full regression clean).

---

## Fix #27 — #33M — DPOF `AHU`/`AUP_OrtoFungible*` documented as a completed historical migration tool

**Owner's verdict:** "It's that way by design, and I think everything is migrated anyway. So
basically there is nothing to fix this was used when migrating form meta to orto fungible. So I
think we can even remove it. But should be updated and kept for historical purposes I think."

**No functional change** — this is the DPMF→DPOF (meta-fungible to orto-fungible) migration's own
one-time key-repair utility (`AUP_OrtoFungibleAccounts`/`AUP_OrtoFungibles`, gated by `AHU`, which
authorizes solely via the hardcoded "AncientHodler"/patron account rather than `GOV|DPOF_ADMIN`).
Owner confirmed the migration is complete and the hardcoded-account design was intentionally scoped
to that one-time historical operation, matching DPMF's own retention rationale (#1C: kept for
historical reference, not actively used).

**Fix:** added a documentation-only comment block above `{F8} [AUP - Admin Update Functions]` in
`06_DPOF.pact`, marking the whole section as a historical, completed migration utility, recording
the owner's verdict, and explicitly noting it is not a substitute for `GOV|DPOF_ADMIN` or a
permanent alternate admin path. No code logic touched.

**Verification methodology:** ran the full default regression pipeline (`cd REPL && pact Z.repl`)
post-change: `Load successful`, exit code 0 — a comment-only change carries no behavioral risk, but
verified anyway per the standing discipline.

**Status:** CLOSED — NOT A BUG / INTENTIONAL DESIGN, documented for historical clarity (owner
declined removal, wanted it kept and clearly marked instead). Full regression clean.

**Note:** the sibling SWP audit independently flagged its own copy of this pattern (`15_SWP.pact`).
This verdict (historical, complete, no fix needed) is specific to DPOF's migration context and
should not be assumed to automatically apply to SWP's — not relayed as a handoff since the owner
didn't request one this time, but worth a sanity check if that audit hasn't already closed its own
copy.

---

## Fix #28 — #35M — `DPOF|C_TogglePause`/`C_ToggleFreezeAccount` dead binding + missing result message

**Root cause:** `02_TS01-C1.pact:1061-1118` — both functions bound `(ref-TS01-A:module{TalosStageOne_AdminV1}
TS01-A)` but never used it (a copy-paste leftover), and both ended with the raw
`ref-IGNIS::C_Collect` result (an `OutputCumulator` object) instead of a `format` string, unlike
their correctly-implemented DPTF counterparts (`DPTF|C_TogglePause`/`DPTF|C_ToggleFreezeAccount`,
same file), which have no such dead binding and end with a clear `format` message.

**Fix:** removed the dead `ref-TS01-A` binding from both; added the DPTF siblings' exact `format`
pattern — `"ID {} succesfully pauses"`/`"...unpauses"` for `C_TogglePause`, `"Account {}
succesfully frozen for {}"`/`"...unfrozen for {}"` (with the `ref-I|OURONET::OI|UC_ShortAccount`
binding DPTF's version already uses) for `C_ToggleFreezeAccount`.

**Verification methodology:**
1. Ran the full default regression pipeline (`cd REPL && pact Z.repl`) post-fix: `Load successful`,
   exit code 0, no unexpected failures — confirmed the return-type change (object → string) breaks
   nothing (neither function has an explicit interface return-type annotation).
2. `REPL/_scratch_dpof_m11_togglemessages.repl`: issued a fresh DPOF token, called both functions
   live, confirmed real messages: `"ID M11D-... succesfully pauses"` and `"Account ...
   succesfully frozen for M11D-..."`.

**Status:** FIXED ✅ AND VERIFIED ✅ (dead binding removed, real messages confirmed live matching
the correct DPTF sibling pattern exactly; full regression clean).

## Fix #29 — #44M — `U_LST::UC_IzUnique` renamed to `UEV_IzUnique`

**Root cause:** `05_U_LST.pact` — `UC_IzUnique` is `UC_`-prefixed (pure-compute contract: no
table reads, **no `enforce`**) but its body directly `enforce`s that every element of the input
list is unique, aborting the transaction on the first duplicate — the same root-cause shape as
#43M, just not folded into that batch because the owner asked a sharper question first: "But is
there a problem that it can never return false?" Direct answer: yes, in effect — there is no
"not unique" case that returns `false`; a duplicate always aborts the whole transaction instead.
The function's own inline comment ("If all items are unique, the function returns true") reads as
a real two-valued predicate contract, which never existed. No caller in this repo currently
branches on a `false` result today (checked all six call sites), so there's no live functional
bug — but the doc/contract mismatch is a real latent risk for any future caller who trusts the
misleading comment and writes an `(if (U|LST::UC_IzUnique ...) ... ...)` branch that can never be
reached. Owner: "So fix it boss" — fix now, standalone, not batched into the #43M StoicSyntax
defer.

**Fix:** renamed `UC_IzUnique` → `UEV_IzUnique` everywhere (definition + interface + every
caller), and rewrote the misleading inline comment/`@doc` to state the true contract plainly:
enforces uniqueness, aborts on the first duplicate, always returns `true`, no false-returning
case exists.

- `1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact` — function renamed, `@doc` rewritten, an
  explanatory `;;#44M fix` comment added above the definition.
- `1_SOVEREIGN/STAGE_01/0_Interfaces/01_Utilities.pact` — declaration moved from the `[UC]` group
  to the `[UEV]` group inside `StringProcessorV1` (V1 edited freely, pre-mainnet policy), with an
  explanatory comment.
- Callers updated via `sed -i 's/UC_IzUnique/UEV_IzUnique/g'`, one file at a time, then
  confirmed by re-reading each diff: `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact`,
  `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact`, `1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact`,
  `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact`, `1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact` (DPMF is
  permanently out of scope for logic upgrades per the owner's #36M/#37M ruling — this edit is
  purely mechanical, keeping DPMF *compiling* against the renamed shared utility, not an upgrade
  to DPMF's own logic/behavior), and `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/07_DPDC-T.pact` (a
  Stage 2 file — touched only because it's a caller of this shared Stage-1 utility).
- `grep -rn "UC_IzUnique" --include="*.pact" .` confirms zero remaining code references to the
  old name anywhere in the repo; the only two hits are the intentional historical mentions in the
  explanatory comments above.

**Verification methodology:**
1. Ran the full default regression pipeline (`cd REPL && pact Z.repl`, both Stage 1 and Stage 2,
   including the Stage-2 `DPDC-T` caller) post-fix: `Load successful`, exit code 0, no unexpected
   failures.
2. `REPL/_scratch_ulst_m20_uev_izunique.repl`: called `UEV_IzUnique` directly post-fix — a unique
   list (`["a" "b" "c"]`) returns `true`; a list with a duplicate (`["a" "b" "a"]`) still aborts
   via `expect-failure`, exactly matching `UC_IzUnique`'s pre-rename behavior. Behavior is
   byte-identical; only the name/prefix/doc changed.

**Status:** FIXED ✅ AND VERIFIED ✅ (doc-contract mismatch corrected, behavior unchanged and
confirmed live, full regression clean across both stages).

## Fix #30 — #45M — `U_INT::UC_MaxInteger` crashes uncatchably on an empty list, renamed to `UEV_MaxInteger`

**Root cause:** `06_U_INT.pact:43` (pre-fix) — `UC_MaxInteger` computes `(fold ... (at 0 lst) (drop 1
lst))`. On an empty list, `(at 0 lst)` throws `Array index out of bounds. Length (0), Index (0)` — a
raw runtime error, confirmed live to be **uncatchable even by `try`** (the load aborts outright,
"Load failed", not a normal Pact `enforce` failure a caller could branch on). Unlike the H15/Fix #18
precedent (`U_DEC::UC_AddHybridArray`, sum-of-nothing has a safe benign default of `[]`), there is no
safe benign default for "max of an empty list" — silently returning e.g. `0` would be actively
dangerous, since callers feed the result into precision/index math (`U_ATS`, `ATS::URC_MaxSyphon`)
where a wrong-but-plausible `0` could corrupt downstream computation instead of failing loudly.

**Reachability check (why this isn't purely theoretical):** of the four call sites, `AQP::SCORE`
guards with `(if (> l1 0) (ref-U|INT::UEV_MaxInteger nonces) 0)` — safe. `DPDC-S`'s
`UEV_PrimordialSetDefinition`/`UEV_CompositeSetDefinition` do **not** guard — `set-definition` is a
direct client-supplied list parameter to `DPDC-S|C>DEFINE-PRIMORDIAL`/`C>DEFINE-COMPOSITE`/
`C>DEFINE-HYBRID`; an empty `set-definition` folds to an empty `nonces-used-in-set-definition`/
`set-classes-used-in-set-definition` and hits the crash. (DPDC is a separate audit's ownership,
out of scope to fix here, but it demonstrates the crash is genuinely reachable through a real public
entrypoint elsewhere in the codebase, not just a theoretical worry.) `U_ATS`/`ATS` callers are
sibling-audit scope (ATS), also out of scope to fix here.

**Fix:** renamed `UC_MaxInteger` → `UEV_MaxInteger` (definition, interface `[UEV]` group, and all
four caller files), and added `(enforce (> (length lst) 0) "UEV_MaxInteger: list cannot be empty")`
as the function's first statement — purely additive, the original `fold`/`at`/`drop` logic below it
is byte-for-byte unchanged. Same root-cause/fix shape as #44M: a `UC_`-prefixed function that
structurally needs to enforce doesn't belong under `UC_`.

- `1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact` — function renamed, enforce added, explanatory
  `;;#45M fix` comment added (kept in its original position in the file, matching #44M's
  minimal-diff/rename-in-place approach rather than reordering into the `{F2} [UEV]` block).
- `1_SOVEREIGN/STAGE_01/0_Interfaces/01_Utilities.pact` — declaration moved from the `[UC]` group to
  the `[UEV]` group inside `OuronetIntegersV1` (V1 edited freely, pre-mainnet policy).
- Callers updated via `sed -i 's/UC_MaxInteger/UEV_MaxInteger/g'`, confirmed by re-reading each
  diff: `1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact`, `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact`
  (both sibling-audit/ATS scope — mechanical rename only, to keep them compiling against the
  renamed shared utility, no change to ATS's own logic), `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`,
  `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact` (both Stage 2 / separate DPDC-audit scope,
  same mechanical-rename-only rationale).
- `grep -rn "UC_MaxInteger" --include="*.pact" .` confirms zero remaining code references; the only
  two hits are the intentional historical mentions in the explanatory comments.

**Verification methodology (`REPL/_scratch_uint_m21_maxinteger_empty.repl`):**
1. **Pre-fix run** (against the original `UC_MaxInteger`): `UC_MaxInteger([])` crashed with
   `Array index out of bounds. Length (0), Index (0)` at `06_U_INT.pact:49` — and wrapping the call
   in `(try "..." ...)` did **not** catch it; the whole REPL load aborted (`Load failed`), proving
   this is not a normal catchable Pact failure.
2. **Post-fix, same harness:** `UEV_MaxInteger([3 1 4 1 5])` still returns `5` (byte-identical to the
   pre-fix non-empty-list behavior); `UEV_MaxInteger([])` now fails cleanly via `expect-failure` —
   a normal, catchable business-logic rejection instead of a raw crash.
3. Ran the full default regression pipeline (`cd REPL && pact Z.repl`, both Stage 1 and Stage 2, since
   `SCORE` and `DPDC-S` are Stage-2 callers): `Load successful`, exit code 0, no unexpected failures.

**Status:** FIXED ✅ AND PROVEN ✅ (uncatchable crash reproduced pre-fix, confirmed not even
`try`-catchable; clean `enforce` failure confirmed post-fix; existing non-empty-list behavior
confirmed byte-identical; full regression clean across both stages).

## Fix #31 — LOW-cleanup batch (#53L, #56L, #58L, #61L, #68L, #72L, #73L, #74L, #75L)

Nine small, independent LOW findings from the remaining open list, each safe/purely-additive or
purely-subtractive with zero behavioral change to any real caller. Grouped into one fix entry since
none individually warranted its own full write-up; each still gets its own strikethrough/verdict in
`ISSUES-RANKED.md`/`README.md`.

- **#53L** — `01_DALOS.pact::A_UpdateUsagePrice` had no bound check on `new-price` (a contributing
  cause of #8H, already fixed at the IGNIS level). Added `(enforce (> new-price 0.0) "New price
  must be a positive amount")` — defense-in-depth for an admin-only fat-finger (`GOV|DALOS_ADMIN`
  already fully trusted), purely additive.
- **#56L** — `07_ELITE.pact`: removed two vestigial boilerplate items copied from the module
  sample template, confirmed zero references anywhere in the repo (including cross-module via
  `ref-ELITE::`): the `GOV|ELITE_ADMIN-CALLER` defcap and the `GOV|CollectiblesKey` defun (the
  latter referencing an unrelated `"dpdc-keyset"` string, clearly copy-pasted from a different
  module's template).
- **#58L** — `09_TFT.pact::C_ClearDispo`: removed the dead `account-ea-supply` binding (bound,
  never referenced in the function body).
- **#61L** — `13_OUROBOROS.pact::C_Compress`: removed the dead `total-ouro` binding (bound, never
  referenced — only `ouro-remainder-amount`, the first element of the fee split, is actually
  minted/transferred).
- **#68L** — `23_PYTHIA.pact`: removed the dead `PYTHIA|FLUSH-GAS-TARGET` constant, confirmed zero
  references anywhere (likely a leftover from an earlier gas-based batching design later replaced
  by the count-based `PYTHIA|MAX-FLUSH-BATCH` cap, added per #M25's context).
- **#72L** — `REPL/Stage_01/[6.10b]_PYTHIA-ledger-v2.repl`: header said "load after [6.10] TX007";
  confirmed the sibling file's real last tx is TX008 (TX007a/b/c were added later) — updated the
  header. Doc-only.
- **#73L** — `01_U_CT.pact::CT_DPTF-FeeLock`: removed a tautological `or` — `(NS_TEST)` is itself
  defined as `(at 0 ["free"])` = `"free"` (line 10), so `(= (CT_NS_USE) (NS_TEST))` and
  `(= (CT_NS_USE) "free")` checked the exact same condition twice. Kept the named `(NS_TEST)` form.
- **#74L** — `11_U_VST.pact`: fixed the isolated typo "to small" → "too small" (message text
  only). **Did not** touch "succesfully"/"succesful" elsewhere in the same function — confirmed via
  `grep -rn "succesfully\|succesful" --include="*.pact" .` (119 hits repo-wide) that this is the
  codebase's own established, consistent spelling convention, not a one-off typo; "fixing" it in a
  single file would create inconsistency with the other 118 occurrences. (The sibling "to small"
  instance in `09_U_ATS.pact:202` is sibling-audit/ATS scope, left untouched.)
- **#75L** — `05_U_LST.pact::UEV_StringPresence`: the `[bar]`-sentinel-only check let a genuinely
  empty list `[]` fall through to the generic "not present" message instead of the specific "Empty
  List detected!" one — both cases still correctly aborted the transaction either way (confirmed
  live, not a functional bug), just an inconsistent message for the real-`[]` case. Added
  `(UC_IsNotEmpty item-lst)` to the same `enforce` so both cases get the specific message.

**Verification methodology:**
1. `REPL/_scratch_low_batch_53_75.repl`: confirmed the two behavior-relevant fixes live —
   `UEV_StringPresence` gives the specific "Empty List detected!" message for both `["|"]` and a
   real `[]` now (previously only `["|"]`); `A_UpdateUsagePrice` cleanly rejects `0.0` and `-1.0`.
   Happy-path calls for both functions confirmed unaffected.
2. Ran the full default regression pipeline (`cd REPL && pact Z.repl`, both stages) post-fix:
   `Load successful`, exit code 0, no unexpected failures — confirms the five pure dead-code
   removals (#56L, #58L, #61L, #68L) and the tautology simplification (#73L) broke nothing.

**Status:** FIXED ✅ AND VERIFIED ✅ (all nine sub-fixes purely additive/subtractive/textual, zero
behavioral change to any real caller path; the two enforcement-relevant sub-fixes confirmed live;
full regression clean across both stages).
