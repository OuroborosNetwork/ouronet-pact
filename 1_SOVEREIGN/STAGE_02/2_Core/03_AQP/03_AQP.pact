(interface AcquisitionPoolsV1
    (defun GOV|Demiurgoi ())
    ;;
    ;;  [UC]
    (defun UC_DPTFTrackerKey:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UC_DPOFTrackerKey:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPSFTrackerKey:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPNFTrackerKey:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UC_DPSFScoreAttributionKey:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UC_DPNFScoreAttributionKey:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    ;;
    ;;  [UR] AQP|Schema (AQP|T|Pool)
    (defun UR_AQP|AllPoolIds:[string] ())
    (defun UR_AQP|Pool:object{AQP|Schema} (pool-id:string))
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string))
    (defun UR_AQP|PoolAssetId:string (pool-id:string))
    (defun UR_AQP|PoolScorePrimary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSecondary:string (pool-id:string))
    (defun UR_AQP|PoolScoreTertiary:string (pool-id:string))
    (defun UR_AQP|PoolScoreQuaternary:string (pool-id:string))
    (defun UR_AQP|PoolScoreQuinary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSenary:string (pool-id:string))
    (defun UR_AQP|PoolScoreSeptenary:string (pool-id:string))
    (defun UR_AQP|PoolAqpId:string (pool-id:string))
    ;;
    ;;  [UR] AQP|TrueFungibleTracker (AQP|T|DPTFTracker)
    (defun UR_AQP|DPTFTracker:object{AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
    )
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    ;;
    ;;  [UR] AQP|OrtoFungibleTracker (AQP|T|DPOFTracker)
    (defun UR_AQP|DPOFTracker:object{AQP|OrtoFungibleTracker}
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
    )
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|SemiFungibleTracker (AQP|T|DPSFTracker)
    (defun UR_AQP|DPSFTracker:object{AQP|SemiFungibleTracker}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
    )
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|NonFungibleTracker (AQP|T|DPNFTracker)
    (defun UR_AQP|DPNFTracker:object{AQP|NonFungibleTracker}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
    )
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    ;;  [UR] AQP|DPSFScoreAttribution (AQP|T|DPSFScoreAttribution)
    (defun UR_AQP|DPSFScoreAttribution:object{AQP|DPSFScoreAttribution}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionPoolId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionDpsfId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionOwnerId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionBeneficiaryId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPSFScoreAttributionScoreId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    ;;
    ;;  [UR] AQP|DPNFScoreAttribution (AQP|T|DPNFScoreAttribution)
    (defun UR_AQP|DPNFScoreAttribution:object{AQP|DPNFScoreAttribution}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionPoolId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionDpnfId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionOwnerId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionBeneficiaryId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
    (defun UR_AQP|DPNFScoreAttributionScoreId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
    )
)
(module AQP-POOL GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionPoolsV1)
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP                    (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|AQP_ADMIN)))
    (defcap GOV|AQP_ADMIN ()                (enforce-guard GOV|MD_AQP))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|AQP|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|AQP|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|AQP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|AQP|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    (defschema AQP|Schema
        @doc "One aqp-class and one canonical asset-id per pool; employed \
            \ scores must match that class. Staking asset identity is \
            \ authoritative here (SCORE: Score -> aqpool-link -> this pool \
            \ -> asset-id). Class 0: asset-id is the primary LP key; stake \
            \ paths may accept additional linked LP token ids (native / \
            \ sleeping OF / frozen TF) when verified as the same LP family; \
            \ all credit the same pool score slots. Fix wrong pool economics \
            \ by issuing a new pool and new scores, not by mutating class or \
            \ primary asset-id after stake exists."
        ;;
        aqp-class:integer                                       ;;Defines the Pool Class, there are 5
        ;;                                                        Class 0 = LPs allowed - native|sleeping|freezing
        ;;                                                        Class 1 = DPTF Allowed (non LP) - native|freezing|sleeping|hibernating
        ;;                                                        Class 2 = DPOF Allowed (non LP) - native only
        ;;                                                        Class 3 = DPSF Score (SFTs)
        ;;                                                        Class 4 = DPNF Score (NFTs)
        asset-id:string                                         ;;ID of the Asset that is allowed to be staked in the Pool.
        ;;                                                        This must be in accordance with the <aqp-class> and together with it
        ;;                                                        Defines which assets can be staked in the Pool
        ;;
        ;;Score - Links
        score-primary:string
        score-secondary:string
        score-tertiary:string
        score-quaternary:string
        score-quinary:string
        score-senary:string
        score-septenary:string
        ;;
        ;;Select Keys
        aqp-id:string
    )
    ;;Staking Trackers
    (defschema AQP|TrueFungibleTracker
        balance:decimal                                         ;;Store DPTF Balance Amount
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dptf-id:string                                          ;;DPTF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
    )
    (defschema AQP|OrtoFungibleTracker
        balance:decimal                                         ;;Staked DPOF amount for this nonce slot
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpof-id:string                                          ;;DPOF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|SemiFungibleTracker
        @doc "DPSF custody: staked balance per pool, collection, owner, \
            \ beneficiary, nonce. Per-score contribution and revision live in \
            \ AQP|T|DPSFScoreAttribution (one row per score-id that this stake \
            \ updates, up to 7 per pool)."
        balance:decimal                                         ;;Stores DPSF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpsf-id:string                                          ;;DPSF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|NonFungibleTracker
        @doc "DPNF custody: staked balance per pool, collection, owner, \
            \ beneficiary, nonce. Per-score contribution and revision live in \
            \ AQP|T|DPNFScoreAttribution (one row per score-id that this stake \
            \ updates, up to 7 per pool)."
        balance:decimal                                         ;;Stores DPNF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpnf-id:string                                          ;;DPNF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    ;;Per pool score-id: one stake may update several of score-primary…septenary;
    ;;each (pool, asset, position, score-id) gets its own cached contribution
    ;;and def-revision cursor (SCR|T|SF|DefRevision / SCR|T|NF|DefRevision).
    (defschema AQP|DPSFScoreAttribution
        @doc "Last committed base score from this DPSF position for one \
            \ pool score-id (same numeric sense as folded into \
            \ SCR|T|UserScore.base-score). Compare applied-def-revision-nonce \
            \ to SCR|T|SF|DefRevision at (score-id, dpsf-id). SFT: sft-equality \
            \ vs nonce table. On refresh/unstake, delta user aggregate using \
            \ cached-position-score vs recomputed value."
        cached-position-score:decimal                           ;;[M] Last applied base score for this score-id
        applied-def-revision-nonce:integer                      ;;Last applied SCR|T|SF|DefRevision revision
        ;;
        ;;Select Keys
        pool-id:string
        dpsf-id:string
        owner-id:string
        beneficiary-id:string
        nonce:integer
        score-id:string
    )
    (defschema AQP|DPNFScoreAttribution
        @doc "Last committed base score from this DPNF position for one \
            \ pool score-id. Compare applied-def-revision-nonce to \
            \ SCR|T|NF|DefRevision.global-revision-nonce at (score-id, dpnf-id). NFT model 1: \
            \ trait or class definition writes bump global (and their branch counter). Model 0 (native): compare \
            \ cached-position-score to live native read when revision unchanged."
        cached-position-score:decimal                           ;;[M] Last applied base score for this score-id
        applied-def-revision-nonce:integer                      ;;Last applied SCR|T|NF|DefRevision.global-revision-nonce
        ;;
        ;;Select Keys
        pool-id:string
        dpnf-id:string
        owner-id:string
        beneficiary-id:string
        nonce:integer
        score-id:string
    )
    ;;
    ;;{2}
    (deftable AQP|T|Pool:{AQP|Schema})                                  ;;Key = <Pool-ID>
    ;;Trackers
    (deftable AQP|T|DPTFTracker:{AQP|TrueFungibleTracker})              ;;Key = <Pool-ID> | <DPTF-ID> | <Owner-ID> | <Beneficiary-ID>
    (deftable AQP|T|DPOFTracker:{AQP|OrtoFungibleTracker})              ;;Key = <Pool-ID> | <DPOF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPSFTracker:{AQP|SemiFungibleTracker})              ;;Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPNFTracker:{AQP|NonFungibleTracker})               ;;Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    ;;Score Attributions
    ;;
    (deftable AQP|T|DPSFScoreAttribution:{AQP|DPSFScoreAttribution})    ;;Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce> | <Score-ID>
    (deftable AQP|T|DPNFScoreAttribution:{AQP|DPNFScoreAttribution})    ;;Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce> | <Score-ID>
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun CT_Bar:string
        ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR))
    )
    (defconst BAR                                               (CT_Bar))
    ;;
    ;;{F0}  [UC]
    (defun UC_DPTFTrackerKey:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|DPTFTracker: pool-id | dptf-id | owner-id | beneficiary-id."
        (concat [pool-id BAR dptf-id BAR owner-id BAR beneficiary-id])
    )
    (defun UC_DPOFTrackerKey:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPOFTracker: pool-id | dpof-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpof-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPSFTrackerKey:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPSFTracker: pool-id | dpsf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPNFTrackerKey:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPNFTracker: pool-id | dpnf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UC_DPSFScoreAttributionKey:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Composite key for AQP|T|DPSFScoreAttribution: pool | dpsf | owner | beneficiary | nonce | score-id."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce]) BAR score-id])
    )
    (defun UC_DPNFScoreAttributionKey:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Composite key for AQP|T|DPNFScoreAttribution: pool | dpnf | owner | beneficiary | nonce | score-id."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce]) BAR score-id])
    )
    ;;
    ;;{F3}  [UDC]
    ;; Default tracker and attribution rows for UR with-default-read.
    (defun UDC_AQP|TrueFungibleTracker:object{AQP|TrueFungibleTracker}
        (bal:decimal pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Default DPTF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dptf-id"          : dptf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id}
    )
    (defun UDC_AQP|OrtoFungibleTracker:object{AQP|OrtoFungibleTracker}
        (bal:decimal pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPOF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpof-id"          : dpof-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|SemiFungibleTracker:object{AQP|SemiFungibleTracker}
        (bal:decimal pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPSF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpsf-id"          : dpsf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|NonFungibleTracker:object{AQP|NonFungibleTracker}
        (bal:decimal pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPNF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpnf-id"          : dpnf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|DPSFScoreAttribution:object{AQP|DPSFScoreAttribution}
        (cached:decimal rev:integer pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Default DPSF score attribution row."
        {"cached-position-score"         : cached
        ,"applied-def-revision-nonce"   : rev
        ,"pool-id"                      : pool-id
        ,"dpsf-id"                      : dpsf-id
        ,"owner-id"                     : owner-id
        ,"beneficiary-id"               : beneficiary-id
        ,"nonce"                        : nonce
        ,"score-id"                     : score-id}
    )
    (defun UDC_AQP|DPNFScoreAttribution:object{AQP|DPNFScoreAttribution}
        (cached:decimal rev:integer pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Default DPNF score attribution row."
        {"cached-position-score"         : cached
        ,"applied-def-revision-nonce"   : rev
        ,"pool-id"                      : pool-id
        ,"dpnf-id"                      : dpnf-id
        ,"owner-id"                     : owner-id
        ,"beneficiary-id"               : beneficiary-id
        ,"nonce"                        : nonce
        ,"score-id"                     : score-id}
    )
    ;;
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (3) OrtoFungibleTracker \
    ;;     (4) SemiFungibleTracker (5) NonFungibleTracker (6) DPSFScoreAttribution (7) DPNFScoreAttribution
    ;;
    ;; [1] AQP|T|Pool  (AQP|Schema)  Key = <Pool-ID>
    (defun UR_AQP|AllPoolIds:[string] ()
        @doc "Returns all row keys from AQP|T|Pool."
        (keys AQP|T|Pool)
    )
    (defun UR_AQP|Pool:object{AQP|Schema} (pool-id:string)
        @doc "Reads full pool definition row from AQP|T|Pool."
        (read AQP|T|Pool pool-id)
    )
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string)
        @doc "Reads aqp-class from pool row."
        (at "aqp-class" (read AQP|T|Pool pool-id ["aqp-class"]))
    )
    (defun UR_AQP|PoolAssetId:string (pool-id:string)
        @doc "Reads canonical asset-id from pool row."
        (at "asset-id" (read AQP|T|Pool pool-id ["asset-id"]))
    )
    (defun UR_AQP|PoolScorePrimary:string (pool-id:string)
        @doc "Reads score-primary slot from pool row."
        (at "score-primary" (read AQP|T|Pool pool-id ["score-primary"]))
    )
    (defun UR_AQP|PoolScoreSecondary:string (pool-id:string)
        @doc "Reads score-secondary slot from pool row."
        (at "score-secondary" (read AQP|T|Pool pool-id ["score-secondary"]))
    )
    (defun UR_AQP|PoolScoreTertiary:string (pool-id:string)
        @doc "Reads score-tertiary slot from pool row."
        (at "score-tertiary" (read AQP|T|Pool pool-id ["score-tertiary"]))
    )
    (defun UR_AQP|PoolScoreQuaternary:string (pool-id:string)
        @doc "Reads score-quaternary slot from pool row."
        (at "score-quaternary" (read AQP|T|Pool pool-id ["score-quaternary"]))
    )
    (defun UR_AQP|PoolScoreQuinary:string (pool-id:string)
        @doc "Reads score-quinary slot from pool row."
        (at "score-quinary" (read AQP|T|Pool pool-id ["score-quinary"]))
    )
    (defun UR_AQP|PoolScoreSenary:string (pool-id:string)
        @doc "Reads score-senary slot from pool row."
        (at "score-senary" (read AQP|T|Pool pool-id ["score-senary"]))
    )
    (defun UR_AQP|PoolScoreSeptenary:string (pool-id:string)
        @doc "Reads score-septenary slot from pool row."
        (at "score-septenary" (read AQP|T|Pool pool-id ["score-septenary"]))
    )
    (defun UR_AQP|PoolAqpId:string (pool-id:string)
        @doc "Reads aqp-id field from pool row."
        (at "aqp-id" (read AQP|T|Pool pool-id ["aqp-id"]))
    )
    ;;
    ;; [2] AQP|T|DPTFTracker  (AQP|TrueFungibleTracker)
    (defun UR_AQP|DPTFTracker:object{AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads DPTF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPTFTracker (UC_DPTFTrackerKey pool-id dptf-id owner-id beneficiary-id)
            (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dptf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid}
            (UDC_AQP|TrueFungibleTracker bal pid did oid bid)
        )
    )
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads staked DPTF balance from tracker row."
        (at "balance" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads pool-id from DPTF tracker row."
        (at "pool-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads dptf-id from DPTF tracker row."
        (at "dptf-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads owner-id from DPTF tracker row."
        (at "owner-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads beneficiary-id from DPTF tracker row."
        (at "beneficiary-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    ;;
    ;; [3] AQP|T|DPOFTracker  (AQP|OrtoFungibleTracker)
    (defun UR_AQP|DPOFTracker:object{AQP|OrtoFungibleTracker}
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPOF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPOFTracker (UC_DPOFTrackerKey pool-id dpof-id owner-id beneficiary-id nonce)
            (UDC_AQP|OrtoFungibleTracker 0.0 pool-id dpof-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpof-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|OrtoFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPOF balance from tracker row."
        (at "balance" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPOF tracker row."
        (at "pool-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpof-id from DPOF tracker row."
        (at "dpof-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPOF tracker row."
        (at "owner-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPOF tracker row."
        (at "beneficiary-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPOF tracker row."
        (at "nonce" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [4] AQP|T|DPSFTracker  (AQP|SemiFungibleTracker)
    (defun UR_AQP|DPSFTracker:object{AQP|SemiFungibleTracker}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPSF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPSFTracker (UC_DPSFTrackerKey pool-id dpsf-id owner-id beneficiary-id nonce)
            (UDC_AQP|SemiFungibleTracker 0.0 pool-id dpsf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpsf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|SemiFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPSF balance from tracker row."
        (at "balance" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPSF tracker row."
        (at "pool-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpsf-id from DPSF tracker row."
        (at "dpsf-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPSF tracker row."
        (at "owner-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPSF tracker row."
        (at "beneficiary-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPSF tracker row."
        (at "nonce" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [5] AQP|T|DPNFTracker  (AQP|NonFungibleTracker)
    (defun UR_AQP|DPNFTracker:object{AQP|NonFungibleTracker}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPNF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPNFTracker (UC_DPNFTrackerKey pool-id dpnf-id owner-id beneficiary-id nonce)
            (UDC_AQP|NonFungibleTracker 0.0 pool-id dpnf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpnf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|NonFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPNF balance from tracker row."
        (at "balance" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPNF tracker row."
        (at "pool-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpnf-id from DPNF tracker row."
        (at "dpnf-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPNF tracker row."
        (at "owner-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPNF tracker row."
        (at "beneficiary-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPNF tracker row."
        (at "nonce" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    ;;
    ;; [6] AQP|T|DPSFScoreAttribution  (AQP|DPSFScoreAttribution)
    (defun UR_AQP|DPSFScoreAttribution:object{AQP|DPSFScoreAttribution}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads DPSF score attribution row; absent rows read as zero cache and revision 0."
        (with-default-read AQP|T|DPSFScoreAttribution
            (UC_DPSFScoreAttributionKey pool-id dpsf-id owner-id beneficiary-id nonce score-id)
            (UDC_AQP|DPSFScoreAttribution 0.0 0 pool-id dpsf-id owner-id beneficiary-id nonce score-id)
            {"cached-position-score"         := cps
            ,"applied-def-revision-nonce"   := arn
            ,"pool-id"                      := pid
            ,"dpsf-id"                      := did
            ,"owner-id"                     := oid
            ,"beneficiary-id"               := bid
            ,"nonce"                        := n
            ,"score-id"                     := sid}
            (UDC_AQP|DPSFScoreAttribution cps arn pid did oid bid n sid)
        )
    )
    (defun UR_AQP|DPSFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads cached-position-score from DPSF score attribution row."
        (at "cached-position-score" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads applied-def-revision-nonce from DPSF score attribution row."
        (at "applied-def-revision-nonce" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionPoolId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads pool-id from DPSF score attribution row."
        (at "pool-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionDpsfId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads dpsf-id from DPSF score attribution row."
        (at "dpsf-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionOwnerId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads owner-id from DPSF score attribution row."
        (at "owner-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionBeneficiaryId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads beneficiary-id from DPSF score attribution row."
        (at "beneficiary-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionNonce:integer
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads nonce from DPSF score attribution row."
        (at "nonce" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPSFScoreAttributionScoreId:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads score-id from DPSF score attribution row."
        (at "score-id" (UR_AQP|DPSFScoreAttribution pool-id dpsf-id owner-id beneficiary-id nonce score-id))
    )
    ;;
    ;; [7] AQP|T|DPNFScoreAttribution  (AQP|DPNFScoreAttribution)
    (defun UR_AQP|DPNFScoreAttribution:object{AQP|DPNFScoreAttribution}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads DPNF score attribution row; absent rows read as zero cache and revision 0."
        (with-default-read AQP|T|DPNFScoreAttribution
            (UC_DPNFScoreAttributionKey pool-id dpnf-id owner-id beneficiary-id nonce score-id)
            (UDC_AQP|DPNFScoreAttribution 0.0 0 pool-id dpnf-id owner-id beneficiary-id nonce score-id)
            {"cached-position-score"         := cps
            ,"applied-def-revision-nonce"   := arn
            ,"pool-id"                      := pid
            ,"dpnf-id"                      := did
            ,"owner-id"                     := oid
            ,"beneficiary-id"               := bid
            ,"nonce"                        := n
            ,"score-id"                     := sid}
            (UDC_AQP|DPNFScoreAttribution cps arn pid did oid bid n sid)
        )
    )
    (defun UR_AQP|DPNFScoreAttributionCachedPositionScore:decimal
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads cached-position-score from DPNF score attribution row."
        (at "cached-position-score" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionAppliedDefRevisionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads applied-def-revision-nonce from DPNF score attribution row."
        (at "applied-def-revision-nonce" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionPoolId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads pool-id from DPNF score attribution row."
        (at "pool-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionDpnfId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads dpnf-id from DPNF score attribution row."
        (at "dpnf-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionOwnerId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads owner-id from DPNF score attribution row."
        (at "owner-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionBeneficiaryId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads beneficiary-id from DPNF score attribution row."
        (at "beneficiary-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionNonce:integer
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads nonce from DPNF score attribution row."
        (at "nonce" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    (defun UR_AQP|DPNFScoreAttributionScoreId:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer score-id:string)
        @doc "Reads score-id from DPNF score attribution row."
        (at "score-id" (UR_AQP|DPNFScoreAttribution pool-id dpnf-id owner-id beneficiary-id nonce score-id))
    )
    ;;
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Lifecycle (AQP|T|Pool / AQP|Schema)
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Create a new pool with aqp-class and asset-id; single asset type per pool (classes 0–4)."
        true
    )
    ;;Score slots (score-primary … score-septenary); score-class must match pool aqp-class.
    (defun C_AddScore:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Assign a score-id to a free pool score slot; invokes SCORE XE_CreateAqpoolLink when wiring is enforced."
        true
    )
    (defun C_RevokeScore:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Clear a score slot on the pool and revoke aqpool-link on that score via SCORE XE_RevokeAqpoolLink."
        true
    )
    ;;Staking (trackers + downstream score / ANK / FVT updates)
    (defun C_Stake:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Stake into the pool; write DPSF/DPNF tracker; for each pool \
            \ score slot that this stake updates, write DPSF/DPNF \
            \ ScoreAttribution (cached-position-score, applied revision)."
        true
    )
    (defun C_Unstake:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Unstake from the pool; unwind tracker row and reconcile user scores and anchors."
        true
    )
    ;;
    ;;ACTIONS
    ;;
    ;;1]INJECT Rewards (can inject only when <total-score> != 0.0)
    ;;  1a] Update <current-rps> = (+ <current-rps> (/ <reward-amount> <total-score>))
    ;;  1b] Update <available-rewards> = (+ <available-rewards> <reward-amount>)
    ;;  1c] Update <unclaimed-count> = <nzs-count>
    ;;
    ;;2]STAKE
    ;;  2a] Check if <deb-score> is different from the stored <deb-score>; if it is different use the newly computed <deb-score> for 2b]
    ;;  2b] Update <pending-rewards> = <pending-rewards> + (* <deb-score> (- <current-rps> <last-rps>))     
    ;;      Use the stored <deb-score> is if the same as the newly computed <deb-score>; No score updates yet
    ;;  2c] Update <total-base-score>/<total-deb-score> and <base-score>/<deb-score> considering the newly staked assets.
    ;;  2d] If prev <deb-score> was 0, increment <nzs-count>; 
    ;;      Increment <unclaimed-count> for first-stakers (prev <deb-score> was 0)
    ;;  2e] Update <last-rps> to the Pools <current-rps>
    ;;
    ;;3]UNSTAKE
    ;;  3a] Check if <deb-score> is different from the stored <deb-score>; if it is different use the newly computed <deb-score> for 3b]
    ;;  3b] Update <pending-rewards> = <pending-rewards> + (* <deb-score> (- <current-rps> <last-rps>))
    ;;      Use the stored <deb-score> is if the same as the newly computed <deb-score>; No score updates yet.
    ;;  3c] Update <total-base-score>/<total-deb-score> and <base-score>/<deb-score> considering the newly staked assets.
    ;;  3d] If <deb-score> becomes 0, decrement <nzs-count>
    ;;  3e] Update <last-rps> to the Pools <current-rps>
    ;;
    ;;4]COLLECT
    ;;  4a] Check if <deb-score> is different from the stored <deb-score>; if it is different use the newly computed <deb-score> for 4c]
    ;;  4b] Update <available-rewards> = <available-rewards> - <collected-rewards>
    ;;  4c] Computes Current Reward = <pending-reward> + (* <deb-score> (- <current-rps> <last-rps>))
    ;;      If <unclaimed-count> = 1 (is last user with non zero rewards) , then Current-Reward is the min between computed and exiting (for dust sweaping)
    ;;  4d] Updates the <pending-reward> to either 0.0 (in case all is collected) or to the remaining amount. (difference between computed and collected)
    ;;  4e] If all Computed Reward is collected, and the <pending-reward> becomes 0, decrement <unclaimed-count>
    ;;  4f] Update <last-rps> to the Pools <current-rps>
    ;;
    ;;{F7}  [X]
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table AQP|T|Pool)
(create-table AQP|T|DPTFTracker)
(create-table AQP|T|DPOFTracker)
(create-table AQP|T|DPSFTracker)
(create-table AQP|T|DPNFTracker)
(create-table AQP|T|DPSFScoreAttribution)
(create-table AQP|T|DPNFScoreAttribution)