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
| *(pending)* `02-signing-and-caps.md` | Which capabilities a client must sign for, per operation class | not started |
| *(pending)* `03-cost-preview.md` | `INFO_` / `URCi_` readers and what a user should be shown before signing | not started |
| *(pending)* `04-errors.md` | How Ouronet's refusals read, and which are user error vs state | not started |

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
