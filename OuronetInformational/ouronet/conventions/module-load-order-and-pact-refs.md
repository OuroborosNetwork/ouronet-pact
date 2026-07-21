# Module load order and `(module{…} OtherModule)` references

Pact resolves **`(ref-X:module{SomeInterface} OtherModule)`** at **module load** time. The target module must **already be deployed** in the REPL (or chain) when the referencing module is loaded — even if the reference appears only inside a **`defun`** body.

## Symptom

```
Cannot find module: ouronet-ns.TS01-C4
Cannot find module: ouronet-ns.TS01-A
```

Stack trace points at a **`let`** binding like **`(ref-P|TS01-C4:module{…} TS01-C4)`** inside **`P|A_Define`**, a Talos **`C_*`**, or a core **`defcap`**.

## Rules

### 1. REPL deploy order matches dependency graph

| Layer | Stage 01 example | Must exist before |
|-------|------------------|-----------------|
| Interfaces | `[0.1]_Interfaces.repl` — **shared + historical** only | any module using a shared type (`OuronetInfoV1.ClientInfo`, `BrandingV1.SocialSchema`, …) |
| Utilities | `[1]_Utilities.repl` | core / Talos |
| Core | `[2.2]_Core.repl` (e.g. **CODEX** TX-15) | Talos client that calls **`ref-CODEX::…`** |
| Talos | `[3]_Talos.repl` (**TS01-A** first, then **TS01-C1…C4**, **TS01-P**) | executor / scenario REPLs that call Talos |
| Executor | `[4.0]_Sovereign-Executor.repl` | **`P|A_Define`** on all deployed modules |

**Do not** deploy a Talos client in **`[2.2]_Core.repl`** if its module body references **TS01-A** or other Talos modules that load later in **`[3]_Talos.repl`**.

### 2. Avoid circular load-time references between core and Talos

Bad pattern (load fails):

- **CODEX** **`P|A_Define`** → **`ref-P|TS01-C4::P|A_AddIMP`** (needs **TS01-C4** at **CODEX** load)
- **TS01-C4** **`C_*`** → **`ref-CODEX::…`** (needs **CODEX** at **TS01-C4** load)

**Ouronet convention:**

- **Core** **`P|A_Define`** wires **IMP** only to **other core** modules (**DALOS**, **IGNIS**, …) using **`P|…|CALLER`** guards — **not** to Talos modules.
- **Talos client** **`P|A_Define`** adds **`P|TALOS-SUMMONER`** to the core modules it calls (**CODEX**, **DALOS**, **IGNIS**, **TS01-A**, …).
- Cross-links that need **both** modules loaded run at **executor** time via **`ref-P|TS01-C4::P|A_Define`** / **`ref-P|CODEX::P|A_Define`** in **`[4.0]_Sovereign-Executor.repl`**, **after** both are deployed.

Reference: **`06_TS01-C4.pact`** **`P|A_Define`** (Talos → core IMP only); **`22_CODEX.pact`** **`P|A_Define`** (core → **DALOS** only).

### 3. Interface vs module in the same `.pact` file

Loading **`22_CODEX.pact`** installs **CodexV1** then **CODEX**. Talos only needs **CODEX** deployed; the **CodexV1** interface is available as soon as the file is loaded once.

### 4. Module-owned interfaces (deploy pattern)

| Location | What lives there |
|----------|------------------|
| **`2_Core/<module>.pact`** | Latest interface for that module + `(module …)` + `(create-table …)` |
| **`0_Interfaces/02_Core.pact`** | **Shared** interfaces (`OuronetPolicyV1`, `OuronetInfoV1`, `BrandingUsagePrimaryV1`, `DpofUdcV1`, `IgnisCollectorV1/V2`, …) + **historical** frozen versions (`PythiaV1`, `SwapperV2`, …) |
| **`0_Interfaces/03_Talos.pact`** | **Historical** Talos clients only (e.g. `ClientFourV1`–`V5`); latest `ClientFourV6` ships in **`06_TS01-C4.pact`** |

**`[0.1]_Interfaces.repl`** loads the slim shared/historical bundles only. **`[2.2]_Core.repl`** / **`[3]_Talos.repl`** load each module file once (interface + module in the same tx).

**Exceptions (stay in registry, not embedded):**

- **`BrandingV1`** — single implementer (**BRD**), but **`BrandingUsagePrimaryV1`** / **`BrandingUsageTertiaryV1`** reference **`BrandingV1.SocialSchema`**; keep **`BrandingV1`** in **`0_Interfaces/02_Core.pact`**.
- **`IgnisCollectorV1/V2`** — infrastructure types referenced across many signatures before **IGNIS** loads.

**Do not** duplicate the latest interface in both places — removes double-deploy / “interface cannot be upgraded” errors.

Migration helper: **`scripts/embed-module-interfaces.py`** (`s01`, `s02`, `--dry-run`).

Smoke: **`REPL/_smoke_interface_embed.repl`** (sandboxes + starter + Stage 01/02 `[0.1]`).

### 5. Stage 02 (same pattern)

| Location | What lives there |
|----------|------------------|
| **`STAGE_02/2_Core/**/*.pact`** | Latest interface per module (DPDC slices, AQP, DemiPad, …) |
| **`STAGE_02/0_Interfaces/02_Core.pact`** | **`DpdcUdcV1`** only (schemas referenced by all DPDC slice interfaces) |
| **`STAGE_02/0_Interfaces/03_Talos.pact`** | Historical frozen Talos clients (empty until a version is retired) |

**`REPL/Stage_02/[0.1]_Interfaces.repl`** loads slim Stage 02 bundles after Stage 01 is on-chain.

## Checklist (new core + Talos pair)

1. List every **`module{…} Name`** in the new **core** and **Talos** files.
2. Ensure REPL order: **core module tx** in **`[2.2]_Core.repl`**, **Talos client tx** in **`[3]_Talos.repl`** after **TS01-A**.
3. Keep **`P|A_Define`** free of **`module{Talos…}`** refs on the core side (and vice versa if it would cycle).
4. Register **`P|A_Define`** calls in **`[4.0]_Sovereign-Executor.repl`** in dependency-safe order (Talos clients after cores they reference).

## Cursor skill

**`OuronetInformational/ouronet/conventions/module-load-order-and-pact-refs.md`**
