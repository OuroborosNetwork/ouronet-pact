(interface AcquisitionScoresV1
    ;;  [UC]
    (defun UC_UserScoreKey:string (ouronet-account:string pool-id:string score-id:string))
    (defun UC_SFScoreKey:string (score-id:string dpsf-id:string nonce:integer))
    (defun UC_NFScoreKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string dpnf-nonce-class:integer))
    (defun UC_SFDefRevisionKey:string (score-id:string dpsf-id:string))
    (defun UC_NFDefRevisionKey:string (score-id:string dpnf-id:string))
    ;;
    ;;  [UR]
    (defun UR_SCR|AllScoreIds:[string] ())
    (defun UR_SCR|ScoreOwnerKonto:string (score-id:string))
    (defun UR_SCR|ScoreCanUpgrade:bool (score-id:string))
    (defun UR_SCR|ScoreCanChangeOwner:bool (score-id:string))
    (defun UR_SCR|ScoreBoostClassLink:string (score-id:string))
    (defun UR_SCR|ScoreBoostLink:string (score-id:string))
    (defun UR_SCR|ScoreAqpoolLink:string (score-id:string))
    (defun UR_SCR|ScoreFvtLink:string (score-id:string))
    (defun UR_SCR|ScoreDebBoost:bool (score-id:string))
    (defun UR_SCR|ScorePrecision:integer (score-id:string))
    (defun UR_SCR|ScoreTotalBaseScore:decimal (score-id:string))
    (defun UR_SCR|ScoreTotalBoostedScore:decimal (score-id:string))
    (defun UR_SCR|ScoreTotalDebScore:decimal (score-id:string))
    (defun UR_SCR|ScoreNzsCount:integer (score-id:string))
    (defun UR_SCR|ScoreClass:integer (score-id:string))
    (defun UR_SCR|ScoreLpDenominator:string (score-id:string))
    (defun UR_SCR|ScoreMxFrozen:decimal (score-id:string))
    (defun UR_SCR|ScoreMxSleeping:decimal (score-id:string))
    (defun UR_SCR|ScoreMxHibernated:decimal (score-id:string))
    (defun UR_SCR|ScoreSftEquality:bool (score-id:string))
    (defun UR_SCR|ScoreNftScoreModel:integer (score-id:string))
    (defun UR_SCR|ScoreScoreId:string (score-id:string))
    (defun UR_U-SCR|UserScoreBaseScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreBoostedScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreDebScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreOuronetAccount:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScorePoolId:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreScoreId:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_S-DEF|SFScoreNonceScoreValue:decimal (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreScoreId:string (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreDpsfId:string (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreNonce:integer (score-id:string dpsf-id:string nonce:integer))
    (defun UR_N-DEF|NFTraitScoreTraitScoreValue:decimal (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFTraitScoreScoreId:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFTraitScoreDpnfId:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFTraitScoreTraitKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFTraitScoreTraitValue:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFClassScoreTraitScoreValue:decimal (score-id:string dpnf-id:string dpnf-nonce-class:integer))
    (defun UR_N-DEF|NFClassScoreScoreId:string (score-id:string dpnf-id:string dpnf-nonce-class:integer))
    (defun UR_N-DEF|NFClassScoreDpnfId:string (score-id:string dpnf-id:string dpnf-nonce-class:integer))
    (defun UR_N-DEF|NFClassScoreNonceClass:integer (score-id:string dpnf-id:string dpnf-nonce-class:integer))
    (defun UR_S-DEF-REV|SFDefRevisionRevisionNonce:integer (score-id:string dpsf-id:string))
    (defun UR_S-DEF-REV|SFDefRevisionScoreId:string (score-id:string dpsf-id:string))
    (defun UR_S-DEF-REV|SFDefRevisionDpsfId:string (score-id:string dpsf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce:integer (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce:integer (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionClassRevisionNonce:integer (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionScoreId:string (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionDpnfId:string (score-id:string dpnf-id:string))
    ;;
    ;;  [UEV]
    (defun UEV_IMC ())
    (defun UEV_NonFungibleScoreDefinition
        (score-id:string dpnf-id:string trait-score-values:[decimal] trait-keys:[string] trait-values:[string] dpnf-nonce-classes:[integer])
    )
    ;;
    ;;  [C]
    (defun C_IssueLiquidityScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
    )
    (defun C_IssueTrueFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
    )
    (defun C_IssueOrtoFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
    )
    (defun C_IssueSemiFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
    )
    (defun C_IssueNonFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
    )
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator} (score-id:string new-owner-konto:string))
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator} (score-id:string new-can-upgrade:bool new-can-change-owner:bool))
    (defun C_CreateBoostClassLink:object{IgnisCollectorV1.OutputCumulator} (score-id:string boost-class-id:string))
    (defun C_CreateBoostLink:object{IgnisCollectorV1.OutputCumulator} (score-id:string boost-score-id:string))
    (defun C_EnableDebBoost:object{IgnisCollectorV1.OutputCumulator} (score-id:string))
    (defun C_IssueSemiFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun C_IssueNonFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    (defun C_IssueNonFungibleSetScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
    )
    ;;
    ;;  [XE]  cross-module forward (FVT::C_TrueFungibleStakeFlow, AQP-POOL C_AddScore/C_RevokeScore)
    (defun XE_CreateAqpoolLink:string
        (score-id:string pool-id:string)
    )
    (defun XE_RevokeAqpoolLink:string
        (score-id:string pool-id:string)
    )
    (defun XE_CreateFvtLink:string
        (score-id:string fvt-id:string)
    )
    (defun XE_ApplyTrueFungibleStakeDelta:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool employed-ids:[string] native-leg:bool)
    )
)
(module AQP-SCORE GOV
    @doc "AQP-SCORE — sovereign acquisition scoring for AQP pools. Owns global score configuration and totals (SCR|T|Score), per (ouronet-account, pool-id, score-id) user triples (SCR|T|UserScore), semi-fungible nonce weights (SCR|T|SF|Score) and SF DefRevision, and non-fungible definitions on SCR|T|NF|TraitScore vs SCR|T|NF|ClassScore with NF DefRevision split into global-, trait-, and class-revision nonces so trackers and URCX stake math can gate expensive selects. \
        \ Public surface: AcquisitionScoresV1 reads and stake-weight URC_*; Talos-facing C_* builds IGNIS (and STOA where applicable) and acquires client caps; XI_* performs table writes under require-capability (SECURE / SCR|XI>*); XE_* is for forward modules and likewise does not enforce — the guarding defcap or C_* owns validation and enforce. URCX_* helpers exist only as operands inside URC_* stake deltas. \
        \ Implements OuronetPolicyV1 and AcquisitionScoresV1."
    ;; REPL: REPL/Stage_02/[6.2.2]_AQP-SCORE.repl — intra-tx groups TX-SCORE-nn · mm in ;;==== … ==== lines (mm = 01.. within each begin-tx).
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionScoresV1)
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP-SCORE              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|AQP-SCORE_ADMIN)))
    (defcap GOV|AQP-SCORE_ADMIN ()          (enforce-guard GOV|MD_AQP-SCORE))
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
    (defcap P|AQP-SCORE|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|AQP-SCORE|CALLER))
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
        (with-capability (GOV|AQP-SCORE_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|AQP-SCORE_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
                    ;;
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
        @doc "Post-deploy hook (AQP-BOOT Step 0). No cross-module IMP registration required — \
            \ SCORE calls DALOS UR_*/CAP_*/UEV_* only (no DALOS UEV_IMC on those paths); client entry is Talos P|TALOS-SUMMONER."
        true
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
    (defschema SCR|Schema
        @doc "General Score Definition \
            \ [.]   = fixed, cannot be changed \
            \ [..]  = Once linked, cannot be changed \
            \ [.t]  = Once set to true, cannot be changed \
            \ [M]   = mutable, can be modified  <owner-konto> \
            \ [Mu]  = mutable via upgrade, can be modified via \
            \        <owner-konto> and true <can-upgrade> \
            \ \
            \ Identity: No separate scr-asset on the score. Staking asset is \
            \ defined on the AQP pool. Resolve Score -> aqpool-link -> Pool \
            \ -> asset-id. FVT must only add ScoreLink when aqpool-link is \
            \ set, so membership checks (e.g. farm common-denominator vs LP \
            \ construction) use that chain. \
            \ \
            \ Class-0 LP: One score employed per pool aggregates all stake \
            \ that pool allows. Multiple token ids (e.g. native LP, sleeping \
            \ OF, frozen TF) may stake into the same pool when the protocol \
            \ verifies they are the same LP family; trackers distinguish ids, \
            \ but SCR|T|UserScore rows are per pool-id x score-id for \
            \ beneficiaries. \
            \ \
            \ Immutability vs users: Per-user weights in SCR|T|UserScore are \
            \ advanced on Stake/Unstake (and FVT Inject/Collect handle \
            \ rewards), matching the UrStoa vault pattern; there is no \
            \ practical global recomputation over all accounts. Do not change \
            \ [.] semantic fields (score-class, multipliers, sft/nft models), \
            \ links [..], or deb-boost [.t] after positions \
            \ exist; that would leave existing rows wrong until users \
            \ restake. Correct mistakes by issuing a new score-id, removing \
            \ the old score from pool slots and FVT membership, then wiring \
            \ the new score. \
            \ \
            \ [M] totals on this row are aggregate bookkeeping; they do not \
            \ replace the rule that meaning-of-weight is fixed by [.] fields \
            \ at issue."
        ;;
        ;;Management
        owner-konto:string          ;;[Mu]  Stores the Score Owner.
        can-upgrade:bool            ;;[Mu]  Defines if Score Settings can be upgraded
        can-change-owner:bool       ;;[Mu]  Defines if the Owner can be changed
        ;;
        ;; Links
        boost-class-link:string     ;;[..]  Specifies the BoostClass-ID for boosting. BAR if not in use.
        ;; Foreign boost-link: promile uses linked score user base; UserScore boosted/deb may hold surplus only (README_SCORE.md). Never self: SCR|C>CREATE-BOOST-LINK-SCORE.
        boost-link:string           ;;[..]  BAR = own base for promile; else other score-id (≠ this score-id per SCR|C>CREATE-BOOST-LINK-SCORE).
        aqpool-link:string          ;;[..]  Specifies the Pool that employs the Score. BAR if not in use.
        fvt-link:string             ;;[..]  Specifies the FVT the Score is part of. BAR if not in use.
        ;;Score Information
        deb-boost:bool              ;;[.t]  Specifies if DEB boosting occurs.
        precision:integer           ;;[.]   Decimal places for per-user weights and aggregate total-* fields on this score; range enforced at issuance; forward writers must respect it.
        total-base-score:decimal    ;;[M]   Sum of user base-scores; same decimal precision as precision field
        total-boosted-score:decimal ;;[M]   Sum of user boosted-scores; same decimal precision as precision field
        total-deb-score:decimal     ;;[M]   Sum of user deb-scores; same decimal precision as precision field
        nzs-count:integer           ;;[M]   Store the amount of Non-Zero-Scores
        ;;
        ;;Score Class
        score-class:integer         ;;[.]   Defines the Score Class, there are 5
        ;;                                  Class 0 = LP Score (LP - native|sleeping|freezing)
        ;;                                  Class 1 = DPTF Score (non LP) 
        ;;                                  Class 2 = DPOF Score (non LP)
        ;;                                  Class 3 = DPSF Score (SFTs)
        ;;                                  Class 4 = DPNF Score (NFTs)
        ;;
        ;;LP, DPTF, DPOF
        lp-denominator:string       ;;[.]   Class-0 only: native DPTF token-id of the common pool leg (e.g. OURO-98c486052a51); BAR for classes 1-4.
        mx-frozen:decimal           ;;[.]   Multiplier for Frozen Tokens (Default 2.0)
        mx-sleeping:decimal         ;;[.]   Multiplier for Sleeping Tokens (Default 1.0)
        mx-hibernated:decimal       ;;[.]   Multiplier for Hibernated Tokens (Default 1.0)
        ;;
        ;;DPSF
        sft-equality:bool           ;;[.]   When true all SFTs are equal. When <false>, <nonce-score-value> is checked.
        ;;
        ;;DPNF
        nft-score-model:integer     ;;[.]   Sets NFT Score Model; Only 3 Models Allowed [-1 0 1]
        ;;                                  Model -1 = All NFTs are equal, and will have a score of 1
        ;;                                  Model  0 = NFTs will be scored by their native Score Systems
        ;;                                  Model  1 = NFTs scored from SCR|T|NF|TraitScore / SCR|T|NF|ClassScore rows
        ;;
        ;;Select Keys
        score-id:string             ;;[.]   Stores the ID of the Score
    )
    (defschema SCR|UserSchema
        @doc "Per account x pool x score. base-score, boosted-score, \
            \ deb-score are updated on Stake/Unstake (and related paths), \
            \ not by bulk recompute when SCR|Schema rules change; migrate \
            \ via a new score-id."
        base-score:decimal
        boosted-score:decimal
        deb-score:decimal
        ;;
        ;;Select Keys
        ouronet-account:string
        pool-id:string
        score-id:string
    )
    (defschema SCR|SingularUserScoreDelta
        @doc "Result of applying one signed user-base delta at score precision: new user triple, nz-count delta, and deltas to SCR|T|Score aggregate totals \
            \ (LP stake legs are one consumer; other forward paths can reuse the same derivation object). Aggregate totals are floored at the score precision field in XI."
        new-user-base-score:decimal
        new-user-boosted-score:decimal
        new-user-deb-score:decimal
        nz-delta:integer
        delta-global-base-score:decimal
        delta-global-boosted-score:decimal
        delta-global-deb-score:decimal
    )
    ;;
    (defschema SCR|SF|Schema
        @doc "Per (score-id, dpsf-id, nonce). Changing nonce-score-value \
            \ changes weights for that nonce going forward; wholesale rule \
            \ changes still favor a new score-id if fairness requires it."
        nonce-score-value:decimal   ;;[M]   Score Value of DPSF Nonce
        ;;
        ;;Select Keys
        score-id:string
        dpsf-id:string
        nonce:integer
    )
    (defschema SCR|NF|TraitSchema
        @doc "Per (score-id, dpnf-id, trait-key, trait-value). trait-score-value is mutable."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        trait-key:string
        trait-value:string
    )
    (defschema SCR|NF|ClassSchema
        @doc "Per (score-id, dpnf-id, dpnf-nonce-class). trait-score-value is mutable (set-mode class weights)."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        dpnf-nonce-class:integer    ;;[.]   0 = all native NFTs in class model; >0 = specific set class (AQP-ANK DPNF anchors)
    )
    ;;
    ;;Monotonic revision per (score-id, DPDC collection): bump only when a
    ;;row in SCR|T|SF|Score or SCR|T|NF|TraitScore / SCR|T|NF|ClassScore changes for that pair. AQP
    ;;trackers compare applied-def-revision-nonce to SCR|T|SF|DefRevision.revision-nonce /
    ;;SCR|T|NF|DefRevision.global-revision-nonce at (employed-score-id, dpsf-id|dpnf-id).
    (defschema SCR|SF|DefRevision
        @doc "Per (score-id, dpsf-id). revision-nonce bumps on any add or \
            \ update in SCR|T|SF|Score for that score-id and dpsf-id."
        revision-nonce:integer      ;;[M]   Bump on SCR|T|SF|Score change
        ;;
        ;;Select Keys
        score-id:string
        dpsf-id:string
    )
    (defschema SCR|NF|DefRevision
        @doc "Per (score-id, dpnf-id). global-revision-nonce bumps on any trait or class definition change; \
            \ trait-revision-nonce only on SCR|T|NF|TraitScore change; class-revision-nonce only on SCR|T|NF|ClassScore change."
        global-revision-nonce:integer   ;;[M]
        trait-revision-nonce:integer    ;;[M]
        class-revision-nonce:integer     ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
    )
    ;;
    ;;{2}
    ;;Score ID
    ;;1]Global and 2]Individual
    (deftable SCR|T|Score:{SCR|Schema})                         ;;Key = <Score-ID>
    (deftable SCR|T|UserScore:{SCR|UserSchema})                 ;;Key = <Ouronet-Account> | <Pool-ID> | <Score-ID>
    ;;
    ;;Score Definitions for SFT and NFT
    (deftable SCR|T|SF|Score:{SCR|SF|Schema})                   ;;Key = <Score-ID> | <DPSF-ID> | <Nonce>
    ;;Split NF definitions: trait-mode and nonce-class-mode use separate tables.
    (deftable SCR|T|NF|TraitScore:{SCR|NF|TraitSchema})         ;;Key = <Score-ID> | <DPNF-ID> | <Trait-Key> | <Trait-Value>
    (deftable SCR|T|NF|ClassScore:{SCR|NF|ClassSchema})          ;;Key = <Score-ID> | <DPNF-ID> | <DPNF-Nonce-Class>
    ;;
    (deftable SCR|T|SF|DefRevision:{SCR|SF|DefRevision})        ;;Key = <Score-ID> | <DPSF-ID>
    (deftable SCR|T|NF|DefRevision:{SCR|NF|DefRevision})        ;;Key = <Score-ID> | <DPNF-ID>
    ;;{3}
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR))
    )
    (defconst BAR                                               (CT_Bar))
    (defconst GAS|ISSUE-SCORE                                   1000.0)
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defconst EOC                                               (CT_EmptyCumulator))
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let ((ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)) (ref-ANK::GOV|AQP|SC_NAME))
    )
    (defconst AQP|SC_NAME                                       (CT_AqpScName))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    (defcap SCR|XI>ISSUE-SCORE
        (
            score-name:string
            owner-konto:string
            precision:integer
            score-class:integer
            lp-denominator:string
            mx-frozen:decimal
            mx-sleeping:decimal
            mx-hibernated:decimal
            nft-score-model:integer
        )
        @doc "Core issuance authorisation for SCR|T|Score: validates score-name, owner, class, lp-denominator, multipliers, \
            \ nft-score-model. sft-equality is not a cap parameter (boolean; applied at insert only). score-id \
            \ from score-name (UDC_Makeid); can-upgrade and can-change-owner default true at insert. Composed from \
            \ each SCR|C>ISSUE-* client capability."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
            )
            ;;1]Validate <score-name>
            (ref-U|ATS::UEV_AutostakeIndex score-name)
            ;;2]Validate <owner-konto> Ownership and that is Standard Ouronet Account
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DALOS::UEV_EnforceAccountType owner-konto false)
            ;;2b]Validate <mx-frozen>, <mx-sleeping>, <mx-hibernated> as fee decimals (DALOS UEV_Fee)
            (ref-U|DALOS::UEV_Fee mx-frozen)
            (ref-U|DALOS::UEV_Fee mx-sleeping)
            (ref-U|DALOS::UEV_Fee mx-hibernated)
            ;;3]Validate <score-class>, <mx-frozen>, <mx-sleeping>, <mx-hibernated> and <nft-score-model>
            (enforce
                (fold (and) true
                    [
                        (>= score-class 0)
                        (<= score-class 4)
                        (>= precision 3)
                        (<= precision 24)
                        (> mx-frozen 0.0)
                        (> mx-sleeping 0.0)
                        (> mx-hibernated 0.0)
                        (fold (or) false [(= nft-score-model -1) (= nft-score-model 0) (= nft-score-model 1)])
                    ]
                )
                "Invalid precision, score-class, mx-frozen, mx-sleeping, mx-hibernated or nft-score-model"
            )
            ;;4]Validate <lp-denominator>: class 0 requires non-BAR native DPTF id; classes 1-4 require BAR
            (enforce
                (if (= score-class 0)
                    (!= lp-denominator BAR)
                    (= lp-denominator BAR)
                )
                "lp-denominator must be non-BAR for class 0 and BAR for classes 1-4"
            )
            (if (= score-class 0)
                (let ((ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF))
                    (ref-DPTF::UEV_id lp-denominator)
                )
                true
            )
        )
    )
    ;;{C3}
    ;;{C4}  Client score issuance — evented caps distinguish score-class path; each composes SCR|XI>ISSUE-SCORE.
    (defcap SCR|C>ISSUE-LIQUIDITY-SCORE
        (owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issue LP score (score-class 0). Caller supplies lp-denominator, mx-frozen and mx-sleeping; mx-hibernated 1.0, sft-equality true, nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 0 lp-denominator mx-frozen mx-sleeping 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issue DPTF score (score-class 1). Caller supplies mx-frozen; mx-sleeping and mx-hibernated 1.0; sft-equality true; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 1 BAR mx-frozen 1.0 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issue DPOF score (score-class 2), including special-token variants. Caller supplies mx-sleeping and mx-hibernated; \
            \ mx-frozen defaults 2.0; sft-equality true; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 2 BAR 2.0 mx-sleeping mx-hibernated -1)
        )
    )
    (defcap SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Issue DPSF score (score-class 3). Caller supplies sft-equality; multipliers default 2.0 / 1.0 / 1.0; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 3 BAR 2.0 1.0 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-NON-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issue DPNF score (score-class 4). Caller supplies nft-score-model; multipliers default 2.0 / 1.0 / 1.0; sft-equality true."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 4 BAR 2.0 1.0 1.0 nft-score-model)
        )
    )
    (defcap SCR|C>ROTATE-OWNERSHIP-SCORE (score-id:string new-owner-konto:string)
        @doc "Rotate SCR|T|Score owner-konto: current-owner ownership, can-change-owner true, new owner standard account, \
            \ new ≠ current. Composes SECURE for XI write; C_RotateOwnership builds IGNIS cumulator."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-now:string (UR_SCR|ScoreOwnerKonto score-id))
                (can-change-owner:bool (UR_SCR|ScoreCanChangeOwner score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-now)
            (ref-DALOS::UEV_EnforceAccountType new-owner-konto false)
            (enforce
                (and can-change-owner (!= new-owner-konto owner-now))
                "Score owner rotation requires can-change-owner true and a distinct new owner-konto"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>CONTROL-SCORE (score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Update can-upgrade and can-change-owner: owner-konto ownership and current can-upgrade true. Composes SECURE for XI write; C_Control builds IGNIS cumulator."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (can-upgrade:bool (UR_SCR|ScoreCanUpgrade score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce can-upgrade "Score control requires can-upgrade true")
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>ENABLE-DEB-BOOST-SCORE (score-id:string)
        @doc "One-time deb-boost: score owner, deb-boost currently false. Composes SECURE for XI write; C_EnableDebBoost builds IGNIS cumulator."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (deb-boost:bool (UR_SCR|ScoreDebBoost score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce (not deb-boost) "DEB boost is already enabled and cannot be disabled")
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>ISSUE-SF-SCORE-DEFINITION
        (score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Write SCR|T|SF|Score definitions for multiple nonces. Enforces score ownership, score exists, \
            \ sft-equality false, nonce/value list shape, nonce existence (including fragmented negative nonces), \
            \ and value precision from score precision. Composes SECURE for XI writes."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (ref-DPDC-F:module{DpdcFragmentsV1} DPDC-F)
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (score-row-id:string (UR_SCR|ScoreScoreId score-id))
                (sft-equality:bool (UR_SCR|ScoreSftEquality score-id))
                (precision:integer (UR_SCR|ScorePrecision score-id))
                (l1:integer (length nonces))
                (l2:integer (length nonce-score-values))
                (max-input-nonce:integer (if (> l1 0) (ref-U|INT::UC_MaxInteger nonces) 0))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed dpsf-id true))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (fold (and) true
                    [
                        (= score-row-id score-id)
                        (not sft-equality)
                        (> l1 0)
                        (= l1 l2)
                        (<= max-input-nonce nonces-used)
                    ]
                )
                "Invalid score/dpsf inputs: score must exist, sft-equality false, nonce/value lists aligned, and max nonce <= DPDC nonces-used"
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (abs-nonce:integer (abs nonce))
                            (nonce-score-value:decimal (at idx nonce-score-values))
                        )
                        (ref-DPDC::UEV_Nonce dpsf-id true abs-nonce)
                        (if (< nonce 0)
                            (ref-DPDC-F::UEV_IzNonceFragmented dpsf-id true abs-nonce)
                            true
                        )
                        (enforce
                            (= (floor nonce-score-value precision) nonce-score-value)
                            (format
                                "Nonce score value {} does not match score precision {}"
                                [nonce-score-value precision]
                            )
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>ISSUE-NF-SCORE-DEFINITION
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Trait-mode NF score definitions: delegates validation to UEV_NonFungibleScoreDefinition (empty dpnf-nonce-classes); \
            \ composes SCR|XI>X_ISSUE-NF-SCORE-DEFINITION."
        @event
        (UEV_NonFungibleScoreDefinition score-id dpnf-id trait-score-values trait-keys trait-values [])
        (compose-capability (SCR|XI>X_ISSUE-NF-SCORE-DEFINITION score-id dpnf-id))
    )
    (defcap SCR|C>ISSUE-NF-SET-SCORE-DEFINITION
        (score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Set-mode NF score definitions: delegates validation to UEV_NonFungibleScoreDefinition (empty trait keys/values); \
            \ composes SCR|XI>X_ISSUE-NF-SCORE-DEFINITION."
        @event
        (UEV_NonFungibleScoreDefinition score-id dpnf-id class-score-values [] [] dpnf-nonce-classes)
        (compose-capability (SCR|XI>X_ISSUE-NF-SCORE-DEFINITION score-id dpnf-id))
    )
    (defcap SCR|XI>X_ISSUE-NF-SCORE-DEFINITION
        (score-id:string dpnf-id:string)
        @doc "Common checks for NF score definition issuance: score owner, dpnf exists, score row id match, \
            \ score-class 4 (DPNF). Composes SECURE for XI writes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (score-row-id:string (UR_SCR|ScoreScoreId score-id))
                (score-class:integer (UR_SCR|ScoreClass score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DPDC::UEV_id dpnf-id false)
            (enforce
                (and (= score-row-id score-id) (= score-class 4))
                "Invalid score/dpnf: score must exist as DPNF (class 4) with matching score-id"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>CREATE-BOOST-CLASS-LINK-SCORE (score-id:string boost-class-id:string)
        @doc "One-time boost-class-link on SCR|T|Score: slot BAR, score owner, boost-class-id not BAR, BoostClass exists and active in AQP-ANK. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (current-link:string (UR_SCR|ScoreBoostClassLink score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (and (= current-link BAR) (!= boost-class-id BAR))
                "Boost-class-link slot must be unset and boost-class-id must be non-BAR"
            )
            (enforce (ref-ANK::UR_BC|Active boost-class-id) "BoostClass must be active")
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>CREATE-BOOST-LINK-SCORE (score-id:string boost-score-id:string)
        @doc "One-time boost-link: slot BAR, score owner, boost score exists, boost ≠ self, boost-id non-BAR. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (boost-link:string (UR_SCR|ScoreBoostLink score-id))
                (boost-row-sid:string (UR_SCR|ScoreScoreId boost-score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (fold (and) true
                    [
                        (= boost-link BAR)
                        (!= boost-score-id BAR)
                        (!= boost-score-id score-id)
                        (= boost-row-sid boost-score-id)
                    ]
                )
                "SCR|C>CREATE-BOOST-LINK-SCORE: boost-link slot must be BAR; boost-score-id must exist, be non-BAR, and must not equal this score-id (no self-link)"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|XE>CREATE-AQPOOL-LINK (score-id:string pool-id:string)
        @doc "One-time aqpool-link: slot BAR, score owner, pool-id non-BAR. Pool/score pairing rules live in forward modules (e.g. AQP)."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (aqpool-link:string (UR_SCR|ScoreAqpoolLink score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (and (= aqpool-link BAR) (!= pool-id BAR))
                "Aqpool link slot must be unset and pool-id must be non-BAR"
            )
        )
    )
    (defcap SCR|XE>REVOKE-AQPOOL-LINK (score-id:string pool-id:string)
        @doc "Clear aqpool-link: slot must equal pool-id, score owner. Pool revoke guards live in forward modules (e.g. AQP)."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (aqpool-link:string (UR_SCR|ScoreAqpoolLink score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (and (= aqpool-link pool-id) (!= pool-id BAR))
                "Aqpool link must match pool-id and pool-id must be non-BAR"
            )
        )
    )
    (defcap SCR|XE>CREATE-FVT-LINK (score-id:string fvt-id:string)
        @doc "One-time fvt-link: slot BAR, score owner, fvt-id non-BAR. FVT membership rules live in forward modules (e.g. FVT)."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (fvt-link:string (UR_SCR|ScoreFvtLink score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (and (= fvt-link BAR) (!= fvt-id BAR))
                "FVT link slot must be unset and fvt-id must be non-BAR"
            )
        )
    )
    (defcap SCR|XE>UPDATE-LP-STAKE-DPTF-LP
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            lp-id:string
            lp-amount:decimal
            native-or-frozen:bool
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-0 LP stake/unstake via DPTF LP (native or frozen). Validates account, pool–score link, SWP pair vs lp-denominator, amount precision."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (UEV_LpStakeScoreContext ouronet-account pool-id score-id lp-id)
            (ref-DPTF::UEV_id lp-id)
            (ref-DPTF::UEV_Amount lp-id lp-amount)
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-LP-STAKE-ORTO-LP
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            lp-id:string
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-0 LP stake/unstake via sleeping orto (DPSF) LP. Validates account, pool–score link, pair vs denominator, nonce lists and DPDC nonces."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length nonce-amounts))
            )
            (UEV_LpStakeScoreContext ouronet-account pool-id score-id lp-id)
            (enforce
                (fold (and) true
                    [
                        (= l1 l2)
                        (> l1 0)
                    ]
                )
                "orto LP stake score update: nonces and nonce-amounts must have equal positive length"
            )
            (ref-DPDC::UEV_id lp-id true)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (n:integer (at idx nonces))
                            (q:decimal (at idx nonce-amounts))
                        )
                        (ref-DPDC::UEV_Nonce lp-id true n)
                        (enforce (> q 0.0) "orto LP nonce amount must be positive")
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-STAKE-DPTF
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dptf-id:string
            dptf-amount:decimal
            native-or-frozen:bool
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-1 DPTF stake/unstake (non-LP). Validates account, pool–score link, score-class 1, DPTF id + amount. \
            \ native-or-frozen selects multiplier 1.0 vs score mx-frozen (same convention as LP DPTF leg). \
            \ Alignment of dptf-id with the pool's canonical asset-id is enforced by the composing AQP-POOL path before this cap is installed."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (UEV_DptfStakeScoreContext ouronet-account pool-id score-id)
            (ref-DPTF::UEV_id dptf-id)
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-STAKE-DPOF
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-2 DPOF stake/unstake (native circulating nonces). Sum of nonce amounts × 1.0 at score precision; pool asset vs dpof-id enforced upstream."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length nonce-amounts))
            )
            (UEV_DpofStakeScoreContext ouronet-account pool-id score-id)
            (enforce
                (fold (and) true [(= l1 l2) (> l1 0)])
                "DPOF stake score update: nonces and nonce-amounts must have equal positive length"
            )
            (ref-DPOF::UEV_id dpof-id)
            (ref-DPOF::UEV_NoncesCirculating dpof-id nonces)
            (ref-DPOF::UEV_NoncesToAccount dpof-id ouronet-account nonces)
            (map
                (lambda (idx:integer)
                    (ref-DPOF::UEV_Amount dpof-id (at idx nonce-amounts))
                )
                (enumerate 0 (- l1 1))
            )
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-STAKE-DPOF-SPECIAL
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            sleeping-or-hibernating:bool
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-2 special DPOF (sleeping vs hibernating multiplier on summed nonce amounts). sleeping-or-hibernating true → mx-sleeping; false → mx-hibernated."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length nonce-amounts))
            )
            (UEV_DpofStakeScoreContext ouronet-account pool-id score-id)
            (enforce
                (fold (and) true [(= l1 l2) (> l1 0)])
                "special DPOF stake score update: nonces and nonce-amounts must have equal positive length"
            )
            (ref-DPOF::UEV_id dpof-id)
            (ref-DPOF::UEV_NoncesCirculating dpof-id nonces)
            (ref-DPOF::UEV_NoncesToAccount dpof-id ouronet-account nonces)
            (map
                (lambda (idx:integer)
                    (ref-DPOF::UEV_Amount dpof-id (at idx nonce-amounts))
                )
                (enumerate 0 (- l1 1))
            )
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-STAKE-DPSF
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpsf-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-3 DPSF stake/unstake. Validates account, pool–score link, score-class 3, DPDC id + nonces (sleeping collection leg: second arg true to UEV_id / UEV_Nonce)."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length nonce-amounts))
            )
            (UEV_DpsfStakeScoreContext ouronet-account pool-id score-id)
            (enforce
                (fold (and) true [(= l1 l2) (> l1 0)])
                "DPSF stake score update: nonces and nonce-amounts must have equal positive length"
            )
            (ref-DPDC::UEV_id dpsf-id true)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (n:integer (at idx nonces))
                            (q:integer (at idx nonce-amounts))
                        )
                        (ref-DPDC::UEV_Nonce dpsf-id true n)
                        (enforce (> q 0) "DPSF stake nonce amount must be positive")
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
        (compose-capability (SECURE))
    )
    (defcap SCR|XE>UPDATE-STAKE-DPNF
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpnf-id:string
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward (AQP-POOL): class-4 DPNF stake/unstake (native collection). Validates account, pool–score link, score-class 4, DPDC nonces."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length nonce-amounts))
            )
            (UEV_DpnfStakeScoreContext ouronet-account pool-id score-id)
            (enforce
                (fold (and) true [(= l1 l2) (> l1 0)])
                "DPNF stake score update: nonces and nonce-amounts must have equal positive length"
            )
            (ref-DPDC::UEV_id dpnf-id false)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (n:integer (at idx nonces))
                            (q:integer (at idx nonce-amounts))
                        )
                        (ref-DPDC::UEV_Nonce dpnf-id false n)
                        (enforce (> q 0) "DPNF stake nonce amount must be positive")
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
        (compose-capability (SECURE))
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]
    (defun UC_UserScoreKey:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Composite key for SCR|T|UserScore: account | pool | score."
        (concat [ouronet-account BAR pool-id BAR score-id])
    )
    (defun UC_SFScoreKey:string (score-id:string dpsf-id:string nonce:integer)
        @doc "Composite key for SCR|T|SF|Score: score-id | dpsf-id | nonce."
        (concat [score-id BAR dpsf-id BAR (format "{}" [nonce])])
    )
    (defun UC_NFScoreKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string dpnf-nonce-class:integer)
        @doc "Legacy composite NF key: score-id | dpnf-id | trait-key | trait-value | dpnf-nonce-class (kept for interface compatibility)."
        (concat [score-id BAR dpnf-id BAR trait-key BAR trait-value BAR (format "{}" [dpnf-nonce-class])])
    )
    (defun UC_NFTraitScoreKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Composite key for SCR|T|NF|TraitScore: score-id | dpnf-id | trait-key | trait-value."
        (concat [score-id BAR dpnf-id BAR trait-key BAR trait-value])
    )
    (defun UC_NFClassScoreKey:string (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Composite key for SCR|T|NF|ClassScore: score-id | dpnf-id | dpnf-nonce-class."
        (concat [score-id BAR dpnf-id BAR (format "{}" [dpnf-nonce-class])])
    )
    (defun UC_SFDefRevisionKey:string (score-id:string dpsf-id:string)
        @doc "Composite key for SCR|T|SF|DefRevision: score-id | dpsf-id."
        (concat [score-id BAR dpsf-id])
    )
    (defun UC_NFDefRevisionKey:string (score-id:string dpnf-id:string)
        @doc "Composite key for SCR|T|NF|DefRevision: score-id | dpnf-id."
        (concat [score-id BAR dpnf-id])
    )
    ;;
    ;; Early UDC: SCR|UserSchema constructor is required before UR_U-SCR|UserScore (with-default-read default object).
    (defun UDC_SCR|UserSchema:object{SCR|UserSchema}
        (a:decimal b:decimal c:decimal d:string e:string f:string)
        @doc "Core constructor for object{SCR|UserSchema}."
        {"base-score"       : a
        ,"boosted-score"    : b
        ,"deb-score"        : c
        ,"ouronet-account"  : d
        ,"pool-id"          : e
        ,"score-id"         : f}
    )
    (defun UDC_SCR|SingularUserScoreDelta:object{SCR|SingularUserScoreDelta}
        (
            new-user-base-score:decimal
            new-user-boosted-score:decimal
            new-user-deb-score:decimal
            nz-delta:integer
            delta-global-base-score:decimal
            delta-global-boosted-score:decimal
            delta-global-deb-score:decimal
        )
        @doc "Constructor for URC_SingularUserScoreDeltaFromSignedUserBase result (named user + aggregate deltas)."
        {"new-user-base-score"          : new-user-base-score
        ,"new-user-boosted-score"       : new-user-boosted-score
        ,"new-user-deb-score"           : new-user-deb-score
        ,"nz-delta"                     : nz-delta
        ,"delta-global-base-score"      : delta-global-base-score
        ,"delta-global-boosted-score"   : delta-global-boosted-score
        ,"delta-global-deb-score"       : delta-global-deb-score}
    )
    ;;
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) SCR|Schema (2) SCR|UserSchema (3) SCR|SF|Schema (4) SCR|NF|TraitSchema (5) SCR|NF|ClassSchema (6) SF DefRevision (7) NF DefRevision
    ;;
    ;; [1] SCR|T|Score  (SCR|Schema)  Key = <Score-ID>
    (defun UR_SCR|AllScoreIds:[string] ()
        @doc "Returns all row keys from SCR|T|Score."
        (keys SCR|T|Score)
    )
    (defun UR_SCR|Score:object{SCR|Schema} (score-id:string)
        @doc "Reads full score definition row from SCR|T|Score."
        (read SCR|T|Score score-id)
    )
    (defun UR_SCR|ScoreOwnerKonto:string (score-id:string)
        @doc "Reads owner-konto from score row."
        (at "owner-konto" (read SCR|T|Score score-id ["owner-konto"]))
    )
    (defun UR_SCR|ScoreCanUpgrade:bool (score-id:string)
        @doc "Reads can-upgrade from score row."
        (at "can-upgrade" (read SCR|T|Score score-id ["can-upgrade"]))
    )
    (defun UR_SCR|ScoreCanChangeOwner:bool (score-id:string)
        @doc "Reads can-change-owner from score row."
        (at "can-change-owner" (read SCR|T|Score score-id ["can-change-owner"]))
    )
    (defun UR_SCR|ScoreBoostClassLink:string (score-id:string)
        @doc "Reads boost-class-link from score row."
        (at "boost-class-link" (read SCR|T|Score score-id ["boost-class-link"]))
    )
    (defun UR_SCR|ScoreBoostLink:string (score-id:string)
        @doc "Reads boost-link from score row."
        (at "boost-link" (read SCR|T|Score score-id ["boost-link"]))
    )
    (defun UR_SCR|ScoreAqpoolLink:string (score-id:string)
        @doc "Reads aqpool-link from score row."
        (at "aqpool-link" (read SCR|T|Score score-id ["aqpool-link"]))
    )
    (defun UR_SCR|ScoreFvtLink:string (score-id:string)
        @doc "Reads fvt-link from score row."
        (at "fvt-link" (read SCR|T|Score score-id ["fvt-link"]))
    )
    (defun UR_SCR|ScoreDebBoost:bool (score-id:string)
        @doc "Reads deb-boost from score row."
        (at "deb-boost" (read SCR|T|Score score-id ["deb-boost"]))
    )
    (defun UR_SCR|ScorePrecision:integer (score-id:string)
        @doc "Reads precision (decimal places for user score weights) from score row."
        (at "precision" (read SCR|T|Score score-id ["precision"]))
    )
    (defun UR_SCR|ScoreTotalBaseScore:decimal (score-id:string)
        @doc "Reads total-base-score from score row."
        (at "total-base-score" (read SCR|T|Score score-id ["total-base-score"]))
    )
    (defun UR_SCR|ScoreTotalBoostedScore:decimal (score-id:string)
        @doc "Reads total-boosted-score from score row."
        (at "total-boosted-score" (read SCR|T|Score score-id ["total-boosted-score"]))
    )
    (defun UR_SCR|ScoreTotalDebScore:decimal (score-id:string)
        @doc "Reads total-deb-score from score row."
        (at "total-deb-score" (read SCR|T|Score score-id ["total-deb-score"]))
    )
    (defun UR_SCR|ScoreNzsCount:integer (score-id:string)
        @doc "Reads nzs-count from score row."
        (at "nzs-count" (read SCR|T|Score score-id ["nzs-count"]))
    )
    (defun UR_SCR|ScoreClass:integer (score-id:string)
        @doc "Reads score-class from score row."
        (at "score-class" (read SCR|T|Score score-id ["score-class"]))
    )
    (defun UR_SCR|ScoreLpDenominator:string (score-id:string)
        @doc "Reads lp-denominator from score row."
        (at "lp-denominator" (read SCR|T|Score score-id ["lp-denominator"]))
    )
    (defun UR_SCR|ScoreMxFrozen:decimal (score-id:string)
        @doc "Reads mx-frozen multiplier from score row."
        (at "mx-frozen" (read SCR|T|Score score-id ["mx-frozen"]))
    )
    (defun UR_SCR|ScoreMxSleeping:decimal (score-id:string)
        @doc "Reads mx-sleeping multiplier from score row."
        (at "mx-sleeping" (read SCR|T|Score score-id ["mx-sleeping"]))
    )
    (defun UR_SCR|ScoreMxHibernated:decimal (score-id:string)
        @doc "Reads mx-hibernated multiplier from score row."
        (at "mx-hibernated" (read SCR|T|Score score-id ["mx-hibernated"]))
    )
    (defun UR_SCR|ScoreSftEquality:bool (score-id:string)
        @doc "Reads sft-equality from score row."
        (at "sft-equality" (read SCR|T|Score score-id ["sft-equality"]))
    )
    (defun UR_SCR|ScoreNftScoreModel:integer (score-id:string)
        @doc "Reads nft-score-model from score row."
        (at "nft-score-model" (read SCR|T|Score score-id ["nft-score-model"]))
    )
    (defun UR_SCR|ScoreScoreId:string (score-id:string)
        @doc "Reads score-id field from score row (row key should match)."
        (at "score-id" (read SCR|T|Score score-id ["score-id"]))
    )
    ;;
    ;; [2] SCR|T|UserScore  (SCR|UserSchema)  Key = <Ouronet-Account> | <Pool-ID> | <Score-ID>
    (defun UR_U-SCR|UserScore:object{SCR|UserSchema} (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads full user score row from SCR|T|UserScore; absent rows read as zero weights via UDC default."
        (with-default-read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id)
            (UDC_SCR|UserSchema 0.0 0.0 0.0 ouronet-account pool-id score-id)
            {"base-score"        := b
            ,"boosted-score"    := bb
            ,"deb-score"        := d
            ,"ouronet-account"  := oa
            ,"pool-id"          := pid
            ,"score-id"         := sid}
            (UDC_SCR|UserSchema b bb d oa pid sid)
        )
    )
    (defun UR_U-SCR|UserScoreBaseScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads base-score from user score row."
        (at "base-score" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScoreBoostedScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads boosted-score from user score row."
        (at "boosted-score" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScoreDebScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads deb-score from user score row."
        (at "deb-score" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScoreOuronetAccount:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads ouronet-account from user score row."
        (at "ouronet-account" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScorePoolId:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads pool-id from user score row."
        (at "pool-id" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScoreScoreId:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads score-id from user score row."
        (at "score-id" (UR_U-SCR|UserScore ouronet-account pool-id score-id))
    )
    ;;
    ;; [3] SCR|T|SF|Score  (SCR|SF|Schema)  Key = <Score-ID> | <DPSF-ID> | <Nonce>
    (defun UR_S-DEF|SFScore:object{SCR|SF|Schema} (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads full DPSF nonce score definition row."
        (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce))
    )
    (defun UR_S-DEF|SFScoreNonceScoreValue:decimal (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads nonce-score-value from SF score row; returns 0.0 when the row is absent."
        (with-default-read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce)
            (UDC_SCR|SF|Schema 0.0 score-id dpsf-id nonce)
            {"nonce-score-value" := nonce-score-value}
            nonce-score-value
        )
    )
    (defun UR_S-DEF|SFScoreScoreId:string (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads score-id from SF score row."
        (at "score-id" (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce) ["score-id"]))
    )
    (defun UR_S-DEF|SFScoreDpsfId:string (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads dpsf-id from SF score row."
        (at "dpsf-id" (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce) ["dpsf-id"]))
    )
    (defun UR_S-DEF|SFScoreNonce:integer (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads nonce key field from SF score row."
        (at "nonce" (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce) ["nonce"]))
    )
    ;;
    ;; [4] SCR|T|NF|TraitScore  (SCR|NF|TraitSchema)
    (defun UR_N-DEF|NFTraitScore:object{SCR|NF|TraitSchema} (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads full trait-mode NF score definition row."
        (read SCR|T|NF|TraitScore (UC_NFTraitScoreKey score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFTraitScoreTraitScoreValue:decimal (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-score-value from SCR|T|NF|TraitScore row."
        (at "trait-score-value" (UR_N-DEF|NFTraitScore score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFTraitScoreScoreId:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads score-id from SCR|T|NF|TraitScore row."
        (at "score-id" (UR_N-DEF|NFTraitScore score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFTraitScoreDpnfId:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads dpnf-id from SCR|T|NF|TraitScore row."
        (at "dpnf-id" (UR_N-DEF|NFTraitScore score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFTraitScoreTraitKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-key from SCR|T|NF|TraitScore row."
        (at "trait-key" (UR_N-DEF|NFTraitScore score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFTraitScoreTraitValue:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-value from SCR|T|NF|TraitScore row."
        (at "trait-value" (UR_N-DEF|NFTraitScore score-id dpnf-id trait-key trait-value))
    )
    ;;
    ;; [5] SCR|T|NF|ClassScore  (SCR|NF|ClassSchema)
    (defun UR_N-DEF|NFClassScore:object{SCR|NF|ClassSchema} (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Reads full class-mode NF score definition row."
        (read SCR|T|NF|ClassScore (UC_NFClassScoreKey score-id dpnf-id dpnf-nonce-class))
    )
    (defun UR_N-DEF|NFClassScoreTraitScoreValue:decimal (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Reads trait-score-value (class weight) from SCR|T|NF|ClassScore row."
        (at "trait-score-value" (UR_N-DEF|NFClassScore score-id dpnf-id dpnf-nonce-class))
    )
    (defun UR_N-DEF|NFClassScoreScoreId:string (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Reads score-id from SCR|T|NF|ClassScore row."
        (at "score-id" (UR_N-DEF|NFClassScore score-id dpnf-id dpnf-nonce-class))
    )
    (defun UR_N-DEF|NFClassScoreDpnfId:string (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Reads dpnf-id from SCR|T|NF|ClassScore row."
        (at "dpnf-id" (UR_N-DEF|NFClassScore score-id dpnf-id dpnf-nonce-class))
    )
    (defun UR_N-DEF|NFClassScoreNonceClass:integer (score-id:string dpnf-id:string dpnf-nonce-class:integer)
        @doc "Reads dpnf-nonce-class from SCR|T|NF|ClassScore row."
        (at "dpnf-nonce-class" (UR_N-DEF|NFClassScore score-id dpnf-id dpnf-nonce-class))
    )
    ;;
    ;; [6] SCR|T|SF|DefRevision  (SCR|SF|DefRevision)  Key = <Score-ID> | <DPSF-ID>
    (defun UR_S-DEF-REV|SFDefRevision:object{SCR|SF|DefRevision} (score-id:string dpsf-id:string)
        @doc "Reads SF definition revision row for (score-id, dpsf-id)."
        (read SCR|T|SF|DefRevision (UC_SFDefRevisionKey score-id dpsf-id))
    )
    (defun UR_S-DEF-REV|SFDefRevisionRevisionNonce:integer (score-id:string dpsf-id:string)
        @doc "Reads revision-nonce from SF def-revision row; returns 0 when row is absent."
        (with-default-read SCR|T|SF|DefRevision (UC_SFDefRevisionKey score-id dpsf-id)
            (UDC_SCR|SF|DefRevision 0 score-id dpsf-id)
            {"revision-nonce" := revision-nonce}
            revision-nonce
        )
    )
    (defun UR_S-DEF-REV|SFDefRevisionScoreId:string (score-id:string dpsf-id:string)
        @doc "Reads score-id from SF def-revision row."
        (at "score-id" (read SCR|T|SF|DefRevision (UC_SFDefRevisionKey score-id dpsf-id) ["score-id"]))
    )
    (defun UR_S-DEF-REV|SFDefRevisionDpsfId:string (score-id:string dpsf-id:string)
        @doc "Reads dpsf-id from SF def-revision row."
        (at "dpsf-id" (read SCR|T|SF|DefRevision (UC_SFDefRevisionKey score-id dpsf-id) ["dpsf-id"]))
    )
    ;;
    ;; [7] SCR|T|NF|DefRevision  (SCR|NF|DefRevision)  Key = <Score-ID> | <DPNF-ID>
    (defun UR_N-DEF-REV|NFDefRevision:object{SCR|NF|DefRevision} (score-id:string dpnf-id:string)
        @doc "Reads NF definition revision row for (score-id, dpnf-id)."
        (read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id))
    )
    (defun UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce:integer (score-id:string dpnf-id:string)
        @doc "Reads global-revision-nonce; returns 0 when row is absent."
        (with-default-read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id)
            (UDC_SCR|NF|DefRevision 0 0 0 score-id dpnf-id)
            {"global-revision-nonce" := global-revision-nonce}
            global-revision-nonce
        )
    )
    (defun UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce:integer (score-id:string dpnf-id:string)
        @doc "Reads trait-revision-nonce; returns 0 when row is absent."
        (with-default-read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id)
            (UDC_SCR|NF|DefRevision 0 0 0 score-id dpnf-id)
            {"trait-revision-nonce" := trait-revision-nonce}
            trait-revision-nonce
        )
    )
    (defun UR_N-DEF-REV|NFDefRevisionClassRevisionNonce:integer (score-id:string dpnf-id:string)
        @doc "Reads class-revision-nonce; returns 0 when row is absent."
        (with-default-read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id)
            (UDC_SCR|NF|DefRevision 0 0 0 score-id dpnf-id)
            {"class-revision-nonce" := class-revision-nonce}
            class-revision-nonce
        )
    )
    (defun UR_N-DEF-REV|NFDefRevisionScoreId:string (score-id:string dpnf-id:string)
        @doc "Reads score-id from NF def-revision row."
        (at "score-id" (read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id) ["score-id"]))
    )
    (defun UR_N-DEF-REV|NFDefRevisionDpnfId:string (score-id:string dpnf-id:string)
        @doc "Reads dpnf-id from NF def-revision row."
        (at "dpnf-id" (read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id) ["dpnf-id"]))
    )
    ;;
    ;;{F1}  [URD]
    (defun URD_NF|TraitRows:[object] (score-id:string dpnf-id:string)
        @doc "Expensive read: selects all trait definition rows for (score-id, dpnf-id)."
        (select SCR|T|NF|TraitScore ["trait-key" "trait-value" "trait-score-value"]
            (and?
                (where "score-id" (= score-id))
                (where "dpnf-id" (= dpnf-id))
            )
        )
    )
    (defun URD_NF|ClassRows:[object] (score-id:string dpnf-id:string)
        @doc "Expensive read: selects all class definition rows for (score-id, dpnf-id)."
        (select SCR|T|NF|ClassScore ["dpnf-nonce-class" "trait-score-value"]
            (and?
                (where "score-id" (= score-id))
                (where "dpnf-id" (= dpnf-id))
            )
        )
    )
    (defun URD_S-DEF|SFScoreRows:[object] (score-id:string dpsf-id:string)
        @doc "Expensive read: selects nonce + nonce-score-value for every SF definition row at (score-id, dpsf-id)."
        (select SCR|T|SF|Score ["nonce" "nonce-score-value"]
            (and?
                (where "score-id" (= score-id))
                (where "dpsf-id" (= dpsf-id))
            )
        )
    )
    ;;{F1}  [URCX]  Auxiliary raw-weight helpers used only from parent URC_* stake deltas.
    (defun URCX_StakeEqualNativeUnitRawWeight:decimal (nonces:[integer] nonce-amounts:[integer])
        @doc "Shared SFT equal-weight (sft-equality true) and NFT model -1: sum_i amount_i × (1.0 if nonce_i ≥ 0 else 0.001)."
        (let
            (
                (l1:integer (length nonces))
            )
            (fold
                (lambda (acc:decimal idx:integer)
                    (+ acc
                        (*
                            (dec (at idx nonce-amounts))
                            (if (< (at idx nonces) 0)
                                0.001
                                1.0
                            )
                        )
                    )
                )
                0.0
                (enumerate 0 (- l1 1))
            )
        )
    )
    (defun URCX_SfStakeDefinitionWeightedRawWeight:decimal
        (score-id:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "SFT non-equal mode: revision-nonce 0 ⇒ 0; else one URD select, parallel def-nonces and def-values, weighted sum with native/fragment scale."
        (let
            (
                (rev:integer (UR_S-DEF-REV|SFDefRevisionRevisionNonce score-id dpsf-id))
            )
            (if (= rev 0)
                0.0
                (let
                    (
                        (def-rows:[object] (URD_S-DEF|SFScoreRows score-id dpsf-id))
                        (paired:object
                            (fold
                                (lambda (acc:object r:object)
                                    {"def-nonces": (+ (at "def-nonces" acc) [(at "nonce" r)])
                                    ,"def-values": (+ (at "def-values" acc) [(at "nonce-score-value" r)])}
                                )
                                {"def-nonces": [], "def-values": []}
                                def-rows
                            )
                        )
                        (def-nonces:[integer] (at "def-nonces" paired))
                        (def-values:[decimal] (at "def-values" paired))
                        (l1:integer (length nonces))
                    )
                    (fold
                        (lambda (acc:decimal idx:integer)
                            (let
                                (
                                    (nonce:integer (at idx nonces))
                                    (nonce-amount:integer (at idx nonce-amounts))
                                )
                                (+ acc
                                    (*
                                        (dec nonce-amount)
                                        (*
                                            (URCXX_SFScoreForNonceFromDefLists nonce def-nonces def-values)
                                            (if (< nonce 0)
                                                0.001
                                                1.0
                                            )
                                        )
                                    )
                                )
                            )
                        )
                        0.0
                        (enumerate 0 (- l1 1))
                    )
                )
            )
        )
    )
    (defun URCXX_SFScoreForNonceFromDefLists:decimal
        (nonce:integer def-nonces:[integer] def-values:[decimal])
        @doc "If nonce is not in def-nonces returns 0.0; else first index from U|LST::UC_Search on def-nonces, then def-values at that position. Lists are built in lockstep from URD_S-DEF|SFScoreRows."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (if (contains nonce def-nonces)
                (at (at 0 (ref-U|LST::UC_Search def-nonces nonce)) def-values)
                0.0
            )
        )
    )
    (defun URCX_DpnfModelZeroDpdcNativeRawWeight:decimal
        (dpnf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "NFT score model 0 only: sum_i amount_i × UR_N|RawScore(UR_NonceData(dpnf-id, false, nonce_i)) from DPDC."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length nonces))
            )
            (fold
                (lambda (acc:decimal idx:integer)
                    (let
                        (
                            (n:integer (at idx nonces))
                            (q:integer (at idx nonce-amounts))
                            (unit-score:decimal (ref-DPDC::UR_N|RawScore (ref-DPDC::UR_NonceData dpnf-id false n)))
                        )
                        (+ acc (* (dec q) unit-score))
                    )
                )
                0.0
                (enumerate 0 (- l1 1))
            )
        )
    )
    (defun URCX_DpnfModelOneScrDefinitionRawWeight:decimal
        (score-id:string dpnf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "NFT model 1: global-revision-nonce 0 ⇒ 0. Else step class-revision-nonce: if 0 class leg is 0.0 and no URD; if non-zero URD_NF|ClassRows then class scores from that list. \
            \ Then step trait-revision-nonce: if 0 trait leg is 0.0 and no URD; if non-zero URD_NF|TraitRows then trait scores from that list. \
            \ Per-nonce base = class-part + trait-part, then fragment scale on negative nonces."
        (let
            (
                (g:integer (UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce score-id dpnf-id))
            )
            (if (= g 0)
                0.0
                (let
                    (
                        (ref-DPDC:module{DpdcV1} DPDC)
                        ;;
                        (class-rev:integer (UR_N-DEF-REV|NFDefRevisionClassRevisionNonce score-id dpnf-id))
                        (class-rows:[object]
                            (if (= class-rev 0)
                                []
                                (URD_NF|ClassRows score-id dpnf-id)
                            )
                        )
                    )
                    (let
                        (
                            (trait-rev:integer (UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce score-id dpnf-id))
                            (trait-rows:[object]
                                (if (= trait-rev 0)
                                    []
                                    (URD_NF|TraitRows score-id dpnf-id)
                                )
                            )
                        )
                        (fold
                            (lambda (acc:decimal idx:integer)
                                (let
                                    (
                                        (n:integer (at idx nonces))
                                        (q:integer (at idx nonce-amounts))
                                        (class-nonce:integer (if (< n 0) (abs n) n))
                                        (nonce-class:integer (ref-DPDC::UR_NonceClass dpnf-id false class-nonce))
                                        (class-part:decimal (URC_NFClassScoreFromRows class-rows nonce-class))
                                        (trait-part:decimal
                                            (URC_NFTraitScoreFromRows trait-rows
                                                (ref-DPDC::UR_N|RawMetaData (ref-DPDC::UR_NonceData dpnf-id false n))
                                            )
                                        )
                                        (base-score:decimal (+ class-part trait-part))
                                        (unit-score:decimal
                                            (if (< n 0)
                                                (/ base-score 1000.0)
                                                base-score
                                            )
                                        )
                                    )
                                    (+ acc (* (dec q) unit-score))
                                )
                            )
                            0.0
                            (enumerate 0 (- (length nonces) 1))
                        )
                    )
                )
            )
        )
    )
    ;;{F1}  [URC]
    (defun URC_LpAmountToLpDenominatorEquivalent:decimal
        (lp-id:string lp-amount:decimal lp-denominator:string)
        @doc "Class-0: maps staked LP amount into lp-denominator token units (e.g. OURO). \
            \ Pro-rata break via SWPL against current SWP reserves for the pair behind native lp-id; \
            \ F|/Z| stripped by URC_StakeLpTokenToNativeLpDptf. Pair must list lp-denominator (UEV_LpStakeScoreContext)."
        (if (= lp-amount 0.0)
            0.0
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                    ;;
                    (native-lp:string (URC_StakeLpTokenToNativeLpDptf lp-id))
                    (swpair:string (ref-SWP::UR_GetLpSwpair native-lp))
                    (denom-pos:integer (ref-SWP::UR_PoolTokenPosition swpair lp-denominator))
                    (break-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                )
                (at denom-pos break-amounts)
            )
        )
    )
    (defun URC_StakeLpTokenToNativeLpDptf:string (lp-id:string)
        @doc "SWP|LP rows use native LP DPTF ids. Strip leading F| (frozen LP) or Z| (sleeping orto LP); S|, W|, P| native LP prefixes pass through unchanged."
        (let 
            (
                (p2:string (take 2 lp-id))
            )
            (if (fold (or) false [(= p2 "F|") (= p2 "Z|")])
                (drop 2 lp-id)
                lp-id
            )
        )
    )
    (defun URC_SignedBaseDeltaForDptfLpStake:decimal
        (score-id:string lp-id:string lp-amount:decimal native-or-frozen:bool direction:bool)
        @doc "Signed base delta (score precision) for one DPTF LP stake leg; shared by LP-stake cap and XE forwarder."
        (let
            (
                (lp-denom:string (UR_SCR|ScoreLpDenominator score-id))
                (equiv:decimal (URC_LpAmountToLpDenominatorEquivalent lp-id lp-amount lp-denom))
                (mxlp:decimal (if native-or-frozen 1.0 (UR_SCR|ScoreMxFrozen score-id)))
                (raw-weight:decimal (* equiv mxlp))
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForOrtoLpStake:decimal
        (score-id:string lp-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Signed user-base delta for one sleeping-orto LP leg (denom-equiv × mx-sleeping, score precision); nonce-amounts are decimals summed for weight."
        (let
            (
                (sum-amounts:decimal
                    (fold
                        (lambda (acc:decimal q:decimal) (+ acc q))
                        0.0
                        nonce-amounts
                    )
                )
                (lp-denom:string (UR_SCR|ScoreLpDenominator score-id))
                (equiv:decimal (URC_LpAmountToLpDenominatorEquivalent lp-id sum-amounts lp-denom))
                (mxlp:decimal (UR_SCR|ScoreMxSleeping score-id))
                (raw-weight:decimal (* equiv mxlp))
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForDptfStake:decimal
        (score-id:string dptf-id:string dptf-amount:decimal native-or-frozen:bool direction:bool)
        @doc "Signed base delta (score precision) for one class-1 DPTF stake leg; same mx rule as URC_SignedBaseDeltaForDptfLpStake (native vs frozen). \
            \ Shared by SCR|XE>UPDATE-STAKE-DPTF and XI_1|UpdateScoreDataForTrueFungible."
        (let
            (
                (mx:decimal (if native-or-frozen 1.0 (UR_SCR|ScoreMxFrozen score-id)))
                (raw-weight:decimal (* dptf-amount mx))
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForDpofStake:decimal
        (score-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Signed base delta for class-2 native DPOF leg: sum(nonce-amounts) × 1.0 at score precision. Shared by SCR|XE>UPDATE-STAKE-DPOF."
        (let
            (
                (sum-amounts:decimal
                    (fold
                        (lambda (acc:decimal q:decimal) (+ acc q))
                        0.0
                        nonce-amounts
                    )
                )
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* sum-amounts (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForSpecialDpofStake:decimal
        (
            score-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            sleeping-or-hibernating:bool
            direction:bool
        )
        @doc "Signed base delta for class-2 special DPOF: sum(nonce-amounts) × mx-sleeping when sleeping-or-hibernating is true, else × mx-hibernated."
        (let
            (
                (sum-amounts:decimal
                    (fold
                        (lambda (acc:decimal q:decimal) (+ acc q))
                        0.0
                        nonce-amounts
                    )
                )
                (mx:decimal
                    (if sleeping-or-hibernating
                        (UR_SCR|ScoreMxSleeping score-id)
                        (UR_SCR|ScoreMxHibernated score-id)
                    )
                )
                (raw-weight:decimal (* sum-amounts mx))
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForDpsfStake:decimal
        (score-id:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Signed base delta for class-3 DPSF (score precision): sft-equality true uses URCX_StakeEqualNativeUnitRawWeight; \
            \ false uses URCX_SfStakeDefinitionWeightedRawWeight (revision 0 ⇒ 0; else URD + parallel def lists, missing nonce ⇒ 0 score)."
        (let
            (
                (sft-equality:bool (UR_SCR|ScoreSftEquality score-id))
                (raw-weight:decimal
                    (if sft-equality
                        (URCX_StakeEqualNativeUnitRawWeight nonces nonce-amounts)
                        (URCX_SfStakeDefinitionWeightedRawWeight score-id dpsf-id nonces nonce-amounts)
                    )
                )
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_SignedBaseDeltaForDpnfStake:decimal
        (score-id:string dpnf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Signed base delta for class-4 DPNF (score precision): model -1 uses URCX_StakeEqualNativeUnitRawWeight; \
            \ model 0 uses URCX_DpnfModelZeroDpdcNativeRawWeight; model 1 uses URCX_DpnfModelOneScrDefinitionRawWeight."
        (let
            (
                (model:integer (UR_SCR|ScoreNftScoreModel score-id))
                (raw-weight:decimal
                    (if (= model -1)
                        (URCX_StakeEqualNativeUnitRawWeight nonces nonce-amounts)
                        (if (= model 0)
                            (URCX_DpnfModelZeroDpdcNativeRawWeight dpnf-id nonces nonce-amounts)
                            (URCX_DpnfModelOneScrDefinitionRawWeight score-id dpnf-id nonces nonce-amounts)
                        )
                    )
                )
                (p:integer (UR_SCR|ScorePrecision score-id))
            )
            (floor (* raw-weight (if direction 1.0 -1.0)) p)
        )
    )
    (defun URC_NFClassScoreFromRows:decimal (rows:[object] nonce-class:integer)
        @doc "Returns class score for nonce-class from selected class rows; 0.0 when no matching class definition exists."
        (fold
            (lambda
                (acc:decimal row)
                (if (= (at "dpnf-nonce-class" row) nonce-class)
                    (+ acc (at "trait-score-value" row))
                    acc
                )
            )
            0.0
            rows
        )
    )
    (defun URC_NFTraitScoreFromRows:decimal (rows:[object] nonce-meta:object)
        @doc "Returns sum of trait definition scores that match nonce metadata."
        (fold
            (lambda
                (acc:decimal row)
                (let
                    (
                        (k:string (at "trait-key" row))
                        (v:string (at "trait-value" row))
                        (s:decimal (at "trait-score-value" row))
                    )
                    (if (and (contains k nonce-meta) (= (at k nonce-meta) v))
                        (+ acc s)
                        acc
                    )
                )
            )
            0.0
            rows
        )
    )
    (defun URC_SingularUserScoreDeltaFromSignedUserBase:object{SCR|SingularUserScoreDelta}
        (ouronet-account:string pool-id:string score-id:string signed-user-base-delta:decimal)
        @doc "Core singular user-score step: from one signed user-base delta already at score precision (e.g. LP weight × mx after URC_SignedBaseDeltaForDptfLpStake / URC_SignedBaseDeltaForOrtoLpStake / URC_SignedBaseDeltaForDptfStake / DPOF|DPSF|DPNF stake URC_*), \
            \ compute new user base/boosted/deb, nz-delta, and global deltas. When boost-link ≠ BAR and boost-class-link ≠ BAR (foreign anchor + ANK promile), \
            \ user base-score is always 0: the foreign row owns canonical base; promile input is foreign user base + this signed delta; boosted/deb store surplus \
            \ over foreign base only (README_SCORE.md). Otherwise user base is ob + signed. deb-boost applies to nominal boosted before foreign subtraction."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-U|DEC:module{OuronetDecimalsV1} U|DEC)
                ;;
                (scr:object{SCR|Schema} (UR_SCR|Score score-id))
                (p:integer (at "precision" scr))
                (bcl:string (at "boost-class-link" scr))
                (bl:string (at "boost-link" scr))
                (db-boost:bool (at "deb-boost" scr))
                ;;
                (old-u:object{SCR|UserSchema} (UR_U-SCR|UserScore ouronet-account pool-id score-id))
                (ob:decimal (at "base-score" old-u))
                (obb:decimal (at "boosted-score" old-u))
                (od:decimal (at "deb-score" old-u))
                ;;
                (local-base-raw:decimal (floor (+ ob signed-user-base-delta) p))
                (foreign-boost-base:bool 
                    ;; boost-link ≠ self: enforced at SCR|C>CREATE-BOOST-LINK-SCORE (boost-score-id must differ from score-id).
                    (!= bl BAR)
                )
                (foreign-base-ref:decimal
                    (if foreign-boost-base
                        (UR_U-SCR|UserScoreBaseScore ouronet-account pool-id bl)
                        0.0
                    )
                )
                (apply-foreign-boost-surplus:bool (and foreign-boost-base (!= bcl BAR)))
                (new-user-base-score:decimal
                    (if apply-foreign-boost-surplus
                        0.0
                        local-base-raw
                    )
                )
                (prom:decimal
                    (if (= bcl BAR)
                        0.0
                        (ref-ANK::UR_UB|AggregatePromile ouronet-account bcl)
                    )
                )
                (base-for-boost:decimal
                    (if (= bl BAR)
                        local-base-raw
                        (if (= bcl BAR)
                            local-base-raw
                            (floor (+ foreign-base-ref signed-user-base-delta) p)
                        )
                    )
                )
                (nominal-boosted-score:decimal
                    (if (= bcl BAR)
                        local-base-raw
                        (floor (* base-for-boost (/ prom 1000.0)) p)
                    )
                )
                (nominal-deb-score:decimal
                    (if db-boost
                        (floor (* nominal-boosted-score (ref-DALOS::UR_Elite-DEB ouronet-account)) p)
                        nominal-boosted-score
                    )
                )
                (new-user-boosted-score:decimal
                    (if apply-foreign-boost-surplus
                        (ref-U|DEC::UC_Max
                            0.0
                            (floor (- nominal-boosted-score foreign-base-ref) p)
                        )
                        nominal-boosted-score
                    )
                )
                (new-user-deb-score:decimal
                    (if apply-foreign-boost-surplus
                        (ref-U|DEC::UC_Max
                            0.0
                            (floor (- nominal-deb-score foreign-base-ref) p)
                        )
                        nominal-deb-score
                    )
                )
                (was-nz:bool
                    (fold (or) false [(> ob 0.0) (> obb 0.0) (> od 0.0)])
                )
                (is-nz:bool
                    (fold (or) false
                        [
                            (> new-user-base-score 0.0)
                            (> new-user-boosted-score 0.0)
                            (> new-user-deb-score 0.0)
                        ]
                    )
                )
                (nz-delta:integer
                    (if (and was-nz (not is-nz))
                        -1
                        (if (and (not was-nz) is-nz)
                            1
                            0
                        )
                    )
                )
                (delta-global-base-score:decimal (- new-user-base-score ob))
                (delta-global-boosted-score:decimal (- new-user-boosted-score obb))
                (delta-global-deb-score:decimal (- new-user-deb-score od))
            )
            (UDC_SCR|SingularUserScoreDelta
                ;; 1 — User base-score after update: 0 when foreign boost-link + boost-class (surplus-only row); else floor(ob + signed, p).
                new-user-base-score
                ;; 2 — User boosted column after update (nominal boosted, or surplus over foreign base when foreign boost-link + boost-class).
                new-user-boosted-score
                ;; 3 — User deb column after update (nominal deb, or surplus over foreign base in that foreign-boost case).
                new-user-deb-score
                ;; 4 — Change to SCR|T|Score.nzs-count: -1 if user went from any non-zero triple to all zeros, +1 if reverse, else 0.
                nz-delta
                ;; 5 — Amount to add to SCR|T|Score.total-base-score (new user base − previous user base), floored at score precision in XI.
                delta-global-base-score
                ;; 6 — Amount to add to SCR|T|Score.total-boosted-score (new user boosted − previous user boosted).
                delta-global-boosted-score
                ;; 7 — Amount to add to SCR|T|Score.total-deb-score (new user deb − previous user deb).
                delta-global-deb-score
            )
        )
    )
    (defun URC_StakeScoreDeltaIgnisUnit:decimal (score-id:string)
        @doc "IGNIS for one score row update in stake phase 2.3]: flat ignis|biggest per score + surcharges: \
            \ +ignis|biggest if deb-boost enabled; +ignis|biggest if boost-class-link ≠ BAR; +ignis|biggest if boost-link ≠ BAR; \
            \ +2×ignis|biggest if score-class 0 (LP)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (highest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (c:integer (UR_SCR|ScoreClass score-id))
                (bcc:string (UR_SCR|ScoreBoostClassLink score-id))
                (bl:string (UR_SCR|ScoreBoostLink score-id))
                (deb:bool (UR_SCR|ScoreDebBoost score-id))
            )
            (fold (+) 0.0
                [
                    highest
                    (if deb highest 0.0)
                    (if (!= bcc BAR) highest 0.0)
                    (if (!= bl BAR) highest 0.0)
                    (if (= c 0) (* 2.0 highest) 0.0)
                ]
            )
        )
    )
    (defun URC_StakeScoreDeltaIgnisCumulator:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string)
        @doc "Internal: TF stake ico4 — one employed score row IGNIS (URC_StakeScoreDeltaIgnisUnit). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_StakeScoreDeltaIgnisUnit score-id)
                AQP|SC_NAME
                trigger
                [score-id]
            )
        )
    )
    ;;{F2}  [UEV]
    (defun UEV_LpStakeScoreContext
        (ouronet-account:string pool-id:string score-id:string lp-id:string)
        @doc "LP stake paths: standard account exists; score class 0; aqpool-link equals pool-id; native LP row whose pair lists lp-denominator."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (native-lp:string (URC_StakeLpTokenToNativeLpDptf lp-id))
                (lp-denom:string (UR_SCR|ScoreLpDenominator score-id))
                (swpair:string (ref-SWP::UR_GetLpSwpair native-lp))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
            )
            (ref-DALOS::UEV_EnforceAccountExists ouronet-account)
            (ref-DALOS::UEV_EnforceAccountType ouronet-account false)
            (enforce
                (fold (and) true
                    [
                        (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (UR_SCR|ScoreClass score-id) 0)
                        (contains lp-denom pool-tokens)
                    ]
                )
                "LP stake score context: pool-id, score-class, or LP pair vs lp-denominator mismatch"
            )
        )
    )
    (defun UEV_DptfStakeScoreContext
        (ouronet-account:string pool-id:string score-id:string)
        @doc "Class-1 DPTF (non-LP) stake paths: account exists and is non-principal; aqpool-link equals pool-id; score-class 1. \
            \ Pool asset-id vs staked dptf-id is validated in AQP-POOL before composing this module's XE_* (see SCR|XE>UPDATE-STAKE-DPTF @doc)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists ouronet-account)
            (ref-DALOS::UEV_EnforceAccountType ouronet-account false)
            (enforce
                (fold (and) true
                    [
                        (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (UR_SCR|ScoreClass score-id) 1)
                    ]
                )
                "DPTF stake score context: pool-id must match aqpool-link and score-class must be 1 (true fungible score)"
            )
        )
    )
    (defun UEV_DpofStakeScoreContext
        (ouronet-account:string pool-id:string score-id:string)
        @doc "Class-2 DPOF (non-LP) stake paths: account exists and is non-principal; aqpool-link equals pool-id; score-class 2. \
            \ Pool asset-id vs staked dpof-id is validated in AQP-POOL before composing this module's XE_* (see SCR|XE>UPDATE-STAKE-DPOF @doc)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists ouronet-account)
            (ref-DALOS::UEV_EnforceAccountType ouronet-account false)
            (enforce
                (fold (and) true
                    [
                        (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (UR_SCR|ScoreClass score-id) 2)
                    ]
                )
                "DPOF stake score context: pool-id must match aqpool-link and score-class must be 2 (orto fungible score)"
            )
        )
    )
    (defun UEV_DpsfStakeScoreContext
        (ouronet-account:string pool-id:string score-id:string)
        @doc "Class-3 DPSF (semi-fungible) stake paths: account exists and is non-principal; aqpool-link equals pool-id; score-class 3. \
            \ Pool asset-id vs staked dpsf-id is validated in AQP-POOL before composing this module's XE_* (see SCR|XE>UPDATE-STAKE-DPSF @doc)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists ouronet-account)
            (ref-DALOS::UEV_EnforceAccountType ouronet-account false)
            (enforce
                (fold (and) true
                    [
                        (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (UR_SCR|ScoreClass score-id) 3)
                    ]
                )
                "DPSF stake score context: pool-id must match aqpool-link and score-class must be 3 (semi-fungible score)"
            )
        )
    )
    (defun UEV_DpnfStakeScoreContext
        (ouronet-account:string pool-id:string score-id:string)
        @doc "Class-4 DPNF (non-fungible) stake paths: account exists and is non-principal; aqpool-link equals pool-id; score-class 4. \
            \ Pool asset-id vs staked dpnf-id is validated in AQP-POOL before composing this module's XE_* (see SCR|XE>UPDATE-STAKE-DPNF @doc)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists ouronet-account)
            (ref-DALOS::UEV_EnforceAccountType ouronet-account false)
            (enforce
                (fold (and) true
                    [
                        (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (UR_SCR|ScoreClass score-id) 4)
                    ]
                )
                "DPNF stake score context: pool-id must match aqpool-link and score-class must be 4 (non-fungible score)"
            )
        )
    )
    (defun UEV_NonFungibleScoreDefinition
        (
            score-id:string
            dpnf-id:string
            trait-score-values:[decimal]
            trait-keys:[string]
            trait-values:[string]
            dpnf-nonce-classes:[integer]
        )
        @doc "Validates inputs for NF score definition issuance. Dispatches to UEV_NonFungibleScoreDefinitionTrait or \
            \ UEV_NonFungibleScoreDefinitionSet after UEV_IzNonFungibleScoreDefinitionTraitBranch. score-id supplies precision."
        (let
            (
                (precision:integer (UR_SCR|ScorePrecision score-id))
                (trait-mode:bool (UEV_IzNonFungibleScoreDefinitionTraitBranch trait-keys dpnf-nonce-classes))
            )
            (if trait-mode
                (UEV_NonFungibleScoreDefinitionTrait dpnf-id precision trait-keys trait-values trait-score-values)
                (UEV_NonFungibleScoreDefinitionSet dpnf-id precision dpnf-nonce-classes trait-score-values)
            )
        )
    )
    (defun UEV_IzNonFungibleScoreDefinitionTraitBranch:bool
        (trait-keys:[string] dpnf-nonce-classes:[integer])
        @doc "True when caller selected trait-mode: non-empty trait-keys and empty dpnf-nonce-classes. \
            \ Enforces exactly one active branch (trait xor set)."
        (let
            (
                (l1:integer (length trait-keys))
                (l2:integer (length dpnf-nonce-classes))
            )
            (enforce
                (fold (or) false
                    [
                        (and (> l1 0) (= l2 0))
                        (and (= l1 0) (> l2 0))
                    ]
                )
                "NF score definition requires exactly one branch: non-empty trait-keys (trait) or non-empty dpnf-nonce-classes (set)"
            )
            (> l1 0)
        )
    )
    (defun UEV_NonFungibleScoreDefinitionTrait
        (dpnf-id:string precision:integer trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Trait-mode NF score definition validation: first-nonce metadata, list alignment, trait-value bounds, score precision."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length trait-keys))
                (l2:integer (length trait-values))
                (l3:integer (length trait-score-values))
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
            )
            (enforce
                (fold (and) true
                    [
                        (> l1 0)
                        (= l1 l2)
                        (= l1 l3)
                    ]
                )
                "Invalid trait definition inputs: trait key/value/score lists must be non-empty and aligned"
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (trait-key:string (at idx trait-keys))
                            (trait-value:string (at idx trait-values))
                            (trait-score-value:decimal (at idx trait-score-values))
                            (l4:integer (length trait-value))
                            (iz-key-present:bool (contains trait-key meta-data))
                        )
                        (enforce
                            (fold (and) true
                                [
                                    iz-key-present
                                    (>= l4 2)
                                    (<= l4 256)
                                    (= (floor trait-score-value precision) trait-score-value)
                                ]
                            )
                            (format
                                "Invalid DPNF trait definition (key={}, value={}, score={}, precision={})"
                                [trait-key trait-value trait-score-value precision]
                            )
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    (defun UEV_NonFungibleScoreDefinitionSet
        (dpnf-id:string precision:integer dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Set-mode NF score definition validation: nonce-class list vs class-score-values alignment, bounds vs UR_SetClassesUsed, precision."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (l1:integer (length dpnf-nonce-classes))
                (l2:integer (length class-score-values))
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            (enforce
                (fold (and) true
                    [
                        (> l1 0)
                        (= l1 l2)
                    ]
                )
                "Invalid set NF score definition inputs: nonce-class and score value lists must be non-empty and aligned"
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nc:integer (at idx dpnf-nonce-classes))
                            (v:decimal (at idx class-score-values))
                        )
                        (enforce
                            (fold (and) true
                                [
                                    (>= nc 0)
                                    (<= nc classes-used)
                                    (= (floor v precision) v)
                                ]
                            )
                            (format
                                "Invalid DPNF set score definition (nonce-class={}, value={}, precision={})"
                                [nc v precision]
                            )
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_SCR|Schema:object{SCR|Schema}
        (a:string b:bool c:bool d:string e:string f:string g:string h:bool i:integer j:decimal k:decimal l:decimal m:integer n:integer o:string p:decimal q:decimal r:decimal s:bool t:integer u:string)
        @doc "Core constructor for object{SCR|Schema}: every schema field is an explicit argument (use for custom UDC wrappers)."
        {"owner-konto"          : a
        ,"can-upgrade"          : b
        ,"can-change-owner"     : c
        ,"boost-class-link"     : d
        ,"boost-link"           : e
        ,"aqpool-link"          : f
        ,"fvt-link"             : g
        ,"deb-boost"            : h
        ,"precision"            : i
        ,"total-base-score"     : j
        ,"total-boosted-score"  : k
        ,"total-deb-score"      : l
        ,"nzs-count"            : m
        ,"score-class"          : n
        ,"lp-denominator"       : o
        ,"mx-frozen"            : p
        ,"mx-sleeping"          : q
        ,"mx-hibernated"        : r
        ,"sft-equality"         : s
        ,"nft-score-model"      : t
        ,"score-id"             : u}
    )
    (defun UDC_SCR|SF|Schema:object{SCR|SF|Schema}
        (a:decimal b:string c:string d:integer)
        @doc "Core constructor for object{SCR|SF|Schema}."
        {"nonce-score-value" : a
        ,"score-id"          : b
        ,"dpsf-id"           : c
        ,"nonce"             : d}
    )
    (defun UDC_SCR|SF|DefRevision:object{SCR|SF|DefRevision}
        (a:integer b:string c:string)
        @doc "Core constructor for object{SCR|SF|DefRevision}."
        {"revision-nonce" : a
        ,"score-id"       : b
        ,"dpsf-id"        : c}
    )
    (defun UDC_SCR|NF|TraitSchema:object{SCR|NF|TraitSchema}
        (a:decimal b:string c:string d:string e:string)
        @doc "Core constructor for object{SCR|NF|TraitSchema}: trait-score-value, score-id, dpnf-id, trait-key, trait-value."
        {"trait-score-value" : a
        ,"score-id"          : b
        ,"dpnf-id"           : c
        ,"trait-key"         : d
        ,"trait-value"       : e}
    )
    (defun UDC_SCR|NF|ClassSchema:object{SCR|NF|ClassSchema}
        (a:decimal b:string c:string d:integer)
        @doc "Core constructor for object{SCR|NF|ClassSchema}: trait-score-value, score-id, dpnf-id, dpnf-nonce-class."
        {"trait-score-value"  : a
        ,"score-id"           : b
        ,"dpnf-id"            : c
        ,"dpnf-nonce-class"   : d}
    )
    (defun UDC_SCR|NF|DefRevision:object{SCR|NF|DefRevision}
        (ga:integer tr:integer cl:integer score-id:string dpnf-id:string)
        @doc "Core constructor for object{SCR|NF|DefRevision}: global, trait, class revision nonces plus keys."
        {"global-revision-nonce" : ga
        ,"trait-revision-nonce"  : tr
        ,"class-revision-nonce"  : cl
        ,"score-id"              : score-id
        ,"dpnf-id"               : dpnf-id}
    )
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Issue by score-class (SCR|T|Score / SCR|Schema)
    (defun C_IssueLiquidityScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Create score-class 0 (LP). Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-LIQUIDITY-SCORE owner-konto score-name precision lp-denominator mx-frozen mx-sleeping)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 0 lp-denominator mx-frozen mx-sleeping 1.0 true -1)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-SCORE owner-konto trigger [score-id])
            )
        )
    )
    (defun C_IssueTrueFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Create score-class 1 (DPTF). Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE owner-konto score-name precision mx-frozen)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 1 BAR mx-frozen 1.0 1.0 true -1)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-SCORE owner-konto trigger [score-id])
            )
        )
    )
    (defun C_IssueOrtoFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Create score-class 2 (DPOF, including special tokens). Caller sets mx-sleeping and mx-hibernated; mx-frozen defaults 2.0. \
            \ Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE owner-konto score-name precision mx-sleeping mx-hibernated)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 2 BAR 2.0 mx-sleeping mx-hibernated true -1)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-SCORE owner-konto trigger [score-id])
            )
        )
    )
    (defun C_IssueSemiFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Create score-class 3 (DPSF). Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE owner-konto score-name precision sft-equality)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 3 BAR 2.0 1.0 1.0 sft-equality -1)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-SCORE owner-konto trigger [score-id])
            )
        )
    )
    (defun C_IssueNonFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Create score-class 4 (DPNF). Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-NON-FUNGIBLE-SCORE owner-konto score-name precision nft-score-model)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 4 BAR 2.0 1.0 1.0 true nft-score-model)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-SCORE owner-konto trigger [score-id])
            )
        )
    )
    ;;Management (SCR|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string new-owner-konto:string)
        @doc "Transfer score owner-konto. No native STOA; validation in SCR|C>ROTATE-OWNERSHIP-SCORE; XI writes only; medium IGNIS cumulator built here."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-pre-rotate:string (UR_SCR|ScoreOwnerKonto score-id))
            )
            (with-capability (SCR|C>ROTATE-OWNERSHIP-SCORE score-id new-owner-konto)
                (XI_RotateOwnership score-id new-owner-konto)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-pre-rotate)
        )
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Set can-upgrade and can-change-owner. No native STOA; validation in SCR|C>CONTROL-SCORE; XI writes only; medium IGNIS cumulator built here."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
            )
            (with-capability (SCR|C>CONTROL-SCORE score-id new-can-upgrade new-can-change-owner)
                (XI_Control score-id new-can-upgrade new-can-change-owner)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-konto)
        )
    )
    ;;Post-issuance: only C_EnableDebBoost (deb-boost defaults false). Multipliers, sft-equality, nft-score-model, links [..] set at issue.
    (defun C_CreateBoostClassLink:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string boost-class-id:string)
        @doc "Set boost-class-link once. No STOA; validation in SCR|C>CREATE-BOOST-CLASS-LINK-SCORE; XI writes only; biggest IGNIS cumulator built here."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
            )
            (with-capability (SCR|C>CREATE-BOOST-CLASS-LINK-SCORE score-id boost-class-id)
                (XI_CreateBoostClassLink score-id boost-class-id)
            )
            (ref-IGNIS::UDC_BiggestCumulator owner-konto)
        )
    )
    (defun C_CreateBoostLink:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string boost-score-id:string)
        @doc "Set boost-link once. No STOA; validation in SCR|C>CREATE-BOOST-LINK-SCORE; XI writes only; biggest IGNIS cumulator built here."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
            )
            (with-capability (SCR|C>CREATE-BOOST-LINK-SCORE score-id boost-score-id)
                (XI_CreateBoostLink score-id boost-score-id)
            )
            (ref-IGNIS::UDC_BiggestCumulator owner-konto)
        )
    )
    (defun C_EnableDebBoost:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string)
        @doc "Set deb-boost true once; irreversible. No native STOA; validation in SCR|C>ENABLE-DEB-BOOST-SCORE; XI write only; medium IGNIS cumulator."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
            )
            (with-capability (SCR|C>ENABLE-DEB-BOOST-SCORE score-id)
                (XI_EnableDebBoost score-id)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-konto)
        )
    )
    ;;DPDC granular definitions
    (defun C_IssueSemiFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Write SCR|T|SF|Score nonce-score-value for multiple nonces in one call; increments SF DefRevision revision-nonce once."
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (big:decimal (ref-DALOS::UR_UsagePrice "ignis|big"))
                (how-many:decimal (dec (length nonces)))
                (price:decimal (* how-many big))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (SCR|C>ISSUE-SF-SCORE-DEFINITION score-id dpsf-id nonces nonce-score-values)
                (XI_IssueSemiFungibleScoreDefinition score-id dpsf-id nonces nonce-score-values)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner-konto trigger [])
        )
    )
    (defun C_IssueNonFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Write SCR|T|NF|TraitScore trait-score-value rows for multiple trait key/value pairs in one call; bumps NF DefRevision global + trait counters."
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (how-many:decimal (dec (length trait-keys)))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (SCR|C>ISSUE-NF-SCORE-DEFINITION score-id dpnf-id trait-keys trait-values trait-score-values)
                (XI_IssueNonFungibleScoreDefinitionCore
                    score-id dpnf-id true trait-keys trait-values trait-score-values [] []
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner-konto trigger [])
        )
    )
    (defun C_IssueNonFungibleSetScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Write SCR|T|NF|ClassScore set-mode definitions (one row per dpnf-nonce-class); bumps NF DefRevision global + class counters."
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (how-many:decimal (dec (length dpnf-nonce-classes)))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (SCR|C>ISSUE-NF-SET-SCORE-DEFINITION score-id dpnf-id dpnf-nonce-classes class-score-values)
                (XI_IssueNonFungibleScoreDefinitionCore
                    score-id dpnf-id false [] [] [] dpnf-nonce-classes class-score-values
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner-konto trigger [])
        )
    )
    ;;
    ;;{F7}  [X]
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* … ; XE_* / XB_* → XI_1|* (depth 1) → XI_2|* …
    ;; Blocks follow map order (entry first, then children, then shared leaves).
    ;;
    ;; --- Block A · C_* lifecycle writers ---
    ;;   C_Issue / C_RotateOwnership / C_Control / C_EnableDebBoost
    ;;     └ XI_Issue / XI_RotateOwnership / XI_Control / XI_EnableDebBoost
    ;;   C_IssueSemiFungibleScoreDefinition → XI_IssueSemiFungibleScoreDefinition
    ;;   C_IssueNonFungible* → XI_IssueNonFungibleScoreDefinitionCore
    ;;   C_CreateBoost* → XI_CreateBoostClassLink / XI_CreateBoostLink
    ;;
    (defun XI_Issue:string
        (
            score-name:string
            owner-konto:string
            precision:integer
            score-class:integer
            lp-denominator:string
            mx-frozen:decimal
            mx-sleeping:decimal
            mx-hibernated:decimal
            sft-equality:bool
            nft-score-model:integer
        )
        @doc "Inserts SCR|T|Score under SCR|XI>ISSUE-SCORE (cap omits sft-equality). score-id from UDC_Makeid(score-name); \
            \ can-upgrade and can-change-owner true; links BAR; deb-boost false; totals zero. Write only — no OutputCumulator; C_Issue* builds IGNIS."
        (require-capability
            (SCR|XI>ISSUE-SCORE
                score-name owner-konto precision score-class
                lp-denominator mx-frozen mx-sleeping mx-hibernated nft-score-model
            )
        )
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;
                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
            )
            (insert SCR|T|Score score-id
                (UDC_SCR|Schema
                    owner-konto true true
                    BAR BAR BAR BAR
                    false
                    precision
                    0.0 0.0 0.0 0
                    score-class lp-denominator mx-frozen mx-sleeping mx-hibernated
                    sft-equality nft-score-model
                    score-id
                )
            )
        )
    )
    (defun XI_RotateOwnership:string
        (score-id:string new-owner-konto:string)
        @doc "Under SECURE (from SCR|C>ROTATE-OWNERSHIP-SCORE): update owner-konto only. Write only; C_RotateOwnership builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            (+ (UR_SCR|Score score-id) {"owner-konto": new-owner-konto})
        )
    )
    (defun XI_Control:string
        (score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Under SECURE (from SCR|C>CONTROL-SCORE): update can-upgrade and can-change-owner only. Write only; C_Control builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            (+ (UR_SCR|Score score-id)
                {"can-upgrade": new-can-upgrade, "can-change-owner": new-can-change-owner}
            )
        )
    )
    (defun XI_EnableDebBoost:string
        (score-id:string)
        @doc "Under SECURE (from SCR|C>ENABLE-DEB-BOOST-SCORE): set deb-boost true only. Write only; C_EnableDebBoost builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            (+ (UR_SCR|Score score-id) {"deb-boost": true})
        )
    )
    (defun XI_IssueSemiFungibleScoreDefinition:string
        (score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Under SECURE (from SCR|C>ISSUE-SF-SCORE-DEFINITION): write SCR|T|SF|Score rows and increment SF DefRevision once per call."
        (require-capability (SECURE))
        (let
            (
                (sf-rev-key:string (UC_SFDefRevisionKey score-id dpsf-id))
                (revision-nonce:integer (UR_S-DEF-REV|SFDefRevisionRevisionNonce score-id dpsf-id))
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (nonce-score-value:decimal (at idx nonce-score-values))
                            (sf-key:string (UC_SFScoreKey score-id dpsf-id nonce))
                        )
                        (write SCR|T|SF|Score sf-key
                            (UDC_SCR|SF|Schema nonce-score-value score-id dpsf-id nonce)
                        )
                    )
                )
                (enumerate 0 (- (length nonces) 1))
            )
            (write SCR|T|SF|DefRevision sf-rev-key
                (UDC_SCR|SF|DefRevision (+ revision-nonce 1) score-id dpsf-id)
            )
        )
    )
    (defun XI_IssueNonFungibleScoreDefinitionCore:string
        (
            score-id:string
            dpnf-id:string
            trait-mode:bool
            trait-keys:[string]
            trait-values:[string]
            trait-score-values:[decimal]
            dpnf-nonce-classes:[integer]
            set-score-values:[decimal]
        )
        @doc "Under SECURE (from SCR|XI>X_ISSUE-NF-SCORE-DEFINITION): invoked from C_IssueNonFungibleScoreDefinition \
            \ (trait-mode true) or C_IssueNonFungibleSetScoreDefinition (trait-mode false). Writes SCR|T|NF|TraitScore or SCR|T|NF|ClassScore rows \
            \ and bumps NF DefRevision global plus trait-only or class-only counter."
        (require-capability (SECURE))
        (let
            (
                (nf-rev-key:string (UC_NFDefRevisionKey score-id dpnf-id))
                (g:integer (UR_N-DEF-REV|NFDefRevisionGlobalRevisionNonce score-id dpnf-id))
                (tr:integer (UR_N-DEF-REV|NFDefRevisionTraitRevisionNonce score-id dpnf-id))
                (cl:integer (UR_N-DEF-REV|NFDefRevisionClassRevisionNonce score-id dpnf-id))
            )
            (if trait-mode
                (map
                    (lambda
                        (idx:integer)
                        (let
                            (
                                (trait-key:string (at idx trait-keys))
                                (trait-value:string (at idx trait-values))
                                (trait-score-value:decimal (at idx trait-score-values))
                                (nf-key:string (UC_NFTraitScoreKey score-id dpnf-id trait-key trait-value))
                            )
                            (write SCR|T|NF|TraitScore nf-key
                                (UDC_SCR|NF|TraitSchema trait-score-value score-id dpnf-id trait-key trait-value)
                            )
                        )
                    )
                    (enumerate 0 (- (length trait-keys) 1))
                )
                (map
                    (lambda
                        (idx:integer)
                        (let
                            (
                                (nc:integer (at idx dpnf-nonce-classes))
                                (trait-score-value:decimal (at idx set-score-values))
                                (nf-key:string (UC_NFClassScoreKey score-id dpnf-id nc))
                            )
                            (write SCR|T|NF|ClassScore nf-key
                                (UDC_SCR|NF|ClassSchema trait-score-value score-id dpnf-id nc)
                            )
                        )
                    )
                    (enumerate 0 (- (length dpnf-nonce-classes) 1))
                )
            )
            (write SCR|T|NF|DefRevision nf-rev-key
                (if trait-mode
                    (UDC_SCR|NF|DefRevision (+ g 1) (+ tr 1) cl score-id dpnf-id)
                    (UDC_SCR|NF|DefRevision (+ g 1) tr (+ cl 1) score-id dpnf-id)
                )
            )
        )
    )
    ;; Link fields [..] on SCR|Schema: XI under SECURE from SCR|C>*; XE from forward modules (UEV_IMC + SCR|XE>*).
    (defun XI_CreateBoostClassLink:string
        (score-id:string boost-class-id:string)
        @doc "Under SECURE: set boost-class-link only. Write only; C_CreateBoostClassLink builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            (+ (UR_SCR|Score score-id) {"boost-class-link": boost-class-id})
        )
    )
    (defun XI_CreateBoostLink:string
        (score-id:string boost-score-id:string)
        @doc "Under SECURE: set boost-link only. Write only; C_CreateBoostLink builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            (+ (UR_SCR|Score score-id) {"boost-link": boost-score-id})
        )
    )
    ;;
    ;; --- Block B · Stake user-score delta ---
    ;;   XE_ApplyTrueFungibleStakeDelta (TF · FVT phase 2.3)
    ;;     └ XI_1|UpdateScoreDataForTrueFungibleLP / TrueFungible
    ;;   (future XE_* for Orto / Semi / NF recipes)
    ;;     └ XI_1|UpdateScoreDataForOrto* / SemiFungible / NonFungible
    ;;         └ XI_2|ApplySingularUserScoreDelta (shared leaf)
    ;;
    (defun XE_ApplyTrueFungibleStakeDelta:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool employed-ids:[string] native-leg:bool)
        @doc "Forward (FVT::C_TrueFungibleStakeFlow phase 2.3]): TF stake only — class 0 LP or class 1 DPTF per employed score. \
            \ employed-ids and native-leg are resolved by FVT from AQP-POOL (avoids SCORE→AQP module ref at load). UEV_IMC only."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (score-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    ;; map: employed pool scores (class 0 LP vs class 1 DPTF write leg per score)
                    (map
                        (lambda (score-id:string)
                            (if (= (UR_SCR|ScoreClass score-id) 0)
                                (do
                                    (XI_1|UpdateScoreDataForTrueFungibleLP
                                        beneficiary-id pool-id score-id dptf-id amount native-leg direction
                                    )
                                    (URC_StakeScoreDeltaIgnisCumulator score-id)
                                )
                                (do
                                    (XI_1|UpdateScoreDataForTrueFungible
                                        beneficiary-id pool-id score-id dptf-id amount native-leg direction
                                    )
                                    (URC_StakeScoreDeltaIgnisCumulator score-id)
                                )
                            )
                        )
                        employed-ids
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators score-ocs [])
        )
    )

    (defun XI_1|UpdateScoreDataForTrueFungibleLP:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            lp-id:string
            lp-amount:decimal
            native-or-frozen:bool
            direction:bool
        )
        @doc "Internal (XE_ApplyTrueFungibleStakeDelta · depth 1]): class-0 LP stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-LP-STAKE-DPTF-LP
                ouronet-account pool-id score-id lp-id lp-amount native-or-frozen direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForDptfLpStake score-id lp-id lp-amount native-or-frozen direction)
            )
        )
    )

    (defun XI_1|UpdateScoreDataForTrueFungible:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dptf-id:string
            dptf-amount:decimal
            native-or-frozen:bool
            direction:bool
        )
        @doc "Internal (XE_ApplyTrueFungibleStakeDelta · depth 1]): class-1 DPTF stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-STAKE-DPTF
                ouronet-account pool-id score-id dptf-id dptf-amount native-or-frozen direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForDptfStake score-id dptf-id dptf-amount native-or-frozen direction)
            )
        )
    )

    (defun XI_1|UpdateScoreDataForOrtoFungibleLP:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            lp-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Internal (future XE_* · depth 1]): sleeping orto LP stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-LP-STAKE-ORTO-LP
                ouronet-account pool-id score-id lp-id nonces nonce-amounts direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForOrtoLpStake score-id lp-id nonces nonce-amounts direction)
            )
        )
    )

    (defun XI_1|UpdateScoreDataForOrtoFungible:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Internal (future XE_* · depth 1]): class-2 DPOF stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-STAKE-DPOF
                ouronet-account pool-id score-id dpof-id nonces nonce-amounts direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForDpofStake score-id dpof-id nonces nonce-amounts direction)
            )
        )
    )

    (defun XI_1|UpdateScoreDataForSpecialOrtoFungible:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            sleeping-or-hibernating:bool
            direction:bool
        )
        @doc "Internal (future XE_* · depth 1]): class-2 special DPOF stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-STAKE-DPOF-SPECIAL
                ouronet-account pool-id score-id dpof-id nonces nonce-amounts sleeping-or-hibernating direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForSpecialDpofStake
                    score-id dpof-id nonces nonce-amounts sleeping-or-hibernating direction
                )
            )
        )
    )

    (defun XI_1|UpdateScoreDataForSemiFungible:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpsf-id:string
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Internal (future XE_* · depth 1]): class-3 DPSF stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-STAKE-DPSF
                ouronet-account pool-id score-id dpsf-id nonces nonce-amounts direction
            )
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForDpsfStake score-id dpsf-id nonces nonce-amounts direction)
            )
        )
    )

    (defun XI_1|UpdateScoreDataForNonFungible:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            dpnf-id:string
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Internal (future XE_* · depth 1]): class-4 DPNF stake/unstake write leg."
        (with-capability
            (SCR|XE>UPDATE-STAKE-DPNF ouronet-account pool-id score-id dpnf-id nonces nonce-amounts direction)
            (XI_2|ApplySingularUserScoreDelta
                ouronet-account
                pool-id
                score-id
                (URC_SignedBaseDeltaForDpnfStake score-id dpnf-id nonces nonce-amounts direction)
            )
        )
    )

    (defun XI_2|ApplySingularUserScoreDelta:string
        (ouronet-account:string pool-id:string score-id:string signed-user-base-delta:decimal)
        @doc "Internal (XI_1|UpdateScoreData* · depth 2]): core user-score write at score precision."
        (require-capability (SECURE))
        (let
            (
                (scr:object{SCR|Schema} (UR_SCR|Score score-id))
                (p:integer (at "precision" scr))
                (d:object{SCR|SingularUserScoreDelta}
                    (URC_SingularUserScoreDeltaFromSignedUserBase ouronet-account pool-id score-id signed-user-base-delta)
                )
                (old-tb:decimal (at "total-base-score" scr))
                (old-tbst:decimal (at "total-boosted-score" scr))
                (old-td:decimal (at "total-deb-score" scr))
                (old-nzs:integer (at "nzs-count" scr))
                (new-nzs:integer (+ old-nzs (at "nz-delta" d)))
            )
            (write SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id)
                (UDC_SCR|UserSchema
                    (at "new-user-base-score" d)
                    (at "new-user-boosted-score" d)
                    (at "new-user-deb-score" d)
                    ouronet-account
                    pool-id
                    score-id
                )
            )
            (update SCR|T|Score score-id
                (+ scr
                    {"total-base-score"     : (floor (+ old-tb (at "delta-global-base-score" d)) p)
                    ,"total-boosted-score"  : (floor (+ old-tbst (at "delta-global-boosted-score" d)) p)
                    ,"total-deb-score"      : (floor (+ old-td (at "delta-global-deb-score" d)) p)
                    ,"nzs-count"            : new-nzs}
                )
            )
        )
    )

    ;;
    ;; --- Block C · Link-field XE (leaf writes · no XI children) ---
    ;;   XE_CreateAqpoolLink / XE_RevokeAqpoolLink / XE_CreateFvtLink
    ;;
    (defun XE_CreateAqpoolLink:string
        (score-id:string pool-id:string)
        @doc "Forward entry (e.g. AQP-POOL): UEV_IMC; SCR|XE>CREATE-AQPOOL-LINK validates BAR + ownership; write aqpool-link only."
        (enforce (UEV_IMC) "AQP-SCORE UEV_IMC rejected forward XE_CreateAqpoolLink caller")
        (with-capability (SCR|XE>CREATE-AQPOOL-LINK score-id pool-id)
            (update SCR|T|Score score-id {"aqpool-link": pool-id})
            (enforce
                (= (UR_SCR|ScoreAqpoolLink score-id) pool-id)
                "XE_CreateAqpoolLink: aqpool-link write did not persist"
            )
        )
        pool-id
    )
    (defun XE_RevokeAqpoolLink:string
        (score-id:string pool-id:string)
        @doc "Forward entry (e.g. AQP-POOL): UEV_IMC; SCR|XE>REVOKE-AQPOOL-LINK validates aqpool-link = pool-id + ownership; clear to BAR."
        (UEV_IMC)
        (with-capability (SCR|XE>REVOKE-AQPOOL-LINK score-id pool-id)
            (update SCR|T|Score score-id
                (+ (UR_SCR|Score score-id) {"aqpool-link": BAR})
            )
        )
    )
    (defun XE_CreateFvtLink:string
        (score-id:string fvt-id:string)
        @doc "Forward entry (e.g. AQP-FVT): UEV_IMC; SCR|XE>CREATE-FVT-LINK validates BAR + ownership; write fvt-link only."
        (enforce (UEV_IMC) "AQP-SCORE UEV_IMC rejected forward XE_CreateFvtLink caller")
        (with-capability (SCR|XE>CREATE-FVT-LINK score-id fvt-id)
            (update SCR|T|Score score-id {"fvt-link": fvt-id})
            (enforce
                (= (at "fvt-link" (read SCR|T|Score score-id ["fvt-link"])) fvt-id)
                "XE_CreateFvtLink: inner read after update failed"
            )
        )
        (enforce (= (UR_SCR|ScoreFvtLink score-id) fvt-id) "XE_CreateFvtLink: fvt-link write did not persist")
        fvt-id
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table SCR|T|Score)
(create-table SCR|T|UserScore)
(create-table SCR|T|SF|Score)
(create-table SCR|T|NF|TraitScore)
(create-table SCR|T|NF|ClassScore)
(create-table SCR|T|SF|DefRevision)
(create-table SCR|T|NF|DefRevision)