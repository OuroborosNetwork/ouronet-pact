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

**35 attacks across 11 families. 19 found a defect. None succeeded.**

"None succeeded" means no attack achieved its stated goal — no value was moved, no gate was bypassed,
no privilege was escalated. It does **not** mean nothing was wrong: 19 of the 35 exposed a real
defect on the way to being refused, and those are the substance of this Part.

| family | attacks | found a defect | refused cleanly |
|---|---:|---:|---:|
| **A** — economics, MEV, pricing | 5 | 3 | 2 |
| **B** — permissionless reach | 2 | 1 | 1 |
| **C** — admin impersonation | 1 | 0 | 1 |
| **D** — ownership | 7 | 1 | 6 |
| **E** — sequencing | 2 | 0 | 2 |
| **F** — griefing | 2 | 2 | 0 |
| **G** — hostile citizen module | 2 | 0 | 2 |
| **H** — input domain | 3 | 3 | 0 |
| **I** — gas station | 1 | 1 | 0 |
| **J** — conservation of value | 3 | 1 | 2 |
| **K** — preview/exec parity | 7 | 7 | 0 |

Two families were **invented during the round** rather than planned: **J** (does the protocol's own
accounting balance?) and **K** (does the free preview agree with the charged execution?). K is the
largest family in the round and every one of its seven attacks found something — which says more
about where to look for defects in this kind of system than any of the planned families did.

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
largest single thread in the round and has its own chapter. Of 167 ownership-gated capabilities
reachable from a named client operation, **19 had never caused a refusal in any test** — not because
they were absent, but because a business rule ran first and answered on their behalf. A gate in that
position is indistinguishable from a deleted one, from the outside.

## Chapters

| | |
|---|---|
| `01-METHOD.md` | How an attack is built here, and the four ways one can be worthless while passing |
| `02-OWNER-GATES.md` | The shadowed-gate programme: 167 gates, what it took to witness them |
| `03-DEFECTS.md` | The 19 defects, by severity, each with the assertion that would go red |
| `04-INSTRUMENTS.md` | The measuring tools — and the defects found *in them*, which were worse |
