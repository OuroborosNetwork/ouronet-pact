# StoicSyntax — Prefix Denominations (single source of truth)

> **This is the authoritative registry of every function/capability name prefix in the Ouronet
> Pact codebase.** It is an **addendum to `StoicSyntax.md`** and supersedes the inline prefix
> tables there. **Any change to the prefix vocabulary is made HERE first**, then propagated.
> The syntax-highlighting / colouring agent colours **by the families in this file** — refer it
> here directly.

---

## 1. The composition rule

A name is `PREFIX_Name` (or `PREFIX_Scope|Name`). The prefix is read left-to-right:

- **UPPERCASE letters = the operation class** — what side-effect / cost class the function is.
  `U` utility · `C` compute · `R` read · `H` heavy (scan) · `D` data · `E`/`V` enforce/validate · `W` write.
- **lowercase letters = a specialization role** appended to the class:
  - `k` → the compute produces a **composite table Key** (`concat` fields with `BAR`).
  - `x` → the function is an **auxiliary** (a private helper of the function directly ABOVE it).
  - `v` → **validating** — the function's `enforce` is an intrinsic, unavoidable part of its own single
    job (a shape/domain guard on the computation itself — e.g. "these amounts must sum positive and none
    may be negative" as part of computing whether they're balanced), **not** business/client validation
    that belongs in a separate `UEV_*`/defcap. Legitimate on `UC_`/`URC_`/`URDC_` — `UCv_`/`URCv_`/
    `URDCv_` — where every other real caller does not already guarantee the property, so the check is
    reachable and not tautological (deleting it would be wrong), but relocating it to a caller-side
    `UEV_*` would mean duplicating the identical check at every real call site instead of once, in the
    one place all real paths already share. Introduced 2026-08-24 (SWP audit L56) — retroactively also
    covers the `U|LST` bounds-guard exception from v1.9.0/§6.1 (L41), now a named category instead of an
    ad-hoc carve-out.
  - ~~`cap`~~ → **RETIRED 2026-08-31.** A function that installs a capability now uses the **`CAP_`** prefix —
    a defcap-installing enforce is exactly what `CAP_` denotes — so it folds into the **ENFORCE / Validate**
    family and drops the former `URCcap_` specialization and its own colour. (History: introduced 2026-08-30,
    DEMIPAD audit #17L, for the launchpad's no-signature "slippage-off" payment setup, as a `URC_` that
    `install-capability`s instead of returning cap-description strings; retired on the 7-class colour
    consolidation — it is extremely rare and `CAP_` fits it perfectly.)
  - `i` → the function **emits an IGNIS cost** — a `URCi_` cost reader (a `URC_` specialization). Pure, no
    `enforce`; a **leaf** returns a cost cumulator (`object{IgnisCollectorV1.OutputCumulator}`) or fair-price
    `decimal`, a **composer** totals a `C_`/`CC_`/`A_`. Unlike `cap` it has **no** side effect — it is the
    single **cost source** both the exec path (billing) and INFO (preview) call, so the two can never drift.
    Introduced 2026-08-30 (Phase 1.1 URCi cost architecture). Colour: its **own** family (COST).
  - lowercase markers may stack (rare): `UCkx_` = a key-building auxiliary.
- **`|` = a module/table scope** inside the *name* part, not the prefix
  (`UR_SCR|ScoreOwnerKonto` = a `UR_` reader scoped to the `SCR` tables;
  `DPNF|C_Create` = the `C_` client class scoped under the `DPNF` module wrapper).

**Positioning:** an `…x` auxiliary is placed **immediately below** the function that consumes it.

**Honesty rule:** the prefix reflects the function's **own** nature and its **heaviest reachable
branch**, never its caller's class. A pure-compute helper used by a `URC_` is still `UC` (→ `UCx_`),
because it does no reads. A conditionally-heavy function takes the heavy prefix (`URHC_`) — but we
**design those out** (make definition/aggregate data point-readable) rather than ship them.

---

## 2. Canonical prefix registry

### Unprotected utility (callable without a capability — safe by construction)

| Prefix | Class | Meaning | On execution path? | Colour family |
|--------|-------|---------|--------------------|---------------|
| `UC_`   | compute | Pure compute on arguments only — **no table reads, no `enforce`**\* | yes | **COMPUTE** |
| `UCk_`  | compute·key | Pure compute that builds a **composite table key** (`concat […BAR…]`) | yes | **COMPUTE** |
| `UCx_`  | compute·aux | Pure-compute **auxiliary** of the function above it | yes | **COMPUTE** (dim) |
| `UCv_`  | compute·validating | `UC_` whose `enforce` is intrinsic to its own computation (§1 `v`) — not business validation | yes | **COMPUTE** |
| `UR_`   | read | **Point** read (single row/field by key) | yes | **READ** |
| `URC_`  | read+compute | Point read **+ derive** (no `enforce`) | yes | **READ** |
| `URCx_` | read+compute·aux | `URC_` **auxiliary** | yes | **READ** (dim) |
| `URCv_` | read+compute·validating | `URC_` whose `enforce` is intrinsic to its own computation (§1 `v`) | yes | **READ** |
| ~~`URCcap_`~~ | *removed → `CAP_`* | **Removed 2026-08-31.** A cap-installing helper uses the **`CAP_`** prefix (Validate/ENFORCE) — installing a defcap is what `CAP_` denotes. (Was a `URC_` that `install-capability`s instead of returning cap strings — the no-signature client-side payment setup; UI-called, so still interface-declared as `CAP_`.) | yes | **ENFORCE** |
| `URCi_` | read+compute·cost | **Cost-emitting** reader (§1 `i` = IGNIS cost). Pure, **no `enforce`**; a **leaf** returns an IGNIS cost cumulator (`object{IgnisCollectorV1.OutputCumulator}`) or a native fair-price `decimal`, a **composer** totals a `C_`/`CC_`/`A_`. The single source both the exec path (billing) **and** INFO (preview) call, so they cannot drift. Cross-module ones belong in the interface | yes | **COST** |
| `URU_`  | read·upgrade | Read helper for **version-upgrade / migration** paths | admin only | **READ** (dim) |
| `URH_`  | heavy-read | **Scan** read (`select` / `keys`) — expensive/unbounded | **NO — off-path only** | **HEAVY-READ ⚠** |
| `URHx_` | heavy-read·aux | `URH_` **auxiliary** | **NO** | **HEAVY-READ ⚠** (dim) |
| `URHC_` | heavy-read+compute | Scan read **+ derive** | **NO — off-path only** | **HEAVY-READ ⚠** |
| `URHCx_`| heavy-read+compute·aux | `URHC_` **auxiliary** | **NO** | **HEAVY-READ ⚠** (dim) |
| `UEV_`  | enforce | Read **+ `enforce`** — may abort the tx | yes | **ENFORCE** |
| `CAP_`  | enforce·ownership | Account-ownership `enforce` (UEV-like, ownership-specific) | yes | **ENFORCE** |
| `UDC_`  | construct | **Data constructor** — named object builder (no reads, no enforce) | yes | **CONSTRUCT** |
| `UDCx_` | construct·aux | `UDC_` **auxiliary** | yes | **CONSTRUCT** (dim) |
| `CT_`   | constant | Constant accessor — wraps a shared `defconst` / utility constant | yes | **CONSTANT** |

> **`URCi_` — IMPLEMENTED (Phase 1.1, 2026-08-30).** The **cost-emitting** reader family for the URCi
> cost architecture (spec `URCI-COST-ARCHITECTURE.md`; the `i` = IGNIS cost). A **leaf** `URCi_` returns
> an IGNIS cost cumulator (`object{IgnisCollectorV1.OutputCumulator}`) or a native fair-price `decimal`;
> a **composer** `URCi_` totals a `C_`/`CC_`/`A_`. It is the **single source** both the exec path
> (billing) and INFO (preview) call, so the two can never drift. Lives **in the module it prices** —
> except sub-IGNIS modules (only DALOS), whose `URCi_` live in **IGNIS** (the pre-Talos cost hub, since
> DALOS deploys below IGNIS and cannot construct cumulators). First landed: `DALOS|URCi_*` in IGNIS (9
> client ops); rolling out module-by-module in deploy order (DPTF next). Own **COST** colour family.

### Protected (locked inside the module — reached by clients only via Talos)

| Prefix | Class | Meaning | Colour family |
|--------|-------|---------|---------------|
| `AU_` | admin·update | **Admin Update** — schema/data migration only (force existing rows onto a newly-added field), admin-mode only; placed immediately before `A_`. Codifies the pre-existing `AHU`/`AUP_*` pattern (see `StoicSyntax.md` § 6.2, v1.10.0) | **RECIPE** |
| `A_`   | admin | Admin-key mutation recipe — **standard** (its execution tree hits **no** heavy read) | **RECIPE** |
| `AA_`  | admin·heavy | Admin recipe whose **execution tree hits a heavy scan somewhere** (`URH_*`/`URHC_*`/`URD_*`), **at any depth** — see the transitive rule below | **RECIPE** |
| `Ap_`  | admin·parallel | **Hydra** parallel-slice admin — fed one slice of a `URH_*` dirty-read plan, order-independent, retryable, fired in parallel; its own tree hits **no** heavy read | **RECIPE** |
| `AAp_` | admin·heavy·parallel | Hydra parallel-slice admin whose tree still hits a heavy read (tolerated; hoist the read into the preflight and demote to `Ap_` when possible) | **RECIPE** |
| `C_`   | client | Client entrypoint — builds IGNIS cumulators, returns `OutputCumulator`; **cannot be invoked from its own module**; **standard** (its execution tree hits **no** heavy read) | **RECIPE** |
| `CC_`  | client·heavy | Client recipe whose **execution tree hits a heavy scan somewhere** (`URH_*`/`URHC_*`/`URD_*`), **at any depth** — see the transitive rule below | **RECIPE** |
| `Cp_`  | client·parallel | **Hydra** parallel-slice client — fed one slice of a `URH_*` dirty-read plan, order-independent, retryable, fired in parallel; its own tree hits **no** heavy read | **RECIPE** |
| `CCp_` | client·heavy·parallel | Hydra parallel-slice client whose tree still hits a heavy read (tolerated; prefer to demote to `Cp_`) | **RECIPE** |
| `XI_` | protected·internal | Internal-only protected write/orchestration | **PROTECTED** |
| `XE_` | protected·external | For **external** modules only (forward-module entrypoint; opens `UEV_IMC`) | **PROTECTED** |
| `XB_` | protected·both | Both internal and external | **PROTECTED** |

> **Recipe axes — weight × mode (two orthogonal notations, so they never blur).** A user recipe (`C_`
> client / `A_` admin) carries two independent properties, each with its **own** notation so the base
> letter stays stable and the band still reads as a band:
> - **weight** → **letter-doubling**: `C`→`CC`, `A`→`AA`. Single = **standard**; doubled = **heavy**.
>   **Canonical (transitive) rule:** a recipe is **heavy** iff **anywhere in its executing tree — at any
>   depth, in any callee (`XI_`/`XE_`/`XB_`/nested `C_`/…) — a heavy scan (`URH_*` / `URHC_*` / `URD_*` /
>   `URDC_*`) is hit.** The value of `CC_` is exactly this at-a-glance signal: you see the doubled letter and
>   know a heavy read is reached *somewhere* in the execution, without opening the tree. (It is **not** a
>   textual "does this body literally call `URH_`" test — it is the whole reachable call graph.)
> - **mode** → a lowercase **`p` suffix**, present **only** when the recipe is a **Hydra parallel slice**:
>   `Cp_`, `CCp_`, `Ap_`, `AAp_`. Absent = solo/standalone.
>
> Read order is `[C|CC][p]_` (weight, then mode): `CCp_` = "heavy client, parallel". Bare `C_`/`CC_`/`A_`/`AA_`
> are unchanged, so the change is additive.
>
> **The Hydra pattern** (a first-class execution shape, distinct from `defpact`). A `defpact` is a
> **sequential** many-transaction op (ordered continuation state). A **Hydra** op is the **parallel**
> counterpart — work too big for one transaction that decomposes into **order-independent** slices fired
> concurrently. Anatomy:
> 1. **Preflight** — a `URH_*` / `URHC_*` dirty-read (run off-chain by the UI) enumerates + partitions the
>    total work into capacity-bounded slices. This is the **only** heavy read in a well-formed Hydra flow,
>    and its sliced output is the *input* to the slice functions.
> 2. **Slices** — `Cp_` / `Ap_` (or `CCp_` / `AAp_` if a slice still needs an internal heavy read). Each is
>    fed one slice as arguments, is idempotent-per-slice and retryable, and is submitted **in parallel**.
> 3. **Bracket (optional)** — a `C_`/`CC_` **begin** (freeze state) and **finalize** (nuke / unfreeze); these
>    are single ordered transactions, not slices.
>
> Canonical Hydra families: deb-unstale, anchor-sweep, vacate/drain. Migration candidates: wipes and
> oversized multi-transfers (a transfer whose leg set exceeds one tx). The **cost preview** falls out for
> free: each Hydra op gets `…|INFO_<Op>Full` (from the preflight plan → grand total + slice breakdown) and
> `…|INFO_<Op>Slice` (from the slice's own args → that batch's exact cost).

### Writers (raw persistence — one write site each, gated on a home `SECURE`)

| Prefix | Class | Meaning | Colour family |
|--------|-------|---------|---------------|
| `WI_`  | write·insert | `insert` writer | **WRITE** |
| `WU_`  | write·update | `update` writer (`WU2_` / `WU3_` / `WU4_` = multi-field update variants) | **WRITE** |
| `WW_`  | write·upsert | `write` (upsert) writer | **WRITE** |

### Structural / governance / policy (standardized boilerplate — self-explanatory)

| Prefix | Meaning | Colour family |
|--------|---------|---------------|
| `GOV`, `GOV\|*` | Governance capabilities + keyset/keys | **STRUCTURAL** (dim) |
| `P\|*` | Policy capabilities + policy-registry functions (IMC guard registry) | **STRUCTURAL** (dim) |
| `SECURE` | The home secure-compose leaf capability (guards writers) | **STRUCTURAL** (dim) |
| `UEV_IMC` | The inter-module-call gate (special `UEV_`; opens every `C_`/`CC_`/`X` entrypoint) | **STRUCTURAL** (dim) |

> \* **Documented exception (StoicSyntax.md § 6.1, v1.9.0):** `U|LST`'s bounds-guard helpers
> (`UC_ReplaceAt`, `UC_RemoveItemAt`, `UC_LE`, `UC_FE`) and any `UC_*` calling them stay `UC_*` and are
> excluded from renaming — their `enforce` guards the computation's own list/string shape (index-in-
> bounds, not-empty), not a business/domain decision.

> **Not prefixes — module/table scopes.** Tokens like `DPTF`, `DPOF`, `DPSF`, `DPNF`, `DPDC`,
> `DALOS`, `SWP`, `ATS`, `VST`, `AQP`, `ANK`, `SCR`, `FVT`, `MTX`, `IGNIS`, `DEMIPAD`, `PYTHIA`,
> `CODEX`, `GLYPH`, … are **module / table names**, not function classes. They appear after a `|`
> as a scope, or as a Talos wrapper stem (`MODULE|C_Name`). Colour the **class token**, not the scope.

---

## 3. Migration mapping (old → new)

The heavy-read letter changed from `D` (which collided with `D`=Data in `UDC_`, and was not
mnemonic) to **`H` = Heavy**; the key/auxiliary role letters moved to **lowercase**. Rename is a
mechanical, prefix-anchored find/replace. Colour **both spellings the same** until the rename lands.

| Old | New | Reason |
|-----|-----|--------|
| `URD_`   | `URH_`   | `D`→`H` (Heavy); frees `D` to mean only Data |
| `URDC_`  | `URHC_`  | same |
| `URDX_`  | `URHx_`  | `D`→`H`; auxiliary marker → lowercase |
| `URDCX_` | `URHCx_` | same |
| `UCK_`   | `UCk_`   | Key role marker → lowercase |
| `UCX_`   | `UCx_`   | auxiliary marker → lowercase |
| `URCX_`  | `URCx_`  | auxiliary marker → lowercase |
| `UDCX_`  | `UDCx_`  | auxiliary marker → lowercase |

**Reclassify while renaming:** any `URCX_` / `UCX_` that does **no** table read is pure compute →
it becomes **`UCx_`**, not `URCx_` (e.g. `URCX_StakeEqualNativeUnitRawWeight` → `UCx_…`).

---

## 4. Colour families (for the highlighting agent)

Ten semantic families; related prefixes share a hue. `…x` / `…k` variants take the **same hue** as
their base, optionally **dimmed / desaturated / italic** to signal "specialization / auxiliary."

| Family | Prefixes | Intent of the colour |
|--------|----------|----------------------|
| **COMPUTE**    | `UC_ UCk_ UCx_` | cheap, pure, side-effect-free — calm/neutral |
| **READ**       | `UR_ URC_ URCx_ URU_` | bounded point reads — safe read hue |
| ~~**CAP-INSTALL**~~ | *removed → `CAP_`* | Folded into **ENFORCE** on 2026-08-31 — the cap-installing helper uses `CAP_` and never warranted its own hue (extremely rare). |
| **COST**       | `URCi_` | the IGNIS **cost layer** — leaf/composer cumulator readers that billing and preview share; its own "money" hue (e.g. gold), distinct from the HEAVY-READ warning |
| **HEAVY-READ ⚠** | `URH_ URHx_ URHC_ URHCx_` | **scan / expensive — must flinch**; off-path only (warning hue: amber/orange) |
| **ENFORCE**    | `UEV_ CAP_` | can abort the tx — alert hue (red family) |
| **CONSTRUCT**  | `UDC_ UDCx_` | object builders |
| **CONSTANT**   | `CT_` | constant accessors — muted |
| **WRITE**      | `WI_ WU_ WU2_ WU3_ WU4_ WW_` | persistence — distinct write hue |
| **RECIPE**     | `AU_ A_ AA_ Ap_ AAp_ C_ CC_ Cp_ CCp_` | client/admin entrypoints — strong/bold |
| **PROTECTED**  | `XI_ XE_ XB_` | protected orchestration — distinct band |
| **STRUCTURAL** | `GOV GOV\|* P\|* SECURE UEV_IMC` | standardized boilerplate — dim/grey |

---

## 5. Interface-membership rule

A module's interface is its **cross-module contract**. Because callers reach a module through a
typed reference (`ref-M:module{SomeInterface}` → `ref-M::fn`), **only functions declared in the
interface are callable from outside the module.** Therefore:

> **Every function is declared in the module's interface — EXCEPT the four kinds below, which are
> module-internal and must NOT appear in the interface:**
>
> 1. **`…x` auxiliaries** (`UCx_`, `URCx_`, `URHCx_`, `UDCx_`) — private helpers of the function above them.
> 2. **`W…` writers** (`WI_`, `WU_`, `WU2/3/4_`, `WW_`) — raw persistence, only ever called inside the module.
> 3. **`XI_`** — internal-only protected orchestration.
> 4. **Any function returning `object{Schema}` where `Schema` is defined in the *module* (not the interface)** —
>    a hard Pact load-order constraint: the interface loads before the module's schemas exist, so such a
>    return type cannot be declared there. (Ouronet keeps schemas in modules, so these stay module-only.)
>
> **Corollary — these MUST appear in the interface** (they are reachable from outside):
> `XE_` and `XB_` (external / both), `C_` / `CC_` / `A_` recipes, and all unprotected readers/validators/
> constructors/compute (`UR_`, `URC_`, `URH_`, `URHC_`, `UEV_`, `CAP_`, `UDC_`, `UC_`, `UCk_`)
> **unless** they hit exclusion #4 (module-schema return). (The cap-installing helper — formerly `URCcap_`,
> now a `CAP_` — is client-facing, the UI calls it to install the payment caps, so it is always
> interface-declared.)

So an `XE_`/`XB_` missing from the interface is a **bug** (it's callable from outside but undeclared);
a `URH_` reader used by the UI/another module belongs in the interface (subject to #4); a `URH_` reader
used only inside its own module does not.

---

## 5.1 Canonical module structure & ORDER (and interface mirror)

**There is NO load-order constraint inside a module.** Pact resolves every intra-module reference
regardless of definition order, so a module's contents are ordered **purely by the canonical scheme
below** — the colour/strength order — never forced by dependency. The single exception is a genuine
*definition* dependency (a `defconst` that calls a `CT_` const-helper defun needs it defined *above*),
which lives in region 3 and takes precedence there. Everywhere else the order is free, so we **fix** it —
giving every module (and interface) one identical, deterministic shape.

**A module has FIVE code regions, in this order:**

1. **Governance** — the module governance capability (`GOV`) and its keyset/keys.
2. **Policy** — policy capabilities + policy-registry functions (`P|*`; the IMC guard registry).
3. **Schemas · tables · constants** — `defschema`, `deftable`, `defconst`; a `CT_` const-helper defun
   feeding a `defconst` stays here, directly **above** the const that uses it.
4. **Capabilities** — in bands **C1 → C2 → C3 → C4** (§5.2).
5. **Functions** — the prefixed functions, in the **canonical function order** (§5.1.1).

### 5.1.1 Canonical function order (region 5)

The seven classes in build order; **within each class strongest → lightest** (bold lead ▸ shades ▸
`…x` aux *italic* ▸ cost accent). This is exactly the colour order (§4/§6) **and** the write order:

| # | Class | Prefixes, in order |
|---|-------|--------------------|
| 1 | **Construct**     | `UDC_` · `UDCx_` |
| 2 | **Compute**       | `UC_` · `UCk_` · `UCv_` · `UCx_` · `UCkx_` |
| 3 | **Read**          | `URH_` · `URHC_` · `URHx_` · `URHCx_` · `UR_` · `URC_` · `URU_` · `URCv_` · `URCx_` · `URCi_` |
| 4 | **Validate**      | `UEV_` · `CAP_` |
| 5 | **Write**         | `WW_` · `WU_` · `WU2_` · `WU3_` · `WU4_` · `WI_` |
| 6 | **Aux/Protected** | `XI_` · `XE_` · `XB_` |
| 7 | **User**          | `AU_` · `A_` · `AA_` · `Ap_` · `AAp_` · `C_` · `CC_` · `Cp_` · `CCp_` |

Each `…x` auxiliary still sits **directly beneath the function it serves** (§1 positioning) — that
gluing wins over the class-internal rank when a concrete aux would otherwise float up to the class list.

### 5.1.2 Interface mirror

The interface observes the **same region order**, with these differences:

- **No region 1 (Governance)** and **no region 2 (Policy)**.
- **Region 3** — schemas + constants may appear, but **never `deftable`** (tables are module-only).
- **Region 4** — capabilities may appear (those that are part of the cross-module contract).
- **Region 5** — functions may appear in the canonical order, **minus the four excluded kinds** (§5:
  `…x` auxiliaries, `W…` writers, `XI_`, and any `object{module-schema}`-returning function).

So the interface's function order is the §5.1.1 order with exclusions dropped:
`UDC → UC/UCk/UCv → URH/URHC → UR/URC/URU/URCv/URCi → UEV/CAP → XE/XB → A…/C…`.

### 5.2 Capability bands (region 4)

Capabilities are written in four bands, in order **C1 → C2 → C3 → C4**, each with a **metallic** colour:

- **C1 — true / simple → bronze.** `true`-only capabilities (trivial/unconditional), **and** capabilities
  that compose **only** other simple-`true` capabilities.
- **C2 — custom, non-composing → silver.** Non-simple capabilities with their own custom body (enforce /
  reads / guards) that **compose no other capability**.
- **C3 — custom, composing → silver.** Non-simple capabilities that **also compose** other capabilities.
- **C4 — ownership / governance → gold.** Capabilities that prove **ownership or governance** of something
  (account-ownership, admin / governance authority) — the heaviest "authority" smell, so it sorts **last**.

> **Reorder (2026-08-31).** C3 and C4 swapped from the initial listing: **composed** caps are now **C3**
> (silver, grouped with C2), and **ownership / governance** caps are **C4** (gold), so the authority band
> closes the capability region. Colour: **C1 bronze · C2/C3 silver · C4 gold — all metallic** (rendered as
> a gradient-clipped brushed-metal sheen, distinct from the neutral silver used for type annotations).

### 5.3 Body-statement order (deterministic when order is free)

Inside any body — a capability **or** a function — when the statements are **order-independent**, order them:

1. **Pact built-ins** first (`enforce`, `enforce-guard`, `at`, `read`, `map`, `fold`, …).
2. **Cross-module (mod-ref) calls** next — from the **most distant** module (deepest in the dependency
   stack) **up to the closest** (the module just below the one we are in).
3. **Same-module functions** last — in the **canonical function order** (§5.1.1).

A genuine data dependency **takes precedence** — this rule only fixes order when it is otherwise free,
making the written structure exact and deterministic across the whole codebase.

> **Amendment (2026-08-31).** Supersedes the prior bottom-up ordering: (a) a module is now defined as the
> five regions above; (b) **Construct (`UDC_`) now LEADS the function region** (was late, after `CAP_`),
> per the 7-class colour/build order; (c) "no intra-module load-order constraint" is made explicit —
> functions are ordered by canon, not dependency; (d) capability bands **C1–C4** and the **body-statement
> order** are now specified (they were referenced but undefined). The earlier worked reference
> `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_MTX-AQP.pact` predates the Construct-first order.

---

**Two hard rules the colour should reinforce:**
1. **HEAVY-READ must be visually loud** — its entire reason to exist as a separate class is so a
   reviewer instantly sees a scan and checks it is **off the execution path** (never called from a
   `defcap` / `C_` / `X` / writer). Amber/orange, not a quiet blue.
2. **`…x` auxiliaries stay in their base family's hue** (dimmed) — they are not a new colour; they
   are "the helper of the coloured thing right above me."

---

## 6. Flat prefix index (hand-off list for the highlighter)

Every function/cap prefix, grouped by colour family. `_` marks the class boundary; `|` scopes and
module/table names are **not** prefixes (colour the class token, not the scope). Match **longest prefix
first** (e.g. `URHC_` before `URH_`, `URCi_` before `URC_` before `UR_`, `CC_` before `C_`, `AAp_` before `AA_`).

| Family | Prefixes (match longest-first) |
|--------|--------------------------------|
| **COMPUTE**      | `UCkx_` `UCk_` `UCx_` `UCv_` `UC_` |
| **READ**         | `URCx_` `URCv_` `URC_` `URU_` `UR_` |
| ~~**CAP-INSTALL**~~  | *removed 2026-08-31 → `CAP_`* (folds into ENFORCE) |
| **COST**         | `URCi_` |
| **HEAVY-READ ⚠** | `URHCx_` `URHC_` `URHx_` `URH_` |
| **ENFORCE**      | `UEV_IMC` (structural, see below) · `UEV_` `CAP_` |
| **CONSTRUCT**    | `UDCx_` `UDC_` |
| **CONSTANT**     | `CT_` |
| **WRITE**        | `WI_` `WU4_` `WU3_` `WU2_` `WU_` `WW_` |
| **RECIPE**       | `AAp_` `AA_` `Ap_` `AU_` `A_` · `CCp_` `CC_` `Cp_` `C_` |
| **PROTECTED**    | `XI_` `XE_` `XB_` |
| **STRUCTURAL**   | `GOV` `GOV\|` `P\|` `SECURE` `UEV_IMC` |

**Lowercase specialization markers** (appended to a class, take the base hue, usually dimmed — except
`i`): `k` key-build · `x` auxiliary · `v` intrinsic-validating · ~~`cap`~~ **retired 2026-08-31 → use `CAP_`**
(ENFORCE) · `i` **IGNIS-cost-emitting (own COST hue)** · `p` Hydra-parallel-slice (on recipes) ·
doubled base letter (`CC`/`AA`) = heavy.
