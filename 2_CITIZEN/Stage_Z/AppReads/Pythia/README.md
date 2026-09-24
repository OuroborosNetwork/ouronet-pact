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

## Where they live now

**In git, not on chain.** This section used to say they would survive the stub, because archive
mode keeps readers and deletes only mutators. That was wrong for a module that is *nothing but*
readers: applied literally the rule would have deleted nothing, and the version of the stub
written on that reasoning kept seven reads alive purely because they referenced each other.

Counting call sites settled it — these three have **zero**, in OuronetUI, in
`@ouronet/ouronet-core`, in every other Pact module, in the websites. `PureV2/14` deletes them
with the rest.

Nothing is lost that mattered. All three are thin passthroughs over `PYTHIA`'s own readers:

```
URC_0031                    (map PYTHIA::UR_ApiKeyRowOrNull  apollo-accounts)
URC_0033_DualApiKeyMapper   (map PYTHIA::UR_DualLinkRowOrNull dual-api-keys)
URC_0034_PythiaPrices       PYTHIA::UR_DeployPrice / UR_RenamePrice, plus display text
```

The rows they return are PYTHIA's, and a console can read them from PYTHIA directly. The only
thing the wrappers add is one round trip instead of N — worth having, and worth building *here*
as `P-UI-ONE` when there is a screen to shape it around. Their bodies are one revision back in
git; recovering them is a copy, not a rewrite.

When that console exists, port them the same way everything in `OuronetUI/` was ported: from the
screen, not from the contract.
