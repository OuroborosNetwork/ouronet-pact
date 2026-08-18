# 2026-08-17 — `MTX-SWP`'s multi-step (defpact) design is historical, not a current gas requirement

**Context:** SWP audit, finding C9 (pools issued through `MTX-SWP`'s `defpact` path never got a `SWP|LP`
registration row). While fixing it, owner explained *why* the multi-step path exists at all, and that the
underlying constraint that motivated it no longer applies.

## What was true when `MTX-SWP` was built

Transactions were constrained to a ~150,000 gas ceiling. A 7-pool-token issuance (validating tokens,
inserting `SWP|Pairs`, minting/deploying the LP token, wiring principal/tracer state, etc.) could exceed
that in a single transaction, so `MTX-SWP` splits issuance/liquidity-add flows across `defpact` steps —
each step small enough to fit under the old ceiling, continued across separate transactions.

## What's true now

StoaChain's actual live gas limit is **~2,000,000 gas per transaction** (see
`OuronetInformational/pact5/SEMANTICS.md`'s gas table). A single transaction can go well above the old
150k ceiling and still complete — comfortably enough for even a 7-pool-token issuance to run as one
transaction today. **The multi-step mechanism is no longer technically required for gas reasons.** It's
kept live for two reasons only: historical continuity (real pools were already issued through it — e.g.
`pool7` in the SWP audit's own REPL fixtures), and as a worked `defpact`/multi-step example elsewhere in
the codebase.

## Why this matters for future work

- **Don't assume new issuance/multi-step flows need gas-driven splitting.** That constraint belonged to a
  gas limit that no longer applies. A new single-tx flow is a legitimate default choice now, not something
  that needs justifying against the old 150k ceiling.
- **This context is directly why C9 slipped through.** `SWPI::C_Issue` (the single-tx path) remembered to
  call `XE_AddLPTracker`. `MTX-SWP`'s own `XE_Issue` call was added *later* and never got the same
  follow-up wired in — two issuance paths, one bookkeeping step, only one caller remembered it. Fixed by
  folding the `SWP|LP` insert into `SWP::XE_Issue` itself (`15_SWP.pact`), so every issuance path gets it
  "for free" instead of relying on each caller to remember a standalone call.
- Documented directly above `(module MTX-SWP GOV` in `20_MTX-SWP.pact` so a future reader doesn't have to
  ask "why does this split into steps?" and doesn't assume the split is still gas-mandatory.

## Durable rule

When auditing or extending anything that composes several writes across module boundaries (issuance,
multi-leg liquidity ops, etc.): if there are **two or more call paths that both need the same follow-up
bookkeeping step** (a tracker insert, a registration, a role grant), fold that step into the shared
function both paths already call, rather than leaving it as a standalone call each path's author has to
remember separately. This is the same shape as C9 and is a good thing to check for generally, not just in
`SWP`.
