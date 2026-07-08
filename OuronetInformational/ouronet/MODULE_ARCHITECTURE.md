# Ouronet — module architecture & nomenclature

_Authoritative vocabulary for how sovereign modules are structured, named, and wired. Refer to **`0_Sample/C0s__01_01_ModuleSample.pact`** for a concrete layout (policies, section ordering, and examples)._

_Last updated: 2026-06-28._

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
3. **Functions** — after capabilities; see prefixes below and **§ FUNCTIONS block order (canonical)**.

## FUNCTIONS block order (canonical)

Under **FUNCTIONS**, group unprotected helpers and client/write entrypoints in this order (reference: **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_VCT.pact`**):

| Order | Prefix | Role |
|------:|--------|------|
| 1 | **UC_** | Pure compute (arguments only) |
| 2 | **UCK_** | Table **key** constructors (args only) — **AQP modules** |
| 3 | **UR_** | Single-row reads |
| 4 | **UDC_** | Object constructors (when present; immediately after **UR_**) |
| 5 | **W_** (**WI_** / **WU_** / **WW_**) | Module-internal persisted writes — **AQP modules**; see **§ W write helpers** |
| 6 | **URD_** | Table scans / inventory (**`select`**, **`keys`**) |
| 7 | **URC_** | Read + compute via **UR_** (no **URD_**) |
| 8 | **URDC_** | Read + compute via **URD_** (and **UR_** / **UC_** / **UDC_**) |
| 9 | **UEV_** | Enforce / validate — **after** all read tiers |
| 10 | **C_** | Client recipes |
| 11 | **A_** | Administrator recipes (when present) |
| 12 | **X** (**XI_** / **XE_** / **XB_**) | Orchestration + cross-module write entry — **after** **C_** / **A_** |

**CAP_** helpers, if any, typically sit with **UEV_** or immediately before **C_** per module convention.

### Function naming inside a module

Utility **`defun`** names use the **prefix only** — do **not** repeat the module id in the identifier when the function is defined in that module. Prefer **`UC_ComputeMinSliceCount`** in **`AQP-VCT`**, not **`UC_VCT|ComputeMinSliceCount`**. **Capabilities** and **schemas** may keep **`MODULE|…`** disambiguators (**`VCT|C>FULL-…`**, **`VCT|Job`**). Cross-module **`@doc`** and README references use **`ModuleName.function`**, e.g. **`AQP-VCT.URDC_BuildVacateSlicePlan`**.

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
| **UC** | Utility **compute** | **Pure** on arguments only: no `read` of module tables, no **UR_** / **URD_**, **no `enforce`**. **First** under FUNCTIONS. |
| **UCK** | Utility **compute (keys)** | Builds **table row keys** from arguments only (**AQP** rollout). Replaces ad-hoc **`UC_*Key`** over time. |
| **UDC** | Utility **data construction** | Builds **objects**; block follows **UR_** when present. |
| **UR** | Utility **read** | Read from tables; no special protection. |
| **URD** | Utility **read (scan)** | **`select`** / multi-row inventory; only tier that scans tables directly. |
| **URC** | Utility **read + compute** | Reads via **UR_** / single-row **`read`**; derives values. **No `URD_`**. **No `enforce`**. |
| **URDC** | Utility **URD + compute** | Calls **URD_** (heavy **`select`** / scan inventory) and derives values. **No `enforce`**. See **`OuronetInformational/ouronet/conventions/uc-urc-urdc-prefixes.md`**. |
| **UEV** | Utility **enforce / validate** | Reads, then **enforces**; failure **fails the transaction**. Block **after URDC_**, before **C_**. |
| **CAP** | **Ouronet account** enforcement | Like **UEV** but specifically tied to **Ouronet account ownership**; fails if ownership cannot be verified. |

## Protected prefixes (not “open” entrypoints)

| Prefix | Meaning | Who / how |
|--------|---------|------------|
| **A_** | **Administrator** | Mutations restricted to **Ouronet admin** keys. |
| **C_** | **Client** | Intended for **clients** building **slave** modules on Ouronet. |
| **X** | **Auxiliary** protected | **XI** — internal to **this** module only; **XE** — for **external** modules only; **XB** — **both** internal and future external call paths. |

**A_** and **C_** are **locked inside** the module where they are defined: they are **not** meant as the normal public entry surface for integrators.

## Client flows: `C_`, client `defcap`, and `XI` / `XE` / `XB` writes

This is the **intended decomposition** for sovereign modules that expose **`C_`** entrypoints (see e.g. **`AQP-SCORE`**: **`SCR|XI>ISSUE-SCORE`** vs **`SCR|C>ISSUE-*`**, **`SCR|C>ROTATE-OWNERSHIP-SCORE`** / **`XI_RotateOwnership`**).

| Layer | Responsibility |
|--------|----------------|
| **Client `defcap`** (often **`@event`**, may **`compose-capability`** a core cap or **`SECURE`**) | **All authorization and validation** for that operation: **`CAP_EnforceAccountOwnership`**, **`UEV_*`**, **`UEV_Fee`**, reads from tables, etc. **Boolean predicates** combined in **one** **`enforce`**: see **§ Combining boolean checks in one `enforce`** below (non-boolean / helper validations stay as separate calls before that block). |
| **`W_` (**WI_** / **WU_** / **WW_**)** | **Module-internal persistence only** (**AQP** rollout). **`(require-capability (SECURE))`** then **`insert` / `update` / `write`** as the **final** expression. **Not** on interfaces; **never** called from other modules. **No** **`enforce`**. See **§ W write helpers**. |
| **`XI` / `XB`** | **Orchestration** when **`UR_*` + compute + one or more `W_*`** (or IGNIS tier) is needed — or internal convenience wrapper. Under **`SECURE`** (or **`XB`** via **IMC** + cap composing **SECURE**). **Must not** **`enforce`** or call **`UEV_*`**. **Do not** return **`OutputCumulator`**. In **AQP** modules, **do not** call raw **`insert` / `update` / `write`** when a **`W_*`** exists for that site. |
| **`XE`** | **Forward-module** entrypoints: **`UEV_IMC`**, then **`with-capability (…\|XE>…)`**, then **`W_*`** (not raw persistence). **`defcap`** holds all validation. **No** **`OutputCumulator`** — caller **`C_`** composes IGNIS. |
| **`C_` / `A_`** | **Wiring + billing**: **`with-capability`**, then **`W_*`**, **`XI_*`**, **`XE_*`**, or **`XB_*`** as needed. May call **`W_*` directly** when no orchestration is required. |

**Several writes:** If one user operation must touch **multiple tables** or **distinct write sites**, use **multiple** **`XI`** or **`XB`** functions (one focused write path each, or a clear split), composed from the same or different capabilities as the domain requires — do not cram unrelated persistence into a single **`XI`** when the caps and auditing should stay separable.

## W write helpers (WI_ / WU_ / WW_) — AQP rollout

**Scope:** **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`** (`01_ANK` … `05_VCT`). Other sovereign modules keep legacy patterns until explicitly migrated.

**Purpose:** **`W_*`** is the write mirror of **`UR_*`**: one canonical, **SECURE**-gated persistence function per table / field. **`XI_*` / `XE_*` / `XB_*`** orchestrate; **`C_*` / `A_*`** may call **`W_*`** directly when no extra logic is needed.

### Variants

| Prefix | Op | Assumption | Payload |
|--------|-----|------------|---------|
| **WI_** | `insert` | Row absent | Full row via **UDC_** |
| **WU_** | `update` | Row exists | One non-key field |
| **WU2_** / **WU3_** … | `update` | Row exists | Multiple fields (per need) |
| **WW_** | `write` | Upsert | Full row via **UDC_** (per need) |

Pact has **no row delete** — “removal” is a **WU_** on a liveness / active flag.

### Visibility

- **`W_*`** is **module-internal only** — not on interfaces, **never** `ref-OTHER::W_*`.
- Every **`W_*`** body: **`(require-capability (SECURE))`**, then one **`insert` / `update` / `write`** as the **last** expression — nothing after the persistence op. **No `enforce`**.
- Cross-module writes: **`XE_*` / `XB_*`** → **`UEV_IMC`** + named cap (composing **SECURE**) → **`W_*`**.

### UCK_ (keys)

**`UCK_*`** constructs **deftable** row keys (pure args). **`WI_*` / `WU_*` / `WW_*`** take key components and call **`UCK_*`** internally. Migrate legacy **`UC_*Key`** → **`UCK_*`** when touching an AQP file.

### Naming

**Table short name** = last segment of **`deftable`** after **`T|`** (e.g. **`ANK|T|Anchor`** → **`Anchor`**). **W_** names **omit** the module prefix (internal only).

| Pattern | Example |
|---------|---------|
| Full-row insert | **`WI_Anchor`** |
| Full-row upsert | **`WW_DPTFTracker`** |
| Single field | **`WU_Anchor|State`** |
| Multi-field | **`WU4_Pool|VacateJobState`**, **`WU7_Pool|ScoreSlots`**, **`WU2_Score|Control`** |

**Field suffix** = same expanded name as the paired **`UR_*`** (e.g. **`UR_ANK|State`** → **`WU_Anchor|State`**), not the raw schema string.

**Multi-field:** **`WU{N}_`** prefix = **N** fields updated; prefer one **aggregate suffix** when the fields form a single concept; otherwise join field suffixes with **`&`**. **`|`** separates table short name from suffix.

### WI not used

If a table’s first touch is **`WW_*`** only, do **not** add a stub **`WI_*`**. Place a comment:

`;; WI_Anchor — not used: first row touch is WW_Anchor (upsert path).`

### W block layout (per table)

One block per **`deftable`** (schema order). Sub-order: **`WI_*`** → **`WW_*`** → **`WU_*`** (every schema field as **`defun`** or comment) → **`WU2_*`+** only when needed (no placeholder when absent).

**WU comments:** **`not mutable [.]`** (schema fixed), **`select key; WU not needed`**, **`not used: mutates via WW_* (full row)`**.

Detail and example: **`OuronetInformational/ouronet/conventions/w-writes.md`** § W block layout.

### Defaults per table

1. One **W block** per **`deftable`**: **WI** → **WW** → **WU** (all fields) → **WU2+**.
2. **`WI_*`** or WI-not-used comment; **`WW_*`** or WW-not-used comment.
3. **`WU_*`** line for **every** schema field; **`defun`** only for fields actually updated alone.
4. **`WU2_+`**: **`defun`** only when a real path needs them; omit when not needed.

Detail: **`OuronetInformational/ouronet/conventions/w-writes.md`**; Cursor: **`OuronetInformational/ouronet/conventions/w-writes.md`**.

### Combining boolean checks in one `enforce`

When several **boolean** conditions should share one failure path, use **one** **`enforce`**, choosing the combinator by **count**:

| # of boolean conditions | Form |
|-------------------------|------|
| **1** | **`(enforce predicate "message")`** |
| **2** | **`(enforce (and p q) "message")`** |
| **3 or more** | **`(enforce (fold (and) true [p q r ...]) "message")`** |

**`CAP_*`**, **`UEV_*`**, **`UEV_Fee`**, etc. stay **outside** that block when they are not plain booleans (same pattern as **`SCR|XI>ISSUE-SCORE`**: fee and ownership calls, then **`fold (and)`** for the numeric / enum predicates). Reference: **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`** — **`SCR|XI>ISSUE-SCORE`** (six booleans → **`fold`**); **`SCR|C>ROTATE-OWNERSHIP-SCORE`** (two → **`and`**); **`SCR|C>CONTROL-SCORE`** (one → plain **`enforce`**).

The same **1 / 2 / 3+** rule applies to **`:bool` utilities** (e.g. **`GLYPH|UEV_ApolloAccountCheck`**, **`UC_IzStoicTagIndex`**) — not only **`enforce`**. Using **`(and a b c d)`** causes **`Attempted to apply a closure to too many arguments`**. Detail: **`OuronetInformational/pact/enforce-boolean-grouping.md`**; Cursor: **`OuronetInformational/pact/enforce.md`**.

### Reference: **`AQP-SCORE`** link fields (`anchor-link`, `boost-link`, `aqpool-link`, `fvt-link`)

- **Internal client path:** **`C_CreateAnchorLink` / `C_CreateBoostLink`** → **`SCR|C>CREATE-*`** (validations + **`compose-capability (SECURE)`**) → **`XI_Create*`** (**`require-capability (SECURE)`**, **`update`** only) → **`C_*`** calls **`UDC_BiggestCumulator`** on the pre-write owner. No native STOA on these links.
- **Forward path:** **`XE_CreateAqpoolLink` / `XE_CreateFvtLink`** → **`UEV_IMC`**, **`with-capability (SCR|XE>CREATE-…)`**, **`update`** only; **`AQP` / `FVT`** (or Talos) supplies **IGNIS** **`OutputCumulator`** after **`XE_*`**. **`defcap`** enforces score ownership, link slot **`BAR`**, non-**`BAR`** target id; pool/FVT consistency stays in the caller. **`AcquisitionAnchors.UR_AnchorID`** proves anchor row exists for anchor-link (**`01_ANK.pact`** interface).

## Talos: the only supported client path and gas (IGNIS)

**Talos modules** are where **A_** and **C_** are **composed** into **allowed sequences** (e.g. one module’s **C_** followed by another’s, or preceded/followed by admin-only steps). Consequences:

- **Clients** run the curated flows **through Talos**, not by calling **C_** on the home core module (where it is blocked).
- **Ouronet “gas station”** pays execution **only** for paths **defined in Talos**. Admin **A_** usage from Talos can be in that payable envelope; ad-hoc **A_** from inside the raw core module is possible for maintenance but **loses** that gas-station story.
- **IGNIS** is the **virtual-chain gas token**. Collection logic lives in **one** place; **C_** logic in **another**; because **C_** cannot be invoked from its **own** module by design, Talos sequences can **force** “execute **C_** then **collect IGNIS**,” so clients **cannot** skip paying gas while still using the blessed path.

**Rule**: when a new **A_** or **C_** (or protected **X**) is added to a core module, it must be **wired into the appropriate Talos module** to **finalize** it for production client and gas semantics.

## Working agreement for future modules

When we add modules or functions together, we will:

1. Respect **deploy order** and **interface versioning**.
2. Place new code in the right **section** (schemas → caps by C1–C4 → FUNCTIONS in **§ FUNCTIONS block order (canonical)** order).
3. Name with the correct **prefix** (**UC / UCK / UR / W / URC / URDC / UEV / UDC / CAP / A_ / C_ / X***).
4. Register **Talos** sequences and **policy** guards where inter-module or client access requires it.

## Schema layout (deftable order)

**Numbered schema entries = one per `deftable` only.** If the module has five tables, use **`;;1]`** … **`;;5]`** for those five table schemas — not six.

**Nested schemas** (a field uses **`object{OtherSchema}`** but **`OtherSchema`** has no **`deftable`**): define **`OtherSchema`** **immediately beneath** the parent table’s **`defschema`**, still under the parent’s **`;;N]`** header. Do **not** give nested-only schemas their own **`;;N]`** entry.

Example (**`01_ANK.pact`**): **`;;3]Per-Asset Bookkeeping`** → **`ANK|AssetAnchors`** → **`ANK|InternalGroup`** (nested; no table).

**`deftable`** declarations follow the same five-entry order.

## UR helpers: schema order and field order

**No raw read outside `UR_*` (domain tables):** Capabilities, client functions, and other non-`UR_*` code must use the module's **`UR_*`** helpers for business **`deftable`** rows; **`read`** / **`at`**+**`read`** on those tables belongs only in **`UR_*`** bodies (typically the **`{F0} [UR]`** block). Per-field **`UR_*`** may keep **`(at "field" (read table key ["field"]))`** as the efficient pattern; they do not need to delegate through the full-row **`UR_*`** unless you want a single read path. Policy **`P|T`** / **`P|MT`** bootstrap reads follow each module's existing policy pattern.

**Group order:** **`UR_*`** definitions are grouped in **the same order as the schema definitions** in the module (first declared schema → first UR block, second schema → second block, and so on). Table / `deftable` blocks in source should stay aligned with that same ordering so reads stay easy to navigate.

**Within each group:** define **`UR_*` in an order that mirrors the schema keys** (row fields): e.g. full-row reader first when you have one, then per-field readers following the **field order in the `defschema`**, then any helpers that take an **object** of that schema type (aggregates, predicates on the row object). Example reference: **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact`** — `{F0} [UR]` blocks **`[1]`…`[5]`** for the five **`deftable`** schemas.

**Per-field `UR_*` take table keys, not row objects:** Field-level readers use the **same key components** as the full-row read (e.g. **`anchor-id`** for **`ANK|T|Anchor`**; **`asset-id`**, **`asset-fungibility`**, **`class-id`** for per-class rows — **`asset-fungibility`** names the TF/SF/NF discriminator for **`UC_*Table`**, distinct from **`ank-fungibility`** as the field name on the anchor definition row). **`UDC_*`** may still assemble **`object{…}`** values; **`UR_*`** stay keyed reads unless the schema group is intentionally object-only (e.g. in-memory summary).

**Multi-table dispatch (same schema):** When one **`UR_*`** chooses among several tables but returns the **same object type** (e.g. fungibility → TF vs SF vs NF), prefer a **single entry `UR_*`** whose body uses **`with-default-read (UC_*Table discriminator) row-key ...`** when a **`UC_*Table`** resolver already exists — no need for a separate **`let`** binding unless the table ref is reused. Same idea as variable table polling in **`02_DPDC.pact`** (search **`tbl`**); there **`let`** is used when **`tbl`** appears multiple times. That avoids three copy-pasted **`UR_*`** that only differ by table name. Put that **entry reader first** in the UR block for that schema; only split into separate per-table **`UR_*`** when the read logic actually diverges. If you do keep per-table helpers, list the **dispatch** reader above them (see earlier note).

## Greenfield feature workflow (schemas → clients → UR → implementation)

When adding a new slice of behavior (new or extended schemas, tables, and client entrypoints), use this **sequence**. Future module work should follow it unless a task explicitly says otherwise.

1. **Decide on the schema** — Fix **`defschema`** shapes, keys, and **`deftable`** layout. **One numbered entry per table**; nested **`object{…}`** schemas sit beneath the parent table schema (see **§ Schema layout**). Keep **`deftable`** and UR/W block order aligned.
2. **Decide on the client functions** — Name and specify **`C_`** outcomes (and which policies / Talos flows will call them). This is the intended **surface**, not implementation yet.
3. **Populate the UR reading functions** — Implement **`UR_*`** grouped by schema/table, **field order inside each group** as above (including **multi-table reads**: **`with-default-read (UC_*Table …) …`** when tables share the same row shape — see preceding subsection). Add branching readers where the domain requires them.
3b. **Populate W write helpers (AQP)** — **`UCK_*`**, then **`WI_*` / `WU_*` / `WW_*`** per **§ W write helpers**; WI-not-used comments where **`WW_*`** is the create path.
4. **Create the client functions one at a time** — For **each** **`C_`** (or protected **`X`** path you add), implement it **end-to-end** for that function: **defcap** / capability wiring, **`W_*`** / **`X_`** as needed, **`UDC`** for persisted objects, and **`URC`** / **`UEV`** **as they become required** by that path. Do **not** front-load all **`URC`**/**`UEV`** before the client code; they are introduced **alongside** the client and cap layers as each flow needs them.

Steps 1–3 establish **data shape and reads**; step 4 layers **writes, validation, and capabilities** incrementally so dependencies stay honest.
