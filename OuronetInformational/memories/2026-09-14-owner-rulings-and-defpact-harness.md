# 2026-09-14 — six owner rulings, the defpact billing harness, and two self-inflicted near-misses

Continues `2026-09-14-NIGHT-RUN-STATUS.md`. The red-team programme had stopped with four findings
that needed a decision rather than a fix, plus two housekeeping questions. All six were ruled on.

## The rulings, and what each became

| # | ruling (owner's words, condensed) | outcome |
|---|---|---|
| 1 | master key passing as a module is correct; **RotateStoa must pass through Talos** | narrowed — see below |
| 2 | step 0 bills **100**, the rest at the step that succeeds | done, measured |
| 3 | add the self-swap check | done, plus the uniqueness check |
| 4 | **authorise first, then sweep** | done, 18 sites |
| 5 | **build the harness and let's see what's wrong** | done; GS-04 closed |
| 6 | make a tools folder inside REPL | pending |

## 1 — X-01 got smaller when it was read properly

The registration that makes the master key satisfy `P|UEV_IMC` —

    (DALOS.P|A_AddIMP (keyset-ref-guard "ouronet-ns.dh_master-keyset"))

— exists at **exactly one place in the repository**: `REPL/Stage_01/[2.1]_Dalos.repl:221`. It is not
in the genesis payloads. The red-team report had presented it as a live exception to "Talos is the
only supported client path"; **that overstated it**. On chain, `DALOS::C_RotateStoa` is already
Talos-only.

The finding changes category rather than disappearing: the **harness is weaker than production**, and
that weakness hides a mislabelled test. `[2.1]_Dalos.repl`'s rotation assertions are titled with the
**Talos** entrypoint names — `<(DALOS|C_RotateGuard EMMA user-guard)>` — while the code beneath calls
`ref-DALOS::C_RotateGuard`. They pass only because of this registration.

Why the line is not simply deletable: `[2.1]_Dalos.repl` runs **before Talos is deployed**. Closing it
properly means moving those rotation tests to a file that runs after `3_Talos/`, which is also where
`[6.12]_DALOS-ADMIN.repl:177-182` already records the Talos rotation path as *"never run"*. One move
closes both. **Left for a focused pass rather than bolted onto this one.**

> An audit harness that grants itself a privilege the real system withholds will certify behaviour
> nobody can reach.

## 2 — the add-liquidity fee split

`LQ|INITIATION-FEE` (100.0) in step 0; `URCi_AddLiquidityChurnRemainder` in the execution step, after
the pool-state check. Total unchanged, so `RT-A-001`'s "two doors, one price" still holds; griefing
exposure falls **557.03 → 53.00 net**.

Found while doing it: **GS-05** — all seven `UDC_ConstructOutputCumulator` calls in `20_MTX-SWP.pact`
passed a hardcoded `false` where every other cumulator in the codebase passes
`(URC_IsVirtualGasZero)`. With the virtual-gas toggle off, the single-tx door would go free while the
defpact door kept charging. Undetectable by the suite because the toggle is on in every fixture:
*a constant that happens to equal the expression it replaced is invisible to a test that never varies
the expression.*

## 3 — the set-level swap guards, and where they did NOT fire

`output-id NOT IN input-ids` and `UEV_IzUnique` added to `SWPU|X>SWAP`. The self-swap now refuses by
name, early, with nothing debited.

The duplicate-input case did **not** change on a stable pool, and the reason is the finding:
`TS01-C3::SWP|C_MultiSwapNoSlippage` binds `slippage-bounds` in a `let` **before** calling
`SWPU::C_Swap`; a Pact `let` is eager; the curve runs and its stable-pool rule raises — all upstream
of the capability. **The validator is downstream of the math it guards.** The new rule is real and is
now demonstrated on a **weighted** pool, the case that previously had no guard at all.

## 4 — authorise-first, and the hole I nearly shipped

18 defcaps across 11 files. The first attempt was scripted and **introduced a real authorisation
hole**: in `SWP|C>PRINCIPAL` it moved the admin `compose-capability` *into* an `(if add-or-remove ...)`
branch, so **removing a principal would no longer have required admin**. In `SWPI|C>ISSUE` it did the
reverse, hoisting a deliberately conditional gate out of its `if`.

Both were caught by the Pact loader on argument arity. That is luck. **I reviewed the diff and missed
both** — 5 of 18 hunks read, both bad sites outside the 5.

> A refactor that moves security-relevant code is not verified by the code still loading. It is
> verified by knowing, per site, what the code was nested inside.

Redone as 18 hand-written `(old, new)` pairs with `count == 1` assertions, the conditional hoisted as
a whole `if` form. Convention now in CLAUDE.md.

## 5 — the defpact billing harness

`REPL/modules/DEFPACT-BILLING.repl` (auto-globbed into the gate by `modules/*.repl`).

**The blocking idiom was one line.** `(continue-pact N)` resolves against the pact started in the
*same* transaction, so a whole defpact can be bracketed by one pair of balance reads. The existing
suites drive defpacts across `commit-tx` boundaries with an explicit pact id — correct when proving
the steps are independent transactions, useless for measuring a total, because the `let` holding the
opening balance does not survive the commit.

GS-04 closed: `quoted == charged == 2920.30`. **Negative control run**: reverting one preview to the
old reader gives `3265.86` vs `2920.30`, a delta of **−345.56 = 652 raw × 0.53**, reproducing the
ledger's own 652 figure from a live balance delta. *A new assertion that passes is not evidence until
you have seen it fail on the defect it was written for* — in this same file I had already written one
toothless inequality (`step1 > discount × 951`) that the defect would have passed, because step 1 also
carries the perfect-ignis-fee, which alone clears that bar.

**The generalisable lesson is about the instrument.** `_info_measured.py` called these previews
"measured" and was right by its own rule, which samples *transactions*. A defpact's billing spans
transactions, so the tool could only ever see one step of it.

> A coverage proxy inherits the shape of the thing it samples. It answered "measured" because its
> vocabulary had no way to say "not applicable".

## A third near-miss: the signature change I grepped for in the wrong file types

Removing the dead `op-key` from `SWPI::URCi_Issue` was preceded by a callers grep — `--include=*.pact`
— which found the six INFO previews and nothing else. That was the wrong question. **REPL files call
module functions too**, and `Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl:656` passed the old arity.

The gate caught it, but the *shape* of the failure is worth recording: **23 entrypoints reported
`BROKEN` with identical `114 + / 20 -` counts.** None of them mentioned `URCi_Issue`; none of the
per-entrypoint failure sections printed anything at all, because the run died during *load* rather
than at an assertion. A single wrong arity in one shared fixture presented as a third of the suite
collapsing.

Two things follow:

1. **Grep for callers across every file type that can call, not just the ones that define.** In this
   repo that means `.pact` *and* `.repl`.
2. **Identical assertion counts across many BROKEN entrypoints is a signature, not a coincidence.**
   It means one shared load failure, and the fastest diagnosis is to run the cheapest broken
   entrypoint directly and read its tail — the last `print` before the silence names the transaction.
