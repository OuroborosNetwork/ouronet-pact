# The read layer

Most of this documentation describes contracts that *change* things. This chapter describes the
part that changes nothing — fourteen files whose only job is to answer questions, and which own
no data at all.

That sounds like a minor supporting cast. It is closer to the opposite: the read layer is what
every interface actually talks to, it is the most expensive module in the system to deploy, and
it exists as a separate layer because of a specific outage.

---

## 1. The defining property

> **A read module owns no tables.** It is a projection over sovereign state.

Every one of the thirteen modules here declares **zero** tables. That is not an observation about
the current code, it is the rule that makes the layer work — stated in the layer's own rules file:

> "Owning nothing is what makes it freely redeployable — there is no migration, because there is
> nothing to move."

A core module holds state, so replacing it is a careful operation. A read module holds nothing, so
replacing it is just replacing code. **The read layer is the only part of Ouronet that can be
redeployed alone**, and everything else in this chapter follows from that.

There is a corollary the layer discovered the hard way: a projection has no state of its own, so
it cannot derive anything. A core module can compute an entity's identifier from its own tables;
a read module must be *told*. That is why the layer carries a small interface of shared
identifier constants — and why that file exists at all:

> "What was actually wrong was never the literals. It was that there were **forty-plus copies** of
> them — twelve in one function, two in another, thirty in TypeScript."

---

## 2. Why it is a separate layer

The predecessor was a single module carrying every read the interface made. It became untenable
for three reasons, and they compound.

**It would not fit.** One module, roughly 3,000 lines, cost about 211,588 gas to deploy — some 11%
of a StoaChain block, with none of the block explorer's reads in it yet.

**Every change redeployed everything.** Adding one field to a dashboard header meant re-running
that entire transaction, carrying seventy functions nobody had touched.

**Blast radius.** On 2026-09-24 an outage took out **all 26 reads the interface made**, because
they lived in one module whose references stopped resolving. Per-page modules would have taken out
one page.

The third is the one that forced the split. The first two are costs; the third is a correlated
failure, and correlated failure is what architecture is for.

### Today's shape

**One folder per application, one module per display entity.**

> "An app's reads are its own — two apps showing the same number still want different shapes, and
> coupling them means a change for one is a redeploy for both."

That principle is applied with unusual strictness. Formatting helpers are **copied into each
module rather than shared**, because a shared helper module would be a deploy dependency for every
read module — which destroys the single property the split buys.

Duplicated code that preserves independence is the right trade here. It is worth noting because
it is the opposite of the advice one would normally give, and the layer states its reasoning
rather than leaving a reader to assume carelessness.

### The roster

**14 files · 13 modules · 9,711 lines**, in three groups:

| group | modules | what they serve |
|---|---|---|
| Stage 1 previews | `INFO-ZERO`, `INFO-ONE` | operation previews for the core |
| Stage 2 previews | `INFO-TWO` | the same, for the later modules |
| Application reads | 9 `O-UI-*` + 1 `P-UI-*` | one per interface page |

The fourteenth file is an interface only — the shared identifier constants, no module.

Modules are **numbered rather than named** (`01_O-UI-ONE`, `02_O-UI-TWO`), and numbered slots have
gaps where a planned page has no reads behind it. The reason is blunt: a deployed Pact module
cannot be renamed, only superseded. A descriptive name is a promise about content that content
will eventually break.

---

## 3. What a preview is

The layer's largest population is **428 `INFO_` readers** — one per client operation, each
answering *"what will this do, and what will it cost?"* before anything is signed.

A preview returns a fixed shape:

| field | contains |
|---|---|
| `pre-text` | what the operation will do |
| `post-text` | what it will say on success |
| `ignis` | full cost, discounted cost, what this account needs |
| `stoa` | the same for native currency, plus where it splits |

So a preview is not a price. It is a **complete description of a pending operation**, in language,
with the money attached.

### The number is not computed here

A preview does not calculate anything. It wraps a cost function that lives **in the module that
charges it**, and the billing path calls the same function:

> the exec path and the preview cannot drift, because they are the same function.

There are **314** such cost functions serving 428 previews — not one-to-one, because a single cost
leaf is shared by the execution path and by several previews.

This is the layer's most important property. A preview that computed its own estimate would be a
second implementation of the price, and two implementations of a price are two prices.

### Nothing on chain calls a preview

A tree-wide search for on-chain preview calls returns **zero hits**. Every one is invoked
off-chain, over a read-only node query, by an interface or by the registry generator.

That is what permits the next section.

---

## 4. Reads run in a mode the tests cannot reproduce

A read-only query on a StoaChain node runs with a flag that lifts restrictions Pact applies inside
transactions. Two of those restrictions shape this entire layer.

**Cross-module scans are transaction-gated.** Listing the keys of another module's table requires
module admin in transactional mode, and is simply permitted in a read-only query on a node
configured for it.

**And the local test harness is always transactional.** It cannot be put into the other mode —
the flag is a node setting, and the harness rejects it.

The consequence is stated in the project's own notes, and it corrected an earlier conclusion that
had been confidently wrong:

> This note originally concluded **"six readers cannot run on any chain, including mainnet."**
> **That was wrong.** … every observation came from the one execution mode these functions never
> run in.
>
> **Lesson: an error reproduced in a test harness is an error in a test harness.**

That is an unusually honest piece of engineering documentation, and it is the reason this
chapter can describe the mode split accurately.

### The second constraint, which is subtler

Pact evaluates a `try` block in read-only mode, where unbounded database operations are
disallowed. So **a function that scans cannot be placed inside a `try`** — and `try` is how a page
composes several cards so that one failing card degrades instead of taking the page down.

The failure shape is the worst kind:

> With the scan inline, the composer died … **while every card still passed when called
> individually** — the hardest shape to diagnose.

So "this read scans" is not a performance note. It decides whether the read can participate in a
resilient page at all.

---

## 5. Heavy reads

Ouronet's naming separates reads by cost, and the separation is load-bearing:

| prefix | meaning | allowed on the execution path |
|---|---|---|
| `UR_` | read one row or field by key | **yes** |
| `URC_` | read and derive | **yes** |
| `URH_` | **scan** — walks a table | **no — off-path only** |
| `URHC_` | scan and derive | **no — off-path only** |

A scan is unbounded: its cost grows with the data. Ouronet's position is that such a read may
exist and may be genuinely useful, but may never sit inside a transaction — and the naming makes
that checkable rather than remembered. Heaviness is **transitive**: any client function that can
reach a scan anywhere in its call tree, at any depth, is marked heavy by a doubled prefix.

The whole read layer contains exactly **five** scans. The most expensive is a rich list, and its
own source documents the ceiling:

> **It is also the heaviest read in the application**, and grows worse than linearly: it walks
> every account, then insertion-sorts the result — **O(n²) in accounts under a 10,000,000 gas
> ceiling. At ~195 accounts that is comfortable. It will not always be.**

Note what that comment does. It states the algorithm, the ceiling, the current margin, and that
the margin is temporary — and then says the answer will be pagination rather than a bigger
ceiling. A known limit with a named remedy is not technical debt.

### A field deleted rather than made heavy

The clearest illustration of the policy is a number that was removed. A dashboard header once
showed the total account count, which required scanning every account.

It worked. It was removed anyway:

> "It does work live today, so this is not a bug being fixed; **it is a dependency being made
> deliberate.**"

Losing the field bought: no cross-module scan, so no dependency on a node flag; no admin grant
needed to call or test it; and — the real prize — **every zone of the page can now degrade
independently**, where that one field could take the whole page down, because a scan cannot live
inside a `try`.

One number, traded for a page that fails in pieces.

---

## 6. Previews do not share the shapes they preview

The most useful fact for anyone building against Ouronet, measured directly from the generated
registry:

| | |
|---|---:|
| client entrypoints | **427** |
| entrypoints with a preview | **427** |
| previews whose parameter list **differs** from the entrypoint's | **414** |
| previews whose parameter list **matches** | **13** |

**Divergence is the normal case.** A preview may take different parameter names, in a different
order, with different arity, and the thirteen exceptions are coincidences rather than a rule.

The practical consequence: arguments must be bound to a preview **by name**, never by position.
Positional binding does not fail — the values are mostly strings, so a wrong mapping type-checks
and returns a confident price for a different question. This is not hypothetical; it is exactly
the defect class the integration tooling was built to prevent.

> Both numbers in the table above were checked twice while writing this chapter. The first check
> compared the wrong field name, found it absent on both sides, and reported **"423 identical, 0
> different"** — a perfect score, produced by comparing two empty lists 423 times. A check that
> cannot fail agrees with everything.

---

## 7. Why this cannot simply live in the core modules

Three reasons, and the dominant one has changed over time.

**Deploy gas** was the historical trigger. The preview module is the single most expensive module
in the system to deploy — about 22% of a block — running at nearly double the tree's median cost
per line. But the owner ruled in 2026-09-18 that no further splitting is required: nothing exceeds
22%, and the shape is final.

**Interface immutability** is now the binding constraint. A deployed interface can never be
changed, so adding one function to a published read interface would mean a new version — and by
the cascade rule, every interface naming it and every consumer bumps too.

The read layer escapes this uniquely. Because no other module reaches a read module by reference,
a read function can be **defined in the module and omitted from its interface**. Three currently
are. That is legal — a module may exceed its interface — and it means the read layer can grow
without triggering a cascade that would cost dozens of redeploys.

**And it is a design choice**, stated independently in several places: reads are *pulled by an
interface, not pushed by a contract*. Building reads for a page that does not exist yet means
guessing a shape the eventual design will contradict — which is precisely how the predecessor
ended up with one seventy-key object assembled in a single eager binding.

---

## 8. Two defects worth carrying forward

**The cent sign.** A formatter copied between modules was transcribed with an ASCII `c` instead of
`¢`, so prices rendered as `0.253c`. It reached **mainnet in two modules**, and was found only by
diffing the new module's output against the old one field by field.

That is now the standard: **assert a port equals the function it replaces**, on a real input and
on an absent one. The deploy bodies are generated and gate-diffed rather than hand-copied.

**Dead code that kept itself alive by citation.** When the predecessor was archived, an earlier
attempt kept functions by dependency closure — anything still referenced survived. The result:

```
URC_PrimordialIDs            1 caller: URC_PrimordialPrices, itself uncalled
URC_StoaCollectionReceivers  1 caller: URC_SplitStoaPriceForReceivers, itself uncalled
every other survivor         0 callers
```

> "A closed cluster of dead code that kept itself alive by citation."

Reachability from *something* is not reachability from anything that matters. The test has to be
whether a caller chain terminates at a real entry point.

And the reason the old module was emptied rather than left in place:

> "**A migrated read left in place is a second source of truth answering the same question**, and
> the two drift the moment either is touched."

---

## Sources

- `1_SOVEREIGN/STAGE_01/Z_Reads/`, `STAGE_02/Z_Reads/`, `2_CITIZEN/Stage_Z/AppReads/` — the layer
- `2_CITIZEN/Stage_Z/AppReads/RULES.md` and `README.md` — its normative rules
- `OuronetInformational/HANDOFFS/HANDOFF-read-layer-split.md` — the split rationale
- `OuronetInformational/MODULE-SIZING.md` — measured deploy gas
- `Deploy/OURONET-REGISTRY.json` — entrypoint and preview shapes

The 414/13 split was computed directly from the registry. See
`90-reference/03-how-these-figures-were-obtained.md`.
