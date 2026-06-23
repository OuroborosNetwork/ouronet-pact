# Stake / Unstake — canonical phase model

Reference: UrStoa `C_URV|Stake` / `C_URV|Unstake` in `00_StoaSandbox/coin.pact`.

All flows (`C_TrueFungibleStakeFlow`, `C_OrtoFungibleStakeFlow`, future `C_CollectableStakeFlow`) share the **same phase skeleton**. Steps marked **—** compose a zero-IGNIS no-op so recipes stay line-aligned.

## PHASE 1 — Custody (`AQP-POOL`)

Move assets user↔vault and record custody trackers **before** any RPS or SCORE mutation.

| Step | Function | UrStoa ≡ | TF | OF | DPDC |
|------|----------|----------|----|----|------|
| **1.1** | `XE_Phase_1_1\|*Transfer` | `X_UR\|Transfer` | ✓ | ✓ | ✓ |
| **1.2** | `XE_Phase_1_2\|*PoolTracker` | N/A | ✓ | ✓ | ✓ |
| **1.3** | `XE_Phase_1_3\|TrueFungibleBeneficiaryRollup` | N/A | ✓ | — | — |

OF / DPDC: `XI_Phase_1_3\|NoOpBeneficiaryRollup`.

## PHASE 2 — FVT RPS prelude (at **OLD** deb / L_i)

Reward ledger updates **before** SCORE changes user deb.

| Step | Function | UrStoa ≡ | TF | OF | DPDC |
|------|----------|----------|----|----|------|
| **2.1** | `XI_Phase_2_1\|SyncFarmGhostTvl` | N/A | farm | farm | farm |
| **2.2** | `XI_Phase_2_2\|EnsureScoreRewardRows` | insert if `!IzAccount` | ✓ | ✓ | ✓ |
| **2.3** | `XI_Phase_2_3\|BankScorePendingRewards` | `XI_URV\|UpdatePendingRewards` | ✓ | ✓ | ✓ |

Orchestrator: `XI_Phase_2\|RpsPreScore` (runs **2.1 → 2.2 → 2.3**).

## PHASE 3 — Anchors (`AQP-ANK`)

Refresh promile from post-custody totals **before** SCORE boosted/deb recompute.

| Step | Function | UrStoa ≡ | TF | OF | DPDC |
|------|----------|----------|----|----|------|
| **3.1** | `XI_Phase_3_1\|RefreshTrueFungibleStakeAnchors` | N/A | ✓ | — | — |
| **3.2** | `XI_Phase_3_2\|NoOpSemiFungibleAnchors` (future DPSF) | N/A | — | — | `son=true` |
| **3.3** | `XI_Phase_3_3\|NoOpNonFungibleAnchors` (future DPNF) | N/A | — | — | `son=false` |

## PHASE 4 — SCORE weight mutation

| Step | Function | UrStoa ≡ | TF | OF | DPDC |
|------|----------|----------|----|----|------|
| **4.1** | `XI_Phase_4_1\|ApplyVaultScoreTotals` | `XI_URV\|UpdateVaultScore` | ✓ | ✓ | ✓ |
| **4.2** | `XI_Phase_4_2\|WriteUserScoreTriple` | `XI_URV\|UpdateUserScore` | ✓ | ✓ | ✓ |
| **4.3** | `XI_Phase_4_3\|ApplyScoreNzsDelta` | `XI_URV\|UpdateNZS` | ✓ | ✓ | ✓ |

Orchestrator per score: `XE_Apply*StakeDelta` → `XI_2\|ApplySingularUserScoreDelta` (**4.2 → 4.1 → 4.3**).

## PHASE 5 — FVT RPS post-SCORE

After NZ state is known.

| Step | Function | UrStoa ≡ | TF | OF | DPDC |
|------|----------|----------|----|----|------|
| **5.1** | `XI_Phase_5_1\|BookUnclaimedCounts` | `XI_URV\|UpdateUnclaimedCount` | ✓ | ✓ | ✓ |
| **5.2** | `XI_Phase_5_2\|CheckpointStakeRps` | `XI_URV\|UpdateUserRPS` | ✓ | ✓ | ✓ |

## UrStoa single-vault mapping

```
UrStoa block                    AQP phase.step
─────────────────────────────────────────────
1]   X_UR|Transfer              1.1 (+ 1.2/1.3 AQP extensions)
     insert UrStoaVaultUser      2.2
2.1] UpdatePendingRewards       2.3
2.2] UpdateVaultScore           4.1
     UpdateUserScore            4.2
2.3] UpdateNZS                  4.3
     UpdateUnclaimedCount        5.1
2.4] UpdateUserRPS              5.2
```
