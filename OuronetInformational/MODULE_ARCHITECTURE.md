# Ouronet — module architecture & nomenclature

_Authoritative vocabulary for how sovereign modules are structured, named, and wired. Refer to **`0_Sample/C0s>>01|01_ModuleSample.pact`** for a concrete layout (policies, section ordering, and examples)._

_Last updated: 2026-04-08._

## Layering: utilities, core, Talos

| Layer | Role | Typical location |
|--------|------|------------------|
| **Utilities** | Small shared helpers (e.g. **`U|CT`**, **`U|G`**, **`U|LST`**) | **Stage 1 only** |
| **Core** | Main business logic modules (DALOS, TFT, VST, DemiPad, etc.) | Sovereign stages |
| **Talos** | Orchestration entrypoints that sequence calls and integrate gas / IGNIS collection | `*_TS01-*`, `*_TS02-*`, etc. |

## Deployment order, interfaces, and `::` vs `.`

**Kadena’s ~150k deploy cap** forced a **strict deploy order**: a module may only call code in modules **already deployed** on chain.

- **Cross-module calls** from later modules use a **module reference** and the **`::`** qualifier (e.g. `(ref-M::some-fun ...)`) so only the **used interface members** are relevant to typing and dependency discipline, in contrast to **`module.function`**-style use that conceptually pulls the **whole** module surface into how you think about coupling.
- **Interfaces** therefore carry almost the full public API. **Adding or changing** a function in the interface **bumps the interface version** (e.g. `SomethingV7`), which drives **repo-wide refactors** of `implements` and `module{...}` types.

## Policies (inter-module guards)

The **beginning** of each module establishes **policy tables**: shared **guard** structures so modules can **authorize** each other safely. This is the inter-module communication backbone; **`ModuleSample.pact`** shows how a module should **start** (policy block before bulk logic).

## Canonical section order (top of file)

Roughly:

1. **Schemas & tables & constants** — labeled in sources as **`{1}`**, **`{2}`**, **`{3}`** style blocks where applicable.
2. **Capabilities** — grouped by kind:
   - **C1** — trivial / “always **`true`**”-style capability roots.
   - **C2** — simple capabilities that **do not** compose other capabilities.
   - **C3** — ownership-related (or similar) capability patterns.
   - **C4** — **composite** capabilities (`compose-capability`, etc.).
3. **Functions** — after capabilities; see prefixes below. **`UC`** utilities are intentionally **first** under the FUNCTIONS area.

## Pact formatting and indentation discipline

Code readability is a hard requirement, not a cosmetic preference.

- Keep Pact code **visually scannable** for humans first: clean indentation, stable spacing, and grouped blocks.
- Preserve existing layout patterns in sovereign modules (section bars, block comments, grouped `let` bindings, aligned multi-line arguments).
- Prefer small structural edits that **do not churn formatting** unrelated to the behavioral change.
- New code should match nearby style in the same file so the module does not become visually mixed.
- Prefer **`let`** when a bound name is **used more than once**; if each binding is used **only once**, **inline** the expression (common with **`with-default-read (UC_*Table …) (UC_*Key …)`**). Avoid duplicate **`defun`** names that differ only as aliases to the same implementation.
- **`@doc` placement:** Put **`@doc "..."` immediately after the function’s **parameter list** (including when parameters are on following lines), before the body. Do not place **`@doc`** between the function name and the parameter **`(`** list.
- **Evented `defcap`:** If a capability uses **`@event`**, order metadata as **`@doc`** first, then **`@event`**, then the capability body (required for Pact).

## Unprotected utility prefixes (callable without capability gates)

These are **not** wrapped in admin/client locks; they are safe by construction (pure read, pure compute, or validate-only).

| Prefix | Meaning | Notes |
|--------|---------|--------|
| **UC** | Utility **compute** | **Pure** on arguments only: no `read` of module tables, **no `enforce`**. **Placed first** under FUNCTIONS (only true UC defs). |
| **UR** | Utility **read** | Read from tables; no special protection. |
| **URC** | Utility **read + compute** | Reads (via **UR** / `read`) and derives values. **Not** named **UC** even if the math is small. **No `enforce`** here — validation belongs in **UEV** or in **defcap** / caller. May call **UR**, **UC**, or other **URC**. |
| **UEV** | Utility **enforce / validate** | Reads, then **enforces**; failure **fails the transaction**. Still unprotected (anyone can trigger validation). |
| **UDC** | Utility **data construction** | Builds **objects** so call sites use a named constructor instead of ad-hoc `object` literals; eases **find-uses** and review. |
| **CAP** | **Ouronet account** enforcement | Like **UEV** but specifically tied to **Ouronet account ownership**; fails if ownership cannot be verified. |

## Protected prefixes (not “open” entrypoints)

| Prefix | Meaning | Who / how |
|--------|---------|------------|
| **A_** | **Administrator** | Mutations restricted to **Ouronet admin** keys. |
| **C_** | **Client** | Intended for **clients** building **slave** modules on Ouronet. |
| **X** | **Auxiliary** protected | **XI** — internal to **this** module only; **XE** — for **external** modules only; **XB** — **both** internal and future external call paths. |

**A_** and **C_** are **locked inside** the module where they are defined: they are **not** meant as the normal public entry surface for integrators.

## Talos: the only supported client path and gas (IGNIS)

**Talos modules** are where **A_** and **C_** are **composed** into **allowed sequences** (e.g. one module’s **C_** followed by another’s, or preceded/followed by admin-only steps). Consequences:

- **Clients** run the curated flows **through Talos**, not by calling **C_** on the home core module (where it is blocked).
- **Ouronet “gas station”** pays execution **only** for paths **defined in Talos**. Admin **A_** usage from Talos can be in that payable envelope; ad-hoc **A_** from inside the raw core module is possible for maintenance but **loses** that gas-station story.
- **IGNIS** is the **virtual-chain gas token**. Collection logic lives in **one** place; **C_** logic in **another**; because **C_** cannot be invoked from its **own** module by design, Talos sequences can **force** “execute **C_** then **collect IGNIS**,” so clients **cannot** skip paying gas while still using the blessed path.

**Rule**: when a new **A_** or **C_** (or protected **X**) is added to a core module, it must be **wired into the appropriate Talos module** to **finalize** it for production client and gas semantics.

## Working agreement for future modules

When we add modules or functions together, we will:

1. Respect **deploy order** and **interface versioning**.
2. Place new code in the right **section** (schemas → caps by C1–C4 → FUNCTIONS with **UC** first, etc.).
3. Name with the correct **prefix** (**UC / UR / URC / UEV / UDC / CAP / A_ / C_ / X***).
4. Register **Talos** sequences and **policy** guards where inter-module or client access requires it.

## UR helpers: schema order and field order

**Group order:** **`UR_*`** definitions are grouped in **the same order as the schema definitions** in the module (first declared schema → first UR block, second schema → second block, and so on). Table / `deftable` blocks in source should stay aligned with that same ordering so reads stay easy to navigate.

**Within each group:** define **`UR_*` in an order that mirrors the schema keys** (row fields): e.g. full-row reader first when you have one, then per-field readers following the **field order in the `defschema`**, then any helpers that take an **object** of that schema type (aggregates, predicates on the row object). Example reference: **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`** — `{F0} [UR]` blocks labeled `[1]`…`[4]` for **`ANK|Schema`**, **`ANK|AnchorClass`**, **`ANK|AssetAnchorClasses`**, **`ANK|UserSchema`**.

**Per-field `UR_*` take table keys, not row objects:** Field-level readers use the **same key components** as the full-row read (e.g. **`anchor-id`** for **`ANK|T|Anchor`**; **`asset-id`**, **`asset-fungibility`**, **`class-id`** for per-class rows — **`asset-fungibility`** names the TF/SF/NF discriminator for **`UC_*Table`**, distinct from **`ank-fungibility`** as the field name on the anchor definition row). **`UDC_*`** may still assemble **`object{…}`** values; **`UR_*`** stay keyed reads unless the schema group is intentionally object-only (e.g. in-memory summary).

**Multi-table dispatch (same schema):** When one **`UR_*`** chooses among several tables but returns the **same object type** (e.g. fungibility → TF vs SF vs NF), prefer a **single entry `UR_*`** whose body uses **`with-default-read (UC_*Table discriminator) row-key ...`** when a **`UC_*Table`** resolver already exists — no need for a separate **`let`** binding unless the table ref is reused. Same idea as variable table polling in **`02_DPDC.pact`** (search **`tbl`**); there **`let`** is used when **`tbl`** appears multiple times. That avoids three copy-pasted **`UR_*`** that only differ by table name. Put that **entry reader first** in the UR block for that schema; only split into separate per-table **`UR_*`** when the read logic actually diverges. If you do keep per-table helpers, list the **dispatch** reader above them (see earlier note).

## Greenfield feature workflow (schemas → clients → UR → implementation)

When adding a new slice of behavior (new or extended schemas, tables, and client entrypoints), use this **sequence**. Future module work should follow it unless a task explicitly says otherwise.

1. **Decide on the schema** — Fix **`defschema`** shapes, keys, and **`deftable`** layout; keep schema and table declaration order consistent with how you want UR grouped later.
2. **Decide on the client functions** — Name and specify **`C_`** outcomes (and which policies / Talos flows will call them). This is the intended **surface**, not implementation yet.
3. **Populate the UR reading functions** — Implement **`UR_*`** grouped by schema/table, **field order inside each group** as above (including **multi-table reads**: **`with-default-read (UC_*Table …) …`** when tables share the same row shape — see preceding subsection). Add branching readers where the domain requires them.
4. **Create the client functions one at a time** — For **each** **`C_`** (or protected **`X`** path you add), implement it **end-to-end** for that function: **defcap** / capability wiring, **`X_`** / **XI** / **XE** / **XB** as needed, **`UDC`** for persisted objects, and **`URC`** / **`UEV`** **as they become required** by that path. Do **not** front-load all **`URC`**/**`UEV`** before the client code; they are introduced **alongside** the client and cap layers as each flow needs them.

Steps 1–3 establish **data shape and reads**; step 4 layers **writes, validation, and capabilities** incrementally so dependencies stay honest.
