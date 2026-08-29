# Dual reward-split (task #89 / D1-G2) — deferred ECONOMIC-flip proof

## Status
- **Implementation: DONE + green** — `SPLIT|STAKED` / `SPLIT|TVL` per-farm mutable toggle
  (`04_FVT.pact`, Talos, INFO); full `Z.repl` pipeline green (542 asserts).
- **Switch mechanism + guards + reader: DONE + green** — `REPL/Stage_02/[6.2.11]_AQP-SPLIT-MODE.repl`
  (default pipeline): default mode, free bidirectional switching, invalid-mode + farm-only guards.
- **Economic-flip proof: DEFERRED** — the *same member's* W_i flipping between modes needs the
  full-boot `OuroLpFarm` (real staked LP + seeded `StoaValue`), which lives in `[6.2.9]_AQP-BOOT-FULL`.
  Every runner that boots it (`AQP-comprehensive`, `AQP-FULL`, `aqp-info-groundtruth`, …) is currently
  **RED on a pre-existing, unrelated defect**: the Bloodshed citizen modules call `DPDC-UDC::UDC_ScoreMetaData`,
  **removed by DPDC audit #45L** (metadata model changed — score dropped from `NonceMetaData`). 4 sites:
  `2_SLAVE/Stage_02/1_Bloodshed/{01_BSD-L:338, 02_BSD-E:271, 03_BSD-R:295, 04_BSD-C:370}.pact`.
  Correct migration is a Bloodshed/DPDC design decision (what the post-audit metadata should be), not a
  mechanical rename → a citizen-module task (see roadmap carry-over), NOT part of #89.

## Re-add once the citizen drift is fixed
Insert this TX at the end of `REPL/Stage_02/[6.2.9]_AQP-BOOT-FULL.repl` (before its END banner) and run
`AQP-comprehensive.repl`. It proves the SAME member's Level-2 W_i changes with the farm's mode
(participation vs pool-size), that TVL mode == whole-pool `UR_StoaValue`, and that restoring STAKED
returns the staked weight (a switch re-weights only future injects). Verified-correct by construction
(routes through `URC_MemberLevel2Weight`, exercised in `[6.2.11]`); only blocked on a green boot.

```lisp
(begin-tx "TX-BOOT-13-SPLIT - dual reward-split ECONOMIC flip on OuroLpFarm (task #89 / D1-G2)")
(print "")
(print "=== TX-BOOT-13-SPLIT — the SAME member's W_i flips STAKED<->TVL on the real LP farm ==")
(namespace "ouronet-ns")
(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)
(env-sigs [{ "key": "PK_AncientHodler", "caps": [] }])
(let*
    (
        (patron:string KST.ANHD)
        (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
        (ref-SWP:module{SwapperV3} SWP)
        (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
        (farm-id:string (ref-U|DALOS::UDC_Makeid "OuroLpFarm"))
        (members:[string] (ref-FVT::URH_FvtEnabledScoreEntityIdsForFvt farm-id))
        (m:string (at 0 members))
        (mtype:integer (ref-FVT::UR_FVT-SEL|ScoreEntityType farm-id m))
        (swp:string (ref-FVT::UR_FVT-SEL|Swpair farm-id m))
        (tvl:decimal (ref-SWP::UR_StoaValue swp))
        (w-staked:decimal (ref-FVT::URC_MemberLevel2Weight farm-id mtype m swp))
        (set-tvl:string (ref-TS02-C3::AQP-FVT|C_SetSplitMode patron farm-id "SPLIT|TVL"))
        (w-tvl:decimal (ref-FVT::URC_MemberLevel2Weight farm-id mtype m swp))
        (set-staked:string (ref-TS02-C3::AQP-FVT|C_SetSplitMode patron farm-id "SPLIT|STAKED"))
        (w-restored:decimal (ref-FVT::URC_MemberLevel2Weight farm-id mtype m swp))
    )
    (map print
        [
            (format "<(farm member)> => {} type={} swpair={}" [m mtype swp])
            (format "<(URC_MemberLevel2Weight)> STAKED={} TVL={} (StoaValue={})" [w-staked w-tvl tvl])
            (expect (format "<<TX-BOOT-13-SPLIT>> seeded swpair TVL > 0 got={}" [tvl]) true (> tvl 0.0))
            (expect (format "<<TX-BOOT-13-SPLIT>> SPLIT|TVL W_i == whole-pool TVL got={} expected={}" [w-tvl tvl]) tvl w-tvl)
            (expect (format "<<TX-BOOT-13-SPLIT>> SAME member W_i differs by mode (STAKED {} != TVL {})" [w-staked w-tvl]) true (!= w-staked w-tvl))
            (expect (format "<<TX-BOOT-13-SPLIT>> restoring SPLIT|STAKED returns the staked W_i got={} expected={}" [w-restored w-staked]) w-staked w-restored)
        ]
    )
)
(env-sigs [])
(commit-tx)
(print "=== END TX-BOOT-13-SPLIT ==================================================")
```
