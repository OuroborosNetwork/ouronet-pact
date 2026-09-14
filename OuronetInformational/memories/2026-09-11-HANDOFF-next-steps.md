# HANDOFF — 2026-09-11, revised 2026-09-13 (rev 4)

## 2026-09-13 — GUARD PINNING (P3.3) IS CLOSED. READ THIS FIRST.

**LIVE guard worklist = 0.** 752/777 pinned (96%), 698 by a module-unique message (89%), 31
proven-unreachable and annotated, 3 live-but-untestable behind `require-capability`, 25 remaining
unpinned all in the dead `00_DPMF` module. Trajectory over the whole engagement: **159 → 18 → 0**.

Full account of the closing pass, including the three mechanical lessons and the new guard-shadow
shapes, is in **`2026-09-13-guard-pinning-complete.md`**. The two that will bite again:

* **`test-capability` cannot acquire an `@event` defcap** — it routes to the install path. Check for
  `@event` before planning that route.
* **A bare-substring `expect-failure` is not a pin.** Two assertions were green for the wrong reason
  (`[5.3]` TX-SPK-03 expected `"Amount"`, matching `"Invalid Redemmption Amount"` by substring;
  `[6.3]_SWP.repl:3937` was a 2-arg `expect-failure` accepting any error). Both are fixed.

**NEXT PHASE, per the owner's order: item 2 — the 117 architectural conformance observations.**
Then the `10_ATSU.pact:395` wording decision, then `@doc` claims (P3.6), then function coverage
(P3.7, 1,268 unreached — the biggest by far), then assembly + the folder reorganisation (P4.5, LAST).

**Nothing is waiting on the owner.** The last open item, `10_ATSU.pact:395`, was closed 2026-09-13
under a standing instruction to stop escalating fixes: *"fix whatever problem you find yourself...
if the fueling cant happen on negative index, then thats what needs to not happen, and must be
enforced in code."* The resolution was to keep the BOUND and fix the MESSAGE — see the wording note
below.

---

# HANDOFF — 2026-09-11, revised 2026-09-12 (rev 3, after the owner's three corrections)

## 2026-09-12 — WHAT CHANGED, READ THIS FIRST

The owner issued three corrections. All three are applied, and two of them **retracted findings of
mine**. Net effect on the suite was *positive*, because re-examining each one found real work.

1. **"keys can be called freely, there is no admin gating on this."**
   → the `cross-module-scan` finding is **WITHDRAWN**. See the conformance section below.
2. **"if an enforce is missing its string (format outputs a string), you should just add it."**
   → **FIXED** at `15_SWP.pact:466`; `SWP-G21` flipped to pin the repaired message.
3. **"liquid staking is live on mainnet, i dont know what you mean by saying it without an ATS pair?"**
   → **RE-FRAMED** as a boot-window gap, and the re-examination produced a new technique that pinned
   **five guards** previously written off as unreachable.

**Conformance VIOLATIONS: 0. `_vacuous` 0. Gate GREEN at 19,132 executed assertions.**
**Guard worklist 59** (from 159 at the start of this run); pinned 696/783 (89%), 640 of those by a
module-unique message (82%); 24 proven unreachable and annotated at the source.
**FOUR open defects wait on an owner decision** — see the OPEN DEFECTS section; the newest and most
clear-cut is the three-argument `or` at `05_FVT.pact:1954`, which is a functional break, not wording.

### The 2026-09-12 closing batch — 74 → 59, and what each one taught

Ten guards closed and three annotated. Listed by what made each one *possible*, because that is the
reusable part; the mechanics are in `2026-09-12-repl-fixture-mechanics.md`.

**Reached by moving the TEST to the chain that already had the state, not by building a fixture:**
- `08_ATS:2382` (Special/LP tokens cannot be RT or RBT) — `modules/ATS.repl` had recorded this as
  needing "a special DPTF that EXISTS in this suite" and given up. `modules/VST.repl` mints `F|MOCKA`
  three transactions earlier. The assertion moved there (`VST-G8`); the ATS note now points at it.
  **The obstacle was never the token — it was its OWNER** (a `Σ.` smart-contract account whose module
  guard no key satisfies, and `CAP_Owner` runs first).
- `05_FVT:2088` (MULTIPLET collect needs an active family) — `GT-12` already deactivated the family
  for the quality-split guard. One more call in the same window.
- `02_SCORE:1326` (three sub-models must all be single) — `GT-02` builds three SINGLE models *and*
  combines them into a TRIPLET. Nothing else in the suite has both.

**Reached by driving a flag the client itself can set:**
- `02_SCORE:744` — `C_ControlScore` writes its own precondition. No `env-module-admin`. The test
  documents a product property: **can-upgrade is a one-way door.**

**Reached by `env-module-admin` because no flow produces the state:**
- `02_DPDC:1020` (already paused) — DPDC-G2 had recorded this arm as "not reachable here"; DPDC
  property flags are fixed at issuance, so there is no pause client at all. `DPDC-G2b` supplies the
  state and drives **both arms in both states** — a full 2x2 where there were two half-truths.
- `02_SCORE:894` (BoostClass must be active) — and the contrast is **the same class, reactivated**,
  so one variable separates refusal from acceptance.
- `01_DALOS:1215` — **executed rather than annotated**; see item 2 in the proposals list below.

**Reached by finding the input that gets PAST the guard above it:**
- `05_DPTF:1010` (a Special token cannot take a frozen link) — freezing an already-FROZEN token does
  not reach it; the immutability check two lines up answers first. A **RESERVED** token with the
  **FROZEN** tag does: Special by prefix, empty frozen slot. The two guards read different fields and
  only a cross-kind input separates them. `VST-G9`.

**Pinned as-behaves because the written message cannot be emitted:**
- `05_FVT:1948` — the three-argument `or`. See OPEN DEFECTS.

**Annotated `;;UNREACHABLE` with the proof at the source** (was "cheap/mechanical for owner"):
`05_DPTF:951`, `03_DPDC-C:279`, `03_DPDC-C:282`, plus `05_DPTF:1004` (its `secondary-dptf` is always
a token issued moments earlier, so it can never be an RT or Cold-RBT) and `05_FVT:1948`.

New this session:
- `modules/LIQUID.repl` **LQD-G1/G2** — all three of `UEV_IzLiquidStakingLive`'s deep guards, in
  five states, plus a no-leakage check.
- `modules/DPTF.repl` **DPTF-G6/G6b** — the treasury-in-debt fixture; two guards that needed it and
  two admin entrypoints (`A_WipeTreasuryDebt`, `A_WipeTreasuryDebtPartial`) that had never executed.
- `modules/DPTF.repl` **DPTF-G7/G8/G9** — the OURO dispo floor, a **proof that its sibling guard at
  `05_DPTF.pact:951` is unreachable by construction** (four composed facts, each asserted), the
  fee-promile backstop, and a no-leakage check for both.
- `_gate.py` **tool-integrity pre-flight** — see the warning two sections down. Mutation-verified.
- New memories: `2026-09-12-state-driven-guard-coverage.md` (the technique),
  `2026-09-12-repl-mode-is-not-production-mode.md` (the standing rule both retractions produced).

### GUARD PINNING — 85 guards closed today, worklist 159 → 74

Every one needed **state**, not a new argument: `_cheapseam.py` reports the zero-fixture seam as
**exhausted**, so "pass a different value" is finished as a strategy. What replaced it:

| where | guards | how the state was reached |
|---|---|---|
| `LQD-G1/G2` | 3 | `env-module-admin DPTF` → write the two ATS-pair role fields |
| `DPTF-G6/G6b` | 2 | `env-module-admin DALOS` → treasury OURO balance negative |
| `DPTF-G7` | 1 (+1 **proven unreachable**) | freeze a standard account, over-wipe past the dispo floor |
| `DPTF-G8` | 1 | `env-module-admin DPTF` → an out-of-band fee promile |
| `DPOF-G6/G7` | 2 | nonce supply `-1.0` + holder BAR (exactly what `06_DPOF.pact:2497` writes) |
| `SWP-G21b/c` | 1 | the flag an existing test already flipped; then EMMA's elite tier raised |
| `VST-G6` | 1 | **`env-chain-data`** — time, not tables |
| `AQP-G35/G36` | 3 | boost-class + asset anchor counters |
| `GT-09` (grand tour) | 6 | **none** — the state was already there; EMMA was already a staker |
| `GT-10/GT-11` | 1 | `env-module-admin AQP-SCORE` → the three triplet scores that sum to quintessence |
| `ATS-G13/G14` | 4 | **none** — Auryndex/KORIndex were already hibernating; LUMY for the permission gate |
| `DPTF-G10/G10b` | 2 | **one needed none** (every account is in credit); the other reused the debt recipe |
| `SWP-G24/G25` | 4 | **no table surgery** — `BRD\|A_SetFlag` is a real admin client, so the flag moves legitimately |
| `DPDC-G9` | 1 | **none** — one amount against two nonce-datas |
| `DPDC-G10` | 6 | **none** — AQP-BOOT's steps carry no `P\|UEV_IMC`, so they are directly callable |
| `DPDC-G11/G11b` | 1 | **none** — nonce 0 / negative nonce / zero amount |
| `ATS-G15` | 4 | **none** — KORIndex had no positions, the index already carried 24 decimals |
| `ATS-G16/G16b` | 3 | **two needed none** — `TestKickPair` has every recovery off, `Auryndex` has one |
| `ATS-G17/G17b` | 2 | `c-positions = 0`; and a zeroed RBT supply, which makes the index its -1.0 sentinel |
| `DPOF-G12/G12b` | 3 | **two needed nothing**; the third wrote `owner-konto` to the ATS smart account |
| `VST-G7` | 3 | one argument-domain bound; two needed only **`env-chain-data`** rewound before the releases |
| `AQP-G37` | 4 | **none** — three argument-domain, and the suite leaves eight empty+inactive boost classes |
| `DPDC-G13` | 4 | **none** — four argument-domain guards across four different DPDC modules |
| `SICO-G10` | 3 | **none** — the KPay period domain plus two STOAICO contribution guards |
| `DPDC-G15`, `STAGEZ-21` | 2 | **none** — citizen-module list-parity checks, hosted where they deploy cheapest |
| `PYTHIA-G1`, `CODEX-G3` | 2 | **none** — an empty-pubkey check and the composite codex-id fold |
| `ATS-G18` | 2 | **none** — Constrict/Brumate hibernation polarity; the suite already has every combination |
| `DPTF-G11`, `SWP-G26` | 2 | **none** — multi-transfer list parity; removing a token that was never a principal |
| `GT-12/GT-13` | 2 | the grand tour's live vault; one `active` flag written for the second |

Three things worth carrying forward:

1. **Check whether an existing test already BUILDS the state.** The biggest single win of the day.
   `UEV_CanChangeOwnerON` was on the worklist while `SWP-G21b` was already flipping the exact flag it
   reads — it just never called the guard inside that window. And **six of DSA's eight unpinned guards
   needed no fixture at all**: `Kursan/dsa-grand-tour.repl` had already built the vault, the agency,
   the oracle authority and a second funded participant (EMMA, who stakes into that agency in GT-04),
   so four "only the FVT owner may …" refusals plus both oracle argument bounds were a matter of
   calling them. Before budgeting a fixture, grep the Kursan suites for the entity you need.
2. **If a guard compares against `(at "block-time" (chain-data))`, move the clock, not the tables.**
   `VST-G6` needed no admin and has nothing to roll back. `UEV_StillHasSleeping` was filed as needing
   a fixture and in fact fired *as the chain already stood* — the suite's clock is 2035 and the
   release dates were written for 2026. It had simply never been called late enough.
3. **Guard ORDER shadows guards.** `AQP-G35` initially passed its 49-cap assertion for the wrong
   reason, because a leftover `anchors: 7` from the previous case answered first. Restore each field
   before the next case. Same shape as `SWP-G21c`: the tier check in `SWP|S>RT_OWN` sits in front of
   the ownership flag, so the flag guard is unreachable from the client until the tier is cleared.
4. **Always drive the positive case in the same transaction.** It caught a real mistake: `GT-09`'s
   delegation-membership assertion was written with the REAL triplet id, which *is* a member, so the
   oracle write succeeded and the `expect-failure` failed. A one-sided test would have been written,
   passed for the wrong reason, and counted as coverage.
5. **When the success path is expensive, prove the guard STOPPED ANSWERING instead.** `DPOF-G12`'s
   debit-floor contrast needed a real transfer, which meant clearing the holder check *and* DPOF's
   transfer-role matrix — three fixtures deep for one assertion. What actually needed proving was
   narrower: that the guard is a threshold, not a blanket refusal. So the same call is made with a
   legal amount and the assertion is that a **different, later** message answers. Same claim, no
   fixture. Two ordering facts fell out of it for free: the amount check runs before the holder check,
   and the role matrix sits in front of the holder test too.
6. **`try` cannot be used to read an error message.** `(try default expr)` returns the **default** when
   `expr` fails, so it hands back the fallback and never the error. `expect-failure` is the only thing
   in this suite that can assert *which* error came out. (Cost me one run.)
7. **A guard tells you what it does NOT protect.** Three of today's guards give no answer at all for a
   nonexistent entity — the table read fails first with a raw key error (`VST-G6` with a bad nonce,
   `GT-10` with a bad score entity, `DPOF-G7` with any non-BAR value). Each is pinned as a boundary,
   because it means callers taking an id from outside need their own existence check.

**One guard proven UNREACHABLE rather than pinned:** `05_DPTF.pact:951` *"Can only Debit positive OURO
Amounts"*. Four composed facts close every way in (`DPTF-G7 · 02` asserts each): `UEV_Amount` forces
`amount > 0`; `wipe-mode true` always pairs with `UDC_EmptyDispo` (all 5 external callers in `09_TFT`
pass `false`); so the floor is `0.0`; and the treasury — the one account with a negative floor — can
never be frozen (`UEV_NotSmartOuronetAccount`) hence never wiped. Reaching it therefore requires
`current-supply > 0`, which is what it tests. Proposed: annotate `;;UNREACHABLE`. Not applied.

### MY OWN VACUITY DETECTOR MISSED A VACUOUS ASSERTION I WROTE — now fixed

I wrote a no-leakage check as `(expect "…back to its pre-test value" true (= (UR_NonceSupply X) (UR_NonceSupply X)))`
— the same expression twice, always true — ran `_vacuous.py`, and got a **clean 0**.

The gap: the VACUOUS test compared the **expected** against the **actual** and was blind to a
self-comparison nested **inside** the actual. That is the shape a leakage check degrades into most
naturally: the two things you want to compare are "the value now" and "the value before", and with no
handle on "before" it is one keystroke to write "now" twice.

`_vacuous.py` now has a `self_comparison` check — any `(op A A)` with textually identical operands, at
any nesting depth, for `= != >= <= > <`. Precise and false-positive-free: `(= A A)` is always true and
`(> A A)` always false, so either way the outcome does not depend on state. Two synthetic selftest
cases added (nested one level and two). Verified by running it against my own bug: it names the exact
site and operand. The corrected assertion then **failed on its first run** (expected 10, got 6 —
earlier transactions had moved the supply), which is the whole point: a real value is something a test
can be wrong about.

**The detector is still only as good as its shape library.** The class it cannot reach is unchanged and
worth repeating: an expectation computed by the code under test. Mutation remains the only complete
check.

### THE BRANDING BUGS ARE FIXED (owner-authorised) — and BRD is now fully covered

Owner: *"so lets fix those BRD bugs, since they are bugs, as it seems."* Both applied in
`04_BRD.pact`, gate GREEN, and **all five BRD guards are now pinned** — `04_BRD` is off the worklist.

1. **`XE_UpgradeBranding`** — the extension base is **clamped to now when the premium has lapsed**:
   `(add-time (if (> (diff-time premium current) 0.0) premium current) seconds)`. `current` was not
   bound in that `let`, only in the defcap, so the fix adds it.
2. **`XE_Issue`** — `genesis` is stamped **per issuance** (it was a `defconst`, i.e. BRD's own deploy
   time, shared by every entity); `premium-until` becomes a deliberate `BRD|NO_PREMIUM` sentinel
   (1970-01-01) meaning *"never held premium"*.

**The first version of fix 2 stamped `premium-until` with the issuance time, and the gate caught it.**
"Premium expired the instant this row was written" is a different claim from "never held premium", and
its truth depends on *when the row was written* — and this suite's simulated clock runs **backwards**
between files, so issuance-stamped premium made fresh entities look months-premium to earlier
transactions and refused three upgrades that had always worked. A fixed point no clock can overtake is
the right encoding. Worth remembering whenever a sentinel could be "now".

**What the fix bought:** `BRD|C>UPGRADE`'s fifth guard — *"Blue Flag has more than 15 days remainig!"* —
**could not be reached while the bug stood**, because premium was always behind the clock. `SWP-G24`
now pins it, plus **the other branch of the clamp**: 20 days on (10 days left, under the threshold) a
renewal adds 30 days to the *stored* date, so the entity keeps its 10 days for 40 total. Without that,
the fix could drift into "always extend from now" — the mirror-image bug, confiscating remaining days.

**The bug had been written down as the rule.** `modules/ATS.repl <<ATS-BRD>>` asserted
`(add-time (at "genesis" b) (days 90))` with the comment *"<months> buys months measured from branding
genesis, not from now."* Accurate about the old code, and that is exactly why it survived — an
assertion that restates what the code does, with a comment rationalising it, **converts a defect into a
requirement**. A test earns the right to state a rule only once somebody has checked the rule is
intended.

### THE MESSAGE-CONSTRUCTION FAMILY IS NOW THREE VARIANTS, ALL FIXED, ALL DETECTED

| shape | what the caller gets | sites | detector (all must stay at 0) |
|---|---|---|---|
| `("…{}" [args])` — `format` missing | `Cannot apply value to non-closure` | 1, fixed | `enforce-msg-not-format` |
| `(format "…")` — arg list missing | `Expected Pact Value, got closure` | 5, fixed | `format-no-arglist` |
| `"…{}…"` — bare template, no call | **the braces, printed literally** | 1, fixed | `enforce-msg-bare-template` |

The first two **abort**; the third fails **safe and silent**, which is why it survived longest. All three are
false-positive-free — a `{}` in a string that is never formatted is never intentional, and a one-argument
`format` is never correct. That is the profile that justifies shipping a rule, against the three declined
this session for noise (cross-module-scan, eager-let at 182 hits, `enumerate 0 -1` at 244).

The third variant was `11_VST.pact:659` (`ATSU|C>BRUMATE`), fixed with the `format` call plus the `andfor`
run-together; its sibling at `:646` said *"Hibernation turned of"*, corrected in the same pass. **Both are
spelling, not meaning** — the semantically wrong message found the same day (fuel-index *"negative Index"*
for a bound of `0.1`) was left for the owner precisely because it is a different kind of change.

**The scan for it returned a confident 0 on the first try**, on an instance already reproduced by hand:
`_pactlex.split_top` splits on top-level FORMS and discards bare string tokens. Second time this trap has
been hit (`enforce-msg-not-format` fell into it via `strip` blanking string bodies). **Reproduce first, then
scan** — both times, having the instance in hand is the only reason the 0 was read as a bug.

### (earlier that day) `(format "…")` with no argument list

Pact's `format` takes a template **and** a list. Given one argument it is an arity error that resolves
to a **closure**, and the caller dies with `Expected Pact Value, got closure or table reference`.

**The mirror of `enforce-msg-not-format`, and strictly worse** — that one is hidden by `enforce`'s lazy
message until the guard fires; this one also sits on **success paths**, where the function does not
lose a message, **it aborts**:

| site | context |
|---|---|
| `08_ATS.pact:883` | `ATS\|C>ADD-HOT-RBT` enforce message (guard fired, then died on its own message) |
| `12_LIQUID.pact:125` | migration pause-gate message |
| `03_DSP+.pact:360` | **return value** for "nothing to mint" — success path |
| `01_DPL-UR.pact:2430` | **UI stage text** after the KPay sale ends — success path |
| `02_INFO-ONE+.pact:2465` | `INFO_ATS\|Cull`'s description — **broken for every input, always** |

All five **FIXED** (owner-authorised class). None of the templates had a `{}`, so the repair is to drop
`format`. A previous session had already diagnosed all five and proposed `[]`; dropping the call
removes the hazard instead of patching it. `INFO_ATS|Cull` was unpriceable by any client until now.

**A second defect that the first one hid.** `12_LIQUID.pact:125` enforced `gap` — pause **ON** — while
its sentence said **"offline"**. Five sites elsewhere use "online" for pause-on, so the convention was
unambiguous and this line was the odd one out. Corrected. **A message that never renders cannot be
noticed to be wrong** — which is the general hazard with message-construction bugs.

**New detector: `_conformance.py --rule format-no-arglist`, must stay at 0.** It found **two sites a
grep missed** (`00_DPMF:641/:645`, templates wrapping across lines with `\`-continuation) — *structure
beats regex whenever the thing you are matching can wrap*. Those two are a worse shape (a `{}` **and**
no args, so dropping `format` would print the brace) and are deliberately left: DPMF is dead, and
guessing the forgotten argument there is churn. Three synthetic selftest cases added.

### NEW FINDING (behaviour change, needs your call): the Hot-RBT prefix exclusion has a hole

`ATS|C>ADD-HOT-RBT`'s comment states the rule — *"Hot-RBT cannot be V|, Z| or H| -Tokens"* — but the
code tests `(contains hot-rbt-ftc ["V|" "Z|" "H"])` where `hot-rbt-ftc` is `(take 2 hot-rbt)`, **always
two characters**. The third entry is one character, so `"H|"` never matches: **hibernation tokens are
not excluded.** A zero-supply `H|` token would be accepted as a Hot-RBT.

Measured through the real client: an `H|` token falls through to the *next* guard and is caught only
because that particular token's supply happens to be non-zero. Pinned as-behaves by `<<ATS-G15>>`,
including the list-membership computation itself. **`"H"` → `"H|"` changes what the function ACCEPTS,
so unlike the message repairs it is a behaviour change and waits on you.**

### NEW FINDING (needs your call): the bulk-transfer shape guard is mute in two of three directions

A **fourth live instance of the `enumerate 0 -1` gotcha**, and the first where the consequence is a
**silenced guard in a supported client path**.

`DPDC-T|C>BULK-TRANSFER`'s cap is written correctly — nothing indexes before its enforce. But the Talos
wrapper `TS02-C1::DPDC|C_BulkTransfer` derives helper lists in an eager `let` **before** calling the core:

```pact
(ids:[string] (map (lambda (idx) id) (enumerate 0 (- l 1))))
```

For `l = 0` that is `(enumerate 0 -1)` → **`[0, -1]`**, so an empty receiver list produces TWO ids, the
royalty collector indexes past the one-element arrays, and the caller gets `Array index out of bounds`.

Measured, not inferred:

| input | what answers |
|---|---|
| **empty** receiver list | index fault — `(> l 0)` never runs |
| **more receivers** than nonce legs | index fault — same cause |
| **more nonce legs** than receivers | the written message **arrives** |

That asymmetry is what makes it a defect rather than a dead guard. **The fix is one module over and is
purely ORDER:** `TS01-C1::DPOF|C_BulkTransfer` uses the identical idiom and is not mute, because it calls
the core **first** and maps **afterwards** (its working behaviour is pinned by `DPOF-G12`). Proposed: move
the `ids`/`sons`/`irs` bindings below the core call. Reorders a paid client, so it waits on you.
`2026-09-11-enumerate-counts-down.md` (extended).

**No detector added, deliberately:** the idiom appears **244 times**, almost all on paths where the list
is guaranteed non-empty. That is the third detector declined on signal-to-noise grounds this session
(cross-module-scan kept as an observation, eager-let at 182 hits, this at 244) — the rule I *did* ship,
`format-no-arglist`, had 7 hits and zero false positives. **The difference is whether the syntax alone
settles it.**

### NEW FINDING (needs your call): `C_Slumber` mints a nonce `C_Unsleep` cannot read

Two operations write **different metadata shapes** into the same column of the same token:

| minted by | `meta-data-chain` |
|---|---|
| `C_Sleep` | `[{"release-amount": …, "release-date": …}]` |
| `C_Slumber` (merge) | `[{"mint-time": …, "release-date": …}]` |

`VST|MetaDataSchema` is the first shape, so a slumber-merged row fails Pact's **runtime typecheck** on
the way into `VST|C_Unsleep` — before any `enforce` is consulted:

```
Runtime typecheck failure, argument is list , but expected type
list (object{ouronet-ns.VestingV2.VST|MetaDataSchema})
```

`mint-time` is HIBERNATION metadata — the downstream cost of what `VST-08` already records (*"SLUMBER
is the HIBERNATION merge, not the sleeping one"*). **Consequence:** `Z|MOCKA` nonce 3, minted by
`C_Slumber` in `VST-07`, is in circulation, held by a real account, and **permanently un-unsleepable**.
Not timing — it fails at the suite's clock and a rewound one alike, both pinned. The holder's only exit
is `RepurposeSlumber`.

Two candidate fixes, **both behavioural**: `C_Slumber` writes `release-amount` for a sleeping token
(narrower, and what the data model implies), or the unsleep path accepts both shapes (wider, and spreads
the dual-shape assumption). `2026-09-12-slumber-mints-an-unsleepable-nonce.md`.

**How it was found, because the habit is the transferable part:** `VST-G7` needed a *live* sleeping
nonce and picked the first with a positive supply **at runtime** rather than hardcoding one. That landed
on nonce 3. A hardcoded nonce that happened to work would have hidden this entirely — and the same habit
had already caught nonce 1 of that token being out of circulation. **Choosing fixture rows by predicate
instead of by literal is worth the extra line.**

### ONE MORE WORDING FINDING, and it was already documented in the source

`ATSU|C>FUEL` (`10_ATSU.pact:395`) enforces `(>= index 0.1)` under the message *"Fueling cannot take
place on a negative Index"*. The source **already carried a note** that the message is narrower than
the check — the bound is 0.1, not 0 — and **nothing was testing that note**. `ATS-G17` now drives both
states, because they are reached differently and only one is honest:

- **index = -1.0** — `URC_Index`'s sentinel for "this pair has no RBT supply at all". The message is
  accurate; the index really is negative.
- **index = 0.05** — a live pair whose resident sum is small next to its RBT supply. The index is
  **positive** and the caller is still told it is negative.

Message-only (the guard blocks correctly either way), but it is a **client-visible string**, so unlike
today's repairs this is a wording decision rather than a defect fix. Proposed: *"Fueling requires an
Index of at least 0.1"*. **Not applied.**

Worth noting as a pattern: a source comment that records a defect is not coverage. Three times today a
previous session's accurate note sat next to code nothing exercised — the fuel bound here, the
one-argument `format` list, and the `ADD-QUANTITY` hoist. **If a note is worth writing, it is worth an
assertion, or the next reader has to re-derive it.**

### HOST A CITIZEN MODULE'S TESTS WHERE IT DEPLOYS CHEAPEST, NOT WHERE IT CONCEPTUALLY BELONGS

Several citizen modules have **no harness of their own** — `KBN` (Bunnies minter), `DSP` (the Stage-Z
dispenser automaton), `DEMIPAD-STOICPAY`. Their remaining guards are all argument-domain, so they need
nothing but a chain where the module is *deployed*:

| guard | hosted in | why |
|---|---|---|
| `KBN::C_Spawn` position parity | `modules/DPDC.repl` (26s) | `deploy-stage02` deploys KBN, and it mints DPNF |
| `DSP\|STOICISM-MINTER` list parity | `modules/STAGE-Z.repl` | the cheapest file that deploys DSP |
| `DEMIPAD-STOICPAY::URv_PeriodAllocation` | `modules/STOAICO.repl` (21s) | `[6.3]_STOAICO` deploys it |

The alternative homes (the Kursan AQP suites, `modules/LAUNCHPAD.repl` at 174s) cost 2–7× the wall time
for identical assertions. **Find the cheapest harness that DEPLOYS the module**; say so in the test so
the placement does not read as arbitrary.

Also worth noting from this batch: **a `URv_`/`UDC_` guard is the cheapest thing in the worklist.** Both
are unprotected and directly callable, so pinning one is a single call with no signer and no state —
`URv_GetVerumChain` and `URv_PeriodAllocation` each took one line. Scan for those prefixes first.

### THE MUTE-GUARD CLASS HAS A SECOND SUB-SHAPE, and it is the one an audit would miss

Nine instances are **sub-shape A**: an eager `let` above the `enforce` reads a table with the value the
guard was supposed to reject. Findable by reading the `let`.

**Sub-shape B** (new, `04_RPS.pact:2956`) is inside the `enforce` itself:

```pact
(enforce (fold (and) true
    [(!= multiplet-family-id BAR)                      ;; the cheap check IS first
     (URC_MultipletFamilyExists multiplet-family-id)
     (UR_FVT-MF|Active multiplet-family-id) …])        ;; …and this hard-reads it anyway
    "MULTIPLET_BASE reward requires active MultipletFamily …")
```

Pass `BAR` — the case the first conjunct exists to catch — and the caller gets
`No value found in table … for key: |`. **`fold (and)` does not short-circuit**, so being right early
saves nothing.

This matters more than its severity: the code *looks* correct, the cheap check IS first, the ordering IS
right. Anyone auditing for sub-shape A walks straight past it. Both underlying facts were already
documented here separately — *`fold (and)` is not short-circuiting* and *a hard `read` aborts on a missing
row*. Ten instances in, the general statement:

> **A guard cannot protect the expression that computes its own operands.** Whether they come from a `let`
> above it or a later conjunct beside it, they run first.

Bounded: mute only for `BAR`; every other way to fail that fold reaches the message (`GT-12 · 01` proves
it). Same one-line fix as the other eleven. `2026-09-12-eager-let-mute-guards.md`.

### NEW HARNESS `modules/AQP-LP.repl` — AQP on a chain that also has SWP pools

The fixture gap recorded below is now closed. Load order (the one `modules/STAGE-Z.repl` already proves):

    deploy-stage00 -> deploy-stage01 -> [6.2+3]_DPTF-SWP_Issuance-Only -> deploy-stage02 -> [6.2]_AQP

56.8s, and it carries **both** an SWP LP pair and the AQP score set — which no other harness did.
`UEV_LpStakeScoreContext` is pinned there (`AQPLP-G1`), with each of its three conjuncts asserted
individually, because one message covers all three and the refusal alone would not say which failed.

**AND IT NOW CARRIES THE SUITE'S FIRST CLASS-0 SCORE.** `modules/AQP.repl` has 37 scores and not one is
class 0 (measured) — class 0 is the LP/farm class, and several guards have nothing to say about anything
else. It turned out to be one client call, `AQP-SCR|C_IssueLiquidityScore`, and `AQPLP-G2` makes one and
keeps it (committed, not rolled back — it is a fixture, not a probe).

**That is the reusable part, and it compounded immediately.** `AQPLP-G3` adds the matching **class-0
POOL** (one more client call, `AQP-POOL|C_Issue … 0`, anchored on the same LP token) and pins
`03_AQP:2312` — the class-0 lp-denominator rule, which needed a class-0 score AND a class-0 pool AND an
SWP pair on one chain. Three fixtures, none of which existed this morning; the guard itself was then one
assertion.

**A correction I should have caught earlier:** `Kursan/dsa-grand-tour.repl` ALREADY had class-0 scores
(`BronzeSnakePower`, `GoldenSnakePower`, both pool-linked to `DHOuroLp`) and a class-0 FVT (`GtVault`),
all owned by one account. I built `AQP-LP` to create a class-0 score without checking the richest
existing chain first. The file still earns its place -- it pins two guards that need an **SWP LP pair**
alongside AQP state, which the grand tour does not carry -- but **survey the heaviest existing fixture
before building a new one.** That is the same lesson as "check whether an existing test already builds
the state", applied one level up: check whether an existing *chain* does.

Both the score and the pool are **committed, not rolled back** — they are fixtures. The chain now carries:
an SWP LP pair, a class-0 score with a deliberately outside lp-denominator, and a class-0 pool anchored on
that LP. **THE RECIPE WORKED, AND TWO OF THE FOUR ARE NOW PINNED** (`GT-14`/`GT-15` in the grand tour):

  * `05_FVT:1890` "Farm score: lp-denominator and ghost weight required" — two client calls built a class-0
    score that is pool-linked but NOT FVT-linked (the conjunct that blocked the existing ones), and because
    its lp-denominator already matches the vault's common denominator, `ghost-weight 0.0` is the ONLY
    failing term. Positive contrast driven too, so it reads as a threshold rather than a blanket refusal.
  * `05_FVT:1873` "Non-mosaic FVT locked to score membership only" — two field writes (`mosaic`,
    `membership-mode`), then restored and asserted restored. The re-admission case is driven as well, which
    shows the guard reads the MODE and not the mosaic flag alone.

Writing the recipe down first was what made this cheap: the previous pass's measurements said exactly which
conjunct blocked each guard, so this pass was execution rather than exploration. **Two corrections it still
cost, both now in the file:** `URC_ResolveScoreEntitySwpair`'s first argument is the INTEGER
`CT_SCORE_ENTITY_SCORE` (1), not a string; and `mosaic`/`membership-mode` live in
`RPS.FVT|T|RewardAggregate`, not `FVT|T|RPS|Global` — writing to the wrong one fails with a schema mismatch
that **prints the expected schema**, which is a fast way to read a table's shape.

**BOTH TRIPLET TWINS ARE NOW CLOSED TOO (`GT-16`/`GT-17`) — and one of them was not a guard at all.**
`05_FVT:1957` ("Farm triplet: lp-denominator and ghost weight required") pinned cleanly in both
directions, as did a third the recipe turned up on the way, `02_SCORE:970` ("LP triplet requires
identical lp-denominator on all three scores").

`05_FVT:1948` **would not pin, because the message it is supposed to emit cannot be emitted.** Line
1954 writes a **three-argument `or`**, and Pact's `or` is binary; the whole expression raises
`"Attempted to apply a closure to too many arguments"`. It had never been evaluated in anger because
the enclosing `(or (UR_FVT|Mosaic fvt-id) <this>)` short-circuits and every FVT built so far is
mosaic. **Consequence: a non-mosaic FVT cannot admit a triplet at all** — the *admitting* modes fail
identically to the refusing one, which is how it was distinguished from a mute-message defect. The
two-argument SCORE twin at `:1873` is the contrast that isolates the arity as the cause. Pinned
as-behaves by GT-16.03 (three legs, including the restore-and-it-works leg that proves the
mechanism). Exactly **one** instance codebase-wide, so no detector.
`2026-09-12-binary-or-arity-break.md`.

The differences the recipe had to absorb, enumerated when these were still open:

  * the entity is a TRIPLET, so the swpair resolver takes `CT_SCORE_ENTITY_TRIPLET` (**3**) and resolves
    through the triplet's SILVER score's pool;
  * the refusing membership mode is the mirror of GT-14's;
  * the chain's only triplet is class 3, so a class-0 one must be built from three liquidity scores plus
    `UC_ComputeTripletId` — the same two client calls, three times.

Two things the fixture cost, worth knowing before repeating them:
  * score issuance is **STOA-priced** and settles as coin transfers, so the managed caps must be in scope
    or the call dies in `coin.TRANSFER` before the score exists;
  * the issuer bounds precision to [3,24] and requires **both** multipliers strictly positive, under one
    message covering eight conjuncts ("Invalid precision, score-class, mx-frozen, mx-sleeping,
    mx-hibernated or nft-score-model"). `0.0` was rejected; AQP-BOOT's Step 6 values (6, 2.0, 2.0) work.

**HONEST ARITHMETIC ON THE GATE NUMBER.** It went 18,508 -> 19,059, and **+538 of that +551 is
re-execution**: the new file loads `[6.2+3]` and `[6.2]_AQP`, whose assertions now run one more time.
Only **13 assertions were written**. Distinct went 3,861 -> 3,857 (it fell, because probe scaffolding was
deleted). A new loader always inflates the executed count; decompose before quoting it.

### (now closed) ONE GUARD THAT NEEDED A FIXTURE NO HARNESS BUILT

`02_SCORE.pact:2708` `UEV_LpStakeScoreContext` is unprotected and directly callable, and its argument side
is free: `(= (UR_SCR|ScoreClass score-id) 0)` fails for **every** score on the AQP chain, because none of
the 37 scores is class 0 (measured). What blocks it is upstream of the conjuncts —

```pact
(swpair:string (ref-SWP::UR_GetLpSwpair native-lp))   ;; hard read of SWP|LP
```

— and **this chain has no SWP LP pairs at all**, so any `lp-id` dies in the `let` first:
`No value found in table ouronet-ns.SWP_SWP|LP for key: S|DLK-…`.

**What it would take:** one chain carrying BOTH an SWP LP pair and an AQP score. No harness builds both —
`modules/SWP.repl` has the pools but not Stage-02; `modules/AQP.repl` has the scores but no pools. Cheapest
route is a new loader with `[6.2+3]_DPTF-SWP_Issuance-Only` ahead of `[6.2]_AQP`, then point a class-0
score's lp-denominator at a token of that pair.

Recorded in `modules/AQP.repl` rather than left as a bare worklist entry, because *"needs a fixture"* is not
the useful part — **which** fixture, and why the obvious argument-only attempt fails, is. That is the
difference between an entry the next pass can act on and one it has to re-derive.

**Cost note, honestly:** this one took four probe cycles on a 62-second harness to establish a negative.
The AQP/FVT side is where per-guard cost stops being worth it one at a time; the remaining six `UEV_`
context guards there are chained behind interlocking enforces (score-owner = FVT-owner, membership mode,
link rows, class matching) and want a coherent multi-row fixture built once and reused, not probed
individually.

### TWO MORE PROVEN UNREACHABLE — and one suspected defect that turned out fine

`03_DPDC-C.pact:279` and `:282` (the SFT-set and NFT amount branches of `REGISTER-NONCES`) are
**unreachable by construction**, and the proof is now recorded in `modules/DPDC.repl` rather than leaving
two worklist entries reading as "needs a fixture". `C_CreateNewNonce` has exactly four call sites:

| site | `son` | `amount` | `sft-set-mode` |
|---|---|---|---|
| `TS02-C1:450` (DPSF) | true | caller-supplied | **false** |
| `TS02-C2:397` (DPNF) | false | **literal 1** | false |
| `08_DPDC-S:1345` (NFT set) | **false** (inside `C_MakeNonFungibleSet`) | literal 1 | true |
| `11_EQUITY+:732` | — | multi form, cap hardcodes `sft-set-mode` false | |

So `:282` needs `son=false` with `amount != 1` (both such callers pass the literal 1), and `:279` needs
`son=true` **and** `sft-set-mode=true` — a combination no caller passes.

**I went looking for a defect here and there isn't one.** `DPDC-S:1345` passes `amount = 1` with
`sft-set-mode = true`, which against `(= amount 0)` looked like a broken SFT-set path. It is not: `son` is
false at that site, and the real SFT set path (`C_MakeSemiFungibleSet`) never calls this function at all —
it credits an already-existing set nonce via `XB_CreditSFT-Nonce`. Checking the enclosing defun before
reporting is what turned a finding into a proof.

Generalising what `DPDC-G8` already said: **a guard's reachability is a property of its call sites, not of
the guard.** Proposed: annotate both `;;UNREACHABLE`, as 19 other proven sites already are.

### A MISTAKE OF MINE — never `git checkout --` in this tree

To undo a test edit I no longer needed I ran `git checkout -- "REPL/Stage_01/[6.6]_ATS.repl"`. This
repo has **extensive uncommitted work**, and that file was among it: the checkout discarded an unstaged
rename from a previous session (`ATS::URC_RTSplitAmounts` → `URCv_RTSplitAmounts`, 4 occurrences).
Unstaged changes are not in git objects — `git fsck --lost-found` had nothing.

Recovered by static analysis, not guesswork: extract every `ref-MOD::FUNC` / `MOD.FUNC` reference in
the file, resolve aliases from its own `let` bindings, check each against the current `.pact` sources.
Exactly four stale references; three were commented out, the fourth was the lost rename, and
`git diff` on `08_ATS.pact` gave the new name. Gate green after, so nothing else was lost.

**Rule: use a targeted reverse edit, never `checkout`, to undo your own change here.** The blast radius
of `checkout` is the whole file.

### (original write-up) the branding premium defect, as found

`04_BRD.pact` has two defects that compound, and the second one costs real STOA.

1. **`BRD|DEFAULT` (:197) is a `defconst` holding `(at "block-time" (chain-data))`.** A `defconst`
   evaluates ONCE, at module load — so `genesis` and `premium-until` are **BRD's own deploy
   timestamp**, shared by every entity `XE_Issue` ever creates. `genesis` is therefore useless as a
   birth date, and **every never-upgraded entity starts with premium already lapsed**.
2. **`XE_UpgradeBranding` (:442) extends from the STORED premium-until, never from now**
   (`(add-time premium seconds)`). Correct for a live subscription; wrong for a lapsed one — which by
   (1) is every entity. Measured through the real client: paying for one month advances premium-until
   by exactly 30 days and **leaves it in the past**, while setting the flag to **1 (BLUE)**. A second
   and third paid upgrade are both ALLOWED. The STOA is really spent (two `coin.TRANSFER` legs,
   ≈19.1 + ≈57.4).

Fix shapes are one expression each (clamp the base to `current`, which is already bound; and move the
two timestamps into `XE_Issue`). **Neither is a free repair** — both change what a paid call does — so
both wait on you. Pinned as-behaves by `SWP-G24`, which asserts each step so the fix verifies itself.
`2026-09-12-branding-premium-paid-for-elapsed-time.md`.

This also **explains a coverage gap honestly**: BRD's fifth guard, *"Blue Flag has more than 15 days
remainig!"*, cannot be reached while (2) stands — premium is always behind the clock, so `remaining` is
negative and the guard always passes. It is unpinned because of a defect, not a missing fixture.

**Method note worth keeping:** this surfaced because the test asserted *the state the fixture was
supposed to have created*, not just the outcome it was after. Going straight for the refusal would have
shown the upgrade "working" and recorded the guard as needing a fixture.

### NEW FINDING: two more MUTE guards, and the pattern now has six instances

`10_ATSU.pact`'s `ATSU|C>REDEEM` (:521) and `ATS|C>RECOVER` (:508) both carry `"Invalid Hot-RBT"`, and
**neither can ever reach a caller.** Both bind `(ats (UR_RewardBearingToken id))` and then, in the
SAME eager `let`, read an ATS pair with it — so for a non-RBT the lookup on key `|` aborts before the
capability is acquired. The caller sees `No value found in table ouronet-ns.ATS_ATS|Pairs for key: |`.

That makes **six confirmed instances of one pattern**: the guard's own subject bound above it in an
eager `let` (OUROBOROS::UEV_Exchange ×2, these two, PYTHIA, FVT, DALOS::GAS_PAYER, SCORE triplet).
Pinned as-behaves by `ATS-G14`, which also asserts the *absence* of the intended message so the
assertion flips when the binding moves. Not applied — moving a binding is behaviour, not wording.
`2026-09-12-eager-let-mute-guards.md`.

**A detector for it was prototyped and deliberately NOT shipped:** the obvious formulation measures
**182 hits**, nearly all benign (chaining off `UR_OuroborosID` and friends, which are always set), and
it *missed* the two instances that motivated it. A rule at that signal-to-noise gets read once and then
ignored — worse than no rule, the same reason `admin-gate-terminal` is not extended to `C_`. Left as a
review checklist item: *reading a `let` group, ask of each binding — if the previous one returned its
sentinel, what happens on this line?*

### NEW FINDING (message-only, not applied): `E-ANK` is an object, not a label

All 7 ANK rejection messages open with `{"anchor-id": "|","ouronet-account": "|","promile": 0.0}`,
because `E-ANK` is the **blank-anchor row constructor**, not a label string. ANK has no label
constant; DPOF's `OF` = `"Orto-Fungible"` is the shape that was intended. Fails safe, pinned both ways
by `AQP-G35`, so the repair verifies itself. `2026-09-12-ank-label-constant-is-an-object.md`.

**How all three message defects this week were found:** by driving a guard to failure and *reading
what it actually says*. The message is code too, and it is the one part of a guard that no passing
test ever executes.

### THE TECHNIQUE THAT CAME OUT OF IT — use it on the remaining worklist

`env-module-admin <MOD>` grants another module's admin **inside a REPL**, so a guard whose input no
legitimate flow produces can still be pinned: write the state directly, assert, `rollback-tx`, then a
separate transaction that proves nothing leaked. Five guards today. Full write-up and its boundary
(it says nothing about production reachability) in `2026-09-12-state-driven-guard-coverage.md`.

### THE GATE WAS GREEN WHILE `_conformance.py` COULD NOT START

An edit left an unescaped quote in a rule description. `_conformance.py` raised `SyntaxError` on
import — and **the gate went GREEN twice** before anyone ran the tool, because no `_*.py` analysis
tool was exercised by the gate at all. A broken detector reports nothing, and nothing reads as clean.

Fixed: `_gate.py` now byte-compiles every `_*.py` and runs `--selftest` on the ones that have it,
before running a single REPL. Mutation-verified both ways (broken tool → exit 1, clean → exit 0).
**If you add a tool, give it a `--selftest`** — the gate will pick it up by itself.

### …and the scratch-loader guard only covered half the globbed directories

It checked `modules/_*.repl`. `Kursan/` is globbed into the gate too, and a probe dropped there sat
outside the guard entirely — found by doing exactly that. Kursan's own underscore files follow one
convention (`_verify_finding_*`), so the guard now treats any other `Kursan/_*.repl` as scratch.
Verified against a live leftover: it names the probe and leaves all 20+ `_verify_finding_*` files
alone. The orphan check would eventually have caught an *asserting* leftover, but with a message about
reachability rather than "you forgot to delete this", and only after a full scan.

**Convention, now enforced in both places:** a throwaway loader is `_`-prefixed, lives in `modules/`
or `Kursan/`, and is deleted before a gate run.

---

# Original handoff (2026-09-11, rev 2) follows, corrected in place

## READ THIS BEFORE QUOTING THE ASSERTION NUMBER

`_gate.py`'s headline counts assertions **EXECUTED**, not assertions written. Shared files run once
per entrypoint that loads them, so one new assertion in `Stage_01/[6.11]_INFO.repl` shows up ~35
times in the total. Adding 9 INFO previews moved the headline by **345**.

- **executions** (the gate headline): **18,229**
- **distinct assertions written**: **3,565** — `grep -rhoE "\(expect(-failure)?\b" --include=*.repl . | wc -l`

Both are real; they answer different questions. Quote the second when someone asks "how many tests
are there", the first when asking "how much ran". A jump of +345 for 9 new tests is arithmetic, not
progress — always decompose a delta before publishing it.

## STATE  (numbers updated 2026-09-12)

Gate **GREEN — 19,074 executed / 3,875 distinct**. Conformance **VIOLATIONS: 0**, OBSERVATIONS 117.
Verify with: `cd REPL && python3 _gate.py` then `python3 _conformance.py`.

- guard pinning: **632/784 unambiguous (80%)**, 686 pinned overall (87%)
  **THE REAL REMAINING WORKLIST IS 74 (was 159 at the start of 2026-09-12), NOT 25.** `_enforce_coverage.py` prints it directly as
  "LIVE unpinned (the real worklist total)". I had been quoting `_cheapseam.py`'s ~25, which is a
  SUBSET: cheapseam only covers guards in PLAIN callable functions (`UEV_`/`URC_`/`UC_`/…). The
  other ~138 live unpinned guards sit in defcaps and protected bodies, which cheapseam does not
  scan. Both numbers are right for their own question; quoting the smaller one as "what's left"
  under-reports by ~6x.
  Decomposition of the 188 not-pinned: 25 in the DEAD `00_DPMF` module, leaving 163 live. The
  UNREACHABLE (40 enforce-one-nested), annotated (19), untestable-externally (3) and unmatchable
  (2) categories are already EXCLUDED from the 784 denominator -- they never enter the worklist.
  (Verified: the annotated `OUROBOROS:603` is absent from `--list`'s gap output; the `:608` entry
  nearby is a different, genuinely unpinned enforce in the same function.) — `python3 _enforce_coverage.py`
- function reach: **3,216/4,497 (71%)** — `python3 _scale_report.py`
- orphan check clean — `python3 _gate.py --audit-only`

### Conformance: 1 violation, 117 observations (both cross-module-scan and the `format` bug closed)

**`enforce-msg-not-format` — FIXED 2026-09-12, owner-authorised** (*"if an enforce is missing its
string (format outputs a string), you should just add it"*). `SWP|S>RT_OWN` (`15_SWP.pact:466`) wrote
its `enforce` message as a bare `("...{}" [args])`, so a tier rejection surfaced as `Cannot apply
value to non-closure` instead of its own sentence. `format` added; the rule is now a **regression
detector that must stay at 0**, and `SWP-G21` flipped from pinning the internal error to pinning the
repaired message (`"Insufficient Major Elite Tier for NewOwner"`). See
`2026-09-11-enforce-message-missing-format.md`, including why that rule first reported a clean 0
against a defect already reproduced.

**`cross-module-scan` — WITHDRAWN as a violation 2026-09-12, now an OBSERVATION.** Owner ruling:
*"keys can be called freely, there is no admin gating on this."* I had the 10 sites filed as a
runtime-fatal defect class — *"six UI readers uncallable on any chain"* — and that was **wrong**. The
aborts are real but **transactional-mode-only**, and a **REPL is always transactional**; nodes run
`--allowReadsInLocal` (verified on this project's own nodes) so `/local` reads are unrestricted, and
`/local` is how UI readers are invoked. All six readers have **ZERO callers in Pact code**. The rule
is kept as a **watch list**: a function with a cross-module scan cannot be called from a transaction,
so if one ever acquires a `C_`/`A_` caller it becomes a real defect at that moment. Full account:
`2026-09-11-stage-z-cross-module-keys.md`; the fix proposal is withdrawn.

**Lesson worth more than the finding was:** an error reproduced in a REPL is an error *in a REPL*.
Before calling it a production defect, establish that production runs in the same execution mode the
test used — and check whether anything calls the function at all. Both checks are cheap.

## WHAT THE OWNER'S VARIANT RULING TURNED UP  ← read this first

The ruling was *"We'd use a variant for testing with the testing IDs."* Done — but the interesting
part is what it exposed.

`REPL/_stagez_variant.py` **generates** a testing variant from canonical (it does not check in a
copy — a copy rots; a generated file cannot, because `--check` is wired into `_gate.py` and fails
the gate the moment canonical moves). Canonical was not touched.

Removing the id blocker revealed a **second property underneath it**, which the eager `let` had been
hiding: six Stage-Z UI readers call `keys` on *other modules'* tables. Because `let` is eager, the id
error fired first and the investigation always stopped there. **The hardcoded mainnet ids are a real
portability defect; the scans are not a defect at all** — see the conformance section above for the
withdrawal. Worth keeping for the method: clearing one blocker to see what is behind it is the right
move, and the variant is what made it possible without touching canonical.

**No decision needed from the owner. The proposal is withdrawn** — nothing should be changed at
those 10 sites.

Two facts established by execution in that investigation, both durable and both still useful:
1. **No interface bump, no cascade** if a transactional scan is ever genuinely needed. A module-only
   `URH_` is directly callable cross-module — `(DALOS.URH_AccountCounter)` from outside DALOS works,
   and it is declared in no interface. Pinned by `STAGEZ-05`.
2. **`keys` costs a FLAT 40,009 gas**, not per-row (measured at 10/100/400/1000 rows). I had
   hypothesised linear scaling; wrong. At 144x a point read, `DPL-UR::URC_0021_CollectablesHeader`
   does FOUR scans = ~160k gas, over Kadena's 150k per-tx limit on its own. **This is the real reason
   these readers belong on `/local`**: even with no admin involved they could not fit in a
   transaction. Pinned by `STAGEZ-17`; see `2026-09-11-scan-gas-budget.md`.

## OTHER OPEN THREADS (no decision needed)

1. **INFO cost integrity — widen.** 358 `INFO_` functions; **33** carry the invariant (was 24).
   The batch now spans full costs 2 -> 1362, so a discount applied as a constant instead of a
   multiplier can no longer hide. Extending = one
   line per preview in the `cis` list in `REPL/Stage_01/[6.11]_INFO.repl` (`TX-I-COST`). Mechanical.
2. **DPL-UR readers — LARGELY UNBLOCKED (63 -> 35 unreached).** The cause was never the code: the
   Stage-Z chain simply had no SWP pools, so 13 swpair-taking readers could not be called at all.
   `modules/STAGE-Z.repl` now loads `[6.2+3]_DPTF-SWP_Issuance-Only.repl` -- the CHEAP path, measured
   at ~8s for the whole load, versus the full `[6.3]_SWP` suite. Two guards fell out of it
   (`STAGEZ-18`) plus real reader coverage (`STAGEZ-19`). **If a module's readers look untestable,
   check whether the chain is simply missing the entity they read** before concluding anything
   about the code.
3. **(older note) DPL-UR's remaining unreached readers.** ~45 left. They are NOT blocked — nothing had ever
   called them. `STAGEZ-07..13` did the easy ones; the rest are the same shape of work. Probe
   first (`modules/` scratch file, delete it after — `_gate.py` globs `modules/*.repl`).
   Four are blocked by genuine missing fixtures, confirmed by execution, not guessed:
   `URC_0002_PrimordialsSingle` + `URC_PrimordialPrices` need SWP pools; `URC_0030_StoicPay` needs
   a `KPAY|T|Properties` row; `URC_0013_StoaICO` needs the `StoaIcoInformation` singleton (STOAICO
   *does* ship an `insert` for it — it is a fixture gap, not an uninitialised-table defect).
3. **Index-fault sweep — SUBSTANTIALLY DONE, read the memory before continuing.**
   `2026-09-11-enumerate-counts-down.md`. The sweep's conclusion is a CONVENTION, not a defect list:
   *the client checks non-empty; the internal predicates assume it*. Most of the 92
   `(enumerate 0 (- n 1))` sites are shielded by it. **THREE** places break it, and those are the
   real defects — all pinned in
   `Kursan/_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl`:
   `ATSU::URCi_WithdrawRoyalties` (internal empty list, preview unguarded),
   `DPDC-T` bulk transfer (client unguarded too),
   `U|ATS::UEV_CRF|FeeArray` (guards empty, not length-mismatch).
   Detectors: `python3 _foldeager.py` `[index]` (4 sites) and grep for the enumerate idiom.
   **Do not report the 92-site inventory as 92 defects.** If continuing: call a list-taking
   internal predicate with `[]`, then its client with `[]`, and compare — the PAIR is the finding.
   See `2026-09-11-enumerate-counts-down.md`. It remains a review list, NOT a bug list; do not
   report 92 defects.
4. **Scan-gas budget — checked, clean.** `2026-09-11-scan-gas-budget.md`. A table scan costs
   ~40,000 gas FLAT (`keys`/`select`/`fold-db` alike); Kadena's per-tx limit is 150,000, so three
   is the ceiling. `python3 _heavy.py` `[scan-budget]` lists entrypoints reaching 4+ heavy readers.
   Its two current hits (`CC_FullVacate` + wrapper) were MEASURED at 43,187 gas and cleared — a
   static upper bound overstating by 10x. **Do not re-investigate those two; a THIRD entry is new.**
   Guarded by `AQP-VAC-GAS` in `modules/AQP.repl` and `STAGEZ-17` in `modules/STAGE-Z.repl`.
5. **@doc AUTHORITY claims — CLOSED, all 15 verified** (was reported as 7; see the CORRECTION). `python3 _docclaims.py`, see
   `2026-09-11-doc-claims-audit.md`. 7 authority claims exist; only 2 are now pinned. The pattern
   One was FALSE and already fixed (`ORBR|A_Fuel`), one was already tested (`FVT|C>UNSTALE-ALL` —
   a tool false positive: a DEFCAP is never named by a test, it is reached via its acquirer), and
   five were pinned this pass. `ATS|C_VestedCoil`'s doc is imprecise, not wrong — "Owner of
   <coil-token>" means HOLDER, not registrar-owner.
   **The tier was 7 only because my regex matched too few verbs.** "Can only be DONE by the Admin"
   was invisible. Widening it took 7 -> 15 and surfaced two unverified admin gates on STOAICO's
   money-moving vault mutators. Lesson written into the tool: prefer a false positive to a miss.
   **BOUND tier: audited.** 11 claims; most were already tested (`UEV_ScoreMultiplier`,
   `A_UpdateTreasuryDispoParameters`, the SWP issue family). `SWP|C_UpdateFee`'s 0.0001-320.0
   promile bound was NOT and is now pinned at both edges (`SWP-G20`), with the fee restored after.
   **IMMUTABLE tier: added and CLOSED (5).** None of the other three patterns matched "immutable"
   — a whole class was invisible. Two VST link types now pinned (`VST-G5`); `C_EnableDebBoost` is
   structurally irreversible (no disable function exists at all).
   **INVARIANT tier (74 claims) NOT audited** — mostly incidental prose using "always"/"never";
   expect a low hit rate and triage by reading before testing.
   **If adding a tier, check the pattern against a known example first.** Both of this tool's
   blind spots (narrow verbs, missing IMMUTABLE class) produced confident clean results.
6. **P3.3 residue** — `python3 _p33_classify.py`. Rate is 0-4 pins/pass; defect hunting has paid
   better. Do not push the number unless asked.
7. **Assertion strength — BOTH sides now audited, both closed.**
   * NEGATIVE: `python3 _expectfail.py`. 46 -> 35 weak; all 35 remaining are in UNGATED
     scratch/audit files. Every negative assertion the gate executes checks its message.
   * POSITIVE: `python3 _vacuous.py` (new). 2,601 sites, **VACUOUS 0** — every positive assertion
     can be made to fail. One real hit found and fixed (a self-comparison in `[2.1]_Dalos.repl`);
     6 WEAK remain and are all legitimate (sentinel bounds, acceptance checks) — documented in the
     tool so they are not "fixed" later. See `2026-09-11-vacuous-assertions.md`.
   * Neither tool catches an expectation computed by the code under test. **Mutation-test anything
     that matters**: break the expectation, confirm red, restore.
8. **(old) Weak `expect-failure`s — CLOSED for anything that runs.** 46 -> 35, and all 35 remaining sit in
   UNGATED scratch/audit files (`_audit_ats_baseline.repl` has 18 of them). **Every negative
   assertion the gate actually executes now checks its message.** `python3 _expectfail.py` re-checks;
   `python3 _tighten.py <file> --apply` harvests the real message, and only works where a gate
   entrypoint loads the file. If those scratch files are ever gated, tighten them in the same pass.

## OPEN DEFECTS — the three that were here are closed; three new ones found since.

**ZERO behaviour decisions remain open.** All four were ruled and applied on 2026-09-12:

| # | defect | ruling | applied |
|---|---|---|---|
| 1 | mute-guard class (12 sites) | *"make each one succeed to either false or true"* — `with-default-read` | **1 of 12 done** (`00_Demipad`); 11 remain, reader-side where a row is missing, call-site sentinel check where the key is `BAR` |
| 2 | 3-argument `or`, `05_FVT` | *"instead use fold construction using or over false"* | **DONE** |
| 3 | `C_Slumber` un-unsleepable nonce | kind guards on the two MINTING caps | **DONE** — the stranded 200.0 now releases |
| 4 | Hot-RBT `"H"` → `"H|"` | trivial typo, apply | **DONE** |

**Only a wording call is left:** `10_ATSU.pact:395` says *"negative Index"* for a bound of `0.1`.

## STANDING AUTONOMY THRESHOLD (set by the owner 2026-09-12)

> *"If you find bugs like this you are sure are fixing properly ... fix them if you know you are able
> to apply the correct fix."*

**Apply without asking** when the correct fix is not a choice: the intent is stated in a comment or
`@doc` directly above the code, an in-repo convention settles it, or the fix is provable (an arity
error, a one-character prefix typo). Report what was changed and why.

**Still ask** when the fix requires picking between defensible alternatives, changes a product
decision, or would restrict something currently permitted in a way a holder could feel. `C_Slumber`
was rightly asked about — the first diagnosis was wrong, and applying it would have broken the
hibernation path.

The `"H"` → `"H|"` fix should NOT have been escalated. Owner: *"why the fuck didn't you do it alone."*

Worth keeping the record of how each closed, because two of the three closed by being **wrong**, and
in both cases the error was the same one: reporting a state the REPL could reach as a state
production is in.

- ~~**`LIQUID::UEV_IzLiquidStakingLive` reports LIVE when liquid staking is NOT live**~~ --
  **RE-FRAMED 2026-09-12, not a defect.** Owner: *"liquid staking is live on mainnet, i dont know
  what you mean by saying it without an ATS pair?"* What I measured was the **boot window** of
  `[4.0]`, between the tx that sets the two STOA ids and the tx that creates the pair. On the
  deployed chain the pair exists and the guard is true *because liquid staking is live*; it also
  correctly refuses all three misconfigurations that have a pair. Pairs are not deleted, so mainnet
  cannot re-enter the window. What remains: `UR_RewardToken` returns a ONE-element `[BAR]` for "no
  pair", so `(= (length …) 1)` cannot tell "one pair" from "none" -- a **boot-robustness gap**, with
  a one-expression in-repo precedent if ever wanted (`DPOF::UEV_MoveRoleCheck` normalises the same
  sentinel: `(if (and (= lvf 1) (= verum-five [BAR])) 0 lvf)`).
  **And the "unpinnable" claim was wrong too, which is the part that paid:** `env-module-admin`
  grants DPTF admin in a REPL, so the role fields can be driven to any state and `rollback-tx`
  discards it. `<<LQD-G1>>` now pins **all three previously-unreachable deep guards** with their
  exact messages, and `<<LQD-G2>>` proves nothing leaked.
  `2026-09-11-liquid-staking-liveness-sentinel.md`.
- ~~**Branding premium paid for elapsed time**~~ -- **FIXED 2026-09-12, owner-authorised.** Both sites
  in `04_BRD.pact`; `SWP-G24` pins the fixed behaviour and BRD is fully covered (5/5 guards).
  `2026-09-12-branding-premium-paid-for-elapsed-time.md`.
- **Two MUTE "Invalid Hot-RBT" guards** (NEW 2026-09-12, ordering) -- `10_ATSU.pact:508` and `:521`.
  Pinned as-behaves by `ATS-G14`. `2026-09-12-eager-let-mute-guards.md`.
- **AQP-BOOT steps 6 and 7 are MUTE for a SHORT id list** (NEW 2026-09-12, ordering) --
  `04_AQP-BOOT.pact:487` and `:601-604`, six operator-facing messages that only arrive when the list is
  too LONG; a short list raises an unrecoverable native index fault. `C_Step9` in the same file is the
  correctly-ordered twin, so the fix is demonstrated in place. Pinned by `DPDC-G10`.
- ~~**A three-argument `or` makes non-mosaic triplet admission impossible**~~ -- **FIXED 2026-09-12,
  owner-ruled** (*"triple or or multiple or is not allowed. instead use fold construction using or
  over false"*). `05_FVT.pact`, `UEV_AddScoreEntityTripletContext`. The original defect: Pact's
  `or` is binary; three arguments raises `"Attempted to apply a closure to too many arguments"`. The
  outer `(or mosaic <this>)` short-circuits, so it has never been evaluated on a mosaic vault -- and
  every FVT built so far is mosaic. **The admitting modes fail exactly like the refusing one**, which
  is what makes this a break rather than a bad message: no non-mosaic FVT can admit a triplet in ANY
  mode. The legal two-argument twin at `:1873` works, isolating the arity as the cause. Fix is to
  `(fold (or) false [...])`, the `or` analogue of CLAUDE.md's 3+ boolean rule; **two such sites already
  existed in the same module**, so the ruling matched practice. GT-16.03 now drives all FOUR membership
  modes plus the mosaic short-circuit. **Exactly one instance codebase-wide**, so no detector was added.
  `2026-09-12-binary-or-arity-break.md`.
- **The launchpad DEPOSIT registration message is mute** (NEW 2026-09-12, ordering) --
  `00_Demipad.pact:513`. **The clearest instance of the twelve, because the fix is already in the
  module three lines up:** `UR_CheckRegistration` deliberately wraps its `with-read` in
  `(try false ...)` so a missing row answers "not registered" safely -- and the guard uses it. But
  three SIBLING reads of the same row (`UR_OpenForBusiness`, `UR_IzSSTOA`, `UR_IzOURO`) sit in the
  same eager `let`, are bare `read`s, and abort first. So this is not a design question about the
  guard; it is three readers out of step with a fourth in the same expression. Not a funds hole --
  the deposit is refused either way -- but the likeliest mistake on the path (a wrong asset-id)
  returns a table key instead of a sentence naming the launchpad. Pinned as-behaves by
  `Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>` 01b and annotated at the source.
- **CODEX composite-id guard mute for a SHORT id** (NEW 2026-09-12, ordering) -- `21_CODEX.pact:332`.
  The length check is computed FIRST and still saves nothing, because the `let` is eager and
  `fold (and)` does not short-circuit. Pinned by `CODEX-G3`, which also bounds it: at the correct
  length the message works. **Ninth instance of the eager-`let` pattern.**
- **Bulk-transfer shape guard mute in two directions** (NEW 2026-09-12, **behaviour change, needs your
  call**) -- `TS02-C1::DPDC|C_BulkTransfer` evaluates `enumerate 0 (- l 1)` before the core cap. Pinned
  by `DPDC-G14`; DPOF's correctly-ordered twin is pinned by `DPOF-G12`.
- **`C_Slumber` mints an un-unsleepable nonce** (NEW 2026-09-12, **behaviour change, needs your call**)
  -- metadata shape mismatch with `C_Unsleep`; a live holding has no unsleep path. Pinned by `VST-G7`.
- **Hot-RBT prefix exclusion has a hole** (NEW 2026-09-12, **behaviour change, needs your call**) --
  `08_ATS.pact:884` tests against `"H"` where the value is always 2 chars, so `H|` tokens are not
  excluded. Pinned as-behaves by `ATS-G15`.
- **`E-ANK` used as a message label** (NEW 2026-09-12, message-only, 7 sites) -- pinned as-behaves by
  `AQP-G35`; a one-constant repair. `2026-09-12-ank-label-constant-is-an-object.md`.
- ~~**Cross-module `keys`**~~ -- WITHDRAWN 2026-09-12, not a defect. Those readers are `/local`-only
  by design and have no Pact callers.
- ~~**`15_SWP.pact:466` missing `format`**~~ -- FIXED 2026-09-12 (owner-authorised). `SWP-G21` now
  pins the repaired message.

## SMALL OWNER ITEMS (comments/one-liners, none applied)

1. **`06_DPOF.pact:2014` carries a now-stale comment.** It says `UEV_ParentOwnership`'s sleeping-LP
   rejection needs "a REAL issued sleeping-LP token, which no suite creates." One does now —
   `SWP-G22` issues a sleeping link on an LP token, which is what puts a BAR in the 4th character
   the guard reads (an ordinary `Z|MOCKA` DPOF does NOT trip it). The comment also proposes the
   fix: bind `<parent>` lazily inside the `if` below the enforce, matching the DPTF twin
   `URCv_Parent`, which enforces before its read and is pinned by `modules/DPTF.repl <<DPTF-G5>>`.
   Not applied — canonical sources are not edited from the test side.
2. ~~**`01_DALOS.pact:1215` should be annotated `;;UNREACHABLE`**~~ — **SUPERSEDED 2026-09-12: it was
   EXECUTED instead**, by `modules/DALOS-ADMIN.repl <<DALOS-G8>>`. The proof below still stands, and
   that is exactly why annotating was the weaker move: **an `;;UNREACHABLE` note is a claim about
   today's call graph and goes stale silently the first time someone adds a writer.** This guard is a
   backstop against corruption -- its job is to fire in a state the writers are supposed to prevent --
   so `env-module-admin` produces that state, the guard fires, and `rollback-tx` discards it. The
   assertion also records something the proof could not: it fires **with a correctly-signed caller**,
   i.e. the structural check runs BEFORE `enforce-guard`, which is the right order for a corruption
   check. **The general rule this settles: when a guard is unreachable because an INVARIANT holds
   rather than because a branch is dead, drive the invariant false and execute it -- annotate only
   when no state could ever reach it** (as with `03_DPDC-C:279`, where the call simply does not exist).
   The original proposal and its proof, kept for the reasoning:
   `UEV_StandardAccOwn`'s second enforce, *"Incompatible Governer Guard detected for Standard DALOS
   Account"* `(= account-guard governor)`, cannot be tripped for a standard account. Proven three
   ways: account creation writes `"governor" : guard` (both the smart and standard branches, lines
   ~1362/1386); `XI_RotateGuard` updates BOTH fields on a standard account and says so in its own
   @doc; and `XI_RotateGovernor` — the only writer that touches governor alone — is gated to SMART
   accounts (verified by execution: *"Operation requires a Smart DALOS Account"*). So the two fields
   cannot diverge on a standard account. It is a defensive assertion, and annotating it removes a
   non-item from the pinning worklist rather than leaving it to be re-investigated.
3. ~~**`15_SWP.pact:466` missing `format`**~~ — **DONE 2026-09-12**, owner-authorised. This was the
   one item on this list that the owner converted from "proposed" to "apply it", and it is the
   pattern to follow for the rest: a missing-`format` message is a pure repair with no behavioural
   change, so it does not need a decision.
4. ~~**Cross-module `keys`**~~ — **withdrawn**, no question to answer.

## STATE-DRIVEN GUARD COVERAGE — `env-module-admin` + `rollback-tx` (new, 2026-09-12)

The biggest single source of "unpinnable guard" in this suite is a guard whose input **no legitimate
flow produces** — a token in two ATS pairs, a treasury in debt, two fields that writers keep in sync.
I had been writing those off. They are reachable:

    (env-module-admin DPTF)                 ;; test-only: grants another module's admin in a REPL
    (update DPTF.DPTF|PropertiesTable …)    ;; drive the state directly
    …assertions…
    (rollback-tx)                           ;; NOT commit-tx — discard every write

then a **separate transaction that asserts nothing leaked** (`<<LQD-G2>>`). The leakage check is not
optional: a `commit-tx` typo would leave a sovereign table claiming a pair that does not exist, and
every downstream liveness check would silently agree with it.

First use bought **three guards** that this handoff had listed as unreachable. Candidates to try it
on next: `DPTF`'s treasury-in-debt note (`UC_TreasuryLowestDispo` is negative by construction, so the
fixture needs a treasury actually in DEBT), and anything else in the worklist whose blocker is
described as "no suite creates this state" rather than "needs a different argument".

Caveat on scope: this grants in a REPL what no signer could grant on chain, so it is only valid for
pinning a guard's REACTION to a state, never for claiming the state is reachable in production. Keep
those two claims apart in the comment — that conflation is exactly what produced the two withdrawn
findings above.

## EVERY DETECTOR I WROTE NOW SELF-TESTS — run these before trusting a number

    cd REPL && python3 _deadbind.py            # canary baked into every run
                python3 _docclaims.py          # canary baked into every run
                python3 _conformance.py --selftest
                python3 _vacuous.py --selftest

Two canary designs, chosen per tool:
  * **live canary** (`_deadbind`, `_docclaims`) -- a hand-confirmed instance that must keep being
    found. Cheap, but only valid while that instance exists.
  * **synthetic canary** (`_conformance`, `_vacuous`) -- the rule is fed a constructed input. Used
    where a live canary would FALSE-ALARM once the defects are fixed: "cross-module-scan must find
    10" becomes wrong the day somebody fixes those ten, which is exactly when the tool should stay
    quiet. **This reasoning paid off immediately and not how I expected**: the cross-module-scan
    finding was withdrawn two days later, and a live canary pinned to "must find 10" would have
    failed the gate for being *right*.

Two bugs were found in the canaries themselves while writing them, which is the point:
  * `_docclaims`' first canary tested the POST-FILTER list, so in default mode it failed precisely
    BECAUSE the canary functions are now tested and therefore filtered out. It now tests what the
    patterns CLASSIFIED, before filtering.
  * `_docclaims --all` printed "claims whose function is NEVER mentioned: 100" while listing all
    100 -- the label did not follow the mode.

## A TOOL THAT SELF-TESTS — copy this pattern

`_deadbind.py` verifies itself on EVERY run against two dead bindings confirmed by hand
(`TFT::URCx_CPF_RT-RBT`'s `length-rt`/`length-rbt`) and **exits non-zero** if it cannot find them.

The reason is empirical, not theoretical. FOUR scans written during this work returned a confident
clean 0 over a class already reproduced by hand:
  * a conformance rule matching a quote that the module's own `strip` had already blanked;
  * a sentinel scan looking for `(length (UR_X …))` when the real code binds the list first;
  * the same scan again, filtered to calls with an UPPERCASE head, missing the native `(length x)`;
  * an `_shadowed.py` "fix" that was a no-op because `sig` already contained the lambda line.
Every one looked like a clean result. **A detector that cannot find a known instance is reporting
its own bug, not the codebase's** -- so bake the canary in rather than remembering to check.

`python3 _deadbind.py` currently: **150 dead bindings** (0 heavy, 95 point reads, 55 pure compute).
Waste on live paths, not a correctness bug -- 24 in `02_SCORE.pact`, 21 in `05_FVT.pact`. Spot-checked
by hand: `05_DPTF.pact:393` (`GOV|WIPE_ALL-TREASURY-DEBT` reads OURO supply and decimals, uses
neither) and `08_ATS.pact:3084` (`ATS|C_AddSecondary` reads price and trigger, uses neither).

## THE 163 SPLIT BY COST (run this before picking a target)

Of the 163 live unpinned guards, **57 have an owner the suite ALREADY calls** -- those need a
different ARGUMENT, not a new fixture. The other 106 need both. Reproduce the split by parsing
`_enforce_coverage.py --list` and testing each owner name against the concatenated `.repl` corpus.
Concentrations in the cheap half: `05_FVT` 8, `05_DPTF` 6, `01_ANK` 5, `03_DPDC-C` 4, `02_SCORE` 4.

Two pinned straight off that list, both needing only a different ARGUMENT:
  * `ORBR::C_WithdrawFees` "There are no {} fees to be withdrawn" -- the state was already produced
    one block earlier by `ORBR-FEE4`'s drain. One transaction, no fixture (`ORBR-FEE5`).
  * `SWP|S>UPDATE-AMPLIFIER` "Amplifier can only be updated for Stable Pools" -- a product pool was
    already in the suite (`SWP-G23`). Note the mechanism: "is this stable" is decided by the
    AMPLIFIER'S SIGN (non-stable pools store the -1.0 sentinel), not by the pool-type letter. Both
    are asserted, because they agree here and a reader would assume the letter is what is checked.

**A GUARD'S REACHABILITY IS A PROPERTY OF ITS CALL SITES, NOT OF THE GUARD.**
`DPDC-C|C>REGISTER-NONCES` carries four guards. Through `DPNF|C_Create` NONE of the amount/parity
ones can fire -- that client hardcodes `amount` to 1 and derives both list lengths from the SAME
list, so they hold by construction. Through `DPSF|C_Create` the caller supplies `amount` and the
two lists independently, and both become reachable (pinned as `DPDC-G8`). Before filing a guard as
unreachable, enumerate its clients -- one of them may pass user data where another passes a constant.

**Read any NOT-PINNED note already in the suite before trusting it.** `modules/DPTF.repl`'s note on
the treasury-dispo guard was WRONG in a way that sends the next attempt down a dead end -- it said
the probe succeeded "because the treasury is larger" and that a value derived from the live treasury
would work. Measured: the treasury is 0.0, and `UC_TreasuryLowestDispo` returns a NEGATIVE number by
construction, so the check `(<= lowest-dispo treasury-supply)` is unconditionally true while the
treasury is in credit. No argument can trip it. The note is corrected in place, with the real
requirement (a treasury in DEBT -- the same fixture its sibling guard needs) and the observation
that the mutation worry does not apply to a correctly-FAILING call, which aborts and writes nothing.

## TESTED NEGATIVES — do not re-try these

Recorded so the next pass does not spend itself re-deriving a dead end. Each was tried, measured,
and rejected on evidence:

- **Do not build a rule for "enforce comparing two always-synced fields".** That shape --
  `DALOS::UEV_StandardAccOwn`'s `(= account-guard governor)` -- is a SINGLETON: a scan for
  `(enforce (= x y))` where x and y come from DIFFERENT `UR_` readers on the SAME key finds exactly
  one site in the whole codebase, the one already triaged. `_deadguard.py` covers a different shape
  (reader enforces P, then a cap enforces P again) and correctly reports 0.
- **Do not extend `admin-gate-terminal` to `C_`.** 8 hits, all false positives. An `A_` delegates
  ACROSS a modref, so "no modref" means "no downstream gate"; a `C_` delegates to an IN-MODULE
  `XI_`/`XB_` carrying its own cap, which the rule's `ref-X::` test cannot see. Full reasoning is in
  the rule's own docstring in `_conformance.py`.
- **Do not add lambda-params to `_shadowed.py`'s `args` set.** It is a no-op: `sig` is the first 8
  lines of the body and already contains the lambda line. The real gap is that the rule requires the
  enforce CONDITION to name an argument, and `DPOF::UEV_NoncesCirculating` tests the read RESULT
  instead. Triage note is in the tool at the exact line.
- **`_cheapseam.py`'s raw count OVERSTATES the work by ~30%.** Its header now decomposes it:
  of 47 listed, **13 are in the DEAD `00_DPMF` module** and **1 is already annotated
  `;;UNREACHABLE`** with a full write-up and a pointer to where it is pinned as-it-behaves
  (`OUROBOROS::UEV_Exchange`). Real remaining work is ~33. Both filters were added after the tool
  sent me at dead targets.
- **Marker matching uses a 12-LINE WINDOW, not the line above.** `_enforce_coverage.py`'s
  convention is that a `;;UNREACHABLE` comment claims the next enforce within 12 lines, because
  those notes routinely run to two or three lines. A "line immediately above" check finds the
  CONTINUATION and reports a clean 0 — which is exactly what my first version did, over a site
  carrying a full explanation. Two tools disagreeing about what counts as annotated is worse than
  either rule alone.
- **SECOND-BEST: the `archive/` and `_scratch_*` files are a FIXTURE COOKBOOK.** They are ungated
  and assert little, but they were written while investigating real audit findings and contain
  worked-out recipes for states no gated suite leaves behind. `TFT::UEV_DispoLocker` needs an
  account with NEGATIVE OURO; `archive/_scratch_tft_m4_cleardispo_unfreeze.repl` had already
  derived how (give it Elite-Auryn, then SUBLIMATE OURO against a zero balance -- sublimation
  spends OURO the account does not have, and the overdraft is the Dispo the Elite-Auryn backs).
  Reusing it made that pin one pass instead of several. **Grep `archive/` before deriving a state.**
- **`<<TX4.0-CONFIG>>` is a STAGED window, not one window.** That block walks the chain through
  distinct configurations -- nothing set, then OURO only, then OURO+IGNIS-same-token -- asserting at
  each. A guard shielded in one stage may speak in the next: `ORBR::UEV_Exchange` is mute in ALL of
  them (it binds its own guard's subject), while `ORBR::URCv_Sublimate`'s twin guard DOES fire once
  OURO alone is set, because its binding group reads only the OURO id. Pinning the working twin is
  what keeps the UEV_Exchange FINDING precise -- otherwise it reads as "BAR ids abort everything"
  rather than "this function binds its own subject". **Check each stage separately.**
- **PACT PRINTS OBJECT KEYS ALPHABETICALLY, NOT IN CONSTRUCTOR ORDER.** `UDC_LiquiditySplitType`
  is `(iz-balanced, iz-asymmetric)`, but printing the built object shows `iz-asymmetric` first.
  Reading the printed shape to infer argument order gets it backwards -- and the wrong order fired
  the very guard under test, which is the only reason it was caught. **Read the UDC body, never the
  printed object, to learn argument order.**
- **A DESTRUCTIVE fixture belongs in the LAST block of its file.** `STAGEZ-20` drains a pool to
  zero to reach `SWPLC::UEV_AddLiquidity`'s empty-pool rule; every earlier block in that file reads
  the same pool. Full removal is supported (`UEV_RemoveLiquidity` permits the whole balance with no
  retained minimum, deliberately -- its @doc argues gating removal on the owner's switch "isn't a
  safety mechanism, it's a trust violation"), so the empty state is reachable, just not repeatable.
  Note the LP holder was `KST.AOZT`, not the usual patron -- the obvious guesses all hold zero.
- **BOOT-TIME WINDOWS COUNT TOO.** `[4.0]_Sovereign-Executor.repl` walks the chain from nothing to
  configured, so every "X is not set yet" guard is reachable in the lines before X is set. That is
  where `SWPI::UEV_Issue`'s "Principals must be defined" was pinned (`<<TX-18>>`). **Caveat: that
  file is loaded by deploy-stage01, so an assertion there executes in ~69 entrypoints** -- 3
  distinct tests moved the EXECUTED total by 207. Fine, but decompose it before reporting.
- **BEST REMAINING TECHNIQUE: assert inside a state window an existing harness already opens.**
  Some guards need a state that exists only transiently. `FVT::UEV_CollectContext`'s
  "Collect is frozen while a re-score sweep is in progress" needs an OPEN sweep -- which exists for
  exactly the span between `CC_SweepBegin` and the recompute chunks in
  `Kursan/AQP-scale-sweep.repl`. Building that fixture from scratch is a day; asserting inside the
  window that harness already opens took one transaction (`SCALE-SWP-FREEZE`). **Before building a
  fixture, grep the suite for a harness that already passes through the state you need.**
  Assert the PRECONDITION in the same block, so the test stands alone and cannot silently start
  pinning a different guard if the window moves.
- **The ZERO-FIXTURE guard seam is EXHAUSTED.** `_cheapseam.py` now reports it directly: of the
  non-dead candidates, only 3 were reachable with plain arguments (no table read, no `CAP_`/`UEV_`
  in front). Two are now pinned (`ATS-G12`, `DPDC-S-G4`); the third sits behind `CAP_Owner`. The
  tool prints "START HERE: nothing" today, and also counts the 13 DEAD-module sites separately —
  pinning those raises the number and tests nothing. Everything remaining needs state or a
  signature built first: a wiped DPOF nonce, a tier-qualified new owner, and so on. **Budget one
  guard per several turns, and expect the coverage percentage to move slowly.**

## HARD-WON RULES — READ BEFORE WRITING ANY TOOL OR TEST

- **`ls REPL/_*.py` FIRST.** 35 tools; see `REPL/TOOLS.md`. Import `strip_comments` from `_pactlex`,
  never re-derive it (shipped broken 4+ times).
- **Always pass the expected message to `expect-failure`.** The 2-arg form passes on ANY error. Every
  one of the six Stage-Z findings would have gone green against the wrong error without this.
- **`try` puts the DB in read-only mode**, so `keys`/`select` inside a `try` fail with *"Operation
  disallowed in read-only or sys-only mode"* — the probe's error, not the code's. Plain `read` under
  `try` works, which is exactly what makes this trap convincing. Probe scans with a direct call.
- **`expect-failure` does NOT roll back writes.**
- **Grep the suite for prior art before writing up a defect class.** The `enumerate` fact I spent a
  pass establishing was already documented in TWO files and already fixed twice (#20H, #47L/#51L).
  The sweep was still worth doing; the write-up needed correcting. `grep -rn "<the fact>" --include=*.repl`
  costs seconds.
- **A FIRST error message is not a root cause.** `let` is eager, so the first abort may be hiding
  others. The only way to know is to remove it and look again — that is the whole yield of today.
- **Mutation-test a new assertion.** Break the expectation, confirm the suite goes red, restore.
- **Report the absolute figure from a clean tool run**, not a delta — and DECOMPOSE any delta
  before publishing it. Two deltas this session looked wrong and were not: one was re-execution
  across 35 entrypoints, the other was the gate reading a file I edited while it ran.
- **Put a new test in an entrypoint that ALREADY loads its fixtures.** Adding
  `(load "Stage_02/[6.2]_AQP.repl")` to a Kursan harness to get three assertions re-ran the whole AQP
  suite: +450 executions and +24s for +3 real tests. Moved to `modules/AQP.repl`, it cost +3 and +4s.
  Check what each entrypoint already loads before adding a load line.
- **Delete scratch loaders from `modules/` before a gate run.** `modules/*.repl` is globbed into
  the gate, so a forgotten probe runs as a real entrypoint — mine failed the gate 200s in. `_gate.py`
  now refuses to start if `modules/_*.repl` exists; keep using that `_` prefix for throwaways.
- **Do not edit suite files while `_gate.py` is running.** It re-reads them; the run then reports a
  mixture of before and after, which is unreconcilable after the fact.
