;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 3 of 24
;; This is STEP 3 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-2 must have run first, including the init steps between deploys.
;; 3 source file(s), 332,277 gas measured in the REPL gas model, 301,107 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact
;;
;; TOTAL: 5 interface(s), 3 module(s), 13 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact
;;      interface  BrandingUsagePrimaryV2
;;      interface  DemiourgosPactTrueFungibleV2
;;      module     DPTF
;;      table      P|T
;;      table      P|MT
;;      table      DPTF|PropertiesTable
;;      table      DPTF|BalanceTable
;;      table      DPTF|RoleTable
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
;;      interface  DpofUdcV2
;;      interface  DemiourgosPactOrtoFungibleV2
;;      module     DPOF
;;      table      P|T
;;      table      P|MT
;;      table      DPOF|T|Properties
;;      table      DPOF|T|Nonces
;;      table      DPOF|T|VerumRoles
;;      table      DPOF|T|AccountRoles
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact
;;      interface  EliteV2
;;      module     ELITE
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingUsagePrimaryV2
    @doc "Exposes Branding Functions for True-Fungibles (T), Orto-Fungibles (M), ATS-Pairs (A) and SWP-Pairs (S)"

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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosPactTrueFungibleV2
    @doc "Exposes most of the Functions related to True-Fungibles"

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
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV2.DPTF|BalanceSchema} (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string))
    ;;{5.2}  Compute [UC]
    (defun UC_IdAccount:string (id:string account:string))
    (defun UC_VolumetricTax (id:string amount:decimal))
    (defun UC_TreasuryLowestDispo (ouro-supply:decimal ouro-precision:integer dispo-type:integer tdp:decimal tds:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UC]
    ;;
    (defun URU_UpgradeTruefungibleToV2 (ids:[string]))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [0] DPTF|PropertiesTable:{DPTF|PropertiesSchema}
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_Paused:bool (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_OriginMint:bool (id:string))
    (defun UR_OriginAmount:decimal (id:string))
    (defun UR_FeeToggle:bool (id:string))
    (defun UR_MinMove:decimal (id:string))
    (defun UR_FeePromile:decimal (id:string))
    (defun UR_FeeTarget:string (id:string))
    (defun UR_FeeLock:bool (id:string))
    (defun UR_FeeUnlocks:integer (id:string))
    (defun UR_PrimaryFeeVolume:decimal (id:string))
    (defun UR_SecondaryFeeVolume:decimal (id:string))
    (defun UR_RewardToken:[string] (id:string))
    (defun UR_RewardBearingToken:[string] (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Hibernation:string (id:string))
    (defun UR_Frozen:string (id:string))
    (defun UR_Reservation:string (id:string))
    (defun UR_IzReservationOpen:bool (id:string))
    (defun UR_IzId:bool (id:string))
    ;;  [1]     DPTF|RoleTable:{DPTF|RoleSchema}
    (defun UR_Verum1:[string] (id:string))
    (defun UR_Verum2:[string] (id:string))
    (defun UR_Verum3:[string] (id:string))
    (defun UR_Verum4:[string] (id:string))
    (defun UR_Verum5:[string] (id:string))
    ;;  [2]     DPTF|BalanceTable:{OuronetDalosV2.DPTF|BalanceSchema}
    (defun UR_IzAccount:bool (id:string account:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_AccountFrozenState:bool (id:string account:string))
    (defun UR_AccountRoleBurn:bool (id:string account:string))
    (defun UR_AccountRoleMint:bool (id:string account:string))
    (defun UR_AccountRoleTransfer:bool (id:string account:string))
    (defun UR_AccountRoleFeeExemption:bool (id:string account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_IzRT:bool (reward-token:string))
    (defun URC_IzRTg:bool (atspair:string reward-token:string))
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
    (defun URC_IzCoreDPTF:bool (id:string))
    (defun URC_Fee:[decimal] (id:string amount:decimal))
        ;;
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URC_HasHibernation:bool (id:string))
    (defun URC_HasFrozen:bool (id:string))
    (defun URC_HasReserved:bool (id:string))
    (defun URCv_Parent:string (dptf:string))
    (defun URC_TreasuryLowestDispo:decimal ())
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldTrueFungibles:[string] (account:string))
    (defun URH_ExistingTrueFungibles:[string] (dptf:string))
    (defun URH_OwnedTrueFungibles:[string] (account:string))
    ;;
    ;;  [URCi] cost readers — single source per op (the C_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetFee:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string))
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string origin:bool))
    (defun URCi_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string))
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string))
    (defun URCi_ToggleFeeLockStoa:decimal (id:string toggle:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_ParentOwnership (dptf:string))
    (defun UEV_ExecutorIsKonto (executor:string id:string))
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string))
    (defun UEV_id (id:string))
    (defun UEV_CheckID:bool (id:string))
    (defun UEV_Amount (id:string amount:decimal))
    (defun UEV_CheckAmount:bool (id:string amount:decimal))
        ;;
    (defun UEV_CanChangeOwnerON (id:string))
    (defun UEV_CanUpgradeON (id:string))
    (defun UEV_CanAddSpecialRoleON (id:string))
    (defun UEV_CanFreezeON (id:string))
    (defun UEV_CanWipeON (id:string))
    (defun UEV_CanPauseON (id:string))
        ;;
    (defun UEV_PauseState (id:string state:bool))
    (defun UEV_ReservationState (id:string state:bool))
    (defun UEV_AccountBurnState (id:string account:string state:bool))
    (defun UEV_AccountTransferState (id:string account:string state:bool))
    (defun UEV_AccountFreezeState (id:string account:string state:bool))
    (defun UEV_Virgin (id:string))
    (defun UEV_FeeLockState (id:string state:bool))
    (defun UEV_FeeToggleState (id:string state:bool))
    (defun UEV_AccountMintState (id:string account:string state:bool))
    (defun UEV_AccountFeeExemptionState (id:string account:string state:bool))
    (defun UEV_Vesting (id:string existance:bool))
    (defun UEV_Sleeping (id:string existance:bool))
    (defun UEV_Hibernation (id:string existance:bool))
    (defun UEV_Frozen (id:string existance:bool))
    (defun UEV_Reserved (id:string existance:bool))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_IssueLP:object{IgnisCollectorV3.OutputCumulator} (name:string ticker:string))
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
    )
    (defun XBv_DeployAccount (id:string account:string))
    (defun XB_DeployAccountWNE (account:string id:string))
    (defun XBv_UpdateSupply (id:string amount:decimal direction:bool))
    (defun XE_UpdateFeeVolume (id:string amount:decimal primary:bool))
    (defun XE_UpdateRewardToken (atspair:string id:string direction:bool))
    (defun XE_UpdateRewardBearingToken (atspair:string id:string))
    (defun XE_UpdateVesting (dptf:string dpof:string))
    (defun XE_UpdateSleeping (dptf:string dpof:string))
    (defun XE_UpdateHibernation (dptf:string dpof:string))
    (defun XE_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dptf:string fr-tag:integer)
    )
    (defun XB_DebitTrueFungible (id:string account:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool))
    (defun XB_CreditTrueFungible (id:string account:string amount:decimal))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_UpdateTreasury (patron:string executor:string type:integer tdp:decimal tds:decimal))
    (defun A_WipeTreasuryDebt (patron:string executor:string))
    (defun A_WipeTreasuryDebtPartial (patron:string executor:string debt-to-be-wiped:decimal))
    ;;
    ;;  [C]
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer] 
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] 
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
    (defun C_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
        ;;
    (defun C_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
    (defun C_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string min-move-value:decimal))
    (defun C_SetFee:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string fee:decimal))
    (defun C_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string target:string))
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
        ;;
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string amount:decimal))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string amount:decimal origin:bool))
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string amount-to-be-wiped:decimal))
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))

)
;;
(module DPTF GOV
    @doc "DPTF — the True-Fungible token core, implementing DemiourgosPactTrueFungibleV2 and \
        \ the primary branding interface. It owns a properties table (ownership, decimals, \
        \ control flags, supply, fee config, reward-token/RBT and \
        \ vesting/sleeping/frozen/reservation links), a role table and a balance table. \
        \ Client ops include issue, mint/burn, control flags, pause, reservation, fee \
        \ set/target/lock/exemption, account freeze, mint/burn/transfer roles, wipe, \
        \ ownership rotation and treasury-debt admin."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements DemiourgosPactTrueFungibleV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPTF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPTF_ADMIN)))
    (defcap GOV|DPTF_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_DPTF)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "DPTF Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    (defcap GOV|SET_TREASURY-DISPO (type:integer tdp:decimal tds:decimal)
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            ;;Type can only pe 0, 1, 2 or 3
            ;;Type 0 = No Treasury Dispo
            ;;Type 1 = Maximum Dispo equal to Total Supply
            ;;Type 2 = Percent Based Dispo
            ;:Type 3 = Absolute Value Dispo in Thousands
            (enforce (= (contains type (enumerate 0 3)) true) "Treasury Dispo Type can only be 0, 1, 2 or 3!")
            (let
                (
                    (lowest-dispo:decimal (UC_TreasuryLowestDispo ouro-supply op type tdp tds))
                )
                (enforce
                    (<= lowest-dispo treasury-supply)
                    (format "A Type {} Treasury Dispo cannot be set at {} because it surpases the Current Treasury Value of {}" [type tdp treasury-supply])
                )
            )
        )
    )
    (defcap GOV|WIPE_ALL-TREASURY-DEBT ()
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")
            (compose-capability (SECURE))
        )
    )
    (defcap GOV|WIPE_PARTIAL-TREASURY-DEBT (debt-to-be-wiped:decimal)
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")
            (enforce (<= debt-to-be-wiped (abs treasury-supply))
                "Debt to be wiped must be smaller than or equal to the absolute value of the current Treasury Debt"
            )
            (compose-capability (SECURE))
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
    (defcap P|DPTF|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPTF|CALLER))
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
        (with-capability (GOV|DPTF_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPTF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPTF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPTF_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPTF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst DALOS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
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
    ;;{3.2}  schemas
    ;;
    (defschema DPTF|PropertiesSchema
        id:string
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-add-special-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        ;;
        is-paused:bool
        ;;
        supply:decimal
        origin-mint:bool
        origin-mint-amount:decimal
        ;;
        fee-toggle:bool
        min-move:decimal
        fee-promile:decimal
        fee-target:string
        fee-lock:bool
        fee-unlocks:integer
        primary-fee-volume:decimal
        secondary-fee-volume:decimal
        ;;
        reward-token:[string]
        reward-bearing-token:[string]
        ;;
        vesting-link:string
        sleeping-link:string
        hibernation-link:string
        frozen-link:string
        reservation-link:string
        reservation:bool
    )
    (defschema DPTF|RoleSchema
        a-frozen:[string]
        r-burn:[string]
        r-mint:[string]
        r-fee-exemption:[string]
        r-transfer:[string]
    )
    ;;{3.3}  tables
    (deftable DPTF|PropertiesTable:{DPTF|PropertiesSchema})             ;;Key = <DPTF-id>
    (deftable DPTF|RoleTable:{DPTF|RoleSchema})                         ;;Key = <DPTF-id>
    (deftable DPTF|BalanceTable:{OuronetDalosV2.DPTF|BalanceSchema})    ;;Key = <DPTF-id> + BAR + <account> 

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPTF|S>ROTATE-OWNERSHIP (id:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_Konto id) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (CAP_Owner id)
            (UEV_CanChangeOwnerON id)
        )
    )
    (defcap DPTF|S>CONTROL (id:string)
        @event
        (CAP_Owner id)
        (UEV_CanUpgradeON id)
    )
    (defcap DPTF|S>TOGGLE_PAUSE (id:string pause:bool)
        @event
        (if pause
            (UEV_CanPauseON id)
            true
        )
        (CAP_Owner id)
        (UEV_PauseState id (not pause))
    )
    (defcap DPTF|S>TOGGLE_RESERVATION (id:string toggle:bool)
        @event
        (CAP_Owner id)
        (UEV_ReservationState id (not toggle))
    )
    ;;
    (defcap DPTF|S>SET_FEE (id:string fee:decimal)
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UEV_Fee fee)
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>SET_FEE-TARGET (id:string target:string) ;;add blacklisted accounts. eventual D Accounts.
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current-fee-target:string (UR_FeeTarget id))
                (target-type:bool (ref-DALOS::UR_AccountType target))
                (dalos-sc:string (ref-DALOS::GOV|DALOS|SC_NAME))
                (orbr-sc:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
            )
            (enforce (!= target current-fee-target) "New Fee Target must be different than the current <fee-target>")
            (if target-type
                (enforce (or (= target dalos-sc)(= target orbr-sc)) "As Smart OURONET Accounts, only DALOS and OUROBOROS can be set as as fee Target")
                (ref-DALOS::UEV_EnforceAccountExists target)
            )
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>SET_MIN-MOVE (id:string min-move-value:decimal)
        @event
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor min-move-value decimals) min-move-value)
                (format "Min tr amount {} does not conform with the {} DPTF dec. no." [min-move-value id])
            )
            (enforce (or (= min-move-value -1.0) (> min-move-value 0.0)) "Min-Move Value does not compute")
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>TOGGLE_FEE (id:string toggle:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fee-promile:decimal (UR_FeePromile id))
            )
            (enforce (or (= fee-promile -1.0) (and (>= fee-promile 0.0) (<= fee-promile 1000.0))) "Please Set up Fee Promile before Turning Fee Collection on !")
            (ref-DALOS::UEV_EnforceAccountExists (UR_FeeTarget id))
            (CAP_Owner id)
            (UEV_FeeLockState id false)
            (UEV_FeeToggleState id (not toggle))
        )
    )
    (defcap DPTF|S>X_TG_FEE-LOCK (id:string toggle:bool)
        (CAP_Owner id)
        (UEV_FeeLockState id (not toggle))
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
    ;;
    (defcap DPTF|C>UPDATE-BRD (dptf:string)
        @event
        (UEV_ParentOwnership dptf)
        (compose-capability (P|DPTF|CALLER))
    )
    (defcap DPTF|C>UPGRADE-BRD (dptf:string)
        @event
        (UEV_ParentOwnership dptf)
        (compose-capability (P|DPTF|CALLER))
    )
    ;;
    (defcap DPTF|C>ISSUE (account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length name))
                (l2:integer (length ticker))
                (l3:integer (length decimals))
                (l4:integer (length can-change-owner))
                (l5:integer (length can-upgrade))
                (l6:integer (length can-add-special-role))
                (l7:integer (length can-freeze))
                (l8:integer (length can-wipe))
                (l9:integer (length can-pause))
                (lengths:[integer] [l1 l2 l3 l4 l5 l6 l7 l8 l9])
            )
            (ref-U|INT::UEV_UniformList lengths)
            (ref-U|LST::UEV_IzUnique name)
            (ref-U|LST::UEV_IzUnique ticker)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;
    (defcap DPTF|C>TOGGLE_FEE-LOCK (id:string toggle:bool)
        @event
        (compose-capability (DPTF|S>X_TG_FEE-LOCK id toggle))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DPTF|C>FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        @event
        (compose-capability (DPTF|C>X_FREEZE id account frozen))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_FREEZE (id:string account:string frozen:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountFreezeState id account (not frozen))
            (if frozen
                (UEV_CanFreezeON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-BURN-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountBurnState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE-MINT-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-MINT-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-MINT-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountMintState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
        (compose-capability (P|DPTF|CALLER))
    )
    (defcap DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (ref-DALOS::UEV_EnforceAccountType account true)
            (CAP_Owner id)
            (UEV_AccountFeeExemptionState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE_TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (special:[string] ["F|" "R|"])
                (ft:string (take 2 id))
                (iz-special:bool (contains ft special))
            )
            ;;Frozen and Reserved Special Tokens can use Core Smart Ouronet Accounts for Transfer Roles Setup.
            (if (not iz-special)
                (do
                    (ref-DALOS::UEV_NotSmartOuronetAccount account)
                    (UEV_AccountTransferState id account (not toggle))
                )
                true
            )
            (CAP_Owner id)
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>BURN (id:string client:string amount:decimal)
        @event
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_AccountBurnState id client true)
            (compose-capability (DPTF|C>DEBIT client id amount (ref-U|DPTF::UDC_EmptyDispo) false))
        )
    )
    (defcap DPTF|C>MINT (id:string client:string amount:decimal origin:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (lp-prefix:[string] ["S|" "W|" "P|"])
                (ft:string (take 2 id))
                (iz-lp:bool (contains ft lp-prefix))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (if origin
                (do
                    (CAP_Owner id)
                    (UEV_Virgin id)
                    (if (not iz-lp)
                        (ref-DALOS::UEV_NotSmartOuronetAccount client)
                        true
                    )
                )
                (UEV_AccountMintState id client true)  
            )
            (compose-capability (DPTF|C>CREDIT client id amount))
        )
    )
    (defcap DPTF|C>WIPE-SLIM (id:string account-to-be-wiped:string amount:decimal)
        @event
        (compose-capability (DPTF|C>X_WIPE id account-to-be-wiped amount))
    )
    (defcap DPTF|C>WIPE (id:string account-to-be-wiped:string)
        @event
        (compose-capability (DPTF|C>X_WIPE id account-to-be-wiped (UR_AccountSupply id account-to-be-wiped)))
    )
    (defcap DPTF|C>X_WIPE (id:string account-to-be-wiped:string amount:decimal)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_CanWipeON id)
            (UEV_AccountFreezeState id account-to-be-wiped true)
            (compose-capability (DPTF|C>DEBIT account-to-be-wiped id amount (ref-U|DPTF::UDC_EmptyDispo) true))
        )
    )
    ;;
    (defcap DPTF|C>DEBIT (account:string id:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool)
        (UEV_Amount id amount)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current-supply:decimal (UR_AccountSupply id account))
                (debit-result:decimal (- current-supply amount))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
            )
            (if (= id ouro-id)
                (let
                    (
                        (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                        (ea-id:string (ref-DALOS::UR_EliteAurynID))
                        (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                        (account-type:bool (ref-DALOS::UR_AccountType account))
                        (lowest-dispo:decimal
                            (if account-type
                                (if (= account treasury)
                                    (URC_TreasuryLowestDispo)
                                    0.0
                                )
                                (if (= ea-id BAR)
                                    0.0
                                    (- (ref-U|DPTF::UC_OuroDispo dispo-data))
                                )
                            )
                        )
                    )
                    (enforce (>= debit-result lowest-dispo) (format "Cannot Debit OURO from {}, dispo capabilities exceeded!" [account]))
                )
                (enforce (>= debit-result 0.0) (format "Cannot Debit DPTF {} from {} into the negatives" [id account]))
            )
            (if wipe-mode
                (CAP_Owner id)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            (if (and (= id ouro-id) wipe-mode)
                ;;UNREACHABLE -- a fail-closed backstop that no input can trip. Proven in
                ;;REPL/modules/DPTF.repl <<DPTF-G7>> section 02, four facts: (a) wipe-mode TRUE
                ;;implies the wipe path (all five external callers in 09_TFT pass FALSE);
                ;;(b) the wipe path always passes UDC_EmptyDispo, so the floor is 0.0;
                ;;(c) the treasury -- the only account with a non-zero floor -- is a SMART account
                ;;and can never be frozen, hence never wiped; (d) UEV_Amount forces amount > 0.0.
                ;;Compose (b)+(d): reaching this line at all requires current-supply > 0, which is
                ;;exactly what it tests. NOTE: the condition tests current-supply while the message
                ;;names the amount; if `(> amount 0.0)` was intended, (d) already enforces it.
                (enforce (> current-supply 0.0) "Can only Debit positive OURO Amounts")
                true
            )
            (compose-capability (SECURE))
        )
    )
    (defcap DPTF|C>CREDIT (account:string id:string amount:decimal)
        (UEV_Amount id amount)
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>UPDATE-SPECIAL (main-dptf:string secondary-dptf:string fr-tag:integer)
        ;;UNREACHABLE BY CONSTRUCTION, and a DUPLICATE. The only path in is
        ;;VST::XI_CreateSpecialTrueFungibleLink -> XE_UpdateSpecialTrueFungible, and VST already
        ;;runs the identical check under the identical message in VST|C>REPURPOSE-TRUE-FUNGIBLE.
        ;;Every caller passes a literal 1 or 2 and no client supplies <fr-tag>. Kept as this
        ;;module's own fail-closed backstop for a future external caller; because the wording is
        ;;shared with VST it also cannot be pinned distinctly by message.
        (enforce (contains fr-tag [1 2]) "Invalid Frozen|Reserve Tag")
        (let
            (
                (main-special-id:string
                    (cond
                        ((= fr-tag 1) (UR_Frozen main-dptf))
                        ((= fr-tag 2) (UR_Reservation main-dptf))
                        BAR
                    )
                )
                (secondary-special-id:string
                    (cond
                        ((= fr-tag 1) (UR_Frozen secondary-dptf))
                        ((= fr-tag 2) (UR_Reservation secondary-dptf))
                        BAR
                    )
                )
                (iz-secondary-rt:bool (URC_IzRT secondary-dptf))
                (iz-secondary-rbt:bool (URC_IzRBT secondary-dptf))
                (main-dptf-ftc:string (take 2 main-dptf))
            )
            (CAP_Owner main-dptf)
            (CAP_Owner secondary-dptf)
            (enforce
                (and (= main-special-id BAR) (= secondary-special-id BAR) )
                "Special True Fungible Links (Frozen or Reserved) are immutable !"
            )
            ;;UNREACHABLE -- <secondary-dptf> is ALWAYS a token issued moments earlier, and a
            ;;just-issued token can be neither an RT nor a Cold-RBT (both require registration on
            ;;an ATS pair, which cannot have happened yet). The single caller,
            ;;VST::XI_CreateSpecialTrueFungibleLink, calls DPTF::XB_IssueFree and passes THAT id
            ;;straight into XE_UpdateSpecialTrueFungible in the same expression -- there is no input
            ;;by which a client names the secondary. Fail-closed backstop for a future caller that
            ;;does. Its sibling one `cond` below (the Special/LP prefix rule on the MAIN token) IS
            ;;reachable and is pinned by REPL/modules/VST.repl <<VST-G9>>.
            (enforce
                (and (not iz-secondary-rt) (not iz-secondary-rbt))
                "Special True Fungible cannot be RTs or Cold-RBTs"
            )
            (cond
                ((= fr-tag 1)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|"]))
                        (format "When setting a Frozen Link, the main DPTF {} cannot be a Special Token" [main-dptf])
                        ;;But can be an LP Token
                    )
                )
                ((= fr-tag 2)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Reserve Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                true
            )
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]

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
    ;;
    (defun UDC_VerumRoles:object{DPTF|RoleSchema}
        (a:[string] b:[string] c:[string] d:[string] e:[string])
        {"a-frozen"             : a
        ,"r-burn"               : b
        ,"r-mint"               : c
        ,"r-fee-exemption"      : d
        ,"r-transfer"           : e}
    )
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV2.DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UDC_TrueFungibleAccount a b c d e f g h)
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IdAccount:string (id:string account:string)
        (format "{}{}{}" [id BAR account])
    )
    (defun UC_VolumetricTax (id:string amount:decimal)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_Amount id amount)
            (ref-U|DPTF::UC_VolumetricTax (UR_Decimals id) amount)
        )
    )
    (defun UC_TreasuryLowestDispo
        (ouro-supply:decimal ouro-precision:integer dispo-type:integer tdp:decimal tds:decimal)
        (let
            (
                (max-dispo:decimal
                    (cond
                        ((= dispo-type 1) ouro-supply)
                        ((= dispo-type 2) (floor (/ (* tdp ouro-supply) 1000.0) ouro-precision))
                        ((= dispo-type 3) (floor (* tds 1000.0) ouro-precision))
                        0.0
                    )
                )
            )
            (- 0.0 max-dispo)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URU_UpgradeTruefungibleToV2 (ids:[string])
        (map
            (lambda
                (id:string)
                (UR_Hibernation id)
            )
            ids
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys DPTF|PropertiesTable)
    )
    (defun UR_KEYS:[string] ()
        (keys DPTF|BalanceTable)
    )
    ;;
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPTF|PropertiesTable id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPTF|PropertiesTable id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPTF|PropertiesTable id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPTF|PropertiesTable id ["decimals"]))
    )
    ;;
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPTF|PropertiesTable id ["can-upgrade"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPTF|PropertiesTable id ["can-change-owner"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPTF|PropertiesTable id ["can-add-special-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPTF|PropertiesTable id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPTF|PropertiesTable id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPTF|PropertiesTable id ["can-pause"]))
    )
    ;;
    (defun UR_Paused:bool (id:string)
        (at "is-paused" (read DPTF|PropertiesTable id ["is-paused"]))
    )
    ;;
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPTF|PropertiesTable id ["supply"]))
    )
    (defun UR_OriginMint:bool (id:string)
        (at "origin-mint" (read DPTF|PropertiesTable id ["origin-mint"]))
    )
    (defun UR_OriginAmount:decimal (id:string)
        (at "origin-mint-amount" (read DPTF|PropertiesTable id ["origin-mint-amount"]))
    )
    ;;
    (defun UR_FeeToggle:bool (id:string)
        (at "fee-toggle" (read DPTF|PropertiesTable id ["fee-toggle"]))
    )
    (defun UR_MinMove:decimal (id:string)
        (at "min-move" (read DPTF|PropertiesTable id ["min-move"]))
    )
    (defun UR_FeePromile:decimal (id:string)
        (at "fee-promile" (read DPTF|PropertiesTable id ["fee-promile"]))
    )
    (defun UR_FeeTarget:string (id:string)
        (at "fee-target" (read DPTF|PropertiesTable id ["fee-target"]))
    )
    (defun UR_FeeLock:bool (id:string)
        (at "fee-lock" (read DPTF|PropertiesTable id ["fee-lock"]))
    )
    (defun UR_FeeUnlocks:integer (id:string)
        (at "fee-unlocks" (read DPTF|PropertiesTable id ["fee-unlocks"]))
    )
    (defun UR_PrimaryFeeVolume:decimal (id:string)
        (at "primary-fee-volume" (read DPTF|PropertiesTable id ["primary-fee-volume"]))
    )
    (defun UR_SecondaryFeeVolume:decimal (id:string)
        (at "secondary-fee-volume" (read DPTF|PropertiesTable id ["secondary-fee-volume"]))
    )
    ;;
    (defun UR_RewardToken:[string] (id:string)
        (at "reward-token" (read DPTF|PropertiesTable id ["reward-token"]))
    )
    (defun UR_RewardBearingToken:[string] (id:string)
        (at "reward-bearing-token" (read DPTF|PropertiesTable id ["reward-bearing-token"]))
    )
    ;;
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPTF|PropertiesTable id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPTF|PropertiesTable id ["sleeping-link"]))
    )
    (defun UR_Hibernation:string (id:string)
        ;;#30M fix: was a "read" that silently backfilled a missing hibernation-link with a
        ;;live table `update` - a read/write-separation violation of the UR_* prefix contract.
        ;;Confirmed via a live StoaChain dirty-read (2026-08-28, see
        ;;OuronetInformational/memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md)
        ;;that every one of the 18 real deployed DPTF tokens already has this field populated -
        ;;the backfill branch was fully dead code, so no migration step was needed. The write is
        ;;removed; the in-memory default-value fallback (for any future schema-incomplete row)
        ;;is kept, so the return value is unchanged for every caller.
        (let
            (
                (default-value:string BAR)
                (temp (read DPTF|PropertiesTable id ["hibernation-link"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernation-link" temp))
        )
    )
    (defun UR_Frozen:string (id:string)
        (at "frozen-link" (read DPTF|PropertiesTable id ["frozen-link"]))
    )
    (defun UR_Reservation:string (id:string)
        (at "reservation-link" (read DPTF|PropertiesTable id ["reservation-link"]))
    )
    (defun UR_IzReservationOpen:bool (id:string)
        (at "reservation" (read DPTF|PropertiesTable id ["reservation"]))
    )
    ;;
    (defun UR_IzId:bool (id:string)
        (let
            (
                (trial (try false (read DPTF|PropertiesTable id))) 
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_Verum1:[string] (id:string)
        (at "a-frozen" (read DPTF|RoleTable id ["a-frozen"]))
    )
    (defun UR_Verum2:[string] (id:string)
        (at "r-burn" (read DPTF|RoleTable id ["r-burn"]))
    )
    (defun UR_Verum3:[string] (id:string)
        (at "r-mint" (read DPTF|RoleTable id ["r-mint"]))
    )
    (defun UR_Verum4:[string] (id:string)
        (at "r-fee-exemption" (read DPTF|RoleTable id ["r-fee-exemption"]))
    )
    (defun UR_Verum5:[string] (id:string)
        (at "r-transfer" (read DPTF|RoleTable id ["r-transfer"]))
    )
    ;;
    ;;
    (defun UR_IzAccount:bool (id:string account:string)
        (let
            (
                (trial (try false (read DPTF|BalanceTable (UC_IdAccount id account))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun UR_AccountSupply:decimal (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::UR_TF_AccountSupply account (= id (ref-DALOS::UR_OuroborosID)))
                (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                    { "balance" : 0.0 }
                    { "balance" := b}
                    b
                )
            )
        )
    )
    (defun UR_AccountFrozenState:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (and
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountFreezeState account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "frozen" : false}
                        { "frozen" := fr }
                        fr
                    )
                )
                (not (ref-DALOS::UR_AutonomicRoles account))
            )
        )
    )
    (defun UR_AccountRoleBurn:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleBurn account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-burn" : false}
                        { "role-burn" := rb }
                        rb
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
            
        )
    )
    (defun UR_AccountRoleMint:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleMint account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-mint" : false}
                        { "role-mint" := rm }
                        rm
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_AccountRoleTransfer:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleTransfer account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-transfer" : false}
                        { "role-transfer" := rt }
                        rt
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
            
        )
    )
    (defun UR_AccountRoleFeeExemption:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner:string (UR_Konto id))
            )
            (fold (or) false
                [
                    (if (URC_IzCoreDPTF id)
                        (ref-DALOS::UR_TF_AccountRoleFeeExemption account (= id (ref-DALOS::UR_OuroborosID)))
                        (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                            { "role-fee-exemption" : false}
                            { "role-fee-exemption" := rfe }
                            rfe
                        )
                    )
                    (= account owner)
                    (ref-DALOS::UR_AutonomicRoles account)
                ]
            )
        )
    )
    (defun URC_IzRT:bool (reward-token:string)
        @doc "Returns a boolean, if token id is RT in any atspair"
        (UEV_id reward-token)
        (if (= (UR_RewardToken reward-token) [BAR])
            false
            true
        )
    )
    (defun URC_IzRTg:bool (atspair:string reward-token:string)
        @doc "Returns a boolean, if token id is RT in a specific atspair"
        (UEV_id reward-token)
        (if (= (UR_RewardToken reward-token) [BAR])
            false
            (if (= (contains atspair (UR_RewardToken reward-token)) true)
                true
                false
            )
        )
    )
    (defun URC_IzRBT:bool (reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in any atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) [BAR])
            false
            true
        )
    )
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in a specific atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) [BAR])
            false
            (if (contains atspair (UR_RewardBearingToken reward-bearing-token))
                true
                false
            )
        )
    )
    (defun URC_IzCoreDPTF:bool (id:string)
        @doc "Returns a boolean, if id is a Core DPTF \
            \ Core DPTFs are OUROBOROS and IGNIS"
        (UEV_id id)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (iz-ouro-defined:bool (not (= ouro-id BAR)))
                (iz-ignis-defined:bool (not (= ignis-id BAR)))
            )
            (if (not iz-ouro-defined)
                (if (not iz-ignis-defined)
                        false
                        (= id ignis-id)
                    )
                (if (= id ouro-id)
                    true
                    (if (not iz-ignis-defined)
                        false
                        (= id ignis-id)
                    )
                )
            )
        )
    )
    (defun URC_Fee:[decimal] (id:string amount:decimal)
        @doc "Computes the DPTF transfer fee split given a DPTF Id and amount \
            \ Returns a list of decimals: \
            \ <primary-fee-value> - the actual transfer fee \
            \ <secondary-fee-value> - results when to many Fee-Unlocks have been executed \
            \ <remainder> - the Token amount that reaches the target"
        (let
            (
                (fee-toggle:bool (UR_FeeToggle id))
            )
            (if (= fee-toggle false)
                [0.0 0.0 amount]
                (let
                    (
                        (precision:integer (UR_Decimals id))
                        (fee-promile:decimal (UR_FeePromile id))
                        (fee-unlocks:integer (UR_FeeUnlocks id))
                        (volumetric-fee:decimal (UC_VolumetricTax id amount))
                        (primary-fee-value:decimal
                            (if (= fee-promile -1.0)
                                volumetric-fee
                                (floor (* (/ fee-promile 1000.0) amount) precision)
                            )
                        )
                        (secondary-fee-value:decimal
                            (if (= fee-unlocks 0)
                                0.0
                                (* (dec fee-unlocks) volumetric-fee)
                            )
                        )
                        (remainder:decimal (- amount (+ primary-fee-value secondary-fee-value)))
                    )
                    [primary-fee-value secondary-fee-value remainder]
                )
            )
        )
    )
    ;;
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPTF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPTF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URC_HasHibernation:bool (id:string)
        @doc "Returns a boolean if DPTF has a hibernation counterpart"
        (if (= (UR_Hibernation id) BAR)
            false
            true
        )
    )
    (defun URC_HasFrozen:bool (id:string)
        @doc "Returns a boolean if DPTF has a frozen counterpart"
        (if (= (UR_Frozen id) BAR)
            false
            true
        )
    )
    (defun URC_HasReserved:bool (id:string)
        @doc "Returns a boolean if DPTF has a reserved counterpart"
        (if (= (UR_Reservation id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dptf:string)
        @doc "Computes <dptf> parent"
        (let
            (
                (fourth:string (drop 3 (take 4 dptf)))
            )
            (enforce (!= fourth BAR) "Frozen LP Tokens not allowed for this operation")
            (let
                (
                    (first-two:string (take 2 dptf))
                )
                (cond
                    ((= first-two "F|") (UR_Frozen dptf))
                    ((= first-two "R|") (UR_Reservation dptf))
                    dptf
                )
            )
        )
    )
    (defun URC_TreasuryLowestDispo:decimal ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
            )
            (UC_TreasuryLowestDispo
                (UR_Supply ouro)
                (UR_Decimals ouro)
                (ref-DALOS::UR_DispoType)
                (ref-DALOS::UR_DispoTDP)
                (ref-DALOS::UR_DispoTDS)
            )
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1] Returns True Fungibles held by Account
    (defun URH_HeldTrueFungibles:[string] (account:string)
        @doc "Returns all True Fungibles that are registered for a given <account>"
        (map (at "id")
            (select DPTF|BalanceTable ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts that are registered for a given DPTF
    (defun URH_ExistingTrueFungibles:[string] (dptf:string)
        @doc "Returns all Ouronet Accounts that are registered for a given <dptf>"
        (map (at "account")
            (select DPTF|BalanceTable ["account"]
                (where "id" (= dptf))
            )
        )
    )
    ;;3]Returns a List of DPTFs that are owned by a given Account for Management Purposes
    (defun URH_OwnedTrueFungibles:[string] (account:string)
        @doc "Returns all True Fungibles that can be managed by the given <account>"
        (map (at "id")
            (select DPTF|PropertiesTable ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;[URCi] cost readers — the single cost source per client/forward op. The C_/XE_ returns its URCi
    ;;  (billing); Phase 1.2 INFO previews from the same reader. Each == the prior inline cumulator.
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_Konto entity-id) 1.0)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_RotateOwnership" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Control" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_TogglePause" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleReservation" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFee" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetMinMove" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetFee:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetFee" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetFeeTarget" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFreezeAccount" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleBurnRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleMintRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFeeExemptionRole" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleTransferRole" "usage")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_WipeSlim" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Wipe" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string)
        ;;REFUSAL PARITY (family K, 2026-09-15): this reader is shared by the exec's cumulator and
        ;;by INFO_DPTF|Burn, and without this line the PREVIEW narrated
        ;;"Succesfully burned 1.0 NOSUCHTOKEN-98c486052a51 on Account ..." for a token that does not
        ;;exist, while C_Burn refuses with UEV_id's own message. A non-existent token is a
        ;;STRUCTURAL impossibility -- no action by the caller makes the op available -- so the quote
        ;;was simply wrong, not merely optimistic about a balance. Guarded HERE rather than in the
        ;;INFO wrapper so both paths keep using one message.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-002b>>.
        (UEV_id id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "DPTF|C_Burn" "usage") account (ref-IGNIS::URC_ZeroGAS id account) [])
        )
    )
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string origin:bool)
        ;;REFUSAL PARITY (family K, 2026-09-15): this reader is shared by the exec's cumulator and
        ;;by INFO_DPTF|Mint, and without this line the PREVIEW narrated
        ;;"Succesfully minted 1.0 NOSUCHTOKEN-98c486052a51 on Account ..." for a token that does not
        ;;exist, while C_Mint refuses with UEV_id's own message. A non-existent token is a
        ;;STRUCTURAL impossibility -- no action by the caller makes the op available -- so the quote
        ;;was simply wrong, not merely optimistic about a balance. Guarded HERE rather than in the
        ;;INFO wrapper so both paths keep using one message.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-002c>>.
        (UEV_id id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Mint" "usage")
                account (ref-IGNIS::URC_ZeroGAS id account) []
            )
        )
    )
    (defun URCi_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_LegCumulator "special-tf-link" (UR_Konto main-dptf))
        )
    )
    ;;  Group C — pure cost readers whose cumulator/price were previously coupled to a write.
    ;;  ToggleFeeLock: full cumulator, re-derived from fee-unlocks (must be read PRE-increment — see C_).
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    ;;  Issue: two native/gas price rails per issued token; the cumulator's output (created IDs) stays in XB_IssueFree.
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): true fungible issuance = $10 = 1000 ignis/token (owner 2026-09-05). \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-tf"))
               (ref-IGNIS::UC_IgnisComponents "DPTF|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (true fungible = $10 => 100 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-tf"))
        )
    )
    ;;  UpgradeBranding: STOA price is unconditionally months x "blue" (BRD's XE_UpgradeBranding returns the same).
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;  DeployAccount: CORE XBv_DeployAccount returns no cumulator; the ignis|small toll is billed
    ;;  by Talos keyed on the deployed account. This reader single-sources that toll for exec + INFO.
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string)
        @doc "IGNIS cost of DELIBERATE token-account creation (the explicit DPTF|C_DeployAccount \
            \ entrypoint, billed at its Talos wrapper): the central IG|DETER token-account tier \
            \ (50) — an anti-spam deterrent per owner 2026-09-05. Auto-creation inside a transfer \
            \ never reaches this reader and stays FREE (S1 constraint). Shared by exec + INFO_*."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_DeployAccount" "token-account")
                account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  ToggleFeeLock STOA leg: the unlock price rail (0.0 when locking); mirrors the STOA amount
    ;;  C_ToggleFeeLock collects (at 1 (IGNIS::UC_FeeUnlockPrice)) — FLAT since 2026-09-06; the
    ;;  <fee-unlocks> count no longer scales it (this line described the retired ladder). Pure.
    (defun URCi_ToggleFeeLockStoa:decimal (id:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_ParentOwnership (dptf:string)
        @doc "Enforces: \
            \ <dptf> Ownership, if <dptf> is pure \
            \ <(UR_Frozen dptf)>, if its a f|dptf \
            \ (UR_Reservation dptf), if its a r|dptf \
            \ While ensuring a Frozen LP cant be used for this operation."
        (CAP_Owner (URCv_Parent dptf))
    )
    (defun UEV_ExecutorIsKonto (executor:string id:string)
        @doc "BINDS the named <executor> to DPTF <id>'s owner. \
            \ \
            \ Ownership of <executor> is proven INDIRECTLY: every entrypoint that calls this \
            \ reaches <CAP_Owner id>, which enforces ownership of <(UR_Konto id)>. This supplies \
            \ the other half -- that the account the caller NAMED is that same owner. Without \
            \ it the executor parameter would be DECORATIVE, a name the function never reads, \
            \ which is worse than absent because it reads as verified. \
            \ (patron/executor canon 2.2: an indirect route is permitted and MUST be named.) \
            \ \
            \ NOT used by C_Mint / C_Burn. Their capabilities enforce \
            \ CAP_EnforceAccountOwnership on the executor DIRECTLY and unconditionally, so the \
            \ executor is already proven there and a binding would re-check a settled fact."
        (enforce (= executor (UR_Konto id)) "Executor is not the Token Owner")
    )
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string)
        @doc "The <UEV_ExecutorIsKonto> binding for the BRANDING entrypoints, whose authority is \
            \ the PARENT token's owner rather than the entity's own -- branding an f|/r| variant \
            \ is the pure parent's right. Mirrors <UEV_ParentOwnership>, which is the capability \
            \ half of the same pair."
        (enforce (= executor (UR_Konto (URCv_Parent entity-id))) "Executor is not the Parent Token Owner")
    )
    (defun UEV_id (id:string)
        (with-default-read DPTF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPTF ID {} does not exist" [id])
            )
        )
    )
    (defun UEV_CheckID:bool (id:string)
        (with-default-read DPTF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (if (>= s 0.0)
                true
                false
            )
        )
    )
    (defun UEV_Amount (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor amount decimals) amount)
                (format "{} is not conform with the {} prec." [amount id])
            )
            (enforce
                (> amount 0.0)
                (format "{} is not a Valid Transaction amount" [amount])
            )
        )
    )
    (defun UEV_CheckAmount:bool (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
                (decimal-check:bool (if (= (floor amount decimals) amount) true false))
                (positivity-check:bool (if (> amount 0.0) true false))
                (result:bool (and decimal-check positivity-check))
            )
            result
        )
    )
    (defun UEV_CanChangeOwnerON (id:string)
        (let
            (
                (x:bool (UR_CanChangeOwner id))
            )
            (enforce x (format "{} ownership cannot be changed" [id]))
        )
    )
    (defun UEV_CanUpgradeON (id:string)
        (let
            (
                (x:bool (UR_CanUpgrade id))
            )
            (enforce x (format "{} properties cannot be upgraded" [id]))
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id))
            )
            (enforce x (format "For {} no special roles can be added" [id])
            )
        )
    )
    (defun UEV_CanFreezeON (id:string)
        (let
            (
                (x:bool (UR_CanFreeze id))
            )
            (enforce x (format "{} cannot be freezed" [id])
            )
        )
    )
    (defun UEV_CanWipeON (id:string)
        (let
            (
                (x:bool (UR_CanWipe id))
            )
            (enforce x (format "{} cannot be wiped" [id])
            )
        )
    )
    (defun UEV_CanPauseON (id:string)
        (let
            (
                (x:bool (UR_CanPause id))
            )
            (enforce x (format "{} cannot be paused" [id])
            )
        )
    )
    (defun UEV_PauseState (id:string state:bool)
        (let
            (
                (x:bool (UR_Paused id))
            )
            ;;Arm 1 fires when the token is NOT paused (it enforces x = is-paused), so the old
            ;;wording "must not be paused for action" said the opposite of the condition that
            ;;produced it. Aligned with DPOF/DPDC/DPMF, which all word this arm "is already
            ;;unpaused". Arm 2 was already correct and is left as-is.
            (if state
                (enforce x (format "{} is already unpaused" [id]))
                (enforce (not x) (format "{} is paused; transfers are paused" [id]))
            )
        )
    )
    (defun UEV_ReservationState (id:string state:bool)
        (let
            (
                (x:bool (UR_IzReservationOpen id))
            )
            ;;Both messages were INVERTED: arm 1 enforces x (= is-open) so it fires when
            ;;reservations are CLOSED, yet reported "already open"; arm 2 fires when they are
            ;;OPEN and reported "already closed". Swapped, so each names the state that actually
            ;;tripped it -- the same "is already <current state>" shape the sibling
            ;;UEV_PauseState guards use across DPOF/DPDC/DPMF.
            (if state
                (enforce x (format "{} is already closed for reservations" [id]))
                (enforce (not x) (format "{} is already open for reservations" [id]))
            )
        )
    )
    (defun UEV_AccountBurnState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleBurn id account))
            )
            (enforce (= x state) (format "Burn Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleTransfer id account))
            )
            (enforce (= x state) (format "Transfer Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFreezeState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountFrozenState id account))
            )
            (enforce (= x state) (format "Frozen for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Virgin (id:string)
        (let
            (
                (om:bool (UR_OriginMint id))
                (oma:decimal (UR_OriginAmount id))
            )
            (enforce
                (and (= om false) (= oma 0.0))
                (format "Origin Mint for {} is offline" [id])
            )
        )
    )
    (defun UEV_FeeLockState (id:string state:bool)
        (let
            (
                (x:bool (UR_FeeLock id))
            )
            (enforce (= x state) (format "Fee-lock for {} must be set to {} for exec" [id state]))
        )
    )
    (defun UEV_FeeToggleState (id:string state:bool)
        (let
            (
                (x:bool (UR_FeeToggle id))
            )
            (enforce (= x state) (format "Fee-Toggle for {} must be set to {} for exec" [id state]))
        )
    )
    (defun UEV_AccountMintState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleMint id account))
            )
            (enforce (= x state) (format "Mint Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFeeExemptionState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleFeeExemption id account))
            )
            (enforce (= x state) (format "Fee-Exemption Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Vesting (id:string existance:bool)
        (let
            (
                (has-vesting:bool (URC_HasVesting id))
            )
            (enforce (= has-vesting existance) (format "Vesting for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Sleeping (id:string existance:bool)
        (let
            (
                (has-sleeping:bool (URC_HasSleeping id))
            )
            (enforce (= has-sleeping existance) (format "Sleeping for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Hibernation (id:string existance:bool)
        (let
            (
                (has-hibernation:bool (URC_HasHibernation id))
            )
            (enforce (= has-hibernation existance) (format "Hibernation for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Frozen (id:string existance:bool)
        (let
            (
                (has-frozen:bool (URC_HasFrozen id))
            )
            (enforce (= has-frozen existance) (format "Frozen for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Reserved (id:string existance:bool)
        (let
            (
                (has-reserved:bool (URC_HasReserved id))
            )
            (enforce (= has-reserved existance) (format "Reserved for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces DPTF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_Konto id))
        )
    )
    ;;{5.5}  Write [W]
    (defun WW_UpdateBalance (id:string account:string new-balance:decimal)
        (require-capability (SECURE))
        (let
            (
                (tk:string (UC_IdAccount id account))
                (data-obj:object (read DPTF|BalanceTable tk))
                (has-removable:bool (contains "exist" data-obj))
                (new-balance-obj:object
                    (+
                        {"balance" : new-balance}
                        (remove "balance" data-obj)
                    )
                )
            )
            (write DPTF|BalanceTable tk
                (if has-removable
                    (remove "exist" new-balance-obj)
                    new-balance-obj
                )
            )
        )
    )
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_IssueLP:object{IgnisCollectorV3.OutputCumulator}
        (name:string ticker:string)
        @doc "Issues a DPTF Token as a Liquidity Pool Token. A LP DPTF follows specific rules in naming."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                )
                (XB_IssueFree swp-sc [name] [ticker] [24] [false] [false] [true] [false] [false] [false] [true])
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPTF|C>ISSUE
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
        (P|UEV_IMC)
        (with-capability (DPTF|C>ISSUE account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (l1:integer (length name))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (folded-lst:[string]
                        (fold
                            (lambda
                                (acc:[string] index:integer)
                                (let
                                    (
                                        (id:string
                                            (XIv_Issue
                                                account
                                                (at index name)
                                                (at index ticker)
                                                (at index decimals)
                                                (at index can-change-owner)
                                                (at index can-upgrade)
                                                (at index can-add-special-role)
                                                (at index can-freeze)
                                                (at index can-wipe)
                                                (at index can-pause)
                                                (at index iz-special)
                                            )
                                        )
                                    )
                                    (ref-BRD::XE_Issue id)
                                    (ref-U|LST::UC_AppL acc id)
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs account trigger folded-lst)
            )
        )
    )
    ;;Enforce: <account> existence cannot be relocated. There is no defcap on this path to
    ;;          host it, and the two Talos doors differ precisely here: the CLIENT door proves
    ;;          existence as a side effect of CAP_EnforceAccountOwnership, but the ADMIN door
    ;;          deliberately has NO ownership check on the target -- that absence is its reason
    ;;          to exist. Hoisting the check into the doors would therefore duplicate it into
    ;;          one that does not need it and one that does, and would leave XB_DeployAccountWNE's
    ;;          external callers (ATS/SWP/VST) unguarded. It guards the write, so it lives here.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_DeployAccount (id:string account:string)
        @doc "Activates DPTF <id> on <account> -- writes the zero balance row if absent, \
            \ preserving an existing row's fields. \
            \ \
            \ RECLASSIFIED FROM `C_DeployAccount` 2026-09-21 (owner). It was never a client \
            \ function: it builds no OutputCumulator, and it was called by `XIv_Issue` and \
            \ `XB_DeployAccountWNE` -- an X_ reaching into a C_, which inverts the layering. \
            \ A `C_` and an `A_` are the FINAL functions of a module, the ones Talos wraps; \
            \ nothing inside the module may call them. Both Talos doors now wrap this X_ \
            \ instead, and they are where the two policies differ: \
            \ \
            \   DPTF|C_DeployAccount  self-service. The caller must own <account>, and PAYS. \
            \   DPTF|A_DeployAccount  admin only. Deploys for SOMEONE ELSE, no ownership check \
            \                         on the target -- the case a user cannot serve. \
            \ \
            \ Neither is usually needed: an account is created automatically as required. Both \
            \ exist for flexibility."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (f:bool false)
                (tk:string (UC_IdAccount id account))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id)
            (with-default-read DPTF|BalanceTable tk
                (UDC_TrueFungibleAccount 0.0 f f f f f id account)
                {"balance"                  := b
                ,"frozen"                   := f
                ,"role-burn"                := rb
                ,"role-mint"                := rm
                ,"role-transfer"            := rt
                ,"role-fee-exemption"       := rfe
                ,"id"                       := i
                ,"account"                  := a
                }
                (write DPTF|BalanceTable tk
                    (UDC_TrueFungibleAccount b f rb rm rt rfe i a)
                )
            )
        )
    )
    ;;Enforce: per-element-in-map -- XB_IssueFree maps this over LISTS (name/ticker/decimals), so
    ;;          UEV_Decimals validates one element. DPTF|C>ISSUE receives the whole [integer] list and has
    ;;          no per-element loop; adding one purely for decimals is more code. (ATS does have such a
    ;;          loop, so ATS's copy was a true duplicate and was deleted.)
    ;;Protection: Class 2 — SECURE
    (defun XIv_Issue:string
        (
            account:string
            name:string
            ticker:string
            decimals:integer
            can-change-owner:bool
            can-upgrade:bool
            can-add-special-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            iz-special:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (id:string (ref-U|DALOS::UDC_Makeid ticker))
            )
            (ref-U|DALOS::UEV_Decimals decimals)
            (ref-U|DALOS::UEV_NameOrTicker name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker ticker false iz-special)
            (insert DPTF|PropertiesTable id
                {"id"                   : id
                ,"owner-konto"          : account
                ,"name"                 : name
                ,"ticker"               : ticker
                ,"decimals"             : decimals
                ;;
                ,"can-upgrade"          : can-upgrade
                ,"can-change-owner"     : can-change-owner
                ,"can-add-special-role" : can-add-special-role
                ,"can-freeze"           : can-freeze
                ,"can-wipe"             : can-wipe
                ,"can-pause"            : can-pause
                ;;
                ,"is-paused"            : false
                ;;
                ,"supply"               : 0.0
                ,"origin-mint"          : false
                ,"origin-mint-amount"   : 0.0
                ;;
                ,"fee-toggle"           : false
                ,"min-move"             : -1.0
                ,"fee-promile"          : 0.0
                ,"fee-target"           : OUROBOROS|SC_NAME
                ,"fee-lock"             : false
                ,"fee-unlocks"          : 0
                ,"primary-fee-volume"   : 0.0
                ,"secondary-fee-volume" : 0.0
                ;;
                ,"reward-token"         : [BAR]
                ,"reward-bearing-token" : [BAR]
                ;;
                ,"vesting-link"         : BAR
                ,"sleeping-link"        : BAR
                ,"frozen-link"          : BAR
                ,"reservation-link"     : BAR
                ,"hibernation-link"     : BAR
                ,"reservation"          : false}
            )
            (XI_WriteRoles id
                (UDC_VerumRoles
                    [BAR]
                    [BAR]
                    [BAR]
                    [BAR]
                    [BAR]
                )
            )
            (XBv_DeployAccount id account)
            id
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DeployAccountWNE (account:string id:string)
        (P|UEV_IMC)
        (let
            (
                (exist-account:bool (UR_IzAccount id account))
            )
            (if (not exist-account)
                (XBv_DeployAccount id account)
                true
            )
        )
    )
    ;;1]DPTF|PropertiesTable
    ;;Protection: Class 3 — Custom: DPTF|S>ROTATE-OWNERSHIP
    (defun XI_ChangeOwnership (id:string new-owner:string)
        (require-capability (DPTF|S>ROTATE-OWNERSHIP id new-owner))
        (update DPTF|PropertiesTable id
            {"owner-konto"                      : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>CONTROL
    (defun XI_Control (id:string can-upgrade:bool can-change-owner:bool can-add-special-role:bool can-freeze:bool can-wipe:bool can-pause:bool)
        (require-capability (DPTF|S>CONTROL id))
        (update DPTF|PropertiesTable id
            {"can-upgrade"                      : can-upgrade
            ,"can-change-owner"                 : can-change-owner
            ,"can-add-special-role"             : can-add-special-role
            ,"can-freeze"                       : can-freeze
            ,"can-wipe"                         : can-wipe
            ,"can-pause"                        : can-pause}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_PAUSE
    (defun XI_TogglePause (id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_PAUSE id toggle))
        (update DPTF|PropertiesTable id
            { "is-paused" : toggle}
        )
    )
    ;;Enforce: 5 call sites (C_Burn, C_Mint, C_Wipe, C_WipeSlim, XI_CPF_BurnFee) -- relocating UEV_Amount
    ;;          duplicates it 5x. AND read-and-write-in-one: the supply-underflow guard reads <supply> and
    ;;          writes it back, so a defcap would have to re-read the same row.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_UpdateSupply (id:string amount:decimal direction:bool)
        (P|UEV_IMC)
        (UEV_Amount id amount)
        (if (= direction true)
            (with-read DPTF|PropertiesTable id
                { "supply" := s }
                ;;UNREACHABLE BY ARITHMETIC -- unlike its twin on the debit branch below, which is a
                ;;live backstop. `UEV_Amount` runs FIRST (two lines up) and enforces `amount > 0.0`,
                ;;and a supply is never negative (this very pair of guards is what keeps it so). So
                ;;`(+ s amount)` is a positive added to a non-negative and cannot be < 0.0.
                ;;The DEBIT branch IS reachable -- `(- s amount)` goes negative when an account holds
                ;;more than the token's total supply -- and is driven by
                ;;REPL/modules/DPTF.repl <<DPTF-G12>>, which forces that corruption and watches this
                ;;message stop the burn. Both sites share the wording, so only that test proves one.
                (enforce (>= (+ s amount) 0.0) "DPTF Token Supply cannot be updated to negative values!")
                (update DPTF|PropertiesTable id { "supply" : (+ s amount)})
            )
            (with-read DPTF|PropertiesTable id
                { "supply" := s }
                (enforce (>= (- s amount) 0.0) "DPTF Token Supply cannot be updated to negative values!")
                (update DPTF|PropertiesTable id { "supply" : (- s amount)})
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_FEE
    (defun XI_ToggleFee(id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_FEE id toggle))
        (update DPTF|PropertiesTable id
            { "fee-toggle" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_MIN-MOVE
    (defun XI_SetMinMove (id:string min-move-value:decimal)
        (require-capability (DPTF|S>SET_MIN-MOVE id min-move-value))
        (update DPTF|PropertiesTable id
            { "min-move" : min-move-value}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_FEE
    (defun XI_SetFee (id:string fee:decimal)
        (require-capability (DPTF|S>SET_FEE id fee))
        (update DPTF|PropertiesTable id
            { "fee-promile" : fee}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_FEE-TARGET
    (defun XI_SetFeeTarget (id:string target:string)
        (require-capability (DPTF|S>SET_FEE-TARGET id target))
        (update DPTF|PropertiesTable id
            { "fee-target" : target}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>X_TG_FEE-LOCK
    (defun XI_ToggleFeeLock:[decimal] (id:string toggle:bool)
        (require-capability (DPTF|S>X_TG_FEE-LOCK id toggle))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (update DPTF|PropertiesTable id
                { "fee-lock" : toggle}
            )
            (if (= toggle true)
                [0.0 0.0]
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Enforce: read-and-write-in-one -- <fee-unlocks> is read here and written back incremented, so a
    ;;          defcap would have to re-read the same row. The cap is economic, not cosmetic: URC_Fee
    ;;          prices every transfer's secondary fee at (fee-unlocks - 1) x volumetric-fee.
    ;;Protection: Class 2 — SECURE
    (defun XIv_IncrementFeeUnlocks (id:string)
        (require-capability (SECURE))
        (with-read DPTF|PropertiesTable id
            { "fee-unlocks" := fu }
            ;;UNTESTABLE-EXTERNALLY: XIv_IncrementFeeUnlocks sits behind (require-capability (SECURE)), and SECURE cannot be acquired from outside
            ;;this module -- so no REPL negative test can reach this line. The guard is LIVE and
            ;;does real work on the in-module path; it is NOT dead code. Distinguished from
            ;;the UNREACHABLE marker deliberately: that marker means no input can trip the guard at all.
            (enforce (< fu 7) (format "Cannot increment Fee Unlocks for Token {}" [id]))
            (update DPTF|PropertiesTable id
                {"fee-unlocks" : (+ fu 1)}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateFeeVolume (id:string amount:decimal primary:bool)
        (P|UEV_IMC)
        (UEV_Amount id amount)
        (if primary
            (with-read DPTF|PropertiesTable id
                { "primary-fee-volume" := pfv }
                (update DPTF|PropertiesTable id
                    {"primary-fee-volume" : (+ pfv amount)}
                )
            )
            (with-read DPTF|PropertiesTable id
                { "secondary-fee-volume" := sfv }
                (update DPTF|PropertiesTable id
                    {"secondary-fee-volume" : (+ sfv amount)}
                )
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardToken (atspair:string id:string direction:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read DPTF|PropertiesTable id
                {"reward-token" := rt}
                (if (= direction true)
                    (if (= (at 0 rt) BAR)
                        (update DPTF|PropertiesTable id
                            {"reward-token" : [atspair]}
                        )
                        (update DPTF|PropertiesTable id
                            {"reward-token" : (ref-U|LST::UC_AppL rt atspair)}
                        )
                    )
                    ;;SENTINEL RESTORED ON REMOVE (2026-09-13). `UC_RemoveItem` is
                    ;;`(filter (!= item) in)`, so removing the LAST remaining atspair yields the bare
                    ;;empty list -- breaking the `[BAR]`-sentinel invariant that the ADD branch
                    ;;directly above this one is careful to maintain. The two branches were
                    ;;asymmetric: ADD understood the sentinel, REMOVE did not.
                    ;;
                    ;;WHY IT MATTERED. `URC_IzRT` decides "is this token a reward token anywhere?" by
                    ;;`(if (= (UR_RewardToken id) [BAR]) false true)`. An empty list is not `[BAR]`,
                    ;;so the token would answer TRUE -- claiming to be a reward token while holding
                    ;;no pairs -- and every transfer of it routes into `TFT::URCx_CPF_RT`, which does
                    ;;`(enumerate 0 (- (length ats-pairs) 1))`. On an empty list that is
                    ;;`(enumerate 0 -1)` = the DESCENDING PAIR `[0, -1]`, so `(at 0 [])` faults.
                    ;;The token becomes permanently untransferable -- and un-repairable, because the
                    ;;ADD branch opens with `(at 0 rt)`, which faults on `[]` too.
                    ;;
                    ;;The `(> rt-position 0)` guard in `ATSU|C>X_REMOVE-SECONDARY` does NOT prevent
                    ;;this: it protects position 0 of the ATS PAIR's reward-token list, a different
                    ;;list from the DPTF's list of pairs. A token that is the sole SECONDARY RT of
                    ;;one pair passes that guard; the precondition is reachable through the ordinary
                    ;;`ATS|C_AddSecondary` client path (verified live).
                    ;;
                    ;;Restoring the sentinel is the minimal repair and is symmetric with ADD: lists
                    ;;of length >= 1 after the filter are untouched, so this changes behaviour ONLY
                    ;;in the case that was broken. Invariant swept by REPL/modules/ATS.repl <<ATS-F1>>.
                    (update DPTF|PropertiesTable id
                        {"reward-token" :
                            (let
                                (
                                    (remaining:[string] (ref-U|LST::UC_RemoveItem rt atspair))
                                )
                                (if (= (length remaining) 0) [BAR] remaining)
                            )
                        }
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardBearingToken (atspair:string id:string)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read DPTF|PropertiesTable id
                {"reward-bearing-token" := rbt}
                (if (= (at 0 rbt) BAR)
                    (update DPTF|PropertiesTable id
                        {"reward-bearing-token" : [atspair]}
                    )
                    (update DPTF|PropertiesTable id
                        {"reward-bearing-token" : (ref-U|LST::UC_AppL rbt atspair)}
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateVesting (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"vesting-link" : dpof}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateSleeping (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"sleeping-link" : dpof}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateHibernation (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"hibernation-link" : dpof}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateFrozen (core-dptf:string frozen-dptf:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable core-dptf
            {"frozen-link" : frozen-dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateReserved (core-dptf:string reserved-dptf:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable core-dptf
            {"reservation-link" : reserved-dptf}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_RESERVATION
    (defun XI_ToggleReservation (id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_RESERVATION id toggle))
        (update DPTF|PropertiesTable id
            { "reservation" : toggle}
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPTF|C>UPDATE-SPECIAL
    (defun XE_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dptf:string fr-tag:integer)
        (P|UEV_IMC)
        (with-capability (DPTF|C>UPDATE-SPECIAL main-dptf secondary-dptf fr-tag)
            (cond
                ((= fr-tag 1)
                    (do
                        (XI_UpdateFrozen main-dptf secondary-dptf)
                        (XI_UpdateFrozen secondary-dptf main-dptf)
                    )
                )
                ((= fr-tag 2)
                    (do
                        (XI_UpdateReserved main-dptf secondary-dptf)
                        (XI_UpdateReserved secondary-dptf main-dptf)
                    )
                )
                true
            )
            (URCi_UpdateSpecialTrueFungible main-dptf)
        )
    )
    ;;2]DPTF|RoleTable
    ;;Protection: Class 2 — SECURE
    (defun XI_WriteRoles (id:string verum-roles:object{DPTF|RoleSchema})
        (require-capability (SECURE))
        (write DPTF|RoleTable id verum-roles)
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum1 (id:string new-verum1:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"a-frozen" : new-verum1}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum2 (id:string new-verum2:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-burn" : new-verum2}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum3 (id:string new-verum3:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-mint" : new-verum3}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum4 (id:string new-verum4:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-fee-exemption" : new-verum4}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum5 (id:string new-verum5:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-transfer" : new-verum5}
        )
    )
    ;;3]DPTF|BalanceTable
    ;;Protection: Class 3 — Custom: DPTF|C>X_FREEZE
    (defun XI_ToggleFreezeAccount (id:string account:string toggle:bool)
        @doc "Toggle Verum 1"
        (require-capability (DPTF|C>X_FREEZE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateFreeze account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    { "frozen" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-BURN-ROLE
    (defun XI_ToggleBurnRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (require-capability (DPTF|C>X_TOGGLE-BURN-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateBurnRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-burn" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-MINT-ROLE
    (defun XI_ToggleMintRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        (require-capability (DPTF|C>X_TOGGLE-MINT-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateMintRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-mint" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE
    (defun XI_ToggleFeeExemptionRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        (require-capability (DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateFeeExemptionRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-fee-exemption" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-TRANSFER-ROLE
    (defun XI_ToggleTransferRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"                
        (require-capability (DPTF|C>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateTransferRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-transfer" : toggle}
                )
            )
        )
    )
    ;;
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPTF|C>DEBIT
    (defun XB_DebitTrueFungible (id:string account:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool)
        @doc "Debit DPTF <id> on <account> with <amount> \
            \ Ouronet Account <account> must exist \
            \ Assumes DPTF Account with key <(UC_IdAccount id account)> exists\
            \ Only Performs Debitation, does not update supply"
        (P|UEV_IMC)
        (with-capability (DPTF|C>DEBIT account id amount dispo-data wipe-mode)
            (let
                (
                    (current-supply:decimal (UR_AccountSupply id account))
                )
                (XI_UpdateBalance id account (- current-supply amount))
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPTF|C>CREDIT
    (defun XB_CreditTrueFungible (id:string account:string amount:decimal)
        @doc "Debit DPTF <id> on <account> with <amount> \
            \ Ouronet Account <account> must exist \
            \ DPTF Account with key <(UC_IdAccount id account)> may exist or not\
            \ Only Performs Creditation, does not update supply"
        (P|UEV_IMC)
        (with-capability (DPTF|C>CREDIT account id amount)
            (XB_DeployAccountWNE account id)
            (let
                (
                    (current-supply:decimal (UR_AccountSupply id account))
                )
                (XI_UpdateBalance id account (+ current-supply amount))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateBalance (id:string account:string new-balance:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                ;;Updates for Core Tokens
                (with-capability (P|DPTF|CALLER)
                    (ref-DALOS::XB_UpdateBalance account (= id (ref-DALOS::UR_OuroborosID)) new-balance)
                )
                ;;Updates for Non Core Tokens
                (WW_UpdateBalance id account new-balance)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateTreasury (patron:string executor:string type:integer tdp:decimal tds:decimal)
        @doc "ADMIN op. Executor: ENFORCED DIRECTLY below -- and it is enforced for \
            \ ATTRIBUTION, not for authority: the GOV|*_ADMIN gate inside the capability decides \
            \ WHETHER this may happen, while <executor> records WHO made it happen. Before the \
            \ 2026-09-21 attribution ruling this parameter was present and never checked, which \
            \ is strictly worse than absent -- the caller could name any account and the event \
            \ would implicate it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
            (with-capability (GOV|SET_TREASURY-DISPO type tdp tds)
                (ref-DALOS::XE_UpdateTreasury type tdp tds)
            )
        )
    )
    (defun A_WipeTreasuryDebt (patron:string executor:string)
        @doc "ADMIN op. Executor: ENFORCED DIRECTLY below -- and it is enforced for \
            \ ATTRIBUTION, not for authority: the GOV|*_ADMIN gate inside the capability decides \
            \ WHETHER this may happen, while <executor> records WHO made it happen. Before the \
            \ 2026-09-21 attribution ruling this parameter was present and never checked, which \
            \ is strictly worse than absent -- the caller could name any account and the event \
            \ would implicate it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
            (with-capability (GOV|WIPE_ALL-TREASURY-DEBT)
                (C_Mint patron treasury ouro (abs treasury-supply) false)
                (ref-DALOS::XE_UpdateTreasury 0 0.0 0.0)
            )
        )
    )
    (defun A_WipeTreasuryDebtPartial (patron:string executor:string debt-to-be-wiped:decimal)
        @doc "ADMIN op. Executor: ENFORCED DIRECTLY below -- and it is enforced for \
            \ ATTRIBUTION, not for authority: the GOV|*_ADMIN gate inside the capability decides \
            \ WHETHER this may happen, while <executor> records WHO made it happen. Before the \
            \ 2026-09-21 attribution ruling this parameter was present and never checked, which \
            \ is strictly worse than absent -- the caller could name any account and the event \
            \ would implicate it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
            (with-capability (GOV|WIPE_PARTIAL-TREASURY-DEBT debt-to-be-wiped)
                (C_Mint patron treasury ouro debt-to-be-wiped false)
            )
        )
    )
    (defun AU_TrueFungibleAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_TrueFungibleAccount) keyz)
        )
    )
    (defun AU_TrueFungibleAccount (ky:string)
        (require-capability (SECURE))
        (let
            (
                (input-obj:object (read DPTF|BalanceTable ky))
                (has-exist:bool (contains "exist" input-obj))
                (v1:object
                    (+
                        {"id" : (drop -163 ky)}
                        (remove "id" input-obj)
                    )
                )
                (v2:object
                    (+
                        {"account" : (take -162 ky)}
                        (remove "account" v1)
                    )
                )
                (v3:object
                    (if has-exist
                        (remove "exist" v2)
                        v2
                    )
                )
            )
            (write DPTF|BalanceTable ky v3)
        )
    )
    (defun AU_TrueFungibles (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_TrueFungible) ids)
        )
    )
    (defun AU_TrueFungible (id:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (DPTF|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (parent:string (URCv_Parent entity-id))
                (parent-owner:string (UR_Konto parent))
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (DPTF|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id parent-owner months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Issues one or more DPTF tokens owned by <executor>, charging STOA to <patron>. \
            \ \
            \ Executor: ENFORCED INDIRECTLY -- XB_IssueFree -> DPTF|C>ISSUE -> \
            \ CAP_EnforceAccountOwnership <executor>. Note that the (SECURE) capability wrapping \
            \ the call provides NO protection (SECURE is `true`); the real gate is the one named \
            \ above, inside XB_IssueFree. Without it anyone could mint a token into someone \
            \ else's ownership. (patron/executor canon 2.2, indirect route named.)"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l1:integer (length name))
                (tl:[bool] (make-list l1 false))
                (stoa-costs:decimal (URCi_IssueStoa l1))
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (SECURE)
                        (XB_IssueFree executor name ticker decimals can-upgrade can-change-owner can-add-special-role can-freeze can-wipe can-pause tl)
                    )
                )
            )
            (ref-IGNIS::XE_CollectStoa patron stoa-costs)
            ico
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>ROTATE-OWNERSHIP id executee)
            (XI_ChangeOwnership id executee)
            (URCi_RotateOwnership id)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>CONTROL id)
            (XI_Control id cu cco casr cf cw cp)
            (URCi_Control id)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>TOGGLE_PAUSE id toggle)
            (XI_TogglePause id toggle)
            (URCi_TogglePause id)
        )
    )
    (defun C_ToggleReservation:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>TOGGLE_RESERVATION id toggle)
            (XI_ToggleReservation id toggle)
            (URCi_ToggleReservation id)
        )
    )
    ;;
    (defun C_ToggleFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>TOGGLE_FEE id toggle)
            (XI_ToggleFee id toggle)
            (URCi_ToggleFee id)
        )
    )
    (defun C_SetMinMove:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string min-move-value:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>SET_MIN-MOVE id min-move-value)
            (XI_SetMinMove id min-move-value)
            (URCi_SetMinMove id)
        )
    )
    (defun C_SetFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string fee:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>SET_FEE id fee)
            (XI_SetFee id fee)
            (URCi_SetFee id)
        )
    )
    (defun C_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string target:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|S>SET_FEE-TARGET id target)
            (XI_SetFeeTarget id target)
            (URCi_SetFeeTarget id)
        )
    )
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>TOGGLE_FEE-LOCK id toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleFeeLock id toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads fee-unlocks BEFORE XIv_IncrementFeeUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleFeeLock id toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XIv_IncrementFeeUnlocks id)
                        (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    ;;
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 1"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>FREEZE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-one:[string] (UR_Verum1 id))
                    (updated-verum-one:[string] (ref-U|DALOS::UCv_NewRoleList verum-one executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum1 id updated-verum-one)
                ;;Update Account Roles
                (XI_ToggleFreezeAccount id executee toggle)
                ;;Output
                (URCi_ToggleFreezeAccount id)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 2"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>TOGGLE-BURN-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-two:[string] (UR_Verum2 id))
                    (updated-verum-two:[string] (ref-U|DALOS::UCv_NewRoleList verum-two executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum2 id updated-verum-two)
                ;;Update Account Roles
                (XI_ToggleBurnRole id executee toggle)
                ;;Output
                (URCi_ToggleBurnRole id)
            )
        )
    )
    (defun C_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 3"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>TOGGLE-MINT-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-three:[string] (UR_Verum3 id))
                    (updated-verum-three:[string] (ref-U|DALOS::UCv_NewRoleList verum-three executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum3 id updated-verum-three)
                ;;Update Account Roles
                (XI_ToggleMintRole id executee toggle)
                ;;Output
                (URCi_ToggleMintRole id)
            )
        )
    )
    ;;Toggle Verum 4
    (defun C_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 4"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-four:[string] (UR_Verum4 id))
                    (updated-verum-four:[string] (ref-U|DALOS::UCv_NewRoleList verum-four executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum4 id updated-verum-four)
                ;;Update Account Roles
                (XI_ToggleFeeExemptionRole id executee toggle)
                ;;Output
                (URCi_ToggleFeeExemptionRole id)
            )
        )
    )
    ;;Toggle Verum 5
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 5"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPTF|C>TOGGLE_TRANSFER-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-five:[string] (UR_Verum5 id))
                    (updated-verum-five:[string] (ref-U|DALOS::UCv_NewRoleList verum-five executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum5 id updated-verum-five)
                ;;Update Account Roles
                (XI_ToggleTransferRole id executee toggle)
                ;;Output
                (URCi_ToggleTransferRole id)
            )
        )
    )
    ;;
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (with-capability (DPTF|C>BURN id executor amount)
                (XB_DebitTrueFungible id executor amount (ref-U|DPTF::UDC_EmptyDispo) false)
                (XBv_UpdateSupply id amount false)
                (URCi_Burn id executor)
            )
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string amount:decimal origin:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|C>MINT id executor amount origin)
            (XB_CreditTrueFungible id executor amount)
            (XBv_UpdateSupply id amount true)
            (if origin
                (update DPTF|PropertiesTable id
                    {"origin-mint"          : false
                    ,"origin-mint-amount"   : amount}
                )
                true
            )
            (URCi_Mint id executor origin)
        )
    )
    ;;
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string amount-to-be-wiped:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (with-capability (DPTF|C>WIPE-SLIM id executee amount-to-be-wiped)
                (XB_DebitTrueFungible id executee amount-to-be-wiped (ref-U|DPTF::UDC_EmptyDispo) true)
                (XBv_UpdateSupply id amount-to-be-wiped false)
                (URCi_WipeSlim id)
            )
        )
    )
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                (amount-to-be-wiped:decimal (UR_AccountSupply id executee))
            )
            (with-capability (DPTF|C>WIPE id executee)
                (XB_DebitTrueFungible id executee amount-to-be-wiped (ref-U|DPTF::UDC_EmptyDispo) true)
                (XBv_UpdateSupply id amount-to-be-wiped false)
                (URCi_Wipe id)
            )
        )
    )

)

;; --- tables for 05_DPTF.pact (5 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPTF|PropertiesTable)
;; (create-table DPTF|BalanceTable)
;; (create-table DPTF|RoleTable)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpofUdcV2
    @doc "Exposes DPOF UDC Constructors"

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
    (defschema DPOF|Properties
        id:string
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-add-special-role:bool
        can-transfer-oft-create-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        segmentation:bool
        ;;
        is-paused:bool
        nonces-used:integer
        nonces-excluded:integer
        ;;
        supply:decimal
        ;;
        reward-bearing-token:string
        vesting-link:string
        sleeping-link:string
        hibernation-link:string
        ;;
    )
    ;;Nonces cant be separated. A Ortofungible Nonce has one unique holder.
    (defschema DPOF|NonceElement
        holder:string                       ;;Stores the <OuronetAccount> holding the nonce - mutable
        id:string                           ;;ID of the Ortofungible - immutable.
        value:integer                       ;;Stores the Nonce value itself - immutable.
        supply:decimal                      ;;Nonce Supply - mutable
        meta-data-chain:[object]            ;;Stores Nonce Metadata - immutable
    )
    (defschema DPOF|VerumRoles
        a-frozen:[string]
        r-oft-add-quantity:[string]
        r-oft-burn:[string]
        r-oft-create:string
        r-transfer:[string]
    )
    (defschema DPOF|AccountRoles
        total-account-supply:decimal        ;; Holds the Total Account Supply for id
        frozen:bool                         ;; multiple
        role-oft-add-quantity:bool          ;; multiple
        role-oft-burn:bool                  ;; multiple
        role-oft-create:bool                ;; single
        role-transfer:bool                  ;; multiple
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema RemovableNonces
        @doc "Removable Nonces are Class 0 Nonces held by a given Account with greater than 0 supply \
        \ Given an <account>, a dpdc <id>, and a list of <nonces>, they can be filtered to Removable Nonces"
        r-nonces:[integer]
        r-amounts:[decimal]
    )
    (defschema DPOF|WipeSlicePlan
        @doc "Hydra wipe slice plan: the URHC_WipePure output partitioned into <slice-count> \
        \ disjoint contiguous |RemovableNonces| slices, each fed to one <Cp_WipeSlice> tx. \
        \ Offline plan only (UI dirty-read) — never persisted on-chain."
        account:string
        id:string
        slice-count:integer
        slices:[object{RemovableNonces}]
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosPactOrtoFungibleV2
    @doc "Exposes Functions related to Orto-Fungibles \
        \ Orto-Fungibles are the next Evoloution of the Meta-Fungibles \
        \ using a newer and more efficient Architecture, and fixing discovered bugs \
        \ \
        \ The most important functionality is the ability for an Ouronet Account to own \
        \ as many Nonces (Elements) as needed without any limitations \
        \ which was the main reason Orto-Fungible was created \
        \ \
        \ Existing Meta-Fungible <id> and <accounts> will have to be migrated to Orto-Fungibles \
        \ Luckily Meta-Fungible usage hasnt properly started at the time of Orto-Fungible Deployment"

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
    (defun UDC_NonceElement:object{DpofUdcV2.DPOF|NonceElement}
        (a:string b:string c:integer d:decimal e:[object])
    )
    (defun UDC_VerumRoles:object{DpofUdcV2.DPOF|VerumRoles}
        (a:[string] b:[string] c:[string] d:string e:[string])
    )
    (defun UDC_AccountRoles:object{DpofUdcV2.DPOF|AccountRoles}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
    )
    (defun UDC_RemovableNonces:object{DpofUdcV2.RemovableNonces}
        (a:[integer] b:[decimal])
    )
    (defun UDC_WipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (a:string b:string c:integer d:[object{DpofUdcV2.RemovableNonces}])
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_IdNonce:string (id:string nonce:integer))
    (defun UC_IdAccount:string (id:string account:string))
    (defun UC_IzSingular:bool (id:string nonces:[integer]))
    (defun UC_IzConsecutive:bool (id:string nonces:[integer]))
    (defun UCv_TakePureWipe:object{DpofUdcV2.RemovableNonces} (input:object{DpofUdcV2.RemovableNonces} size:integer))
    (defun UC_ComputeMinWipeSliceCount:integer (nonce-count:integer))
    (defun UC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces} slice-count:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_MoveCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string nonces:[integer] transmit-or-transfer:bool))
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    ;;  [URCi] composer/price cost readers — single source per op (the C_/XE_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string))
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_N-KEYS:[string] ())
    (defun UR_V-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [0] DPOF|T|Properties:{DpofUdcV2.DPOF|Properties}
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanTransferOftCreateRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_IsPaused:bool (id:string))
    (defun UR_Segmentation:bool (id:string))
    (defun UR_NoncesUsed:integer (id:string))
    (defun UR_NoncesExcluded:integer (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_RewardBearingToken:string (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Hibernation:string (id:string))
    (defun UR_IzId:bool (id:string))
    ;;
    ;;  [1] DPOF|T|Nonces:{DpofUdcV2.DPOF|NonceElement}
    (defun UR_NonceHolder:string (id:string nonce:integer))
    (defun UR_NonceID:string (id:string nonce:integer))
    (defun UR_NonceValue:integer (id:string nonce:integer))
    (defun UR_NonceSupply:decimal (id:string nonce:integer))
    (defun UR_NonceMetaData:[object] (id:string nonce:integer))
    (defun UR_NoncesSupplies:[decimal] (id:string nonces:[integer]))
    (defun UR_NoncesMetaDatas:[[object]] (id:string nonces:[integer]))
    (defun UR_IzNonce:bool (id:string nonce:integer))
    ;;
    ;;  [2] DPOF|T|VerumRoles:{DpofUdcV2.DPOF|VerumRoles}
    (defun UR_Verum1:[string] (id:string))
    (defun UR_Verum2:[string] (id:string))
    (defun UR_Verum3:[string] (id:string))
    (defun UR_Verum4:string (id:string))
    (defun UR_Verum5:[string] (id:string))
    ;;
    ;;  [3] DPOF|T|AccountRoles:{DpofUdcV2.DPOF|AccountRoles}
    (defun UR_R-Frozen:bool (id:string account:string))
    (defun UR_R-AddQuantity:bool (id:string account:string))
    (defun UR_R-Burn:bool (id:string account:string))
    (defun UR_R-Create:bool (id:string account:string))
    (defun UR_R-Transfer:bool (id:string account:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_IzAccount:bool (id:string account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URHC_WipePure:object{DpofUdcV2.RemovableNonces} (account:string id:string))
    (defun URHC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan} (account:string id:string slice-count:integer))
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
        ;;
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URC_HasHibernation:bool (id:string))
    (defun URCv_Parent:string (dpof:string))
    (defun URC_BrandingKonto:string (entity-id:string))
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldOrtoFungibles:[string] (account:string))
    (defun URH_ExistingOrtoFungibles:[string] (dotf:string))
    (defun URH_OwnedOrtoFungibles:[string] (account:string))
    (defun URH_AccountNonces:[integer] (account:string dpof-id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_id (id:string))
    (defun UEV_NoncesCirculating (id:string nonces:[integer]))
    (defun UEV_ParentOwnership (id:string))
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string))
    (defun UEV_ExecutorIsKonto (executor:string id:string))
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer]))
    (defun UEV_Amount (id:string amount:decimal))
        ;;
    (defun UEV_UpdateRewardBearingToken (id:string))
    (defun UEV_CanUpgradeON (id:string))
    (defun UEV_CanChangeOwnerON (id:string))
    (defun UEV_CanAddSpecialRoleON (id:string))
    (defun UEV_CanTransferOftCreateRoleON (id:string))
    (defun UEV_CanFreezeON (id:string))
    (defun UEV_CanWipeON (id:string))
    (defun UEV_CanPauseON (id:string))
    (defun UEV_PauseState (id:string state:bool))
        ;;
    (defun UEV_SegmentationState (id:string state:bool))
    (defun UEV_AccountFreezeState (id:string account:string state:bool))
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool))
    (defun UEV_AccountBurnState (id:string account:string state:bool))
    (defun UEV_AccountCreateState (id:string account:string state:bool))
    (defun UEV_AccountTransferState (id:string account:string state:bool))
        ;;
    (defun UEV_Vesting (id:string existance:bool))
    (defun UEV_Sleeping (id:string existance:bool))
    (defun UEV_Hibernation (id:string existance:bool))
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    (defun UEV_EnforceSegmentationForTransmit (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            ;;
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            can-transfer-oft-create-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
    )
    (defun XBv_DeployAccount (id:string account:string))
    (defun XB_DeployAccountWNE (account:string id:string))
    (defun XB_InsertNewNonce (nonce-owner:string id:string nonce:integer amount:decimal meta-data-chain:[object]))
    (defun XE_UpdateRewardBearingToken (atspair:string hot-rbt:string))
    (defun XE_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dpof:string vzh-tag:integer)
    )
    (defun XB_W|AccountRoles (id:string account:string account-data:object{DpofUdcV2.DPOF|AccountRoles}))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
        ;;
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string amount:decimal meta-data-chain:[object]))
        ;;
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonce:integer amount:decimal))
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator} (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun C_Transmit:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonces:[integer] method:bool))
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
    )

)
;;
(module DPOF GOV
    @doc "DPOF — the OrtoFungible token core, the modern successor to DPMF for \
        \ metadata-rich, NFT-like fungibles; implements DemiourgosPactOrtoFungibleV2 and \
        \ DpofUdcV2. Tables hold token properties, per-nonce elements \
        \ (holder/value/supply/metadata, each nonce single-held), verum roles and \
        \ per-account roles. Client ops cover issue, mint, add-quantity, burn, \
        \ transfer/transmit/bulk-transfer, move-create-role, role and pause/freeze toggles, \
        \ several wipe variants and ownership rotation."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements DemiourgosPactOrtoFungibleV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPOF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPOF_ADMIN)))
    (defcap GOV|DPOF_ADMIN ()                           (enforce-guard GOV|MD_DPOF))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CollectiblesKey ()                       (+ (CT_Namespace) ".dh_sc_dpdc-keyset"))

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
    (defcap P|DPOF|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPOF|CALLER))
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
        (with-capability (GOV|DPOF_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPOF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPOF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPOF_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPOF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst OF                                        (at 0 ["Orto-Fungible"]))
    (defconst WIPE-SLICE-MAX-NONCES                     1000
        "Hydra wipe: max nonces per <Cp_WipeSlice> tx. UI SEED + generous backstop, NOT the \
        \ optimizer — the UI /local-simulates each slice and adds slices when one does not fit; \
        \ the node gas meter is the real enforcement (an oversized slice aborts atomically). \
        \ CALIBRATED REPL/Kursan/DPOF-scale-wipe.repl: measured 405.6 gas per nonce wiped => ~4907 nonces fit a \
        \ 2,000,000-gas tx. Set well under that because the probe used the LIGHTEST possible \
        \ nonces (zero URI data, no metadata); real nonces carry more payload per row.")
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
    ;;{3.2}  schemas
    ;;
    (defschema TransmitData
        input-nonces:[integer]
        input-amounts:[decimal]
        output-nonces:[integer]
        meta-data-array:[[object]]
    )
    ;;{3.3}  tables
    (deftable DPOF|T|Properties:{DpofUdcV2.DPOF|Properties})        ;;Key = <DPOF-id>      
    (deftable DPOF|T|Nonces:{DpofUdcV2.DPOF|NonceElement})          ;;Key = <DSOF-id> + BAR + <nonce>
    (deftable DPOF|T|VerumRoles:{DpofUdcV2.DPOF|VerumRoles})        ;;Key = <DPOF-id>
    (deftable DPOF|T|AccountRoles:{DpofUdcV2.DPOF|AccountRoles})    ;;Key = <DPOF-id> + BAR + <account> 

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPOF|S>ROTATE-OWNERSHIP (id:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_Konto id) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (CAP_Owner id)
            (UEV_CanChangeOwnerON id)
        )
    )
    (defcap DPOF|S>CONTROL (id:string)
        @event
        (CAP_Owner id )
        (UEV_CanUpgradeON id)
    )
    (defcap DPOF|S>CREDIT-SINGULAR (account:string id:string nonce:integer amount:decimal)
        ;;Nonce must be held by Account (also indirectly validates that account exists)
        (UEV_NoncesToAccount id account [nonce])
        ;;Amount must be validated
        (UEV_Amount id amount)
        ;;Nonce must be in circulation
        (UEV_NoncesCirculating id [nonce])
    )
    (defcap DPOF|S>CREDIT-CONSECUTIVE (account:string id:string nonces:[integer] amounts:[decimal])
        (map
            (lambda
                (idx:integer)
                (let
                    (
                        (amount:decimal (at idx amounts))
                    )
                    (UEV_Amount id amount)
                )
            )
            (enumerate 0 (- (length nonces) 1))
        )
    )
    ;;
    (defcap DPOF|S>PAUSE (id:string pause:bool)
        @doc "Pause and Unpause a DPOF <id>"
        @event
        (CAP_Owner id)
        (UEV_PauseState id (not pause))
        (if pause
            (UEV_CanPauseON id)
            true
        )
    )
    (defcap DPOF|S>X_FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountFreezeState id account (not frozen))
            (if frozen
                (UEV_CanFreezeON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountAddQuantityState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountBurnState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_SWITCH-CREATE-ROLE (id:string receiver:string)
        @doc "Switch Verum 4"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current:string (UR_Verum4 id))
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount receiver)
            (ref-DALOS::UEV_SenderWithReceiver current receiver)
            (CAP_Owner id)
            (UEV_CanTransferOftCreateRoleON id)
        )
    )
    (defcap DPOF|S>X_TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (special:[string] ["V|" "Z|"])
                (ft:string (take 2 id))
                (iz-special:bool (contains ft special))
            )
            ;;Vested and Sleeping Special Tokens can use Core Smart Ouronet Accounts for Transfer Roles Setup.
            (if (not iz-special)
                (do
                    (ref-DALOS::UEV_NotSmartOuronetAccount account)
                    (UEV_AccountTransferState id account (not toggle))
                )
                true
            )
            (CAP_Owner id)
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>MOVE (id:string sender:string receiver:string method:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            ;;1]Ownership
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;2]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;3]<id> Pause State and <sender> <receiver> Frozen State
            (UEV_PauseState id false)
            (UEV_AccountFreezeState id sender false)
            (UEV_AccountFreezeState id receiver false)
            ;;4]Transfer Roles Check
            (UEV_MoveRoleCheck id sender receiver)
        )
    )
    (defcap DPOF|S>BULK-MOVE
        (id:string sender:string receiver-lst:[string] method:bool)
        @doc "Bulk move guards — same family as DPOF|S>MOVE over receiver-lst. \
            \ Standard Ouronet accounts only (no smart accounts in receiver-lst)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (l:integer (length receiver-lst))
            )
            (ref-U|LST::UEV_IzUnique receiver-lst)
            (UEV_PauseState id false)
            (UEV_AccountFreezeState id sender false)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (receiver:string (at idx receiver-lst))
                        )
                        (ref-DALOS::UEV_EnforceAccountType receiver false)
                        (ref-DALOS::UEV_EnforceTransferability sender receiver method)
                        (UEV_AccountFreezeState id receiver false)
                        (UEV_MoveRoleCheck id sender receiver)
                    )
                )
                (enumerate 0 (- l 1))
            )
        )
    )
    ;;{C3}  Composed
    ;;
    ;;#33M (audit note, 2026-08-28): AHU/AU_OrtoFungible(s)/AU_OrtoFungibleAccount(s) are a
    ;;orto-fungible) migration, to batch-repair "id"/"account" key fields on rows carried over
    ;;from that migration. Not a general-purpose admin backdoor: the hardcoded account (AH,
    ;;"AncientHodler"/patron) was intentionally scoped to that one-time historical operation,
    ;;which is now complete - not a substitute for GOV|DPOF_ADMIN and not meant to be a
    ;;permanent alternate admin path. Owner (2026-08-28): "It's that way by design, and I think
    ;;everything is migrated anyway... this was used when migrating from meta to orto fungible."
    ;;Kept for historical reference, same retention rationale as DPMF itself (see #1C). No
    ;;functional change made - documentation only.
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
    ;;UNUSED here. DALOS defines the same cap and DOES use it (with-capability (SECURE-ADMIN));
    ;;DPOF's admin paths acquire GOV|DPOF_ADMIN directly instead, so this composite is never
    ;;reached. It sits beside AHU, the migration-era admin cap the owner explicitly retained for
    ;;historical reference (#33M), which is why it is documented rather than deleted: the same
    ;;retention rationale may apply. Flagged 2026-09-10.
    (defcap SECURE-ADMIN ()
        (compose-capability (SECURE))
        (compose-capability (GOV|DPOF_ADMIN))
    )
    (defcap DPOF|C>UPDATE-BRD (dpof:string)
        @event
        (UEV_ParentOwnership dpof)
        (compose-capability (P|DPOF|CALLER))
    )
    (defcap DPOF|C>UPGRADE-BRD (dpof:string)
        @event
        (UEV_ParentOwnership dpof)
        (compose-capability (P|DPOF|CALLER))
    )
    ;;
    (defcap DPOF|C>ISSUE 
        (
            account:string name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-U|INT::UEV_UniformList 
                [
                    (length name)
                    (length ticker)
                    (length decimals)
                    (length can-upgrade)
                    (length can-change-owner)
                    (length can-add-special-role)
                    (length can-transfer-oft-create-role)
                    (length can-freeze)
                    (length can-wipe)
                    (length can-pause)
                ]
            )
            (ref-U|LST::UEV_IzUnique name)
            (ref-U|LST::UEV_IzUnique ticker)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;
    (defcap DPOF|C>ADD-QTY (client:string id:string nonce:integer amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_AccountAddQuantityState id client true)
            (compose-capability (DPOF|C>CREDIT client id [nonce] [amount] [[{}]]))
        )
    )
    (defcap DPOF|C>BURN (client:string id:string nonce:integer amount:decimal)
        @event
        (let
            (
                (nonce-supply:decimal (UR_NonceSupply id nonce))
            )
            (UEV_AccountBurnState id client true)
            (if (< amount nonce-supply)
                (UEV_SegmentationState id true)
                true
            )
            (compose-capability (DPOF|C>DEBIT client id [nonce] [amount] false))
        )
    )
    (defcap DPOF|C>MINT (client:string id:string amount:decimal meta-data-chain:[object])
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (nonces-used:integer (UR_NoncesUsed id))
                (owner:string (UR_Konto id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_AccountAddQuantityState id client true)
            (if (and (= owner ATS|SC_NAME) (!= client owner))
                (enforce false "Only the ATS owner can mint when the owner is ATS")
                (UEV_AccountCreateState id client true)
            )
            (compose-capability (DPOF|C>CREDIT client id [(+ nonces-used 1)] [amount] [meta-data-chain]))
        )
    )
    (defcap DPOF|C>WIPE-SLIM (account:string id:string nonce:integer amount:decimal)
        @event
        (UEV_SegmentationState id true)
        (compose-capability (DPOF|C>X_WIPE account id [nonce] [amount]))
    )
    (defcap DPOF|C>WIPE (account:string id:string nonces:[integer])
        @event
        (compose-capability (DPOF|C>X_WIPE account id nonces (UR_NoncesSupplies id nonces)))
    )
    (defcap DPOF|C>X_WIPE (account:string id:string nonces:[integer] amounts:[decimal])
        ;;Nonces must be held by <account>
        (UEV_NoncesToAccount id account nonces)
        ;;Orto-Fungible is frozen on target account
        (UEV_AccountFreezeState id account true)
        ;;Orto-Fungible has <can-wipe> on
        (UEV_CanWipeON id)
        ;;Neeeded Capabilities
        (compose-capability (DPOF|C>DEBIT account id nonces amounts true))
    )
    ;;
    (defcap DPOF|C>DEBIT (account:string id:string nonces:[integer] amounts:[decimal] wipe-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) "Invalid Inputs for Debitation")
            ;;A repeated nonce would let each index's pre-write <= nonce-supply check pass against the
            ;;same stale supply value, then debit it more than once at write time — supply-negative
            ;;corruption (DALOS audit #3C). Single shared gate for C_Transmit/C_WipePure/C_WipeClean/etc.
            ;;UEV_IzUnique is [string]-typed; nonces are integers, so stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:decimal (at idx amounts))
                            (nonce-supply:decimal (UR_NonceSupply id nonce))
                        )
                        (enforce
                            ;;Cannot Debit into the negatives
                            (<= amount nonce-supply)
                            (format "Cannot Debit into the Negatives for {} {} Nonce {} on Account {}" [OF id nonce account])
                        )
                        (UEV_Amount id amount)
                        ;;<UEV_CirculatingNonce> is indirectly verified via the <enforce> above and <UEV_Amount> 
                        ;;(since non circulating nonce have supply -1.0 and amount must be greater than 0 and smaller than <nonce-supply>)
                    )
                    
                )
                (enumerate 0 (- l1 1))
            )
            ;;Enforces <account> ownership needed for Debitation
            (if wipe-mode
                (CAP_Owner id)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            ;;Checks all <nonces> are owned by Account
            (UEV_NoncesToAccount id account nonces)
            ;:For XI Functions
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>CREDIT (account:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (iz-singular:bool (UC_IzSingular id nonces))
                (iz-consecutive:bool (UC_IzConsecutive id nonces))
                (l1:integer (length nonces))
                (l2:integer (length amounts))
                (l3:integer (length meta-data-array))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce-one
                "Invalid Nonce Chain for Creditation"
                [
                    (enforce iz-singular "Nonce Chain is not Singular")
                    (enforce iz-consecutive "Nonce Chain is not Consecutive")
                ]
            )
            ;;UNREACHABLE (both this enforce and its mirror in the iz-consecutive branch below):
            ;;each fires only if BOTH predicates hold at once, and they are mutually exclusive.
            ;;UC_IzSingular = length 1 AND the nonce EXISTS; UC_IzConsecutive = the run starts at
            ;;nonces-used + 1, i.e. the nonces DO NOT exist yet. At length 1 "consecutive" means
            ;;exactly nonces-used + 1, which is by definition unused, so UR_IzNonce is false and
            ;;singular is false; at length > 1 singular is false anyway. Fail-closed backstops.
            ;;Demonstrated in REPL/modules/DPOF.repl <<DPOF-G3b>>.
            (if iz-singular
                (do
                    (enforce (not iz-consecutive) "Nonce Chain must compute false for Consecutive")
                    (compose-capability (DPOF|S>CREDIT-SINGULAR account id (at 0 nonces) (at 0 amounts)))
                )
                true
            )
            (if iz-consecutive
                (do
                    ;;UNREACHABLE: the mirror of the backstop above -- iz-singular and
                    ;;iz-consecutive are mutually exclusive for every input, so this enforce can
                    ;;never see both true. See the note on the iz-singular branch for the proof,
                    ;;and REPL/modules/DPOF.repl <<DPOF-G3b>> for the demonstration.
                    (enforce (not iz-singular) "Nonce Chain must compute false for Singular")
                    (compose-capability (DPOF|S>CREDIT-CONSECUTIVE account id nonces amounts))
                )
                true
            )
            (compose-capability (SECURE))
        )
    )
    ;;
    (defcap DPOF|C>FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        @event
        (compose-capability (DPOF|S>X_FREEZE id account frozen))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-ADD-QUANTITY-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-BURN-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>SWITCH-CREATE-ROLE (id:string receiver:string)
        @doc "Switch Verum 4"
        @event
        (compose-capability (DPOF|S>X_SWITCH-CREATE-ROLE id receiver))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DPOF|C>TRANSMIT (id:string td:object{TransmitData} sender:string receiver:string method:bool)
        @event
        (let
            (   
                (input-nonces:[integer] (at "input-nonces" td))
                (input-amounts:[decimal] (at "input-amounts" td))
                (output-nonces:[integer] (at "output-nonces" td))
                (meta-data-array:[[object]] (at "meta-data-array" td))
            )
            (UEV_SegmentationState id true)
            (compose-capability (DPOF|C>DEBIT sender id input-nonces input-amounts false))
            (compose-capability (DPOF|C>CREDIT receiver id output-nonces input-amounts meta-data-array))
            (compose-capability (DPOF|S>MOVE id sender receiver method))
        )
    )
    (defcap DPOF|C>TRANSFER (id:string nonces:[integer] sender:string receiver:string method:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            ;;A repeated nonce would let XI_TransferWholeNonces sum its supply more than once into
            ;;sender/receiver total-account-supply while only moving the nonce itself once — fabricated
            ;;supply inflation/deflation (DALOS audit #3C). UEV_IzUnique is [string]-typed; stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))
            (UEV_NoncesToAccount id sender nonces)
            (UEV_NoncesCirculating id nonces)
            (compose-capability (DPOF|S>MOVE id sender receiver method))
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>BULK-TRANSFER
        (id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Whole-nonce bulk transfer (multiple receivers). Composes DPOF|S>BULK-MOVE like C>TRANSFER composes S>MOVE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (l:integer (length receiver-lst))
                (all-nonces:[integer] (UC_FlattenNoncesArray nonces-array))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (enforce
                (fold (and) true
                    [
                        (> l 0)
                        (= l (length nonces-array))
                        (> (length all-nonces) 0)
                    ]
                )
                "Invalid DPOF bulk transfer: receiver/nonces legs or nonce list"
            )
            ;;Uniqueness across the FULL flattened set — blocks both a duplicate within one receiver's
            ;;own leg and the same nonce appearing in two different receivers' legs (each leg calls
            ;;XI_TransferWholeNonces independently; either case fabricates supply — DALOS audit #3C).
            ;;UEV_IzUnique is [string]-typed; stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) all-nonces))
            (UEV_NoncesToAccount id sender all-nonces)
            (UEV_NoncesCirculating id all-nonces)
            (compose-capability (DPOF|S>BULK-MOVE id sender receiver-lst method))
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>UPDATE-SPECIAL (main-dptf:string secondary-dpof:string vzh-tag:integer)
        (enforce (contains vzh-tag [1 2 3]) "Invalid Vesting|Sleeping|Hibernation Tag")
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (main-special-id:string
                    (cond
                        ((= vzh-tag 1) (ref-DPTF::UR_Vesting main-dptf))
                        ((= vzh-tag 2) (ref-DPTF::UR_Sleeping main-dptf))
                        ((= vzh-tag 3) (ref-DPTF::UR_Hibernation main-dptf))
                        BAR
                    )
                )
                (secondary-special-id:string
                    (cond
                        ((= vzh-tag 1) (UR_Vesting secondary-dpof))
                        ((= vzh-tag 2) (UR_Sleeping secondary-dpof))
                        ((= vzh-tag 3) (UR_Hibernation secondary-dpof))
                        BAR
                    )
                )
                (iz-secondary-rbt:bool (URC_IzRBT secondary-dpof))
                (main-dptf-ftc:string (take 2 main-dptf))
            )
            (ref-DPTF::CAP_Owner main-dptf)
            (CAP_Owner secondary-dpof)
            (enforce
                (and (= main-special-id BAR) (= secondary-special-id BAR) )
                "Special Orto Fungible Links (Vesting, Sleeping or Hibernation) are immutable !"
            )
            ;;UNREACHABLE -- `secondary-dpof` is ALWAYS a DPOF issued moments earlier, and a
            ;;just-issued ortofungible cannot be a Hot-RBT (that requires registration on an ATS
            ;;pair, which cannot have happened yet). The single caller,
            ;;VST::XI_CreateSpecialOrtoFungibleLink, takes the id straight out of its own
            ;;XB_IssueFree cumulator and passes it into XE_UpdateSpecialOrtoFungible in the same
            ;;expression -- no client ever names the secondary.
            ;;EXACT TWIN of 05_DPTF.pact:1004 ("Special True Fungible cannot be RTs or Cold-RBTs"),
            ;;same caller shape, same proof. Fail-closed backstop for a future caller that does
            ;;supply its own secondary.
            (enforce
                (not iz-secondary-rbt)
                "Special Orto Fungible cannot be a Hot-RBT"
            )
            (cond
                ((= vzh-tag 1)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Vesting Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                ((= vzh-tag 2)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|"]))
                        (format "When setting a Sleeping Link, the main DPTF {} cannot be a Special Token" [main-dptf])
                        ;;But can be an LP Token
                    )
                )
                ((= vzh-tag 3)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Hibernation Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                true
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_NonceElement:object{DpofUdcV2.DPOF|NonceElement}
        (a:string b:string c:integer d:decimal e:[object])
        {"holder"           : a
        ,"id"               : b
        ,"value"            : c
        ,"supply"           : d
        ,"meta-data-chain"  : e}
    )
    (defun UDC_VerumRoles:object{DpofUdcV2.DPOF|VerumRoles}
        (a:[string] b:[string] c:[string] d:string e:[string])
        {"a-frozen"             : a
        ,"r-oft-add-quantity"   : b
        ,"r-oft-burn"           : c
        ,"r-oft-create"         : d
        ,"r-transfer"           : e}
    )
    (defun UDC_AccountRoles:object{DpofUdcV2.DPOF|AccountRoles}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        {"total-account-supply"     : a
        ,"frozen"                   : b
        ,"role-oft-add-quantity"    : c
        ,"role-oft-burn"            : d
        ,"role-oft-create"          : e
        ,"role-transfer"            : f
        ,"id"                       : g
        ,"account"                  : h}
    )
    (defun UDC_RemovableNonces:object{DpofUdcV2.RemovableNonces}
        (a:[integer] b:[decimal])
        {"r-nonces"     : a
        ,"r-amounts"    : b}
    )
    (defun UDC_WipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (a:string b:string c:integer d:[object{DpofUdcV2.RemovableNonces}])
        {"account"      : a
        ,"id"           : b
        ,"slice-count"  : c
        ,"slices"       : d}
    )
    (defun UDCx_TransmitData:object{TransmitData}
        (a:[integer] b:[decimal] c:[integer] d:[[object]])
        {"input-nonces"     : a
        ,"input-amounts"    : b
        ,"output-nonces"    : c
        ,"meta-data-array"  : d}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IdNonce:string (id:string nonce:integer)
        (format "{}{}{}" [id BAR nonce])
    )
    (defun UC_IdAccount:string (id:string account:string)
        (format "{}{}{}" [id BAR account])
    )
    (defun UC_IzSingular:bool (id:string nonces:[integer])
        @doc "Checks if the <[nonces]> is singular; \
        \ Singular <[nonces]> means length is 1, and the nonce exists"
        (let
            (
                (l:integer (length nonces))
                (first-nonce:integer (at 0 nonces))
                (iz-nonce:bool (UR_IzNonce id first-nonce))
            )
            (if (and (= l 1) iz-nonce)
                true
                false
            )
        )
    )
    (defun UC_IzConsecutive:bool (id:string nonces:[integer])
        @doc "Checks if <[nonces]> are consecutive; \
        \ Consecutive means they need to be consecutive, dont exist yet, \
        \ and start imediatly after tha last used nonce"
        (let
            (
                (l:integer (length nonces))
                (nonces-used:integer (UR_NoncesUsed id))
                (last-nonce:integer (at 0 (take -1 nonces)))
                (enumerated:[integer] (enumerate (+ nonces-used 1) last-nonce))
            )
            (if 
                (fold (and) true
                    [
                        (= (+ nonces-used l) last-nonce)
                        (= enumerated nonces)
                        (>= l 1)
                    ]
                )
                true
                false
            )
        )
    )
    (defun UCv_TakePureWipe:object{DpofUdcV2.RemovableNonces} 
        (input:object{DpofUdcV2.RemovableNonces} size:integer)
        @doc "Takes <size> and returns a smaller |object{DpofUdcV2.RemovableNonces}|"
        (let
            (
                (nonces:[integer] (at "r-nonces" input))
                (amounts:[decimal] (at "r-amounts" input))
                (l:integer (length nonces))
            )
            (enforce (< size l) (format "Size of {} is larger than the Data set of the Removable Nonces Object" [size]))
            (UDC_RemovableNonces
                (take size nonces)
                (take size amounts)
            )
        )
    )
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer)
        @doc "Integer ceiling division: smallest integer >= numerator/denominator."
        (if (= (mod numerator denominator) 0)
            (/ numerator denominator)
            (+ 1 (/ numerator denominator))
        )
    )
    (defun UC_ComputeMinWipeSliceCount:integer (nonce-count:integer)
        @doc "Hydra wipe UI SEED: the minimum <Cp_WipeSlice> count for <nonce-count> nonces \
            \ under the <WIPE-SLICE-MAX-NONCES> per-tx backstop; minimum 1. NOT the optimizer — \
            \ the UI /local-simulates each candidate slice and adds slices when one does not fit."
        (let
            (
                (raw:integer (UC_CeilDiv nonce-count WIPE-SLICE-MAX-NONCES))
            )
            (if (> raw 1) raw 1)
        )
    )
    (defun UC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces} slice-count:integer)
        @doc "Hydra wipe partitioner (pure compute, no table reads): splits a |RemovableNonces| \
            \ object into disjoint CONTIGUOUS slices via take/drop index ranges. The requested \
            \ <slice-count> is clamped to [1, nonce-count] and then recomputed from the per-slice \
            \ width, so the returned plan NEVER contains an empty slice (an empty nonce list \
            \ aborts the executor); the plan's own <slice-count> field is the authoritative count."
        (let*
            (
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (l:integer (length nonces))
                (n-clamped:integer (if (< slice-count 1) 1 (if (> slice-count l) (if (> l 0) l 1) slice-count)))
                (per-slice:integer (UC_CeilDiv (if (> l 0) l 1) n-clamped))
                (n-final:integer (UC_CeilDiv (if (> l 0) l 1) per-slice))
            )
            (UDC_WipeSlicePlan account id n-final
                (map
                    (lambda
                        (slice-idx:integer)
                        (let*
                            (
                                (start:integer (* slice-idx per-slice))
                                (rest:integer (- l start))
                                (count:integer (if (< per-slice rest) per-slice rest))
                            )
                            (UDC_RemovableNonces
                                (take count (drop start nonces))
                                (take count (drop start amounts))
                            )
                        )
                    )
                    (enumerate 0 (- n-final 1))
                )
            )
        )
    )
    (defun UC_FlattenNoncesArray:[integer] (nonces-array:[[integer]])
        @doc "Concatenate per-receiver nonce slices into one list for bulk custody + IGNIS cumulator."
        (fold
            (lambda (acc:[integer] ns:[integer])
                (+ acc ns)
            )
            []
            nonces-array
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCix_NoncesCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string number-of-nonces:integer price-per-nonce:decimal output-obj:object)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (*
                    (dec number-of-nonces)
                    price-per-nonce
                )
                (UR_Konto id)
                (ref-IGNIS::URC_IsVirtualGasZero)
                [output-obj]
            )
        )
    )
    (defun URCi_MoveCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonces:[integer] transmit-or-transfer:bool)
        @doc "PER-NONCE unit for an ortofungible move: transmit costs the small unit, transfer \
            \ the smallest, multiplied by the nonce count in URCix_NoncesCumulator. Units come \
            \ from the IG|LEGS constants, not a DALOS table (owner 2026-09-07)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (URCix_NoncesCumulator 
                id 
                (length nonces)
                (if transmit-or-transfer
                    (ref-IGNIS::UC_IgnisLeg "tier-small")
                    (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                )
                {}
            )
        )
    )
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipe IGNIS = 5 ignis PER NONCE WIPED (owner 2026-09-05: ortofungible wiping scales \
            \ with nonce count), sourced from the central IG|WEIGHTS map in the IGNIS module. \
            \ Linear in N, so a Hydra wipe slice bills exactly its own slice. Shared by the exec \
            \ path (C_WipeClean/Heavy/Pure + Cp_WipeSlice) and their INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (URCix_NoncesCumulator 
                id 
                (length (at "r-nonces" removable-nonces-obj))
                (ref-IGNIS::UC_IgnisWeight "wipe-nonce")
                removable-nonces-obj
            )
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys DPOF|T|Properties)
    )
    (defun UR_N-KEYS:[string] ()
        (keys DPOF|T|Nonces)
    )
    (defun UR_V-KEYS:[string] ()
        (keys DPOF|T|VerumRoles)
    )
    (defun UR_KEYS:[string] ()
        (keys DPOF|T|AccountRoles)
    )
    ;;
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPOF|T|Properties id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPOF|T|Properties id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPOF|T|Properties id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPOF|T|Properties id ["decimals"]))
    )
    ;;
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPOF|T|Properties id ["can-upgrade"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPOF|T|Properties id ["can-change-owner"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPOF|T|Properties id ["can-add-special-role"]))
    )
    (defun UR_CanTransferOftCreateRole:bool (id:string)
        (at "can-transfer-oft-create-role" (read DPOF|T|Properties id ["can-transfer-oft-create-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPOF|T|Properties id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPOF|T|Properties id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPOF|T|Properties id ["can-pause"]))
    )
    (defun UR_Segmentation:bool (id:string)
        (at "segmentation" (read DPOF|T|Properties id ["segmentation"]))
    )
    ;;
    (defun UR_IsPaused:bool (id:string)
        (at "is-paused" (read DPOF|T|Properties id ["is-paused"]))
    )
    (defun UR_NoncesUsed:integer (id:string)
        (at "nonces-used" (read DPOF|T|Properties id ["nonces-used"]))
    )
    (defun UR_NoncesExcluded:integer (id:string)
        (at "nonces-excluded" (read DPOF|T|Properties id ["nonces-excluded"]))
    )
    ;;
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPOF|T|Properties id ["supply"]))
    )
    ;;
    (defun UR_RewardBearingToken:string (id:string)
        (at "reward-bearing-token" (read DPOF|T|Properties id ["reward-bearing-token"]))
    )
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPOF|T|Properties id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPOF|T|Properties id ["sleeping-link"]))
    )
    (defun UR_Hibernation:string (id:string)
        (at "hibernation-link" (read DPOF|T|Properties id ["hibernation-link"]))
    )
    ;;
    (defun UR_IzId:bool (id:string)
        (let
            (
                (trial (try false (read DPOF|T|Properties id))) 
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_NonceHolder:string (id:string nonce:integer)
        (at "holder" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["holder"]))
    )
    (defun UR_NonceID:string (id:string nonce:integer)
        (at "id" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["id"]))
    )
    (defun UR_NonceValue:integer (id:string nonce:integer)
        (at "value" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["value"]))
    )
    (defun UR_NonceSupply:decimal (id:string nonce:integer)
        (at "supply" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["supply"]))
    )
    (defun UR_NonceMetaData:[object] (id:string nonce:integer)
        (at "meta-data-chain" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["meta-data-chain"]))
    )
    (defun UR_NoncesSupplies:[decimal] (id:string nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] element:integer)
                    (ref-U|LST::UC_AppL acc (UR_NonceSupply id element))
                )
                []
                nonces
            )
        )
    )
    (defun UR_NoncesMetaDatas:[[object]] (id:string nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[[object]] element:integer)
                    (ref-U|LST::UC_AppL acc (UR_NonceMetaData id element))
                )
                []
                nonces
            )
        )
    )
    (defun UR_IzNonce:bool (id:string nonce:integer)
        (let
            (
                (trial (try false (read DPOF|T|Nonces (UC_IdNonce id nonce))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_Verum1:[string] (id:string)
        (at "a-frozen" (read DPOF|T|VerumRoles id ["a-frozen"]))
    )
    (defun UR_Verum2:[string] (id:string)
        (at "r-oft-add-quantity" (read DPOF|T|VerumRoles id ["r-oft-add-quantity"]))
    )
    (defun UR_Verum3:[string] (id:string)
        (at "r-oft-burn" (read DPOF|T|VerumRoles id ["r-oft-burn"]))
    )
    (defun UR_Verum4:string (id:string)
        (at "r-oft-create" (read DPOF|T|VerumRoles id ["r-oft-create"]))
    )
    (defun UR_Verum5:[string] (id:string)
        (at "r-transfer" (read DPOF|T|VerumRoles id ["r-transfer"]))
    )
    ;;
    ;;
    (defun UR_R-Frozen:bool (id:string account:string)
        ;;(at "frozen" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["frozen"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (and
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "frozen" : false}
                    { "frozen" := fr }
                    fr
                )
                (not (ref-DALOS::UR_AutonomicRoles account))
            )
        )
    )
    (defun UR_R-AddQuantity:bool (id:string account:string)
        ;;(at "role-oft-add-quantity" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-add-quantity"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-oft-add-quantity" : false}
                    { "role-oft-add-quantity" := roaq }
                    roaq
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_R-Burn:bool (id:string account:string)
        ;;(at "role-oft-burn" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-burn"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-oft-burn" : false}
                    { "role-oft-burn" := rob }
                    rob
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_R-Create:bool (id:string account:string)
        ;;(at "role-oft-create" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-create"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner:string (UR_Konto id))
            )
            (fold (or) false
                [
                    (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                        { "role-oft-create" : false}
                        { "role-oft-create" := roc }
                        roc
                    )
                    (= account owner)
                    (ref-DALOS::UR_AutonomicRoles account)
                ]
            )
        )
    )
    (defun UR_R-Transfer:bool (id:string account:string)
        ;;(at "role-transfer" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-transfer"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-transfer" : false}
                    { "role-transfer" := rt }
                    rt
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    ;;
    (defun UR_AccountSupply:decimal (id:string account:string)
        (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
            { "total-account-supply" : 0.0 }
            { "total-account-supply" := tas}
            tas
        )
    )
    (defun UR_IzAccount:bool (id:string account:string)
        (let
            (
                (trial (try false (read DPOF|T|AccountRoles (UC_IdAccount id account))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun URHC_WipePure:object{DpofUdcV2.RemovableNonces} (account:string id:string)
        @doc "Uses Expensive Read Functions to obtain a |object{DpofUdcV2.RemovableNonces}| that can be used \
            \ to execute a <C_WipePure>, bypassing the expensive gas costs of using (keys...) or (select...) functions"
        (let
            (
                (nonces:[integer] (URH_AccountNonces account id))
                (amounts:[decimal] (UR_NoncesSupplies id nonces))
            )
            (UDC_RemovableNonces nonces amounts)
        )
    )
    (defun URHC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string slice-count:integer)
        @doc "Hydra wipe PREFLIGHT (UI /local ONLY — the one heavy read of the flow): dirty-reads \
            \ the full wipeable set via <URHC_WipePure> and partitions it into the slice plan. \
            \ The UI fires one <Cp_WipeSlice> tx per slice, all in parallel; a re-read after a \
            \ partial campaign naturally returns the outstanding remains (re-plan is implicit). \
            \ Seed <slice-count> with <UC_ComputeMinWipeSliceCount>."
        (UC_BuildWipeSlicePlan account id (URHC_WipePure account id) slice-count)
    )
    (defun URC_IzRBT:bool (reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in any atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            true
        )
    )
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in a specific atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            (if (= (UR_RewardBearingToken reward-bearing-token) atspair)
                true
                false
            )
        )
    )
    ;;
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPOF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPOF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URC_HasHibernation:bool (id:string)
        @doc "Returns a boolean if DPOF has a hibernation counterpart"
        (if (= (UR_Hibernation id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dpof:string)
        ;;#31M fix: dropped the "Sleeping LP Tokens not allowed" enforce (moved to
        ;;UEV_ParentOwnership, the only caller that actually needs it - see its own @doc). A
        ;;URC_* must never enforce; the read-context caller (DPL-UR's wallet-listing helper)
        ;;needs a pure derivation and the existing "Z|" branch below already handles a
        ;;Sleeping-LP-shaped id correctly, same as any other Sleeping token.
        @doc "Computes <dpof> parent"
        (let
            (
                (first-two:string (take 2 dpof))
            )
            (cond
                ((= first-two "V|") (UR_Vesting dpof))
                ((= first-two "Z|") (UR_Sleeping dpof))
                ((= first-two "H|") (UR_Hibernation dpof))
                dpof
            )
        )
    )
    (defun URC_BrandingKonto:string (entity-id:string)
        @doc "The account with BRANDING AUTHORITY over <entity-id>: the PARENT token's owner, \
            \ or the entity's own owner when it IS its own parent. \
            \ \
            \ Exists because that rule was being retyped at call sites, and got retyped WRONG: \
            \ the patron/executor migration inserted `(UR_Konto (URCv_Parent x))` as the \
            \ executor for the branding entrypoints, which is right only for a PURE entity. \
            \ For a derived one -- `Z|VST-...` -- the parent is a DPTF id, so the read hit \
            \ DPOF's own properties table and died with \
            \ `No value found in table ... for key: VST-...`. \
            \ UEV_ExecutorIsParentKonto already computed this correctly; this is that \
            \ computation, named once and callable, so a call site never has to branch."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent entity-id))
            )
            (if (= parent entity-id) (UR_Konto entity-id) (ref-DPTF::UR_Konto parent))
        )
    )

    ;;
    ;;  [URD]
    ;;
    ;;1] Returns True Fungibles held by Account
    (defun URH_HeldOrtoFungibles:[string] (account:string)
        @doc "Returns all Orto Fungibles that are registered for a given <account>"
        (map (at "id")
            (select DPOF|T|AccountRoles ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts that are registered for a given DPTF
    (defun URH_ExistingOrtoFungibles:[string] (dotf:string)
        @doc "Returns all Ouronet Accounts that are registered for a given <dotf>"
        (map (at "account")
            (select DPOF|T|AccountRoles ["account"]
                (where "id" (= dotf))
            )
        )
    )
    ;;3]Returns a List of DPOFs that are owned by a given Account for Management Purposes
    (defun URH_OwnedOrtoFungibles:[string] (account:string)
        @doc "Returns all Orto Fungibles that can be managed by the given <account>"
        (map (at "id")
            (select DPOF|T|Properties ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;4]
    (defun URH_AccountNonces:[integer] (account:string dpof-id:string)
        (map (at "value")
            (select DPOF|T|Nonces ["value"]
                (and?
                    (where "id" (= dpof-id))
                    (where "holder" (= account))
                )
            )
        )
    )
    ;;
    ;;
    ;;[URCi] cost readers — single cost source per op. The C_/XE_ returns/bills its URCi; Phase 1.2 INFO
    ;;  previews from the same reader. (Per-nonce wipe/move costs are URCi_WipeCumulator/URCi_MoveCumulator.)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_Konto entity-id) 1.5)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_RotateOwnership" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Control" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_TogglePause" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleFreezeAccount" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleAddQuantityRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleBurnRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_MoveCreateRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleTransferRole" "usage")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_AddQuantity" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Burn" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_WipeSlim" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-IGNIS::UDC_LegCumulator "special-of-link" (ref-DPTF::UR_Konto main-dptf))
        )
    )
    ;;  Mint: URCi is the Medium price part; C_Mint concatenates the created-nonce output onto it.
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Mint" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  Issue/UpgradeBranding: :decimal price rails (the cumulator output/side-effect stays in the write).
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): ortofungible issuance = $10 = 1000 ignis/token (owner 2026-09-05); VST links inherit this. \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-of"))
               (ref-IGNIS::UC_IgnisComponents "DPOF|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (ortofungible = $10 => 100 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-of"))
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
    ;;  DeployAccount: CORE C_DeployAccount returns no cumulator; the ignis|small toll is billed
    ;;  by Talos keyed on the deployed account. This reader single-sources that toll for exec + INFO.
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string)
        @doc "IGNIS cost of DELIBERATE token-account creation (the explicit C_DeployAccount \
            \ entrypoint, billed at its Talos wrapper): the central IG|DETER token-account tier \
            \ (50) — an anti-spam deterrent per owner 2026-09-05. Auto-creation inside a transfer \
            \ never reaches this reader and stays FREE (S1 constraint). Shared by exec + INFO_*."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_DeployAccount" "token-account")
                account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;3]Returns a 
    (defun UEV_id (id:string)
        (with-default-read DPOF|T|Properties id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPOF ID {} does not exist" [id])
            )
        )
    )
    (defun UEV_NoncesCirculating (id:string nonces:[integer])
        @doc "Validates that <nonces> are in circulation"
        (map
            (lambda
                (element:integer)
                (let
                    (
                        (nonce-supply:decimal (UR_NonceSupply id element))
                    )
                    (enforce 
                        (!= nonce-supply -1.0) 
                        (format "{} {} Nonce {} must be in Circulation for exec"[OF id element])
                    )
                )
            )
            nonces
        )
    )
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string)
        @doc "BINDS <executor> to the branding authority for <entity-id>: the PARENT token's \
            \ owner, or the entity's own owner when it IS its own parent. Ownership is proven \
            \ by UEV_ParentOwnership inside the branding capability; this supplies the other \
            \ half -- that the account the caller NAMED is that owner."
        (enforce (= executor (URC_BrandingKonto entity-id)) "Executor is not the Parent Token Owner")
    )
    (defun UEV_ExecutorIsKonto (executor:string id:string)
        @doc "BINDS the named <executor> to DPOF <id>'s owner. Ownership of <executor> is proven \
            \ INDIRECTLY -- every entrypoint calling this reaches <CAP_Owner id>, which enforces \
            \ ownership of <(UR_Konto id)>. This supplies the other half: that the account the \
            \ caller NAMED is that same owner. Without it the executor parameter would be \
            \ decorative, which is worse than absent because it reads as verified. \
            \ (patron/executor canon 2.2 -- an indirect route is permitted and MUST be named.) \
            \ \
            \ NOT used by C_Mint / C_AddQuantity / C_Burn: their capabilities enforce \
            \ CAP_EnforceAccountOwnership on the executor DIRECTLY, so it is already proven."
        (enforce (= executor (UR_Konto id)) "Executor is not the Token Owner")
    )
    (defun UEV_ParentOwnership (id:string)
        @doc "Enforces: \
            \ <id> Ownership, if <id> is pure \
            \ <(UR_Vesting id)>, if its a Vested ID \
            \ <(UR_Sleeping id)>, if its a Sleeping ID \
            \ <(UR_Hibernation id)>, if its a Hibernation ID \
            \ While ensuring a Sleeping LP cant be used for this operation."
        (let
            (
                (fourth:string (drop 3 (take 4 id)))
            )
            ;;#31M fix: moved here from URCv_Parent, which must never enforce - this is the only
            ;;caller that actually needs this rejection (per this function's own @doc).
            ;;
            ;;HOISTED 2026-09-17, ABOVE the <parent> binding, and the note that used to sit here was
            ;;half wrong in a way worth recording. It said flatly that this enforce was UNPINNED and
            ;;UNREACHABLE -- that <parent>, bound eagerly by URCv_Parent, READS the properties table,
            ;;so any sleeping-LP id aborts in that read first, and that reaching it "needs a REAL
            ;;issued sleeping-LP token, which no suite creates".
            ;;
            ;;Measured, both halves: `URCv_Parent` only reads for ids prefixed `V|`, `Z|` or `H|`;
            ;;every other shape falls through to its `dpof` default with NO read at all. So
            ;;`Z|X|NOSUCH-…` did abort on the raw table key exactly as described, while
            ;;`ABC|NOSUCH-…` reached this enforce and produced its written message. A PARTIAL shadow,
            ;;not a total one -- the same shape as DEFECT-LEDGER G-10.
            ;;
            ;;<fourth> is a pure string slice of <id> and needs no table access, so the guard is
            ;;simply hoisted above the binding. Both shapes now refuse in the written words, which is
            ;;also what the DPTF twin does (it enforces before its read) -- the twin is pinned by
            ;;REPL/modules/DPTF.repl <<DPTF-G5>>, and this one by <<DPOF-G16>>.
            (enforce (!= fourth BAR) "Sleeping LP Tokens not allowed for this operation")
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (parent:string (URCv_Parent id))
                )
                (if (= parent id)
                    (CAP_Owner id)
                    (ref-DPTF::CAP_Owner parent)
                )
            )
        )
    )
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer])
        @doc "Enforces <nonces> of <id> are held by <account>"
        (map
            (lambda
                (idx:integer)
                (let
                    (
                        (nonce:integer (at idx nonces))
                        (nonce-holder:string (UR_NonceHolder id nonce))
                    )
                    (enforce (= account nonce-holder) (format "Nonce {} of DPOF {} is not owned by account" [nonce id account]))
                )
            )
            (enumerate 0 (- (length nonces)1))
        )
    )
    (defun UEV_Amount (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor amount decimals) amount)
                (format "{} is not conform with the {} prec" [amount id])
            )
            (enforce
                (> amount 0.0)
                (format "{} is not a Valid Transaction amount" [amount])
            )
        )
    )
    ;;
    (defun UEV_UpdateRewardBearingToken (id:string)
        (let
            (
                (rbt:string (UR_RewardBearingToken id))
            )
            (enforce (= rbt BAR) (format "{} as an RBT is immutable tied to an ATS-Pair" [OF]))
        )
    )
    ;;
    (defun UEV_CanUpgradeON (id:string)
        (let
            (
                (x:bool (UR_CanUpgrade id))
            )
            (enforce (= x true) (format "{} {} properties cannot be upgraded" [OF id]))
        )
    )
    (defun UEV_CanChangeOwnerON (id:string)
        (let
            (
                (x:bool (UR_CanChangeOwner id))
            )
            (enforce (= x true) (format "{} {} ownership cannot be changed" [OF id]))
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id))
            )
            (enforce (= x true) (format "For {} {} no special roles can be added" [OF id]))
        )
    )
    (defun UEV_CanTransferOftCreateRoleON (id:string)
        (let
            (
                (x:bool (UR_CanTransferOftCreateRole id))
            )
            (enforce (= x true) (format "{} Token {} cannot have its create role transfered" [OF id]))
        )
    )
    (defun UEV_CanFreezeON (id:string)
        (let
            (
                (x:bool (UR_CanFreeze id))
            )
            (enforce (= x true) (format "{} {} cannot be freezed" [OF id]))
        )
    )
    (defun UEV_CanWipeON (id:string)
        (let
            (
                (x:bool (UR_CanWipe id))
            )
            (enforce (= x true) (format "{} {} cannot be wiped" [OF id]))
        )
    )
    (defun UEV_CanPauseON (id:string)
        (let
            (
                (x:bool (UR_CanPause id))
            )
            (enforce (= x true) (format "{} {} cannot be paused" [OF id])
            )
        )
    )
    (defun UEV_PauseState (id:string state:bool)
        (let
            (
                (x:bool (UR_IsPaused id))
            )
            (if state
                (enforce x (format "{} {} is already unpaused" [OF id]))
                (enforce (= x false) (format "{} {} is already paused" [OF id]))
            )
        )
    )
    ;;
    (defun UEV_SegmentationState (id:string state:bool)
        (let
            (
                (x:bool (UR_Segmentation id))
            )
            (enforce (= x state) (format "Segmentation state for {} {} must be set to {} for exec" [OF id state]))
        )
    )
    (defun UEV_EnforceSegmentationForTransmit (id:string)
        @doc "C_Transmit and AQP OrtoFungible Transmit stake/unstake: issued DPOF id with segmentation enabled."
        (UEV_id id)
        (UEV_SegmentationState id true)
    )
    (defun UEV_AccountFreezeState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Frozen id account))
            )
            (enforce (= x state) (format "Frozen for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-AddQuantity id account))
            )
            (enforce (= x state) (format "Add Quantity Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountBurnState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Burn id account))
            )
            (enforce (= x state) (format "Burn Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountCreateState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Create id account))
            )
            (enforce (= x state) (format "Create Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Transfer id account))
            )
            (enforce (= x state) (format "Transfer Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    ;;
    (defun UEV_Vesting (id:string existance:bool)
        (let
            (
                (has-vesting:bool (URC_HasVesting id))
            )
            (enforce (= has-vesting existance) (format "Vesting for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_Sleeping (id:string existance:bool)
        (let
            (
                (has-sleeping:bool (URC_HasSleeping id))
            )
            (enforce (= has-sleeping existance) (format "Sleeping for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_Hibernation (id:string existance:bool)
        (let
            (
                (has-hibernation:bool (URC_HasHibernation id))
            )
            (enforce (= has-hibernation existance) (format "Hibernation for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (verum-five:[string] (UR_Verum5 id))
                (lvf:integer (length verum-five))
                (transfer-roles:integer
                    (if (and (= lvf 1) (= verum-five [BAR]))
                        0 lvf
                    )
                )
                (are-transfer-roles-active:bool (if (> transfer-roles 0) true false))
                (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                (allow:string (format "{} Transfer from {} to {} is allowed" [OF ss sr]))
            )
            (if are-transfer-roles-active
                (let
                    (
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ouroboros:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                        (dalos:string (ref-DALOS::GOV|DALOS|SC_NAME))
                        ;;
                        (sender-transfer-role:bool (UR_R-Transfer id sender))
                        (receiver-transfer-role:bool (UR_R-Transfer id receiver))
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
    (defun CAP_Owner (id:string)
        @doc "Enforces DPOF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_Konto id))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_TransferWholeNonces
        (id:string sender:string receiver:string nonces:[integer])
        @doc "Move whole <nonces> from <sender> to <receiver> — shared by C_Transfer and C_BulkTransfer."
        (require-capability (SECURE))
        (let
            (
                (sender-supply:decimal (UR_AccountSupply id sender))
                (receiver-supply:decimal (UR_AccountSupply id receiver))
                (nonces-supplies:[decimal] (UR_NoncesSupplies id nonces))
                (sum:decimal (fold (+) 0.0 nonces-supplies))
            )
            (XB_DeployAccountWNE receiver id)
            (XI_UpdateAccountSupply id sender (- sender-supply sum))
            (XI_UpdateAccountSupply id receiver (+ receiver-supply sum))
            (map
                (lambda
                    (element:integer)
                    (XI_UpdateNonceHolder id element receiver)
                )
                nonces
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPOF|C>ISSUE
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            ;;
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            can-transfer-oft-create-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
        (P|UEV_IMC)
        (with-capability 
            (DPOF|C>ISSUE 
                account name ticker decimals    
                can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role
                can-freeze can-wipe can-pause
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (l1:integer (length name))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (folded-lst:[string]
                        (fold
                            (lambda
                                (acc:[string] index:integer)
                                (let
                                    (
                                        (id:string
                                            (XIv_Issue
                                                account
                                                (at index name)
                                                (at index ticker)
                                                (at index decimals)
                                                ;;
                                                (at index can-upgrade)
                                                (at index can-change-owner)
                                                (at index can-add-special-role)
                                                (at index can-transfer-oft-create-role)
                                                ;;
                                                (at index can-freeze)
                                                (at index can-wipe)
                                                (at index can-pause)
                                                ;;
                                                (at index iz-special)
                                            )
                                        )
                                    )
                                    (ref-BRD::XE_Issue id)
                                    (ref-U|LST::UC_AppL acc id)
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs account trigger folded-lst)
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DeployAccountWNE (account:string id:string)
        (P|UEV_IMC)
        (let
            (
                (iz-account:bool (UR_IzAccount account id))
            )
            (if (not iz-account)
                (XBv_DeployAccount id account)
                true
            )
        )
    )
    ;;
    ;;Enforce: per-element-in-map -- XB_IssueFree maps this over LISTS, so UEV_Decimals validates one
    ;;          element. DPOF|C>ISSUE validates only UniformList/IzUnique/account-ownership and has no
    ;;          per-element loop; adding one purely for decimals is more code.
    ;;Protection: Class 2 — SECURE
    (defun XIv_Issue:string
        (
            account:string
            name:string
            ticker:string
            decimals:integer
            ;;
            can-upgrade:bool
            can-change-owner:bool
            can-add-special-role:bool
            can-transfer-oft-create-role:bool
            ;;
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            ;;
            iz-special:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (id:string (ref-U|DALOS::UDC_Makeid ticker))
            )
            (ref-U|DALOS::UEV_Decimals decimals)
            (ref-U|DALOS::UEV_NameOrTicker name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker ticker false iz-special)
            ;;
            (XI_InsertNewId id
                {"id"                           : id
                ,"owner-konto"                  : account
                ,"name"                         : name
                ,"ticker"                       : ticker
                ,"decimals"                     : decimals
                ;;
                ,"can-upgrade"                  : can-upgrade                           ;;false
                ,"can-change-owner"             : can-change-owner                      ;;false
                ,"can-add-special-role"         : can-add-special-role                  ;;true
                ,"can-transfer-oft-create-role" : can-transfer-oft-create-role          ;;false
                ;;
                ,"can-freeze"                   : can-freeze                            ;;true
                ,"can-wipe"                     : can-wipe                              ;;true
                ,"can-pause"                    : can-pause                             ;;false
                ,"segmentation"                 : false
                ;;
                ,"is-paused"                    : false
                ,"nonces-used"                  : 0
                ,"nonces-excluded"              : 0
                ;;
                ,"supply"                       : 0.0
                ;;
                ,"reward-bearing-token"         : BAR
                ,"vesting-link"                 : BAR
                ,"sleeping-link"                : BAR
                ,"hibernation-link"             : BAR}
            )
            (XI_WriteRoles id
                (UDC_VerumRoles
                    [BAR]
                    [BAR]
                    [BAR]
                    account
                    [BAR]
                )
            )
            (XBv_DeployAccount id account)
            id
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>CONTROL
    (defun XI_Control
        (
            id:string
            can-upgrade:bool
            can-change-owner:bool
            can-add-special-role:bool
            can-transfer-oft-create-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            segmentation:bool
        )
        (require-capability (DPOF|S>CONTROL id))
        (update DPOF|T|Properties id
            {"can-upgrade"                  : can-upgrade
            ,"can-change-owner"             : can-change-owner
            ,"can-add-special-role"         : can-add-special-role
            ,"can-transfer-oft-create-role" : can-transfer-oft-create-role
            ,"can-freeze"                   : can-freeze
            ,"can-wipe"                     : can-wipe
            ,"can-pause"                    : can-pause
            ,"segmentation"                 : segmentation}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPOF|C>DEBIT
    (defun XI_DebitNonces (account:string id:string nonces:[integer] amounts:[decimal] wipe-mode:bool)
        @doc "Debit DPOF <id> <nonces> on <account> with <amounts> \
            \ Will Take Nonce out of circulation if all <nonce> supply is debited. \
            \ Only Performs debitation, does not update supply. \
            \ All <nonces> must be held by <account>"
        (require-capability (DPOF|C>DEBIT account id nonces amounts wipe-mode))
        (let
            (
                (tas:decimal (UR_AccountSupply id account))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (XI_UpdateAccountSupply id account (- tas sum))
            ;;Per-nonce debit; each full debit yields 1 so the exclusion counter is
            ;;bumped ONCE per batch (single hot-row write) instead of once per nonce
            (XI_IncrementNoncesExcludedBy id
                (fold (+) 0
                    (map
                        (lambda
                            (idx:integer)
                            (let
                                (
                                    (nonce:integer (at idx nonces))
                                    (amount:decimal (at idx amounts))
                                    (nonce-supply:decimal (UR_NonceSupply id nonce))
                                )
                                (if (= amount nonce-supply)
                                    ;;Take Nonce out of Circulation;
                                    (do
                                        (XI_UpdateNonceSupply id nonce -1.0)
                                        (XI_UpdateNonceHolder id nonce BAR)
                                        1
                                    )
                                    ;;Only Debit Nonce without taking it out of circulation
                                    (do
                                        (XI_UpdateNonceSupply id nonce (- nonce-supply amount))
                                        0
                                    )
                                )
                            )
                        )
                        (enumerate 0 (- (length nonces) 1))
                    )
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|C>CREDIT
    (defun XI_CreditNonces (account:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        @doc "Credit a DPOF <id> <nonces> on <account> with <amounts> and <meta-datas> \
            \ Only Performs creditation, does not update supply\
            \ Designed to Process <nonces> in two variants \
            \ Either the nonce exists already, in which case length must be 1; <iz-singular> true\
            \ Or ALL the nonce dont exist, in which case the length must be greater than 1; <iz-singular> false"
        (require-capability (DPOF|C>CREDIT account id nonces amounts meta-data-array))
        ;;Deploy Account WNE
        (XB_DeployAccountWNE account id)
        (let
            (
                (iz-singular:bool (UC_IzSingular id nonces))
                (iz-consecutive:bool (UC_IzConsecutive id nonces))
                (tas:decimal (UR_AccountSupply id account))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            ;;Update Total Individual Account Supply
            (XI_UpdateAccountSupply id account (+ tas sum))
            (if iz-singular
                (XI_UpdateNonceSupply id (at 0 nonces) (+ (UR_NonceSupply id (at 0 nonces)) (at 0 amounts)))
                true
            )
            (if iz-consecutive
                (do
                    ;;Update <nonces-used> in properties of <id>
                    (XI_UpdateNoncesUsed id (at 0 (take -1 nonces)))
                    ;;Insert New Nonces
                    (XI_InsertNewNonces account id nonces amounts meta-data-array)
                )
                true
            )
        )
    )
    ;;
    ;;Pure Write/Update Functions
    ;;1]DPOF|T|Properties
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_InsertNewId (id:string id-data:object{DpofUdcV2.DPOF|Properties})
        (P|UEV_IMC)
        (insert DPOF|T|Properties id id-data)
    )
    ;;Protection: Class 3 — Custom: DPOF|S>ROTATE-OWNERSHIP
    (defun XI_ChangeOwnership (id:string new-owner:string)
        (require-capability (DPOF|S>ROTATE-OWNERSHIP id new-owner))
        (update DPOF|T|Properties id
            {"owner-konto" : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>PAUSE
    (defun XI_TogglePause (id:string toggle:bool)
        (require-capability (DPOF|S>PAUSE id toggle))
        (update DPOF|T|Properties id
            { "is-paused" : toggle}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSupply (id:string new-supply:decimal)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"supply" : new-supply}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNoncesUsed (id:string new-value:integer)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"nonces-used" : new-value}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementNoncesExcludedBy (id:string count:integer)
        @doc "Bumps the <id> excluded-nonce counter by <count> in ONE write (batched per debit \
            \ call instead of once per fully-wiped nonce); no-op when <count> is zero."
        (require-capability (SECURE))
        (if (> count 0)
            (let
                (
                    (excluded:integer (UR_NoncesExcluded id))
                )
                (update DPOF|T|Properties id
                    {"nonces-excluded" : (+ excluded count)}
                )
            )
            "no-excluded-nonces"
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardBearingToken (atspair:string hot-rbt:string)
        (P|UEV_IMC)
        (with-read DPOF|T|Properties hot-rbt
            {"reward-bearing-token" := rbt}
            ;;SHADOWED BY A ONE-WAY LATCH IN THE ONLY CALLER. This function has exactly one caller in
            ;;the whole codebase: ATS::C_AddHotRBT (08_ATS.pact:3196). That caller's `let` binds
            ;;<ico2> to (DPOF::C_Control hot-rbt false false false false true true false false) --
            ;;whose FIRST argument is <can-upgrade>, set to false. Pact evaluates let bindings
            ;;eagerly, so on the first successful registration can-upgrade is latched off BEFORE this
            ;;line runs, and it can never be turned back on: C_Control itself requires can-upgrade to
            ;;be true (06_DPOF.pact:2076, "{} {} properties cannot be upgraded").
            ;;
            ;;So a second registration of the same DPOF is refused -- but by C_Control, one binding
            ;;earlier, with the can-upgrade message rather than this one. The state this enforce
            ;;tests for (rbt != BAR) is therefore unreachable here: the only way a DPOF's
            ;;reward-bearing-token becomes non-BAR is through this very function, and the same
            ;;transaction latches the door behind it.
            ;;
            ;;NOT REMOVED, and deliberately so: it is the invariant the latch happens to enforce, and
            ;;it would become live again the moment C_AddHotRBT's ico2 stopped clearing can-upgrade.
            ;;Demonstrated, not assumed, by REPL/modules/ATS.repl <<ATS-G23>>, which drives the full
            ;;re-registration route to the wall and reads the message that actually comes back.
            ;;UNREACHABLE
            (enforce (= rbt BAR) (format "RBT-Data for DPOF {} is already set as ATS-Pair {}" [hot-rbt rbt]))
            (update DPOF|T|Properties hot-rbt
                {"reward-bearing-token" : atspair}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVesting (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"vesting-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSleeping (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"sleeping-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateHibernation (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"hibernation-link" : dptf}
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPOF|C>UPDATE-SPECIAL
    (defun XE_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dpof:string vzh-tag:integer)
        (P|UEV_IMC)
        (with-capability (DPOF|C>UPDATE-SPECIAL main-dptf secondary-dpof vzh-tag)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (cond
                    ((= vzh-tag 1)
                        (do
                            (ref-DPTF::XE_UpdateVesting main-dptf secondary-dpof)
                            (XI_UpdateVesting main-dptf secondary-dpof)
                        )
                    )
                    ((= vzh-tag 2)
                        (do
                            (ref-DPTF::XE_UpdateSleeping main-dptf secondary-dpof)
                            (XI_UpdateSleeping main-dptf secondary-dpof)
                        )
                    )
                    ((= vzh-tag 3)
                        (do
                            (ref-DPTF::XE_UpdateHibernation main-dptf secondary-dpof)
                            (XI_UpdateHibernation main-dptf secondary-dpof)
                        )
                    )
                    true
                )
                (URCi_UpdateSpecialOrtoFungible main-dptf)
            )
        )
    )
    ;;2]DPOF|T|Nonces
    ;;Protection: Class 2 — SECURE
    (defun XI_InsertNewNonces (nonce-owner:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        (require-capability (SECURE))
        (with-capability (SECURE)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:decimal (at idx amounts))
                            (meta-data-chain:[object] (at idx meta-data-array))
                        )
                        (XB_InsertNewNonce nonce-owner id nonce amount meta-data-chain)
                    )
                )
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_InsertNewNonce (nonce-owner:string id:string nonce:integer amount:decimal meta-data-chain:[object])
        (P|UEV_IMC)
        (insert DPOF|T|Nonces (UC_IdNonce id nonce)
            (UDC_NonceElement nonce-owner id nonce amount meta-data-chain)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNonceSupply (id:string nonce:integer new-nonce-supply:decimal)
        (require-capability (SECURE))
        (update DPOF|T|Nonces (UC_IdNonce id nonce)
            {"supply" : new-nonce-supply}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNonceHolder (id:string nonce:integer new-nonce-holder:string)
        (require-capability (SECURE))
        (update DPOF|T|Nonces (UC_IdNonce id nonce)
            {"holder" : new-nonce-holder}
        )
    )
    ;;3]DPOF|T|VerumRoles
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_WriteRoles (id:string verum-roles:object{DpofUdcV2.DPOF|VerumRoles})
        (P|UEV_IMC)
        (write DPOF|T|VerumRoles id verum-roles)
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum1 (id:string new-verum1:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"a-frozen" : new-verum1}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum2 (id:string new-verum2:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-add-quantity" : new-verum2}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum3 (id:string new-verum3:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-burn" : new-verum3}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum4 (id:string new-r-oft-create-account:string)
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-create" : new-r-oft-create-account}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum5 (id:string new-verum5:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-transfer" : new-verum5}
        )
    )
    ;;4]DPOF|T|AccountRoles
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_W|AccountRoles (id:string account:string account-data:object{DpofUdcV2.DPOF|AccountRoles})
        (P|UEV_IMC)
        (write DPOF|T|AccountRoles (UC_IdAccount id account)
            account-data
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_FREEZE
    (defun XI_ToggleFreezeAccount (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_FREEZE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "frozen" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE
    (defun XI_ToggleAddQuantityRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-oft-add-quantity" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-BURN-ROLE
    (defun XI_ToggleBurnRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-BURN-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-oft-burn" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_SWITCH-CREATE-ROLE
    (defun XI_SwitchCreateRole (id:string receiver:string)
        (require-capability (DPOF|S>X_SWITCH-CREATE-ROLE id receiver))
        (update DPOF|T|AccountRoles (UC_IdAccount id (UR_Verum4 id))
            { "role-oft-create" : false}
        )
        (update DPOF|T|AccountRoles (UC_IdAccount id receiver)
            { "role-oft-create" : true}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-TRANSFER-ROLE
    (defun XI_ToggleTransferRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-transfer" : toggle}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateAccountSupply (id:string account:string new-tas:decimal)
        (require-capability (SECURE))
        (update  DPOF|T|AccountRoles (UC_IdAccount id account)
            {"total-account-supply" : new-tas}
        )
    )
    ;;{5.7}  User [A/C]
    (defun AU_OrtoFungibleAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_OrtoFungibleAccount) keyz)
        )
    )
    (defun AU_OrtoFungibleAccount (ky:string)
        (require-capability (SECURE))
        (update DPOF|T|AccountRoles ky
            {"id"       : (drop -163 ky)
            ,"account"  : (take -162 ky)}
        )
    )
    (defun AU_OrtoFungibles (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_OrtoFungible) ids)
        )
    )
    (defun AU_OrtoFungible (id:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <entity-id>'s pending branding. <executor> is bound to the PARENT token's \
            \ owner -- branding a derived entity is the parent owner's right. Ownership itself \
            \ is proven by DPOF|C>UPDATE-BRD via UEV_ParentOwnership; the binding is what keeps \
            \ the named executor from being a name nobody reads."
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (DPOF|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent entity-id))
                (parent-owner:string
                    (if (= parent entity-id)
                        (UR_Konto entity-id)
                        (ref-DPTF::UR_Konto parent)
                    )
                )
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (DPOF|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id executor months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
        @doc "Issues one or more DPOF tokens owned by <executor>, charging STOA to <patron>. \
            \ \
            \ Executor: ENFORCED INDIRECTLY -- XB_IssueFree -> DPOF|C>ISSUE -> \
            \ CAP_EnforceAccountOwnership <executor>. Note that the (SECURE) capability wrapping \
            \ the call provides NO protection (SECURE is `true`); the real gate is the one named \
            \ above, inside XB_IssueFree. Without it anyone could issue a token into someone \
            \ else's ownership. (patron/executor canon 2.2, indirect route named.)"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l1:integer (length name))
                (stoa-costs:decimal (URCi_IssueStoa l1))
                (iz-special:[bool] (make-list l1 false))
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (SECURE)
                        (XB_IssueFree 
                            executor name ticker decimals 
                            can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role
                            can-freeze can-wipe can-pause iz-special
                        )
                    )
                )
            )
            (ref-IGNIS::XE_CollectStoa patron stoa-costs)
            ico
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>ROTATE-OWNERSHIP id executee)
            (XI_ChangeOwnership id executee)
            (URCi_RotateOwnership id)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>CONTROL id)
            (XI_Control id cu cco casr ctocr cf cw cp sg)
            (URCi_Control id)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>PAUSE id toggle)
            ;;Pause|Unpause <id>
            (XI_TogglePause id toggle)
            ;;Output
            (URCi_TogglePause id)
        )
    )
    ;;
    ;;Enforce: <account> existence cannot be relocated -- there is no defcap on this path to
    ;;          host it, and the ADMIN Talos door deliberately has NO ownership check on the
    ;;          target, which is its reason to exist. See the DPTF twin for the full argument.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_DeployAccount (id:string account:string)
        @doc "Activates DPOF <id> on <account>. RECLASSIFIED from `C_DeployAccount` 2026-09-21, \
            \ the twin of the DPTF change: it builds no OutputCumulator and was called from \
            \ INSIDE its own module, which a C_ may never be -- a C_ and an A_ are a module's \
            \ FINAL functions, the ones Talos wraps. Both Talos doors wrap this X_ now, and \
            \ they are where the policies differ: DPOF|C_DeployAccount is self-service and \
            \ PAYS; DPOF|A_DeployAccount is admin-only and deploys for SOMEONE ELSE."
        (P|UEV_IMC)
        ;;<id> IS CHECKED BEFORE THE BINDING GROUP, and that ordering is load-bearing. This call
        ;;used to sit three lines below, inside the `let` body -- and the binding
        ;;`(create-role-account (UR_Verum4 id))` reads DPOF|T|VerumRoles, so for an id that does not
        ;;exist the function died with `No value found in table ouronet-ns.DPOF_DPOF|T|VerumRoles
        ;;for key: <id>` and this check, written for exactly that input, was never reached.
        ;;Third occurrence of the same eager-`let` shape: C_Recover (2026-09-12), C_HotRecovery
        ;;(RT-H-003), and here. Pact evaluates every binding in a group before the body, so a
        ;;validation placed in the body cannot protect a read placed in the bindings.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-003b>>.
        (UEV_id id)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (create-role-account:string (UR_Verum4 id))
                (f:bool false)
                (role-oft-create-boolean:bool (if (= create-role-account account) true f))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                (UDC_AccountRoles 0.0 f f f role-oft-create-boolean f id account)
                {"total-account-supply"     := tas
                ,"frozen"                   := fz
                ,"role-oft-add-quantity"    := roaq
                ,"role-oft-burn"            := rob
                ,"role-oft-create"          := roc
                ,"role-transfer"            := rt
                ,"id"                       := i
                ,"account"                  := a}
                (with-capability (SECURE)
                    (XB_W|AccountRoles id account
                        (UDC_AccountRoles tas fz roaq rob roc rt i a)
                    )
                )
            )
        )
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 1"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>FREEZE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-one:[string] (UR_Verum1 id))
                    (updated-verum-one:[string] (ref-U|DALOS::UCv_NewRoleList verum-one executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum1 id updated-verum-one)
                ;;Update Account Roles
                (XI_ToggleFreezeAccount id executee toggle)
                ;;Output
                (URCi_ToggleFreezeAccount id)
            )
        )
    )
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 2"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-ADD-QUANTITY-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-two:[string] (UR_Verum2 id))
                    (updated-verum-two:[string] (ref-U|DALOS::UCv_NewRoleList verum-two executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum2 id updated-verum-two)
                ;;Update Account Roles
                (XI_ToggleAddQuantityRole id executee toggle)
                ;;Output
                (URCi_ToggleAddQuantityRole id)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 3"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-BURN-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-three:[string] (UR_Verum3 id))
                    (updated-verum-three:[string] (ref-U|DALOS::UCv_NewRoleList verum-three executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum3 id updated-verum-three)
                ;;Update Account Roles
                (XI_ToggleBurnRole id executee toggle)
                ;;Output
                (URCi_ToggleBurnRole id)
            )
        )
    )
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        @doc "Switch Verum 4"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>SWITCH-CREATE-ROLE id executee)
            ;;Deploy WNE
            (XB_DeployAccountWNE executee id)
            ;;Update Account Roles — MUST run before Verum Roles below: XI_SwitchCreateRole
            ;;reads the CURRENT (pre-write) Verum4 internally to find the account to revoke.
            ;;Running XI_UpdateVerum4 first would overwrite that value to <executee> before
            ;;XI_SwitchCreateRole ever reads it, so the real previous holder would never be
            ;;revoked (DALOS audit #2C).
            (XI_SwitchCreateRole id executee)
            ;;Update Verum Roles
            (XI_UpdateVerum4 id executee)
            ;;Output
            (URCi_MoveCreateRole id)
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 5"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-TRANSFER-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-five:[string] (UR_Verum5 id))
                    (updated-verum-five:[string] (ref-U|DALOS::UCv_NewRoleList verum-five executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum5 id updated-verum-five)
                ;;Update Account Roles
                (XI_ToggleTransferRole id executee toggle)
                ;;Output
                (URCi_ToggleTransferRole id)
            )
        )
        
    )
    ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>ADD-QTY executor id nonce amount)
                ;;Credit <nonce> held on <executor> by <amount> 
                (XI_CreditNonces executor id [nonce] [amount] [[{}]])
                ;;Update <id> Supply
                (XI_UpdateSupply id (+ supply amount))
                ;;Output
                (URCi_AddQuantity id)
            )
        )
    )
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>BURN executor id nonce amount)
                ;;Debit <nonce> held on <executor> by <amount>
                (XI_DebitNonces executor id [nonce] [amount] false)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output
                (URCi_Burn id)
            )
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string amount:decimal meta-data-chain:[object])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (supply:decimal (UR_Supply id))
                (nonces-used:integer (UR_NoncesUsed id))
            )
            (with-capability (DPOF|C>MINT executor id amount meta-data-chain)
                ;;Credit <nonce> held on <executor> by <amount>
                (XI_CreditNonces executor id [(+ nonces-used 1)] [amount] [meta-data-chain])
                ;;Update <id> Supply
                (XI_UpdateSupply id (+ supply amount))
                ;;Output
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [(URCi_Mint id)]
                    [(UR_NoncesUsed id)]
                )
            )
        )
    )
    ;;Wipes
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <executee> by <amount> \
        \ Amount may be lower or equal to the nonce amount. \
        \ Requires <id> has <segmentation> set to true"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>WIPE-SLIM executee id nonce amount)
                ;;Debit <nonce> held on <executee> by <amount>
                (XI_DebitNonces executee id [nonce] [amount] true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output 2 IGNIS
                (URCi_WipeSlim id)
            )
        )
    )
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <executee> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (C_WipePure patron executor executee id (URHC_WipePure executee id))
    )
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <executee>, presented via an <removable-nonces-obj> object \
            \ \
            \ The object must be pre-read (dirty read) \
            \ \
            \ Example to retrieve the <removable-nonces-obj> \
            \ <(URHC_WipePure executee id)> ; to get the whole object \
            \ <(UCv_TakePureWipe (URHC_WipePure executee id) 165)> ; to get only the first 165 units \
            \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (supply:decimal (UR_Supply id))
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (with-capability (DPOF|C>WIPE executee id nonces)
                ;;Debit <nonces> by <amounts> on <executee> for <id>
                (XI_DebitNonces executee id nonces amounts true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply sum))
                ;;Output (2 IGNIS per Nonce Wiped)
                (URCi_WipeCumulator id removable-nonces-obj)
            )
        )
    )
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <executee>"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (C_WipePure patron executor executee id
            (UDC_RemovableNonces
                nonces
                (UR_NoncesSupplies id nonces)
            )
        )
    )
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes exactly ONE <URHC_BuildWipeSlicePlan> slice of \
            \ <account>'s <id> nonces. Order-independent and retryable: slices are disjoint by \
            \ construction, the frozen target account cannot move nonces mid-campaign, and a \
            \ replayed/duplicate slice REVERTS (a wiped nonce is decommissioned to supply -1.0, \
            \ failing debit validation) — no job state, the live table is the completion ledger. \
            \ Same authority chain as <C_WipePure>: token owner via wipe-mode, can-wipe ON, \
            \ target frozen. True Cp_ — no heavy read anywhere in its tree."
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (with-capability (DPOF|C>WIPE account id nonces)
                ;;Debit slice <nonces> by <amounts> on <account> for <id>
                (XI_DebitNonces account id nonces amounts true)
                ;;Update <id> Supply (read fresh per slice; decrements compose in any order)
                (XI_UpdateSupply id (- supply sum))
                ;;Output (2 IGNIS per Nonce Wiped)
                (URCi_WipeCumulator id removable-nonces-obj)
            )
        )
    )
    ;;Transfers
    (defun C_Transmit:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by a specific <amount> \
            \ This debits the <executor> nonces by <amount> and creates new nonces on executee of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (P|UEV_IMC)
        (let
            (
                (nonces-used:integer (UR_NoncesUsed id))
                (how-many:integer (length nonces))
                (output-nonces:[integer] (enumerate (+ nonces-used 1) (+ nonces-used how-many)))
                (meta-data-array:[[object]] (UR_NoncesMetaDatas id nonces))
                (td:object{TransmitData}
                    (UDCx_TransmitData nonces amounts output-nonces meta-data-array)
                )
            )
            (with-capability (DPOF|C>TRANSMIT id td executor executee method)
                ;;1]Debit executor
                (XI_DebitNonces executor id nonces amounts false)
                ;;2]Credit executee
                (XI_CreditNonces executee id output-nonces amounts meta-data-array)
                ;;3]Output Costs 2 IGNIS per Nonce Transmitted
                (URCi_MoveCumulator id nonces true)
            )
        )
    )
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonces:[integer] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by changing their Ownership"
        (P|UEV_IMC)
        (with-capability (DPOF|C>TRANSFER id nonces executor executee method)
            (do
                (XI_TransferWholeNonces id executor executee nonces)
                (URCi_MoveCumulator id nonces false)
            )
        )
    )
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
        @doc "Bulk whole-nonce transfer: one executor, many receivers (DemiourgosPactOrtoFungibleV2). \
            \ One IGNIS cumulator for total nonce count — not N× C_Transfer collection overhead."
        (P|UEV_IMC)
        (with-capability (DPOF|C>BULK-TRANSFER id nonces-array executor executee-lst method)
            (let
                (
                    (all-nonces:[integer] (UC_FlattenNoncesArray nonces-array))
                )
                (do
                    (map
                        (lambda (idx:integer)
                            (XI_TransferWholeNonces
                                id
                                executor
                                (at idx executee-lst)
                                (at idx nonces-array)
                            )
                        )
                        (enumerate 0 (- (length executee-lst) 1))
                    )
                    (URCi_MoveCumulator id all-nonces false)
                )
            )
        )
    )

)



;;

;; --- tables for 06_DPOF.pact (6 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPOF|T|Properties)
;; (create-table DPOF|T|Nonces)
;; (create-table DPOF|T|VerumRoles)
;; (create-table DPOF|T|AccountRoles)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact ===================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EliteV2
    @doc "Exposes Elite Account Related Functions"

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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_EliteAurynzSupply (account:string))
    (defun URC_IzIdEA:bool (id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_UpdateEliteSingle (id:string account:string))
    (defun XE_UpdateElite (id:string sender:string receiver:string))
    ;;{5.7}  User [A/C]

)
;;
(module ELITE GOV
    @doc "ELITE — the Elite-account helper core, implementing EliteV2. It holds no domain \
        \ tables of its own, instead providing Elite-Aurynz supply reads (summing the \
        \ Elite-Auryn token plus its frozen/reserved/vesting/sleeping counterparts) and \
        \ XE_UpdateElite entrypoints that recompute an account's Elite tier when Elite-Auryn \
        \ balances move. Other modules call it on transfers/mints to keep Elite tiers \
        \ current."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements EliteV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ELITE                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ELITE_ADMIN)))
    (defcap GOV|ELITE_ADMIN ()                          (enforce-guard GOV|MD_ELITE))
    ;;{G5}  functions
    ;;#56L fix: removed GOV|ELITE_ADMIN-CALLER (defcap) and GOV|CollectiblesKey (defun,
    ;;referencing an unrelated "dpdc-keyset") - two vestigial boilerplate items copied from the
    ;;module sample template, confirmed zero references anywhere in the repo (including from
    ;;other modules via ref-ELITE::). No functional change.
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
    (defcap P|ELITE|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ELITE|CALLER))
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
        (with-capability (GOV|ELITE_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ELITE_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|ELITE_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|ELITE_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (mg:guard (create-capability-guard (P|ELITE|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_EliteAurynzSupply (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (fea:string (ref-DPTF::UR_Frozen ea-id))
                        (rea:string (ref-DPTF::UR_Reservation ea-id))
                        (vea:string (ref-DPTF::UR_Vesting ea-id))
                        (sea:string (ref-DPTF::UR_Sleeping ea-id))
                        (hea:string (ref-DPTF::UR_Hibernation ea-id))
                        (fea-supply:decimal
                            (if (!= fea BAR)
                                (ref-DPTF::UR_AccountSupply fea account)
                                0.0
                            )
                        )
                        (rea-supply:decimal
                            (if (!= rea BAR)
                                (ref-DPTF::UR_AccountSupply rea account)
                                0.0
                            )
                        )
                        (vea-supply:decimal
                            (if (!= vea BAR)
                                (ref-DPOF::UR_AccountSupply vea account)
                                0.0
                            )
                        )
                        (sea-supply:decimal
                            (if (!= sea BAR)
                                (ref-DPOF::UR_AccountSupply sea account)
                                0.0
                            )
                        )
                        (hea-supply:decimal
                            (if (!= hea BAR)
                                (ref-DPOF::UR_AccountSupply hea account)
                                0.0
                            )
                        )
                    )
                    (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply hea-supply])
                )
                0.0
            )
        )
    )
    (defun URC_IzIdEA:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
                (vea:string (ref-DPTF::UR_Vesting ea-id))
                (sea:string (ref-DPTF::UR_Sleeping ea-id))
                (hea:string (ref-DPTF::UR_Hibernation ea-id))
            )
            (contains id [ea-id fea rea vea sea hea])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateEliteSingle (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (a-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not a-type)
                        (ref-DALOS::XE_UpdateElite account (URC_EliteAurynzSupply account))
                        true
                    )
                )
                true
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateElite (id:string sender:string receiver:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (s-type:bool (ref-DALOS::UR_AccountType sender))
                (r-type:bool (ref-DALOS::UR_AccountType receiver))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not s-type)
                        (ref-DALOS::XE_UpdateElite sender (URC_EliteAurynzSupply sender))
                        true
                    )
                    (if (not r-type)
                        (ref-DALOS::XE_UpdateElite receiver (URC_EliteAurynzSupply receiver))
                        true
                    )
                )
                true
            )
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 07_ELITE.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

