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

**Not yet done** — flagged, not silently skipped: a dedicated end-to-end integration regression proving the
full C2(a) scenario (a position opened *before* a removal, still open across a remove+re-add cycle, culled
*after*, asserting the payout lands in the originally-owed token/amount, not the newly-added one) through
real Talos calls with real token transfers. The unit-level proof above establishes the core logic is
correct in isolation; this would additionally prove it through the full call stack. Recommend building this
as part of migrating `[6.6]_ATS.repl` into the canonical pipeline (closes L4 at the same time) — separate,
trackable follow-up, not blocking this fix.

**Status:** FIXED ✅ — awaiting Round III re-verify (cold re-read against the invariant, per the audit's
own cycle discipline).
