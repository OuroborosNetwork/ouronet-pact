# Talos AQP Client Catalogue (`TS02-C3`)

**Module:** `TS02-C3` · **Interface:** `TalosStageTwo_ClientThreeV1`  
**File:** `1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact`

Every entry below is a **client shell**: `@event` cap (usually `P|TS` only) → sovereign `C_*` / FVT recipe → `IGNIS::C_Collect` on `patron`.

**System map:** [README_GLOBAL.md](README_GLOBAL.md) · **Construction how-to:** [README_HOWTO_FVT.md](README_HOWTO_FVT.md) · **Vacate UI:** [README_VACATE_UI.md](README_VACATE_UI.md)

**Conventions**

- `patron` pays IGNIS (and any Talos KDA fuel where wired).
- Ids are usually `U|DALOS::UDC_Makeid(name)` after issue-by-name.
- One-time SCORE links cannot be retargeted — issue a new score if wiring was wrong.

---

## Construction phases (where each call fits)

| Phase | Goal |
|------:|------|
| A | Optional ANK boost infrastructure |
| B | SCORE entities + optional boost wiring / definitions |
| C | POOL issue + employ scores + stake gate |
| D | FVT issue + reward + score-entity links |
| E | Runtime stake / unstake / inject / collect / sync |
| F | Ops vacate / abort / re-enable stake |

---

## A — AQP-ANK

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-ANK\|C_IssueTrueFungibleAnchor` | patron, name, dptf-id, acnoi, boost-class-name-or-id, precision, promile, dptf-amount | TF holding boost | DPTF exists; caller owns asset policy | `acnoi=true` creates BoostClass (2× STOA); `false` joins existing (1×) | A |
| `AQP-ANK\|C_IssueSemiFungibleAnchor` | … dpsf-id, nonce | SF nonce boost | DPSF + nonce | Same acnoi rules | A |
| `AQP-ANK\|C_IssueNonFungibleAnchor` | … dpnf-id, trait-key, trait-value | NF trait boost | DPNF | Same acnoi rules | A |
| `AQP-ANK\|C_IssueNonFungibleSetAnchor` | … dpnf-id, nonce-class | NF set-class boost | DPNF set | Same acnoi rules | A |
| `AQP-ANK\|C_RevokeAnchor` | patron, anchor-id | Remove anchor from class | Anchor exists | Frees BC slot; promile drops | A |
| `AQP-ANK\|C_RevokeBoostClass` | patron, boost-class-id | Deactivate **empty** class | Zero anchors left | Cannot revoke class with live anchors | A |

**Not for:** staking or paying rewards. ANK only feeds SCORE promile math.

---

## B — AQP-SCR (scores)

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-SCR\|C_IssueLiquidityScore` | patron, owner, name, precision, lp-denominator, mx-frozen, mx-sleeping | Class-0 LP score | `lp-denominator` = **full** DPTF id | Max freeze/sleep multipliers | B |
| `AQP-SCR\|C_IssueTrueFungibleScore` | … mx-frozen | Class-1 TF score | — | — | B |
| `AQP-SCR\|C_IssueOrtoFungibleScore` | … mx-sleeping, mx-hibernated | Class-2 OF score | — | — | B |
| `AQP-SCR\|C_IssueSemiFungibleScore` | … sft-equality | Class-3 SF score | — | Equality flag for SF model | B |
| `AQP-SCR\|C_IssueNonFungibleScore` | … nft-score-model | Class-4 NF score | — | Model selects trait/set path | B |
| `AQP-SCR\|C_IssueTriplet` | patron, bronze-id, silver-id, golden-id | Bundle three existing class-0 scores | Three scores already issued | Bookkeeping for farm triplet collect | B |
| `AQP-SCR\|C_CreateScoreBoostClassLink` | patron, score-id, boost-class-id | Wire ANK class | Score `boost-class-link` still BAR; class active | **One-time** | B |
| `AQP-SCR\|C_CreateScoreBoostLink` | patron, score-id, boost-score-id | Foreign base for composite LP | Slot BAR; not self | **One-time**; Bronze/Golden → Silver pattern | B |
| `AQP-SCR\|C_EnableDebBoost` | patron, score-id | Elite DEB on boosted | Once | **Irreversible** | B |
| `AQP-SCR\|C_IssueSemiFungibleScoreDefinition` | patron, score-id, dpsf-id, nonces, values | SF nonce weights | Score class 3 | Revisions lazy-refresh on stake | B |
| `AQP-SCR\|C_IssueNonFungibleScoreDefinition` | … traits + values | NF trait weights | Score class 4 | — | B |
| `AQP-SCR\|C_IssueNonFungibleSetScoreDefinition` | … nonce-classes + values | NF set-class weights | Score class 4 | — | B |
| `AQP-SCR\|C_RotateScoreOwnership` | patron, score-id, new-owner | Change score owner | `can-change-owner` | — | B |
| `AQP-SCR\|C_ControlScore` | patron, score-id, can-upgrade, can-change-owner | Control flags | `can-upgrade` | Class/multipliers immutable after issue | B |

**Do not:** delete scores; reuse one score on two pools; set `lp-denominator` to ticker `"OURO"` instead of full id.

---

## C — AQP-POOL (admin + stake gate)

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-POOL\|C_Issue` | patron, pool-name, asset-id, aqp-class | Create pool | Asset matches class 0–4 rules; asset owner signs | One canonical asset-id | C |
| `AQP-POOL\|C_AddScore` | patron, pool-id, score-id | Employ score | Matching class; free slot; score `aqpool-link` BAR | ≤7 scores; sets `aqpool-link` | C |
| `AQP-POOL\|C_RevokeScore` | patron, pool-id, score-id | Unemploy score | Zero stake guards as coded | Clears employment; score row remains | C |
| `AQP-POOL\|C_DisablePoolStake` | patron, pool-id | Pause deposits | Pool owner | Does not force unstake | C/E |
| `AQP-POOL\|C_EnablePoolStake` | patron, pool-id | Resume deposits | Pool owner | Also used after vacate abort | C/F |

---

## E — Stake / unstake / sync

Sovereign recipes live in **AQP-FVT** (`C_*StakeFlow`). Talos resolves amounts/nonces then calls FVT.

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-POOL\|C_StakeTrueFungible` | patron, pool, owner, beneficiary, dptf-id, amount | Stake TF / native\|F\| LP | Stake enabled; class OK; supply | Partial amounts OK | E |
| `AQP-POOL\|C_UnstakeTrueFungible` | … amount | Unstake TF | Tracker balance | Partial OK | E |
| `AQP-POOL\|C_StakeOrtoFungible` | … dpof-id, nonces | Stake whole OF nonces | Class 0/1/2 OF rules | Whole nonce only | E |
| `AQP-POOL\|C_UnstakeOrtoFungible` | … nonces | Unstake OF | Tracker holds nonces | Whole nonce; beneficiary from tracker | E |
| `AQP-POOL\|C_StakeSemiFungibleCollectable` | … dpsf-id, nonces | Stake DPSF | Class 3 | Full nonce rows into tracker | E |
| `AQP-POOL\|C_UnstakeSemiFungibleCollectable` | … nonces, nonce-amounts | Unstake DPSF | Tracker qty | Partial qty OK | E |
| `AQP-POOL\|C_StakeNonFungibleCollectable` | … dpnf-id, nonces | Stake DPNF | Class 4 | — | E |
| `AQP-POOL\|C_UnstakeNonFungibleCollectable` | … nonces, nonce-amounts | Unstake DPNF | Tracker qty | Partial qty OK | E |
| `AQP-POOL\|C_SyncTrueFungibleAnchors` | patron, beneficiary, dptf-id | Repair TF ANK after external moves | Beneficiary holds context | Pool-agnostic | E |
| `AQP-POOL\|C_SyncSemiFungibleAnchors` | patron, beneficiary, dpsf-id | Repair SF ANK | — | — | E |
| `AQP-POOL\|C_SyncNonFungibleAnchors` | patron, beneficiary, dpnf-id | Repair NF ANK | — | — | E |

**Owner ≠ beneficiary:** allowed when product needs it; custody always returns to **owner**.

---

## D — AQP-FVT

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-FVT\|C_Issue` | patron, fvt-name, owner-konto, fvt-class, common-denominator | Create Farm(0)/Vault(1)/Treasury(2) | Owner konto | Farm needs real common-denominator DPTF id; vault/treasury may use sentinel per code | D |
| `AQP-FVT\|C_IssueMultipletFamily` | patron, token-0/1/2, ats-0-1, ats-1-2 | ATS multiplet reward family | ATS ids exist | Returns family-id in OC; for segmented rewards | D |
| `AQP-FVT\|C_AddRewardLink` | patron, fvt-id, reward-dptf-id, segmentation, multiplet-family-id | Register reward token | FVT exists | `multiplet-family-id` BAR if plain token | D |
| `AQP-FVT\|C_AddScoreEntity` | patron, fvt-id, score-entity-type, score-entity-id | Admit score or triplet | Score employed / triplet issued | **type 1** = score-id; **type 3** = triplet-id; sets `fvt-link` | D |
| `AQP-FVT\|C_ToggleScoreEntityLink` | … enabled | Pause/resume tranche | Link exists | Does not clear `fvt-link` on score | D/E |
| `AQP-FVT\|C_ToggleRewardLink` | … enabled | Pause/resume reward | Link exists | — | D/E |
| `AQP-FVT\|C_SetCommonDenominator` | patron, fvt-id, common-denominator | Set/fix farm denominator | Farm class 0; upgrade allowed | Must match member `lp-denominator` | D |
| `AQP-FVT\|C_SetMosaic` | patron, fvt-id, mosaic | Mosaic mode flag | Control flags | Product-specific farm behaviour | D |
| `AQP-FVT\|C_Control` | … can-upgrade, can-change-owner | FVT control | Owner | — | D |
| `AQP-FVT\|C_RotateOwnership` | … new-owner | Rotate FVT owner | `can-change-owner` | — | D |
| `AQP-FVT\|C_Inject` | patron, fvt-id, reward-dptf-id, amount | Fund rewards | Reward link enabled; amount ≤ patron supply | Farm: advances G using S | E |
| `AQP-FVT\|C_Collect` | patron, fvt-id, score-entity-type, score-entity-id, reward-dptf-id | User claim | Pending rewards; type 1 or 3 | Does not unstake | E |

---

## F — Vacate (AQP-VCT via POOL Talos names)

| Talos | Args (summary) | Use for | Assumes | Limits / notes | Phase |
|-------|----------------|---------|---------|----------------|------:|
| `AQP-POOL\|CC_FullVacate` | patron, pool-id | One-tx AGNOSTIC full vacate (any class) | Pool owner; whole pool empties in one tx | VCT reads aqp-class, scans inventory on-chain, drains every stream, auto begin+finalize | F |
| `AQP-POOL\|XB_VacateTrueFungible` | patron, pool-id | One-tx vacate of the pool's TF leg | Pool owner | On-chain scan; auto begin+finalize | F |
| `AQP-POOL\|XB_VacateOrtoFungible` | patron, pool-id, dpof-id | One-tx vacate of ONE OF asset | Pool owner | On-chain scan | F |
| `AQP-POOL\|XB_VacateSemiFungible` | patron, pool-id, dpsf-id | One-tx vacate of the DPSF collection | Pool owner (class 3) | On-chain scan | F |
| `AQP-POOL\|XB_VacateNonFungible` | patron, pool-id, dpnf-id | One-tx vacate of the DPNF collection | Pool owner (class 4) | On-chain scan | F |
| `AQP-POOL\|CC_BatchVacateTrueFungible` | patron, pool-id, dptf-id, owners, bens, amounts | One UI-sliced TF batch | Pool owner; disjoint gas-safe slice; per-leg amount == tracker | No finalize flag: first batch auto-begins (freezes), the batch that empties the pool auto-finalizes | F |
| `AQP-POOL\|CC_BatchVacateOrtoFungible` | patron, pool-id, dpof-id, owners, bens, nonces | One UI-sliced OF batch | Pool owner; amounts resolved on-chain from tracker | Same auto-begin / auto-finalize | F |
| `AQP-POOL\|CC_BatchVacateCollectables` | patron, pool-id, collectable-id, son, owners, bens, nonces, amounts | One UI-sliced DPSF (son=true) / DPNF (son=false) batch | Pool owner | Same auto-begin / auto-finalize | F |
| `AQP-POOL\|C_AbortVacate` | patron, pool-id | Clear vacate-in-progress mid-campaign | Pool owner | **Stake stays disabled** (ops re-enable) | F |

**UI offline helpers (not Talos):** `AQP-VCT.URD_Vacate*Inventory`, `URDC_BuildVacateSlicePlan`, `UC_ComputeMinSliceCount`.  
Full protocol: [README_VACATE_UI.md](README_VACATE_UI.md).

---

## Quick “which call?” index

| Intent | Call |
|--------|------|
| Create OURO LP earning line | See [README_HOWTO_FVT.md](README_HOWTO_FVT.md) § Farm LP |
| Stake OURO | `C_StakeTrueFungible` on class-1 pool |
| Stake LP | `C_StakeTrueFungible` (native LP) and/or `C_StakeOrtoFungible` (Z\|) on class-0 |
| Claim rewards | `AQP-FVT\|C_Collect` |
| Fund rewards | `AQP-FVT\|C_Inject` |
| Empty a pool as owner | `C_FullVacate*` or `C_Vacate*Legs` |
| Pause deposits | `C_DisablePoolStake` |
| Resume after abort vacate | `C_EnablePoolStake` |
