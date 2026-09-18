# Init steps

1 init/config steps, in sequence order. **These are extracted, not generated.**

Each file carries the real forms from its source block with the REPL scaffolding (`print`, `expect`, `env-*`) stripped, plus the signer keys that block used. The `env-sigs` keys are REPL names -- translate them to the real signers your pipeline uses.

**Two things this cannot do for you.** It cannot know your keysets, and it cannot decide which blocks are sandbox fixtures. Blocks matching a fixture keyword are flagged in their own header; the flag is a keyword match, so a required block can be flagged and a fixture can be missed. Read each one.

| file | step | forms | label | flag |
|---:|---:|---:|---|---|
| `01_init.pact` | 20 | 1 | deploy-stage02 · AQP-BOOT Step0 WireImcAndGovernor |  |

**1 steps** · 0 flagged as possible fixtures · 0 carry no deployable forms (pure REPL scaffolding).

