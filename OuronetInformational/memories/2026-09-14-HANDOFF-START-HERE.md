# HANDOFF — 2026-09-14 — START HERE

Written immediately before a context reset. This is the current, authoritative state.

## WHERE WE ARE

Phases 1-4 of the pre-red-team plan are **CLOSED**. Phase 5 (function coverage) is scoped and
agreed but **NOT STARTED**. Phase 6 (assembly + REPL folder reorg) is last and untouched.

| gate | measures | state |
|---|---|---|
| **G2** guards | every `enforce` pinned to its exact message | **753/777 (96%)**, 698 module-unique; **LIVE worklist 0** |
| **G3** determinism | full-suite gate | **GREEN - 19,722 assertions** (15,895 pos / 3,827 neg), ~215s |
| **G4** conformance | architectural rules | **0 VIOLATIONS**; 114 observations, all bounded + ruled |
| **G5** `@doc` claims | stated rules actually tested | **100/100; 0 remaining** |
| **G6** function coverage | client-reachable functions reached | 3,393/4,498 (75%); **787 never-reached excl. dead DPMF** |

Other checkers: `_vacuous` = **none**. `_expectfail` weak sites = 35, **all in UNGATED files**
(verified against the gate entrypoint list; zero overlap).

Scale: Pact source (1_SOVEREIGN + 2_CITIZEN) = **113,666 lines / 93 files**.
REPL tests = **103,379 lines / 259 files**. Roughly 1:1.

### The 24 unpinned guards, accounted for
777 matchable - 753 pinned = 24, and **all 24 are in `00_DPMF.pact`** - the dead MetaFungible module,
superseded by DPOF, deployed for provenance. Re-verified: every mention of DPMF outside its own file
is in a `@doc` string or comment. **Zero live callers.** So live-module unpinned = 0.

## PHASE 5 SCOPE - AGREED WITH THE OWNER

**787 client-reachable never-reached (excluding DPMF, which also held 18 of the 20 `C_`s).**

| family | count | test spec | do it? |
|---|---:|---|---|
| `INFO_` | 322 | **cost fields == what the exec counterpart ACTUALLY charges** | YES |
| `URCi_` | 71 | decomposition identity: preview == sum of its named legs | YES |
| `UEV_` | 56 | both arms - accept legal, refuse illegal | YES |
| `A_` admin | 31 | signed passes / unsigned refuses + the state written | YES |
| `C_` | 2 | full client path | YES |
| `URC_` | 71 | derivation vs inputs; differentials on flags/classes | judgement |
| `UR_` | 60 | round-trip vs a REAL row (prove existence first) | judgement |
| `UC_`/`UDC_` | 36 | pure: both arms + empty/boundary edges | judgement |
| `URH_` | 10 | scan symmetry / cross-check | judgement |
| `CAP_` | 9 | signed vs unsigned + WHICH konto it resolves to | judgement |
| `CT_` constants | 113 | -- | **SKIP (owner ruling)** |

Target ~93% reached. `INFO_` is concentrated: 279 of 322 in `01_INFO-TWO` + `02_INFO-ONE+`, 32 in
`09_AQP-INFO`.

### OWNER RULINGS, 2026-09-14 (verbatim intent)

1. **"If an op exec counterpart is missing it has to be added, it means we missed it."**
   -> When an `INFO_X` has no exercised exec counterpart, BUILD THE EXEC TEST. Do not log it as
   "preview untested because the op is untested". A missing exec test is a coverage gap we missed,
   not an acceptable reason to skip.
2. **"Yes we skip the constant functions."** -> `CT_` (113) is OUT of scope.

### Why the INFO_ spec matters (the owner corrected me here)

Each `INFO_X` returns a `ClientInfo` whose cost fields are built from `URCi_` readers. Three possible
specs, only the third is worth anything:
1. `INFO_X.ignis == <hardcoded>` - **already went stale**: `[6.5]_AQP-INFO.repl` pinned four at
   1000.0, task #76 replaced the inline constants with a computed price (574.0), and the suite was
   ORPHANED - nothing caught it.
2. `INFO_X.ignis == URCi_X` - **tautological**, INFO is literally built from URCi.
3. **`INFO_X.ignis == the IGNIS actually collected when `C_X` runs`** - the owner's spec. The only
   one with an independent oracle. Pattern: capture patron balance -> run the op -> diff -> compare.

## STANDING INSTRUCTIONS FROM THE OWNER

* **Fix what you find, do not escalate.** *"fix whatever problem you find yourself... dont stop to
  ask me for every little shiet."* Earlier: *"If you find bugs like this you are sure are fixing
  properly (these seem to be bugs the audits missed) fix them if you know you are able to apply the
  correct fix."*
* **NEVER `git checkout --` a file in this tree.** Extensive uncommitted work. Use targeted reverse
  edits.
* Do NOT edit canonical Stage-Z modules to suit tests; use a REPL-only testing variant.
* Publish the worklist with every final answer.
* Verify before changing. Static reading of this codebase has been wrong many times; every fix this
  engagement was applied only after a live execution confirmed the diagnosis.

## WHAT WAS FIXED THIS ENGAGEMENT (all with regression tests)

| module | defect | failure mode |
|---|---|---|
| `05_DPTF` | reward-token sentinel dropped on removal (`UC_RemoveItem` -> `[]`) | token permanently un-transferable AND un-repairable |
| `06_VCT` x4 | mute shape guard - eager `let` faulted before the enforce could speak | native fault instead of the cap message |
| `03_AQP` | `(+ pool {...})` - Pact object `+` gives the LEFT operand precedence | silent no-op returning a valid-looking row |
| `11_EQUITY+` | 24-link check sat below an issuing `let` | paid for a full collection issue before validating |
| `10_ATSU` | guard message said "negative" for a bound of 0.1 | client-visible wrong wording |

Also: 4 VCT functions made total; 2 tautological validators annotated; **2 existing proofs found
VACUOUS and repaired** (the #65bL shared-graph equalities short-circuited on OURO and never read the
graph argument - they would have passed with the parameter deleted).

## ONE OPEN FINDING - deliberately not fixed

**Zero-royalty fuel path dies in a native fault**, on BOTH the exec and the preview.
`URCi_FuelRoyaltyCustody` builds an all-zero input vector when royalty is 0.0; `SWPLC::URCi_Fuel`
filters the zeros out with `UC_RemoveItem` -> `[]` -> handed to an indexer. Confirmed by direct call:
`"Array index out of bounds. Length (0), Index (0)"`.
`DSA|C>FUEL-ROYALTY` has three enforces and **no `royalty > 0` check**.
NOT FIXED because the cap's signature is `(patron, fvt-id, swpair)` - it does not name a reward
token, while royalty is per `(fvt-id, reward-dptf-id)`. Which royalty must be non-zero is a DESIGN
question. Pinned as behaviour with a `FINDING:` marker in `Kursan/dsa-grand-tour.repl <<GT-DOC2>>`.

## TRAPS THAT WILL BITE AGAIN - read before writing tests

1. **Key-echo readers.** Families built on `with-default-read` whose DEFAULT OBJECT IS BUILT FROM THE
   KEY echo your arguments back on a miss. They are NOT existence checks, and a round-trip test
   against them is VACUOUS unless existence is proven independently (from a value field). Hit three
   times: `RPS::UR_FVT-RU|*`, `SCORE::UR_U-SCR|*`, `AQP::UR_AQP|*Tracker*`. It also produced TWO DEAD
   VALIDATORS in production (`URC_Vacate{Collectable,Orto}LegBeneficiaryOk` - both now annotated).
   Documented in `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md`.
2. **`(enumerate 0 (- (length xs) 1))` on an empty list** is `(enumerate 0 -1)` = the DESCENDING PAIR
   `[0, -1]`, not `[]` - so `(at 0 [])` faults. **153 sites in the codebase.** Most are safe only
   because this codebase uses `[BAR]` sentinels of length 1. **The danger signal is a `filter`
   (especially `UC_RemoveItem`) or a raw caller parameter feeding the idiom.** Four real instances
   found so far.
3. **`test-capability` cannot acquire an `@event` defcap** - it routes to the install path and fails
   with "capability is not managed and cannot be installed". Check for `@event` first.
4. **A bare-substring `expect-failure` is not a pin.** Two were green for the wrong reason.
5. **When a test's DOC STRING and its EXPECTED MESSAGE describe different things, that gap is an
   unfiled defect report.** `TX-VCT-N01` pinned a native fault while its label named the intended
   guard. Deliberate ones carry a `FINDING:` marker - that marker is the difference between
   documentation and camouflage.
6. **`env-module-admin` must sit at transaction top level.** Inside a `let` the write silently aborts
   the whole file with NO FAILURE line.
7. **Module schemas are not interface members.** `object{Iface.MODULE|Schema}` does not resolve
   through a modref - bind untyped.
8. **`try` with a fallback hides a missing row.** Do not probe for an unusual VALUE using a `try`
   fallback that IS the value you are hunting.
9. **Never `pgrep -f` for a string your own waiter command line contains** - it matches itself and
   spins forever. Prefer `run_in_background` + the completion notification.

## HOW TO RUN THINGS

    cd REPL
    python3 _gate.py                  # full determinism gate (~215s) - the authority
    python3 _enforce_coverage.py      # G2 guards
    python3 _conformance.py           # G4
    python3 _docclaims.py [--show N]  # G5
    python3 _scale_report.py --untested   # G6; `reach` column: "-" = never reached, VIA = transitive
    python3 _vacuous.py ; python3 _expectfail.py

Individual harness: `pact modules/<NAME>.repl` (self-booting). Always run the module harness after
an edit, then the full gate after a source change.

## PLAN DOCS

* `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md` - ORDER OF WORK block is authoritative (phases 1-4 struck
  through; 5 is NEXT; 6 last).
* `ARCHITECTURE/REPL_SUITE_STATS.md` - running figures.
* `memories/2026-09-13-*.md` - per-phase write-ups (guard pinning, conformance, docclaims, function
  coverage, and the DEFECT file which carries all four fixes plus the open finding).


---

# THE `INFO_` COST TEMPLATE — PROVEN GREEN 2026-09-14

First green instance: `REPL/modules/ATS.repl <<ATS-I1>>` (predicted 89.0 == real 89.00, non-zero).
**Copy this shape for every `INFO_`.**

```pact
(env-sigs [{ "key": "<PK of the patron>", "caps": [] }])
(let
    (
        (ref-TALOS:module{<TalosIface>} <TALOS>)
        (ref-DALOS:module{OuronetDalosV2} DALOS)
        (patron:string <ACCOUNT THAT HOLDS THE FUNDS>)
    )
    (let
        (
            ;;PREDICTED -- read BEFORE anything executes, exactly as a client would
            (predicted:object{OuronetInfoV2.ClientInfo} (<INFO-MODULE>.<INFO_FN> patron ...))
            (ignis-before:decimal (ref-DALOS::UR_TF_AccountSupply patron false))
        )
        (let ((predicted-ignis:decimal (at "ignis-need" (at "ignis" predicted))))
            (ref-TALOS::<EXEC OP> patron ...)                 ;; REAL, same args
            (let ((real-ignis:decimal (- ignis-before (ref-DALOS::UR_TF_AccountSupply patron false))))
                (map print
                    [ (expect "<<TAG>> predicted IGNIS equals what the op actually charged"
                          real-ignis predicted-ignis)
                      (expect "<<TAG>> ...and it is a real, non-zero charge"
                          true (> real-ignis 0.0)) ])))))
(rollback-tx)     ;; discard the side effects
```

## Facts confirmed by execution

* **IGNIS balance reader**: `DALOS::UR_TF_AccountSupply <patron> false` (the `false` selects IGNIS).
  Equivalent: `DPTF::UR_AccountSupply (DALOS::UR_IgnisID) patron`.
* **STOA balance reader**: `coin.get-balance <k:account>`.
* **Field path is `(at "ignis-need" (at "ignis" info))`** -- the `ClientInfo` schema
  (`02_IGNIS.pact:156`) is `{pre-text, post-text, ignis:{ClientIgnisCosts}, stoa:{ClientStoaCosts},
  output}`. `ClientIgnisCosts` = `{ignis-discount, ignis-full, ignis-need, ignis-text}`;
  `ClientStoaCosts` = `{stoa-discount, stoa-full, stoa-need, stoa-split, stoa-targets, stoa-text}`.
* **Use `ignis-need`, NOT `ignis-full`.** `URCi_` defines the RAW cost; the patron is charged
  `raw x URC_IgnisGasDiscount(patron)`, and `ignis-need` is that discounted figure -- i.e. the number
  the client actually pays. Independently corroborated by the one pre-existing instance of this
  assertion in the suite, `Stage_01/[6.12]_DALOS-ADMIN.repl:245`.
* **ALWAYS assert the charge is non-zero.** Some harnesses boot with virtual gas zeroed; there a
  delta assertion would pass vacuously (0 == 0). The non-zero line is what stops that.
* **Wrap in `rollback-tx`** so the executed op leaves no state behind.

## Traps hit while building it

* `INFO_ATS|Coil`, not `ATS|INFO_Coil` -- the module qualifier comes first, the pipe segment second.
* The INFO-ONE module lives at `1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact`; INFO-TWO alongside.
* Pick a pair/account that can ACTUALLY run the op: Auryndex and KORIndex have hibernation ON (coil
  refused); ANHD holds no PKOSON (coil aborts on the debit). PlebeicStrength + `KST.AOZT` works.
* A dormant precedent exists at `_scratch_infoone_h6_coil_cost.repl` quoting the same owner rule, but
  it is UNGATED and written against the removed V1 interfaces. Do not copy it verbatim.

## The three specs, and why only one counts

1. `INFO_X.ignis-need == <hardcoded>` -- ALREADY FAILED SILENTLY: `[6.5]_AQP-INFO.repl` pinned four
   anchor costs at 1000.0; task #76 moved the real price to a computed 574.0; the suite was orphaned.
2. `INFO_X.ignis-need == URCi_X` -- TAUTOLOGICAL; `INFO_X` is built from `URCi_X`.
3. `INFO_X.ignis-need == measured charge` -- the owner's spec. The only independent oracle.


---

# DEFECT: the Equity preview told clients a 918-STOA operation was free — 2026-09-14

**FOUND BY THE OWNER'S `INFO_` SPEC ON ITS FIRST REAL APPLICATION.** Fixed in
`1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact` `INFO_EQUITY|IssueCompany`.
Pinned by `REPL/modules/EQUITY.repl <<EQ-I1>>`.

## What was wrong

The preview reported `OI|UDC_NoStoaCosts` -- a LITERAL ZERO, rendered to the client as
*"Operation is free of native Stoa (STOA)"*. Measured against a live `DPSF|C_IssueCompany`:

    IGNIS predicted 6965.26   real 6965.26    <- correct
    STOA  predicted    0.0    real  918.0     <- the bug

**Half the quote was right, which is exactly why it survived.** A test checking only IGNIS -- the
obvious thing to check -- would have passed.

## The charge has TWO STOA legs, and the first repair only found one

Reporting just the equity premium moved the quote to 765.0 against a real 918.0. The rest comes from
a NESTED collect:

* `04_DPDC-I.pact:502` -- `C_IssueDigitalCollection` runs its OWN
  `STOA|C_Collect patron (URCi_IssueCollectionStoa son)`, inside `C_IssueShareholderCollection`;
* `01_TS02-C1.pact:1560` -- the Talos wrapper then adds
  `STOA|C_Collect patron (UC_StoaPrice "issue-shareholder")`.

Raw 200 + 1000 = 1200, x the patron discount 0.765 = **918**. Correct fix sums both raw legs and
lets `OI|UDC_DynamicStoaCost` apply the discount.

**The codebase already said this.** `11_EQUITY+.pact:385`: *"the collection-issue STOA price previews
SEPARATELY via DPDC-I::URCi_IssueCollectionStoa"*. Nothing ever added the two together for the
client. A documented decomposition with no test is a decomposition nobody performs.

## Why this validates the spec

The three candidate specs, applied to this exact function:

1. `== hardcoded` -- would have been written as `0.0` and been green forever.
2. `== URCi_X` -- TAUTOLOGICAL: the preview *is* `OI|UDC_NoStoaCosts`, so it equals itself. Green.
3. `== measured charge` -- **the only one that fails.** Owner's spec.

## Generalised

* **Check EVERY currency an op charges, not the obvious one.** `ClientInfo` carries `ignis` and
  `stoa`; an op can be right in one and silently wrong in the other.
* **Follow nested `C_` calls for additional collects.** The Talos wrapper is not the only place a
  charge originates -- a core `C_` invoked inside the cumulator build can collect independently.
  Grep the whole call tree for `STOA|C_Collect` / `C_Collect`, not just the entrypoint.
* Suspect any `OI|UDC_No{Ignis,Stoa}Costs` in a preview whose exec touches that currency. Those are
  literal zeros and are the cheapest possible way to be wrong.


---

# TWO MORE PREVIEW/CHARGE DEFECTS, FOUND BY SWEEPING FOR THE *SHAPE* OF THE EQUITY BUG — 2026-09-14

After `INFO_EQUITY|IssueCompany` (see above), the obvious question was: how many more quote a literal
zero for a currency their op really charges? Rather than test 425 previews one at a time, I swept the
source for the SHAPE. That found two, both fixed, both now pinned by measurement:

| preview | said | really charges | pinned by |
|---|---|---|---|
| `INFO_SWP|ToggleFeeLock` | STOA-free | 432.5 STOA on UNLOCK | `modules/SWP.repl <<SWP-I1>>` |
| `INFO_ATS|ToggleParameterLock` | STOA-free | 500.0 STOA on UNLOCK | `modules/ATS.repl <<ATS-I2>>` |

Fixes: added `SWP::URCi_ToggleFeeLockStoa` and `ATS::URCi_ToggleParameterLockStoa` (+ interface
stubs), and pointed the two previews at them via `OI|UDC_DynamicStoaCost`.

## The tell: THREE SIBLINGS, ONE OF THEM ALREADY CORRECT

    DPTF::C_ToggleFeeLock       -> INFO_DPTF|ToggleFeeLock        uses URCi_ToggleFeeLockStoa   CORRECT
    SWP::C_ToggleFeeLock        -> INFO_SWP|ToggleFeeLock         hardcoded NoStoaCosts         WRONG
    ATS::C_ToggleParameterLock  -> INFO_ATS|ToggleParameterLock   hardcoded NoStoaCosts         WRONG

Identical exec shape in all three:

    (stoa-costs (at 1 (XI_Toggle... id toggle)))      ;; [0.0 0.0] on LOCK, UC_FeeUnlockPrice on UNLOCK
    (if (> stoa-costs 0.0) (do (XI_Increment...) (STOA|C_Collect patron stoa-costs)) true)

DPTF had been given the read-only price twin; SWP and ATS never were. **When one member of a family
of identical ops is correct and the others are not, the correct one is the specification.** Diffing
siblings is cheaper than auditing each in isolation, and it tells you what the fix should look like.

## WHY THE ZERO SURVIVED: it is right half the time

LOCKING really is free. So the preview is correct in one direction and wrong in the other, and any
test that happened to exercise the lock direction passes. **A conditional cost tested on only one
branch is untested.** Both new blocks deliberately measure the CHARGED direction, and both carry a
`(> real-stoa 0.0)` assertion so the equality can never be the old bug agreeing with itself at zero.

## SWEEP RESULT, IN FULL (so nobody re-runs it hoping for more)

Static sweeps over all 425 `INFO_` functions, four directions:

1. quotes zero STOA / exec collects STOA  -> **2 real** (above), 9 false
2. quotes zero IGNIS / exec collects IGNIS -> 0 real, 1 false (`AQP-POOL|AbortVacate`: the exec
   collects an EMPTY cumulator, which charges nothing -- the preview is right)
3. quotes STOA / exec has no STOA leg -> 0 real (all 6 were SWP issuance, where the collect sits two
   call levels down in `MTX-SWP`)
4. preview quotes a `URCi_` the exec never uses -> 168 hits, ALL noise. Abandoned.

**The false positives all have one cause: resolving a call by BARE FUNCTION NAME.** `C_Fuel` exists in
ATSU, SWPLC and OUROBOROS; the resolver picked OUROBOROS's, which really does reach `STOA|C_Collect`,
and three previews got flagged for a path their op never takes. Any cross-module static analysis here
must resolve through the modref binding (`(ref-X:module{Iface} MOD)`), not the name. Sweeps 1 and 2
stayed useful because their signal is a LITERAL ZERO in the preview -- a property of one function,
needing no call resolution -- and only the confirmation step needed the call graph, which a human
read settled in minutes.

## THE MEASUREMENT HARNESS -- two traps that cost real time

Measuring STOA needs managed `coin.TRANSFER` caps, because a STOA charge is a real `coin.transfer`
split 10/20/30/40 across the four `OI|UR_StoaTargets`. It fails deep inside `coin.pact` with
"Managed capability not installed", pointing nowhere near the actual mistake:

**Build the cap list LITERALLY.** `(map (lambda (t) (coin.TRANSFER sender t 1000000.0)) targets)`
does not install anything — it produces a signature entry with no usable caps, silently. The
capability values have to be written out one per line in the `caps` list.

**CORRECTION, and the reason this entry is worth reading twice.** I first recorded a second cause
here -- "`env-sigs` inside a `let` does not install managed caps; it must sit at transaction top
level" -- by analogy with the known `env-module-admin` trap. **That is false.** I had changed two
things at once (hoisted the form AND replaced the lambda with literals), it went green, and I
credited the wrong one. `REPL/Stage_01/[6.10]_PYTHIA.repl:62` installs four managed `coin.TRANSFER`
caps from INSIDE a `let` and has always been green, which settles it: placement is fine, the lambda
was the whole problem. **A fix that changes two things proves nothing about either.** Change one,
re-run, then change the other -- or you will write down a law that is half superstition, and the next
person will restructure working tests to obey it.

The sender key is the patron's Stoa account minus its `k:` prefix; the four receivers are stable
across the suite. Fastest way to find the sender: run once and read it out of the error line.


---

# THE SAME DEFECT, FIVE MORE TIMES, IN A FOURTH MODULE — 2026-09-14

`INFO_VST|CreateFrozenLink`, `CreateReservationLink`, `CreateVestingLink`, `CreateSleepingLink`,
`CreateHibernatingLink` all returned `OI|UDC_NoStoaCosts`. All five charge STOA. Measured: **76.5
predicted vs 76.5 real**, where the preview had said 0.0. Fixed by adding
`VST::URCi_CreateSpecialTrueFungibleLinkStoa` / `...OrtoFungibleLinkStoa` (+ interface stubs) and
repointing the five previews at them. Pinned by `REPL/modules/VST.repl <<VST-I1>>`.

**Running total: 8 preview/charge defects, 4 modules** -- EQUITY x1, SWP x1, ATS x1, VST x5.

## A WRONG COMMENT KEPT THE BUG ALIVE

The block was headed:

    ;; ---- Special-link creation (IGNIS only; STOA auto-fuel is protocol, not a patron charge) ----

Which is half true, and the true half is the dangerous part. There ARE two STOA mechanisms here:

* `TS01-A::XB_DynamicFuelSTOA` -- protocol auto-fuel, genuinely not a patron charge, and inert
  anyway while `native-gas-pump` is false. The comment describes this correctly.
* `XI_CreateSpecialTrueFungibleLink` (`11_VST.pact:1489`) / `XI_CreateSpecialOrtoFungibleLink`
  (`:1553`) -- `(ref-IGNIS::STOA|C_Collect patron stoa-costs)`. A direct, discounted charge to the
  patron. The comment does not describe this at all, and it is what actually runs.

Someone reasoned correctly about one mechanism, wrote the conclusion down, and it then applied to
five functions for which it was false. **A comment asserting an absence is a claim, and claims in
comments are not tested.** When a comment explains why something costs nothing, that is the exact
place to demand a measured zero.

## THE PROOF WAS ALREADY SITTING IN THE TEST FILE

`REPL/modules/VST.repl` VST-02 cannot run without signing four managed `coin.TRANSFER` caps built
from `URC_SplitSTOAPrices patron (UR_UsagePrice "dpmf")`. That block has been green for a long time.
**A test that must sign for a charge is standing proof the charge exists.** Nobody had asked the
preview whether it agreed, so the two facts sat ten files apart and never met.

**Generalised, and worth automating:** any op whose test needs a managed `coin.TRANSFER` cap MUST
have a non-zero `stoa-need` in its preview. That is a mechanical cross-check between the REPL corpus
and the INFO family, and it would have found this without reading a line of Pact.

## WHY MY OWN SWEEP MISSED IT

My earlier sweep followed calls matching `(?:C_|CC_|XE_|XB_)` and **not `XI_`**. Both VST collectors
live inside `XI_` functions. The reasoning was that `XI_` is persistence-only -- the house rule says
`XI_` does writes, no enforce, no billing -- so I did not follow it. **The rule is a convention, and
these two `XI_`s break it by collecting STOA.** Never let an architectural convention prune a search
for violations of that same convention: the violations are exactly what you are looking for.

## PROCESS FAILURE WORTH MORE THAN THE BUG: I CORRUPTED FIVE UNRELATED FUNCTIONS

The patch script located each preview with `t.index(f'(defun {fn}:')` and then the next
`OI|UDC_NoStoaCosts` after it. In this codebase interfaces are CO-LOCATED in the same file as the
module, so `(defun INFO_VST|CreateFrozenLink:` matched the **interface stub** near the top, and the
"next" `NoStoaCosts` was ~1300 lines away inside `INFO_DPTF|UpdatePendingBranding`. Five DPTF
previews were silently rewritten to call a VST function.

It was caught immediately -- `Unbound variable ref-VST` on the next run -- but only by luck: the
inserted text happened to reference a modref those functions do not bind. **Had the corrupted
functions bound `ref-VST`, this would have compiled and quietly reported VST's link price for five
DPTF operations.**

Rules adopted, and they are cheap:
1. When a file contains both an interface and a module, anchor on the **body**, not the name:
   accept a `(defun X:` match only if `'(let' in text[start:start+400]`.
2. After any anchored edit, assert the edit landed **before the next `(defun`** -- i.e. inside the
   function you aimed at.
3. Prefer anchors that include several lines of surrounding context over `index` + "find the next
   thing". A unique multi-line anchor cannot silently slide 1300 lines.

## SUBAGENT REPORTS ARE EVIDENCE, NOT FINDINGS -- VERIFY BEFORE ACTING

Two research agents contradicted each other on whether the gas toggles are on:

* One: "IGNIS preview is 0.0 for every op ... your test will be vacuous unless you first turn the
  toggles on", with a full derivation from `[4.0]_Sovereign-Executor.repl:302-311`.
* The other: "virtual ON, native ON", citing `[4.0]_Sovereign-Executor.repl:989-990`.

I probed all four harness chains directly:
`VIRTUAL-TOGGLE=true NATIVE-TOGGLE=true virtual-gas-zero=false native-gas-zero=false`. **The second
was right.** The first had read the seed values at line 302 and missed that line 989 flips them.

Acting on the first report would have meant restructuring every INFO block around a toggle-flip that
was never needed, and writing a "fix" for a problem that did not exist. The probe cost one command.
**A confident, well-cited, internally-consistent report can still be wrong about a fact you can
measure in thirty seconds -- so measure it.** The same agent's VST finding, in the same report I was
about to distrust, was the real bug. Verify claim by claim; do not accept or reject a report whole.


---

# THE TWO OPS THAT HAD NEVER SUCCEEDED — 2026-09-14

Owner ruling: *"If an op exec counterpart is missing it has to be added, it means we missed it."*
Both now execute successfully, with their `INFO_` quote measured against the charge.

| op | first success | why it was never built |
|---|---|---|
| `VST\|C_Slumber` | `REPL/modules/VST.repl <<VST-I2>>` | the only historical caller was calling it BY MISTAKE |
| `DPTF\|C_ToggleFeeExemptionRole` | `REPL/modules/DPTF.repl <<DPTF-I1>>` | three authors read an intersection as a contradiction |

## `VST|C_Slumber` -- a fix plus a negative test looked complete

"Slumber" and "Sleep" are synonyms in English and OPPOSITES here:

    C_Merge   / C_RepurposeMerge     -> vzh-tag 2 = SLEEPING
    C_Slumber / C_RepurposeSlumber   -> vzh-tag 3 = HIBERNATING

Before 2026-09-12 VST-07 called `C_Slumber` on a SLEEPING token and it SUCCEEDED, minting the
un-unsleepable nonce `<<VST-G7>>` still pins. The repair added `(enforce (= (take 2 dpof) "H|") ...)`,
migrated the mistaken call to `C_Merge`, and pinned the refusal with two `expect-failure`s.

**Nobody wrote a correctly-typed caller to replace the removed wrong one.** So the guard was tested,
the misuse was tested, and the SUCCESS PATH was left with no test at all -- in an op whose only prior
execution in the repo's history had been a bug. **A fix plus a negative test can look complete while
leaving the positive case permanently unexercised.** When a repair deletes the only caller of
something, check whether it was the only caller.

The second barrier was fixture state: `XIv_MergeNonces` wipes every listed nonce from the merger, so
the merger must hold >= 2 live `H|` nonces. ANHD holds ZERO at that point -- every hibernating nonce
it ever minted was awakened or repurposed to EMMA. There had never been a moment in the file with two
ANHD-held `H|` nonces, so even a correctly-typed call would have died inside `C_WipeClean`. The test
mints its own pair and rolls back.

Bonus: the consumed nonces read **-1.0**, not 0.0. Spent nonces are DECOMMISSIONED with a sentinel,
not zeroed, so the row stays distinguishable from a live-but-empty nonce. Asserting -1.0 is strictly
stronger -- 0.0 would also hold for an emptied live nonce and would not prove the merge retired them.

## `DPTF|C_ToggleFeeExemptionRole` -- "unreachable" was three people misreading an intersection

    (ref-DALOS::UEV_NotSmartOuronetAccount account)      ;;05_DPTF.pact:819
    (ref-DALOS::UEV_EnforceAccountType account true)     ;;05_DPTF.pact:820

Read casually: "not smart" AND "must be smart" -> unsatisfiable. They are different predicates.
Line 819 rejects the EIGHT hard-coded PROTOCOL contracts (`01_DALOS.pact:1111` -- DALOS, ATS, VST,
LIQUID, OUROBOROS, SWP, DHV2, AQP). Line 820 demands a `Σ`-prefixed account flagged smart. The
intersection is exactly one class: **a user-deployed smart account.**

Three separate attempts picked from outside that class and each concluded the op was untestable:

* `modules/DPTF.repl` passed `emma`, a standard account -> dies on 820, pinned as a refusal.
* `[4.0]:1587/1591` passed the SWP contract -> would die on 819. Commented out.
* `_scratch_dptf_h4_missing_imc.repl` states it outright: *"no such fixture was readily available in
  this harness's boot chain"* -- and routes around it.

The fixture existed the whole time: **`KC.BJ`**, deployed at `[2.1]_Dalos.repl:192` as a "Banana
Example" -- smart, and not one of the eight. `<<DPTF-I1>>` asserts BOTH halves separately
(`UR_AccountType` true, `UR_AutonomicRoles` false) so the next reader can see why this account and
not another, then grants AND revokes the role.

**THE LESSON: when two guards read as a contradiction, they are usually an intersection.** Work out
which class satisfies both before concluding "unreachable". Three people concluded unreachable about
a set with one member sitting in the boot chain. "I could not find a fixture" is a statement about
the search, not about the code.

---

# `REPL/_infostoa.py` -- a detector, and why it was nearly worthless twice

Added a static sweep for the defect class above: an `INFO_` preview returning `OI|UDC_NoStoaCosts`
with no real STOA constructor anywhere in it, whose exec tree reaches `STOA|C_Collect`.

It reported **"0 to review"** twice while live defects sat in the tree. Both times the zero was a
BUG IN THE TOOL, not a clean codebase:

1. **It matched prose.** `STOA|C_Collect` appears inside `IGNIS::C_TransferDalosFuel`'s own `@doc`
   ("Guarding here covers every STOA|C_Collect* path at once"). The tool invented a call path through
   a function that only transfers coin, and reported five previews against it. Now strips `;;`
   comments and all string literals before searching. **A detector that matches prose invents
   evidence, which is worse than finding nothing.**
2. **It required `::` on callees.** Cross-module calls read `(ref-VST::C_CreateFrozenLink ...)`, but
   `VST::C_CreateFrozenLink` reaches its collector through a LOCAL `(XI_CreateSpecialTrueFungibleLink
   ...)` with no qualifier. The tool was blind to every same-module hop -- which is most of them.

**How both were caught: MUTATION TESTING.** I reintroduced one known defect and required the tool to
name it. The first run after "0 to review" still said "0 to review" with the defect present -- which
is the only reason I did not file the codebase as clean.

**Rule: a static checker that reports zero findings has proven nothing until you have watched it
fail.** Before trusting any new sweep, break something it must catch and confirm it catches it. Cost:
one command. Value: the difference between "clean" and "blind", which are indistinguishable from the
output alone.

With both bugs fixed and the mutation test passing, the tool reports 0 across the tree -- and that
zero now means something. The STOA-direction class is exhausted.

---

# Operational note: DO NOT EDIT SOURCE WHILE THE GATE IS RUNNING

Two gate runs failed tonight on files I was mid-edit on (`[6.2.5]_AQP-VCT.repl`, then
`02_INFO-ONE+.pact` during the mutation test). Both looked like real regressions -- one reported
BROKEN across eight Stage-02 entrypoints -- and both were phantoms. The gate reads 305 files across
16 workers over ~5 minutes; any write inside that window can be read half-applied. Either wait, or
work on files the run cannot reach. Ten minutes were lost chasing the first one.


---

# NEGATIVE RESULT: the IGNIS-side "drift" detector cannot work. Do not rebuild it. — 2026-09-14

`_infostoa.py` works because its signal is a LITERAL ZERO in one function -- a property needing no
call-graph resolution. I tried the IGNIS analogue twice: flag any preview quoting a `URCi_` its
operation's call tree never reaches.

* v1 (bare-name callee resolution): 168 suspects, all noise.
* v2 (proper modref resolution, prose stripped, 4 levels deep): **117 suspects, still all noise.**

The reason is structural, not a tuning problem:

    INFO_VST|Vest   quotes  URCi_Vest
    VST|C_Vest      reaches URCi_Mint, URCi_MoveCumulator, URCi_TransferCumulator

`URCi_Vest` is an AGGREGATE -- a deliberate sigma over the component legs. The preview is *supposed*
to name a function the exec never calls. So "preview names a URCi_ the exec does not reach" is the
NORMAL, CORRECT shape for most of the family, and a detector built on it flags the architecture.

The real question -- does `URCi_Vest` equal the sum of the legs the exec actually bills? -- is
NUMERIC. No static check can answer it, because the aggregate and the components are different
expressions that must evaluate equal. **Only measurement decides.** That is precisely the owner's
spec, and it is why the `INFO_` phase is per-op measured tests rather than one sweep.

**The general rule this taught: a static detector works when the defect is a property of ONE function
(a literal zero); it fails when the defect is a DISAGREEMENT BETWEEN TWO computations.** Check which
kind you have before building the tool. I got one of each tonight, and the second cost two builds
before the shape became clear. `_infodrift.py` was not committed -- shipping a 117-line noise report
would train everyone to ignore it, and a checker nobody reads is worse than no checker.


---

# THE `INFO_` MEASUREMENT PHASE: METHOD THAT SCALED — 2026-09-14

~78 `INFO_` previews now have a MEASURED test (quote read before the op, charge measured across it).
Families complete or near-complete: PYTHIA 4/4, CODEX 4/4, DPTF 14, DPOF 8, VST 11, DPDC 12,
DPDC-S 4, DPDC-FRAGMENTS 4, DEMIPAD 8, DALOS 5, ATS 2, SWP 1, EQUITY 1, LIQUID 1, AQP 1.

## WHAT MADE IT GO FAST

**1] One `begin-tx ... rollback-tx` per op.** Self-contained, order-independent, leaves no residue.
Trying to wrap the EXISTING call sites in place was the wrong instinct: those sites have their own
assertions and their own `let` shapes, so each edit is bespoke and each carries a risk of breaking a
green test. A fresh block reuses the harness's STATE without touching its CODE.

**2] Generate the blocks from a template, do not hand-write them.** A Python dict per op
(`tag / info-call / exec-call / extra assertions / notes`) rendered through one f-string. Twelve DPDC
blocks went green on the first run this way. Hand-written blocks averaged two or three fix cycles,
almost all of them typos in modref interface names.

**3] Rely on `let` being EAGER and ORDERED.** Bind `predicted`, then `ignis-before`, then the exec
call itself, all in ONE `let`. They evaluate in order, so the quote and the opening balance are both
taken before the op runs — no nesting needed. This is the same property that causes the mute-guard
bug class elsewhere; here it is exactly what the measurement wants.

**4] Always assert the charge is NON-ZERO.** Every block carries `(> real 0.0)` alongside the
equality. Without it, a preview quoting 0.0 for an op that charges 0.0 passes while proving nothing —
which is precisely how `INFO_EQUITY|IssueCompany` survived. Where zero IS the correct answer
(`AQP-POOL|AbortVacate`), the block says so explicitly and substitutes a different guard: proof that
the op DID something.

## WHAT COST TIME, SO THE NEXT PERSON DOES NOT REPEAT IT

* **Modref interface versions must be READ, never guessed.** `TalosStageOne_ClientOneV2`,
  `...ClientThreeV4`, `...ClientFourV8`, `TalosStageTwo_ClientOneV2` — no pattern. Copy the binding
  line out of the harness being edited.
* **Reader names are not guessable either.** `UR_AccountFreeze` does not exist; it is
  `UR_AccountFrozenState`. One run lost.
* **Preview and exec arity/order differ per function, not per family.** `INFO_DPOF|AddQuantity` takes
  `(patron id NONCE ACCOUNT amount)` while `DPOF|C_AddQuantity` takes `(patron id ACCOUNT NONCE
  amount)`. Here the type checker caught it; a same-type swap would have silently priced the wrong
  thing. `INFO_DPTF|ToggleFeeLock` even declares a 4th parameter its body never reads.
* **Check preconditions the CAP demands on a THIRD party.** `DPOF|C_AddQuantity` needs the
  add-quantity role on the TARGET account, not the patron. Grant it as explicit setup, before the
  measurement window opens.

## THE FIXTURE HAZARD THAT WOULD HAVE PRODUCED A FALSE DEFECT REPORT

DPDC transfers debit the patron TWICE: once for gas, and again inside
`DPDC-T::C_IgnisRoyaltyCollector`, which pays the creator's ignis-royalty. **The preview quotes only
the gas leg.** Measure a transfer of `MOCKS` nonce 3 (royalty 9.0, ignis-royalty 8.0) and the charge
exceeds the quote — which looks exactly like a preview defect and is not. Nonces 1, 2 and 4 carry
0.0, so `<<DPDC-I1>>` uses nonce 1 and says why in a comment.

**Generalised: before calling a preview/charge gap a defect, ask what ELSE debited the patron in that
transaction.** A measured mismatch is evidence of a mismatch, not evidence of whose fault it is.


---

# SIX MORE PREVIEW DEFECTS — THE INJECT FAMILY AND THE SWAP-PAIR ISSUE FAMILY — 2026-09-14

Running total: **15 preview/charge defects, 6 modules**, every one fixed and pinned by measurement.

| # | preview | said | really charges | pinned by |
|---|---|---|---|---|
| 1 | `INFO_EQUITY\|IssueCompany` | 0 STOA | 918 STOA | `modules/EQUITY.repl <<EQ-I1>>` |
| 2 | `INFO_SWP\|ToggleFeeLock` | 0 STOA | 432.5 STOA | `modules/SWP.repl <<SWP-I1>>` |
| 3 | `INFO_ATS\|ToggleParameterLock` | 0 STOA | 500 STOA | `modules/ATS.repl <<ATS-I2>>` |
| 4-8 | `INFO_VST\|Create*Link` x5 | 0 STOA | 76.5 STOA | `modules/VST.repl <<VST-I1>>` |
| 9-12 | `INFO_AQP-FVT\|Inject` + Stream + Finalize + `MTX\|2Inject` | 276.13 IGNIS | 276.66 IGNIS | `[6.5.1] <<TX-INFO-GT-INJECT>>` |
| 13-15 | `INFO_SWP\|Issue{Stable,Standard,Weighted}` | 600 STOA | 500 STOA | `[6.2+3] <<SWP-ISSUE-INFO>>` |

## THE INJECT FAMILY: a missing leg, found by asking "which sibling is NOT shaped like the others"

`INFO_AQP-FVT|Inject` quoted `RPS.URCi_Inject` -- the gas leg only. But `XI_FvtInjectCore`
concatenates FOUR phases, and PHASE 1 is
`(ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)` -- a custody transfer that
carries its own cumulator. Measured: predicted 276.13, real 276.66, **short by exactly 0.53**.

The tell was structural: **every other transfer-bearing AQP op has a `*Full` reader that counts its
transfer leg** -- `URCi_TrueFungibleStakeFlow` leg 1.1 counts `TFT.URCi_TransferCumulator`,
`URCi_CollectFull` counts `URC_CollectTransferLegIgnis`, `URCi_Sync*Full` counts `ico-ank`. The
inject family was the only one with no `*Full` reader at all. Added `RPS::URCi_InjectFull`; after the
fix, delta 0.0000.

**All four members shared it** (`CC_Inject`, `CC_InjectStream`, `CC_InjectFinalize`,
`MTX-AQP|2|CC_Inject`) because they route through the same core. Verified the other two phases
(`XI_ReleaseStream`, `XI_DistributeInjectAmount`) build no cumulator before crediting the transfer.

## THE SWAP-PAIR ISSUE FAMILY: two paths, two prices, one preview

There are TWO swap-pair issuance paths and they price STOA from DIFFERENT constants:

    single-tx  SWP|C_IssueStandard     -> SWPI::C_Issue -> UC_StoaPrice "issue-swp-pair"  = 500
    defpact    SWP|C_IssueStandardPool -> MTX-SWP       -> (+ UsagePrice "dptf" "swp")    = 600

**All six previews quoted the second.** So the three single-tx previews over-quote by 100 STOA.
Fixed by adding `SWPI::URCi_IssueStoa` (mirroring `ATS::URCi_IssueStoa`, whose @doc already says
"Shared by the exec path and its INFO_* preview") and repointing only the three single-tx previews;
the three `*Pool` previews keep the MTX figure, which is right for them.

**AN OVER-QUOTE IS THE QUIETER HALF OF THIS DEFECT CLASS.** Nothing fails. No transaction is
rejected. The managed `coin.TRANSFER` caps in the very test that exercises this op are sized on the
LARGER figure, so they comfortably cover the smaller charge. The suite could not have noticed. Only
asking the preview what it says and then counting the coins does. **Do not assume the dangerous
direction is the only direction worth testing.**

## AND A WARNING ABOUT ACTING ON A REPORT'S ARITHMETIC

The research flagged this as a **1,429x under-quote** (0.35 quoted vs 500 charged), reading the usage
prices as `dptf 0.2 / swp 0.15` from a seed table. Live values are 600 vs 500 -- an OVER-quote of
20%, the opposite direction and three orders of magnitude smaller. One probe settled it:

    PROBE issue-swp-pair-stoa=500.0  dptf+swp=600.000000000000  deter=5000.0

The report also carried its own contradiction and said so: *"[6.3] still sizes its managed
coin.TRANSFER caps on (+ dptf swp). If the exec really transfers 500, those caps are already blown --
so either [6.3] is currently red at issuance, or 16_SWPI is newer."* The gate was green, so the caps
were NOT blown, so the quoted figure had to be the LARGER one. **The evidence to discriminate was
already in the report; the report just did not resolve it.** Read a finding's own caveats as
load-bearing, and when a claim implies something that contradicts a known-green state, resolve that
contradiction before touching source. The defect was real either way -- but a "fix" aimed at a
1,429x under-quote would have moved the preview in the wrong direction entirely.


---

# TWO MORE, IN THE CITIZEN SALES — THE ROYALTY LEG NOBODY QUOTED — 2026-09-14

**Running total: 17 preview/charge defects, 8 modules.**

`DEMIPAD-SNAKES.INFO_Acquire` and `DEMIPAD-CUSTODIANS.INFO_Acquire` both under-quoted. Measured
89.002 vs 89.004 on a 2-share buy; after the fix 89.004 == 89.004 and 130.004 == 130.004.

## WHAT WAS MISSING

`URCi_Acquire` is documented as "the Sigma of the two Talos ops" and summed exactly two legs: the
deposit and the transfer's gas. But the second Talos op, `DPDC|C_MultiTransfer`, runs
`C_IgnisRoyaltyCollector patron sender ...` BEFORE its own collect, and that pays the collection
creator **out of the patron**. So a buyer of a royalty-bearing nonce is charged the royalty on top of
the quote.

Fixed by adding the already-existing read-only reader
`DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount]` to both Sigmas, wrapped
in the same `(if virtual-gas-zero 0.0 ...)` short-circuit the collector itself uses so the preview
stays correct when virtual gas is off.

## 0.002 IS THE POINT, NOT A ROUNDING NUISANCE

The absolute gap was 0.1% of the charge. It is worth fixing anyway, for two reasons:

1. **It scales with the royalty, which is a per-collection setting.** 0.001/share here because this
   fixture's royalty is small. A collection with a real royalty makes the same omission arbitrarily
   large, and nothing in the preview would change.
2. **It is a MISSING TERM, not an imprecision.** The distinction matters: an imprecision stays small,
   a missing term grows with whatever it was supposed to track.

Anyone tempted to widen the assertion to a tolerance would have hidden a structural omission behind
a plausible-looking epsilon. **When a measured gap is small, ask whether it is small because the
quantity is small or because the error is small.** Those look identical at one data point.

## A HAZARD I HAD ALREADY WRITTEN DOWN, ARRIVING AS A REAL DEFECT

Earlier tonight, while adding the DPDC transfer blocks, I recorded the ignis-royalty double-debit as
a MEASUREMENT HAZARD -- "avoid MOCKS nonce 3, its royalty makes the charge exceed the quote and it
will look like a preview defect when it is not" -- and deliberately measured a zero-royalty nonce.

That was right for DPDC's own transfer previews, which do not claim to cover the royalty. It was
wrong as a general rule, and I nearly carried it over. For a SALE the royalty is part of what
executing the acquisition costs the buyer, the preview claims to be a complete Sigma, and the reader
to compute it already existed. **The same observation is a fixture hazard in one place and a defect
in another; what decides it is what the preview CLAIMS to cover.** Read the @doc before deciding
which it is -- "Sigma of the two Talos ops" is a claim of completeness, and completeness is testable.

## AND: TWO MODULES, ONE BYTE-IDENTICAL FUNCTION

Snakes and Custodians carry `URCi_Acquire` bodies that are identical apart from the module they sit
in. Both were fixed, and BOTH are pinned -- fixing one and trusting the other would have left half
the defect live with no test to notice. Duplicated code duplicates its bugs; it does not duplicate
its tests unless someone writes them.


---

# OPEN FINDING — NEEDS AN OWNER DECISION: the special-link IGNIS model — 2026-09-14

**This is the only thing found tonight that I did NOT fix, and the reason is that fixing it is a
pricing decision rather than a repair.** Pinned as behaviour at `modules/VST.repl <<VST-I1>>` and
`modules/SWP.repl <<SWP-I8>>` / `<<SWP-I9>>` so the numbers cannot drift while it is open.

## THE MEASUREMENT

    INFO_VST|CreateFrozenLink    quoted 719.74 IGNIS   charged 601.02   (raw 1358.0 vs 1134.0)
    INFO_SWP|EnableFrozenLP      quoted 719.74         charged 601.02
    INFO_SWP|EnableSleepingLP    quoted 721.86         charged 599.96

The STOA half of all three is EXACT (76.5 == 76.5). Only the IGNIS model disagrees.

## WHY IT IS A DESIGN QUESTION

`VST::URCi_CreateSpecialTrueFungibleLink` builds leg 1 as

    (+ (UC_IgnisPrice "VST|C_CreateFrozenLink" "vst-link")   ;; 279.0 raw
       (DPTF::URCi_IssueGas 1))                              ;; 1070.0 raw

but `XI_CreateSpecialTrueFungibleLink` concatenates only `XB_IssueFree`,
`XE_UpdateSpecialTrueFungible` and `C_ToggleTransferRole` -- **it never charges the `vst-link`
deterrence at all.** The preview also models the remaining two legs as 5.0 + 4.0 where the exec's
come to 64.0. The two sides disagree in BOTH directions, which is what rules out a transcription
error.

So either:
* **(a)** the preview invents a $2.50 deterrence the operation was never meant to carry -> fix the
  preview, and the op stays cheap; or
* **(b)** the exec FORGOT to charge a deterrence that was deliberately designed in -> fix the exec.
  That is a REVENUE bug, not a quoting bug, and every link ever created has been under-charged.

Every one of the 17 defects fixed tonight had an unambiguous answer -- the exec is the truth and the
preview must match it -- because in each case the exec was plainly doing the right thing and the
preview had simply failed to describe it. **Here the exec may be the broken side.** Guessing would
either under-price the operation permanently or silently raise its price, and neither is mine to
choose.

## BLAST RADIUS: ONE READER PAIR, SEVEN PREVIEWS

    INFO_VST|CreateFrozenLink, CreateReservationLink              <- TrueFungible reader
    INFO_VST|CreateVestingLink, CreateSleepingLink, CreateHibernatingLink  <- Orto reader
    INFO_SWP|EnableFrozenLP, INFO_SWP|EnableSleepingLP            <- preview the same link creation

Whichever way it is resolved, it resolves all seven at once.

## HOW IT WAS ALMOST MISSED, AND THE RULE THAT CAUGHT IT

Earlier tonight I fixed the STOA half of these five VST previews and wrote `<<VST-I1>>` asserting
**only STOA**. It passed. The IGNIS half was 19% wrong and sat there unmeasured.

It surfaced only because `INFO_SWP|EnableFrozenLP` previews the same link creation from a different
module, and that block measured BOTH currencies -- so the SWP test found a VST defect. I then went
back and added the IGNIS half to `<<VST-I1>>`, which confirmed the root cause.

**The rule was already written down, from the EQUITY defect: "check EVERY currency an op charges, not
the obvious one."** I applied it to EQUITY, wrote it in this file, and then broke it myself on the
very next STOA fix -- because I was hunting a STOA defect and stopped when I found it. **Finding the
bug you are looking for is the most reliable way to stop looking.** Every measured block should assert
both legs whether or not you expect either to be interesting; it costs two lines.
