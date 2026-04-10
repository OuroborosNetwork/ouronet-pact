(interface AcquisitionScoresV1
    ;;  [UC]
    (defun UC_UserScoreKey:string (ouronet-account:string pool-id:string score-id:string))
    (defun UC_SFScoreKey:string (score-id:string dpsf-id:string nonce:integer))
    (defun UC_NFScoreKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UC_SFDefRevisionKey:string (score-id:string dpsf-id:string))
    (defun UC_NFDefRevisionKey:string (score-id:string dpnf-id:string))
    ;;
    ;;  [UR]
    (defun UR_SCR|Score:object{SCR|Schema} (score-id:string))
    (defun UR_SCR|ScoreOwnerKonto:string (score-id:string))
    (defun UR_SCR|ScoreCanUpgrade:bool (score-id:string))
    (defun UR_SCR|ScoreCanChangeOwner:bool (score-id:string))
    (defun UR_SCR|ScoreAnchorLink:string (score-id:string))
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
    (defun UR_SCR|ScoreMxFrozen:decimal (score-id:string))
    (defun UR_SCR|ScoreMxSleeping:decimal (score-id:string))
    (defun UR_SCR|ScoreMxHibernated:decimal (score-id:string))
    (defun UR_SCR|ScoreSftEquality:bool (score-id:string))
    (defun UR_SCR|ScoreNftScoreModel:integer (score-id:string))
    (defun UR_SCR|ScoreScoreId:string (score-id:string))
    (defun UR_U-SCR|UserScore:object{SCR|UserSchema} (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreBaseScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreBoostedScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreDebScore:decimal (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreOuronetAccount:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScorePoolId:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_U-SCR|UserScoreScoreId:string (ouronet-account:string pool-id:string score-id:string))
    (defun UR_S-DEF|SFScore:object{SCR|SF|Schema} (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreNonceScoreValue:decimal (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreScoreId:string (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreDpsfId:string (score-id:string dpsf-id:string nonce:integer))
    (defun UR_S-DEF|SFScoreNonce:integer (score-id:string dpsf-id:string nonce:integer))
    (defun UR_N-DEF|NFScore:object{SCR|NF|Schema} (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFScoreTraitScoreValue:decimal (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFScoreScoreId:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFScoreDpnfId:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFScoreTraitKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_N-DEF|NFScoreTraitValue:string (score-id:string dpnf-id:string trait-key:string trait-value:string))
    (defun UR_S-DEF-REV|SFDefRevision:object{SCR|SF|DefRevision} (score-id:string dpsf-id:string))
    (defun UR_S-DEF-REV|SFDefRevisionRevisionNonce:integer (score-id:string dpsf-id:string))
    (defun UR_S-DEF-REV|SFDefRevisionScoreId:string (score-id:string dpsf-id:string))
    (defun UR_S-DEF-REV|SFDefRevisionDpsfId:string (score-id:string dpsf-id:string))
    (defun UR_N-DEF-REV|NFDefRevision:object{SCR|NF|DefRevision} (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionRevisionNonce:integer (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionScoreId:string (score-id:string dpnf-id:string))
    (defun UR_N-DEF-REV|NFDefRevisionDpnfId:string (score-id:string dpnf-id:string))
    ;;
    ;;  [UEV]
    (defun UEV_IMC ())
    (defun UEV_UserScoreTriple:bool
        (score-id:string base-score:decimal boosted-score:decimal deb-score:decimal)
    )
    ;;
    ;;  [UDC]
    (defun UDC_SCR|Schema:object{SCR|Schema}
        (a:string b:bool c:bool d:string e:string f:string g:string h:bool i:integer j:decimal k:decimal l:decimal m:integer n:integer o:decimal p:decimal q:decimal r:bool s:integer t:string)
    )
    (defun UDC_SCR|UserSchema:object{SCR|UserSchema}
        (a:decimal b:decimal c:decimal d:string e:string f:string)
    )
    (defun UDC_SCR|SF|Schema:object{SCR|SF|Schema}
        (a:decimal b:string c:string d:integer)
    )
    (defun UDC_SCR|SF|DefRevision:object{SCR|SF|DefRevision}
        (a:integer b:string c:string)
    )
    (defun UDC_SCR|NF|Schema:object{SCR|NF|Schema}
        (a:decimal b:string c:string d:string e:string)
    )
    (defun UDC_SCR|NF|DefRevision:object{SCR|NF|DefRevision}
        (a:integer b:string c:string)
    )
    ;;
    ;;  [C]
    (defun C_IssueLiquidityScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal mx-sleeping:decimal)
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
    (defun C_CreateAnchorLink:object{IgnisCollectorV1.OutputCumulator} (score-id:string anchor-id:string))
    (defun C_CreateBoostLink:object{IgnisCollectorV1.OutputCumulator} (score-id:string boost-score-id:string))
    (defun C_EnableDebBoost:object{IgnisCollectorV1.OutputCumulator} (score-id:string))
    (defun C_IssueSemiFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun C_IssueNonFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    ;;
    ;;  [XE]
    (defun XE_CreateAqpoolLink:string
        (score-id:string pool-id:string)
    )
    (defun XE_CreateFvtLink:string
        (score-id:string fvt-id:string)
    )
    (defun XE_UpdateUserScore:string
        (ouronet-account:string pool-id:string score-id:string base-score:decimal boosted-score:decimal deb-score:decimal)
    )
)
(module AQP-SCORE GOV
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
                (mg:guard (create-capability-guard (P|AQP-SCORE|CALLER)))
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
        anchor-link:string          ;;[..]  Specifies the Anchor ID that is to boost the score. BAR if not in use.
        boost-link:string           ;;[..]  Specifies the Score ID that is used as Base for the Boosted Score. BAR if not in use (uses its own base)
        aqpool-link:string          ;;[..]  Specifies the Pool that employs the Score. BAR if not in use.
        fvt-link:string             ;;[..]  Specifies the FVT the Score is part of. BAR if not in use.
        ;;Score Information
        deb-boost:bool              ;;[.t]  Specifies if DEB boosting occurs.
        precision:integer           ;;[.]   Decimal places for SCR|T|UserScore weights (base/boosted/deb); validated on XE_UpdateUserScore.
        total-base-score:decimal    ;;[M]   Sum of all Entities Scores, 24 prec
        total-boosted-score:decimal ;;[M]   Sum of all Entities Boosted Scores, 24 prec
        total-deb-score:decimal     ;;[M]   Sum of all Entities Final Score, 24 prec
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
        ;;DPTF & DPOF
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
        ;;                                  Model  1 = NFTs scored from SCR|T|NF|Score rows (trait-key, trait-value, trait-score-value)
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
    (defschema SCR|NF|Schema
        @doc "Per (score-id, dpnf-id, trait-key, trait-value). \
            \ trait-score-value is mutable; trait set in keys is fixed at \
            \ write; new traits need new rows."
        trait-score-value:decimal   ;;[M]   Score Value of DPNF Trait
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        trait-key:string
        trait-value:string
    )
    ;;
    ;;Monotonic revision per (score-id, DPDC collection): bump only when a
    ;;row in SCR|T|SF|Score or SCR|T|NF|Score changes for that pair. AQP
    ;;trackers compare applied-def-revision-nonce to SCR|T|SF|DefRevision /
    ;;SCR|T|NF|DefRevision at (employed-score-id, dpsf-id|dpnf-id).
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
        @doc "Per (score-id, dpnf-id). revision-nonce bumps on any add or \
            \ update in SCR|T|NF|Score for that score-id and dpnf-id."
        revision-nonce:integer      ;;[M]   Bump on SCR|T|NF|Score change
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
    (deftable SCR|T|NF|Score:{SCR|NF|Schema})                   ;;Key = <Score-ID> | <DPNF-ID> | <Trait-Key> | <Trait-Value>
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
            mx-frozen:decimal
            mx-sleeping:decimal
            mx-hibernated:decimal
            nft-score-model:integer
        )
        @doc "Core issuance authorisation for SCR|T|Score: validates score-name, owner, class, multipliers, \
            \ nft-score-model. sft-equality is not a cap parameter (boolean; applied at insert only). score-id \
            \ from score-name (UDC_Makeid); can-upgrade and can-change-owner default true at insert. Composed from \
            \ each SCR|C>ISSUE-* client capability."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                        (or (= nft-score-model -1) (= nft-score-model 0) (= nft-score-model 1))
                    ]
                )
                "Invalid precision, score-class, mx-frozen, mx-sleeping, mx-hibernated or nft-score-model"
            )
        )
    )
    ;;{C3}
    ;;{C4}  Client score issuance — evented caps distinguish score-class path; each composes SCR|XI>ISSUE-SCORE.
    (defcap SCR|C>ISSUE-LIQUIDITY-SCORE
        (owner-konto:string score-name:string precision:integer mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issue LP score (score-class 0). Caller supplies mx-frozen and mx-sleeping; mx-hibernated 1.0, sft-equality true, nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 0 mx-frozen mx-sleeping 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-TRUE-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issue DPTF score (score-class 1). Caller supplies mx-frozen; mx-sleeping and mx-hibernated 1.0; sft-equality true; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 1 mx-frozen 1.0 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-ORTO-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issue DPOF score (score-class 2), including special-token variants. Caller supplies mx-sleeping and mx-hibernated; \
            \ mx-frozen defaults 2.0; sft-equality true; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 2 2.0 mx-sleeping mx-hibernated -1)
        )
    )
    (defcap SCR|C>ISSUE-SEMI-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Issue DPSF score (score-class 3). Caller supplies sft-equality; multipliers default 2.0 / 1.0 / 1.0; nft-score-model -1."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 3 2.0 1.0 1.0 -1)
        )
    )
    (defcap SCR|C>ISSUE-NON-FUNGIBLE-SCORE
        (owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issue DPNF score (score-class 4). Caller supplies nft-score-model; multipliers default 2.0 / 1.0 / 1.0; sft-equality true."
        @event
        (compose-capability
            (SCR|XI>ISSUE-SCORE score-name owner-konto precision 4 2.0 1.0 1.0 nft-score-model)
        )
    )
    (defcap SCR|C>ROTATE-OWNERSHIP-SCORE (score-id:string new-owner-konto:string)
        @doc "Rotate SCR|T|Score owner-konto: current-owner ownership, can-change-owner true, new owner standard account, \
            \ new ≠ current. Composes SECURE for XI write; C_RotateOwnership builds IGNIS cumulator."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                (ref-DPDC-F:module{DpdcFragmentsV1} DPDC-F)
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (score-row-id:string (UR_SCR|ScoreScoreId score-id))
                (sft-equality:bool (UR_SCR|ScoreSftEquality score-id))
                (precision:integer (UR_SCR|ScorePrecision score-id))
                (l-nonces:integer (length nonces))
                (l-values:integer (length nonce-score-values))
                (max-input-nonce:integer (if (> l-nonces 0) (ref-U|INT::UC_MaxInteger nonces) 0))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed dpsf-id true))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (fold (and) true
                    [
                        (= score-row-id score-id)
                        (not sft-equality)
                        (> l-nonces 0)
                        (= l-nonces l-values)
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
                (enumerate 0 (- l-nonces 1))
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>ISSUE-NF-SCORE-DEFINITION
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Write SCR|T|NF|Score definitions for multiple trait key/value pairs. Enforces score ownership, \
            \ score exists, first-nonce metadata contains each trait-key, trait-value length bounds, and \
            \ score-value precision from score precision. Composes SECURE for XI writes."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (score-row-id:string (UR_SCR|ScoreScoreId score-id))
                (precision:integer (UR_SCR|ScorePrecision score-id))
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (l-keys:integer (length trait-keys))
                (l-values:integer (length trait-values))
                (l-scores:integer (length trait-score-values))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DPDC::UEV_id dpnf-id false)
            (enforce
                (fold (and) true
                    [
                        (= score-row-id score-id)
                        (> l-keys 0)
                        (= l-keys l-values)
                        (= l-keys l-scores)
                    ]
                )
                "Invalid score/dpnf inputs: score must exist and trait key/value/score lists must be non-empty and aligned"
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (trait-key:string (at idx trait-keys))
                            (trait-value:string (at idx trait-values))
                            (trait-score-value:decimal (at idx trait-score-values))
                            (l:integer (length trait-value))
                            (iz-key-present:bool (contains trait-key meta-data))
                        )
                        (enforce
                            (fold (and) true
                                [
                                    iz-key-present
                                    (>= l 2)
                                    (<= l 256)
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
                (enumerate 0 (- l-keys 1))
            )
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>CREATE-ANCHOR-LINK-SCORE (score-id:string anchor-id:string)
        @doc "One-time anchor-link on SCR|T|Score: slot BAR, score owner, anchor-id not BAR, anchor row exists in AQP-ANK. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (anchor-link:string (UR_SCR|ScoreAnchorLink score-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (enforce
                (and (= anchor-link BAR) (!= anchor-id BAR))
                "Anchor link slot must be unset and anchor-id must be non-BAR"
            )
            (ref-ANK::UR_ANK|ID anchor-id)
            (compose-capability (SECURE))
        )
    )
    (defcap SCR|C>CREATE-BOOST-LINK-SCORE (score-id:string boost-score-id:string)
        @doc "One-time boost-link: slot BAR, score owner, boost score exists, boost ≠ self, boost-id non-BAR. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                "Boost link slot must be unset; boost score must exist and differ from this score"
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
    (defcap SCR|XE>CREATE-FVT-LINK (score-id:string fvt-id:string)
        @doc "One-time fvt-link: slot BAR, score owner, fvt-id non-BAR. FVT membership rules live in forward modules (e.g. FVT)."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    (defcap SCR|XE>UPDATE-USER-SCORE
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            base-score:decimal
            boosted-score:decimal
            deb-score:decimal
        )
        @doc "Forward-only: write UserScore at (account, pool, score); pool-id must equal score aqpool-link; \
            \ base/boosted/deb must match score precision. Cap is not evented — composed inside AQP stake/unstake client caps."
        (let
            (
                (pool-link:string (UR_SCR|ScoreAqpoolLink score-id))
            )
            (enforce (= pool-link pool-id) "pool-id must match score aqpool-link for UserScore update")
            (UEV_UserScoreTriple score-id base-score boosted-score deb-score)
        )
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
    (defun UC_NFScoreKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Composite key for SCR|T|NF|Score: score-id | dpnf-id | trait-key | trait-value."
        (concat [score-id BAR dpnf-id BAR trait-key BAR trait-value])
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
    ;;{F0}  [UR]
    ;; Reads follow schema order: (1) SCR|Schema (2) SCR|UserSchema (3) SCR|SF|Schema (4) SCR|NF|Schema (5) SF DefRevision (6) NF DefRevision
    ;;
    ;; [1] SCR|T|Score  (SCR|Schema)  Key = <Score-ID>
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
    (defun UR_SCR|ScoreAnchorLink:string (score-id:string)
        @doc "Reads anchor-link from score row."
        (at "anchor-link" (read SCR|T|Score score-id ["anchor-link"]))
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
        @doc "Reads full user score row from SCR|T|UserScore."
        (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id))
    )
    (defun UR_U-SCR|UserScoreBaseScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads base-score from user score row."
        (at "base-score" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["base-score"]))
    )
    (defun UR_U-SCR|UserScoreBoostedScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads boosted-score from user score row."
        (at "boosted-score" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["boosted-score"]))
    )
    (defun UR_U-SCR|UserScoreDebScore:decimal (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads deb-score from user score row."
        (at "deb-score" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["deb-score"]))
    )
    (defun UR_U-SCR|UserScoreOuronetAccount:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads ouronet-account from user score row."
        (at "ouronet-account" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["ouronet-account"]))
    )
    (defun UR_U-SCR|UserScorePoolId:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads pool-id from user score row."
        (at "pool-id" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["pool-id"]))
    )
    (defun UR_U-SCR|UserScoreScoreId:string (ouronet-account:string pool-id:string score-id:string)
        @doc "Reads score-id from user score row."
        (at "score-id" (read SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id) ["score-id"]))
    )
    ;;
    ;; [3] SCR|T|SF|Score  (SCR|SF|Schema)  Key = <Score-ID> | <DPSF-ID> | <Nonce>
    (defun UR_S-DEF|SFScore:object{SCR|SF|Schema} (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads full DPSF nonce score definition row."
        (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce))
    )
    (defun UR_S-DEF|SFScoreNonceScoreValue:decimal (score-id:string dpsf-id:string nonce:integer)
        @doc "Reads nonce-score-value from SF score row."
        (at "nonce-score-value" (read SCR|T|SF|Score (UC_SFScoreKey score-id dpsf-id nonce) ["nonce-score-value"]))
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
    ;; [4] SCR|T|NF|Score  (SCR|NF|Schema)  Key = <Score-ID> | <DPNF-ID> | <Trait-Key> | <Trait-Value>
    (defun UR_N-DEF|NFScore:object{SCR|NF|Schema} (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads full DPNF trait score definition row."
        (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value))
    )
    (defun UR_N-DEF|NFScoreTraitScoreValue:decimal (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-score-value from NF score row."
        (at "trait-score-value" (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value) ["trait-score-value"]))
    )
    (defun UR_N-DEF|NFScoreScoreId:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads score-id from NF score row."
        (at "score-id" (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value) ["score-id"]))
    )
    (defun UR_N-DEF|NFScoreDpnfId:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads dpnf-id from NF score row."
        (at "dpnf-id" (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value) ["dpnf-id"]))
    )
    (defun UR_N-DEF|NFScoreTraitKey:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-key from NF score row."
        (at "trait-key" (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value) ["trait-key"]))
    )
    (defun UR_N-DEF|NFScoreTraitValue:string (score-id:string dpnf-id:string trait-key:string trait-value:string)
        @doc "Reads trait-value from NF score row."
        (at "trait-value" (read SCR|T|NF|Score (UC_NFScoreKey score-id dpnf-id trait-key trait-value) ["trait-value"]))
    )
    ;;
    ;; [5] SCR|T|SF|DefRevision  (SCR|SF|DefRevision)  Key = <Score-ID> | <DPSF-ID>
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
    ;; [6] SCR|T|NF|DefRevision  (SCR|NF|DefRevision)  Key = <Score-ID> | <DPNF-ID>
    (defun UR_N-DEF-REV|NFDefRevision:object{SCR|NF|DefRevision} (score-id:string dpnf-id:string)
        @doc "Reads NF definition revision row for (score-id, dpnf-id)."
        (read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id))
    )
    (defun UR_N-DEF-REV|NFDefRevisionRevisionNonce:integer (score-id:string dpnf-id:string)
        @doc "Reads revision-nonce from NF def-revision row; returns 0 when row is absent."
        (with-default-read SCR|T|NF|DefRevision (UC_NFDefRevisionKey score-id dpnf-id)
            (UDC_SCR|NF|DefRevision 0 score-id dpnf-id)
            {"revision-nonce" := revision-nonce}
            revision-nonce
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
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    (defun UEV_UserScoreTriple:bool
        (score-id:string base-score:decimal boosted-score:decimal deb-score:decimal)
        @doc "Ensures each user-score decimal matches the stored score precision."
        (let
            (
                (precision:integer (UR_SCR|ScorePrecision score-id))
            )
            (enforce
                (fold (and) true
                    [
                        (= (floor base-score precision) base-score)
                        (= (floor boosted-score precision) boosted-score)
                        (= (floor deb-score precision) deb-score)
                    ]
                )
                (format
                    "UserScore decimals must match score precision {} (base={}, boosted={}, deb={})"
                    [precision base-score boosted-score deb-score]
                )
            )
        )
    )
    ;;{F3}  [UDC]
    (defun UDC_SCR|Schema:object{SCR|Schema}
        (a:string b:bool c:bool d:string e:string f:string g:string h:bool i:integer j:decimal k:decimal l:decimal m:integer n:integer o:decimal p:decimal q:decimal r:bool s:integer t:string)
        @doc "Core constructor for object{SCR|Schema}: every schema field is an explicit argument (use for custom UDC wrappers)."
        {"owner-konto"          : a
        ,"can-upgrade"          : b
        ,"can-change-owner"     : c
        ,"anchor-link"          : d
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
        ,"mx-frozen"            : o
        ,"mx-sleeping"          : p
        ,"mx-hibernated"        : q
        ,"sft-equality"         : r
        ,"nft-score-model"      : s
        ,"score-id"             : t}
    )
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
    (defun UDC_SCR|NF|Schema:object{SCR|NF|Schema}
        (a:decimal b:string c:string d:string e:string)
        @doc "Core constructor for object{SCR|NF|Schema}."
        {"trait-score-value" : a
        ,"score-id"          : b
        ,"dpnf-id"           : c
        ,"trait-key"         : d
        ,"trait-value"       : e}
    )
    (defun UDC_SCR|NF|DefRevision:object{SCR|NF|DefRevision}
        (a:integer b:string c:string)
        @doc "Core constructor for object{SCR|NF|DefRevision}."
        {"revision-nonce" : a
        ,"score-id"       : b
        ,"dpnf-id"        : c}
    )
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Issue by score-class (SCR|T|Score / SCR|Schema)
    (defun C_IssueLiquidityScore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal mx-sleeping:decimal)
        @doc "Create score-class 0 (LP). Costs GAS|ISSUE-SCORE IGNIS and UR_UsagePrice \"smart\" STOA from patron."
        (UEV_IMC)
        (with-capability (SCR|C>ISSUE-LIQUIDITY-SCORE owner-konto score-name precision mx-frozen mx-sleeping)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 0 mx-frozen mx-sleeping 1.0 true -1)
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
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 1 mx-frozen 1.0 1.0 true -1)
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
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 2 2.0 mx-sleeping mx-hibernated true -1)
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
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 3 2.0 1.0 1.0 sft-equality -1)
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
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_Issue score-name owner-konto precision 4 2.0 1.0 1.0 true nft-score-model)
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
                (owner-pre-rotate:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
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
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SCR|C>CONTROL-SCORE score-id new-can-upgrade new-can-change-owner)
                (XI_Control score-id new-can-upgrade new-can-change-owner)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-konto)
        )
    )
    ;;Post-issuance: only C_EnableDebBoost (deb-boost defaults false). Multipliers, sft-equality, nft-score-model, links [..] set at issue.
    (defun C_CreateAnchorLink:object{IgnisCollectorV1.OutputCumulator}
        (score-id:string anchor-id:string)
        @doc "Set anchor-link once. No STOA; validation in SCR|C>CREATE-ANCHOR-LINK-SCORE; XI writes only; biggest IGNIS cumulator built here."
        (UEV_IMC)
        (let
            (
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SCR|C>CREATE-ANCHOR-LINK-SCORE score-id anchor-id)
                (XI_CreateAnchorLink score-id anchor-id)
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
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
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
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
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
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
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
        @doc "Write SCR|T|NF|Score trait-score-value for multiple trait key/value pairs in one call; increments NF DefRevision revision-nonce once."
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (owner-konto:string (UR_SCR|ScoreOwnerKonto score-id))
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (how-many:decimal (dec (length trait-keys)))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability
                (SCR|C>ISSUE-NF-SCORE-DEFINITION score-id dpnf-id trait-keys trait-values trait-score-values)
                (XI_IssueNonFungibleScoreDefinition score-id dpnf-id trait-keys trait-values trait-score-values)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner-konto trigger [])
        )
    )
    ;;
    ;;{F7}  [X]
    (defun XI_Issue:string
        (
            score-name:string
            owner-konto:string
            precision:integer
            score-class:integer
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
                mx-frozen mx-sleeping mx-hibernated nft-score-model
            )
        )
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
            )
            (insert SCR|T|Score score-id
                (UDC_SCR|Schema
                    owner-konto true true
                    BAR BAR BAR BAR
                    false
                    precision
                    0.0 0.0 0.0 0
                    score-class mx-frozen mx-sleeping mx-hibernated
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
        (update SCR|T|Score score-id {"owner-konto": new-owner-konto})
    )
    (defun XI_Control:string
        (score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Under SECURE (from SCR|C>CONTROL-SCORE): update can-upgrade and can-change-owner only. Write only; C_Control builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id
            {"can-upgrade": new-can-upgrade, "can-change-owner": new-can-change-owner}
        )
    )
    (defun XI_EnableDebBoost:string
        (score-id:string)
        @doc "Under SECURE (from SCR|C>ENABLE-DEB-BOOST-SCORE): set deb-boost true only. Write only; C_EnableDebBoost builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id {"deb-boost": true})
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
    (defun XI_IssueNonFungibleScoreDefinition:string
        (score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Under SECURE (from SCR|C>ISSUE-NF-SCORE-DEFINITION): write SCR|T|NF|Score rows and increment NF DefRevision once per call."
        (require-capability (SECURE))
        (let
            (
                (nf-rev-key:string (UC_NFDefRevisionKey score-id dpnf-id))
                (revision-nonce:integer (UR_N-DEF-REV|NFDefRevisionRevisionNonce score-id dpnf-id))
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (trait-key:string (at idx trait-keys))
                            (trait-value:string (at idx trait-values))
                            (trait-score-value:decimal (at idx trait-score-values))
                            (nf-key:string (UC_NFScoreKey score-id dpnf-id trait-key trait-value))
                        )
                        (write SCR|T|NF|Score nf-key
                            (UDC_SCR|NF|Schema trait-score-value score-id dpnf-id trait-key trait-value)
                        )
                    )
                )
                (enumerate 0 (- (length trait-keys) 1))
            )
            (write SCR|T|NF|DefRevision nf-rev-key
                (UDC_SCR|NF|DefRevision (+ revision-nonce 1) score-id dpnf-id)
            )
        )
    )
    ;; Link fields [..] on SCR|Schema: XI paths under SECURE from SCR|C>*; XE paths for forward modules (UEV_IMC + SCR|XE>* in-body).
    (defun XI_CreateAnchorLink:string
        (score-id:string anchor-id:string)
        @doc "Under SECURE: set anchor-link only. Write only; C_CreateAnchorLink builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id {"anchor-link": anchor-id})
    )
    (defun XI_CreateBoostLink:string
        (score-id:string boost-score-id:string)
        @doc "Under SECURE: set boost-link only. Write only; C_CreateBoostLink builds IGNIS cumulator."
        (require-capability (SECURE))
        (update SCR|T|Score score-id {"boost-link": boost-score-id})
    )
    (defun XE_CreateAqpoolLink:string
        (score-id:string pool-id:string)
        @doc "Forward entry (e.g. AQP): UEV_IMC; SCR|XE>CREATE-AQPOOL-LINK validates BAR + ownership; write aqpool-link only. \
            \ Write only; caller merges IGNIS OutputCumulator."
        (UEV_IMC)
        (with-capability (SCR|XE>CREATE-AQPOOL-LINK score-id pool-id)
            (update SCR|T|Score score-id {"aqpool-link": pool-id})
        )
    )
    (defun XE_CreateFvtLink:string
        (score-id:string fvt-id:string)
        @doc "Forward entry (e.g. FVT): UEV_IMC; SCR|XE>CREATE-FVT-LINK validates BAR + ownership; write fvt-link only. \
            \ Write only; caller merges IGNIS OutputCumulator."
        (UEV_IMC)
        (with-capability (SCR|XE>CREATE-FVT-LINK score-id fvt-id)
            (update SCR|T|Score score-id {"fvt-link": fvt-id})
        )
    )
    ;;
    (defun XE_UpdateUserScore:string
        (
            ouronet-account:string
            pool-id:string
            score-id:string
            base-score:decimal
            boosted-score:decimal
            deb-score:decimal
        )
        @doc "Forward entry (AQP stake/unstake): UEV_IMC; SCR|XE>UPDATE-USER-SCORE validates aqpool-link and precision; \
            \ upserts SCR|T|UserScore. Values are computed in AQP; this cap is not evented (parent client flow is)."
        (UEV_IMC)
        (with-capability
            (SCR|XE>UPDATE-USER-SCORE
                ouronet-account pool-id score-id base-score boosted-score deb-score
            )
            (write SCR|T|UserScore (UC_UserScoreKey ouronet-account pool-id score-id)
                (UDC_SCR|UserSchema base-score boosted-score deb-score ouronet-account pool-id score-id)
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
;;
(create-table SCR|T|Score)
(create-table SCR|T|UserScore)
(create-table SCR|T|SF|Score)
(create-table SCR|T|NF|Score)
(create-table SCR|T|SF|DefRevision)
(create-table SCR|T|NF|DefRevision)