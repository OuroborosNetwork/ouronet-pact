# The sibling rule, and the BAR sentinel as a table key

*2026-09-15. Red-team Stage 15, RT-H-003 — found by mechanically applying RT-A-003's own lesson.*

## The rule

> **When one sibling op guards a state deliberately, check the other siblings for the same state.**

RT-A-003 found `ATS|C_Coil` dividing by a zero index while `ATS|C_Fuel`, its sibling, guarded that
exact state with a carefully-worded message. So I drove **every** ATS client op at the same
zero-index pool and recorded the failure mode:

| op | result |
|---|---|
| Coil / Curl | the new index guard |
| Fuel | its own `index >= 0.1` guard |
| Syphon / Cold / Direct Recovery | clean feature-flag refusals |
| Cull | clean "nothing to cull" message |
| **HotRecovery** | **`No value found in table ouronet-ns.DPOF_DPOF\|T\|Properties for key: \|`** |

One raw database error out of eight ops, leaking an internal table name.

## The bug, and where it had already been fixed

`UR_HotRewardBearingToken` returns the **BAR sentinel** (`"|"`) for a pair with no Hot-RBT — **nine
of the fifteen live pairs**. `C_HotRecovery` bound `h-rbt` from it and, in the *same eager `let`
group*, did `(UR_NoncesUsed h-rbt)` — a DPOF read keyed by `"|"`. Bindings evaluate **before**
`with-capability`, so no guard could run first.

**`C_Recover`, twenty lines below, carries a comment block about this exact bug, fixed 2026-09-12:**

> *"for a token that is not reward-bearing `UR_RewardBearingToken` returns the BAR sentinel, so the
> next binding looked up ATS pair `|` and died with `No value found in table
> ouronet-ns.ATS_ATS|Pairs for key: |`."*

Same sentinel, same eager-`let` ordering, same error shape, different table — and the sibling
immediately above was left alone. **The repair here is the one already written once.**

## Reachability is not hypothetical

`ATS|S>SWITCH-HOT-RECOVERY` checks **only** `CAP_Owner` and the previous toggle value — it does
**not** require a Hot-RBT to exist. So a pool owner can switch hot recovery ON for a pair that has
none, and every caller then meets the raw read. `<<RT-H-003d>>` constructs exactly that state
through the owner's own client op (ANHD owns `Bisthanium`), and `<<RT-H-003e>>` drives it.

Across all 15 live pairs the toggle currently *tracks* Hot-RBT presence exactly — which is why the
hoist alone fixes every pool that exists today, and why the presence check is still needed for the
state an owner can create tomorrow.

## Fix

1. **Hoist** `with-capability` above the binding group in `C_HotRecovery` (the C_Recover repair).
2. **Add** a `URC_IzPresentHotRBT` enforce to `ATS|C>HOT_RECOVERY`, because the toggle and the
   Hot-RBT are independent.

**The hoist is visible in the test itself.** Block 01 now needs a signature it did not need before:
once the capability runs first, `CAP_EnforceAccountOwnership` answers ahead of any business rule —
*authorisation precedes validation*, exactly as ruled. An unsigned call now returns a keyset failure
instead of a table error, and that change of message is the evidence the hoist landed.

## Generalisable

Two instances in one day of the same shape: **a sentinel value flowing into a position that requires
a real one** (`"|"` as a DPOF key; `0` as a divisor). Grep for getters documented to return `BAR`,
then check every consumer — especially consumers inside an *eager `let`*, which no defcap can
protect. `REPL/tools/_eagerlet.py` exists for that ordering question and is worth pointing at the
BAR-returning getters specifically.
