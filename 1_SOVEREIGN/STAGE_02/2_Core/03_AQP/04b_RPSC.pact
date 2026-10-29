;; net: v1   ·   dev: v1   ;; NEW MODULE 2026-10-29. Never deployed, so its interface stays V1.
;; Deploy: load THIS file — interface + module ship together.
;; ==============================================================================
;; AQP-RPSC — the RPS COST & CLIENT surface, split out of 04_RPS.pact.
;;
;; WHY IT EXISTS, and the number that forced it. 04_RPS.pact reached 336,132 bytes
;; and its emitted deploy transaction reached 318,758 of _deploybundle.py's 320,000
;; cap — 1,242 bytes of headroom. Making the triplet reward ladder coil as
;; AQP|SC_NAME (so reward EVICTION can drive it without the beneficiary's
;; signature) needs more room than that: the homogeneous branch alone put the
;; transaction at 321,744, and the heterogeneous branch, two cost mirrors and the
;; ladder preview were still to come.
;;
;; The cap is not arbitrary and could not simply be raised: the size charge grows
;; as the SEVENTH power of transaction bytes, so RPS already spends 37% of a
;; 2,000,000-gas block on size alone. A module cannot be split across two
;; transactions either. So the module had to lose mass.
;;
;; WHAT MOVED, and how the seam was chosen. Not by taste — by fixpoint. Starting
;; from every URCi_*, every URC_*Ignis/*Preview and every client entrypoint, the
;; set was shrunk until no function LEFT BEHIND in RPS calls anything that moved,
;; because AQP-RPSC deploys AFTER RPS and a backward call is unbuildable. 25 members
;; survived that, 38,310 bytes.
;;
;; FOUR WERE PULLED BACK and stay in RPS, each named by the stayer that calls it:
;;   URC_SettleStakePendingIgnis    <- XI_RpsPreScore
;;   URCi_Inject                    <- XI_FvtInjectCore, XIv_FvtAddStream
;;   URC_BookStakeUnclaimedIgnis    <- XI_BookStakeUnclaimedCounts
;;   URC_CheckpointStakeRpsIgnis    <- XI_CheckpointStakeRps
;; A useful consequence: the last two are exactly what AQP-VCT calls, so VCT's 12
;; call sites needed no change. AA_MigrateMinInject also stays — it is the only
;; candidate doing DIRECT table access, and the tables belong to RPS.
;;
;; NO POLICY SURFACE, DELIBERATELY. Every member here is a READER: there is no
;; write, no capability, no table, so there is nothing for P|UEV_IMC to gate and
;; no OuronetPolicyV2 to implement. 09_AQP-INFO.pact is the precedent — a leaf
;; preview module with no policy boilerplate at all. Unlike AQP-INFO this one IS
;; called by others (AQP-FVT, AQP-INFO, AQP-DSA), so it carries an interface and
;; is reached by modref rather than by dot call.
;; ==============================================================================

(interface AcquisitionRewardCostsV1
    @doc "The cost-preview and client surface for the AQP reward engine: every URCi_* IGNIS \
        \ reader, the collect ladder's cost mirrors and amount preview, and the stake-flow cost \
        \ readers. Split out of AcquisitionRewardPerShareV4 on 2026-10-29 for deploy-size \
        \ reasons recorded in the file header; the members are unchanged."

    ;;{1}  CAP
    ;;{2}  FUN
    ;;{5.1}  Compute [UC/UCv]
    ;;{5.2}  Read [UR]
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun UDC_LadderPreview:object ( mode:string payout:decimal token-0-id:string token-0-amount:decimal token-1-id:string token-1-amount:decimal token-2-id:string token-2-amount:decimal ))
    (defun URCi_RotateOwnership:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string))
    (defun URCi_Control:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetMosaic:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetSplitMode:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_AddRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_InjectFull:decimal (op-key:string patron:string fvt-id:string reward-dptf-id:string amount:decimal))
    (defun URCi_Collect:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string))
    (defun URC_CollectXferIgnis:decimal (id:string collector:string amount:decimal))
    (defun URC_HeterogeneousLaneRouteIgnis:decimal (collector:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer))
    (defun URC_CollectLadderPreview:object (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URC_CollectTransferLegIgnis:decimal (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URC_CollectForcedFixIgnis:decimal (patron:string collector:string fvt-id:string reward-dptf-id:string))
    (defun URCi_CollectFull:decimal (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URCi_TrueFungibleStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool))
    (defun URCi_OrtoFungibleStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool))
    (defun URCi_CollectableStakeFlow:decimal (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
)

(module AQP-RPSC GOV
    @doc "AQP reward-engine COST and CLIENT surface. Reads RPS's state through its interface and \
        \ derives every IGNIS figure the Talos layer and AQP-INFO quote; writes nothing, owns no \
        \ table, holds no capability. See the file header for why it is a separate module."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements AcquisitionRewardCostsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_RPSC (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G4}  capabilities
    (defcap GOV () (compose-capability (GOV|RPSC_ADMIN)))
    (defcap GOV|RPSC_ADMIN () (enforce-guard GOV|MD_RPSC))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    ;;RESOLVED, NOT COPIED. These two are read from their owning modules by the same
    ;;accessor pattern 04_RPS.pact uses, so there is one source of truth for each.
    (defconst BAR                                       (CT_Bar))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    ;;
    ;;COPIED LITERALS, AND THE DUPLICATION IS PRE-EXISTING RATHER THAN INTRODUCED HERE:
    ;;04_RPS.pact and 05_FVT.pact ALREADY carry their own copies of all four (see
    ;;05_FVT.pact's {3.1} block). A third copy follows that practice, so it is pinned
    ;;instead of trusted -- the REPL suite asserts RPS, FVT and AQP-RPSC agree on every
    ;;one. A constant duplicated three ways and checked nowhere is how a reward kind
    ;;silently stops matching.
    (defconst CT_FORCED_FIX_RATE:decimal                10.0)
    (defconst CT_SCORE_ENTITY_TRIPLET                   3)
    (defconst CT_REWARD_KIND_MULTIPLET_BASE             "MULTIPLET_BASE")
    (defconst CT_REWARD_MODE_HETEROGENEOUS              "HETEROGENEOUS")
    ;;{3.2}  functions
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun UDC_LadderPreview:object
        (
            mode:string
            payout:decimal
            token-0-id:string token-0-amount:decimal
            token-1-id:string token-1-amount:decimal
            token-2-id:string token-2-amount:decimal
        )
        @doc "Constructor for URC_CollectLadderPreview's answer: the per-token amounts a collect \
            \ actually pays out, plus the `mode` that decided the routing and the `payout` basis \
            \ they sum to. BARE object by design -- it describes no table row, and a schema would \
            \ have to live in AcquisitionSchemasV3 and bump it for a read-only client preview. \
            \ `mode` is BAR for a non-ladder lane, where the whole payout lands on token-0."
        {"mode"             : mode
        ,"payout"           : payout
        ,"token-0-id"       : token-0-id
        ,"token-0-amount"   : token-0-amount
        ,"token-1-id"       : token-1-id
        ,"token-1-amount"   : token-1-amount
        ,"token-2-id"       : token-2-id
        ,"token-2-amount"   : token-2-amount}
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership on the (pre-rotate) FVT owner \
            \ — deter(auth) + components, like every other module's RotateOwnership."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_RotateOwnership" "auth")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_Control:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string)
        @doc "Cost preview for AQP-FVT|C_Control on the FVT owner — deter(setup) + components, \
            \ like every other module's Control."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_Control" "setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetCommonDenominator" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetMosaic:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetMosaic" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetSplitMode:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetSplitMode" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_AddScoreEntity" "add-score-entity")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_ToggleScoreEntityLink" "fvt-link-toggle")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_AddRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_AddRewardLink" "add-reward-link")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_ToggleRewardLink" "fvt-link-toggle")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_SetQualitySplit" "fvt-split-setup")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_InjectFull:decimal
        (op-key:string patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FULL ignis-for-price of the inject family: the custody-transfer leg PLUS the gas leg. \
            \ <URCi_Inject> alone is only the gas leg, but XI_FvtInjectCore concatenates a \
            \ <TFT::C_Transfer> of the reward principal ahead of it, and that transfer carries its \
            \ own cumulator -- so a preview quoting <URCi_Inject> on its own is short by exactly the \
            \ transfer leg. The other two phases XI_FvtInjectCore concatenates (XI_ReleaseStream, \
            \ XI_DistributeInjectAmount) build no cumulator and cost nothing. Same shape as \
            \ <URCi_CollectFull> and <URCi_TrueFungibleStakeFlow> leg 1.1, both of which already \
            \ count their transfer legs this way; the inject family was the only one that did not. \
            \ Module-only, like <URCi_Inject> itself -- the INFO module reaches it dotted."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (xfer-type:integer
                    (at "type" (TFT.URC_TransferClasses reward-dptf-id patron AQP|SC_NAME amount)))
            )
            (+  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (TFT.URCi_TransferCumulator xfer-type reward-dptf-id patron AQP|SC_NAME))
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (RPS.URCi_Inject op-key fvt-id []))
            )
        )
    )
    (defun URCi_Collect:object{IgnisCollectorV4.OutputCumulator} (fvt-id:string output:[string])
        @doc "GAS|COLLECT gas leg (konto = FVT owner); exec concats it with the forced-fix penalty leg and (triplet) the ATS ladder legs."
        (let
            (
                (r:module{IgnisCollectorV4} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|CC_Collect" "aqp-collect")
                (RPS.UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string)
        @doc "Read-only IGNIS ifp of the custody move in XE_WithdrawRoyalty: IGNIS-normalize leg (compress the \
            \ IGNIS royalty to OURO when reward-dptf is IGNIS, else none) + a TFT transfer of the normalized live \
            \ royalty balance from AQP|SC_NAME to <destination>."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                ;;
                (royalty:decimal   (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool     (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string      (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal    (if is-ignis (at 0 (ref-ORBR::URCv_Compress royalty)) royalty))
                (xfer-type:integer (at "type" (ref-TFT::URC_TransferClasses token AQP|SC_NAME destination amount)))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_TransferCumulator xfer-type token AQP|SC_NAME destination)))
        ))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string)
        @doc "Read-only IGNIS ifp of the custody burn in XE_BurnRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + a DPTF burn of the normalized live royalty balance from AQP|SC_NAME."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                ;;
                (royalty:decimal (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Burn token AQP|SC_NAME)))
        ))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Read-only IGNIS ifp of the custody fuel in XE_FuelRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + an SWPLC fuel of the normalized live royalty balance from AQP|SC_NAME \
            \ into <swpair> (amount in the normalized token's slot, 0 elsewhere; direct)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
                (ref-SWP:module{SwapperV5} SWP)
                (ref-SWPLC:module{SwapperLiquidityClientV3} SWPLC)
                ;;
                (royalty:decimal (RPS.UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal  (if is-ignis (at 0 (ref-ORBR::URCv_Compress royalty)) royalty))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (input-amounts:[decimal] (map (lambda (t:string) (if (= t token) amount 0.0)) pool-tokens))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_Fuel AQP|SC_NAME swpair input-amounts true)))
        ))
    (defun URC_CollectXferIgnis:decimal (id:string collector:string amount:decimal)
        @doc "IGNIS ifp of one reward custody transfer AQP|SC_NAME -> collector of <amount> <id> (0 when amount<=0); \
            \ mirrors (if (> amt 0.0) (C_Transfer id AQP|SC_NAME collector amt true) (UC_EmptyOc))."
        (if (<= amount 0.0)
            0.0
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                )
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_TransferCumulator
                        (at "type" (ref-TFT::URC_TransferClasses id AQP|SC_NAME collector amount))
                        id AQP|SC_NAME collector))
            )))
    (defun URC_HeterogeneousLaneRouteIgnis:decimal
        (collector:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer)
        @doc "IGNIS ifp mirror of XI_1|HeterogeneousLaneRoute: ONE token-0 pre-fund of the whole payout + \
            \ Coil(total-t1+total-t2) on ats-01 + Coil(remainder) on ats-12. Mirrors the exec leg for leg; \
            \ the leg list here and the leg list there are the same three branches."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-ATS:module{AutostakeV4} ATS)
                (bs:[integer] (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id))
                (ss:[integer] (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id))
                (gs:[integer] (RPS.UR_FVT-QS|GoldSplit fvt-id reward-dptf-id))
                (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                (b0:decimal (floor (/ (* amt-b (dec (at 0 bs))) 1000.0) prec))
                (b1:decimal (floor (/ (* amt-b (dec (at 1 bs))) 1000.0) prec))
                (s0:decimal (floor (/ (* amt-s (dec (at 0 ss))) 1000.0) prec))
                (s1:decimal (floor (/ (* amt-s (dec (at 1 ss))) 1000.0) prec))
                (g0:decimal (floor (/ (* amt-g (dec (at 0 gs))) 1000.0) prec))
                (g1:decimal (floor (/ (* amt-g (dec (at 1 gs))) 1000.0) prec))
                (total-t0:decimal (+ b0 (+ s0 g0)))
                (total-t1:decimal (+ b1 (+ s1 g1)))
                (total-t2:decimal (- (+ amt-b (+ amt-s amt-g)) (+ total-t0 total-t1)))
                (fund-12:decimal (+ total-t1 total-t2))
                (payout-all:decimal (+ total-t0 fund-12))
            )
            (if (<= fund-12 0.0)
                (URC_CollectXferIgnis token-0 collector payout-all)
                (let
                    (
                        (h-all:object{AutostakeV4.CoilData}
                            (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund-12))
                        (rbt1-keep:decimal
                            (if (> total-t1 0.0)
                                (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t1))
                                0.0))
                    )
                    (let
                        (
                            (rbt1-id:string (at "rbt-id" h-all))
                            (rbt1-ladder:decimal (- (at "rbt-amount" h-all) rbt1-keep))
                            ;;MIRRORS THE AQP|SC_NAME LADDER, leg for leg, and the leg list here and
                            ;;the one in RPS::XI_1|HeterogeneousLaneRoute are the same four branches.
                            ;;<URCi_CoilTo>, not <URCi_Coil>: a transfer's IGNIS class is chosen by
                            ;;URC_TransferClasses -> URC_IzSimpleTransfer -> UR_AccountRoleFeeExemption
                            ;;on the RECEIVER, so a coil funded by AQP|SC_NAME and credited to a
                            ;;beneficiary must price BOTH endpoints. Naming one account twice is the
                            ;;five-site defect this family already paid for on 2026-10-29.
                            (hop1:bool (> (at "rbt-amount" h-all) 0.0))
                            (hop2:bool
                                (and (> rbt1-ladder 0.0)
                                     (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder)) 0.0)))
                        )
                        (fold (+) 0.0
                            [ (URC_CollectXferIgnis token-0 collector (if hop1 total-t0 payout-all))
                              (if hop1
                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME AQP|SC_NAME ats-01 token-0 fund-12))
                                  0.0)
                              (if hop1
                                  (URC_CollectXferIgnis rbt1-id collector (if hop2 rbt1-keep (at "rbt-amount" h-all)))
                                  0.0)
                              (if hop2
                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME collector ats-12 rbt1-id rbt1-ladder))
                                  0.0)
                            ])
                    )
                )
            )
        ))
    (defun URC_CollectLadderPreview:object
        (collector:string pool-id:string fvt-id:string score-entity-type:integer
         score-entity-id:string reward-dptf-id:string)
        @doc "AMOUNT preview for a collect: what the collector actually RECEIVES, per token. \
            \ A MULTIPLET_BASE triplet lane pays in up to THREE tokens, so a client showing one \
            \ figure in one ticker names a denomination the collector will not receive. Returns \
            \ {mode, payout, token-N-id, token-N-amount} for N in 0..2; a non-ladder lane answers \
            \ the whole payout on token-0 with BAR/0.0 above it. \
            \ Mirrors XI_TransferRewardDptfFromVault leg for leg, INCLUDING both precision skips: \
            \ when hop 1 rounds to zero the collector keeps the whole payout as token-0, and when \
            \ hop 2 rounds to zero they keep ALL of token-1 rather than the token-1 keep-share. \
            \ Returns a BARE object, so by the interface object-return rule it is module-only -- \
            \ a client reaches it as `ouronet-ns.RPS.URC_CollectLadderPreview`, the same way it \
            \ must already reach URC_ComputeTripletLanes. Pinned against real balance deltas by \
            \ REPL/Stage_02/[6.4]_AQP-LADDER-PREVIEW.repl -- a preview nothing compares to \
            \ execution is a fourth copy of the ladder waiting to drift."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (reward-kind:string (RPS.UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (RPS.URC_CollectClaimableRewards collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            ;;BRANCH ON KIND BEFORE AMOUNT, deliberately. Short-circuiting on `payout <= 0`
            ;;first was the obvious shape and it was wrong for the common case: EVERY lane the
            ;;user is not currently owed anything on has payout 0, and answering those with BAR
            ;;token ids leaves a client unable to tell a drained LADDER lane from a plain one --
            ;;so it renders one unknown ticker instead of three tokens at zero.
            (if (not (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE)
                          (= score-entity-type CT_SCORE_ENTITY_TRIPLET)))
                ;;plain lane: one token, the whole payout, nothing above it.
                (UDC_LadderPreview BAR payout reward-dptf-id payout BAR 0.0 BAR 0.0)
                (if (<= payout 0.0)
                    ;;drained LADDER lane: the identities and the mode are still the truth about
                    ;;this lane, and they cost three row reads -- no lane scan, no ATS derivation.
                    (let
                        (
                            (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        )
                        (UDC_LadderPreview (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id) 0.0
                            (RPS.UR_FVT-MF|Token0Id mf-id) 0.0
                            (RPS.UR_FVT-MF|Token1Id mf-id) 0.0
                            (RPS.UR_FVT-MF|Token2Id mf-id) 0.0)
                    )
                (let*
                    (
                        (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        (lanes:object (RPS.URC_ComputeTripletLanes collector pool-id score-entity-id))
                        (w-total:decimal (at "w-user" lanes))
                        (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                        (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                        (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                        (prec:integer (ref-DPTF::UR_Decimals token-0))
                        (mode:string (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id))
                        (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ (at "lane-b" lanes) w-total)) prec) 0.0))
                        (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ (at "lane-s" lanes) w-total)) prec) 0.0))
                        (amt-g:decimal (- payout (+ amt-b amt-s)))
                        ;;HOMOGENEOUS routes lane->one token; HETEROGENEOUS splits EACH lane across
                        ;;all three per the per-mille matrix. Either way the route reduces to the
                        ;;same three figures: raw token-0, the amount coiled once, the remainder.
                        (raw:decimal
                            (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                                (+ (floor (/ (* amt-b (dec (at 0 (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                   (+ (floor (/ (* amt-s (dec (at 0 (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                      (floor (/ (* amt-g (dec (at 0 (RPS.UR_FVT-QS|GoldSplit   fvt-id reward-dptf-id)))) 1000.0) prec)))
                                amt-b))
                        (once:decimal
                            (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                                (+ (floor (/ (* amt-b (dec (at 1 (RPS.UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                   (+ (floor (/ (* amt-s (dec (at 1 (RPS.UR_FVT-QS|SilverSplit fvt-id reward-dptf-id)))) 1000.0) prec)
                                      (floor (/ (* amt-g (dec (at 1 (RPS.UR_FVT-QS|GoldSplit   fvt-id reward-dptf-id)))) 1000.0) prec)))
                                amt-s))
                    )
                    (let*
                        (
                            (fund:decimal (- payout raw))
                            (token-1:string (RPS.UR_FVT-MF|Token1Id mf-id))
                            (token-2:string (RPS.UR_FVT-MF|Token2Id mf-id))
                            ;;hop 1 on the WHOLE laddering amount, exactly as the route coils it
                            (h-all:object{AutostakeV4.CoilData}
                                (if (> fund 0.0)
                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund)
                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 0.0)))
                            (rbt1-total:decimal (at "rbt-amount" h-all))
                            (rbt1-id:string (at "rbt-id" h-all))
                            (rbt1-keep:decimal
                                (if (> once 0.0)
                                    (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 once))
                                    0.0))
                            (rbt1-ladder:decimal (- rbt1-total rbt1-keep))
                            (rbt2:decimal
                                (if (> rbt1-ladder 0.0)
                                    (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder))
                                    0.0))
                        )
                        (if (<= rbt1-total 0.0)
                            ;;hop 1 rounds away: nothing is coiled, the single pre-fund already
                            ;;handed the collector the entire payout as token-0.
                            (UDC_LadderPreview mode payout token-0 payout token-1 0.0 token-2 0.0)
                            (if (> rbt2 0.0)
                                (UDC_LadderPreview mode payout token-0 raw token-1 rbt1-keep token-2 rbt2)
                                ;;hop 2 rounds away: the collector keeps ALL of token-1, not the keep-share.
                                (UDC_LadderPreview mode payout token-0 raw token-1 rbt1-total token-2 0.0)))
                    )
                ))
            )
        )
    )
    (defun URC_CollectTransferLegIgnis:decimal
        (collector:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of XI_TransferRewardDptfFromVault (PHASE 1.1 collect payout leg)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (reward-kind:string (RPS.UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (RPS.URC_CollectClaimableRewards collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            (if (<= payout 0.0)
                0.0
                (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                    (let*
                        (
                            (mf-id:string (RPS.UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (lanes:object (RPS.URC_ComputeTripletLanes collector pool-id score-entity-id))
                            (lane-b:decimal (at "lane-b" lanes))
                            (lane-s:decimal (at "lane-s" lanes))
                            (lane-g:decimal (at "lane-g" lanes))
                            (w-total:decimal (at "w-user" lanes))
                            (token-0:string (RPS.UR_FVT-MF|Token0Id mf-id))
                            (ats-01:string (RPS.UR_FVT-MF|Ats01Id mf-id))
                            (ats-12:string (RPS.UR_FVT-MF|Ats12Id mf-id))
                            (prec:integer (ref-DPTF::UR_Decimals token-0))
                            (mode:string (RPS.UR_FVT-QS|Mode fvt-id reward-dptf-id))
                            (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ lane-b w-total)) prec) 0.0))
                            (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ lane-s w-total)) prec) 0.0))
                            (amt-g:decimal (- payout (+ amt-b amt-s)))
                            (fund-sg:decimal (+ amt-s amt-g))
                        )
                        (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                            (URC_HeterogeneousLaneRouteIgnis collector fvt-id reward-dptf-id mf-id amt-b amt-s amt-g prec)
                            (if (<= fund-sg 0.0)
                                (URC_CollectXferIgnis token-0 collector payout)
                                (let*
                                    (
                                        (h-all:object{AutostakeV4.CoilData}
                                            (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 fund-sg))
                                        (rbt1-keep:decimal
                                            (if (> amt-s 0.0)
                                                (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-s))
                                                0.0))
                                        (rbt1-id:string (at "rbt-id" h-all))
                                        (rbt1-ladder:decimal (- (at "rbt-amount" h-all) rbt1-keep))
                                    )
                                    ;;SAME FOUR LEGS as RPS's homogeneous branch -- see the note in the
                                    ;;heterogeneous mirror above for why this takes URCi_CoilTo.
                                    (let
                                        (
                                            (hop1:bool (> (at "rbt-amount" h-all) 0.0))
                                            (hop2:bool
                                                (and (> rbt1-ladder 0.0)
                                                     (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-12 rbt1-id rbt1-ladder)) 0.0)))
                                        )
                                        (fold (+) 0.0
                                            [ (URC_CollectXferIgnis token-0 collector (if hop1 amt-b payout))
                                              (if hop1
                                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME AQP|SC_NAME ats-01 token-0 fund-sg))
                                                  0.0)
                                              (if hop1
                                                  (URC_CollectXferIgnis rbt1-id collector (if hop2 rbt1-keep (at "rbt-amount" h-all)))
                                                  0.0)
                                              (if hop2
                                                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_CoilTo AQP|SC_NAME collector ats-12 rbt1-id rbt1-ladder))
                                                  0.0)
                                            ]))
                                )))
                    )
                    (URC_CollectXferIgnis reward-dptf-id collector payout)))
        ))
    (defun URC_CollectForcedFixIgnis:decimal
        (patron:string collector:string fvt-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of CC_Collect PHASE 7 forced-fix penalty: (ffc x CT_FORCED_FIX_RATE / patron-discount) \
            \ gated by the virtual-gas toggle; 0 when ffc<=0. \
            \ TOOK A SECOND PARAMETER rather than a rename: the COUNT is the collector's (the exec reads \
            \ it for <executor>) while the DISCOUNT dividing it is the patron's, who actually pays."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ffc:integer (RPS.UR_FVT-FFC|Count fvt-id reward-dptf-id collector))
            )
            (if (<= ffc 0)
                0.0
                (RPS.UC_GasPrice (/ (* (dec ffc) CT_FORCED_FIX_RATE) (ref-DALOS::URC_IgnisGasDiscount patron))
                             (ref-IGNIS::URC_IsVirtualGasZero)))
        ))
    (defun URCi_CollectFull:decimal
        (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of CC_Collect = reward-payout leg (URC_CollectTransferLegIgnis) + Phase-7 \
            \ forced-fix penalty (URC_CollectForcedFixIgnis) + the URCi_Collect leg. Residual: the payout is read pre-drip, so \
            \ a lane carrying a LIVE stream (whose exec drip vests extra reward before payout) can shift the transfer \
            \ tier — exact only for un-streamed / already-settled lanes."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                ;;
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            ;;THE CONFLATION IS GONE, 2026-10-29. This read <patron> for BOTH roles, because
            ;;adding a parameter meant bumping a LIVE interface. AQP-FVT's interface had to bump
            ;;to V5 anyway -- for the XE_EvictDrip/XE_EvictPay eviction surface -- so the fix rode
            ;;that bump at near-zero marginal cost, which is why it waited rather than shipping as
            ;;its own cascade round.
            ;;
            ;;<collector> is the REWARD SUBJECT: its claimable is computed, its triplet lane split
            ;;is read from ITS deb scores, the transfer class depends on IT as receiver, and the
            ;;forced-fix count is ITS count. <patron> only supplies the IGNIS discount. A sponsored
            ;;collect now quotes the right account; before, it quoted the sponsor's figures.
            (fold (+) 0.0
                [ (URC_CollectTransferLegIgnis collector pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                  (URC_CollectForcedFixIgnis patron collector fvt-id reward-dptf-id)
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id]))
                ])
        ))
    (defun URCi_TrueFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Toggled total IGNIS IFP of CC_TrueFungibleStakeFlow. Legs: transfer + tracker + rollup \
            \ + RPS-settle + anchor-refresh(ANK per-unit + XB flat) + score-delta + book + checkpoint. \
            \ direction=true stake (owner→vault), false unstake (vault→owner)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (xfer-type:integer (at "type" (TFT.URC_TransferClasses dptf-id sender receiver amount)))
                (n-live:integer   (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 custody transfer
                      (TFT.URCi_TransferCumulator xfer-type dptf-id sender receiver)))
                  (RPS.URC_TierMedium)                                                                 ;; 1.2 pool tracker (medium ×1)
                  (RPS.URC_TierBiggest)                                                                ;; 1.3 ben rollup   (biggest ×1)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierFixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live))         ;; 3.1a ANK anchor refresh
                  (RPS.URC_TierBiggest)                                                                ;; 3.1b XB sync-count (biggest ×1)
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSum pool-id))                                 ;; 4   score delta
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_OrtoFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_OrtoFungibleStakeFlow. Legs: transfer(DPOF, direction- \
            \ INDEPENDENT) + tracker(medium × |nonces|) + RPS-settle + score-delta(class ∈ {0,2}) + \
            \ book + checkpoint. NO 1.3 rollup, NO anchor leg."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (nn:decimal       (dec (length nonces)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-indep)
                      (DPOF.URCi_MoveCumulator dpof-id nonces false)))
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSumForClasses pool-id [0 2]))                 ;; 4   score delta (class ∈ {0,2})
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_CollectableStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_CollectableStakeFlow (SF son=true class-3 / NF son=false \
            \ class-4). Legs: transfer(DPDC-T, direction-dependent) + tracker(medium × |nonces|) + \
            \ rollup(medium × |nonces|) + RPS-settle + anchor(FLAT medium + biggest) + score-delta \
            \ (class == son?3:4) + book + checkpoint. nonce-amounts is caller-supplied."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (bundle           (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (nn:decimal       (dec (length nonces)))
                (tgt-class:integer (if son 3 4))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-dep)
                      (DPDC-T.URCi_MultiTransferCumulator [collectable-id] [son] sender receiver [nonces] [nonce-amounts])))
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (* (RPS.URC_TierMedium) nn)                                                          ;; 1.3 rollup  (medium × |nonces|)
                  (RPS.URC_TierFixed (RPS.URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (RPS.URC_TierMedium)                                                                 ;; 3 anchor flat medium
                  (RPS.URC_TierBiggest)                                                                ;; 3 anchor flat biggest
                  (RPS.URC_TierFixed (RPS.URC_StakeScoreDeltaSumForClasses pool-id [tgt-class]))           ;; 4 score delta (class == son?3:4)
                  (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
)
