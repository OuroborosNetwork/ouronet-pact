# 2026-08-19 — `select` is disallowed inside an `enforce` predicate (Pact rule)

Learned while building the enforced-fresh **inject CC-batch** (`CC_InjectFinalize`, #FP4.3). Cost real
debugging time because the error message points at the DB layer, not at the `enforce`.

## The concrete case

`CC_InjectFinalize` must refuse to inject while any present staker is stale. First cut put the scan directly
in the enforce:

```lisp
;; WRONG — select inside the enforce predicate
(enforce (= 0 (length (URH_FvtStalePresentUsers fvt-id)))
    "Stale stakers remain — page CC_InjectFixChunk first")
```

`URH_FvtStalePresentUsers` does a `select` over `FVT|T|UserPresence`. At runtime this aborted with:

```
Error during database operation: Operation disallowed in read-only or sys-only mode
  at ... URH_FvtPresentUsers ... (select FVT|T|UserPresence ...)
```

The tell: it failed **even in a normal `begin-tx`** (not just under REPL `expect-failure`). The single-tx
`CC_Inject` calls the *same* `select` and works — because there it sits inside a `map`, not an `enforce`.

## The rule

**Pact evaluates an `enforce` condition in a read-only / sys-only sub-context, where `select` / `keys` /
`fold-db` (any table scan) are disallowed.** Point reads (`read`, `with-default-read`, `with-read`) are fine
inside an enforce; **scans are not.**

## The fix (pattern)

Compute the scan in a `let`, then `enforce` on the plain value:

```lisp
;; RIGHT
(let ((stale-remaining:integer (length (URH_FvtStalePresentUsers fvt-id))))
    (enforce (= 0 stale-remaining) "Stale stakers remain — page CC_InjectFixChunk first")
    ...)
```

## Notes / where it bites

- Same failure surfaces under REPL `expect-failure`, which runs the expression in a read-only savepoint — so a
  `select`-using call inside `expect-failure` fails with this DB error rather than your intended `enforce` message.
  Use the generic 2-arg `expect-failure` (any error) when the negative path scans, and assert the enforce's
  *condition* (e.g. `> stale 0`) separately in a normal context. (See `[6.2.8c]_AQP-INJECT-CC.repl` A-gate.)
- Distinct from the gas question — see `2026-08-14-selects-dirty-read-and-purpose-built-tables.md` (selects are
  *cheap* under the 2M ceiling). That lesson is "select cost"; this one is "where select may be *called*."
- Ref: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_FVT.pact` `CC_InjectFinalize`; `Audit/M3-DEB-DESIGN.md` §2.7.
