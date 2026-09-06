# IGNIS/STOA re-pricing — implementation plan

> Target: `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING-SPEC.md`. Ends with REPL tests that observe REAL
> costs and assert them against the planned table; whatever they surface gets fixed. The final
> per-function IGNIS/STOA list is a deliverable for the Chapter-2 documentation constructors.

## The cost architecture (the decision everything else follows from)

Every priced client op charges:

```
IGNIS = deter(op)            ; the deterrence multiplier — a business number
      + components(op)       ; the op's PROPER ignis computation — its real work
STOA  = dollars(deter) / stoa_price      ; ISSUE functions only
```

Both halves live centrally in `02_IGNIS.pact`, so a price is never scattered again:

| constant | holds | source of truth |
|---|---|---|
| `IG|DETER` | per-op deterrence (business decision) | the spec table |
| `IG|COMPONENTS` | per-op computed work cost (the "proper ignis computation") | generated from the static analyser, calibrated to measured gas |
| `IG|WEIGHTS` | primitive weights + surcharges (per-nonce, per-fragment) | calibrated in substage 6 |

and three helpers:

* `UC_IgnisPrice(op-key)` → `deter + components` — the single call every `URCi_*` makes.
* `UC_IgnisPriceScaled(op-key, n)` → `deter + components + n·surcharge` — for per-nonce/per-item ops.
* `UC_StoaPrice(op-key)` → `deter_dollars / stoa_price`, read from the oracle (hard-pegged $0.10
  today) so the **dollar value stays constant** when a real STOA price lands.

Keying by `ENTITY|FN` (the Talos client name) makes the price sheet and the code the same list.

## Phases

**P1 — Foundation (IGNIS module).**
Extend `IG|DETER` with every spec value; add generated `IG|COMPONENTS`; add `UC_IgnisPrice`,
`UC_IgnisPriceScaled`, `UC_StoaPrice` + interface decls. Add the discountable/NON-discountable
distinction (PYTHIA + the asymmetric-liquidity legs are taxed in full). ZALL green.

**P2 — DALOS account-creation STOA switch.**
New flag + `A_ToggleAccountCreationStoa` (admin, exempt) + Talos wrapper; wire
`C_DeployStandardAccount` $5 / `C_DeploySmartAccount` $10 behind it. Default OFF (onboarding).

**P3 — ISSUE functions (IGNIS + STOA together).**
ATS, DPTF, DPOF, DPSF (incl. `C_IssueCompany`), DPNF, SWP ×3 logical pools ×2 paths, VST links
(250 deter), PYTHIA (STOA only, non-discountable). Each gets its STOA leg from `UC_StoaPrice`.

**P4 — Fee-unlock family → flat $50+$50.**
`DPTF|C_ToggleFeeLock`, `ATS|C_ToggleParameterLock`, `SWP|C_ToggleFeeLock`. Retire the escalating
ladder: `U_DEC::UC_UnlockPrice` + `CT_DPTF-FeeLock` + `CT_ATS-FeeLock` become dead.

**P5 — The bulk: rewrite every `URCi_*`.**
Move each off its legacy `UDC_*Cumulator` tier onto `UC_IgnisPrice`/`UC_IgnisPriceScaled`.
~200 readers. INFO functions should need NO change (they call these readers) — verified per module.

**P6 — Retire dead cumulator constructors.**
Once P5 lands: delete `UDC_SmallestCumulator`, `UDC_SmallCumulator`, `UDC_MediumCumulator`,
`UDC_BigCumulator`, `UDC_BiggestCumulator` and any other caller-less constructor from IGNIS
(interface + module). Grep-verified zero callers before each deletion.

**P7 — REPL price tests (the acceptance gate).**
For every SIMPLE function: run it, read the collected IGNIS, assert it equals the planned price
(pre-discount). Same for the STOA leg on ISSUE functions. Failures here are real defects — fix
them, do not adjust the expectation to match.

**P8 — Final list for the documentation chapter.**
Regenerate `IGNIS-PRICE-SHEET.md` from live code, now test-enforced, as the pricing input to the
Chapter-2 Stage-1/Stage-2 documentation.

## Status — 2026-09-06 (end of the owner-decision batch)

| phase | state |
|---|---|
| **P1** foundation | **done** — `IG\|DETER`, `IG\|WEIGHTS`, `IG\|COMPONENTS` (394 ops), `IG\|LEGS`, `UC_IgnisPrice` / `…Scaled` / `UC_IgnisLeg` / `UC_StoaPrice`, `stoa\|price` oracle |
| **P2** account-creation STOA switch | **done** — independent flag + admin fn + Talos wrapper, $5/$10 pegged, default OFF |
| **P3** issue functions | **done** — dollar-pegged STOA legs; non-discountable path for PYTHIA |
| **P4** fee-unlock flat $50+$50 | **done** — escalating ladder off every call path |
| **P5** `URCi_*` migration | **DONE** — **zero deterrence-only readers, zero legacy tier calls on a client path** |
| **P6** retire dead constructors | **open** — the `UDC_<tier>Cumulator` family still has non-client callers; needs a sweep before deletion |
| **P7** acceptance gate | **~90 price assertions** across 8 sweeps (DPTF 17, ATS 16, DPDC 44, DPOF 14, SWP 6, SCORE/RPS 4, AQP family 27, IG\|LEGS 11) + a composed-op floor |
| **P8** documentation list | **ready** — `IGNIS-PRICE-SHEET.md` regenerates from live code and agrees with the chain |

**Price sheet:** 168 simple (exact) · 144 complex (floor) · 40 exempt · 78 unresolved of 352 Talos
client functions. The remaining "unresolved" are extractor limits on composed shapes, NOT missing
readers — see the INFO audit below.

**INFO layer:** 345 of 365 INFO implementations wrap a `URCi_` reader; 14 declare their op free
(gas-station-subsidised hydra slices, ORBR, DSA oracle toggles), 4 are data views, 2 that bypassed
their reader were fixed. 395 of 401 Talos client ops had an INFO preview; the 2 genuinely missing
(`CODEX|C_RotateCodexGuard`, `C_RecordArweaveUpload`) were added.

### Open questions for the owner

1. **`CODEX|C_RotateCodexGuard` / `C_RecordArweaveUpload` are gasless** — no cumulator, no `URCi_`
   reader — yet `IG\|COMPONENTS` carries entries for them (4 / 9). Price them, or delete the
   entries?
2. **P6** — deleting `UDC_SmallestCumulator … UDC_BiggestCumulator` needs each remaining caller
   checked; some are internal legs that legitimately still use a tier.
3. **`SWP|C_IssueStandard` was missing** from the generated `IG\|COMPONENTS` while both siblings
   were present. Added by hand at their value (35). The generator should be re-checked for other
   omissions.

### Verification rules learned the hard way

* **Gate on `ZALL.repl`, never `Z.repl`** for anything price-related — `Z.repl` skips
  `[6.1]_Cumulator.repl`, where the price assertions live. See
  `IGNIS-PRICING/memories/2026-09-06-zall-is-the-real-gate-not-z.md`.
* **A green pipeline is not evidence a price is right.** A half-migrated `(if son …)` branch kept
  charging the legacy NFT price through many green runs. Only an assertion catches that, and only
  if it exercises BOTH branches.
* **`::` modref calls resolve at runtime** — a wrong member or arity deploys clean and dies on
  first call. `python3 REPL/_audit_modref_calls.py` covers that statically (baseline: 2 dead calls,
  both in dead `00_DPMF.pact`; 0 arity mismatches).

## Ordering note

P1 → P2/P3/P4 can proceed in any order → P5 is the long pole → P6 depends on P5 → P7 gates P8.
ZALL stays green after every phase; nothing is "done" until its REPL assertion exists.
