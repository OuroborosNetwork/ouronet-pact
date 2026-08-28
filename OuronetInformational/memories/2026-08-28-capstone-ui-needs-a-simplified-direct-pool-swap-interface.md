# Capstone/UI phase needs a simplified direct-pool-swap interface, not the SmartSwap tab (2026-08-28)

**For whoever picks up the Ouronet capstone phase on `main`** — the phase that designs and builds
the UI elements needed to bring the whole on-chain functionality to life. This is a UI/UX direction
note, not a code fix; nothing in this repo changes because of it.

## The problem, as the owner described it

Right now, on the existing UI, the **SmartSwap tab gets used even for the trivial case** — a single
pool, a direct on-pool swap, with none of SmartSwap's actual reasons for existing (multi-hop
routing, cross-pool value comparison, STOA repricing across several touched pools). Direct
single-pool swaps have none of these issues — there's nothing to route, nothing to compare, nothing
multi-hop about them. Funneling that simple case through the same interface built for the complex
one is, in the owner's own words, "a bit too complicated."

## The ask

When the capstone phase designs the UI, **add a separate, simplified swap interface specifically for
direct pool swaps** — distinct from the SmartSwap tab, not a variant/mode of it. The direct-swap
case is structurally simple (one pool, one hop, no routing decision to make) and its UI should
reflect that simplicity directly, instead of reusing SmartSwap's own UI shape (route display, slippage
config framed around multi-hop uncertainty, etc.) for a case that doesn't need any of it.

## Relevant context from the SWP work that motivated this note

This surfaced while closing out `#65bL` (the SWP audit's on-chain graph-search engine optimization,
see `1_SOVEREIGN/STAGE_01/2_Core/Audit/SWP/ROUND-01-OWNER-FEEDBACK.md` and
`OuronetInformational/HANDOFF-swp-graph-search-engine-optimization.md`). Part of that closing
discussion was about SmartSwap's own on-chain routing search dropping from best-of-3 to
first-found-only (Phase 5) — the owner's own reasoning for accepting that tradeoff was partly
grounded in "on the UI we have the smart swap tab, that is used even now when there is a single
pool, and direct on-pool swap, which has none of these issues" — i.e., a chunk of SmartSwap's
current real-world traffic is arguably mis-routed traffic that a proper direct-swap interface would
naturally separate out, leaving SmartSwap itself to handle what it's actually for (genuine multi-hop
routing) rather than being the default entry point for every swap regardless of complexity.
