# A score is not tied to an asset — it is tied to its definitions

*2026-10-06. Raised by the owner after issuing `WonderCoach-nK4O_C00so9w` and finding that the
issue form never asked which collection the score was for; the collection id was only requested
later, when writing the per-nonce weights.*

## The question

> "Didn't we make an architectural mistake by not defining the asset id the score is tied to at
> issuing time? What if I had chosen `sft-equality true` — how does the score know what collection
> it is tied to?"

## The answer: no, and the schema says so in as many words

`SCR|Schema` (`00_AQP-SCHEMAS.pact`) carries no asset field, deliberately:

> *"Identity: No separate scr-asset on the score. Staking asset is defined on the AQP pool.
> Resolve Score -> aqpool-link -> Pool -> asset-id."*

**It could not be otherwise.** A class-0 LP pool legitimately credits several token ids — native
LP, sleeping OF, frozen TF — through ONE score. A single `asset-id` column on `SCR|Schema` makes
class 0 unrepresentable. The asset lives on `AQP|Schema` (`asset-id` + `aqp-class`), and one pool
employs up to seven scores.

**The chain closes at three points, all enforced:**

| where | what is enforced | site |
|---|---|---|
| pool employs score | `score-class == aqp-class` | `03_AQP.pact:2247` |
| stake | `collectable-id == pool.asset-id` | `05_FVT.pact:1102`, via `URC_StakeCollectableMatchesPool` |
| weight lookup | keys on that same enforced id | `URC_SignedBaseDeltaForDpsfStake` |

So `sft-equality true` needs no asset: only the pool's canonical asset can ever arrive, and
"every unit counts 1" is complete without naming it.

## The real gap, which the question found by walking into it

**The definition-WRITE path validates the asset id for EXISTENCE only.** `SCR|C>ISSUE-SF-SCORE-
DEFINITION` checks `ref-DPDC::UR_NoncesUsed dpsf-id true` and `UEV_Nonce` — that the collection
and its nonces exist — and never asks whether that collection has anything to do with this score.
Same in both NF definition caps.

Combine that with **"an undefined nonce scores 0, it does not fail"** and the failure is silent
end to end: mistype the collection id, 34 structurally valid rows are written, the transaction
is green, and the weights are never read. **A dead definition and a live one are
indistinguishable from every screen.**

Two reasons it cannot simply be enforced:

1. At definition time `aqpool-link` is usually still BAR — scores are issued before pools
   (AQP-BOOT step 6 issues scores, step 7 creates pools). There is nothing to compare against.
2. The definition key INCLUDES the asset (`score-id | dpsf-id | nonce`), so one score holding
   definitions for several assets is legal and is what class 0 needs.

**The NF case is strictly worse and is NOT fixable by comparison.** A trait weight for a
`trait-key`/`trait-value` that no staked nonce carries is equally dead, and detecting it needs a
metadata scan of the whole collection, not an id comparison. The UI names the risk; it cannot
measure it.

## What was built (2026-10-06)

**Five module-only `URH_` readers on AQP-SCORE** filling the schema-ordered slots 3-7 that the
`[URH]` section comment had reserved and left empty:

- `URH_SCR|SFScoreDefinition (score-id dpsf-id)` — per-nonce rows, ascending
- `URH_SCR|NFTraitScoreDefinition (score-id dpnf-id)`
- `URH_SCR|NFClassScoreDefinition (score-id dpnf-id)`
- `URH_SCR|ScoreDefinedSemiFungibles (score-id)` — which DPSFs have definitions
- `URH_SCR|ScoreDefinedNonFungibles (score-id)`

They use `select` over the schemas' own "Select Keys" columns, not key-prefix parsing.

**THEY STARTED MODULE-ONLY AND ENDED IN THE INTERFACE — the reasoning is worth keeping, because
both answers were right at different moments.** Module-only was correct while they were a
read-only UI feature: the only consumer reached them as a **top-level client dot-read**, which is
safe (it resolves per call), and lifting them into `AcquisitionScoresV1` would have forced `V2`
plus a lockstep redeploy of all ten modules naming it — an absurd price for an inspection view.

Two things flipped it on the same day. The canon sweep already redeploys those ten, so the cascade
became **free**; and AQP-POOL needed `URH_SCR|ScoreDefined*` for the dead-definition guard, which
a dot call could not do — a dot call from INSIDE a module pins AQP-SCORE's hash and aborts with
"hash not blessed" on its next upgrade (`REPL/tools/_dotpin.py`). So `AcquisitionScoresV2` carries
all five. **The lesson is that "is the cascade worth it" is not a property of the change; it is a
property of what else is shipping.**

Pinned by `[6.2.2]_AQP-SCORE.repl` `<<TX-SCORE-15>>` — 10 assertions, including the non-vacuity
pair proving both arguments filter (a reader ignoring `dpsf-id` would return another collection's
rows, which is exactly the dead-definition case).

**UI**: `WeightTables` renders every table and marks each one `dead` / `matches pool asset` /
`unverified — no pool yet`. The query resolves the pool asset itself in the same round trip, so
the manager and client screens cannot disagree about whether a table is live. `ScoreAssetTieNote`
states the rule on the issue form and on both detail views.

## Done, and where the guard actually landed

`UEV_ScoreDefinitionTargetMatchesPool` is in **AQP-POOL**, not AQP-SCORE, and called from the three
Talos definition wrappers. Two constraints forced that, and both are easy to rediscover the hard
way:

1. **Deploy order.** AQP-SCORE loads BEFORE AQP-POOL. A score may never reference a pool; only the
   reverse. So the guard cannot live where the write happens.
2. **Heavy-read prefix canon.** The complete check — enumerate every asset the score has
   definitions for, reject any that is not the pool's — needs a `URH_` scan, which makes every
   caller in its tree heavy (`CC_`/`AA_` doubling) and drags a rename through Talos. The shipped
   guard asks the cheap half with **two point reads** and catches the case that actually bites:
   writing weights for the wrong collection on a score that is already employed, i.e. one that may
   already have stakers.

It no-ops while `aqpool-link` is BAR, which is the normal state at definition time. Pinned by
`[6.2.3]` `<<TX-POOL-01 GUARD>>` — **asserted on the MESSAGE**, because the fixture score carries
`sft-equality true` and would be refused for a second, unrelated reason. Mutation-tested: with the
guard removed the call still fails, with the sft-equality message. A bare `expect-failure` there
proves nothing.

`UEV_SemiFungibleScoreDefinition` was extracted as asked; the NF path had already done it, so SF
was the deviation.
