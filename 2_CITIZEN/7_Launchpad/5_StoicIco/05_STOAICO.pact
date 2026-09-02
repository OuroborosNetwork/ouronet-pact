(module STOAICO GOV
    ;;
    (implements OuronetPolicyV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_STOAICO                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst DEMIPAD|SC_NAME               (GOV|DEMIPAD|SC_NAME))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|STOAICO_ADMIN)))
    (defcap GOV|STOAICO_ADMIN ()            (enforce-guard GOV|MD_STOAICO))
    ;;{G3}
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;; [Keys]
    (defun CT_Namespace ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|LaunchpadKey ()              (+ (CT_Namespace) ".dh_sc_mb-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DEMIPAD|SC_NAME ()           (at 0 ["Σ.Îäć$ЬчýφVεÎÿůпΨÖůηüηŞйnюŽXΣşpЩß5ςĂκ£RäbE₳èËłŹŘYшÆgлoюýRαѺÑÏρζt∇ŹÏýжIŒațэVÞÛщŹЭδźvëȘĂтPЖÃÇЭiërđÈÝДÖšжzČđзUĚĂsкιnãñOÔIKпŞΛI₳zÄû$ρśθ6ΨЬпYпĞHöÝйÏюşí2ćщÞΔΔŻTж€₿ŞhTțŽ"]))
    ;;
    ;; [PBLs]
    (defun GOV|DEMIPAD|PBL ()               (at 0 ["9F.gGCkuc2wMAnFAjuFphikftLdl6qFqBD4yfeMEe9u65yMqf4r340Jd6dphh1d7E1cE20btMwl4HJ2cBEMvp209GA1eD4syB96hu4nmpFbB7dKnJEMz4p8fGLcmhvrBCfDmM0axnGin8qedl5vDtwbgL3l1aK5BsmjkEEJartqCH8qG8ialtjxwCcIMf50t2lkeww6Dct5LlmmLG25FmfpcgnwMMnkJl4Gfn9gwoA6vm0jKebjhodeJLjxnh9L11ss8f26866dqv1tEphxFFqutGetH4Itj3rHkrcrGsnlqpf4gfJp94b0gBwIBe4vCj6ha8jm6kd3f8B6pEaJtkJ3fbs6rCcGibltz1BAMn0vvKME5ddFyGBnzssk1s2s0vFzwxs6vjC61Ma2l1xDxqdg1thAk2u01hDiGndLhzK73HAfgtk7bxscn0qKhymG6JAqnEFt282pyHAq5nIthK9bA8nH76x7FEpLz4eK9tLIBsyjb8M5DxaeEei6pEnLxFCAg7ulacgtjjpjMiAaqhpmM1jEHqjt4G85q4L33zrME7whgIkIpIgwnF2qKd4"]))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|STOAICO|CALLER ()
        true
    )
    (defcap P|PAD-STOAICO|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|STOAICO|CALLER))
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
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|STOAICO_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|STOAICO_ADMIN)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DPAD:module{OuronetPolicyV1} DEMIPAD)
                (mg:guard (create-capability-guard (P|STOAICO|CALLER)))
            )
            (ref-P|DPAD::A_P|Add
                "STOAICO|RemoteGov"
                (create-capability-guard (P|PAD-STOAICO|REMOTE-GOV))
            )
            (ref-P|DPAD::A_P|AddIMP mg)
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
    (defschema UserContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-earned:integer       ;;Adds Urstoa earned (WURSTOA bought with 5$ Contributions)
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz                 ;;Stores the amount of Dollarz Contributed by Account; same as <dollarz>
        last-rps:decimal            ;;Value of the Users last RPS
        pending-rewards:decimal     ;;Amount of pending rewards the user can claim (amount of WSTOA user can still claim)
        last-collected-round:integer ;;#1C: the distribution-round this account last collected. Collect allowed only when < the vault distribution-round (one collect per round; a new A_Inject opens the next round).
        ;;
        ;;Select Keyz
        owner-id:string             ;;Ouronet Account
    )
    (defschema GeneralContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-left:integer         ;;Subtracts, storing UrStoa left
        users:integer               ;;Stores number of participants
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz-supply          ;;Stores the total amount of Virtual Dollars in the Vault; same as <dollarz>; Functions as global score
        wstoa-supply:decimal        ;;Stores the total WSTOA held by the distribution Vault (10 mil wSTOA of ICO sale)
        nzs-count:integer           ;;Stores the number of users with non zero score.
        current-rps:decimal         ;;Stores current RPS decimal
        unclaimed-count:integer     ;;Stores the total number of user with unclaimed Rewards.
        distribution-round:integer  ;;#1C: monotonic distribution-round counter, ++ on every A_Inject. Gates collect eligibility (per-round idempotency) and the inject barrier (a new round opens only when unclaimed-count == 0).
        zombie-rewards:decimal      ;;#5M: escrow-on-empty (mirrors AQP). wSTOA injected while vault-score==0 (no stakers) is parked here (not divided) and flushed by the next non-zero-score inject (eff = amount + zombie).
        ;;
        ;;IDs
        wstoa:string
        wurstoa:string
        vusd:string
    )
    ;;{2}
    (deftable STOAICO|T|User:{UserContributionSchema})          ;;Key = <Ouronet-Account>
    (deftable STOAICO|T|General:{GeneralContributionSchema})    ;;Key = <STOAICO|INFO>
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    (defun CT_Info ()          (at 0 ["StoaIcoInformation"]))
    (defconst STOAICO|INFO          (CT_Info))
    (defconst STOA_PREC             12)
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
    (defcap INIT-ICO-DISTRIBUTION ()
        @event
        (compose-capability (SECURE))
        (compose-capability (GOV))
    )
    (defcap STOAICO|INJECT (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|ADD-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (v-usd-id:string (UR_Global10))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|REMOVE-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (v-usd-id:string (UR_Global10))
                (user-score:decimal (UR_User1 account))
            )
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (enforce 
                (<= v-usd-amount user-score) 
                (format "Removing {} from Account {} exceeds its existing balance" [v-usd-amount account])
            )
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|REDEEM-CONTRIBUTION (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (iz-account:bool (UR_IzAccount account))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (enforce iz-account (format "Account {} cannot be redeemed" [account]))
            ;;#1C: per-round idempotency — an account may collect at most once per distribution-round.
            ;;     This is the guard that kills the drain (the unclaimed-count can no longer be walked
            ;;     down to the whole-supply dust-sweep by repeated zero-value re-collects).
            (enforce
                (< (UR_User5 account) (UR_Global11))
                (format "Account {} has already collected this distribution round" [account]))
            (compose-capability (SECURE))
            (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
        )
    )
    (defcap STOAICO|ADMIN ()
        (compose-capability (GOV))
        (compose-capability (SECURE))
        (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
    )
    (defcap STOAICO|FLUSH ()
        @doc "#1C admin flush authorization — push-collect uncollected stragglers on their behalf (delivered \
            \ to them). Composes STOAICO|ADMIN, so XI_CollectFor runs in the same SECURE + REMOTE-GOV context \
            \ as a self-collect, plus admin. Evented."
        @event
        (compose-capability (STOAICO|ADMIN))
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    (defun UDC_UserData:object{UserContributionSchema}
        (a:decimal b:integer c:decimal d:decimal f:integer e:string)
        {"dollarz"              : a
        ,"urstoa-earned"        : b
        ,"last-rps"             : c
        ,"pending-rewards"      : d
        ,"last-collected-round" : f
        ,"owner-id"             : e}
    )
    ;;{F2}  Compute [UC]
    ;;{F3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_User0:object{UserContributionSchema} (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                (UDC_UserData 0.0 0 current-rps 0.0 0 account)
                {"dollarz":= d, "urstoa-earned" := ue, "last-rps" := lrps, "pending-rewards" := pr, "last-collected-round" := lcr, "owner-id" := id}
                (UDC_UserData d ue lrps pr lcr id)
            )
        )   
    )
    (defun UR_User1:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"dollarz" : 0.0}
            {"dollarz" := d}
            d
        )
    )
    (defun UR_User2:integer (account:string)
        (with-default-read STOAICO|T|User account
            {"urstoa-earned" : 0}
            {"urstoa-earned" := ue}
            ue
        )
    )
    (defun UR_User3:decimal (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                {"last-rps" : current-rps}
                {"last-rps" := l-rps}
                l-rps
            )
        )
    )
    (defun UR_User4:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"pending-rewards" : 0.0}
            {"pending-rewards" := pr}
            pr
        )
    )
    (defun UR_User5:integer (account:string)
        @doc "#1C: the distribution-round this account last collected (0 default)."
        (with-default-read STOAICO|T|User account
            {"last-collected-round" : 0}
            {"last-collected-round" := lcr}
            lcr
        )
    )
    ;;
    (defun UR_Global0:object{GeneralContributionSchema} ()
        (read STOAICO|T|General STOAICO|INFO)
    )
    (defun UR_Global1:decimal ()
        (at "dollarz" (read STOAICO|T|General STOAICO|INFO ["dollarz"]))
    )
    (defun UR_Global2:integer ()
        (at "urstoa-left" (read STOAICO|T|General STOAICO|INFO ["urstoa-left"]))
    )
    (defun UR_Global3:integer ()
        (at "users" (read STOAICO|T|General STOAICO|INFO ["users"]))
    )
    (defun UR_Global4:decimal ()
        (at "wstoa-supply" (read STOAICO|T|General STOAICO|INFO ["wstoa-supply"]))
    )
    (defun UR_Global5:integer ()
        (at "nzs-count" (read STOAICO|T|General STOAICO|INFO ["nzs-count"]))
    )
    (defun UR_Global6:decimal ()
        (at "current-rps" (read STOAICO|T|General STOAICO|INFO ["current-rps"]))
    )
    (defun UR_Global7:integer ()
        (at "unclaimed-count" (read STOAICO|T|General STOAICO|INFO ["unclaimed-count"]))
    )
    (defun UR_Global8:string ()
        (at "wstoa" (read STOAICO|T|General STOAICO|INFO ["wstoa"]))
    )
    (defun UR_Global9:string ()
        (at "wurstoa" (read STOAICO|T|General STOAICO|INFO ["wurstoa"]))
    )
    (defun UR_Global10:string ()
        (at "vusd" (read STOAICO|T|General STOAICO|INFO ["vusd"]))
    )
    (defun UR_Global11:integer ()
        @doc "#1C: the vault distribution-round (monotonic, ++ on every A_Inject)."
        (at "distribution-round" (read STOAICO|T|General STOAICO|INFO ["distribution-round"]))
    )
    (defun UR_Global12:decimal ()
        @doc "#5M: escrowed zombie-rewards — wSTOA injected while the vault had no stakers, awaiting the next non-zero-score inject."
        (at "zombie-rewards" (read STOAICO|T|General STOAICO|INFO ["zombie-rewards"]))
    )
    ;;
    (defun UR_IzAccount:bool (account:string)
        @doc "Checks if an account exists"
        (let
            (
                (trial (try false (read STOAICO|T|User account)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_ClaimableRewards (account:string)
        @doc "Computes Claimable Reward of Account"
        (if (= (UR_Global7) 1)
            (UR_Global4)
            (URC_AvailableRewards account)
        )
    )
    (defun URC_AvailableRewards (account:string)
        (let
            (
                (current-pending-rewards:decimal (UR_User4 account))
                (current-score:decimal (UR_User1 account))
                (last-rps:decimal (UR_User3 account))
                (current-rps:decimal (UR_Global6))
                ;;
                (diff-rps:decimal (- current-rps last-rps))
                (gained-pending-rewards:decimal (floor (* current-score diff-rps) STOA_PREC))
            )
            (+ current-pending-rewards gained-pending-rewards)
        )
    )
    (defun URH_UncollectedAccounts:[string] ()
        @doc "#1C Hydra preflight — the ONE heavy read: every account that still holds an UNCOLLECTED \
            \ position this distribution-round, i.e. an actual staker (dollarz > 0) whose \
            \ last-collected-round is behind the vault distribution-round. The UI slices this list into \
            \ capacity-bounded Ap_FlushUncollectedSlice legs; AA_FlushUncollected consumes it whole."
        (let
            (
                (cur-round:integer (UR_Global11))
            )
            (map
                (lambda (row:object{UserContributionSchema}) (at "owner-id" row))
                (select STOAICO|T|User
                    (and?
                        (where "last-collected-round" (> cur-round))
                        (where "dollarz" (< 0.0))
                    )
                )
            )
        )
    )
    (defun URCi_Collect:decimal (account:string)
        @doc "Pure-citizen IGNIS cost preview for C_Collect = Sigma of the sovereign Talos ops XI_CollectFor \
            \ fires: DPTF remint of urSTOA + the reward payout — a MultiTransfer (wSTOA+urSTOA) when urSTOA \
            \ is non-zero, else a single wSTOA Transfer. Data-dependent, dirty-read-fed from the live vault."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint urSTOA-id DEMIPAD|SC_NAME false))
               (if (!= urSTOA-supply 0.0)
                   (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                       (ref-TFT::URCi_MultiTransferCumulator [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account [wSTOA-supply urSTOA-supply]))
                   (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                       (ref-TFT::URCi_Transfer wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply))))
        )
    )
    (defun INFO_Collect:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        @doc "Cost preview for the C_STOAICO|Collect pure-citizen reward collect (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_Collect. No protocol STOA fee; the collect DELIVERS \
            \ wSTOA + urSTOA rewards to the account (a payout, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Collect distribution rewards for {} (pure-citizen, Sigma-billed)." [sa])
                  (format "Delivers {} wSTOA + {} urSTOA to the account (a payout, not a cost)." [wSTOA-supply urSTOA-supply]) ]
                [ (format "Collected {} wSTOA + {} urSTOA." [wSTOA-supply urSTOA-supply]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Collect account))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{F4}  Validate [UEV/CAP]
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    (defun XI_CollectFor:string (patron:string account:string)
        @doc "#1C shared settle+deliver core: pays <account> its OWN wSTOA (its RPS delta, or the whole \
            \ remaining wstoa-supply when it is the round's last unclaimed staker — the dust sweep) plus its \
            \ urSTOA, then stamps it collected for the current distribution-round and decrements \
            \ unclaimed-count. Used by C_Collect (self-collect, gated by STOAICO|REDEEM-CONTRIBUTION) and by \
            \ the admin flush (push-collect on behalf of a straggler, gated by STOAICO|FLUSH). SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            ;;1]Collect wSTOA and URSTOA Rewards — delivered to <account>, the rightful owner
            (ref-TS01-C1::C_DPTF|Mint patron urSTOA-id DEMIPAD|SC_NAME urSTOA-supply false)
            (if (!= urSTOA-supply 0.0)
                (ref-TS01-C1::C_DPTF|MultiTransfer patron
                    [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account
                    [wSTOA-supply urSTOA-supply] true
                )
                (ref-TS01-C1::C_DPTF|Transfer patron wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply true)
            )
            ;;2]Reset <pending-rewards> to 0
            (XI_ResetPendingRewards account)
            ;;3]Decrement <unclaimed-count>
            (XI_UpdateUnclaimedCount false)
            ;;4]Update <last-rps> with the D-Vault <current-rps>
            (XI_UpdateUserRPS account (UR_Global6))
            ;;5]Update Vault Supply
            (XI_UpdateVaultSupply wSTOA-supply false)
            (XI_ResetUrstoaEarned account)
            ;;6]#1C: stamp this account as collected for the current distribution-round
            (XI_MarkCollected account)
            ;;7]Return claimed amounts
            (if (!= urSTOA-supply 0.0)
                (format
                    "Account {} succesfully claimed {} {} and {} {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-supply urSTOA-id]
                )
                (format
                    "Account {} succesfully claimed {} {} and no {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-id]
                )
            )
        )
    )
    (defun XI_ResetPendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : 0.0}
        )
    )
    (defun XI_UpdateUnclaimedCount (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (uc:integer (UR_Global7))
                (new-uc:integer
                    (if direction
                        (+ uc 1)
                        (- uc 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"unclaimed-count" : new-uc}
            )
        )
    )
    ;;Admin
    (defun XI_InitialiseDistributionVault (dptf-ids:[string])
        (require-capability (SECURE))
        (insert STOAICO|T|General STOAICO|INFO
            {"dollarz"          : 0.0
            ,"urstoa-left"      : 250000
            ,"users"            : 0
            ,"wstoa-supply"     : 0.0
            ,"nzs-count"        : 0
            ,"current-rps"      : 0.0
            ,"unclaimed-count"  : 0
            ,"distribution-round" : 0
            ,"zombie-rewards"   : 0.0
            ,"wstoa"            : (at 0 dptf-ids)
            ,"wurstoa"          : (at 1 dptf-ids)
            ,"vusd"             : (at 2 dptf-ids)
            }
        )
    )
    ;;User
    (defun XI_UpdateUserScore (account:string amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score amount)
                        (- user-score amount)
                    )
                )
            )
            (update STOAICO|T|User account
                {"dollarz" : new-user-score}
            )
        )
    )
    (defun XI_UpdateUserRPS (account:string new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-rps" : new-rps}
        )
    )
    (defun XI_MarkCollected (account:string)
        @doc "#1C: stamp the account as having collected the CURRENT distribution-round."
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-collected-round" : (UR_Global11)}
        )
    )
    (defun XI_UpdatePendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : (URC_AvailableRewards account)}
        )
    )
    ;;D-Vault
    (defun XI_UpdateVaultScore (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score amount)
                        (- vault-score amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"dollarz" : new-vault-score}
            )
        )
    )
    (defun XI_UpdateVaultSupply (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-supply:decimal (UR_Global4))
                (new-vault-supply:decimal
                    (if direction
                        (+ vault-supply amount)
                        (- vault-supply amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"wstoa-supply" : new-vault-supply}
            )
        )
    )
    (defun XI_UpdateNZS (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (nzs:integer (UR_Global5))
                (new-nzs:integer
                    (if direction
                        (+ nzs 1)
                        (- nzs 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"nzs-count" : new-nzs}
            )
        )
    )
    (defun XI_UpdateVaultRPS (new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"current-rps" : new-rps}
        )
    )
    (defun XI_ResetUnclaimedCount ()
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"unclaimed-count" : (UR_Global5)}
        )
    )
    (defun XI_IncrementDistributionRound ()
        @doc "#1C: advance the vault to the next distribution-round (called by A_Inject)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"distribution-round" : (+ 1 (UR_Global11))}
        )
    )
    (defun XI_SetZombieRewards (amount:decimal)
        @doc "#5M: set the escrowed zombie-rewards (escrow adds to it; a flush zeroes it)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"zombie-rewards" : amount}
        )
    )
    ;;
    (defun XI_ResetUrstoaEarned (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"urstoa-earned"    : 0}
        )
    )
    (defun XI_UpdateUrstoaEarned (account:string v-usd-amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score v-usd-amount)
                        (- user-score v-usd-amount)
                    )
                )
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score v-usd-amount)
                        (- vault-score v-usd-amount)
                    )
                )
                (urstoa-left:integer (UR_Global2))
                (present-urstoa-earned:integer (UR_User2 account))
                (new-urstoa-earned:integer (floor (/ new-user-score 5.0)))
                (diff-urstoa:integer (- new-urstoa-earned present-urstoa-earned))
            )
            (if (= diff-urstoa 0)
                ;;do nothing
                true
                (let
                    (
                        (final-urstoa-earned:integer
                            (if (< urstoa-left diff-urstoa)
                                (+ present-urstoa-earned urstoa-left)
                                new-urstoa-earned
                            )


                        )
                        (final-urstoa-left:integer
                            (if (< urstoa-left diff-urstoa)
                                0
                                (- urstoa-left diff-urstoa)
                            )
                        )
                    )
                    (update STOAICO|T|User account
                        {"urstoa-earned"    : final-urstoa-earned}
                    )
                    (update STOAICO|T|General STOAICO|INFO
                        {"urstoa-left"      : final-urstoa-left}
                    )
                )
            )
        )
    )
    ;;{F7}  User [A]
    ;;
    (defun A_InitialiseDistributionVault (account:string)
        @doc "Initialises the Distribuition Vault by creating and filling all necesary prerequisites"
        (with-capability (INIT-ICO-DISTRIBUTION)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (ref-P|DPAD:module{OuronetPolicyV1} DEMIPAD)
                    (dptf-ids:list 
                        (ref-TS01-C1::C_DPTF|Issue account account
                            ["WrappedUrStoa" "VirtualIcoDollars"]
                            ["WURSTOA" "VUSDC"]
                            [3 2]
                            [true true]
                            [true true]
                            [true true]
                            [false false]
                            [false false]
                            [false false]
                        )
                    )
                    (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                    (wurstoa-id:string (at 0 dptf-ids))
                    (vusd-id:string (at 1 dptf-ids))
                )
                ;;1]Issue wURSTOA as DPTF
                ;;2]Issue vUSD as mockup virtual Dollarz
                ;;3]Toggle mint and burn roles
                (ref-TS01-C1::C_DPTF|ToggleMintRole account vusd-id DEMIPAD|SC_NAME true)
                (ref-TS01-C1::C_DPTF|ToggleBurnRole account vusd-id DEMIPAD|SC_NAME true)
                (ref-TS01-C1::C_DPTF|ToggleMintRole account wstoa-id account true)
                (ref-TS01-C1::C_DPTF|ToggleMintRole account wurstoa-id DEMIPAD|SC_NAME true)
                ;;4]Mint 10 mil wSTOA (injection will follow after ICO concludes)    
                (ref-TS01-C1::C_DPTF|Mint account wstoa-id account 10000000.0 true)
                ;;5]Initialises the distribution Vault
                (XI_InitialiseDistributionVault [wstoa-id wurstoa-id vusd-id])
                ;;6]Output Message
                [wurstoa-id vusd-id]
            )
        )
    )
    (defun A_Inject (patron:string account:string wstoa-amount:decimal)
        @doc "Injects the ICO wSTOA amount into the Distribution-Vault (D-Vault); \
            \ the 10 mil from the ICO sale, from <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|INJECT account)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (wSTOA-ID:string (UR_Global8))
                    ;;
                    (vault-score:decimal (UR_Global1))
                    (zombie:decimal (UR_Global12))
                )
                (if (> vault-score 0.0)
                    ;;=== FLUSH — stakers present: distribute (new amount + any escrowed zombie), open next round.
                    (let
                        (
                            (eff:decimal (+ wstoa-amount zombie))
                        )
                        ;;#1C] Inject barrier — a new distribution-round may open ONLY when the previous one is
                        ;;     fully collected (unclaimed-count == 0). Stragglers are cleared by the admin flush.
                        (enforce
                            (= (UR_Global7) 0)
                            "STOAICO: previous distribution-round not fully collected — flush the stragglers (or wait for collections) before injecting again")
                        ;;0]Move wSTOA from <account> to the D-Vault
                        (ref-TS01-C1::C_DPTF|Transfer patron wSTOA-ID account DEMIPAD|SC_NAME wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (total held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Advance <current-rps> by the EFFECTIVE amount (new + escrowed zombie) / vault-score.
                        ;;  vault-score > 0 here, so the reward-per-share division can never divide by zero.
                        (XI_UpdateVaultRPS (+ (UR_Global6) (floor (/ eff vault-score) STOA_PREC)))
                        ;;3]#5M: the escrowed zombie is fully consumed by this flush
                        (if (> zombie 0.0) (XI_SetZombieRewards 0.0) true)
                        ;;4]Reset <unclaimed-count> (set it to <nzs-count>)
                        (XI_ResetUnclaimedCount)
                        ;;5]#1C: advance the vault to the next distribution-round (opens collection for this round)
                        (XI_IncrementDistributionRound)
                    )
                    ;;=== ESCROW — #5M no stakers (vault-score 0): park the amount as zombie for the NEXT non-zero
                    ;;    inject (eff = amount + zombie). Nothing is distributed (no rps/round/unclaimed change),
                    ;;    so the division is never reached with a zero denominator.
                    (do
                        ;;0]Move wSTOA from <account> to the D-Vault (held, not yet distributed)
                        (ref-TS01-C1::C_DPTF|Transfer patron wSTOA-ID account DEMIPAD|SC_NAME wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Escrow: postpone distribution to the next injection when vault-score is non-zero
                        (XI_SetZombieRewards (+ zombie wstoa-amount))
                    )
                )
            )
        )
    )
    (defun A_Stake (patron:string account:string v-usd-amount:decimal)
        @doc "Adds a contribution in virtual $ to the Distribution Vault \
            \ Contributing with v-dollars allows for a piece of the 10 mil wSTOA \
            \ placed for distribution in this Vault.\
            \ Also earns urSTOA (up to 300k) \
            \ Can only be done by the Admin"
        (with-capability (STOAICO|ADD-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Mint the v-USD amount to the <DEMIPAD|SC_NAME>
                (ref-TS01-C1::C_DPTF|Mint patron v-usd-id DEMIPAD|SC_NAME v-usd-amount false)
                ;;0.1]If New Account
                (if (not (UR_IzAccount account))
                    (do
                        (insert STOAICO|T|User account
                            ;;#1C: new contributor starts at the CURRENT distribution-round, so a (mis-ordered)
                            ;;     post-inject stake is not eligible for the already-injected round.
                            (UDC_UserData 0.0 0 (UR_Global6) 0.0 (UR_Global11) account)
                        )
                        ;;Increment Users by one
                        (update STOAICO|T|General STOAICO|INFO
                            {"users" : (+ 1 (UR_Global3))}
                        )
                    )                
                    true
                )
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If initial <user-score> was 0, increment <nzs-count>
                (if (= user-score 0.0)
                    (XI_UpdateNZS true)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: Earn urSTOA ONLY during the ICO phase (distribution-round 0). After the ICO
                ;;    concludes (first inject → round >= 1) contributions no longer earn urSTOA; the unsold
                ;;    remainder of the 250k budget stays unminted (returns to the foundation).
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount true)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount true)
                (XI_UpdateUserScore account v-usd-amount true)
                (format "Succesfully contributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun A_Unstake (patron:string account:string v-usd-amount:decimal)
        @doc "Removes a contribution of virtual $ from the Distribution Vault for an <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|REMOVE-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV1} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (remaining:decimal (- user-score v-usd-amount))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Burn the v-USD amount from the <DEMIPAD|SC_NAME> that is to be removed
                (ref-TS01-C1::C_DPTF|Burn patron v-usd-id DEMIPAD|SC_NAME v-usd-amount)
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If remaining <user-score> becomes 0, decrement <nzs-count>
                (if (= remaining 0.0)
                    (XI_UpdateNZS false)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: adjust urSTOA earning ONLY during the ICO phase (distribution-round 0); after the
                ;;    ICO concludes, contributions/withdrawals no longer touch urSTOA earning.
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount false)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount false)
                (XI_UpdateUserScore account v-usd-amount false)
                (format "Succesfully uncontributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun Ap_FlushUncollectedSlice:string (patron:string accounts:[string])
        @doc "#1C Hydra parallel slice: the admin push-collects ONE slice of uncollected accounts, delivering \
            \ each its OWN wSTOA + urSTOA (identical to a self-collect — not to the admin, not burned). \
            \ Order-independent and retryable — an account already collected this round is skipped, so re-runs \
            \ are idempotent. Drives unclaimed-count toward 0 so the next A_Inject can open the following round."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (cur-round:integer (UR_Global11))
                )
                (map
                    (lambda (account:string)
                        (if (< (UR_User5 account) cur-round)
                            (XI_CollectFor patron account)
                            (format "Account {} already collected — skipped" [account])
                        )
                    )
                    accounts
                )
                (format "Flush slice processed {} account(s)" [(length accounts)])
            )
        )
    )
    (defun AA_FlushUncollected:string (patron:string)
        @doc "#1C solo/heavy admin flush: push-collect ALL uncollected stragglers in one transaction (reaches \
            \ the URH_UncollectedAccounts heavy scan — hence AA_). For large contributor sets prefer the \
            \ parallel URH_UncollectedAccounts preflight + Ap_FlushUncollectedSlice legs. Delivers each \
            \ straggler its own rewards and clears unclaimed-count so the next inject can proceed."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (accounts:[string] (URH_UncollectedAccounts))
                )
                (map (lambda (account:string) (XI_CollectFor patron account)) accounts)
                (format "Flushed {} uncollected account(s)" [(length accounts)])
            )
        )
    )
    ;;{F8}  User [C]
    (defun C_Collect (patron:string account:string)
        @doc "Self-collect from the distribution Vault — once per distribution-round, by the <account> owner. \
            \ A new A_Inject opens the next round and re-enables collection (the RPS delta since last collect)."
        (with-capability (STOAICO|REDEEM-CONTRIBUTION account)
            (XI_CollectFor patron account)
        )
    )
    ;;{F9}  REPL (test-only, stripped at mainnet) [REPL]
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table STOAICO|T|User)
(create-table STOAICO|T|General)