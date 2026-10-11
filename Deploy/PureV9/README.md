# Deploy/PureV9 — a frozen leg's id is resolved via the real link, not "F|" + the native id

**6 transactions. Send 01 → 06 in order.** ~1.20 MB total, ~435,000 gas in size charges; the
largest single transaction is ~294 KB of the ~395 KB / 2.00M limit.

## Why this round exists

Reported live, 2026-10-11, right after the `PostV8` pool-id fix unblocked testing: staking a
real frozen LP token (`F|W|SSTOA-OURO-WSTOA|LP-_MYr9VcKUkBx`, 1250 units) into its AQP pool was
refused with `Invalid dptf-id: leg does not match pool canonical asset`, while the native leg of
the same pool staked fine.

**The frozen counterpart is a separately minted token, not the native id with `F|` glued on.**
`VST::XI_CreateSpecialTrueFungibleLink` → `DPTF::XB_IssueFree` → `XIv_Issue`'s `UDC_Makeid`
builds every DPTF id as `ticker + "-" + take(12, prev-block-hash)` — a fresh,
block-hash-derived suffix, independent of the native token's own. Live proof: native
`...LP-6D_MJJXmhuz3`, frozen `F|...LP-_MYr9VcKUkBx` — different suffixes.

Two readers assumed the opposite, reconstructing a "native id" by stripping the `F|` prefix and
comparing the remainder directly — which could never match a real frozen leg, for any pool,
ever:

| tx | module | bytes | ~size gas | why it ships |
|---:|---|---:|---:|---|
| 01 | **AQP-SCORE** | 285,728 | 174,037 | `URC_StakeLpTokenToNativeLpDptf` — the F| branch now resolves via `DPTF::UR_Frozen`, not `drop 2`. (The Z| branch is unchanged; see "Still not built" below.) |
| 02 | **AQP-POOL** | 231,770 | 40,214 | `URC_StakeTrueFungibleDptfMatchesPool` — the direct cause of the reported refusal, same fix |
| 03 | RPS | 294,278 | 213,932 | dot-pin re-pin only (dot-calls both 01 and 02) |
| 04 | AQP-VCT | 179,913 | 6,830 | dot-pin re-pin only (dot-calls 02) |
| 05 | AQP-INFO | 109,433 | 210 | dot-pin re-pin only (dot-calls both 01 and 02) |
| 06 | AQP-BOOT | 101,965 | 128 | dot-pin re-pin only (dot-calls 02) |

## The fix

`frozen-link` is written **bidirectionally** by `DPTF::XE_UpdateSpecialTrueFungible`
(`XI_UpdateFrozen` runs once in each direction), so `DPTF::UR_Frozen` already reverses in BOTH
directions: given the native id it returns the frozen id, and given the frozen id it returns the
native parent back. This is the exact lookup `URCv_CoreDptf` (`01_ANK.pact`) already relied on
for the reverse direction — found by reading it as a style reference, not re-derived. Both fixed
functions now call `DPTF::UR_Frozen` instead of `drop 2 dptf-id`.

## No new interface, and no client transaction

Both fixes are module-only (`URC_StakeTrueFungibleDptfMatchesPool` and
`URC_StakeLpTokenToNativeLpDptf` are neither interface-declared), and both are changes to how an
argument is **validated**, not to any stored data — nothing moves, nothing needs migrating.

## Dot-pin — why four modules that did not change still have to ship

```
python3 REPL/tools/_dotpin.py --upgrade AQP-POOL
python3 REPL/tools/_dotpin.py --upgrade AQP-SCORE
```

Both report the same shape: AQP-SCORE and AQP-POOL both own tables, so a caller still pinned to
a pre-round hash does not go stale — it **aborts with "hash not blessed"** on its next call in.
RPS, AQP-VCT, AQP-INFO and AQP-BOOT all dot-call into one or both, so all four re-send
byte-identical sources (besides their header) purely to re-resolve their dot-references. **Send
01 and 02 before any of 03-06**, or a re-pinned caller pins a hash that is about to be
superseded anyway.

## Still not built — the Z| (sleeping) sibling of this same defect

`URC_StakeLpTokenToNativeLpDptf` also prefix-strips `Z|` (sleeping) ids, on the identical false
assumption — a sleeping DPOF's id is independently minted too (confirmed: native
`...LP-6D_MJJXmhuz3` vs sleeping `Z|...LP-jGB01kZvL4bh`, different suffixes). Unlike `F|`, there
is **no existing reverse resolver** to reuse: `DPTF::UR_Sleeping` is a one-way write
(`XE_UpdateSleeping` updates only the native row). Fixing this leg needs a genuine new reverse
resolver, the same shape of gap `URH_14|PoolForAsset` closed for the swpair/pool-id direction —
out of scope for this round, which fixes only the leg that was reported broken. Left exactly as
it was so this round's blast radius matches its own description. See DEFECT-LEDGER 8.53.

## Verification

Pinned by a new fixture in `REPL/modules/AQP-LP.repl` (`AQPLP-G4`) that freezes a **real**
native LP token — not a hand-built `"F|" + asset` string, which is exactly the shape of id that
never existed on chain and so would prove nothing about the real bug. Explicitly varies
`prev-block-hash` around the freeze call (`env-chain-data`) and restores it immediately after:
this whole REPL pipeline sets that value once, to a fixed constant, so without forcing a
different block hash the freeze would mint a frozen id sharing the native token's own suffix —
making the OLD buggy `"F| + native-id"` guess accidentally correct in-sandbox, the opposite of
what real, differently-hashed mainnet blocks produce. Mutation-proven: reverting either fixed
function back to `drop 2` fails two of the seven new assertions. Gate green, 28,377 assertions
(7 new).

Then: `python3 REPL/tools/_registrylive.py --record`.
