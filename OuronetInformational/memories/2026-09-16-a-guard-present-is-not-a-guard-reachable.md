# "A guard being present is not a guard being reachable" — and the scanner that couldn't see it

*2026-09-16. Follow-up to RT-K-007. No new contract defect; one measured defect in the shared
instrumentation, one new detector, and a corrected understanding of what `hard` means.*

## Why this was worth doing

Four times in two days the same shape appeared, each found **by accident**:

| where | the obstruction |
|---|---|
| `C_Recover` (fixed 2026-09-12) | capability acquired **below** the binding group |
| `C_HotRecovery` (RT-H-003) | same |
| `C_DeployAccount` (RT-K-003) | `UEV_id` called from the `let` **body** |
| `UEV_LiveAnchor` (RT-K-007) | **the reader beneath the guard** raised first |

Four accidents is a pattern, and patterns should be mechanical. `_eagerlet.py` already covered the
first three shapes. The fourth had no coverage, because the tool models the wrong relation.

## The missing relation

`_eagerlet.py` looks for a hard read that **CONSUMES** the guard's subject. RT-K-007 is a hard read
that **PRODUCES** it:

```pact
(let ((iz-anchor-active (UR_ANK|State anchor-id)))   ;; hard read -> the guard's own input
  (enforce iz-anchor-active "Anchor ... must be alive for operation"))
```

Added as `--produced`. **The remedy differs from the other shapes**: the guard cannot be hoisted
above the value it tests, so the fix is to *default the reader*.

## Two defects in the shared classifier, both measured

`_pactlex.reader_kinds` is used by `_eagerlet.py`, `_foldeager.py` and anything else asking "can this
read abort?". It was wrong twice.

**1. It keyed by bare name and kept whichever body was longest.**

| | |
|---|---:|
| `UR_*` readers with a real body | 650 |
| defined in **more than one module** | **79** |
| and **disagreeing** on hard/soft | **33** |

`UR_AccountSupply` alone has five definitions — four soft, one hard. Every call by that name
inherited whichever won a length contest. **A bare name is not an identity in a module system** —
the third time that exact trap has cost me this week. Ambiguous names are now **withheld** from
`hard` (a scanner should rather miss than cry wolf) and returned separately, so nothing is silent.

**2. `hard` meant "contains a raising read somewhere", not "can raise for the subject".**

A bare `read` whose **key is a constant** is a singleton config row that always exists —
`(read DALOS|PropertiesTable DALOS|INFO ...)` — and cannot abort for a caller's id. Counting those,
then propagating through delegation, marked `UR_AccountRoleBurn` hard although **every branch of it
is a `with-default-read`**: it merely consults `UR_OuroborosID` to pick a table. Hardness is now
key-aware, and propagation requires the caller to hand one of its **own** parameters to the callee.

**Effect, measured:** hard readers **413 → 249**; `--wide` false positives **30 → 15**; narrow mode
still **0**. The fix improved the checkers that already existed, not only the new mode.

## The detector took three corrections against evidence

Shipping the first version would have been worse than shipping nothing.

| version | hits | why it was wrong |
|---|---:|---|
| any enforce mentioning a hard-read binding | **247** | reading state and enforcing on it is *how nearly every guard is written* |
| + ambiguity fix | 201 | still not a defect signature |
| + "existence-claiming message" | 33 | vocabulary included **"must be set"**, which is a *state* claim |
| + `try`-wrapped reads are safe | 5 | `try` cannot raise — same principle as `with-default-read` |
| + `(if <guard> …)` reads are safe | **4** | the other half of the correct idiom |

> **"must be set" was the instructive mistake.** It matched `UEV_LockState`, `UEV_EliteState` and the
> ATS recovery toggles — and those are *not* this defect. For a pair that does not exist, *"its lock
> must be set to true"* is a **misleading** answer, so the raw read is the lesser evil; defaulting
> those readers would manufacture exactly the wrong-diagnosis problem RT-K-004 found in DPDC. The
> signature only holds when the guard's message **already covers absence**, because then the raising
> read is stealing a sentence the guard was written to say.

## Validation, and the model to copy

`--produced` independently flagged **`18_SWPLC.pact:926`** — `UEV_AddChilledLiquidity`'s `iz-frozen`
— the exact function RT-K-005 had reached by hand. A detector that rediscovers a hand-found defect
is worth keeping.

And it flagged `CODEX|C>RELEASE-STOICTAG`, which turned out to be **the one place in the tree that
answers this question properly**:

```pact
(tag-row-found (not (= (try false (UR_STG|Data tag-name)) false)))   ;; try-wrap the probe
(tag-iz-active (if tag-row-found (UR_STG|IzActive tag-name) false))  ;; conditionalise the rest
(enforce tag-row-found "StoicTag not found")
```

**Try-wrap the existence probe, then make every later read conditional on it.** That is the idiom;
the two rules that removed CODEX from the list are the two halves of it.

## Status of the 4 remaining candidates

Triage, not verdicts: `08_ATS.pact:1790`, `18_SWPLC.pact:926` (already addressed by RT-K-005),
`02_SCORE.pact:884`, `05_FVT.pact:1843`. Each needs the same question asked by hand — *does this
guard's message already cover absence?* — before any reader is defaulted.
