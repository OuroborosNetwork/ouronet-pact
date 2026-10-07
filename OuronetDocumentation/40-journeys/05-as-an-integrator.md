# As an integrator

Wiring a client — a wallet, an interface, a bot — to Ouronet.

**The working material for this is `docs/CHAPTER-INTEGRATION/`**, five documents written to be used
first and published second. This chapter does not restate them; it tells you what is there, in what
order to read it, and the handful of facts that will cost you a day if you meet them by surprise.

---

## 1. The five documents

| | |
|---|---|
| `05-reading-data.md` | **start here.** How to read anything, and what comes back. |
| `01-client-orchestration.md` | **the comprehensive one.** Every pattern where you read, build from the result, then execute — including multi-transaction and parallel forms. |
| `02-signing-and-caps.md` | the payer/actor split, the sponsorship capability, whose ownership is actually enforced. |
| `03-cost-preview.md` | preview readers, the result shape, and four ways to display a confidently wrong number. |
| `04-errors.md` | how refusals read, and — **measured** — which ones are catchable. |

The reading order is not numeric. Start with `05`, because everything assumes it.

Their own statement of why they are shaped this way is worth repeating:

> A chapter written after the fact describes what someone *remembers* doing; a chapter assembled
> from the handoffs people actually followed describes what **works**, because anything that did
> not work got corrected while it was being used.

---

## 2. Five facts that cost a day each

Everything below is covered properly in those documents. It is here because each one is silent —
you get a plausible wrong answer rather than an error.

### Previews do not share the shape of what they preview

**414 of 427 entrypoints have a preview whose parameter list differs from their own** — different
names, different order, different arity. Only 13 match.

**Bind by name, never by position.** Positional binding does not fail. The values are mostly
strings, so a wrong mapping type-checks and returns a confident price for a different question.

### Reads run in a different mode from transactions

A read-only query runs with restrictions lifted that apply inside transactions — notably scans
across module boundaries.

The local test harness is *always* transactional and **cannot** be put into the other mode. So a
failure you reproduce locally may not exist in production. The project's own note, after getting
this wrong publicly:

> **An error reproduced in a test harness is an error in a test harness.** Before calling it a
> production defect, establish that production runs in the same execution mode the test used.

### A failed table read cannot be caught

`try` does not catch it. So a read that fails does not degrade one field — **it takes down every
caller**.

That is not theoretical. A sentinel value reached a table lookup and killed the read an entire
toolbar was built from. And the interface's response to the failure was worse than the failure:

> **The interface answered a failed read by enabling every button.**

Decide now what your client does when a read fails, because the default is usually wrong.

### Unset is a sentinel, not empty

An unset reference reads as `"|"` — not an empty string, not an empty list. Code testing for
emptiness gets the wrong answer, and code passing it onward uses it as a key.

### Not everything is sponsored

**409 of 427** operations are gas-sponsored. Ten are multi-step, and their continuations carry no
code for the gas station to inspect — **the user pays for those**. Eight more are not sponsored at
all.

If your interface tells users transactions are free, it will be wrong eighteen times.

---

## 3. The registry is the authority on call shapes

`Deploy/OURONET-REGISTRY.json` is generated from the chain and carries every client entrypoint: its
parameters and types, its preview, its ownership requirements, its sponsorship, and example values.

It is the authority for one specific reason. Sovereign modules follow a naming canon that makes
their shapes predictable — **citizen modules deliberately do not.** The owner has ruled they may
construct functions as they please. So for a citizen entrypoint, the registry is the *only* thing
that can tell you how to call it.

**One caveat, and the project publishes it against itself:** the registry is generated from the
chain, but the checks guarding it compare it to a **copy of itself**. After a deployment it can
agree with itself about the previous surface. A separate tool asks the chain directly and records
when the snapshot was last confirmed — a date, not a verdict. Check the date.

---

## 4. Displaying costs

Every operation's preview returns what it will do, what it will say on success, and exactly what it
will cost — in both currencies, before and after the account's discount.

Two things to get right:

**Show the discounted figure and the full one.** The discount comes from the account's tier, so two
users see different prices for the same operation. Showing only one number invites a support
question.

**Do not fire a preview for arguments you know are placeholders.** The registry's example values
name entities that do not exist on mainnet. A read against them is a foregone refusal, and a read
per hover is latency for a known answer.

---

## 5. If you are building a tooltip or a cost hint

A published canon exists for this, in the client package — the render model, the rules, and the
reasoning. It is shipped as **code rather than prose**, because a document drifts from the
implementation and a shared function cannot.

Use it rather than reimplementing. The rules it encodes were each learned by getting something
wrong first, and several of them are invisible until a user notices.

---

## Where to read next

- `docs/CHAPTER-INTEGRATION/` — the five working documents
- `10-architecture/08-the-read-layer.md` — why reads are a separate layer
- `50-economics/04-the-price-sheet.md` — the catalogue of prices
