# Deploy/PureV7 — the multiplier DEFAULTS, and the two rules that define them

**9 transactions. Send 01 → 09 in order.** ~1.66 MB, ~502,000 gas in size charges; the largest
single transaction is ~294 KB of the ~395 KB / 2.00M limit.

## Why this round exists

V6 shipped the multiplier MACHINERY but not the owner's numbers. `1.999` and `2.998` existed
**only as worked examples inside docstrings** while issuance hard-coded `2.0 / 1.0 / 1.0` for
every class but 0. A default that lives in prose is not a default — and nothing could detect the
divergence, because there was no constant to compare against.

| tx | modules | bytes | ~size gas | why it ships |
|---:|---|---:|---:|---|
| 01 | **AQP-SCORE** | 284,551 | 169,080 | `CT_MX_{FROZEN,SLEEPING,HIBERNATED}_DEFAULT` = 2.998 / 1.999 / 1.0, used as the real issuance defaults. `UC_MxSleepIntervalOk` (divide-by-three) enforced at issuance AND update. `UC_MxFrozenFloor` extracted and reused as class 2's default |
| 02 | **AQP-POOL** | 230,426 | 38,609 | `URC_AQP\|ScoreMxChangeSafe` no longer ABORTS on a collection pool |
| 03 | RPS | 294,258 | 213,830 | dot-pin cascade |
| 04 | MTX-AQP, AQP-DSA | 81,239 | 26 | dot-pin cascade |
| 05 | AQP-VCT | 179,824 | 6,806 | dot-pin cascade |
| 06 | AQP-FVT | 241,042 | 52,920 | dot-pin cascade |
| 07 | TS02-C3 | 141,792 | 1,290 | dot-pin cascade; carries the Talos surface tx 09 calls |
| 08 | AQP-INFO, **AQP-BOOT** | 208,959 | 19,471 | dot-pin cascade + `BOOT\|MX_*` 2.0/2.0 → 2.998/1.999 |
| 09 | *(client)* | — | — | reset all 15 scores to the defaults + re-run Step 0 |

**Only two modules changed.** The other six are the dot-pin cascade: both changed modules own
tables, so a caller compiled against a superseded one does not go stale — it **aborts with "hash
not blessed"**. Set computed by `_dotpin.py`, not by hand. The group is `sequential` and must stay
so.

## The three numbers are not independent

```
sleeping interval  = 1.999 - 1.0 = 0.999   -> divides by THREE exactly (0.333)
frozen interval    = 2.998 - 1.0 = 1.998   -> exactly DOUBLE the sleeping interval
hibernated         = 1.0                   -> flat; it asks no commitment
```

`UC_MxSleepIntervalOk` enforces the first. `UC_MxOrderingOk` enforces the second **as a floor**,
not an equality — and that matters: every class-3/4 score on chain sits at `2.0 / 1.0 / 1.0`,
where the frozen interval is 1.0 against a doubled-sleeping of 0.0. An equality would make all
eleven **permanently un-updatable**.

The divisibility check works in whole units of `0.0001` rather than by dividing, because
`UEV_Fee` already caps precision at 4 decimals so the integer `mod` is exact. A float
round-trip would pass on the values you tried and fail on one you did not.

## One BREAKING change

**Class-1 (DPTF) issuance now defaults `mx-sleeping` to 1.999 instead of 1.0**, so the caller must
supply `mx-frozen >= 2.998`. The old 1.0 was never a decision — it meant a class-1 pool's `Z|`/`H|`
satellites earned **no sleeping bonus**, which stopped being correct the moment V6 made them score
at all.

## What tx 09 does, and why it must be last

It sets all fifteen live scores to `2.998 / 1.999 / 1.0` and re-runs
`AQP-BOOT.C_Step0_WireImcAndGovernor`. Both halves depend on 01 and 02:

- against the OLD AQP-SCORE the multiplier writes would **succeed**, which is worse than failing —
  the values would land without the rule that makes them coherent;
- against the OLD AQP-POOL **eleven of the fifteen ABORT**. `URC_AQP|ScoreMxChangeSafe` read
  `DPTF::UR_Frozen` on the pool's asset, and a class-3/4 collection pool has no row in
  `DPTF|PropertiesTable`, so the bare read killed the transaction. That fix is what lets all
  fifteen go through the ordinary client path — **no raw table write is needed anywhere.**

Three scores currently violate the new rules and this is what repairs them: Bronze, Silver and
Golden SnakePower sit at `mx-sleeping 2.0` (interval 1.0, which leaves 1 over) and `mx-frozen 2.0`
(below the 3.0 floor a 2.0 ceiling demands). They came from `BOOT|MX_*`, fixed in tx 08 so the
next boot cannot reintroduce them.

**Signers for 09:** the score owner's konto (all fifteen share one) *and* the AQP-BOOT governance
keyset.

## After the round

Admin → Scripts → **Run the full chain**, then confirm:

```
(ouronet-ns.AQP-SCORE.UR_SCR|ScoreMxSleeping "<any-score-id>")   -> 1.999
```
