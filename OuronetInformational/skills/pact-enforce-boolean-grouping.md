# Pact: one `enforce`, multiple booleans (Ouronet)

When several **boolean** checks should share **one** failure message in **`defcap`** or **`defun`** bodies:

1. **One predicate** — `(enforce p "msg")`
2. **Two predicates** — `(enforce (and p q) "msg")`  
   Pact `and` takes two boolean arguments here; no `fold`.
3. **Three or more** — `(enforce (fold (and) true [p q r ...]) "msg")`

**Not booleans:** Leave **`CAP_*`**, **`UEV_*`**, **`UEV_Fee`**, etc. as separate calls before the combined boolean **`enforce`** (see **`SCR|XI>ISSUE-SCORE`** in **`02_SCORE.pact`**).

**Canonical doc:** `OuronetInformational/MODULE_ARCHITECTURE.md` — subsection *Combining boolean checks in one `enforce`*.

**Cursor skill:** `.cursor/skills/ouronet-pact-enforce/SKILL.md`
