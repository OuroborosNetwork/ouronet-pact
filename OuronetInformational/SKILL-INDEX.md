# SKILL-INDEX — every piece of Ouronet guidance

> **GENERATED** by `REPL/tools/_skillindex.py`. Do not edit — add the document, then run
> `python3 REPL/tools/_skillindex.py --write`. `--check` is fatal inside `_gate.py`, so a
> new guidance file cannot stay uncatalogued.
>
> **Why this is generated.** Exactly one file loads automatically in this repo: `CLAUDE.md`.
> A hand-maintained list of what to read stops being complete the first time someone forgets
> a line, and the symptom is not an error — it is an agent that never learns the rule. On
> 2026-10-25 only 79 of 217 files here were reachable from `CLAUDE.md`, and the unreachable
> set included the canonical testing standard and the `INFO_` construction procedure.
>
> Dated captures (`memories/`, `HANDOFFS/`, `kursan/`, `agents/`) are **records, not rules**,
> and are excluded by directory. Generated artefacts are excluded so nobody edits them.

**75 guidance documents.** Read [`SKILL.md`](SKILL.md) first — it gives the ORDER.
This page gives the COVERAGE.

## Start here

*the hub, the canon, the vocabulary*

| document | what it is for |
|---|---|
| [`01-mnemosyne-codex-pact-module.md`](01-mnemosyne-codex-pact-module.md) | Design note for the Mnemosyne cloud codex-management service and its Apollo identity pairing. |
| [`A5-RENAME-PROPOSAL.md`](A5-RENAME-PROPOSAL.md) | Unadopted proposal to rename functions lacking a canon prefix. |
| [`CONTEXT.md`](CONTEXT.md) | Consolidated project facts, vocabulary and stage definitions — read early for shared language. |
| [`DEPLOY-READY-GATE.md`](DEPLOY-READY-GATE.md) ⛔ **superseded** | Historical roadmap-1.7 deploy-readiness proof; its source-line gas cliff figure is superseded. |
| [`DOCUMENTATION-PLAN.md`](DOCUMENTATION-PLAN.md) ⛔ **superseded** | Superseded plan for the OuronetDocumentation book; its BUILD-PLAN.md is now authoritative. |
| [`HOW-DEPLOY-ROUNDS-WORK.md`](HOW-DEPLOY-ROUNDS-WORK.md) | MANDATORY before building a Deploy/PureVn round: parity model, transitive cascade, backfills, post-deploy sequence. |
| [`INDEX.md`](INDEX.md) | Directory map of the organized guidance tree — which folder answers which kind of question. |
| [`LIVE-INTERFACE-VERSIONS.md`](LIVE-INTERFACE-VERSIONS.md) ⛔ **superseded** | SUPERSEDED historical snapshot of live interface versions — do NOT use to pick a version; poll the chain. |
| [`MODULE-SIZING.md`](MODULE-SIZING.md) | Measured per-module source sizes against StoaChain's 2M block gas limit. |
| [`MODULE_ARCHITECTURE.md`](MODULE_ARCHITECTURE.md) | Prefixes, capability bands, Talos, client flows — read before touching a sovereign core or Talos module. |
| [`POST-AUDIT-MAIN-ROADMAP.md`](POST-AUDIT-MAIN-ROADMAP.md) | Tracker for work queued once the audit worktrees land on main. |
| [`README.md`](README.md) | What this folder is: persistent context for humans and AI; Claude skill route stubs are generated pointers only. |
| [`SKILL.md`](SKILL.md) | THE HUB. Load order, fast-recall non-negotiables, the scan-the-module-first habit, active-learning protocol. |
| [`SPEC-round-simulator.md`](SPEC-round-simulator.md) | What _livesandbox.py --round proves against live chain state — and what it does NOT prove. |
| [`STAGE-TWO-BUCKET-ISSUANCE.md`](STAGE-TWO-BUCKET-ISSUANCE.md) | Stage-2 dispensing-bucket issuance design. |
| [`STAGE-TWO-EMISSION.md`](STAGE-TWO-EMISSION.md) | Stage-2 OURO emission economics and the minter signature it implies. |
| [`StoicSyntax-Prefixes.md`](StoicSyntax-Prefixes.md) | Every prefix decoded left-to-right, plus the patron/executor canon and the archive-mode spec. |
| [`StoicSyntax.md`](StoicSyntax.md) | The naming and structure discipline the whole codebase is written in: prefix = contract. |
| [`UI-INCORPORATION-PLAN.md`](UI-INCORPORATION-PLAN.md) | Plan for wiring the Pact surface into OuronetUI. |
| [`pythia-dirty-read-access.md`](pythia-dirty-read-access.md) | How to keyless dirty-read live chain code and state via describe-module, for comparing repo against chain. |

## Pact language mechanics

*how to write the form correctly*

| document | what it is for |
|---|---|
| [`defcap-body-order.md`](pact/defcap-body-order.md) | The strict order of validation forms inside a defcap body. |
| [`defun-parameter-layout.md`](pact/defun-parameter-layout.md) | How to format the input parameter list on defun, defcap, and defun-style UDC constructors. |
| [`enforce-boolean-grouping.md`](pact/enforce-boolean-grouping.md) | How to combine 1, 2 or 3+ boolean checks into a single enforce with one failure message. |
| [`enforce.md`](pact/enforce.md) | Do not use fold (and) for one or two booleans. Do not use a single-element list in fold when one plain predicate suffices. |
| [`function-body-order.md`](pact/function-body-order.md) | How to order statements inside a defcap, defun (C / A / XI / UEV), and the bindings inside let. |
| [`interface-object-return-rule.md`](pact/interface-object-return-rule.md) | (no description) |
| [`let-binding-layout.md`](pact/let-binding-layout.md) | How to lay out a let that binds module references alongside local variables. |

## Pact 5 language layer

*how Pact ITSELF behaves — source-verified*

| document | what it is for |
|---|---|
| [`BUILTINS.md`](pact5/BUILTINS.md) | Every Pact 5 builtin with its signature and purpose, generated from the local pact-5 source clone — the same pages as docs.kadena.io/reference, versioned with the compiler. |
| [`README.md`](pact5/README.md) | Source-verified knowledge about Pact 5 the language (not the Ouronet discipline — that's |
| [`REFERENCE.md`](pact5/REFERENCE.md) | A Turing-incomplete, human-readable LISP-style smart-contract language for the Kadena blockchain. |
| [`SEMANTICS.md`](pact5/SEMANTICS.md) | Sequence of step/step-with-rollback. Exactly one step per transaction, in order (index must match the stored DefPactExec); can't skip/re-run/nest. Cro… |
| [`STORAGE-PATTERNS.md`](pact5/STORAGE-PATTERNS.md) | When you need "the set of X for key K" (and later must read that set back), there are exactly two |

## Ouronet architecture

*prefixes, capability bands, Talos, the UR/W layers*

| document | what it is for |
|---|---|
| [`MODULE_ARCHITECTURE.md`](ouronet/MODULE_ARCHITECTURE.md) | Authoritative vocabulary for how sovereign modules are structured, named, and wired. Refer to 0Sample/C0s0101ModuleSample.pact for a concrete layout (… |

## Day-to-day conventions

*the rules you apply while editing a module*

| document | what it is for |
|---|---|
| [`index.md`](ouronet/conventions/index.md) | Agent checklist for day-to-day edits. Canonical home: OuronetInformational/ — this file is the map. |
| [`module-load-order-and-pact-refs.md`](ouronet/conventions/module-load-order-and-pact-refs.md) | Pact resolves (ref-X:module{SomeInterface} OtherModule) at module load time. The target module must already be deployed in the REPL (or chain) when th… |
| [`repl-integration-test-layout.md`](ouronet/conventions/repl-integration-test-layout.md) | Use this checklist when adding or restructuring any Ouronet REPL//.repl that runs begin-tx / commit-tx integration steps. Reference implementation: RE… |
| [`schema-field-backfill-on-read.md`](ouronet/conventions/schema-field-backfill-on-read.md) | Audit/module-audits/DALOS/ROUND-02-FIXES.md Fix #25 for the full worked example. |
| [`smart-account-governor.md`](ouronet/conventions/smart-account-governor.md) | (ref-P|VST::P|UR "SWPLC|RemoteSwpGov") ≡ (create-capability-guard (SWPLC.P|SWPLC|REMOTE-GOV)) after P|AAdd. |
| [`uc-urc-urdc-prefixes.md`](ouronet/conventions/uc-urc-urdc-prefixes.md) | Use this when naming unprotected helpers in sovereign modules (especially AQP-ANK / AQP-SCORE / AQP-POOL / AQP-FVT / AQP-VCT). |
| [`ur-and-w-writes.md`](ouronet/conventions/ur-and-w-writes.md) | Which layer may touch a table: UR_ reads vs W_ writes vs XI_ orchestration. |
| [`ur-layout.md`](ouronet/conventions/ur-layout.md) | Where table reads may live, and how UR_ groups are ordered against the schema. |
| [`w-writes.md`](ouronet/conventions/w-writes.md) | How to organise W_ write helpers: one section per deftable, in schema order. |
| [`x-function-guards.md`](ouronet/conventions/x-function-guards.md) | Every XI / XE / XB must document how it is protected: either an explicit guard in the body, or a ;; SECURE: / ;; IMC: comment stating why a repeat gua… |
| [`x-writes-no-cumulator.md`](ouronet/conventions/x-writes-no-cumulator.md) | X functions: writes only (no OutputCumulator) |
| [`xb-imc-cross-module.md`](ouronet/conventions/xb-imc-cross-module.md) | When a shared table write needs an XB_ entrypoint behind UEV_IMC rather than an XI_. |

## Inventories and specs

*what exists, interface versioning, REPL layout*

| document | what it is for |
|---|---|
| [`00_MASTER_INVENTORY.md`](ouronet/architecture/00_MASTER_INVENTORY.md) | Generated from repository layout scan. Update when files are added or removed. |
| [`CITIZEN_AND_SAMPLES.md`](ouronet/architecture/CITIZEN_AND_SAMPLES.md) | Citizen modules and samples |
| [`DEEP_DIVE_ALL_MODULES.md`](ouronet/architecture/DEEP_DIVE_ALL_MODULES.md) | Module-by-module structural index across the sovereign and citizen trees. |
| [`DEPLOY_IMPACT_PATTERN.md`](ouronet/architecture/DEPLOY_IMPACT_PATTERN.md) | Use this checklist every time new Pact code is added or existing modules are changed, so deploy prep is deterministic. |
| [`INTERFACE_VERSIONING.md`](ouronet/architecture/INTERFACE_VERSIONING.md) ⛔ **superseded** | Interface names use a trailing version marker (V1, V2, V3, …). Each new interface revision advances that suffix by exactly one unit (for example Swapp… |
| [`README.md`](ouronet/architecture/README.md) | This folder is the canonical map of what exists in the repo: modules, interfaces, citizen code, and REPL harnesses. It supports whitepapers, external… |
| [`REFERENCE_URSTOA_VAULT_RPS.md`](ouronet/architecture/REFERENCE_URSTOA_VAULT_RPS.md) | Source: 00StoaSandbox/coin.pact — UR-STOA submodule (~L909), UrStoa Vault submodule (~L1193). Chain 0 only for UR / vault ops. |
| [`REPL_AND_TESTS.md`](ouronet/architecture/REPL_AND_TESTS.md) | REPL files under REPL/ load sovereign modules in order and run scripted transactions. They are not a substitute for on-chain deploy checks; they are a… |
| [`STAGE_01_CODEX_ON_CHAIN_DEPLOY.md`](ouronet/architecture/STAGE_01_CODEX_ON_CHAIN_DEPLOY.md) | Use when deploying Mnemosyne CODEX and related utility/interface fixes. Follows INTERFACEVERSIONING.md and DEPLOYIMPACTPATTERN.md. |
| [`STAGE_01_INTERFACES.md`](ouronet/architecture/STAGE_01_INTERFACES.md) | Interfaces live primarily in 1SOVEREIGN/STAGE01/0Interfaces/. Implementations use implements and typed module{InterfaceVn} refs. |
| [`STAGE_01_MODULES.md`](ouronet/architecture/STAGE_01_MODULES.md) | Deploy order in production follows dependency edges (earlier modules first). Utilities are Stage 1 only; core implements domain logic; Talos exposes o… |
| [`STAGE_02_INTERFACES.md`](ouronet/architecture/STAGE_02_INTERFACES.md) | Primary bundle: 1SOVEREIGN/STAGE02/0Interfaces/02Core.pact (DPDC family). |
| [`STAGE_02_MODULES.md`](ouronet/architecture/STAGE_02_MODULES.md) | Stage 2 adds collectables (DPDC), DemiPad (launchpad ecosystem), AQP (acquisition / earning pools), and INFO-TWO for richer client views. Talos stage-… |
| [`WHITEPAPER_ROADMAP.md`](ouronet/architecture/WHITEPAPER_ROADMAP.md) | This file ties OuronetInformational/ouronet/architecture/ to external-facing docs. |

## AQP

*acquisition pools, scores, FVT, INFO previews*

| document | what it is for |
|---|---|
| [`entrypoint-surface.md`](modules/aqp/entrypoint-surface.md) | Coverage catalogue of every AQP user/admin entrypoint and its preview status. |
| [`info-module-procedure.md`](modules/aqp/info-module-procedure.md) | Step-by-step methodology for building the INFO_ cost-preview counterpart of an entrypoint. |
| [`recipe-cap-validation.md`](modules/aqp/recipe-cap-validation.md) | Each public C_ recipe owns exactly one master capability — how to structure that. |
| [`score-links.md`](modules/aqp/score-links.md) | Follow ouronet-pact-enforce: 1 predicate → plain enforce; 2 → (and p q); 3+ → fold (and) true [...]. |
| [`talos-orchestrator-events.md`](modules/aqp/talos-orchestrator-events.md) | See 1SOVEREIGN/STAGE02/2Core/03AQP/READMESTAKEPHASES.md. |
| [`tft-vault-imc.md`](modules/aqp/tft-vault-imc.md) | A core module holds staked tokens on MODULE|SCNAME (smart DALOS account) and calls TFT::CTransfer from an XI / XE under a component cap (e.g. AQP|XE>T… |

## Stage 1

*DALOS, DPTF, ATS, SWP, CODEX*

| document | what it is for |
|---|---|
| [`codex-repl.md`](modules/stage01/codex-repl.md) | Integration scenario: REPL/Stage01/[6.9]CODEX.repl (Talos TS01-C4 → CODEX A / C). |
| [`pythia-ledger-flush.md`](modules/stage01/pythia-ledger-flush.md) | Khronoton handoff: [HANDOFF-pythia-khronoton-flush.md](../../HANDOFF-pythia-khronoton-flush.md) |

## Deploy

*handoff, ClientInfo pairing*

| document | what it is for |
|---|---|
| [`handoff-checklist.md`](modules/deploy/handoff-checklist.md) | When a feature is build-complete, produce this document for the operator. Cursor skill: OuronetInformational/modules/deploy/handoff.md. |
| [`handoff.md`](modules/deploy/handoff.md) | (no description) |
| [`info-one-clientinfo.md`](modules/deploy/info-one-clientinfo.md) | Workflow for constructing an INFO_ reader and pairing it with OuronetInfoV*.ClientInfo. |

## Test architecture

*the testing standard (stays here — _figuresync.py globs this dir)*

| document | what it is for |
|---|---|
| [`README.md`](ARCHITECTURE/README.md) | Pointer only — the architecture inventories moved to ouronet/architecture/; this dir now holds generated artefacts and the test standard. |
| [`REPL_TEST_ARCHITECTURE.md`](ARCHITECTURE/REPL_TEST_ARCHITECTURE.md) | THE testing standard and best-practice reference for any module written from here on. |

## Pricing

*the single authoritative cost reference*

| document | what it is for |
|---|---|
| [`DECISION-LOG-DETAILED.md`](IGNIS-PRICING/DECISION-LOG-DETAILED.md) | OuronetInformational/IGNIS-PRICING/PRICING-FEEDBACK-RECOVERED.md) revising |
| [`IGNIS-PRICING.md`](IGNIS-PRICING/IGNIS-PRICING.md) | the PLAN, the URCi architecture note, the Hydra design note and the pre-rehaul archive, all of |

## Legacy pointer

*migration table only*

| document | what it is for |
|---|---|
| [`README.md`](skills/README.md) | Migration table only — this folder moved into the organized tree; start at INDEX.md. |
