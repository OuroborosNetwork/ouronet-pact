# 2026-09-06 — `::` modref calls are resolved at RUNTIME: a whole class of dead calls loads clean

## What was tested (empirically, `pact` in this repo's toolchain — not inferred)

Two 10-line REPL probes (`/tmp/arity_probe.repl`, `/tmp/member_probe*.repl`):

1. **Wrong arity through a modref loads fine.** `(r::f 1 2)` where the target takes one
   parameter — the calling module deploys successfully; the call fails only when executed.
2. **A member missing from the concrete module loads fine.** `(r::nope 1)` — same: clean load,
   runtime failure.
3. **A member that exists on the MODULE but not on the bound INTERFACE works.** Dispatch is
   against the concrete module, so "not declared on the interface" is NOT a defect.

Consequence for this repo: **the pipeline being green proves nothing about call sites that no
test exercises.** A misspelled member or a wrong arg count sits in the source indefinitely,
deploys cleanly, and dies the first time a real user takes that branch.

This is the same failure shape as the IGNIS half-migration bug (2026-09-06): syntactically
valid, load-clean, wrong at runtime, invisible to a green ZALL.

## The audit and what it found

Scanned every `1_SOVEREIGN` + `2_CITIZEN` `.pact` for `ref-X::member` calls whose member does not
exist on the **nearest-bound** module. 11 live-code dead calls (+2 in dead `00_DPMF.pact`):

| site | enclosing fn | dead call |
|---|---|---|
| `3_Talos/02_TS01-C1.pact:404,423` | `DALOS\|C_UpdateEliteAccount`, `…Squared` | `DALOS::EliteAurynID` (it is `UR_EliteAurynID`) — **FIXED** |
| `2_Core/15_SWP.pact` ×7 (1987–2193) | `A_ToggleAsymetricLiquidityAddition`, `C_ToggleAddOrSwap` | `ATS::DPTF\|C_Toggle{Burn,Mint,FeeExemption}Role` — ATS has no such member; the 3-arg shape matches `DPTF::C_Toggle*Role` exactly, and `ref-DPTF` is already bound in the same `let` |
| `2_Core/12_LIQUID.pact:479` | `A_MigrateLiquidFunds` | `DALOS::C_TransferDalosFuel` — no such member, no near-name match |
| `2_Core/16_SWPI.pact:1278` | `URC_W-InverseSwap` | `U\|SWP::UC_ComputedInverseWP` — no such member |

Only the first was fixed: `UR_EliteAurynID` is the unique 0-arg string candidate, so the repair is
unambiguous. The other three need an owner decision on the intended target (and the SWP one also
raises a layering question: a core module calling another core module's `C_`). **Both elite ops
were entirely dead — two Talos client entrypoints — and stayed that way because `[6.11]_INFO.repl`
only covered the INFO *preview*, never the exec.** Exec assertions were added.

Separately, three INFO-ONE+ previews passed `ats` to `URCi_` readers taking a different number of
parameters (`ToggleParameterLock` takes 2, `AddSecondary` and `SetColdRecoveryFees` take 0). All
three were dead on call; fixed, and now exercised by `[6.11] TX-I05`.

## The audit is now a checked-in tool

`python3 REPL/_audit_modref_calls.py` (from the repo root) reproduces this audit: it reports dead
calls and arity mismatches, and exits 1 when either is non-empty, so it can gate a pre-deploy
check. Current baseline: **11 dead calls** (2 of them in dead `00_DPMF.pact`), **0 arity
mismatches**. It is mutation-tested — planting a wrong-arity call makes it fire, so a clean run
means the check ran, not that it silently did nothing.

Coverage sibling-fact: of 442 Talos client ops, only ~10 are never referenced by any REPL
(`VST|C_RepurposeSlumber`, `VST|C_RepurposeHibernating`,
`VST|C_ToggleTransferRoleHibernatingDPOF`, `PYTHIA|A_RevokeLink`, `AQP-FVT|CC_SweepRevokeAnchor`,
`DEMIPAD|C_Withdraw`, `SPARK|C_RedemAllSparks`, `SNAKES|C_Acquire`, `CUSTODIANS|C_Acquire`,
`STOAICO|C_Collect`). The two elite ops were on that list until this session. Untested-and-dead is
the combination to fear: the auditor now covers the "dead" half statically.

## Scanner methodology — three traps that produce garbage findings

Every one of these bit this session before the result was trustworthy (411 → 150 → 56 → 13 hits):

1. **Untyped params.** `(defun UC_AppL:list (in:list item))` — counting only `name:type` tokens
   undercounts. Count top-level tokens instead.
2. **Comments and doc strings.** `@doc` text and `;;` comments mention function names in call-like
   shapes. Strip them first — but preserve newlines and collapse each string to ONE token, or the
   arg counts and line numbers both go wrong.
3. **Ref-name scoping.** `r` / `ref-DALOS` are rebound dozens of times per file. A file-level
   name→module map silently attributes every call to the last binding — this alone manufactured
   22 fake "INFO-TWO calls the wrong module" findings. Resolve to the *nearest preceding* binding.

Rule of thumb learned: if a scan of this codebase returns hundreds of hits, the scanner is broken,
not the codebase. Verify a sample by hand before reporting anything.
