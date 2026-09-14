# `C_Slumber` mints a sleeping nonce that `C_Unsleep` cannot read

**Date:** 2026-09-12 · **Status:** **FIXED 2026-09-12, owner-ruled.** Pinned by
`modules/VST.repl <<VST-G7 · 03>>`, `<<VST-09>>` and `<<VST-11>>`.
**Sites:** `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact` — the `C_Slumber` write path vs the `C_Unsleep`
read path

## What happens

`VST|C_Unsleep` on a slumber-merged nonce reaches **no guard at all**:

```
Runtime typecheck failure, argument is list , but expected type
list (object{ouronet-ns.VestingV2.VST|MetaDataSchema})
```

## Why

Two operations write **different metadata shapes** into the same column of the same token.

| minted by | `meta-data-chain` shape |
|---|---|
| `C_Sleep` | `[{"release-amount": …, "release-date": …}]` |
| `C_Slumber` (merge) | `[{"mint-time": …, "release-date": …}]` |

`VST|MetaDataSchema` is the **first** shape, so the merged row fails Pact's runtime typecheck on the
way into the unsleep path — before any `enforce` in `VST|C>UNSLEEP` is consulted.

`mint-time` is **hibernation** metadata. That is consistent with the finding `VST-08` already records —
*"SLUMBER is the HIBERNATION merge, not the sleeping one"* — here applied to a sleeping token, and this
is the downstream cost of it.

## Consequence

On the suite's own chain, `Z|MOCKA` nonce 3 — minted by `C_Slumber` merging nonces 1 and 2 in `VST-07`
— is **in circulation, held by a real account, and permanently un-unsleepable**. Not a timing matter:
it fails at the suite's clock and at a rewound clock alike, which `VST-G7` pins both ways. The holder's
only remaining exit is `RepurposeSlumber`.

## Candidate fixes — both behavioural, so both wait

1. **`C_Slumber` writes `release-amount` metadata** for a sleeping token, keeping `mint-time` for the
   hibernation case. Matches the shape the rest of the sleeping path expects.
2. **The unsleep path accepts both shapes.** Wider, and it spreads the dual-shape assumption rather
   than removing it.

(1) is the narrower change and the one the data model implies, but it alters what a paid client writes.

## How it was found

Not by reading, and not by looking for it. `VST-G7` needed a **live** sleeping nonce for an unrelated
assertion, and picked the first with a positive supply at runtime rather than hardcoding one — which
landed on nonce 3. Hardcoding a nonce that happened to work would have hidden this completely.

**Choosing fixture rows by a predicate instead of by literal is worth the extra line.** It found this,
and the same habit earlier caught nonce 1 of the same token being out of circulation (supply `-1.0`,
holder `BAR`) — a second state a hardcoded choice would have silently depended on.

---

# THE FIRST DIAGNOSIS WAS WRONG — and acting on it would have broken the hibernation path

This is the part worth keeping. The original write-up above says *"two operations write different
metadata shapes"* and proposed **"`C_Slumber` writes `release-amount` for a sleeping token"** as the
narrower fix. **That would have been a mistake.**

`XIv_MergeNonces` already branches correctly on its `vzh-tag`:

```pact
(if (= vzh-tag 2)
    [ {"release-amount" : locked-amount, "release-date" : release-date} ]      ;; SLEEPING
    [ {"mint-time" : (at "block-time" (chain-data)), "release-date" : release-date} ])  ;; HIBERNATING
```

and the four callers are deliberate: `C_Merge`/`C_RepurposeMerge` pass **2**, `C_Slumber`/
`C_RepurposeSlumber` pass **3**. Changing what `C_Slumber` writes would have broken hibernation
merges to fix sleeping ones.

## The real fault was one level up: neither cap checked the TOKEN KIND

`VST|C>MERGE` and `VST|C>SLUMBER` both compose `VST|X>MERGE`, which validates only the merger's
account. **So the metadata shape was decided by which CLIENT the caller picked, not by what the TOKEN
is.** `VST-07` called `C_Slumber` (tag 3) on a SLEEPING token and stamped hibernation metadata on it.

## The fix, in two parts

1. **Kind guards on the two MINTING caps**, using the prefix idiom already established at
   `02_SCORE.pact:2522/:2526`:
   ```pact
   (defcap VST|C>MERGE   (…) (enforce (= (take 2 dpof) "Z|") "Merge requires a Sleeping DPOF")   …)
   (defcap VST|C>SLUMBER (…) (enforce (= (take 2 dpof) "H|") "Slumber requires a Hibernating DPOF") …)
   ```
2. **Callers corrected** — `modules/VST.repl` VST-07 and `vst-harness.repl` now call `C_Merge`,
   the right client for sleeping nonces.

**Deliberately NOT added to the REPURPOSE pair.** `C_RepurposeSlumber` is the only exit for a row
that was already minted wrong; guarding it on kind would strand exactly the holders this fix exists
to protect. The minting caps stop new bad rows, the repurpose path stays open for existing ones.

## Proof the stuck value is returned

`VST-11` used to assert the release was impossible. It now asserts it **succeeds**, and `VST-G7`
asserts the receipt — supply `-1.0` (decommissioned) where it previously read a stranded `200.0`:

```
Succesfully unsleeped DPOF Z|MOCKA-98c486052a51 Nonce 3 on Account ...
```

## How the wrong diagnosis was caught

By applying it. The kind guard made the suite **fail to load** — because every call site in the tree
was passing a sleeping token to `C_Slumber`. Had the guard been silently satisfied, the mistaken
"fix the writer" theory would have survived. **A fix that breaks the suite is information, not a
setback** — here it said "the callers are wrong, not the writer."

Worth noting a measurement trap it exposed: `grep -c FAILURE` returned **0** for a run that had
actually died. A hard load failure emits no `FAILURE` lines at all, so counting them is not a
sufficient check — always confirm `Load successful`.
