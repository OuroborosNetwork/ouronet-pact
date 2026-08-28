;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
(interface TalosStageOne_AdminV1
    @doc "Exposes Ouronet Administrative Functions"
    ;;
    ;;DALOS Functions
    (defun DALOS|A_MigrateLiquidFunds:decimal (migration-target-kda-account:string))
    (defun DALOS|A_ToggleOAPU (oapu:bool))
    (defun DALOS|A_ToggleGAP (gap:bool))
    (defun DALOS|A_DeploySmartAccount (account:string guard:guard kadena:string sovereign:string public:string))
    (defun DALOS|A_DeployStandardAccount (account:string guard:guard kadena:string public:string))
    (defun DALOS|A_IgnisToggle (native:bool toggle:bool))
    (defun DALOS|A_SetIgnisSourcePrice (price:decimal))
    (defun DALOS|A_SetAutoFueling (toggle:bool))
    (defun DALOS|A_UpdatePublicKey (account:string new-public:string))
    (defun DALOS|A_UpdateUsagePrice (action:string new-price:decimal))
    ;;
    ;;
    ;;BRD Functions
    (defun BRD|A_Live (entity-id:string))
    (defun BRD|A_SetFlag (entity-id:string flag:integer))
    ;;
    ;;
    ;;DPTF Functions
    (defun DPTF|A_UpdateTreasuryDispoParameters (type:integer tdp:decimal tds:decimal))
    (defun DPTF|A_WipeTreasuryDebt ())
    (defun DPTF|A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal))
    ;;
    ;;ATS Functions
    (defun ATS|A_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string]))
    (defun ATS|A_KickStart (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    ;;
    ;;LIQUID Functions
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-kda-account:string))
    ;;
    ;;
    ;;ORBR Functions
    (defun ORBR|A_Fuel ())
    ;;
    ;;
    ;;SWP Functions
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun SWP|A_RotatePrincipal (old:string new:string))
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool))
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string))
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool))
    ;;
    ;;
    ;;Fueling Functions
    (defun XB_DynamicFuelKDA ())
    (defun XE_ConditionalFuelKDA (condition:bool))
)
;;
(module TS01-A GOV
    @doc "TALOS Stage 1 Administrator Functions \
        \ Contains All Administrator functions [DALOS BRD ORBR SWP]\
        \ Also contains Fueling Functions needed in all subsequent TALOS Modules"
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageOne_AdminV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_TS01-A         (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|TS01-A_ADMIN)))
    (defcap GOV|TS01-A_ADMIN ()     (enforce-guard GOV|MD_TS01-A))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|TS ()
        @doc "Talos Summoner Capability"
        true
    )
    (defcap P|TRG ()
        @doc "Talos Remote Governor Capability"
        true
    )
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (GOV|TS01-A_ADMIN))
    )
    (defcap P|GOVERNING-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (P|TRG))
    )
    (defcap P|SECURE-SUMMONER ()
        (compose-capability (P|TS))
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
        (with-capability (GOV|TS01-A_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-A_ADMIN)
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
        @doc "Fix (audit finding #22L test-coverage sweep): ATS and ATSU were never \
            \ registered as permitted callers here (ATS was even bound - ref-P|ATS - \
            \ but never used), so any TS01-A admin function routing into either module \
            \ (e.g. ATS|A_RemoveSecondary, ATS|A_KickStart) always failed UEV_IMC's \
            \ whitelist check - unconditionally, regardless of caller/key. Never caught \
            \ because those functions had zero test coverage. Every other Talos module's \
            \ own P|A_Define already registers into both ATS and ATSU; this just matches \
            \ that existing pattern."
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|ATS:module{OuronetPolicyV1} ATS)
                (ref-P|ATSU:module{OuronetPolicyV1} ATSU)
                (ref-P|LIQUID:module{OuronetPolicyV1} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV1} SWP)
                (mg:guard (create-capability-guard (P|TS)))
            )
            (ref-P|DALOS::P|A_Add
                "TS01-A|RemoteDalosGov"
                (create-capability-guard (P|TRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
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
    ;;{2}
    ;;{3}
    (defun TALOS|Gassless ()        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|DALOS|SC_NAME)))
    (defconst GASLESS-PATRON        (TALOS|Gassless))
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
    ;;  [DALOS_Administrator]
    (defun DALOS|A_MigrateLiquidFunds:decimal (migration-target-kda-account:string)
        @doc "Migrates Ouronet Gas Station Funds, to another kda adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_MigrateLiquidFunds migration-target-kda-account)
                (format "Liquid Funds succesfuly migrated to {}" [migration-target-kda-account])
            )
        )
    )
    (defun DALOS|A_ToggleOAPU (oapu:bool)
        @doc "Toggles the Ouroboros Autonomous Price Update to <oapu>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_ToggleOAPU oapu)
                (if oapu
                    "Ouroboros Autonomous Price Update successfully turned ON"
                    "Ouroboros Autonomous Price Update successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_ToggleGAP (gap:bool)
        @doc "Toggles the Global administrative Pause, the GAP, to <toggle>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_ToggleGAP gap)
                (if gap
                    "Global Administrative Pause successfully turned ON"
                    "Global Administrative Pause successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_DeploySmartAccount (account:string guard:guard kadena:string sovereign:string public:string)
        @doc "Deploys a Smart Ouronet Account in Administrator Mode, without collection KDA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::A_DeploySmartAccount account guard kadena sovereign public)
                (format "Succesfuly deployed Smart Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_DeployStandardAccount (account:string guard:guard kadena:string public:string)
        @doc "Deploys a Standard Ouronet Account in Administrator Mode, without collection KDA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::A_DeployStandardAccount account guard kadena public)
                (format "Succesfuly deployed Standard Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_IgnisToggle (native:bool toggle:bool)
        @doc "Toggles Ouronet Gas Collection \
        \ <native> true is KDA Collection for Specific Usage Actions \
        \ <native> false is IGNIS Collection for Client Functions"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_ToggleGasCollection native toggle)
                (if native
                    (if toggle
                        "KDA Collection succesfully turned ON"
                        "KDA Collection succesfully turned OFF"
                    )
                    (if toggle
                        "IGNIS Collection succesfully turned ON"
                        "IGNIS Collection succesfully turned OFF"
                    )
                )
            )
        )
    )
    (defun DALOS|A_SetIgnisSourcePrice (price:decimal)
        @doc "Sets OUROBOROS Price in $. Used in Compresion and Sublimation"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_SetIgnisSourcePrice price)
                (format "Succesfuly set IGNIS price to {}" [price])
            )
        )
    )
    (defun DALOS|A_SetAutoFueling (toggle:bool)
        @doc "Sets Automatic fueling of Collected KDA for the Increase of the <KdaLiquindex>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_SetAutoFueling toggle)
                (if toggle
                    "LiquidStaking Autofueling successfully turned ON"
                    "LiquidStaking Autofueling successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_UpdatePublicKey (account:string new-public:string)
        @doc "Updates Public Key; To be used only as failsafe by the Admin"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::A_UpdatePublicKey account new-public)
                (format "Public Key for Account {} successfully updated!" [sa])
            )
        )
    )
    (defun DALOS|A_UpdateUsagePrice (action:string new-price:decimal)
        @doc "Updates specific Usage Price in KDA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                )
                (ref-DALOS::A_UpdateUsagePrice action new-price)
                (format "Price for Action {} successfully updated with {}" [action new-price])
            )
        )
    )
    ;;  [BRD_Administrator]
    (defun BRD|A_Live (entity-id:string)
        @doc "Sets <pending-branding> for an <entity-id> to <live-branding>, reseting <pending-branding> data \
            \ Resetting <pending-branding> data does not reset its last 3 keys \
            \ Can only be done by Branding Administrator"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV1} BRD)
                )
                (ref-BRD::A_Live entity-id)
            )
        )
    )
    (defun BRD|A_SetFlag (entity-id:string flag:integer)
        @doc "Forcibly (in administrator mode) sets a Branding Flag for <entity-id> \
            \ <0> Flag = Golden Flag        Premium Flag reserved for Demiourgos Entity IDs \
            \ <1> Flag = Blue Flag          Premium Flag for Entity IDs (non-Demiourgos); \
            \                               Premium Flags are paid live branded Entity-IDs that are not labeled as problematic \
            \                               Paid live branded Entity IDs can still be flaged Red by the Branding Administrator \
            \ <2> Flag = Green Flag         Standard Flag for Entity IDs (non-Demiourgos) that have their Branding set to Live \
            \ <3> Flag = Gray Flag          Default Flag for newly-issued Entity-IDs (non-Demiourgos) that dont have their Branding Live yet \
            \ <4> Flag = Red Flag           Problem Flag for Entity IDs, marking potential dangerous or scam Entity IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV1} BRD)
                )
                (ref-BRD::A_SetFlag entity-id flag)
            )
        )
    )
    ;;  [DPTF_Administrator]
    (defun DPTF|A_UpdateTreasuryDispoParameters (type:integer tdp:decimal tds:decimal)
        @doc "Updates Treasury Dispo Parameters, that dictate how much OURO Debt the Treasury can incurr \
            \ Type can only be 0 1 2 3 \
            \ Type 0 = No Treasury Dispo \
            \ Type 1 = Maximum Dispo equal to Total Supply \
            \ Type 2 = Promile Based Dispo; A <tdp> value of 320.0 means up to 32% of Total Supply can be overspent\
            \ Type 3 = Absolute Value Dispo in Thousands; A <tds> value of 250.0 means up to 250 Thousands can be overspent"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-DPTF::A_UpdateTreasury type tdp tds)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebt ()
        @doc "Wipes all Treasury Debt, increasing OURO supply by the Debt Amount, \
            \ and setting Treasury Dispo Parameters to neutral (no overspend capability)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebt)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal)
        @doc "Wipes all partialy the Treasury Debt, increasing OURO supply by the <debt-to-be-wiped> amount \
        \ Treasury Dispo Parameters are left as they are, this function simply wipe a part of the Treasury Debt through mint."
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebtPartial debt-to-be-wiped)
            )
        )
    )
    ;;  [ATS_Administrator]
    (defun ATS|A_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant, queries <accounts-with-ats-data> via <DPTF-DPOF-ATS|UR_FilterKeysForInfo>"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV1} ATSU)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-ATSU::A_RemoveSecondary remover ats reward-token accounts-with-ats-data)
                )
            )
        )
    )
    (defun ATS|A_KickStart (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative Variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance, with no upper bound on the resulting KickStart \
            \ index (still subject to the shared 0.1 floor) - for legitimate ratios \
            \ above the owner-facing ATS|C_KickStart's 100.0 ceiling."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV1} ATSU)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-ATSU::A_KickStart kickstarter ats rt-amounts rbt-request-amount)
                )
            )
        )
    )
    ;;  [LIQUID_Administrator]
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-kda-account:string)
        @doc "Migrates Kadena Liquid Staking KDA Funds, to another kda adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-LIQUID:module{StoaLiquidStakingV1} LIQUID)
                )
                (ref-LIQUID::A_MigrateLiquidFunds migration-target-kda-account)
            )
        )
    )
    ;;  [OUROBOROS_Administrator]
    (defun ORBR|A_Fuel ()
        @doc "Uses up all collected Native KDA on the Ouroboros Account, wraps it, and fuels the Kadena Liquid Index \
            \ Transaction fee must be paid for by the Ouronet Gas Station, so that all available balance may be used. \
            \ Is Part of all the Functions that collect native KDA as fee, \
            \ boosting the KDA Liquid Index, from 40% of the collected KDA \
            \ As Stand-Alone Function, can only be used by the Admin. \
            \ In normal condition, there is no need for using it on itself, as all collected KDA is automatically used up \
            \ by implementing this function at the end of those funtions that collect the KDA. \
            \ Dalos-Patron is the only gass"
        (with-capability (SECURE)
            (XI_DirectFuelKDA)
        )
    )
    ;;  [SWP_Administrator]
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
        \ least 2 would remain defined, and <principal> isn't a 'major' principal \
        \ — #65eL). A principal is a token that must exist once in every W or P \
        \ Swpiar, on the first position. Also, the S Pools, must have at least \
        \ one Token dtied directly to a principal Token. SWPT's storage is \
        \ principal-agnostic (#21H), so removal of a minor principal is safe — it \
        \ only affects future pool-issuance principal-anchoring validation, never \
        \ existing routing. A major principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice) can never be removed \
        \ this way; retiring one requires redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool). SWP|A_RotatePrincipal remains available as \
        \ an atomic, count-preserving alternative for minor principals — it never \
        \ touches the floor or cap, but is equally blocked from rotating a major \
        \ principal away."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_UpdatePrincipal principal add-or-remove)
            )
        )
    )
    (defun SWP|A_RotatePrincipal (old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one step, without \
        \ touching the 2-minimum floor or 7-maximum cap. Safe with respect to \
        \ SWPT's routing graph (#21H fix): SWPT's storage is principal-agnostic, \
        \ so this never orphans anything there — the only effect is on future \
        \ pool-issuance principal-anchoring validation. Rejects rotating a \
        \ principal into itself, rejects <new> already being a principal, and \
        \ rejects <old> being a 'major' principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice, #65eL) — majors are \
        \ fixed, retirable only by redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool)."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_RotatePrincipal old new)
            )
        )
    )
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool)
        @doc "Updates either the <spawn-limit> or <inactive-limit> for the SWP Module \
        \ The <spawn-limit> is the minimum number in KDA that a pool must be created with, in order to be opened for swap \
        \ The <inactive-limit> is the minimum number in KDA as total pool liquidity value, that trigger autonomic disable of the swap mechanism"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_UpdateLimit limit spawn)
            )
        )
    )
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool)
        @doc "Updates Liquid Boost switch. When set to true, every swap is set to pump the Index for Kadena Liquid Staking"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_UpdateLiquidBoost new-boost-variable)
            )
        )
    )
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_DefinePrimordialPool primordial-pool)
            )
        )
    )
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-SWP::A_ToggleAsymetricLiquidityAddition toggle)
            )
        )
    )
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;  [Fueling Functions]
    (defun XB_DynamicFuelKDA ()
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if (ref-DALOS::UR_AutoFuel)
                (with-capability (SECURE)
                    (XI_DirectFuelKDA)
                )
                true
            )
        )
    )
    ;;
    (defun XE_ConditionalFuelKDA (condition:bool)
        (UEV_IMC)
        (if condition
            (with-capability (SECURE)
                (XB_DynamicFuelKDA)
            )
            true
        )
    )
    ;;
    (defun XI_DirectFuelKDA ()
        (require-capability (SECURE))
        (let
            (
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
            )
            (with-capability (P|TS)
                (ref-ORBR::C_Fuel)
            )
        )
    )
    ;;
)

(create-table P|T)
(create-table P|MT)