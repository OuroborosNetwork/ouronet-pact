# Versus ERC-20

The honest comparison starts by admitting the two are not competing.

**ERC-20 is a standard.** Six functions and two events, published in 2015, deliberately minimal so
that anything could implement it. Its success is its smallness — a standard that demanded more
would have been adopted less.

**Ouronet's token layer is an implementation.** It is not proposing that everyone adopt a
3,352-line contract. It is one system's answer to what a token should be able to do when the
platform is yours to design.

So this chapter is not "which is better". It is: **what does the minimal interface leave to each
implementer, and what happens when a platform decides those answers once?**

---

## 1. What ERC-20 actually specifies

```
totalSupply()   balanceOf(owner)   transfer(to, value)
transferFrom(from, to, value)      approve(spender, value)   allowance(owner, spender)
```

That is the entire surface. It says nothing about who may mint, whether supply is capped, whether
transfers can be paused, what a token is called, or what happens if you send to a contract that
cannot handle it.

Every one of those is left to the implementer — which is why, in practice, most real ERC-20 tokens
are a standard interface bolted onto a library implementing everything the standard omitted.

**The comparison is therefore not "6 functions versus 200".** It is *"where does the missing 194
live?"* In the ERC-20 world it lives in a library, a proxy pattern, and a per-project decision. In
Ouronet it lives in the protocol, decided once.

---

## 2. The lineage is not Ethereum

Worth stating plainly, because it explains the shape. The owner's stated reference is MultiversX:

> "Think of MultiversX — existed initially as ERD on Ethereum, then they launched the chain,
> migrated ERD to EGLD on their own chain … then they added the token infrastructure, with all the
> **4 token types**. **Ouronet token architecture is an extension of that, with even more complex
> management capabilities.**"

MultiversX's token system defines four types at the protocol level — fungible, semi-fungible,
non-fungible, and a metadata-bearing variant — with roles granted per account per token. Ouronet's
four types map onto those directly, with the metadata-bearing one renamed from *meta* to *orto*.

So the right frame is not "ERC-20 plus extras". It is **a protocol-level token system, in the
MultiversX tradition, implemented in smart contracts rather than in a chain's own runtime.**

That last clause is the unusual part, and it is where the cost in `50-economics/` comes from.

---

## 3. What is decided once rather than per token

| | ERC-20 | Ouronet |
|---|---|---|
| token types | one | **four**, at protocol level |
| roles | not specified | **4 grantable**, per account per token |
| per-holder freeze | not specified | built in, behind an issuance flag |
| transfer fees | not specified | built in, including a progressive tax |
| supply mechanics | not specified | mint and burn as gated roles |
| metadata | not specified (ERC-721/1155 add it) | on three of the four types |
| pausing | not specified | an issuance flag |
| approvals | **`approve` / `allowance`** | **no equivalent** — see below |

The last row is the substantive difference in the day-to-day model, and it deserves more than a
table cell.

### There is no allowance model

ERC-20's `approve`/`transferFrom` pair lets you authorise a contract to move your tokens later.
It is how every DeFi interaction on Ethereum begins, and it is also the source of a long list of
problems: the well-known race condition when changing a non-zero allowance, unlimited approvals
that outlive the interaction that needed them, and phishing that consists entirely of getting
someone to sign one.

Ouronet has no equivalent because the platform's capability model makes it unnecessary. **A
transaction declares, and the signer grants, exactly the authority it needs, scoped to that
transaction.** There is no standing grant to forget about, and nothing to revoke afterwards.

This is a genuine advantage, and it is worth being precise about *why*: it is not that Ouronet
solved the approval problem. It is that the underlying platform's capabilities make the approval
pattern unnecessary, and Ouronet is built on that platform. Any Pact contract gets this.

---

## 4. What the four types buy

An ERC-20 balance cannot express:

**A holding with its own contents and exactly one owner.** Vesting schedules, time-locked
positions, anything where "half of it" is meaningless. Ouronet's orto-fungible is this, and it is
the type most systems lack — the usual workaround is a separate contract holding a mapping, which
is a token in everything but interoperability.

**Composition.** Binding several collectables into one tradeable set, with the constituents held
rather than burned, and a decomposition that returns them.

**Fractionalisation.** Splitting one collectable into exactly 1,000 pieces, represented as the
negation of the original — so the relationship between piece and whole is arithmetic, not a lookup.

Each of these is buildable on Ethereum. The difference is that here they are **the same tokens**,
subject to the same transfer rules, visible to the same interfaces, and usable as pool collateral
without an adapter.

---

## 5. What ERC-20 has that Ouronet does not

An honest chapter needs this section, and it is short but real.

**Ubiquity.** Every wallet, every exchange, every analytics tool speaks ERC-20. Ouronet's tokens
are legible to Ouronet. That is an enormous practical difference and no amount of design quality
closes it.

**Simplicity as a security property.** Six functions can be read in a sitting. Ouronet's token core
is 3,352 lines and 40 capabilities, and *that is 40 places where an authorisation could be wrong* —
which is precisely why this project built the checking apparatus described in `60-methodology/`. A
smaller surface needs less proof.

**Freedom to be unusual.** Because ERC-20 specifies so little, an implementer can do something the
standard never imagined. Ouronet's tokens do what Ouronet's token module does. The extension point
is a citizen module *composing* those operations, not altering them.

**Immutability by default.** A typical ERC-20 has no admin. Ouronet's tokens have issuers with real
powers — freezing, wiping, fee changes — and the mitigation is that **each is behind a flag chosen
at issuance and most cannot be re-enabled later.** An issuer can issue a token nobody can freeze.
But they have to choose to.

That last trade is the honest summary of this whole comparison: **Ouronet gives issuers powers and
makes the absence of those powers a deliberate, visible choice.** ERC-20 gives them nothing and
makes the presence of powers a deliberate, often invisible, choice by whoever wrote the contract.

Neither is obviously right. But only one of them is checkable from the outside.

---

## 6. The comparison that actually matters

Not function counts. **Where the missing behaviour lives, and who verifies it.**

A typical ERC-20 deployment inherits a widely-audited library, then adds project-specific logic that
is audited separately if at all. The standard is proven; the deployment is not.

Ouronet's answer is the opposite: the behaviour is in the protocol, it is the same for every token,
and it is checked by the apparatus in `60-methodology/` — 26 structural rules at zero violations,
26,128 assertions, on every commit.

Both approaches concentrate risk. One concentrates it in a library everyone shares; the other in a
protocol everyone shares. The difference is that **a bug in Ouronet's token core is one bug in one
place with one test suite over it**, and a bug in a project's custom ERC-20 extension is one bug in
one project that nobody else will find.

---

## Where to read next

- `20-assets/00-the-asset-model.md` — the four types
- `02-versus-an-amm.md` — the pool comparison, against a same-platform implementation
- `03-what-the-complexity-buys.md` — the ledger

## A note on sources

Claims about ERC-20 in this chapter concern the published standard's own surface, which has not
changed since 2015. Claims about Ouronet are sourced to `1_SOVEREIGN/` and measured; the lineage
quotation is the owner's, recorded in `90-reference/04-the-owner-directive.md`.

Where this documentation compares against a specific other implementation, it does so against one
whose source is in this repository — see `02-versus-an-amm.md`.
