# UR reads vs XI writes (Ouronet)

## Rule

| Layer | Table access |
|-------|----------------|
| **`UR_*`** | **`read`** / **`with-default-read`** on domain **`deftable`** rows. **Absent rows** → default via **`with-default-read`** + **`UDC_*`** in the **full-row** `UR_*` (or documented dispatch reader). |
| **`XI_*` / `XB_*`** | **No** direct **`read`**, **`with-default-read`**, **`keys`**, or **`select`** on domain tables. **Read** prior state through **`UR_*`**, compute new value, **`write`** (or **`update`** / **`insert`** when the path always creates a new key). |
| **`URD_*`** only | **`keys`**, **`select`**, full-table scans — never in **`XI_*`**, **`C_*`**, or **`defcap`**. |

At a glance: open **`{F0} [UR]`** — any function using **`with-default-read`** is the “missing row defaults here” surface. **`XI_*`** callers never duplicate that logic.

## XI bump pattern (tracker / rollup)

```pact
(let
    (
        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
        ;;
        (key:string (UC_DPTFTrackerKey pool-id dptf-id owner-id beneficiary-id))
        (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
        (delta:decimal (if direction amount (- amount)))
        (new-bal:decimal (+ bal delta))
    )
    (write AQP|T|DPTFTracker key
        (UDC_AQP|TrueFungibleTracker new-bal pool-id dptf-id owner-id beneficiary-id)
    )
    (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
)
```

- **`UR_AQP|DPTFTrackerBalance`** → delegates to **`UR_AQP|DPTFTracker`** → **`with-default-read`** with zero balance default.
- **`XI_*` / `XB_*`**: **No** **`enforce`**, **no** **`UEV_*`** — validation belongs in the **`defcap`** that composes **`SECURE`**. Read via **`UR_*`**, compute, **`write`**.
- First stake: **`write`** creates the row (no **`insert`** / **`update`** split, no **`contains key (keys …)`**).
- **IGNIS tier cumulators** — prefer **`ref-IGNIS::UDC_MediumCumulator`**, **`UDC_BiggestCumulator`**, etc. over inline **`UDC_ConstructOutputCumulator`** in **`XI_*`** (active account = vault / module **`SC_NAME`**).

Reference: **`03_AQP.pact`** — **`XI_WriteDptfTracker`**, **`XI_BumpBeneficiaryDptfTotal`**.

## Anti-patterns

- **`with-default-read`** inside **`XI_*`** when a **`UR_*`** already exists for that row.
- **`(contains key (keys Table))`** then **`insert`** / **`update`** in **`XI_*`** — use **`UR_*` + `write`**.
- **`UR_AQP|DPTFTrackerBalance`** calling **`with-default-read`** again at the field level — field readers delegate to full-row **`UR_*`**.

**Canonical doc:** `OuronetInformational/MODULE_ARCHITECTURE.md` — § UR helpers, § Client flows.

**Cursor skills:** `.cursor/skills/ouronet-ur-layout/SKILL.md`, `.cursor/skills/ouronet-pact-conventions/SKILL.md`.
