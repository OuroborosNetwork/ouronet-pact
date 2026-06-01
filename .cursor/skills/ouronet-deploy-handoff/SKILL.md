---
name: ouronet-deploy-handoff
description: When a feature is build-complete, produce the deploy handoff — interface bumps, modules to upload on-chain, post-deploy setup txs (P|A_Define, keysets, prices), and smoke REPL. Use when user confirms a feature is done or asks what to deploy/run after uploading interfaces and modules.
---

When the user confirms a feature is **done building**, always deliver a **deploy handoff** in this exact structure (do not skip sections).

Read first:
- **`OuronetInformational/ARCHITECTURE/DEPLOY_IMPACT_PATTERN.md`**
- **`OuronetInformational/ARCHITECTURE/INTERFACE_VERSIONING.md`**
- Feature-specific deploy doc if it exists (e.g. **`STAGE_01_CODEX_ON_CHAIN_DEPLOY.md`**)

---

## Handoff template (copy for every release)

### 1. Dependency chain

ASCII or bullet cascade: which interface bumped → which interfaces cascade → which modules implement/reference them.

Classify each interface:
- **Bump** (live Vn changed) → upload V(n+1)
- **New** (first deploy) → upload V1
- **Unchanged** (implementation-only) → no interface upload

### 2. Interfaces to upload on-chain

Numbered list with frozen predecessors noted (do not re-upload old versions).

### 3. Modules to upload on-chain

Numbered list in deploy order. Split:
- **Required this release**
- **Deferred** (repo updated; upload when next touched)

### 4. Post-deploy setup (mandatory txs)

After interfaces + modules are on-chain, list **every governance/setup call** required before the feature works:

| Setup | Typical call | When |
|-------|--------------|------|
| Namespace keysets | `define-keyset` | New keysets only |
| IMC / IMP graph | `P|A_Define` on each affected module | Always after new/changed modules |
| DALOS usage prices | `DALOS\|A_UpdateUsagePrice` via TS01-A | If executor sets them (may be legacy) |
| Module admin / table init | executor INIT txs | Greenfield only |

Reference REPL file + tx id for each setup step.

### 5. Smoke / integration REPL

Which `.repl` to run, prerequisite load order, and what txs assert.

### 6. Repo consistency check

- `rg` for stale `module{OldInterface}` refs
- Reload order if `module{Interface}` load-time refs exist

---

## CODEX (Stage 01) — reference handoff

### Dependency chain

```
UtilityDalosGlyphsV1 → V2 → U|DALOS, DALOS, CODEX
UtilityAtsV1 → V2 → U|ATS, DALOS
UtilityAtsV2 → AutostakeV2 → ATS
CodexV1 (new) → CODEX, TS01-C4
TalosStageOne_ClientFourV1 (new) → TS01-C4
```

### Interfaces to upload (5)

1. `UtilityDalosGlyphsV2`
2. `UtilityAtsV2`
3. `AutostakeV2`
4. `CodexV1`
5. `TalosStageOne_ClientFourV1`

### Modules to upload (6 required)

1. `U|DALOS` → 2. `U|ATS` → 3. `DALOS` → 4. `ATS` → 5. `CODEX` → 6. `TS01-C4`

### Post-deploy setup

**Prerequisite:** Stage 01 base stack live (IGNIS, DALOS, TS01-A, coin, namespaces).

| Step | REPL / action | What it does |
|------|---------------|--------------|
| A | `[2.1]_Dalos.repl` | `ouronet-ns.codex-keyset` → Mnemosyne operator keyset |
| B | `[4.0]_Sovereign-Executor.repl` **TX-02** | Batch **`P|A_Define`**: includes **`CODEX::P|A_Define`** (CODEX IMP → DALOS) and **`TS01-C4::P|A_Define`** (Talos IMP → CODEX, IGNIS, DALOS, TS01-A) |
| C | `[4.0]_Sovereign-Executor.repl` **TX-03** | **`DALOS\|A_UpdateUsagePrice "codex" 100.0`** — **legacy** table price; StoicTag fee is **1 STOA × tag length** in TS01-C4, not this price |
| D | (optional) Full executor INIT | Only on greenfield — demiurgoi, gas, accounts |

**On mainnet (manual txs after module upload):**

```pact
;; 1. Keyset (once per network)
(define-keyset "ouronet-ns.codex-keyset" (read-keyset "…"))

;; 2. IMC wiring
(CODEX.P|A_Define)
(TS01-C4.P|A_Define)

;; 3. Optional legacy price (not StoicTag fee)
(TS01-A.DALOS|A_UpdateUsagePrice "codex" 100.0)
```

**What setup enables:**

- **`CODEX::P|A_Define`** — registers **`P|CODEX|CALLER`** IMP on DALOS so Talos/core can call CODEX under IMC.
- **`TS01-C4::P|A_Define`** — registers **`P|TALOS-SUMMONER`** on CODEX, IGNIS, DALOS, TS01-A so patron txs reach core writers.
- **`codex-keyset`** — required for **`A_RegisterCodexIdentity`** (Mnemosyne admin cap).
- StoicTag **fee** — **`IGNIS::C_TransferDalosFuel`** inside TS01-C4 at register time (patron signs **`coin.TRANSFER`** for STOA amount).

### Smoke REPL

**`REPL/Stage_01/[6.9]_CODEX.repl`** after full stack through `[4.0]`.

| TX | Covers |
|----|--------|
| TX001 | Register CodexID |
| TX002 | Rotate codex guard |
| TX003 | Record Arweave upload (rotated guard) |
| TX004 | Register StoicTag — **virgin** insert (both tables) |
| TX005 | Release StoicTag — **bijection** (both `iz-active` false, DataOrNull flags) |
| TX006 | Re-register **released** tag — upsert both tables (same as virgin path semantically) |

See **`OuronetInformational/skills/codex-stage01-repl.md`**.

---

## Agent rule

When user says feature is done / ready to deploy / "what do I upload":

1. Run dependency chain (interface file diffs + `rg` consumers).
2. Output sections 1–6 of the handoff template.
3. If code still references old interface versions, fix before handoff.
4. Point to feature REPL + executor setup txs explicitly.
