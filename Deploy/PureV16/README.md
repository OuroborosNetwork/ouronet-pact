# Deploy/PureV16 — every un-staling now says how many it un-staled

**1 transaction. One new event-only capability, seven emit sites, no interface change.**

## The report that opened it

An owner injected into `OuroLpFarm-x_P-KU2bWWt9` twice:

| tx | code | gas |
|---|---|---|
| `DVR7IfRv8D3mXtThgUghZDzTS2YACa38mDDQ043wdok` | `CC_Inject … 100.0` | **486,732** |
| `CwU1RbgEYv1wDokgub__n2qiYnpw96YJHq3VKiOw7sQ` | `CC_Inject … 50.0` | **388,534** |

Same lane, same accounts, **the identical five events on both** — and a 98,198 gas difference. The
reasonable conclusion from the chain alone was that the inject engine had regressed.

**It had not.** `CC_Inject` PHASE 0 scans the FVT's stale present users and fixes every one before
injecting, and its own comment states the consequence: *"Atomic: fixing the whole scanned set ⟹
ZERO stale afterward (scan-cut, no re-scan)."* So the first inject settled the stale stakers at
their old deb, refreshed their SCORE debs, resynced the mirror and recorded the forced-fix counts;
the second found an empty stale set and mapped the fix loop over `[]`. **388k is the steady state
and 486k was a one-off debt being paid down.** The amount (100 vs 50) is irrelevant — nothing in
PHASE 0 or `XI_FvtInjectCore` scales with it.

Checked, so the diagnosis is not just plausible: inject gas is byte-identical before and after the
V15 collect work (273,217 in both), zero diff hunks touch any inject function, and three
consecutive farm injects in the REPL are flat (275,982 / 275,961 / 275,961 — flat *because* the
fixture leaves zero stale users, which is why it could not reproduce the 486k at all).

## The actual defect: the events announced the REQUEST, not the RESULT

It was not that un-staling emitted nothing. **Every path already had an `@event` capability.** They
just never said what happened:

| capability | carries | what it tells you |
|---|---|---|
| `FVT\|C>INJECT-FIX` | `patron, fvt, reward, chunk` | the page size **asked for** |
| `FVT\|C>UNSTALE-ALL` | `patron, fvt, reward, chunk` | the page size **asked for** |
| `FVT\|C>SWEEP-DRAIN` | `patron, anchor, chunk` | the window size **asked for** |
| `FVT\|C>SWEEP-REVOKE` | `patron, executor, anchor` | no count at all |
| `FVT\|C>UNSTALE-MY-SCORES` | `executor` | the caller, nothing else |

And the writes themselves run through `RPS|XE>WRITE`, which composes `SECURE` and carries **no
`@event`**:

```pact
(defcap RPS|XE>WRITE ()
    @doc "Forward entry: FVT (registered IMC caller) drives one RPS ledger write. Composes SECURE."
    (compose-capability (SECURE)))
```

So a reader of the chain could see that a sweep was **attempted** and never what it **did**. The
forced-fix counts were persisted and readable via `UR_FVT-FFC|Count` the entire time — the DATA
existed and the SIGNAL did not, and a ~98k gas swing with no event is indistinguishable from a bug.

## What ships

```pact
(defcap FVT|C>UNSTALED (op:string subject:string lane:string fixed-count:integer penalized:bool)
    @event
    true)
```

Event-only: it guards nothing, is never acquired with `with-capability`, and `emit-event` is its
sole use. **One event per transaction**, from all seven paths that un-stale — not one per fixed
user, which on a 307-member FVT would be 307 events saying the same thing.

| `op` | `subject` | `lane` | `fixed-count` means |
|---|---|---|---|
| `CC_Inject` | fvt-id | reward token | stale stakers PHASE 0 fixed |
| `CCp_InjectFixChunk` | fvt-id | reward token | fixed by that page |
| `CCp_FvtFixSlice` | fvt-id | reward token | `users` filtered to actually-stale |
| `CCp_UnstaleAll` | fvt-id | reward token | owner-run mass refresh |
| `CC_UnstaleMyScores` | **the caller** | `BAR` | FVTs the caller was genuinely stale in |
| `CCp_SweepRecomputeChunk` | **anchor-id** | boost class | holders the window recomputed |
| `CC_SweepRevokeAnchor` | **anchor-id** | boost class | employing scores swept |

Both halves of the family are covered: **deb** staleness (Elite-DEB drift) and **booster**
staleness (a boost class changing under a holder) — different causes, the same invisibility.

`penalized` says whether the 2e forced-fix count was recorded against the fixed users, which is
true exactly when the FVT's own owner injected. `subject` is deliberately not always an FVT:
`CC_UnstaleMyScores` is scoped to a PERSON across their FVTs, and a sweep is scoped to the ANCHOR
being retired.

**It fires even when `fixed-count` is 0.** "This op ran and found nothing to do" is the answer that
settles the question an operator is asking; an event that fires only on the expensive path leaves
the cheap path looking like the broken one all over again — which is the exact failure this round
exists to fix.

## Two limits, stated rather than glossed

- **`CC_SweepRevokeAnchor` reports EMPLOYING SCORES, not holders.** Step 3 maps
  `XE_XI_FvtSweepRecomputeChunk` over the scores and each call recomputes its own present set
  without returning how many it touched, so a holder count is not obtainable there without
  re-reading every present set a second time. The paginated sibling `CCp_SweepRecomputeChunk` DOES
  report holders, because `XE_XI_FvtSweepRecomputeWindow` returns `n`. Read this event as "the
  sweep ran across N employing scores"; read the chunked one for per-holder counts.
- **`CC_UnstaleMyScores` counts FVTs, not members.** `(length fvt-ids)` would have repeated the very
  "request not result" mistake this round fixes, so it pre-reads which of the listed FVTs the caller
  was actually stale in — one `URC_FvtUserHasStaleMember` per listed FVT. Affordable because the op
  is documented as "single-tx and bounded (a user's own FVT set is small)".

## Also in this round

`CC_Inject` called `URH_FvtStalePresentUsers` inside **both** arms of its owner/non-owner branch.
Only one arm runs, so it cost one read either way — but binding it once is what makes the count
available to the event. `_pricesync` records the per-function component count moving **12 → 11**.

## Verification

- `python3 REPL/tools/_gate.py` — **GREEN**, receipt `2026-10-26 22:14:25`, **94 entrypoints,
  29,190 assertions** (23,650 positive, 5,540 negative), 0 broken suites.
- The event's count is **pinned to the real stale set** by `TX-AQP-DEB06` in
  `REPL/Stage_02/[6.2.7]_AQP-DEB-MTX.repl` — the only suite that runs single-tx `CC_Inject` with
  stale users present. It asserts exactly one `FVT|C>UNSTALED` per transaction, that it names the
  op, that its count equals the stale set read immediately before the inject, that the count is
  non-zero (so the test sits on the EXPENSIVE path), and that `penalized` is true because the FVT
  owner injected. Observed: `["CC_Inject", "SubsidiaryTreasury-…", "AURYN-…", 1, true]`.
  **A count nothing compares against is decoration, not observability** — without that assertion the
  event could report a plausible constant forever and nothing would notice.
- All 30 gate-fatal static checks exit 0.
