# Ouronet Pact conventions (index)

Agent checklist for day-to-day edits. **Canonical home:** `OuronetInformational/` — this file is the map.

## Quick rules

| Topic | Rule |
|-------|------|
| **FUNCTIONS order** | **UC_** → **UCK_** → **UR_** → **UDC_** → **W_** → **URD_** → **URC_** → **URDC_** → **UEV_** → **C_** / **A_** → **X** (AQP). See **`../MODULE_ARCHITECTURE.md`** § FUNCTIONS block order. |
| **Body statement order** | Inside **`let`** / **`defcap`** / **`C_*`**: natives → **`ref-*`** → home → caps. → **`../../pact/function-body-order.md`** |
| **Utility naming** | Prefix only inside the module (**`UC_Foo`**, not **`UC_VCT\|Foo`**). Caps/schemas may use **`MODULE\|…`**. |
| **UC / URC / URDC** | **UC_** = args only. **URC_** = **UR_** reads, no **URD_**. **URDC_** = calls **URD_**. → **`uc-urc-urdc-prefixes.md`** |
| **`let` bindings** | All **`ref-*:module{…}`** first → **`;;`** → variables. → **`../../pact/let-binding-layout.md`** |
| **Body statement order** | After **`let`**: natives → **`ref-*`** → home → caps. → **`../../pact/function-body-order.md`** |
| **`defun` / `defcap` params** | One line when it fits; else name on line 1, one param per line in `(...)`. → **`../../pact/defun-parameter-layout.md`** |
| **Reads** | Domain **`read`** / **`with-default-read`** only in **`UR_*`**. → **`ur-layout.md`**, **`ur-and-w-writes.md`** |
| **Writes (AQP)** | **`WI_` / `WU_` / `WW_`** under **SECURE**; persistence op **last**; **`&`** multi-field names. → **`w-writes.md`** |
| **Scans** | **`keys`**, **`select`** only in **`URD_*`**. |
| **`defcap` body** | **`let`** → **`enforce`** / **`enforce-guard`** → **`ref-*::UEV_*`** → **`compose-capability`**. → **`../../pact/defcap-body-order.md`** |
| **Booleans** | 1 plain; 2 **`and`**; 3+ **`fold (and)`**. → **`../../pact/enforce-boolean-grouping.md`** |
| **Smart vault** | **`MODULE\|GOV`**, **`P\|A_Define`**. → **`smart-account-governor.md`**, **`../../modules/aqp/tft-vault-imc.md`** |
| **XB + IMC** | → **`xb-imc-cross-module.md`** |
| **X guards** | → **`x-function-guards.md`** |
| **Batch cap validation** | **Single `UEV_*` fold in cap**; no `(keys …)` in validation. → **`../../modules/stage01/pythia-ledger-flush.md`** |

## Hub

- **`../MODULE_ARCHITECTURE.md`**
- **`../../CONTEXT.md`**
- **`../../INDEX.md`**

## Workflow

1. Read **`CONTEXT.md`** + **`MODULE_ARCHITECTURE.md`** if unfamiliar.
2. Open the matching file from the table above.
3. For AQP domain flows, also **`../../modules/aqp/`**.
