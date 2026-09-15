# Funding continuations — CLOSED as a non-issue (owner ruling 2026-09-15)

> ## RULING — READ THIS FIRST, THE ANALYSIS BELOW IS BACKGROUND
>
> **This is theoretical, not a live concern.** Owner, 2026-09-15:
>
> * **Multi-step transactions only ever existed because the block gas limit was 150k.** With the
>   current 2,000,000 headroom there is no reason to use them. The measurement below
>   (worst case **415,419 gas, 21% of budget**) is the evidence for that, and it is pinned.
> * **The defpact paths are kept for historical / learning purposes only.** They are not the
>   supported route for anything.
> * **The gas station does not pay continuations in production — the CUSTOMER ACCOUNT does.**
>   That is the UI implementation. So the "foreign continuation drains the station" vector does not
>   exist on the supported path: there is nothing to drain, because the station is never the payer.
>
> Consequently **no work is planned here**: no continuation-funding account, no relayer keyset, no
> co-signing service. The `exec`-only gas station stays as it is and is correct.
>
> The `LQ|INITIATION-FEE` charged twice on a griefed add (200 raw) also **stands unchanged** — but
> note its original rationale (protecting the gas station from continuation drain) does not apply
> when the customer pays their own continuation gas. It survives as plain anti-spam, which the owner
> ruled is what he wants.
>
> **Everything below is kept because the mechanism analysis is correct and was expensive to
> establish** — and because the next person to find a double-charge on the add-liquidity rollback
> branch deserves to find the reason next to it rather than reconstruct it.


*2026-09-15. Owner: "is there a way to allow the gas station to pay only continuations of functions
from our namespace?" — then, correctly: "wait, we have `stoa-xchain-gas`, that pays for
continuations on any chain, so accounts CAN be conceived to pay for continuations somehow."*

## CORRECTION to the first answer

The first version of this note answered only about **`gas-payer-v1`** — the `GAS_PAYER` defcap that
`01_DALOS.pact` implements, which whitelists by reading `(at "exec-code" (read-msg))`. That analysis
was right about `gas-payer-v1` and **wrong as a general answer**, because `stoa-xchain-gas` is not a
`gas-payer-v1` module at all.

**`stoa-xchain-gas` is a plain `coin` account whose GUARD does the work** (`stoa-genesis-5.pact`):

```pact
(gas-restriction-guard:guard
    (create-user-guard
        (util.gas-guards.enforce-guard-all
            [ (create-user-guard (coin.gas-only))
              below-or-at-gas-price
              (create-user-guard (util.gas-guards.enforce-below-or-at-gas-limit 850)) ])))
```

`coin.gas-only` is `(require-capability (GAS))` — `GAS` being the magic capability Chainweb puts in
scope only during gas buy/redeem. So the account is **spendable on gas and nothing else**, and it
**never inspects the payload**. That is exactly why it funds continuations: it does not care what the
transaction is.

## What is still true, and what it costs Kadena

**Nothing exposes the pact-id of a continuation.** The buy-gas message carries `tx-type` and — for
exec only — `exec-code`. A `cont` payload is `{pactId, step, rollback, data, proof}` and none of it
reaches Pact. So *payload introspection cannot restrict continuations by namespace*, whichever
mechanism you use.

**Kadena does not solve this either. It bounds the damage instead:** `gas-limit <= 850`. A
`coin.transfer-crosschain` step 1 fits; essentially nothing else does. The restriction is *size*, not
identity.

For Ouronet that bound does not transfer. Measured continuation steps of `MTX|C_AddLiquidity`:
**step 1 = 162,334 gas, step 2 = 30,262**. A cap sized for those is ~200,000 — **235x** Kadena's 850.

## The mechanism that DOES restrict to us: authorisation, not introspection

A user guard is arbitrary Pact evaluated at debit time, so it can `enforce-guard` a keyset. **This is
already proven in your own genesis code** — `final-guard` composes exactly that:

```pact
(util.guards.enforce-or (keyset-ref-guard "ns-admin-keyset") gas-restriction-guard)
```

So a continuation-funding account can be guarded by an **AND** of four conditions:

```pact
(enforce-guard-all
  [ (create-user-guard (coin.gas-only))                                   ;; gas only, never transferable
    (create-user-guard (enforce-below-or-at-gas-price <protocol-min>))    ;; cheapest possible
    (create-user-guard (enforce-below-or-at-gas-limit 200000))            ;; sized to the measured step 1
    (keyset-ref-guard "ouronet-ns.cont-relayer-keyset") ])                ;; <-- ONLY OUR TRANSACTIONS
```

**Foreign continuations are excluded not because we inspect them, but because they cannot be
signed.** That is strictly stronger than a namespace check: a namespace check trusts what the payload
claims; a signature check trusts a key you hold.

### Two economics facts that make this safer than it first looks

* **Kadena charges for gas USED, not the declared limit** — unused gas is refunded at redeem. So a
  high cap does not mean a high per-transaction loss; the loss is what the attacker's continuation
  actually consumes.
* **An attacker must fund their own step 0 first.** Your `exec` station only pays for
  `(ouronet-ns.TS…` code, so starting a foreign defpact costs the attacker real KDA. Continuations
  are not free to manufacture.

### The trade-off, stated plainly

The relayer keyset means **every continuation must be co-signed by Ouronet infrastructure**. If users
submit continuations directly today, they would need a signing service. That is a real operational
cost, and it is the whole price of the feature.

## The alternative that removes the question instead of answering it

**Every multi-step defpact already fits in ONE transaction**, measured under the same `table` gas
model chainweb uses, all steps inside a single `begin-tx`:

| defpact | gas, all steps, one tx | of `DALOS\|GAS-BUDGET` (2,000,000) |
|---|---:|---:|
| `MTX\|C_AddLiquidity` (standard) | **415,419** | **21%** |
| `MTX\|C_Issue` — stable pool | 176,945 | 9% |
| `MTX\|C_Issue` — standard pool | 127,357 | 6% |
| `MTX\|C_Issue` — weighted pool | 106,912 | 5% |

**4.8x headroom on the worst case**, including harness overhead. Pinned at `DEFPACT-BILLING.repl`
`<<DPB-01>>` against **half** the budget — if it ever crosses, the collapse stops being available.

Collapse the `MTX|` defpacts into single-tx `C_` ops and there are no continuations to fund, no
relayer to run, and no grief deterrent needed.

## Recommendation

1. **Prefer the collapse.** It removes an entire class of problem for 21% of a gas budget.
2. **If continuations must stay**, the relayer-keyset guard above is the correct shape, on a
   **separate, thinly funded account** whose balance is the blast radius.
3. **Verify on chain before trusting it.** Whether a `keyset-ref-guard` evaluates as expected inside
   a guard during *buy-gas* is exactly the kind of thing that must be smoke-tested live rather than
   reasoned about — the REPL does not model the gas-buy phase at all. `stoa-xchain-gas` proves
   `gas-only` + price + limit works; the keyset conjunct is the untested part.

*Until any of this changes, the owner's ruling stands: the 200 grief charge is the deliberate price
of the gap, and it is now written down so it does not read as a double-charge to the next person.*
