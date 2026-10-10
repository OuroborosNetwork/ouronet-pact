# Deploy/PureV6 — duration multipliers, the re-rate engine, and MANDATORY sleeping-LP custody

**11 transactions. Send 01 → 11 in order.** ~1.92 MB, ~534,000 gas in size charges; the largest
single transaction is ~230,000 of the 2,000,000 limit.

Each round in this folder family is kept **exactly as it went out**. Once a transaction is on
chain its file is a *record*, not a source: move it into `FROZEN` in `REPL/tools/_purev6.py`
rather than regenerating it, or `--write` will overwrite the bytes you signed.

## The round

| tx | modules | bytes | ~size gas | why it ships |
|---:|---|---:|---:|---|
| 01 | VST | 133,450 | 844 | **VST** — `XE_Unsleep` (the custodial unsleep, this module's first `XE_`), `URC_HibernationFeePromile` (the 800-promile decay, extracted from two inlined copies), and `URC_SpecialLegIssuerRestricted` (infrastructure grant vs owner intent) |
| 02 | IGNIS | 99,723 | 110 | IGNIS — the `backfill` deter key + 5 component prices |
| 03 | AQP-SCORE | 285,085 | 171,314 | **AQP-SCORE** — the 1.0 multiplier floor, `UC_MxForRemaining` (flat hibernation / decaying sleep), one weighting function on two clocks, special legs routed by LEG not score class, the sleep-term ledger, the 3-param multiplier setter, drain + raw-delta entrypoints |
| 04 | AQP-POOL | 234,044 | 43,058 | **AQP-POOL** — the re-rate engine, the 3-phase score revoke, the unstake freeze, the 3-param multiplier client |
| 05 | RPS | 297,384 | 230,247 | RPS — reward-engine changes + dot-pin re-pin |
| 06 | MTX-AQP, AQP-DSA | 84,080 | 33 | MTX-AQP + AQP-DSA *(dot-pin re-pin)* |
| 07 | **AQP-VCT** | 183,004 | 7,695 | **AQP-VCT** — `UC_VacateOrtoDestinations`, which stops vacate stranding a custodial position |
| 08 | AQP-FVT | 244,038 | 57,700 | **AQP-FVT** — custodial stake/release, the mandatory-custody guard, **beneficiary reassignment**, the parallel FVT fix slice, the pool-sweep release, two price readers |
| 09 | TS02-C3 | 145,309 | 1,531 | **TS02-C3** — the Talos surface for all of it (10 new entrypoints) |
| 10 | **AQP-INFO**, AQP-BOOT | 211,293 | 21,046 | **AQP-INFO** (10 new cost previews, 88 → 98) + **AQP-BOOT** (the late boot steps) |
| 11 | *(init)* | 2,505 | — | `create-table SCR\|T\|SleepStake` — **hand-written, run after 03** |

Every emitted upgrade carries **0 interface forms and 0 `create-table` forms** — the two ways an
upgrade burns the owner's gas. Verified on the emitted bytes, not on the sources.

**07 and 10 are no longer dot-pin re-pins.** They carried byte-identical modules in the previous
packing of this round and now carry real changes; the lines above say which.

## Load it in one go — `ROUND.multipact.json`

`Deploy/PureV6/ROUND.multipact.json` is the whole round as a single **Multipact manifest** for
OuronetUI's Execute-Code deploy queue. Load that one file instead of pasting eleven bodies.
Regenerate with `python3 REPL/tools/_purev6.py --multipact`.

It is **one file to load, still eleven transactions to send**, and that cannot be otherwise. The
size charge grows as the **seventh power** of transaction size, so this round as a single `exec`
would cost:

```
concatenated (1,872 KB) : 106,653,827,095 gas   ← 53,327× the 2,000,000 limit
eleven transactions     :        533,572 gas    ← fits
```

The split is not packaging; it is the only shape that deploys. What the manifest removes is the
eleven pastes — the part a human can get wrong.

The group is **`sequential`**, deliberately. `DOT_EDGES` in `_purev6.py` records the cross-module
dot-call edges this round must honour: a caller deployed before its callee's upgrade keeps the
*old* callee, and because those callees own tables it does not go stale — it **aborts with "hash
not blessed"** on some later, unrelated call. `parallel` submits everything at once and nothing
orders a miner's inclusion. Do not switch the mode.

Every transaction carries its own `sha256` and the manifest carries a body hash, because the
signer cannot read 1.9 MB of generated Pact. The reader refuses a mismatch.

## Two steps that are not module deploys

**TX 11 — `create-table SCR|T|SleepStake`.** A table added to an already-deployed module cannot
ride an upgrade (`create-table` aborts when the table exists, which is why both packers strip
them). Run it after 03. **If it is skipped, every sleeping stake aborts** on the first read — a
loud failure, but it means sleeping stakes are down until it lands.

**After the round — re-run `AQP-BOOT.C_Step0_WireImcAndGovernor`.** That is what calls AQP-FVT's
`P|A_Define`, which now registers FVT's caller guard on **VST's** IMP list. Without it
`XE_Unsleep`'s `P|UEV_IMC` refuses AQP-FVT and the custodial release aborts with *"None of the
guards passed"*. AQP's first reach into VST, so this registration has never existed before.

## No new interface, and that is a decision

Pact 5 resolves modref members against the **concrete module** at runtime — `module{Iface}`
constrains only what may be *assigned* — so none of the new functions needs an interface
declaration to be callable. `REPL/tools/_modref.py` (gate-fatal) records this as the repo's
convention, with **165 live instances** of exactly this shape; what it gates is the different
thing, a modref call to a member that exists in no implementing module (held at zero).

More importantly, changing `implements` on a *deployed* module breaks every not-yet-upgraded module
still annotated with the old interface, which across a ten-transaction round is a live window
where the whole AQP family aborts.

The gate *proves* no interface broke: the REPL deploys each module with its `implements` clause and
Pact refuses a module that does not satisfy it. **Green gate ⇒ all deployed interfaces still
satisfied.** Two renames (`CC_UpdateScoreMultipliers`, `AQP-FVT|CC_ClearPoolSweep`) are prefix-canon
corrections for functions that now reach table scans; neither was ever interface-declared.

## One BREAKING change for clients

`AQP-POOL|CC_StakeOrtoFungible` **now refuses a sleeping (`Z|`) batch on an aqp-class-0 pool.**
Those must go through `AQP-POOL|CCp_StakeSpecialCustodial` (renamed from `…SleepingCustodial`;
the release is `CCp_ReleaseSpecialCustodial`). Scoped to the **stake** direction only, so nothing
already staked is trapped:

```
"Invalid stake path: a sleeping leg that earns a duration multiplier must be staked under pool custody"
```

**Nothing else is affected.** Custody follows the MULTIPLIER, not the prefix: a `Z|` or `H|`
satellite on an aqp-class-1 pool, and any native DPOF, stay on the ordinary path exactly as
before. That scoping is load-bearing — those legs score **zero** (see the finding below), so a
prefix-keyed rule would have locked an asset for up to twenty-five years in exchange for weight it
never receives. DEFECT-LEDGER 8.39.

**`AQP-POOL|CC_UpdateScoreMultipliers` takes a THIRD argument** — `mx-hibernated`, which had no
setter at all before (issuance hard-coded 1.0 for every class but 2). Free to change because that
entrypoint is new in this round and not yet deployed.

**No multiplier may be set below 1.0, anywhere.** Issuance validated `> 0.0`, which admitted a
*penalising* 0.5 while the setter had always required `>= 1.0` — a value that could be issued and
then never updated to. Note `UEV_Fee` independently accepts `-1.0`, `0.0` and `[1.0 .. 999.0]`, so
the floor's real job is catching **0.0**, which clears the fee validator and would zero a leg's
entire weight.

Two Talos entrypoints were also renamed by the heavy/light prefix canon:
`AQP-POOL|CC_UpdateScoreMultipliers` and `AQP-FVT|CC_ClearPoolSweep`. Neither was ever
interface-declared.

Nothing on chain is affected today — there are no sleeping positions — but any UI or script that
built a `Z|` stake against the ordinary entrypoint must be repointed.

## What goes live, and what stays off until you turn it on

**Immediately live and safe:** the duration-weighted multipliers, the signed-floor fix, the
sleep-term ledger, the re-rate/drain engine, and the vacate destination fix. Nothing on chain needs
repair — every current position is native, and a native leg multiplies by 1.0 without reading `mx`.
Confirm:

```
(ouronet-ns.AQP-POOL.URHC_AQP|ScoreBackfillOutstanding "<pool-id>" "<score-id>")   -> []
```

**Newly possible, opt-in:** adding or revoking a score on a pool that has stakers; custodial
sleeping staking (LP *and* plain satellites); hibernating satellites staking at a flat
`mx-hibernated`; **selling a locked custodial position** by reassigning the beneficiary; setting
`mx-hibernated` at all; and the parallel FVT fix slice. All work the moment the round lands; none
happens unless somebody calls it.

Then: `python3 REPL/tools/_registrylive.py --record`.

## What changed about special-token satellites — read this before announcing

**Sleeping and hibernating satellites used to score ZERO, and now they score.** That was not a
documented limitation; it was three rules composing into something none of them stated:

- `UEV_AddScorePoolAndScore` enforces `score-class == aqp-class`, so a pool's employed scores all
  share its class;
- the orto score-delta dispatch handled score-class 0 and 2 **only**, falling through to an
  `"of-skip"` cumulator of 0.0 for anything else;
- `URC_StakeOrtoFungibleDpofMatchesPool` lets aqp-class 1 **admit** `Z|`/`H|` satellites, while
  aqp-class 2 admits native DPOF only.

So a satellite moved, was tracked, and earned nothing — and the score-class-2 path that did the
weighting was unreachable from any client. `mx-sleeping` and `mx-hibernated` were dead outside the
class-0 sleeping-LP leg. The dispatch now routes on the **leg**, so a satellite weighs like the
native token times its multiplier (owner ruling).

**The legitimate zero is untouched.** An additive boosting satellite in a true triplet contributes
no base by design, and that is enforced downstream in
`URC_SingularUserScoreDeltaFromSignedUserBase` — routing through the normal machinery preserves it
rather than re-deriving it.

**Consequence for live pools:** any aqp-class-1 pool that has a `Z|` or `H|` satellite of its asset
can now be staked into for real weight. Nothing on chain is retro-credited — weight accrues from
the next stake onward — and there are no sleeping positions today, so nothing needs repair.

**And the earlier "class-2 hibernation gamble" was never live.** Same composition made that path
unreachable. The fix to it was correct arithmetic on dead code, and I had reported it as closing an
open exploit. DEFECT-LEDGER §8.39–8.40.

## Still not built

- **Re-rating an existing ledger to a changed `mx` ceiling.** A ceiling change applies to new
  stakes only; existing sleeping positions keep the multiplier they were awarded (owner's call).
  Note the coupling: `SCR|C>UPDATE-MULTIPLIERS` refuses a change while any sleeping position
  exists, and **that gate is what keeps the ledger exact** — the stored term is ceiling-independent,
  so relaxing the gate without also re-rating stored legs would make an unstake reverse at a rate
  the stake never credited.
- **Hibernation custody — deliberately absent, per owner ruling.** A hibernating position asks no
  commitment: it can be unstaked at any moment with no penalty, and leaving hibernation itself
  already costs a decaying burn fee, so the term is priced there. Its multiplier is therefore
  FLAT and custody would only remove a freedom the design grants on purpose. (A `VST::XE_Awake`
  was written and removed when measurement showed it would be unreachable; the fee-decay
  extraction in tx 01 is what survived.)
- **Re-rating a buyer to the seller's original multiplier.** A reassignment re-rates the buyer to
  the term remaining *now*, so if a 25-year lock has ten years behind it the buyer earns the
  fifteen-year rate. Inheriting the seller's ceiling would make reassignment strictly better than
  buying the nonce and staking it fresh — the same position by another route — and that arbitrage
  is what the duration curve exists to remove. One flag to flip if the owner prefers inheritance.
- **A measured balance-delta for `INFO_AQP-POOL|ReleaseSpecialCustodial`.** Its two legs are
  reconstructed from the same readers the execution path calls and it is pinned structurally, but
  no chain holds both AQP-INFO and a live custodial position, so the figure is not measured against
  an actual charge.
