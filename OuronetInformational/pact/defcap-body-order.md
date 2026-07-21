# `defcap` validation body order (Ouronet)

For component / recipe caps with inline validation (e.g. **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**, **`SCR|XI>ISSUE-SCORE`**):

## Order (strict)

1. **`let`** — bind booleans / reads / **shared computed values** (e.g. **`entry-count:integer (length entries)`** when length is checked more than once). See **`let-binding-layout.md`**: all **`ref-*:module{…}`** first, **`;;`**, then locals.
2. **All Pact native guards** — every **`enforce`**, **`enforce-guard`**, **`enforce-keyset`**, **`enforce-one`** (including **`enforce (ref-MODULE::URC_…)`** wrappers).
3. **All bare cross-module ref calls** — **`ref-DALOS::CAP_*`**, **`ref-DPTF::UEV_id`**, **`ref-U|DALOS::UEV_Fee`**, etc. not already executed inside step 2.
4. **Home-module calls** — **`URC_*`** / **`CAP_*`** used as standalone validators (rare in caps).
5. **`compose-capability` last** — **`SECURE`**, **`P|CALLER`**, **`GOV`**, composed child caps.

**Rule of thumb:** *all `enforce` → all bare `ref-*` → home → compose caps.*

Do **not** place **`compose-capability`** before step 2–4.

Full detail: **`function-body-order.md`**.
