# Deploy impact pattern (interfaces + modules)

Use this checklist every time new Pact code is added or existing modules are changed, so deploy prep is deterministic.

## 1) Classify each interface as one of three states

- **Bumped interface**: an already-on-chain interface changed its external surface (`defun` added/removed/renamed, type changed).  
  - Action: publish next suffix (`V1` -> `V2`) and update all `module{...}` / `object{...}` consumers.
- **New interface**: a brand-new interface family introduced by a new module/client.  
  - Action: deploy it as `V1` even though it is not a bump.
- **Unchanged interface**: implementation changed but signatures did not.  
  - Action: no interface upload required.

## 2) Build the deploy set from interface state

For every release candidate, produce these two lists:

- **Interfaces to upload**
  - all bumped interfaces (new version suffixes),
  - all new interfaces (new `V1` families).
- **Modules to upload**
  - modules implementing bumped interfaces (must be upgraded to newest suffix),
  - modules implementing unchanged interfaces but with behavior fixes,
  - modules newly introduced in the feature.

## 3) Cascade update rule (critical)

When an interface bumps, update every typed consumer:

- `implements InterfaceV*`
- `module{InterfaceV*}`
- `object{InterfaceV*.Schema}` (or equivalent typed references)

This includes utilities, core, Talos, citizen bridges, REPL typed refs, and architecture docs.

## 4) Deployment order template

1. Upload interfaces (bumped + new).
2. Upload utilities.
3. Upload core modules.
4. Upload Talos/client modules.
5. Run executor/governance wiring (`P|A_Define`, keyset-dependent setup).
6. Run scenario smoke REPL(s).

## 5) Required output format for each feature

Before deploy, always publish a short release note with:

- **Interface changes**: bumped/new/unchanged table.
- **On-chain uploads**: exact interface list + module list.
- **Conditional uploads**: modules only needed if their typed refs were bumped.
- **Post-deploy txs**: executor/governance actions required.

This is the default "what changed -> what must be uploaded" contract for Ouronet releases.

## Worked example — CODEX release (Stage 01)

| Step | Interface | Trigger | Modules that must implement / reference new version |
|------|-----------|---------|-----------------------------------------------------|
| 1 | `UtilityDalosGlyphsV2` | New defuns on live V1 | `U\|DALOS`, `DALOS`, `CODEX` |
| 2 | `UtilityAtsV2` | New StoicTag index defuns on live V1 | `U\|ATS`, `DALOS` (and any `module{UtilityAtsV2}` caller) |
| 3 | `AutostakeV2` | Cascade: V1 typed `object{UtilityAtsV1.Awo}` | `ATS` (implements); callers use `module{AutostakeV2}` when redeployed |
| 4 | `CodexV1` | New module | `CODEX`, `TS01-C4` |
| 5 | `TalosStageOne_ClientFourV1` | New Talos client | `TS01-C4` |

**On-chain upload (this release):** interfaces 1–5 above; modules `U\|DALOS`, `U\|ATS`, `DALOS`, `ATS`, `CODEX`, `TS01-C4`.

See [`STAGE_01_CODEX_ON_CHAIN_DEPLOY.md`](STAGE_01_CODEX_ON_CHAIN_DEPLOY.md) for full ordering and optional caller redeploys.
