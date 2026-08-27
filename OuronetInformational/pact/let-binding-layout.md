# `let` binding layout (Ouronet Pact)

When a **`let`** binds **module references** and **local variables** together:

```pact
(let
    (
        (ref-DALOS:module{OuronetDalosV1} DALOS)
        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
        ;;
        (key:string (UC_DPTFTrackerKey ...))
        (bal:decimal (UR_AQP|DPTFTrackerBalance ...))
        (delta:decimal (if direction amount (- amount)))
    )
    ...
)
```

## Order

1. **All `(ref-*:module{…} …)` bindings** — every cross-module reference used in the body.
2. **`;;` separator** — blank comment line on its own (same indent as bindings).
3. **Variables** — keys, computed values, **`ico*`** cumulator bindings, etc.

## Variable section

- **Preserve internal `;;` groups** when variables are logically chunked (see **`URC_SingularUserScoreDeltaFromSignedUserBase`** in **`02_SCORE.pact`**).
- **Single-ref one-liners** — `(let ((ref-DALOS:module{…} DALOS)) …)` need no separator (no local vars).
- **Bind once, reuse** — when the same expression appears in multiple **`enforce`** lines (e.g. **`(length entries)`**, **`(length nonces)`**), bind it in **`let`** first (`entry-count:integer`, `l-n:integer`, …) and reference the binding. Avoids redundant evaluation and keeps cap bodies readable.

## Reference

- **`04_FVT.pact`** — **`URC_StoaValue`**, **`CC_TrueFungibleStakeFlow`**
- **`02_SCORE.pact`** — **`URC_SingularUserScoreDeltaFromSignedUserBase`**
- **`03_AQP.pact`** — **`XI_WriteDptfTracker`**, **`C_IssuePool`**

**Cursor skill:** `OuronetInformational/ouronet/conventions/index.md` — see also **`function-body-order.md`** for full **`defcap`** / **`C_*`** statement order.
