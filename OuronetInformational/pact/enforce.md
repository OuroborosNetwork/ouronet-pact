
# Ouronet — combining booleans (`enforce`, caps, and `:bool` checks)

## Rule (by count of boolean conditions)

| Count | Use |
|-------|-----|
| **1** | `(enforce predicate "message")` or return `predicate` from a `:bool` function |
| **2** | `(enforce (and p q) "message")` or `(and p q)` as the final form in a `let` |
| **3 or more** | `(enforce (fold (and) true [p q r ...]) "message")` or `(fold (and) true [p q r ...])` |

Do **not** use `fold (and)` for one or two booleans. Do **not** use a single-element list in `fold` when one plain predicate suffices.

## Applies beyond `enforce`

The same arity rule applies anywhere you combine booleans:

- **`defcap`** validation (then wrapped in **`enforce`**)
- **`:bool` utilities** — e.g. **`GLYPH|UEV_ApolloAccountCheck`**, **`GLYPH|UEV_DalosAccountCheck`**, **`UC_IzStoicTagIndex`**
- Final expression of a **`let`** that returns **`bool`**

### Symptom when wrong

```
Attempted to apply a closure to too many arguments
```

Stack trace points at **`(and`** with **three or more** operands. Pact **`and`** is **binary only** (unlike Lisp).

### Fixed references (Stage 01)

- **`08_U_DALOS.pact`** — **`GLYPH|UEV_ApolloAccountCheck`**, **`GLYPH|UEV_DalosAccountCheck`**
- **`09_U_ATS.pact`** — **`UC_IzStoicTagIndex`**
- **`22_CODEX.pact`** — **`UC_ValidateCompositeCodexId`**

Prefer the **Apollo / Dalos check** style: compute bindings in **`let`**, then one **`(fold (and) true [ … ])`** as the body — avoid chained **`t1`**, **`t2`**, **`(and t1 t2)`** unless you only have two leaves.

## Non-boolean checks

Keep **`CAP_EnforceAccountOwnership`**, **`UEV_*`**, **`UEV_Fee`**, and similar **outside** grouped boolean **`enforce`** when they are bare **`ref-*`** calls (step 2). **`(enforce …)`** lines are always step 1 — including **`(enforce (ref-DPTF::URC_IzRBTg …))`**. See **`function-body-order.md`**.

## References

- **`OuronetInformational/pact/enforce-boolean-grouping.md`**
- **`OuronetInformational/ouronet/MODULE_ARCHITECTURE.md`** — § **Combining boolean checks in one `enforce`**
- **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`** — **`SCR|XI>ISSUE-SCORE`** (fold), **`SCR|C>ROTATE-OWNERSHIP-SCORE`** (`and`), **`SCR|C>CONTROL-SCORE`** (plain)
