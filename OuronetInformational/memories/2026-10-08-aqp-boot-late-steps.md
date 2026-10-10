# 2026-10-08 — the AQP-BOOT late steps, and a sovereign sharp edge worth knowing

Three scores on chain are issued from the UI, not by the boot ladder, and the ladder had no
home for any of them: `NosferatuDracula` (class 4), `WonderCoach` (class 3) and `StoicPower`
(class 1). Step 7 already pools the first two; nothing ever gave any of them an FVT, and
StoicPower had no pool either — the only score on chain in that state.

Fixed with four ADDITIVE steps (`C_Step7b/8b/9b/12b`) rather than edits to 7/8/9/12, because
**steps 7 and 8 have already run on mainnet**: `C_Issue` aborts on a duplicate name, so adding
entities to Step 8 would make it permanently unrunnable rather than usefully extended. An
additive step runs against the chain as it actually is; an edited one could only run on a chain
that no longer exists.

## The finding that generalises: a score with NO POOL cannot be ADMITTED at all

Not "earns nothing" — **aborts**:

```
No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: |
  at AQP-FVT.URC_ResolveScoreEntitySwpair
  at AQP-FVT.C_AddScoreEntity
```

`URC_ResolveScoreEntitySwpair` (`05_FVT.pact:1334`) binds

```pact
(pool-id:string  (ref-SCR::UR_SCR|ScoreAqpoolLink pool-score-id))
(asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
(aqp-class:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
```

in a `let` — and **Pact `let` is EAGER**, so both pool reads happen before the `if` that would
have skipped them. At `fvt-class` 1/2 the two values are never used, and the read still fires.
So admission requires a pool even where the pool is irrelevant to the result.

This is the SAME hazard `C_Step7_CreatePoolsAndScores` was fixed for on 2026-10-06 (it read a
pool row for a pool the transaction had not yet created, and could therefore never have
succeeded on any chain). Worth treating as a standing Pact-level caution rather than two
incidents: **an eager `let` turns a conditional read into an unconditional one.**

**Consequence for anyone wiring a score:** pool first, then FVT. Always.

## And how it was found

By writing the REPL fixture, not by reading the code. The `@doc` for Step 9b originally called
this a soft precondition — *"or it has no pool and the aggregate still refuses its stakes"* —
which is a confident, plausible, wrong sentence that a careful reading of `05_FVT.pact` produced
and one `pact AQP-FULL.repl` destroyed. The same run also caught `precision` (must be 3..24; the
live scores are 6/3/24) and that `AQP|C>ADD-SCORE` enforces `CAP_PoolOwner` on the POOL's owner,
which is not always the account issuing the scores.

The boot fixture had never created these three scores — which is precisely why nothing caught
the gap in the first place. A fixture that only contains what the ladder builds can only test
what the ladder builds.

## One cascade fact, for the next module change

Changing one citizen module moved SEVEN generated artefacts: `Deploy/` (24 files),
`REPL_SUITE_STATS.md`, `REPL-ROUND-REPORT.md`, the Audit Book, the module map, the module pages,
and **prose figures in 12 documentation files**. `_docsfigures.py` refuses to auto-edit prose and
is right to: after the comma-formatted counts were updated it still reported a NEAR-MISS on

```
# defun 8918 · defcap 992 · defschema 206 · deftable 231 · defpact 6
```

an UNFORMATTED copy inside a shell-output example that a `128,397`→`128,397` style replace
cannot see. "A number within 1% carrying the same label nearby" is exactly what a stale copy of
a drifting count looks like, and that check earned its place.

Deltas, which also served as an independent check that the change was what it claimed:
**+229 lines, +8 defuns** (4 implementations + 4 interface declarations). Gate 27,534 → 27,686
(+152 = 19 new assertions × the 8 entrypoints that load the boot suite).
