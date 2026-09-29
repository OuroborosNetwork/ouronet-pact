# As a token issuer

What you get when you issue a token, what it costs, and which decisions you cannot take back.

---

## 1. Choosing a type

| | choose it when |
|---|---|
| **true fungible** | units are interchangeable and divisible — a currency, a share of value |
| **orto-fungible** | each holding is a distinct object with its own contents and one owner |
| **semi-fungible** | one design held in integer quantities by many — a ticket tier, an item |
| **non-fungible** | each unit is unique, with traits |

The decision most often got wrong is orto- versus semi-fungible, because both carry metadata and
both have a quantity. The distinction is ownership: **an orto-fungible parcel has exactly one
holder, recorded on the parcel.** A semi-fungible nonce has no holder at all — holdings live in a
separate table.

A vesting schedule is orto-fungible. A concert ticket tier is semi-fungible.

---

## 2. What issuance costs

| | virtual gas | native | dollars |
|---|---:|---:|---:|
| true or orto-fungible | 1,019 | 100 | **$10** |
| semi-fungible collection | 2,049 | 200 | **$20** |
| non-fungible collection | 2,549 | 250 | **$25** |
| a company (equity) | — | 1,200 | **$120** |

Issuance is one of the few operations charging **both** currencies. The premium is deliberate: a
chain full of abandoned tokens is worse for everyone than the barrier is for anyone.

Ordinary operations on your token afterwards cost cents — a mint is $0.87, a burn $0.72.

---

## 3. The flags you set at issuance

Seven, and **most cannot be changed later**:

| | permits |
|---|---|
| `can-upgrade` | changing the token's own settings afterwards |
| `can-change-owner` | transferring ownership |
| `can-add-special-role` | **granting** roles (revoking is always allowed) |
| `can-freeze` | freezing individual holders |
| `can-wipe` | destroying a holder's balance |
| `can-pause` | halting all transfers |
| `iz-special` | marks a derived token — not for ordinary issuance |

This is the most consequential screen in the whole system. **A token issued without `can-freeze`
can never freeze anyone** — which may be exactly what you want, and is worth choosing deliberately
rather than accepting a default.

Note the asymmetry on roles: the flag gates **granting**, not revoking. An issuer who has switched
off role-granting can still take a role away. The alternative would trap a mistake permanently.

---

## 4. Roles

Four you can grant, plus a freeze roster:

| | lets an account |
|---|---|
| **mint** | create supply |
| **burn** | destroy supply |
| **transfer** | move the token when transfers are restricted |
| **fee-exemption** | pay no transfer fee |

Granting checks that the recipient is not a contract account, that you own the token, that the
state is actually changing, and that role-granting is enabled.

**Orto-fungibles differ in one way**: their *create* role is held by exactly one account. It is not
toggled, it is **moved** — and only if you enabled that at issuance.

---

## 5. Fees

A fee has a rate, a minimum transfer amount, a destination and a lock.

**Rates are per mille with four decimals**, capped at 999 — a maximum of 99.9%.

There is also a **volumetric tax**: a fee that grows with the size of the transfer, and not
linearly. The amount is decomposed by decimal digit position, and each position contributes its own
rate. Moving 10 costs proportionally less than moving 10,000,000. It is a progressive transaction
tax with no brackets to maintain — the arithmetic is the schedule.

### The fee lock is the expensive decision

Locking your fee tells holders it cannot change. **Unlocking it costs $50 in virtual gas and $50 in
native currency**, and the lock runs for a long fixed duration.

It matters more than the price suggests. Swap slippage protection compares fee-exclusive quotes, so
it does **not** protect a trader against a fee-rate change between quote and execution. A locked fee
is the only thing that does. If you want your token used in pools by people who quote before they
trade, locking is what makes those quotes trustworthy.

---

## 6. Freezing and wiping

**Freezing** marks one holder's balance immovable. Requires the flag at issuance.

**Wiping** destroys a holding — partial or total. Also requires the flag.

Two things to know:

**"Freezing an account" and "a frozen token" are different.** The first is administrative, against a
holder. The second is a voluntary lock a holder chooses, producing a separate `F|` token. They share
a word and nothing else.

**Wiping scales with the asset type.** A true fungible has two wipe operations because a balance is
one number. An orto-fungible has **five** and a collectable **seven**, because a holder may own
thousands of parcels and one transaction cannot touch them all. Large wipes are sliced into disjoint
batches that can run in parallel.

---

## 7. Derived forms, and the link that must exist first

Holders can only vest, sleep, hibernate, freeze or reserve your token **if you created the link
first**.

Creating one issues an entire new token — owned by the protocol, inheriting your decimal precision,
with upgrade and ownership-transfer permanently disabled.

**Three properties, all consequential:**

- Only you, the token's owner, can create one
- The link is **bidirectional** — each side points at the other
- **It is immutable.** Once created, never changed or removed

Not every variant suits every token. Frozen and sleeping links are permitted on pool tokens; vesting
and hibernation are not.

---

## 8. What you cannot undo

Worth a list of its own:

- the seven issuance flags, unless you enabled upgrades
- a special link, once created
- enabling fractionalisation on a collectable
- ownership transfer — it is **one-phase**, and a mistyped destination is permanent

That last one deserves emphasis because nothing in the contract will save you. Verify the
destination before signing.

---

## 9. Branding

Tokens carry a name, description, website and social links, upgradeable monthly. A premium tier
costs **$25 per month**.

Branding is one of the few surfaces shared across asset types — four modules implement the same
interface — so what you learn issuing a fungible applies to issuing a pool.

---

## Where to read next

- `20-assets/01-true-fungibles.md` — roles, fees, freezing, wiping in depth
- `20-assets/06-the-special-variants.md` — what each derived form does
- `50-economics/04-the-price-sheet.md` — every price
