# ROUND II — Fixes (ATS modules)

One entry per fix, applied sequentially, owner green-lit before landing. Diff summary + why.

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
