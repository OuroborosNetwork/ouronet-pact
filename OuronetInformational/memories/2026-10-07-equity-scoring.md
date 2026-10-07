# 2026-10-07 — share-based (equity) scoring, and three things I got wrong first

Owner ruling: an **`E|` shareholder collection exposes share-based scoring and nothing else**. It is
a built-in mechanism, not a definition; the score row's only remaining degree of freedom is whether
the stake earns debt. Score definitions on an equity collection are **refused**, not ignored.

Shipped as **`Deploy/PureV4`** (6 transactions, 12 modules, 5 changed). `_purev4.py` generates and
checks it; `_purev3.py`'s manifest is now empty and its 8 files are `FROZEN` (executed on mainnet —
`URH_AQP|AllPoolIds` = 7, and those pools exist only if Step 7 ran, which V3/08 carries).

## The code

| where | what |
|---|---|
| `EQUITY` | `URC_IzEquitySemiFungible` — the `E\|` predicate, promoted to the interface. `EquityV2 → V3`. |
| `AQP-SCORE` | `URCx_EquityShareRawWeight` — Σ over staked nonces of `quantity × share value`: `1.0` for nonce 1, the live `URC_SingleSharePerMillions` for tiers 2–8, `0.0` outside 1–8. |
| `AQP-SCORE` | `URC_SignedBaseDeltaForDpsfStake` is three-way: equity → shares, `sft-equality` → flat, else the stored per-nonce table. |
| `AQP-SCORE` | `UEV_SemiFungibleScoreDefinition` refuses an equity collection. |

Weight is denominated in **shares**, so packaging is weight-neutral: 500 loose shares and one
tier-3 package are the same stake. That is the property a stored table cannot promise.

## Three corrections to my own work, kept because the pattern matters

**1. "The owner can raise the share count at any time through `DPDC-MNG::C_AddQuantity` on nonce 1."
False.** It was the stated justification in the module `@doc`, the REPL comment, the emitter
docstring, the six deploy headers and the folder README before anyone checked it.
`C_IssueShareholderCollection` mints exactly 1,000,000 nonce-1 shares and grants `R-AddQuantity` to
`<dpdc>` **alone**; the only two functions that use it (`XI_MakePackageShares`,
`XI_ConvertPackageShares`) credit *package* nonces, never nonce 1, and Make/Break route shares
through `<dpdc>` as **escrow** rather than minting. The observable proof was already in the suite:
`URC_CombineCapacity` reads **400,000**, not 450,000, after a 100,000-share Make — which is only
true if nonce-1 *total* supply never left 1,000,000.

So `URC_SharesPerMillion` is `[100 200 500 1000 2000 5000 10000]` on every equity collection in
existence, and a stored table **would not be stale yet**. The change is still right, for two
reasons that do not depend on the false one: the variable share count is a *stated requirement*, and
deriving now means adding the issuance path later cannot force a re-settling of scores already
issued; and a table has to be *written*, per score × per collection × per nonce, which is the
failure mode the Bloodshed/Nosferatu/Bunnies settling round spent a day on.

**2. A group headed "asserted rather than argued" that only `print`ed.** `TX-EQUITY-004 · 03`
claimed to pin the tracking property and contained no `expect`. It now drives nonce-1 supply
1M → 10M with `env-module-admin` — the same module-admin write the owner uses on mainnet, chosen
*because* no client path exists — and asserts the tier weight follows ×10 while a raw share stays
at 1. Restored in the same transaction.

**3. A cross-suite fixture is a load-order bet, not a fixture.** The dispatch assertion sat in
`[6.2.2]` `<<TX-SCORE-15>>` and read `E|TSEQ-98c486052a51` out of `[6.1.1]`'s collection. Seven of
the eight gate entrypoints that load `[6.2.2]` never load `[6.1.1]`: green under `Stage02_Tester`,
`No value found in table DPSF|T|Nonces` in all seven others. `<<TX-SCORE-15b>>` now issues its own
company under a ticker nothing else uses and rolls the transaction back.

And the reason that assertion had to exist at all: **every helper assertion passed with the dispatch
branch deleted.** Twelve green assertions over a feature that was not wired in. Under the mutation
`<<TX-SCORE-15b>>` reports `expected 750.0, received 0.0` while its ordinary-collection partner still
passes — which is the shape that proves the dispatch reads the *asset*.

## A requirement for the future `C_IssueShares`, found by deriving live

`XI_BreakPackageShares` releases `sspm × amount` nonce-1 shares **from the `<dpdc>` escrow**. `sspm`
scales with total supply; the escrow does not. So a share issuance that mints only into the issuer's
account leaves every outstanding package **unbreakable** — the escrow is under-collateralised by
exactly the inflation factor. A correct `C_IssueShares` must top up `<dpdc>`'s nonce-1 balance in
proportion to every outstanding tier unit, not just credit the issuer.

`UC_Convert` and `URC_CombineCapacity` are both scale-invariant (numerator and denominator inflate
together), so Break is the only path with this exposure. Worth noting that a stored weight table
would have hidden this: the hazard is only visible once you ask what the live value is derived from.

## Open decision: magnitude

With shares as points, Demiourgos Snakes' tier-3 nonce scores **500**, not the 100 the owner
described. Inside one pool only ratios matter (reward share is `user/total`, and a class-3 score
serves exactly one collection), so the constant cancels everywhere except **display**.
Recommendation: keep shares as points — it is the only choice with a meaning ("your score is your
shares") and the only one that makes packaging weight-neutral by construction — and put any divisor
in the UI, where it cannot go stale.
