# Part III — The Red-Team Round

> Roadmap §1.6.1. Source records: `ARCHITECTURE/RED-TEAM-REPORT.md` (the attack register),
> `ARCHITECTURE/DEFECT-LEDGER.md` (the defect record), and `REPL/RedTeam/*.repl` (the attacks
> themselves, which run in the gate).

## What this round was

Parts I and II document audits that read the code and asked *"is this right?"*. This round asked a
different question: **"can I make it do something it should not?"** — and answered it by executing
attacks against a live REPL blockchain, not by reasoning about source.

That distinction is the whole point. Four separate times in this programme, a conclusion reached by
reading the call chain turned out to be wrong when the operation was actually driven. Pact's `let`
bindings are eager, so a value bound in a Talos wrapper is read **before** the `with-capability` that
follows it — which means the check that actually refuses a bad input is routinely not the one the
code reads like it would be. Every finding in this Part was reached by running something.

## The register

**38 attacks across 11 families. 20 found a defect. None succeeded.**

"None succeeded" means no attack achieved its stated goal — no value was moved, no gate was bypassed,
no privilege was escalated. It does **not** mean nothing was wrong: **20 of the 38** exposed a real
defect on the way to being refused, and those are the substance of this Part.

*That sentence read "19 of the 35" for several days after the round grew to 38 attacks, while the
bold headline directly above it already said 38 and 20. A summary line and the prose under it are
maintained by different reflexes, and only one of them was in the checker's scope. Both are now.*

| family | attacks | found a defect | refused cleanly |
|---|---:|---:|---:|
| **A** — economics, MEV, pricing | 5 | 3 | 2 |
| **B** — permissionless reach | 2 | 1 | 1 |
| **C** — admin impersonation | 1 | 0 | 1 |
| **D** — ownership | 7 | 1 | 6 |
| **E** — sequencing | 3 | 0 | 3 |
| **F** — griefing | 2 | 2 | 0 |
| **G** — hostile citizen module | 2 | 0 | 2 |
| **H** — input domain | 3 | 3 | 0 |
| **I** — gas station | 2 | 1 | 1 |
| **J** — conservation of value | 3 | 1 | 2 |
| **K** — preview/exec parity | 8 | 8 | 0 |

Two families were **invented during the round** rather than planned: **J** (does the protocol's own
accounting balance?) and **K** (does the free preview agree with the charged execution?). K is the
largest family in the round and every one of its eight attacks found something — which says more
about where to look for defects in this kind of system than any of the planned families did.

## Coverage against the plan

The round was specified before it began, naming eight attack surfaces. This is what each one
actually received — stated as coverage, not as a claim of completeness.

| planned surface | families | assessment |
|---|---|---|
| capability & auth bypass, composed caps | B, C, D, G | **the deepest** — plus the whole owner-gate programme, {{ch:ownergates}} |
| sentinel / collision | H, D | **good** — three input-domain defects, all fixed |
| preview / execution divergence *(not on the plan)* | K | **the largest family; every one of its eight attacks found a defect** |
| economic & MEV — front-run, sandwich, ratio extremes | A | **good** — the sandwich attack exists and the AMM's floor now has a witness |
| arithmetic / rounding / precision | A, J | **adequate** — the share-price boundary and the supply-vs-balances split |
| defpact / Hydra-slice races | F | **adequate** — both attacks found defects, one of them a live money defect |
| cross-module boundary abuse | G, B | **adequate** |
| gas-station exploitation | I | **assessed as thin on an attack count of one — and that assessment was wrong.** `modules/DALOS-ADMIN.repl` already drives the gas capability through five blocks, including its spending ceiling. What was missing was not the cap but the arm beside it |
| ordering / reentrancy-like | E | **three attacks, all refused.** One of them documents a *structural absence* rather than a guard: nothing in the multi-transaction layer checks who is driving a recipe; safety today is a property of what each step happens to touch |

Two of the nine rows were **not on the plan at all** and were invented during the round: **J**
(does the protocol's own accounting balance?) and **K**. K is the largest family and had a 100% hit
rate. A planned list of attack surfaces is a hypothesis about where defects live, and this one was
wrong about the most productive surface in the system.

**One of those "thin" rows was a mistake in the assessment, not in the coverage.** Family I was
called the round's weakest surface because it contained one attack. The gas capability was in fact
already driven through five blocks of a module suite, including its spending ceiling with a
same-form control. **Counting attacks in a red-team family undercounts coverage that lives
elsewhere** — and this is the second time in the round that "weakest family" turned out to mean
"fewest attacks" rather than "least covered". The genuine gap, once looked for properly, was not the
cap but the arm beside it: the cap is one branch of an `enforce-one` whose other branch is the admin
guard, so the master keyset has no spending limit at all. Measured, and now pinned.

**The remaining row was closed the same way — by counting, not by intuition.** Asked which
sequencing surface was least covered, the answer came from enumerating every multi-transaction recipe
in the codebase and counting the test files that drive each. Ten of eleven had between three and
seven. **One had none** — an *admin* entrypoint that push-collects other people's rewards, whose
documentation made three claims and had never been executed by a test. Two of the three claims now
hold under measurement; the third is untestable with the available fixture and is **stated as
untested** rather than implied.

> Both of the round's last two findings came from counting a population rather than inspecting a
> candidate. Intuition kept pointing at surfaces that were already covered, and the thing with no
> coverage at all was not the thing that looked suspicious. Family E's thinness is qualified: its second
attack establishes that the defpact layer performs **no** driver check, and that every step is
currently safe only because it happens to move the starter's own tokens. A future step touching only
protocol state would have nothing to demand the starter's key, and that attack would succeed against
it without anything else changing.

## The headline results

**Two live money defects, both found and both fixed.**

- **A 38.65% mispricing of OURO.** `URC_OuroPrimordialPrice` computed a weighted pool's price with
  the weights omitted. The function feeds the on-chain price oracle, the launchpad's payment
  conversion and the block explorer. Proven by controlled experiment: reserves held constant, the
  pool's weights varied through the live client path, and the flagged function returned a
  **bit-identical** value across three different weightings of the very pool it prices.
- **A fee charged before the gate that refuses.** `MTX|C_Issue` with the permissioned flag set
  commits **2,919.77 IGNIS + 459 STOA** in step 1, then refuses in step 2 at an admin gate the caller
  can never satisfy. Non-refundable; cancelling cleanly costs a further 53 IGNIS. The
  single-transaction twin of the same operation refuses for **zero**.

**A swap that reported success while moving nothing.** The AMM's slippage floor refuses by
*returning* a payload rather than raising. One Talos wrapper indexed that payload out of range and
raised a bare `Array index out of bounds`; its siblings indexed it *in* range and interpolated the
refusal text into a sentence beginning **"Succesfully swapped"**, committed the transaction, and
emitted a swap event. Zero in, zero out. The same defect — and the noisy one was the safe one.

**A class of capability that was present, reached, and had never refused anybody.** This is the
largest single thread in the round and has its own chapter. Of the ownership-gated capabilities
reachable from a named client operation, **only 19 had ever caused a refusal in any test when the
round began** — not because the rest were absent, but because a business rule ran first and answered
on their behalf. A gate in that position is indistinguishable from a deleted one, from the outside.
By the round's end {{fig:gates_observed}} had been observed to refuse somebody and
{{fig:gates_depth0}} of those refusals were attributed to the gate itself rather than to something
it composes; {{fig:gates_never}} remain unobserved, and {{ch:ownergates}} is about why that is
reported as a bound rather than closed.

*This paragraph previously read "**19 had never caused a refusal**", which inverts the figure: 19 is
the count that **had** one. The error survived because the sentence is true-sounding in either
direction — a small number of gates in an alarming state is exactly what the passage is claiming —
and nothing checked it against the table in {{ch:ownergates}} that it paraphrases.*

## Verification state

At the time of writing, the full gate is **green at {{fig:assertions}} assertions** ({{fig:assertions_positive}} positive, {{fig:assertions_negative}}
negative) across the whole system — every deploy stage, every scenario suite, every red-team attack,
plus the static checks on generated artefacts, tool paths, prefix vocabulary, cross-module member
resolution, assertion vacuity, eager-let shadows, and this book's own tables. Wall time ~5-7 minutes.
Reproduction: Appendix 1.

> **That number is a snapshot and will move.** It rose from 22,939 to {{fig:assertions}} during the round
> documented here. The canonical value is whatever `ARCHITECTURE/REPL_SUITE_STATS.md` holds, and
> `_figuresync.py --check` now verifies that file **against the tree** — it previously verified only
> that every document agreed with it, which is circular and was green while all of them were wrong
> together (DEFECT-LEDGER §8.22).

## Chapters

| | |
|---|---|
| `01-METHOD.md` | How an attack is built here, and the four ways one can be worthless while passing |
| `02-OWNER-GATES.md` | The shadowed-gate programme: 167 gates, what it took to witness them |
| `03-DEFECTS.md` | The twenty defects, by severity, each with the assertion that would go red |
| `04-INSTRUMENTS.md` | The measuring tools — and the defects found *in them*, which were worse |
