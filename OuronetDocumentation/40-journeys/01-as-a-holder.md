# As a holder

What you can actually do with an Ouronet account, in the order you would meet it.

This chapter assumes nothing from the earlier sections. Where something needs explaining properly,
it says where to look.

---

## 1. Getting an account

You start with an ordinary StoaChain wallet — a keypair, a `k:` account. An Ouronet account is a
separate thing: a 162-character identifier that you create by proving control of the key that will
own it.

Creation is **permissionless**. Anyone can make one; there is no allowlist.

**One wallet key can own several Ouronet accounts.** The mapping is one-to-many in that direction
and one-to-one back — each Ouronet account settles to exactly one wallet.

**What it costs: nothing, today.** Account creation is priced at $5 for a standard account, but the
charge is behind a switch whose default is off — deliberately independent of every other fee, so
onboarding stays free while the rest of the protocol charges.

See `10-architecture/05-accounts-and-identity.md` for the account model, including the second kind
of account (a "smart" account) that you would only create if you were running something.

---

## 2. Holding

Your account holds four kinds of thing, and the differences matter when you go to move them:

| | what one unit is | moving part of a holding |
|---|---|---|
| **true fungible** | a balance | ordinary — send any amount |
| **orto-fungible** | an indivisible parcel with its own contents | **mints a new parcel** |
| **semi-fungible** | a quantity of one design | ordinary — send any count |
| **non-fungible** | exactly one thing | send it or don't |

The one that surprises people is the second. An orto-fungible holding is a *parcel*, not a number —
it has one owner and cannot be split. Sending half of one creates a new parcel, and only if the
token's issuer enabled that.

Vested, sleeping and hibernating positions are all parcels, which is why.

---

## 3. Transacting without native currency

**You do not need StoaChain's currency to use Ouronet.** The protocol's gas station pays the chain
fee for **405 of 423 client operations**.

What you pay instead is **IGNIS** — Ouronet's own gas, pegged at **one cent per unit**. You acquire
it by converting the protocol token in either direction, and both conversions are free.

So the practical answer to *"what do I need to get started"* is: a wallet key, an Ouronet account,
and some IGNIS.

Two caveats worth knowing:

**Multi-step operations are not fully sponsored.** Ten entrypoints are continuations, and a
continuation carries no code for the gas station to inspect. You pay the chain fee for those steps.

**Some operations also charge native currency.** Only where something permanent is created — issuing
a token, a pool, a branding registration. Ordinary use is IGNIS-only.

---

## 4. Knowing the price before you sign

Every client operation has a **preview** that returns what the operation will do, what it will say
on success, and exactly what it will cost — before anything is signed.

This is not an estimate. The preview and the charge call **the same cost function**, so they cannot
disagree.

One thing to know if you are reading previews directly rather than through an interface: **410 of
the 423 previews take a different parameter list from the operation they describe** — different
names, order, arity. Only 13 match. Bind arguments by name.

---

## 5. Locking

Five ways to make a holding temporarily or permanently unavailable, each with a different purpose:

| | you get back | when |
|---|---|---|
| **vested** | tranches | on a schedule, up to 25 years |
| **sleeping** | everything | at a cliff, all or nothing |
| **hibernating** | everything, minus a decaying penalty | **whenever you like** |
| **frozen** | — | **never** |
| **reserved** | when the issuer releases it | issuer's decision |

**They are not flags on your balance.** Each is a *different token* that you hold instead, and the
original is held in escrow. "My tokens are vested" means you hold `V|`-prefixed parcels.

**Hibernating is the only one you can trade.** The other four are transfer-restricted. That is
deliberate: hibernating is a bond with a decaying exit penalty — 80% if you wake immediately, zero
at the release date, linear in between — and a bond needs a secondary market. **The penalty is
burned, not paid to anyone.**

A token's issuer decides which of these are available. If they never created the vesting link, you
cannot vest it.

Full detail: `20-assets/06-the-special-variants.md`.

---

## 6. Earning

Three ways, and they suit different temperaments.

**Autostake** — stake a token, receive a receipt, do nothing. The pool's index rises as rewards
arrive, so your receipt becomes worth more of the underlying. No claiming, no compounding
transaction, no deadline.

The four live pools chain, so a receipt from one is the deposit for the next:

```
OURO → AURYN → ELITEAURYN        WSTOA → SSTOA → GSTOA
```

Single operations traverse two pools at once, so climbing a rung does not cost two transactions.

**Swap pools** — supply reserves, earn from traders' fees. Your claim on the reserves grows as fees
accumulate. You may supply in any ratio, including entirely one-sided; the imbalance is charged as
a fee rather than penalised in the LP you receive.

**Acquisition pools** — stake for a weighted share of a reward stream, where your weight can be
boosted by assets you hold *elsewhere*. The most configurable and the most involved.

All three positions are ordinary tokens. You can freeze an LP token, stake an autostake receipt
into the next pool, or anchor one holding to boost another.

---

## 7. Swapping

Two shapes. A **direct swap** names the pool. A **smart swap** finds a route across the pool graph
for you.

Three things worth knowing:

**Slippage protection is a floor, not a band.** If the trade delivers more than quoted, it goes
through. That matches every major AMM.

**A breached floor is not a revert.** The operation returns a message and charges nothing. You are
not billed for a swap that did not happen.

**The quote is fee-exclusive.** It catches the reserves moving; it does not catch a pool owner
changing their fee rate between your quote and your transaction. Only a pool with its fee locked
guarantees that, and the lock is off by default.

---

## 8. Two practical cautions

**An identifier's prefix tells you what something is — usually.** `V|` is vested, `F|` is frozen,
`S|` `W|` `P|` are pool tokens. But multi-token families use `F|` as a plain separator, so
`F|TOKEN-A|TOKEN-B|TOKEN-C` is not a frozen token. Count the separators.

**Some things are one-way.** Freezing has no reverse. Enabling fractionalisation cannot be undone.
A special link, once created, is permanent. The system is explicit about these; none of them
happens by accident, but none of them can be undone by asking nicely either.

---

## Where to read next

- `10-architecture/05-accounts-and-identity.md` — the account model
- `20-assets/00-the-asset-model.md` — the four types
- `25-defi/00-the-three-pool-families.md` — earning, in depth
- `50-economics/04-the-price-sheet.md` — what everything costs
