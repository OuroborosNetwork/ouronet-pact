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
- **DPDC-S 10/10** — Make/Break SFT+NFT sets, Define Primordial/Composite/Hybrid,
  EnableSetClassFragmentation, ToggleSet, RenameSet.
- **EQUITY** — `URCi_MorphPackageShares` (Make/Break/Convert). `C_IssueShareholderCollection`
  DEFERRED (issue + 8-nonce populate; populate price reads the block-hash equity-id).
- **DPDC-N / DPDC-MNG already complete** (verified): all 7 UpdateNonce* ops share
  `URCi_UpdateNonceField`; all 4 Wipe ops share `URCi_WipeCumulator` (via C_WipePure).
  Name-diffs are misleading — these are single-sourced through shared readers.
- **SWPLC liquidity family** — `URCi_RemoveLiquidity` + all 5 `Add*Liquidity`
  (Standard/Iced/Glacial/Frozen/Sleeping). The LP math is mechanical: `URC|STOA-PID_CLAD`
  is a pure reader carrying the perfect-ignis-fee cumulator + primary/secondary LP + tax;
  VST freeze/sleep legs use `URCi_Freeze`/`URCi_Sleep`. => **SWPLC fully done.**
- **DEMIPAD 3** — `URCi_Deposit` (wrap/unwrap + working-token transfer off `URC_Prices`),
  `URCi_TransmitSemiFungibles`/`NonFungibles` (shared `URCi_TransmitCollectables`).
  Withdraw/TransmitTF/TransmitOF are bare Talos-routed (no cumulator).
- Earlier (prior sessions): rest of DPDC family (R/02/MNG/N/F/C/I/T), BRD, TFT
  `URCi_Transfer`, ATSU flavor-B (11). => **DPDC family fully done.**

**=> Every mechanically-composable module is now complete.** What remains is the
irreducible issue-hybrid / heavy-AMM / AQP-#74 tier below.

## OWNER DIRECTION (2026-08-31): EXACT previews, dirty-read-fed
"Exact — it's read-only so we can derive exactly. If the exec is fed dirty-read data
(a bundle/path/plan), the URCi/info function is fed the SAME dirty-read data." So swap
URCi take the bundle (route + boost-path + stoa-paths); vacate/drain URCi take the
dirty-read plan; self-searching variants take the dirty-read boost-path. All read-only.
BOOST CRACK: XI_RawLiquidPump's cost is ONE fixed SSTOA burn (or EOC if no active route)
REGARDLESS of route length — the search only decides existence + amount (read-only),
never the cumulator. This makes swaps fully, exactly derivable.

## SWPU swaps
- **`C_Swap` (direct) — DONE, exact** (commit 7726cc1): `URCi_Swap` + `URCi_SwapCore`
  + `URCi_RawLiquidPump`. Slippage gate (read-only `URC_Swap` vs client bounds) → 4 legs
  off the PURE `UC_BareboneSwapWithFeez`: multi-transfer in, LP fuel (indirect=EOC),
  output leg (special-fee bulk split or netto transfer), boost (one SSTOA burn/EOC).
  Exact by composition of already-proven sub-readers; execs unchanged.
- **`C_SmartSwap` (bundle) / `CC_SmartSwap` (self-searching) — DONE, exact** (commit
  bac44fc): `URCi_SmartSwapCore` (hop fold) + `URCi_SmartSwapExec` + `URCi_SmartSwap`
  (self-searching, route via read-only URC_HopperActive, NO_PATH boost) +
  `URCi_SmartSwapWithBundle` (dirty-read bundle's route + boost-path). Intermediate hops
  cost only EOC; last hop = batched special-fee flush + output payout + one boost burn.
  Amount-INDEPENDENT cost; output threaded via the pure swap math. Exact by composition.
- **MTX-SWP (16 defpact ops) — COVERED, no new work.** `MTX|C_Issue` calls the SAME
  `SWPI::XE_IssueWrite` as `SWPI::C_Issue` (#36M/M5 unification) and `MTX|C_AddLiquidity`
  wraps the same SWPLC add-liquidity; both are bare gas-limited defpacts (no cumulator
  return). Their cost preview IS `SWPI::URCi_Issue` / `SWPLC::URCi_Add*Liquidity` (already
  built) — the INFO layer (task #78) calls those sovereign readers directly.

**=> THE ENTIRE SWP FAMILY (SWP/SWPI/SWPL/SWPLC/SWPU/MTX-SWP) IS URCi-COMPLETE.**

## RESOLVED issue-hybrids (kept for method reference)
- **Issue-hybrids**: a token is issued (block-hash id = write product) and a LATER leg
  operates on that fresh id. KEY INSIGHT (from SWPI): the fresh-id cost readers mostly do
  string compares not table reads, and `URC_IsVirtualGasZeroAbsolutely(non-gas-id)` is
  GLOBAL, so many "unpreviewable" triggers reduce to `URC_IsVirtualGasZero()`.
  - **SWPI::C_Issue — DONE + GROUND-TRUTH PROVEN** (commit 452a9f4/ef8309c). `URCi_Issue`
    reconstructs the 5 legs (ico1/ico2/ico5 real readers; ico3 mint=biggest, ico4 fresh-LP
    class-1=smallest from XE_IssueLP's fixed fee-toggle-off invariant). Test [6.2+3] TX04b:
    URCi_Issue IFP == real DPTF/TFT readers on the now-existing LP (4509==4509). The
    ground-truth pattern: after issue the token exists, so compare the pre-existence
    reconstruction to the real readers post-issue.
  - **EQUITY::C_IssueShareholderCollection — DONE, CODE-PROVEN** (commit de8a9dc). The
    discount ambiguity is SETTLED by reading the exec: XI_IssueDigitalCollection inits the
    collection at nonces-used=0 and creates NO nonce (UDC_DPDC|Properties trailing 0 =
    nonces-used, 01_DPDC-UDC:130), so the 8-nonce populate runs at nu=0; equity ids are
    Elite ('E|' via UC_EquityID + UDC_Makeid=concat[ticker '-' hash]) and son=true => the
    [ft='E|' & son & nu=0] /1000 discount FIRES at exec time. Populate = smallest*1000.
    The SWPI-style post-issue ground-truth does NOT apply (nonces-used=8 post-populate reads
    the UNdiscounted price) — equality is code-proven not test-arbitrated; a GAS-delta
    harness on DPSF|C_IssueCompany would confirm. Discount economics -> task #76.
- **MTX-SWP** (16): defpact swap/issue orchestration — composes SWPI/SWPU, inherits their
  hybrid/heavy nature.
- **AQP family** — Option-A already: exec + INFO share `URC_*Ignis` readers. AQP-INFO
  (08_AQP-INFO.pact) holds them; INFO fns named `AQP-POOL|INFO_*`. BUILT: all stake/unstake
  (TF/OF/SF/NF, ground-truth-proven), Finalize/Abort vacate, config, sync, issue.
  - **TF batch-vacate — DONE** (commit 50b2e59): `URC_VacateTfBatchCostIfp` +
    `INFO_BatchVacateTrueFungible`, fed the dirty-read `legs`. Reuses SIP|URC_* + the same
    phase readers as stake; VCT leg helpers via direct `AQP-VCT.fn` ref (no interface change).
  - **REMAINING (6): OF/coll batch-vacate + 3 drains + FullVacate.** All same method (dirty-
    read-plan-fed, compose proven readers). Traced specs:
    · OF vacate (XI_VacateOrtoFungibleBatch 2456): bulk `DPOF::C_BulkTransfer` + per-nonce-leg
      tracker (medium×|nonces|) + per-benef unwind = RpsPreZero(free) + ApplyOFDelta(class
      {0,2} via URC_StakeScoreDeltaSumForClasses [0 2]) + book + checkpoint. NO rollup/anchor.
    · Coll vacate (XI_VacateCollectableBatch 2487): bulk `DPDC-T::C_BulkTransfer` + tracker
      (medium×|nonces|) + rollup(medium×|nonces|) + FLAT anchor (medium+biggest) + per-benef
      unwind class-matched (SF [3] / NF [4]) + book + checkpoint.
    · DRAIN (TF/OF/coll): score-free mirror — OMITS ApplyStakeDelta; the per-benef settle-
      triple (anchor+book+checkpoint) fires ONLY for beneficiaries whose UserUnn hits 0 (their
      last position drained). DATA-DEPENDENT subset — the hard part: read each benef's unn and
      simulate the per-leg decrement, count who reaches 0. Fed the dirty-read legs.
    · FullVacate = Σ over lanes of the batch recipe (TF lanes + OF lanes + coll lanes).
    Need DPOF/DPDC-T bulk-transfer cost readers (URCi_Bulk*). Deserves fresh context for the
    drain subset.
- **DEMIPAD composites** — done earlier (Deposit + transmits).

## Deferred structural cleanup
- **Task #90**: reorder inline `URCi_` into a canonical band + rename mis-prefixed `X_`
  internal writers to `XI_` (`X_KickStart`, `X_RemoveSecondary`, `X_TransmitCollectables`).
  All `URCi_` this session were placed inline right before their `C_` for readability.
