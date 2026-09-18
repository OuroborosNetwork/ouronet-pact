Parts I and II were audits. They read the code and asked whether it was right. This round asked a
different question, and the difference in question forced a different method, a different output
format, and a different definition of success. This chapter is about those choices — why the round
was shaped the way it was, and how it was physically built — before the next three chapters report
what it found.

## Why run one at all

The two prior rounds had already read every sovereign module. A reasonable objection to a red team
at that point is that it can only re-find what careful reading already found.

That objection is wrong for one specific reason, and the reason is a property of Pact rather than
of this codebase: **`let` bindings are eager**. A Pact function that opens

```pact
(let ((parent (UR_Parent id)))
  (with-capability (OWNERSHIP account)
    ...))
```

does not evaluate the capability first. It evaluates `(UR_Parent id)` first, and if that read fails
— because the id does not exist, because the row is empty, because a sentinel came back — the
transaction dies there, with that read's error, and the ownership gate below it is never reached.

The consequence for an auditor is severe: **the check that actually refuses a bad input is routinely
not the check the code reads as though it would be.** You cannot determine which guard fired by
reading the call chain. You can only determine it by driving the operation and looking at the
message that comes back.

Four separate times in this programme a conclusion reached by reading was overturned by execution.
That is the whole justification for the round. Everything in Parts III and IV was reached by
running something.

## Who the attacker is

A threat model that says "an attacker" and stops has not been written. This round used four
distinct attacker classes, because they have genuinely different reach and the interesting defects
sit at the boundaries between them:

| class | holds | can do | cannot do |
|---|---|---|---|
| **Stranger** | a funded Ouronet account, nothing else | call any Talos wrapper, sign with their own key | present anybody else's signature |
| **Neighbour** | an account plus a legitimate position (LP tokens, a stake, a nonce) | everything a stranger can, plus every operation their own assets authorise | act on assets they do not hold |
| **Citizen author** | the ability to deploy a module into `ouronet-ns` | call sovereign entrypoints directly from module code, discard return values, compose capabilities in their own module | acquire a sovereign `GOV|*` capability |
| **Rogue operator** | one of the admin keys | everything that key gates | act outside that key's gate, or act in another admin's band |

The class matters because using the wrong one is the commonest way to produce a test that looks
like a security proof and is not. An attack driven by a stranger against a door that was never
reachable by a stranger proves nothing about the door — it proves the stranger could not get to it,
which was already known. {{ch:method}} calls this *the wrong attacker* and treats it as one of the five
ways an attack can be worthless.

The **citizen author** class deserves particular emphasis, because it is the class most systems do
not have. Ouronet's namespace is open: anybody may deploy a module alongside the sovereign ones,
and that module's code runs with whatever the namespace permits. A citizen module is not a user —
it is code, calling code, inside the same chain. Family G exists entirely to ask what that buys an
attacker.

## How the families were chosen

Eight attack surfaces were named in the round's specification before any attack was written. The
point of naming them in advance was to make coverage a checkable claim rather than a feeling:
at the end, each named surface either received attacks or visibly did not, and the gaps are stated
as gaps.

The eight planned surfaces became families **A** through **I**. Two more families were **invented
during the round**, which is worth recording honestly because it says something about where defects
in this kind of system actually live:

- **J — ledger conservation.** The question "does the protocol's own accounting balance?" was not on
  the list. It arose from noticing that a token's `supply` column and the sum of its account
  balances are maintained by two *separate write paths*, with nothing structural forcing them to
  agree. That is not an attack surface in the usual sense; nobody signs a transaction called
  "desynchronise the supply". It is an invariant, and invariants are the thing a red team is best
  positioned to test because it can drive the system into states a unit test would not construct.

- **K — preview/execution divergence.** Ouronet publishes a free cost preview for every charged
  operation, so a client can quote a price before committing. Cost parity between preview and
  execution was already proven for the entire population. **Refusal parity was proven for none of
  it.** The question "when the operation would fail, does the preview also fail?" had never been
  asked. Family K asked it eight times and found something every time.

K became the largest family in the round, and its hit rate — 8 of 8 — is the single most useful
methodological result here. It did not come from suspicion about any particular function. It came
from **counting the population and noticing an entire class of behaviour that had no coverage at
all**. {{ch:method}}'s discussion of acceptance criteria is downstream of this.

## What counts as a finished attack

An attack was not considered done when it produced a refusal. It was considered done when it
produced a refusal **that could only have come from the guard under test**. Those are very
different bars, and the gap between them is where most of this round's effort actually went.

The house technique for closing that gap is the **differential pair**: run the operation twice,
holding every input constant except the one the guard is supposed to care about, and pin *both*
resulting messages. If the guard is deleted, the two messages become identical and the test fails.
If only the refusal is pinned, deleting the guard leaves some other check to refuse the same input
with a different message — and the test passes while proving nothing.

The specific hazard this defends against has a name in this project: a **shadowed gate**. When a
`defcap` both authorises ("are you allowed?") and validates ("is this a sensible request?"), only
the first one to run is visible from outside. If the business check runs first and the normal state
of the world fails it, then *every* caller — admin and stranger alike — is turned away by the
business rule, and the authorisation gate beneath it is never exercised. A test can truthfully
report "a non-admin was refused" while the ownership capability it claims to be testing has been
deleted. **A shadowed gate is indistinguishable from an absent one from the outside.** {{ch:ownergates}}
is the programme that went looking for them.

## The exploit-first rule

Where an attack found a defect, the defect was **measured before it was repaired**, by executing the
exploit and recording what it actually cost or moved. Only then was the fix written.

This ordering is not ceremony. Three claims in this round would have been published wrong without
it:

- The `lp-churn` deterrent discrepancy was *suspected* at some large multiple. Measured, it was
  **10.5×** — the defpact door charged 53.00 where the single-transaction door charged 557.03 net
  for the same operation on the same pool. A fix written from the suspicion would have been correct
  but the finding would have carried a fabricated number.
- The `MTX|C_Issue` gate-after-payment defect was measured as **2,919.77 IGNIS + 459.0 STOA
  committed before the refusal**, plus a further 53.00 to roll back. That figure is the finding;
  "a fee is charged before the gate" without it is an assertion.
- A suspected **10,000× underpricing** was very nearly filed. Execution showed all three readings
  were identical at 250.0 — the executor sets one value at one line and re-seeds from the
  deterrent table twenty lines later. Reading found the first line. Only running found the second.

The rule generalises: **locate by execution, not by reading.**

## How it was physically built

The round produces no separate report artefact, and that is deliberate. A red-team report is a
document that was true on the day it was written. What this round produces instead is **executable
tests that live in the permanent suite**.

Each attack is a block inside a `.repl` file under `REPL/RedTeam/`, opening with a structured header:

```
;;<<RT-F-002>> FAMILY: F | STATUS: FIXED
;;HYPOTHESIS: ...what was suspected, stated so it could be wrong
;;METHOD:     ...how the operation was actually driven
;;RESULT:     ...what happened, with measured figures, and what was changed
;;
;;...free prose: why this is a real finding and not a preference, what was
;;   originally believed, which ledger entry records it
```

Three properties follow from that layout, and each was chosen:

1. **The attacks run in the gate.** They are not archived evidence; they are regression tests. A
   future change that reopens `RT-F-002` fails the build. The finding is protected by the same
   machinery as the fix.

2. **The register is generated, not maintained.** `REPL/tools/_redteam.py` walks every `.repl` in
   the tree, parses these headers, and emits the family counts and the per-attack list. {{ch:register}}
   of this book *is that output*. There is no hand-kept list of attacks that can disagree with the
   attacks — a category of error this programme found three times in its own instruments and once
   in its own published figures.

3. **The header format is checked.** A malformed or duplicated header is a gate failure, not a
   silent omission. This was learned the hard way: quoting another block's tag as `;;<<RT-E-001>>`
   at the start of a line inside a comment caused the register to read it as a real header and the
   gate to go red. The lesson — that a generated register makes prose about tags dangerous — is
   itself now in the ledger.

The scan deliberately covers **all** `.repl` files rather than only `REPL/RedTeam/`, and reports
any attack registered from outside that directory by name. One is: `RT-K-008` lives in
`Stage_02/[6.3]_STOAICO.repl`, because it belongs with the suite that sets up the state it needs.
The convention is that attacks live in `RedTeam/`; the tool's job is to make every exception
visible rather than to enforce a tidiness that would push a test away from its fixture.

## What "none succeeded" means, and what it does not

The headline result is that **no attack achieved its stated goal**. No value was moved that should
not have moved, no gate was bypassed, no privilege was escalated, no accounting invariant was
broken in a way that survived the transaction.

That is a real result and it is also a narrow one. It does not mean the system was found to be
without defect — twenty of the thirty-eight attacks exposed a genuine defect on the way to being
refused, two of them involving live money, and those are the substance of the next chapters. It
means that in every case the system's *final* answer was correct, even where the route to that
answer charged the caller first, reported the wrong thing, or refused for a reason unrelated to the
one the code appeared to give.

It should also be read against its coverage rather than in the abstract. Thirty-eight attacks
across eleven families is a bounded effort against a system of this size. The claim is "these
thirty-eight did not succeed", and the register in {{ch:register}} exists precisely so that the reader
can see the shape of what was tried and judge the shape of what was not.
