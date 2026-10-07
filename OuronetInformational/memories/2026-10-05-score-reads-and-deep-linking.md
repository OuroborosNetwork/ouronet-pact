# 2026-10-05 — the score read slice, and the deep-linking rule applied for real

Chapter B, AQP UI. Two owner requests: *"do the modification that every page has its own link"*
and *"prepare the readers needed in their own reader module, to make the scores viable in the
client side."* Both are done. What follows is only the part worth carrying forward.

---

## 1. `npx tsc --noEmit` IN `daimons/OuronetUI` CHECKS NOTHING

**Use `npm run typecheck`** (`tsc -p tsconfig.app.json --noEmit`).

The root `tsconfig.json` is a project-references stub: `"files": []` plus two `references`. A bare
`tsc --noEmit` against it compiles **zero files** and exits 0. Verified with
`tsc --noEmit --listFiles | grep -c aqp/fixtures.ts` → **0**.

This is not cosmetic. Several "tsc clean" checks in this session were no-ops, and when the real
command finally ran it immediately reported **two genuine errors** that had been sitting there:

- `src/lib/aqp/fixtures.ts` missing a newly-required property on a typed fixture array, and
- `import { useWallet } from "@/hooks/useWallet"` — **a module that does not exist**. The correct
  path is `@/context/wallet-context`. A broken import, invisible for the whole session.

A type checker that passes because it opened nothing is the same failure class as
`_previewcoverage`'s "perfect score" over three hardcoded files, and as `_bandplan.py` reporting 89
entrypoints where there were 482. **The question is never "did it pass", it is "what did it open".**

---

## 2. DEEP LINKING: THE ROUTE EXISTING IS NOT THE PANELS USING IT

The AQP page had all three routes declared —
`/app/aqp-pairs/:area/:side/:view/:entity?/:sub?` — and `deep-linking.test.ts` asserted exactly
that, and passed. Meanwhile **8 of the 10 panels held their descent in `useState`** and read
nothing from the URL. The `:entity` and `:sub` slots were routable and unoccupied; only the two
anchors panels ever filled them.

**The remount key was the tell.** Eight panels carried
`key={`${area}/${side}/${view}`}`, and the comment above them described the bug it was papering
over: a tier-2 switch does not unmount a panel (same component, new `view` prop), so entering an
entity and switching tabs put you back inside it. The key cleared that by throwing the component
away — treating the symptom and preserving the cause, while making the position unlinkable,
unreloadable, and absent from any bug report.

Now: every panel takes `entity`/`sub` as props, `onPick`/`switchSide` call `to()` with no entity
so the URL itself drops the descent, and **no remount key remains**.

**What counts as a position, settled:** a DESCENT (replaces the screen, or selects the entity the
screen is about) and a TAB are positions. A DISCLOSURE (expanded row, open selector) and FORM
STATE are not. The exempt names are `open`, `newOn`, `unstaking`, `creating`, each listed with its
reason. `ScoresMgmt` holds only `newOn` and therefore takes no slot — and the test **derives**
that from the panel's own source rather than exempting it by name, because a name-based exemption
outlives the fact it was granted for (see the five stale `_patronslots.py` entries).

The test now asserts on the **consumers**, and was negative-tested seven ways.

---

## 3. A NON-EMPTINESS GUARD IN A SHARED REPL FILE ASSERTS THE FIXTURE, NOT THE READER

New assertions in `[6.2.9]_AQP-BOOT-FULL.repl` folded over FILTERED subsets, and a fold over an
empty list is `true` for any reader — so each subset was asserted non-empty first. Measured
against that boot: 40 catalogue rows, 5 with no pool, 6 admitted nowhere. All green.

**The gate then failed in `Kursan/dsa-hetero-split-tests.repl`**, which loads the same file against
a catalogue where every score is pooled and admitted. "Some scores are unlinked" is a claim about
the CALLER'S WORLD, and a reader test that dictates its caller's world gets deleted rather than
fixed.

**The replacement is stronger, not weaker:**

- a **partition** — every row's `aqpool-link` is either BAR or a pool, never neither; same for
  `fvt-link`. True in any fixture, and it fails on exactly the defect non-emptiness was reaching
  for: a renamed or absent field empties BOTH filters, so the sum stops matching the total.
- a **sentinel agreement** — `fvt-class` is `-1` for exactly the rows whose `fvt-link` is BAR.
  Needs no particular population: a reader defaulting to class 0 fails it on any catalogue with
  one unadmitted score, and a reader answering -1 always fails it on any catalogue with one
  admitted score. Both verified by breaking the module.
- non-emptiness kept **only** for the sides a populated catalogue must have (pooled, admitted).

---

## 4. THINGS THE CHAIN DOES NOT HAVE, measured so nobody re-derives them

| claim | status |
|---|---|
| `URH_BC|Anchors` | **DOES NOT EXIST.** `AcquisitionAnchorsV1` declares `UR_BC|Anchors:integer` — a slot COUNT. The seven slot ids live in the module-only `UR_BC|Data`, unreachable by modref. A read calling it was written, passed tsc and every decoder test, and would have aborted on chain. |
| an FVT **name** | **DOES NOT EXIST ANYWHERE** — no field, no reader, zero hits tree-wide. Nor does a score name or a pool name. The issuing entrypoints take a human string as the id's STEM, so the stem is the only human label there is. |
| a score's **asset** | **NOT ON THE SCORE.** `SCR|Schema`: *"No separate scr-asset on the score. Staking asset is defined on the AQP pool. Resolve Score -> aqpool-link -> Pool -> asset-id."* Two hops, via `UR_AQP|PoolAssetId`. |
| `UR_SCR|TripletTrueTriplet` | **EXISTS and is declared.** Do not derive "true triplet" from the three rungs' boost-links, as a first draft did. |
| a user row's **stamped generation** | **NO READER.** `UR_SCR|ScoreVacateGeneration` answers the SCORE's. `URC_U-SCR|UserScoreDebStale` already answers the only decidable question, so the field is reported as `null` — never 0, which would imply staleness. |
| an FVT or MultipletFamily **enumerator** | **NEITHER EXISTS.** AQP has exactly four global enumerators: anchors, boost classes, scores, pools. The Reward Ladders view stays unwired, deliberately, and the reason is recorded in `Deploy/PureV2/32_deploy.pact`. |

---

## 5. `max-promille` WAS A FALSE CLAIM, AND IT WAS OURS

`URH_13|BoostClasses` returned a field called `max-promille`, computed as
`(fold (+) 0.0 (map UR_ANK|Promile members))` — the SUM of a class's per-unit rates. Calling that a
maximum claims a ceiling the contract does not impose: each rate multiplies by the holder's
CONFORMING UNITS and nothing caps the product.

Owner correction, verbatim: *"if you stake multiple nfts with blue eyes, you have multiple times
the 250 promile boost ... there is no upper limit."*

A UI labelling it "max" tells users their boost is capped when it is not, which is the kind of
wrong that makes someone stake less. Renamed to `total-promille` (ships in `PureV2/33`). The client
reads **both keys** with the new one taking precedence, so the column is correct before and after
the deploy; `aqp-chain-reads.test.ts` pins all three facts, and the fallback is to be dropped once
33 is confirmed live.

---

## 6. DECLARE THE WHOLE INTERFACE BEFORE IT SHIPS

`OUiThirteenV1` went live with four of its module's functions undeclared, so `URC_13|AnchorFull`
is **permanently module-only** — adding it now would force a V2 bump for a function only the UI
calls, by name, at `/local`.

`OUiFourteenV1` had not shipped, so all **nine** functions are declared. The rule that keeps a
function module-only is `object{Schema}` for a schema defined in the MODULE; a bare `object`
return is fine in an interface (13 declares two). The four object-returning functions here were
undeclared **by omission, not by rule** — and an earlier draft of 32's header asserted the rule as
the reason, which was wrong and is corrected in place.

---

## 7. DOC FIGURES HAD DRIFTED A WHOLE ROUND

`_docsfigures.py` is check-only **by design** — *"Both need a human; a silently dropped claim is
not a correction."* So prose figures are updated by hand, and three had been stale since the
registry moved: **423 → 427** entrypoints, **405 → 409** sponsored, **410 → 414** divergent
previews, plus lines/defuns/files from this session's own Pact edits.

Three traps in that sweep, all hit:

- **`405.6 gas per parcel`** is an unrelated measurement a bare `405 → 409` would have corrupted.
  Swept by PHRASE, never by number.
- **`60-methodology/04-what-went-wrong.md`** holds a `| reported | actual |` table that is a
  FROZEN RECORD of what a broken tool printed on one day (410 vs 423). Updating it would rewrite
  history to make a past mistake look like a different mistake. Skipped explicitly.
- **two "equal today, unrelated forever" notes** about MODULE-INDEX's 423 *tables* coinciding with
  the registry's 423 *entrypoints*. **They have now actually diverged** (427 vs 423), which is the
  best possible evidence for the rule those notes exist to teach: anyone who filed "423" as one
  fact about Ouronet now holds one number that is right and one that is wrong, with nothing in the
  number to say which. Both notes rewritten to say so.

One live claim was also **backwards**: the module map said a "logical lines" count gives a SMALLER
figure than `wc -l`. A file whose last line lacks a newline contributes a line `wc -l` cannot see,
so it gives **more** — exactly **+73**, which is precisely the number of such files. The old
figure was 597 below the then-current count, a gap its stated reason cannot produce.

---

## 8. STATE

- `14_O-UI-FOURTEEN.pact` — 9 functions, all declared. **36 REPL assertions, 0 failures**, green
  in both gate contexts that load them. Deploy file `PureV2/32` (interface + module, no tables).
- `PureV2/33` — the `total-promille` rename, module-only, kept out of 32 so a zero-risk rename is
  not queued behind a first-interface deploy.
- **NEITHER IS DEPLOYED.** The UI reads them and will show the named-module failure screen until
  they land — which is what that screen is for.
- UI: `scoreChain.ts`, `useScoreReads.ts`, `ScoresTab`/`ScoreDetail` on live reads; `ReadGate`
  extracted to `shared/ui.tsx` so both slices report loading and failure identically.
- Still fixture-backed, and still correct to be: **Reward Ladders** (no enumerator exists) and
  `boostSources` on the score detail (the per-class anchor list is unreachable by modref; the
  aggregate promille IS fetched, in the same round trip).
- **Scores MANAGER side — 17 functions — not started.** Owner deferred it until the client part
  was done.

## Round 2 — deep linking finished across the asset pages (2026-10-05)

The first pass covered AQP's ten panels. This one covers the rest, and the audit found more than
tab segments missing.

**`swp-pairs-proto` had SEVEN of its eleven positions with no address at all.** Two hand-written
maps carried the slugs — `TAB_MAP` for parsing, `CAT_TO_TAB` for writing — and both stopped after
tier-1 tab 1. "Liquidity Pools Management" (3 sub-tabs) and "My Liquidity Positions" (3) were
unreachable by link, and clicking into them rewrote the URL to the bare page path, which the
parser then read back as Smart Swap. **Nothing reported it because the two maps agreed with each
other.** They were mutually consistent and jointly incomplete, which is the failure mode a second
copy of a mapping always has. Fixed by DERIVING the slugs from the label arrays
(`src/lib/swp/tabs.ts`), with the five old slugs kept as read-only aliases so links in circulation
still resolve. A new tab now gets an address by existing.

**`collectables` had TWO sources of truth for one position** — the token in both the `:entity`
segment and a `?token=` query param, the view only in `?view=`, plus a dead `?cat=` fallback.
`/…/TOKEN-A?token=TOKEN-B` resolved to A while still writing B. Unified onto path segments.

**Three more unlinked descents**: orto-fungibles' `viewMode` (tokens↔nonces) and `focusedNonce`,
collectables' reset effect which forced `view=tokens` on mount and so **discarded any deep link
into the nonces or sets view before it rendered** — a deep link the page throws away is worse than
none, because it looks like it worked.

### Two hook-level invariants that came out of this

**A position cannot be written without its ancestors.** `useUrlSelection` appended into slot N
regardless of path length, so on a holdings page with nothing held the view landed in slot 1 and
the router bound `:entity = "tokens"`. It now refuses.

**The setter is stable but never stale.** `write` closes over `pathname`; a caller wrapping it in
`useCallback([])` — the normal thing before passing a handler to a memoised child — captured the
mount-time path forever. Routed through a ref: one identity, current writer.

### Three things I got wrong, worth keeping

- **My own test had the hole it was written to close.** It matched `useState<string | null>` only,
  so three numeric selections sat in collectables while it reported the page clean. An id's TYPE
  is not what makes it a position. Now matches numbers, with a named exemption list for the
  set-builder slots — and dropping that list flags them, which is how I know the names are
  genuinely in scope rather than slipping past the shape.
- **A test asserting a spelling, not a property.** `write(next, false)` was pinned literally and
  broke the moment the setter was routed through a ref. Re-pinned on the replace FLAG, plus
  "exactly one call site may replace."
- **A negative test that was wrong about the code.** I asserted the derivation never mints a
  legacy slug — but `smart-swap` is legitimately both. The real hazard is a legacy entry
  *shadowing a different* position, since legacy is consulted first; that is what is pinned now.

One guard is **measured redundant and kept anyway**: `if (!tab) return null` in `tabToCats`
changes no answer for any falsy input (verified by running both variants). It stays as the
statement of intent, because the fall-through is a coincidence of `indexOf` and would stop
holding the moment a label slugified to the empty string.

### Verification

Gate GREEN, 26,783 assertions, 0 failures — no Pact changed this round. UI: **1,046 tests, 66
files**, typecheck and build clean; the 2 lint errors are pre-existing on HEAD (checked by
stashing). Every new assertion negative-tested: 6 on the hook and pages, 6 on the tab module,
3 on the swp page, 3 on the widened matcher — 18 corruptions, 18 caught, tree restored
byte-identical each time.

**Still not deployed: `PureV2/32` (O-UI-FOURTEEN) and `PureV2/33` (the `total-promille` rename).**
Until they land the Scores tab shows the named-module failure screen. The scores MANAGER side
(17 functions) is not started.

## Round 3 — score identity, two kinds of score family, and a tab in the wrong area

Three of the four things asked for turned out to rest on a false premise, and the premise came
from a function NAME.

**`AQP-BOOT.C_Step6_CreateOuroLpTriplet` creates no triplet.** Its own `@doc` says
*"Issue OURO LP triplet **scores only**"*; the actual `C_IssueTriplet` lives in Step 11
(`C_Step11_WireFarmTriplet`), which has not run. Measured on mainnet rather than read from the
source:

```
(keys ouronet-ns.AQP-SCORE.SCR|T|Triplet)  -> []        zero triplets
UR_SCR|ScoreBoostLink Bronze               -> Silver    live
UR_SCR|ScoreBoostLink Golden               -> Silver    live
UR_SCR|ScoreBoostLink Silver               -> "|"       the hub
```

So the UI showing the three SnakePower scores individually was **right about the triplet and
wrong about the relationship**. What the chain holds is a BOOST CHAIN, and it was already
readable — `UR_SCR|ScoreBoostLink` is declared on `AcquisitionScoresV1` and the reader simply
did not expose it. The omission was in the reader, not in the chain.

**The two kinds of family are not interchangeable, and conflating them is the worse error.** A
registered triplet is ONE aggregator member whose weight comes from maintained lane weights, so
a TRUE triplet is deb-independent and cannot go stale. A chain is three members that each earn
and each stale on their own. Telling a user they hold one member when they hold three is telling
them something false about how they get paid — so the UI draws a chain as a chain and says
outright that it is not a registered triplet.

**Reward Ladders was in the wrong AREA, not merely mislabelled.** `multiplet-family-id` is a
field on `FVT|RPS|Global`, keyed `<FVT-ID> | <DPTF-ID>` — *"One registered reward DPTF on this
FVT"* — so a ladder is an attribute of ONE REWARD LANE OF ONE AGGREGATOR. A score cannot have
one, choose one, or be used to find one: the only path to a family id is
`UR_FVT-RG|MultipletFamilyId(fvt-id, dptf-id)`, which takes an aggregator and a token and never
touches a score. Two further facts made the old view unservable anyway — there is no enumerator
for FVTs or MultipletFamilies anywhere on chain, and `FVT|T|MultipletFamily` holds zero rows. The
renderer moved onto the lane; `RewardLane` gained `rewardKind` and `multipletFamilyId`.

### The field contract this slice shipped without

O-UI-FOURTEEN's six siblings each assert *"returns its N contracted keys"*; it had no such
assertion. That is the one check that catches a reader quietly LOSING a field — every consumer
reads by key, a dropped key renders as a blank cell rather than an error, and the surviving
fields still agree. Added, negative-tested by dropping and by renaming (8 assertions fire either
way).

It is **one-way and says so**. My first draft asserted the exact set via `(sort (keys obj))` and
claimed that was stronger than a count — it does not even run: `keys` is a TABLE native and
errors on an object, and this Pact cannot enumerate an object's fields at all. "A field was
added" is not checkable here; dropped and renamed are, and those are the ones that break a
screen.

### Four of my own tests were wrong, in two distinct ways

**Too loose — matched more than I meant.** `{s.scoreId}` counted the React `key=`, which renders
nothing, so deleting the displayed column left the test green. And `/function ScoreCatalogueRowView/`
without `\b` matched `…ViewX`, so renaming the component — which breaks every call site — passed.
Both found by mutation, not by reading.

**Fixture too weak to distinguish two behaviours.** The hub-order test used two hubs inserted Z
then A, where `reverse()` and `sort()` give the same answer; mutating `.sort()` to `.reverse()`
stayed green. Three hubs in an order that is neither sorted nor reversed fixes it.

Also: a negative test that was **wrong about the code** — I asserted the derivation never mints a
legacy slug, but `smart-swap` is legitimately both. And one guard measured **redundant and kept
anyway**, with the measurement recorded: `if (!tab) return null` changes no answer for any falsy
input (both variants run side by side), and stays as the statement of intent.

### The freeze discipline paid off within minutes

32 and 33 landed and were still in `MANIFEST`. `14_O-UI-FOURTEEN.pact` gained two fields minutes
later, so the next `--write` would have regenerated 32's body from a moved source — the 24/25/26
mistake a fourth time. Moved to `FROZEN` first, confirmed live over `/local` before freezing
(not assumed), and the new fields ship in **34** instead.

### Verification

Gate GREEN, **26,815 assertions**, 0 failures. UI: **1,064 tests, 68 files**, typecheck and build
clean. 23 corruptions introduced across the Pact module, the grouping function and the four UI
files; 23 caught after the two loose assertions and the weak fixture were tightened; every tree
restored byte-identical.

**Not deployed: `PureV2/34`** (O-UI-FOURTEEN module-only, `boost-link` + `lp-denominator`). The
decoder reads `r["boost-link"] ?? null`, so the grouping is correct before AND after it lands —
absent reads as "no chain", which is also what BAR means. Until it lands the chain shows as three
singles, which is what the page does today.

**Chore now unblocked:** 33 is live, so `chain.ts`'s `total-promille ?? max-promille` fallback can
be dropped, as 33's own header instructs.

## Round 4 — the pool premise was half right, and what the manager side actually needs

**Owner's instinct was correct.** The detail screen refused to render anything for a score with no
pool: *"A position exists per (account, pool, score), so there is nothing to show."* The premise
is right and the conclusion was wrong — a POSITION needs the triple, a DEFINITION needs only the
score. Owner, class, precision, boost-class link, foreign boost link, LP denominator, aggregator
link, triplet membership and the chain-wide totals are all keyed on `score-id` alone.

**It was the entire view, not an edge case.** Measured: all twelve scores on mainnet have
`aqpool-link = "|"`, so every score anyone clicked showed one orange box.

The fix reuses `fromScoreChain.entityFull` with `hasPosition: false` rather than zeros — *"you
hold none of this score"* is a claim about the reader; *"no pool employs this yet"* is a claim
about the score and is actionable. The totals panel was extracted so both paths show it: those
figures are keyed on score-id and survive having no pool, so zero there is a measurement, not a gap.

**The builder for this already existed**, carrying the comment *"Unused by the client views; kept
because the manager side will need it unchanged."* It was the fix for a client bug sitting unused
beside the screen that needed it — and the comment is why nobody looked. A note saying what a
thing is NOT for reads as settled.

### The manager side: 17 entrypoints, and the asset wiring is NOT needed

`TS02-C3` carries exactly 17 `AQP-SCR|` entrypoints. Measured from the registry:

* **12 of 17 take no asset at all.** `C_IssueTrueFungibleScore(patron, executor, score-name,
  precision, mx-frozen)` — a score is a scoring RULE you name, not a claim on anything. The asset
  arrives later through the POOL (`SCR|Schema`: *"Staking asset is defined on the AQP pool"*).
* **5 take an asset id** (`lp-denominator`, `dpsf-id`, `dpnf-id`, `collectable-id`) **but the gate
  is SCORE ownership, not asset ownership.** `SCR|C>ISSUE-SF-SCORE-DEFINITION` enforces
  `CAP_EnforceAccountOwnership owner-konto` where `owner-konto` is the SCORE's owner; the asset id
  is validated for nonce existence only (`UEV_Nonce`, `UEV_IzNonceFragmented`).

So the anchorable-assets authority reader has **no role here**. "Scores I own" is a client-side
filter on the catalogue's `owner` — no new reader needed.

**Three of the 17 are unreachable from any UI.** `SCR|T|ScoreEntityModel` has **zero readers on
`AcquisitionScoresV1`** — no enumerator, no field reader, nothing; `URC_ScoreEntityModelExists` is
module-only. So `C_IssueSingleScoreModel` and `C_CombineTripletScoreModel` write rows nothing can
list, and `C_IssueScoreFromModel` consumes a `model-id` nothing can supply. Same shape as the
MultipletFamily gap, and it needs a sovereign addition.

### Verification

UI: **1,066 tests, 68 files**, typecheck and build clean, 0 lint errors in touched files. Gate
unchanged at **26,815** — no Pact moved this round. Five corruptions negative-tested on the
no-pool fix, all caught.

One test of mine failed against **its own removal note** — a negative match on the file cannot
tell a rendered string from the comment explaining why it was removed. Added a `code()` helper
that strips comments first, so documenting a removed string stays allowed.

## Round 5 — the score manager, 14 of 17 wired

Split accepted and built: **Issue a score** (5) + **Scores I own** (9). No deploy — nothing Pact
moved.

### The shape of the screen follows one measured fact

**A score is not gated on an asset.** `C_IssueTrueFungibleScore(patron, executor, score-name,
precision, mx-frozen)` takes none. Twelve of seventeen entrypoints take no asset at all; the five
that do are gated on SCORE ownership, with the asset id validated for nonce EXISTENCE only
(`SCR|C>ISSUE-SF-SCORE-DEFINITION` enforces `CAP_EnforceAccountOwnership owner-konto` read from
the score row).

So the manager has **no asset list**, where the booster manager opens on one. That is a decision
with a reason, written into the nav: an asset picker here would gate nothing while implying a
requirement the contract does not have. "Scores I own" is a client-side filter on the catalogue's
`owner` — `URH_14|MyScoreEntities` answers a different question (beneficiary, not owner).

### The bound that would have been wrong

`SCR|C>ISSUE-SCORE` demands `(> mx 0.0)`; the `UEV_Fee` it calls admits only
`-1.0 | 0.0 | [1.0, 999.0]`. **The usable range is the intersection, [1.0, 999.0]** — every value
in `(0.0, 1.0)` looks like a sensible multiplier and is refused after the fee. That is a
conjunction across two files, which is exactly what a hand-copied number gets wrong; `anchorSpecs`
had all four of its bounds wrong on first write and its test compared the spec to itself.

`score-op-specs.test.ts` therefore **parses the bounds out of the Pact sources** — precision 3..24
from `02_SCORE.pact`, the fee band from `08_U_DALOS.pact`, `CT_FEE_PRECISION` and the designation
lengths from `01_U_CT.pact` — and compares every spec's parameter set against the deployed
registry in BOTH directions. 49 assertions, negative-tested six ways including the multiplier trap.

### Three of seventeen cannot be wired, and the screen says so

`C_IssueSingleScoreModel`, `C_CombineTripletScoreModel`, `C_IssueScoreFromModel` turn on
`SCR|T|ScoreEntityModel`, which has **zero readers on `AcquisitionScoresV1`**. They are named in a
panel with the reason rather than silently absent — a user who has read the contract will look for
them. `SCR|ScoreEntityModel` is documented as the DSA template mechanism, so this is the
delegated-vault path, not a side feature. Needs a `V1→V2` cascade.

### What the old screen was

A fixture-backed mockup whose Control and Rotate buttons carried `onClick={() => {}}` — enabled,
clickable, doing nothing. Worse than a disabled button, which at least tells the truth. There is
now a test forbidding a no-op `onClick` in that file, and the one-time links disable rather than
fail: offering a relink is offering a transaction that cannot succeed, which the user pays to
discover.

### Two of my own tests were wrong again, same class both times

A regex `/scores:[^]*?id: "assets"/` matched **across section boundaries**, firing on the `assets`
view of a different area — a pattern that spans sections asserts about the file, not the section
it names. Fixed by slicing the block between its own delimiters.

And `aqp-mockup-coverage.test.ts` required `useMyAnchorableAssets` of every wired manager tab. That
is the right read for boosters and the wrong one for scores, so the single string became a map —
the question "what do I own that qualifies" has a different answer per tab, which is the reason it
cannot be one assertion.

### Verification

**1,128 tests, 69 files**, typecheck and build clean, 0 lint errors (2 warnings, identical to the
sibling `aqpConsumerSpecs.tsx` — same `LOC` helper, same rule, so matching the house pattern was
preferred to diverging to silence them). 13 corruptions negative-tested across the specs and the
manager, all caught. Gate unchanged at **26,815**; no Pact touched.

## Round 6 — post-deploy chores, and four dead controls I had shipped

**Chores first**, all three with deadlines of a sort:

* **Froze `34`.** It was deployed and still in `MANIFEST` — the configuration that silently
  rewrote the record of what was sent for 24, 25 and 26.
* **Recorded the live registry snapshot.** The sidecar said 2026-10-04 while 32/33/34 had landed.
  12 modules, 12 current, 0 drifted.
* **Dropped the `max-promille` fallback**, as `PureV2/33`'s own header instructed, after verifying
  on chain (`total-promille` present, `max-promille` absent on a live row). The test that pinned
  BOTH names now pins the **absence** of the old one — the half that matters once a compatibility
  branch retires, because a reinstated fallback reads a key the chain no longer emits and would
  never fail. It would just be dead code that looks load-bearing.

### Then I audited what I had just shipped, and found four dead controls

`kind: "select"` renders from `options[param]`; `kind: "nonces"` from the page's `nonces` prop.
**A spec can declare either, type-check, and match the registry parameter-for-parameter while
rendering a control with nothing in it** — the failure is in the PAGE, so no test of the spec file
alone can see it.

Three selects had no option list anywhere (`lp-denominator`, `dpsf-id`, `dpnf-id`) and
`ISSUE_SF_SCORE_DEFINITION` declared `nonces` + `decimalPerNonce` on a screen with no nonce
selector. **Four of the fourteen ops I reported as wired could not have been submitted.**

Found by diffing declared fields against supplied keys — which is now a test, and it reproduced
both defects exactly before I fixed either.

**The fix was not to add pickers.** There is no global true-fungible enumerator on chain:
`05_DPTF.pact` declares exactly three and all are per-account or per-token
(`URH_ExistingTrueFungibles` returns ACCOUNTS for a token, not tokens). And none of these fields
is ownership-gated — the definition ops enforce `CAP_EnforceAccountOwnership owner-konto` read
from the SCORE row and validate the asset id for nonce EXISTENCE only, so **defining weights over
a collectable you do not own is legitimate**. A picker over "yours" would have silently forbidden
it, and for `lp-denominator` would have excluded the likely right answer (the OURO leg, which the
issuer need not hold). They are text fields stating the exact shape required.

The nonce arrays became `json`, matching the two NF definition ops that already took theirs that
way — so all three now read identically.

### Verification

Gate GREEN **26,815** (no Pact moved). UI **1,131 tests, 69 files**, typecheck and build clean.
Five corruptions negative-tested, all caught. Also wrote
`HANDOFFS/HANDOFF-aqp-scores-round.md` — this session has run long and the facts most likely to be
rediscovered painfully are the ones a cold start would not look for.

## Round 7 — generalising the dead-control check

The four dead controls in round 6 were caught by a check that knew about **one spec file and one
page**. That would have caught the defect that happened and nothing else — the same mistake in
`anchorSpecs` or the next spec file would have been invisible.

`spec-fields-are-fillable.test.ts` now derives the link tree-wide: for each module declaring an
`OpSpec`, find the files importing it and require their union to supply every page-filled field
(`select`, `selectPair`, `nonce`, `nonces`, `decimalPerNonce`). A spec module nobody imports is
reported too — an unreachable spec is a different bug, not an exemption.

**Measured: the other two files are clean**, so this is a guard rather than a repair.

### Two things about the check itself

**The UNION is deliberate, and weaker than per-importer.** A page may import one spec from a file
and none of the others — `StandardAggregatorsTab` takes only `COLLECT_REWARDS` from
`aqpConsumerSpecs` and has no business supplying nonces for the stake ops. Demanding every
importer supply every field would fail on correct code. The cost is real: two pages rendering from
one file, only one supplying the options, passes. So the score-specific check that names
`ScoresMgmt.tsx` STAYS — precise and broad, neither subsumes the other, and both say so in their
headers because the next reader will see redundancy and delete one.

**A sweep that finds nothing passes every loop under it.** Guarded twice: at least 3 spec modules,
and at least 14 page-filled fields. The second is the one that bites — finding the modules proves
nothing if the field pattern goes stale, which a renamed kind or a swapped `param:`/`kind:` would
do. Negative-tested: with the pattern broken the file drops from 19 assertions to 1, and that 1
fails.

Four corruptions tested, all caught — including the original defect and the same defect planted in
a different spec file.

UI **1,150 tests, 70 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

## Round 8 — a false claim I made three times, and the duplicate that hid it

**I said the three `C_Sync*Anchors` were unwired. Three times — twice in conversation, once in the
HANDOFF. They are wired, reachable from two screens, and one grep disproved it.** The error came
from conflating "those entrypoints live on the `AQP-POOL` module" with "the AQP-POOL slice is
unwired", then carrying the conclusion forward unchecked. A handoff repeating an unverified claim
is worse than one omitting it: the next session inherits it as established fact.

So coverage is now **measured** (`aqp-surface-coverage.test.ts`), the same reason
`_executorplan.py` is ground truth for the Pact sweep rather than a number in a document.

### Getting the measure right took three attempts, wrong in opposite directions

```
match `entrypoint: "..."`      26/77  -- missed every spec built through a helper
match any registry key literal 74/77  -- swept in pactSignatures.generated.ts
read the spec OBJECTS          correct -- they ARE what the UI renders
```

Both regexes looked plausible and neither was close. The objects cannot drift from the screens
because they are the screens' input.

### What the correct measure then showed, which I also had wrong

I expected `AQP-FVT` to be 0 wired. It is **2** — `CC_Collect` and `CC_UnstaleMyScores`, both
things a HOLDER does, correctly wired on the client side. The 21 remaining are owner operations.
Same shape on `AQP-POOL`: 11 wired are stake/unstake/sync, 18 unwired are vacate, batch-drain and
administration.

**"The aggregator slice is unwired" was imprecise in exactly the way the sync claim was.** A module
is not a screen, and per-module coverage hides which HALF is missing:

```
AQP-ANK   6/6      AQP-SCR  14/17      AQP-POOL 11/29      AQP-FVT 2/23
```

### The duplicate — found by negative-testing, not by reading

Deleting all three syncs from `ALL_ANCHOR_SPECS` **did not fail** the new coverage check.
`aqpConsumerSpecs.tsx` defined the same three entrypoints, exported, inventoried, and imported by
nothing — the screens use `anchorSpecs`. They had **already drifted**: the dead copy labelled the
non-fungible sync "NFT" where the live one says "collectable", so the inventory described a button
whose wording no screen used.

**A second definition does not merely rot — it restores the appearance of something deleted.** That
is the worse failure, because the lie is told by a PASSING test. Removed, and
`spec-entrypoints-are-unique.test.ts` forbids the shape; re-running the mutation that was masked
now fails, which is the proof the mask is gone.

`ALL_AQP_CONSUMER_SPECS` is 13 → 10.

### Verification

UI **1,146 tests, 72 files**, typecheck and build clean. Eight corruptions tested across the three
new checks, all caught — including the vacuity cases (empty registry read, stale field pattern) and
the masking case that started it. No Pact touched; gate stands at 26,815.

## Round 9 — the check written to stop coverage being remembered was itself remembering

`aqp-surface-coverage.test.ts` hardcoded its module set as `(ANK|SCR|POOL|FVT|VCT)`. Measured
against the registry:

* **`AQP-VCT` is not a registry module at all** — I invented it.
* **`AQP-DSA` (9) was missing** — the Delegated Aggregators, which is a whole AREA of this UI.
* **`MTX-AQP` (2) was missing** — defpact continuations.

So the file I had just written to stop coverage being *remembered* was reporting a **remembered
scope**, and under-counted the surface by 11. Exactly the failure CLAUDE.md records about
`_toolpaths.py`: *"the sentence added to warn against under-enumeration under-enumerated."*

The module set is now DERIVED from the registry, and an unrecognised AQP module fails the test —
a hardcoded list cannot report its own incompleteness, so the fix is not a longer list.

**Continuations are named, not filtered silently.** `MTX-AQP|2|CC_Inject` is step 2 of a defpact:
the client signs the starter and the step follows, so counting it as an unwired operation would
overstate the gap by two forever. The old regex dropped nine DSA entrypoints with no such note,
which is the difference between a decision and an omission.

### A second gap, found by the negative test rather than by reading

Removing the continuation filter **did not fail** anything: the leaked entries landed in an
`MTX-AQP` tally bucket that no assertion named. Per-module expectations only check the modules
they mention, so a sixth key is unasserted by construction. The tally's KEY SET is now pinned
first — which catches both a new module appearing and a continuation leaking in. Re-running the
mutation now fails.

### Corrected surface

```
AQP-ANK 6/6    AQP-SCR 14/17    AQP-POOL 11/29    AQP-FVT 2/23    AQP-DSA 0/9
```

84 client entrypoints, not 77. Handoff updated with the numbers and with *"do not hand-count
this"*.

UI **1,147 tests, 72 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

---

## Pattern across rounds 6–9, worth stating once

Four consecutive rounds found defects **in work from the round immediately before**, and in every
case the defect was invisible to the check that round had added:

| round | added | what it could not see |
|---|---|---|
| 5 | the manager + specs | four controls the page could not fill |
| 6 | a fillability check | that it knew only one spec file and one page |
| 7 | a tree-wide version | a duplicate spec masking a removal |
| 8 | a coverage measure | that its own module set was hardcoded and wrong |

The common shape: **a check scoped by a list its author wrote**. The fix each time was to derive
the scope from something external — the registry, the import graph, the objects themselves — and
to fail on anything unrecognised rather than skip it. Every one of these was found by MUTATING the
code and watching the test stay green, never by re-reading it.

## Round 10 — the AQP slice had never been rendered in a test

Every test covering this work read SOURCE: it asserted a file contained a branch, a prop, a
string. Useful, and blind to what a user actually sees. **There was no render test for AQP at
all** — the first one is `aqp/__tests__/ScoreDetail.render.test.tsx`.

**Why there wasn't one is worth knowing**, because it is a trap for the next attempt: importing
`ScoreDetail` pulls `useWallet`, whose context pulls `request-user-pass`, which renders a Lottie
animation whose player touches `getContext()` at IMPORT time. In jsdom the suite dies before a
single test runs, with `TypeError: Cannot set properties of null (setting 'fillStyle')` — which
reads like the component is broken rather than the environment. One `vi.mock("react-lottie")`
fixes it.

### Two of my own mistakes, both only visible once something rendered

**The fixture id was too short to test the property.** `SCR-lpb` is eight characters and fits any
column, so "shown in full" and "truncated" are indistinguishable with it. Swapped for a real
mainnet id with its 12-character block-hash suffix.

**`getByText(id)` failed with "found multiple elements"** — and the report was CORRECT: the header
shows the id truncated as a subtitle and the copy row shows it whole, by design. The assertion was
badly aimed, not the UI. It now reaches the copy row through its label and checks the class is
`break-all` and not `truncate`.

That second one is the case for render tests in one line: **no source grep can tell you an element
is clipped.** Negative-testing confirmed it — changing `break-all` to `truncate` in `EntityId`
fails here and nothing else in 1,153 tests notices.

Four corruptions tested, all caught: zeros shown as a position, totals hidden, id truncated, id
row removed.

UI **1,153 tests, 73 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

**This is a better use of a blocked session than more static audits** — rounds 6–9 each found a
defect in the previous round's tooling, which is a signal of diminishing returns; this found a
whole category of verification that was missing.

## Round 11 — render tests for the manager, and the second import-chain obstacle

Extended round 10's missing category to the screen the owner will actually click through.

**There were TWO obstacles blocking AQP render tests, not one**, and between them they explain why
the slice had none. Each fails at IMPORT, before any test runs, and each reads like the component
is broken rather than the environment:

```
react-lottie          reaches getContext() at import; jsdom has no canvas
RegistryOpCFMModal    pulls src/lang-pact/pact.grammar — a Lezer grammar the app builds through
                      a vite plugin and vitest cannot parse as JS
```

Both mocked. The modal in particular is not what the file tests — what it RECEIVES is already
checked exhaustively against the deployed registry in `score-op-specs.test.ts`.

### The assertion worth having, and why only a render can make it

`Btn` shows its `reason` in place **only when disabled** — a rule the user has no other way to
learn. Deleting that one line is invisible to every source grep in the suite: the `reason` prop is
still passed, the spec still names it, the button still renders. Negative-tested: removing it
fails two assertions here and nothing else in 1,161 tests notices.

### My fixture was wrong again, in the same way as last round

The first version left every one-time link `null`, so **nothing was refused**, no `reason`
rendered, and the test asserting the explanations failed against a perfectly correct screen. A
fixture that cannot reach a branch tests nothing about it — which is the second time in two rounds
that the test DATA, not the test logic, was the defect. Worth watching for: when a render
assertion fails, check whether the state it needs was actually constructed before suspecting the
component.

Five corruptions tested, all caught: refusals made hover-only, a refusal made generic, the triplet
guard no longer naming the count, the blocked-three panel hidden, and the empty state no longer
distinguishing owning a score from earning in one.

UI **1,161 tests, 74 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

## Round 12 — render coverage completed for the scores work

`ScoresTab` was the last screen from this round with no render test. It is also the one the owner
reported on, and the one where being WRONG is worse than being absent: a boost chain drawn as a
triplet tells a holder they have one aggregator member when they have three, which is a false
statement about how they get paid.

Nine assertions on what reaches the screen — the grouping, the hub tag, the "not a registered
triplet" sentence, the "this group has no id" answer, the TRUE-triplet shape note, the shared
denominator, the id column, an ungrouped single, and the unbounded name width.

### Two assertion mistakes of my own, both instructive

**`/\bw-\d+\b/` matched `min-w-0`.** `\b` matches after a hyphen, so the pattern meant to forbid a
fixed width fired on the class that MAKES the fix work — a flex child will not shrink below its
content without `min-w-0`, which is what lets `truncate` do anything. Fixed with a lookbehind that
distinguishes `w-36` from `min-w-0`, and `min-w-0` is now asserted as REQUIRED rather than merely
tolerated.

**A fixture that could not distinguish two behaviours — for the third round running.** Mutating
`denoms.size === 1 ? … : null` to `members[0].lpDenominator` PASSED, because all three fixture
members shared a denominator and the two expressions agree there. Added the disagreement case,
which is a real screen state (nothing on chain forces a boost link's two ends to share a
denominator) and renders a visible difference: no denominator line at all, because asserting one
on a majority would put a wrong token id on screen.

**That is three rounds in a row where the test DATA was the defect, not the test logic.** The
pattern is worth naming: after writing a negative test that passes, the first question is whether
the fixture can reach the branch — not whether the assertion is too weak.

Five corruptions tested on the first pass (4 caught), the fifth caught after the fixture was
fixed: chain called a triplet, id predicted, grouping bypassed, fixed-width name, denominator from
majority.

UI **1,170 tests, 75 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

### Render coverage for the scores work is now complete

```
ScoreDetail   6 assertions   the no-pool branch, totals, the id shown in full
ScoresMgmt    8              refusals explained in place, blocked three, empty state
ScoresTab     9              the chain grouping and everything it must not claim
```

Before round 10 this was zero. The category existed nowhere in AQP, and two import-chain
obstacles (`react-lottie`'s canvas, `RegistryOpCFMModal`'s Lezer grammar) are why — each kills the
suite at import in a way that reads like a broken component.

## Round 13 — the shared primitives, which carry both slices

Rounds 10–12 covered the three SCORE screens. The higher-leverage target was underneath them:
`shared/ui.tsx`. Both the boosters and the scores screens draw every refusal, every id and every
loading state through it, so a regression there is a regression everywhere at once.

**Measured evidence it was the right target:** deleting `Btn`'s in-place reason broke exactly two
assertions in the whole suite, and both were in a ScoresMgmt test written the round before. The
BOOSTER screens — live on mainnet, in daily use — rely on the identical line and had nothing. The
assertions now sit on the component rather than on one accidental consumer.

Eleven assertions over five primitives, each pinning a rule the component's own comments state and
nothing verified:

* **`Btn`** — the reason renders IN PLACE when disabled, not only as a tooltip. A rule the user has
  no other way to learn must not depend on hovering, which a touch device cannot do at all. Also
  that the button is genuinely `disabled`, not merely styled so.
* **`StaleBadge`** — NEVER SYNCED / TIER DRIFTED / "reads as 0" stay three distinct states with
  three different remedies, and a FRESH row renders nothing at all.
* **`EntityId`** — `break-all`, never `truncate`.
* **`ReadGate`** — the one that matters most: a PENDING read must not render as "you have nothing",
  because that is a statement about the USER and it turns a slow node into an empty wallet. A
  FAILED read names the module, because while a slice is being wired the likeliest cause is that
  the reader is not deployed on the chain the wallet points at. And `data === null` with no error
  and no loading is reported as impossible rather than hidden behind an eternal spinner.
* **`EmptyState`** — explains rather than reporting nothing.

Six corruptions tested, **all caught on the first pass** — the first round in four where neither
the fixture nor an assertion of mine was wrong.

UI **1,181 tests, 76 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

## Round 14 — the booster detail, and eight strings the rename missed

Covered `AnchorDetail` — the LIVE screen, in daily use for rounds while every test on it read
source. The behaviour worth pinning is the `manage` SLOT: one component serves a holder who merely
EARNS from a booster and an owner who may revoke it, and the authority decision lives with the
caller. Rendering the control unconditionally would hand every viewer a button they cannot use,
and no source grep distinguishes "renders a slot" from "renders it only when given one".

Also extracted `_entityId.ts` — the walk that reaches the labelled copy row. An id legitimately
appears TWICE on a detail screen (truncated in the header, whole beside the copy button), so
`getByText(id)` throws "found multiple elements". Two copies of that walk would be two chances for
the detail screens to disagree about what "the id row" means.

### A negative test that passed for a GOOD reason, and what it uncovered

Hiding the revoked banner did not fail — because the header Tag still says "revoked". Two
independent signals, so the property "a revoked booster is identifiable" genuinely survives losing
one. A true negative, not a gap.

But reading that banner closely showed it said **"This anchor is REVOKED"** — the noun the rename
replaced months ago. The vocabulary test walks those six files for the VERB only; the NOUN rule was
scoped to the infomatic maps. **Eight user-facing strings still called a booster an anchor, on
screens that are live, and every test passed:**

```
AnchorDetail   "This anchor is REVOKED."
AnchorsTab     "this anchor is revoked — syncing sets it to 0"
AnchorsMgmt    "An anchor appears here once you issue one…"
anchorSpecs    "Revoke this anchor"  (a modal TITLE)
               "The anchor stops growing but does not vanish…"
               "AQP-Pairs → Anchors → My anchors"  (a breadcrumb, also a stale nav label)
               "Repairs EVERY anchor standing on this asset…"
               "the asset, not the anchor."
```

The noun rule now walks all six files. **Matched as ARTICLE + NOUN**, which separates the parts of
speech mechanically: "an anchor" is the thing, "you may anchor" is the act, and the contract's own
identifiers (`anchorId`, `revoke-anchor`) have no space before the word so they cannot match.
Comments are stripped first — they discuss the chain, where `anchor` is correct.

Negative-tested four ways, including the two that matter most: **the over-correction** (scrubbing
the verb fails) and **an identifier** (`theAnchorFor` must NOT trip it).

UI **1,193 tests, 77 files**, typecheck and build clean. No Pact touched; gate stands at 26,815.

**Lesson worth carrying:** a rule applied to one file set and a vocabulary applied to another will
diverge silently, and the gap is invisible precisely where the rule is not looking. Five of these
eight were in `anchorSpecs.tsx` — a file the verb rule already walked.
