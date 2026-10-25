# HANDOFF — AQP collectable (NFT/SFT) staking UI + score staleness wiring

**Opened** 2026-10-18. **CLOSED 2026-10-19 — all six steps shipped as v2.18.7 (`30b1a41`, dev + master).**

> **DONE:** reader; both Unstale buttons wired; NFT/SFT stake + unstake views; 4 stale
> `PENDING_WIRING` lines removed; brittle proximity assertion made structural; modal lazy-loaded.
> Gate: 141 test files all passing, typecheck 0, lint 0 errors, build 44.5s. **No Pact deploy was
> needed.** Sections 1-6 below remain accurate as REFERENCE for how it works; section 7-8 are
> superseded by the Residual list at the end of this file.
**Repos:** `_onchain/Ouronet` (Pact, read-only for this task) · `daimons/OuronetUI` (all remaining work).

---

## 0. SCOPE AGREED WITH OWNER

* **IN:** wire **NFT stake / unstake** views on the UI + wire the **unstale** button(s).
* **DEFERRED (owner's call):** modifying the Pact so an SFT stake can take a PARTIAL per-nonce
  amount. Today the stake entrypoint accepts no amounts at all. Not a priority; revisit later.
* **NO PACT DEPLOY IS REQUIRED** for anything below. Every chain function used is already live
  (verified three ways: present in `HEAD` so predating the uncommitted sweep; `AQP-POOL` and
  `DPDC` both `deployed: true`; registry livecheck confirmed against mainnet 2026-10-18).

---

## 1. WHAT IS DONE — the stake-side reader (committed? NO, uncommitted in OuronetUI)

Files touched:

| File | Change |
|---|---|
| `src/lib/aqp/poolChain.ts` | `poolCode.stakeableCollectable(poolId, account, son)`; types `StakeableCollectable` / `StakeableNonce`; decoder `fromPoolChain.stakeableCollectable` |
| `src/lib/aqp/usePoolReads.ts` | hook `useStakeableCollectable(poolId, aqpClass, account)` — tier **T4** |
| `src/lib/__tests__/pool-chain.test.ts` | +8 tests (46 pass in file) |

Generated expression:

```pact
(let* ((p:string "<POOL-ID>")
       (asset:string (ouronet-ns.AQP-POOL.UR_AQP|PoolAssetId p)))
  { "asset"     : asset
  , "class-ok"  : (ouronet-ns.AQP-POOL.URC_StakeCollectablePoolClassOk p false)
  , "matches"   : (ouronet-ns.AQP-POOL.URC_StakeCollectableMatchesPool p asset)
  , "admission" : (ouronet-ns.AQP-POOL.URC_PoolStakeAdmissionOk p)
  , "held"      : (ouronet-ns.DPDC.URH_AccountNoncesWithSupplies "<ACCT>" asset false)
  })
```

Three design decisions, keep them:
1. **The pool picks the collection, not the user.** `URC_StakeCollectableMatchesPool` enforces
   `collectable-id = UR_AQP|PoolAssetId`, so the asset is read FROM the pool and reused for the
   holdings lookup rather than taken as a parameter a caller could get wrong.
2. **`son` is DERIVED from `aqp-class`**, never passed alongside it. Contract defines the
   correspondence: `URC_StakeCollectablePoolClassOk` → `son=true`→class 3 (DPSF),
   `son=false`→class 4 (DPNF). Accepting both invites the one combination that is always wrong.
3. **The three verdicts stay SEPARATE, not pre-ANDed.** "Re-scoring in progress" and "this pool
   does not accept this kind of collectable" are different sentences; one boolean says one.

**`supply` is a COUNT, not a spendable ceiling** — the stake path has no amount argument.

---

## 2. THE UNSTAKE SIDE WAS ALREADY BUILT — do not rebuild it

`poolCode.positions` already calls all four `URH_AQP|Dp{sf,nf}StakesBy{Owner,Beneficiary}`
enumerators, and `positionLegs` already decodes them to `PoolPositionLeg` with
`kind: "sf" | "nf"`, `nonce`, `balance`, `balanceRaw`, `owner`, `beneficiary`, `kindOfPosition`.
`useMyPositions(account)` returns them. `balanceRaw` is the exact decimal for the amount ceiling.

**`src/__tests__/spec-fields-are-fillable.test.ts:100` `PENDING_WIRING` is STALE** where it says
`UNSTAKE_*: "pools has no position list: no reader enumerates occupied trackers"`. That reader
exists and already feeds the Position tab. **Those 6 lines must be deleted when the views land,
or the suite fails** (that is the tripwire's intent).

---

## 3. THE FOUR ENTRYPOINTS (deployed, registry-indexed, single-tx `direct`, no defpact/hydra)

```
TS02-C3.AQP-POOL|CC_StakeSemiFungibleCollectable    (patron executor executee pool-id collectable-id nonces)
TS02-C3.AQP-POOL|CC_StakeNonFungibleCollectable     (patron executor executee pool-id collectable-id nonces)
TS02-C3.AQP-POOL|CC_UnstakeSemiFungibleCollectable  (... nonces nonce-amounts)
TS02-C3.AQP-POOL|CC_UnstakeNonFungibleCollectable   (... nonces nonce-amounts)
```

**Specs ALREADY EXIST**, registry-validated, all four carrying `previewValues: ownerBeneficiary`:
`src/constants/aqpConsumerSpecs.tsx:189` `STAKE_SEMI_FUNGIBLE`, `:209` `STAKE_NON_FUNGIBLE`,
`:284` `UNSTAKE_SEMI_FUNGIBLE`, `:305` `UNSTAKE_NON_FUNGIBLE`.

### THE EXEC↔PREVIEW ROTATION (real, but already defused — do not "fix" it)

| slot | exec | preview |
|---|---|---|
| 2 | `executor` | `pool-id` |
| 3 | `executee` | `owner-id` |
| 4 | `pool-id` | `beneficiary-id` |

Same arity, all `string`, so a POSITIONAL splat type-checks and prices a different question.
The repo binds **by name** (`buildCall`/`buildPreviewCall`), `previewValues: ownerBeneficiary`
performs the rename, and `src/lib/previewArgs.ts:68` refuses when a shared name moves
(*"reorders a shared parameter, so position cannot be trusted"*). Three layers. Leave them.
A repo-wide scan found **58** such permutations (DPSF 22, DPNF 22, AQP-POOL 9, DPTF 4, DPOF 1) —
documentation asymmetry, **not** 58 live bugs. The ONE positional-binding file is the old-era
`src/lib/swp/addLiquidityModes.ts`; do not copy that pattern.

### Stake takes the WHOLE holding
`04_TS02-C3.pact:2175` polls `(ref-DPDC::UR_AccountNoncesSupplies executor collectable-id true nonces)`.
No partial-amount stake exists on this path. The UI must NOT offer an amount field on stake.
Unstake is the reverse: `nonce-amounts` IS caller-supplied (owner no longer holds the tokens),
and `(= (length nonces) (length nonce-amounts))` is enforced in two places.

### Registry ghosts are shape-invalid for unstake
`nonces` ghosts to `[1,2]`, `nonce-amounts` has no `byParam` entry → falls back to `[1]`.
Do not prefill a form from ghosts. Same class of gap: `C_IssueNonFungibleAnchor`'s ghost sets
`anchor-precision: 1`, which the chain rejects (must be exactly 3).

---

## 4. SCORE STALENESS — settled

### Detection EXISTS and covers BOTH causes. Nothing new needed.
`14_O-UI-FOURTEEN.pact:292` → `"needs-sync" : (ref-SCR::URC_U-SCR|UserScoreDebStale account pool-id score-id)`
→ decoded at `poolChain.ts:674` as `needsSync`.

There is **NO stored stale flag** — it is a derived equality: stored `deb-score` ≠ what the live
formula would write now. (`Audit/module-audits/AQP/M3-DEB-DESIGN.md:52` records a stored flag as a
proven dead end.) The predicate recomputes with **live deb AND live promile**, so it catches both
causes. Its `@doc` records the 2026-10-09 widening: it previously read the STORED boost while
recomputing only the tier, so it *"detected a DEB change and was BLIND to a BOOSTER change."* Fixed.

**A stale score REPORTS THE OLD VALUE** — not zero, not partial. So the screen shows a silently
wrong number and MUST warn. Design sanctions deriving live for display: *"UI derives live for
display only."*

### Causes (owner's model, confirmed)
1. **Elite-DEB moves** (EliteAuryn transfer/coil/curl).
2. **Anchor value changes** — staking/unstaking an asset that carries an anchor rewrites
   `ANK|T|UserBoost.aggregate-promile`, which is the `prom` term in every score linked to that
   boost class.

Stake phase 4 refreshes only `URC_PoolActiveScoreIds pool-id` — *the staked pool's* scores.
So staking a bunny (class-4 pool) refreshes that pool and leaves the LP triplet (class-0 pool)
stale. **A triplet's three legs are all employed on ONE pool** (`04_AQP-BOOT.pact:734`:
`C_AddScore × 3 — employ triplet on that pool`) — an earlier claim in this session that they live
in different pools was WRONG; `URC_ComputeTripletLanes` reads each leg's own `aqpool-link`
defensively, which is not evidence of different pools.

### Wiring status — THE ACTUAL REMAINING WORK
| Site | State |
|---|---|
| `PoolsTab.tsx:2105` pool-level panel | wired to real `CC_UnstaleMyScores` |
| `ScoresTab.tsx` "My score entities" batch bar | **DEAD — `onRun={() => {}}`** |
| `ScoreDetail.tsx:299` per-score Unstale | **DEAD — "not wired to a transaction yet"** |

**OWNER REPORTS (screenshot 2026-10-18): the only Unstale buttons visible are on My score
entities and its Details view — i.e. BOTH DEAD ONES. The owner does not see a pool-level unstale
at all.** So either the `PoolsTab` button is unreachable on the current nav path or it renders
only under conditions not met. **FIRST TASK NEXT SESSION: find out which**, before wiring —
`PoolsTab`'s button is gated on `staleFvtIds = pool.scores.filter(s => s.needsSync && s.fvtId)`,
so it is hidden whenever nothing is stale, which may be the whole explanation.

The mount to copy (`PoolsTab.tsx:2105`):
```tsx
<RegistryOpCFMModal open onClose={() => setOpenUnstale(false)}
  spec={UNSTALE_MY_SCORES} executor={account ?? undefined}
  supplied={{ "fvt-ids": staleFvtIds }} />
```
`UNSTALE_MY_SCORES` is `aqpConsumerSpecs.tsx:357`. `ScoresTab` ALREADY computes the right
argument: `const staleFvts = [...new Set(stale.map(r => r.fvtId).filter(Boolean))]`.
**The unit of repair is the FVT, not the score** — `CC_UnstaleMyScores(patron, executor,
fvt-ids:[string])`; one transaction mends every stale entity.

### The incentive to surface
If the user does not self-unstale, an inject force-fixes them and records
`FVT|ForcedFixCount`; at **collect** that becomes `ffc × CT_FORCED_FIX_RATE (10.0)` IGNIS, then
zeroes (`05_FVT.pact:3896`). **Self-unstale is FREE.** Predict the debt with
`RPS.URC_FvtUserStaleMemberCount(fvt-id, user-id) × 10.0`. Nothing currently tells the user
refreshing saves money — add it.

### Parallelism contract (do not fan out the wrong one)
| entrypoint | shape | parallel |
|---|---|---|
| `CC_UnstaleMyScores` | single tx | — |
| `CCp_FvtFixSlice(patron, fvt-id, reward-dptf-id, users)` | fed-slice | **YES**, disjoint lists |
| `CCp_UnstaleAll` / `CCp_InjectFixChunk` | `take chunk` of shared list | **NO** |
| `CCp_SweepRecomputeChunk(patron, anchor-id, chunk)` | cursor pager | **NO** |
Two concurrent chunk calls *"record the 2e forced-fix penalty TWICE for those users, which is not
merely wasteful — it overcharges the holder."*
Anchor retire/re-price lifecycle: `CC_SweepBegin` → N× `CCp_SweepRecomputeChunk` **one at a time**
→ `CC_ClearPoolSweep`. Both the chunk call and the clear are PERMISSIONLESS and subsidised, so a
holder can finish it themselves — say so in the UI or the freeze reads as a trap.
**A sweep blocks stake AND unstake** (`URC_PoolUnstakeAdmissionOk`); the schema comment at
`00_AQP-SCHEMAS.pact:403` still says "stake + collect" and is stale.

---

## 5. BOOST / ANCHOR DISPLAY — units settled

`02_SCORE.pact` computes `(floor (* base-for-boost (/ prom 1000.0)) p)` — divide by 1000, **no
`1 +`**. `README_SCORE.md:211`: *"ANK promiles are the bonus ALONE. A booster advertised at 5%
stores 50, not 1050."*

```
boostPercent    = promille / 10      // 50.0 -> 5%
boostFraction   = promille / 1000    // 50.0 -> 0.05
boostMultiplier = 1 + promille/1000  // 50.0 -> 1.05x
```
Read from `AQP-ANK.UR_UB|AggregatePromile(account, boost-class-id)`, or `my-class-total` /
`my-aggregate` in the O-UI-THIRTEEN slices.

**RENDERING NOTE:** owner asked for "5% → 0.05x". Bare `0.05x` reads as *multiply by 0.05*, i.e.
a penalty. Render **`+5% (×1.05)`** or `+0.05×` with the sign always present.

* Per-row `boosted-score` on chain is the **increment, not the total**
  (`14_O-UI-FOURTEEN.pact:37` warns it "would look entirely plausible on screen").
* Only `deb-score` is additive across legs. Never sum base+boosted+deb.
* Stacking is a SUM three times over (units × rate, across anchors in a class, across lanes).
* **NO CAP on a user's aggregate** (a single anchor's RATE caps at 10000‰). A passing assertion
  pins 104 OG SFTs at 5200‰ = +520%. **Do not draw a progress bar against a ceiling** — a field
  once named `max-promille` was renamed `total-promille` for exactly this reason.
* Anchor precision is **exactly 3**, always. `00_AQP-SCHEMAS.pact:43` and `README_ANK.md:46`
  both claim "2–8" and are both WRONG; `UEV_Promile` enforces `= 3`.

Bunny tiers (`04_AQP-BOOT.pact:520`) — bronze/golden are **BoostClass names, not bunny rarities**;
`02_KBunnies.pact` holds no boost logic, bunnies are the anchored ASSET of trait-anchors:

| BoostClass | Trait | ‰ | per bunny |
|---|---|---|---|
| BronzeSnakePower | Background = Ouroboros Rain | 50 | +5% |
| SilverSnakePower | Background = Auryn Rain | 100 | +10% |
| GoldenSnakePower | Background = Elite-Auryn Rain | 200 | +20% |
| GoldenSnakePower | Rarity = Legendary | 400 | +40% |
| UnityBooster | Eyes / Rarity | 100/300/900/1000 | +10…+100% |
| StoaBooster | Eyes / Rarity | 1000 / 3500 | +100% / +350% |
| VestaBooster | Red/Green/Blue Eyes, Legendary, RGB-set | 250 ea / 3500 / 1000 | +25% ea … |

GoldenSnakePower holds TWO anchors → an Elite-Auryn-Rain Legendary bunny gives 200+400 = 600‰.

---

## 6. UI PATTERN FACTS

* **`RegistryOpCFMModal.tsx` is a GENERIC registry-driven modal** and the only one
  collectables/orto/AQP ops use. Adding an entrypoint = an `OpSpec` object + a mount site.
  **No new React component is needed for the four staking ops.**
* Closest templates to mirror: `PoolsTab.tsx:1269 StakeLegsView` and `:2139 UnstakeLegsView`.
* For `nonce-amounts`, prefer `kind: "decimalPerNonce"` over `"supplied"` — the modal already has
  the per-nonce editor (precedent: `ortoOpSpecs.tsx:203`).
* `amountCeiling` must be the **staked** balance (`PoolPositionLeg.balanceRaw`), never the wallet
  balance, and must be the exact decimal string.
* Wrap every read in `ReadGate` (`aqp/shared/ui.tsx:863`): *"a read that has not answered yet must
  NOT render as 'you have nothing'."*
* Colours from `src/constants/assetColors.ts`: `FAMILY_COLOR.semiFungible` (#f9a8d4) /
  `.nonFungible` (#be185d), `POOL_COLOR.aqp` (#9f1239). Do NOT import `ROLE_COLOR` (file-local to
  `LiquidityBreakdown.tsx`, a different axis). Guard test: `asset-colors-canonical.test.ts`.
* Probably **no new route** — staking lives under `/app/aqp-pairs/:area/:side/:view/:entity/:sub`
  via `POOL_TABS` (`PoolsTab.tsx:109`). Nav: `nav-data.ts`; never conflate `url` and `section`.

---

## 7. OPEN / BLOCKING AT PAUSE

1. **ONE FAILING TEST** — `src/__tests__/aqp-mockup-coverage.test.ts` > *"the unstake console
   splits by LEG KIND"*. Caused by the uncommitted `amountCeiling` work (`PoolsTab.tsx`,
   `RegistryOpCFMModal.tsx`, `chain.ts`, new `src/__tests__/amount-ceiling.test.ts`), NOT by the
   reader — verified by path-scoped stash: with those three stashed, 92/92 pass. The assertion
   matches `spec={UNSTAKE_TRUE_FUNGIBLE}` within a bounded CHARACTER DISTANCE and the inserted
   comment lines pushed the token outside the window. Fix = widen/structuralise the regex.
2. **OuronetUI working tree is UNCOMMITTED** — the reader + the `amountCeiling` work. Last commit
   is `c149797` (v2.18.6), pushed to dev+master.
3. Owner cannot see a pool-level Unstale button (see §4) — diagnose first.
4. Verify with one `/local` that `URH_AccountNoncesWithSupplies` is in the DEPLOYED DPDC.

### Carried over from earlier in the session (unrelated to this task)
* `_onchain/Ouronet` has **359 uncommitted files** — the 2026-10-12 interface-membership sweep +
  version cascade, the Frozen LP fix, and regenerated `Deploy/`. Gate is GREEN over all of it
  (93 entrypoints, 28,526 assertions). Held back pending owner's go-ahead; the Frozen LP fix
  cannot be separated from the cascade it depends on.
* `@stoachain/stoa-core` needs a release: `isHealthy` probes `${host}/info` while reads go to
  `/chain/N/pact`, so a 502 gateway reads as "recovered" and the node pair flaps. v2.18.6 makes
  the app resilient to it; the probe itself is still wrong and its source is not in this workspace.
* Multi-step liquidity still previews with the single-shot `infoCode` rather than
  `INFO_SWP|AddStandardLiquidity`.

---

## 8. NEXT SESSION, IN ORDER

1. Diagnose the missing pool-level Unstale button (§4) — likely just "nothing is stale".
2. Fix the brittle proximity assertion (§7.1) → green suite.
3. Wire the two dead Unstale buttons (`ScoresTab` bar, `ScoreDetail`) to `UNSTALE_MY_SCORES`,
   and surface the avoided penalty (`URC_FvtUserStaleMemberCount × 10.0`).
4. Build NFT stake + unstake views on `useStakeableCollectable` / `useMyPositions`.
5. Delete the 6 stale `PENDING_WIRING` lines.
6. Commit + push OuronetUI (v2.18.7).


---

## 9. RESIDUAL AFTER v2.18.7 (supersedes §7-8)

**Shipped**, so do not redo: the stake-side reader, both Unstale buttons, the two collectable
views, the `PENDING_WIRING` removals, the proximity-assertion fix, the lazy modal import.
The `STAKE_ORTO_FUNGIBLE` / `UNSTAKE_ORTO_FUNGIBLE` entries REMAIN in `PENDING_WIRING` and were
deliberately left alone — class 2 is out of this task's scope.

### Still open

1. **`_onchain/Ouronet` — 359 uncommitted files.** The 2026-10-12 interface-membership sweep +
   version cascade, the Frozen LP fix, regenerated `Deploy/`. Gate GREEN over all of it
   (93 entrypoints, 28,526 assertions). Awaiting owner's go-ahead; the Frozen LP fix cannot be
   separated from the cascade it depends on.
2. **`@stoachain/stoa-core` release needed** — `isHealthy` probes `${host}/info` while reads go to
   `/chain/N/pact`, so a 502 gateway reads as "recovered" and the node pair flaps. v2.18.6 made the
   app resilient; the probe is still wrong and its source is not in this workspace.
3. **One `/local` to confirm `URH_AccountNoncesWithSupplies` is in the DEPLOYED DPDC.** Verified
   from source and from `deployed: true` + today's livecheck, but never asked of the chain. The
   expression to paste is in §1. If it errors "no such member", that is the one thing here that
   would need a deploy.
4. **Multi-step liquidity** still previews with the single-shot `infoCode` rather than
   `INFO_SWP|AddStandardLiquidity`.
5. **Two copies of the descent-state `EXEMPT` allowlist** (`deep-linking.test.ts` and
   `anchor-op-specs.test.ts`) — adding `clGroupKey` required editing both, and the second only
   surfaced because the first was already green. Fold into a shared constant next time either is
   touched.

### Lessons paid for in this task, worth not re-learning

* **A comment is not evidence.** `PENDING_WIRING` said "no reader enumerates occupied trackers";
  the reader existed and had been feeding the Position tab for some time. Checking the tree would
  have saved a detour. Same class of error as trusting `LIVE-MODULES.json` over the chain.
* **Guards that measure prose break on prose.** A 200-character proximity assertion failed because
  a correct comment was added, and reported a defect that was not there.
* **Place state in the component that renders the mount**, not the one that resolves the data —
  this was got wrong twice in one sitting (`MyScores` vs `MyScoresList`, `ScoreDetail` vs
  `ScoreDescent`).
* **Never read and write a file in one expression** — `io.open(p,"w").write(io.open(p).read()...)`
  truncates to zero bytes before the read runs. `version.ts` was lost this way and restored with
  `git show HEAD:<path>`; the changelog guard is what caught it.
* **Do not pipe `git push` to /dev/null when you intend to verify the result** — six "failures"
  were unexplained because the error was discarded; the retry that captured stderr succeeded
  immediately.
