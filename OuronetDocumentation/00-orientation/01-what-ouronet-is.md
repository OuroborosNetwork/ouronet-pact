# What Ouronet is

Ouronet is a **virtual blockchain implemented entirely in smart contracts**.

It runs on StoaChain — a Kadena-family chain — but it does not use StoaChain's account model,
its token standard, or its gas. It brings its own. Accounts, balances, fees, asset types and
DeFi primitives are all defined inside the contracts, in 122,969 lines of Pact across 105
modules.

That is the whole idea, and everything difficult about the system follows from it.

---

## The one-paragraph version

A user of Ouronet has an **Ouronet account**, not a chain address. They hold **Ouronet assets**,
which are rows in Ouronet's tables rather than separate contracts. They pay **IGNIS**, Ouronet's
own gas, rather than the host chain's. Their transactions are submitted through **Talos**, a
single orchestration layer that is the only supported way in, and the host-chain gas is paid by
a **gas station** so the user never holds the underlying coin. Inside, they can issue tokens,
run liquidity pools, stake, lock, vest, and write their own modules against the same primitives
the core uses.

## What that buys, in one sentence each

**One account model.** An Ouronet account is a single identity across every asset type. Issuing
a token does not deploy a contract; it inserts a row. So the system knows about every asset,
and operations can be composed across them without an integration per token.

**Its own gas.** Cost is expressed in IGNIS and priced per operation by the contracts
themselves, which means the protocol can charge for what an operation actually costs it —
including reads that scan — rather than inheriting the host chain's opinion.

**One way in.** Every client-facing operation goes through Talos. That is where gas is
sponsored, where IGNIS is collected, and where the capability boundary sits. There is no second
path to keep in step.

**Composability by construction.** A liquidity pool, a staking position and a vesting schedule
are all operations on the same asset tables, not bridges between separate standards.

## What it costs

The same sentence, read the other way: **everything is on chain, so everything is paid for.**

A balance lookup is a table read. A route through a swap graph is a graph search. A "list
everything this account holds" is a scan, and a scan is the most expensive thing a blockchain
can be asked to do. Ouronet's prices are higher than an ERC-20 transfer's because an ERC-20
transfer is doing considerably less.

`50-economics/` treats this honestly and at length, including the parts that are simply
expensive. It is not a defence; it is an accounting.

## What is actually deployed

| | |
|---|---|
| modules | 105 `.pact` files, 79 in the deploy round |
| lines of Pact | 122,969 |
| functions | 8,848 |
| capabilities | 988 |
| schemas / tables | 206 / 231 |
| interfaces | 68 |
| client entrypoints | 423 |

Measured 2026-09-27 against the deployed tree. The commands are in
`../90-reference/03-how-these-figures-were-obtained.md`.

## What it is not

**It is not a token standard.** ERC-20 is a shape a contract may implement. Ouronet is a system
that owns the assets.

**It is not a layer 2.** It does not batch, prove, or settle elsewhere. Every operation executes
on StoaChain, in Pact, in the transaction that requested it.

**It is not finished being expensive.** The cost model is the subject of continuing work, and
the documentation says where that work stands rather than implying it is solved.

---

## Where to go next

- `02-why-it-exists.md` — the bet this design makes, and against what
- `03-the-shape-in-one-diagram.md` — the mental model the rest of the documentation refines
- `04-how-to-read-this.md` — three reading orders, depending on why you are here

## Sources

Figures computed from the deployed tree at `1_SOVEREIGN/` and `2_CITIZEN/`, and from
`Deploy/OURONET-REGISTRY.json` (423 entrypoints, surface `7c2b70c6118d6db2`, confirmed against
mainnet 2026-09-27).
