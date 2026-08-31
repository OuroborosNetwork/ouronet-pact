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
  - **ALL 7 batch vacate/drain — DONE** (commits 50b2e59, be54592, 950005c, b58f4a1,
    83b52fb, 4aaf2db, 7a25f90). `URC_Vacate{Tf,Of,Coll}BatchCostIfp`,
    `URC_Drain{Tf,Of,Coll}BatchCostIfp`, `URC_FullVacateCostIfp` + their `AQP-POOL|INFO_*`.
    All dirty-read-plan-fed, composing the SAME proven phase readers as stake; VCT leg
    helpers + lane schemas via direct `AQP-VCT.fn` / `AcquisitionVacateV1.VCT|*` (no interface
    change). Key facts locked: tracker-zero=medium, rollup=biggest; OF omits rollup/anchor
    (class {0,2}); coll adds rollup + FLAT anchor (class SF[3]/NF[4]); DRAIN is score-free and
    fires settle-triple ONLY where UserUnn hits 0 (TF decrements unn per-LEG, OF/coll per-
    NONCE — simulated read-only from live UR_AQP|UserUnn); FullVacate = Σ over lanes (the auto
    MaybeFinalizeVacate write is discarded by the exec, so not in the total).
  **=> ENTIRE AQP INFO/URCi surface complete (stake/unstake/vacate/drain/config/sync/issue).**
- **DEMIPAD composites** — done earlier (Deposit + transmits).

## => URCi COST ARCHITECTURE (task #77) COMPLETE across the whole codebase.
Every client op with an OutputCumulator now has an exact, single-sourced cost reader/INFO,
fed the same dirty-read data the exec gets where applicable. Only optional follow-ups
remain: GAS-delta ground-truth harnesses for the AQP vacate/drain + EQUITY-issue readers
(analytically/code-proven; empirical lock is belt-and-suspenders), and task #90 (StoicSyntax
ordering/placement sweep — reorder inline URCi into bands, X_->XI_ rename).

## GAS-delta ground truth — ALL AQP vacate/drain EMPIRICALLY LOCKED (2026-08-31)
Runner: `cd REPL && ~/.local/bin/pact aqp-info-groundtruth.repl` (NOT loaded by Z; standalone).
Method: `predicted = (at "ignis-need" (at "ignis" info))`; `delta = pre-gas - post-gas` where
gas = `DPTF::UR_AccountSupply "GAS-98c486052a51" patron`; assert `predicted == delta`.
Dirty-read scan pattern (owner's principle — SAME data fed to INFO and exec): call
`AQP-VCT.URH_Vacate{TrueFungible,OrtoFungible,Collectables}PoolLegs pool-id [son]`, take the
lane(s), feed `legs` to `INFO_Batch*` and the parallel `(map (at "field") legs)` arrays to the
`CCp_Batch*` exec. Each vacate/drain CONSUMES + disables its pool, so every test needs a FRESH
pool (issue score + `C_Issue` + `C_AddScore` + `REPL_BootstrapVault` + stake). Fixture STOA sigs =
4 `coin.TRANSFER` caps on split-STOA recipients from `URC_SplitSTOAPrices patron (* 2.0 UsagePrice"smart")`.
Proven EXACT (all in REPL/Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl):
- stake: TF 23.32 / OF 15.9 / SF 551.2 ; unstake: TF 23.32
- vacate: TF 19.08 / OF 11.66 / SF(coll) 546.96
- drain (score-free, settle-triple where UserUnn hits 0): TF 16.43 / OF 9.01 / SF(coll) 544.31
- FullVacate (Σ over lanes; class-1 → tf+of lanes only, coll-lanes=[] — CC_FullVacate NEVER
  scans collectables for class {0,1}): 19.08 == single TF-lane vacate.
Gotchas locked: (1) VCT Vacate* schemas are MODULE-local — reference `object{AQP-VCT.VCT|Vacate*}`,
NOT `AcquisitionVacateV1.VCT|*` (that fails in the runner though Z hid it). (2) TF vacate needs the
FULL tracked balance — read `AQP-POOL.UR_AQP|DPTFTrackerBalance`; cost is amount-independent.
(3) fresh 2nd MVST mint fails (add-quantity role) — reuse an owner-held MVST nonce the prior vacate
returned. (4) coll drain leg carries an `amounts` field → `CCp_BatchDrainCollectable` needs the
`(map (map floor (at "amounts")) legs)` array too. Commits e42137a, b689926, 27e0f5b, 62b3ac9, 2fd6a8e.

## Citizen launchpad — PURE-CITIZEN conversion (task #94) + proven working
Owner ruling: the launchpad "baron/of-the-house" citizens (which composed bare-core
cumulators to save gas under Kadena's 150k cap) become PURE citizens as the reference PoC:
they call ONLY Talos ops (each self-collects IGNIS), so billing is Sigma (once per op) — a
citizen cannot fold cumulators (no permission for bare uncollected core funcs; the compose
permission is inseparable from the write permission, and granting it would break the gas
boundary). The kicker: citizen C_ stay callable directly, but ONLY the Talos wrapper is the
gas-funded path. Composition privilege name (if ever revived): "Patrician" (privileged citizen).

STRUCTURE (Phase 1, commit ae1f9b6): TS02-DPAD split ->
- SOVEREIGN `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact`: DEMIPAD|* orchestration +
  new `DEMIPAD|C_Deposit`; P|A_Define registers DEMIPAD/DPDC/TS01-A.
- CITIZEN `2_CITIZEN/6_Launchpad/99_TS02-CPAD.pact` (interface CitizenLaunchpadTalosV1, deployed
  LAST): all SPARK|/SNAKES|/CUSTODIANS|/KPAY| user wrappers; P|A_Define registers the 5 sales'
  IMP + **TS01-A** (so the wrappers' XB_DynamicFuelSTOA gas refuel passes UEV_IMC).
- Deploy reorder: DEMIPAD core -> TS02-C1/C2/C3 -> TS02-DPAD(sov) -> citizen sales -> TS02-CPAD.
  [2.2]_DemiPad loads only DEMIPAD core; [3]_Talos loads sov Talos + the 5 sales + TS02-CPAD;
  [4.0] runs both split P|A_Define. P|TALOS-SUMMONER=true so a pure citizen may call any Talos op.

CONVERSIONS (Phase 2, commits a481624/44acf82/e052aed): each C_ now calls Talos ops, Sigma-billed,
+ URCi_<op> (Sigma of per-op IGNIS via URCi_Deposit + the transfer readers) + INFO_<op>
(acquisition cost declared in the description as the good bought; protocol stoa = NoStoaCosts —
launchpad ops carry NO protocol STOA fee, only IGNIS):
- Spark buy: DEMIPAD|C_Deposit + DPTF|C_Transfer. Redeems (6-leg): DPTF|C_Transfer + 2x
  ToggleFreezeAccount + WipeSlim + Mint + TS01-C2.VST|C_Freeze.
- Snakes/Custodians acquire: DEMIPAD|C_Deposit + TS02-C1.DPDC|C_MultiTransfer.
- StoicPay buy (3-leg): DEMIPAD|C_Deposit + DPTF|C_Transfer + DPTF|C_MultiBulkTransfer (venture split).
- StoicIco was ALREADY pure (XI_CollectFor calls TS01-C1.DPTF|* Talos ops) — no conversion.

**FUNCTIONAL PROOF (commit e052aed):** `REPL/launchpad-groundtruth.repl` SPARK-BUY-GT — boots
base + [5.3], buys 25 sparks via TS02-CPAD.SPARK|C_BuySparks (native STOA / type 0). Buyer
receives 25 sparks AND INFO_BuySparks.ignis-need == real IGNIS balance delta = **2.65 exactly**.
Proves SC->buyer transfer authorizes through Talos + Sigma-billing is exact. The acquisition
payment sigs = URC_Prices(asset,pid,type) -> sign coin.TRANSFER for wrap(non-env) + 4-way env
split (c:iQQ/k:0cb/k:50d/c:XM) — the DEMIPAD C_Deposit env/coding/remainder model.

TWO REAL LATENT BUGS fixed (never caught — launchpad buys were never runtime-tested in Z; the
functional tests [5.3]/[6.1]/[6.3] are commented out of the gate):
1. INFO-ZERO (implements DalosInfoV1) was bound as module{OuronetInfoV1} throughout the launchpad
   -> runtime typecheck failure the moment any such fn runs. Rebind to real IGNIS (implements
   OuronetInfoV1), matching AQP-INFO. (0 remain in 2_CITIZEN/6_Launchpad.)
2. TS02-CPAD summoner guard not registered into TS01-A -> XB_DynamicFuelSTOA UEV_IMC failed.

REMAINING polish (gated / analogous): Snakes/Custodians/StoicPay buy functional proofs need the
E|DH equity collection funded, which only [6.1.1]/[6.1] provide (bit-rotted — task #95); their
conversions are analogous to the proven Spark path + load green. Spark-redeem URCi/INFO and
StoicIco collect URCi/INFO + a STOAICO|C_Collect wrapper are not yet added. Task #93: Stage-1
citizens (AOZ + DSP dispenser) — owner still deciding incorporation.

## Deferred structural cleanup
- **Task #90**: reorder inline `URCi_` into a canonical band + rename mis-prefixed `X_`
  internal writers to `XI_` (`X_KickStart`, `X_RemoveSecondary`, `X_TransmitCollectables`).
  All `URCi_` this session were placed inline right before their `C_` for readability.
