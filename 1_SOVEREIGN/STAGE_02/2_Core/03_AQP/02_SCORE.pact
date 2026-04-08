(module AQP-SCORE GOV
    ;;
    (implements OuronetPolicyV1)
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
            \ [.] semantic fields (score-class, multipliers, sft/nft models, \
            \ nft-trait-keys), links [..], or deb-boost [.t] after positions \
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
        ;;                                  Model  1 = NFTs will be scored based on Scores defined per Trait <trait-score-value>
        ;;                                  (Multiple Traits can be used, must be specified in the key below)
        nft-trait-keys:[string]     ;;[.]   Specifies which NFT Traits will be used for scoring.
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
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;Issue by score-class (SCR|T|Score / SCR|Schema)
    (defun C_IssueLiquidityScore:object{IgnisCollectorV1.OutputCumulator}
        (

        )
        @doc "Create a new score definition with score-class 0 (LP: native | sleeping | freezing)."
        true
    )
    (defun C_IssueTrueFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (

        )
        @doc "Create a new score definition with score-class 1 (DPTF, non-LP)."
        true
    )
    (defun C_IssueOrtoFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (

        )
        @doc "Create a new score definition with score-class 2 (DPOF, non-LP)."
        true
    )
    (defun C_IssueSemiFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (

        )
        @doc "Create a new score definition with score-class 3 (DPSF / SFT)."
        true
    )
    (defun C_IssueNonFungibleScore:object{IgnisCollectorV1.OutputCumulator}
        (

        )
        @doc "Create a new score definition with score-class 4 (DPNF / NFT)."
        true
    )
    ;;Management (SCR|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Transfer score owner-konto when can-change-owner allows."
        true
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Update can-upgrade and can-change-owner on the score definition."
        true
    )
    ;;Immutable links once set ([..] in schema) — client establishes anchor-link and boost-link.
    (defun C_CreateAnchorLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Bind anchor-link to an ANK anchor-id so staking promile can boost this score."
        true
    )
    (defun C_CreateBoostLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Bind boost-link to another score-id as base for boosted scoring; BAR uses this score's own base."
        true
    )
    ;;Score parameters
    (defun C_EnableDebBoost:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set deb-boost true; once true, schema marks [.t] and cannot be turned off."
        true
    )
    (defun C_SetScoreMultipliers:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set DPTF/DPOF multipliers mx-frozen, mx-sleeping, mx-hibernated on the score definition."
        true
    )
    (defun C_SetScoreSftEquality:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set sft-equality; when false, per-nonce values come from SCR|T|SF|Score."
        true
    )
    (defun C_SetScoreNftModel:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set nft-score-model (-1 | 0 | 1) for how DPNF positions contribute to base score."
        true
    )
    (defun C_SetScoreNftTraitKeys:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set nft-trait-keys used when scoring by trait (model 1)."
        true
    )
    ;;DPDC granular definitions
    (defun C_IssueSemiFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Write SCR|T|SF|Score nonce-score-value for (score-id, dpsf-id, nonce)."
        true
    )
    (defun C_IssueNonFungibleScoreDefinition:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Write SCR|T|NF|Score trait-score-value for (score-id, dpnf-id, trait-key, trait-value)."
        true
    )
    ;;
    ;;{F7}  [X]
    ;;Pool / FVT wiring (called from AQP / FVT with SECURE; sets aqpool-link / fvt-link on SCR|Schema)
    (defun XE_CreateAqpoolLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set aqpool-link on a score to a pool-id when the pool adopts this score."
        true
    )
    (defun XE_CreateFvtLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set fvt-link on a score to an fvt-id when the FVT adds this score as a member."
        true
    )
    ;;
    (defun XE_RevokeAqpoolLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Clear aqpool-link (BAR) when a score is removed from a pool's score slots."
        true
    )
    (defun XE_RevokeFvtLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Clear fvt-link (BAR) when a score is no longer tied to an FVT (policy-dependent)."
        true
    )
    ;;
    (defun XE_UpdateUserScore
        ()
        @doc "Recompute or patch SCR|T|UserScore for (account, pool-id, score-id) on stake/unstake and RPS steps."
        true
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