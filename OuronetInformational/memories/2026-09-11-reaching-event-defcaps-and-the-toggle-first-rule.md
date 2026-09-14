# 2026-09-11 — Reaching `@event` defcaps, and the toggle-first rule

Two techniques settled this session that between them govern most of what is left in P3.3.

## 1. `test-capability` acquires a defcap directly — but not an `@event` one

`test-capability` runs a capability's body with no wrapper: no Talos call, no account, no signing
dance. That made whole families reachable that had been filed as "needs a fixture" — the six
`GOV|<X>_ADMIN` module-governance caps, the five `SCR|XE>UPDATE-STAKE-*` arity checks, the DPOF /
DPDC-C / SWPU admission guards.

**A previous pass concluded the `GOV|*_ADMIN` family was unreachable** because Talos's own keyset
check fires before the module's cap. That premise was true and the conclusion did not follow.

**The boundary:** `test-capability` fails on an `@event` defcap with

```
Install capability error: capability is not managed and cannot be installed
```

Pact takes the *install* path for those, and they are not managed. Verified on two separate caps
before concluding it. Current split of the unpinned set:

| | count |
|---|---|
| in an `@event` defcap | 140 |
| non-`@event`, enforce after a table read | 46 |
| non-`@event`, enforce before any read | 5 |

## 2. …and the ordinary Talos client path DOES reach `@event` caps

Established with `SCR|C>ISSUE-TRIPLET` (`REPL/modules/AQP.repl` `<<AQP-G14>>`): calling the Talos
shell with a deliberately bad argument runs the cap body and trips the guard. So the 140 are **not**
blocked — they are merely more expensive, needing a client call rather than a direct acquisition.

**The argument must be REAL, not a ghost id.** Three ghost score ids abort in a hard table read
inside the cap's own `let` before any enforce runs. Passing ONE real score three times satisfies
existence and fails only distinctness — which is the guard under test.

## 3. Toggle first, build second

When a guard needs state the suite lacks, look for a **supported toggle** before building state.
Three found this session, each turning a multi-pass fixture into two client calls:

- `SWP|C_ToggleSwapCapability` — swap capability off/on (`<<SWP-G11>>`)
- `AQP-POOL|C_DisablePoolStake` / `C_EnablePoolStake` — pool staking (`<<AQP-G11/G12>>`)
- `AQP-FVT|C_ToggleScoreEntityLink` — FVT reward link (`<<AQP-G13>>`)

Discipline: disable in its own transaction, assert, restore in another, and **assert the
restoration** so nothing downstream inherits the change. One IGNIS-collecting client op per tx.
Never wrap the toggle in `(try …)` — it writes, and Pact forbids DB writes inside `try`
("Operation disallowed in read-only or sys-only mode", itself uncatchable).

Asymmetries are what make these cheap: `SPWU|C>TOGGLE-SWAP` enforces a worth floor only when
turning swapping ON, because a drained pool must be stoppable but not restartable.

## 4. Look for the fixture before declaring it a blocker

I carried "the SCORE/LP relationship fixture" as an open decision for ~10 passes, describing it as
several passes of build. It already existed: `[6.2.10]_AQP-NEGATIVES.repl` leaves **`ResumeVacPool`**
fully vacated, auto-finalised and stake re-enabled — class-OK, stake-open, FVT-ready — and
`modules/AQP.repl` already loads it transitively. Same lesson as the DPOF special-link fixture,
which existed in `fixtures/mock-of.repl` and only needed cross-loading.

**Check every suite for the state before scoping a build.**

## 5. A recurring source defect: the eagerly-bound subject

Four instances now, all the same shape — a guard's own subject is bound eagerly in the `let` above
it, so the binding raises before the guard can speak, and the caller sees a raw table error instead
of the written message:

- `PYTHIA::UEV_DualPairForLink` — undeployed half (`<<TX007e-03>>`)
- `FVT::UEV_AddScoreEntityScoreContext` — pool-less score (`<<TX-BOOT-G1>>`)
- `DALOS::GAS_PAYER` — missing `exec-code` (`<<DALOS-G2e>>`)
- `SCR|C>ISSUE-TRIPLET` — ghost score ids (`<<AQP-G14>>`, worked around with real ids)

All pinned AS THEY BEHAVE, so a fix has to update the test deliberately.

## 6. Metric integrity

`_enforce_coverage.py` disambiguates wording shared ACROSS modules but not WITHIN one. Added a
reported upper bound on that over-count — deliberately its own line, never folded into the
headline. Two defects fixed on the way: it counted *sites* rather than *assertions* (so it GREW as
duplicates got properly driven), and `_hits` keys on the expected *string*, so separate assertions
sharing wording collapsed to one. It now counts distinct `(file, line)` assertions from
`pinned_src`. Bound: 33 → 18, verified against FVT by hand rather than trusted.
