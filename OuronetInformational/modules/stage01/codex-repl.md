# Stage 01 — CODEX REPL harness

Integration scenario: **`REPL/Stage_01/[6.9]_CODEX.repl`** (Talos **TS01-C4** → **CODEX** **A_** / **C_**).

## Prerequisites

Load through **`[4.0]_Sovereign-Executor.repl`** (or full **`Stage01_Tester.repl`**) so these exist:

- **CODEX** (**`[2.2]_Core.repl`** TX-15)
- **TS01-C4** (**`[3]_Talos.repl`** TX-03b — **after TS01-A**)
- Executor may still set **`DALOS|A_UpdateUsagePrice "codex"`** (legacy); **StoicTag register** = **`UC_StoicTagStoaFee`** × length, **always** via **`IGNIS|KDA|C_CollectWTEx`** (patron pays Kadena, **`account-address`** Elite discount, `trigger=false`); **release** = same amount in IGNIS (virtual-gas rules) — neither uses that price table
- **`ouronet-ns.codex-keyset`** (**`[2.1]_Dalos.repl`**)

Optional: uncomment **`(load "Stage_01/[6.9]_CODEX.repl")`** in **`Stage01_Tester.repl`**.

## Deploy order (do not change without reading load-order skill)

```
[2.2]_Core   → CODEX
[3]_Talos    → TS01-A → … → TS01-C4  (not in Core — TS01-C4 needs TS01-A)
[4.0]        → P|A_Define for CODEX + TS01-C4
[6.9]        → scenario txs
```

See **`OuronetInformational/ouronet/conventions/module-load-order-and-pact-refs.md`**.

## TX000 — `env-data` placeholders

Edit **`env-data`** in TX000 before TX001:

| Key | Notes |
|-----|--------|
| **`CODEX\|COMPOSITE-ID`** | 325 chars: **`₱.`** standard half (162) + **`:`** + **`Π.`** smart half (162) |
| **`CODEX\|PUBLIC-STANDARD`**, **`CODEX\|PUBLIC-SMART`** | Non-empty pubkey strings |
| **`CODEX\|REGISTERED-BY`** | Operator string stored on row |
| **`KEY_CODEX_GUARD`**, **`KEY_CODEX_GUARD_NEW`** | Keysets for register / rotate |
| **`CODEX\|STOICTAG-NAME`** | **3–256** glyphs, **`DALOS\|CHARSET`** only (**`U\|DALOS`** **`UEV_StoicTagName`**) |
| **`CODEX\|STOICTAG-ACCOUNT`** | Ouronet **`Ѻ.*`** / **`Σ.*`**; empty → **`KST.ANHD`** |

### `env-data` syntax

Pact object literals **require commas** between fields (same as **`[0.0]_Starter.repl`**):

```pact
(env-data
    {
        "CODEX|COMPOSITE-ID": "",
        "CODEX|PUBLIC-STANDARD": "…",
        …
    }
)
```

Missing commas → **`Expected: ['}']`** at the second key.

## Scenario transactions

| TX | Function | Signers | What it proves |
|----|----------|---------|----------------|
| TX001 | **`A_RegisterCodexIdentity`** | **`PK_AncientHodler`** (codex-keyset / Demiourgos) | CodexID row + UR_CIX reads |
| TX002 | **`C_RotateCodexGuard`** | Current guard + new guard (**`PK_Florean`** for KEY_CODEX_GUARD_NEW) | Guard rotation |
| TX003 | **`C_RecordArweaveUpload`** | Rotated codex guard | Arweave tracker append |
| TX004 | **`C_RegisterStoicTag`** | DALOS owner + **four** **`coin.TRANSFER`** ( **`URC_SplitKDAPrices`** on `UC_StoicTagStoaFee`) | **Virgin** insert — both **`StoicTags`** and **`StoicTagsByAccount`** active + bijection |
| TX005 | **`C_ReleaseStoicTag`** | DALOS owner | **Bijection release** — both tables **`iz-active` false**, DataOrNull unregistered; **`UC_StoicTagStoaFee`** collected as IGNIS via **`IGNIS|C_Collect`**
| TX006 | **`C_RegisterStoicTag`** (same tag) | DALOS owner + **four** **`coin.TRANSFER`** (same split) | **Released re-activate** — upsert both tables (same XI path as virgin) |

## Starter key name gotcha

Florian’s env-sig key in **`KC`** is **`PK_Florean`** (spelling in **`[0.0]_Starter.repl`**), **not** **`PK_Florian`**. **`KEY_CODEX_GUARD_NEW`** uses **`KC.DPTS_PBKY_000a`** → **`PK_Florean`**.

Use **`PK_Florean`** in **`env-sigs`** when the keyset was built from **`KC.DPTS_PBKY_000a`**.

## Validation utilities (reload after pact fixes)

Registration and StoicTag paths call:

- **`U|DALOS`** (**`UtilityDalosGlyphsV2`**): **`GLYPH|UEV_ApolloAccountCheck`**, **`GLYPH|UEV_DalosAccountCheck`**, **`UEV_StoicTagName`**

StoicTag charset is **DALOS|CHARSET** (not **`U|ATS`** index rules). Reload **`[1]_Utilities.repl`** after utility bumps.

## Interface surface

**CodexV1** omits **`UR_*|Data:object{CODEX|S|…}`** (module-local schemas). Use field **`UR_*`** accessors or **`UR_*|DataOrNull`** from **`module{CodexV1}`**. See **`interface-object-return-rule.md`**.
