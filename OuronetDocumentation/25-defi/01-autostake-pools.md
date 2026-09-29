# Autostake pools

The simplest of the three families, and the one that requires nothing of its holders.

You stake a token and receive a **receipt token**. You then do nothing. Rewards enter the pool; the
receipt's redemption value rises; when you leave, you get more than you put in. There is no
claiming, no compounding transaction, no decision to make and no deadline to miss.

---

## 1. The index

One number does all the work:

```pact
index = total_staked / receipt_supply        ;; -1.0 when supply is zero
```

Converting in either direction inverts it:

```pact
receipt_out = floor(stake_in / index)
```

When rewards arrive, the numerator rises and the denominator does not. Every receipt becomes worth
more of the underlying **simultaneously and without any transaction**. That is the whole mechanism.

The sentinel matters: an empty pool reads `-1.0` rather than zero, so "no index yet" is
distinguishable from "an index of zero".

### Starting one requires a real deposit

A pool cannot be kickstarted until its would-be index reaches **0.1**, and only while the current
index is still the empty sentinel. Fuelling an existing pool requires the same floor.

Without that, a pool could be started at a near-zero index, where a trivial deposit mints an
enormous receipt supply.

### The division that was nearly a live fault

Because conversion **divides** by the index, an index of zero is a division by zero. The source
records that this is not a contrived input:

> a reachable live state — any pair whose receipt carries supply minted **outside** the pool reads
> a zero stake against a positive receipt supply, which is exactly the state **the five
> primal-asset pools are in at deploy**

One entry point already refused. Another had no index check and died inside the arithmetic — and,
as the comment notes, that kind of failure `try` **cannot catch**, so it takes down every caller
rather than degrading one field.

The guard now lives in the conversion itself, so a preview and an execution refuse in the same
words. That placement is the actual fix: a check at each call site would have to be remembered at
the next one.

---

## 2. Four ways in

A two-by-two grid over two independent choices — how many pools, and what kind of receipt:

| | one pool | two pools chained |
|---|---|---|
| **liquid receipt** | **coil** | **curl** |
| **hibernated receipt** | **constrict** | **brumate** |

*(The names are snake metaphors. Brumation is the reptile term for winter dormancy.)*

**Coil** is the ordinary case: stake, receive a liquid receipt.

**Curl** does two pools in one transaction. Both receipts are minted inside the protocol account;
only the second reaches you. It exists because the ladder makes two-pool staking the common case,
and doing it in two transactions means paying twice and risking a price move between them.

**Constrict and brumate** produce a *hibernated* receipt — a bond with a time lock, described in
`20-assets/06-the-special-variants.md`.

The four are not interchangeable. Coil and curl require the pool's hibernation mode **off**;
constrict and brumate require it **on**. A pool is in one mode or the other, so at any moment only
two of the four are available to you.

### Two fees, running in opposite directions

Entering a hibernated position costs a fee that **decays with the length of the commitment**:

```pact
fee_promille = max(0, peak − decay × days)
```

Longer lock, cheaper entry. The pool owner sets both the peak and the decay, and the peak is capped
at 800 per mille — 80%.

The resulting token then carries an **exit** fee that decays as its release date approaches, also
peaking at 80%.

**These are different fees pointing opposite ways**, and both top out at the same number, which
makes them easy to conflate:

| | decays with | charged |
|---|---|---|
| entry (pool) | **longer commitment** | when you constrict |
| exit (token) | **elapsed time** | when you wake early |

One rewards committing for longer; the other penalises leaving sooner.

---

## 3. Three ways out

| | |
|---|---|
| **cold recovery** | position-based, with an unbonding period before collection |
| **hot recovery** | mints an orto-fungible unbonding receipt you hold meanwhile |
| **direct recovery** | immediate, one flat fee |

Holdings are recorded in **eight position slots** per account per pool, each carrying its reward
amounts and a maturity time. The slots are what makes unbonding tractable: several withdrawals can
be in flight at once without the pool tracking a list per account.

Not every pool offers every exit. Measured across the fifteen live pairs, **nine have no hot
recovery at all** — and the reader that answers "what is this pool's unbonding token?" returns the
sentinel `"|"` for those nine.

That produced a real defect: a binding read the parcel table keyed by `"|"` and died **before any
guard could run**, because the failing read was inside the `let` that the capability was supposed
to protect. The fix was to acquire the capability *before* the binding. Pinned by a red-team suite.

The general shape recurs throughout this codebase: **Pact's `let` is eager**, so a failing binding
pre-empts every check written below it. Where a binding can fail, the guard has to be above it.

---

## 4. What a pool owner controls

| | |
|---|---|
| **royalty** | a per-mille cut taken from every deposit |
| **hibernation mode** | which two of the four entry operations are available |
| **peak fee and decay** | the hibernated entry fee curve |
| **recovery toggles** | which of the three exits are offered |
| **index decimals** | the precision the index is floored to |

The fee parameters are validated together rather than separately: the peak must be an exact
multiple of the decay. That makes the curve reach exactly zero at a whole number of days instead of
crossing it mid-day, so the cheapest commitment is always a stated duration.

---

## 5. Limitations

**A pool is one-directional and one-asset.** Multiple reward tokens can fund it, but a pool
converts *into* exactly one receipt. Chaining is composition, not a feature of the pool.

**The index only rises through funding.** Nothing about the mechanism generates yield — an
autostake pool is a *distribution* device, and the rewards come from elsewhere: protocol revenue,
a treasury, a swap pool's fees.

**Mode is global to the pool.** Hibernation being on or off decides what is available to everyone.
A holder who wants a liquid position from a hibernating pool cannot have one.

**Recovery fees are the pool owner's to set**, within bounds. The unbonding period and the direct
exit fee are parameters, and a reader should check them per pool rather than assume.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact` — the pool state, the index, the fee arithmetic
- `1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact` — coil, curl, and the three exits
- `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact` — constrict and brumate
- `1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact` — fee bounds and position records
- `REPL/RedTeam/[RT-A]_Economics.repl`, `[RT-H]_InputDomain.repl` — the two pinned near-misses

Live per-pool settings — current indices, royalty rates, mode toggles — are not quoted here. They
change; see `90-reference/03-how-these-figures-were-obtained.md`.
