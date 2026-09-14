# 2026-09-15 — the RPS dust sweep: one correct model, two lossy copies

The owner asked a question that turned out to be worth more than any attack this round produced:

> *"I thought the audit of the stoa ico fixed the dust sweep, allegedly following the canonical model
> of the coin module, where the implementation allegedly is correct. Can we verify this? Because if
> this is incorrect, the implementation in the AQP module also might be off."*

Every part of that was right, including the part that sounded like a hunch.

## What was actually true

**The coin module is correct, and it was fixed by an audit.** `genesis/stoa-genesis-4.pact` keeps
the OLD unguarded `URC_URV|ClaimableRewards` commented out at `:1510`, directly above the guarded
version at `:1521`. The repair is legible there and nowhere else in the tree.

    coin (correct)   (if (and (= (UR_URV|VaultUnclaimedCount) 1) (> available 0.0)) ...)
    the ports        (if (= unclaimed-count 1) ...)        <- caller conjunct dropped

**The STOAICO audit did NOT fix the sweep.** `#1C CRITICAL` (`d6aa52b`) fixed the *drain* — repeated
collects walking `unclaimed-count` down — and concluded *"Sweep kept, now safe."* True of the attack
it closed; it never touched the reader. `#13L` (`bdf79ff`) then compared STOAICO to "canonical AQP"
on **counter clamping**, a different question entirely. So "matches canonical AQP" propagated the
shape rather than validating it — and AQP had the same hole.

## The two defects, and why they had to be fixed together

**GS-08 — the reader paid whoever asked.** Measured on the deployed stack, `[6.4]` wind-down:

    gc=1   emma-claimable == anhd-claimable      <- the reader could not tell them apart
    EMMA (fully exited, deb=0) collected the sweep, vault -> 0
    ANHD (rightful sole claimant, deb=10)  gained 0.0

Strictly worse than the STOAICO twin: there a `last-collected-round` stamp made the wrong number
unreachable as theft. Here nothing did, and `gc == 1` is a NORMAL END-OF-LIFE STATE.

**GS-09 — the counter could be walked.** Exposed BY fixing GS-08: the same run then showed the dust
STRANDED instead of stolen. `XI_1|BookCollectUnclaimed` decremented on `deb == 0` alone, so a
zero-weight account could tick the counter down for the price of gas — eventually forcing a payout
to the wrong person while honest stakers were still staked.

> Fixing the reader alone converts theft into a fund-lock. The two are one defect wearing two faces.

## The mechanism that let it happen

AQP's collect is a line-by-line port of coin's UrStoa vault — the comments still name the steps
("coin step 1", "coin step 2", "coin step 3"). Two things were lost in the copy:

| | coin | AQP (before) |
|---|---|---|
| sweep branch | `(and (= … 1) (> available 0.0))` | `(= gc 1)` |
| step 1 on a zero amount | `C_Transmit` → **aborts** (`UEV_Amount`) | `(if (<= payout 0.0) (UC_EmptyOc) …)` → **skips** |

The second is the subtle one and it caused GS-09 on its own. In coin, the abort at step 1 is what
makes the step-3 counter decrement unreachable for a caller with nothing to collect. Turning an abort
into a skip looks like making a no-op graceful.

> **A guard can be load-bearing for code it does not mention.** Removing an abort relaxes everything
> sequenced after it.

## Why identical code would have been the wrong fix

Each module counts something different, so each guard must match ITS OWN writer:

| module | counter counts | guard |
|---|---|---|
| coin | users with unclaimed rewards | `available > 0` |
| STOAICO | non-zero scores, per round | `score > 0 ∧ not already collected` |
| AQP | claimants, retired at zero weight | `deb-user > 0` |

Same principle — *the sweep branch must test the caller* — three different predicates. Copying coin's
literal condition into AQP would have stranded dust for a staker owed nothing yet.

## The assertion that was true and useless

**The suite was green through both defects.** The existing test drives this exact wind-down and
checks that the vault DRAINED (`ar-final`/`mv-final` → 0). Conservation is satisfied whether the
money reaches the rightful claimant or someone who just left.

> **A test that asserts an outcome does not assert who caused it.**

Third instance this round: `RT-C-001`'s admin gate behind a solvency check, `RT-E-001`'s theft
blocked by an unrelated stamp, and this. `<<TX-AQP-CL04>>` now pins seven assertions, including the
two a careless repair would break — the rightful claimant must STILL sweep, and the vault must STILL
reach zero. Returning `0.0` to everyone satisfies "the non-claimant gets nothing" while destroying
the feature.

## What was deliberately not done

Five files under `0_Stoa/coin-contract/` still carry the pre-fix form, one of them named
`coin-live.pact` and listed in `MODULE-INDEX.md` as the source for `coin`. They are historical
snapshots; **rewriting them would falsify the record**, so the hazard is documented in
`IGNIS-PRICING.md` instead. Whether the two ports were copied from a stale snapshot is NOT
established and is NOT claimed — a plausible story is not a finding.

## Postscript — the figure drift that outlived three reconciliations

While closing this out, the generated `REPL_SUITE_STATS.md` and the narrative `REPL-ROUND-REPORT.md`
drifted apart for the **fourth** time in two days. Each earlier reconciliation had grepped for the
stale values already known about (`21,580`, `5,399`, `5,413`) — which finds the drift you suspect and
not the drift you do not. The fourth instance was `| gate entrypoints | 77 |` sitting in the round
report's **headline statistics table**, a figure from before the RedTeam suites existed, in a
document that said **86** three other times. It survived all three passes.

`REPL/tools/_figuresync.py` now checks **every labelled table row** against the generated source and
is fatal in the gate. Two deliberate scope choices:

- **Prose is exempt.** Sentences legitimately carry historical figures ("no other failure in the
  21,732 the suite executed at that moment"). A checker that flagged those would be wrong more often
  than right, be overridden, and then be ignored when it mattered.
- **The document list is a GLOB, not a list.** Only one document carries labelled figure rows today,
  so a hardcoded list would have been complete *and silently wrong* the day someone adds a statistics
  table elsewhere.

> **A checker whose coverage depends on a human remembering to extend it will eventually report
> clean about a region it stopped looking at.**

Same shape as `_info_measured.py` being structurally blind to defpacts, and as the tools-relocation
output diff excluding the two orchestrators for cost — the highest-risk population. In all three the
number produced was *reassuring*.
