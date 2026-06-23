---
name: ouronet-talos-orchestrator-events
description: Talos client shell for multi-module flows — AQP @event cap (compose P|TS only), sovereign C_* recipe with direction in home module (e.g. FVT), per-phase XE_* + component caps. Use for TF stake/unstake and similar orchestrated flows.
---

# Talos orchestrator + sovereign stake recipes

## Layer 1 — Talos `@event` cap

- Composes **`(P|TS)` only** — no domain validation in Talos.
- Resolves read-model inputs (e.g. `UR_NoncesSupplies`) **before** the cap.
- **`IGNIS::C_Collect patron`** on the recipe `OutputCumulator`.

## Layer 2 — Sovereign recipe cap (`FVT|C>*STAKE-FLOW`)

- **`UEV_IMC`** + numbered input validation matrix.
- **`compose-capability (SECURE)`** for all `XI_*` phases.

## Layer 3 — Canonical phases (all flows share skeleton)

See **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README_STAKE_PHASES.md`**.

| Phase | Concern | TF | OF |
|-------|---------|----|----|
| **1.1–1.3** | Custody | all three | 1.1–1.2; **1.3 no-op** |
| **2** | FVT RPS prelude | ✓ | ✓ |
| **3.1–3.3** | Anchors | **3.1** only | all **no-op** |
| **4** | SCORE | ✓ | ✓ |
| **5.1–5.2** | FVT post-SCORE | ✓ | ✓ |

## Layer 4 — TF stake phase entries

| Step | Module | Entry | UrStoa ≡ | Protection |
|------|--------|--------|----------|------------|
| 1.1 | AQP-POOL | `XE_Phase_1_1\|TrueFungibleTransfer` | `X_UR\|Transfer` | `AQP\|XE>TRUE-FUNGIBLE-POOL-CUSTODY` |
| 1.2 | AQP-POOL | `XE_Phase_1_2\|TrueFungiblePoolTracker` | N/A | same cap |
| 1.3 | AQP-POOL | `XE_Phase_1_3\|TrueFungibleBeneficiaryRollup` | N/A | same cap |
| 2 | AQP-FVT | `XI_Phase_2\|RpsPreScore` | 2.2 insert + 2.3 pending | `SECURE` |
| 3.1 | AQP-FVT/ANK | `XI_Phase_3_1\|RefreshTrueFungibleStakeAnchors` | N/A | `SECURE` |
| 3.2–3.3 | AQP-FVT | no-op | N/A | `SECURE` |
| 4 | AQP-SCORE | `XE_ApplyTrueFungibleStakeDelta` | 4.1–4.3 | `UEV_IMC` → `SECURE` |
| 5.1 | AQP-FVT | `XI_Phase_5_1\|BookUnclaimedCounts` | `UpdateUnclaimedCount` | `SECURE` |
| 5.2 | AQP-FVT | `XI_Phase_5_2\|CheckpointStakeRps` | `UpdateUserRPS` | `SECURE` |

**ANK:** `XE_UpdateTrueFungibleUserAnchorValues` = cross-module sync path; stake uses **`XI_Phase_3_1|RefreshTrueFungibleStakeAnchors`** inside FVT recipe.

### OrtoFungible (DPOF)

Talos: **`C_StakeOrtoFungible`**, **`C_UnstakeOrtoFungible`**. Recipe **`FVT::C_OrtoFungibleStakeFlow`** — same phase skeleton; **1.3** and **3.x** no-op. No DPOF anchor phase.

---

## Layer 5 — Internal writers (`XI_*`)

**`require-capability (SECURE)`** only — caller already holds composed **`SECURE`** from recipe cap.

---

## Do not

- Put validation in Talos `@event` beyond `P|TS` + patron billing inputs.
- Skip reserved no-op phases in new flows — keep skeleton aligned for diffability.
- Renumber phases per flow; use no-op instead.
