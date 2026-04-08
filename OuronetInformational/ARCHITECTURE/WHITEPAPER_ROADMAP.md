# Whitepaper and public documentation — roadmap

This file ties **`OuronetInformational/ARCHITECTURE/`** to **external-facing** docs.

## Suggested document structure

1. **Executive summary** — What Ouronet is (virtual chain on Pact, IGNIS, Talos, stages).
2. **Architecture** — Utilities → Core → Talos; policy spine; deploy-order constraints.
3. **Stage 1** — Account model (DALOS), tokens (DPTF/DPMF/DPOF), liquidity (SWP*), autostake (ATS), vesting (VST), IGNIS.
4. **Stage 2** — Collectables (DPDC sharded modules), DemiPad ecosystem, AQP, INFO-TWO.
5. **Security model** — Capabilities C1–C4 naming, `P|TS` / GAP, inter-module policy guards, why `C_` is Talos-only.
6. **Economics** — IGNIS cumulators, native KDA hooks where applicable, gas station (conceptual).
7. **Extensibility** — Slave modules, interfaces and versioning discipline.
8. **Reference** — Link to `MODULE_ARCHITECTURE.md` and interface index files.

## Source material in-repo

| Topic | Primary sources |
|-------|------------------|
| Naming / prefixes | `OuronetInformational/MODULE_ARCHITECTURE.md`, `0_Sample/.../ModuleSample.pact` |
| Module inventory | `ARCHITECTURE/STAGE_01_MODULES.md`, `STAGE_02_MODULES.md` |
| Interface catalog | `ARCHITECTURE/STAGE_01_INTERFACES.md`, `STAGE_02_INTERFACES.md` |
| Test harness | `ARCHITECTURE/REPL_AND_TESTS.md`, `REPL/Z.repl` |
| First scan pack | `OuronetInformational/memories/2026-04-07-pact-codebase-scan-pack-01.md` |

## Iteration process

1. Pick a section (e.g. “DPDC transfer + royalties”).
2. Trace code: `Talos` → `IGNIS` → `DPDC-T` (see `STAGE_02_MODULES.md` intricacy notes).
3. Write prose + one sequence diagram (optional).
4. Add a dated memory under `memories/` if the chapter introduces new invariant rules.

## Per-file deep dives (backlog)

Track these as checkboxes in `STAGE_*_MODULES.md` **Deep-dive placeholders** or new `memories/2026-*-topic.md` files.
