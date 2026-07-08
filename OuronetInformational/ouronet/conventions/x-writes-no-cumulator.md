# `X*` functions: writes only (no `OutputCumulator`)

**`XI_*`**, **`XE_*`**, **`XB_*`** perform persistence only: body ends on **`insert` / `update` / `write`** — **no** trailing **`true`**, **no** **`object{IgnisCollectorV1.OutputCumulator}`**.

**`C_*`** (or a forward orchestrator for **`XE_*`**) builds **IGNIS** cumulators after capability-gated writes.

**Cursor skill:** `OuronetInformational/ouronet/conventions/x-writes-no-cumulator.md`  
**Architecture:** `OuronetInformational/ouronet/MODULE_ARCHITECTURE.md` (Client flows).
