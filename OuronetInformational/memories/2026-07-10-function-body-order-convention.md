# Function / capability body order (2026-07-10)

Canonical doc: **`OuronetInformational/pact/function-body-order.md`**.

User requested explicit ordering inside **`defcap`** / **`defun`** bodies across all five AQP modules (`01_ANK` … `05_VCT`):

1. Pact natives (`enforce`, `fold`, …)
2. **`ref-MODULE::`** (deployed dependencies)
3. Home module (`UR_*`, `XI_*`, `UEV_*`, `W_*`, …)
4. Capabilities (`with-capability`, `compose-capability`, `require-capability`)

**`let` bindings:** all **`ref-*:module{…}`** first → **`;;`** → locals (`let-binding-layout.md`).

**Note:** Non-boolean **`ref-*::UEV_*`** / **`CAP_*`** validators typically run **before** grouped boolean **`enforce`** (see **`SCR|XI>ISSUE-SCORE`**). Inside **`with-capability`**, prefer **`ref-*::XE_*`** before home **`XI_*`** (see **`FVT|C_AddScoreLink`**).

Full module-wide reorder pass is incremental — apply when touching a function; do not churn unrelated formatting.
