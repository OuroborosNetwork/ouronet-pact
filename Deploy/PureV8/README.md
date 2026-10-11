# Deploy/PureV8 — custody retired for a maturity lock; the generalized beneficiary switch

**3 transactions. Send 01 → 02 → 03 in order.** ~603 KB total, ~88,000 gas in size charges; the
largest single transaction is ~249 KB of the ~395 KB / 2.00M limit.

## Why this round exists

Owner ruling, 2026-10-11: *"we switch back to the original mode, where i am the owner of the
staked batch, while specifying a beneficiary (me or someone else). We simply disallow unstaking
until the sleeping period expired, while allowing switching directly for the beneficiary while
the batch is staked — and the same must exist for every staked NFT and SFT as well."*

PureV6's custody mechanism closed a real hole (an early exit at the sleeping rate) by naming the
**pool** as the tracker owner. That welded two different things to one column: holding the asset
to term, and controlling who may ever earn from the position. This round un-welds them.

| tx | modules | bytes | ~size gas | why it ships |
|---:|---|---:|---:|---|
| 01 | **AQP-FVT** | 248,605 | 65,696 | the maturity lock, the generalized reassignment, the collectable phase-chain extraction |
| 02 | **TS02-C3** | 143,975 | 1,435 | Talos shells for the renamed/new reassignment entrypoints |
| 03 | AQP-INFO, AQP-BOOT | 210,734 | 20,659 | renamed/new cost previews; dot-pin cascade |

## The mechanism

`FVT|C>ORTO-FUNGIBLE-STAKE-FLOW`'s two custody enforces are replaced by one `all-matured` check
applied to **both** directions: a sleeping leg that earns a duration multiplier may not unstake
until every nonce's live remaining term is `<= 0`. The tracker owner is the staker, always.

Verified safe without a new transfer lock, not assumed: `XI_OrtoStakePhases`'s own docstring
already recorded that the asset leaves the staker on the **ordinary** path too — custody was
never possession, it was one column. A staker reassigning who earns was never at risk of losing
what they no longer held.

## The beneficiary switch — generalized, not duplicated

`CCp_ReassignCustodialBeneficiary` → **`CCp_ReassignOrtoStakeBeneficiary`**. Signed by the
**owner** (not the current beneficiary — the owner is who decides who earns). **No
transfer-role check** — the old gate existed because the release paid the native asset to
whoever was beneficiary at maturity; under this model the asset always returns to the owner
regardless of who the beneficiary was, so there is no delivery to police. Proven as a positive
case: `[6.4]` `TX-AQP-CL06` reassigns successfully on a token whose owner restricted transfers,
where the old gate would have refused it.

**New: `CCp_ReassignCollectableStakeBeneficiary`** — the NFT/SFT counterpart, over a newly
extracted `XI_CollectableStakePhases` (mirrors `XI_OrtoStakePhases` exactly: `tracker-owner` vs
`transfer-sender`, `move-asset`). Collectables carry no maturity lock; this is a pure convenience.

**Re-rating is preserved and now stated as policy.** A reassignment still re-stamps
`SCR|T|SleepStake` to the term remaining *now* — a documented trade-off of reusing the proven
stake/unstake machinery rather than writing new score arithmetic for this round. `[6.4]`
`TX-AQP-CL07` pins the exact midpoint figure on a real (non-degenerate) ceiling.

## What stays, deliberately

`CCp_StakeSpecialCustodial` / `CCp_ReleaseSpecialCustodial` are **unchanged in body and now
unreachable** — the stake-flow guard refuses the custodial path unconditionally. Left in place
rather than removed: deleting a deployed Talos entrypoint is a bigger, slower change than this
round needed, and the chain holds **zero** custodial positions to migrate (confirmed before any
code was touched: `URH_AQP|DpofStakesByOwner GOV|AQP|SC_NAME -> []`).

`UC_VacateOrtoDestinations`'s custodial-redirect branch (DEFECT-LEDGER 8.38/8.39) is now dead
code by the same mechanism. The fix stays correct; the path it defends is unreachable.

## No client transaction this round

Unlike V7, there is nothing to reset or migrate — this round is pure code. No existing position
needs touching.

## After the round

```
(ouronet-ns.AQP-FVT.URH_AQP|DpofStakesByOwner "<any-staker>")   -- confirm positions still read
```

DEFECT-LEDGER 8.50. Gate GREEN: 28,370 assertions (23,001 positive / 5,369 negative).
