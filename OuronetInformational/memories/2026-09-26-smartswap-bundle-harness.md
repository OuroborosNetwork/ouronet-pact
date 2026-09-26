# The SmartSwap bundle harness — step 3 of the UI plan  (2026-09-26)

The owner's step 3: *"rewire functions that exist but need new rewiring (the smart swap)."*

## What was wrong

Both executors called `SWP|C_SmartSwapWithSlippage` / `…NoSlippage` **without the bundle** —
their last argument. Pact does not reject a short call; it **partially applies and yields a
closure**, so the transaction was built around a value that is not a swap.

## Why the bundle is not optional, and why the fallback is not a fix

Two SmartSwap families exist and only one fits in a block. Measured, worst case (6 hops, ~102
active pools, Liquid Boost on):

| entrypoint | gas | vs ~2,000,000 ceiling |
|---|---:|---|
| `SWP\|CC_SmartSwap…` self-searching | 7,145,298 | **3.57x OVER** |
| `SWP\|C_SmartSwap…` bundle-based | 397,043 | 0.20x |

So "just point the UI at `CC_`" is not available — at scale it cannot be mined. Assembling the
route off-chain is the entire point of the `C_` family.

## The sequence (handoff §4), and what it depends on

1. **route** — `SWPI::URC_HopperActive(in, out, amount)`. **Never cached**: amount-sensitive, so
   a cached route could be a worse split for this size.
2. **boost path** — `out → DLK`. Cache first (`SWPT::URC_ReadPathCache`), trace on a miss
   (`SWPI::URC_HopperActiveShortest`), `is-new` records which.
3. **stoa-paths** — each distinct pool's first token → **DWK**, deduped by first token.
4. assemble, 5. submit.

**DLK is `UR_SilverStoaID`, DWK is `UR_WrappedStoaID` — different tokens.** The handoff records
conflating them as a real bug found while tracing `URC_PoolValue`. A test asserts the direction
of every cache read and that `OUT → DWK` is never asked for.

**Dedupe by first token, not per pool.** Redundant per-pool searching was 56.9% of the original
102-pool worst case.

`[BAR]` (the pipe glyph) is the "no path anywhere" sentinel — not an empty list. Reading it as a
real path would submit a route whose only node is a glyph.

Steps 1–4 are **free** `/local` reads. Only submission costs gas, which is what makes the
"discovery shown live" UX honest; `onProgress` reports real work.

## Verified against the chain, not inferred

Every reader name was checked against `describe-module` before any code was written — the recipe
named `DALOS::UR_LiquidStoaID`, which **does not exist**; the real one is `UR_SilverStoaID`.

Then end to end: a bundle built by this exact sequence for `OURO → WSTOA` was fed to
`INFO_SWP|SmartSwapNoSlippageBundle`, which **accepted it and priced the swap at 77 IGNIS**. The
contract's own reader is the only authority that counts, and it agrees.

## Result

Tree-wide, **75 client-entrypoint call sites checked against the registry, 0 mismatched.** That
is every consumer Pact call in OuronetUI and ouronet-core agreeing with the deployed contract —
the state this week's work was aiming at.

858 core tests / 56 files; UI tsc clean, 321 tests / 36 files.

## A near-miss worth recording

The bundle travels in the transaction **data** (`(read-msg 'bundle)`), the same route the
slippage bounds already take, rather than being rendered into the code string. I wrote a
`bundleToPact` literal renderer first and kept it for tooling, but inlining a nested object into
a template string is where a quoting slip is silent — the data payload has a parser on both ends.
