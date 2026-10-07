# Deploy — round V5

**Open and empty.** Nothing is queued yet.

Siblings, not a sequence: `../1_Pure/` is V1 (24 tx), `../PureV2/` V2 (35 tx), `../PureV3/` V3
(8 tx, the StoicSyntax 2.16 canon sweep — **executed 2026-10-06/07**), `../PureV4/` V4 (6 tx,
share-based equity scoring — **executed 2026-10-07**). Each numbers from 1 again and is kept
exactly as it went out.

This folder exists before it is needed on purpose. V3 and V4 both began as an edit made first
and a pipeline assembled afterwards, and that is how `Deploy/` drifted from its sources twice.
`_purev5.py --check` runs in the gate from today; an empty round passes trivially.

## Filling it

```bash
python3 REPL/tools/_purev5.py --plan     # size + gas + the order proof, BEFORE writing
python3 REPL/tools/_purev5.py --write    # emit bodies under hand-written headers
python3 REPL/tools/_purev5.py --check    # regenerate in memory and diff (fatal in _gate)
```

Add to `MANIFEST`, then `DOT_EDGES` from `python3 REPL/tools/_dotpin.py`, then `NEW_IFACES` if
the round introduces one.

## The three things that decide the packing

**Gas grows as the seventh power of size** — `gas ≈ 95,225 × (KB/256)⁷`, ceiling ~395 KB at the
2.00M limit. Fewer, bigger transactions is the wrong instinct: V3 was nearly consolidated from 8
files into 3 of ~692 KB, which would have cost **~100,000,000 gas each**. Balance beats count.

**The dot-pin cascade is usually most of the round.** A dot call resolves at the *caller's*
deploy time, and a stale caller of a table-owning callee **aborts** with `"hash not blessed"`.
V4 was twelve modules for a three-place change; seven were byte-identical to what was already
live and shipped only to re-pin.

**A new interface cannot be simulated before it exists.** Any module naming an interface the
round introduces fails the wallet's simulation until the defining transaction lands. That is
expected — and the modules that simulate *fine* are precisely the ones ordering protects, so a
green tick there is the misleading one. `../PureV4/README.md` has the worked case.

## Known candidates — neither committed to

- **`SCR|C>ENABLE-DEB-BOOST-SCORE` hub consistency.** DEB is per-score, one-time, and latches on
  first stake, so a boost chain whose hub and satellites disagree pays inconsistently and cannot
  be corrected without a vacate. Enforcing the match **at enable time** is the honest fix;
  inheriting at read time would make `UR_SCR|ScoreDebBoost` stop reporting what is stored, and
  the deb-staleness check at `02_SCORE.pact:1691` compares against exactly that.
- **`09_AQP-INFO.pact` is absent from `deploy-stage02.repl`.** Live on mainnet (V3/08, again in
  V4/06), so nothing is pending — but a from-scratch chain would miss it. A loader fix, not a
  deploy; noted here so it is not forgotten when one is next assembled.
