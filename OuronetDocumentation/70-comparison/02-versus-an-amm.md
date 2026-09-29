# Versus an AMM

This chapter compares Ouronet's swap layer against **Kaddex**, the established AMM on Kadena.

That choice is deliberate. Comparing against Uniswap means comparing across languages, virtual
machines and gas models, where every difference has three possible causes. Kaddex is **written in
the same language, on the same platform, against the same constraints** — so a difference is a
design decision rather than a platform artefact.

Its source sits in this repository: **5,253 lines of Pact across 14 modules**, captured from a
mainnet explorer in August 2026 for exactly this purpose.

> **A caveat the capture itself states:** it was transcribed from an explorer and never verified
> against a live node, and carries no version or block height. It is "believed accurate as pasted".
> Treat structural observations as sound and exact byte-level claims as needing re-verification.

---

## 1. The size difference, stated correctly

| | lines |
|---:|---|
| Ouronet's swap core (8 files) | **15,243** |
| Kaddex's entire 14-module ecosystem | **5,253** |
| Kaddex's closest functional equivalent (3 modules) | **1,607** |

So roughly **3× the whole ecosystem, or 9.5× the equivalent modules**.

The repository's own comparison note gives smaller ratios. **It is wrong** — its figures could not
be reproduced at any commit, and it also understates one Kaddex module by 40%. The numbers above
were re-counted for this chapter.

That correction matters more than the arithmetic, because the ratio is the least flattering fact in
this chapter and the erroneous version flattered.

---

## 2. Where the difference is real

| | Kaddex | Ouronet |
|---|---|---|
| curves | **one** — constant product, two tokens | **three** — stable, weighted, plain — 2 to 7 tokens |
| swap fee | one global constant, **0.3%**, changeable only by upgrade | **per-pool, mutable**, three components, lockable |
| routing | **none on-chain** — the caller supplies the path | **breadth-first search** over the pool graph, with caching |
| imbalanced deposits | a **zap** — swap half, then deposit | **accepted directly**, imbalance priced as a tax |
| multi-step operations | none | four multi-step flows |
| pool ownership | **none** — no per-pair owner | per-pool owner with real powers |
| oracle | **a TWAP oracle** | **none** |
| governance | on-chain quadratic voting | none |

Two rows deserve more than a table cell.

### Routing: Kaddex has none, and says so

Kaddex's swap entrypoints take a **caller-supplied path** and check only that it has at least two
elements. The nearest thing to a route-finder in the whole ecosystem is twelve lines: if a direct
pair exists use it, otherwise route through the chain's native coin.

It carries a literal, never-completed note in the source:

```
;; TODO: Either try more than the basic single-hop path, or
;;       operators should register optimal token paths to take.
```

Ouronet implements the search on-chain — 506 lines of breadth-first traversal plus a 1,367-line
graph and cache layer — and found three routing bugs **in its own router** during audit. That is
the honest shape of this row: Ouronet built something Kaddex declined to build, and paid for it in
bugs and gas before it worked.

### Imbalanced deposits: both support it, differently

The repository's own note claims Kaddex "has no concept of intentionally-imbalanced deposits." **That
is wrong at the ecosystem level** — Kaddex ships one-sided liquidity in a helper module.

The real difference is the mechanism:

| | |
|---|---|
| **Kaddex** | *zaps* — really swaps half your deposit, charging the normal fee, with the price impact borne by you |
| **Ouronet** | accepts the imbalance directly and prices it by **simulating the trades that would rebalance it** |

Ouronet's is the more unusual design and the more expensive one to implement. Kaddex's has the
advantage of being obviously correct — it is just a swap.

---

## 3. Where Ouronet is measurably stronger

One, and it is verifiable in this repository rather than asserted.

**Ouronet cannot lock users out of their own liquidity. Kaddex can.**

Kaddex has a single global contract lock per module, settable by an operations keyset. It is
enforced on adding liquidity, on swapping, on creating a pair — **and on removing liquidity**:

```pact
(defun remove-liquidity ...
    (enforce-contract-unlocked)
```

The same pattern reaches staking: the base guard calls it, and the unstake capability composes that
guard. **So a Kaddex operations keyset can block both LP exit and unstaking.**

Ouronet's audit examined exactly this and removed the equivalent gate. The reasoning, written at the
site:

> `can-add` is a pool-owner switch meant to pause new liquidity provisioning; it must never also
> block existing LPs from getting their own principal back — **an admin-controlled ability to freeze
> user funds already deposited isn't a safety mechanism, it's a trust violation.**

A pool owner can pause deposits and halt trading. **Withdrawal is exempt by design**, proven against
a real pool with a real balance.

The decision was justified by citing Curve's kill switch exempting plain removal and Balancer's
recovery mode being permissionless while paused. **Those citations are asserted in the audit rather
than sourced.** The Kaddex comparison, which *is* in the repository and *is* checkable, shows the
same-platform competitor failing the criterion — and that contrast had not been drawn anywhere
before this chapter.

---

## 4. Where Kaddex is better

A comparison without this section is not one. Five items, all from the repository's own notes
except where marked.

**Kaddex has a TWAP oracle. Ouronet has none.** Kaddex maintains cumulative prices updated on every
reserve change, with registered multi-hop paths. Ouronet uses raw spot reserve ratios — a grep for
oracle machinery across the swap layer returns three hits, all prose or a commented-out external
call.

The repository files this as "a roadmap question, not a bug", on the grounds that nothing downstream
needs manipulation-resistant pricing. **That reasoning does not survive its own audit book**, which
states that the swap layer publishes the canonical dollar price of the gas token, consumed by the
launchpad and the block explorer. A downstream consumer of manipulation-sensitive pricing exists.

**Kaddex's router short-circuits the direct-pair case. Ouronet's does not** — it builds the full
graph and searches even when a direct pool exists. Filed as an optimisation, unscheduled.

**Kaddex buys reentrancy insurance it believes it does not need.** It maintains a per-pair lock,
with a source comment admitting no exploit could be constructed because Pact detects recursion.
Ouronet has no lock, and proved the case properly rather than accepting Kaddex's word — an isolated
reproduction showing that re-entering a module mid-execution through a callback fails with
`Operation disallowed in read-only or sys-only mode`, **and that `try` cannot catch it.**

That proof is stronger than "recursion is detected", because a real reentrancy attack rarely
re-invokes the same function. But the repository's own note declines to treat it as closed:

> Kaddex's own choice — **pay for insurance even believing you don't need it — is worth weighing
> explicitly**, not just assuming the refutation closes the question forever.

And the guarantee is explicitly scoped: it covers callbacks during guard evaluation. If the swap
layer ever accepts a caller-supplied module reference invoked mid-operation, it must be re-proved.

**Kaddex ships gas ceiling guards** — a pattern for bounding gas price and limit — which Ouronet's
note calls "the one piece Kaddex has that we don't". Filed, not urgent.

**Kaddex used formal verification; Ouronet uses none.** Four Kaddex modules carry `@model` property
annotations. Ouronet carries zero.

The repository's self-criticism here is the sharpest passage in its own comparison, and it is worth
reproducing because it argues *against* the project:

> the class of bug the prover targets is precisely what four of this audit's findings turned out to
> be, found by hand, one at a time, across a multi-day audit. **A property check would have caught
> that entire bug family in one run instead of a 71-finding manual sweep.**

**This one has since resolved itself, and not in anyone's favour: formal verification was removed
in Pact 5.** Verified by inspecting the language's own source — the analysis modules are gone and
`@model` still parses but runs nothing. So Kaddex's annotations are now inert too. Ouronet's
substitute is the apparatus in `60-methodology/` — structural rules and 26,128 assertions — which
is broader and weaker: it proves shape thoroughly and semantics not at all.

---

## 5. The thing neither document says

Searching the repository for an admission that **15,243 lines of self-written AMM is a larger attack
surface than 1,207 lines of a battle-tested Uniswap-V2 clone** returns nothing. The closest is:

> size **is** what makes an audit like that expensive and slow, and every additional formula family
> / router / defpact flow is another surface the next audit round has to re-cover from scratch.

That is true and insufficient. The stronger version belongs here:

**Kaddex's core is a port of the most-attacked, most-audited AMM design in existence.** Its
constant-product formula has been adversarially examined for years across thousands of deployments.
Ouronet's three curve families, its router, its asymmetric tax and its multi-step flows are
original work, examined by one audit programme.

Ouronet's answer is not that its code is better. It is that the surface is **checked continuously
and publicly** — the failures are catalogued in `60-methodology/04-what-went-wrong.md` rather than
absent from the record. That is a real answer, and it is weaker than being a clone of something
proven. A reader weighing the two should weigh it as such.

---

## 6. What the comparison actually produced

It ran in August 2026 and describes itself as *"a starting hypothesis, not verified ground truth"*,
with five open items. **Three of those five are still open**, including whether the no-lock stance
is a documented decision or merely where the audit stopped.

Its outcome, in the audit book's own words:

> **Almost nothing survived scrutiny** — the conclusion on whether the swap layer needs Kaddex's
> lock was *no* — but findings trace back to it.

Two real defects came from it, both in price computation: a weight omission and a depth-skew where
valuing 300 units returned 272 against a true 449 — **a 39% collapse**. Both fixed, both proven,
with the gas cost of the fix disclosed.

*(The book says three findings trace back; the third's own record says it originated from a direct
question, not the comparison. Two is the defensible number.)*

That is a reasonable return: a competitor comparison that produced two real bug fixes, one
methodology correction, and a list of things not adopted with reasons. It is also, by its own
admission, unfinished.

---

## Sources

- `Audit/module-audits/SWP/reference/` — 5,253 lines of Kaddex Pact source and the comparison note
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` … `20_MTX-SWP.pact` — Ouronet's swap layer
- `Audit/book/PART-I/03-SWP.md` — the audit's verdict
- `OuronetInformational/memories/2026-08-29-recursion-detection-and-try-forces-readonly.md` — the
  reentrancy proof
- `OuronetInformational/pact5/REFERENCE.md` — formal verification's removal, source-verified

Line counts, the pause-gate asymmetry and the one-sided-liquidity correction were re-verified
directly for this chapter; the repository's own figures for the first were not reproducible.
