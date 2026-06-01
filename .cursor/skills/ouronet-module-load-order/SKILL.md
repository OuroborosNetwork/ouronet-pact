---
name: ouronet-module-load-order
description: Pact module load order in Ouronet REPL — module{Interface} refs resolve at load time; core vs Talos P|A_Define; no circular TS01-C4/CODEX deploy in Core.repl. Use when adding core+Talos pairs or fixing "Cannot find module" at load.
---

Read and follow **`OuronetInformational/skills/module-load-order-and-pact-refs.md`**.

## Quick rules

1. **`(ref-X:module{I} M)`** in a module body → **`M`** must already be deployed when that module loads.
2. **Core** in **`REPL/Stage_01/[2.2]_Core.repl`**; **Talos clients** in **`[3]_Talos.repl`** **after TS01-A**.
3. **Never** put **TS01-C4** (or any Talos client referencing **TS01-A**) in Core REPL — causes **`Cannot find module: TS01-A`**.
4. **Core `P|A_Define`** must not reference Talos modules (avoids **CODEX ↔ TS01-C4** cycle at load). Talos **`P|A_Define`** adds **`P|TALOS-SUMMONER`** to cores; executor runs both after deploy.
5. **CODEX** scenario REPL: **`OuronetInformational/skills/codex-stage01-repl.md`**.

## Symptom → fix

| Error | Likely cause |
|-------|----------------|
| **`Cannot find module: TS01-C4`** at **CODEX** load | Core **`P|A_Define`** still refs **TS01-C4** — remove; wire IMP in Talos/executor only |
| **`Cannot find module: TS01-A`** at **TS01-C4** load | **TS01-C4** deployed before **`[3]_Talos`** **TS01-A** tx |
| **`Cannot find module: CODEX`** at **TS01-C4** load | **TS01-C4** before **CODEX** TX-15 in Core |
