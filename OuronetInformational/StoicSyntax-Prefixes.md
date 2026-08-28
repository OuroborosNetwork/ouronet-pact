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
> constructors/compute (`UR_`, `URC_`, `URH_`, `URHC_`, `UEV_`, `CAP_`, `UDC_`, `UC_`, `UCk_`) **unless**
> they hit exclusion #4 (module-schema return).

So an `XE_`/`XB_` missing from the interface is a **bug** (it's callable from outside but undeclared);
a `URH_` reader used by the UI/another module belongs in the interface (subject to #4); a `URH_` reader
used only inside its own module does not.

---

## 5.1 Canonical within-module ORDER (and interface mirror)

A module reads strictly **bottom-up**: every dependency precedes what composes it, so the file
culminates in its **public recipes**. Five blocks:

1. **Schemas / tables / constants** — const-helper defuns (e.g. `CT_Bar` feeding `(defconst BAR (CT_Bar))`)
   stay here; a `defconst` that calls a defun needs it defined *above* the const.
2. **Capabilities** — bands C1–C4.
3. **Utility functions** (the "first round" — all auxiliaries), in family order:
   `UC / UCk` → `UR / URC / URU` → `URH / URHC` → `UEV` → `CAP` → `UDC` → **`W` (`WU / WU2-4 / WW / WI`)**.
   `W` is **last** in this block; each `…x` auxiliary sits directly beneath its base function.
4. **X — auxiliary orchestration**: `XI` → `XE` → `XB` (sub-tiering observed).
5. **User functions** (the complete/final recipes — **LAST**): `A_ / AA_ / Ap_ / AAp_` → `C_ / CC_ / Cp_ / CCp_`
   (weight by letter-doubling, mode by `p` suffix; within a base, solo before parallel)
   (admin = a user fn needing admin rights; client = a user fn anyone may call).

The **interface mirrors this order**, dropping the four excluded kinds (§5):
`UC/UCk → UR/URC/URU → URH/URHC → UEV → CAP → UDC → XE/XB → A → C`.

> **Amendment (2026-08).** Two corrections to earlier canon: (a) `W` writers moved to the **tail of
> block 3** (were loosely placed); (b) `X` is an *auxiliary* layer, so it now precedes the user
> functions — the old `A → C → X` becomes `… → X → A → C`, and the module ends on `A_/C_`. Worked
> reference for the amended order: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_MTX-AQP.pact`.

---

**Two hard rules the colour should reinforce:**
1. **HEAVY-READ must be visually loud** — its entire reason to exist as a separate class is so a
   reviewer instantly sees a scan and checks it is **off the execution path** (never called from a
   `defcap` / `C_` / `X` / writer). Amber/orange, not a quiet blue.
2. **`…x` auxiliaries stay in their base family's hue** (dimmed) — they are not a new colour; they
   are "the helper of the coloured thing right above me."
