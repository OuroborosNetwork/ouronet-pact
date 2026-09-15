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

---

# RT-K-002 — the same question of DPTF, and where the line is

Extending family K into the most-used module drew a distinction that matters more than either
finding, because getting it wrong would mean bolting validation onto 401 previews unilaterally.

## STRUCTURAL impossibility — a quote here is simply wrong. FIXED.

The token does not exist; the pool index is zero; there is no Hot-RBT. **Nothing the caller does in
this block makes the op available.**

`INFO_DPTF|Burn` and `INFO_DPTF|Mint` returned full quotes with post-text

```
"Succesfully burned 1.0 NOSUCHTOKEN-98c486052a51 on Account Ѻ.éXø...Ìàî"
```

— narrating success for a token that has never existed — while their execs refused with `UEV_id`'s
own message. Repaired by calling **`UEV_id` inside `URCi_Burn` / `URCi_Mint`**, the readers *both*
paths share, so one wording serves both.

## TRANSIENT affordability — an owner decision, RECORDED not changed

The balance is too low; the role is missing. **These change between the quote and the submission,
and that is the normal life of a quote.**

`INFO_DPTF|Transfer` quotes 99,999,999 BUSD against a balance of 8,929,990 and says *"Succesfully
transfered …"*. Defensible **as a cost quote** — `post-text` reads as the success *template* rather
than a prediction, and a UI may legitimately want the price before the user has funded anything. It
is also arguably a dry-run failure.

> That is a product decision about 401 previews. `<<RT-K-002e>>` pins the **current** behaviour
> rather than changing it: documented, and impossible to alter unnoticed.

## Observed and deliberately left alone

Driven at a non-existent id, **`DPTF|C_Transfer` and its preview BOTH** give the raw
`No value found in table ouronet-ns.DPTF_DPTF|PropertiesTable for key:`. They are in **parity**, so
it is not a family-K divergence — but neither carries the `UEV_id` check that `C_Burn` and `C_Mint`
both have. **The sibling-rule shape from RT-H-003, on a hotter path.** Recorded rather than patched,
because it changes a refusal *message* on the most frequently called op in the system, and that
wants its own pass with its own controls.

## The rule family K should be applied with

1. Does the condition change between quote and submit? If **no**, the preview must refuse as the op
   does. If **yes**, it is a product decision — record it, do not decide it.
2. A raw internal error in a preview is wrong under **either** answer. `try` cannot catch an
   arithmetic exception, so the caller cannot even handle it.
3. Fix by **sharing the guard**, never by copying the message.
