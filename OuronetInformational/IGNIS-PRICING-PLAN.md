# IGNIS/STOA re-pricing — implementation plan

> Target: `OuronetInformational/IGNIS-PRICING-SPEC.md`. Ends with REPL tests that observe REAL
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

## Status — 2026-09-06

| phase | state |
|---|---|
| **P1** foundation | **done** — `IG\|COMPONENTS` 393 ops, `UC_IgnisPrice` / `…Scaled` / `UC_StoaPrice`, `stoa\|price` oracle |
| **P2** account-creation STOA switch | **done** — independent flag + admin fn + Talos wrapper, $5/$10 pegged |
| **P3** issue functions | **done** — dollar-pegged STOA legs; non-discountable path for PYTHIA |
| **P4** fee-unlock flat $50+$50 | **done** — escalating ladder off every call path |
| **P5** `URCi_*` migration | **partial — 97 readers migrated.** The tail is the AQP family (see below) |
| **P6** retire dead constructors | **blocked on P5** — the tier constructors still have live callers |
| **P7** acceptance gate | **6 module sweeps + a composed-op floor; 84 of 97 migrated readers asserted** |
| **P8** documentation list | **regenerable** — `IGNIS-PRICE-SHEET.md` is in sync with the chain |

**P7 coverage.** DPTF 17 · ATS 16 · DPDC 25 readers (44 assertions — both `son` branches) ·
DPOF 14 · SWP 6 · SCORE/RPS 4 · VST composed-op floor. Unasserted: ANK 3, SWPLC 6,
`SCORE::URCi_CombineTripletModel`, `DPDC-I::URCi_IssueCollectionPrice`,
`EQUITY+::URCi_IssueShareholderCollection`, `VST::URCi_CreateSpecialOrtoFungibleLink` — all
state-dependent (SWPLC needs real pool state; the rest need issuance fixtures).

**Price sheet.** 145 simple (exact) · 136 complex (floor) · 40 exempt · 109 unresolved.
The 109 are overwhelmingly the AQP-family gap, not an extraction defect.

### What is NOT done, and why

1. **The AQP-family component gap.** `AQP-SCR\|`, `AQP-POOL\|`, `AQP-FVT\|`, `AQP-DSA\|`,
   `AQP-ANK\|` bill **deterrence only** — ~79 `IG\|COMPONENTS` entries exist for them and nothing
   reads them. Closing it is mechanical (`UC_IgnisDeter k` → `UC_IgnisPrice op k`) but it RAISES
   prices across the AQP surface, so it needs an explicit owner go-ahead.
2. **Per-leg cumulators inside `XI_`/`XB_` writers** — 10 sites, all in AQP, each a flat tier
   (mostly `Medium` = 3). Option A leaves them outside central control; option B makes them named
   `IG\|WEIGHTS` legs. Owner leaned B; not yet done.
3. **`URCi_UpdateNonceField`** — one reader serving ~20 `C_UpdateNonce*` wrappers: uniform price
   or split per wrapper?
4. **`MergeFragments`** moved to `usage` per the recorded owner directive — flagged in case the
   directive itself is stale.

### Verification rules learned the hard way

* **Gate on `ZALL.repl`, never `Z.repl`** for anything price-related — `Z.repl` skips
  `[6.1]_Cumulator.repl`, where the price assertions live. See
  `memories/2026-09-06-zall-is-the-real-gate-not-z.md`.
* **A green pipeline is not evidence a price is right.** A half-migrated `(if son …)` branch kept
  charging the legacy NFT price through many green runs. Only an assertion catches that, and only
  if it exercises BOTH branches.
* **`::` modref calls resolve at runtime** — a wrong member or arity deploys clean and dies on
  first call. `python3 REPL/_audit_modref_calls.py` covers that statically (baseline: 11 dead
  calls, 2 of them in dead `00_DPMF.pact`; 0 arity mismatches).

## Ordering note

P1 → P2/P3/P4 can proceed in any order → P5 is the long pole → P6 depends on P5 → P7 gates P8.
ZALL stays green after every phase; nothing is "done" until its REPL assertion exists.
