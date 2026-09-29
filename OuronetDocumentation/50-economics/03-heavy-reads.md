# Heavy reads

One cost is not in the price model at all, and it is the one most likely to bite an integrator: a
read whose cost **grows with the data**.

Ouronet's answer is unusual. It does not forbid such reads. It **names** them, and makes the name
carry a rule that a script can check.

---

## 1. Four kinds of read

| prefix | does | on the execution path |
|---|---|---|
| `UR_` | reads one row or field by key | **yes** |
| `URC_` | reads and derives | **yes** |
| `URH_` | **scans** — walks a table | **no** |
| `URHC_` | scans and derives | **no** |

The first two are bounded: a key lookup costs the same whether the table holds ten rows or ten
million. The last two are not.

The distribution is the interesting part:

| | |
|---:|---|
| 1,406 | point reads |
| 755 | derived reads |
| **128** | **scans** |
| 22 | derived scans |

**Scans are about 6% of the read surface**, and every one is marked in its own name.

---

## 2. Heaviness is transitive, and enforced

A function does not have to *contain* a scan to be expensive. It only has to be able to **reach**
one.

So the rule is on the whole call graph: any client operation that can reach a scan at any depth,
through any callee, must carry a **doubled prefix** — `CC_` rather than `C_`, `AA_` rather than
`A_`.

This is not a textual check for whether a body mentions a scan. It is reachability.

And it is machine-checked on every gate run. The current state:

```
[single-reaches-heavy] 0
```

Zero single-prefixed client operations reach a heavy read. The checker's own description of what
that guards is worth quoting:

> This is the dangerous direction: **the name promises bounded cost and the tree does not deliver
> it.**

An unbounded operation that admits it is a design decision. An unbounded operation named as if it
were bounded is a trap, and that is the case the check exists to make impossible.

---

## 3. Where the scans are allowed to live

Almost all of them are in the **read layer** — the modules that answer questions off-chain and own
no data. A read-only query runs against a much larger gas ceiling than a transaction, and nothing
is written, so an expensive answer costs the asker and nobody else.

The whole read layer contains exactly **five** scans. The most expensive is a rich list, and its
own source states the limit rather than leaving it to be discovered:

> **It is also the heaviest read in the application**, and grows worse than linearly: it walks
> every account, then insertion-sorts the result — **O(n²) in accounts under a 10,000,000 gas
> ceiling. At ~195 accounts that is comfortable. It will not always be.**

Note what that comment contains: the algorithm, the ceiling, the current margin, that the margin is
temporary, and the remedy — pagination in the caller, not a bigger ceiling.

**A known limit with a named remedy is not technical debt.** It is a specification.

---

## 4. A second constraint that decides page design

Pact evaluates a `try` block in read-only mode, where unbounded database operations are
**disallowed**.

So a scanning function **cannot be placed inside a `try`** — and `try` is how a page composes
several cards so one failure degrades instead of taking the page down.

The failure shape is the worst kind:

> With the scan inline, the composer died … **while every card still passed when called
> individually** — the hardest shape to diagnose.

So "this read scans" is not a performance footnote. It decides whether the read can participate in
a resilient page at all.

---

## 5. What was actually done about it

Three responses, in increasing order of how much they tell you about the project.

**Scans were moved off the execution path.** Where a bulk operation needs a scan, the pattern is:
the *client* performs the scan as a free off-chain read and passes the result in; the transaction
does the writes. The expensive read happens where it is cheap.

**Bulk operations were sliced.** A wipe of thousands of parcels is split into disjoint, order-
independent slices that can be submitted in parallel, with replay safe because each targets items
already marked dead. The slice ceiling is **measured**: 405.6 gas per item, about 4,907 would fit —
set to **1,000**, because the measurement used the cheapest possible items. A calibration that
states its own optimism.

**And one field was deleted rather than made heavy.** A dashboard header once showed a total account
count, which required scanning every account. It worked. It was removed anyway:

> "It does work live today, so this is not a bug being fixed; **it is a dependency being made
> deliberate.**"

Losing the field bought: no cross-module scan, so no dependency on a node configuration flag; no
administrative grant needed to call or test it; and — the real prize — **every zone of the page can
now degrade independently**, where that one field could take the whole page down.

One number, traded for a page that fails in pieces. That is the clearest single illustration of how
this project treats unbounded cost: not as something to optimise, but as something to **locate and
contain**.

---

## 6. What this means if you are building on it

**Check the prefix before you call.** A doubled prefix means the operation's cost depends on data
you may not control.

**Do not put a scanning read inside a `try`.** It will fail in a way that is hard to attribute.

**Prefer passing results in.** Where an operation accepts a pre-read list, the off-chain variant is
free and the on-chain one is not.

**And treat the stated limits as real.** Where a source comment says a read is comfortable at
today's scale and will not always be, that is a maintainer telling you the remedy is already known
and not yet needed.

---

## Sources

- `OuronetInformational/StoicSyntax-Prefixes.md` — the prefix definitions and the transitive rule
- `REPL/tools/_heavy.py` — the reachability checker, run by the gate
- `2_CITIZEN/Stage_Z/AppReads/` — the read layer and its five scans
- `10-architecture/08-the-read-layer.md` — why that layer exists
