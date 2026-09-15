# The gas station cannot whitelist continuations — settled, with the measurement that makes it moot

*2026-09-15. Owner question: "is there a way to allow the gas station to pay only continuations of
functions from our namespace? I couldn't find one and I still think it's impossible to code."*

## The answer: correct, it is not expressible — and the reason is structural

The Ouronet gas station (`01_DALOS.pact`, `GAS_PAYER`) whitelists by reading the transaction's code:

```pact
(exec-lines:[string] (at "exec-code" (read-msg)))
... (enforce (= "(ouronet-ns.TS" (take 14 (at 0 exec-lines))) "Only TALOS or DSP Modules allowed")
```

**That is the whole surface Chainweb gives a gas payer.** The buy-gas message carries:

| field | present for | contents |
|---|---|---|
| `tx-type` | exec **and** cont | `"exec"` / `"cont"` |
| `exec-code` | **exec only** | the list of top-level code strings |
| — | cont | **nothing identifying the pact being continued** |

A `cont` payload is `{pactId, step, rollback, data, proof}`, and **none of `pactId` / `step` is
exposed to Pact during gas buy**. So "pay only for continuations of our namespace" has nothing to
test. `tx-type` is the only lever and it is all-or-nothing: allow conts and you subsidise the
continuation of *any* defpact anyone has ever started.

**Independent confirmation is already in this repo.** `Audit/SWP/reference/KADDEX-SOURCE-4.md:35` —
Kaddex, a production DEX built on defpacts — does exactly one thing about it:

```pact
(enforce (= "exec" (at "tx-type" (read-msg))) "Inside an exec")
```

They hard-refuse. Same conclusion, reached independently, by the largest defpact user on the chain.

### Why the obvious workarounds fail

* **Put the pact-id in the cont payload's `data` and check it against a table step 0 wrote.** The
  `data` field is not bound to the actual continuation target. An attacker continues *their own*
  pact while quoting a sanctioned id, and the station pays.
* **Require a signed capability naming the pact.** Signing a capability does not constrain which
  payload the transaction carries. Same hole.
* **Cap the gas limit for conts.** Caps the drain per transaction; does not bound the count.
* **Rate-limit by writing from `GAS_PAYER`.** A capability body is the wrong place for state, and it
  still cannot tell our continuation from theirs — it only meters the bleeding.

## The measurement that makes the question moot

The deterrent exists to protect a path that no longer needs to exist. **Every multi-step defpact in
Ouronet runs end to end inside ONE transaction**, measured under the same `table` gas model chainweb
uses, with all three steps in a single `begin-tx`:

| defpact | gas, all steps, one tx | of `DALOS\|GAS-BUDGET` (2,000,000) |
|---|---:|---:|
| `MTX\|C_AddLiquidity` (standard) | **415,419** | **21%** |
| `MTX\|C_Issue` — stable pool | 176,945 | 9% |
| `MTX\|C_Issue` — standard pool | 127,357 | 6% |
| `MTX\|C_Issue` — weighted pool | 106,912 | 5% |

Worst case is **4.8× inside the budget**, and those figures *include* the harness's own preview call
and balance reads, so the operations are cheaper than shown.

**Pinned**, so the headroom cannot quietly evaporate: `DEFPACT-BILLING.repl` `<<DPB-01>>` asserts the
whole defpact completes under **half** the budget. Half, not all — if it ever crosses that, the
single-transaction collapse stops being available and this question comes back.

## What follows

1. **Keep the gas station `exec`-only.** It is not a limitation to work around; it is the only safe
   setting, and the industry agrees.
2. **The multi-step path can be retired.** Collapsing each `MTX|` defpact into a single-tx `C_`
   removes the continuation from the gas-paid surface entirely.
3. **Then the grief deterrent becomes unnecessary.** `LQ|INITIATION-FEE` is charged at step 0 *and*
   again on the step-1 rollback branch — 200 raw on a griefed add. That 200 exists to protect the
   gas station from continuation drain. No continuations, no drain, no need for the deterrent.

*Until then the owner's ruling stands: 200 it is, and it is the strongest anti-spam. It is a
deliberate price paid for a structural gap in `gas-payer-v1`, not an oversight — and that is worth
recording, because it looks like a double-charge to anyone who finds it later.*
