# ROUND II — Fixes (ATS modules)

One entry per fix, applied sequentially, owner green-lit before landing. Diff summary + why.

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
