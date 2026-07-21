
# Ouronet UR layout

## When editing `UR_*` in sovereign modules

0. **Call sites vs `UR_*` bodies** — Never **`read`** / **`at`+`read`** on domain **`deftable`** rows in **`defcap`**, **`C_*`**, **`X_*`**, **`UEV_*`**, etc. Use the module’s **`UR_*`** functions. **Inside** **`UR_*`**, per-field readers normally use **`(at "field" (read table key ["field"]))`** (original efficient form); full-row **`UR_*`** uses **`(read table key)`**. Do not “fix” **`UR_*`** by routing every field through the full-row reader unless you explicitly want that.

1. **Groups** — One UR block per **`deftable`** (same order as numbered table schemas). Nested-only schemas (no table) share the parent’s UR/W block; they do not get their own numbered group. See `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` § Schema layout.

2. **Within a group** — Order **`UR_*`** like **`defschema` keys**: full-row reader when applicable, then per-field readers in schema field order, then object-level helpers (counts, predicates). Composites that span several keys come **after** single-key extractors.

   **Key arguments, not row objects:** Per-field **`UR_*`** should take the **same arguments that identify the row** as the full-row reader (e.g. **`anchor-id`** for **`ANK|T|Anchor`**; **`asset-id`**, **`asset-fungibility`** `[bool][bool]` for TF/SF/NF, and **`class-id`** for **`ANK|T|*|AnchorClass`**). Do **not** take **`input:object{…}`** for those reads — mirror **`01_ANK.pact`** **`[1]`** (single key) and **`[2]`** (composite key). Call **`read`** / **`with-default-read`** with **`UC_*Table`** + key helpers. Name the discriminator **`asset-fungibility`** when it selects among asset-backed tables (vs **`ank-fungibility`** on the **`ANK|T|Anchor`** row, which is the stored field name there).

3. **Same schema, multiple tables (fungibility, role flags, etc.)** — If the **`with-default-read`** body is **identical** except which **`deftable`** is used, do **not** copy three **`UR_*`**. Use the existing **`UC_*Table`** resolver as the **first argument** to **`with-default-read`**: `(with-default-read (UC_…Table discriminator) key …)`. Only introduce **`(let ((tbl …)))`** when the table ref is reused or the expression is clearer split (see DPDC **`tbl`** for **`select`**, multi-use paths).
   - Reference: **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`** — `UR_AssetAnchorClassesData`; **`1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact`** — search **`tbl`** for longer forms.

4. **If** per-table **`UR_*`** are kept because reads differ, put the **dispatch** reader **first**, then implementations **below** (TF→SF→NF or domain order).

5. **One name, no redundant aliases** — Do not define **`UR_A`** and **`UR_B`** when they always mean the same row read; keep a **single** **`UR_*`** whose name matches the schema (e.g. **`UR_AnchorClass`** for **`ANK|AnchorClass`** rows).

6. **`let` only when a binding repeats** — If every **`let`** binding is used **once**, inline it (e.g. **`(with-default-read (UC_AnchorClassTable f) (UC_AssetClassKey a c) …)`** instead of **`let` + `table-ref` + `class-key`**). Use **`let`** when a value is referenced **two or more times**, or when splitting improves readability in a large form.

7. **`with-default-read` lives in `UR_*`** — Full-row (and dispatch) **`UR_*`** use **`with-default-read`** for absent keys. **`XI_*`** reads prior state via **`UR_*`**, then **`write`**. See **`OuronetInformational/ouronet/conventions/ur-and-w-writes.md`**.

8. **`let` layout when mixing refs and vars** — All **`(ref-*:module{…} …)`** bindings, then **`;;`**, then locals. See **`OuronetInformational/pact/let-binding-layout.md`**.
9. **`defun` / `defcap` parameter lists** — One line when the signature fits; otherwise name on line 1 and one parameter per line in a `(...)` block. See **`OuronetInformational/pact/defun-parameter-layout.md`**.

## Pact metadata (Ouronet modules)

- **`@doc`** — Immediately **after** the **`defun` / `defcap` parameter list** (see `UDC_*` and `C_*` style in **`01_ANK.pact`**), never between the name and `(`.
- **`defcap` + `@event`** — **`@doc`** then **`@event`**, then body.

## Related docs

- `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` — full prefix rules and greenfield workflow.
