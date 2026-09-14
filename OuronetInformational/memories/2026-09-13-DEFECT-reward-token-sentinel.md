# DEFECT: the reward-token sentinel was dropped on removal — 2026-09-13

**Severity: token-bricking, permanent, un-repairable. Latent (not triggered in any fixture), reachable
through the ordinary client path. FIXED at source in `05_DPTF.pact` `XE_UpdateRewardToken`.**

Found by sweeping the codebase for the `(enumerate 0 (- (length x) 1))` idiom after it bit for the
third time, then handing the 153 hits to a research agent to triage by reachability. This was its #1.

## The chain

1. `DPTF|PropertiesTable.reward-token` holds the ATS pairs a token is a reward token of. **"None" is
   spelled with a ONE-ELEMENT SENTINEL `[BAR]`, never `[]`** — that is the initial value.
2. `XE_UpdateRewardToken`'s two branches were ASYMMETRIC:
   - ADD understood the sentinel: `(if (= (at 0 rt) BAR) [atspair] (UC_AppL rt atspair))`
   - REMOVE did not: `(UC_RemoveItem rt atspair)`, and `UC_RemoveItem` is `(filter (!= item) in)` —
     removing the last pair yields the bare `[]`.
3. `URC_IzRT` decides "is this a reward token anywhere?" with
   `(if (= (UR_RewardToken id) [BAR]) false true)`. **`[]` is not `[BAR]`, so an emptied token answers
   TRUE** while holding no pairs.
4. Every transfer then routes into `TFT::URCx_CPF_RT` ->
   `(enumerate 0 (- (length ats-pairs) 1))` -> `(enumerate 0 -1)` -> the DESCENDING PAIR `[0, -1]` ->
   `(at 0 [])` -> native fault.
5. **Un-repairable**: the ADD branch opens with `(at 0 rt)`, which faults on `[]` too. The token could
   never be re-registered to climb out.

## Why no guard caught it

`ATSU|C>X_REMOVE-SECONDARY` enforces `(> rt-position 0)` — *"Primal RT cannot be removed"*. That reads
like the protection, and it is not: it is a position in **the ATS PAIR's** reward-token list, a
different list from **the DPTF's** list of pairs. A token that is the sole SECONDARY RT of exactly one
pair clears it.

**The general shape: two lists, one guard, and the guard is on the wrong one.** Both are called
"reward token", which is exactly why it reads as covered.

## What was verified live before touching source

* The precondition is constructible through the ordinary client path: `ATS|C_AddSecondary` took
  PDKOSON from `[BAR]` to `[TestKickPair]` — sole secondary of one pair.
* The removal itself was blocked only by an **incidental** `"0.0 is not a Valid Transaction amount"`
  in the buyout transfer (a freshly-added RT has no stake). That is not a protection of the sentinel;
  a pair with real stake in the secondary would complete.
* `URC_IzRT` and `UC_RemoveItem` read and confirmed at source.

## The fix

Restore the sentinel in the REMOVE branch — symmetric with ADD, and it changes behaviour ONLY in the
broken case (a filter result of length >= 1 is untouched):

    (let ((remaining (UC_RemoveItem rt atspair)))
        (if (= (length remaining) 0) [BAR] remaining))

The ATS-side twin (`08_ATS.pact` `XE_RemoveSecondary`, the PAIR's list) is genuinely safe — there
`(> rt-position 0)` IS the right list, so the primal always remains.

## The regression test is an INVARIANT, not a replay

`REPL/modules/ATS.repl` `<<ATS-F1>>` sweeps every reward token on the chain and asserts (a) none holds
an empty list, (b) a non-RT reads as exactly `[BAR]`, (c) `URC_IzRT` agrees with the stored list in
both directions for every token. Written that way deliberately: the same emptying could arrive from
any future writer of that column, and only an invariant catches all of them.

## Two process notes

* **`try` with a fallback hid a missing row from me.** Probing `(try [] (DPTF.UR_RewardToken t))` made
  DDKOSON and MOCKA look like they already held `[]`; they are not DPTFs in that harness at all and
  the read was aborting. I briefly believed the bug was already live. **When probing for an unusual
  VALUE, do not use `try` with a fallback that IS the value you are hunting.**
* **The `(enumerate 0 (- (length x) 1))` sweep was worth doing.** 153 sites; ~84 are safe only because
  this codebase uses `[BAR]`-sentinels of length 1 rather than empty lists, so `enumerate 0 0` = `[0]`.
  The danger is concentrated exactly where a list ESCAPES that convention — i.e. wherever a `filter`
  (`UC_RemoveItem`) or a caller-supplied parameter feeds the idiom. That is the signal to grep for,
  not the idiom itself.


---

# The VCT mute guard — a test was pinning the bug, 2026-09-13

Second finding out of the `(enumerate 0 (- (length x) 1))` triage. Different failure mode from the
DPTF sentinel: nothing was corrupted, a guard simply could not speak.

## The shape

`VCT|C>TRUE-FUNGIBLE-VACATE-BATCH`:

    (gas-ok:bool  (URC_TfOwnerArraysGasOk owner-ids beneficiary-ids amounts))   ; DOES test (> l 0)
    (legs:[...]   (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts))
    ...
    (enforce (fold (and) true [class-ok asset-ok gas-ok owners-ok]) "Invalid TF vacate cap input")

Eager `let` again. On an empty batch `legs` faulted on `(enumerate 0 -1)` -> `[0,-1]` -> `(at 0 [])`
**before the enforce could read gas-ok**. Measured both halves before touching anything:

    (URC_TfOwnerArraysGasOk [] [] [])      => false     <- the guard KNEW
    (UC_TfLegsFromParallelArrays [] [] []) => FAULT     <- but this ran first

**A mute guard: right answer, no voice.**

## AN EXISTING TEST WAS PINNING THE DEFECT — and its own label gave it away

`Stage_02/[6.2.5]_AQP-VCT.repl:1100`:

    (expect-failure
        "<<TX-VCT-N01 expect-failure>> empty batch arrays rejected (GAS-OK REQUIRES L>0)"
        "Array index out of bounds. Length (0), Index (0)"        ; <- what actually happened
        (… CCp_BatchVacateTrueFungible patron pool-id ouro-id [] [] []))

The label states the INTENT (the shape guard); the expected string records the SYMPTOM (a native
fault). Both were true simultaneously, which is exactly why it survived review — the test was green,
and green tests do not get re-read.

**Generalised: when a test's DOC STRING and its EXPECTED MESSAGE describe different things, that gap
is a defect report nobody filed.** Worth a sweep of its own: grep for `expect-failure` whose expected
text is a native Pact error ("Array index out of bounds", "row not found", "Cannot apply value to
non-closure") rather than a module message — each one is a place where an intended guard is mute.

## The asymmetry that proves intent

Two of the three sibling leg validators already guard internally:

| helper | guard |
|---|---|
| `URC_VacateOrtoLegsOk` :1861 | `(if (> l 0) …)` |
| `URC_VacateCollectableLegsOk` :1888 | `(if (> l 0) …)` |
| `URC_VacateTfLegsOk` :1825 | none needed — it takes a PRE-BUILT legs list |

So the author knew the hazard. The TF path differed by taking a pre-built list, and it was the
BUILDER that was unguarded. Fixing the builder — not duplicating a check into the cap — is what puts
the repair where the other two already have it.

## Four functions made total in 06_VCT

`UC_TfLegsFromParallelArrays`, `UC_VacateMergeDecimalNonceRowsForBeneficiary`,
`UC_VacateMergeIntNonceRowsForBeneficiary`, `URC_ResolveOfDecimalAmountsFromTracker` — all four zip
parallel arrays, so all four genuinely need the index and got an `(if (= l 0) <empty> …)` guard
rather than a `map`-over-list rewrite.

Pinned from the unit side by `modules/AQP.repl <<AQP-F6>>` (both arms for each, plus proof the merge
still concatenates a matching row and still skips a non-matching beneficiary — totality must not cost
correctness), and from the integration side by the flipped `TX-VCT-N01`.


---

# DEFECT: an object-merge that silently discarded every value — 2026-09-13

**`03_AQP.pact` `UDC_AQP|SchemaWithScoreSlots` was a COMPLETE NO-OP.** Found by writing the first
test the function has ever had; fixed by swapping two operands.

    ;; before
    (+ pool {"score-primary": …, "score-secondary": …, … seven slots …})

**Pact's object `+` gives precedence to the LEFT operand on key collisions.** Verified live rather
than recalled:

    (+ {"a": 1, "b": 9} {"a": 2, "c": 3})   =>   {"a": 1, "b": 9, "c": 3}

The pool row already carries all seven slot keys, so every supplied value was discarded and the
function returned its input unchanged — flatly contradicting its own @doc, *"Returns pool row with
all seven score slots replaced"*.

## How the test caught it

The shape is the reason I wrote a test at all: **seven near-identical branches over seven same-typed
fields** is the textbook home for a copy-paste slip (write slot 4, land in slot 5), and nothing
downstream would notice, because a score-id in the wrong slot is still a valid score-id in a valid
slot. So the test addresses each slot in turn and asserts exactly one field moved.

It failed on the FIRST assertion — reading back slot N returned the row's ORIGINAL score. Not the
off-by-one I was hunting; a total no-op. **The test found something better than what it was aimed at.**

## Disposition: repair, not delete

Zero blast radius, which is what made this a repair rather than a deletion:
* `UDC_AQP|SchemaWithScoreSlots`'s only caller is `UDC_AQP|SchemaWithScoreAtSlot`;
* `UDC_AQP|SchemaWithScoreAtSlot` has **no callers anywhere in the codebase**;
* neither is on the `AcquisitionPoolsV2` interface, so no cascade;
* the LIVE slot writer is a different mechanism entirely — `UC_PoolScoreSlotPatch` builds a PARTIAL
  update map consumed by `WU_Pool|ScoreSlot`, which is correct and untouched.

Dead code, but dead code that would have been a trap for the first caller. Fixed and pinned
slot-by-slot so it stays correct.

## The sweep, and the test that distinguishes safe from broken

Six more `(+ <row> {…})` sites exist. **Only the AQP one was a defect.** The distinguishing question
is not the idiom, it is:

> **Does the LEFT operand already carry the key being merged in?**

| site | key | in the left row's schema? | verdict |
|---|---|---|---|
| `03_AQP` `SchemaWithScoreSlots` | all seven `score-*` slots | **YES** — they are schema fields | **BROKEN** |
| `21_CODEX` ×3 | `is-registered`, `has-stoictag` | no — derived presentation key | safe |
| `22_PYTHIA` ×2 | `is-registered` | no — confirmed absent from `PYTHIA|S|ApiKey` | safe |
| `06_VCT`, `02_SCORE`, `07_DPDC-T` `(+ acc […])` | — | list concatenation, not object merge | n/a |

The safe ones follow a deliberate and good pattern: a `UDC_*|WithRegisteredFlag` that ADDS a flag
absent from the stored schema, paired with an "absent row" default object that carries the flag as
`false`. No collision, so left-precedence never bites.

**Generalised: `(+ row {…})` is only safe when the added keys are NOT in the row. When they are, the
merge is a silent no-op — and it fails the quietest way possible, by returning something that looks
exactly like a valid row.**

## Also corrected: my own wrong expectation about OF pool classes

I asserted `URC_StakeOrtoFungiblePoolClassOk` would refuse a class-1 true-fungible pool. It does not,
and the matcher's @doc says why: THREE classes bear an OF lane — "class 2 native circulating; class 1
Z|/H| satellite linked to pool DPTF; class 0 Z| orto LP". A TF pool can carry sleeping/hibernating
ORTO satellites of its own token. The class genuinely refused is a COLLECTABLE one (3/4), and the
test now asserts both sides.


---

# OPEN FINDING: the zero-royalty fuel path fails with a native error — 2026-09-13

**NOT FIXED. Recorded as behaviour with a trip-wire test. Needs a focused pass.**

Found while covering the last Tier-1 functions. Confirmed by execution, not inference.

## The chain

`RPS::URCi_FuelRoyaltyCustody` builds its input vector as

    (map (lambda (t) (if (= t token) amount 0.0)) pool-tokens)

so when the vault's royalty is **0.0**, EVERY slot is 0.0. `SWPLC::URCi_Fuel` then does

    has-zeros -> (UC_RemoveItem input-amounts 0.0)     ;; = (filter (!= 0.0) ...)

which filters an all-zero vector to `[]`, and hands the empty list to
`TFT::URCi_MultiTransferCumulator`, which indexes it.

**Confirmed directly**: `URCi_Fuel <vault> <real swpair> [0.0 0.0] true` ->
`"Array index out of bounds. Length (0), Index (0)"`.

This is the **filter -> empty -> index** shape the `enumerate` triage flagged as the single strongest
danger signal, and it is the FOURTH instance found this session.

## Why nothing stops it

`DSA|C>FUEL-ROYALTY` (`08_DSA.pact:384`) carries three enforces -- vault live, patron IS the FVT
owner, ownership signed -- and **no `royalty > 0` check**. So a DSA vault owner calling "fuel with my
royalty" while royalty is zero reaches the fault. The exec entrypoint
`TS02-C3::AQP-DSA|C_FuelRoyalty` also fails on that input, with a DIFFERENT native error
(`"Expected Pact Value, got closure or table reference"`) whose cause I did NOT isolate.

Both the exec AND the preview fail, so a UI cannot even quote the operation before attempting it.

## Why I did not fix it

The repair belongs in the cap, alongside its existing three enforces. But the cap's signature is
`(patron, fvt-id, swpair)` -- it does **not name a reward token**, while the royalty is per
`(fvt-id, reward-dptf-id)`. So "which royalty must be non-zero" is a DESIGN question (all enabled
rewards? the one the swpair trades? any?), not a mechanical one.

Every other fix this session was applied only after establishing the answer was forced. This one is
not forced, so it is flagged rather than guessed at.

## The trip-wire

`Kursan/dsa-grand-tour.repl` `<<GT-DOC2>>` pins the CURRENT behaviour with a `FINDING:` label --
the suite's existing convention for a defect recorded as behaviour (see `[6.10]_PYTHIA` TX007d-02c,
`modules/VST.repl` VST-G6). **The day those assertions start failing, the path has been given a real
guard and should be re-pinned to that guard's message.**

Note the precedent worth following: labelling it `FINDING:` is what distinguishes a deliberately
recorded defect from `TX-VCT-N01`, which pinned a native fault WITHOUT that marker and so read as a
passing test for months. The marker is the difference between documentation and camouflage.
