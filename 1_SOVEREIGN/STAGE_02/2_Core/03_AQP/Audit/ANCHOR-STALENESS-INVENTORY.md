# Anchor / boost staleness inventory (eventual-consistency map)

**Why this file exists:** while fixing H5 (farm-triplet divisor scan) we confirmed a *system-wide*
"stale-until-restake" property: a user's stored score is a **snapshot taken at their last score
stake/unstake**, and nothing recomputes it when the *anchor* side changes. This is by design (you cannot
re-price N stakers cheaply), but every place that relies on it must be known so we fix the right ones
deliberately. Evidence gathered by the 4-way ANK/SCORE/FVT/VCT trace (2026-08-13).

## The core property (confirmed)

- **ANK aggregate promile IS maintained** on anchor-asset stake/unstake: `XE_Update*UserAnchorValues` →
  `XI_2|RecomputeAffectedBoostAggregates` → writes `ANK|T|UserBoost.aggregate-promile`. (`01_ANK.pact`)
- **But it never propagates into SCORE.** `SCR|UserSchema.{base,boosted,deb}-score` and
  `SCR|Schema.total-*-score` are written **only** by `XI_2|ApplySingularUserScoreDelta`, reachable **only**
  from the 7 stake/unstake legs. Doc `02_SCORE.pact:315-317` states it: *"updated on Stake/Unstake … not by
  bulk recompute when rules change."* No ANK code path calls back into SCORE.
- Net: change an anchor / boost-class-link / revoke → every affected user's stored score stays stale until
  **that user** next stakes/unstakes the score asset.

## Where staleness bites (inventory)

| # | Location | What is stale | Severity |
|---|----------|---------------|----------|
| S1 | **ALL boosted singular scores** — `SCR|UserSchema.deb-score` + `SCR|Schema.total-deb-score` | user's deb + pool total reflect promile as-of last stake; both stale together after any anchor/promile change | eventual-consistency (numerator+divisor both stored → self-consistent, just lagged). = **H4** |
| S2 | **Anchor revoke** — `C_RevokeAnchor` / `XI_RevokeAnchorBookkeeping` (`01_ANK.pact:1714/1805`) | never decrements holders' `aggregate-promile` nor zeroes `ANK|T|Anchors.promile`; dead anchor's boost stays baked in until some *other* live anchor in the class re-triggers a recompute for that user | **H4 (confirmed bug)** — revoke is worse than a plain promile change because nothing ever refreshes it |
| S3 | **Boost-link creation on a non-empty score** — `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE` / `…CREATE-BOOST-LINK-SCORE` / `…ENABLE-DEB-BOOST-SCORE` (`02_SCORE.pact:706/726/590`) | none enforce `nzs-count==0`/`totals==0`; linking after positions exist makes all prior stored scores stale vs the new link, and can even erase base (foreign-surplus branch) | **M4 (confirmed bug)** |
| S4 | **Vault/treasury & non-true triplets** — reward math branched on FVT class instead of the true-triplet flag | numerator/divisor basis mismatch → conservation drift | **FIXED ✅ (#25)** — now branches on `UR_SCR|TripletTrueTriplet` (any class): true → maintained lanes; non-true → Σ-of-3-deb (num+div); class-agnostic lane precision. Also corrected #8's class-based branch. Untested paths → Round III. |

Note: the **farm triplet** (S-of the old scan) is now FIXED — both numerator and divisor read the same stored
snapshot (`MemberUserWeight.contrib-weight` / `ScoreEntityLink.total-lane-weight`), so it joined S1's
self-consistent-but-lagged model instead of being the live-recompute exception.

## The agreed fix strategy (owner design, 2026-08-12/13) — for the whole S-cluster

Do NOT chase staleness with O(N) updates. Make the mutation that creates it either impossible or explicit:

1. **Lock anchor *definitions* while employed.** An anchor boosting any score employed in an FVT cannot have
   its promile changed / be revoked. Enforce via an **O(1) maintained usage counter** on the anchor (bump on
   link, only unlink at zero-state). Fixes S2's silent-stale (revoke simply blocked while in use).
2. **Virgin-only linking** — enforce `nzs-count==0` (or totals==0) before S3's three caps. Fixes M4.
3. **Reverse index** anchor/boost-class → scores (bounded by score *definitions*, not stakers) so an owner can
   enumerate "vacate pools X,Y,Z to change this anchor."
4. **Re-score sweep (later)** — to actually change a locked anchor: freeze pool → paginated walk that
   recomputes each position's score in place (no asset move, no user re-stake) → unfreeze. Reuses the VCT
   leg-walk shell + per-beneficiary dedupe; `AQP|T|DPSF/DPNFScoreAttribution.{cached-position-score,
   applied-def-revision-nonce}` already provide the recompute-diff primitive. Also enables a **paginated
   vacate** for large pools (the 10k-staker gas-ceiling problem).
5. **S4** — decide farm-style (both stored) vs live-both for vault triplets, or forbid vault triplets.

## ⚠️ UNFINISHED / future work — re-score-sweep-based anchor retire (owner decision 2026-08-13)

The **full** H4 fix has two halves:
1. **Lock while employed** — block revoke of an in-use anchor (O(1) counter). ← **BUILT NOW as a temporary patch
   (Fix #9).**
2. **A way to actually retire an employed anchor** — freeze the affected pools/scores, run the **re-score
   sweep** on-chain to zero/recompute the dependent scores, *then* allow revoke. ← **NOT BUILT YET.**

Because the re-score sweep (§ item 4 above) does not exist yet, half 2 is deferred. **Consequence of the
temporary patch:** once an anchor's boost-class is linked to a score, that anchor is **locked forever** (cannot
be revoked) until we build the sweep-based (or vacate-based) unwind. That is intentionally conservative —
safe, but stricter than the final design. **Revisit when the re-score sweep lands** and add the
freeze → sweep → unlink → revoke path (and the matching decrement on the lock counter). Marked **UNFINISHED**.

## Status
- **S-farm-triplet: FIXED** (this round, H5 — see `ROUND-02-FIXES.md` Fix #8).
- **S2/H4: TEMP-PATCHED (Fix #9)** — lock-while-employed only; sweep-based unwind UNFINISHED (see box above).
- **S1/H4-lazy, S3/M4, S4: OPEN** — candidates for this round. M4 (S3) is the natural companion to #9
  (virgin-only linking uses the same link-count mechanism).
