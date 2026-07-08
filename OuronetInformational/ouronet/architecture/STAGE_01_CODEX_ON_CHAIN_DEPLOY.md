# Stage 01 — CODEX on-chain deploy checklist

Use when deploying **Mnemosyne CODEX** and related utility/interface fixes. Follows `INTERFACE_VERSIONING.md` and `DEPLOY_IMPACT_PATTERN.md`.

**REPL reference:** `REPL/Stage01_Tester.repl` through `[4.0]_Sovereign-Executor.repl`, then `[6.9]_CODEX.repl`.

---

## Dependency chain (this release)

```
UtilityDalosGlyphsV1 (on-chain) + new defuns
  └─► UtilityDalosGlyphsV2  ──► U|DALOS, DALOS, CODEX

UtilityAtsV1 (on-chain) + new StoicTag index defuns
  └─► UtilityAtsV2  ──► U|ATS
        └─► AutostakeV2 (names UtilityAtsV2.Awo)  ──► ATS (+ all module{AutostakeV2} callers in repo)

CodexV1 (not on-chain yet)  ──► CODEX, TS01-C4

TalosStageOne_ClientFourV1 (new)  ──► TS01-C4
```

**Rule:** interface surface change → bump suffix → update every `implements`, `module{…}`, and `object{Interface.Schema}` consumer in the repo before deploy.

---

## 1. Interfaces to upload on-chain

| # | Interface | Status | Why |
|---|-----------|--------|-----|
| 1 | **UtilityDalosGlyphsV2** | Bump | V1 live; added Apollo + StoicTag charset helpers |
| 2 | **UtilityAtsV2** | Bump | V1 live; added `UC_IzStoicTagIndexChar`, `UC_IzStoicTagIndex`, `UEV_StoicTagIndex` |
| 3 | **AutostakeV2** | Cascade bump | AutostakeV1 typed `object{UtilityAtsV1.Awo}` → `UtilityAtsV2.Awo` |
| 4 | **CodexV1** | New (first deploy) | CODEX core — not previously on-chain |
| 5 | **TalosStageOne_ClientFourV1** | New (first deploy) | TS01-C4 client surface |
| 6 | **IgnisCollectorV2** | Additive (new) | Opt-in only: `KDA\|C_CollectWTEx` — **IgnisCollectorV1 unchanged** |

**Frozen on-chain (do not re-upload):** `UtilityDalosGlyphsV1`, `UtilityAtsV1`, `AutostakeV1`, **`IgnisCollectorV1`**.

---

## 2. Modules to upload on-chain

### Required for CODEX + utility bumps

| # | Module | Path | Why |
|---|--------|------|-----|
| 1 | **U\|DALOS** | `1_Utilities/08_U_DALOS.pact` | `implements UtilityDalosGlyphsV2`; Apollo/StoicTag fixes |
| 2 | **U\|ATS** | `1_Utilities/09_U_ATS.pact` | `implements UtilityAtsV2`; StoicTag index + fold fix |
| 3 | **DALOS** | `2_Core/01_DALOS.pact` | `module{UtilityDalosGlyphsV2}` + `module{UtilityAtsV2}` refs |
| 4 | **ATS** | `2_Core/08_ATS.pact` | `implements AutostakeV2`; `UtilityAtsV2.Awo` typing |
| 5 | **CODEX** | `2_Core/22_CODEX.pact` | New registry (CodexV1) |
| 6 | **IGNIS** | `2_Core/02_IGNIS.pact` | `implements IgnisCollectorV2` (additive; V1 consumers unchanged) |
| 7 | **TS01-C4** | `3_Talos/06_TS01-C4.pact` | New Talos client; `module{IgnisCollectorV2}` for StoicTag STOA |

### Redeploy when you next touch these (repo already points at V2)

These modules **call** `module{AutostakeV2}` or `module{UtilityAtsV2}` but do not **implement** the bumped interfaces. They keep working at runtime after ATS/U|ATS upgrade until you redeploy them for other reasons:

| Module | Path |
|--------|------|
| ATSU | `2_Core/10_ATSU.pact` |
| VST | `2_Core/11_VST.pact` |
| TFT | `2_Core/09_TFT.pact` |
| SWP | `2_Core/15_SWP.pact` |
| SWPI | `2_Core/16_SWPI.pact` |
| SWPU | `2_Core/19_SWPU.pact` |
| OUROBOROS | `2_Core/13_OUROBOROS.pact` |
| INFO-ONE+ | `2_Core/21_INFO-ONE+.pact` |
| TS01-C2 | `3_Talos/03_TS01-C2.pact` |
| Stage 02 AQP (ANK, SCORE, AQP) | `STAGE_02/2_Core/03_AQP/*.pact` |

---

## 3. Deploy order

### A. Upload (on-chain)

1. **Interfaces:** `UtilityDalosGlyphsV2` → `UtilityAtsV2` → `AutostakeV2` → `CodexV1` → `TalosStageOne_ClientFourV1`
2. **Modules:** `U|DALOS` → `U|ATS` → `DALOS` → `ATS` → `CODEX` → `TS01-C4`

### B. Setup txs (after upload — required)

| Step | REPL | Action |
|------|------|--------|
| 1 | `[2.1]_Dalos.repl` | `define-keyset ouronet-ns.codex-keyset` (once per network) |
| 2 | `[4.0]_Sovereign-Executor.repl` **TX-02** | Batch **`P|A_Define`** — must include **`CODEX::P|A_Define`** and **`TS01-C4::P|A_Define`** |
| 3 | `[4.0]` **TX-03** | Optional **`DALOS\|A_UpdateUsagePrice "codex" 100.0`** (legacy; StoicTag register = **`KDA\|C_CollectWTEx`** patron + tagged account; release = IGNIS per virtual-gas rules) |

**What TX-02 wires:**

- `CODEX::P|A_Define` → `P|CODEX|CALLER` IMP on **DALOS**
- `TS01-C4::P|A_Define` → `P|TALOS-SUMMONER` IMP on **CODEX, IGNIS, DALOS, TS01-A**

Without step 2, Talos patron calls and core IMC will fail (`UEV_IMC` / missing IMP).

### C. Smoke

**`[6.9]_CODEX.repl`** — TX001–TX006 (see `OuronetInformational/modules/stage01/codex-repl.md`)

---

## 4. What changed on each bumped interface

### UtilityDalosGlyphsV2 (vs frozen V1)

**Added:** `GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_ApolloAccount`, `UC_IzStoicTagName`, `UEV_StoicTagName`

### UtilityAtsV2 (vs frozen V1)

**Added:** `UC_IzStoicTagIndexChar`, `UC_IzStoicTagIndex`, `UEV_StoicTagIndex`

**Implementation fix (same signature):** `UC_IzStoicTagIndex` uses `(fold (and) true [...])`

### AutostakeV2 (vs frozen V1)

**Only change:** `object{UtilityAtsV1.Awo}` → `object{UtilityAtsV2.Awo}` on position/unstake defs

### CodexV1 / TalosStageOne_ClientFourV1

First deploy — current repo surface.

---

## 5. Pre-deploy verification

- [ ] `rg 'UtilityDalosGlyphsV1|UtilityAtsV1|AutostakeV1' 1_SOVEREIGN` — only in `0_Interfaces/` frozen blocks
- [ ] `pact` load `[0.1]_Interfaces` → `[1]_Utilities` → `[2.2]_Core` (CODEX tx) → `[3]_Talos` (TS01-C4)
- [ ] `[6.9]_CODEX.repl` passes

**Related:** `DEPLOY_IMPACT_PATTERN.md`, `INTERFACE_VERSIONING.md`, `REPL_AND_TESTS.md`
