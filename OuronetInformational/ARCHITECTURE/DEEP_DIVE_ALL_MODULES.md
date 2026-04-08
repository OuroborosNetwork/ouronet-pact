# Deep Dive — all Pact modules

This document indexes module-level structure across sovereign and slave code:

- function/cap/table/schema counts,
- function-prefix distributions,
- dependency relationships (typed `module{...}` refs),
- functional purpose of each subsystem.

It is intended as a whitepaper-ready technical baseline.

## Scope and method

- Included: all module files under `1_SOVEREIGN/STAGE_01`, `1_SOVEREIGN/STAGE_02`, `2_SLAVE`.
- Excluded from counting: interface-only files (`0_Interfaces/*`) as module implementations.
- Caveat: files with co-located `interface` + `module` may duplicate some names at file-level scans; treat per-file prefix totals as operational indicators, not legal API contracts.

## Global picture

| Area | Module files | defun | defcap | deftable | defschema |
|------|-------------:|------:|-------:|---------:|----------:|
| Stage 1 sovereign | 40 | 1937 | 449 | 76 | 22 |
| Stage 2 sovereign | 26 | 1124 | 271 | 89 | 28 |
| Stage 2 slave + Stage 1 slave + Stage_Z | 10 | 261 | 35 | 10 | 10 |
| **Total** | **76** | **3322** | **755** | **175** | **60** |

## Prefix distribution (high-level)

### Stage 1 (strongly mature utility/read/computation footprint)

- `UR_` and `URC_` are heavy (read-driven architecture).
- `UEV_` and `X*` are also large (validation and internal orchestration complexity).
- `C_` is concentrated in core/Talos entry surfaces.

Stage 1 aggregate prefix totals from scan:

| UC_ | UR_ | URC_ | UEV_ | UDC_ | CAP_ | A_ | C_ | X* |
|----:|----:|-----:|-----:|-----:|-----:|---:|---:|---:|
| 130 | 265 | 124 | 191 | 90 | 6 | 22 | 180 | 229 |

### Stage 2 (DPDC + DEMIPAD + Talos orchestration)

- `UR_` remains dominant in DPDC and DEMIPAD read surfaces.
- `X*` is high in DPDC sharded modules (internal mutation/orchestration).
- `C_` is distributed across DPDC shards and satellite modules.

Stage 2 aggregate prefix totals from scan (file-level, with caveat on co-located interface/module files):

| UC_ | UR_ | URC_ | URD_ | UEV_ | UDC_ | CAP_ | AUP_ | C_ | X* |
|----:|----:|-----:|-----:|-----:|-----:|-----:|-----:|---:|---:|
| 30 | 203 | 58 | 5 | 98 | 33 | 7 | 6 | 118 | 159 |

### 2_SLAVE (scenario/read and deployment helpers)

- `URC_` concentrated in `DPL-UR`.
- `A_` concentrated in collection deployment pipelines (`NOSFERATU`, `KBN`, Bloodshed).

## Largest modules by `defun` (complexity signal)

| Rank | Module | File | defun |
|-----:|--------|------|------:|
| 1 | ATS | `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact` | 172 |
| 2 | DPTF | `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact` | 171 |
| 3 | DPOF | `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact` | 164 |
| 4 | DPDC | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact` | 162 |
| 5 | DALOS | `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` | 148 |
| 6 | DPMF | `1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact` | 130 |
| 7 | DEMIPAD | `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` | 122 |
| 8 | SWP | `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact` | 109 |
| 9 | INFO-ONE | `1_SOVEREIGN/STAGE_01/2_Core/21_INFO-ONE+.pact` | 87 |
| 10 | TS01-C2 | `1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact` | 86 |

## Relationship map (how modules connect)

### Stage 1 backbone

1. `DALOS` provides account/governance and wide policy anchoring.
2. `IGNIS` defines cumulators and fee collection primitives.
3. Core domains (`DPTF`, `DPOF`, `ATS`, `VST`, `SWP*`, `LIQUID`, `OUROBOROS`) implement business logic.
4. `TS01-*` Talos modules orchestrate client/admin sequences and economic hooks (`IGNIS::C_Collect`, fuel flows).

### Stage 2 backbone

1. DPDC is a sharded vertical:
   - hub: `DPDC`
   - operations: `DPDC-C/I/R/MNG/T/S/F/N`
   - schema carrier: `DPDC-UDC`
   - extension: `EQUITY`
2. DEMIPAD is hub + satellites:
   - hub: `DEMIPAD`
   - satellites: `DEMIPAD-SPARK`, `DEMIPAD-SNAKES`, `DEMIPAD-CUSTODIANS`, `DEMIPAD-STOICPAY`, `STOAICO`
3. `TS02-*` Talos modules route DPDC and DEMIPAD surfaces into approved client/admin paths.

### Slave + Stage_Z

1. `DPL-UR` is the unified read bundle (`DeployerReadsV7`) aggregating cross-domain UI reads.
2. `AOZ`, `DSP` are Stage 1 slave examples tied to sovereign policy/account primitives.
3. Stage 2 slave families (`NOSFERATU`, `KBN`, Bloodshed set) focus on DPDC-centric content pipelines.

## Functional domains achieved so far

| Domain | Primary modules |
|--------|------------------|
| Accounts/governance/policy | `DALOS`, `OuronetPolicyV1` implementers, Talos policy defs |
| Gas economics / IGNIS | `IGNIS`, Talos wrappers |
| Fungibles (true/meta/orto) | `DPTF`, `DPMF` (legacy), `DPOF` (active), `TFT` |

> Note: `DPMF` is preserved for historical/migration purposes. The active live-network path for metadata-rich fungible ("meta-token") behavior is `DPOF` (OrtoFungible).
| Autostake / vesting / liquid | `ATS`, `ATSU`, `VST`, `LIQUID`, `OUROBOROS` |
| Swapper stack | `SWPT`, `SWP`, `SWPI`, `SWPL`, `SWPLC`, `SWPU`, `MTX-SWP` |
| Collectables | `DPDC*`, `EQUITY` |
| Launchpad and sale satellites | `DEMIPAD*`, `STOAICO` |
| Acquisition pools | `AQP-ANK`, `AQP-SCORE`, `AQP`, `FVT` |
| Aggregated read layers | `INFO-ZERO`, `INFO-ONE`, `INFO-TWO`, `DPL-UR` |
| Slave scenarios | `AOZ`, `DSP`, `NOSFERATU`, `KBN`, `BLOODSHED-*` |

## Where to find module-by-module details

- Stage 1 list and roles: `STAGE_01_MODULES.md`
- Stage 2 list and roles: `STAGE_02_MODULES.md`
- Stage 1 interfaces: `STAGE_01_INTERFACES.md`
- Stage 2 interfaces: `STAGE_02_INTERFACES.md`
- Slave and sample files: `SLAVE_AND_SAMPLES.md`
- REPL harness map: `REPL_AND_TESTS.md`

## Next deepening steps (for whitepaper chapters)

1. Build explicit call-flow diagrams for:
   - Stage 1: `TS01-C* -> IGNIS -> DALOS/DPTF/SWP`
   - Stage 2: `TS02-C* -> DPDC-* -> IGNIS`
2. Add deploy-order dependency DAGs for DPDC and DEMIPAD families.
3. Add per-module invariants table (state transitions, enforcement points, failure conditions).
4. Add per-interface change log mapping (`Vn` bumps and affected implementers).
