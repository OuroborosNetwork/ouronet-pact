# Pact Codebase Scan Pack 01

Date: 2026-04-07
Scope: Stage 1 Core, Stage 2 Core (DPDC/DEMIPAD), Stage 1+2 Talos
Intent: Persist concrete implementation patterns from existing Ouronet Pact code.

## 1) Stable module skeleton patterns

- Sovereign modules consistently follow a readable top-down shape:
  - governance block
  - policy block (`P|T`, `P|MT`, `P|A_*`, `UEV_IMC`)
  - schemas/tables/constants
  - capabilities (`C1` to `C4` grouped by comments)
  - functions
- Cross-module interactions are usually typed module refs + `::`, not ad-hoc imports.
- Example anchors:
  - `1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact`
  - `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact`
  - `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact`
  - `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact`

## 2) Policy spine conventions (inter-module communication)

- Standard policy pair appears broadly:
  - `P|T:{OuronetPolicyV1.P|S}`
  - `P|MT:{OuronetPolicyV1.P|MS}`
- Standard helper flow:
  - `P|UR`, `P|UR_IMP`
  - `P|A_Add`, `P|A_AddIMP`, `P|A_Define`
  - `UEV_IMC` to validate implemented policy guards
- Caller caps commonly use `P|<MODULE>|CALLER` + `P|SECURE-CALLER`.

## 3) Function/capability naming semantics confirmed in code

- Utility/read side:
  - `UC_` compute helpers
  - `UR_` reads
  - `URC_` read + compute
  - `UEV_` enforce/validate
  - `UDC_` data/object constructors
  - `CAP_` ownership/capability enforcement helpers
- Protected entrypoints:
  - `A_` admin
  - `C_` client
  - `X*` auxiliary protected paths
- Capability name bands (`S>`, `F>`, `C>`, `C>X_`, `X>`) are also used as semantic markers in many modules.

## 4) Interface/versioning behavior

- Interfaces are central and versioned (`*V1`, `*V2`, ...).
- API surface changes should be treated as interface-version changes and propagated through:
  - `implements ...`
  - `module{InterfaceVn}` references
- Stage 2 shows larger multi-module interface compositions (DPDC family, DEMIPAD family).

## 5) Stage 2 architecture differences from Stage 1

- Stage 1 core is mostly flat one-file module units.
- Stage 2 core uses grouped vertical slices:
  - DPDC split across multiple modules in `01_DPDC/`
  - DEMIPAD split into launchpad + satellites in `02_DEMIPAD/`
- DPDC UDC schema/interface separation is explicit (`DPDC-UDC` + `DpdcUdcV1`).

## 6) Talos orchestration and economic enforcement patterns

- Talos modules are the practical execution entry layer for chained operations.
- Typical behavior:
  - `with-capability (P|TS)` around client flows
  - route into core `C_`/`A_` functions via typed refs
  - integrate IGNIS collection and/or fuel routines in sequence
- Repeated operational pattern:
  - execute intended domain action in Talos path
  - enforce payment/fuel mechanics around that path
  - keep client flow constrained to approved sequence
- Example anchors:
  - `1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact`
  - `1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact`
  - `1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact`
  - `1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact`
  - `1_SOVEREIGN/STAGE_02/3_Talos/03_TS02-DPAD.pact`

## 7) Formatting/indentation style retained

- Human readability is a first-class requirement:
  - stable indentation depth
  - grouped/aligned `let` bindings
  - section banners and comment separators retained
  - minimal formatting churn in edits
- New code should visually match neighboring code in the same file.

## 8) Working rules for future AI edits (from this scan)

1. Preserve module skeleton ordering and section markers.
2. Keep policy spine complete when creating new sovereign modules.
3. Use the correct prefix family for every function/cap.
4. Prefer typed module refs + `::` for inter-module access.
5. Treat interface updates as explicit versioning events.
6. Finalize new protected behavior through Talos orchestration paths.
7. Preserve your formatting discipline and avoid stylistic noise.

---

This is Scan Pack 01. Additional packs should narrow into topic-specific areas (DPDC nonce/ledger flow, branding flow, IGNIS economics flow, policy guard propagation maps).
