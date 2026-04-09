# Skills (Ouronet)

Place **repeatable procedures** here as small markdown files (e.g. `running-the-repl.md`, `adding-a-stage.md`).

**Cursor Agent Skills** (project `.cursor/skills/`):

- **`ouronet-ur-layout`** — order **`UR_*`** helpers (schema groups, field order, multi-table dispatch). Detail: `OuronetInformational/MODULE_ARCHITECTURE.md`.
- **`ouronet-pact-enforce`** — combine booleans in one **`enforce`**: 1 → plain; 2 → **`(and p q)`**; 3+ → **`fold (and) true [...]`**. Detail: same doc § *Combining boolean checks in one `enforce`*; human note: `skills/pact-enforce-boolean-grouping.md`.
- **`ouronet-aqp-score-links`** — **`AQP-SCORE`** link fields: **`C_`/`XI_`/`SECURE`** vs **`XE_`/`SCR|XE>`** / forward-module split; **`AcquisitionAnchors.UR_AnchorID`**. **`X*`** end on **`update`** only; **`C_`** builds **`UDC_BiggestCumulator`**. Detail: `MODULE_ARCHITECTURE.md` § *AQP-SCORE link fields*; `.cursor/skills/ouronet-aqp-score-links/SKILL.md`.
- **`ouronet-x-writes-ignis`** — **`XI`/`XE`/`XB`**: writes only, **no** **`OutputCumulator`** return; **`C_`** composes IGNIS. Detail: `MODULE_ARCHITECTURE.md` § Client flows; `skills/x-writes-no-cumulator.md`; `.cursor/skills/ouronet-x-writes-ignis/SKILL.md`.
