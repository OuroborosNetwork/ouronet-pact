# UR reads vs W writes vs XI orchestration (Ouronet)

## Rule

| Layer | Table access |
|-------|----------------|
| **`UR_*`** | **`read`** / **`with-default-read`** on domain **`deftable`** rows. **Absent rows** → default via **`with-default-read`** + **`UDC_*`** in the **full-row** `UR_*` (or documented dispatch reader). |
| **`W_*`** (**AQP**) | **`insert` / `update` / `write`** only — module-internal, **`(require-capability (SECURE))`**, persistence op **last**. One **`WI_*` / `WU_*` / `WW_*`** per table/field. See **`w-writes.md`**. |
| **`XI_*` / `XB_*`** | **No** direct table **`read`**. **Read** via **`UR_*`**, compute, call **`W_*`** (not raw persistence in AQP modules). |
| **`URD_*`** only | **`keys`**, **`select`**, full-table scans — never in **`XI_*`**, **`C_*`**, or **`defcap`**. |

At a glance: open **`{F0} [UR]`** — any function using **`with-default-read`** is the “missing row defaults here” surface. **`XI_*`** callers never duplicate that logic.

## XI bump pattern (tracker / rollup) — AQP target

```pact
(let
    (
        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
        ;;
        (key:string (UCK_DPTFTracker pool-id dptf-id owner-id beneficiary-id))
        (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
        (delta:decimal (if direction amount (- amount)))
        (new-bal:decimal (+ bal delta))
    )
    (require-capability (SECURE))
    (WW_DPTFTracker key new-bal pool-id dptf-id owner-id beneficiary-id)
    (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
)
```

Or split: **`XI_*`** holds read-compute + IGNIS; calls **`WW_DPTFTracker`** (which requires **SECURE** internally).

- **`UR_AQP|DPTFTrackerBalance`** → **`with-default-read`** with zero balance default.
- **`XI_*` / `XB_*`**: **No** **`enforce`**, **no** **`UEV_*`** — validation in **`defcap`**.
- First stake / upsert path: **`WW_*`** (not **`insert`/`update` split** in **XI_**).
- **IGNIS tier cumulators** — prefer **`ref-IGNIS::UDC_MediumCumulator`**, **`UDC_BiggestCumulator`**, etc.

## Anti-patterns

- **`with-default-read`** inside **`XI_*`** when a **`UR_*`** already exists for that row.
- Raw **`insert` / `update` / `write`** in **XI_** / **XE_** / **C_** when **`W_*`** exists (**AQP**).
- **`(contains key (keys Table))`** then **`insert` / `update`** — use **`WW_*`** or **`WI_*`** + cap guarantees.
- Cross-module **`ref-MOD::W_*`** — use **`XE_*` / `XB_*`** instead.

**Canonical doc:** `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` — § UR helpers, § W write helpers, § Client flows.

**Cursor skills:** `OuronetInformational/ouronet/conventions/w-writes.md`, `OuronetInformational/ouronet/conventions/ur-layout.md`, `OuronetInformational/ouronet/conventions/index.md`.
