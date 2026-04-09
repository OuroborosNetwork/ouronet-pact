(interface AcquisitionFarmsVaultsTreasuriesV1
    (defun GOV|Demiurgoi ())
)
(module AQP-FVT GOV
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionFarmsVaultsTreasuriesV1)
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_FVT                    (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|FVT_ADMIN)))
    (defcap GOV|FVT_ADMIN ()                (enforce-guard GOV|MD_FVT))
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
    (defcap P|FVT|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|FVT|CALLER))
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
        (with-capability (GOV|FVT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|FVT_ADMIN)
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
                (mg:guard (create-capability-guard (P|FVT|CALLER)))
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
    (defschema FVT|Schema
        @doc "FVT aggregates member scores for RPS. Policy: add ScoreLink \
            \ only when the score has aqpool-link set (employed by a pool), \
            \ then enforce fvt-class vs score-class and, for farms, \
            \ common-denominator vs that pool's asset (LP construction). \
            \ Changing fvt-class or common-denominator after links exist is \
            \ unsafe for fairness; prefer a new fvt-id. Reward accounting is \
            \ per reward dptf-id (FVT|RPS|Global / FVT|RPS|User)."
        ;;FVT Type
        fvt-class:integer                                       ;; 0 = Farm, 1 = Vault, 2 = Treasury
        ;;
        ;;Management
        owner-konto:string
        can-upgrade:bool
        can-change-owner:bool
        ;;
        ;; 
        common-denominator:string                               ;;Farm-only: common DPTF in all LPs (e.g. "OURO"), "|" for Vault/Treasury
        ;;
        ;;Aggregated Scores
        total-base-score:decimal
        total-boosted-score:decimal
        total-deb-score:decimal
        total-nzs-count:integer
        ;;
        ;; Select Keys
        fvt-id:string
    )
    ;;FVT Memberships
    (defschema FVT|ScoreLink
        @doc "Row key (fvt-id, score-id) is permanent; enabled excludes \
            \ from aggregation. Admission: score must be pool-employed \
            \ (SCR aqpool-link) so asset checks use Pool -> asset-id."
        enabled:bool                                            ;;Defines if the Score is active in FVT
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;FVT the Score-ID operates in
        score-id:string                                         ;;ID of the Score that is linked to the FVT
    )
    (defschema FVT|RewardLink
        @doc "Row key (fvt-id, dptf-id) is permanent; enabled gates inject/collect for that reward token."
        enabled:bool                                            ;;Defines if the Reward is active in FVT
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;FVT the Reward-ID operates in
        dptf-id:string                                          ;;ID of the Reward Token that operates in the FVT
    )
    ;;RPS Schemas
    ;;1]Global RPS per FVT + Reward Token
    (defschema FVT|RPS|Global
        current-rps:decimal                                     ;; 48 decimals
        available-rewards:decimal                               ;; 24 decimals
        unclaimed-count:integer
        segmentation:bool
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    ;;2]User Rewards per FVT + Reward Token
    (defschema FVT|RPS|User
        last-rps:decimal
        pending-rewards:decimal
        ;;
        ;;Select Keys
        user-id:string                                          ;; <Ouronet-Account>
        fvt-id:string                                           ;; <FVT-ID>
        dptf-id:string                                          ;; <DPTF-ID>
    )
    ;;
    ;;{2}
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
    ;;
    (deftable FVT|T|ScoreLink:{FVT|ScoreLink})                  ;; Key = <FVT-ID> | <Score-ID>
    (deftable FVT|T|RewardLink:{FVT|RewardLink})                ;; Key = <FVT-ID> | <DPTF-ID>
    ;;
    (deftable FVT|T|RPS|Global:{FVT|RPS|Global})                ;; Key = <FVT-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|User:{FVT|RPS|User})                    ;; Key = <Ouronet-Account> | <FVT-ID> | <DPTF-ID>
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
    ;;Lifecycle
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Create a new FVT (Farm | Vault | Treasury) entity."
        true
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Transfer FVT owner-konto per governance rules."
        true
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Toggle can-upgrade and can-change-owner on the FVT entity."
        true
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Set farm-only common DPTF id shared by linked LP scores; vault/treasury use sentinel."
        true
    )
    ;;Score membership (FVT|T|ScoreLink) — key is permanent; no delete. Add = enabled true; Toggle = on/off.
    (defun C_AddScoreLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Register a score-id on this FVT; ScoreLink.enabled is true. Row key cannot be removed."
        true
    )
    (defun C_ToggleScoreLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Turn ScoreLink.enabled on or off for (fvt-id, score-id); off \
            \ excludes score from FVT aggregates and RPS denominator."
        true
    )
    ;;Reward tokens (FVT|T|RewardLink + RPS rows) — key is permanent; no delete. Add = enabled true; Toggle = on/off.
    (defun C_AddRewardLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Register a reward DPTF on this FVT; RewardLink.enabled is true. Row key cannot be removed."
        true
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Turn RewardLink.enabled on or off for (fvt-id, \
            \ reward-dptf-id); off disables emissions/collection for that \
            \ token."
        true
    )
    ;;RPS economics (FVT|T|RPS|Global / FVT|T|RPS|User)
    (defun C_Inject:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Inject reward amount for a reward dptf-id; updates \
            \ current-rps and available-rewards when total score non-zero."
        true
    )
    (defun C_Collect:object{IgnisCollectorV1.OutputCumulator}
        ()
        @doc "Collect accrued rewards for caller into the chosen reward \
            \ dptf-id (pending + delta RPS, dust rule)."
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
(create-table FVT|T)
(create-table FVT|T|ScoreLink)
(create-table FVT|T|RewardLink)
(create-table FVT|T|RPS|Global)
(create-table FVT|T|RPS|User)