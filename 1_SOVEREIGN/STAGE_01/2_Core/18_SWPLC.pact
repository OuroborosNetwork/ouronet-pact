;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingUsageSecondaryV2
    @doc "Exposes Branding Functions for True-Fungible LP Tokens \
        \ <entity-pos>: 1 (Native LP), 2 (Freezing LP), 3 (Sleeping LP)"

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
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV2.OutputCumulator} (swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer))

)
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SwapperLiquidityClientV2
    @doc "Exposes the Client Functions of Swapper Liquidity"

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
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_EntityPosToID:string (swpair:string entity-pos:integer))
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV2.OutputCumulator} (swpair:string entity-pos:integer))
    (defun URCi_UpgradeBrandingLPs:decimal (months:integer))
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV2.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_Fuel:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool))
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string lp-amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_InputsForLP (swpair:string input-amounts:[decimal]))
    (defun UEV_AddFrozenLiquidity (swpair:string frozen-dptf:string))
    (defun UEV_AddSleepingLiquidity (account:string swpair:string sleeping-dpof:string nonce:integer))
    (defun UEV_AddDormantLiquidity (swpair:string))
    (defun UEV_AddChilledLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData}))
    (defun UEV_AddLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData}))
    (defun UEV_RemoveLiquidity (swpair:string lp-amount:decimal))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV2.OutputCumulator} (swpair:string toggle:bool))
    (defun C_Fuel:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool))
        ;;
    (defun C_STOA-PID|AddStandardLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_STOA-PID|AddIcedLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_STOA-PID|AddGlacialLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_STOA-PID|AddFrozenLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun C_STOA-PID|AddSleepingLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
        ;;
    (defun C_RemoveLiquidity:object{IgnisCollectorV2.OutputCumulator} (account:string swpair:string lp-amount:decimal))

)
;;
(module SWPLC GOV
    @doc "SWPLC (SwapperLiquidityClientV2 + BrandingUsageSecondaryV2) is the \
        \ liquidity-client module for SWP pools. It exposes C_ entrypoints to add liquidity \
        \ in several modes (standard, iced, glacial, frozen, sleeping) and remove liquidity, \
        \ plus fuel pools and update/upgrade LP-token branding, each with a matching URCi_ \
        \ cost-preview reader that composes IGNIS OutputCumulators. It wires LP-token \
        \ transfers, VST freeze/sleep, and complete-liquidity-addition-data fee handling, \
        \ with UEV_ validators gating each liquidity path."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsageSecondaryV2)
    (implements SwapperLiquidityClientV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPLC                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPLC_ADMIN)))
    (defcap GOV|SWPLC_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_SWPLC)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "SWPLC Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G5}  functions
    ;;
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPLC|CALLER ()
        true
    )
    (defcap P|SWPLC|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPLC|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|SWPLC|REMOTE-GOV))
        (compose-capability (P|SWPLC|CALLER))
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
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
        (with-capability (GOV|SWPLC_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|SWPLC_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (mg:guard (create-capability-guard (P|SWPLC|CALLER)))
            )
            (ref-P|VST::P|A_Add
                "SWPLC|RemoteSwpGov"
                (create-capability-guard (P|SWPLC|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "SWPLC|RemoteSwpGov"
                (create-capability-guard (P|SWPLC|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
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
    (defcap SWPLC|C>UPDATE-BRD (swpair:string)
        @event
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::CAP_Owner swpair)
            (compose-capability (P|SWPLC|CALLER))
        )
    )
    (defcap SWPLC|C>UPGRADE-BRD (swpair:string)
        @event
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::CAP_Owner swpair)
            (compose-capability (P|SWPLC|CALLER))
        )
    )
    ;;
    (defcap SWPLC|C>INDIRECT-FUEL
        (account:string swpair:string id-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (P|SWPLC|CALLER))
    )
    (defcap SWPLC|C>DIRECT-FUEL
        (account:string swpair:string id-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (P|DT))
    )
    ;;
    (defcap SWPLC|C>ADD-STANDARD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-ICED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-GLACIAL-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap SWPLC|C>ADD-FROZEN-LQ 
        (swpair:string frozen-dptf:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (UEV_AddFrozenLiquidity swpair frozen-dptf)
        (compose-capability (SWPLC|C-ADD-CHILLED-LQ swpair ld))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    (defcap SWPLC|C>ADD-SLEEPING-LQ 
        (account:string swpair:string sleeping-dpof:string nonce:integer ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (UEV_AddSleepingLiquidity account swpair sleeping-dpof nonce)
        (compose-capability (SWPLC|C-ADD-DORMANT-LQ swpair ld))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    (defcap SWPLC|C-ADD-DORMANT-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddDormantLiquidity swpair)
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C-ADD-CHILLED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddChilledLiquidity swpair ld)
        (compose-capability (SWPLC|C>X-ADD-LQ swpair ld))
    )
    (defcap SWPLC|C>X-ADD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (UEV_AddLiquidity swpair ld)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|SWPLC|REMOTE-GOV))
    )
    ;;
    (defcap SWPLC|C>REMOVE_LQ (swpair:string lp-amount:decimal)
        @event
        (UEV_RemoveLiquidity swpair lp-amount)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|SWPLC|REMOTE-GOV))
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
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_EntityPosToID:string (swpair:string entity-pos:integer)
        @doc "For the LP Branding Functions"
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|INT::UEV_PositionalVariable entity-pos 3 "Invalid entity position")
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                )
                (if (= entity-pos 1)
                    lp-id
                    (if (= entity-pos 2)
                        (ref-DPTF::UR_Frozen lp-id)
                        (ref-DPTF::UR_Sleeping lp-id)
                    )
                )
            )
        )
    )
    ;;
    ;;LP DPTF Branding
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV2.OutputCumulator}
        (swpair:string entity-pos:integer)
        @doc "Cost preview for C_UpdatePendingBrandingLPs: the fixed branding cumulator (2.0) \
            \ billed on the entity owner, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (entity-owner:string
                    (if (= entity-pos 3)
                        (ref-DPOF::UR_Konto entity-id)
                        (ref-DPTF::UR_Konto entity-id)
                    )
                )
            )
            (ref-IGNIS::UDC_BrandingCumulator entity-owner 2.0)
        )
    )
    (defun URCi_UpgradeBrandingLPs:decimal (months:integer)
        @doc "STOA cost single-source for C_UpgradeBrandingLPs — months x branding price. \
            \ Pure sibling of the impure XE_UpgradeBranding derivation the exec uses."
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;LQ Functions
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (swpair:string toggle:bool)
        @doc "Cost preview for C_ToggleAddLiquidity: delegates to SWP's add-or-swap toggle \
            \ cost (add-or-swap = true)."
        (let ((ref-SWP:module{SwapperV4} SWP))
            (ref-SWP::URCi_ToggleAddOrSwap swpair toggle true)
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool)
        @doc "Cost preview for C_Fuel: a direct fuel bills the multi-transfer of the non-zero \
            \ input tokens into the pool; an indirect fuel only updates supplies (EOC). The \
            \ XE_UpdateSupplies aggregate write carries no cumulator cost. Re-derived purely."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (has-zeros:bool (contains 0.0 input-amounts))
                (input-ids-for-transfer:[string]
                    (if has-zeros
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts)
                        pool-tokens
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if has-zeros
                        (ref-U|LST::UC_RemoveItem input-amounts 0.0)
                        input-amounts
                    )
                )
            )
            (if direct-or-indirect
                (ref-TFT::URCi_MultiTransferCumulator input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer)
                EOC
            )
        )
    )
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for C_STOA-PID|AddStandardLiquidity: the CLAD perfect-ignis-fee + the \
            \ SWP->account LP transfer. clad is a pure reader; the add-liquidity + autonomous- \
            \ swap-management writes are free."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (ld:object{SwapperLiquidityV2.LiquidityData} (ref-SWPL::URC_LD swpair input-amounts))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC_STOA-PID|CLAD account swpair ld true true stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                ]
                [native-lp]
            )
        )
    )
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for C_STOA-PID|AddIcedLiquidity: CLAD fee + native-LP transfer + \
            \ freeze of the secondary (iced) LP to the account."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (ld:object{SwapperLiquidityV2.LiquidityData} (ref-SWPL::URC_LD swpair input-amounts))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false true stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [native-lp frozen-lp]
            )
        )
    )
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for C_STOA-PID|AddGlacialLiquidity: CLAD fee + (conditional) native-LP \
            \ transfer + freeze of the secondary (glacial) LP."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (ld:object{SwapperLiquidityV2.LiquidityData} (ref-SWPL::URC_LD swpair input-amounts))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (if (!= native-lp 0.0)
                        (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                        EOC
                    )
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [native-lp frozen-lp]
            )
        )
    )
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "Cost preview for C_STOA-PID|AddFrozenLiquidity: move the frozen DPTF to VST + burn + \
            \ CLAD fee + re-freeze the resulting LP. Uses the frozen-token's underlying position."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount)))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld false false stoa-pid))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer frozen-dptf account vst-sc input-amount)
                    (ref-DPTF::URCi_Burn frozen-dptf vst-sc)
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [frozen-lp]
            )
        )
    )
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "Cost preview for C_STOA-PID|AddSleepingLiquidity: move the sleeping nonce to VST + \
            \ burn + IGNIS-tax transfer + CLAD fee + re-sleep the resulting LP over the remaining \
            \ lock. Uses the sleeping-token's underlying position."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount)))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld true true stoa-pid))
                (sleeping-lp:decimal (at "primary-lp" clad))
                ;;
                (release-date:time (at "release-date" (at 0 (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))))
                (dt:integer (floor (diff-time release-date (at "block-time" (chain-data)))))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_MoveCumulator sleeping-dpof [nonce] false)
                    (ref-DPOF::URCi_Burn sleeping-dpof)
                    (ref-TFT::URCi_Transfer ignis-id account vst-sc (at "total-ignis-tax-needed" clad))
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-VST::URCi_Sleep SWP|SC_NAME account lp-id sleeping-lp dt)
                ]
                [sleeping-lp]
            )
        )
    )
    ;;
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string lp-amount:decimal)
        @doc "Cost preview for C_RemoveLiquidity: the flat 10$ (1000 IGNIS) removal fee + the \
            \ account->SWP LP transfer + LP burn + SWP->account multi-transfer of the pool tokens \
            \ at current ratio. Output == pt-output-amounts (URC_LpBreakAmounts), purely derived \
            \ (the supply update + autonomous-swap-management writes carry no cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator 1000.0 SWP|SC_NAME trigger [])
                    (ref-TFT::URCi_Transfer lp-id account SWP|SC_NAME lp-amount)
                    (ref-DPTF::URCi_Burn lp-id SWP|SC_NAME)
                    (ref-TFT::URCi_MultiTransferCumulator pool-token-ids SWP|SC_NAME account pt-output-amounts)
                ]
                pt-output-amounts
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_InputsForLP (swpair:string input-amounts:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (l1:integer (length input-amounts))
                (l2:integer (length pool-tokens))
                (sum:decimal (fold (+) 0.0 input-amounts))
            )
            (enforce (= l1 l2) "Invalid input amounts")
            (enforce (>= sum 0.0) "Input amounts Sum must be greater than zero")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (amount:decimal (at idx input-amounts))
                            (pool-token:string (at idx pool-tokens))
                        )
                        (enforce (>= amount 0.0) "Amounts must be greater or equal to zero")
                        (if (> amount 0.0)
                            (ref-DPTF::UEV_Amount pool-token amount)
                            true
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    (defun UEV_AddFrozenLiquidity
        (swpair:string frozen-dptf:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-frozen-dptf-compatible:bool (contains dptf pool-tokens))
            )
            (enforce iz-frozen-dptf-compatible (format "Frozen-DPTF {} isnt't compatible with Swpair {}" [frozen-dptf swpair]))
        )
    )
    (defun UEV_AddSleepingLiquidity 
        (account:string swpair:string sleeping-dpof:string nonce:integer)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (iz-sleeping-dpof-compatible:bool (contains dptf pool-tokens))
            )
            (enforce iz-sleeping-dpof-compatible (format "sleeping-dpof {} isnt't compatible with Swpair {}" [sleeping-dpof swpair]))
            (ref-DPOF::UEV_NoncesToAccount sleeping-dpof account [nonce])
            (ref-VST::UEV_StillHasSleeping sleeping-dpof nonce)
        )
    )
    (defun UEV_AddDormantLiquidity (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (iz-sleeping:bool (ref-SWP::UR_IzSleepingLP swpair))
            )
            (enforce iz-sleeping (format "Sleeping LP Functionality is not enabled on Swpair {}" [swpair]))
        )
    )
    (defun UEV_AddChilledLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (iz-frozen:bool (ref-SWP::UR_IzFrozenLP swpair))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
            )
            (enforce iz-asymmetric "Chilled Liquidity can only be added when asymtric liquidity exists")
            (enforce iz-frozen (format "Frozen LP Functionality is not enabled on Swpair {}" [swpair]))
        )
    )
    (defun UEV_AddLiquidity (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (can-add:bool (ref-SWP::UR_CanAdd swpair))
                (read-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (iz-asymmetric:bool (at "iz-asymmetric" (at "sorted-lq-type" ld)))
                (iz-balanced:bool (at "iz-balanced" (at "sorted-lq-type" ld)))
                (iz-asymmetric-allowed:bool (ref-SWP::UR_Asymetric))
            )
            (if iz-asymmetric
                (enforce iz-asymmetric-allowed "Asymetric Liquidity Addition isn't enabled by an Ouronet Administrator")
                true
            )
            (if (= read-lp-supply 0.0)
                (enforce iz-balanced
                    "Liquidity Addition on an empty Pool must have a Balanced Part present!"
                )
                true
            )
            (enforce can-add (format "Adding|Removing Liquidity isn't enabled on pool {}" [swpair]))
        )
    )
    (defun UEV_RemoveLiquidity (swpair:string lp-amount:decimal)
        @doc "H11 fix: intentionally does NOT gate on <can-add>. <can-add> is a pool-owner switch meant \
            \ to pause new liquidity provisioning; it must never also block existing LPs from getting \
            \ their own principal back — an admin-controlled ability to freeze user funds already \
            \ deposited isn't a safety mechanism, it's a trust violation (owner's own framing, matching \
            \ how Curve's kill_me exempts plain remove_liquidity and Balancer's Recovery Mode is \
            \ deliberately permissionless while paused, 'so that funds can never be locked by governance \
            \ action'). Removal stays subject only to genuine validity checks below, never to the pool \
            \ owner's add-liquidity switch."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pool-lp-amount:decimal (ref-DPTF::UR_Supply lp-id))
            )
            (ref-DPTF::UEV_Amount lp-id lp-amount)
            (enforce (<= lp-amount pool-lp-amount) (format "{} is an invalid LP Amount for removing Liquidity" [lp-amount]))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV2.OutputCumulator}
        (swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (entity-owner:string
                    (if (= entity-pos 3)
                        (ref-DPOF::UR_Konto entity-id)
                        (ref-DPTF::UR_Konto entity-id)
                    )
                )
            )
            (with-capability (SWPLC|C>UPDATE-BRD swpair)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (ref-IGNIS::UDC_BrandingCumulator entity-owner 2.0)
            )
        )
    )
    (defun C_UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-SWP:module{SwapperV4} SWP)
                (owner:string (ref-SWP::UR_OwnerKonto swpair))
                (entity-id:string (URC_EntityPosToID swpair entity-pos))
                (stoa-payment:decimal
                    (with-capability (SWPLC|C>UPGRADE-BRD swpair)
                        (ref-BRD::XE_UpgradeBranding entity-id owner months)
                    )
                )
            )
            (ref-IGNIS::STOA|C_CollectWT patron stoa-payment false)
        )
    )
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (swpair:string toggle:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (with-capability (P|SWPLC|CALLER)
                (ref-SWP::C_ToggleAddOrSwap swpair toggle true)
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (has-zeros:bool (contains 0.0 input-amounts))
                (input-ids-for-transfer:[string]
                    (if has-zeros
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts)
                        pool-tokens
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if has-zeros
                        (ref-U|LST::UC_RemoveItem input-amounts 0.0)
                        input-amounts
                    )
                )
                (new-balances:[decimal] 
                    (zip (+) pt-current-amounts input-amounts)
                )
            )
            (if validation
                (UEV_InputsForLP swpair input-amounts)
                true
            )
            (if direct-or-indirect
                (with-capability (SWPLC|C>DIRECT-FUEL account swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    (ref-TFT::C_MultiTransfer input-ids-for-transfer account SWP|SC_NAME input-amounts-for-transfer true)
                )
                (with-capability (SWPLC|C>INDIRECT-FUEL account swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    EOC
                )
            )
        )
    )
    (defun C_STOA-PID|AddStandardLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-STANDARD-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-SWP:module{SwapperV4} SWP)
                        
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld true true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV2.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity account swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV2.OutputCumulator}
                                (ref-TFT::C_Transfer lp-id SWP|SC_NAME account native-lp-transfer-amount true)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [ico1 ico2] [native-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_STOA-PID|AddIcedLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-ICED-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV2.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity account swpair false true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV2.OutputCumulator}
                                (ref-TFT::C_Transfer lp-id SWP|SC_NAME account native-lp-transfer-amount true)
                            )
                            (ico3:object{IgnisCollectorV2.OutputCumulator}
                                (ref-VST::C_Freeze SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [
                            ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_STOA-PID|AddGlacialLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
            )
            (with-capability (SWPLC|C>ADD-GLACIAL-LQ swpair ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV2.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity account swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV2.OutputCumulator}
                                (if (!= native-lp-transfer-amount 0.0)
                                    (ref-TFT::C_Transfer lp-id SWP|SC_NAME account native-lp-transfer-amount true)
                                    EOC
                                )
                            )
                            (ico3:object{IgnisCollectorV2.OutputCumulator}
                                (ref-VST::C_Freeze SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_STOA-PID|AddFrozenLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        ;;
                        (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                        (ignis-id:string (ref-DALOS::UR_IgnisID))
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Move F|DPTF to vst-sc and burn it
                        (ico1:object{IgnisCollectorV2.OutputCumulator}
                            (ref-TFT::C_Transfer frozen-dptf account vst-sc input-amount true)
                        )
                        (ico2:object{IgnisCollectorV2.OutputCumulator}
                            (ref-DPTF::C_Burn frozen-dptf vst-sc input-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico3:object{IgnisCollectorV2.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity vst-sc swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico4:object{IgnisCollectorV2.OutputCumulator}
                                (ref-VST::C_Freeze SWP|SC_NAME account lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [ico1 ico2 ico3 ico4] [frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_STOA-PID|AddSleepingLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-SLEEPING-LQ account swpair sleeping-dpof nonce ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-VST:module{VestingV2} VST)
                        ;;
                        (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                        (ignis-id:string (ref-DALOS::UR_IgnisID))
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        (nonce-md:[object] (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))
                        (release-date:time (at "release-date" (at 0 nonce-md)))
                        (present-time:time (at "block-time" (chain-data)))
                        (dt:integer (floor (diff-time release-date present-time)))
                        ;;
                        ;;
                        ;;Move Z|DPMF to vst-sc and burn it
                        (ico1:object{IgnisCollectorV2.OutputCumulator}
                            (ref-DPOF::C_Transfer sleeping-dpof [nonce] account vst-sc true)
                        )
                        (ico2:object{IgnisCollectorV2.OutputCumulator}
                            (ref-DPOF::C_Burn sleeping-dpof vst-sc nonce batch-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld true true stoa-pid)
                        )
                        ;;
                        ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                        (ico3:object{IgnisCollectorV2.OutputCumulator}
                            (ref-TFT::C_Transfer ignis-id account vst-sc (at "total-ignis-tax-needed" clad) true)
                        )
                        ;;
                        (ico4:object{IgnisCollectorV2.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (sleeping-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity vst-sc swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico5:object{IgnisCollectorV2.OutputCumulator}
                                (ref-VST::C_Sleep SWP|SC_NAME account lp-id sleeping-lp-transfer-amount dt)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [ico1 ico2 ico3 ico4 ico5] [sleeping-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_RemoveLiquidity:object{IgnisCollectorV2.OutputCumulator}
        (account:string swpair:string lp-amount:decimal)
        @doc "Removes <swpair> Liquidity using <lp-amount> of LP Tokens \
            \ Always returns all Pool Tokens at current Pool Token Ratio"
        ;;
        (P|UEV_IMC)
        (with-capability (SWPLC|C>REMOVE_LQ swpair lp-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                    (pt-current-amounts:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                    (pt-new-amounts:[decimal] (zip (-) pt-current-amounts pt-output-amounts))
                    ;;
                    ;;Removing Liquidity requires a flat fee of 10$ in Ignis
                    ;;This deincentivizes frequent Liquidity removals
                    ;;
                    (flat-ignis-lq-rm-fee:decimal 1000.0)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-flat:object{IgnisCollectorV2.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-rm-fee SWP|SC_NAME trigger [])
                    )
                    ;;
                    (ico1:object{IgnisCollectorV2.OutputCumulator}
                        (ref-TFT::C_Transfer lp-id account SWP|SC_NAME lp-amount true)
                    )
                    (ico2:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPTF::C_Burn lp-id SWP|SC_NAME lp-amount)
                    )
                    (ico3:object{IgnisCollectorV2.OutputCumulator}
                        (ref-TFT::C_MultiTransfer pool-token-ids SWP|SC_NAME account pt-output-amounts true)
                    )
                )
                ;;Updates Pool Supplies
                (ref-SWP::XE_UpdateSupplies swpair pt-new-amounts)
                ;;Autonomous Swap Mangement
                (ref-SWPL::XE_AutonomousSwapManagement swpair)
                ;;Output Cumulator
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-flat ico1 ico2 ico3] pt-output-amounts)
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)