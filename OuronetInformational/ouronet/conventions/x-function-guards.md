
# X-function guards and cap-only validation

## Guard options

Every **`XI_*` / `XE_*` / `XB_*`** must document how it is protected: either an explicit guard in the body, or a **`;; SECURE:`** / **`;; IMC:`** comment stating why a repeat guard is not needed.

| Entry | Guard | Body |
|-------|-------|------|
| **`XI_*`** (same module) | `(require-capability (SECURE))` **or** `;; SECURE: …` comment | **`W_*`** orchestration — **no `enforce`** |
| **`XE_*` / `XB_*`** (cross-module) | `(UEV_IMC)` as **first statement** **or** comment if cap-only child | `with-capability (NAMED-CAP …)` then **`XI_*` / `W_*`** — **no `enforce`** |
| **`C_*` / `A_*`** | recipe cap | **`W_*`**, **`XI_*`**, **`XE_*`** as needed — **no `enforce`** |
| **`WI_*` / `WU_*` / `WW_*`** | `(require-capability (SECURE))` | one **`insert` / `update` / `write`** as the **last** expression — module-internal only |

### `XI_*` and redundant `SECURE`

When **`XI_*`** persistence goes **only** through **`W_*`** (each **`W_*`** already **`(require-capability (SECURE))`**), do **not** repeat **`(require-capability (SECURE))`** on **`XI_*`**. Instead:

```pact
(defun XI_1|PlaceAnchorInBookkeeping …
  @doc "…"
  ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
  (let ((bc …) (aa …))
    (WW_BoostClass …)
    (WW_AssetAnchors …)
  )
)
```

Use explicit **`(require-capability (SECURE))`** on **`XI_*`** only when the body performs a **raw** persistence op not routed through **`W_*`** (legacy / migration only in non-AQP modules).

### X tier depth (reminder)

**`C_*`** → **`XI_*`** (tier 0) → **`XI_1|*`** (tier 1) → **`XI_2|*`** (tier 2) …  
**`XE_*` / `XB_*`** → **`XI_1|*`** (tier 1) → **`XI_2|*`** … — never call **`XI_2|*`** directly from **`XE_*`** without an **`XI_1|*`** hop.

### Wrong — never do this

```pact
;; WRONG: IMC is not an enforce predicate
(enforce (UEV_IMC) "…")

;; WRONG: validation in XE body
(defun XE_CreateFvtLink …
  (UEV_IMC)
  (with-capability (SCR|XE>CREATE-FVT-LINK …)
    (update …)
    (enforce (= (read …) fvt-id) "persist check")  ;; belongs in cap, not here
  )
)

;; WRONG: validation in C_ body inside with-capability
(with-capability (VCT|C>FULL-…)
  (enforce (URC_… inventory) "…")   ;; move into defcap (pass arrays as cap params if needed)
  (XI_…)
)
```

### Right

```pact
(defun WU_Anchor|State:string (anchor-id:string ank-active:bool)
  (require-capability (SECURE))
  (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
)

(defun XE_CreateFvtLink:string (score-id:string fvt-id:string)
  (UEV_IMC)
  (with-capability (SCR|XE>CREATE-FVT-LINK score-id fvt-id)
    (WU_Score|FvtLink score-id fvt-id)
  )
  fvt-id
)

(defun XI_AddScoreToPool:string (pool-id:string score-id:string slot-index:integer)
  ;; SECURE: granted by WU_Pool|ScoreSlot (underlying W_).
  (WU_Pool|ScoreSlot pool-id slot-index score-id)
  score-id
)
```

## Where validation lives

| Layer | Role |
|-------|------|
| **`defcap`** | **All** `enforce`, `UEV_*`, `CAP_*` ownership checks, boolean folds |
| **`UEV_*`** | Reusable validation **called from defcap** (may `enforce` internally) |
| **`URC_*` / `URDC_*`** | Boolean reads / scans — prefer **no `enforce`**; return bool or data |
| **`WI_*` / `WU_*` / `WW_*`** | **No `enforce`** — **SECURE** + one persistence op as **final** expression (**AQP**, never cross-module) |
| **`XI_*` / `XE_*` / `XB_*` / `C_*` / `A_*`** | **No `enforce`** — documented guard (`SECURE` / `IMC` / cap) + **`W_*`** / orchestration |

`defcap` body order: **`let`** → **`UEV_*` / `CAP_*`** → one boolean **`enforce`** → **`compose-capability`**. See **`defcap-body-order.md`**.

## Dynamic validation (inventory arrays, slot index)

When validation needs runtime data computed before the tx body:

1. Compute in **`C_*`** `let` **before** `with-capability`.
2. **Pass values into the defcap** as extra parameters.
3. Run **`URC_*` / `UEV_*`** checks **inside the defcap**.

Example: `VCT|C>FULL-TRUE-FUNGIBLE-VACATE` takes `owner-ids`, `beneficiary-ids`, `amounts` and calls `URC_VacateFullTfLegArraysOk` in the cap — not in `C_FullVacateTrueFungible` body.

## `XB_*` vs `XE_*`

- **`XB_*`**: home-module shared write; `(UEV_IMC)` then bare `update` (no second SECURE).
- **`XE_*`**: forward module write; `(UEV_IMC)` then `with-capability (HOME|XE>…)` or `P|SECURE-CALLER` for phased legs.

Home **`C_*`** composes owner/event caps → calls **`XB_*`** or **`XI_*`**.

## Related

- `OuronetInformational/ouronet/conventions/w-writes.md`
- `OuronetInformational/ouronet/conventions/xb-imc-cross-module.md`
- `OuronetInformational/modules/aqp/score-links.md`
- `OuronetInformational/modules/aqp/recipe-cap-validation.md`
