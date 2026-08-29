# OuronetInformational — canonical knowledge base

**All** architecture, conventions, and agent learning for this repo live here — not only in `.cursor/skills/`. Cursor skills are thin pointers into this tree so nothing is lost when changing machines.

## Start here

0. **`SKILL.md`** — the **single entry point / load hook**. Read it first: it gives the load order, the fast-recall rules, the "scan the module before editing" habit, and the active-learning protocol. Agents (Cursor, Claudstermind Pact chat, Claude Code) should always begin here.
1. **`StoicSyntax.md`** — Ouronet’s Pact **discipline** (human-auditable large code + multi-module composition); offered for any Pact builder
2. **`CONTEXT.md`** — vocabulary, stages, stable facts
3. **`ouronet/MODULE_ARCHITECTURE.md`** — prefixes, caps, Talos, UR/W layers (Ouronet detail behind StoicSyntax)
4. **`ouronet/architecture/README.md`** — module inventory, REPL map, deploy docs

## Layout

| Path | Contents |
|------|----------|
| **`pact/`** | Pact language mechanics (enforce grouping, defcap order, `let` layout, `defun` params, interfaces) |
| **`pact5/`** | Pact 5 **language** layer — source-verified semantics + builtin/type reference (from `kda-community/pact-5`) |
| **`ouronet/`** | Platform architecture + cross-module conventions |
| **`ouronet/conventions/`** | Day-to-day rules: UR layout, W writes, X guards, IMC, REPL layout, … |
| **`ouronet/architecture/`** | Inventories, REPL spec, deploy patterns, stage module lists |
| **`modules/`** | Domain-specific: **`aqp/`**, **`stage01/`**, **`deploy/`** |
| **`kursan/`** | Agent persona + scratch REPL policy |
| **`memories/`** | Dated conversation captures |

## Convention index (read before editing Pact)

| Topic | File |
|-------|------|
| **Index / checklist** | `ouronet/conventions/index.md` |
| **UR layout** | `ouronet/conventions/ur-layout.md` |
| **UR + W + XI** | `ouronet/conventions/ur-and-w-writes.md` |
| **Schema-field backfill hidden in a `UR_*` read (anti-pattern + retirement)** | `ouronet/conventions/schema-field-backfill-on-read.md` |
| **W writes (WI/WU/WW)** | `ouronet/conventions/w-writes.md` |
| **X guards + caps** | `ouronet/conventions/x-function-guards.md` |
| **XB + IMC** | `ouronet/conventions/xb-imc-cross-module.md` |
| **Boolean enforce** | `pact/enforce-boolean-grouping.md`, `pact/enforce.md` |
| **defcap body order** | `pact/defcap-body-order.md` |
| **Function / cap body order** | `pact/function-body-order.md` |
| **`defun` / `defcap` parameters** | `pact/defun-parameter-layout.md` |
| **UC / URC / URDC** | `ouronet/conventions/uc-urc-urdc-prefixes.md` |
| **Module load order** | `ouronet/conventions/module-load-order-and-pact-refs.md` |
| **Integration REPLs** | `ouronet/conventions/repl-integration-test-layout.md` |

## AQP modules

| Topic | File |
|-------|------|
| **Global architecture + Vacate chapter** | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README_GLOBAL.md` |
| **Talos C_* catalogue** | `…/03_AQP/README_TALOS_CATALOGUE.md` |
| **How-to Farm/Vault/Treasury** | `…/03_AQP/README_HOWTO_FVT.md` |
| Hub + module READMEs | `…/03_AQP/README.md` |
| Score links XI/XE | `modules/aqp/score-links.md` |
| Recipe cap validation | `modules/aqp/recipe-cap-validation.md` |
| TFT vault IMC | `modules/aqp/tft-vault-imc.md` |
| Talos stake phases | `modules/aqp/talos-orchestrator-events.md` |

## Kursan (agent scratch REPLs)

Experimental probes and one-off tests: **`REPL/Kursan/`**. See **`kursan/README.md`**. Do **not** put canonical integration suites there.

## Handoffs (feature specs)

| Topic | File |
|-------|------|
| Pyth ledger (Pact tables + reads) | `HANDOFF-pact-pyth-ledger.md` |
| Khronoton flush service (calendar day + :58 schedule) | `HANDOFF-pythia-khronoton-flush.md` |
| PYTHIA dual-Apollo keys | `HANDOFF-pythia-dual-apollo.md` |
| PYTHIA ledger flush implementation | `modules/stage01/pythia-ledger-flush.md` |

## Maintenance rule

When you learn something durable about Pact or Ouronet, **write it here first**. Update `.cursor/skills/ouronet-*/SKILL.md` only if the YAML `description` needs to change for Cursor discovery — body should point to this tree.
