# URCi cost architecture (task #77) — progress + remaining map

Date: 2026-08-31. Option A: a pure `URCi_*` cost reader is the single source both the
exec billing path and the INFO preview call, so they can't drift.

## Patterns (proven, cost-equivalent)
- **Flavor-A (write-product output)**: op whose cumulator output holds created ids/names
  (block-hash-derived via `UDC_Makeid`, NOT purely reproducible). Single-source the
  *price*; exec keeps its real output, the URCi preview uses `[]`. Ref: DPDC-C
  `URCi_RegisterCollectablesPrice` + `URCi_CreateNewNonces`.
- **Flavor-B (composition composer)**: op whose cost = `ConcatenateOutputCumulators` of
  sub-op write-`C_` returns. The `URCi_<op>` re-derives the same concat by calling each
  sub-op's *pure* cost reader instead of the write `C_`. Exec is UNCHANGED (additive).
- **Issue-leg (hybrid)**: reproduce `XB_IssueFree`'s gas cumulator as
  `UDC_ConstructOutputCumulator (ref-M::URCi_IssueGas 1) <issuer> trigger []`; STOA is a
  separate side-collect, not in the returned cumulator.
- **Toggle-on-freshly-issued-token**: the special token's konto is the issuer
  (VST/SWP SC). Its toggle cost is DPTF `UDC_BigCumulator`/DPOF `UDC_BiggestCumulator` on
  that konto — reproduce via the issuer konto (id doesn't exist yet at preview time).
- **Cross-module toggle-role** (e.g. SWP routes through `ATS::DPTF|C_Toggle*Role`): the
  COST is just DPTF's own `URCi_Toggle{Burn,Mint,FeeExemption}Role` cumulator — call the
  DPTF reader directly, ignore the ATS wrapper path.

## DONE this session (all green on `cd REPL && ~/.local/bin/pact Z.repl`, committed+pushed)
- **VST 29/29** — clean tier (Freeze/Reserve/Unreserve/Vest/Sleep/Unsleep/Hibernate + 4
  toggles) + intricate tier: `URCi_CreateSpecialTrueFungibleLink`/`…OrtoFungibleLink`,
  `URCi_RepurposeTrueFungible`/`…OrtoFungible`, `URCi_MergeNonces`, `URCi_Unvest`,
  `URCi_Awake`, `URCi_Constrict`, `URCi_Brumate`.
- **LIQUID 4/4** — Unwrap/Wrap Stoa + UrStoa.
- **OUROBOROS 5/5** — Compress (covers XB_Compress), Sublimate, SublimateV2, WithdrawFees,
  Fuel (conditional wrap + ATSU-fuel legs).
- **SWP 12/12** — the 3 deferred finalized: EnableFrozenLP, EnableSleepingLP,
  ToggleAddOrSwap (role-bootstrap fold via DPTF toggle-role readers).
- **SWPLC 3, SWPU 1** — UpdatePendingBrandingLPs, ToggleAddLiquidity, Fuel;
  ToggleSwapCapability. (All delegate to SWP `URCi_ToggleAddOrSwap` / branding / multi-transfer.)
- Earlier (prior sessions): DPDC family, BRD, TFT `URCi_Transfer`, ATSU flavor-B (11).

## REMAINING (heavy — needs dedicated single-source design, NOT mechanical)
- **SWPU swaps**: `C_Swap`, `C_SmartSwap`, `CC_SmartSwap` — BFS path search + per-hop
  LP/special/boost fee legs + slippage; cost is embedded in `XI_SmartSwapRouter` /
  `XI_SmartSwapExplicitRoute`. Re-deriving purely ≈ the AMM engine itself.
- **SWPLC**: `C_RemoveLiquidity`, and the `C|STOA-PID_Add*Liquidity` family (LP mint math).
- **SWPI**: `C_Issue` (pool creation, issue flavor-A + init transfers).
- **MTX-SWP** (16): defpact swap orchestration.
- **AQP family** (~48): guided by the AQP-INFO map; stake/unstake/vacate/inject.
- **DPDC-S, EQUITY, DEMIPAD composites**.

## Deferred structural cleanup
- **Task #90**: reorder inline `URCi_` into a canonical band + rename mis-prefixed `X_`
  internal writers to `XI_` (`X_KickStart`, `X_RemoveSecondary`, `X_TransmitCollectables`).
  All `URCi_` this session were placed inline right before their `C_` for readability.
