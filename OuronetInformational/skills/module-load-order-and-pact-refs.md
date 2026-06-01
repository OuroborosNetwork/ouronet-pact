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
| Interfaces | `[0.1]_Interfaces.repl` | any module using the interface |
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

## Checklist (new core + Talos pair)

1. List every **`module{…} Name`** in the new **core** and **Talos** files.
2. Ensure REPL order: **core module tx** in **`[2.2]_Core.repl`**, **Talos client tx** in **`[3]_Talos.repl`** after **TS01-A**.
3. Keep **`P|A_Define`** free of **`module{Talos…}`** refs on the core side (and vice versa if it would cycle).
4. Register **`P|A_Define`** calls in **`[4.0]_Sovereign-Executor.repl`** in dependency-safe order (Talos clients after cores they reference).

## Cursor skill

**`.cursor/skills/ouronet-module-load-order/SKILL.md`**
