# ── PASTE TO THE CODEX AGENT ──────────────────────────────────────────────

A new package is live: **`@ouronet/talos-registry@1.1.0`** (npmjs.org, public). It is the
Ouronet callable surface generated from the **deployed** contracts — 423 entrypoints, their
parameters in declared order, their `INFO_` previews, capability recipes, example values.

**Your brief:**
`_onchain/Ouronet/OuronetInformational/HANDOFFS/HANDOFF-talos-registry-CODEX.md`
(read `HANDOFF-talos-registry.md` beside it first — API, and the three traps.)

## Why you, specifically

I audited every `ouronet-ns.<module>.<function>` string in `@ancientpantheon/codex@0.11.0`'s
`dist/` against mainnet:

> **34 distinct names. 19 return `has no such member`.**

They work **only inside OuronetUI**, which rewrites them at the transport before they leave the
browser. Standalone — which is what "standalone codex package" means — all nineteen fail as
**resolution errors**, which `try` cannot catch, so they do not throw: they surface as an empty
panel. The brief lists all nineteen with their verified live replacements.

**The table is not the fix.** Those nineteen were each correct when written. `buildCall` takes
your values and renders the name, order and types from the deployed surface, so nothing in your
source names a function again.

## How to depend on it — you do NOT embed it

Declare it as a **`peerDependency`**, exactly as you already do for this class of package:

```json
"peerDependencies": {
  "@ouronet/ouronet-core":   ">=4.6.0",
  "@ouronet/dalos-crypto":   ">=4.4.0",
  "@ouronet/talos-registry": ">=1.1.0"     // <- add
}
```
Plus a `devDependency` on it so your own build and tests resolve — peers are not installed for you.

**This answers "must I re-embed and republish on every registry update?" — no.** The consuming
app installs it, you use what is in the tree, and a registry update reaches every consumer
**without Codex publishing anything**. You publish when *your code* changes.

**Do not bundle it.** A bundled copy plus the app's copy is two `surfaceHash`es in one process,
and a registry whose value is being *the* answer to "what is callable" must not have a rival in
the same tree. Peer guarantees exactly one copy — which is also what makes the version readout
below meaningful rather than decorative.

## Show the version in Codex settings

Because it is a peer, the version you display **is** the version the whole app composes. Read it
from the installed package at build time so it cannot claim a version that is not there, and show
`surfaceHash` beside it. A Codex on one surface inside an app on another is a real state, and
this is the only place it becomes visible before it becomes a bug report.

## Done means

- zero `ouronet-ns.` literals in your source
- your package exercised **from an empty directory with no OuronetUI present** — the test that
  would have caught all nineteen
- `surfaceHash` + version in settings
- a test walking every key you use through `tryGetEntrypoint`, so the next rename fails your suite
  instead of a user's panel

## Two things that will trip you

1. **The preview's parameter list is not the entrypoint's — 410 of 423 differ.**
   `INFO_DPTF|Transfer` is `(patron id sender receiver transfer-amount)`; `C_Transfer` is
   `(patron executor executee id transfer-amount method)`. Merge real values on
   `getPreview(key).params`, never positionally against the execution signature.
2. **When you grep for your own call strings, watch for namespace aliases** —
   `const NS = KADENA_NAMESPACE`, `import { KADENA_NAMESPACE as NS }`, a value passed as a prop.
   A scan that knows only the literal spelling missed four files in OuronetUI, one holding a live
   funding bug. And strip comment-only lines, or you will chase
   `ouronet-ns.CODEX.register-codex-identity`, which is a doc-comment mention, not a call.
