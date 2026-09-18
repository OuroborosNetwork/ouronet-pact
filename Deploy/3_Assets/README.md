# Asset tree — NOT YET GENERATED

This folder will hold the acquisition-pool asset tree: the AQP pool definitions, their issuance,
and the score/FVT wiring. It is deliberately empty.

## Why it is blocked

`AQP-BOOT.C_Step7_CreatePoolsAndScores` attaches **two** scores to `DHBloodshed` — the pure
`Bloodshed` score and `SubsidiaryBloodshed` — which the owner confirmed on 2026-09-18 is correct.
Applying that to the test fixture makes staking on that pool **abort**:

```
Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink
or reward DPTF                                          05_FVT.pact:1210
```

`C_Step7` makes `Bloodshed` *employed* by attaching it to a pool, but
`C_Step9_AddFvtScoreEntities` links only the five subsidiary scores plus coding, snakes and shares.
The pure `Bloodshed` score gets no FVT link, and the reward pipeline refuses an employed score
without one.

Two possible resolutions, and the choice is economic rather than mechanical:

- The pure score is fed by the collection's **internal NFT scores**, never through FVT — in which
  case the pipeline guard is over-strict and should tolerate an employed score with no FVT link.
- The pure score **should** draw FVT rewards — in which case `Step9` needs a tenth score and a
  treasury to pay it.

Generating this folder before that is settled would encode a wiring already known to be disputed,
so it waits.

## What it will contain when unblocked

`let` blocks that compute and thread ids, then call `AQP-BOOT.C_StepN`. **Not** re-implemented
logic.

The steps in `AQP-BOOT` are audited and run in the gate; the same logic rewritten into a deploy
script would be neither — and this repository already has a worked example of what that costs.
`TX-BOOT-07b` hand-rolled `C_Step7` and drifted from it, which is exactly how the missing
`Bloodshed` link stayed hidden.

So the `let` carries only what cannot live in the module: the ids. Most are deterministic
(`UDC_Makeid "DHCodingDivision"`), but asset ids carry a block-hash suffix (`DHCD-98c486052a51`)
that exists only after the issuing transaction — which is why the chained output-string /
input-string design is needed.
