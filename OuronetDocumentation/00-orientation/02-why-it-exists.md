# Why Ouronet exists

The short answer: because a token on a general-purpose chain is a contract that happens to track
balances, and almost everything interesting you want to do with assets is a fight against that
fact.

Ouronet's bet is that the asset system should be **infrastructure**, not a convention — owned by
one system that knows about every asset, rather than reimplemented per contract and bridged
together afterwards.

---

## 1. The problem, concretely

On a chain where a token is a contract, the chain does not know what a token is. Each deployment
is an independent program that agreed to expose some function names. Everything downstream
inherits that:

- **Composition is integration.** A staking contract must be taught about each token it accepts.
  A pool must be taught about each pair. Nothing is known about an asset that was not
  deliberately wired in.
- **Capabilities stop at the standard.** Freezing, per-holder rules, fee routing, metadata that
  changes, a token that can be locked but not spent — each is either absent or a bespoke fork,
  and a fork is not interoperable with the tooling built for the original.
- **Identity is per-contract.** "What does this account hold?" has no answer. You can ask each
  contract you happen to know about.
- **The chain's fee model is the only fee model.** A contract cannot charge for what an operation
  actually costs *it* — only for what the chain charges.

None of this is a defect of Ethereum or of Kadena. It is the consequence of a deliberate choice:
keep the base layer minimal and let the ecosystem converge on conventions. That choice bought
enormous flexibility. It also means the hard parts recur in every project, forever.

## 2. The lineage: what MultiversX did, and what Ouronet took

This design is not speculative. It follows a path that has already been walked, and the owner
frames it that way explicitly:

> "Think of mutliversX, existed initial as erd on ether, then they lanuched the chain, migrated erd
> to egl on their own chain. then there was aperiod where onyl native EGLD existed. and nothing
> else. then they added the token infrastructre, with all the 4 token types, **Ouronet token
> architecture is an extension of that, with even more complex management capabilitites.** However
> on top of that we also added the defi primitives."

MultiversX put the asset system **in the protocol**: four token types (fungible, semi-fungible,
non-fungible, meta) with issuance, roles, freezing and metadata as chain-level operations rather
than contract conventions. The result is that the chain knows what a token is, and every tool
gets that knowledge for free.

Ouronet takes that taxonomy and does two things to it:

1. **Extends the management surface.** The same four types, with substantially more that can be
   done to them — the special variants (vested, locked, frozen, reserved, sleeping, hibernating),
   role systems, fee routing, and wipe semantics that differ per type because the types differ.
2. **Adds the DeFi primitives to the same layer.** MultiversX left pools to contracts. Ouronet
   puts autostake pools, swap pools and acquisition pools *beside* the asset tables, so a position
   in a pool is an operation on the asset system rather than an integration with it.

**And it does this without launching a chain.** That is the actual novelty, and the actual bet.

## 3. The bet

> Everything a protocol gives you — an asset system that composes, its own fee model, its own
> account model — can be had in smart contracts on a host chain, if you are willing to pay for it
> in execution cost and accept the limits of the host's runtime.

If that holds, the payoff is large: no validator set, no consensus to bootstrap, no bridge to the
rest of the world, no chain to keep alive. You inherit StoaChain's security and liveness and spend
your effort on the asset system instead.

The word doing the work is **"willing to pay"**. Section 5 is that bill.

## 4. What the bet buys, and the part that is the actual point

Three things follow from owning the asset layer, and the third is the one that matters most.

**One account, every asset.** An Ouronet account is a single identity across all four types, with
its own cryptography and its own account string. "What does this account hold?" has an answer,
because one system owns every table that could hold something.

**Priced for what it costs.** Because Ouronet collects its own gas (IGNIS), it can charge per
operation according to what that operation actually does to it — including reads that scan, which
a host chain's fee model has no way to price and no reason to. `../50-economics/` is the detail.

**Anyone can build on it, at the same level as the core.** This is the payoff:

> "moreover, **everyone is able to construct its own logic in so called citizen modules**. using
> the sovereign architecture."

A third party's module calls the same Talos entrypoints, is billed by the same IGNIS, and gets the
same guarantees as the sovereign code — it is not a consumer of an API, it is a participant in the
system. Every launchpad sale, the bridge, the minters and the dispenser automaton in this
repository are citizen modules written against the public surface, which is how the claim is
tested rather than asserted. `../10-architecture/02-sovereign-and-citizen.md` is the boundary; the
owner ruling that citizen modules may shape their own functions freely is recorded there.

## 5. Why StoaChain, and why not everywhere

The bet depends on one number.

| | per-transaction gas |
|---|---|
| Kadena | ~150,000 |
| StoaChain (Pact 5) | ~2,000,000 |

A ~13× budget is the difference between this design being possible and being an essay. Ouronet's
operations are not small: a route search over the pool graph, a scan of an account's holdings, a
multi-leg price computation. The owner's words on the margin are not comfortable ones:

> "the 2 mil sgas limit of sta chain running pact 5 helps this, **as you can see we are in dire
> need of gas capacity**, since we ven constructed paralelizable trasnactions."

That is an honest statement of the constraint, and it explains design decisions that look strange
otherwise: why some operations are split into parallelisable transactions, why heavy reads are
tracked as a distinct class with their own naming rule, and why the deploy round is 24
transactions rather than one. **This design does not port to a 150 k chain.** It is specific to its
host, and that is a real limitation rather than a footnote.

## 6. What it costs — stated here, not buried

The same sentence that makes Ouronet powerful makes it expensive: **everything is on chain, so
everything is paid for.**

- A balance lookup is a table read, not a memory access.
- "Everything this account holds" is a scan, and a scan is the most expensive thing a blockchain
  can be asked to do.
- A swap route is a breadth-first search executed inside a transaction.
- The asset system's generality is paid for on every operation, including the simple ones. An
  Ouronet transfer costs more than an ERC-20 transfer, and the honest reason is that it is
  consulting a system that knows about fees, freezes, roles and variants, where the ERC-20 is
  decrementing a number.

`../50-economics/` accounts for this rather than defending it, and `../70-comparison/` says where
Ouronet is genuinely worse, including the named absence: concentrated liquidity, researched and
not built.

## 7. What would show the bet was wrong

Worth stating, because a vision that cannot fail is marketing:

- **If the gas ceiling binds harder than the design can absorb.** Already partly visible: several
  operations exist only as parallelisable multi-transaction recipes because a single transaction
  does not fit. If that class grows faster than the host's capacity, the design is cornered.
- **If the cryptography seam becomes untenable.** Account derivation and signature verification
  happen outside Pact (`../80-cryptography/`). That is a deliberate compromise with a known cost,
  not a solved problem.
- **If nobody writes a citizen module.** The composability argument is the main justification for
  the complexity. If the only modules on Ouronet are Ouronet's own, the system is an expensive way
  to run one project's assets.

The first two are engineering questions with measurable answers. The third is not, and it is the
one that matters.

---

## Where to go next

- `03-the-shape-in-one-diagram.md` — the mental model, before any detail
- `../10-architecture/02-sovereign-and-citizen.md` — the boundary that makes item 3 above real
- `../50-economics/02-why-it-is-expensive.md` — the bill, in full

## Sources

- **Lineage, citizen modules, and the gas-capacity remark** — owner, 2026-09-23, quoted verbatim
  with full context in `../90-reference/04-the-owner-directive.md` §3.
- **Gas ceilings** — `OuronetInformational/StoicSyntax.md` §10.2. The 150 k figure is Kadena's
  deploy budget and is the constraint that forces Ouronet's deploy ordering; see
  `../10-architecture/04-deploy-order.md`, which also corrects a long-standing misreading of it as
  a byte limit.
- **MultiversX token model** — <https://docs.multiversx.com>, named by the owner as the closest
  reference for what this documentation should be.
