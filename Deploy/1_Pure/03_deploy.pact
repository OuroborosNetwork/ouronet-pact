;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 3 of 20
;; This is STEP 3 of 21 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-2 must have run first, including the init steps between deploys.
;; 2 module(s), 285,032 gas measured in the REPL gas model, 224,714 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface AutostakeV3
    @doc "AutostakeV3 — same surface as AutostakeV1 with UtilityAtsV3.Awo typing for unstake objects."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    ;;  SCHEMAS
    ;;
    (defschema ATS|RewardTokenSchemaV2
        token:string
        nfr:bool
        resident:decimal
        unbonding:decimal
        royalty:decimal
    )
    (defschema ATS|Hot
        mint-time:time
    )
    (defschema CoilData
        primal-input-amount:decimal
        first-input-amount:decimal
        royalty-fee:decimal
        last-input-amount:decimal
        hibernation-fee:decimal
        rbt-amount:decimal
        rbt-id:string
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_MakeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string tm:time))
    (defun UDC_MakeZeroUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string))
    (defun UDC_MakeNegativeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string))
    (defun UDC_ComposePrimaryRewardToken:object{ATS|RewardTokenSchemaV2} (token:string nfr:bool))
    (defun UDC_RT:object{ATS|RewardTokenSchemaV2} (a:string b:bool c:decimal d:decimal e:decimal))
    (defun UDC_CoilData:object{CoilData} (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal g:string))
    ;;{5.2}  Compute [UC]
    (defun UC_AtspairAccount:string (atspair:string account:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UC]
    ;;
    (defun URU_UpgradeAtspairToV2 (atspairs:[string]))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [UR]
    ;;
    ;;  [0    ATS|Pairs:{ATS|PropertiesSchema}
    (defun UR_OwnerKonto:string (atspair:string))
    (defun UR_CanUpgrade:bool (atspair:string))
    (defun UR_CanChangeOwner:bool (atspair:string))
    (defun UR_Syphoning:bool (atspair:string))
    (defun UR_Hibernate:bool (atspair:string))
    (defun UR_IndexName:string (atspair:string))
    (defun UR_IndexDecimals:integer (atspair:string))
    (defun UR_Royalty:decimal (atspair:string))
    (defun UR_Syphon:decimal (atspair:string))
        ;;
    (defun UR_PeakHibernatePromile:decimal (atspair:string))
    (defun UR_HibernateDecay:decimal (atspair:string))
        ;;
    (defun UR_Lock:bool (atspair:string))
    (defun UR_Unlocks:integer (atspair:string))
        ;;
    (defun UR_RewardTokens:[object{ATS|RewardTokenSchemaV2}] (atspair:string))
    (defun UR_RewardTokenList:[string] (atspair:string))
    (defun UR_RewardTokenNFR:[bool] (atspair:string))
    (defun UR_RewardTokenRUR:[decimal] (atspair:string rur:integer))
    (defun UR_SingleRewardTokenNFR:bool (atspair:string rt:string))
    (defun UR_SingleRewardTokenRUR:decimal (atspair:string rt:string rur:integer))
        ;;
    (defun UR_ColdRewardBearingToken:string (atspair:string))
    (defun UR_ColdNativeFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryPositions:integer (atspair:string))
    (defun UR_ColdRecoveryFeeThresholds:[decimal] (atspair:string))
    (defun UR_ColdRecoveryFeeTable:[[decimal]] (atspair:string))
    (defun UR_ColdRecoveryFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryDuration:[integer] (atspair:string))
    (defun UR_EliteMode:bool (atspair:string))
        ;;
    (defun UR_HotRewardBearingToken:string (atspair:string))
    (defun UR_HotRecoveryStartingFeePromile:decimal (atspair:string))
    (defun UR_HotRecoveryDecayPeriod:integer (atspair:string))
    (defun UR_HotRecoveryFeeRedirection:bool (atspair:string))
        ;;
    (defun UR_DirectRecoveryFee:decimal (atspair:string))
        ;;
    (defun UR_ToggleColdRecovery:bool (atspair:string))
    (defun UR_ToggleHotRecovery:bool (atspair:string))
    (defun UR_ToggleDirectRecovery:bool (atspair:string))
    ;;
    (defun UR_RtPrecisions:[integer] (atspair:string))
    (defun UR_P0:[object{UtilityAtsV3.Awo}] (atspair:string account:string))
    (defun UR_P1-7:object{UtilityAtsV3.Awo} (atspair:string account:string position:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_Index (atspair:string))
    (defun URC_ResidentSum:decimal (atspair:string))
    (defun URC_PairRBTSupply:decimal (atspair:string))
    (defun URC_RBT:decimal (atspair:string rt:string rt-amount:decimal))
    (defun URCv_RTSplitAmounts:[decimal] (atspair:string rbt-amount:decimal))
    (defun URC_MaxSyphon:[decimal] (atspair:string))
        ;;
    (defun URCv_RewardTokenPosition:integer (atspair:string reward-token:string))
        ;;
    (defun URC_AccountUnbondingBalance:decimal (atspair:string account:string reward-token:string))
    (defun URC_CullValue:[decimal] (atspair:string input:object{UtilityAtsV3.Awo}))
    (defun URC_WhichPosition:integer (atspair:string c-rbt-amount:decimal account:string))
    (defun URCv_ColdRecoveryFee (atspair:string c-rbt-amount:decimal input-position:integer))
    (defun URC_CullColdRecoveryTime:time (atspair:string account:string))
    (defun URC_IzPresentHotRBT:bool (atspair:string))
        ;;
    (defun URC_RewardBearingTokenAmounts:object{CoilData} (ats:string rt:string amount:decimal))
    (defun URC_RewardBearingTokenAmountsWithHibernation:object{CoilData} (ats:string rt:string amount:decimal hibernation-dayz:integer))
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldAutostakePairs:[string] (account:string))
    (defun URH_ExistingAutostakePairs:[string] (ats:string))
    (defun URH_OwnedAutostakePairs:[string] (account:string))
    ;;  [URCi] cost readers — single source per op (the C_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_AddSecondary:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (atspair:string hot-rbt:string))
    (defun URCi_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
    (defun URCi_ToggleParameterLockStoa:decimal (atspair:string toggle:bool))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_id (atspair:string))
    (defun UEV_CanUpgradeON (atspair:string))
    (defun UEV_CanChangeOwnerON (atspair:string))
    (defun UEV_RewardTokenExistance (atspair:string reward-token:string existance:bool))
    (defun UEV_RewardBearingTokenExistance (atspair:string reward-bearing-token:string existance:bool cold-or-hot:bool))
    (defun UEV_ParameterLockState (atspair:string state:bool))
    (defun UEV_EliteState (atspair:string state:bool))
    (defun UEV_ColdRecoveryState (atspair:string state:bool))
    (defun UEV_HotRecoveryState (atspair:string state:bool))
    (defun UEV_DirectRecoveryState (atspair:string state:bool))
    (defun UEV_IssueData (atspair:string index-decimals:integer reward-token:string reward-bearing-token:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_RemoveSecondary (atspair:string reward-token:string))
    (defun XE_UpdateRUR (atspair:string reward-token:string rur:integer direction:bool amount:decimal))
    (defun XE_SpawnAutostakeAccount (atspair:string account:string))
    (defun XE_ReshapeUnstakeAccount (atspair:string account:string rp:integer))
    (defun XE_UpP0 (atspair:string account:string obj:[object{UtilityAtsV3.Awo}]))
    (defun XE_UpP1 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP2 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP3 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP4 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP5 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP6 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP7 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun HOT-RBT|C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun HOT-RBT|C_UpgradeBranding (patron:string entity-id:string months:integer))
    (defun HOT-RBT|C_Repurpose:object{IgnisCollectorV3.OutputCumulator} (hot-rbt:string nonce:integer repurpose-to:string))
        ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            account:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (atspair:string new-owner:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (atspair:string can-change-owner:bool syphoning:bool hibernate:bool))
    (defun C_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (atspair:string royalty:decimal))
    (defun C_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (atspair:string syphon:decimal))
    (defun C_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string peak:decimal decay:decimal))
        ;;
    (defun C_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (patron:string atspair:string toggle:bool))
    (defun C_AddSecondary:object{IgnisCollectorV3.OutputCumulator} (atspair:string reward-token:string rt-nfr:bool))
        ;;
    (defun C_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string c-nfr:bool c-fr:bool))
    (defun C_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun C_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (atspair:string soft-or-hard:bool base:integer growth:integer))
    (defun C_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
    (defun C_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
    (defun C_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
        ;;
    (defun C_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (atspair:string hot-rbt:string))
    (defun C_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string h-fr:bool))
    (defun C_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string promile:decimal decay:integer))
    (defun C_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
        ;;
    (defun C_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string promile:decimal))
    (defun C_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))

)
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AutostakeComputerV2
    @doc "AutostakeComputerV2 — the read/compute interface for ATS staking eligibility. It \
        \ defines the CanCoil/CanConstrict/CanCurl/CanBrumate schemas (a boolean plus \
        \ where-lists of eligible pools), exposing the pure computation surface the ATS \
        \ module and Talos consult to decide which autostake pools an account may coil, \
        \ constrict, curl or brumate into."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    (defschema CanCoil
        can-coil:bool
        where-coil:[string]
    )
    (defschema CanConstrict
        can-constrict:bool
        where-constrict:[string]
    )
    (defschema CanCurl
        can-curl:bool
        where-curl:[[string]]
    )
    (defschema CanBrumate
        can-brumate:bool
        where-brumate:[[string]]
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_CanCoil:object{CanCoil} (dptf:string))
    (defun UC_CanConstrict:object{CanConstrict} (dptf:string))
    (defun UC_CanCurl:object{CanCurl} (dptf:string))
    (defun UC_CanBrumate:object{CanBrumate} (dptf:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
;;
(module ATS GOV
    @doc "ATS — the autostake pool core, implementing AutostakeV3, AutostakeComputerV2 and \
        \ branding. It owns ATS|Pairs (pool config: owner, reward tokens, royalty/syphon, \
        \ cold/hot/direct recovery settings, hibernation, parameter locks) and ATS|Ledger \
        \ (per-account staked positions P0-P7). Owner/admin client ops configure pairs — \
        \ issue, control, royalty/syphon, recovery fees/durations/toggles, secondary reward \
        \ tokens, hot-RBT, elite mode and locks — while token-moving stake actions live in \
        \ ATSU."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements AutostakeV3)
    ;;
    ;; [AutostakeComputer]
    ;;
    (implements AutostakeComputerV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ATS                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ATS                                (keyset-ref-guard ATS|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ATS_ADMIN)))
    (defcap GOV|ATS_ADMIN ()
        (enforce-one
            "ATS Autostake Admin not satisfed"
            [
                (enforce-guard GOV|MD_ATS)
                (enforce-guard GOV|SC_ATS)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AutostakeKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|AutostakeKey)
        )
    )
    (defun GOV|ATS|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|ATS|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ATS|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|ATS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|ATS_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (mg:guard (create-capability-guard (P|ATS|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst ATS|SC_KEY                                (GOV|AutostakeKey))
    (defconst ATS|SC_NAME                               (GOV|ATS|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst NULLTIME                                  (time "1984-10-11T11:10:00Z"))
    (defconst ANTITIME                                  (time "1983-08-07T11:10:00Z"))
    ;;{3.2}  schemas
    ;;
    (defschema ATS|PropertiesSchemaV3
        id:string                       ;[x] Added in V3
        owner-konto:string
        can-upgrade:bool                ;[x] Added in V2. Gates C_Control (can-change-owner/
                                         ;    syphoning/hibernate) via UEV_CanUpgradeON - false
                                         ;    blocks C_Control entirely until set back to true.
                                         ;    Fix (audit finding #21L / L3): now settable via
                                         ;    C_ToggleUpgrade (was permanently true, no setter).
        can-change-owner:bool
        syphoning:bool
        hibernate:bool                  ;[x] Added in V2
        pair-index-name:string
        index-decimals:integer
        royalty-promile:decimal         ;[x] Added in V2
        syphon:decimal
        ;;
        peak-hibernate-promile:decimal  ;[x] Added in V2
        hibernate-decay:decimal         ;[x] Added in V2
        ;;
        parameter-lock:bool
        unlocks:integer
        ;;
        reward-tokens:[object{AutostakeV3.ATS|RewardTokenSchemaV2}]
        ;;
        ;;Cold Recovery
        c-rbt:string
        c-nfr:bool
        c-positions:integer
        c-limits:[decimal]
        c-array:[[decimal]]
        c-fr:bool
        c-duration:[integer]
        c-elite-mode:bool
        ;;
        ;;Hot Recovery
        h-rbt:string
        h-fr:bool
        h-promile:decimal
        h-decay:integer
        ;;
        ;;Direct Recovery
        d-promile:decimal               ;[x] Added in V2
        ;;
        ;;Toggle Recoveries
        cold-recovery:bool
        hot-recovery:bool
        direct-recovery:bool            ;[x] Added in V2
    )
    (defschema ATS|BalanceSchemaV2
        @doc "Key = <ATS-Pair> + BAR + <account>"
        P0:[object{UtilityAtsV3.Awo}]
        P1:object{UtilityAtsV3.Awo}
        P2:object{UtilityAtsV3.Awo}
        P3:object{UtilityAtsV3.Awo}
        P4:object{UtilityAtsV3.Awo}
        P5:object{UtilityAtsV3.Awo}
        P6:object{UtilityAtsV3.Awo}
        P7:object{UtilityAtsV3.Awo}
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    ;;{3.3}  tables
    (deftable ATS|Pairs:{ATS|PropertiesSchemaV3})   ;;Key = <ATS-Pair-id>
    (deftable ATS|Ledger:{ATS|BalanceSchemaV2})     ;;Key = <ATS-Pair-id> + BAR + <account>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap ATS|GOV ()
        @doc "Governor Capability for the Autostake Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap ATS|S>ROTATE_OWNERSHIP (atspair:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_OwnerKonto atspair) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (UEV_CanChangeOwnerON atspair)
            (CAP_Owner atspair)
        )
    )
    (defcap ATS|S>CONTROL (atspair:string hibernate:bool)
        @event
        (if hibernate
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (c-rbt:string (UR_ColdRewardBearingToken atspair))
                )
                (ref-DPTF::UEV_Hibernation c-rbt true)
            )
            true
        )
        (CAP_Owner atspair)
        (UEV_CanUpgradeON atspair)
    )
    (defcap ATS|S>SYPHON (atspair:string syphon:decimal)
        @event
        (let
            (
                (precision:integer (UR_IndexDecimals atspair))
            )
            (enforce (>= syphon 0.1) "Syphon cannot be set lower than 0.1")
            (enforce
                (= (floor syphon precision) syphon)
                (format "The syphon value of {} is not a valid Index Value for the {} ATS Pair" [syphon atspair])
            )
            (CAP_Owner atspair)
        )
    )
    ;; Fix (audit finding #6H / H1, owner-confirmed 2026-08-17): peak-hibernate-promile/hibernate-decay
    ;; were added later (V2) and never got the parameter-lock gate the original fields have. Added here.
    (defcap ATS|S>SET-HIBERNATION-FEES (atspair:string peak:decimal decay:decimal)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (UEV_ParameterLockState atspair false)
            (ref-U|ATS::UEV_HibernationFees peak decay)
            (CAP_Owner atspair)
        )
    )
    ;; Fix (audit finding #6H / H1, owner-confirmed 2026-08-17): royalty-promile was added later (V2)
    ;; and never got the parameter-lock gate. Added here. (syphon stays intentionally un-gated — #4C —
    ;; it's designed to fluctuate; do not add a lock check there.)
    ;; Fix (audit finding #7H / H2, owner-confirmed 2026-08-18): shared UEV_Fee (U_DALOS) allows up to
    ;; 999.0 promile (99.9%) - deliberately left untouched here since it's shared with DPTF's own fee
    ;; validation (05_DPTF.pact), outside this audit's scope. A per-tx delta cap was considered and
    ;; explicitly rejected by the owner (trivially bypassable by calling C_UpdateRoyalty repeatedly
    ;; within the same transaction). Instead, a royalty-specific ceiling: 500.0 promile (50%) max,
    ;; layered on top of UEV_Fee's existing {-1.0, 0.0} off-sentinels / [1.0, 999.0] active-range /
    ;; 4-decimal-precision check - -1.0 and 0.0 both still mean "off" and are always <= 500.0, so this
    ;; single enforce correctly narrows only the active [1.0, 999.0] range down to [1.0, 500.0].
    (defcap ATS|S>ROYALTY (atspair:string royalty:decimal)
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (UEV_ParameterLockState atspair false)
            (ref-U|DALOS::UEV_Fee royalty)
            (enforce (<= royalty 500.0) "Royalty cannot exceed 500.0 promile (50%)")
            (CAP_Owner atspair)
        )
    )
    ;;
    (defcap ATS|S>CONTROL-RECOVERY (atspair:string)
        (CAP_Owner atspair)
        (UEV_ParameterLockState atspair false)
    )
    (defcap ATS|S>SWITCH-COLD-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_ColdRecoveryState atspair (not toggle))
    )
    (defcap ATS|S>SWITCH-HOT-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_HotRecoveryState atspair (not toggle))
    )
    (defcap ATS|S>SWITCH-DIRECT-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_DirectRecoveryState atspair (not toggle))
    )
    ;;{C3}  Composed
    ;;
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    ;; Core (unevented) — StoicSyntax §14.7 layered-composition pattern: shared body, distinct leaf
    ;; events. Was two @event caps with the identical body pasted twice; refactored alongside the
    ;; C5 fix (ATS|C>HOT-RBT-BRD, below) that introduced this pattern's documentation.
    (defcap ATS|S>BRD (atspair:string)
        (CAP_Owner atspair)
        (compose-capability (P|ATS|CALLER))
    )
    (defcap ATS|C>UPDATE-BRD (atspair:string)
        @event
        (compose-capability (ATS|S>BRD atspair))
    )
    (defcap ATS|C>UPGRADE-BRD (atspair:string)
        @event
        (compose-capability (ATS|S>BRD atspair))
    )
    ;;
    (defcap ATS|C>REPURPOSE-HOT-RBT (hot-rbt:string)
        @event
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (atspair:string (ref-DPOF::UR_RewardBearingToken hot-rbt))
            )
            (CAP_Owner atspair)
            (compose-capability (ATS|GOV))
        )
    )
    ;; Fix (audit finding #5C / C5): HOT-RBT|C_UpdatePendingBranding/UpgradeBranding composed ATS|GOV
    ;; directly with no preceding ownership check — ATS|GOV is legitimately required (the hot-rbt's
    ;; DPOF owner-konto is ATS|SC_NAME, so DPOF's own UEV_ParentOwnership resolves to "prove you own
    ;; ats-sc", which only ATS's own code can do), but nothing gated *which caller* could trigger it.
    ;; Mirrors ATS|C>REPURPOSE-HOT-RBT's exact shape: resolve the pair from the hot-rbt, check real
    ;; ownership, THEN compose ATS|GOV.
    ;; Core (unevented) — shared validation body, StoicSyntax §14.7 layered-composition pattern
    ;; (mirrors ATS|S>CONTROL-RECOVERY / ATS|C>CONTROL-COLD-RECOVERY just above): resolve the pair,
    ;; check real ownership, compose ATS|GOV. Composed by both named leaf caps below — one body,
    ;; two distinctly-named events.
    (defcap ATS|C>HOT-RBT-BRD (entity-id:string)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (atspair:string (ref-DPOF::UR_RewardBearingToken entity-id))
            )
            (CAP_Owner atspair)
            (compose-capability (ATS|GOV))
        )
    )
    (defcap ATS|C>HOT-RBT-UPDATE-BRD (entity-id:string)
        @event
        (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
    )
    (defcap ATS|C>HOT-RBT-UPGRADE-BRD (entity-id:string)
        @event
        (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
    )
    (defcap ATS|C>ISSUE (account:string atspair:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string]rbt-nfr:[bool])
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length atspair))
                (l2:integer (length index-decimals))
                (l3:integer (length reward-token))
                (l4:integer (length rt-nfr))
                (l5:integer (length reward-bearing-token))
                (l6:integer (length rbt-nfr))
                (lengths:[integer] [l1 l2 l3 l4 l5 l6])
            )
            (ref-U|INT::UEV_UniformList lengths)
            (ref-U|LST::UEV_IzUnique atspair)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (map
                (lambda
                    (index:integer)
                    (UEV_IssueData (at index atspair) (at index index-decimals) (at index reward-token) (at index reward-bearing-token))
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap ATS|C>TOGGLE-PARAMETER-LOCK (atspair:string toggle:bool)
        @event
        (let
            (
                (cr:bool (UR_ToggleColdRecovery atspair))
                (hr:bool (UR_ToggleHotRecovery atspair))
                (dr:bool (UR_ToggleDirectRecovery atspair))
            )
            (CAP_Owner atspair)
            (UEV_ParameterLockState atspair (not toggle))
            (if toggle
                ;;When turned on, at least one Recovery must be set to true
                (enforce-one
                    (format "When Parameter Lock is set to {}, at least One Recovery must be on" [toggle])
                    [
                        (enforce cr "Cold Recovery must be active for exec")
                        (enforce hr "Hot Recovery must be active for exec")
                        (enforce dr "Direct Recovery must be active for exec")
                    ]
                )
                ;;When turned off, all Recoveries must be set to false
                (enforce 
                    (fold (and) true [(not cr) (not hr) (not dr)]) 
                    (format "ATSPair {} Recoveries must be stopped for exec" [atspair])
                )
            )
            (compose-capability (SECURE))
        )
    )
    ;;
    (defcap ATS|C>ADD-REWARD-TOKEN (atspair:string reward-token:string)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (n:integer (length (UR_RewardTokens atspair)))
            )
            (enforce (<= n 6) "An ATS Pair can have a maximum of 7 RTs")
            (ref-DPTF::CAP_Owner reward-token)
            ;;
            (CAP_Owner atspair)
            (UEV_RewardTokenExistance atspair reward-token false)
            (compose-capability (ATS|C>ADD-TOKEN atspair))
        )
    )
    (defcap ATS|C>ADD-TOKEN (atspair:string)
        (UEV_ParameterLockState atspair false)
        (UEV_ColdRecoveryState atspair false)
        (UEV_HotRecoveryState atspair false)
        (UEV_DirectRecoveryState atspair false)
        (compose-capability (P|ATS|CALLER))
    )
    ;;
    (defcap ATS|C>CONTROL-COLD-FEES (atspair:string)
        @event
        (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
    )
    (defcap ATS|C>SET_COLD_FEES (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (c-rbt-prec:integer (ref-DPTF::UR_Decimals (UR_ColdRewardBearingToken atspair)))
            )
            (ref-U|ATS::UEV_CRF|Positions fee-positions)
            (ref-U|ATS::UEV_CRF|FeeThresholds fee-thresholds c-rbt-prec)
            (ref-U|ATS::UEV_CRF|FeeArray fee-positions fee-thresholds fee-array)
            (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
        )
    )
    (defcap ATS|C>SET_COLD-DURATION (atspair:string soft-or-hard:bool base:integer growth:integer)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_ColdDurationParameters soft-or-hard base growth)
            (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
        )
    )
    (defcap ATS|C>TOGGLE_ELITE (atspair:string toggle:bool)
        @event
        (if toggle
            (let
                (
                    (x:integer (UR_ColdRecoveryPositions atspair))
                )
                (enforce 
                    (= x 7)
                    "Turning Elite Mode requires 7 Cold Recovery Positions"
                )
            )
            true
        )
        (UEV_EliteState atspair (not toggle))
        (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
    )
    (defcap ATS|C>CONTROL-COLD-RECOVERY (atspair:string)
        (UEV_ColdRecoveryState atspair false)
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;
    (defcap ATS|C>ADD-HOT-RBT (atspair:string hot-rbt:string)
        @event
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (hot-rbt-supply:decimal (ref-DPOF::UR_Supply hot-rbt))
                (hot-rbt-ftc:string (take 2 hot-rbt))
            )
            ;;1]Token Ownership
            (ref-DPOF::CAP_Owner hot-rbt)
            (CAP_Owner atspair)
            ;;2]Hot-RBT cannot be V|, Z| or H| -Tokens
            ;;FIXED 2026-09-12: the third entry was "H" (one character) while <hot-rbt-ftc> is
            ;;ALWAYS (take 2 hot-rbt) -- two characters -- so it could never match and HIBERNATION
            ;;tokens were not excluded at all. The comment above stated the intent correctly and
            ;;every other prefix test in the tree writes the pipe (02_SCORE.pact:2522/:2526 use
            ;;["Z|" "H|"]); this was the only site missing it. Pinned by modules/ATS.repl <<ATS-G15>>.
            (enforce 
                (not (contains hot-rbt-ftc ["V|" "Z|" "H|"]))
                "Special Orto-Fungibles cannot be registered as Hot-RBTs"
            )
            ;;3]ATS Pair must not have a Hot-RBT, when registering a Hot-RBT to it
            (UEV_RewardBearingTokenExistance atspair hot-rbt false false)
            ;;4]Only Zero Supply Orto-Fungibles can be registered as Hot-RBTs
            (enforce 
                (= hot-rbt-supply 0.0) 
                "Cannot Add OrtoFungible with non Zero Supply as ATS-Pair Hot RBT"
            )
            (compose-capability (ATS|C>ADD-TOKEN atspair))
            (compose-capability (ATS|GOV))
        )
    )
    (defcap ATS|C>CONTROL-HOT-FEE (atspair:string)
        @event
        (compose-capability (ATS|C>CONTROL-HOT-RECOVERY atspair))
    )
    (defcap ATS|C>SET_HOT_FEES (atspair:string promile:decimal decay:integer)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_Fee promile)
            (ref-U|ATS::UEV_Decay decay)
            (compose-capability (ATS|C>CONTROL-HOT-RECOVERY atspair))
        )
    )
    (defcap ATS|C>CONTROL-HOT-RECOVERY (atspair:string)
        (UEV_HotRecoveryState atspair false)    
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;
    (defcap ATS|C>SET_DIRECT_FEE (atspair:string promile:decimal)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_Fee promile)
            ;;Deliberately NOT ATS|S>CONTROL-DIRECT-RECOVERY -- see the note on that cap below.
            ;;The direct-recovery fee is adjustable while direct recovery is LIVE, unlike the hot
            ;;twin. Tested 2026-09-10: composing the state-checking cap here breaks the sovereign
            ;;init, which enables direct recovery and then sets the fee.
            (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
        )
    )
    ;;NEVER COMPOSED, and the asymmetry it would close is INTENTIONAL. Investigated 2026-09-10.
    ;;
    ;;It is the direct-recovery twin of ATS|C>CONTROL-HOT-RECOVERY (just above), which IS composed
    ;;by ATS|C>CONTROL-HOT-FEE / ATS|C>SET_HOT_FEES and so forbids changing the hot fee while hot
    ;;recovery is live. The direct side has no such link, which looked like a missing wiring --
    ;;especially next to ATS|C>ADD-TOKEN, which requires all four recovery states off.
    ;;
    ;;TESTED, AND THE HYPOTHESIS WAS WRONG. Composing this cap from ATS|C>SET_DIRECT_FEE breaks
    ;;the sovereign init: REPL/Stage_01/[4.0]_Sovereign-Executor.repl enables direct recovery on
    ;;KORIndex (line 1592) and THEN sets its fee to 100.0 (line 1595). The direct-recovery fee is
    ;;therefore adjustable while direct recovery is live BY DESIGN -- a real behavioural
    ;;difference from hot recovery, not an oversight. The change was reverted.
    ;;
    ;;Left in place as the record of that investigation: it is unreachable, it guards nothing
    ;;today, and re-wiring it would break the deploy chain.
    (defcap ATS|S>CONTROL-DIRECT-RECOVERY (atspair:string)
        (UEV_DirectRecoveryState atspair false)
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;{C4}  Ownership [gold]
    (defcap ATS|C>TOGGLE_UPGRADE (atspair:string toggle:bool)
        @doc "Fix (audit finding #21L / L3): can-upgrade previously had no setter at all - \
            \ this is the first one. Gates C_Control (can-change-owner/syphoning/hibernate) \
            \ via UEV_CanUpgradeON; turning this off blocks C_Control entirely until it's \
            \ turned back on."
        @event
        (CAP_Owner atspair)
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;;
    (defun UDC_MakeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string tm:time)
        {"reward-tokens"    : (make-list (length (UR_RewardTokenList atspair)) 0.0)
        ,"cull-time"        : tm}
    )
    (defun UDC_MakeZeroUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string)
        (UDC_MakeUnstakeObject atspair NULLTIME)
    )
    (defun UDC_MakeNegativeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string)
        (UDC_MakeUnstakeObject atspair ANTITIME)
    )
    (defun UDC_ComposePrimaryRewardToken:object{AutostakeV3.ATS|RewardTokenSchemaV2} (token:string nfr:bool)
        (UDC_RT token nfr 0.0 0.0 0.0)
    )
    (defun UDC_RT:object{AutostakeV3.ATS|RewardTokenSchemaV2} 
        (a:string b:bool c:decimal d:decimal e:decimal)
        (enforce 
            (fold (and) true [(>= c 0.0)(>= d 0.0)(>= e 0.0)]) 
            "Negative Decimals unallowed for Reward Token Object"
        )
        {"token"        : a
        ,"nfr"          : b
        ,"resident"     : c
        ,"unbonding"    : d
        ,"royalty"      : e}
    )
    (defun UDCx_Balance:object{ATS|BalanceSchemaV2}
        (
            a:[object{UtilityAtsV3.Awo}] b:object{UtilityAtsV3.Awo} 
            c:object{UtilityAtsV3.Awo} d:object{UtilityAtsV3.Awo}
            e:object{UtilityAtsV3.Awo} f:object{UtilityAtsV3.Awo}
            g:object{UtilityAtsV3.Awo} h:object{UtilityAtsV3.Awo}
            i:string j:string
        )
        {"P0"       : a
        ,"P1"       : b
        ,"P2"       : c
        ,"P3"       : d
        ,"P4"       : e
        ,"P5"       : f
        ,"P6"       : g
        ,"P7"       : h
        ,"id"       : i
        ,"account"  : j}
    )
    (defun UDC_CoilData:object{AutostakeV3.CoilData}
        (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal g:string)
        {"primal-input-amount"  : a
        ,"first-input-amount"   : b
        ,"royalty-fee"          : c
        ,"last-input-amount"    : d
        ,"hibernation-fee"      : e
        ,"rbt-amount"           : f
        ,"rbt-id"               : g}
    )
    (defun UDC_CanCoil:object{AutostakeComputerV2.CanCoil} (a:bool b:[string])
        {"can-coil"     : a
        ,"where-coil"   : b}
    )
    (defun UDC_CanConstrict:object{AutostakeComputerV2.CanConstrict} (a:bool b:[string])
        {"can-constrict"    : a
        ,"where-constrict"  : b}
    )
    (defun UDC_CanCurl:object{AutostakeComputerV2.CanCurl} (a:bool b:[[string]])
        {"can-curl"     : a
        ,"where-curl"   : b}
    )
    (defun UDC_CanBrumate:object{AutostakeComputerV2.CanBrumate} (a:bool b:[[string]])
        {"can-brumate"      : a
        ,"where-brumate"   : b}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_AtspairAccount:string (atspair:string account:string)
        (format "{}{}{}" [atspair BAR account])
    )
    ;;
    ;;
    (defun UC_CanCoil:object{AutostakeComputerV2.CanCoil} (dptf:string)
        @doc "Computes if a DPTF can be coiled, and outputs a <CanCoil> object. \
            \ This object also points the ats-pairs towards which the <dptf> can be coiled."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (can-coil:bool (ref-DPTF::URC_IzRT dptf))
            )
            (if (not can-coil)
                (UDC_CanCoil can-coil [])
                (UDC_CanCoil can-coil (UCx_RewardTokenPairsByHibernate dptf true))
            )
        )
    )
    (defun UC_CanConstrict:object{AutostakeComputerV2.CanConstrict} (dptf:string)
        @doc "Like coil, but <where-constrict> lists only hibernating ATS pairs where <dptf> is RT."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (can-constrict:bool (ref-DPTF::URC_IzRT dptf))
            )
            (if (not can-constrict)
                (UDC_CanConstrict can-constrict [])
                (UDC_CanConstrict can-constrict (UCx_RewardTokenPairsByHibernate dptf false))
            )
        )
    )
    (defun UC_CanCurl:object{AutostakeComputerV2.CanCurl} (dptf:string)
        @doc "Computes if a DPTF can be curled. <dptf> is a reward token in non-hibernating \
            \ ats-pair-1; that pair's cold RBT is a reward token in non-hibernating ats-pair-2."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (not (ref-DPTF::URC_IzRT dptf))
                (UDC_CanCurl false [])
                (let
                    (
                        (chains:[[string]] (UCx_ChainsRtRbtSecondRt dptf true))
                    )
                    (UDC_CanCurl (< 0 (length chains)) chains)
                )
            )
        )
    )
    (defun UC_CanBrumate:object{AutostakeComputerV2.CanBrumate} (dptf:string)
        @doc "Like curl, but ats-pair-1 is non-hibernating and ats-pair-2 must be hibernating."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (not (ref-DPTF::URC_IzRT dptf))
                (UDC_CanBrumate false [])
                (let
                    (
                        (chains:[[string]] (UCx_ChainsRtRbtSecondRt dptf false))
                    )
                    (UDC_CanBrumate (< 0 (length chains)) chains)
                )
            )
        )
    )
    ;;
    (defun UCx_ChainsRtRbtSecondRt:[[string]] (dptf:string second-pairs-non-hibernate:bool)
        @doc "Two-hop chains [ats1 ats2]: <dptf> is RT on non-hibernating ats1; cold RBT of ats1 \
            \ is RT on ats2. Second hop uses <second-pairs-non-hibernate> (true: non-hibernate ats2 \
            \ only; false: hibernating ats2 only). Enforces ats1 != ats2."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pair1-candidates:[string] (UCx_RewardTokenPairsByHibernate dptf true))
            )
            (fold
                (lambda (acc:[[string]] ats1:string)
                    (let
                        (
                            (rbt:string (UR_ColdRewardBearingToken ats1))
                            (pair2-candidates:[string]
                                (UCx_FilterHibernatedAts
                                    (ref-DPTF::UR_RewardToken rbt)
                                    second-pairs-non-hibernate
                                )
                            )
                        )
                        (+
                            acc
                            (fold
                                (lambda (row:[[string]] ats2:string)
                                    (if (!= ats1 ats2)
                                        (+ row [[ats1 ats2]])
                                        row
                                    )
                                )
                                []
                                pair2-candidates
                            )
                        )
                    )
                )
                []
                pair1-candidates
            )
        )
    )
    (defun UCx_RewardTokenPairsByHibernate:[string] (dptf:string non-hibernate:bool)
        @doc "ATS pairs where <dptf> is a reward token, filtered by hibernation: \
            \ <non-hibernate> true keeps non-hibernating pairs only; false keeps hibernating only."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (UCx_FilterHibernatedAts (ref-DPTF::UR_RewardToken dptf) non-hibernate)
        )
    )
    (defun UCx_FilterHibernatedAts:[string] (ats-pairs:[string] out-or-in:bool)
        @doc "If <out-or-in> is true, return <ats-pairs> with hibernating pairs removed; \
            \ if false, return only hibernating pairs."
        (if out-or-in
            (filter (lambda (ats-pair:string) (not (UR_Hibernate ats-pair))) ats-pairs)
            (filter (lambda (ats-pair:string) (UR_Hibernate ats-pair)) ats-pairs)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URU_UpgradeAtspairToV2 (atspairs:[string])
        (map
            (lambda
                (atspair:string)
                [
                    (UR_CanUpgrade atspair)
                    (UR_Hibernate atspair)
                    (UR_PeakHibernatePromile atspair)
                    (UR_HibernateDecay atspair)
                    (UR_Royalty atspair)
                    (UR_DirectRecoveryFee atspair)
                    (UR_ToggleDirectRecovery atspair)
                    (UR_RewardTokens atspair)
                ]
            )
            atspairs
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys ATS|Pairs)
    )
    (defun UR_KEYS:[string] ()
        (keys ATS|Ledger)
    )
    ;;
    (defun UR_Properties (atspair:string)
        (read ATS|Pairs atspair)
    )
    (defun UR_OwnerKonto:string (atspair:string)
        (at "owner-konto" (read ATS|Pairs atspair ["owner-konto"]))
    )
    (defun UR_CanUpgrade:bool (atspair:string)
        ;;#ATSm fix: this used to backfill a missing <can-upgrade> with a live table <update> --
        ;;an ungated write as a side effect of a nominal UR_* read, at the caller's gas expense,
        ;;and a read/write-separation violation of the UR_* prefix contract (same defect class as
        ;;DPTF's #30M <UR_Hibernation> and SWP's #50L <UR_StoaValue>, both already fixed).
        ;;Confirmed dead via a live StoaChain dirty-read (2026-09-10): all 4 deployed ATS pairs
        ;;already carry every one of these 8 fields, so the backfill branch never fires. The
        ;;write is dropped; the in-memory default fallback is kept, so the return value is
        ;;unchanged for every caller.
        (let 
            (
                (default-value:bool true)
                (temp (read ATS|Pairs atspair ["can-upgrade"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "can-upgrade" temp))
        )
    )
    (defun UR_CanChangeOwner:bool (atspair:string)
        (at "can-change-owner" (read ATS|Pairs atspair ["can-change-owner"]))
    )
    (defun UR_Syphoning:bool (atspair:string)
        (at "syphoning" (read ATS|Pairs atspair ["syphoning"]))
    )
    (defun UR_Hibernate:bool (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:bool false)
                (temp (read ATS|Pairs atspair ["hibernate"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernate" temp))
        )
    )
    (defun UR_IndexName:string (atspair:string)
        (at "pair-index-name" (read ATS|Pairs atspair ["pair-index-name"]))
    )
    (defun UR_IndexDecimals:integer (atspair:string)
        (at "index-decimals" (read ATS|Pairs atspair ["index-decimals"]))
    )
    (defun UR_Royalty:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.0)
                (temp (read ATS|Pairs atspair ["royalty-promile"]))
                (needs-populate:bool (= temp {}))
                (link:decimal (if needs-populate default-value (at "royalty-promile" temp)))
            )
            (if (= link -1.0)
                0.0
                link
            )
        )
    )
    (defun UR_Syphon:decimal (atspair:string)
        (at "syphon" (read ATS|Pairs atspair ["syphon"]))
    )
    ;;
    (defun UR_PeakHibernatePromile:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 120.0)
                (temp (read ATS|Pairs atspair ["peak-hibernate-promile"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "peak-hibernate-promile" temp))
        )
    )
    (defun UR_HibernateDecay:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.008 )
                (temp (read ATS|Pairs atspair ["hibernate-decay"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernate-decay" temp))
        )
    )
    ;;
    (defun UR_Lock:bool (atspair:string)
        (at "parameter-lock" (read ATS|Pairs atspair ["parameter-lock"]))
    )
    (defun UR_Unlocks:integer (atspair:string)
        (at "unlocks" (read ATS|Pairs atspair ["unlocks"]))
    )
    ;;
    (defun UR_RewardTokens:[object{AutostakeV3.ATS|RewardTokenSchemaV2}] (atspair:string)
        ;;#ATSm fix: migration backfill <update> dropped -- see <UR_CanUpgrade>. The write WAS
        ;;load-bearing here (the old body re-read the row afterwards), so the populate branch now
        ;;yields the royalty-augmented list directly instead of persisting then re-reading.
        (let
            (
                (temp:list (at "reward-tokens" (read ATS|Pairs atspair ["reward-tokens"])))
                (first-element (at 0 temp))
                (has-royalty:bool (contains "royalty" first-element))
                (needs-populate:bool (not has-royalty))
            )
            (if needs-populate
                (let
                    (
                        (default-royalty:decimal 0.0)
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                    )
                    (fold
                        (lambda
                            (acc:[object{AutostakeV3.ATS|RewardTokenSchemaV2}] idx:integer)
                            (ref-U|LST::UC_AppL acc
                                (+
                                    (at idx temp)
                                    {"royalty" : default-royalty}
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length temp) 1))
                    )
                )
                temp
            )
        )
    )
    (defun UR_RewardTokenList:[string] (atspair:string)
        (fold
            (lambda
                (acc:[string] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                (+ acc [(at "token" item)])
            )
            []
            (UR_RewardTokens atspair)
        )
    )
    (defun UR_RewardTokenNFR:[bool] (atspair:string)
        (fold
            (lambda
                (acc:[bool] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                (+ acc [(at "nfr" item)])
            )
            []
            (UR_RewardTokens atspair)
        )
    )
    (defun UR_RewardTokenRUR:[decimal] (atspair:string rur:integer)
        @doc "Returns the RUR variables of a RewardToken Object \
            \ <rur> = 1: <resident> \
            \ <rur> = 2: <unbonding> \
            \ <rur> = 3: <royalty>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
            )
            (ref-U|INT::UEV_PositionalVariable rur 3 "Invalid RUR Integer")
            (fold
                (lambda
                    (acc:[decimal] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                    (ref-U|LST::UC_AppL acc
                        (cond
                            ((= rur 1) (at "resident" item))
                            ((= rur 2) (at "unbonding" item))
                            ((= rur 3) (at "royalty" item))
                            0.0
                        )
                    )
                )
                []
                (UR_RewardTokens atspair)
            )
        )
    )
    (defun UR_SingleRewardTokenNFR:bool (atspair:string rt:string)
        @doc "Read NFR of a Reward Token, Fails if <rt> is not Reward Token for <atspair>"
        (at (URCv_RewardTokenPosition atspair rt) (UR_RewardTokenNFR atspair))
    )
    (defun UR_SingleRewardTokenRUR:decimal (atspair:string rt:string rur:integer)
        @doc "Read RUR of a Reward Token, Fails if <rt> is not Reward Token for <atspair>"
        (at (URCv_RewardTokenPosition atspair rt) (UR_RewardTokenRUR atspair rur))
    )
    ;;Cold Recovery
    (defun UR_ColdRewardBearingToken:string (atspair:string)
        (at "c-rbt" (read ATS|Pairs atspair ["c-rbt"]))
    )
    (defun UR_ColdNativeFeeRedirection:bool (atspair:string)
        (at "c-nfr" (read ATS|Pairs atspair ["c-nfr"]))
    )
    (defun UR_ColdRecoveryPositions:integer (atspair:string)
        (at "c-positions" (read ATS|Pairs atspair ["c-positions"]))
    )
    (defun UR_ColdRecoveryFeeThresholds:[decimal] (atspair:string)
        (at "c-limits" (read ATS|Pairs atspair ["c-limits"]))
    )
    (defun UR_ColdRecoveryFeeTable:[[decimal]] (atspair:string)
        (at "c-array" (read ATS|Pairs atspair ["c-array"]))
    )
    (defun UR_ColdRecoveryFeeRedirection:bool (atspair:string)
        (at "c-fr" (read ATS|Pairs atspair ["c-fr"]))
    )
    (defun UR_ColdRecoveryDuration:[integer] (atspair:string)
        (at "c-duration" (read ATS|Pairs atspair ["c-duration"]))
    )
    (defun UR_EliteMode:bool (atspair:string)
        (at "c-elite-mode" (read ATS|Pairs atspair ["c-elite-mode"]))
    )
    ;;Hot Recovery
    (defun UR_HotRewardBearingToken:string (atspair:string)
        (at "h-rbt" (read ATS|Pairs atspair ["h-rbt"]))
    )
    (defun UR_HotRecoveryStartingFeePromile:decimal (atspair:string)
        (at "h-promile" (read ATS|Pairs atspair ["h-promile"]))
    )
    (defun UR_HotRecoveryDecayPeriod:integer (atspair:string)
        (at "h-decay" (read ATS|Pairs atspair ["h-decay"]))
    )
    (defun UR_HotRecoveryFeeRedirection:bool (atspair:string)
        (at "h-fr" (read ATS|Pairs atspair ["h-fr"]))
    )
    ;;Direct Recovery
    (defun UR_DirectRecoveryFee:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.0)
                (temp (read ATS|Pairs atspair ["d-promile"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "d-promile" temp))
        )
    )
    ;;Toggle Recoveries
    (defun UR_ToggleColdRecovery:bool (atspair:string)
        (at "cold-recovery" (read ATS|Pairs atspair ["cold-recovery"]))
    )
    (defun UR_ToggleHotRecovery:bool (atspair:string)
        (at "hot-recovery" (read ATS|Pairs atspair ["hot-recovery"]))
    )
    (defun UR_ToggleDirectRecovery:bool (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:bool false)
                (temp (read ATS|Pairs atspair ["direct-recovery"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "direct-recovery" temp))
        )
    )
    ;;
    ;;
    (defun UR_RtPrecisions:[integer] (atspair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[integer] rt:string)
                    (ref-U|LST::UC_AppL acc (ref-DPTF::UR_Decimals rt))
                )
                []
                (UR_RewardTokenList atspair)
            )
        )
    )
    (defun UR_P0:[object{UtilityAtsV3.Awo}] (atspair:string account:string)
        (at "P0" (read ATS|Ledger (UC_AtspairAccount atspair account) ["P0"]))
    )
    (defun UR_P1-7:object{UtilityAtsV3.Awo} (atspair:string account:string position:integer)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (k:string (UC_AtspairAccount atspair account))
            )
            (ref-U|INT::UEV_PositionalVariable position 7 "Invalid Position Number")
            (cond
                ((= position 1) (at "P1" (read ATS|Ledger k ["P1"])))
                ((= position 2) (at "P2" (read ATS|Ledger k ["P2"])))
                ((= position 3) (at "P3" (read ATS|Ledger k ["P3"])))
                ((= position 4) (at "P4" (read ATS|Ledger k ["P4"])))
                ((= position 5) (at "P5" (read ATS|Ledger k ["P5"])))
                ((= position 6) (at "P6" (read ATS|Ledger k ["P6"])))
                ((= position 7) (at "P7" (read ATS|Ledger k ["P7"])))
                (UDC_MakeNegativeUnstakeObject atspair)
            )
        )
    )
    (defun UR_P-Seven:[object{UtilityAtsV3.Awo}]
        (atspair:string account:string)
        (let
            (
                (k:string (UC_AtspairAccount atspair account))
            )
            [
                (at "P1" (read ATS|Ledger k ["P1"]))
                (at "P2" (read ATS|Ledger k ["P2"]))
                (at "P3" (read ATS|Ledger k ["P3"]))
                (at "P4" (read ATS|Ledger k ["P4"]))
                (at "P5" (read ATS|Ledger k ["P5"]))
                (at "P6" (read ATS|Ledger k ["P6"]))
                (at "P7" (read ATS|Ledger k ["P7"]))
            ]
        )
        
    )
    (defun URC_Index (atspair:string)
        @doc "Computes the Index of an <atspair>"
        (let
            (
                (p:integer (UR_IndexDecimals atspair))
                (rs:decimal (URC_ResidentSum atspair))
                (rbt-supply:decimal (URC_PairRBTSupply atspair))
            )
            (if
                (= rbt-supply 0.0)
                -1.0
                (floor (/ rs rbt-supply) p)
            )
        )
    )
    (defun URC_ResidentSum:decimal (atspair:string)
        @doc "Computes the Residend Sum of all <atspair> Reward Tokens"
        (fold (+) 0.0 (UR_RewardTokenRUR atspair 1))
    )
    (defun URC_PairRBTSupply:decimal (atspair:string)
        @doc "Computed the Total Sum of Reward Bearing Tokens of an <atspair> \
            \ Also inludes the Hot-RBT amount"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (c-rbt-supply:decimal (ref-DPTF::UR_Supply c-rbt))
            )
            (if (= (URC_IzPresentHotRBT atspair) false)
                c-rbt-supply
                (let
                    (
                        (h-rbt:string (UR_HotRewardBearingToken atspair))
                        (h-rbt-supply:decimal (ref-DPOF::UR_Supply h-rbt))
                    )
                    (+ c-rbt-supply h-rbt-supply)
                )
            )
        )
    )
    (defun URC_RBT:decimal (atspair:string rt:string rt-amount:decimal)
        @doc "Computes the value in RBT of a given <rt> Token <rt-amount> for an <atspair>"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (index:decimal (abs (URC_Index atspair)))
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (p-rbt:integer (ref-DPTF::UR_Decimals c-rbt))
            )
            (enforce
                (= (floor rt-amount p-rbt) rt-amount)
                (format "Input amount of {} must have at most a precision equal to that of the Cold-RBT ({})" [rt-amount p-rbt])
            )
            ;;THE SINGULARITY. <index> is a share price and the line below inverts it, so a zero
            ;;index is a division by zero -- and zero is a REACHABLE LIVE STATE, not a contrived
            ;;input: any pair whose reward-bearing token carries supply minted OUTSIDE the pool
            ;;reads resident-sum 0 against a positive rbt-supply, which is exactly the state the
            ;;five AOZ primal-asset pools are in at deploy.
            ;;
            ;;The sibling op already refuses this: ATSU|C>FUEL enforces (>= index 0.1) and its
            ;;message was reworded on 2026-09-13 specifically so the caller is told something true
            ;;about their own pair. ATSU|C>COIL has no index check at all, so the coil door -- the
            ;;one an ordinary user reaches -- died inside the arithmetic with
            ;;"Arithmetic exception: div by zero, decimal", which names neither the pool nor the
            ;;cause, and which `try` cannot even catch.
            ;;
            ;;Guarded HERE rather than in ATSU|C>COIL deliberately: this is the function that
            ;;divides, and it is shared by the exec path and by the INFO cost previews, so a quote
            ;;for an impossible coil now refuses in the same words instead of throwing.
            ;;Pinned by RedTeam/[RT-A]_Economics.repl <<RT-A-003c>>/<<RT-A-003d>>.
            (enforce
                (> index 0.0)
                (format "Coiling requires an ATS-Pair Index greater than zero; {} has none" [atspair])
            )
            (floor (/ rt-amount index) p-rbt)
        )
    )
    (defun URCv_RTSplitAmounts:[decimal] (atspair:string rbt-amount:decimal)
        @doc "Computes the amount of RT Tokens an <rbt-amount> of RBT would yield for an <atspair>"
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (rbt-supply:decimal (URC_PairRBTSupply atspair))
                (index:decimal (URC_Index atspair))
                (resident-amounts:[decimal] (UR_RewardTokenRUR atspair 1))
                (rt-precision-lst:[integer] (UR_RtPrecisions atspair))
            )
            (enforce (<= rbt-amount rbt-supply) "Cannot compute for amounts greater than the pairs rbt supply")
            ;;Same singularity URC_RBT carries, same reasoning: the split divides by <index>, and a
            ;;zero index is a reachable live state (rbt-supply minted outside the pool). Guarded
            ;;HERE because ten call sites across ATSU and the INFO readers share this function --
            ;;one enforce covers every one of them, and they all refuse in the same words.
            (enforce
                (> index 0.0)
                (format "ATS-Pair {} has a zero Index; reward-token amounts cannot be derived" [atspair])
            )
            (ref-U|ATS::UC_SplitByIndexedRBT rbt-amount rbt-supply index resident-amounts rt-precision-lst)
        )
    )
    (defun URC_MaxSyphon:[decimal] (atspair:string)
        @doc "Computes the maximum amount of RTs that can be syphoned from the <atspair>"
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (index:decimal (URC_Index atspair))
                (syphon:decimal (UR_Syphon atspair))
                (resident-amounts:[decimal] (UR_RewardTokenRUR atspair 1))
                (precisions:[integer] (UR_RtPrecisions atspair))
                (max-precision:integer (ref-U|INT::UEV_MaxInteger precisions))
                (max-pp:integer (at 0 (ref-U|LST::UC_Search precisions max-precision)))
                (pair-rbt-supply:decimal (URC_PairRBTSupply atspair))
            )
            (if (<= index syphon)
                (make-list (length precisions) 0.0)
                (let
                    (
                        (index-diff:decimal (- index syphon))
                        (rbt:string (UR_ColdRewardBearingToken atspair))
                        (rbt-precision:integer (ref-DPTF::UR_Decimals rbt))
                        (max-sum:decimal (floor (* pair-rbt-supply index-diff) rbt-precision))
                        (prelim:[decimal]
                            (fold
                                (lambda
                                    (acc:[decimal] idx:integer)
                                    (ref-U|LST::UC_AppL acc
                                        (floor (/ (* (- index syphon) (at idx resident-amounts)) index) (at idx precisions))
                                    )
                                )
                                []
                                (enumerate 0 (- (length precisions) 1))
                            )
                        )
                        (prelim-sum:decimal (fold (+) 0.0 prelim))
                        (diff:decimal (- max-sum prelim-sum))
                    )
                    (if (= diff 0.0)
                        prelim
                        (ref-U|LST::UC_ReplaceAt prelim max-pp (+ diff (at max-pp prelim)))
                    )
                )
            )
        )
    )
    ;;
    (defun URCv_RewardTokenPosition:integer (atspair:string reward-token:string)
        @doc "Computes the position of a RT in the <atspair> definition"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (reward-token-lst:[string] (UR_RewardTokenList atspair))
                (iz-on-lst:bool (contains reward-token reward-token-lst))
            )
            (enforce iz-on-lst (format "RT {} isnt not an RT in the ATS-Pair {}" [reward-token atspair]))
            (at 0 (ref-U|LST::UC_Search reward-token-lst reward-token))
        )
    )
    ;;Autostake Account
    (defun URC_AccountUnbondingBalance:decimal (atspair:string account:string reward-token:string)
        @doc "Computes the unbonding amount for a given <account> and specific <atspair> and <reward-token>"
        (+
            (fold
                (lambda
                    (acc:decimal item:object{UtilityAtsV3.Awo})
                    (+ acc (URCx_UnstakeObjectUnbondingValue atspair reward-token item))
                )
                0.0
                (UR_P0 atspair account)
            )
            (fold
                (lambda
                    (acc:decimal item:integer)
                    (+ acc (URCx_UnstakeObjectUnbondingValue atspair reward-token (UR_P1-7 atspair account item)))
                )
                0.0
                (enumerate 1 7)
            )
        )
    )
    (defun URCx_UnstakeObjectUnbondingValue (atspair:string reward-token:string io:object{UtilityAtsV3.Awo})
        (let
            (
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
                (rt:[decimal] (at "reward-tokens" io))
                (rb:decimal (at rtp rt))
            )
            (if (= rb -1.0)
                0.0
                rb
            )
        )
    )
    (defun URC_CullValue:[decimal] (atspair:string input:object{UtilityAtsV3.Awo})
        @doc "Computes the Cull value of an <input> unstake objected, given a specific <atspair> \
        \ Returns a list of decimal, the list having as many decimal as the <atspair> has reward tokens \
        \ Returns a list of 0.0 is nothing can be culled"
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (rt-lst:[string] (UR_RewardTokenList atspair))
                (rt-amounts:[decimal] (at "reward-tokens" input))
                (l:integer (length rt-lst))
                (iz:bool (ref-U|ATS::UC_IzCullable input))
            )
            (if iz
                rt-amounts
                (make-list l 0.0)
            )
        )
    )
    (defun URC_WhichPosition:integer (atspair:string c-rbt-amount:decimal account:string)
        @doc "Computes which Position can be used next for uncoiling"
        (let
            (
                (elite:bool (UR_EliteMode atspair))
            )
            (if elite
                (URCx_ElitePosition atspair c-rbt-amount account)
                (URCx_NonElitePosition atspair account)
            )
        )
    )
    (defun URCx_ElitePosition:integer (atspair:string c-rbt-amount:decimal account:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ELITE:module{EliteV2} ELITE)
                (positions:integer (UR_ColdRecoveryPositions atspair))
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (iz-ea-id:bool (if (= ea-id c-rbt) true false))
                        (pstate:[integer] (URCx_PSL atspair account))
                        (met:integer (ref-DALOS::UR_Elite-Tier-Major account))
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (t-ea-supply:decimal (ref-ELITE::URC_EliteAurynzSupply account))
                        (virtual-met:integer (str-to-int (take 1 (at "tier" (ref-U|ATS::UDC_Elite (- t-ea-supply c-rbt-amount))))))
                        ;;(available:[integer] (if iz-ea-id (take virtual-met pstate) (take met pstate)))
                        ;;Resulting tier after uncoil must support the position we use; tier 0 still allows 1 position.
                        (positions-after:integer (if (= virtual-met 0) 1 virtual-met))
                        (available:[integer] (if iz-ea-id (take positions-after pstate) (take met pstate)))
                        (search-res:[integer] (ref-U|LST::UC_Search available 1))
                    )
                    (if iz-ea-id
                        (enforce (<= c-rbt-amount ea-supply) "Amount of EA used for Cold Recovery cannot be greater than what exists on Account")
                        true
                    )
                    (if (= (length search-res) 0)
                        0
                        (+ (at 0 search-res) 1)
                    )
                )
                (URCx_NonElitePosition atspair account)
            )
        )
    )
    (defun URCx_NonElitePosition:integer (atspair:string account:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (positions:integer (UR_ColdRecoveryPositions atspair))
            )
            (if (= positions -1)
                -1
                (let
                    (
                        (pstate:[integer] (URCx_PSL atspair account))
                        (available:[integer] (take positions pstate))
                        (search-res:[integer] (ref-U|LST::UC_Search available 1))
                    )
                    (if (= (length search-res) 0)
                        0
                        (+ (at 0 search-res) 1)
                    )
                )
            )
        )
    )
    (defun URCx_PSL:[integer] (atspair:string account:string)
        (fold
            (lambda
                (acc:[integer] idx:integer)
                (+ acc [(URCx_PosSt atspair account idx)])
            )
            []
            (enumerate 1 7)
        )
    )
    (defun URCx_PosSt:integer (atspair:string account:string position:integer)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (zero:object{UtilityAtsV3.Awo} 
                    ;;Opened
                    (UDC_MakeZeroUnstakeObject atspair)
                )
                (negative:object{UtilityAtsV3.Awo} 
                    ;;Closed
                    (UDC_MakeNegativeUnstakeObject atspair)
                )
                (elite:bool (UR_EliteMode atspair))
                (hybrid:object{UtilityAtsV3.Awo}
                    (if elite negative zero)
                )
            )
            (ref-U|INT::UEV_PositionalVariable position 7 "Input Position out of bounds")
            (with-default-read ATS|Ledger (UC_AtspairAccount atspair account)
                {"P1"   : zero
                ,"P2"   : hybrid
                ,"P3"   : hybrid
                ,"P4"   : hybrid
                ,"P5"   : hybrid
                ,"P6"   : hybrid
                ,"P7"   : hybrid}
                { "P1" := p1, "P2" := p2, "P3" := p3, "P4" := p4, "P5" := p5, "P6" := p6, "P7" := p7 }
                (cond
                    ((= position 1) (URCx_PosObjSt atspair p1))
                    ((= position 2) (URCx_PosObjSt atspair p2))
                    ((= position 3) (URCx_PosObjSt atspair p3))
                    ((= position 4) (URCx_PosObjSt atspair p4))
                    ((= position 5) (URCx_PosObjSt atspair p5))
                    ((= position 6) (URCx_PosObjSt atspair p6))
                    ((= position 7) (URCx_PosObjSt atspair p7))
                    0
                )
            )
        )
    )
    (defun URCx_PosObjSt:integer (atspair:string input-obj:object{UtilityAtsV3.Awo})
        @doc "Computes the state of an uncoil positional object, \
        \ to see if it the position it is on can be used for uncoiling \
        \ <-1> = closed; <0> = occupied; <1> = opened"
        (let
            (
                (zero:object{UtilityAtsV3.Awo} (UDC_MakeZeroUnstakeObject atspair))
                (negative:object{UtilityAtsV3.Awo} (UDC_MakeNegativeUnstakeObject atspair))
            )
            (if (= input-obj zero)
                1
                (if (= input-obj negative)
                    -1
                    0
                )
            )
        )
    )
    (defun URCv_ColdRecoveryFee (atspair:string c-rbt-amount:decimal input-position:integer)
        @doc "Computes the Cold Recovery Fee for a given <c-rbt-amount> of a given <atspair> on a given <input-position>"
        (enforce (!= input-position 0) "Cannot Compute Cold Recovery Fee as no more Cold Recovery Positions are available")
        (let
            (
                (ats-limit-values:[decimal] (UR_ColdRecoveryFeeThresholds atspair))
                (ats-limits:integer (length ats-limit-values))
                (ats-fee-array:[[decimal]] (UR_ColdRecoveryFeeTable atspair))
                (ats-fee-array-length:integer (length ats-fee-array))
                (ats-fee-array-length-length:integer (length (at 0 ats-fee-array)))
                (zc1:bool (if (= ats-limits 1) true false))
                (zc2:bool (if (= (at 0 ats-limit-values) 0.0) true false))
                (zc3:bool (and zc1 zc2))
                (zc4:bool (if (= ats-fee-array-length 1) true false))
                (zc5:bool (if (= ats-fee-array-length-length 1) true false))
                (zc6:bool (and zc4 zc5))
                (zc7:bool (if (= (at 0 (at 0 ats-fee-array)) 0.0) true false))
                (zc8:bool (and zc6 zc7))
                (zc9:bool (and zc3 zc8))
            )
            (if zc9
                0.0
                (let
                    (
                        (limit:integer
                            (fold
                                (lambda
                                    (acc:integer tv:decimal)
                                    (if (< c-rbt-amount tv)
                                        acc
                                        (+ acc 1)
                                    )
                                )
                                0
                                ats-limit-values
                            )
                        )
                        (qlst:[decimal]
                            (if (= input-position -1)
                                (at 0 ats-fee-array)
                                (at (- input-position 1) ats-fee-array)
                            )
                        )
                    )
                    (at limit qlst)
                )
            )
        )
    )
    (defun URC_CullColdRecoveryTime:time (atspair:string account:string)
        @doc "Computes the Cull Time for Cold Recovery for a given <atspair> and <account>"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
                (position:integer
                    (if (= major 0)
                        0
                        (+ (* (- major 1) 7) minor)
                    )
                )
                (crd:[integer] (UR_ColdRecoveryDuration atspair))
                (h:integer (at position crd))
                (present-time:time (at "block-time" (chain-data)))
            )
            (add-time present-time (hours h))
        )
    )
    (defun URC_IzPresentHotRBT:bool (atspair:string)
        @doc "Returns a Boolean if an <atspair> has a Hot-RBT or not"
        (if (= (UR_HotRewardBearingToken atspair) BAR)
            false
            true
        )
    )
    ;;
    (defun URC_RewardBearingTokenAmounts:object{AutostakeV3.CoilData}
        (ats:string rt:string amount:decimal)
        (URCx_RBT-Amount ats rt amount 1)
    )
    (defun URC_RewardBearingTokenAmountsWithHibernation:object{AutostakeV3.CoilData}
        (ats:string rt:string amount:decimal hibernation-dayz:integer)
        (URCx_RBT-Amount ats rt amount hibernation-dayz)
    )
    (defun URCx_RBT-Amount:object{AutostakeV3.CoilData} 
        (ats:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (h:bool (ref-ATS::UR_Hibernate ats))
                (royalty:decimal (ref-ATS::UR_Royalty ats))
                (rt-prec:integer (ref-DPTF::UR_Decimals rt))
                (royalty-split:[decimal] (ref-U|ATS::UC_PromilleSplit royalty amount rt-prec))
                (input-amount:decimal (at 0 royalty-split))
                (royalty-fee:decimal (at 1 royalty-split))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
            )
            (if (not h)
                (UDC_CoilData
                    amount
                    input-amount
                    royalty-fee
                    input-amount
                    0.0
                    (ref-ATS::URC_RBT ats rt input-amount)
                    c-rbt
                )
                (let
                    (
                        (php:decimal (ref-ATS::UR_PeakHibernatePromile ats))
                        (hd:decimal (ref-ATS::UR_HibernateDecay ats))
                        (raw-hibernation-fee-promile:decimal (- php (* hd (dec dayz))))
                        (hibernation-fee-promile:decimal 
                            (if (<= raw-hibernation-fee-promile 0.0)
                                0.0
                                raw-hibernation-fee-promile
                            )
                        )
                        (hibernating-split:[decimal] (ref-U|ATS::UC_PromilleSplit hibernation-fee-promile input-amount rt-prec))
                        (last-input-amount:decimal (at 0 hibernating-split))
                        (hibernation-fee:decimal (at 1 hibernating-split))
                    )
                    (UDC_CoilData
                        amount
                        input-amount
                        royalty-fee
                        last-input-amount
                        hibernation-fee
                        (ref-ATS::URC_RBT ats rt last-input-amount)
                        c-rbt
                    )
                )
            )
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1] Returns ATSPairs that Have the Account registered in the ATS|Ledger (has used unstake)
    (defun URH_HeldAutostakePairs:[string] (account:string)
        @doc "Returns all ATSpairs for which the <account> existsin the ATS|Ledger Table"
        (map (at "id")
            (select ATS|Ledger ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts have used a given ATSpair Unstaking
    (defun URH_ExistingAutostakePairs:[string] (ats:string)
        @doc "Returns all Ouronet Accounts that exist in a given <ats> ATS|Ledger"
        (map (at "account")
            (select ATS|Ledger ["account"]
                (where "id" (= ats))
            )
        )
    )
    ;;3]Returns a List of ATSPairs that are owned by a given Account for Management Purposes
    (defun URH_OwnedAutostakePairs:[string] (account:string)
        @doc "Returns all ATSPairs that can be managed by the given <account>"
        (map (at "id")
            (select ATS|Pairs ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;
    ;;[URCi] cost readers — single cost source per op. The C_ returns/bills its URCi; Phase 1.2 INFO
    ;;  previews from the same reader. (HOT-RBT branding/Repurpose forward DPOF costs — no own URCi.)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_OwnerKonto entity-id) 5.0)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_RotateOwnership" "auth")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_Control" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_UpdateRoyalty" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_UpdateSyphon" "usage")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetHibernationFees" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ControlColdRecoveryFees" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetColdRecoveryDuration" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ToggleElite" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ToggleUpgrade" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchColdRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ControlHotRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        @doc "Cost preview for the ATS|C_SetHotRecoveryFee client (core fn is plural, the \
            \ Talos op is singular — billed under the TALOS name like every other key)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetHotRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchHotRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetDirectRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchDirectRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  Construct-with-price (pure): also reused for C_AddHotRBT's ico0 (identical token-issue construct).
    (defun URCi_AddSecondary:object{IgnisCollectorV3.OutputCumulator} ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "ATS|C_AddSecondary" "ats-secondary") ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (atspair:string hot-rbt:string)
        @doc "Cost preview for C_AddHotRBT — pure re-derivation of its 3-leg concat: an \
            \ AddSecondary leg + a conditional hot-rbt RotateOwnership (only when the hot-rbt \
            \ is not already owned by ATS|SC_NAME) + the hot-rbt Control lock."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (hot-rbt-owner:string (ref-DPOF::UR_Konto hot-rbt))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (URCi_AddSecondary)
                    (if (!= hot-rbt-owner ATS|SC_NAME) (ref-DPOF::URCi_RotateOwnership hot-rbt) EOC)
                    (ref-DPOF::URCi_Control hot-rbt)
                ]
                []
            )
        )
    )
    (defun URCi_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (* (ref-IGNIS::UC_IgnisLeg "tier-biggest") 20.0) ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  ToggleParameterLock: full cumulator re-derived from unlocks (read PRE-increment — see C_).
    (defun URCi_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    (defun URCi_ToggleParameterLockStoa:decimal (atspair:string toggle:bool)
        @doc "STOA leg of a parameter-lock toggle: locking is free, unlocking costs the \
            \ fee-unlock price. Read-only twin of the <XI_ToggleParameterLock> return that \
            \ <C_ToggleParameterLock> hands to <STOA|C_Collect>, so the INFO_ preview and the \
            \ charge move as one. Mirrors DPTF's <URCi_ToggleFeeLockStoa>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
        )
    )
    ;;  Issue/UpgradeBranding: :decimal price rails (cumulator output / write side-effect stays in the C_/XI).
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): autostake pair issuance = $40 = 4000 ignis/pair (owner 2026-09-05). \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-ats-pair"))
               (ref-IGNIS::UC_IgnisComponents "ATS|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (autostake pair = $40 => 400 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-ats-pair"))
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_id (atspair:string)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_UniqueAtspair atspair)
            (with-default-read ATS|Pairs atspair
                { "unlocks" : -1 }
                { "unlocks" := u }
                (enforce
                    (>= u 0)
                    (format "ATS-Pair {} does not exist" [atspair])
                )
            )
        )
    )
    (defun UEV_CanUpgradeON (atspair:string)
        @doc "Gates ATS|S>CONTROL (C_Control: can-change-owner/syphoning/hibernate). \
            \ can-upgrade is settable via C_ToggleUpgrade (audit finding #21L / L3)."
        (let
            (
                (x:bool (UR_CanUpgrade atspair))
            )
            (enforce x (format "{} properties cannot be upgraded" [atspair]))
        )
    )
    (defun UEV_CanChangeOwnerON (atspair:string)
        (UEV_id atspair)
        (let
            (
                (x:bool (UR_CanChangeOwner atspair))
            )
            (enforce (= x true) (format "ATS Pair {} ownership cannot be changed" [atspair]))
        )
    )
    (defun UEV_RewardTokenExistance (atspair:string reward-token:string existance:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (existance-check:bool (ref-DPTF::URC_IzRTg atspair reward-token))
            )
            (enforce 
                (= existance-check existance) 
                (format "{} Existance isnt verified for Token {} as RT with ATS Pair {}" [existance reward-token atspair])
            )
        )
    )
    (defun UEV_RewardBearingTokenExistance (atspair:string reward-bearing-token:string existance:bool cold-or-hot:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (existance-check:bool
                    (if cold-or-hot
                        (ref-DPTF::URC_IzRBTg atspair reward-bearing-token)
                        (ref-DPOF::URC_IzRBTg atspair reward-bearing-token)
                    )
                )
            )
            (enforce (= existance-check existance) (format "{} Existance isnt verified for Token {} as RBT with ATS Pair {}" [existance reward-bearing-token atspair]))
        )
    )
    (defun UEV_ParameterLockState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_Lock atspair))
            )
            (enforce (= x state) (format "Parameter-lock for ATS Pair {} must be set to {} for this operation" [atspair state]))
        )
    )
    (defun UEV_EliteState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_EliteMode atspair))
            )
            (enforce (= x state) (format "Elite-Mode for ATS Pair {} must be set to {} for this operation" [atspair state]))
        )
    )
    (defun UEV_ColdRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleColdRecovery atspair))
            )
            (enforce (= x state) (format "Cold Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_HotRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleHotRecovery atspair))
            )
            (enforce (= x state) (format "Hot Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_DirectRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleDirectRecovery atspair))
            )
            (enforce (= x state) (format "Direct Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_IssueData (atspair:string index-decimals:integer reward-token:string reward-bearing-token:string)
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (rt-ftc:string (take 2 reward-token))
                (rbt-ftc:string (take 2 reward-bearing-token))
            )
            ;;0]Index name shape - relocated here from XI_Issue (StoicSyntax §7.20 step 1: an
            ;;  enforcement does not belong in an X_). Runs per element inside ATS|C>ISSUE, the
            ;;  single place it belongs. <atspair> was a DEAD parameter until now, and the caller
            ;;  no longer burns a UDC_Makeid per element to build a value nothing read.
            (ref-U|ATS::UEV_AutostakeIndex atspair)
            (ref-U|DALOS::UEV_Decimals index-decimals)
            ;;1]Token Ownership
            (ref-DPTF::CAP_Owner reward-token)
            (ref-DPTF::CAP_Owner reward-bearing-token)
            ;;2]Cannot register the Same Token as RT and RBT
            (enforce (!= reward-token reward-bearing-token) "RT must be different from RBT")
            ;;3]RTs and RBTs cannot be F|, R|, or LP Tokens (S|, W|, P|, - Tokens)
            (enforce
                (and
                    (not (contains rt-ftc ["F|" "R|" "S|" "W|" "P|"]))
                    (not (contains rbt-ftc ["F|" "R|" "S|" "W|" "P|"]))
                )
                "An Autostake Pool cannot be issued when either the RT or RBT are Special or LP Tokens"
            )
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces Atspair Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto id))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 1 — Innate protection offered by XI_Issue, XE_Issue,
    ;;Protection:          XE_UpdateRewardToken, XE_UpdateRewardBearingToken
    (defun XI_FoldedIssue:[string]
        (
            account:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[string] index:integer)
                    (let
                        (
                            (ats-id:string
                                (XI_Issue
                                    account
                                    (at index atspair)
                                    (at index index-decimals)
                                    (at index reward-token)
                                    (at index rt-nfr)
                                    (at index reward-bearing-token)
                                    (at index rbt-nfr)
                                )
                            )
                        )
                        (ref-BRD::XE_Issue ats-id)
                        (ref-DPTF::XE_UpdateRewardToken ats-id (at index reward-token) true)
                        (ref-DPTF::XE_UpdateRewardBearingToken ats-id (at index reward-bearing-token))
                        (ref-U|LST::UC_AppL acc ats-id)
                    )
                )
                []
                (enumerate 0 (- (length atspair) 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_Issue:string
        (
            account:string
            atspair:string
            index-decimals:integer
            reward-token:string
            rt-nfr:bool
            reward-bearing-token:string
            rbt-nfr:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ats-sc:string ATS|SC_NAME)
                (id:string (ref-U|DALOS::UDC_Makeid atspair))
            )
            (insert ATS|Pairs id
                {"id"                       : id
                ,"owner-konto"              : account
                ,"can-upgrade"              : true
                ,"can-change-owner"         : true
                ,"syphoning"                : false
                ,"hibernate"                : false
                ,"pair-index-name"          : atspair
                ,"index-decimals"           : index-decimals
                ,"royalty-promile"          : 0.0
                ,"syphon"                   : 1.0
                ;;
                ,"peak-hibernate-promile"   : 120.0
                ,"hibernate-decay"          : 0.008
                ;;
                ,"parameter-lock"           : false
                ,"unlocks"                  : 0
                ;;
                ,"reward-tokens"            : [(UDC_ComposePrimaryRewardToken reward-token rt-nfr)]
                ;;
                ;;Cold Recovery
                ,"c-rbt"                    : reward-bearing-token
                ,"c-nfr"                    : rbt-nfr
                ,"c-positions"              : -1
                ,"c-limits"                 : [0.0]
                ,"c-array"                  : [[0.0]]
                ,"c-fr"                     : true
                ,"c-duration"               : (ref-U|ATS::UCv_MakeSoftIntervals 300 6)
                ,"c-elite-mode"             : false
                ;;
                ;;Hot Recovery
                ,"h-rbt"                    : BAR
                ,"h-fr"                     : true
                ,"h-promile"                : 100.0
                ,"h-decay"                  : 1
                ;;
                ;;Direct Recovery
                ,"d-promile"                : 0.0
                ;;
                ;;Toggle Recoveries
                ,"cold-recovery"            : false
                ,"hot-recovery"             : false
                ,"direct-recovery"          : false                
                }
            )
            (ref-DPTF::C_DeployAccount reward-token account)
            (ref-DPTF::C_DeployAccount reward-bearing-token account)
            (ref-DPTF::C_DeployAccount reward-token ats-sc)
            (ref-DPTF::C_DeployAccount reward-bearing-token ats-sc)
            id
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>ROTATE_OWNERSHIP
    (defun XI_ChangeOwnership (atspair:string new-owner:string)
        (require-capability (ATS|S>ROTATE_OWNERSHIP atspair new-owner))
        (update ATS|Pairs atspair
            {"owner-konto" : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>CONTROL
    (defun XI_Control (atspair:string can-change-owner:bool syphoning:bool hibernate:bool)
        (require-capability (ATS|S>CONTROL atspair hibernate))
        (update ATS|Pairs atspair
            {"can-change-owner" : can-change-owner
            ,"syphoning"        : syphoning
            ,"hibernate"        : hibernate}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>ROYALTY
    (defun XI_UpdateRoyalty (atspair:string royalty:decimal)
        (require-capability (ATS|S>ROYALTY atspair royalty))
        (update ATS|Pairs atspair
            {"royalty-promile" : royalty}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SYPHON
    (defun XI_UpdateSyphon (atspair:string syphon:decimal)
        (require-capability (ATS|S>SYPHON atspair syphon))
        (update ATS|Pairs atspair
            {"syphon" : syphon}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SET-HIBERNATION-FEES
    (defun XI_SetHibernationFees (atspair:string peak:decimal decay:decimal)
        (require-capability (ATS|S>SET-HIBERNATION-FEES atspair peak decay))
        (update ATS|Pairs atspair
            {"peak-hibernate-promile"   : peak
            ,"hibernate-decay"          : decay}
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_ToggleParameterLock:[decimal] (atspair:string toggle:bool)
        (require-capability (SECURE))
        (update ATS|Pairs atspair
            { "parameter-lock" : toggle}
        )
        (if toggle
            [0.0 0.0]
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementParameterUnlocks (atspair:string)
        (require-capability (SECURE))
        (with-read ATS|Pairs atspair
            { "unlocks" := u }
            (update ATS|Pairs atspair
                {"unlocks" : (+ u 1)}
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>ADD-REWARD-TOKEN
    (defun XI_AddSecondary (atspair:string reward-token:string rt-nfr:bool)
        (require-capability (ATS|C>ADD-REWARD-TOKEN atspair reward-token))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    {"reward-tokens" : (ref-U|LST::UC_AppL rt (UDC_ComposePrimaryRewardToken reward-token rt-nfr))}
                )
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>CONTROL-COLD-FEES
    (defun XI_ControlColdFees (atspair:string c-nfr:bool c-fr:bool)
        (require-capability (ATS|C>CONTROL-COLD-FEES atspair))
        (update ATS|Pairs atspair
            {"c-nfr"    : c-nfr
            ,"c-fr"     : c-fr}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_COLD_FEES
    (defun XI_SetColdFee (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (require-capability (ATS|C>SET_COLD_FEES atspair fee-positions fee-thresholds fee-array))
        (update ATS|Pairs atspair
            {"c-positions"  : fee-positions
            ,"c-limits"     : fee-thresholds
            ,"c-array"      : fee-array}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_COLD-DURATION
    (defun XI_SetCRD (atspair:string soft-or-hard:bool base:integer growth:integer)
        (require-capability (ATS|C>SET_COLD-DURATION atspair soft-or-hard base growth))
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (if soft-or-hard
                (update ATS|Pairs atspair
                    { "c-duration" : (ref-U|ATS::UCv_MakeSoftIntervals base growth)}
                )
                (update ATS|Pairs atspair
                    { "c-duration" : (ref-U|ATS::UCv_MakeHardIntervals base growth)}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>TOGGLE_ELITE
    (defun XI_ToggleElite (atspair:string toggle:bool)
        (require-capability (ATS|C>TOGGLE_ELITE atspair toggle))
        (update ATS|Pairs atspair
            { "c-elite-mode" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>TOGGLE_UPGRADE
    (defun XI_ToggleUpgrade (atspair:string toggle:bool)
        (require-capability (ATS|C>TOGGLE_UPGRADE atspair toggle))
        (update ATS|Pairs atspair
            { "can-upgrade" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-COLD-RECOVERY
    (defun XI_SwitchColdRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-COLD-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "cold-recovery" : toggle}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>ADD-HOT-RBT
    (defun XI_AddHotRBT (atspair:string hot-rbt:string)
        (require-capability (ATS|C>ADD-HOT-RBT atspair hot-rbt))
        (update ATS|Pairs atspair
            {"h-rbt" : hot-rbt}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>CONTROL-HOT-FEE
    (defun XI_ControlHotFee (atspair:string h-fr:bool)
        (require-capability (ATS|C>CONTROL-HOT-FEE atspair))
        (update ATS|Pairs atspair
            {"h-fr"    : h-fr}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_HOT_FEES
    (defun XI_SetHotFees (atspair:string promile:decimal decay:integer)
        (require-capability (ATS|C>SET_HOT_FEES atspair promile decay))
        (update ATS|Pairs atspair
            {"h-promile"    : promile
            ,"h-decay"      : decay}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-HOT-RECOVERY
    (defun XI_SwitchHotRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-HOT-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "hot-recovery" : toggle}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>SET_DIRECT_FEE
    (defun XI_SetDirectFee (atspair:string promile:decimal)
        (require-capability (ATS|C>SET_DIRECT_FEE atspair promile))
        (update ATS|Pairs atspair
            {"d-promile"    : promile}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-DIRECT-RECOVERY
    (defun XI_SwitchDirectRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-DIRECT-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "direct-recovery" : toggle}
        )
    )
    ;;
    ;;
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RemoveSecondary (atspair:string reward-token:string)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    {"reward-tokens" :
                        (ref-U|LST::UC_RemoveItem  rt (at rtp rt))
                    }
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRUR (atspair:string reward-token:string rur:integer direction:bool amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
                (nfr:bool (at rtp (UR_RewardTokenNFR atspair)))
                (resident:decimal (at rtp (UR_RewardTokenRUR atspair 1)))
                (unbonding:decimal (at rtp (UR_RewardTokenRUR atspair 2)))
                (royalty:decimal (at rtp (UR_RewardTokenRUR atspair 3)))
                ;;
                (rur-amount:decimal
                    (cond
                        ((= rur 1) (if direction (+ resident amount) (- resident amount)))
                        ((= rur 2) (if direction (+ unbonding amount) (- unbonding amount)))
                        ((= rur 3) (if direction (+ royalty amount) (- royalty amount)))
                        0.0
                    )
                )
                (new-rt-obj:object{AutostakeV3.ATS|RewardTokenSchemaV2}
                    (cond
                        ((= rur 1) (UDC_RT reward-token nfr rur-amount unbonding royalty))
                        ((= rur 2) (UDC_RT reward-token nfr resident rur-amount royalty))
                        ((= rur 3) (UDC_RT reward-token nfr resident unbonding rur-amount))
                        (UDC_RT reward-token nfr 0.0 0.0 0.0)
                    )
                )
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    { "reward-tokens" : (ref-U|LST::UC_ReplaceItem rt (at rtp rt) new-rt-obj)}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_SpawnAutostakeAccount (atspair:string account:string)
        (P|UEV_IMC)
        (let
            (
                (zero:object{UtilityAtsV3.Awo} (UDC_MakeZeroUnstakeObject atspair))
                (n:object{UtilityAtsV3.Awo} (UDC_MakeNegativeUnstakeObject atspair))
            )
            (with-default-read ATS|Ledger (UC_AtspairAccount atspair account)
                (UDCx_Balance [zero] n n n n n n n atspair account)
                {"P0"       := p0
                ,"P1"       := p1
                ,"P2"       := p2
                ,"P3"       := p3
                ,"P4"       := p4
                ,"P5"       := p5
                ,"P6"       := p6
                ,"P7"       := p7
                ,"id"       := i
                ,"account"  := a}
                (write ATS|Ledger (UC_AtspairAccount atspair account)
                    (UDCx_Balance p0 p1 p2 p3 p4 p5 p6 p7 i a)
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ReshapeUnstakeAccount (atspair:string account:string rp:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (with-read ATS|Ledger (UC_AtspairAccount atspair account)
                {"P0" := p0, "P1" := p1, "P2" := p2, "P3" := p3, "P4" := p4, "P5" := p5, "P6" := p6, "P7" := p7, "id" := id, "account" := acc}
                (update ATS|Ledger (UC_AtspairAccount atspair account)
                    (UDCx_Balance
                        (ref-U|ATS::UC_MultiReshapeUnstakeObject p0 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p1 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p2 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p3 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p4 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p5 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p6 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p7 rp)
                        id
                        acc
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP0 (atspair:string account:string obj:[object{UtilityAtsV3.Awo}])
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P0" : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP1 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P1"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP2 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P2"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP3 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P3"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP4 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P4"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP5 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P5"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP6 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P6"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP7 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P7"  : obj}
        )
    )
    ;;{5.7}  User [A/C]
    (defun AU_UnstakeAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_UnstakeAccount) keyz)
        )
    )
    (defun AU_UnstakeAccount (ky:string)
        (require-capability (SECURE))
        (update ATS|Ledger ky
            {"id"       : (drop -163 ky)
            ,"account"  : (take -162 ky)}
        )
    )
    (defun AU_AutostakePairs (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_AutostakePair) ids)
        )
    )
    (defun AU_AutostakePair (id:string)
        (require-capability (SECURE))
        (update ATS|Pairs id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (ATS|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (owner:string (UR_OwnerKonto entity-id))
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (ATS|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id owner months)
            )
            (ref-IGNIS::STOA|C_CollectWT patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;Hot RBT Management
    (defun HOT-RBT|C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
            )
            (with-capability (ATS|C>HOT-RBT-UPDATE-BRD entity-id)
                (ref-B|DPOF::C_UpdatePendingBranding entity-id logo description website social)
            )
        )
    )
    (defun HOT-RBT|C_UpgradeBranding (patron:string entity-id:string months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
            )
            (with-capability (ATS|C>HOT-RBT-UPGRADE-BRD entity-id)
                (ref-B|DPOF::C_UpgradeBranding patron entity-id months)
            )
        )
    )
    (defun HOT-RBT|C_Repurpose:object{IgnisCollectorV3.OutputCumulator}
        (hot-rbt:string nonce:integer repurpose-to:string)
        @doc "Fix (audit finding #22L test-coverage sweep): UR_NonceMetaData was called \
            \ with zero arguments where it requires (id nonce) - an unconditional crash, \
            \ never caught because this function had zero test coverage before now. \
            \ Fetches the ORIGINAL nonce's own metadata, so the replacement mint carries \
            \ forward the same mint-time (and any other metadata-derived math stays \
            \ correct) rather than fabricating fresh metadata for a seized position."
        (P|UEV_IMC)
        (with-capability (ATS|C>REPURPOSE-HOT-RBT hot-rbt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (nonce-holder:string (ref-DPOF::UR_NonceHolder hot-rbt nonce))
                    (nonce-supply:decimal (ref-DPOF::UR_NonceSupply hot-rbt nonce))
                    (nonce-meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData hot-rbt nonce))
                    (nonces-used:integer (ref-DPOF::UR_NoncesUsed hot-rbt))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [
                        ;;1]Freeze <nonce> owner
                        (ref-DPOF::C_ToggleFreezeAccount hot-rbt nonce-holder true)
                        ;;2]Wipe <nonce> on owner
                        (ref-DPOF::C_WipeClean hot-rbt nonce-holder [nonce])
                        ;;3]Unfreeze <nonce> owner
                        (ref-DPOF::C_ToggleFreezeAccount hot-rbt nonce-holder false)
                        ;;4]Mint new DPOF on ATS|SC_NAME
                        (ref-DPOF::C_Mint hot-rbt ATS|SC_NAME nonce-supply nonce-meta-data-chain)
                        ;;5]Transfer it to <repurpose-to>
                        (ref-DPOF::C_Transfer hot-rbt [(+ nonces-used 1)] ATS|SC_NAME repurpose-to true)
                    ] 
                    []
                )
            )
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            account:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
        (P|UEV_IMC)
        (with-capability (ATS|C>ISSUE account atspair index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (l1:integer (length atspair))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (stoa-costs:decimal (URCi_IssueStoa l1))
                    (ats-ids:[string]
                        (XI_FoldedIssue account atspair index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
                    )
                )
                (ref-IGNIS::STOA|C_Collect patron stoa-costs)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs ATS|SC_NAME trigger ats-ids)
                
            )
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string new-owner:string)
        (P|UEV_IMC)
        (with-capability (ATS|S>ROTATE_OWNERSHIP atspair new-owner)
            (XI_ChangeOwnership atspair new-owner)
            (URCi_RotateOwnership atspair)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string can-change-owner:bool syphoning:bool hibernate:bool)
        (P|UEV_IMC)
        (with-capability (ATS|S>CONTROL atspair hibernate)
            (XI_Control atspair can-change-owner syphoning hibernate)
            (URCi_Control atspair)
        )
    )
    (defun C_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string royalty:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|S>ROYALTY atspair royalty)
            (XI_UpdateRoyalty atspair royalty)
            (URCi_UpdateRoyalty atspair)
        )
    )
    (defun C_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string syphon:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|S>SYPHON atspair syphon)
            (XI_UpdateSyphon atspair syphon)
            (URCi_UpdateSyphon atspair)
        )
    )
    ;;
    (defun C_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string peak:decimal decay:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|S>SET-HIBERNATION-FEES atspair peak decay)
            (XI_SetHibernationFees atspair peak decay)
            (URCi_SetHibernationFees atspair)
        )
    )
    ;;
    (defun C_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (ATS|C>TOGGLE-PARAMETER-LOCK atspair toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleParameterLock atspair toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads unlocks BEFORE XI_IncrementParameterUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleParameterLock atspair toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XI_IncrementParameterUnlocks atspair)
                        (ref-IGNIS::STOA|C_Collect patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    (defun C_AddSecondary:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string reward-token:string rt-nfr:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_AddSecondary" "ats-secondary"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (ATS|C>ADD-REWARD-TOKEN atspair reward-token)
                (ref-DPTF::XB_DeployAccountWNE ATS|SC_NAME reward-token)
                (ref-DPTF::XE_UpdateRewardToken atspair reward-token true)
                (XI_AddSecondary atspair reward-token rt-nfr)
                (URCi_AddSecondary)
            )
        )
    )
    ;;Cold Recovery Management
    (defun C_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} 
        (atspair:string c-nfr:bool c-fr:bool)
        (P|UEV_IMC)
        (with-capability (ATS|C>CONTROL-COLD-FEES atspair)
            (XI_ControlColdFees atspair c-nfr c-fr)
            (URCi_ControlColdRecoveryFees atspair)
        )
    )
    (defun C_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (gas-costs:decimal (* (ref-IGNIS::UC_IgnisLeg "tier-biggest") 20.0))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (ATS|C>SET_COLD_FEES atspair fee-positions fee-thresholds fee-array)
                (XI_SetColdFee atspair fee-positions fee-thresholds fee-array)
                (URCi_SetColdRecoveryFees)
            )
        )
    )
    (defun C_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string soft-or-hard:bool base:integer growth:integer)
        (P|UEV_IMC)
        (with-capability (ATS|C>SET_COLD-DURATION atspair soft-or-hard base growth)
            (XI_SetCRD atspair soft-or-hard base growth)
            (URCi_SetColdRecoveryDuration atspair)
        )
    )
    (defun C_ToggleElite:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (ATS|C>TOGGLE_ELITE atspair toggle)
            (XI_ToggleElite atspair toggle)
            (URCi_ToggleElite atspair)
        )
    )
    (defun C_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string toggle:bool)
        @doc "Fix (audit finding #21L / L3): sets can-upgrade, which was previously \
            \ permanently true with no setter. Gates C_Control (can-change-owner/ \
            \ syphoning/hibernate) - false blocks C_Control entirely until true again."
        (P|UEV_IMC)
        (with-capability (ATS|C>TOGGLE_UPGRADE atspair toggle)
            (XI_ToggleUpgrade atspair toggle)
            (URCi_ToggleUpgrade atspair)
        )
    )
    (defun C_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (ATS|S>SWITCH-COLD-RECOVERY atspair toggle)
            (XI_SwitchColdRecovery atspair toggle)
            (URCi_SwitchColdRecovery atspair)
        )
    )
    ;;Hot Recovery Management
    ;;Must be modified to either add a 0 supply Orto Fungible or Issue One
    (defun C_AddHotRBT:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string hot-rbt:string)
        (P|UEV_IMC)
        (with-capability (ATS|C>ADD-HOT-RBT atspair hot-rbt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_AddHotRBT" "ats-secondary"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (hot-rbt-owner:string (ref-DPOF::UR_Konto hot-rbt))
                    ;;
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (URCi_AddSecondary)
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        ;;Change Ownership to ATS|SC_NAME if it is not
                        (if (!= hot-rbt-owner ATS|SC_NAME)
                            (ref-DPOF::C_RotateOwnership hot-rbt ATS|SC_NAME)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        ;;Lock Properties   <cu>    <cco>   <casr>  <ctocr> <cf>    <cw>    <cp>    <sg> to
                        ;;                  <false> <false> <false> <false> <true>  <true>  <false> <false>
                        (ref-DPOF::C_Control hot-rbt false false false false true true false false)
                    )
                )
                (ref-DPOF::XB_DeployAccountWNE ATS|SC_NAME hot-rbt)
                (ref-DPOF::XE_UpdateRewardBearingToken atspair hot-rbt)
                (XI_AddHotRBT atspair hot-rbt)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2] [])  
            ) 
        )
    )
    (defun C_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} 
        (atspair:string h-fr:bool)
        (P|UEV_IMC)
        (with-capability (ATS|C>CONTROL-HOT-FEE atspair)
            (XI_ControlHotFee atspair h-fr)
            (URCi_ControlHotRecoveryFee atspair)
        )
    )
    (defun C_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string promile:decimal decay:integer)
        (P|UEV_IMC)
        (with-capability (ATS|C>SET_HOT_FEES atspair promile decay)
            (XI_SetHotFees atspair promile decay)
            (URCi_SetHotRecoveryFees atspair)
        )
    )
    (defun C_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (ATS|S>SWITCH-HOT-RECOVERY atspair toggle)
            (XI_SwitchHotRecovery atspair toggle)
            (URCi_SwitchHotRecovery atspair)
        )
    )
    ;;Direct Recovery Management
    (defun C_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string promile:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|C>SET_DIRECT_FEE atspair promile)
            (XI_SetDirectFee atspair promile)
            (URCi_SetDirectRecoveryFee atspair)
        )
    )
    (defun C_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator}
        (atspair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (ATS|S>SWITCH-DIRECT-RECOVERY atspair toggle)
            (XI_SwitchDirectRecovery atspair toggle)
            (URCi_SwitchDirectRecovery atspair)
        )
    )

)

;; --- tables for 08_ATS.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table ATS|Pairs)
;; (create-table ATS|Ledger)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TrueFungibleTransferV2
    @doc "Exposes True Fungible Transfer Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    ;;  SCHEMAS
    ;;
    (defschema TransferClass
        type:integer
        iz-it-simple:bool
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_GetDispoData:object{UtilityDptfV2.DispoData} (account:string))
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_ContainsEliteAurynz:bool (id-lst:[string]))
    (defun UC_BulkRemainders:[decimal] (id:string transfer-amount-lst:[decimal]))
    (defun UC_BulkFees:[decimal] (id:string transfer-amount-lst:[decimal]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_MinimumOuro:decimal (account:string))
    (defun URC_VirtualOuro:decimal (account:string))
    (defun URC_ReceiverAmount:decimal (id:string sender:string receiver:string amount:decimal))
    (defun URC_UnityTransferIgnisPrice (transfer-amount:decimal))
        ;;
    (defun URC_TransferClasses:object{TransferClass} (id:string sender:string receiver:string amount:decimal))
    (defun URC_IzSimpleTransfer:bool (id:string sender:string receiver:string amount:decimal))
    (defun URC_TransferClassesForBulk:object{TransferClass} (id:string sender:string transfer-amount-lst:[decimal]))
    (defun URC_IzSimpleTransferForBulk:bool (id:string sender:string transfer-amount-lst:[decimal]))
        ;;
    (defun URC_IzTrueFungibleEliteAuryn:bool (id:string))
    (defun URC_IzTrueFungibleUnity:bool (id:string))
    (defun URC_AreTrueFungiblesEliteAurynz:bool (id:string))
    (defun URCi_SmallTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_LargeTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_Transmute:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_ClearDispo:object{IgnisCollectorV3.OutputCumulator} (account:string))
    (defun URCi_UnityTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver:string amount:decimal))
        ;;
    (defun URCi_TransferCumulator:object{IgnisCollectorV3.OutputCumulator} (type:integer id:string sender:string receiver:string))
    (defun URCi_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string transfer-amount:decimal))
    (defun URCi_SmallTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string))
    (defun URCi_MediumTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string))
    (defun URCi_LargeTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver:string))
        ;;
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal]))
        ;;
    (defun URCi_MultiBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun URCi_UnityBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun URCi_SimpleBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    (defun URCi_ComplexBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    (defun URCi_EliteBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_MinimumMapperForBulk (id:string transfer-amount-lst:[decimal]))
    (defun UEV_Minimum (id:string amount:decimal))
    (defun UEV_DispoLocker (id:string account:string))
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_ClearDispo:object{IgnisCollectorV3.OutputCumulator} (account:string))
    (defun C_Transmute:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string transmute-amount:decimal))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string transfer-amount:decimal method:bool))
    (defun C_MultiTransfer:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool))
    (defun C_MultiBulkTransfer:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))

)
;;
(module TFT GOV
    @doc "TFT — the True-Fungible transfer core, the movement layer over DPTF, implementing \
        \ TrueFungibleTransferV2. It computes transfer classes, fees and remainders \
        \ (including Elite-Auryn detection) and exposes client ops C_Transfer, \
        \ C_MultiTransfer, C_MultiBulkTransfer, C_Transmute (mint/burn conversion) and \
        \ C_ClearDispo, handling fee-bearing transfers and multi-token batched sends."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TrueFungibleTransferV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TFT                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TFT_ADMIN)))
    (defcap GOV|TFT_ADMIN ()                            (enforce-guard GOV|MD_TFT))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|TFT|CALLER ()
        true
    )
    (defcap P|ATS|REMOTE-GOV ()
        @doc "Autostake Remote Governor Capability"
        true
    )
    (defcap P|DALOS|REMOTE-GOV ()
        @doc "Dalos Remote Governor Capability"
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|TFT|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|TFT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TFT_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (mg:guard (create-capability-guard (P|TFT|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "TFT|RemoteDalosGov"
                (create-capability-guard (P|DALOS|REMOTE-GOV))
            )
            (ref-P|ATS::P|A_Add
                "TFT|RemoteAtsGov"
                (create-capability-guard (P|ATS|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst TF                                        (at 0 ["True-Fungible"]))
    (defconst DALOS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
    (defconst OUROBOROS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|OUROBOROS|SC_NAME)
        )
    )
    (defconst VST|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|VST|SC_NAME)
        )
    )
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;1]    Clear Dispo
    (defcap DPTF|C>CLEAR-DISPO (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-amount:decimal (ref-DALOS::UR_TF_AccountSupply account true))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (account-type:bool (ref-DALOS::UR_AccountType account))
            )
            (enforce (< ouro-amount 0.0) "Dispo Clear requires Negative OURO")
            (enforce (not account-type) "Standard Dispo can only be cleared on Standard Ouronet Accounts")
            (compose-capability (P|DALOS|REMOTE-GOV))
            (compose-capability (P|ATS|REMOTE-GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;2]    Transmute
    (defcap DPTF|C>TRANSMUTE (id:string transmuter:string amount:decimal)
        @event
        (compose-capability (DPTF|C>X-TRANSMUTE id transmuter amount))
    )
    (defcap DPTF|C>ELITE-TRANSMUTE (id:string transmuter:string amount:decimal)
        @event
        (UEV_DispoLocker id transmuter)
        (compose-capability (DPTF|C>X-TRANSMUTE id transmuter amount))
    )
    (defcap DPTF|C>X-TRANSMUTE (id:string transmuter:string amount:decimal) 
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]Ownership (included in the <XB_DebitTrueFungible>)
            ;;2]Transferability (not needed for transmute)
            ;;3];;3]<id> Pause State and <sender> Frozen State
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id transmuter false)
            ;;4]Only Standard Ouronet Account can transmute, 
            ;;Amount is not subject to <min-move> amount, and transfer-role restrictions
            (ref-DALOS::UEV_EnforceAccountType transmuter false)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;3]    TRANSFER
    (defcap DPTF|C>CLASS-1-TRANSFER 
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-1-TRANSFER-UNITY
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_Minimum id transfer-amount)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER-UNITY
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_Minimum id transfer-amount)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER-ELITE
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_DispoLocker id sender)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-3-TRANSFER-ELITE
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move:decimal (ref-DPTF::UR_MinMove id))
            )
            (if (!= min-move 0.0)
                (UEV_Minimum id transfer-amount)
                true
            )
            (UEV_DispoLocker id sender)
            (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
        )
    )
    ;;
    (defcap DPTF|C>X-TRANSFER
        (id:string sender:string receiver:string method:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]Ownership
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;2]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;3]<id> Pause State and <sender> <receiver> Frozen State
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id sender false)
            (ref-DPTF::UEV_AccountFreezeState id receiver false)
            ;;4]Transfer Roles Check
            (UEV_MoveRoleCheck id sender receiver)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;4]    MULTI-TRANSFER
    (defcap DPTF|C>MULTI-TRANSFER
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (l1:integer (length id-lst))
                (l2:integer (length transfer-amount-lst))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (has-ea:bool (contains ea-id id-lst))
            )
            ;;A]SINGLE VALIDATIONS
            ;;0]General
            (ref-U|LST::UEV_IzUnique id-lst)
            (enforce (= l1 l2) "Invalid Multi Transfer Lists")
            ;;1]Dispo Locker if EA is involved
            (if has-ea
                (UEV_DispoLocker ea-id sender)
                true
            )
            ;;2]Ownership (sender ownership within the DPTF Debit Function)
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;3]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;B]MULTI VALIDATIONS (mapper)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (id:string (at idx id-lst))
                        )
                        ;;4]<id> Pause State and <sender> <receiver> Frozen State
                        (ref-DPTF::UEV_PauseState id false)
                        (ref-DPTF::UEV_AccountFreezeState id sender false)
                        (ref-DPTF::UEV_AccountFreezeState id receiver false)
                        ;;5]Transfer Role Checker
                        (UEV_MoveRoleCheck id sender receiver)
                    )
                )
                (enumerate 0 (- l2 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;5]    BULK-TRANSFER
    (defcap DPTF|C>CLASS-0-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal] iz-it-simple:bool)
        @event
        (if (not iz-it-simple)
            (UEV_MinimumMapperForBulk id transfer-amount-lst)
            true
        )
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-0-BULK-UNITY (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal] iz-it-simple:bool)
        @event
        (if (not iz-it-simple)
            (UEV_MinimumMapperForBulk id transfer-amount-lst)
            true
        )
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-1-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-2-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (UEV_MinimumMapperForBulk id transfer-amount-lst)
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-2-BULK-ELITE (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (UEV_DispoLocker id sender)
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-3-BULK-ELITE (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move:decimal (ref-DPTF::UR_MinMove id))
            )
            (if (!= min-move 0.0)
                (UEV_MinimumMapperForBulk id transfer-amount-lst)
                true
            )
            (UEV_DispoLocker id sender)
            (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
        )
    )
    ;;
    (defcap DPTF|C>X-BULK-TRANSFER
        (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (l1:integer (length receiver-lst))
                (l2:integer (length transfer-amount-lst))
            )
            ;;A]SINGLE VALIDATIONS
            ;;0]General
            (ref-U|LST::UEV_IzUnique receiver-lst)
            (enforce (= l1 l2) "Invalid Bulk Transfer Lists")
            ;;1]<id> Pause State and <sender> Frozen State
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id sender false)
            ;;B]MULTI VALIDATIONS (mapper)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (receiver:string (at idx receiver-lst))
                        )
                        ;;1]<receiver> Frozen State
                        (ref-DPTF::UEV_AccountFreezeState id receiver false)
                        ;;2]Transfer Role Checker
                        (UEV_MoveRoleCheck id sender receiver)
                        ;;3]All Receivers must be Standard Ouronet Accounts
                        (ref-DALOS::UEV_EnforceAccountType receiver false)
                    )
                )
                (enumerate 0 (- l2 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    (defun UDC_GetDispoData:object{UtilityDptfV2.DispoData} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
            )
            {"elite-auryn-amount"   : (ref-DPTF::UR_AccountSupply ea-id account)
            ,"auryndex-value"       : (ref-ATS::URC_Index auryndex)
            ,"elite-auryndex-value" : (ref-ATS::URC_Index elite-auryndex)
            ,"major-tier"           : (ref-DALOS::UR_Elite-Tier-Major account)
            ,"minor-tier"           : (ref-DALOS::UR_Elite-Tier-Minor account)
            ,"ouroboros-precision"  : (ref-DPTF::UR_Decimals ouro-id)}
        )
    )
    (defun UDCx_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer price:decimal)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l-dec:decimal (dec size))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (* l-dec price) sender
                (ref-IGNIS::URC_ZeroGAS id sender ) []
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_ContainsEliteAurynz:bool (id-lst:[string])
        (fold
            (lambda
                (acc:bool idx:integer)
                (or acc (URC_AreTrueFungiblesEliteAurynz (at idx id-lst)))
            )
            false
            (enumerate 0 (- (length id-lst) 1))
        )
    )
    (defun UC_BulkRemainders:[decimal] (id:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL acc (at 2 (ref-DPTF::URC_Fee id (at idx transfer-amount-lst))))
                )
                []
                (enumerate 0 (- (length transfer-amount-lst) 1))
            )
        )
    )
    (defun UC_BulkFees:[decimal] (id:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (zip (+) acc (ref-DPTF::URC_Fee id (at idx transfer-amount-lst)))
                )
                [0.0 0.0 0.0]
                (enumerate 0 (- (length transfer-amount-lst) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_MinimumOuro:decimal (account:string)
        @doc "Computes the minimum Negative Ouroboros amount an Account is able to overconsume \
        \ Using the Standard Dispo mechanics"
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData account))
                (max-dispo:decimal (ref-U|DPTF::UC_OuroDispo dispo-data))
                (account-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if account-type
                0.0
                (- 0.0 max-dispo)
            )
        )
    )
    (defun URC_VirtualOuro:decimal (account:string)
        @doc "Computes the Account Virtual Ouro. \
            \ The Virtual Ouro is the maximum Ouro the Account is able to spend"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                (smart-treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (zero:decimal 
                    (if (= account smart-treasury)
                        (ref-DPTF::URC_TreasuryLowestDispo)
                        (URC_MinimumOuro account)
                    )
                ) 
            )
            (+ (abs zero) ouro)
        )
    )
    ;;
    (defun URC_ReceiverAmount:decimal (id:string sender:string receiver:string amount:decimal)
        @doc "Computes the amount the <receiver> gets when transfering DPTFs"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (tc:integer (at "type" (URC_TransferClasses id sender receiver amount)))
            )
            (if (contains tc [1 2 5])
                amount
                (at 2 (ref-DPTF::URC_Fee id amount))
            )
        )
    )
    (defun URC_UnityTransferIgnisPrice (transfer-amount:decimal)
        @doc "UNITY will only be used with Complex Transfers, as it will have a VTT"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if (<= transfer-amount 10.0) (ref-IGNIS::UC_IgnisLeg "tier-small") 0.0)
        )
    )
    (defun URC_TransferClasses:object{TrueFungibleTransferV2.TransferClass}
        (id:string sender:string receiver:string amount:decimal)
        @doc "Computes the Transfer Class \
        \ Class 1   : [DPTF|C>CLASS-1-TRANSFER]         [1]     Simple (T)\
        \           : [DPTF|C>CLASS-1-TRANSFER-UNITY]   [2]     Free Unity (T) \
        \ Class 2   : [DPTF|C>CLASS-2-TRANSFER]         [3]     Complex (T + F) \
        \           : [DPTF|C>CLASS-2-TRANSFER-UNITY]   [4]     Unity (T + F) \
        \           : [DPTF|C>CLASS-2-TRANSFER-ELITE]   [5]     Free Elite (T + U) \
        \ Class 3   : [DPTF|C>CLASS-3-TRANSFER-ELITE]   [6]     Elite (T + F + U)"
        (let
            (
                (iz-simple-transfer:bool (URC_IzSimpleTransfer id sender receiver amount))
                (are-e:bool (URC_AreTrueFungiblesEliteAurynz id))
                (iz-un:bool (URC_IzTrueFungibleUnity id))
                (output-type:integer
                    (if iz-simple-transfer
                        (if are-e 5 (if iz-un 2 1))
                        (if are-e 6 (if iz-un 4 3))
                    )
                )
            )
            {"type"         : output-type
            ,"iz-it-simple" : iz-simple-transfer}
        )
    )
    (defun URC_IzSimpleTransfer:bool (id:string sender:string receiver:string amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fee-toggle:bool (ref-DPTF::UR_FeeToggle id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (fee-unlocks:integer (ref-DPTF::UR_FeeUnlocks id))
            )
            (cond
                ((not fee-toggle) true)
                ((and (= fee-promile 0.0) (= fee-unlocks 0)) true)
                ((and (= fee-promile -1.0) (< amount 10.0)) true)
                ((ref-DPTF::UR_AccountRoleFeeExemption id sender) true)
                ((ref-DPTF::UR_AccountRoleFeeExemption id receiver) true)
                false
            )
        )
    )
    (defun URC_TransferClassesForBulk:object{TrueFungibleTransferV2.TransferClass}
        (id:string sender:string transfer-amount-lst:[decimal])
        @doc "Computes the Bulk Transfer Class, assuming Elite Auryns will never have VTT \
        \ Class 0   : VTT (Volumetric Transfer Tax) Class \
        \           : [DPTF|C>CLASS-0-BULK]             [1]     (T + vF) Variable Fee \
        \           : [DPTF|C>CLASS-0-BULK-UNITY]       [2]     (T + vF) Variable Fee Unity \
        \ Class 1   : [DPTF|C>CLASS-1-BULK]             [3]     (T) No Fee \
        \ Class 2   : [DPTF|C>CLASS-2-BULK]             [4]     (T + F) With Fee \
        \           : [DPTF|C>CLASS-2-BULK-ELITE]       [5]     (T + U) No Fee + Update Elite \
        \ Class 3   : [DPTF|C>CLASS-3-BULK-ELITE]       [6]     (T + F + U) With Fee + Update"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (iz-simple-transfer-for-bulk:bool 
                    (URC_IzSimpleTransferForBulk id sender transfer-amount-lst)
                )
                (are-e:bool (URC_AreTrueFungiblesEliteAurynz id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (iz-un:bool (URC_IzTrueFungibleUnity id))
                (not-vtt:bool (not (= -1.0 fee-promile)))
                (vtt-type:integer (if iz-un 2 1))
                ;;
                (output-type:integer
                    (if iz-simple-transfer-for-bulk
                        (if are-e 5 (if not-vtt 3 vtt-type))
                        (if are-e 6 (if not-vtt 4 vtt-type))
                    )
                )
            )
            {"type"         : output-type
            ,"iz-it-simple" : iz-simple-transfer-for-bulk}
        )
    )
    (defun URC_IzSimpleTransferForBulk:bool (id:string sender:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fee-toggle:bool (ref-DPTF::UR_FeeToggle id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (fee-unlocks:integer (ref-DPTF::UR_FeeUnlocks id))
            )
            (or 
                (cond
                    ((not fee-toggle) true)
                    ((and (= fee-promile 0.0) (= fee-unlocks 0)) true)
                    ((ref-DPTF::UR_AccountRoleFeeExemption id sender) true)
                    false
                ) 
                (fold
                    (lambda
                        (acc:[bool] amount:decimal)
                        (or acc
                            (and (= fee-promile -1.0) (< amount 10.0))
                        )
                    )
                    false
                    transfer-amount-lst
                )
            )
        )
    )
    ;;
    (defun URC_IzTrueFungibleEliteAuryn:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (= id ea-id) true false)
        )
    )
    (defun URC_IzTrueFungibleUnity:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (u-id:string (ref-DALOS::UR_UnityID))
            )
            (if (= id u-id) true false)
        )
    )
    (defun URC_AreTrueFungiblesEliteAurynz:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
            )
            (contains id [ea-id fea rea])
        )
    )
    ;;
    (defun URCx_CPF_RT-RBT:[decimal] (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (rt-ats-pairs:[string] (ref-DPTF::UR_RewardToken id))
                (rbt-ats-pairs:[string] (ref-DPTF::UR_RewardBearingToken id))
                (length-rt:integer (length rt-ats-pairs))
                (length-rbt:integer (length rbt-ats-pairs))
                (rt-boolean:[bool] (URCx_NFR-Boolean_RT-RBT id rt-ats-pairs true))
                (rbt-boolean:[bool] (URCx_NFR-Boolean_RT-RBT id rbt-ats-pairs false))
                (rt-milestones:integer (length (ref-U|LST::UC_Search rt-boolean true)))
                (rbt-milestones:integer (length (ref-U|LST::UC_Search rbt-boolean true)))
                (milestones:integer (+ rt-milestones rbt-milestones))
            )
            (if (!= milestones 0)
                (let
                    (
                        (truths:[bool] (+ rt-boolean rbt-boolean))
                        (split-with-truths:[decimal] (URCx_BooleanDecimalCombiner id native-fee-amount milestones truths))
                    )
                    (if (!= rt-milestones 0)
                        (let
                            (
                                (credit-sum:decimal
                                    (fold
                                        (lambda
                                            (acc:decimal index:integer)
                                            (if (at index rt-boolean)
                                                (do
                                                    (ref-ATS::XE_UpdateRUR (at index rt-ats-pairs) id 1 true (at index split-with-truths))
                                                    (+ acc (at index split-with-truths))
                                                )
                                                acc
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- (length rt-ats-pairs) 1))
                                    )
                                )
                            )
                            (if (= credit-sum 0.0)
                                [0.0 0.0 native-fee-amount]
                                [0.0 credit-sum (- native-fee-amount credit-sum)]
                            )
                        )
                        [0.0 0.0 native-fee-amount]
                    )
                )
                [native-fee-amount 0.0 0.0]
            )
        )
    )
    (defun URCx_CPF_RBT:decimal (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ats-pairs:[string] (ref-DPTF::UR_RewardBearingToken id))
                (ats-pairs-bool:[bool] (URCx_NFR-Boolean_RT-RBT id ats-pairs false))
                (milestones:integer (length (ref-U|LST::UC_Search ats-pairs-bool true)))
            )
            (if (!= milestones 0)
                0.0
                native-fee-amount
            )
        )
    )
    (defun URCx_CPF_RT:decimal (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ats-pairs:[string] (ref-DPTF::UR_RewardToken id))
                (ats-pairs-bool:[bool] (URCx_NFR-Boolean_RT-RBT id ats-pairs true))
                (milestones:integer (length (ref-U|LST::UC_Search ats-pairs-bool true)))
            )
            (if (!= milestones 0)
                (let
                    (
                        (rt-split-with-boolean:[decimal] (URCx_BooleanDecimalCombiner id native-fee-amount milestones ats-pairs-bool))
                        (number-of-zeroes:integer (length (ref-U|LST::UC_Search rt-split-with-boolean 0.0)))
                    )
                    (map
                        (lambda
                            (index:integer)
                            (if (at index ats-pairs-bool)
                                (ref-ATS::XE_UpdateRUR (at index ats-pairs) id 1 true (at index rt-split-with-boolean))
                                true
                            )
                        )
                        (enumerate 0 (- (length ats-pairs) 1))
                    )
                    0.0
                )
                native-fee-amount
            )
        )
    )
    (defun URCx_NFR-Boolean_RT-RBT:[bool] (id:string ats-pairs:[string] rt-or-rbt:bool)
        @doc "Makes a [bool] using RT or RBT <nfr> values from a list of ATS Pair"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (fold
                (lambda
                    (acc:[bool] index:integer)
                    (if rt-or-rbt
                        (if (ref-ATS::UR_SingleRewardTokenNFR (at index ats-pairs) id)
                            (ref-U|LST::UC_AppL acc true)
                            (ref-U|LST::UC_AppL acc false)
                        )
                        (if (ref-ATS::UR_ColdNativeFeeRedirection (at index ats-pairs))
                            (ref-U|LST::UC_AppL acc true)
                            (ref-U|LST::UC_AppL acc false)
                        )
                    )
                )
                []
                (enumerate 0 (- (length ats-pairs) 1))
            )
        )
    )
    (defun URCx_BooleanDecimalCombiner:[decimal] (id:string amount:decimal milestones:integer boolean:[bool])
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (prec:integer (ref-DPTF::UR_Decimals id))
            )
            (ref-U|ATS::UCv_SplitBalanceWithBooleans prec amount milestones boolean)
        )
    )
    ;;
    (defun URCi_SmallTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-small") transmuter
                (ref-IGNIS::URC_IsVirtualGasZeroAbsolutely id) []
            )
        )
    )
    (defun URCi_LargeTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-medium") transmuter
                (ref-IGNIS::URC_IsVirtualGasZeroAbsolutely id) []
            )
        )
    )
    (defun URCi_Transmute:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        @doc "Cost single-source for C_Transmute — the same class choice C_Transmute makes: \
            \ Elite-Auryn transmute bills the Large (ignis|medium) rail, else the Small \
            \ (ignis|small) rail. Consumed by INFO (C_Transmute already returns this cumulator)."
        (if (URC_IzTrueFungibleEliteAuryn id)
            (URCi_LargeTransmuteCumulator id transmuter)
            (URCi_SmallTransmuteCumulator id transmuter)
        )
    )
    (defun URCi_ClearDispo:object{IgnisCollectorV3.OutputCumulator}
        (account:string)
        @doc "Cost single-source for C_ClearDispo — pure re-derivation of the 5-leg concat: \
            \ (conditional EA freeze) + EA WipeSlim + (conditional EA unfreeze) + Auryn burn + \
            \ Ouroboros burn. Freeze legs are EOC when the EA account is already frozen."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ea-id account))
                (toggle-leg:object{IgnisCollectorV3.OutputCumulator}
                    (if (not frozen-state) (ref-DPTF::URCi_ToggleFreezeAccount ea-id) EOC)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    toggle-leg
                    (ref-DPTF::URCi_WipeSlim ea-id)
                    toggle-leg
                    (ref-DPTF::URCi_Burn a-id ats-sc)
                    (ref-DPTF::URCi_Burn ouro-id ats-sc)
                ]
                []
            )
        )
    )
    ;;
    (defun URCi_UnityTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver:string amount:decimal)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (price:decimal
                    (if (< amount 10.0)
                        (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                        0.0
                    )
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                price sender
                (ref-IGNIS::URC_ZeroEliteGAZ sender receiver) []
            )
        )
    )
    ;;
    (defun URCi_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string transfer-amount:decimal)
        @doc "Pure cost of a single C_Transfer, keyed on the SAME inputs C_Transfer takes: \
            \ compute the transfer class then dispatch via URCi_TransferCumulator. Lets \
            \ composers (e.g. ATSU URCi_Coil) total transfer cost WITHOUT performing the \
            \ transfer — the flavor-B preview counterpart of C_Transfer's billed cost."
        (URCi_TransferCumulator
            (at "type" (URC_TransferClasses id sender receiver transfer-amount))
            id sender receiver
        )
    )
    (defun URCi_TransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (type:integer id:string sender:string receiver:string)
        (cond
            ((contains type [1 2]) (URCi_SmallTransferCumulator id sender receiver))
            ((contains type [3 4 5]) (URCi_MediumTransferCumulator id sender receiver))
            ((= type 6) (URCi_LargeTransferCumulator sender receiver))
            EOC
        )
    )
    (defun URCi_SmallTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-smallest")  sender
                (ref-IGNIS::URC_ZeroGAZ id sender receiver) []
            )
        )
    )
    (defun URCi_MediumTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-small") sender
                (ref-IGNIS::URC_ZeroGAZ id sender receiver) []
            )
        )
    )
    (defun URCi_LargeTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-medium") sender
                (ref-IGNIS::URC_ZeroEliteGAZ sender receiver) []
            )
        )
    )
    ;;Multi
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (id:string (at idx id-lst))
                                    (transfer-amount:decimal (at idx transfer-amount-lst))
                                    (what-type:integer (at "type" (URC_TransferClasses id sender receiver transfer-amount)))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (URCi_TransferCumulator what-type id sender receiver)
                                    )
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    ;;Bulk
    (defun URCi_MultiBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (ref-U|LST::UC_AppL acc
                                (URCi_BulkTransferCumulator
                                    (at idx id-lst)
                                    sender
                                    (at idx receiver-array)
                                    (at idx transfer-amount-array)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (what-type:integer (at "type" (URC_TransferClassesForBulk id sender transfer-amount-lst)))
                (size:integer (length receiver-lst))
            )
            (cond
                ((contains what-type [1 4 5]) (URCi_ComplexBulkTransferCumulator id sender size))
                ((= what-type 2) (URCi_UnityBulkTransferCumulator sender receiver-lst transfer-amount-lst))
                ((= what-type 3) (URCi_SimpleBulkTransferCumulator id sender size))
                ((= what-type 6) (URCi_EliteBulkTransferCumulator id sender size))
                EOC
            )
        )
    )
    ;;
    (defun URCi_UnityBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length receiver-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (transfer-amount:decimal (at idx transfer-amount-lst))
                                    (receiver:string (at idx receiver-lst))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (URCi_UnityTransferCumulator sender receiver transfer-amount)
                                    )
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_SimpleBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
        )
    )
    (defun URCi_ComplexBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-small"))
        )
    )
    (defun URCi_EliteBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-medium"))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_MinimumMapperForBulk
        (id:string transfer-amount-lst:[decimal])
        (map
            (lambda
                (idx:integer)
                (UEV_Minimum id (at idx transfer-amount-lst))
            )
            (enumerate 0 (- (length transfer-amount-lst) 1))
        )
    )
    (defun UEV_Minimum (id:string amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move-read:decimal (ref-DPTF::UR_MinMove id))
                (precision:integer (ref-DPTF::UR_Decimals id))
                (min-move:decimal
                    (if (= min-move-read -1.0)
                        (floor (/ 1.0 (^ 10.0 (dec precision))) precision)
                        min-move-read
                    )
                )
            )
            (enforce (>= amount min-move) (format "{} is not a valid {} min move amount" [amount id]))
        )
    )
    (defun UEV_DispoLocker (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (type:bool (ref-DALOS::UR_AccountType account))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-amount:decimal (ref-DALOS::UR_TF_AccountSupply account true))
            )
            (if (and (= id ea-id) (not type))
                (enforce (not (< ouro-amount 0.0)) "When Account has negative OURO, Elite-Auryn is dispo-locked and cannot be moved")
                true
            )
        )
    )
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (verum-five:[string] (ref-DPTF::UR_Verum5 id))
                (lvf:integer (length verum-five))
                (transfer-roles:integer
                    (if (and (= lvf 1) (= verum-five [BAR]))
                        0 lvf
                    )
                )
                (are-transfer-roles-active:bool (if (> transfer-roles 0) true false))
                (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                (allow:string (format "{} Transfer from {} to {} is allowed" [TF ss sr]))
            )
            (if are-transfer-roles-active
                (let
                    (
                        (ouroboros:string OUROBOROS|SC_NAME)
                        (dalos:string DALOS|SC_NAME)
                        ;;
                        (sender-transfer-role:bool (ref-DPTF::UR_AccountRoleTransfer id sender))
                        (receiver-transfer-role:bool (ref-DPTF::UR_AccountRoleTransfer id receiver))
                    )
                    (enforce-one
                        (format "Incompatible Transfer Roles from {} to {}" [ss sr])
                        [
                            (enforce sender-transfer-role (format "Incompatible Transfer Role for Sender {}" [ss]))
                            (enforce receiver-transfer-role (format "Incompatible Transfer Role for Receiver {}" [sr]))
                        ]
                    )
                )
                allow
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSMUTE
    (defun XI_Transmute (id:string transmuter:string transmute-amount:decimal)
        (require-capability (DPTF|C>X-TRANSMUTE id transmuter transmute-amount))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData transmuter))
            )
            (ref-DPTF::XB_DebitTrueFungible id transmuter transmute-amount dispo-data false)
            (XI_CreditPrimaryFee id transmute-amount false)
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSFER
    (defun XI_SimpleTransfer (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (require-capability (DPTF|C>X-TRANSFER id sender receiver method))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
            )
            (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
            (ref-DPTF::XB_CreditTrueFungible id receiver transfer-amount)
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSFER
    (defun XI_ComplexTransfer (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (require-capability (DPTF|C>X-TRANSFER id sender receiver method))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
            )
            (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
            (XI_ComplexCredit id receiver transfer-amount)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_CreditTrueFungible,
    ;;Protection:          XE_UpdateFeeVolume
    (defun XI_ComplexCredit (id:string receiver:string transfer-amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dalos:string DALOS|SC_NAME)
                (fees:[decimal] (ref-DPTF::URC_Fee id transfer-amount))
                (primary-fee:decimal (at 0 fees))
                (secondary-fee:decimal (at 1 fees))
                (remainder:decimal (at 2 fees))
            )
            (if (!= primary-fee 0.0)
                (XI_CreditPrimaryFee id primary-fee true)
                true
            )
            (if (!= secondary-fee 0.0)
                (do
                    (ref-DPTF::XB_CreditTrueFungible id dalos secondary-fee)
                    (ref-DPTF::XE_UpdateFeeVolume id secondary-fee false)
                )
                true
            )
            (ref-DPTF::XB_CreditTrueFungible id receiver remainder)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_DirectUpdateEliteAccount
    (defun XI_DynamicUpdateEliteAccount (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (type:bool (ref-DALOS::UR_AccountType account))
            )
            (if (not type)
                (XI_DirectUpdateEliteAccount account)
                true
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_UpdateElite
    (defun XI_DirectUpdateEliteAccount (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ELITE:module{EliteV2} ELITE)
                (elite-aurynz:decimal (ref-ELITE::URC_EliteAurynzSupply account))
            )
            (ref-DALOS::XE_UpdateElite account elite-aurynz)
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkCredit
        (id:string receiver-lst:[string] transfer-amount-lst:[decimal] complexity:bool elite:bool)
        (require-capability (SECURE))
        (let
            (
                (size:integer (length receiver-lst))
            )
            (if (not complexity)
                (do
                    (XI_BulkCreditAmounts id receiver-lst transfer-amount-lst)
                    (if elite (XI_BulkUpdateElite receiver-lst) true)
                )
                (let
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                        (dalos:string DALOS|SC_NAME)
                        (fees:[decimal] (UC_BulkFees id transfer-amount-lst))
                        (primary-fee:decimal (at 0 fees))
                        (secondary-fee:decimal (at 1 fees))
                        (bulk-remainders:[decimal] (UC_BulkRemainders id transfer-amount-lst))
                    )
                    (if (!= primary-fee 0.0)
                        (XI_CreditPrimaryFee id primary-fee true)
                        true
                    )
                    (if (!= secondary-fee 0.0)
                        (do
                            (ref-DPTF::XB_CreditTrueFungible id dalos secondary-fee)
                            (ref-DPTF::XE_UpdateFeeVolume id secondary-fee false)
                        )
                        true
                    )
                    (XI_BulkCreditAmounts id receiver-lst bulk-remainders)
                    (if elite (XI_BulkUpdateElite receiver-lst) true)
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkCreditAmounts (id:string receiver-lst:[string] amounts:[decimal])
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (map
                (lambda
                    (idx:integer)
                    (ref-DPTF::XB_CreditTrueFungible id (at idx receiver-lst) (at idx amounts))
                )
                (enumerate 0 (- (length receiver-lst) 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkUpdateElite (receiver-lst:[string])
        (require-capability (SECURE))
        (map
            (lambda
                (idx:integer)
                (XI_DirectUpdateEliteAccount (at idx receiver-lst))
            )
            (enumerate 0 (- (length receiver-lst) 1))
        )
    )
    ;;  [Aux Credit-Primary-Fee]
    ;;Protection: Class 1 — Innate protection offered by XI_CPF_StillFee, XI_CPF_CreditFee,
    ;;Protection:          XI_CPF_BurnFee, XB_CreditTrueFungible, XE_UpdateFeeVolume
    (defun XI_CreditPrimaryFee (id:string pf:decimal native:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (rt:bool (ref-DPTF::URC_IzRT id))
                (rbt:bool (ref-DPTF::URC_IzRBT id))
                (target:string (ref-DPTF::UR_FeeTarget id))
            )
            (if (and rt rbt)
                (let
                    (
                        (v:[decimal] (URCx_CPF_RT-RBT id pf))
                        (v1:decimal (at 0 v))
                        (v2:decimal (at 1 v))
                        (v3:decimal (at 2 v))
                    )
                    (XI_CPF_StillFee id target v1)
                    (XI_CPF_CreditFee id target v2)
                    (XI_CPF_BurnFee id target v3)
                )
                (if rt
                    (let
                        (
                            (v1:decimal (URCx_CPF_RT id pf))
                            (v2:decimal (- pf v1))
                        )
                        (XI_CPF_StillFee id target v1)
                        (XI_CPF_CreditFee id target v2)
                    )
                    (if rbt
                        (let
                            (
                                (v1:decimal (URCx_CPF_RBT id pf))
                                (v2:decimal (- pf v1))
                            )
                            (XI_CPF_StillFee id target v1)
                            (XI_CPF_BurnFee id target v2)
                        )
                        (ref-DPTF::XB_CreditTrueFungible id target pf)
                    )
                )
            )
            (if native
                (ref-DPTF::XE_UpdateFeeVolume id pf true)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_StillFee (id:string target:string still-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (!= still-fee 0.0)
                (ref-DPTF::XB_CreditTrueFungible id target still-fee)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_BurnFee (id:string target:string burn-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (!= burn-fee 0.0)
                (ref-DPTF::XBv_UpdateSupply id burn-fee false)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_CreditFee (id:string target:string credit-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ats:string (ref-ATS::GOV|ATS|SC_NAME))
            )
            (if (!= credit-fee 0.0)
                (ref-DPTF::XB_CreditTrueFungible id ats credit-fee)
                true
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;Clear Dispo
    (defun C_ClearDispo:object{IgnisCollectorV3.OutputCumulator}
        (account:string)
        (P|UEV_IMC)
        (with-capability (DPTF|C>CLEAR-DISPO account)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    ;;
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (a-id:string (ref-DALOS::UR_AurynID))
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                    (ouro-amount:decimal (abs (ref-DPTF::UR_AccountSupply ouro-id account)))
                    ;;#58L fix: removed the dead `account-ea-supply` binding (bound, never
                    ;;referenced anywhere in the function body). No functional change.
                    (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ea-id account))
                    ;;
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
                    (auryndex-value:decimal (ref-ATS::URC_Index auryndex))
                    (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex))
                    ;;
                    (o-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                    (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                    (ea-prec:integer (ref-DPTF::UR_Decimals ea-id))
                    ;;
                    (burn-auryn-amount:decimal (floor (/ ouro-amount auryndex-value) a-prec))
                    (burn-elite-auryn-amount:decimal (floor (/ burn-auryn-amount elite-auryndex-value) ea-prec))
                    (total-ea:decimal (floor (* burn-elite-auryn-amount 2.5) ea-prec))
                    (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                    ;;
                    ;;Ignis Cumulation
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount ea-id account true)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_WipeSlim ea-id account total-ea)
                    )
                    ;;#28M fix: only unfreeze if this function was the one that froze it (mirrors
                    ;;ico1's own condition) - otherwise a pre-existing, unrelated freeze on this
                    ;;account gets silently lifted by ClearDispo.
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount ea-id account false)
                            EOC
                        )
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn a-id ats-sc burn-auryn-amount)
                    )
                    (ico5:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn ouro-id ats-sc ouro-amount)
                    )
                )
            ;;1] Freeze EA on account
                ;;via ico1
            ;;2] Partial Wipe EA on account
                ;;via ico2
            ;;3] Unfreeze EA on account
                ;;via ico3
            ;;4] <ATS|SC-NAME> burns <burn-auryn-amount> Auryn amount and decrease Resident Amount by it on <elite-auryndex>
                ;via ico4
                (ref-ATS::XE_UpdateRUR elite-auryndex a-id 1 false burn-auryn-amount)
            ;;5] <ATS|SC-NAME> burns <ouro-amount> OURO amount and decrease Resident Amount by it on <auryndex>
                ;;via ico5
                (ref-ATS::XE_UpdateRUR auryndex ouro-id 1 false ouro-amount)
            ;;6] Finally clears dispo setting OURO <acount> amount to zero
                ;;A dispo IS a negative OURO balance -- the defcap above refuses anything else --
                ;;and <UR_Supply> counts it as negative: the sublimation that opened the dispo
                ;;decremented supply by the very amount it drove the balance below zero. So
                ;;zeroing the balance RETURNS <ouro-amount> to the ledger and supply must follow
                ;;it. Without the second line, ico5's burn is the only supply move in this
                ;;function and it is counted TWICE -- once against ATS's real OURO, once against
                ;;the phantom OURO the dispo represented -- leaving total supply permanently
                ;;BELOW the sum of all balances, by the amount of every dispo ever cleared.
                ;;This is the ONLY one-sided call to DALOS::XB_UpdateBalance in the tree; the
                ;;other four sites are the two halves of a transfer, or DPTF's own dispatch.
                ;;Pinned by RedTeam/[RT-J]_Conservation.repl <<RT-J-001c>>/<<RT-J-001d>>.
                (ref-DALOS::XB_UpdateBalance account true 0.0)
                (ref-DPTF::XBv_UpdateSupply ouro-id ouro-amount true)
            ;;7] Updating Elite Account and Constructing the Output: Pleasure doing business with you !
                (XI_DirectUpdateEliteAccount account)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3  ico4 ico5] [])
            )
        )
    )
    ;;Transmute
    (defun C_Transmute:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string transmute-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (iz-ea:bool (URC_IzTrueFungibleEliteAuryn id))
            )
            (if iz-ea
                (with-capability (DPTF|C>ELITE-TRANSMUTE id transmuter transmute-amount)
                    (XI_Transmute id transmuter transmute-amount)
                    (XI_DirectUpdateEliteAccount transmuter)
                    (URCi_LargeTransmuteCumulator id transmuter)
                )
                (with-capability (DPTF|C>TRANSMUTE id transmuter transmute-amount)
                    (XI_Transmute id transmuter transmute-amount)
                    (URCi_SmallTransmuteCumulator id transmuter)
                )
            )
        )
    )
    ;;Transfer
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (P|UEV_IMC)
        (let
            (
                (what-type:integer (at "type" (URC_TransferClasses id sender receiver transfer-amount)))
            )
            (cond
                ((= what-type 1) 
                    (with-capability (DPTF|C>CLASS-1-TRANSFER id sender receiver transfer-amount method)
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 2) 
                    (with-capability (DPTF|C>CLASS-1-TRANSFER-UNITY id sender receiver transfer-amount method)
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 3) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER id sender receiver transfer-amount method)
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 4) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER-UNITY id sender receiver transfer-amount method)
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 5) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER-ELITE id sender receiver transfer-amount method)    
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                )
                ((= what-type 6) 
                    (with-capability (DPTF|C>CLASS-3-TRANSFER-ELITE id sender receiver transfer-amount method)   
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                )
                true
            )
            (URCi_TransferCumulator what-type id sender receiver)
        )
    )
    ;;Multi Transfer
    (defun C_MultiTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|C>MULTI-TRANSFER id-lst sender receiver transfer-amount-lst method)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (contains-eazs:bool (UC_ContainsEliteAurynz id-lst))
                    (l:integer (length id-lst))
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (let
                                    (
                                        (id:string (at idx id-lst))
                                        (transfer-amount:decimal (at idx transfer-amount-lst))
                                        (what-type-obj:object{TrueFungibleTransferV2.TransferClass} (URC_TransferClasses id sender receiver transfer-amount))
                                        (what-type:integer (at "type" what-type-obj))
                                        (ico:object{IgnisCollectorV3.OutputCumulator}
                                            (URCi_TransferCumulator what-type id sender receiver)
                                        )
                                        (iz-simple-transfer:bool (at "iz-it-simple" what-type-obj))
                                        ;;#29M fix: recompute dispo-data fresh for EACH leg (was
                                        ;;snapshotted once before the fold and reused for every
                                        ;;leg) - otherwise an earlier/later leg in this same batch
                                        ;;that reduces sender's Elite-Auryn holdings leaves this
                                        ;;leg's OURO-overdraft check using a stale, too-generous
                                        ;;dispo limit.
                                        (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
                                    )
                                    ;;Debit
                                    (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
                                    ;;Credit
                                    (if iz-simple-transfer
                                        (ref-DPTF::XB_CreditTrueFungible id receiver transfer-amount)
                                        (XI_ComplexCredit id receiver transfer-amount)
                                    )
                                    (ref-U|LST::UC_AppL acc ico)
                                )
                            )
                            []
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (if contains-eazs
                    (do
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
            )
        )
    )
    ;;Bulk Transfer
    (defun C_MultiBulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (contains-eazs:bool (UC_ContainsEliteAurynz id-lst))
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (id:string (at idx id-lst))
                                    (receiver-lst:[string] (at idx receiver-array))
                                    (transfer-amount-lst:[decimal] (at idx transfer-amount-array))
                                    (size:integer (length receiver-lst))
                                    (what-type-obj:object{TrueFungibleTransferV2.TransferClass}
                                        (URC_TransferClassesForBulk id sender transfer-amount-lst)
                                    )
                                    (what-type:integer (at "type" what-type-obj))
                                    (iz-it-simple:bool (at "iz-it-simple" what-type-obj))
                                    (total-debit:decimal (fold (+) 0.0 transfer-amount-lst))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (cond
                                            ((contains what-type [1 4 5]) (URCi_ComplexBulkTransferCumulator id sender size))
                                            ((= what-type 2) (URCi_UnityBulkTransferCumulator sender receiver-lst transfer-amount-lst))
                                            ((= what-type 3) (URCi_SimpleBulkTransferCumulator id sender size))
                                            ((= what-type 6) (URCi_EliteBulkTransferCumulator id sender size))
                                            EOC
                                        )
                                    )
                                    ;;#29M fix: recompute dispo-data fresh for EACH leg, same
                                    ;;reasoning as C_MultiTransfer above.
                                    (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
                                )
                                ;;Debit
                                (with-capability (P|TFT|CALLER)
                                    (ref-DPTF::XB_DebitTrueFungible id sender total-debit dispo-data false)
                                )
                                ;;Credit
                                (cond
                                    ((= what-type 1) 
                                        (with-capability (DPTF|C>CLASS-0-BULK id sender receiver-lst transfer-amount-lst iz-it-simple) 
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 2) 
                                        (with-capability (DPTF|C>CLASS-0-BULK-UNITY id sender receiver-lst transfer-amount-lst iz-it-simple)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 3) 
                                        (with-capability (DPTF|C>CLASS-1-BULK id sender receiver-lst transfer-amount-lst)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst false false)
                                        )
                                    )
                                    ((= what-type 4) 
                                        (with-capability (DPTF|C>CLASS-2-BULK id sender receiver-lst transfer-amount-lst)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 5) 
                                        (with-capability (DPTF|C>CLASS-2-BULK-ELITE id sender receiver-lst transfer-amount-lst)    
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst false true)
                                        )
                                    )
                                    ((= what-type 6) 
                                        (with-capability (DPTF|C>CLASS-3-BULK-ELITE id sender receiver-lst transfer-amount-lst)    
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true true)
                                        )
                                    )
                                    true
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            ;;Refresh the sender's own Elite tier once, if any leg touched an Elite-Auryn
            ;;class token — the receiver side is already refreshed per-leg inside
            ;;XI_BulkCredit (via its `elite` flag -> XI_BulkUpdateElite).
            (if contains-eazs
                (XI_DynamicUpdateEliteAccount sender)
                true
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )

)

;; --- tables for 09_TFT.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

