# Ouronet

Ouronet is a Pact-based protocol suite organized as staged sovereign modules plus extension ("citizen") modules, with REPL-first development and staged deployment flow.

## Repository scope

- `1_SOVEREIGN/` contains core canonical modules by stage.
- `2_CITIZEN/` contains citizen (extension) modules that consume sovereign APIs. The per-asset launchpad sales live under `2_CITIZEN/7_Launchpad/`.
- `REPL/` contains staged deploy/test harnesses (`Z.repl` for full-chain load).
- `OuronetInformational/` contains persistent architecture and working-context documentation.

## Current project state

- The Stage 02 AQP stack (`ANK`, `SCORE`, `AQP`, `FVT`) is under active development and testing.
- Current work is REPL-first and architecture iteration before final deployment.
- Interfaces are currently maintained as `V1` while modules are not yet deployed.

## Versioning policy (current)

- New interfaces/modules in the active ANQ/AQP work stay on `V1` until first mainnet deployment.
- `V2` should be introduced only after live deployment when post-deployment adjustments require a versioned interface/module move.
- Until deployment, `V1` code can be modified freely.

## Historical naming note (DPMF -> DPOF)

- `DPMF` is the original MetaFungible module and is retained for historical/migration context.
- Live metadata-rich fungible behavior is represented by `DPOF` (OrtoFungible).
- The rename was used to clearly separate the newer active path from legacy meta-fungible semantics.

## Live module browsing

Live modules can be explored at:

- [StoaChain Explorer — ouronet-ns modules](https://explorer.stoachain.com/modules?ns=ouronet-ns)

## Development notes

- Namespace in current Ouronet REPL/deploy flows: `ouronet-ns`.
- Stage test orchestration:
  - `REPL/Stage02_Tester.repl` for Stage 02 pipeline
  - `REPL/Z.repl` for full load
