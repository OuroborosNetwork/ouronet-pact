# Pact: one `enforce`, multiple booleans (Ouronet)

When several **boolean** checks should share **one** failure message in **`defcap`** or **`defun`** bodies:

1. **One predicate** — `(enforce p "msg")`
2. **Two predicates** — `(enforce (and p q) "msg")`  
   Pact **`and`** takes **two** boolean arguments only; no `fold`.
3. **Three or more** — `(enforce (fold (and) true [p q r ...]) "msg")`

The **same 1 / 2 / 3+ rule** applies to **`:bool` return functions** (no `enforce` wrapper): final form **`(fold (and) true [ … ])`** or **`(and p q)`**.

### Runtime error if violated

```
Attempted to apply a closure to too many arguments
```

Usually at **`(and`** with 3+ operands. Fixed examples: **`U|DALOS`** **`GLYPH|UEV_*AccountCheck`**, **`U|ATS`** **`UC_IzStoicTagIndex`**, **`CODEX`** **`UC_ValidateCompositeCodexId`**.

**Not booleans:** Leave **`CAP_*`**, **`UEV_*`**, **`UEV_Fee`**, etc. as separate calls before the combined boolean **`enforce`** (see **`SCR|XI>ISSUE-SCORE`** in **`02_SCORE.pact`**).

**Canonical doc:** `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` — subsection *Combining boolean checks in one `enforce`*.

**Cursor skill:** `OuronetInformational/pact/enforce.md`
