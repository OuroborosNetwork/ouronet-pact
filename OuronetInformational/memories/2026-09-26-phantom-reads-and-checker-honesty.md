# Phantom reads, and three ways a checker lied — 2026-09-26

Session goal was to clear the remaining unresolved chain symbols in OuronetUI /
`@ouronet/ouronet-core`. Started at 20, ended at 11, all 11 with a written reason and a
tool that goes red on a twelfth. Two of the nine fixed were **live user-facing bugs**.

## The finding that generalises: a correct hardcode of a governable parameter

`getHibernateFee` called `DPL-UR.URC_0012_HibernateFee`. `git log --all -S` over every `.pact`
in this repo finds that name **zero times** — it was never deployed, never written, never
existed. So every call was a resolution error, the `catch` fired every time, and the percentage
the Brumate and Constrict modals showed came from a local formula, `0.12 - 0.000008·days`, under
a comment reading *"function may not be deployed yet"*.

**The formula was exactly right.** Mainnet holds `UR_PeakHibernatePromile = 120` and
`UR_HibernateDecay = 0.008`, so `0.12 - 0.000008·d` **is** `max(120 - 0.008·d, 0)/1000`. Nothing
looked wrong. Two tests passed. One of them asserted the fallback *by name* —
`"graceful-degradation contract"` — which named the only code path a degradation.

`ATS|C_SetHibernationFees(patron, executor, ats, peak, decay)` is a live entrypoint. The day a
pool owner uses it, every consumer keeps returning 12% and nothing fails. **A correct hardcode
of a governable parameter is a bug with a delayed trigger, and it is invisible until the trigger
fires.** The tell is not the number; it is that the number's *source* is not the thing that
governs it.

Fixed by reading the four governed inputs in one call and applying the chain's own clamp. The
duplication that remains — a two-term linear interpolation — is **checked rather than trusted**:
`deriveHibernationFee` is driven by recorded output from
`ATS::URC_RewardBearingTokenAmountsWithHibernation`.

### and the denominator that hides a second fee

The oracle is `hibernation-fee / first-input-amount`, **not** `/ primal-input-amount`. ATS takes
the pool's royalty off the deposit and charges hibernation on the remainder. Divide by the
deposit and you get 118.8 against a peak of 120 — which reads as a 1% rounding error rather than
as the 10-promille royalty it actually is. So the true day-zero deduction is **12.88%**, and the
modals show 12%. Surfaced via `getHibernationFeeBreakdown.totalFraction`; whether to display it
is the owner's call.

## The rename class: a prefix-flip sweep leaves exactly the tails that moved

Confirmed in **two** modules, which is what makes it a class rather than an oversight.

| module | fixed by the earlier sweep | left behind |
|---|---|---|
| `INFO-ONE` | 9 rows, `SWP\|INFO_x` → `INFO_SWP\|x` | `INFO_SinglePoolSwap` → `INFO_SWP\|SingleSwapNoSlippage`, `INFO_MultiPoolSwap` → `…MultiSwapNoSlippage` |
| `PYTHIA` | `INFO_DeployApiKey`, `INFO_UpdateDualConsumerLane` | `INFO_LinkDualApiKey` → `INFO_PYTHIA\|Link`, `INFO_UnlinkDualApiKey` → `INFO_PYTHIA\|RevokeLink` |

A rule keyed on the prefix reaches every rename where **only** the prefix moved, and cannot
reach one where the tail moved too — `SinglePoolSwap` became `SingleSwapNoSlippage` the moment a
`WithSlippage` sibling existed. The sweep then *looks* complete, because the names it could see
are all fixed. **When a mechanical rename rule finishes, the residue is not random: it is
exactly the entries the rule's key could not express.**

Cost: `SwapZBOM` calls those two previews on every amount change and swallows the failure
(`catch { setInfoData(null) }`), so the **swap modal has never shown an IGNIS cost preview**.

Verification went past resolution to **roles**: each PYTHIA refusal cites the table keyed on the
argument it was handed — `PYTHIA|T|ApiKeys` for the apollo id, `PYTHIA|T|DualLinks` for the link
key. A name-only check cannot tell those two apart; the error message could.

## Three ways the checkers were wrong, in three different directions

1. **Over-reporting by comment.** A doc banner showing the Pact form it wraps —
   `` * On-chain interactions for C_WrapStoa (ouronet-ns.TS01-C2.LQD)`` — has an open paren
   before the namespace and a close paren after the name, so it matches the call pattern
   *exactly*. That mention alone reported `TS01-C2.LQD` (a **module**, not a function) as broken,
   in two tools. Fixed by stripping **comment-only** lines — deliberately not a general comment
   stripper, because a trailing `//` inside a template literal would take real code with it, and
   that trades over-reporting for the far worse under-reporting.

2. **A skip whose vouching half did not exist.** `check-chain-symbols.py` skips every name
   `staleNames.ts` rewrites, and its docstring said `check-redirect-endpoints.py` kept that
   honest. It did not — that tool read only the DPL-UR table and matched on a `DPL-UR.` prefix,
   so all **52 staleNames replacements went unverified**. The skip and the check were two halves
   of one argument: *a name is excused from the report only because something else vouches for
   where it was sent.* Nothing did. **When a tool excuses something on another tool's authority,
   check that the other tool actually covers it.**

3. **A count that was never zero.** The missing-symbol figure had sat between 20 and 68 for
   weeks. A number that is never zero stops being read, and then the twelfth entry — a real new
   break — arrives among eleven that are fine and nobody can tell. Now an accept-list where each
   entry names its blocker, with STALE detection so a fix clears its own excuse
   (negative-tested). **The list is shared by import, not copied**, because two copies drift and
   a drifted accept-list excuses in one tool what the other still reports.

## Liveness is a claim about another repo's route table

`AppReads/README.md` said all six phantom `URC_00xx` references were *"dead references the UI
names but never reaches"*. Five were. `URC_0012_HibernateFee` is reached from `dashboard.tsx` —
the fee a user reads before locking WSTOA. The claim was checked by grep, which cannot tell a
live read from dead code, which is precisely what that folder's own legacy-read census exists to
avoid.

The authority is `OuronetUI/src/routes/index.tsx` — 49 `<Route>` entries. `poolDetail.tsx` has
none (so `URC_0006/7/8_*` really are dead, and their caller `SwapInterface.tsx` is a superseded
surface); `dashboard.tsx` has one. **Any liveness claim written in the Pact repo is a claim
about a file in a different repo, and should say so.**

## Disposition of all nine fixed

| symbol | action | why that action |
|---|---|---|
| `DPL-UR.URC_0012_HibernateFee` | rewritten against `ATS::UR_*` | live path, four ordinary core readers, no deploy needed |
| `INFO-ONE.SWP\|INFO_Single/MultiPoolSwap` | fixed at source **and** shimmed | source for 5.0.0; shim covers the published 4.6.0 |
| `PYTHIA\|INFO_Link/UnlinkDualApiKey` | shimmed only | issued by `@ancientpantheon/codex`, a package this repo cannot edit |
| `DALOS.UR_DISPOSupply` | repointed to `O-UI-THREE.URC_Dispo` | a real replacement existed; took the raw `…-hover`, since a caller handed a formatted string cannot recover precision |
| `DSP.URC_PrimordialPrices` | removed | no replacement, no live caller (only a commented-out import) |
| `TFT.DPTF-DPMF-ATS\|UR_FilterKeysForInfo` | removed | TFT has no `FilterKeys` member under **any** prefix; zero callers |
| `TS01-C2.LQD` | not a symbol | checker artefact |

Removals are recorded in place rather than done silently: **an export that resolves to nothing is
indistinguishable from one that is merely unused until somebody asks the chain.**

## Still blocked on the owner

- **`DEMIPAD-KPAY.UR_Kpay` has no replacement.** The deployed sale is `DEMIPAD-STOICPAY`, so the
  module name is a rename — but the live module has no per-account data object, only zero-arg
  `UR_KpayID`/`UR_KpayLeft`/`UR_KpayPID` plus `URC_GetMaxBuy`. `KPaySale.tsx`'s shape has to be
  decided, or an AppReads reader written.
- **`MB` (OuroMovieBooster) is not deployed at all** — `describe-module` says *"Cannot find
  module"*. `ouroMovieBoosterFunctions.ts` is written against a design.
- **`SwapInterface.tsx` + `poolDetail.tsx`**: delete, or revive? Reviving needs either a rich
  swap-breakdown reader in Pact or a rewrite against `URCv_05|DirectSwap`'s bare decimal.
