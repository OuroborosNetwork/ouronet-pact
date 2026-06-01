## Interface object-return rule

When an interface function returns `object{...}` where that schema is defined inside the implementing module, deployment order becomes a problem (interface is loaded before module schemas exist).

Use one of two patterns:

1. Remove those functions from the interface.
2. Move the schema definition to the interface, then keep the function in the interface.

Current Ouronet convention:

- Keep schemas in the module.
- Remove from interfaces any function that returns an object typed by a module-local schema.

Applied for **AQP-ANK**, **AQP-SCORE**, and **CodexV1**.

### CodexV1 example (`22_CODEX.pact`)

**Removed from interface** (schema lives in module only):

- `UR_CIX|Data:object{CODEX|S|Identity}`
- `UR_AWT|Data:object{CODEX|S|ArweaveTracker}`
- `UR_STG|Data:object{CODEX|S|StoicTag}`
- `UR_STBA|Data:object{CODEX|S|StoicTagByAccount}`

**Kept in interface:**

- Per-field **`UR_*`** accessors (scalar return types)
- **`UR_*|DataOrNull:object`** (untyped **`object`**, no schema ref)
- **`UR_AWT|ListByCodex:[object]`**, **`URC_AWT|LatestUpload:object`**

External callers use **`module{CodexV1}`** for accessors / **`DataOrNull`**. Full typed row reads stay on the **CODEX** module implementation.

**Cursor skill:** `.cursor/skills/ouronet-pact-enforce/SKILL.md` is unrelated; interface work has no dedicated Cursor skill yet — use this file.
