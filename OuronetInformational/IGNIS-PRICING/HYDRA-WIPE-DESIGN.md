# Hydra parallel wipe — substage 1 design (for owner sign-off)

> IGNIS Cost Rehaul, substage 1. Owner directive 2026-09-05: wipes that don't fit one tx must
> be parallelizable — "the UI scans the user, constructs the transactions, then sends them on
> the blockchain all at once", using the VCT vacate know-how. Model extracted from `06_VCT.pact`;
> targets: `06_DPOF.pact` (Stage 1) + `06_DPDC-MNG.pact` (Stage 2, SFT+NFT via `son:bool`).
> Spec authority: `StoicSyntax-Prefixes.md:129-144` (Hydra pattern; wipes are a named migration
> candidate). Status: **IMPLEMENTED 2026-09-05** (owner approved the surface; all of §1 + §2
> built; ZALL deploy chain green; REPL suites `[6.1.6]` TX-OF-002 + new `[6.1.8]_DPDC-HYDRA-WIPE.repl`
> wired into `Stage02_Tester.repl`). Named follow-ups — ALL CLOSED 2026-09-05: the Kursan
> gas-calibration probes ran for BOTH modules (`DPOF-scale-wipe.repl` 405.6 gas/nonce,
> `DPDC-scale-wipe.repl` 952.4 gas/nonce) and the ceilings moved off their guess (DPOF 120->1000,
> DPDC 120->500); the SFT wipe gap left by `[6.1]_DPDC.repl` TX 005b is closed by `[6.1.8]`
> TX-HW-007, a self-contained SFT campaign creating its own fresh DHCD nonces rather than
> reviving that stale state-dependent block;
> 5 ig/nonce pricing lands in rehaul substage 5 via the shared `URCi_WipeCumulator`/INFO point.
> Implementation deviation from §1: the partitioner recomputes `n-final = ceil(l / per-slice)`
> after clamping (VCT's raw math can emit an empty tail slice, e.g. l=4 n=3 → 2/2/0 — ours
> returns 2 slices instead; the plan's own `slice-count` field is authoritative).

## 0. Why wipes are an *easier* Hydra than vacate

| Concern | VCT vacate | Wipe |
|---|---|---|
| Freeze bracket | needs begin/finalize state machine (`XI_EnsureVacateBegun` / `XI_MaybeFinalizeVacate`, vacate-in-progress flag, FVT freezes) | **already exists as a precondition** — the target account MUST be frozen before any wipe (DPOF `UEV_AccountFreezeState … true`; DPDC `UEV_AccountFreezeState id son account true`). The account cannot move nonces mid-campaign. **No new state machine needed.** |
| Idempotency / replay safety | live tracker rows zeroed ⇒ replay fails `(= amount staked-bal)` | **native**: DPOF — a fully-wiped nonce is decommissioned (`supply := -1.0`) ⇒ replay fails `(<= amount nonce-supply)`; DPDC — supply written to `0` ⇒ replay fails `(> amount 0)` in `REMOVE-CLASS-ZERO-NONCES` (:434). Replayed/duplicate slices revert cleanly. **No job/slice tables — same as VCT.** |
| Cross-slice aggregates | score/tracker/rollup state, needs emptiness oracle | DPOF: `Properties.supply` + `total-account-supply` are read FRESH per call and decremented additively ⇒ slices compose in any order. DPDC: per-nonce writes fully independent, **no aggregate at all**. |
| Amount staleness | OF amounts resolved on-chain from tracker (forces `CCp_`) | DPDC `WIPE-SFT-NONCES` **re-reads amounts live** (:312) ignoring `r-amounts` ⇒ over-wipe impossible; DPOF validator caps `amount ≤ nonce-supply`. Slice payload amounts are safe by construction. |

Consequence: the wipe Hydra is **preflight + slices only** — the bracket phase of the pattern is
"optional" per spec and here it is genuinely not needed. Order-independent, retryable, disjoint.

## 1. New surface (names + outcomes — the sign-off object)

### 1.1 `06_DPOF.pact` (Stage 1)

| fn | kind | signature | outcome |
|---|---|---|---|
| `UC_ComputeMinWipeSliceCount` | UC | `(nonce-count:integer) -> integer` | UI seed: `ceil(nonce-count / WIPE-SLICE-MAX-NONCES)`, min 1. Mirrors VCT `UC_ComputeMinSliceCount` (a seed + generous backstop, NOT the optimizer — the UI /local-simulates and adds slices). |
| `UC_BuildWipeSlicePlan` | UC | `(removable-nonces-obj:object{RemovableNonces} slice-count:integer) -> object{DPOF\|WipeSlicePlan}` | Pure partitioner: contiguous, disjoint `take/drop` ranges over `r-nonces`/`r-amounts` (VCT :848-853 math). **Never emits an empty slice** (guards the DPDC eager-`at 0` abort; supersedes `UC_TakePureWipe`'s prefix-only + strictly-`<` limitations). |
| `URHC_BuildWipeSlicePlan` | URHC | `(account:string id:string slice-count:integer) -> object{DPOF\|WipeSlicePlan}` | The ONE heavy read (UI /local only): `URHC_WipePure` → `UC_BuildWipeSlicePlan`. |
| `Cp_WipeSlice` | **Cp_** | `(account:string id:string removable-nonces-obj:object{RemovableNonces}) -> OutputCumulator` | Wipes exactly one slice. Same cap chain as `C_WipePure` (`DPOF\|C>WIPE` → freeze + can-wipe + owner + per-nonce validation) — true `Cp_` (no heavy read in tree; amounts hoisted into preflight). Body = `C_WipePure`'s engine. |

Schema (module-local, after `RemovableNonces` conventions):

```pact
(defschema DPOF|WipeSlicePlan
    account:string
    id:string
    slice-count:integer
    slices:[object{DpofUdcV2.RemovableNonces}])
```

Constants: `WIPE-SLICE-MAX-NONCES` (start 120; calibrate vs `env-gas` in the REPL — DPOF is
~6 reads + 1–2 writes per nonce; VCT-style generous backstop, node gas meter is the real gate).

### 1.2 `06_DPDC-MNG.pact` (Stage 2 — SFT + NFT via `son:bool`)

| fn | kind | signature | outcome |
|---|---|---|---|
| `UC_ComputeMinWipeSliceCount` | UC | `(nonce-count:integer) -> integer` | as DPOF |
| `UC_BuildWipeSlicePlan` | UC | `(removable-nonces-obj:object{DpdcManagementV2.RemovableNonces} slice-count:integer) -> object{DPDC-MNG\|WipeSlicePlan}` | as DPOF; also fixes the "final slice" `UC_TakePureWipe` off-by-one by superseding it |
| `URHC_BuildWipeSlicePlan` | URHC | `(account:string id:string son:bool slice-count:integer) -> object{DPDC-MNG\|WipeSlicePlan}` | `URHC_WipePure` → `UC_BuildWipeSlicePlan` (UI /local only) |
| `Cp_WipeSlice` | **Cp_** | `(account:string id:string son:bool removable-nonces-obj:object{…RemovableNonces}) -> OutputCumulator` | Same cap chain as `C_WipePure` (`WIPE-SFT-NONCES`/`WIPE-NFT-NONCES` → frozen + can-wipe + `REMOVE-CLASS-ZERO-NONCES` incl. the split-data escrow guard + class-0 + owner-via-debit) — every safety property is inherited per slice, including escrow immunity. |

Schema mirrors DPOF's with `son:bool` added. The Talos `[removable-nonces-obj]` cumulator
payload shape (:502) is preserved — wrappers keep digging `r-nonces` out of `output`.

### 1.3 Talos wrappers (1:1, VCT style — one `IGNIS::C_Collect patron <oc>` per slice tx)

- `TS01-C1` (Stage 1): `DPOF|Cp_WipeSlice (patron id account removable-nonces-obj)`
- `TS02-C1`: `DPSF|Cp_WipeSlice (patron account id removable-nonces-obj)` (son=true)
- `TS02-C2`: `DPNF|Cp_WipeSlice (patron account id removable-nonces-obj)` (son=false)

(Argument order follows the existing multi-wipe wrappers `(patron account id …)` on the DPDC
side and `(patron id account …)` on the DPOF side — matching each module's own siblings.)

**ELITE re-rank (DPOF Talos):** `ELITE::XE_UpdateEliteSingle` runs per slice, same as the
existing wipe wrappers. It recomputes from live state, so whichever slice lands last leaves the
correct final rank — correct under any parallel arrival order. (Suppressing it per-slice with a
`finalize:bool` was considered and rejected: under true parallelism no slice knows it is last.)

### 1.4 INFO cost previews (spec names, `StoicSyntax-Prefixes.md:143-144`)

- `INFO_DPOF|WipeSlice (patron id account removable-nonces-obj)` — from the slice's own args;
  mirrors `URCi_WipeCumulator` byte-for-byte (today: `N × ignis|small`; substage 5 swaps in the
  5 ig/nonce constant — single-point change).
- `INFO_DPOF|WipeFull (patron id account plan)` — Σ over the plan's slices.
- `INFO_DPSF|WipeSlice` / `INFO_DPNF|WipeSlice` / `INFO_DPSF|WipeFull` / `INFO_DPNF|WipeFull` —
  same, in `Z_Reads/01_INFO-TWO.pact` next to the existing `INFO_DP*|WipePure` readers
  (Stage-1 DPOF versions in `Z_Reads/02_INFO-ONE+.pact`).

## 2. In-pass hygiene fixes (same files, same substage)

1. **DPOF `XI_DebitNonces` dead binding** (:2317): `nonce-holder` bound, never used — one wasted
   read per nonce. Remove.
2. **DPOF `XI_IncrementNoncesExcluded` hot row** (:2399): today N read-modify-writes on
   `Properties` per slice; batch to one `+= K` per slice (`XI_IncrementNoncesExcludedBy k`).
3. **`UC_TakePureWipe` off-by-one** (both modules): `(enforce (< size l))` rejects `size == l` —
   the helper can never take the whole set. Superseded by `UC_BuildWipeSlicePlan`; existing
   callers untouched, helper kept (deprecated in @doc) for call-site stability.

## 3. What is deliberately NOT built

- **No begin/finalize bracket, no job/slice tables, no vacate-in-progress analogue** — the
  freeze precondition + native replay-revert make them dead weight (VCT's "no Job/Slice
  tables, offline plan only" doctrine, applied even harder).
- **No DPTF wipe hydra** — true fungibles have one balance, no nonce dimension; `C_WipeSlim`
  always fits one tx.
- **No changes to the existing `C_Wipe*` family** — solo wipes remain the path for small sets
  (UI tries Full first, VCT README flow); Hydra is additive.
- **No new pricing** — cumulators keep today's `N × ignis|small`; the 5 ig/nonce constant lands
  in substage 5 via the IGNIS defconsts, flowing through exec + INFO from one point.

## 3b. UI guidance — plan slices are OPAQUE payloads in LEX order

`URH_AccountNonces` is a `select`; table keys are strings, so nonce rows come back in
**lexicographic** key order (`…|10` sorts before `…|9`), not numeric order. Consequently the
plan's slices are lex-ordered and the UI must treat them as opaque payloads: hold them, fire
them, never reconstruct them from assumed numeric ranges. (Any disjoint cover of viable
nonces is legal — the executor validates each slice independently — but the safe workflow is
"use exactly what the preflight returned".) Proven by `[6.1.8]` TX-HW-002.

## 4. Failure / edge semantics (per-slice)

- **Duplicate or replayed slice** → reverts (wiped nonce fails supply validation). No damage.
- **Owner unfreezes target mid-campaign** → remaining slices revert on the freeze check.
  Fail-safe; UI re-plans from remains (`URHC_WipePure` re-read returns what's left — the VCT
  "construct remains is implicit" property holds identically).
- **DPDC escrow nonce in a slice** → whole slice reverts at `REMOVE-CLASS-ZERO-NONCES`
  (fragment-backing guard). Preflight already filters non-viable nonces, so this only happens
  if state changed between plan and fire — correct outcome.
- **Empty slice** → cannot be constructed (`UC_BuildWipeSlicePlan` guards); direct call with
  `[]` reverts in validation before any write.

## 5. Test plan (canonical layout, mirrors `[6.2.1]`/`[6.2.2]` + `AQP-scale-vacate.repl`)

New `REPL/Stage_02/[6.1.8]_DPDC-HYDRA-WIPE.repl` + additions to `[6.1.6]_DPOF.repl`:
1. Preflight-plan tx: mint K nonces, freeze, `URHC_BuildWipeSlicePlan … N`, assert slice-count
   + disjointness + no empty slice + full coverage.
2. N slice txs (simulated sequentially, `env-gas 0` per tx): assert per-slice gas ≤ budget,
   remaining-nonce count decreases, freeze holds.
3. Replay tx: re-fire slice 0 → `expect-failure` (idempotency proof).
4. Negatives: unfreeze mid-campaign → slice reverts; escrow nonce (DPDC) → slice reverts;
   `C_WipeClean` on already-wiped nonce → reverts.
5. Terminal: `URHC_WipePure` returns empty; supplies/rollups exactly zeroed; DPOF
   `nonces-excluded` incremented by exactly K.
6. Kursan scale probe (`REPL/Kursan/DPOF-scale-wipe.repl`): many-nonce account, measure
   gas/nonce, calibrate `WIPE-SLICE-MAX-NONCES`.

Also revive the commented-out SFT wipe tests (`[6.1]_DPDC.repl` TX 005b :491-546) — SFT
multi-nonce wipes currently have **zero live coverage**; the hydra REPL doubles as that fix.

## 6. Build order (greenfield workflow)

1. Schemas + constants (both modules) — `WipeSlicePlan`, `WIPE-SLICE-MAX-NONCES`.
2. `UC_` partitioners + seeds (pure; REPL-testable immediately).
3. `URHC_BuildWipeSlicePlan` (thin composition over existing `URHC_WipePure`).
4. `Cp_WipeSlice` × 2 modules (reusing the existing cap chains verbatim).
5. Hygiene fixes (§2).
6. Talos wrappers × 3 + interface entries (stay on current interface version per policy —
   pre-mainnet, edit in place).
7. INFO Full/Slice readers.
8. REPL suites + green run of `Stage02_Tester.repl` (and Stage 1 for DPOF).
