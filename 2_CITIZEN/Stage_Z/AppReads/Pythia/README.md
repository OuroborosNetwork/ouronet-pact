# Pythia — `P-UI-<N>`

**Nothing here yet, and that is a decision rather than a gap.**

## The three reads that would have gone here

DPL-UR carries three PYTHIA reads:

| read | what it answers |
|---|---|
| `URC_0031` | the API-key row for a list of Apollo accounts (`₱.` / `Π.`) |
| `URC_0033_DualApiKeyMapper` | the dual-link row for a list of composite Standard\|Smart keys |
| `URC_0034_PythiaPrices` | the STOA deploy and rename prices, with display text |

A workspace-wide search for those three names across every `.ts`, `.tsx`, `.js`, `.json` and
`.md` in `_libs/`, `daimons/`, `websites/` and `_onchain/` returns **two hits, both of them
this migration's own paperwork**. No application calls them.

## Why they are not being ported

The rule is in [`../README.md`](../README.md): **reads are PULLED by a UI, not PUSHED by a
contract.** Every module in `OuronetUI/` was ported from what the front end demonstrably
calls, which is what made the key shapes verifiable — the port could be diffed object-for-object
against DPL-UR on real inputs and the answer was either identical or it was not.

For a console that does not exist there is nothing to diff against. A `P-UI-ONE` built now
would be three functions in a shape guessed from three function names, and the guess would be
contradicted by the first real screen. That is the same reasoning that blocks OuronetUI slot 11
(`AtsPairs`, a mockup that reads the chain zero times), and it is how `URC_0001_HeaderV3` became
one seventy-key object in a single eager `let` — a shape nobody asked for, kept because it
already existed.

## Where they live in the meantime

**In DPL-UR, and that costs nothing.** DPL-UR is being reduced to archive mode
(`StoicSyntax-Prefixes.md` §7.21) as its reads move out, and archive mode **keeps every read
function** — only the mutators go. So these three survive the stub untouched, callable the day
a console wants them.

When that console exists, port them the same way: from the screen, not from the contract.
