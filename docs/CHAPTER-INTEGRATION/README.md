# Chapter — Integration: how to wire a client to Ouronet

Work folder for the documentation chapter of the same name. Material here is written to be
**used first and published second**: every document is a working handoff that a UI implementer
can follow today, and the chapter is assembled from them rather than written separately.

That ordering is deliberate. A chapter written after the fact describes what someone remembers
doing; a chapter assembled from the handoffs people actually followed describes what works,
because anything that did not work got corrected while it was being used.

## Contents

| file | what it is | status |
|---|---|---|
| `01-client-orchestration.md` | **The comprehensive one.** Every pattern where a client must do a dirty read, build something from the result, and then execute — including the multi-transaction and parallel forms. | written |
| `02-signing-and-caps.md` | The patron/executor/executee split, the `GAS_PAYER` shape, whose ownership is actually enforced, and the four purchases needing a computed capability | written |
| `03-cost-preview.md` | `INFO_` readers, the `ClientInfo` shape, and the four ways to display a confidently wrong number | written |
| `04-errors.md` | How Ouronet's refusals read, and — measured — which ones `try` can catch | written |
| `05-reading-data.md` | The per-surface AppReads modules, the read cadence, and what a response actually contains | written |

## Reading order

A client integrator does not need these in numeric order. The dependency runs:

1. **`05`** — how to read anything at all, and what comes back. Everything else assumes it.
2. **`03`** — what an operation costs, because you show that before you do anything.
3. **`02`** — who signs, and who pays.
4. **`01`** — the operations that need a read *first*, and how to tell which shape they are.
5. **`04`** — what the refusals mean, kept last because it is the one you return to rather than
   read through.

`01` is the oldest and the most detailed; `04` is the one most likely to save an afternoon.

## What each one is grounded in

The chapter's rule is that a figure is read, not remembered. Where these four get their numbers:

| file | grounded in |
|---|---|
| `01` | the module sources and REPL runs, at 2026-09-24 |
| `02` | `Deploy/OURONET-REGISTRY.json` — sponsorship, ownership and capability blocks, at 2026-09-27 |
| `03` | the registry's paired parameter lists, plus live `/local` calls for the response shapes |
| `04` | a 41-operation unsigned sweep against mainnet, plus direct tests of what `try` catches |
| `05` | the deployed AppReads modules, OuronetUI's redirect table and tier config, at 2026-09-27 |

Two of those measurements contradicted something this project believed. `try` DOES catch a
point read that misses — the first draft of `04` said it did not — and what it cannot do is run
a `select` at all. And `ignis-discount` is the fraction you PAY, not the discount, while the
text beside it quotes the complement. Both are recorded in place.

## Sources that live outside this folder

These are load-bearing and are referenced, not copied. Copying them would create a second
version to keep in step, which is the failure this project has hit repeatedly.

- `OuronetInformational/HANDOFFS/HANDOFF-swp-smartswap-bundle-architecture.md` — the SmartSwap
  bundle in full: the two-transaction shape, the bundle schema, the client build sequence, cache
  self-warming, and measured `CC_` vs `C_` gas.
- `OuronetInformational/HANDOFFS/HANDOFF-ui-rewire-map.md` — page by page: what the UI calls
  today, what it must call instead, and the 13 broken write paths.
- `OuronetInformational/HANDOFFS/HANDOFF-read-layer-split.md` — the read-module architecture.
- `2_CITIZEN/Stage_Z/READS_UI/README.md` — the eleven-module roster and its rules.
- `OuronetInformational/STAGE-TWO-EMISSION.md` — the daily emission, including its parallel form.
