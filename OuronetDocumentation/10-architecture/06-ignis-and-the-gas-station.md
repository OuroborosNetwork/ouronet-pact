# IGNIS and the gas station

Ouronet charges for its operations in its own unit, and pays the host chain's fees on the user's
behalf. Those are two separate mechanisms that are easy to confuse, so this chapter states the
distinction before anything else:

> **IGNIS** is what an operation *costs*. The **gas station** is who pays the *chain* for
> including the transaction. A user pays the first and, in almost every case, does not pay the
> second.

A user with zero native STOA can still transact. That is the design goal, and everything below is
how it is achieved.

---

## 1. What IGNIS is

IGNIS is Ouronet's virtual gas. It is an ordinary Ouronet fungible token, held in a dedicated slot
on each account row rather than in the general ledger, and it has a **hard peg**:

> **1 IGNIS = 1 US/EUR cent.**

That peg is what makes the whole price list legible. A price of 2,549 IGNIS is $25.49, and every
pricing decision in the system can be argued about in dollars rather than in an abstract unit
whose value drifts.

Users acquire IGNIS by converting the protocol's own token, OURO, in either direction:

| | |
|---|---|
| **Sublimate** | OURO → IGNIS, at `floor(price × 100 × amount)` |
| **Compress** | IGNIS → OURO, minus a 15‰ fee |

Both conversions are themselves **free**. Charging for the act of acquiring the means to pay would
be a bootstrapping problem.

**The whole thing is switched off by default.** Virtual gas collection is behind a toggle whose
genesis value is `false`, with an independent twin for native STOA collection. The economy is
fully built and dormant — which is a deliberate sequencing choice, not an unfinished state.

---

## 2. The cumulator: how a price is assembled

A single user operation touches several modules. Each contributes its own cost, and those costs
must survive the trip back up the call tree without any one module being able to under-report.
The structure that does this is the **cumulator**.

```pact
(defschema ModularCumulator          ;; one leg
    ignis:decimal
    interactor:string)

(defschema OutputCumulator           ;; what a client function returns
    cumulator-chain:[object{ModularCumulator}]
    output:list)
```

A leg is a charge with a **recipient**. It travels in four stages:

| stage | what happens |
|---|---|
| **1. Construct** | each priced operation emits one leg — an amount and who earns it |
| **2. Concatenate** | a composing function folds its callees' chains into one flat list |
| **3. Compress** | legs sharing a recipient merge into a single summed charge each |
| **4. Prime** | the payer's discount is applied, and each charge is split |

Stage 4 is where the economics live. The payer's **elite tier** discounts the whole bill, and each
remaining charge is then split: **25%** to the smart-account recipient that earned it, the rest to
the protocol's gas tanker. Legs with no identifiable recipient go entirely to the tanker.

So the cumulator is not just a total — it is an itemised bill with payees, and the split is what
lets a pool or a token issuer earn from the traffic they generate.

### Why leg-level detail matters

It would be simpler to return one number. The reason not to is recorded in the test suite: on
2026-09-14 a single assertion caught a preview that had **split one leg into two** — with the
total unchanged. Every total-level assertion in the system passed it. Only the leg-level check
saw it.

An operation that charges the right amount to the wrong recipient is invisible to any test that
looks at the sum.

---

## 3. The cost model

Two terms, added:

```
IGNIS  =  deterrence  +  components
```

**Components** is the modelled cost of the work: table writes, reads, cross-module calls, each
weighted. **Deterrence** is a deliberate business premium — a policy decision about what an
operation *should* cost, independent of what it costs to run.

Deterrence is why issuing a token is expensive. Creating a swap pool computes almost nothing and
costs **5,000 IGNIS ($50)**, because a chain full of abandoned pools is worse for everyone than a
$50 barrier is for anyone.

| operation | IGNIS | in dollars |
|---|---:|---:|
| Transfer-class op (`DPTF\|C_Transmute`) | 5 | $0.05 |
| Burn a token | 72 | $0.72 |
| Mint a token | 87 | $0.87 |
| Issue a fungible-vault token | 1,019 | $10.19 |
| Issue a non-fungible collection | 2,549 | $25.49 |
| Issue a swap pool | 5,087 | $50.87 |

Everyday actions cost cents. Creating permanent structure costs tens of dollars. That gradient is
the entire pricing philosophy, and it is visible in the numbers without explanation.

**The component weights were calibrated against measured gas, and the measurement overturned three
of four modelled parameters.** Read costs moved from `1/1/2/3` to `1/2/5/9`; the update divisor
changed; the wipe ceiling moved from 120 to 1,000. Only the write multipliers survived contact
with the data. Collectible wipes measured **2.3× heavier** than ortofungible ones — 952 against
406 gas per item.

### The published price list

**440 priced client functions**, generated rather than written:

| | |
|---|---:|
| exact price | 183 |
| floor price (scales with an item count) | 137 |
| STOA-only | 2 |
| free / exempt | 118 |
| **total** | **440** |

The sheet is a **generated artefact**, regenerated and diffed by the gate. Editing it by hand is a
gate failure. That matters more than it sounds: a price list maintained by hand is a price list
that disagrees with the contract, and the disagreement is always discovered by a user.

### One price is fixed in the wrong unit, deliberately

StoicTag registration costs **1 STOA per character**, not a dollar amount converted at the peg.
The source carries an explicit instruction not to "correct" it. It is worth knowing that the rule
has exactly one exception and that the exception is recorded as a ruling rather than an oversight.

---

## 4. The gas station

The chain still charges for including a transaction, and somebody must pay it. Ouronet implements
StoaChain's own `gas-payer-v1` interface — the **only interface in the system that Ouronet
implements without defining** — and sponsors the fee from a protocol account.

The mechanism is a capability, `GAS_PAYER`, which inspects the transaction and decides whether to
pay. It applies two gates.

### Gate 1 — the budget

The transaction's `gas-price × gas-limit` must fit within a fixed allowance, computed against the
**live minimum gas price read from the `coin` contract at enforcement time**, not a stored
constant. So the allowance tracks the chain's economics instead of decaying as they move.

The governance keyset bypasses this.

### Gate 2 — what the transaction is allowed to contain

This is the interesting one. The station reads the transaction's own code and accepts exactly
three shapes:

| case | shape |
|---|---|
| **1** | one call, prefixed by `coin.C_`, a Talos entrypoint, or one of two named citizen modules |
| **2** | exactly two calls, both `coin.C_` |
| **3** | a namespace declaration, an IGNIS transmute, then an arbitrary `let` block |

**Case 3 is a product, not a loophole.** It is the sponsored-custom-code door: pay in IGNIS, and
the gas station will underwrite an arbitrary Pact block. Forms beyond the third are deliberately
not inspected — the point is that they are arbitrary.

Its price is a flat **25 IGNIS**, and that number is load-bearing in three places at once. The
source says so plainly:

> "Anyone tightening the minimum, repricing the transmute, or editing the gas station's form list
> is touching one leg of that tripod. **All three legs are needed.**"

That comment exists because the three constants are in three different modules and none of them
looks connected to the others.

### How much is sponsored

Measured from the generated registry, all **423** client entrypoints carry a sponsorship record:

| | |
|---|---:|
| fully sponsored | **405** |
| first step only | 10 |
| not sponsored | 8 |

The 10 are multi-step operations. Their continuations arrive as `cont` payloads with **no
transaction code**, and a station that decides by reading the code cannot evaluate what is not
there. The customer pays for those steps. That is a genuine architectural limit, recorded rather
than glossed.

### The station funds itself

Native STOA fees, where charged, split four ways on a fixed **10/20/30/40**: the holding company,
the gas station, protocol maintenance, and the liquid-staking contract — the largest share to
stakers.

**20% returns to the gas station**, which is how sponsorship is paid for. There is also an
automatic top-up after issuance operations.

The split is a constant, and the source is emphatic about why:

> "**THE SPLIT IS NOT A PARAMETER, deliberately.** It used to be, and that let a caller hand this
> function any four numbers."

Every collector funnels through a single function that the source names "the protection point for
the whole STOA path" — one place to audit rather than a dozen.

---

## 5. Two currencies, two switches

| | **IGNIS** | **STOA** |
|---|---|---|
| what | virtual gas | the chain's native coin |
| charged on | nearly every operation | **issuance only**, plus a handful of named fees |
| paid by | the patron's IGNIS balance | the patron's StoaChain account |
| maximum discount | **49%** | **24.5%** — exactly half |
| default | off | off |

The discount comes from the account's elite tier, and the STOA discount is precisely half the
IGNIS one. Both are computed by the same function with a boolean.

STOA is charged **only where something permanent is created** — issuing a token, a pool, an
account, a branding registration, unlocking a fee. Ordinary usage is IGNIS-only. And no STOA price
is hardcoded: every one derives from a dollar figure divided by the current STOA price.

---

## 6. The patron

Every client entrypoint takes **`patron` as its first argument**. The patron is who pays, and it
need not be who acts — that is `executor`, the second argument. The separation is what lets one
account underwrite another's operation.

Who may be a patron is constrained: **a Smart account may be the patron only if it is the gas
station itself.** Any Standard account may pay its own way.

### GASLESS-PATRON, and why it is an exemption rather than a bypass

Admin operations run through the gas station's own account, which is the single account exempt
from IGNIS collection. The source is precise about what that means:

> "the collection runs **exactly as any client's does** — it is simply served by `GASLESS-PATRON`,
> the one account the collector exempts. **The path is preserved, not skipped**; that is what makes
> an admin call gasless."

A skipped path is untested; an exempt payer walks the same code everyone else does.

**This exemption used to be much wider, and the narrowing is the clearest security lesson in the
module.** The check originally asked whether the patron was *any smart account* — and since every
smart account is flagged as one at creation, and anyone may create one permissionlessly, the
exemption was available on request through the custom-code door. It now compares against one named
constant.

The source comment states the general form:

> "a convention that is honoured is indistinguishable from a rule that is enforced, until someone
> does not honour it."

Narrowing it was verified safe by measurement rather than by argument: all 37 genuine patron slots
passing a smart-account constant were in a single module.

---

## 7. What the tests hold

Pricing carries **181 dedicated assertions** in three suites — 64, 42, and 75.

The 75 are the leg-level ones, and they are **not in the fast test path**. That is a deliberate
trade with a known cost, and it is the reason the project's own instructions say pricing changes
must be verified with the exhaustive runner rather than the quick one.

There is a second protection that matters more than a count. Every priced operation has a single
cost function, and **both the billing path and the UI preview call it**:

> the exec path and the preview cannot drift, because they are the same function.

A quoted price that differs from the charged price is the single worst failure a payment system
can have, and this design makes it unrepresentable rather than merely tested.

---

## 8. Where the documentation has drifted

Researching this chapter surfaced ten disagreements between the source and the prose describing
it. Most are small; three are worth recording because a reader may meet them.

**The collectors were renamed and the tables were not.** On 2026-09-20 the gas collectors stopped
being client functions and became protected internal ones — `IGNIS::C_Collect` is now
`XE_CollectIgnis`, and the `STOA|C_Collect*` family is now `XB_CollectStoa*`. The old names appear
nowhere in the source. They still appear in this repository's own instruction file and in the
pricing reference, **in the very documents that record the rename**.

That rename had a measurable cost, recorded at the time: the price-sheet generator detected one of
the billing shapes by grepping for `C_Collect`, silently stopped recognising it, and dropped three
readers from the sheet. The lesson written down afterwards:

> "A rename pass has to carry the **tools** that grep for the old name."

**The discount doc is wrong by half a point.** A docstring states a 49.5% maximum; the code
computes `7 × 6 + 7 = 49`. The pricing reference says 49% and is correct.

**"Talos is the only place IGNIS is collected" is overstated.** Sixteen collection calls live in
core multi-step operations — fourteen in one module, two in another. The behaviour is intended and
documented elsewhere as a distinct billing shape; the sentence is simply too absolute.

None of these changes what the system does. They are recorded here because this documentation's
whole claim is that it was checked, and a chapter that found ten drifts and mentioned none would
be making the same mistake it is describing.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` — cumulators, the cost maps, the collectors
- `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` — the gas station and its two gates
- `1_SOVEREIGN/STAGE_01/3_Talos/` — where collection is invoked
- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md` — the authoritative cost model
- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md` — the generated price list
- `REPL/RedTeam/[RT-I]_GasStation.repl` — the gas station's adversarial tests

Sponsorship counts were computed from `Deploy/OURONET-REGISTRY.json`; price totals are the
generated sheet's own footer. See `90-reference/03-how-these-figures-were-obtained.md`.
