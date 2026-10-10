# Deploy — round V5

**01 is on chain. 02-06 are PENDING — the true-multiplet weight fix. Deploy 02 → 06, in order.**

| file | bytes | ~gas | contents | status |
|---|---|---|---|---|
| `01_deploy.pact` | 104,567 | 153 | `AQP-BOOT` — the four late steps (7b/8b/9b/12b) | **on chain** |
| `02_deploy.pact` | 230,628 | 39k | `AQP-SCORE` — D1 + D3 + D4 | pending |
| `03_deploy.pact` | 301,179 | 252k | `RPS` — D2; alone, on size | pending |
| `04_deploy.pact` | 263,504 | 99k | `MTX-AQP` + `AQP-DSA` + `AQP-VCT` — re-pin only | pending |
| `05_deploy.pact` | 202,416 | 16k | `AQP-FVT` — re-pin + corrected docstrings | pending |
| `06_deploy.pact` | 219,599 | 28k | `AQP-INFO` + `AQP-BOOT` + `O-UI-FOURTEEN` — re-pin | pending |
| **total** | **1,321,893** | **433k** | 6 tx, worst single 252k of a 2.00M budget | |

All upgrades, so `GOV` is evaluated — the admin key, not the namespace keyset. One at a time, in
order; do not run two concurrently. No `create-table` survives into any file (`--check` asserts
that on the emitted bytes).

**Weights become correct the moment 03 lands, and NO corrective transaction follows.** Both the
Tier-1 numerator and the Tier-2 divisor now read the SCORE deb basis live, which SCORE maintains
itself; the hub rows on mainnet were right all along. The zeroed `contrib-weight` /
`total-lane-weight` snapshots are still maintained but are no longer paid from.

**Why eight modules for a two-file change.** The dot-pin cascade: a dot call resolves at the
CALLER's deploy time and a stale caller of a table-owning callee ABORTS with *"hash not blessed"*.
`AQP-SCORE` is dot-called by `RPS` and `AQP-INFO`; `RPS` by `AQP-FVT`, `AQP-VCT`, `MTX-AQP`,
`AQP-DSA`, `AQP-INFO`; `AQP-FVT` by `AQP-INFO` and `AQP-BOOT`. So six of the eight ship
byte-identical to what is live. Same closure V4 shipped. `O-UI-FOURTEEN` is the one exception —
no dot call needs it, it rides in the cheapest file to correct three comments that are now false.
`AQP-DSA` is here only as a dot-caller; it is **not** the deferred DSA asset-tree step.

What the round fixes is recorded in
`OuronetInformational/memories/2026-10-09-true-multiplet-three-defects.md`.

Siblings, not a sequence: `../1_Pure/` is V1 (24 tx), `../PureV2/` V2 (35 tx), `../PureV3/` V3
(8 tx, the StoicSyntax 2.16 canon sweep — **executed 2026-10-06/07**), `../PureV4/` V4 (6 tx,
share-based equity scoring — **executed 2026-10-07**). Each numbers from 1 again and is kept
exactly as it went out.

This folder exists before it is needed on purpose. V3 and V4 both began as an edit made first
and a pipeline assembled afterwards, and that is how `Deploy/` drifted from its sources twice.
`_purev5.py --check` runs in the gate; it reports STALE the moment a source moves.

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
