
# W writes (WI_ / WU_ / WW_)

**Scope:** **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`** (`01_ANK` … `05_VCT`). Legacy modules keep existing patterns until explicitly migrated.

## Role

| Prefix | Pact op | When | Payload |
|--------|---------|------|---------|
| **WI_** | `insert` | Row must **not** exist | Full row via **UDC_** |
| **WU_** | `update` | Row **must** exist | One non-key field |
| **WU2_** / **WU3_** … | `update` | Row exists | Multiple fields (per need) |
| **WW_** | `write` | Upsert (absent or present) | Full row via **UDC_** (per need) |

**No row delete in Pact** — deactivate via **WU_** on liveness / flag fields.

## W block layout (per table)

One **`[W]`** section per **`deftable`**, in **schema / table order**. Within each table block, sub-order is fixed:

```
WI_*   →   WW_*   →   WU_* (every field)   →   WU2_* / WU3_* …
```

| Sub-block | Rule |
|-----------|------|
| **WI_** | **`defun`** when create-only path exists; else comment: `;; WI_Table — not used: …` |
| **WW_** | **`defun`** when upsert path exists; else comment: `;; WW_Table — not used: …` |
| **WU_** | **One line per schema field** (schema key order, matching **UR_** suffix names). **`defun`** when that field is updated alone; else comment: |
| | `not mutable [.]` — fixed at issue (schema **`[.]`**) |
| | `select key; WU not needed` — row key column |
| | `not used: mutates via WW_Table (full row)` — **`[M]`** field touched only through **`WW_*`** |
| **WU2_+** | Multi-field updates when needed; **omit entirely** when not needed (no placeholder comment) |

**Example** (ANK|T|Anchor — abbreviated):

```pact
;; [1] ANK|T|Anchor  (ANK|Schema)  Key = <Anchor-ID>
(defun WI_Anchor:string …)
;; WW_Anchor — not used: issue path is WI_Anchor; revoke uses WU_Anchor|State.
;; WU_Anchor|AnchoredAsset — not mutable [.]
;; WU_Anchor|Fungibility — not mutable [.]
(defun WU_Anchor|State:string …)
;; WU_Anchor|Promile — not mutable [.]
;; WU_Anchor|ID — select key; WU not needed.
```

**WU suffix** = same expanded name as paired **`UR_*`** (e.g. **`UR_ANK|State`** → **`WU_Anchor|State`**), not raw schema strings.

## Visibility and guards

- **W_** functions exist **only inside their home module** — **never** on interfaces, **never** called cross-module.
- Every **W_** body: **`(require-capability (SECURE))`**, then exactly one **`insert` / `update` / `write`** as the **last** expression — nothing after the persistence op. **No `enforce`**, **no `UEV_*`**.
- **External** persistence: **`XE_*`** / **`XB_*`** → **`UEV_IMC`** + named cap (composing **SECURE**) → **W_**.
- **C_** / **A_** may call **W_** directly when no orchestration is needed.
- **XI_** when **UR_** read-compute + one or more **W_** calls (or IGNIS tier choice) is required.

```pact
;; W_ — persistence op is the final expression
(defun WU_Anchor|State:string
  (anchor-id:string ank-active:bool)
  (require-capability (SECURE))
  (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
)

(defun WW_Anchors:string
  (account:string anchor-id:string promile:decimal)
  (require-capability (SECURE))
  (write ANK|T|Anchors (UCK_Anchors account anchor-id)
    (UDC_AccountAnchor promile account anchor-id)
  )
)

;; XI orchestration — return values live here, not in W_
(defun XI_BumpTracker …
  (require-capability (SECURE))
  (let ((new-bal … (UR_… (+ bal delta))))
    (WW_DPTFTracker key new-bal …)
  )
  key
)

## UCK_ — table keys

- **`UCK_*`** = pure key constructors (args only, no table read).
- Migrate legacy **`UC_*Key`** → **`UCK_*`** when touching AQP modules.
- **WI_** / **WU_** / **WW_** take key **components** as args; body calls **`(UCK_…)`** internally.

## Naming

**Table short name** = last segment of **`deftable`** after **`T|`**:

| `deftable` | Short name |
|------------|------------|
| `ANK|T|Anchor` | `Anchor` |
| `ANK|T|UserBoost` | `UserBoost` |
| `FVT|T|RPS|Global` | `RpsGlobal` (document per module) |

**W layer drops module prefix** (module-internal): **`WU_Anchor|State`**, not **`WU_ANK|Anchor|State`**.

### Single-field WU — mirror UR suffix

| `UR_ANK|State` | `WU_Anchor|State` |
| `UR_ANK|Promile` | `WU_Anchor|Promile` |

Use the **same expanded suffix** as the paired **`UR_*`**, not raw schema strings (`State` not `ank-active`).

### Multi-field WU — `WU{N}_` prefix = field count

```
WU_Anchor|State                         ;; one field
WU2_Anchor|State&Promile                ;; two fields (or WU2_Anchor|Control when a domain name fits)
WU4_Pool|VacateJobState                 ;; four vacate fields
WU7_Pool|ScoreSlots                     ;; seven score-slot fields
```

- **`|`** separates table short name from field name(s).
- **`WU{N}_`** prefix = **N** columns updated in one `update` (not a generic “multi-field” bucket).
- Suffix: prefer a **single aggregate name** when the fields form one concept (`VacateJobState`, `ScoreSlots`, `Control`, `VaultTotals`). Use **`&`**-joined field suffixes only when no short aggregate name exists.
- **`&`** is valid in Pact 5.4 identifiers when listing fields.

**Grep note:** escape `&` or use fixed-string search.

### Full-row writers

```
WI_Anchor      ;; insert full row (issue paths)
WW_DPTFTracker ;; write upsert full row (tracker paths)
```

### WI not used — comment placeholder

When a table’s first touch is **WW_** only (no create-only path):

```pact
;; WI_Anchor — not used: first row touch is WW_Anchor (upsert path).
```

No empty **`defun`**.

## FUNCTIONS block order (AQP)

```
UC_  →  UCK_  →  UR_  →  UDC_  →  WI_ / WU_ / WW_  →  URD_  →  URC_  →  URDC_  →  UEV_  →  C_ / A_  →  XI_ / XE_ / XB_
```

Group **W_** blocks in **schema / deftable order**. Within each block: **WI → WW → WU (all fields) → WU2+**. Field order in **WU** matches **defschema** / **UR_**.

## Defaults per table

1. One **W block** per **`deftable`** (schema order): **WI** → **WW** → **WU** (all fields) → **WU2+** (only when needed).
2. **`WI_*`** / **`WW_*`**: **`defun`** or not-used comment at that slot.
3. **`WU_*`**: one entry per schema field — **`defun`** or comment (`not mutable [.]`, `select key`, `mutates via WW_*`).
4. **`WU2_+`**: **`defun`** only when a real path needs them; **no** placeholder when absent.

## Anti-patterns

- Raw **`insert` / `update` / `write`** in **XI_** / **XE_** / **XB_** / **C_** when a **W_** exists for that site.
- Code **after** **`insert` / `update` / `write`** in a **W_** body (e.g. returning a key arg) — persistence must be the **last** expression; callers that need a return value compute it in **XI_** / **C_** / **XE_**.
- **`enforce`** or post-write persist checks in **W_** or **XI_** bodies.
- Cross-module **`ref-MOD::WI_…`** or **`ref-MOD::WU_…`**.
- Unused **WI_** stub **`defun`** — use comment only.

## Related

- **`OuronetInformational/ouronet/MODULE_ARCHITECTURE.md`** — § W write helpers
- **`OuronetInformational/ouronet/conventions/ur-and-w-writes.md`**
- **`OuronetInformational/ouronet/conventions/x-function-guards.md`**
- **`OuronetInformational/ouronet/conventions/ur-layout.md`**
