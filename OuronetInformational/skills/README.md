# Skills (Ouronet)

Place **repeatable procedures** here as small markdown files (e.g. `running-the-repl.md`, `adding-a-stage.md`).

- **`repl-integration-test-layout.md`** — canonical **integration** `.repl` layout (`;;|| NEXT >`, **`TX… · mm ·`** groups + banners, **`map print`** over **`expect`**, file header) plus **semantic tx order** (table dependencies), **`env-data` commas**, Starter key names. Spec: **`../ARCHITECTURE/REPL_AND_TESTS.md`** § *Canonical layout* and § *Stage 1 CODEX* / § *Stage 2 AQP + AQP-BOOT*; examples: **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`**, **`[6.2.2]_AQP-SCORE.repl`**, **`REPL/Stage_01/[6.9]_CODEX.repl`**.

**Cursor Agent Skills** (project `.cursor/skills/`):

- **`ouronet-ur-layout`** — order **`UR_*`** helpers (schema groups, field order, multi-table dispatch). Detail: `OuronetInformational/MODULE_ARCHITECTURE.md`.
- **`ouronet-pact-enforce`** — combine booleans: 1 → plain; 2 → **`(and p q)`**; 3+ → **`fold (and) true [...]`** — applies to **`enforce`**, **`:bool` checks**, and **`defcap`** validation. Detail: same doc § *Combining boolean checks*; **`skills/pact-enforce-boolean-grouping.md`**; `.cursor/skills/ouronet-pact-enforce/SKILL.md`.
- **`ouronet-module-load-order`** — REPL deploy order; **`module{Interface} Other`** refs at load time; core vs Talos **`P|A_Define`**. Detail: **`skills/module-load-order-and-pact-refs.md`**, **`skills/codex-stage01-repl.md`**; `.cursor/skills/ouronet-module-load-order/SKILL.md`.
- **`ouronet-aqp-score-links`** — **`AQP-SCORE`** link fields: **`C_`/`XI_`/`SECURE`** vs **`XE_`/`SCR|XE>`** / forward-module split; **`AcquisitionAnchors.UR_AnchorID`**. **`X*`** end on **`update`** only; **`C_`** builds **`UDC_BiggestCumulator`**. Detail: `MODULE_ARCHITECTURE.md` § *AQP-SCORE link fields*; `.cursor/skills/ouronet-aqp-score-links/SKILL.md`.
- **`ouronet-x-writes-ignis`** — **`XI`/`XE`/`XB`**: writes only, **no** **`OutputCumulator`** return; **`C_`** composes IGNIS. Detail: `MODULE_ARCHITECTURE.md` § Client flows; `skills/x-writes-no-cumulator.md`; `.cursor/skills/ouronet-x-writes-ignis/SKILL.md`.
- **`ouronet-repl-integration-tests`** — integration **`.repl`** layout (`;;|| NEXT >`, **`TX… · mm ·`** groups + banners, **`map print`** over **`expect`**). Detail: **`../ARCHITECTURE/REPL_AND_TESTS.md`**; `skills/repl-integration-test-layout.md`; `.cursor/skills/ouronet-repl-integration-tests/SKILL.md`.
- **`interface-object-return-rule`** — if a function returns `object{Schema}` and that schema is module-local, remove the function from the interface; only keep it in interface if the schema is moved to interface. **CodexV1** example: **`skills/interface-object-return-rule.md`**.
- **`codex-stage01-repl`** — **`[6.9]_CODEX.repl`** placeholders, signers, deploy order. **`skills/codex-stage01-repl.md`**.
- **`ouronet-deploy-handoff`** — when build is done: interfaces + modules to upload + post-deploy setup txs + smoke REPL. **`.cursor/skills/ouronet-deploy-handoff/SKILL.md`**, **`skills/deploy-handoff-checklist.md`**.
- **`module-load-order-and-pact-refs`** — load-time **`module{…}`** refs, **`P|A_Define`** wiring. **`skills/module-load-order-and-pact-refs.md`**.
- **`ouronet-pact-conventions`** — **index** for day-to-day Pact edits: **`let`** ref→`;;`→vars, **`UR_*`** owns **`with-default-read`** / **`XI_*`** uses **`UR_*`+**`write`**, no **`keys`/`select`** outside **`URD_*`**, **`defcap`** body order, smart-account GOV vs RemoteGov. Detail: **`let-binding-layout.md`**, **`ur-with-default-read-and-xi-write.md`**, **`defcap-body-order.md`**, **`smart-account-governor.md`**; `.cursor/skills/ouronet-pact-conventions/SKILL.md`.
- **`let-binding-layout.md`** — **`let`**: all **`ref-*:module{…}`** bindings, then **`;;`**, then variables.
- **`ur-with-default-read-and-xi-write.md`** — absent-row defaults in **`UR_*`** only; **`XI_*`** read via **`UR_*`**, **`write`** only.
- **`defcap-body-order.md`** — **`let`** → outside **`UEV_*`** → boolean **`enforce`** → **`compose-capability`**.
- **`smart-account-governor.md`** — **`MODULE|GOV`** vs RemoteGov; AQP simple vault; **`P|A_Define`** IMP when **`UEV_IMC`** applies.
- **`ouronet-tft-vault-imc`** — TFT vault **`P|A_Define`**, **`MODULE|GOV`** compose (send + receive), Step 0 rotate. `.cursor/skills/ouronet-tft-vault-imc/SKILL.md`.
- **`info-one-clientinfo-pairing`** — **`INFO-ONE+`** `*INFO*` functions return **`OuronetInfoV1.ClientInfo`** via **`OI|UDC_ClientInfo`**; **Ignis/Kadena previews must use the same pricing logic as the paired `C_*`**. Detail: **`skills/info-one-clientinfo-pairing.md`**; `.cursor/skills/ouronet-info-one-clientinfo/SKILL.md`.

## How agents should use this folder

| Location | Role |
|----------|------|
| **`OuronetInformational/`** | Canonical long-form notes, architecture, **`skills/*.md`** procedures |
| **`.cursor/skills/ouronet-*/SKILL.md`** | Short agent-facing skills (YAML **`description`** → auto-suggested in Cursor) |

**Referencing `OuronetInformational` in chat** does not inject the folder automatically — read **`CONTEXT.md`**, **`MODULE_ARCHITECTURE.md`**, and the relevant **`skills/*.md`**. For Pact edits, start with **`.cursor/skills/ouronet-pact-conventions/SKILL.md`**.
