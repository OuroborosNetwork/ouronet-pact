# What Ouronet is

Ouronet is the **Sovereign DeFi Layer of StoaChain**.

That is its designation, and each of the three words is load-bearing:

- **Sovereign** — it owns its own accounts, its own asset architecture and its own gas. It runs
  on StoaChain but uses almost nothing of StoaChain's: not the account model, not the token
  standard, not the fee. It brings its own.
- **DeFi** — on top of those assets sit three families of pool (staking, swapping, earning),
  which between them cover most of what decentralised finance offers today.
- **Layer** — it is not a separate chain and does not pretend to be. Every operation executes on
  StoaChain, in Pact, inside the transaction that requested it.

All of it is smart-contract code: **123,501 lines of Pact across 105 source files**, visible on chain
as deployed.

> **On "virtual blockchain".** You will find that phrase in older material, including this
> repository's own `CLAUDE.md`, and it describes the original ambition accurately — Ouronet set
> out to be its own virtual chain. The designation above superseded it, on the grounds that it is
> both more accurate and less grandiose. Ouronet *resembles* a blockchain in having its own asset
> architecture, its own account strings and its own gas collection; it is not one, because it
> settles nothing and proves nothing on its own. Where this documentation needs the resemblance
> it makes the comparison explicitly rather than leaning on the label.
>
> Owner ruling, 2026-09-23. Source in the footer.

---

## The one-paragraph version

A user of Ouronet holds an **Ouronet account** — a string with its own cryptography, not a
StoaChain address. They hold **Ouronet assets**, which are rows in Ouronet's tables rather than
one contract per token. They pay **IGNIS**, Ouronet's own gas, priced per operation by the
contracts themselves. Their transactions go through **Talos**, the single orchestration layer
that is the only supported way in, and the host-chain gas is paid by a **gas station**, so a user
never has to hold the underlying coin. Inside, they can issue assets, provide liquidity, stake,
lock, vest — and write their own modules against the same primitives the core uses.

## The four layers of the thing

Read top to bottom; each layer only makes sense on the one below it.

**1 — Identity, and its own cryptography.** An Ouronet account is derived from a custom elliptic
curve, carries its own public key, and is verified with Schnorr signatures produced in the
browser. This is the part that is *not* written in Pact and not native to it — it sits beside the
contracts rather than inside them, which is a real architectural seam and is treated as one in
`../10-architecture/05-accounts-and-identity.md` and at length in `../80-cryptography/`.

**2 — Four asset types.** True fungible, **orto**fungible, semi-fungible, non-fungible. The
lineage is deliberate: this is the MultiversX token taxonomy, extended. ("Orto" replaced the
original "meta" fungible; the historical name survives in module names like `DPMF` and is
explained where it appears.) Each type carries management capabilities well beyond issue and
transfer — roles, freezing, wiping, per-nonce metadata.

**3 — Special variants of those assets.** The same token can exist as vested, locked, frozen,
reserved, sleeping or hibernating. These are not separate tokens; they are states with rules, and
each exists to serve one specific DeFi purpose.

**4 — Three pool families on top.** Autostake pools (`ATS`), swap pools (`SWP`), and acquisition
or earning pools (`AQP`). Each has its own mathematics and its own management surface.

And then a fifth thing, which is a property rather than a layer: **anyone can write a citizen
module.** The sovereign architecture is a platform, not a closed system — a third party's module
calls the same Talos entrypoints and is billed by the same IGNIS. StoaChain's ~2 M gas ceiling is
what makes that practical; Kadena's 150 k would not.

## What that buys, in one sentence each

**One account model.** An Ouronet account is one identity across every asset type. Issuing a
token inserts a row rather than deploying a contract, so the system knows about every asset that
exists and can compose operations across them without an integration per token.

**Its own gas.** Cost is expressed in IGNIS and priced per operation by the contracts, so the
protocol can charge for what an operation actually costs it — including reads that scan — rather
than inheriting the host chain's opinion of what is expensive.

**One way in.** Every client-facing operation goes through Talos. That is where host gas is
sponsored, where IGNIS is collected, and where the capability boundary sits. There is no second
path to keep in step.

**Composability by construction.** A liquidity position, a staking position and a vesting
schedule are operations on the same asset tables — not bridges between separate standards.

## What it costs

The same sentence, read the other way: **everything is on chain, so everything is paid for.**

A balance lookup is a table read. A route through the swap graph is a graph search. "List
everything this account holds" is a scan, and a scan is the most expensive thing a blockchain can
be asked to do. Ouronet's prices are higher than an ERC-20 transfer's, and the honest reason is
that an ERC-20 transfer is doing considerably less.

`../50-economics/` treats this at length, including the parts that are simply expensive. It is an
accounting, not a defence.

## What is actually deployed

| | |
|---|---|
| `.pact` source files | 105 |
| modules declared | 99 forms, 98 distinct names |
| interfaces declared | 98 |
| lines of Pact | 123,501 |
| `defun` forms | 8,871 |
| capabilities (`defcap`) | 988 |
| schemas / tables | 206 / 231 |
| multi-step `defpact`s | 6 |
| **the deploy round** | **80 modules + 85 interfaces, in 24 transactions** |
| client entrypoints | 423, each with a cost preview |

Measured 2026-09-27 against the tree at `1_SOVEREIGN/` and `2_CITIZEN/`. Every command is in
`../90-reference/03-how-these-figures-were-obtained.md`.

**Three of those rows are easy to quote wrongly, so they are spelled out.** 105 is a count of
*files*, and a file may hold an interface and a module together — it is not 105 modules. 8,871
counts `defun` **forms**, which includes a function declared in an interface and again in the
module implementing it; it is not 8,871 distinct functions. And the deploy round is smaller than
the tree on purpose: citizen minters, the bridge scaffold and the explorer chain are deployed
separately or not yet, each exclusion recorded with a reason in `Deploy/MANIFEST.md`.

## What it is not

**Not a token standard.** ERC-20 is a shape a contract may implement. Ouronet is a system that
owns the assets.

**Not a layer 2.** Nothing is batched, proved, or settled elsewhere.

**Not feature-complete against every DeFi primitive.** Concentrated liquidity is the named
absence — researched, not built. `../70-comparison/` lists what is missing alongside what is
better.

**Not finished being expensive.** The cost model is under active work, and this documentation
says where that work stands rather than implying it is solved.

---

## Where to go next

- `02-why-it-exists.md` — the bet this design makes, and the lineage it comes from
- `03-the-shape-in-one-diagram.md` — the mental model the rest of the documentation refines
- `04-how-to-read-this.md` — three reading orders, depending on why you are here

## Sources

- **Designation, and the four-layer framing** — owner, 2026-09-23. Recovered verbatim from the
  session transcripts; see `../90-reference/04-the-owner-directive.md` for the quoted passages
  and `REPL/tools/_transcripts.py` for how they were retrieved.
- **Figures** — computed from the deployed tree at `1_SOVEREIGN/` and `2_CITIZEN/`, and from
  `Deploy/OURONET-REGISTRY.json` (423 entrypoints, confirmed against mainnet 2026-09-27).
- **Gas ceilings** — `OuronetInformational/StoicSyntax.md` §10.2 (Kadena 150 k, Stoa ~2 M).
