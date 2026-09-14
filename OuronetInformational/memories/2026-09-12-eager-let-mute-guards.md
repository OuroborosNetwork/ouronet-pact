# The mute guard — one cause, TEN confirmed instances, TWO sub-shapes

**Date:** 2026-09-12 · **Status:** review checklist item; each instance pinned as-behaves, none fixed
**Cause (both sub-shapes):** Pact evaluates everything you wrote, in full, before the `enforce` decides.
So a read that the guard was supposed to prevent runs anyway, aborts, and the written message never
arrives.

**Sub-shape A — eager `let` (9 instances).** The guard's subject is bound ABOVE the guard and a *sibling*
binding reads a table with it. When the subject is the BAR sentinel, the sibling read aborts first.

**Sub-shape B — non-short-circuiting `fold (and)` (1 instance, found 2026-09-12).** The guard is a single
`enforce` over a `fold (and)`, an early conjunct rules the value out, and a LATER conjunct hard-reads a
row with it anyway. `fold (and)` is not short-circuiting, so being right early saves nothing. Same cause,
but the defect is INSIDE the enforce rather than above it — which means reading the `let` is not enough to
find it.

## The newest two, and the clearest

`10_ATSU.pact` — `ATSU|C>REDEEM` (:521) and `ATS|C>RECOVER` (:508) both carry
`(enforce iz-rbt "Invalid Hot-RBT")`, where `iz-rbt` is `DPOF::URC_IzRBT id`. **Neither message can
ever reach a caller.** Both defuns do this before `with-capability`:

```pact
(ats:string   (ref-DPOF::UR_RewardBearingToken id))        ;; BAR for a non-RBT
(rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))        ;; C_Redeem :1974  — same let group
(c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))    ;; C_Recover :1929 — same let group
```

`let` is eager, so for a token that is not reward-bearing the next binding looks up ATS pair `|` and
dies there. The caller gets `No value found in table ouronet-ns.ATS_ATS|Pairs for key: |` instead of
the sentence written for exactly this case. Pinned as-behaves by `modules/ATS.repl <<ATS-G14>>`, which
also asserts the *absence* of the intended message, so the assertion flips when the binding is fixed.

## Instance seven, and the first where the mute half is the MORE LIKELY input

`2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact` — `C_Step6_CreateOuroLpTriplet` (:487) and
`C_Step7_CreatePoolsAndScores` (:601-604) carry **six** input-shape guards whose messages spell out the
exact id list the operator must pass:

```
Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share …]
```

That is operator documentation delivered at the moment of the mistake — and **it only arrives when the
list is too LONG.** Both functions bind the elements above their own enforce:

```pact
(silver-boost-class-id (at 0 boost-class-ids))   ;; :483
…  (at 2 boost-class-ids)                        ;; :485
(enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")  ;; :487
```

A too-SHORT list — the far likelier mistake with hand-assembled id lists — raises a **native index
fault** first: `Array index out of bounds. Length (2), Index (2)`. And an index fault is **not
recoverable**: neither `enforce-one` nor `try` can catch it (both established earlier in this suite),
so no wrapper can soften it either.

**`C_Step9_AddFvtScoreEntities` in the same file is the correctly-ordered twin** — its enforce sits
before any `at`, so the same too-short input gets the written message. Same file, same author, same
kind of check. That is what makes steps 6 and 7 a defect rather than a Pact limitation, and it means
the fix is already demonstrated in place: hoist the length enforces above the `let`.

All seven guards plus the twin are pinned by `modules/DPDC.repl <<DPDC-G10>>` (hosted there because it
deploys Stage 02 in ~26s versus the AQP harness's ~62s, and AQP-BOOT's steps carry no `P|UEV_IMC`, so
they are directly callable).

## The full list

| site | mute guard(s) | pinned at |
|---|---|---|
| `13_OUROBOROS.pact:603,606` `UEV_Exchange` | "Ouroboros is not set", "Ignis is not set" | `[4.0] <<TX4.0-CONFIG>>` |
| `10_ATSU.pact:521` `ATSU\|C>REDEEM` | "Invalid Hot-RBT" | `<<ATS-G14>>` |
| `10_ATSU.pact:508` `ATS\|C>RECOVER` | "Invalid Hot-RBT" (same text) | `<<ATS-G14>>` |
| `22_PYTHIA.pact` | see the annotated sites | — |
| `05_FVT.pact` | see the annotated sites | — |
| `01_DALOS.pact:374,381` `GAS_PAYER` | two, annotated `;;UNREACHABLE` | — |
| `02_SCORE.pact` triplet | annotated | — |
| `04_AQP-BOOT.pact:487` `C_Step6` | 1 shape message, mute for short lists | `<<DPDC-G10>>` |
| `04_AQP-BOOT.pact:601-604` `C_Step7` | 4 shape messages, mute for short lists | `<<DPDC-G10>>` |
| `TS02-C1::DPDC\|C_BulkTransfer` | the shape guard, mute for empty / excess receivers | `<<DPDC-G14>>` |
| `21_CODEX.pact:332` `A>REGISTER-IDENTITY` | mute for a codex-id too short to split | `<<CODEX-G3>>` |
| `04_RPS.pact:2956` `UEV_AddRewardLinkContext` | **sub-shape B** — mute for a BAR family id | `<<GT-12>>` |

## The fix shape, and the in-repo example of the right order

Two options, both local:

1. **Hoist the sentinel check above the `let`** — so the guard answers before anything reads with it.
2. **Bind the dependent value lazily inside the body**, below the guard.

`DPTF::URCv_Parent` is the worked example of correct order: it enforces on the 4th character *before*
reading the parent, and is pinned by `modules/DPTF.repl <<DPTF-G5>>`. `OUROBOROS::URCv_Sublimate` is
the in-window contrast for the OUROBOROS pair: its "Gas Token isnt properly set" guard DOES speak,
because its binding group reads only an id that is already set.

**Not applied anywhere.** Moving a binding changes evaluation order — behaviour, not wording — so
unlike the missing-`format` repair it is not a free fix.

## A detector was prototyped and deliberately NOT shipped

The obvious rule — *"a `let` binding that chains a table read off an earlier sibling bound from a
sentinel-returning reader"* — measures **182 hits** across the sovereign + citizen sources. Almost all
are benign: chaining off `UR_OuroborosID`, `UR_AurynID` and friends is normal, because those ids are
always set on a configured chain. Worse, the formulation *missed* the ATSU instances that motivated it.

A rule at that signal-to-noise would be read once and then ignored, which is worse than no rule —
the same reasoning that keeps `admin-gate-terminal` from being extended to `C_` (8 false positives).

The sharp signature needs something the current scanner cannot see cheaply: *the function, or a
capability it acquires later, contains an enforce whose subject is the very binding being chained off*.
That is cross-member analysis. Left as a **review checklist item** instead:

> When reading a `let` group, ask of each binding: *if the previous binding returned its sentinel,
> what happens on this line?* If the answer is "a table read explodes", check whether a guard further
> down was supposed to catch it.

## How every instance was found

By driving a guard to failure and **reading the error that actually came back**, never by reading the
source. The ATSU pair surfaced while pinning "Invalid Hot-RBT": the expected message was right there
in the source, and the run returned a raw table error on key `|`.

---

## 2026-09-12, later — instance nine, and the clearest statement of the mechanism

`21_CODEX.pact`'s `CODEX|A>REGISTER-IDENTITY` folds **seven** conditions under one message. Its `let`
computes all seven eagerly, including:

```pact
(iz-composite-len:bool (= codex-len CODEX|APOLLO-COMPOSITE-LEN))
…
(iz-standard-valid:bool (GLYPH|UEV_ApolloAccountCheck (UC_CodexIdStandard codex-id) false))
```

For a codex-id with no separator the derived half is empty and the Apollo check indexes into an empty
list: `Array index out of bounds. Length (0), Index (0)`.

**`iz-composite-len` is computed FIRST and is already `false`** — and it saves nothing, because a `let`
is eager and `fold (and)` does not short-circuit. Two facts this suite had recorded separately, meeting
in one defect. That is the sharpest version of the pattern seen so far: *the guard had the right check,
evaluated it first, and still could not say so.*

**Bounded precisely** (`CODEX-G3`): the message is mute ONLY for an id too short to split. At the correct
length (325 = 162 + 1 + 162) a wrong separator and invalid Apollo halves both reach it. So the affected
input is the likeliest one — a truncated or hand-typed id — and the guard is otherwise healthy.

Proposed: hoist `iz-composite-len` into its own `enforce` above the `let`.

### And a boundary on how this can be asserted

The mute half cannot be double-asserted. `expect-failure` matching `"Array index out of bounds"` is the
whole proof, because matching is by substring and that rules out the written message. There is no second
formulation:

- `(try default expr)` returns the **fallback** on failure, never the error text; and
- an index fault is a **native** fault that `try` cannot recover from at all — the same boundary that
  stops `enforce-one` from catching one.

`expect-failure` is the only construct in this suite that can assert *which* error came out.

---

## 2026-09-12 — sub-shape B: the fold that reads what it just ruled out

**Site:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_RPS.pact:2956`, `UEV_AddRewardLinkContext`
**Pinned by:** `Kursan/dsa-grand-tour.repl <<GT-12 · 02>>`

```pact
(enforce
    (fold (and) true
        [(!= multiplet-family-id BAR)
         (URC_MultipletFamilyExists multiplet-family-id)
         (UR_FVT-MF|Active multiplet-family-id)
         (= reward-dptf-id (UR_FVT-MF|Token0Id multiplet-family-id)) …])
    "MULTIPLET_BASE reward requires active MultipletFamily with reward-dptf-id = token-0-id")
```

Pass `BAR` — **the case the first conjunct exists to catch** — and the caller gets:

```
No value found in table ouronet-ns.RPS_FVT|T|MultipletFamily for key: |
```

`UR_FVT-MF|Active` hard-reads a row keyed `|` even though the conjunct above it is already false.

### Why this one matters more than its severity suggests

Sub-shape A is findable by reading the `let` above an `enforce`. **Sub-shape B is not** — the code looks
correct, the cheap check IS first, and the ordering is right. The defect is that Pact does not reward
ordering inside a `fold`. Anyone auditing for A would walk straight past B.

Both facts involved were already documented separately in this suite — *`fold (and)` is not
short-circuiting* and *a hard `read` aborts on a missing row*. Ten instances later, the general statement
is worth having in one line:

> **A guard cannot protect the expression that computes its own operands.** Whether those operands come
> from a `let` above it or from a later conjunct beside it, they run first.

### Bounded

Mute only for `BAR`. Every other way to fail the fold reaches the message — `GT-12 · 01` proves it with a
real, active family and a mismatched reward token. Proposed: hoist `(!= multiplet-family-id BAR)` into its
own `enforce` above the fold. Behaviour change (evaluation order), so it waits on the owner — and it is
the same one-line fix as the other nine.

## Instance 12 — `00_Demipad.pact:513`, the launchpad deposit registration check (2026-09-12)

```pact
(let ((iz-registered (UR_CheckRegistration asset-id))   ;; SAFE: (try false (with-read ...))
      (ofb           (UR_OpenForBusiness  asset-id))    ;; bare read
      (iz-sstoa      (UR_IzSSTOA          asset-id))    ;; bare read
      (iz-ouro       (UR_IzOURO           asset-id)))   ;; bare read
  ...
  (enforce iz-registered (format "Asset {} is not registered to the Demiourgos Lauchpad. Deposit unallowed" [asset-id])))
```

Deposit against an unregistered asset and you get
`No value found in table ouronet-ns.DEMIPAD_DEMIPAD|T|Ledger for key: OURO-…`.

**What makes this the clearest instance of the twelve: the fix is already in the module, three lines
up.** `UR_CheckRegistration` deliberately wraps its `with-read` in `(try false …)` so a missing row
answers "not registered" instead of aborting — someone thought about exactly this case and solved it
for the reader the guard consults. The three *sibling* reads of the same row, bound in the same eager
`let`, did not get the same treatment and abort first. So this is not a design question about whether
the guard should exist; it is three readers out of step with a fourth in the same expression.

Not a funds hole — the deposit is refused either way. The cost is operator-facing, and the affected
input is the likeliest mistake on the path: a wrong asset-id returns a table key instead of a
sentence naming the launchpad.

Pinned as-behaves by `REPL/Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>` section 01b, which asserts
both halves — that `UR_CheckRegistration` alone answers correctly, and that the deposit still dies on
the raw read.

---

# RULED AND IN PROGRESS — 2026-09-12/13

Owner ruling: *"we gotta make each one succeed (to either false or true) ... it's not a hole in the
code, but you want to fail gracefully. So then yeah, add whatever is needed to make it so."*

**Two fix shapes, chosen by what the abort actually is. This distinction was not in the original
write-up and it matters:**

| the abort is… | fix | why |
|---|---|---|
| a **missing row** (`read` on a key that was never written) | **reader-side `with-default-read`** | evaluation order untouched; repairs the reader for every caller |
| a **BAR-sentinel lookup** (an earlier binding returned `\|`, the next reads that as a key) | **call-site: hoist the capability above the `let`** | the readers are shared (22 and 28 call sites); defaulting them would change what fifty places see |

## Done

- **`00_Demipad.pact:513`** — reader-side. `UR_OpenForBusiness` / `UR_IzSSTOA` / `UR_IzOURO` →
  `with-default-read` defaulting to `false`. All four call sites of the first were checked; `false`
  is the semantically right answer for an unregistered asset everywhere. **A second test,
  `modules/DEMIPAD.repl <<DEMIPAD-G2>>`, had independently pinned the same defect and went red when
  the fix landed** — which is how it was found. Its diagnosis was also half wrong (it blamed
  `UR_CheckRegistration`, the one reader that was already safe) and is now corrected.
- **`10_ATSU.pact:508` `ATS|C>RECOVER` and `:521` `ATSU|C>REDEEM`** — call-site. `C_Recover` and
  `C_Redeem` now acquire their capability BEFORE the `let`. Both caps take only plain defun
  parameters, so nothing in the binding group was needed to build them, and the result is the shape
  StoicSyntax asks for anyway. **Fixing `C_Recover` alone left `ATS-G14` green** — the test drove
  Redeem only. The twin was found by the fix *not* turning the test red, which is the inverse of the
  usual signal and worth remembering.

- **`04_RPS.pact:2956` `UEV_AddRewardLinkContext` and `:3001` `UEV_QualitySplitContext`** —
  call-site, and a THIRD sub-shape: the eager evaluation was inside the `enforce` itself, in a
  `fold (and)` whose later element hard-read `FVT|T|MultipletFamily` with a BAR id. **Being false in
  conjunct one saved nothing.** The discriminating test is now hoisted out of each fold into its own
  enforce above it. Both hoists ADD a guard, and both new guards are pinned in the same edit
  (`AQP-G31`, `GT-12.02`) — a hoist that leaves its new message undriven just moves the hole.
- **`21_CODEX.pact:332` `A>REGISTER-IDENTITY`** — call-site, index-fault variant. A short id made
  `GLYPH|UEV_ApolloAccountCheck` index into an empty derived half: `Array index out of bounds.
  Length (0), Index (0)`. The length test is hoisted above the `let`; **a length test needs nothing
  but the parameter**, which makes this the cheapest member of the class to repair. `CODEX-G3` now
  drives a short id AND an empty one.

- **`04_AQP-BOOT.pact:487` `C_Step6` and `:601-604` `C_Step7`** — call-site, index-fault variant.
  Five length enforces sat BELOW `let`s that index the very lists they measure, so a SHORT list --
  the likelier operator mistake on hand-assembled id lists -- raised `Array index out of bounds`
  and six operator-facing messages were reachable only for a list that was too LONG. All five hoisted.
  `C_Step9` in the same file was already correctly ordered, so the fix was demonstrated in place.
- **`13_OUROBOROS.pact:603,606` `UEV_Exchange`** — call-site, sentinel variant, fixed by SPLITTING
  the binding group rather than hoisting an enforce: the id reads depend on nothing, the ROLE reads
  depend on the ids, so the two BAR enforces go between them. Both guards now speak, and the staged
  walk in `[4.0] <<TX4.0-CONFIG>>` became observable for the first time — before the fix, both stages
  produced the same raw DPTF error.

- **`TS02-C1::DPDC|C_BulkTransfer`** — call-site, `enumerate 0 -1` variant, and the one that took
  three attempts. The core `C_BulkTransfer` call is now hoisted ABOVE the royalty collector, matching
  `TS01-C1::DPOF|C_BulkTransfer`, which has always been in that order and was never mute.
  **THREE separate hazards fed one symptom**, which is why the first two attempts failed:
  1. the Talos wrapper's `(enumerate 0 (- l 1))` building `ids`/`sons` — rewritten to map over
     `receiver-lst` itself (kept: removes a latent trap, identical for l>0, but NOT sufficient);
  2. `C_IgnisRoyaltyCollector`'s own `(enumerate 0 (- (length ids) 1))` indexing `nonces-array` —
     unreachable once the core validates first;
  3. `URCi_BulkTransferCumulator`, the COST PREVIEW, with two more of the same — an `INFO` path that
     faulted for a UI calling it with an empty list.
  The preview is a `URCi_`, so it must stay a pure derivation and cannot `enforce`: it was made
  TOTAL instead (an empty bulk transfer has no legs, so no cost). Refusal belongs to the client, and
  the client now gives it.
  **THREE tests had independently pinned this one defect** — `DPDC-G14`, and both halves of
  `Kursan/_verify_finding_EMPTY-LIST_01`. The last of those had written its own instruction for this
  moment: *"When this is fixed, the expected message becomes whatever deliberate refusal replaces it
  — update the string, keep the assertion."* That is the right way to leave an as-behaves pin.

## COMPLETE at 10 sites — and the original list of 12 was over-counted

The last three entries (`22_PYTHIA`, `05_FVT`, `02_SCORE`, each listed as "see the annotated sites")
were checked on 2026-09-13 and **none of them is a mute guard.** The catalogue entry conflated two
different things: "carries an `;;UNREACHABLE` annotation" and "is mute". They are all correctly
annotated, with their reasoning already recorded, and all six sites fall into three kinds that are
NOT this class:

| site | kind | why it is not a mute guard |
|---|---|---|
| `02_SCORE:995`, `:1021` | **shadowed by an upstream validator** | `XE_CreateAqpoolLink`'s only caller runs `UEV_AddScorePoolAndScore` in its cap FIRST, which enforces the same thing and answers with its own message (pinned by `AQP-G19`). Kept as cross-module defence-in-depth — SCORE must not trust a forward module. Nothing aborts before it; it simply never gets a failing input. |
| `05_FVT:3656`, `:3696` | **post-condition self-check** | Asserts that the `XE_CreateFvtLink` call on the line above actually wrote. No ARGUMENT can trip it — only breaking the callee could. Not an input guard, so not coverage. |
| `22_PYTHIA:1353`, `:1377` | **atomicity backstop** | The DLK row exists only if both counterparts were already set, in the same transaction, by the same `XI_ApplyDualCounterparts`. It already reads through `(try false ...)`, so it does not abort — it is genuinely unreachable, not silenced. Would start earning its keep if a non-atomic write path were ever introduced. |

**The distinction that matters, and the one the original list blurred:** a MUTE guard is one whose
written message is displaced by an ABORT that happens first — the input reaches the function and gets
the wrong error. An UNREACHABLE guard never receives a failing input at all. Only the first kind is a
defect; the second is defence-in-depth and the annotation is the whole treatment.

**Final count: 10 mute sites, all repaired.**

## TWO WAYS A FIX CAN COST COVERAGE — both hit in this batch, both caught by measuring after

1. **A tightened guard can starve the one below it.** The Hot-RBT prefix repair meant `H|AURYN` --
   the only input reaching the zero-supply rule -- now stops one enforce earlier, so `08_ATS:893`
   silently became unpinned. Re-pinned with `DDKOSON`, the chain's only NON-special ortofungible with
   a positive supply.
2. **A rewritten expectation can withdraw SHARED-WORDING credit from another module.** The OUROBOROS
   fix replaced a test expecting `"DPTF ID | does not exist"`; `_enforce_coverage.py` matches by
   substring, so that string had been crediting `02_DPDC:929/:934` (`"DPSF/DPNF ID {} does not
   exist"`) as a side effect. Both are now pinned explicitly. **This is the tool's documented
   upper-bound caveat biting for real: a guard credited through another module's wording is not
   actually proven.**

**Run `_enforce_coverage.py` after every source fix, not just the gate.** The suite stayed GREEN
through both regressions; only the coverage number moved.

## Three sub-shapes, not two

| where the eager evaluation is | example | fix |
|---|---|---|
| a `let` binding above the enforce | `00_Demipad:513`, `21_CODEX:332` | default the reader, or hoist the cheap test |
| a `let` binding above a `with-capability` | `10_ATSU:508/:521` | hoist the capability above the `let` |
| **inside the `enforce`, in a `fold (and)`** | `04_RPS:2956/:3001` | hoist the discriminating conjunct out of the fold |

**A hoist that adds a message must pin that message in the same edit.** Otherwise the count of
unpinned guards stays flat while the work looks done — which is exactly what happened here twice,
and is why the worklist reads 39 across three fixes.
