# Procedure — Building the AQP Info Module (`AQP-INFO`)

> **What this is.** The step-by-step methodology for creating the **info-function counterpart** of every
> AQP user/admin entrypoint, and for **proving** each info function reports the *same* cost the execution
> function actually bills. Read this in full before writing any `AQP-*|INFO_*` function. It settles the
> unknowns; after that the work is mechanical — take one user function at a time, write its info function
> mirroring its cost logic, and test the two against each other.
>
> Load order context: this is an Ouronet Pact task — obey `OuronetInformational/SKILL.md` +
> `StoicSyntax.md`. Reference modules: `1_SOVEREIGN/STAGE_01/2_Core/03_INFO-ZERO.pact` (the `OI|*`
> toolkit), `1_SOVEREIGN/STAGE_01/2_Core/21_INFO-ONE+.pact` (the `INFO-ONE` module — the canonical
> populated info module), `1_SOVEREIGN/STAGE_02/2_Core/INFO-TWO.pact` (the stage-2 example).

---

## 0. Purpose and the one rule

An **info function** is a **read-only cost preview**. The UI calls it *before* the user commits an
operation, and renders exactly what will happen and exactly what it will cost **that specific account**
(IGNIS = Ouronet virtual gas, and STOA/KDA = native gas), including that account's gas discounts and the
current zero-gas toggle state.

**THE GOLDEN RULE — mirror the execution's cost logic byte-for-byte.**
The info function must compute its cost using the **identical** logic the execution function uses to build
its `OutputCumulator` (and any STOA `KDA|C_Collect`). Same `GAS|` constant, same `UR_UsagePrice` tier(s),
same multipliers, same conditional branches, same per-leg reconstruction, same `URC_IsVirtualGasZero` /
`URC_IsNativeGasZero` gate. If the execution computes cost with complex logic (e.g. multi-leg
stake/collect, `count × price`, ladder Coil/Curl), **port that whole computation** into the info function
(or into a shared `SIP|`/`SKP|` helper) so the number is *exact*, never approximated. This is the same
discipline used by `ATS|INFO_Coil` / `ATS|INFO_Curl` / `ATS|INFO_Brumate` in `INFO-ONE`, which port the
full ATS cost computation verbatim.

Pre-made **fixed-cost helper functions** (`SIP|URC_*` "Simple Ignis Price", `SKP|URC_*` "Simple Kadena
Price") are allowed and encouraged for the *simple* cases (a single tier read behind the zero-gas gate) —
INFO-ONE uses them heavily — but a helper never *replaces* real logic; it only factors out a
repeated-verbatim expression.

---

## 1. The return object — `object{OuronetInfoV1.ClientInfo}`

Schema (interface `OuronetInfoV1`, `1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact`):

```
(defschema ClientInfo
    pre-text:[string]     ;; what the operation IS about to do (+ the execution function it maps to)
    post-text:[string]    ;; the success outcome the user will see afterwards
    ignis:object{ClientIgnisCosts}
    kadena:object{ClientKadenaCosts}
    output:list)          ;; computed preview values the UI/caller needs back (amounts, weights, ids…)

(defschema ClientIgnisCosts
    ignis-discount:decimal   ;; the account's IGNIS discount factor in [0,1] (1.0 = no discount)
    ignis-full:decimal       ;; the FULL pre-discount IGNIS cost (the raw ifp)  <-- test anchor
    ignis-need:decimal       ;; what THIS account actually pays = discount × full  <-- UI headline
    ignis-text:string)       ;; human sentence describing the IGNIS charge

(defschema ClientKadenaCosts
    kadena-discount:decimal
    kadena-full:decimal      ;; FULL pre-discount KDA cost (the raw kfp)          <-- test anchor
    kadena-need:decimal      ;; what THIS account actually pays = discount × full  <-- UI headline
    kadena-split:[decimal]   ;; kadena-need split 10/20/30/40 across targets
    kadena-targets:[string]  ;; the 4 recipient accounts for the split
    kadena-text:string)
```

- **`ignis-full` / `kadena-full`** are the account-independent *source* costs — these are what the
  cost-equality test asserts against the execution.
- **`ignis-need` / `kadena-need`** are the account-specific headline numbers the UI shows.
- The `text` fields are ready-to-render sentences (built by the `OI|` helpers — you never hand-write them).

---

## 2. The `OI|*` toolkit (borrow from `INFO-ZERO`, never redefine)

Bind INFO-ZERO once per info function and call through it — do **not** redefine these:

```
(ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
```

| Helper | Use it to… |
|---|---|
| `OI|UDC_ClientInfo a b c d e` | assemble the final `ClientInfo` (pre, post, ignis, kadena, output) |
| `OI|UDC_DynamicIgnisCost patron ifp` | wrap a raw ifp → `ClientIgnisCosts` (auto `No…` when ifp=0) |
| `OI|UDC_IgnisCosts patron ifp` | force the discounted-cost path (ifp>0) |
| `OI|UDC_NoIgnisCosts` | "free of IGNIS" (subsidised / zero-gas) |
| `OI|UDC_DynamicKadenaCost patron kfp` | wrap a raw kfp → `ClientKadenaCosts` (auto `No…` when kfp=0) |
| `OI|UDC_KadenaCosts patron kfp` | discounted STOA cost + 10/20/30/40 split + targets |
| `OI|UDC_FullKadenaCosts kfp` | STOA cost with NO account discount (discount=1.0) |
| `OI|UDC_NoKadenaCosts` | "free of KDA" |
| `OI|UC_IfpFromOutputCumulator ico` | sum the `ignis` of every `ModularCumulator` in a reconstructed cumulator → an ifp |
| `OI|UC_ShortAccount acct` | `k:abcd…xyz` display form |
| `OI|UC_FormatTokenAmount amt` | 4-dp token amount string (for `output`/text) |
| `OI|UC_FormatIndex idx` / `OI|UC_ConvertPrice p` | index / fiat-price display strings |

The discount + text formatting lives entirely inside `OI|UDC_IgnisCosts` / `OI|UDC_KadenaCosts`
(they read `URC_IgnisGasDiscount` / `URC_KadenaGasDiscount` for the account). **Your job is only to
produce the exact raw `ifp` and `kfp`.**

---

## 3. The billing model you are mirroring

- The execution builds its cumulator as `(IGNIS.UDC_ConstructOutputCumulator ifp active-account trigger [])`
  where **`trigger = (IGNIS.URC_IsVirtualGasZero)`**. When `trigger` is true, `IGNIS.C_Collect` charges
  **0**. `URC_IsVirtualGasZero` is true whenever DALOS `UR_VirtualToggle` is **off**.
- STOA/native charges are gated the same way by **`URC_IsNativeGasZero`** (DALOS `UR_NativeToggle`).
- So an info function mirrors the gate:
  ```
  (if (ref-IGNIS::URC_IsVirtualGasZero) (OI|UDC_NoIgnisCosts) (OI|UDC_IgnisCosts patron ifp))
  ;; STOA:
  (if (ref-IGNIS::URC_IsNativeGasZero) (OI|UDC_NoKadenaCosts) (OI|UDC_FullKadenaCosts kfp))
  ```
  `OI|UDC_DynamicIgnisCost` / `OI|UDC_DynamicKadenaCost` fold the "0 → No…" case for you, but they do
  **not** check the toggle — if you want the info to blank out under an active gas-station toggle, gate on
  `URC_IsVirtualGasZero` / `URC_IsNativeGasZero` explicitly (as `DALOS-INFO|URC_ControlSmartAccount` and
  `DALOS-INFO|URC_DeploySmartAccount` do). **Default AQP convention: gate explicitly**, so the preview
  tracks the live toggle.

---

## 4. AQP cost taxonomy → recipe per category

Every AQP entrypoint falls into one of these. (Full per-function catalog: the AQP surface map — ANK/SCORE/
POOL/FVT/VCT/MTX/DSA — kept alongside this file; each row lists the exact `GAS|` const / tier.)

### 4a. Fixed-`GAS|` IGNIS op (the common case)
The execution passes a module-local `(defconst GAS|<OP> N)` to `UDC_ConstructOutputCumulator`. Those
constants **are readable cross-module** as `Module.CONST` (verified: `AQP-FVT.GAS|COLLECT` ⇒ `500.0`).
```
(ifp:decimal AQP-FVT.GAS|COLLECT)      ;; read the SAME constant the execution bills — zero drift
...
(if (ref-IGNIS::URC_IsVirtualGasZero) (OI|UDC_NoIgnisCosts) (OI|UDC_IgnisCosts patron ifp))
(OI|UDC_NoKadenaCosts)                  ;; most AQP ops carry no STOA
```
Applies to: FVT config/inject/collect/unstale, POOL add/revoke-score & stake toggles & anchor-syncs,
SCORE triplet/model functions, DSA define-vault/oracle/royalty/fee/open/recompute.

### 4b. STOA-charging issue op
Issue ops (`SCORE.C_Issue*`, `POOL.C_Issue`, `FVT.C_Issue`, `ANK.C_Issue*`) also charge native STOA via
`UR_UsagePrice`. Mirror the tier **and** any multiplier/branch:
- SCORE/POOL/FVT issue → `kfp = (ref-DALOS::UR_UsagePrice "smart")`.
- ANK issue → IGNIS is an **inline `1000.0`** (no defconst — hardcode `1000.0` with a comment pointing at
  the source line) and STOA `kfp = (ref-DALOS::UR_UsagePrice "standard") × (if acnoi 2.0 1.0)` — the
  `acnoi` branch **must** be mirrored (acnoi creates a BoostClass inline = 2× STOA).
```
(if (ref-IGNIS::URC_IsNativeGasZero) (OI|UDC_NoKadenaCosts) (OI|UDC_FullKadenaCosts kfp))
```

### 4c. Computed-IGNIS op
SCORE definition writers bill `count × UR_UsagePrice "<tier>"`:
- `C_IssueSemiFungibleScoreDefinition` → `(* (dec (length nonces)) (ref-DALOS::UR_UsagePrice "ignis|big"))`
- `C_IssueNonFungibleScoreDefinition` / `…SetScoreDefinition` → `… × UR_UsagePrice "ignis|biggest"`.
Port the exact `length`/multiplier expression from the execution.

### 4d. Variable-cost / batch entrypoints — the **preflight-plan + per-leg-unit** pattern (owner-mandated)
Some entrypoints have **no single `GAS|` const** and no simple formula — their cost is a live sum of
sub-cumulators that scales with state: how many owner-legs / nonces a vacate touches, how many employed
scores a stake settles, how many stale members a fresh-inject fixes, how many holders a sweep re-scores.
For **all** such variable-cost `CC_`/`A_`/stake-flow functions, use the **same uniform architecture** — one
dirty-read serves three consumers (the UI's capacity split, the batch execution, and this cost preview):

1. **A URH "preflight" dirty-read** that enumerates the work — the leg/plan list. AQP already has these
   (e.g. `URHC_BuildVacateSlicePlan`, `URHC_VacateUnitCountForKind`, `URH_Vacate*PoolLegs` for vacate;
   `URC_PoolActiveScoreIds` for a stake's employed scores). The UI runs it once to split the operation into
   capacity-bounded batches; the **info function consumes the same reader** for its count.
2. **A per-leg IGNIS *unit* reader** that the execution flow itself multiplies out — a single non-mutating
   `URC_…IgnisUnit` const (like `URC_StakeScoreDeltaIgnisUnit`). Wire the SAME unit into the flow's cost
   construction *and* the info function, so the two can **never diverge** (drift-proof). Where a core flow
   doesn't yet expose such a unit, **add a thin `URC_…IgnisUnit` reader and route the flow's cost through it**
   — this is a sanctioned, minimal core change; do not approximate.
3. **The info computes** `base-fixed-legs + (per-leg-unit × preflight-count) [+ reconstructed one-off legs
   via `ref-TFT::UDC_TransferCumulator` etc.]`, all behind the `UC|GasPrice` toggle gate, then
   `OI|UC_IfpFromOutputCumulator` / `fold (+)` as needed.

Two info shapes per such family:
- **`…|INFO_<Op>Full(pool/fvt-id, asset-id, kind)`** — runs the preflight URH → total count → **grand-total
  cost** + the slice breakdown (batch count + per-batch cost) for the UI's "whole operation" preview.
- **`…|INFO_<Op>Batch…(the same slice args the CC_ execution takes)`** — the leg list for one capacity
  batch IS the execution's args, so the info consumes them directly → that batch's **exact** cost.

This is the `ATS|INFO_Coil` reconstruction idea generalized: instead of hand-porting each leg, the flow and
the info share a preflight-count + per-leg-unit contract. Ladder-collect (MULTIPLET Coil/Curl legs) is the
degenerate case — reconstruct the 2 ATS legs via `ref-ATS::URC_RewardBearingTokenAmounts` + `SIP|URC_*`.
`post-text` still names the state-dependent portion.

### 4e. Subsidised / gas-station-paid op
`CC_*FixChunk`, `CC_UnstaleAll`, the sweep pages (`CC_SweepBegin/RecomputeChunk`) charge the patron
nothing (gas-station subsidised). → `OI|UDC_NoIgnisCosts` + `OI|UDC_NoKadenaCosts`, and say so in text.

### 4f. Admin `A_` returning `:string` (GOV switches)
`A_ToggleExternalOracle`, `A_SetOracleValidity` are master-signed, bill no IGNIS/STOA → both `No…`; the
info exists only to render "governance action, no gas."

---

## 5. `pre-text` / `post-text` / `output` conventions

- **`pre-text`** — one or more strings: an `"Operation: <plain description of what it does>."` line, then a
  line naming the **execution function** the button must call, e.g.
  `"Executes via TS02-C3.AQP-FVT|C_Collect."`. (Descriptive text is left to the author's judgement — you
  know what each function does; be accurate and user-facing.)
- **`post-text`** — the success sentence the user sees after (use `OI|UC_ShortAccount` for accounts).
- **`output`** — the machine-consumable preview payload: computed values the caller/UI needs *before*
  execution — e.g. for `INFO_Collect` the claimable amount (`URC_CollectClaimableRewards`), for
  `INFO_Inject` the resulting per-member slice, for a stake the resulting weight/denominator. Empty `[]`
  for pure control/admin ops. Format decimals with `OI|UC_FormatTokenAmount`.

---

## 6. The `AQP-INFO` module skeleton

New file: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_AQP-INFO.pact`. Deploys **after** every AQP core
(`01_ANK`…`07_DSA`) and TS02-C3 — it only reads their state + constants, never writes.

```
(interface AqpInfoV1
    @doc "AQP pre-execution cost-preview surface. Each AQP-<MOD>|INFO_<Fn> mirrors the cost logic of the \
        \ TS02-C3 execution wrapper it maps to and returns object{OuronetInfoV1.ClientInfo}."
    ;; declare every AQP-<MOD>|INFO_<Fn> here, returning :object{OuronetInfoV1.ClientInfo}
    ;; plus any SIP|URC_* / SKP|URC_* local helpers
)
(module AQP-INFO GOV
    (implements AqpInfoV1)
    ;;{G1} (defconst GOV|MD_INFO|AQP (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2} (defcap GOV () (compose-capability (GOV|INFO|AQP_ADMIN)))
    ;;     (defcap GOV|INFO|AQP_ADMIN () (enforce-guard GOV|MD_INFO|AQP))
    ;;{G3} (defun GOV|Demiurgoi () (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;; POLICY {P1..P4} empty (read-only module, no IMC)
    ;; local SIP|URC_* / SKP|URC_* + UC|GasPrice helpers (mirror INFO-ONE lines 465-637)
    ;; then one AQP-<MOD>|INFO_<Fn> per user function, grouped by source module
)
```

Reference bindings each info function will open in its `let`:
`(ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)`, `(ref-IGNIS:module{IgnisCollectorV1} IGNIS)`,
`(ref-DALOS:module{OuronetDalosV1} DALOS)`, and the mirrored AQP core(s)
(`AcquisitionAnchorsV1 AQP-ANK`, `AcquisitionScoresV1 AQP-SCORE`, `AcquisitionPoolsV1 AQP-POOL`,
`AcquisitionFarmsVaultsTreasuriesV1 AQP-FVT`, `DsaV1 AQP-DSA`), plus `TrueFungibleTransferV1 TFT` /
`AutostakeUsageV1 ATSU` where a leg is reconstructed.

**Naming:** `AQP-<MOD>|INFO_<Fn>` where `<MOD>` matches the Talos wrapper prefix —
`AQP-ANK|INFO_*`, `AQP-SCR|INFO_*`, `AQP-POOL|INFO_*`, `AQP-FVT|INFO_*`, `AQP-DSA|INFO_*`
(VCT/MTX map under `AQP-POOL|INFO_*` / `AQP-MTX|INFO_*` following their wrappers). Parameters mirror the
**Talos wrapper** signature (what the UI actually calls), not the raw core signature.

**StoicSyntax:** functions are read-only computed previews → they live in the `[URC]` band; local
`SIP|`/`SKP|`/`UC|GasPrice` compute helpers precede them. No caps beyond the GOV block; no tables.

**REPL wiring:** add one load tx to the Stage-2 loader after AQP + Talos (mirror how
`[2.2]_Core.repl` loads `03_INFO-ZERO` / `21_INFO-ONE+`).

---

## 7. Per-function creation checklist

For each user function, in this order:
1. Find its row in the AQP surface map: note the **Talos wrapper signature**, the **`GAS|` const / tier /
   formula**, and whether it charges **STOA**.
2. Classify it (§4 a–f).
3. Write `AQP-<MOD>|INFO_<Fn>` with the Talos-wrapper parameter list, returning
   `:object{OuronetInfoV1.ClientInfo}`.
4. Compute `ifp` (and `kfp`) by **mirroring the execution's exact expression** (read the same `GAS|`
   const / `UR_UsagePrice` tier / port the formula / reconstruct the legs).
5. Gate on `URC_IsVirtualGasZero` (and `URC_IsNativeGasZero` for STOA).
6. Assemble via `OI|UDC_ClientInfo` with accurate `pre-text` (incl. the execution function name),
   `post-text`, and the `output` preview payload.
7. Add its declaration to the `AqpInfoV1` interface.
8. Write its cost-equality test (§8). Green-gate.

Do them **one at a time**, module by module (ANK → SCORE → POOL → FVT → VCT → MTX → DSA), committing per
module group.

---

## 8. The cost-equality test protocol (mandatory per function)

Each info function must be proven to output the **same** cost the execution bills. Two complementary
checks — do **both** where feasible, at minimum the first:

### 8a. Source-equality (always)
Assert the info's **full** (pre-discount) cost equals the execution's exact cost source, evaluated
independently:
```
(let ((info:object (AQP-FVT|INFO_Collect patron fvt-id 3 triplet-id ouro)))
  (expect "INFO_Collect ignis-full == GAS|COLLECT"
    AQP-FVT.GAS|COLLECT
    (at "ignis-full" (at "ignis" info)))
  (expect "INFO_Collect no STOA"
    0.0
    (at "kadena-full" (at "kadena" info))))
```
For §4c computed ops, recompute the formula independently and assert equal. For §4d multi-ICO ops, build
the same leg cumulators in the test and assert `ignis-full == (fold (+) 0.0 [leg ifps])`.

### 8b. Ground-truth billing (where the op is safely runnable in the suite)
With DALOS `VirtualToggle` **on** (real IGNIS billing; and `NativeToggle` on for STOA ops), snapshot the
patron's IGNIS token (GAS-98c486052a51) balance (and STOA), call the info fn, then run the **real Talos
execution** op, snapshot again, and assert the charged delta equals the info's account-specific `need`:
```
(let ((ign0 (ref-DPTF::UR_AccountSupply "GAS-98c486052a51" patron))
      (info (AQP-FVT|INFO_Collect patron fvt-id 3 triplet-id ouro)))
  (ref-TS02-C3::AQP-FVT|C_Collect patron fvt-id 3 triplet-id ouro)
  (expect "billed IGNIS == INFO ignis-need"
    (at "ignis-need" (at "ignis" info))
    (- ign0 (ref-DPTF::UR_AccountSupply "GAS-98c486052a51" patron))))
```
(Only for ops that don't need a special mutating precondition; for setup-heavy ops the source-equality
check in 8a is sufficient.)

Add these to a dedicated suite `REPL/Kursan/aqp-info-tests.repl`, wired into `run-aqp-audit.sh`. A green
run means every AQP button's cost preview provably matches its execution.

---

## 9. Worked example — `AQP-FVT|INFO_Collect`

Execution: `TS02-C3.AQP-FVT|C_Collect(patron, fvt-id, score-entity-type, score-entity-id, reward-dptf-id)`
→ core `AQP-FVT.C_Collect` bills `GAS|COLLECT (=500.0)`, custody payout only (no STOA). The claimable
amount is `AQP-FVT.URC_CollectClaimableRewards`.

```
(defun AQP-FVT|INFO_Collect:object{OuronetInfoV1.ClientInfo}
    (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    @doc "Cost preview for AQP-FVT|C_Collect: collect a reward DPTF from an FVT membership."
    (let
        (
            (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
            ;;
            (ifp:decimal AQP-FVT.GAS|COLLECT)                 ;; SAME constant the execution bills
            (claimable:decimal (ref-FVT::URC_CollectClaimableRewards
                                  patron fvt-id score-entity-type score-entity-id reward-dptf-id))
        )
        (ref-I|OURONET::OI|UDC_ClientInfo
            ["Operation: Collect your claimable reward from this FVT membership."
             "Executes via TS02-C3.AQP-FVT|C_Collect."]
            [(format "Collected {} of reward token {}."
                [(ref-I|OURONET::OI|UC_FormatTokenAmount claimable) reward-dptf-id])]
            (if (ref-IGNIS::URC_IsVirtualGasZero)
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
            (ref-I|OURONET::OI|UDC_NoKadenaCosts)
            [(ref-I|OURONET::OI|UC_FormatTokenAmount claimable)])))   ;; output: previewed payout
```
Test (source-equality): assert `ignis-full == AQP-FVT.GAS|COLLECT` and `kadena-full == 0.0`; optionally the
ground-truth delta after a real `AQP-FVT|C_Collect`.

---

## 10. Build order & completion gate

1. Module skeleton + interface + `SIP|`/`SKP|` helpers + REPL load wiring (green-gate empty).
2. `AQP-ANK|INFO_*` (6) → test → commit.
3. `AQP-SCR|INFO_*` (18) → test → commit.
4. `AQP-POOL|INFO_*` (8) + VCT (9) → test → commit.
5. `AQP-FVT|INFO_*` (25) → test → commit.
6. `AQP-MTX|INFO_*` (2) + `AQP-DSA|INFO_*` (11) → test → commit.
7. Full `run-aqp-audit.sh` green (with `aqp-info-tests.repl`) ⇒ done.

**Completion criterion:** every AQP user/admin entrypoint has an `AQP-<MOD>|INFO_*` counterpart whose
reported `ignis-full`/`kadena-full` provably equals the execution's exact billed cost, and whose
`ignis-need`/`kadena-need` equal the real charge for a given account. Only then is the info module ready to
back the UI (§ the separate AQP-UI construction doc).
