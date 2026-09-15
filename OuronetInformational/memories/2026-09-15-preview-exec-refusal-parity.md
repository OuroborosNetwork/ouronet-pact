# Refusal parity — the half of the first rule nobody checked

*2026-09-15. Red-team Stage 16, family K (new). Three defects found, all fixed.*

## The gap

Ouronet's first rule: **an INFO preview must report the same COST as the execution it previews.**
`_info_measured.py` proves that for all **401** client-facing previews.

Nothing checked the other half: **does the preview REFUSE when the op refuses, and say the same
thing when it does?**

A preview is what a UI calls *before* it submits anything. It has exactly two ways to lie:

1. **quote a cost for an operation that cannot execute** — the user signs, pays gas, and fails;
2. **throw a raw internal error where the op gives a clean refusal** — the user learns nothing about
   their own pair, and the caller cannot even catch it (`try` does not catch arithmetic exceptions).

Both were found live, in one module family, on one pool.

## Found: 3 of 7 ATS ops diverged

Driven at an ATS pair with **index 0 and no Hot-RBT** (five such pairs exist at deploy):

| op | preview | exec |
|---|---|---|
| Coil, Curl | ✓ identical | ✓ |
| **Fuel** | full quote, `ignis-need 0.53`, post-text *"Succesfully fueled …"* | refuses outright |
| **ColdRecovery** | `No value found in table ouronet-ns.ATS_ATS\|Ledger for key: <pool>\|<caller's full 162-char account>` | clean refusal |
| **DirectRecovery** | `Arithmetic exception: div by zero, decimal` | clean refusal |
| **HotRecovery** | refused, but named the missing Hot-RBT | refused, named the toggle |

Fuel is the worst: a **confident prediction of success** for something that cannot happen.
HotRecovery is the subtlest: both messages were *true*, and they still disagreed.

## The bug had THREE layers

`DirectRecovery` carried it in the **exec**, again in **`URCi_DirectRecovery`** (its own eager
`let`), and again in **`INFO_ATS|DirectRecovery`**, whose wrapper re-derives `release-amounts`
*before* it ever calls the cost reader. Fixing the first two left the quote still throwing.

> Exec, cost reader, presentation wrapper — each can hold its own copy. Fixing the one you found
> looks finished.

## Every repair is "share the guard", never "copy the message"

- **`UEV_FuelableIndex`** — new *module-local* helper (no interface change), called by
  `ATSU|C>FUEL` **and** `URCi_Fuel`, so the message exists once.
- The Cold/Direct/Hot previews call **`ref-ATS::UEV_*RecoveryState`** — the very function their own
  capabilities call, so the refusal is identical *by construction*.
- **`URCv_RTSplitAmounts`** gets the zero-index guard once, covering all **ten** of its call sites.
- **`INFO_ATS|DirectRecovery`** binds its cost reader **first**, so the op's gate runs before the
  wrapper's own derivations.

Why Coil and Curl already agreed is the lesson stated positively: their guard lives in `URC_RBT`,
a reader **both paths share**. Shared readers cannot drift.

## Order matters for parity, not only for safety

`ATS|C>HOT_RECOVERY` checks the toggle first and the Hot-RBT second. A preview that checked them the
other way round refused for a **true but different** reason — its own kind of lie. Same guards, same
order, same message.

## Non-vacuity

`<<RT-K-001g>>` requires the same preview to still **quote** a healthy pair. Without it, the ten
parity lines are equally consistent with *"every preview throws"*, which would prove nothing.

## Still open

This swept **ATS only — 7 of 401 previews.** The same question is unasked for DPTF, DPOF, DPDC, SWP,
AQP and the launchpads. The method is cheap and mechanical: pick an input the op refuses, drive
`INFO_<op>` and the client at it, require the same message. **The separating inputs are the hard
part** — a pool with a zero index and no Hot-RBT is what made three divergences visible at once.

## The gate caught a contradiction between two of my own assertions

`<<RT-H-003f>>` was written an hour earlier and expected the preview to say *"has no Hot-RBT"* —
correct at the time, because that was the preview's only guard. Establishing parity then put the
**toggle** check first in the preview, to match the order `ATS|C>HOT_RECOVERY` uses, and that line
went red.

**Parity is the stronger requirement.** With the toggle off, the op names the toggle, so the preview
must name the toggle. The Hot-RBT wording moved to `<<RT-H-003g>>`, in block 02, where the toggle is
ON and the op *does* name it — so both states are now pinned, each against the op's own answer.

> An assertion written against "the guard that happens to answer today" ages badly. One written
> against **"whatever the op says"** does not.
