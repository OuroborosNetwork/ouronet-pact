# Ouronet — architecture documentation (living)

This folder is the **canonical map** of what exists in the repo: modules, interfaces, slave code, and REPL harnesses. It supports **whitepapers**, **external docs**, and **AI-assisted development** without re-scanning the tree from scratch each time.

## How to use

| Document | Purpose |
|----------|---------|
| [`00_MASTER_INVENTORY.md`](00_MASTER_INVENTORY.md) | Counts, paths, and navigation to everything |
| [`STAGE_01_MODULES.md`](STAGE_01_MODULES.md) | Stage 1: utilities → core → Talos (per-module notes) |
| [`STAGE_01_INTERFACES.md`](STAGE_01_INTERFACES.md) | Stage 1 interface files and named interfaces |
| [`STAGE_02_MODULES.md`](STAGE_02_MODULES.md) | Stage 2: DPDC slice, DemiPad, AQP, Talos |
| [`STAGE_02_INTERFACES.md`](STAGE_02_INTERFACES.md) | Stage 2 DPDC/DemiPad/Talos interfaces |
| [`SLAVE_AND_SAMPLES.md`](SLAVE_AND_SAMPLES.md) | `2_SLAVE/`, `0_Sample/` |
| [`REPL_AND_TESTS.md`](REPL_AND_TESTS.md) | REPL loaders and scenario files |
| [`DEEP_DIVE_ALL_MODULES.md`](DEEP_DIVE_ALL_MODULES.md) | Cross-repo module indexing: counts, prefixes, relations, functionality |
| [`REFERENCE_URSTOA_VAULT_RPS.md`](REFERENCE_URSTOA_VAULT_RPS.md) | UrStoa Vault RPS mechanics in Stoa `coin.pact` (baseline for AQP) |
| [`WHITEPAPER_ROADMAP.md`](WHITEPAPER_ROADMAP.md) | How to turn this into public documentation |

## Maintenance rule

When you add or rename a **`.pact`** file, **interface**, or **major REPL** entrypoint, update the relevant file here (or add a dated note under `../memories/` and fold it in later).

## Related

- [`../MODULE_ARCHITECTURE.md`](../MODULE_ARCHITECTURE.md) — naming, prefixes, Talos economics
- [`../CONTEXT.md`](../CONTEXT.md) — project-level context
