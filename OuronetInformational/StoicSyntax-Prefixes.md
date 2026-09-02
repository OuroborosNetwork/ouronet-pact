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

## 2.1 Sweep rulings (2026-09-01) — canon additions from the whole-codebase StoicSyntax sweep

Owner-ratified during the #90 sweep. These **extend / amend** §1–§2 (authoritative):

**New prefixes**
- **`INFO_`** — **Information reader**, a specialization of the **READ / URC** family (coloured as READ/URC).
  A preview reader returning `object{OuronetInfoV1.ClientInfo}` that wraps a `URCi_` cost source into a
  UI cost + description preview. Pure read+derive, **no `enforce`**. Canonical form `INFO_MODULE|Op`.
  **Supersedes** the legacy `MODULE|INFO_Op`, bare `INFO_Op`, and the interim `URC_MODULE|Op` INFO
  spellings — all migrate to **`INFO_MODULE|Op`**.
- **`REPL_`** — **repl-test-only helper**. Exists solely for `.repl` harnesses and is **stripped from the
  mainnet deploy**. Off the production surface; excluded from the interface. Not a production class.

**Scope form — prefix-first is canonical (supersedes module-first).** Every module/entity-scoped name is
`PREFIX_MODULE|Name`: the class prefix **leads**, then the entity scope, then the name — for EVERY class,
**including the Talos recipe wrappers**: `DPNF|C_Create` → `C_DPNF|Create`, `SPARK|C_Acquire` →
`C_SPARK|Acquire`, `MTX|2|C_Inject` → `C_MTX|2|Inject`. The earlier `MODULE|PREFIX_Name` Talos form is
retired. Multi-segment scopes keep their pipes (`C_MTX|2|Inject`).

**Suffix stacking.** Lowercase specialization markers stack freely: `x`→`xx` (aux-of-aux, e.g. `UCxx_`) and
combine across roles (`URCi`+`x` = `URCix_`, a cost-reader auxiliary). The prefix still reflects the
function's own nature; extra `x` layers say "helper of the helper above."

**Numeric quantifiers.**
- **Recipe steps** — a recipe may carry a numeric step: `A01_`…`A11_` = `A_` admin executed in ordered
  steps (same class as `A_`; the number is sequence, not a new prefix).
- **Write arity** — `W{I,U,W}<n>_`, `<n>` = fields touched in one op: `WU2_`=2 updates … `WU7_`=7. Extends
  the former WU2/3/4 to any `<n>`.

**Structural-payload scope = `GOV`.** The smart-account branding/governor payloads formerly written bare
(`DALOS|Info`, `SWP|Info`, `TALOS|Gassless`, `DALOS|VirtualGasData`, `DALOS|EmptyOutputCumulatorV2`) take
their **real class prefix**, scoped under **`GOV`**: `UDC_GOV|Info`, `…_GOV|Gassless`, etc.

**Variant scope `STOA-PID`.** SWP liquidity/swap functions taking an explicit `stoa-pid` (STOA price in
USD) arg keep their real class and carry `STOA-PID` as a variant scope: `XI_STOA-PID|Swap`,
`C_STOA-PID|AddStandardLiquidity`, `URC_STOA-PID|LpToIgnis` (kept because a plain twin exists, e.g.
`XI_Swap`). The "`stoa-pid` = STOA price in USD" fact lives in each `@doc`.

**Corrections applied during the sweep.** `X_` (bare) → the correct one of `XI_/XE_/XB_` by reach; `XII_` →
`XI_` (typo); `NS_` → `CT_` (namespace constants). The §3 migrations plus `URCcap_→CAP_` and `AUP_→AU_`
are applied.

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

**Colour rule — only GOLD needs a marker; bronze and silver are inferred.** You can't tell an ownership cap from
a plain custom cap by its body, so **gold** is the one band that must be declared. Everything else follows from the
body. Precedence, top to bottom:

1. **`true`-only body → BRONZE — and this WINS over everything below.** A `(defcap X (…) true)` whose body is the
   literal `true`, checked **after stripping `@doc`/`@model`/`@managed`/`@event` metadata and the arg list** — so
   `(defcap X () @doc "…" true)` is still bronze (the `@doc` must not hide the `true`). **Also bronze:** a cap whose
   body does nothing but `compose-capability` other **bronze** caps — composing only simple/`true` caps is still
   simple (resolved to a **fixpoint**). (A cap whose body *calls* a real function — e.g.
   `(CAP_EnforceAccountOwnership account)` — is **not** trivial.) **Bronze is strictly highest priority: a
   simple/`true` cap stays bronze EVEN inside the `;;{C4}` or governance `;;{G2}` block — it does NOT go gold.**
2. **Under `;;{C4}` OR a governance cap (`;;{G2}`) → GOLD** — *only if it is not bronze by rule 1.* The
   ownership/governance/authority band; declared by the marker because it isn't inferable.
3. **Anything else (a non-`true` cap that isn't a pure compose-of-bronze) → SILVER.**

So the **`;;{C1}` / `;;{C2}` / `;;{C3}` markers organise the file but do NOT drive the colour** — a C1 block holds
true caps (→ bronze) but a non-true cap sitting there is silver; C2/C3 are silver by construction.

> **Amendment (2026-09-02).** Bronze is now resolved to a **fixpoint FIRST**, then gold/silver are assigned to what
> remains. Three corrections, all so a *simple* cap can never masquerade as authority: (a) the literal-`true` test
> **ignores `@doc`/`@model`/`@managed`/`@event` metadata + the arg list** (an `@doc`'d true cap was wrongly
> rendering **gold** in the governance block — the reported bug); (b) bronze is **transitive** — a cap that only
> `compose-capability`s bronze caps is itself bronze; (c) bronze takes **strict precedence over the gold marker**
> (a `true`/simple cap under `;;{G2}`/`;;{C4}` stays bronze). The classifier now reads three signals: *does the body
> reduce to `true`?* · *does it only compose bronze caps?* · *(only if neither) is it under `;;{C4}`/`;;{G2}`?*

### 5.2.1 The GOVERNANCE region (`;;GOVERNANCE`, sub-blocks G1–G3)

The governance region at the top of a module has three marked sub-blocks:

| Marker | Contents | Colour |
|---|---|---|
| `;;{G1}` | governance **constants** (`defconst GOV\|…`) | **grey + BOLD** (grey like other constants, but bolded) |
| `;;{G2}` | governance **capabilities** | **gold** — *except* a true/simple one, which is **bronze** (the priority rule) |
| `;;{G3}` | governance **defuns** (all `GOV`-prefixed) | **grey** (STRUCTURAL — unchanged; correct as-is) |

Policy sub-blocks (`;;{P1}…{P4}`) and the schema/table/const blocks (`;;{1}…{3}`) mark regions the same way but
carry no cap band — a cap under them (rare) falls back to silver.

### 5.2.2 Foreign & uncategorisable → BLACK

Some names are pulled in from **other modules** (via a mod-ref, `ref-X::member`) or otherwise **don't follow
StoicSyntax** and can't be categorised. This module cannot know their band or nature, so they render **neutral
BLACK** — a **charcoal medallion with LIGHT text** (visible, but unmistakably "not one of ours"):

- **Foreign CAPABILITY** — a cap installed/required from another module, e.g. `install-capability
  (ref-coin::TRANSFER …)` → **black ANGLED medallion**. Angled because it *is* a capability; black because from
  outside we cannot know whether it is C1–C4 or what state it's in.
- **Foreign / non-conforming FUNCTION** — a call that matches no StoicSyntax prefix and is no Pact built-in, e.g.
  `ref-coin::get-balance`, `ref-coin::transfer` → **black ROUNDED medallion** (a pill, *not* plain text, so the
  "uncategorised / from outside" flag is impossible to miss). It's black because it doesn't follow the syntax —
  not merely because it's external.

Detection: after a `ref-X::member` split (`::` left default, §5), if the member matches **no** prefix **and** is
no built-in → it's foreign. **ALL-CAPS letters = a capability** (Pact convention: `TRANSFER`/`MINT`/`ROTATE`),
otherwise a **function**. Rare in practice — StoicSyntax modules are still recognised by prefix across the `::`
(e.g. `ref-U|ATS::UDC_Elite` stays yellow); only truly foreign/generic names (the `coin` interface, etc.) go black.

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

### 5.4 The block-marker skeleton (the full canonical layout)

Every module and interface is partitioned by **marker comments** — the machine-readable skeleton the sweep +
colouring agents read. Two forms:

- **Region header** — an ALL-CAPS comment: `;;GOVERNANCE`, `;;POLICY`, `;;SCHEMAS-TABLES-CONSTANTS`,
  `;;CAPABILITIES`, `;;FUNCTIONS`.
- **Sub-block marker** — a braced tag: `;;{G1}`, `;;{C4}`, `;;{F3}`, `;;{2}` … one per sub-block, in order.

**Canonical MODULE skeleton** (regions top-to-bottom; sub-blocks in the order shown):

```
(module NAME GOV
  ;;GOVERNANCE                     — the module's own governance, self-contained
    ;;{G1}   governance CONSTANTS   (defconst GOV|…)            → grey + BOLD
    ;;{G2}   governance CAPS        (defcap  GOV|…)             → gold  (bronze if a `true` body)
    ;;{G3}   governance DEFUNS      (defun   GOV|…)             → grey  (STRUCTURAL)
  ;;POLICY                          — IMC policy registry (present when the module has policies)
    ;;{P1}   policy capabilities · ;;{P2} policy tables (P|…) · ;;{P3} … · ;;{P4} policy consts + defuns (P|…)
  ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}    defschema …            → schemas
    ;;{2}    deftable  …            → tables            (interface: OMIT — tables are module-only)
    ;;{3}    defconst … + CT_ const-helper defuns
  ;;CAPABILITIES                    — bands, in order C1 → C2 → C3 → C4 (colour rule in §5.2)
    ;;{C1}  simple/true             ;;{C2} custom non-composing   ;;{C3} custom composing   ;;{C4} ownership/gov
  ;;FUNCTIONS                       — the prefixed functions, in the CANONICAL 7-class order (§5.1.1)
    ;;{F1} Construct [UDC]  · ;;{F2} Compute [UC] · ;;{F3} Read [UR/URC/URH/URCi] · ;;{F4} Validate [UEV/CAP]
    ;;{F5} Write [W]        · ;;{F6} Aux/Protected [X]  (sub-tiers X-A, X-C, X-<Table>) · ;;{F7} User [A] · ;;{F8} User [C]
)
```

**Ordering, at three scales** (all deterministic — see §5.1's "no intra-module load-order constraint"):
1. **Blocks** — the region + sub-block order above (Governance → Policy → Schemas/Tables/Consts → Capabilities →
   Functions; and within each, the sub-markers in the listed order).
2. **Within a block** — functions follow the **7-class order** (§5.1.1: Construct→Compute→Read→Validate→Write→
   Aux/Protected→User); each `…x` auxiliary sits directly beneath the function it serves (§1); capabilities go
   C1→C4; recipes by weight then mode (§2 recipe-axes).
3. **Within a prefix family** — strongest → lightest (bold lead ▸ shades ▸ aux italic ▸ cost), the exact 1–37
   sequence in §5.1.1 / §6.

**Canonical INTERFACE skeleton** — the same order, dropping what interfaces can't hold (§5.1.2): **no**
`;;GOVERNANCE`, **no** `;;POLICY`, **no** `;;{2}` tables; keeps `;;SCHEMAS-TABLES-CONSTANTS` (schemas + consts
only), `;;CAPABILITIES` (the ones in the contract), and `;;FUNCTIONS` **minus** the four excluded kinds (`…x`
aux, `W…` writers, `XI_`, and any `object{module-schema}` return).

> **Marker note (2026-08-31).** The `;;{Cx}`/`;;{Gx}`/`;;{Fx}`/`;;{Px}`/`;;{n}` markers are the source of truth
> the agents read: the **cap classifier** needs only `;;{C4}` and `;;{G2}` (gold — §5.2), the **G1** marker drives
> the bold-grey governance constants, and the **region order** drives the sweep. A real module's markers may be in
> a pre-sweep order (e.g. DALOS today lists functions `UR→URC→UEV→UDC→CAP→A→C→X→AUP`); the sweep re-lays them into
> the canonical order above, and the colourer is order-independent so it renders correctly either way.

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

---

## §7. Canonical module skeleton — FULL settle (amendment 2026-09-02)

**Authoritative.** Supersedes the partial schemes in §5.1/§5.2/§5.2.1/§5.4 where they differ.
Source: `docs/STOICSYNTAX-MODULE-MARKERS-HANDOFF.md`. The empty-block start-point template is
[`canon.pact`](canon.pact). The highlighter reads these markers + composition — **markers are syntax, not decoration.**

### 7.1 Block order (per logical module UNIT)
A module *file* may hold several *logical units* (`coin` = 3; almost every Ouronet module = 1); a multi-unit
file repeats the whole skeleton once per unit. The optional **`@doc "…"` is the *module's* @doc** — module
metadata in the module header (right after `(module NAME GOV`), **one per logical unit**, sitting before block
`{0}`; it carries **no block marker**. *(The handoff's "per file" was a 1-module-per-file shorthand; it is the module @doc.)*

| # | Block | Contents |
|---|---|---|
| `{0}` | **IMPLEMENTERS** | only `(implements <interface>)` |
| `{#}` | **GASSTATION** | optional · **unnumbered** · rare (DALOS only) · named gas-payer surface · ⟨COLOUR⟩ **all caps GOLD** · omit entirely unless present |
| `{1}` | **GOVERNANCE** | sub-blocks G1..G5, all members `GOV|` |
| `{2}` | **POLICY** | sub-blocks P1..P5, all functions `P|`-led |
| `{3}` | **CST** | 3.1 constants · 3.2 schemas · 3.3 tables |
| `{4}` | **CAPABILITIES** | sub-blocks C1..C4 |
| `{5}` | **FUNCTIONS** | 7 classes, sub-blocks 5.1..5.7 |
| `{6}` | **REPL** | test-only `REPL_*`; **added only when present, DELETED at deploy, NOT in `canon.pact`** (no empty-6 to strip) |

Every block/sub-block is marked **even when empty** (except `{#}` and `{6}`, which are added only when present).

### 7.2 GOVERNANCE G1..G5 — **gov caps move `{G2}`→`{G4}`**
G1 constants (⟨COLOUR⟩ grey+BOLD) · G2 schemas · G3 tables (key-shape comment) · **G4 capabilities**
(⟨COLOUR⟩ GOLD unless bronze by composition; order class-1-first…class-4-last, no `{Cx}` markers in-block) ·
G5 functions (all `GOV|`). G5 **may optionally** carry per-need **custom sub-sub designators** — **arbitrary**
camelCase names, each on its own sub-sub line, present only if the module needs them. DALOS happens to use
`Keys` / `SmartContractNames` / `PublicKey`, but that is **only an example — not a mandatory or fixed set**;
a module may use any names it needs, or none. *This replaces the prior §5.2.1 "G1 const · G2 caps · G3 defuns".*
⟨COLOUR dep⟩ the classifier's gold-gov-cap check moves from `{G2}` to **`{G4}`**.

### 7.3 POLICY P1..P5 — `P|` leads
P1 const · P2 schemas · P3 tables (in use today) · P4 caps (none today) · P5 functions. **Every policy function
is `P|`-first then the normal StoicSyntax name**: `P|UR_IMP`, `P|A_AddIMP`, `P|UEV_IMC`.
- **Rename:** today's `A_P|AddIMP` → **`P|A_AddIMP`** (policy prefix leads); the **policy interface is rewritten** to match.
- ⟨COLOUR dep⟩ **new rule:** filter the leading `P|` (renders grey/structural) and colour the *remainder* by its
  real prefix — same as the `::` split and the `GOV|` grey.

### 7.4 CST — key-shape comments
3.3 tables: on the `deftable` line, a comment giving the **key shape** with `|` as the semantic component
separator: `<component>|<component>|<component>`. The `|` bar is the one canonical separator everywhere
(key shapes, `GOV|`/`P|`, `MODULE|MEMBER`).

### 7.5 CAPABILITIES C1..C4 (composition-based; composition wins over placement)
- **C1 · Trivial — ⟨BRONZE⟩**: body is `true` (metadata `@doc` ignored) **or** composes **only** bronze/C1
  caps (transitive) **with no other logic**. Bronze is resolved to a fixpoint FIRST and **wins even under a `{C4}` marker**.
- **C2 · Simple — silver**: own logic, composes **no** caps.
- **C3 · Composed — silver**: composes **≥1 non-bronze** cap (may compose a C4 cap and **still be C3**).
- **C4 · Ownership — ⟨GOLD⟩**: **non-composing**, body is **ONLY ownership/authority validation** (e.g. just
  `CAP_EnforceAccountOwnership`). A cap that enforces ownership **plus other logic/validation** is **not** C4
  (→ C2 if non-composing, C3 if composing). *Worked example (DALOS): `F>OWNER`,`F>GOV`→C4; `S>ROTATE-OA-SOVEREIGN`
  (CAP_ + extra validators)→C2; `C>DEPLOY-*` (compose SECURE + own logic)→C3; `SECURE`→C1.*
  `GOV|`-named caps sitting in the cap block relocate to the GOVERNANCE block.
- Silver ({C2}/{C3}) is inferred (not colour-bearing); `{C4}` and the GASSTATION block are the gold-bearing markers.

### 7.6 FUNCTIONS 5.1..5.7 (build order; strongest→lightest within each)
| Sub | Class | Prefixes (ordered) | Family colour |
|---|---|---|---|
| 5.1 | **Construct** | `CT_` (constant — **leads**, C<U) · `UDC_` · `UDCx_` | yellow |
| 5.2 | **Compute** | `UC_` · `UCk_` · `UCx_`/`UCkx_` | teal |
| 5.3 | **Read** | `UR_` · `URC_` · `URU_` · `URCx_` · `URH_`/`URHC_`(heavy) · `URCi_`(cost) · `INFO_` | tan/amber |
| 5.4 | **Validate** | `UEV_` · `CAP_` (a Validate **function**, not a `{C4}` cap) — **NB** the IMC spine enforce is a POLICY function `P|UEV_IMC` in `{P5}`, **not** here | red |
| 5.5 | **Write** | `WI_` · `WU_`/`WU2_`/`WU3_`/`WU4_` · `WW_` | magenta |
| 5.6 | **Aux/X** | `XI_` · `XE_` · `XB_` | purple |
| 5.7 | **User** | `A_`·`AA_`·`Ap_`·`AAp_`·`AU_` **then** `C_`·`CC_`·`Cp_`·`CCp_` | green |
Class order 1→7 is build order (Construct leads). *This replaces the earlier `{F1..F9}` numbering — functions
are now `{5.1..5.7}`; admin+client are one class (5.7), REPL is block `{6}`.*

### 7.7 Marker glyphs (Placement-Marker Registry)
- **BLOCK**: a rule line `;;<` + `=`×73 + `>` immediately followed by `;;{N}  NAME` (N ∈ `0 # 1 2 3 4 5 6`).
- **SUB-BLOCK**: `;;{tag}  label` — tags `G1..G5` · `P1..P5` · `3.1..3.3` · `C1..C4` · `5.1..5.7`.
- **SUB-SUB (variant / G5 designator)**: `;;  · label` (indented middle-dot; lighter than a sub-block).
- **REPL block `{6}` separator — DELIBERATELY DISTINCT**: an **X-rule** (not the `=` rule) so the strippable
  test block is trivially greppable/wipeable at deploy. Present **only when the block exists**:
  ```
  ;;<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>
  ;;{6}  REPL   —   TEST-ONLY · DELETE ON DEPLOY
  ;;<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>
  ```
  Deploy strip = delete from the `{6}` X-rule to the module close. Never emitted in `canon.pact`.
- All markers appear in canonical order; the sweep re-lays a file's markers to it.

### 7.8 Colour-bearing markers (keep classifier ↔ canon in lockstep)
`{C4}` (gold caps) · **`{G4}`** (gold gov caps — moved from `{G2}`) · `{G1}` (grey-bold gov constants) ·
the **GASSTATION block** (gold caps) · grey structural **`GOV|`** and **`P|`** prefix filters. Everything else
(`{C1..C3}`, `{P1..P5}`, `{3.1..3.3}`, block/variant separators) is organizational. When marker spellings are
finalized, notify the colouring maintainer so `{G4}` / GASSTATION / `P|`-filter land in the highlighter.

### 7.9 Scope
This pass = **complete rename + reorder + refactor of every Pact module AND interface** to this skeleton
(interfaces mirror the module: implementers, then GOV members, then POLICY, CST, caps, and all functions except
`XI_`/`W*_`, in the same order — and must be **complete**). **REPL test code has no canon** — written however
makes the test work.

### 7.10 Interface location & versioning (amendment 2026-09-02)

**Interfaces are co-located with the modules that use them — the `0_Interfaces/` pool is RETIRED.**

- **Home = first deploy-order implementer.** Each interface lives in the `.pact` file of the **first module
  (in deploy order) that `implements` it**, placed **above** the module form. Since deploy order already
  respects dependencies, the interface then deploys immediately ahead of the first module that needs it —
  self-ordering, nothing to hunt for. (Ex: `OuronetConstantsV*` → `U|CT`'s file; `OuronetDalosV*` → DALOS's
  file; `OuronetPolicyV*` (implemented by ~51 modules) → the earliest module that implements it.)
- **Multiple interfaces in one file** sit in **the order the module defines/uses them**, base-most first
  (interface→interface deps deploy first). Each carries its own `@doc` + the mirror skeleton.
- **Interface mirror** — an interface can't hold `deftable` or function bodies, so it mirrors its module's
  order for the members it *can* declare: constants, schemas, capability signatures, and function signatures —
  **all functions except `XI_` and `W*_`** (plus GOV/policy members, in the same order the module writes them).
  Interfaces must be **complete** (nothing a consumer needs is missing).
- **Deploy size** is measured **per interface** and **per module**, never per source file: if a co-located
  `interface + module` file is too big for one tx, deploy the interface first and the module as a second tx.
- **Retire the pool:** delete the `0_Interfaces/` files; git history preserves old versions.

**Versioning — dual `net:` / `dev:` comment, name = dev version.** Two comment lines sit immediately above
each interface (Kadena interfaces are **immutable**, so a modified interface must deploy under a new name — the
version stays in the name):
```
;; net: v5          ;; live on mainnet  (lags; bumped only when you deploy the update)
;; dev: v5          ;; in this repo      (== net when synced)
(interface OuronetDalosV5  …)            ;; consumers: (module{OuronetDalosV5})
```
- **Synced:** `net: v5` / `dev: v5`, interface `…V5`.
- **On modification:** bump `dev: v6`, rename `…V5 → …V6`, refactor **every** `module{…V5}` consumer to `…V6`
  (deliberate cascade — `dev:` now leads `net:`). `net:` unchanged.
- **On mainnet deploy:** set `net: v6`. Synced again.
- **Pre-first-deploy (today):** `net: —  (undeployed)`; keep each interface's **current** version number as
  `dev:` (V1…V12 as they stand — do **not** reset to V1). The #83 fresh redeploy records `dev:` as the initial `net:`.

### 7.11 Sweep rulings — CT_/gas-station/unprefixed helpers (amendment 2026-09-02)

- **`CT_` = the UDC-constant variant (variant A: keep the spelling).** `CT_` is recognized in canon as a
  **Construct-family constant** (the `c` = constant specialization of UDC). It **leads sub-block `{5.1}`**
  (order: `CT_` → `UDC_` → `UDCx_` — `C` sorts before `U`). No physical rename of the ~186 `CT_` functions /
  `OuronetConstantsV1`. (`defconst` VALUES stay in CST `{3.1}`; `CT_` ACCESSOR functions live in `{5.1}`.)
- **Gas-station `{#}` detection** = a module has a **`GAS_PAYER` capability** and/or a **`create-gas-payer-guard`
  function** (the `stoa-ns.gas-payer-v1` surface). Those two + `CT_VirtualGasData` form the `{#}` block;
  `create-gas-payer-guard` keeps its interface-mandated name. Only DALOS has one today.
- **Unprefixed scoped helpers → canonical prefixes** (reclassified this sweep):
  `‹MOD›|Info` (DALOS/LIQUID/SWP/SPARK/SNAKES/CUSTODIANS/KPAY/STOAICO) → **`CT_Info`** (constant info-key);
  `EmptyDispo` → **`UDC_EmptyDispo`**; `DALOS|EmptyOutputCumulatorV2` → **`UDC_EmptyOutputCumulatorV2`**
  (drop the DALOS scope — generic constructor in IGNIS); `DALOS|VirtualGasData` → **`CT_VirtualGasData`**
  ({#} gas block); `TALOS|Gassless` → **`URC_Gassless`**.

### 7.12 Interface markers (amendment 2026-09-02)
Interfaces carry the **same block-marker skeleton** as modules, minus the blocks
they can't hold: **no `{0}` implementers, no `{#}` gasstation, no `{6}` REPL, no
tables/bodies**. They mirror the module's order for what they *can* declare —
constants `{3.1}` · schemas `{3.2}`/`{G2}`/`{P2}` · cap signatures `{4}` ·
function signatures `{5.1..5.7}` (and `{G5}`/`{P5}`). Notably **`CAP_` is a Validate
FUNCTION → `{5.4}` with the `UEV_`s** (the old separate `[CAP]` group is gone). The
skeleton emitter (`tools/skeleton_emit.py`) sweeps `(interface …)` blocks the same
way it sweeps `(module …)`.

### 7.13 Enforcement & authoring (Phase 7 — the drift gate)
Canon is now **self-enforcing** so future work can't silently drift (no re-sweep needed):
- **`tools/skeleton_emit.py`** — the *fixer*: re-lays any module/interface into canonical form.
- **`tools/cap_band.py`** — the composition-based cap classifier (C1–C4, §7.5).
- **`tools/canon_check.py`** — the *verifier*: runs the fixer in a temp copy and asserts the file is
  already canonical **up to blank lines** (blank spacing is cosmetic, not a canon rule). Exit 1 on any real
  drift (member re-ordered, wrong marker/band, unknown prefix, `CAP_` outside `{5.4}`, …).
- **`tools/gate.sh`** — the hard gate: **`canon_check` clean AND `Z.repl` green**. Run before committing / in CI.
- **`tools/hooks/pre-commit`** — blocks a commit whose staged `.pact` drift (install:
  `ln -sf ../../tools/hooks/pre-commit .git/hooks/pre-commit`).

**Writing a new module:** copy [`canon.pact`](canon.pact) as the start-point, fill the blocks, and run
`tools/gate.sh` before committing. Load this file (the canon) first. Citizen modules get the same gate.

**Colour maintainer sync:** when marker spellings change, tell the highlighter maintainer — current
colour-bearing markers are `{C4}` (gold caps), `{G4}` (gold gov caps), `{G1}` (grey-bold gov consts),
the GASSTATION block (gold caps), and the grey `GOV|`/`P|` structural-prefix filters.
