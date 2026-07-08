# Deploy handoff checklist (canonical)

When a feature is **build-complete**, produce this document for the operator. Cursor skill: **`OuronetInformational/modules/deploy/handoff.md`**.

---

## 1. Dependency chain

Show which interfaces **bump**, which **cascade**, which are **new**.

## 2. Interfaces to upload

List every interface tx (bumped + new). Note frozen Vn that must **not** be re-uploaded.

## 3. Modules to upload

Ordered list. Mark **required** vs **deferred** redeploys.

## 4. Post-deploy setup

After on-chain module upload, these txs are **not optional** for a working feature:

### Universal (Ouronet Stage 01 pattern)

| Step | Call | Purpose |
|------|------|---------|
| Keysets | `define-keyset` in namespace | New governance keys (e.g. `codex-keyset`) |
| IMC | `<Module>.P|A_Define` | Inter-module communication IMP graph |
| Prices | `TS01-A.DALOS\|A_UpdateUsagePrice …` | Legacy KDA price table (feature may override, e.g. STOA/glyph) |
| Init | `[4.0]_Sovereign-Executor.repl` early txs | Greenfield only |

### CODEX-specific

| Step | REPL | Call |
|------|------|------|
| Keyset | `[2.1]_Dalos.repl` | `ouronet-ns.codex-keyset` |
| IMC | `[4.0]` TX-02 | `CODEX::P|A_Define`, `TS01-C4::P|A_Define` (in batch) |
| Legacy price | `[4.0]` TX-03 | `"codex" 100.0` (StoicTag uses length×STOA in TS01-C4) |

**Load order before setup:** interfaces → utilities → core (CODEX, DALOS, ATS) → Talos (TS01-A before TS01-C4) → executor.

## 5. Smoke REPL

| Feature | File | Assertions |
|---------|------|------------|
| CODEX | `[6.9]_CODEX.repl` | TX001–TX006 (identity, rotate, arweave, stoictag virgin/release/re-register) |

## 6. Verify repo

```bash
rg 'UtilityDalosGlyphsV1|UtilityAtsV1|AutostakeV1' 1_SOVEREIGN --glob '*.pact' \
  | grep -v '0_Interfaces/'
```

Should return nothing outside frozen interface files.

---

Related: [`../ARCHITECTURE/DEPLOY_IMPACT_PATTERN.md`](../ARCHITECTURE/DEPLOY_IMPACT_PATTERN.md), [`../ARCHITECTURE/STAGE_01_CODEX_ON_CHAIN_DEPLOY.md`](../ARCHITECTURE/STAGE_01_CODEX_ON_CHAIN_DEPLOY.md), [`OuronetInformational/modules/stage01/codex-repl.md`](codex-stage01-repl.md).
