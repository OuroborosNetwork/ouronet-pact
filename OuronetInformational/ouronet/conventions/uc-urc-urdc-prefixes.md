# UC vs URC vs URDC — read depth prefixes

Use this when naming **unprotected** helpers in sovereign modules (especially **AQP-ANK / AQP-SCORE / AQP-POOL / AQP-FVT / AQP-VCT**).

## Rules

| Prefix | May call | Must not | Use when |
|--------|----------|----------|----------|
| **UC_** | **UC_**, **UDC_** only | **UR_**, **URD_**, table **`read`**, **`select`**, **`keys`**, **`enforce`** | Pure compute on arguments (keys, hashes, ceil-div, array transforms on values already passed in). |
| **URC_** | **UR_**, **UC_**, **UDC_**, other **URC_** | **URD_**, **`select`/`keys`** (except via **UR_**), **`enforce`** | Derives a value from **point reads** / **UR_** rows (existence checks, rollups from **UR_**, cross-field math). |
| **URDC_** | **URD_**, **UR_**, **UC_**, **UDC_**, **URC_**, other **URDC_** | **`enforce`** | Derives a value using **heavy scans** (**URD_** — `select`, multi-row inventory, batched table passes). |

**Migration signal:** if a function named **UC_** calls **UR_** or **`read`**, rename to **URC_**. If it calls **URD_**, rename to **URDC_**. If a function named **URC_** calls **URD_**, rename to **URDC_**.

**Auxiliary tiers:** internal sub-helpers may use **URCX_** / **URDCX_** under the parent **URC_** / **URDC_** block (same read-depth rules).

**Validation stays upstream:** **URC_** / **URDC_** return derived values only — no **`enforce`**. Failures belong in **UEV_**, **defcap**, or **C_** wiring.

## X* write tiers (reminder)

| Prefix | Scope | Body | Protection |
|--------|-------|------|------------|
| **XI_** | Internal to **this** module only | **`W_*`** orchestration; no bare **`write`** when **`W_*`** exists. No **`OutputCumulator`**. | **`(require-capability (SECURE))`** **or** `;; SECURE: granted by … (underlying W_)` when all writes go through **`W_*`** |
| **XB_** | Cross-module (IMC + IMP) | Same write rules as **XI_**; home module **`UEV_IMC`**. | **`(UEV_IMC)`** + named cap |
| **XE_** | Forward export | **`UEV_IMC`** + **`with-capability (…\|XE>…)`** → **`XI_1|*`** / **`W_*`**; caller composes IGNIS. | **`(UEV_IMC)`** + named cap |

**Tier depth:** **`C_*`** → **`XI_*`** (0) → **`XI_1|*`** (1) → **`XI_2|*`** (2). **`XE_*`** → **`XI_1|*`** → **`XI_2|*`** (no **`XE_*`** → **`XI_2|*`** skip).

Detail: **`x-function-guards.md`**.

**Compute-before-write:** **URDC_** / **URC_** / **UC_** prepare data; **C_** acquires cap then calls **XI_** (never **`write`** in **C_**).

## @doc cross-references

When **`@doc`** names another function, prefix with the **on-chain module name** and a dot: e.g. **`AQP-POOL.URD_AQP|VacateTfInventory`**, **`AQP-VCT.UC_ComputeMinSliceCount`**, **`AQP-FVT.XE_RunTrueFungibleVacateBatch`**. Same rule in README handoffs and schema **`@doc`** strings. Inside a module, **`defun`** names use the prefix only (**`UC_`**, **`UR_`**, …) — no redundant **`MODULE|`** in the identifier.

## FUNCTIONS block order (canonical)

**UC_** → **UR_** → **UDC_** → **URD_** → **URC_** → **URDC_** → **UEV_** → **C_** → **X** (**XI_** / **XE_** / **XB_**). Reference: **`05_VCT.pact`**. Detail: **`MODULE_ARCHITECTURE.md`** § *FUNCTIONS block order (canonical)*.

## Examples (AQP)

- **UC_ComputeMinSliceCount** (in **AQP-VCT**) — args only → **UC_**
- **URDC_VacateOwnerCountForKind** — **URD_AQP\|Vacate*Inventory** → **URDC_**
- **URDC_FVT\|BuildStakeSettleBundle** — **URD_FVT\|SettleFvtRewardBundle** → **URDC_**
- **URDCX_SfStakeDefinitionWeightedRawWeight** — **URD_S-DEF\|SFScoreRows** → **URDCX_**

Detail: **`MODULE_ARCHITECTURE.md`** § Unprotected prefixes; **`OuronetInformational/ouronet/conventions/index.md`**.
