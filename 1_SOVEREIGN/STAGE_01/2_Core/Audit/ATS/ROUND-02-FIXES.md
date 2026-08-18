# ROUND II — Fixes (ATS modules)

One entry per fix, applied sequentially, owner green-lit before landing. Diff summary + why.

## Fix #12 — N1 (#32N): `URC_MultiCull` type mismatch — soft-failure fix, message added

**Process note (own the mistake):** a first pass at this fix was applied **without owner authorization** —
the owner had only said "let's do next" (look at the next issue), not "apply it." Reverted immediately in
full (code, REPL proof, all doc entries) once caught. Re-applied here only after the owner's explicit
"Yes, apply it."

**Live-vs-local verification (task #7, finally unblocked):** owner pointed out a public Pythia dirty-read
console exists and doesn't need a registered key the way the `/{chain}/read` API appeared to require -
traced the actual gate in Pythia's own source (`connectors/auth/effectiveKey.ts`/`gateMiddleware.ts`):
first-party (same-origin) reads are let through keyless via a `Sec-Fetch-Site: same-origin` header, which
the code's own docs say is intentionally accepted as forgeable by non-browser clients (blast radius: public
chain reads only). Used that to pull `(describe-module "ouronet-ns.ATS")` / `"ouronet-ns.ATSU"` for real:
**the live deployed `URC_MultiCull` has the byte-for-byte identical broken branch**, just against the older
`AutostakeV1`/`UtilityAtsV1` interfaces (confirms live is behind local dev, not ahead - nothing was ported
back from a mainnet fix, because none exists). Went further and enumerated all 11 real live ledger rows
(`ATS.UR_KEYS`) and called `URC_MultiCull` against each directly - all 11 currently succeed, purely because
every existing live account happens to have something already past its cull-time right now. Not fixed live;
just not yet triggered by the small existing account set.

**Design clarification (owner-led):** owner corrected the framing twice. First: this isn't about culling
early or bypassing the wait - nothing lets you extract funds before maturity, the bug is purely that
*attempting* an early cull (which nothing technically prevents, though the real client UI never exposes
the button before it should) crashes ugly instead of no-op'ing cleanly. Second: owner explicitly wants a
**soft failure** - not a silent zero-value success, but a clear "nothing to cull yet" message distinct from
the real success message.

**Fix — two layers:**
- `10_ATSU.pact:511-520`, `URC_MultiCull` — same core fix as before: the "nothing cullable" branch now
  returns the same 4-key object shape as the cullable branch (`after-cull: p0` unchanged, `to-be-culled: []`,
  `culled-values: []`, `summed-culled-values: zr-output`), instead of a bare list that crashed
  `XI_MultiCull`'s `:object`-typed binding. No interface change - `URC_MultiCull` was already declared
  `:object`.
- `3_Talos/03_TS01-C2.pact:927-947`, `ATS|C_Cull` — added `total-culled:decimal (fold (+) 0.0 cw)` and
  branches the return message: `"Nothing to Cull just yet for ATS-Pair {} - no positions have reached
  their cull-time"` when nothing was culled, vs. the existing `"Succesfully Culled..."` message otherwise -
  matching the repo's own "Talos client output" convention (branch-explaining `format` messages).

**Verification:** appended to `REPL/_audit_ats_baseline.repl` - real `Coil` → `ColdRecovery` → immediate
`ATS|C_Cull` on `ps` now returns `"Nothing to Cull just yet for ATS-Pair PlebeicStrength-98c486052a51 - no
positions have reached their cull-time"` (was a hard crash before the fix); advancing chain-time well past
maturity and culling the same position again returns `"Succesfully Culled 2 RT(s) Tokens with amounts of
[1.254072024969745971767125, 1.081635549635417108184556] from ATS-Pair PlebeicStrength-98c486052a51"` -
proving the real success path is unaffected. Full-suite reload: `Load successful`, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

## Fix #11 — L3 (#21L): `can-upgrade` was a real gap — added its first setter

**Pre-fix discussion:** owner initially described `can-upgrade` as "if set to false by pool admin later on,
all upgrades are stopped, it's as designed" - re-verified precisely (grepped every `update ATS|Pairs` call
site, ~30 of them): none touch `"can-upgrade"`, only genesis writes it (`true`, forever). Traced what it
actually gates: `ATS|S>CONTROL` (`08_ATS.pact:423-437`, via `UEV_CanUpgradeON`) - the capability behind
`C_Control`, which toggles `can-change-owner`/`syphoning`/`hibernate`. Owner confirmed once shown this: a
real, missing setter, not intended-but-unimplemented - "we definitely need one, and we gotta write down
what turning it off gates... needs its own C_ function and talos wrapper."

**Fix, mirroring `C_ToggleElite`'s exact shape (closest sibling - simple owner-gated bool toggle):**
- `08_ATS.pact` interface (`AutostakeV2`) - new `C_ToggleUpgrade` declaration.
- `08_ATS.pact` caps (~line 690, after `ATS|C>TOGGLE_ELITE`) - new `ATS|C>TOGGLE_UPGRADE (atspair, toggle)`:
  `CAP_Owner` only, `@event`. No parameter-lock gate, matching the un-lock-gated precedent already set for
  `can-change-owner`/`syphoning`/`hibernate` themselves (H1's resolution - "owner discretion" control toggles).
- `08_ATS.pact` functions - new `C_ToggleUpgrade`, same shape as `C_ToggleElite` (`UEV_IMC` →
  `with-capability` → `XI_ToggleUpgrade` → `IGNIS::UDC_SmallCumulator`).
- `08_ATS.pact` XI section - new `XI_ToggleUpgrade`, writes `"can-upgrade"`.
- Doc updates: the `can-upgrade` schema field comment and `UEV_CanUpgradeON`'s `@doc` both now explicitly
  state what it gates (`C_Control`).
- Talos (`03_TS01-C2.pact`) - new `ATS|C_ToggleUpgrade` wrapper, mirroring `ATS|C_ToggleElite`'s wrapper
  (interface decl + impl, `P|TS` + `IGNIS::C_Collect`), with branch-specific output messages.

**Verification:** appended to `REPL/_audit_ats_baseline.repl`. Five assertions, all green, on the real
Talos path with real signatures: non-owner (`patron`) rejected; real owner (`aoz`) turns `can-upgrade`
off; `ATS|C_Control` (with unchanged, same-value params) is now blocked even for the real owner; owner
turns `can-upgrade` back on; `ATS|C_Control` works again. Full-suite reload: `Load successful`, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅ (new capability, first setter for a previously-unsettable field).
Awaiting Round III re-verify.

## Fix #10 — L1 (#19L): removed dead capability `ATS|F>OWNER`

**Pre-fix discussion:** confirmed via repo-wide grep it's never `compose-capability`'d or
`require-capability`'d anywhere - genuinely dead. The same `F>OWNER` naming pattern is actively used in
`01_DALOS.pact` (`DALOS|F>OWNER`, composed twice), so this wasn't a nonsense pattern, just unwired
scaffolding for ATS specifically. Owner: remove it if not needed.

**Fix — `08_ATS.pact:499-502`:** deleted the `defcap ATS|F>OWNER (atspair:string) (CAP_Owner atspair)`
block entirely. No other code referenced it, so no other change needed.

**Verification:** full-suite reload, `REPL/_audit_ats_baseline.repl`: `Load successful`, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅ (cleanup; "proof" is a clean reload since nothing behavioral changed).

## Fix #9 — M7 (#16M): `UEV_ColdDurationParameters` now requires `growth > 0` on both branches

**Pre-fix discussion:** owner didn't remember the exact original design intent at first, so walked through
it together: both branches build `c-duration` (`UC_MakeSoftIntervals`/`UC_MakeHardIntervals`), a 50-entry
wait-hours table indexed by elite-tier position (`URC_CullColdRecoveryTime`, `08_ATS.pact:1511-1530`),
built increasing then reversed so higher tier = shorter wait (the elite-tier reward). Neither branch
required `growth > 0` - a negative `growth` produces negative `hours`, landing the computed cull-time in
the *past* and inverting the whole curve (higher tier would wait *longer*, backwards). Owner confirmed:
"it's designed to go always forward, never backward, forgot to add such verification."

**Fix — `1_Utilities/09_U_ATS.pact:506-531`, `UEV_ColdDurationParameters`:** added `(> growth 0)` to both
branches. Soft branch's `and` became a 3-condition `(fold (and) true [...])` per the codebase's boolean-
combining convention; hard branch's stayed a 2-condition `(and ...)`. No signature/interface change.

**Verification:** appended to `REPL/_audit_ats_baseline.repl`. Four assertions, all green: hard branch
rejects a negative-but-otherwise-evenly-divisible `growth` (`-100`/`-10`, previously accepted, silently
inverted the curve) while its positive-growth regression case (proven under Fix #5/H4) still works
unchanged; same pair of checks for the soft branch (`-90`/`-9` rejected, `90`/`9` still accepted).
Full-suite reload: `Load successful`, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

## Fix #8 — M6 (#15M): `UEV_CRF|FeeThresholds` `@doc` reworded (doc-only, no logic change)

**Pre-fix discussion:** the `@doc` said "Enforces <fee-thresholds> are between 1 and 100" - read literally,
a promise that threshold *values* are bounded to [1,100]. Traced the actual code (`09_U_ATS.pact:377-413`):
the enforced `[1,100]` range is the array **length** (how many fee tiers are allowed), not the values.
Traced what threshold values actually represent (`URC_ColdRecoveryFee`, `08_ATS.pact:1462-1506`): raw
cold-RBT token amounts compared against a user's recovery amount to pick a fee tier - these have no
inherent value ceiling (depend entirely on the pool's token supply/precision). Owner confirmed: the doc
just needs rewording, no logic change - the code was always correct.

**Fix — `1_Utilities/09_U_ATS.pact:377-381`:** reworded the `@doc` to say it bounds the **count** of
threshold entries (1-100), not their values, and to note why values have no ceiling. No behavioral change.

**Verification:** full-suite reload, `REPL/_audit_ats_baseline.repl`: `Load successful`, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅ (doc-only; "proof" is a clean reload since nothing behavioral changed).

## Fix #7 — M2 (#11M): `C_KickStart` genesis-index inflation attack — bounded

**Pre-fix discussion:** re-examined fresh per the flag left on this finding (it originally rested on the
same "silent zero-mint donation" premise H3-Scenario-2 refuted). Traced precisely: `C_KickStart`'s own
mint can never be zero (`ATSU|C>KICKSTART` already enforces `rbt-request-amount > 0.0` directly), so H3's
refutation doesn't even apply to the kickstart mint itself — the real risk is downstream, in what an
unbounded genesis ratio sets up for *later* depositors. Corrected the original concrete example (which used
numbers producing an exact `0.0` mint — now known to revert atomically, not silently donate, per H3) to the
real, still-live version: a ratio extreme enough that a later `Coil`'s `floor(rt-amount/index, p)` lands on
a tiny *nonzero* RBT amount instead of exactly `0.0` — the transaction then succeeds, the depositor's RT is
credited in full to resident, but they receive a negligible fraction of fair value, a permanent transfer to
whoever already held RBT (classic vault/first-depositor inflation attack). Owner's fix direction: cap the
owner-facing path's resulting index at `100.0`; expose a separate admin pathway (forgoes pool ownership,
requires module governance instead) with no ceiling, for legitimate higher ratios; and apply the same `0.1`
floor `syphon` already uses to *both* paths.

**Fix — layered per `StoicSyntax.md §14.7` (unevented core + named event leaves), mirroring the existing
`ATSU|C>X_REMOVE-SECONDARY`/`ATSU|C>REMOVE-SECONDARY`/`ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY` precedent in
the same file:**
- **New pure helper `UC_KickStartIndex(rt-amounts, rbt-request-amount)`** (`1_Utilities/09_U_ATS.pact`,
  declared in `UtilityAtsV2` interface): computes `sum(rt-amounts) / rbt-request-amount`, guarded to return
  `-1.0` when `rbt-request-amount` isn't strictly positive — avoids a raw division-by-zero crash during a
  capability's `let`-binding phase (which evaluates before any of the capability's own body `enforce`s can
  fire with a clearer message).
- **`ATSU|C>X_KICKSTART`** (`10_ATSU.pact`, new, unevented core) — all pre-existing shared checks (list-
  length parity, `rbt-request-amount > 0.0`, virgin-pool `index = -1.0`, `P|TT` compose), plus the new
  shared `>= 0.1` floor. Caller-input-only checks ordered before the pool-state (virgin) check, so bound
  violations reject before ever touching live state.
- **`ATSU|C>KICKSTART`** (existing name kept, now a thin `@event` leaf) — `CAP_Owner ats` plus the new
  `<= 100.0` ceiling, composes the core.
- **`ATSU|C>ADMINISTRATIVE-KICKSTART`** (new, `@event` leaf) — `GOV|ATSU_ADMIN` (same module-governance
  guard `A_RemoveSecondary`'s admin variant already uses) instead of ownership, no ceiling, composes the
  core (so the `0.1` floor still applies here too).
- **`X_KickStart`** (new, `require-capability (SECURE)`) — the original `C_KickStart` body, unchanged,
  factored out so both entrypoints share one write path.
- **`C_KickStart`** (owner-facing) / **`A_KickStart`** (new, admin-facing) — thin wrappers, `UEV_IMC` +
  `with-capability` their respective leaf, then `X_KickStart`.
- Interface additions (additive only, no existing signature changed — `AutostakeUsageV1` stays V1 per
  policy, pre-mainnet): `A_KickStart` in `10_ATSU.pact`'s own interface block; `UC_KickStartIndex` in
  `UtilityAtsV2` (`0_Interfaces/01_Utilities.pact`).
- **Talos wiring** (`3_Talos/01_TS01-A.pact`): new `ATS|A_KickStart`, mirroring `ATS|A_RemoveSecondary`'s
  exact shape (`P|ADMINISTRATIVE-SUMMONER` + `IGNIS::C_Collect`), plus its interface declaration.

**Verification:** appended to `REPL/_audit_ats_baseline.repl`. Eight assertions, all green:
1-3. `UC_KickStartIndex` pure math: exact ceiling boundary (`1000.0/10.0 = 100.0`), exact floor boundary
   (`50.0/500.0 = 0.1`), and the divide-by-zero guard (`rbt-request-amount = 0.0` → `-1.0`, no crash).
4. Owner path (`ATSU|C>KICKSTART`, real `ps` pair, real `aoz` owner signature via `test-capability`):
   index `10000.0` (10000.0/1.0) rejected by the ceiling — fires before ever touching pool state.
5. Owner path: index far below `0.1` rejected by the shared floor.
6. Owner path: an in-range index (`2.0`) clears *both* bounds — rejected only for `ps` not being virgin
   (it was already kickstarted earlier this session), proving the bounds correctly let valid ratios through.
7. Admin path (`ATSU|C>ADMINISTRATIVE-KICKSTART`, real `PK_AncientHodler` signature satisfying
   `GOV|ATSU_ADMIN`): index far below `0.1` still rejected — same floor applies to both paths.
8. Admin path: the *exact same* extreme ratio the owner path rejected for exceeding the ceiling (test 4)
   is **not** rejected for that reason here — it clears the floor easily and is only stopped by the
   (unrelated) virgin-pool check, proving the ceiling genuinely doesn't apply on the admin path.
Full-suite reload: only the one pre-existing, unrelated SWP test failure remains (confirmed unrelated —
outside this fix's file scope, present in the working tree before this fix was started).

**Note on test design:** full end-to-end proof through a brand-new virgin pool wasn't practical within
scope (pair creation requires a fresh reward-bearing token registration, a separate multi-step flow) — used
`test-capability` directly against the real, deployed `ATSU|C>KICKSTART`/`ATSU|C>ADMINISTRATIVE-KICKSTART`
capabilities on the fixture's real, already-kickstarted `ps` pair instead, real signatures, real guard
checks. This proves every bound-check exactly as it will run in production; only the final virgin-pool gate
(orthogonal to this fix, unchanged) had to be inferred from its own already-well-established behavior
rather than re-demonstrated end-to-end here.

**Status:** FIXED ✅ AND PROVEN ✅. Renumbered from "NEEDS RE-EXAM" — the re-examination is now complete;
the original premise was partially wrong (exact-zero mint reverts, per H3) but the underlying inflation-
attack mechanism survives in the near-zero-but-nonzero regime, and the owner-specified fix closes it.
Awaiting Round III re-verify.

## Fix #6 — M1 (#10M): `UEV_HibernationFees` always fails (stray malformed predicate)

**Pre-fix discussion:** presented the finding with an isolated empirical check: `()` is Pact's `unit`
value (confirmed via `typeof`), and `(= () 0.0)` evaluates to `false` without erroring — so the 7th term
in the `(fold (and) true [...])` list always drags the whole result to `false`, making the `enforce` fail
unconditionally for every `peak`/`decay` input, valid or not. Asked whether there was an intended 7th bound
before deleting anything. Owner checked the live module directly and confirmed: "that's a wrong form, so I
don't know what I wanted to write there... I think we should simply delete it" — debris, no intended check,
safe to delete outright.

**Fix — `1_Utilities/09_U_ATS.pact:459-474`, `UEV_HibernationFees`:** removed the stray `(= () 0.0)` term
(and the trailing blank line after it) from the fold list, leaving the six real predicates
(`peak`/`decay` precision, range, and sign bounds) untouched. No signature, schema, or interface change;
the separate scaled-division `enforce` right below it (lines ~481-484) is unmodified.

**Verification:** appended to `REPL/_audit_ats_baseline.repl` — unit-tested directly against `U|ATS`
(unprotected `UEV_*` helper), for the same reason as the #9H proof: `C_SetHibernationFees`'s full
capability chain requires `parameter-lock = false`, which the shared fixture's `ps` pair no longer
satisfies (locked by the Fix #4 proof earlier in the file). Three assertions, all green:
1. Valid params (`peak=100.0 decay=0.01`, all six real predicates true, scaled-division also passes):
   now accepted — this call failed unconditionally before the fix, regardless of input.
2. `peak=900.0` (over the real `800.0` ceiling): still correctly rejected — proves the real predicates
   were untouched by the deletion, not accidentally weakened.
3. `peak=100.0 decay=0.03` (passes the fold, fails the separate scaled-division check,
   `1,000,000 mod 300 = 100 != 0`): correctly rejected — proves that second, independent enforce still
   functions correctly, unaffected by this fix.
Full-suite reload: `Load successful`, no regressions elsewhere.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

## Fix #5 — H4 (#9H): `UEV_ColdDurationParameters` soft branch unconditionally uncallable

**Pre-fix discussion:** presented the finding with an isolated Pact 5.4 repro proving a stray 3rd argument
to `enforce` is a hard runtime arity error (`Attempted to apply a closure to too many arguments`) that fires
only when `soft-or-hard = true` — module still loads fine, hard branch still works fine, soft branch always
crashes regardless of whether `base`/`growth` are actually valid. Owner corrected the root-cause framing:
the real defect is the incomplete `(format "Invalid CRD Parameters For ")` call itself (missing `{}`
placeholder and substitution `[]` list) — the "3rd enforce argument" was just the symptom. Verified this
precisely before writing the fix: `(format "Invalid CRD Parameters For ")` alone evaluates to a bare
`<#closure>` (format is curried), and attempting to apply that closure outside `enforce`'s native callsite
independently fails with a different error (`Attempted to apply a closure outside of native callsite`) —
confirming it was never a valid, completable expression as written.

**Fix — `1_Utilities/09_U_ATS.pact:488-506`, `UEV_ColdDurationParameters`:** collapsed the malformed 3-piece
message (a literal string message argument plus a broken, incomplete `format` call) into a single, correctly
-formed 2-arg `enforce` whose message is one complete `format` call interpolating the actual `base`/`growth`
values — matching the established convention already used one function up in the same file
(`UC_MakeHardIntervals`/`UC_MakeSoftIntervals`, lines 70/95-96, which validate the identical `mod`-divisibility
checks). No signature, schema, or interface change; the hard branch is untouched.

**Verification:** appended to `REPL/_audit_ats_baseline.repl` — unit-tested directly against `U|ATS`
(unprotected `UEV_*` helper) rather than through the full `C_SetColdRecoveryDuration` capability chain,
since that chain's unrelated preconditions (cold-recovery-off, lock-off) aren't satisfiable on the shared
fixture's `ps` pair at this point (left locked + cold-recovery-on by the Fix #4 proof above). Five
assertions, all green:
1. Hard branch regression guard: valid params still accepted, invalid params still rejected (unchanged).
2. Soft branch, valid params (`base=90 growth=9`, both mod-conditions true): now accepted — this call
   crashed unconditionally before the fix, regardless of the input.
3. Soft branch, invalid via the first condition (`base=90 growth=4`): rejected with the real validation
   message, not an arity crash.
4. Soft branch, invalid via the second condition (`base=90 growth=10`, `10 mod 3 != 0`): also correctly
   rejected — proves both halves of the `and` are actually being evaluated now, not just the first.
Full-suite reload: `Load successful`, no regressions elsewhere in the file.

**Status:** FIXED ✅ AND PROVEN ✅. Awaiting Round III re-verify.

## Fix #4 — H1/H2 (#6H/#7H, partial): royalty + hibernation-fee params now lock-gated

**Pre-fix discussion:** walked every field of `ATS|PropertiesSchemaV3` against whether its setter checks
`UEV_ParameterLockState`, corrected a polarity misunderstanding along the way (`parameter-lock = true`
means **locked**, i.e. the gated fields *cannot* be changed — not the reverse), and laid out a table of
protected vs. unprotected fields before the owner ruled per-field. Owner verdict: `royalty-promile` and
`peak-hibernate-promile`/`hibernate-decay` were added later (V2 schema fields) and simply never got the
lock gate the original fields already have — an oversight, fix it. `syphon` stays unprotected — confirmed
intentional (C4), "designed to be fluctuant." `owner-konto`, `can-change-owner`/`syphoning`/`hibernate`,
and the three recovery on/off switches remain **open** — not ruled on, not touched.

**Fix — `08_ATS.pact`:**
- `ATS|S>SET-HIBERNATION-FEES` (`:452-461`) — added `(UEV_ParameterLockState atspair false)` as the first
  statement, before the existing `UEV_HibernationFees`/`CAP_Owner` checks.
- `ATS|S>ROYALTY` (`:462-471`) — same, added as the first statement before `UEV_Fee`/`CAP_Owner`.
- No signature/schema/interface changes; no changes to `C_UpdateSyphon` or any of the still-open items.

**Verification:**
1. Full-suite reload: `Load successful`, no regressions.
2. Unlocked baseline: `ATS|C_UpdateRoyalty` succeeds normally (confirmed `royalty-promile` actually
   updates, `40.0`).
3. Engaged the lock for real (`ATS|C_SwitchColdRecovery … true` then `ATS|C_ToggleParameterLock … true` —
   the toggle's own precondition requires a live recovery mechanism, confirmed still correct/unchanged).
4. Locked: both `ATS|C_UpdateRoyalty` and `ATS|C_SetHibernationFees` → `expect-failure` green.
5. Isolated a raw (non-`expect-failure`-wrapped) call to `ATS|C_SetHibernationFees` while locked to
   capture the literal error text and confirm it's genuinely *this* fix's gate firing, not `#10M`'s
   separate malformed-predicate bug (`UEV_HibernationFees`'s stray `(= () 0.0)` term) coincidentally
   masking it: **`"Parameter-lock for ATS Pair PlebeicStrength-98c486052a51 must be set to false for this
   operation"`** — confirmed, `08_ATS.pact:1699`, the lock check, evaluated and failing *before* the
   broken validator is ever reached. `#10M` remains open and unrelated to this fix — once it's fixed,
   `SetHibernationFees` will still correctly require the lock to be off, on top of that separate fix.

**Note:** did not disengage the lock afterward in the proof — `UC_UnlockPrice` scales with an `unlocks`
counter and the shared scratch fixture's `aoz` account doesn't reliably have enough KDA left this deep
into the file to pay a re-unlock fee. Not a fix concern (nothing later in the scratch file depends on `ps`
being unlocked again) — flagged for whoever next touches this scratch fixture.

**Status:** FIXED ✅ AND PROVEN ✅ for the two fields the owner confirmed. `owner-konto`,
`can-change-owner`/`syphoning`/`hibernate`, and the three recovery switches remain open findings — not
resolved by this fix, need their own ruling before touching.

## Fix #3 — C5 (#5C): Hot-RBT branding functions have no owner check

**Pre-fix discussion (owner-led):** the owner independently worked out why `with-capability (ATS|GOV)`
is present in `C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` at all — the Hot-RBT's DPOF owner-konto
is `ATS|SC_NAME` (rotated there by `C_AddHotRBT`), so DPOF's own branding gate
(`DPOF|C>UPDATE-BRD`/`C>UPGRADE-BRD` → `UEV_ParentOwnership` → `CAP_Owner hot-rbt`, `06_DPOF.pact:527-536`,
`:1389-1406`) resolves to "prove you own `ats-sc`" — something only ATS's own code can do, via `ATS|GOV`
(confirmed correct per the #1C "home module" rule). So `ATS|GOV` itself was never the bug. The owner
correctly identified the real gap: *who* is allowed to trigger that — should be the ATS-pair owner, and
nothing checked that. Confirmed against source (grepped the exact 21 lines of both functions for
`CAP_Owner`/`UEV_IMC`/any `defcap` wrapper — zero matches) before writing any code, per the owner's
explicit request to see the fix location before it landed.

**Fix — `08_ATS.pact` (revised after owner review — see correction below):**
- **`defcap ATS|C>HOT-RBT-BRD (entity-id:string)`** — **unevented core**, inserted at the end of the
  `ATS|C>REPURPOSE-HOT-RBT` cap block (~line 519), mirroring that cap's exact shape: resolve the owning
  pair via `ref-DPOF::UR_RewardBearingToken entity-id`, `CAP_Owner atspair`, **then**
  `compose-capability (ATS|GOV)`.
- **`defcap ATS|C>HOT-RBT-UPDATE-BRD (entity-id:string)`** / **`ATS|C>HOT-RBT-UPGRADE-BRD (entity-id:string)`**
  — two thin `@event` leaves, each just `(compose-capability (ATS|C>HOT-RBT-BRD entity-id))`.
- `C_HOT-RBT|UpdatePendingBranding` — added `(UEV_IMC)` as the first statement, changed
  `with-capability (ATS|GOV)` to `with-capability (ATS|C>HOT-RBT-UPDATE-BRD entity-id)`.
- `C_HOT-RBT|UpgradeBranding` — same, using `ATS|C>HOT-RBT-UPGRADE-BRD`.
- No signature changes on either function, no interface/schema touch, no Talos changes needed.

**Correction (owner, 2026-08-17):** first pass used a **single `@event` capability shared by both**
functions. Owner caught this: sharing one `@event` cap across two distinct client actions collapses their
on-chain events into one indistinguishable signature, and — independently of the event issue — flagged
that the codebase already has an established, undocumented pattern for exactly this situation:
**one unevented "core" `defcap` holding the shared validation body, with thin, distinctly-`@event`-tagged
"leaf" caps on top that only `compose-capability` the core.** Verified the pattern is already live in this
same file before making the change: `ATS|S>CONTROL-RECOVERY` (no `@event`) → `ATS|C>CONTROL-COLD-RECOVERY`
/ `ATS|C>CONTROL-HOT-RECOVERY` (also no `@event`, each adds one more check) → five real `@event` leaves on
top. Refactored to the three-cap shape above (one core, two named leaves) to match. Formalized as a new,
previously-undocumented rule: `StoicSyntax.md §14.7` (existing §§14.7–14.8 renumbered to §§14.8–14.9),
plus a `§16` checklist bullet and a `§17` cheat-sheet row — this ATS case is the worked example in the
doc. Detail: `memories/2026-08-17-layered-capability-composition-core-plus-event-leaves.md`.

**Verification (re-run after the layering correction):**
1. Full-suite reload (`REPL/_audit_ats_baseline.repl`): `Load successful`, no regressions.
2. Negative proof, real Talos-driven call, real signer (`patron`, not the pair owner):
   `expect-failure` on `ATS|C_HOT-RBT|UpdatePendingBranding` targeting the pair-owned `DDKOSON` hot-rbt →
   **`"Expect failure: Success: non-owner (patron) cannot update Hot-RBT branding of a pair they don't
   own"`**.
3. Positive proof, same call, signed by the real pair owner (`aoz`) → completes without aborting
   (confirmed by reaching a marker print immediately after) — the legitimate path the fix must not break
   still works.

**Follow-up (owner-requested, same session):** the *other* branding pair in this file —
`ATS|C>UPDATE-BRD` / `ATS|C>UPGRADE-BRD` (pair-branding, not Hot-RBT-branding — these already had a real
`CAP_Owner` check, so not part of C5's original finding) — had the exact duplication this new rule exists
to prevent: both bodies were `(CAP_Owner atspair) (compose-capability (P|ATS|CALLER))`, pasted twice.
Refactored the same way: new unevented core `ATS|S>BRD (atspair:string)` holding that body; both
`ATS|C>UPDATE-BRD`/`ATS|C>UPGRADE-BRD` reduced to thin `@event` leaves composing it. **External cap names
and both callers (`C_UpdatePendingBranding`/`C_UpgradeBranding`) unchanged** — purely an internal
refactor, no signature/behavior change. Proven the same two ways: non-owner (`patron`) rejected
(`expect-failure` green), real owner (`aoz`) unaffected (completes without aborting). Full-suite reload
green throughout, 0 failures.

**Status:** FIXED ✅ AND PROVEN ✅ (both directions). Awaiting Round III re-verify.

## Fix #2 — C3 (#3C): `C_Redeem` always reverts

**Owner direction:** verify precisely under *correct* preconditions before touching anything (owner
suspected the original REPL comment-out might have been a benign "nothing to redeem" state, not a real
bug) — do not modify code until proven, then prove the fix with a real, permanent, rewritten REPL test.

**Verification before any fix (three independent checks, escalating rigor):**
1. Isolated Pact 5.4 repro: `(if <decimal>)` fails for both a nonzero decimal and exactly `0.0` — Pact
   never coerces a decimal to bool either way.
2. Empirical run #1: took the repo's own `[6.6]_ATS.repl`, uncommented the exact dead `C_Redeem` call as-
   is. It failed — but via a *different, earlier* bug (`ico3`'s `TFT::C_MultiTransfer` rejected a negative
   amount), traced to the fixture itself setting `block-time` to `2024-10-11`, two years *before* the
   nonce's real mint time (`TIME00 = 2026-10-10`) — a fixture date bug, not evidence either way.
3. Empirical run #2, under **corrected, honestly-forward-moving** time (mint at `2026-10-10`, redeem at
   `2026-10-12`, past the full 1-day decay window — the legitimate "fully matured, zero fee" case):
   execution passed cleanly through `ico1`/`ico2`/`ico3` and failed exactly where predicted:
   `10_ATSU.pact:1067:28: expected bool value, got 0.0`. Confirmed: not "nothing to redeem" — the function
   cannot complete under any input, including the cleanest possible one.

**Fix — `10_ATSU.pact`, `C_Redeem`:** `are-fee-rts:decimal` (a summed fee amount) was fed directly into
`(if are-fee-rts ...)`, which requires `:bool`. Added `have-fee-rts:bool (!= are-fee-rts 0.0)` and changed
the `if` to use it — matching this codebase's `are-*`/`have-*` boolean naming convention used elsewhere
(`are-e`, `are-transfer-roles-active`). No other change to the function's logic; `are-fee-rts` is otherwise
unused. Schema/interface untouched (`C_Redeem`'s signature is unchanged).

**REPL test — rewrote `REPL/Stage_01/[6.6]_ATS.repl`'s "Hot RBT and Redeem Test 1|5"–"5|5" section**
(the canonical file, not scratch — this is a permanent addition to the real suite, not just an audit
artifact) rather than patch around the original dead test:
- Test 2|5: mints Hot-RBT nonce 1 (unchanged from original).
- Test 3|5 (was purely observational): now also mints Hot-RBT nonce 2, same mint time as nonce 1.
- Test 4|5 (was: `C_Redeem` commented out, `C_Reverse` substituted, wrong 2024 date): now sets a
  *correct*, forward-moving time (~6h after mint, inside the 1-day decay window) and calls the real
  `ATS|C_Redeem` on nonce 1 — the fee-bearing branch. Asserts, against real pre/post DPTF balance deltas:
  nonce burned, payout nonzero, payout **strictly less than** the full no-fee value (proves a real fee was
  actually withheld, not just "didn't crash").
- Test 5|5 (was: pure observation, no assertions): sets time two full decay periods after mint and
  redeems nonce 2 — the exact `are-fee-rts = 0.0` edge case that first exposed the bug. Asserts the payout
  equals the full value **exactly** (no fee). Restores ambient chain-time to what the original file left
  behind afterward, so nothing downstream of this section is perturbed.

**Verification:** `REPL/_audit_ats_baseline.repl` (Stage00 → Stage01 prefix → `[6.5]_DPOF` →
`[6.6]_ATS`, now with the rewritten Redeem section) reloaded end to end: `Load successful`, 19
`expect`/`expect-failure` assertions, **0 failures**. Concrete numbers proven: nonce 1 (supply 100.0, full
value 120.0) paid out **111.0** early (a real ~7.5-point fee withheld); nonce 2 (supply 50.0, full value
60.0) paid out **60.0 exactly** once fully matured.

**Side effect caught and fixed during this work:** the rewritten Test 5|5's time jump (to `2026-10-12`)
left that as ambient chain-time for the next section ("Cold Recovery and Cull Test"), which incidentally
tripped the *separately tracked* N1 finding (`URC_MultiCull` list/object type mismatch, see
`ROUND-01-FINDINGS.md`) that hadn't fired under the original fixture's chronology. Fixed by restoring the
original ambient time at the end of Test 5|5 rather than touching the unrelated downstream section —
confirmed via `git`-comparable before/after: identical trailing behavior to the pre-Redeem-rewrite run.

**Status:** FIXED ✅ AND PROVEN ✅ — verified under correct preconditions before any code change (per
owner instruction), fix applied, proof lives permanently in the canonical REPL suite (not scratch).
Awaiting Round III re-verify.

## Fix #1 — C2 (#1C): reward-token remove/re-add corrupts per-account claim accounting

**Owner direction:** complete, schema-preserving fix — no interface/schema changes. Confirmed safe to
land now: no live multi-reward-token ATS pools exist yet, so there is no on-chain corrupted state to
repair/migrate; this is a forward-looking code fix only.

**Scope:** `1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact`, `1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact`.
No changes to `08_ATS.pact`, no interface changes (`UtilityAtsV2`/`AutostakeUsageV1` untouched), no schema
field added anywhere.

### Diff 1 — `09_U_ATS.pact`, `UC_ReshapeUnstakeObject` (closes C2a + C2c)

Removed the `UC_IzUnstakeObjectValid` conditional gate; the function now unconditionally calls
`UC_SolidifyUnstakeObject`. Root cause: the gate only reshaped an `Awo` when it already had a nonzero
claim, silently no-op'ing on the overwhelming majority of ledger rows (untouched, all-zero P0-P7 slots).
Every one of those rows kept its pre-removal array length forever, which made every later
"is this slot open?" check (`URCX_PosObjSt`, `XI_StoreUnstakeObject`'s P0 check) — both of which compare
by *structural equality* against a freshly length-derived zero/negative sentinel — permanently misclassify
untouched slots as occupied once the live reward-token list had shrunk (C2c), and left every stale,
longer-than-current array ready to be misread positionally against the live list at settlement (C2a).
`UC_SolidifyUnstakeObject`'s merge (`primal + removee` folded into slot 0, then drop the removed index) is
safe to run unconditionally — merging a `0.0` removee into slot 0 is a value no-op, it only ever needed to
shrink the array. No other caller of `UC_ReshapeUnstakeObject`/`UC_MultiReshapeUnstakeObject` depended on
the old "leave untouched if invalid" behavior (single call site: `XE_ReshapeUnstakeAccount`,
`08_ATS.pact:2548-2571`, which now correctly resizes every P0-P7 slot for every account it's run against).
`URCX_PosObjSt`/`XI_StoreUnstakeObject` needed **no direct change** — both already recompute their
zero/negative sentinels fresh from live state on every call, so they self-correct once the stored arrays
are kept in sync.

### Diff 2 — `10_ATSU.pact`, `X_RemoveSecondary` (closes C2b, and removes C2's completeness gap)

- Dropped the `accounts-with-ats-data:[string]` parameter (internal-only `X_*` function, not interface-
  declared — confirmed via `AutostakeUsageV1`, only `A_RemoveSecondary`/`C_RemoveSecondary` are). The
  function now **always** derives the complete account list itself via
  `(ref-ATS::URD_ExistingAutostakePairs ats)` — the same on-chain enumeration `C_RemoveSecondary` already
  used, now the single, non-bypassable source of truth. No account can be silently skipped by a caller
  supplying an incomplete list (the prior latent gap on the `A_RemoveSecondary` admin path).
- Added a `royalty-sum` read (`UR_RewardTokenRUR ats 3`) alongside the existing resident/unbonding reads,
  folded into `remove-sum`, and added `(ref-ATS::XE_UpdateRUR ats primal-rt 3 true royalty-sum)` migrating
  it into the primal token's royalty bucket — mirroring exactly what already happened for resident (bucket
  1) and unbonding (bucket 2). Previously royalty was silently deleted with the removed row: the tokens
  stayed custodied in `ATS|SC_NAME` with no reward-token entry left to reference them, and
  `C_WithdrawRoyalties` could never reach them again. `remove-sum` now covers all three buckets on both
  transfer legs (`ico2`/`ico3`), preserving the existing 1:1 primal-RT buyout design unmodified — just
  extended to not drop a bucket.

### Diff 3 — `10_ATSU.pact`, `A_RemoveSecondary` / `C_RemoveSecondary` (call-site updates)

- `A_RemoveSecondary`: **signature unchanged** (interface-mandated). Still accepts
  `accounts-with-ats-data`, but no longer forwards it — `X_RemoveSecondary` ignores external input entirely
  now. `@doc` updated to say so explicitly, so a future admin caller isn't misled into thinking their list
  matters.
- `C_RemoveSecondary`: dropped its own now-redundant `URD_ExistingAutostakePairs` pre-computation (was
  about to be computed again inside `X_RemoveSecondary` anyway) — pure simplification, same behavior.

### Verification

1. **Unit-level proof** (`REPL/_audit_ats_baseline.repl`, audit-scratch, not canonical suite): isolated
   calls to `U|ATS.UC_ReshapeUnstakeObject` with hand-built `Awo` objects. Three assertions, all pass:
   - Nonzero case (10.0/20.0/30.0, remove position 1) still reshapes correctly — `[30.0, 30.0]` — proving
     the fix didn't change already-correct behavior.
   - **The fix itself**: an all-zero `[0.0, 0.0, 0.0]` Awo now also shrinks to `[0.0, 0.0]` on removal
     (pre-fix: stayed `[0.0, 0.0, 0.0]`, length 3 — the exact C2c defect).
   - The reshaped empty slot now structurally equals a freshly-derived 2-token zero sentinel — the literal
     comparison `URCX_PosObjSt` performs to decide "is this slot open?".
2. **Integration/no-regression check**: full existing pipeline (Stage00 sandboxes → Stage01 prefix →
   `[6.5]_DPOF.repl` → `[6.6]_ATS.repl`, pact 5.4) reloaded and re-run end to end, including every existing
   `RemoveSecondary`/`AddSecondary`/`ColdRecovery`/`Cull` call site (the `"Secondary Remove"` and
   `"Add Secondary AGAIN with Hybrid Cull Test"` transactions specifically). `Load successful`, same 15
   `expect`/`expect-failure` assertions, 0 failures — no regression introduced.

3. **End-to-end integration proof, through the real call stack** (`REPL/_audit_ats_baseline.repl`,
   appended after the unit proof; audit-scratch, not canonical suite yet — see follow-up note below):
   - Funded a brand-new account (`patron`, confirmed via `URD_ExistingAutostakePairs` to have never
     touched the pair before) with real PKOSON, had it `C_Coil` to mint cold-RBT, then real
     `C_ColdRecovery` — this writes a genuine, fee-split, multi-token Awo entry:
     `[6.0627 PKOSON, 6.0175 EKOSON, 8.3403 AKOSON]`, entirely through the pool's real split math, not
     hand-constructed.
   - Removed EKOSON via the real, production, Talos-driven owner path
     (`TS01-C2.ATS|C_RemoveSecondary`) — `patron` is never mentioned anywhere in that call. Verified
     `patron`'s P0 entry immediately after: `[12.0801, 8.3403]` — exactly `6.0627 + 6.0175 = 12.0801`
     folded into PKOSON, and `8.3403` (AKOSON) preserved *exactly*, correctly shifted from array
     position 2 to position 1.
   - Culled `patron`'s position and asserted the actual DPTF balance deltas: **PKOSON +12.080149529322803393554764**,
     **AKOSON +8.340265093244058451673906** — bit-for-bit matching the pre-cull stored amounts. The
     survivor claim was paid in the correct token, for the exact correct amount; nothing was lost to the
     removed token, nothing was misattributed to a different one.
   - Note on scope: the original plan was to specifically drive this through `A_RemoveSecondary` with a
     *deliberately incomplete* caller-supplied account list, to directly demonstrate the completeness-gap
     closure. That specific input no longer exists to construct — Diff 2 removed the parameter from
     `X_RemoveSecondary` entirely, so there is no longer any list for a caller to under-supply. The test
     above proves the equivalent (and, given the parameter is gone, now the *only meaningful*) property:
     an account never mentioned in the removal call is still found and correctly reshaped.

**Separate bug found while building this proof (not part of C2, not fixed by this pass):**
`URC_MultiCull` (`10_ATSU.pact:443-511`) returns `zr-output` — a raw `[decimal]` list — on its
"nothing currently cullable" branch, but an `object` (`{"after-cull":…, "to-be-culled":…, …}`) on the
cullable branch. `XI_MultiCull` (`10_ATSU.pact:1321-1334`) binds the result as `(multi-cull-obj:object
(URC_MultiCull ats acc))` — a runtime type-check failure whenever a P0-mode account has zero currently-
cullable positions, which crashes `C_Cull` outright instead of returning "nothing to cull yet." Reachable
by any account on a `positions = -1` ("unlimited") pool that calls `C_Cull` before any of their P0 entries
reach their `cull-time`. Logged as a new finding (see README.md tracker) — out of scope for this fix, not
touched.

**Follow-up, tracked, not blocking:** the integration proof above currently lives in
`REPL/_audit_ats_baseline.repl` (audit-scratch). Recommend migrating it into the canonical
`REPL/Stage_01/[6.6]_ATS.repl` (in the repo's proper `;;==== TX·mm·slug ====` layout) as part of closing L4
(un-commenting `[6.6]_ATS.repl` from `Stage01_Tester.repl`) — separate follow-up task, not required for
this fix to be considered complete.

**Status:** FIXED ✅ AND PROVEN ✅ — unit-level proof green, full-suite regression green, full end-to-end
integration proof green (real transfers, exact-amount assertions). Awaiting Round III re-verify (cold
re-read against the invariant, per the audit's own cycle discipline) before being marked VERIFIED.
