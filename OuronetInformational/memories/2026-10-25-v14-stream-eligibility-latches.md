# 2026-10-25 — the V14 round: drift-lock / stream-eligible latches, and what the gate caught

## What shipped

Two one-way latches that make `CC_InjectStream` honest by construction rather than by a scan:

- `SCR|Schema.drift-locked:bool [.t]` (`02_SCORE.pact`) — settable only while `deb-boost = false`
  **and** `boost-class-link = BAR`, i.e. only on a score whose stored weight is already
  arithmetically frozen between stakes. Once set it guards `C_EnableDebBoost`,
  `C_CreateBoostClassLink` and `C_CreateBoostLink`.
- `FVT|Schema.stream-eligible:bool [.t]` (`05_FVT.pact`) — owner-gated, **heavy**: it scans every
  enabled member and refuses while any one of them is not drift-locked. Gates
  `FVT|C>INJECT-STREAM`; `UEV_StreamEligibleMemberOk` then keeps the proof true at every later
  `C_AddScoreEntity` and at re-enable in `C_ToggleScoreEntityLink`.

Rationale and the corrected D10 claim live in
`Audit/module-audits/AQP/STREAMED-INJECT-DESIGN.md` (D10 / D10′ / D10″).

## Three things worth not relearning

### 1. `stream-eligible` belongs on `FVT|Schema`, not on RPS — and the byte cap said so first

It was first put on the RPS reward-aggregate row. That pushed the emitted RPS transaction to
**321,970 bytes, 1,970 over `_deploybundle.py`'s 320,000 cap**. Raising `HEADER_RESERVE` did
nothing (a single module cannot be split), and the next instinct — raise the cap — is exactly the
2026-10-06 near-disaster: the cap is justified by *evidence*, the size charge is seventh-power,
and CLAUDE.md's own note says two points fit any curve. Moving the field to `FVT|Schema` fit
**and** was the better design, since eligibility is a property of the vault, not of one reward
lane. **A byte-cap conflict is worth reading as a design smell before it is read as a budget
problem.**

### 2. Both new defcaps shipped with authorisation AFTER validation, and that is the shadowed-gate bug

`SCR|C>LOCK-SCORE-DRIFT` and `FVT|C>LATCH-STREAM-ELIGIBLE` each ran their business `enforce`
(and, for the FVT one, the whole heavy member scan) *before* `CAP_EnforceAccountOwnership`. This
is the `GOV|WIPE_ALL-TREASURY-DEBT` shape from the 2026-09-14 owner ruling, and it bites hardest
here because **"members not yet drift-locked" is the normal state of a fresh vault** — so the
ownership gates were unreachable in the common case, and a red-team test could report "a
non-owner was refused" truthfully while proving nothing. Hoisted both. Note that CLAUDE.md's
*"do not resolve those 62 by reordering them"* is about **pre-existing** sites whose tests depend
on the current order; for a **new** site the ruling applies plainly, and reordering is free.

### 2b. The latch choice is PERMANENT per score, and the first `@doc` denied it

`SCR|C>LOCK-SCORE-DRIFT`'s original `@doc` ended *"vacate and reconfigure if you need to clear
deb-boost or a class link first."* **That remedy does not exist.** All three inputs are
irreversible by their own field tags:

```
deb-boost:bool          ;;[.t]  one-way to true; sole writer is {"deb-boost": true}
boost-class-link:string ;;[..]  fixed once set
boost-link:string       ;;[..]  fixed once set
```

Vacating drains **positions**; it does not rewrite score **config**. So per score, *"can carry
deb/boost-class"* and *"can serve a streaming FVT"* are **permanently mutually exclusive**, and
repurposing a boosted score means issuing a new one. Corrected in the `@doc` on 2026-10-25.

Worth noting WHY the wrong sentence was plausible: three other guards in the same module really do
say "vacate to reconfigure" (the `nzs-count = 0` ones), and that phrasing was carried across to a
latch where it does not apply. **A remedy sentence copied from a neighbouring guard is the easiest
kind of false documentation to write and the hardest to notice**, because it reads like house
style.

### 3. `Z.repl` was green through a breaking change to three stream fixtures

Making eligibility a *precondition* means no existing test can open a stream. `Z.repl` passed at
1,068 assertions anyway, because it loads **none** of the three suites that stream:
`Kursan/AQP-stream-tests.repl` (two fixtures — a class-1 vault and a class-0 farm) and
`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl`. Only `_gate.py` runs them.

**The failure signature is worth memorising: the two suites reported `BROKEN` with a failure
count of ZERO.** A load-time abort is not an assertion failure, so the gate's per-suite failure
extractor printed an empty detail section for both. Reading the summary table alone — "0 fail" —
would have looked like noise. `BROKEN` is the column that matters; the fail count is not.

Fixtures must latch **member score first**, then the vault, because the vault latch scans.
`[6.5.1]`'s latch is a separate **committed** transaction (`<<TX-INFO-GT-STREAM-PRE>>`) for two
reasons: the latches bill IGNIS and that block differences a GAS balance across the streamed
inject alone, and a latch is irreversible — committing one in a shared fixture is only safe
because `[6.5.1]` is the last load in `AQP-FULL.repl` and the boost/deb groundtruth blocks after
it use a `fresh` score. **Both halves of that have to stay true if the file ever moves.**

## Round shape

`Deploy/PureV14/` — 13 transactions, strict order, all ≤320,000 bytes (largest 318,698, RPS).
`04_backfill` and `08_backfill` are hand-authored and **load-bearing in position**: a field added
to a schema leaves pre-existing rows without it, and `with-default-read` defaults an absent ROW,
not an absent FIELD. Their headers state that **re-running one after an owner has latched would
silently UN-latch**. `13_deploy` hand-carries `14_O-UI-FOURTEEN`, which appears in no generated
batch. IGNIS ships this round because `UC_IgnisComponents` fails fast on an unknown op.
