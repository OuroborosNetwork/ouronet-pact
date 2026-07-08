# INFO-ONE+ and `OuronetInfoV1.ClientInfo` pairing

## Workflow (constructing a new INFO function)

1. **Locate execution** — Talos `*|C_*` or sovereign `C_*` / `ATSU::*` / `VST::*` that ends in `IGNIS::C_Collect` (or equivalent). Open the **lowest** module that builds `OutputCumulator` (often `UDC_ConcatenateOutputCumulators` with an ordered list).
2. **Inventory gas legs** — For each leg: `UR_UsagePrice`, `SIP|URC_*` analogue, `TFT::UDC_*Cumulator`, `DPTF|C_Mint`-style calls, `UDC_ConstructOutputCumulator`, nested sub-flows. Note **order**; order must match concatenation in execution.
3. **Implement INFO** — Same parameters as the client entrypoint (typically `patron` first). Compute `ifp` / `kfp` with the same expressions; one `OI|UDC_DynamicIgnisCost patron ifp` (unless product explicitly splits). Build `OI|UDC_ClientInfo` pre/post/`output`.
4. **Declare on `InfoOneV1`** when the function is part of the stable sovereign API surface.
5. **Maintainer review** — Expect corrections on edge cases (elite dispo text, unlock auxiliaries, typos in `UDC_TransferCumulator` token ids). After each correction, **append a short “Lessons” note** under this section or under §10 (dated bullet: what was wrong, what execution line fixed it).

### Copy (`pre-text` / `post-text`)

The agent **authors all user-facing strings**: operation line(s) before confirm, success line(s) after. Match existing module tone (e.g. `Operation: …`, `Succesfully …`, `UC_ShortAccount` for accounts, pool/pair ids in `{}`). Align wording with what actually executes (amounts, tokens, pair id, side effects). Spelling in legacy code may use `Succesfully`; stay consistent with surrounding INFO defs unless you standardize in a dedicated pass.

### Lessons log (post-review)

- **2026-05-14 — `SWP|INFO_ChangeOwnership`:** Talos `04_TS01-C3.pact` `SWP|C_ChangeOwnership` collects `SwapperV3.C_ChangeOwnership` (`15_SWP.pact`). That `C_ChangeOwnership` ends with `UDC_BiggestCumulator (UR_OwnerKonto swpair)` — same nominal tier and trigger as `SIP|URC_Biggest` (`ignis|biggest` + `URC_IsVirtualGasZero`). No KDA leg. Extended `SIP|URC_Biggest` `@doc` to reference this cap.

Use this when adding or auditing UI-facing **INFO** previews: read-only `object{OuronetInfoV1.ClientInfo}` (pre/post copy, Ignis, Kadena, `output`) that must match what the **execution** path would charge.

**Canonical files**

- `1_SOVEREIGN/STAGE_01/2_Core/21_INFO-ONE+.pact` — module `INFO-ONE`, interface `InfoOneV1`.
- `1_SOVEREIGN/STAGE_01/2_Core/03_INFO-ZERO.pact` — `OuronetInfoV1` implements `OI|UDC_ClientInfo`, `OI|UDC_DynamicIgnisCost`, `OI|UC_IfpFromOutputCumulator`, etc.
- `1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact` — `OuronetInfoV1.ClientInfo` schema.

---

## 1. Return shape (all INFO paths)

Build **only** via `ref-I|OURONET::OI|UDC_ClientInfo` (alias `OuronetInfoV1` as `INFO-ZERO` in this module): arguments are **`pre-text`**, **`post-text`**, **`ignis`**, **`kadena`**, **`output`** (`03_INFO-ZERO.pact` `OI|UDC_ClientInfo`).

- **Ignis:** `OI|UDC_DynamicIgnisCost patron ifp`, `OI|UDC_NoIgnisCosts`, or nested extraction of `ignis-full` from another INFO object (see §7).
- **Kadena:** `OI|UDC_NoKadenaCosts`, `OI|UDC_DynamicKadenaCost patron kfp`, etc.

---

## 2. Module inventory (`21_INFO-ONE+.pact`)

### 2.1 Declared on `InfoOneV1` (stable public surface)

- **`UC|GasPrice`** — `(if trigger 0.0 full-price)`; same “zero out when trigger” idea as `UDC_ConstructOutputCumulator`’s trigger flag.
- **`SIP|URC_*` / `SKP|URC_*`** — simple Ignis / KDA price helpers; each `SIP|URC_*` `@doc` lists the **`DPTF|C_*` / `DPOF|C_*`** (or related) caps they mirror.
- **`DPTF|INFO_*`** — branding, supply, toggles, wipes, **`DPTF|INFO_Transfer` / `MultiTransfer` / `BulkTransfer` / `MultiBulkTransfer`** (TFT cumulators).
- **`DPOF|INFO_*`** — parallel to DPOF client ops; mint uses `SIP|URC_Medium` scalar (same tier as `DPOF|C_Mint`).
- **`VST|INFO_Hibernate`** — single vesting entry (also reused as a **cost sub-expression** inside Constrict/Brumate).
- **`ATS|INFO_*`** — Coil, Constrict, Curl, Brumate, ColdRecovery, Cull, DirectRecovery.
- **`SWP|INFO_*`** — Add / Iced / Glacial / Frozen / Sleeping liquidity (see §8).

### 2.2 Implemented in `INFO-ONE` but not on `InfoOneV1` (still part of this module’s contract for UI/backends)

Treat these like INFO: same `ClientInfo` rules and execution parity.

- **`UCX_AddLiquidity`**, **`UCXX_AddLiquidityClientInfo`**, **`UCX_Swap`** — shared SWP liquidity and swap math.
- **`DPTF|INFO_ClearDispo`** — sums several `SIP|URC_*` legs to match a multi-step clear.
- **`VST|INFO_Awake`**, **`VST|INFO_Slumber`** — multi-step vesting + TFT + DPOF cumulators.
- **`VST|INFO-HibernatedNoncesDisplay`**, **`VST|INFO-HibernatedNonceDisplay`** — return **`HibernatedNoncesView`** / `[object{HibernatedNoncesView}]`, **not** `ClientInfo` (display helpers using same fee math as awake paths where relevant).
- **`LIQUID|INFO_*`**, **`ORBR|INFO_*`**, **`SWP|INFO_EnableFrozenLP`**, **`SWP|INFO_EnableSleepingLP`**, **`SWP|INFO_Fuel`**, **`SWP|INFO_Firestarter`**, **`SWP|INFO_SinglePoolSwap`**, **`SWP|INFO_MultiPoolSwap`**, **`SWP|INFO_RemoveLiquidity`**.

### 2.3 Comments at bottom of interface

`;;LIQUID|INFO_UnwrapStoa` etc. mark intents; actual defs exist in the module body as **`LIQUID|INFO_*`**.

---

## 3. Cost patterns (how `ifp` / `kfp` are built)

| Pattern | When to use | Typical APIs |
|--------|----------------|--------------|
| **A. Scalar tier** | Single `UDC_*Cumulator` or one `UDC_ConstructOutputCumulator` price in execution | `SIP|URC_Small` … `SIP|URC_Biggest`, `SIP|URC_Burn`, `SIP|URC_Mint`, `SIP|URC_Issue`, `SKP|URC_*` |
| **B. One TFT leg** | One `C_Transfer` / `UDC_TransferCumulator` | `URC_TransferClasses` + `TFT::UDC_TransferCumulator` + `OI|UC_IfpFromOutputCumulator` |
| **C. Folded sum** | Several legs; execution uses `UDC_ConcatenateOutputCumulators` or separate collects | `(fold (+) 0.0 [ifp1 ifp2 …])` then **one** `UDC_DynamicIgnisCost patron ifp` |
| **D. CLAD / swap pipeline** | SWP add liquidity or swap | `SWPL::URC|KDA-PID_CLAD`, `at "perfect-ignis-fee" (at "clad-op" clad)`, plus extra `TFT::UDC_TransferCumulator` for LP delivery (`UCX_AddLiquidity`) |
| **E. Nested INFO** | Sub-flow already has a full INFO | Constrict/Brumate take **`(at "ignis-full" (at "ignis" (VST|INFO_Hibernate …)))`** for the hibernate leg so the **same** decomposition as `VST|C_Hibernate` is reused |

---

## 4. DPTF / DPOF tier INFO ↔ `05_DPTF.pact` / `06_DPOF.pact`

- **`SIP|URC_*` `@doc`** strings are the authoritative map from tier helper → **`DPTF|C_*` / `DPOF|C_*`**.
- **Burn/mint/issue** mirror `UDC_ConstructOutputCumulator` / `C_Mint` / `C_Burn` price keys and `URC_ZeroGAS` / `URC_IsVirtualGasZero` triggers (see earlier burn example in this doc’s history).
- **Transfers:** `DPTF|INFO_Transfer` (and multi/bulk variants) use **`TFT::UDC_*TransferCumulator`** then **`OI|UC_IfpFromOutputCumulator`**, matching how execution composes TFT gas for those moves, plus the same Elite/Ouro dispo **pre-text** checks as the client layer cares about.

**DPOF branding:** `DPOF|INFO_UpdatePendingBranding` uses `(SIP|URC_UpdatePendingBranding 1.5)` vs DPTF’s `1.0` — reflects different execution multiplier for DPOF pending branding.

---

## 5. ATS complex INFO ↔ Talos + `10_ATSU.pact` + `11_VST.pact`

User-facing Talos entrypoints (`03_TS01-C2.pact` etc.) call **`IGNIS::C_Collect patron`** on a single **`OutputCumulator`** produced downstream. INFO must sum the same virtual legs **in order** as **`UDC_ConcatenateOutputCumulators`** in the callee.

| Talos / UI concept | Collects from | INFO-ONE defun | Match execution by |
|--------------------|----------------|----------------|---------------------|
| Coil | `ATSU::C_Coil` | `ATS|INFO_Coil` | Same `ATS::URC_RewardBearingTokenAmounts`; same three steps: TFT transfer RT → mint RBT → TFT transfer RBT (compare `10_ATSU.pact` `C_Coil` ico1–ico3 with INFO `ifp1`–`ifp3`). |
| Curl | `ATSU::C_Curl` | `ATS|INFO_Curl` | Two `CoilData` computations + four legs (transfer, mint, mint, transfer) like `C_Curl`. |
| Constrict | `VST::C_Constrict` | `ATS|INFO_Constrict` | Same `URC_RewardBearingTokenAmountsWithHibernation`; legs: TFT transfer, mint, **then** hibernate cost via **nested `VST|INFO_Hibernate`** `ignis-full` (equivalent to concatenating `C_Hibernate` cumulator in `11_VST.pact` `C_Constrict`). |
| Brumate | `VST::C_Brumate` | `ATS|INFO_Brumate` | First coil plain, second `WithHibernation`, then nested **`VST|INFO_Hibernate`** for the final hibernate leg — mirrors `C_Brumate` ico1–ico4. |
| Cold recovery | `ATSU::C_ColdRecovery` | `ATS|INFO_ColdRecovery` | Same `URC_WhichPosition`, `URC_ColdRecoveryFee`, `UC_PromilleSplit`, `URC_RTSplitAmounts`, elite tier duration index as execution; flat + optional `ATSU::UDC_UnlimitedUncoilCumulator` + TFT transfer + burn + fee burns. **Re-audit** against `10_ATSU.pact` whenever changing `C_ColdRecovery` (INFO uses parallel `ifp*` fold). |
| Cull | `ATSU::C_Cull` | `ATS|INFO_Cull` | Same `ATSU::URC_MultiCull` / `URC_SingleCull` arrays and `UC_AddHybridArray` as INFO; `2.0 × ignis|biggest` + conditional `TFT::UDC_MultiTransferCumulator` matches execution’s flat + transfer pattern. |
| Direct recovery | `ATSU::C_DirectRecovery` | `ATS|INFO_DirectRecovery` | Transfer cold RBT, burn, multi-transfer RTs — same structure as `C_DirectRecovery` in `10_ATSU.pact`. |

**Important:** Coil/Curl INFO builds **read-only** cumulators via `TFT::UDC_TransferCumulator` / `SIP|URC_Mint` instead of calling `C_Transfer` / `C_Mint`, but the **types, amounts, and accounts** must match `ATSU`’s `C_Coil` / `C_Curl` list passed to `UDC_ConcatenateOutputCumulators`. After any change to those `C_*` functions, diff the INFO `ifp` lines in the same order.

---

## 6. VST INFO ↔ `11_VST.pact`

- **`VST|INFO_Hibernate`** — decomposes into `SIP|URC_Medium` + `TFT::UDC_TransferCumulator` + `SIP|URC_Small` (mint path for DPOF leg), folded; mirrors the hibernate client chain.
- **`VST|INFO_Awake`** — `DPOF::UC_MoveCumulator`, `SIP|URC_Small`, conditional `SIP|URC_Burn` for hibernating fee token, plus TFT transfer for remainder.
- **`VST|INFO_Slumber`** — combines `UDC_ConstructOutputCumulator` (per-nonce `ignis|biggest` stack), `2 × SIP|URC_Biggest`, `DPOF::UC_WipeCumulator`, conditional TFT transfers and `DPOF::UC_MoveCumulator` for locked remainder — reflects the long `C_*` / concatenate chain in vesting.

---

## 7. SWP / MTX liquidity and swap ↔ `UCX_*`, `20_MTX-SWP.pact`, `18_SWPLC.pact`

- **`SWP|INFO_AddLiquidity` / `IcedLiquidity` / `GlacialLiquidity`** — thin wrappers: **`UCX_AddLiquidity`** with flags `(true,true)`, `(false,true)`, `(false,false)` matching **`MTX|C_AddLiquidity`** / `C_AddIcedLiquidity` / `C_AddGlacialLiquidity` in `20_MTX-SWP.pact`.
- **`UCX_AddLiquidity`** — builds `SWPL::URC|KDA-PID_CLAD` (same as on-chain add-liquidity math), **`ifp1`** from `(at "perfect-ignis-fee" (at "clad-op" clad))`, **`ifp2`** from LP token `TFT::UDC_TransferCumulator` to the user for native LP amount; then **`UCXX_AddLiquidityClientInfo`** for user-facing strings and Kadena slot from `OI|UDC_NoKadenaCosts` (liquidity add is Ignis-only in this path).
- **`SWP|INFO_FrozenLiquidity` / `SleepingLiquidity`** — rebuild `LiquidityData` via `UtilitySwpV1::UC_MakeLiquidityList` + `SWPL::URC_LD` + `URC|KDA-PID_CLAD` with frozen/sleeping flags, extract `perfect-ignis-fee` cumulator, delegate to **`UCXX_AddLiquidityClientInfo`** with `iz-for-frozen` / `iz-for-sleeping` for copy variants.
- **`SWP|INFO_SinglePoolSwap` / `MultiPoolSwap`** — build `UtilitySwpV1.DirectSwapInputData` and call **`UCX_Swap`** (same swap pipeline as described in the generic “heavy compositor” section: multi `TFT` cumulators, optional `SIP|URC_Burn` for liquid leg, folded `ifp`).
- **`SWP|INFO_RemoveLiquidity`** — flat `1000.0` + `UDC_ConcatenateOutputCumulator` over LP transfer + pool token multi-transfer + `SIP|URC_Burn` for LP burn; mirrors remove-liquidity gas structure in `INFO-ONE+`.

---

## 8. LIQUID / OUROBOROS-style INFO

- **`LIQUID|INFO_*`** — compose `TFT::UDC_TransferCumulator` with wrapped Stoa / UrStoa ids + `SIP|URC_Mint` / `SIP|URC_Burn`; unwrap adds extra cost when Kadena target unregistered (`5 × ignis|biggest` style branch) — keep in sync with `LIQUID` client caps.
- **`ORBR|INFO_Compress` / `ORBR|INFO_Sublimate`** — **`OI|UDC_NoIgnisCosts`** / **`OI|UDC_NoKadenaCosts`** (fee is structural / off-ledger in the INFO copy); confirm if execution still matches product expectations.

---

## 9. SWP admin-style INFO

**`SWP|INFO_EnableFrozenLP` / `EnableSleepingLP`**, **`SWP|INFO_Fuel`**, **`SWP|INFO_Firestarter`** — mix `DALOS::UR_UsagePrice` keys, conditional DPTF issue (`ignis|token-issue` + tiers + `dptf` KDA price), `URC_IsNativeGasZero`, etc. Trace the corresponding **`SWPLC` / `SWP` / `MTX-SWP`** `C_*` when editing.

---

## 10. Checklist for a new UI button / new INFO defun

1. Locate **Talos `*|C_*`** or **module `C_*`** that `IGNIS::C_Collect` wraps.
2. List every **`OutputCumulator`** source in order (`TFT`, `DPTF`, `DPOF`, `IGNIS::UDC_ConstructOutputCumulator`, nested concatenate).
3. For each source, either call the same **`UDC_*Cumulator`** / **`SIP|URC_*`** / **`OI|UC_IfpFromOutputCumulator`** as INFO already does for similar legs, or add a new **`SIP|URC_*`** with `@doc` pointing at the new cap.
4. Fold into **one** `ifp` (and one `kfp`) before `OI|UDC_DynamicIgnisCost` / `OI|UDC_DynamicKadenaCost` unless the product intentionally splits (normally one discount application on the total).
5. Add **`InfoOneV1`** signature if the function is part of the stable sovereign API; keep parameter lists aligned with the client entrypoint (`patron` first where used).
6. **Regression habit:** after editing **`ATSU` / `VST` / `MTX-SWP` / `SWPLC`** client code, grep **`INFO-ONE+`** for the matching `INFO_` / `UCX_` block and update the fold.

---

## 11. Related project docs

- `OuronetInformational/ouronet/conventions/x-writes-no-cumulator.md`, `MODULE_ARCHITECTURE.md` — `C_*` returns cumulators consumed by IGNIS; INFO never persists, only simulates prices.
- `OuronetInformational/modules/deploy/info-one-clientinfo.md` — short pointer to this file.
