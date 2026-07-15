# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

**Ouronet** is a virtual blockchain implemented entirely in **Pact** (Kadena's smart-contract language), deployed on **StoaChain** under the namespace **`ouronet-ns`** (migrated from legacy `free`). It defines its own token architecture (true fungibles, ortofungibles, collectables) and DeFi primitives (ATS autostake pools, SWP liquidity pools, AQP acquisition pools, DemiPad launchpad). Development is **REPL-first**: iteration happens through staged `.repl` harnesses before any on-chain deploy.

Authoritative docs live under `OuronetInformational/`:
- `CONTEXT.md` — consolidated project facts and vocabulary.
- `MODULE_ARCHITECTURE.md` — prefixes, capability bands, Talos, client flows. Read before touching any sovereign core or Talos module.
- `ARCHITECTURE/README.md` + `ARCHITECTURE/*` — inventory, interface versioning, REPL layout spec, module deep dive.
- `skills/` — repeatable procedures (enforce grouping, UR layout, REPL test layout, etc.).
- `memories/` — dated conversation captures and decisions.

## Running the REPL pipeline

The canonical entry points live under `REPL/` and are loaded from that working directory:

```bash
cd REPL && pact Z.repl                # Full pipeline: Stage 00 sandboxes → 00a Stoa coin tests → Stage 01 → Stage 02 (Stage ZZ commented)
cd REPL && pact Stage01_Tester.repl   # Stage 1 only (deploy + scenario 6.1–6.8)
cd REPL && pact Stage02_Tester.repl   # Stage 2 only (DPDC, DemiPad, AQP, Talos, scenarios)
cd REPL && pact Stage00_Sanboxes.repl # Kadena + Stoa sandbox bootstrap
cd REPL && pact Stage00a_StoaTests.repl # Stoa coin regression tests
cd REPL && pact StageZZ_Tester.repl   # Deploy 2_SLAVE/Stage_Z/01_DPL-UR.pact only
```

Individual scenario REPLs live in `REPL/Stage_01/[*].repl` and `REPL/Stage_02/[*].repl`. The reference hand-maintained integration suites are `REPL/Stage_02/[6.2.1]_AQP-ANK.repl` and `REPL/Stage_02/[6.2.2]_AQP-SCORE.repl` — mirror these when writing new integration tests.

Stage 1 has two DPTF/SWP paths — pick **one** in `Stage01_Tester.repl`: full suites (`[6.2]_DPTF.repl` + `[6.3]_SWP.repl`) or issuance-only (`[6.2+3]_DPTF-SWP_Issuance-Only.repl`, faster, used when prepping for Stage 2).

### REPL maintenance scripts

Run from repo root (they skip the two reference AQP REPLs):

```bash
python3 REPL/_normalize_repl_layout.py   # Preamble + ;;|| NEXT > between commit-tx/begin-tx + subdivision
python3 REPL/_subdivide_repl.py          # Only the mm-banner insertion inside each begin-tx
```

## Repository layout

| Path | Role |
|------|------|
| `1_SOVEREIGN/STAGE_01/` | `0_Interfaces/`, `1_Utilities/` (`U_*` — 13 files), `2_Core/` (DALOS, DPMF, IGNIS, DPTF, DPOF, ATS, VST, SWP family, …), `3_Talos/` (TS01-A/C1/C2/C3/P) |
| `1_SOVEREIGN/STAGE_02/` | `0_Interfaces/`, `2_Core/01_DPDC/` (DPDC family), `2_Core/02_DEMIPAD/` (DEMIPAD, Spark, Snakes, Custodians, StoicPay, STOAICO), `2_Core/03_AQP/` (AQP, AQP-ANK, AQP-SCORE, FVT), `3_Talos/` (TS02-C1/C2/DPAD/C3) |
| `2_SLAVE/` | Third-party modules consuming sovereign APIs: `Stage_01/` (AOZ+, Dispenser+), `Stage_02/` (Nosferatu, KBunnies, Bloodshed), `Stage_Z/01_DPL-UR.pact` |
| `0_Sample/` | Module layout samples (`ModuleSample.pact`) |
| `0_Stoa/genesis/` | Historical Stoa genesis tx / JSON payloads (`stoa-genesis-1` … `5`) — ordering reference for the Stoa sandbox |
| `00_KadenaSandbox/` | Kadena-like sandbox; note `coin` is renamed to `kadena-coin` here so `coin` stays free for Stoa |
| `00_StoaSandbox/` | Stoa-like sandbox: root `ns`, `coin`, `util`, `stoa-ns` interfaces/modules (phased `init-phase-*.repl`) |
| `REPL/` | Staged loaders and scenario files |
| `OuronetInformational/` | Persistent context for humans and AI — **read before editing sovereign modules** |

## High-level architecture

### Sovereign vs slave

- **Sovereign** (`1_SOVEREIGN/`) — canonical Ouronet modules maintained by the project. Contain the business logic and the capability gates.
- **Slave** (`2_SLAVE/`) — extension modules anyone can write. They call **only** into sovereign public APIs; they do not add capabilities to the core surface.

### Layer cake: Utilities → Core → Talos

- **Utilities** (Stage 1 only) — small pure helpers (`U_CT`, `U_G`, `U_LST`, …).
- **Core** — main business logic (DALOS, TFT, VST, DPDC, DemiPad, AQP, …). Each core module starts with **policy tables** (shared guard structures used for inter-module authorization) before bulk logic.
- **Talos** — orchestration entrypoints. **The only supported client path.** Talos sequences compose `A_` / `C_` across core modules into curated flows. The **Ouronet gas station** pays execution **only** for paths defined in Talos, and Talos is the only place that collects **IGNIS** (virtual-chain gas) after a `C_`. Any new `A_` / `C_` / protected `X*` on a core module must be wired into the appropriate Talos module to finalize it for client and gas semantics. `C_` is blocked from being invoked inside its own module by design.

### Deployment order and interface versioning

Kadena's ~150k deploy size cap forces strict deploy ordering: a module may only call into modules already deployed. Consequences:

- Cross-module calls use **module references** with `::` (e.g. `(ref-M::some-fun ...)`), not `module.function`, so only the used interface members matter for coupling.
- Interfaces (`V1`, `V2`, `V3`, …) carry nearly the full public API. Interface names always end in a version suffix; each revision advances the suffix by **exactly one**.
- **Cascade rule**: when interface B → B′, every interface A that names B (via `module{B}` or `object{B.Schema}`) must bump to A′ with the new reference, and every consumer updates in lockstep. Implementing modules `implements` only the **latest** version. Details: `OuronetInformational/ARCHITECTURE/INTERFACE_VERSIONING.md`.
- **Policy**: new/active work stays on `V1` until first mainnet deployment. Bump to `V2` only after live deployment if post-deploy adjustments force a versioned move. Until then `V1` code is edited freely.
- **Same-interface object types**: inside an interface, write `object{PoolTokens}` (unqualified) for schemas defined in that same interface; use `object{OtherInterface.Schema}` only for row shapes owned by a different interface.
- **Interface object-return rule**: if a function would return `object{Schema}` where `Schema` is defined in the implementing module (not the interface), **remove it from the interface** — interface loads before module schemas exist. Ouronet convention is to keep schemas in modules, so such functions stay module-only (applied for `AQP-ANK`, `AQP-SCORE`).

### Canonical module section order

1. Schemas, tables, constants (labeled `{1}`, `{2}`, `{3}` blocks in sources).
2. Capabilities grouped by band:
   - **C1** — trivial / "always true" roots.
   - **C2** — simple, no composition.
   - **C3** — ownership patterns.
   - **C4** — composite (`compose-capability`).
3. Functions. Under FUNCTIONS, **true `UC_*` compute helpers come first**.

Reference: `0_Sample/C0s__01_01_ModuleSample.pact`.

### Function prefix system

Unprotected (callable without caps — safe by construction):

| Prefix | Meaning |
|--------|---------|
| `UC_*` | Pure compute on arguments only — **no table reads, no `enforce`**. First under FUNCTIONS. |
| `UR_*` | Table reads. **No raw `read` on domain tables outside `UR_*`.** Per-field `UR_*` take table keys, not row objects. |
| `URC_*` | Read + derive. **No `enforce`** (validation lives in `UEV_*` / defcap). May call `UR` / `UC` / other `URC`. |
| `UEV_*` | Read + `enforce`. Failure aborts the tx. Unprotected. |
| `UDC_*` | Data construction — named constructors for objects; prefer over ad-hoc `object{}` literals. |
| `CAP_*` | Ouronet account-ownership enforcement (UEV-like but specifically tied to account ownership). |

Protected (locked inside their module — **not** the public integrator surface):

| Prefix | Meaning |
|--------|---------|
| `A_*` | Admin-key mutations. |
| `C_*` | Client entry for slave modules. Builds IGNIS cumulators and returns `OutputCumulator`. **Cannot be invoked from its own module** — clients reach it via Talos. |
| `XI_*` | Internal-only protected (this module). |
| `XE_*` | For external modules only (forward-module entrypoints). |
| `XB_*` | Both internal and external. |

### Client flow shape (`C_` / defcap / `XI`/`XE`/`XB`)

This is the intended decomposition — deviations should be deliberate.

- **Client `defcap`** (often `@event`, may `compose-capability (SECURE)` or a core cap): **all** authorization and validation — `CAP_EnforceAccountOwnership`, `UEV_*`, `UEV_Fee`, table reads. Boolean predicates are combined in **one** `enforce` per the rule below.
- **`XI_*` / `XB_*`**: persisted writes under `require-capability` on a `SECURE`-composing cap. May call `UR` / `URC` / `UC` / `UDC`, but must **not** `enforce` or call `UEV_*` — every check belongs in the defcap. Body ends on `insert` / `update` / `write` — **no trailing `true`, no `OutputCumulator` return**.
- **`XE_*`**: forward-module entrypoint. Start with `UEV_IMC`, then `with-capability (…|XE>…)` inside the defun. The defcap holds all local + deployed-dep checks. The defun body is writes (and scoped reads) only — no `enforce` / `UEV_*` after `UEV_IMC`. No `OutputCumulator`; the forward module's `C_` composes IGNIS.
- **`C_*`**: wiring + billing. `UEV_IMC`, `with-capability (ClientCap …)`, one or more `XI`/`XE`/`XB` calls, optional STOA / `KDA|C_Collect`, then `IGNIS::UDC_*` / `UDC_ConstructOutputCumulator` so the returned `OutputCumulator` reflects the whole operation.

If one user operation spans multiple tables, use **multiple** `XI`/`XB` functions — one focused write path each — rather than cramming unrelated persistence into a single `XI`.

### Combining boolean checks in one `enforce`

| # bool conditions | Form |
|---|---|
| 1 | `(enforce p "msg")` |
| 2 | `(enforce (and p q) "msg")` |
| 3+ | `(enforce (fold (and) true [p q r ...]) "msg")` |

`CAP_*`, `UEV_*`, `UEV_Fee` stay as separate calls **before** the combined boolean `enforce` (they are not plain booleans). Reference: `SCR|XI>ISSUE-SCORE` in `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/02_SCORE.pact`.

### `UR_*` ordering

- `UR_*` groups follow the **order schemas are declared** in the module (first schema → first UR block, …).
- Within a group, mirror the **field order of the `defschema`**: full-row reader first (when present), then per-field readers in field order, then object-taking helpers/predicates.
- **Multi-table dispatch** (same schema, fungibility discriminator, etc.): prefer a single entry `UR_*` using `with-default-read (UC_*Table discriminator) row-key …` over copy-pasted per-table readers. Split only when the read logic diverges. Reference: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact` — `{F0} [UR]` blocks.
- **Per-field `UR_*` take table keys, not row objects.**

### Greenfield feature workflow

When adding a new slice (new schemas/tables + client entrypoints), follow this order:

1. Fix **schemas / `deftable`** shapes and declaration order.
2. Decide **`C_*` client names and outcomes** (surface spec, not implementation).
3. Populate **`UR_*` readers** grouped and ordered as above, including multi-table dispatch.
4. Build each `C_` **end-to-end one at a time**: defcap + cap wiring, `XI` / `XE` / `XB`, `UDC`, and introduce `URC` / `UEV` **as each path needs them**. Do not front-load all `URC`/`UEV` before the client code.

## Pact style rules specific to this repo

- **Formatting is a hard requirement, not cosmetic.** Preserve existing indentation, block comments (section bars), grouped `let` bindings, aligned multi-line args. Avoid formatting churn unrelated to behavioral changes.
- **Line length** — keep source lines within ~88–92 chars. For long `@doc` strings, use Pact string continuation: end a line with `\` and start the next with `\`; break at phrase/clause boundaries. Don't write multi-line `@doc` without continuation.
- **`@doc` placement** — **immediately after the parameter list**, before the body. Never between the function name and `(`.
- **Evented `defcap`** — order metadata `@doc` first, then `@event`, then body (Pact requirement).
- **`let` vs inline** — use `let` when a bound name is used **more than once**; if used only once, inline (common with `with-default-read (UC_*Table …) (UC_*Key …)`). No duplicate `defun` aliases.
- **Function/cap comments** — when introducing or refactoring, add a meaningful `@doc` and annotate core logic with numbered step comments (operational — what the line does). Don't duplicate validation across defcap + UEV for the same input.
- **Talos client output** — Talos `C_*` functions end with a clear `format` result string explaining the branch taken, not raw IDs. When output IDs differ by branch, the message describes what happened.

## Integration REPL canonical layout (required for new `begin-tx`/`commit-tx` suites)

Mirror `REPL/Stage_02/[6.2.1]_AQP-ANK.repl` and `[6.2.2]_AQP-SCORE.repl`. Spec: `OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md` § *Canonical layout*; checklist: `OuronetInformational/skills/repl-integration-test-layout.md`.

- **File header** — `FILE` banner, Legend (angle-bracket log prefixes), Source line, REPL tests line.
- **Inter-tx separator** (between `commit-tx` and next `begin-tx`) — three-line `;;|| NEXT >` block (see `REPL/Stage_01/[2.2]_Core.repl`).
- **Intra-tx groups** — inside each `begin-tx`, label blocks `;;==== TXnnn · mm · <slug> ====` where `mm` restarts at `01` per transaction, and on the **next line** print a matching banner: `(print "--- [TXnnn · mm · <slug>] ---")`.
- **Assertions** — `(expect (format "…" [vals]) expected actual)` and `(expect-failure (format "…" [vals]) expr)` with a **single** `format` for the doc string (don't wrap the whole `expect` in `format`). Because both return strings, batch them in `(map print [ (expect …) … ])` so every line prints.
- **`map print` residue** — `(map print xs)` evaluates to `[() () …]`. Place it so the `let` body's last form isn't a long bracket line; end with `""` or a short neutral `print` if you want to suppress that echo.

## Sandboxes

- **Kadena sandbox** (`00_KadenaSandbox/kda-env/init.repl`) — mainnet-style fungibles. `coin` in `kadena/coin-v6.pact` is renamed to `kadena-coin` in this sandbox so the identifier `coin` remains free for the Stoa native token in the same REPL.
- **Stoa sandbox** (`00_StoaSandbox/stoa-env/init.repl`) — live sources: root `ns`, `coin`, `util`, `stoa-ns` interfaces/modules. Initialized in **genesis order** via phased `init-phase-*.repl` files, with payloads aligned to `0_Stoa/genesis/*.json`. Registers `ouronet-ns` the same way the on-chain genesis does.
- All Ouronet deploy/test `.repl` files under `REPL/` use `(namespace "ouronet-ns")` and qualified refs like `ouronet-ns.DALOS`.

## Historical note: DPMF → DPOF

`DPMF` is the original MetaFungible module, kept for historical/migration context. Live metadata-rich fungible behavior is represented by **`DPOF`** (OrtoFungible). Naming shifted from MetaFungible to OrtoFungible to separate the active path from legacy meta-fungible semantics.

## Working agreement

When adding modules or functions:

1. Respect **deploy order** and **interface versioning** (cascade rule).
2. Place code in the right section (schemas → caps by C1–C4 → FUNCTIONS with `UC_*` first).
3. Use the correct **prefix** (`UC` / `UR` / `URC` / `UEV` / `UDC` / `CAP` / `A_` / `C_` / `X*`).
4. Wire new `A_` / `C_` / `X*` into the appropriate **Talos** module and add **policy** guards where inter-module or client access requires it.
5. When something stable is learned, append to `OuronetInformational/CONTEXT.md` or add a dated note under `OuronetInformational/memories/` so future sessions don't start from zero.
