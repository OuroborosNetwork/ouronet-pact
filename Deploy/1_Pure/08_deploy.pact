;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 8 of 24
;; This is STEP 8 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-7 must have run first, including the init steps between deploys.
;; 3 source file(s), 323,224 gas measured in the REPL gas model, 282,817 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact
;;
;; TOTAL: 4 interface(s), 3 module(s), 6 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact
;;      interface  BrandingUsageSecondaryV2
;;      interface  SwapperLiquidityClientV2
;;      module     SWPLC
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact
;;      interface  SwapperUsageV3
;;      module     SWPU
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact
;;      interface  SwapperMtxV4
;;      module     MTX-SWP
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/18_SWPLC.pact ===================
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
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBrandingLPs (patron:string executor:string swpair:string entity-pos:integer months:integer))

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
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator} (swpair:string entity-pos:integer))
    (defun URCi_UpgradeBrandingLPs:decimal (months:integer))
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] direct-or-indirect:bool))
    (defun URCi_AddStandardLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddIcedLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddGlacialLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddFrozenLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URCi_AddSleepingLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string lp-amount:decimal))
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
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string toggle:bool))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool))
        ;;
    (defun STOA-PID|C_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun STOA-PID|C_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun STOA-PID|C_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
        ;;
    (defun C_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string lp-amount:decimal))

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
        (with-capability (GOV|SWPLC_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPLC_ADMIN)
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
        (with-capability (GOV|SWPLC_ADMIN)
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
        (with-capability (GOV|SWPLC_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
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
            (ref-P|IGNIS::P|A_AddIMP mg)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun URCi_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string entity-pos:integer)
        @doc "Cost preview for C_UpdatePendingBrandingLPs: the fixed branding cumulator (2.0) \
            \ billed on the entity owner, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun URCi_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string toggle:bool)
        @doc "Cost preview for C_ToggleAddLiquidity: delegates to SWP's add-or-swap toggle \
            \ cost (add-or-swap = true)."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::URCi_ToggleAddOrSwap swpair toggle true)
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator}
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
    ;;  [URCi] — CLAD readers. SINGLE SOURCE (2026-09-14) for the five add-liquidity shapes.
    ;;  Adding liquidity takes TWO different things from the caller: gas, which travels through the
    ;;  OutputCumulator and lands in <ignis-need>, and an Asymmetric-Liquidity TAX, which is IGNIS
    ;;  moved as PRINCIPAL and never enters a cumulator at all. The CLAD computes both, plus the
    ;;  human wording for each tax leg. These readers exist so the INFO_ layer can DECLARE the tax
    ;;  half without rebuilding the CLAD from scratch -- rebuilding it means restating the two
    ;;  collection flags per variant, and a preview that guesses those flags describes a different
    ;;  operation than the one it prices. Each URCi_Add*Liquidity below now reads its own twin.
    (defun URCi_AddStandardLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddStandardLiquidity: asymmetric-collection ON, \
            \ gaseous-collection ON -- the one add shape that takes an IGNIS tax as PRINCIPAL."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) true true stoa-pid)
        )
    )
    (defun URCi_AddIcedLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddIcedLiquidity: asymmetric-collection OFF, \
            \ gaseous-collection ON. No asymmetric collection means no IGNIS in <mt-ids> at all."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) false true stoa-pid)
        )
    )
    (defun URCi_AddGlacialLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddGlacialLiquidity: asymmetric-collection OFF, \
            \ gaseous-collection OFF -- no IGNIS tax and no gaseous LP fee."
        (let
            (
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::URC_STOA-PID|CLAD account swpair
                (ref-SWPL::URC_LD swpair input-amounts) false false stoa-pid)
        )
    )
    (defun URCi_AddFrozenLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddFrozenLiquidity. The liquidity vector is built from \
            \ the UNDERLYING token's pool position, and the adder of record is the VST smart \
            \ account (it holds the position while the frozen wrapper is burnt), not <account>. \
            \ Both collection flags OFF."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
            )
            (ref-SWPL::URC_STOA-PID|CLAD (ref-DALOS::GOV|VST|SC_NAME) swpair
                (ref-SWPL::URC_LD swpair
                    (ref-U|SWP::UC_MakeLiquidityList swpair
                        (ref-SWP::URv_PoolTokenPosition swpair dptf) input-amount))
                false false stoa-pid)
        )
    )
    (defun URCi_AddSleepingLiquidityClad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "The CLAD behind STOA-PID|C_AddSleepingLiquidity. As the frozen twin, but the amount \
            \ is the whole nonce supply rather than a caller-chosen figure. Both collection \
            \ flags ON, so this shape DOES carry the IGNIS asymmetry tax."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
            )
            (ref-SWPL::URC_STOA-PID|CLAD (ref-DALOS::GOV|VST|SC_NAME) swpair
                (ref-SWPL::URC_LD swpair
                    (ref-U|SWP::UC_MakeLiquidityList swpair
                        (ref-SWP::URv_PoolTokenPosition swpair dptf)
                        (ref-DPOF::UR_NonceSupply sleeping-dpof nonce)))
                true true stoa-pid)
        )
    )
    (defun URCi_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddStandardLiquidity: the CLAD perfect-ignis-fee + the \
            \ SWP->account LP transfer. clad is a pure reader; the add-liquidity + autonomous- \
            \ swap-management writes are free."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddStandardLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddStandardLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                ]
                [native-lp]
            )
        )
    )
    (defun URCi_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddIcedLiquidity: CLAD fee + native-LP transfer + \
            \ freeze of the secondary (iced) LP to the account."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddIcedLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddIcedLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-TFT::URCi_Transfer lp-id SWP|SC_NAME account native-lp)
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [native-lp frozen-lp]
            )
        )
    )
    (defun URCi_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddGlacialLiquidity: CLAD fee + (conditional) native-LP \
            \ transfer + freeze of the secondary (glacial) LP."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddGlacialLiquidityClad account swpair input-amounts stoa-pid))
                (native-lp:decimal (at "primary-lp" clad))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddGlacialLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
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
    (defun URCi_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddFrozenLiquidity: move the frozen DPTF to VST + burn + \
            \ CLAD fee + re-freeze the resulting LP. Uses the frozen-token's underlying position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddFrozenLiquidityClad account swpair frozen-dptf input-amount stoa-pid))
                (frozen-lp:decimal (at "secondary-lp" clad))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddFrozenLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-TFT::URCi_Transfer frozen-dptf account vst-sc input-amount)
                    (ref-DPTF::URCi_Burn frozen-dptf vst-sc)
                    (at "perfect-ignis-fee" (at "clad-op" clad))
                    (ref-VST::URCi_Freeze SWP|SC_NAME account lp-id frozen-lp)
                ]
                [frozen-lp]
            )
        )
    )
    (defun URCi_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "Cost preview for STOA-PID|C_AddSleepingLiquidity: move the sleeping nonce to VST + \
            \ burn + IGNIS-tax transfer + CLAD fee + re-sleep the resulting LP over the remaining \
            \ lock. Uses the sleeping-token's underlying position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                    (URCi_AddSleepingLiquidityClad account swpair sleeping-dpof nonce stoa-pid))
                (sleeping-lp:decimal (at "primary-lp" clad))
                ;;
                (release-date:time (at "release-date" (at 0 (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))))
                (dt:integer (floor (diff-time release-date (at "block-time" (chain-data)))))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;LP churn deterrent (central IG|DETER lp-churn, owner 2026-09-05)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddSleepingLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
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
    (defun URCi_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string lp-amount:decimal)
        @doc "Cost preview for C_RemoveLiquidity: the flat 10$ (1000 IGNIS) removal fee + the \
            \ account->SWP LP transfer + LP burn + SWP->account multi-transfer of the pool tokens \
            \ at current ratio. Output == pt-output-amounts (URC_LpBreakAmounts), purely derived \
            \ (the supply update + autonomous-swap-management writes carry no cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                    ;;LP add/remove churn deterrent. PRICE-SOURCE FIX (2026-09-14, owner ruling
                    ;;"make them consistent"): preview and exec disagreed here -- the preview read
                    ;;UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn" (1029.0 = the 1000.0 central
                    ;;deterrent PLUS this op's own 29.0 component) while C_RemoveLiquidity's ico-flat
                    ;;read the BARE UC_IgnisDeter "lp-churn" (1000.0), so every removal was over-quoted
                    ;;by 29.0 raw IGNIS. The disagreement was SIDE-WIDE, not just preview-vs-exec: the
                    ;;five ADD ops bill UC_IgnisPrice on BOTH sides (:546 / :1029 and siblings), so an
                    ;;add paid deter+component while a remove paid deter alone and the 29.0 row sat in
                    ;;the price table billed by nothing. Resolved toward the ADD side and toward
                    ;;UC_IgnisPrice's own contract ("every URCi_* reader should bill through this"):
                    ;;BOTH sides of remove now read UC_IgnisPrice, and the exec at :1333 reads it too.
                    ;;Measured by modules/SWP.repl <<SWP-I25>>.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn")
                        SWP|SC_NAME trigger [])
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
            ;;PRODUCED-TRIAGED (_eagerlet --produced, 2026-09-16): <iz-frozen> comes from a hard
            ;;read, so for a swpair that does not exist the raw table error fires before this line.
            ;;Left as is, deliberately. This message makes a STATE claim about a pool that exists;
            ;;for a pool that does NOT exist, "Frozen LP Functionality is not enabled on Swpair X"
            ;;is a MISLEADING answer -- it implies the pair is real and merely unconfigured. The raw
            ;;"no value found" is the lesser evil, and defaulting the reader would manufacture
            ;;exactly the wrong-diagnosis problem RT-K-004 found in DPDC. Same disposition as
            ;;UEV_LockState / UEV_EliteState. The preview half was handled by RT-K-005.
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
    (defun C_UpdatePendingBrandingLPs:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is POOL \
            \ ownership, enforced by SWPLC|C>UPDATE-BRD -> SWP::CAP_Owner <swpair>, which \
            \ resolves the owner from the table rather than from a parameter -- HANDOFF 4g's \
            \ signature for \"authority proven, actor unrecorded\". <UEV_ExecutorIsOwnerKonto> \
            \ supplies the other half, binding the account the caller NAMED to that same owner. \
            \ The ownership enforce is KEPT, not replaced."
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::UEV_ExecutorIsOwnerKonto executor swpair)
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
    (defun C_UpgradeBrandingLPs (patron:string executor:string swpair:string entity-pos:integer months:integer)
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is POOL \
            \ ownership, enforced by SWPLC|C>UPGRADE-BRD -> SWP::CAP_Owner <swpair>, which \
            \ resolves the owner from the table rather than from a parameter -- HANDOFF 4g's \
            \ signature for \"authority proven, actor unrecorded\". <UEV_ExecutorIsOwnerKonto> \
            \ supplies the other half, binding the account the caller NAMED to that same owner. \
            \ The ownership enforce is KEPT, not replaced."
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::UEV_ExecutorIsOwnerKonto executor swpair)
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
            (ref-IGNIS::XB_CollectStoaWithTrigger patron stoa-payment false)
        )
    )
    (defun C_ToggleAddLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string toggle:bool)
        @doc "Executor: ENFORCED INDIRECTLY, downstream. Nothing in THIS module proves it -- P|SWPLC|CALLER is a \
            \ trivially-true policy marker. The proof is SWP::C_ToggleAddOrSwap, whose \
            \ UEV_ExecutorIsOwnerKonto binds <executor> to (UR_OwnerKonto swpair) and whose \
            \ SWP|C>ADD-OR-SWAP then enforces CAP_Owner on that same pool. Its own @doc calls \
            \ itself \"the ONLY place in this call chain that enforces pool ownership\", which \
            \ is exactly why the executor has to be threaded rather than re-derived here. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (with-capability (P|SWPLC|CALLER)
                ;;PROVISIONAL EXECUTOR SLOT CLEARED at this module's own turn (2026-09-22).
                ;;15_SWP's turn left (ref-SWP::UR_OwnerKonto swpair) here -- correct, because it
                ;;is the value SWP's binder derives, but RE-DERIVED rather than attributed. It is
                ;;now the caller's own <executor>, which is the whole difference: the pool owner
                ;;was always going to be what SWP checked, and what was missing was any record of
                ;;WHO asked. SWP::C_ToggleAddOrSwap's UEV_ExecutorIsOwnerKonto rejects the pair
                ;;if they disagree, so this cannot silently drift.
                (ref-SWP::C_ToggleAddOrSwap patron executor swpair toggle true)
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string input-amounts:[decimal] direct-or-indirect:bool validation:bool)
        @doc "Fuels <swpair> from <executor> without issuing LP, raising LP value. \
            \ \
            \ Executor: ENFORCED INDIRECTLY. Neither SWPLC|C>DIRECT-FUEL nor SWPLC|C>INDIRECT-FUEL \
            \ enforces anything -- both are @event caps over trivially-true policy markers. The \
            \ proof is TFT::C_MultiTransfer, which moves the fuel OUT of <executor> and whose own \
            \ @doc records the chain: DPTF|C>MULTI-TRANSFER -> XB_DebitTrueFungible -> DPTF|C>DEBIT \
            \ -> CAP_EnforceAccountOwnership, once per leg. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
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
                (with-capability (SWPLC|C>DIRECT-FUEL executor swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    ;;PROVISIONAL PATRON SLOT CLEARED at this module's own turn (2026-09-22,
                    ;;_patronslots.py). This read `C_MultiTransfer account account ...` -- the
                    ;;same account in BOTH the patron and executor slots, because the module had
                    ;;no patron parameter and the actor was the only account it knew. Arity was
                    ;;right, no swept callee read the slot, and no assertion could reach it;
                    ;;the registry is the only reason it was not lost.
                    (ref-TFT::C_MultiTransfer patron executor SWP|SC_NAME input-ids-for-transfer input-amounts-for-transfer true)
                )
                (with-capability (SWPLC|C>INDIRECT-FUEL executor swpair input-ids-for-transfer input-amounts-for-transfer)
                    (ref-SWP::XE_UpdateSupplies swpair new-balances)
                    EOC
                )
            )
        )
    )
    (defun STOA-PID|C_AddStandardLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Executor: ENFORCED INDIRECTLY. This module proves nothing about it -- SWPLC|C>ADD-*-LQ \
            \ and every capability it composes take only (swpair ld); the account never enters the \
            \ capability graph at all. The proof is two modules along: SWPL::XE_STOA-PID|AddLiquidity \
            \ -> XI_AddLiqSendAndMint (under SECURE) -> TFT::C_MultiTransfer, which moves the \
            \ pool tokens OUT of <executor> and whose own @doc records DPTF|C>MULTI-TRANSFER -> \
            \ XB_DebitTrueFungible -> DPTF|C>DEBIT -> CAP_EnforceAccountOwnership, once per leg. \
            \ Unconditional: that call is a statement in a let BODY, not inside a branch. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-SWP:module{SwapperV4} SWP)
                        
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD executor swpair ld true true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron executor swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer patron SWP|SC_NAME executor lp-id native-lp-transfer-amount true)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddStandardLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2] [native-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddIcedLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Executor: ENFORCED INDIRECTLY. This module proves nothing about it -- SWPLC|C>ADD-*-LQ \
            \ and every capability it composes take only (swpair ld); the account never enters the \
            \ capability graph at all. The proof is two modules along: SWPL::XE_STOA-PID|AddLiquidity \
            \ -> XI_AddLiqSendAndMint (under SECURE) -> TFT::C_MultiTransfer, which moves the \
            \ pool tokens OUT of <executor> and whose own @doc records DPTF|C>MULTI-TRANSFER -> \
            \ XB_DebitTrueFungible -> DPTF|C>DEBIT -> CAP_EnforceAccountOwnership, once per leg. \
            \ Unconditional: that call is a statement in a let BODY, not inside a branch. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD executor swpair ld false true stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron executor swpair false true stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer patron SWP|SC_NAME executor lp-id native-lp-transfer-amount true)
                            )
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME executor lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [
                            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddIcedLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddGlacialLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        @doc "Executor: ENFORCED INDIRECTLY. This module proves nothing about it -- SWPLC|C>ADD-*-LQ \
            \ and every capability it composes take only (swpair ld); the account never enters the \
            \ capability graph at all. The proof is two modules along: SWPL::XE_STOA-PID|AddLiquidity \
            \ -> XI_AddLiqSendAndMint (under SECURE) -> TFT::C_MultiTransfer, which moves the \
            \ pool tokens OUT of <executor> and whose own @doc records DPTF|C>MULTI-TRANSFER -> \
            \ XB_DebitTrueFungible -> DPTF|C>DEBIT -> CAP_EnforceAccountOwnership, once per leg. \
            \ Unconditional: that call is a statement in a let BODY, not inside a branch. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        (ref-SWP:module{SwapperV4} SWP)
                        ;;
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Compute Liquidity Addition Data
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD executor swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                            
                        )
                        (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron executor swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= native-lp-transfer-amount 0.0)
                                    (ref-TFT::C_Transfer patron SWP|SC_NAME executor lp-id native-lp-transfer-amount true)
                                    EOC
                                )
                            )
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME executor lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddGlacialLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3] [native-lp-transfer-amount frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddFrozenLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        @doc "Executor: ENFORCED INDIRECTLY, and by a NEARER route than its standard/iced/glacial \
            \ siblings. SWPLC|C>ADD-FROZEN-LQ takes (swpair frozen-dptf ld) -- no account -- but this \
            \ function's own body calls TFT::C_Transfer <patron> <executor> <vst-sc> to move the \
            \ frozen DPTF out of the executor before anything else happens, and that enforces \
            \ CAP_EnforceAccountOwnership on it via DPTF|C>X-TRANSFER. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        (ref-VST:module{VestingV2} VST)
                        ;;
                        (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                        (ignis-id:string (ref-DALOS::UR_IgnisID))
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        ;;
                        ;;Move F|DPTF to vst-sc and burn it
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron executor vst-sc frozen-dptf input-amount true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Burn patron vst-sc frozen-dptf input-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld false false stoa-pid)
                        )
                        ;;
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (frozen-lp-transfer-amount:decimal (at "secondary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair false false stoa-pid ld clad)
                    (let
                        (
                            (ico4:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME executor lp-id frozen-lp-transfer-amount)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddFrozenLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3 ico4] [frozen-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun STOA-PID|C_AddSleepingLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        @doc "Executor: ENFORCED INDIRECTLY, via DPOF rather than DPTF. SWPLC|C>ADD-SLEEPING-LQ is \
            \ the ONE capability in this module that receives the account, but what it runs on it \
            \ -- DPOF::UEV_NoncesToAccount -- is a POSSESSION check (the nonce belongs to that \
            \ account), not a signature check. Possession is not authority. The authority is \
            \ DPOF::C_Transfer <patron> <executor> <vst-sc>, in this body, moving the sleeping \
            \ DPOF out of the executor. Worth stating because the cap LOOKS like it authorises. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
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
                (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                (ld:object{SwapperLiquidityV2.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
            )
            (with-capability (SWPLC|C>ADD-SLEEPING-LQ executor swpair sleeping-dpof nonce ld)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                        ;;Move the sleeping DPOF (Z| prefix) to vst-sc and burn it
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer patron executor vst-sc sleeping-dpof [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn patron vst-sc sleeping-dpof nonce batch-amount)
                        )
                        ;;
                        ;;Compute CLAD
                        (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                            (ref-SWPL::URC_STOA-PID|CLAD vst-sc swpair ld true true stoa-pid)
                        )
                        ;;
                        ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron executor vst-sc ignis-id (at "total-ignis-tax-needed" clad) true)
                        )
                        ;;
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (at "perfect-ignis-fee" (at "clad-op" clad))
                        )
                        (sleeping-lp-transfer-amount:decimal (at "primary-lp" clad))
                    )
                    (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair true true stoa-pid ld clad)
                    (let
                        (
                            (ico5:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Sleep patron SWP|SC_NAME executor lp-id sleeping-lp-transfer-amount dt)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Output Cumulator
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                            [(ref-IGNIS::UDC_ConstructOutputCumulator
                ;;the STOA-PID variant is the same work as its plain sibling, and both
                ;;branches are the SAME Talos op (SWP|C_AddLiquidity), so it bills the
                ;;sibling component key rather than inventing a second entry
                (ref-IGNIS::UC_IgnisPrice "SWP|C_AddSleepingLiquidity" "lp-churn")
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []) ico1 ico2 ico3 ico4 ico5] [sleeping-lp-transfer-amount]
                        )
                    )
                )
            )
        )
    )
    (defun C_RemoveLiquidity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string lp-amount:decimal)
        @doc "Removes <swpair> Liquidity using <lp-amount> of LP Tokens \
            \ Always returns all Pool Tokens at current Pool Token Ratio \
            \ \
            \ Executor: ENFORCED INDIRECTLY. SWPLC|C>REMOVE_LQ never receives the account at \
            \ all -- its parameters are (swpair lp-amount) and UEV_RemoveLiquidity checks only \
            \ that the amount is valid and within supply. The proof is TFT::C_Transfer, which \
            \ moves the LP OUT of <executor> (DPTF|C>X-TRANSFER -> CAP_EnforceAccountOwnership, \
            \ unconditionally on every branch). The two later calls credit rather than debit the \
            \ executor and prove nothing about it. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        ;;
        (P|UEV_IMC)
        (with-capability (SWPLC|C>REMOVE_LQ swpair lp-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                    ;;LP add/remove churn deterrent — central IG|DETER lp-churn (owner 2026-09-05).
                    ;;2026-09-14: was the BARE UC_IgnisDeter, which made removal the one liquidity op
                    ;;that skipped its own component while its 29.0 row sat unbilled in the price
                    ;;table. Now UC_IgnisPrice, matching the five ADD ops. See URCi_RemoveLiquidity.
                    (flat-ignis-lq-rm-fee:decimal
                        (ref-IGNIS::UC_IgnisPrice "SWP|C_RemoveLiquidity" "lp-churn"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-flat:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-rm-fee SWP|SC_NAME trigger [])
                    )
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron executor SWP|SC_NAME lp-id lp-amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn patron SWP|SC_NAME lp-id lp-amount)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_MultiTransfer patron SWP|SC_NAME executor pool-token-ids pt-output-amounts true)
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

;; --- tables for 18_SWPLC.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/19_SWPU.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface SwapperUsageV3
    @doc "Exposes Adding|Removing Liquidty and Swapping Functions of the SWP Module \
    \    V2: Added the already existing <UDC_SpawnSlippageBounds> to the interface \
    \    V2: Smart Swap slippage quote using fee-less multi-hop path tracing via <UDC_SpawnSmartSwapSlippageBounds> \
    \    V2: Smart Swap Multi-hop swap across the entire pool base using BFS path tracing with per-hop liquid pump via <CC_SmartSwap> \
    \    (#34 Phase 8: renamed from <C_SmartSwap> — self-searching variant; <C_SmartSwap> is reserved for the bundle-based, dirty-read-injected path)"

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema Slippage
        expected-output-amount:decimal
        output-precision:integer
        slippage-percent:decimal
    )
    ;;#34 Phase 6 — dirty-read path-injection bundle schemas. Not used by any function on
    ;;this interface yet (that's Phase 8) — declared now so Phase 7/8 build against a
    ;;settled shape instead of improvising one mid-implementation.
    (defschema SwapRoute
        @doc "The swap's own A->B route (nodes incl. both endpoints, edges one shorter). \
            \ Deliberately NOT the same shape as <CachedPathOrMiss> below — no <is-new> \
            \ concept, because eligibility for caching is decided independently by the \
            \ writer (XI_RegisterBundlePaths), not signaled by the caller here. \
            \ #34 Phase 6 (original doc, now superseded): this was 'never cached... \
            \ amount-sensitive, must be freshly discovered every time' — true UNDER \
            \ best-of-3 (a real value-comparing search legitimately can prefer a \
            \ different structural route for a different trade size). \
            \ #65bL Phase 5+ (current): the live on-chain default dropped best-of-3 to \
            \ first-found-only, which is PURE topology (SWPT::URC_ComputeGraphPath takes \
            \ no amount parameter) — the structural route is now provably \
            \ amount-independent, so XI_RegisterBundlePaths DOES now cache <swap-route> \
            \ into SWPT|PathCache, the same as <boost-path>/<stoa-paths>. Carries no \
            \ value/output data either way — the real transaction always computes actual \
            \ hop outputs fresh from live reserves, exactly as it does today; \
            \ off-chain-estimated outputs are only ever used to pick the best candidate \
            \ route before submission, never trusted for real execution numbers."
        nodes:[string]
        edges:[string]
    )
    (defschema CachedPathOrMiss
        @doc "An amount-agnostic X->target path (P3.0) — reused for two DIFFERENT cacheable \
            \ pricing targets, NOT the same token (caught 2026-08-21, before Phase 8 built \
            \ against this, while tracing URC_PoolValue's real implementation): \
            \ <boost-path> targets SSTOA (DALOS::UR_SilverStoaID — matches XI_RawLiquidPump's \
            \ existing URC_HopperActiveShortest id->sstoa call); each <stoa-paths> entry \
            \ targets WSTOA (DALOS::UR_WrappedStoaID — matches URC_PoolValue's own \
            \ URC_WorthWSTOA first-token->wstoa call, per its own \"Outputs the Pool Value in \
            \ WSTOA\" doc). Same schema shape, different destination token per field — callers \
            \ must supply/validate the correct one for each. <nodes>=[BAR] is the sentinel \
            \ for 'genuinely no path exists anywhere' (handled gracefully, not a crash — \
            \ this is also what finally closes the long-standing XI_RawLiquidPump crash \
            \ bug, Phase 8). <is-new>=true means this was freshly traced off-chain and \
            \ should be registered after use; false means it came from the shared cache \
            \ already. <is-new> is a hint only — the write path (Phase 7) must \
            \ independently verify before writing, never trust this flag as the write \
            \ authority (owner's final-check catch, 2026-08-21)."
        nodes:[string]
        edges:[string]
        is-new:bool
    )
    (defschema TokenPathPair
        @doc "One deduped entry in a bundle's <stoa-paths> list — one per DISTINCT first \
            \ token among all pools a swap actually touches, not one per pool (#34 Phase \
            \ 5 found today's per-pool loop redundantly re-traces identical paths when \
            \ pools share a first token). <path> targets WSTOA, matching URC_PoolValue's \
            \ own URC_WorthWSTOA target — NOT SSTOA (see CachedPathOrMiss's doc)."
        first-token:string
        path:object{CachedPathOrMiss}
    )
    (defschema SmartSwapPathBundle
        @doc "The full dirty-read-discovered input to the bundle-based SmartSwap entrypoint \
            \ (Phase 8, C_ prefix) — replaces all internal on-chain searching. Assembled \
            \ entirely client-side per P3.7's orchestration sequence. <boost-path> targets \
            \ SSTOA, <stoa-paths> entries target WSTOA — different destination tokens, see \
            \ CachedPathOrMiss's doc."
        swap-route:object{SwapRoute}
        boost-path:object{CachedPathOrMiss}
        stoa-paths:[object{TokenPathPair}]
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
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_SpawnSmartSwapSlippageBounds:object{Slippage} (input-id:string input-amount:decimal output-id:string slippage:decimal))
    (defun UDC_SpawnSlippageBounds:object{Slippage} (swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal))
    (defun UDC_Slippage:object{Slippage} (a:decimal b:integer c:decimal))
    (defun UDC_SlippageObject:object{Slippage} (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage-value:decimal))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC_SlippageMinMax:[decimal] (input:object{Slippage}))
    (defun UC_FindStoaPath:object{CachedPathOrMiss} (stoa-paths:[object{TokenPathPair}] first-token:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;#34 Phase 7: dedup + lookup helpers for the bundle's <stoa-paths>, built ahead of
    ;;Phase 8's actual wiring so that phase builds against a settled, tested shape.
    (defun URC_DedupFirstTokens:[string] (distinct-edges:[string]))
    (defun URCi_ToggleSwapCapability:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_SmartSwap:object{IgnisCollectorV3.OutputCumulator} (account:string input-id:string input-amount:decimal output-id:string slippage:decimal slippage-bounds:object{Slippage}))
    (defun URCi_SmartSwapWithBundle:object{IgnisCollectorV3.OutputCumulator} (account:string input-id:string input-amount:decimal output-id:string slippage:decimal slippage-bounds:object{Slippage} bundle:object{SmartSwapPathBundle}))
    (defun URCi_Swap:object{IgnisCollectorV3.OutputCumulator} (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal slippage-bounds:object{Slippage}))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_ToggleSwapCapability:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string toggle:bool))
    (defun CC_SmartSwap:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string input-id:string input-amount:decimal output-id:string slippage:decimal stoa-pid:decimal slippage-bounds:object{Slippage}))
    ;;#34 Phase 8: the bundle-based, dirty-read-injected SmartSwap — performs zero
    ;;internal searching (route, boost-path and stoa-paths are all supplied by the
    ;;caller, per SmartSwapPathBundle), built alongside CC_SmartSwap for direct gas
    ;;comparison, not replacing it.
    (defun C_SmartSwap:list
        (patron:string 
            executor:string input-id:string input-amount:decimal output-id:string slippage:decimal
            stoa-pid:decimal slippage-bounds:object{Slippage} bundle:object{SmartSwapPathBundle}
        )
    )
    (defun C_Swap:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal stoa-pid:decimal slippage-bounds:object{Slippage}))

)
;;
(module SWPU GOV
    @doc "SWPU (SwapperUsageV3) is the user-facing swapping module for SWP. It provides \
        \ single/multi-token swaps and SmartSwap (multi-hop) — both a self-searching path \
        \ (CC_SmartSwap, via Hopper/BFS) and a dirty-read bundle-injected path (C_SmartSwap \
        \ using a client-supplied path bundle to avoid on-chain graph search) — plus \
        \ slippage-bound construction and swap-capability toggling. It handles per-hop fee \
        \ splitting, special-fee-target flushing, and liquid-boost pumps, with STOA-value \
        \ repricing of touched pools."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperUsageV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPU                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPU_ADMIN)))
    (defcap GOV|SWPU_ADMIN ()                           (enforce-guard GOV|MD_SWPU))
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
    (defcap P|SWPU|CALLER ()
        true
    )
    (defcap P|SWPU|REMOTE-GOV ()
        true
    )
    (defcap P|DT ()
        (compose-capability (P|SWPU|REMOTE-GOV))
        (compose-capability (P|SWPU|CALLER))
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
                (mp:[guard] (P|UR_IMP))
                (g:guard (ref-U|G::UEV_GuardOfAny mp))
            )
            (enforce-guard g)
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SWPU_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPU_ADMIN)
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
        (with-capability (GOV|SWPU_ADMIN)
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
        (with-capability (GOV|SWPU_ADMIN)
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
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|SWPU|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "SWPU|RemoteDalosGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|VST::P|A_Add
                "SWPU|RemoteSwpGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "SWPU|RemoteSwpGov"
                (create-capability-guard (P|SWPU|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;#34 Phase 8: sentinel CachedPathOrMiss meaning "no bundle-supplied boost-path was
    ;;given, search for one internally" — passed by the self-searching CC_SmartSwap path
    ;;down through XI_SmartSwapCore/XI_LiquidIndexPump/XI_RawLiquidPump, which fall back
    ;;to their original SWPI::URC_HopperActiveShortest search whenever they see this
    ;;exact sentinel. Reuses the SAME [BAR] representation URC_ReadPathCache already uses
    ;;for "no cached path exists" — semantically the same case ("I have nothing for you,
    ;;compute it yourself"), not overloading the meaning.
    (defconst NO_PATH                                   {"nodes" : [BAR], "edges" : [], "is-new" : false})
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap SWPU|S>LIQUID-BOOST (id:string total-amount:decimal idx-increment:decimal)
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SWPU|S>FEED-SPECIAL-TARGETS 
        (id:string total-amount:decimal targets:[string] target-proportions:[decimal] target-amounts:[decimal])
        @event
        (compose-capability (P|SWPU|REMOTE-GOV))
    )
    (defcap SPWU|C>TOGGLE-SWAP (swpair:string toggle:bool)
        (if toggle
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (pool-worth:decimal (at 0 (ref-SWPI::URC_PoolValue swpair)))
                    (inactive-limit:decimal (ref-SWP::UR_InactiveLimit))
                )
                (enforce
                    (> pool-worth inactive-limit)
                    (format "Pool {} cannot have its Swap Functionality turned on because its worth is {} WSTOA, and a {} WSTOA Value is required for swap" [swpair pool-worth inactive-limit])
                )
            )
            true
        )
        (compose-capability (P|SWPU|CALLER))
    )
    (defcap SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @event
        ;;RT-H-002: the slippage DOMAIN, checked where the value is USED rather than only in
        ;;the UI-side constructor. Validation belongs in the defcap (CLAUDE.md), and these four
        ;;took `slippage` as a parameter while validating nothing about it.
        (UEV_Slippage slippage)
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @event
        ;;RT-H-002: the slippage DOMAIN, checked where the value is USED rather than only in
        ;;the UI-side constructor. Validation belongs in the defcap (CLAUDE.md), and these four
        ;;took `slippage` as a parameter while validating nothing about it.
        (UEV_Slippage slippage)
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>SINGL-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @event
        ;;RT-H-002: the slippage DOMAIN, checked where the value is USED rather than only in
        ;;the UI-side constructor. Validation belongs in the defcap (CLAUDE.md), and these four
        ;;took `slippage` as a parameter while validating nothing about it.
        (UEV_Slippage slippage)
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>SINGL-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>MULTI-SWAP-WITH-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @event
        ;;RT-H-002: the slippage DOMAIN, checked where the value is USED rather than only in
        ;;the UI-side constructor. Validation belongs in the defcap (CLAUDE.md), and these four
        ;;took `slippage` as a parameter while validating nothing about it.
        (UEV_Slippage slippage)
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|C>MULTI-SWAP-NO-SLIPPAGE
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage:decimal)
        @event
        (compose-capability (SWPU|X>SWAP swpair dsid))
    )
    (defcap SWPU|X>SWAP (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (l1:integer (length input-ids))
                (l2:integer (length input-amounts))
                (can-swap:bool (ref-SWP::UR_CanSwap swpair))
                (izo:bool (ref-U|SWP::UC_IzOnPool output-id swpair))
            )
            (enforce izo (format "{} is not part of SwapPool {}" [output-id swpair]))
            (enforce can-swap (format "Pool {} swap functionality is inactive: cannot Swap Tokens" [swpair]))
            (enforce (= l1 l2) "Invalid input Values")
            ;;SET-LEVEL GUARDS (2026-09-14). Every check around these is a per-ITEM property --
            ;;"this id is on the pool", "this amount is valid" -- and a malformed SET satisfies
            ;;all of them. Two such sets existed, and both were refused only INCIDENTALLY:
            ;;  1] output-id also present in input-ids (swapping a token for itself) reached the
            ;;     curve, which returned exactly 0.0 because adding and removing the same token
            ;;     on a constant-function curve nets to nothing, and was then refused three
            ;;     modules away by DPTF::UEV_Amount's zero-amount rule.
            ;;  2] the same id twice in input-ids was refused by "Only a single Input can be used
            ;;     in Stable Swap" -- a POOL-TYPE rule, which says nothing on a weighted or
            ;;     standard pool where several inputs are legitimate.
            ;;Neither is a statement about the set, so neither would survive a change to the
            ;;curve or a new pool type. Owner ruling 2026-09-14: state the rule directly.
            ;;Measured, exploit-first, at RedTeam/[RT-H]_InputDomain.repl <<RT-H-001>>.
            (enforce
                (not (contains output-id input-ids))
                (format "Output Token {} cannot also be an Input Token on SwapPool {}"
                    [output-id swpair])
            )
            (ref-U|LST::UEV_IzUnique input-ids)
            (map
                (lambda
                    (idx:integer)
                    (let*
                        (
                            (id:string (at idx input-ids))
                            (amount:decimal (at idx input-amounts))
                            (iop:bool (ref-U|SWP::UC_IzOnPool id swpair))
                        )
                        (enforce iop (format "Input Token id {} is not part of Liquidity Pool {}" [id swpair]))
                        (ref-DPTF::UEV_Amount id amount)
                    )
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
    )
    (defcap SWPU|C>SMART-SWAP-WITH-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            slippage-bounds:object{SwapperUsageV3.Slippage} h-obj:object{SwapperIssueV4.Hopper}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP account input-id input-amount output-id h-obj))
    )
    (defcap SWPU|C>SMART-SWAP-NO-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            h-obj:object{SwapperIssueV4.Hopper}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP account input-id input-amount output-id h-obj))
    )
    (defcap SWPU|X>SMART-SWAP
        (account:string input-id:string input-amount:decimal output-id:string h-obj:object{SwapperIssueV4.Hopper})
        @doc "#65L fix: <h-obj> (the BFS path search) is now computed exactly ONCE by the \
            \ caller (CC_SmartSwap) and passed in here, instead of this defcap \
            \ independently re-running SWPI::URC_HopperActive's full-graph search and \
            \ XI_SmartSwapRouter running the same search again right after — a genuine \
            \ double-heavy-read, against the rule that a defcap must never repeat a heavy \
            \ read the function body also performs. Mirrors \
            \ SWPU|X>SMART-SWAP-EXPLICIT-ROUTE's own pattern of validating an \
            \ already-known route instead of searching twice."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (all-pool-tokens:[string] (ref-SWP::URC_AllPoolTokens))
                (edges:[string] (at "edges" h-obj))
            )
            (enforce (!= input-id output-id) "Input and Output tokens must differ")
            (enforce (contains input-id all-pool-tokens) (format "Input token {} does not exist in any Swap Pool" [input-id]))
            (enforce (contains output-id all-pool-tokens) (format "Output token {} does not exist in any Swap Pool" [output-id]))
            (enforce (!= (length edges) 0) (format "No path found between {} and {}" [input-id output-id]))
            (ref-DPTF::UEV_Amount input-id input-amount)
            (map
                (lambda
                    (edge:string)
                    (let
                        (
                            (can-swap:bool (ref-SWP::UR_CanSwap edge))
                        )
                        (enforce can-swap (format "Pool {} along the Smart Swap path has swap functionality inactive" [edge]))
                    )
                )
                edges
            )
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
    )
    ;;#34 Phase 8: bundle-based SmartSwap caps — mirror SWPU|C>SMART-SWAP-WITH/NO-SLIPPAGE
    ;;+ SWPU|X>SMART-SWAP exactly, except validation runs against the bundle's own
    ;;swap-route instead of a fresh SWPI::URC_HopperActive search. This is the actual
    ;;gas win this whole redesign exists for: no full-graph BFS at the defcap layer.
    (defcap SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            slippage-bounds:object{SwapperUsageV3.Slippage} bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE account input-id input-amount output-id bundle))
    )
    (defcap SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE
        (
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @event
        (compose-capability (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE account input-id input-amount output-id bundle))
    )
    (defcap SWPU|X>SMART-SWAP-EXPLICIT-ROUTE
        (account:string input-id:string input-amount:decimal output-id:string bundle:object{SwapperUsageV3.SmartSwapPathBundle})
        @doc "All authorization/validation for the bundle-based path lives here, per this \
            \ codebase's client-defcap convention — XI_SmartSwapExplicitRoute below does \
            \ writes only, no enforce. Validates the SUPPLIED swap-route (structural \
            \ connectivity + active-required + depth-cap, all in ONE cheap \
            \ SWPI::URC_ValidatePathActive call — no full-graph search), and that it \
            \ actually starts/ends at <input-id>/<output-id> — a structurally-valid but \
            \ wrong-pair route must never be silently accepted."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (nodes:[string] (at "nodes" (at "swap-route" bundle)))
                (edges:[string] (at "edges" (at "swap-route" bundle)))
                (le:integer (length nodes))
            )
            (enforce (!= input-id output-id) "Input and Output tokens must differ")
            (enforce (!= le 0) (format "No path supplied between {} and {}" [input-id output-id]))
            (enforce (= (at 0 nodes) input-id) "swap-route in bundle does not start at input-id")
            (enforce (= (at (- le 1) nodes) output-id) "swap-route in bundle does not end at output-id")
            (enforce (ref-SWPI::URC_ValidatePathActive nodes edges) "swap-route in bundle is not a valid, fully active path")
            (ref-DPTF::UEV_Amount input-id input-amount)
            (compose-capability (P|DT))
            (compose-capability (SECURE))
        )
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    (defun UDC_SpawnSmartSwapSlippageBounds:object{SwapperUsageV3.Slippage}
        (
            input-id:string 
            input-amount:decimal 
            output-id:string 
            slippage:decimal
        )
        @doc "Creates a Slippage object for Smart Swap, using fee-less multi-hop output via URC_Hopper. \
            \ Called by the UI to generate the slippage-bounds object before submitting the Smart Swap transaction."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (h-obj:object{SwapperIssueV4.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
                (ovs:[decimal] (at "output-values" h-obj))
                (expected:decimal (at 0 (take -1 ovs)))
                (o-prec:integer (ref-DPTF::UR_Decimals output-id))
            )
            (enforce
                (= (floor slippage 2) slippage)
                (format "{} is not slippage conform decimal wise (max 2 decimals allowed)" [slippage])
            )
            (enforce
                (or
                    (= slippage -1.0)
                    (and
                        (> slippage 0.0)
                        (<= slippage 50.0)
                    )
                )
                "Slippage must be greater than 0.0 and maximum 50.0, or -1.0 for no slippage"
            )
            (UDC_Slippage expected o-prec slippage)
        )
    )
    (defun UDC_SpawnSlippageBounds:object{SwapperUsageV3.Slippage}
        (
            swpair:string 
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
            slippage:decimal
        )
        @doc "Creates the <slippage-bounds:object{SwapperUsageV3.Slippage}> \
            \ that needs to be passed to the Slippage Swap Functions,\
            \ using data from the UI"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
            )
            (UDC_SlippageObject swpair dsid slippage)
        )
    )
    (defun UDC_Slippage:object{SwapperUsageV3.Slippage}
        (a:decimal b:integer c:decimal)
        {"expected-output-amount"   : a
        ,"output-precision"         : b
        ,"slippage-percent"         : c}
    )
    (defun UDC_SlippageObject:object{SwapperUsageV3.Slippage}
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} slippage-value:decimal)
        @doc "Makes a Slippage Object from <input amounts>"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (o-prec:integer (ref-DPTF::UR_Decimals (at "output-id" dsid)))
                (expected:decimal (ref-SWPI::URCv_Swap swpair dsid false))
            )
            (enforce
                (= (floor slippage-value 2) slippage-value)
                (format "{} is not slippage conform decimal wise (max 2 decimals allowed)" [slippage-value])
            )
            (enforce
                (or
                    (= slippage-value -1.0)
                    (and
                        (> slippage-value 0.0)
                        (<= slippage-value 50.0)
                    )
                )
                
                "Slippage must be greater than 0.0 and maximum 50.0, or -1.0 for no slippage"
            )
            (UDC_Slippage expected o-prec slippage-value)
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_SlippageMinMax:[decimal] (input:object{SwapperUsageV3.Slippage})
        (let
            (
                (expected:decimal (at "expected-output-amount" input))
                (o-prec:integer (at "output-precision" input))
                (sp:decimal (at "slippage-percent" input))
                (slippage:decimal (floor (/ sp 100.0) 4))
                (plus-minus-value:decimal (floor (* slippage expected) o-prec))
                (min:decimal (- expected plus-minus-value))
                (max:decimal (+ expected plus-minus-value))
            )
            [min max]
        )
    )
    (defun UC_FilterSelfFromTargets:list (account:string targets:[string] amounts:[decimal])
        @doc "If <account> is in <targets>, removes it and returns [filtered-targets filtered-amounts retained-amount]. \
            \ Otherwise returns [targets amounts 0.0]. Prevents duplicate receivers in bulk transfers."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (search:[integer] (ref-U|LST::UC_Search targets account))
            )
            (if (!= (length search) 0)
                (let
                    (
                        (pos:integer (at 0 search))
                        (retained:decimal (at pos amounts))
                    )
                    [
                        (ref-U|LST::UC_RemoveItemAt targets pos)
                        (ref-U|LST::UC_RemoveItemAt amounts pos)
                        retained
                    ]
                )
                [targets amounts 0.0]
            )
        )
    )
    (defun UC_FindStoaPath:object{CachedPathOrMiss} (stoa-paths:[object{TokenPathPair}] first-token:string)
        @doc "#34 Phase 7: linear search of a bundle's (already deduped, at most 6-7 \
            \ entries) <stoa-paths> for the entry matching <first-token>. Returns the \
            \ [BAR]-sentinel shape (is-new=false — nothing to register for a lookup \
            \ miss, that's a bundle-construction error, not a fresh discovery) if the \
            \ bundle didn't include an entry for this token at all — Phase 8's caller \
            \ must treat that the same as any other invalid/missing path, not silently \
            \ skip stoa-value pricing for that pool."
        (let*
            (
                (matches:[object{TokenPathPair}]
                    (filter (lambda (tp:object{TokenPathPair}) (= (at "first-token" tp) first-token)) stoa-paths)
                )
            )
            (if (= (length matches) 0)
                {"nodes": [BAR], "edges": [], "is-new": false}
                (at "path" (at 0 matches))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_DedupFirstTokens:[string] (distinct-edges:[string])
        @doc "#34 Phase 7 (validated with real evidence, P0.6/Phase 5): given the swap's \
            \ own <distinct-edges> (the pools actually traversed), returns the DEDUPED \
            \ list of their first tokens — one entry per distinct first token, not one \
            \ per pool. Two pools sharing a first token (confirmed real in the P2-scale \
            \ topology: two W-chain pools both first=W4, identical 673,080 gas each to \
            \ price independently) collapse to a single lookup here."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (distinct (map (lambda (sp:string) (at 0 (ref-SWP::UR_PoolTokens sp))) distinct-edges))
        )
    )
    (defun URC_PoolStoaValueFromPath:decimal (swpair:string stoa-paths:[object{TokenPathPair}])
        @doc "#34 Phase 8 — the 'dumb-writer' replacement for URC_PoolValue's own \
            \ URC_WorthWSTOA(first-token, first-token-supply) call. Reproduces \
            \ URC_PoolValue's EXACT pool-worth formula (same current-lp-supply/genesis \
            \ branch, same per-pool-type math), but sources <first-worth> from the \
            \ bundle's <stoa-paths> instead of a fresh first-token->WSTOA search — that \
            \ search is the actual redundant cost this whole helper exists to remove \
            \ (P0.6: 56.9% of the 102-pool worst-case total, more than 3x routing+boost \
            \ combined). Target is WSTOA (DALOS::UR_WrappedStoaID), matching \
            \ URC_PoolValue's own doc ('Outputs the Pool Value in WSTOA') — NOT SSTOA (see \
            \ CachedPathOrMiss's doc, caught 2026-08-21 before this was built). \
            \ Returns -1.0 (impossible pool-worth, easy sentinel) when the bundle didn't \
            \ supply a usable path for this pool's first token — same graceful-degrade \
            \ principle as the rest of Phase 8: a bad/missing entry just means this ONE \
            \ pool's stoa-value doesn't get refreshed this round, never a crash or an \
            \ aborted swap. Every path is re-validated here regardless of the bundle's \
            \ own <is-new> claim (P3.1: even a cache hit always re-validates) — \
            \ exists-only (SWPT::URC_ValidatePathStructure), matching URC_WorthWSTOA's own \
            \ URC_Hopper (unfiltered universe, not URC_HopperActive) — pricing paths were \
            \ never required to route over can-swap=true pools only."
        (let*
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                ;;Same wstoa/sstoa short-circuits URC_WorthWSTOA already has — no path tracing
                ;;needed or possible for these two (sstoa<->wstoa is a fixed protocol-level
                ;;ATS liquid-index conversion, not a swap-pool route).
                (first-worth:decimal
                    (if (= first-token wstoa)
                        first-token-supply
                        (if (= first-token sstoa)
                            (let
                                (
                                    (ats-pairs-with-sstoa-id:[string] (ref-DPTF::UR_RewardBearingToken sstoa))
                                    (stoaliquindex:string (at 0 ats-pairs-with-sstoa-id))
                                    (index-value:decimal (ref-ATS::URC_Index stoaliquindex))
                                    (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                                )
                                (floor (* first-token-supply index-value) sstoa-prec)
                            )
                            (let*
                                (
                                    (path:object{CachedPathOrMiss} (UC_FindStoaPath stoa-paths first-token))
                                    (nodes:[string] (at "nodes" path))
                                    (edges:[string] (at "edges" path))
                                    (le:integer (length nodes))
                                    (is-valid:bool
                                        (if (= nodes [BAR])
                                            false
                                            (and
                                                (ref-SWPT::URC_ValidatePathStructure nodes edges)
                                                (and
                                                    (= (at 0 nodes) first-token)
                                                    (= (at (- le 1) nodes) wstoa)
                                                )
                                            )
                                        )
                                    )
                                )
                                (if (not is-valid)
                                    -1.0
                                    (let*
                                        (
                                            (h-obj:object{SwapperIssueV4.Hopper}
                                                (ref-SWPI::URC_HopperForKnownRoute nodes edges first-token-supply)
                                            )
                                            (ovs:[decimal] (at "output-values" h-obj))
                                        )
                                        (if (= (length ovs) 0)
                                            first-token-supply
                                            (at 0 (take -1 ovs))
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
            (if (= first-worth -1.0)
                -1.0
                (if (or (= pool-type "S") (= pool-type "P"))
                    (floor (* (dec how-many) first-worth) first-token-precision)
                    (floor (/ first-worth first-weigth) first-token-precision)
                )
            )
        )
    )
    (defun URC_ComputeStoaValueResults:list
        (distinct-edges:[string] stoa-paths:[object{TokenPathPair}])
        @doc "#34 Phase 8 (P3.3/P3.4) — emits [{pool, stoa-value}, ...] for every pool in \
            \ <distinct-edges> the bundle could actually price (skips any pool whose \
            \ first-token has no valid <stoa-paths> entry — URC_PoolStoaValueFromPath's \
            \ -1.0 sentinel — rather than fail the whole swap over one unpriceable pool). \
            \ Does NOT assume <distinct-edges> or <stoa-paths> were perfectly deduped by \
            \ the caller (P3.3: worst case, redundant but harmless per-pool lookups \
            \ against an already-supplied path — no correctness risk, only a missed \
            \ optimization if the caller's own dedup was sloppy)."
        (if (= (length distinct-edges) 0)
            []
            (let
                (
                    (results:[decimal] (map (lambda (sp:string) (URC_PoolStoaValueFromPath sp stoa-paths)) distinct-edges))
                )
                (fold
                    (lambda (acc:list idx:integer)
                        (if (= (at idx results) -1.0)
                            acc
                            (+ acc [{"pool" : (at idx distinct-edges), "stoa-value" : (at idx results)}])
                        )
                    )
                    []
                    ;;#20H-style guard: (enumerate 0 -1) is [0 -1], not empty, in Pact 5 —
                    ;;the outer 0-length branch above already keeps this fold from ever
                    ;;seeing that case, but guarding the enumerate bound directly too
                    ;;(matches this codebase's established convention) costs nothing.
                    (enumerate 0 (- (length distinct-edges) 1))
                )
            )
        )
    )
    ;;
    (defun URCi_ToggleSwapCapability:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string toggle:bool)
        @doc "Cost preview for C_ToggleSwapCapability: delegates to SWP's add-or-swap toggle \
            \ cost (add-or-swap = false)."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-SWP::URCi_ToggleAddOrSwap swpair toggle false)
        )
    )
    (defun URCi_SmartSwapCore:list
        (account:string input-amount:decimal ico-input:object{IgnisCollectorV3.OutputCumulator} nodes:[string] edges:[string] boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "Exact cost of XI_SmartSwapCore's hop fold. Intermediate hops keep tokens inside \
            \ SWP and contribute only EOC; only the LAST hop emits the batched special-fee flush \
            \ (URCi_MultiBulkTransferCumulator over every earlier hop's targets), its own output \
            \ payout, and the single liquid-boost burn against the accumulated carried boost. \
            \ The cost is amount-INDEPENDENT (which tokens/pools + each pool's fee config decide \
            \ every leg); amounts are still threaded via the PURE swap math so output == exec. \
            \ Returns [final-netto all-icos]. The dra/new-balances/XE_UpdateSupplies writes and \
            \ the per-hop FEED-SPECIAL-TARGETS events carry no cumulator cost and are omitted."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                (le:integer (length edges))
            )
            (take 2
                (fold
                    (lambda
                        (acc:list idx:integer)
                        (let*
                            (
                                (current-input:decimal (at 0 acc))
                                (acc-icos:[object{IgnisCollectorV3.OutputCumulator}] (at 1 acc))
                                (carried-boost-in:decimal (at 2 acc))
                                (sp-id-lst-in:[string] (at 3 acc))
                                (sp-receiver-arr-in:[[string]] (at 4 acc))
                                (sp-amount-arr-in:[[decimal]] (at 5 acc))
                                (i-id:string (at idx nodes))
                                (o-id:string (at (+ idx 1) nodes))
                                (swpair:string (at idx edges))
                                (iz-last:bool (= idx (- le 1)))
                                ;;
                                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                                (fees:object{UtilitySwpV2.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                                (A:decimal (ref-SWP::UR_Amplifier swpair))
                                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                                (input-positions:[integer] (ref-SWPI::URCv_PoolTokenPositions swpair [i-id]))
                                (output-position:integer (ref-SWP::URv_PoolTokenPosition swpair o-id))
                                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                                (dtso:object{UtilitySwpV2.DirectTaxedSwapOutput}
                                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type
                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [current-input] o-id)
                                        fees A X X-prec input-positions output-position W))
                                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                                (o-id-special:decimal (at "o-id-special" dtso))
                                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                                (o-id-netto:decimal (at "o-id-netto" dtso))
                                ;;
                                (ico-fuel:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-SWPLC::URCi_Fuel account swpair lp-fuel false))
                                (carried-boost-out:decimal
                                    (+
                                        (if (= carried-boost-in 0.0)
                                            0.0
                                            (ref-SWPI::URCv_Swap swpair (ref-U|SWP::UDC_DirectSwapInputData [i-id] [carried-boost-in] o-id) false)
                                        )
                                        o-id-liquid
                                    )
                                )
                                (sp-hop-targets:list
                                    (if (and (!= o-id-special 0.0) (not iz-last))
                                        (let
                                            (
                                                (fsft:list (UC_FilterSelfFromTargets account (ref-SWP::UR_SpecialFeeTargets swpair)
                                                    (ref-U|SWP::UC_SpecialFeeOutputs (ref-SWP::UR_SpecialFeeTargetsProportions swpair) o-id-special (at output-position X-prec))))
                                            )
                                            [(at 0 fsft) (at 1 fsft)]
                                        )
                                        [[] []]
                                    )
                                )
                                (hop-f-targets:[string] (at 0 sp-hop-targets))
                                (hop-f-amounts:[decimal] (at 1 sp-hop-targets))
                                (sp-id-lst-out:[string]
                                    (if (!= (length hop-f-targets) 0) (+ sp-id-lst-in [o-id]) sp-id-lst-in))
                                (sp-receiver-arr-out:[[string]]
                                    (if (!= (length hop-f-targets) 0) (+ sp-receiver-arr-in [hop-f-targets]) sp-receiver-arr-in))
                                (sp-amount-arr-out:[[decimal]]
                                    (if (!= (length hop-f-targets) 0) (+ sp-amount-arr-in [hop-f-amounts]) sp-amount-arr-in))
                                (sp-flush:object{IgnisCollectorV3.OutputCumulator}
                                    (if (and iz-last (!= (length sp-id-lst-in) 0))
                                        (ref-TFT::URCi_MultiBulkTransferCumulator sp-id-lst-in SWP|SC_NAME sp-receiver-arr-in sp-amount-arr-in)
                                        EOC))
                                (ico-special:object{IgnisCollectorV3.OutputCumulator}
                                    (if iz-last
                                        (if (!= o-id-special 0.0)
                                            (let
                                                (
                                                    (fsft:list (UC_FilterSelfFromTargets account (ref-SWP::UR_SpecialFeeTargets swpair)
                                                        (ref-U|SWP::UC_SpecialFeeOutputs (ref-SWP::UR_SpecialFeeTargetsProportions swpair) o-id-special (at output-position X-prec))))
                                                )
                                                (let
                                                    (
                                                        (f-targets:[string] (at 0 fsft))
                                                        (adjusted-netto:decimal (+ o-id-netto (at 2 fsft)))
                                                    )
                                                    (if (!= (length f-targets) 0)
                                                        (ref-TFT::URCi_MultiBulkTransferCumulator [o-id] SWP|SC_NAME [(+ [account] f-targets)] [(+ [adjusted-netto] (at 1 fsft))])
                                                        (ref-TFT::URCi_Transfer o-id SWP|SC_NAME account adjusted-netto)
                                                    )
                                                )
                                            )
                                            (ref-TFT::URCi_Transfer o-id SWP|SC_NAME account o-id-netto)
                                        )
                                        EOC))
                                (boost:object{IgnisCollectorV3.OutputCumulator}
                                    (if (and iz-last (!= carried-boost-out 0.0))
                                        (URCi_RawLiquidPump o-id carried-boost-out boost-path)
                                        EOC))
                            )
                            [
                                o-id-netto
                                (+ acc-icos [ico-fuel sp-flush ico-special boost])
                                carried-boost-out
                                sp-id-lst-out
                                sp-receiver-arr-out
                                sp-amount-arr-out
                            ]
                        )
                    )
                    [input-amount [ico-input] 0.0 [] [] []]
                    (enumerate 0 (- le 1))
                )
            )
        )
    )
    (defun URCi_SmartSwapExec:object{IgnisCollectorV3.OutputCumulator}
        (account:string input-id:string input-amount:decimal output-id:string nodes:[string] edges:[string] boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "Exact cost of XI_SmartSwap: the user->SWP input transfer + the hop-fold cost + the \
            \ [final-netto hops pools distinct-edges] output. The STOA-pid OPU is a free write."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (hop-result:list
                    (URCi_SmartSwapCore account input-amount
                        (ref-TFT::URCi_Transfer input-id account SWP|SC_NAME input-amount)
                        nodes edges boost-path))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                (at 1 hop-result)
                [(at 0 hop-result) (length edges) (length (distinct edges)) (distinct edges)]
            )
        )
    )
    (defun URCi_SmartSwap:object{IgnisCollectorV3.OutputCumulator}
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @doc "Exact cost preview for CC_SmartSwap (self-searching). Traces the route read-only via \
            \ URC_HopperActive, applies the same fee-less-output slippage floor vs the client-supplied \
            \ bounds, then prices the hop fold with NO_PATH (the boost route is re-derived read-only)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (h-obj:object{SwapperIssueV4.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
            )
            (if (!= slippage -1.0)
                (if (>= (at 0 (take -1 (at "output-values" h-obj))) (at 0 (UC_SlippageMinMax slippage-bounds)))
                    (URCi_SmartSwapExec account input-id input-amount output-id (at "nodes" h-obj) (at "edges" h-obj) NO_PATH)
                    (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [])
                )
                (URCi_SmartSwapExec account input-id input-amount output-id (at "nodes" h-obj) (at "edges" h-obj) NO_PATH)
            )
        )
    )
    (defun URCi_SmartSwapWithBundle:object{IgnisCollectorV3.OutputCumulator}
        (account:string input-id:string input-amount:decimal output-id:string slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage} bundle:object{SwapperUsageV3.SmartSwapPathBundle})
        @doc "Exact cost preview for C_SmartSwap (bundle-based). Uses the dirty-read bundle's own \
            \ swap-route + boost-path (fed identically to exec and preview), validates the fee-less \
            \ output vs the client bounds, then prices the hop fold with the supplied boost-path. \
            \ Returns the OutputCumulator only (C_SmartSwap's extra stoa-results is a Talos-side \
            \ precompute, not a cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (nodes:[string] (at "nodes" (at "swap-route" bundle)))
                (edges:[string] (at "edges" (at "swap-route" bundle)))
            )
            (if (!= slippage -1.0)
                (if (>= (at 0 (take -1 (at "output-values" (ref-SWPI::URC_HopperForKnownRoute nodes edges input-amount)))) (at 0 (UC_SlippageMinMax slippage-bounds)))
                    (URCi_SmartSwapExec account input-id input-amount output-id nodes edges (at "boost-path" bundle))
                    (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [])
                )
                (URCi_SmartSwapExec account input-id input-amount output-id nodes edges (at "boost-path" bundle))
            )
        )
    )
    (defun URCi_RawLiquidPump:object{IgnisCollectorV3.OutputCumulator}
        (id:string amount:decimal boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "Exact cost of XI_RawLiquidPump's boost leg. The whole boost — regardless of route \
            \ length — is ONE SSTOA burn on SWP (or EOC when there is no active route to SSTOA). \
            \ The route search only decides existence + amount, both read-only; it never changes \
            \ the cumulator. Mirrors the exec exactly: direct burn when id==SSTOA; otherwise \
            \ NO_PATH sentinel => URC_HopperActiveShortest search, or a validated bundle-supplied \
            \ path => URC_HopperForKnownRoute; empty output-values => EOC."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
            )
            (if (= id sstoa)
                (ref-DPTF::URCi_Burn sstoa SWP|SC_NAME)
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (is-sentinel:bool (= (at "nodes" boost-path) [BAR]))
                    )
                    (let
                        (
                            (ovs:[decimal]
                                (if is-sentinel
                                    (at "output-values" (ref-SWPI::URC_HopperActiveShortest id sstoa amount))
                                    (if (and
                                            (ref-SWPI::URC_ValidatePathActive (at "nodes" boost-path) (at "edges" boost-path))
                                            (and
                                                (= (at 0 (at "nodes" boost-path)) id)
                                                (= (at (- (length (at "nodes" boost-path)) 1) (at "nodes" boost-path)) sstoa)
                                            )
                                        )
                                        (at "output-values" (ref-SWPI::URC_HopperForKnownRoute (at "nodes" boost-path) (at "edges" boost-path) amount))
                                        []
                                    )
                                )
                            )
                        )
                        (if (= (length ovs) 0)
                            EOC
                            (ref-DPTF::URCi_Burn sstoa SWP|SC_NAME)
                        )
                    )
                )
            )
        )
    )
    (defun URCi_SwapCore:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "Exact cost of a single XI_Swap: input multi-transfer in + LP fuel (indirect => EOC) \
            \ + the output leg (special-fee bulk split or a plain netto transfer) + the liquid \
            \ boost. All amounts come from the PURE UC_BareboneSwapWithFeez swap math; output == \
            \ [o-id-netto]. The XE_UpdateSupplies / autonomous-swap-management writes carry no cost."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                ;;
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV2.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URCv_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::URv_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                (dtso:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W))
                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                (o-id-special:decimal (at "o-id-special" dtso))
                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                (o-id-netto:decimal (at "o-id-netto" dtso))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator input-ids account SWP|SC_NAME input-amounts))
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-SWPLC::URCi_Fuel account swpair lp-fuel false))
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (if (!= o-id-special 0.0)
                        (let
                            (
                                (o-prec:integer (at output-position X-prec))
                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                (fsft:list (UC_FilterSelfFromTargets account (ref-SWP::UR_SpecialFeeTargets swpair) target-amounts))
                                (f-targets:[string] (at 0 fsft))
                                (f-amounts:[decimal] (at 1 fsft))
                                (adjusted-netto:decimal (+ o-id-netto (at 2 fsft)))
                            )
                            (if (!= (length f-targets) 0)
                                (ref-TFT::URCi_MultiBulkTransferCumulator
                                    [output-id] SWP|SC_NAME [(+ [account] f-targets)] [(+ [adjusted-netto] f-amounts)])
                                (ref-TFT::URCi_Transfer output-id SWP|SC_NAME account adjusted-netto)
                            )
                        )
                        (ref-TFT::URCi_Transfer output-id SWP|SC_NAME account o-id-netto)
                    )
                )
                (boost:object{IgnisCollectorV3.OutputCumulator}
                    (if (!= o-id-liquid 0.0)
                        (URCi_RawLiquidPump output-id o-id-liquid boost-path)
                        EOC
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 boost] [o-id-netto])
        )
    )
    (defun URCi_Swap:object{IgnisCollectorV3.OutputCumulator}
        (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @doc "Exact cost preview for C_Swap (direct single/multi-pool swap; the STOA-pid OPU is a \
            \ free write). When slippage != -1.0, the read-only URCv_Swap actual output is checked \
            \ against the client-supplied (dirty-read) slippage-bounds min — exactly as the exec — \
            \ and a below-floor swap returns the zero-cost exceed cumulator without executing. The \
            \ direct swap self-searches its boost route, so NO_PATH is passed (URCi_SwapCore then \
            \ re-derives the route read-only)."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id))
            )
            (if (= slippage -1.0)
                (URCi_SwapCore account swpair dsid NO_PATH)
                (if (>= (ref-SWPI::URCv_Swap swpair dsid true) (at 0 (UC_SlippageMinMax slippage-bounds)))
                    (URCi_SwapCore account swpair dsid NO_PATH)
                    (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [])
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;MODULE-ONLY on purpose: nothing outside SWPU needs it, and declaring it in SwapperUsageV3
    ;;would bump the interface and pull every consumer along under the cascade rule -- the same
    ;;reasoning 04_BRD.pact records for UDC_BrandingGenesis.
    (defun UEV_Slippage (slippage:decimal)
        @doc "RT-H-002 / Stage-0 target V-01 (2026-09-15). The <= 50 ceiling existed ONLY inside \
            \ UDC_SpawnSmartSwapSlippageBounds and UDC_SlippageObject -- CONSTRUCTORS, whose own \
            \ @doc says they are called by the UI. The client surface takes the BUILT OBJECT: \
            \ SWP|CC_SmartSwapWithSlippage receives slippage-bounds, and TS01-C3 reads the number \
            \ back out of it. An integrator who hand-builds the object never calls the constructor, \
            \ and nothing downstream re-checked it -- UEV_SwapData validates token sets and lengths \
            \ only. MEASURED at RedTeam/[RT-H]_InputDomain.repl <<RT-H-002>>: a forged 9999% drives \
            \ UC_SlippageMinMax's floor to -98990.0, so no output can breach it and the bound is \
            \ inoperative -- precisely what the ceiling exists to prevent. The rule mirrors the \
            \ constructor's exactly, -1.0 included, so a WITH-SLIPPAGE cap that legitimately \
            \ receives the no-slippage sentinel is unaffected."
        (enforce
            (= (floor slippage 2) slippage)
            (format "{} is not slippage conform decimal wise (max 2 decimals allowed)" [slippage])
        )
        (enforce
            (or
                (= slippage -1.0)
                (and
                    (> slippage 0.0)
                    (<= slippage 50.0)
                )
            )
            "Slippage must be greater than 0.0 and maximum 50.0, or -1.0 for no slippage"
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_SmartSwapAndRegister:list
        (patron:string 
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage} bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: C_SmartSwap's body, factored out so it runs entirely INSIDE \
            \ the caller's with-capability block (required for XI_RegisterBundlePaths' \
            \ own require-capability (SECURE) to see a granted capability — see \
            \ C_SmartSwap's doc for why this had to be restructured this way)."
        (require-capability (SECURE))
        (let*
            (
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (XI_SmartSwapExplicitRoute patron account input-id input-amount output-id slippage stoa-pid slippage-bounds bundle)
                )
                (out:list (at "output" ico))
                ;;A slippage-exceeded soft-fail (matching CC_SmartSwap's own established
                ;;shape) returns a 1-element <output> ([exceed-message]) instead of the
                ;;successful [final-netto hops pools distinct-edges] 4-element shape — no
                ;;swap happened, so there's nothing to price or register, <stoa-results>
                ;;is [] and no registration call fires.
                (stoa-results:list
                    (if (= (length out) 4)
                        (URC_ComputeStoaValueResults (at 3 out) (at "stoa-paths" bundle))
                        []
                    )
                )
            )
            (if (= (length out) 4)
                (XI_RegisterBundlePaths input-id output-id (at 3 out) bundle)
                "no registration — swap did not execute"
            )
            [ico stoa-results]
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SmartSwapRouter:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage} h-obj:object{SwapperIssueV4.Hopper}
        )
        @doc "Routes Smart Swap: performs slippage check using fee-less multi-hop output, then executes. \
            \ #65L fix: <h-obj> is now supplied by the caller (CC_SmartSwap), computed \
            \ once and shared with the defcap — this function no longer re-runs \
            \ SWPI::URC_HopperActive's full-graph search a second time."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (nodes:[string] (at "nodes" h-obj))
                (edges:[string] (at "edges" h-obj))
                (ovs:[decimal] (at "output-values" h-obj))
                (feeless-final:decimal (at 0 (take -1 ovs)))
            )
            (if (!= slippage -1.0)
                (let
                    (
                        (min-max:[decimal] (UC_SlippageMinMax slippage-bounds))
                        (min:decimal (at 0 min-max))
                        (max:decimal (at 1 min-max))
                        (exceed-message:string
                            (format "Smart Swap Expected Output of {} out of Slippage bounds min of {} - max of {}" [feeless-final min max])
                        )
                    )
                    ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and` wrapper
                    ;;removed with it — Pact 5's `and` doesn't accept a single argument at
                    ;;runtime, confirmed the hard way via a real swap-execution test, not just
                    ;;load). Rejecting a swap for delivering MORE than quoted ("positive
                    ;;slippage") isn't how any major AMM works — checked Uniswap V2/V3, Curve,
                    ;;Balancer, SushiSwap, PancakeSwap: every one enforces a floor only on
                    ;;exact-input swaps, never a ceiling; several (CoW Protocol, UniswapX) are
                    ;;explicitly built to maximize/pass through favorable execution instead. To
                    ;;re-enable, restore `(and (>= feeless-final min) (<= feeless-final max))` —
                    ;;the `>= min` check below must never be touched, it's the real protection
                    ;;this whole check exists for.
                    (if
                        (>= feeless-final min)
                        ;;(<= feeless-final max)
                        (XI_SmartSwap patron account input-id input-amount output-id nodes edges stoa-pid NO_PATH)
                        ;;#66L fix: named UDC_* constructor instead of a hand-built object literal —
                        ;;trigger=true reproduces the exact same {"ignis":0.0,"interactor":BAR} shape.
                        (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [exceed-message])
                    )
                )
                (XI_SmartSwap patron account input-id input-amount output-id nodes edges stoa-pid NO_PATH)
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SmartSwapExplicitRoute:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            account:string input-id:string input-amount:decimal output-id:string slippage:decimal
            stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage} bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8 — the bundle-based counterpart to XI_SmartSwapRouter: zero \
            \ internal searching. The route (structural connectivity, active-required, \
            \ depth-cap, correct endpoints) is already fully validated by the calling \
            \ defcap (SWPU|X>SMART-SWAP-EXPLICIT-ROUTE) before this function ever runs — \
            \ matching this codebase's client-defcap-does-all-validation convention, this \
            \ XI_* does no enforce of its own. The feeless quote for the slippage floor \
            \ check is computed via URC_HopperForKnownRoute over the bundle's EXACT \
            \ edges (not a re-derived 'best' edge — see that function's own doc for why \
            \ this matters for keeping the quote and real execution consistent)."
        (require-capability (SECURE))
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (nodes:[string] (at "nodes" (at "swap-route" bundle)))
                (edges:[string] (at "edges" (at "swap-route" bundle)))
                (h-obj:object{SwapperIssueV4.Hopper} (ref-SWPI::URC_HopperForKnownRoute nodes edges input-amount))
                (ovs:[decimal] (at "output-values" h-obj))
                (feeless-final:decimal (at 0 (take -1 ovs)))
            )
            (if (!= slippage -1.0)
                (let
                    (
                        (min-max:[decimal] (UC_SlippageMinMax slippage-bounds))
                        (min:decimal (at 0 min-max))
                        (max:decimal (at 1 min-max))
                        (exceed-message:string
                            (format "Smart Swap Expected Output of {} out of Slippage bounds min of {} - max of {}" [feeless-final min max])
                        )
                    )
                    ;;Same floor-only policy as XI_SmartSwapRouter (#26M/M9) — see that
                    ;;function's own comment for the full rationale, unchanged here.
                    (if
                        (>= feeless-final min)
                        (XI_SmartSwap patron account input-id input-amount output-id nodes edges stoa-pid (at "boost-path" bundle))
                        ;;#66L fix: named UDC_* constructor instead of a hand-built object literal —
                        ;;trigger=true reproduces the exact same {"ignis":0.0,"interactor":BAR} shape.
                        (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [exceed-message])
                    )
                )
                (XI_SmartSwap patron account input-id input-amount output-id nodes edges stoa-pid (at "boost-path" bundle))
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_RegisterBundlePaths (input-id:string output-id:string distinct-edges:[string] bundle:object{SwapperUsageV3.SmartSwapPathBundle})
        @doc "#34 Phase 8: cache self-warming — registers a bundle's <boost-path> and \
            \ each <stoa-paths> entry into SWPT|PathCache, ONLY when (a) the bundle \
            \ claims <is-new>=true AND (b) re-validated here from scratch (never trusting \
            \ the caller's claim — P3.1) AND (c), for stoa-paths, the first-token was \
            \ genuinely among THIS swap's own touched pools (URC_DedupFirstTokens of the \
            \ real <distinct-edges>, never blindly every entry a caller stuffed into the \
            \ bundle — matches P3.1's 'writes only as a side-effect of a real, validated, \
            \ USED path' rule, not just 'a real, validated path'). Registers via \
            \ SWPT::XE_RegisterPath (the forward-module writer, P|UEV_IMC + internal \
            \ SECURE composition) — never a caller-side grant of SWPT's own SECURE cap \
            \ directly (see XE_RegisterPath's own doc for why that would be unsafe). \
            \ XI_RegisterPath's own version-checked-refresh (#65bL Phase 1) makes every \
            \ call here safe regardless of whether an entry already exists. \
            \ #65bL fix: also registers the bundle's own <swap-route> (input-id-> \
            \ output-id) — previously never cached at all (see SwapRoute's own doc for \
            \ the ORIGINAL reason, and why #65bL's Phase 5 resolved it): the concern was \
            \ that the 'best' route is amount-sensitive (a real, value-comparing search \
            \ could legitimately prefer a different route for a different trade size), \
            \ so caching one amount's answer and serving it for another's could have been \
            \ wrong. Phase 5 already removed value-comparison from the live on-chain \
            \ default (best-of-3 -> first-found) — first-found is PURE topology \
            \ (SWPT::URC_ComputeGraphPath takes no amount parameter at all), so the \
            \ structural route itself is now provably amount-independent regardless of \
            \ which amount it was originally discovered for. Serving a cached, \
            \ off-chain-exhaustive-search-discovered route to a live first-found query is \
            \ therefore never WORSE than a fresh first-found search (same structural \
            \ validity for any amount) and is very plausibly better (a genuine exhaustive \
            \ search found it, not a first-hit BFS) — real value is still always computed \
            \ fresh, live, at execution time regardless, exactly as every other cached \
            \ entry already works."
        (require-capability (SECURE))
        (let*
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (swap-route:object{SwapRoute} (at "swap-route" bundle))
                (route-nodes:[string] (at "nodes" swap-route))
                (route-edges:[string] (at "edges" swap-route))
                (route-le:integer (length route-nodes))
                (route-eligible:bool
                    (if (= route-nodes [BAR])
                        false
                        (fold (and) true
                            [
                                (ref-SWPI::URC_ValidatePathActive route-nodes route-edges)
                                (= (at 0 route-nodes) input-id)
                                (= (at (- route-le 1) route-nodes) output-id)
                            ]
                        )
                    )
                )
                (boost-path:object{CachedPathOrMiss} (at "boost-path" bundle))
                (boost-nodes:[string] (at "nodes" boost-path))
                (boost-edges:[string] (at "edges" boost-path))
                (boost-le:integer (length boost-nodes))
                (boost-eligible:bool
                    (if (or (not (at "is-new" boost-path)) (= boost-nodes [BAR]))
                        false
                        (fold (and) true
                            [
                                (ref-SWPI::URC_ValidatePathActive boost-nodes boost-edges)
                                (= (at 0 boost-nodes) output-id)
                                (= (at (- boost-le 1) boost-nodes) sstoa)
                            ]
                        )
                    )
                )
            )
            (if route-eligible
                (ref-SWPT::XE_RegisterPath input-id output-id route-nodes route-edges)
                "swap-route not registered (invalid or sentinel)"
            )
            (if boost-eligible
                (ref-SWPT::XE_RegisterPath output-id sstoa boost-nodes boost-edges)
                "boost-path not registered (not new, invalid, or sentinel)"
            )
            (map
                (lambda (ft:string)
                    (let*
                        (
                            (path:object{CachedPathOrMiss} (UC_FindStoaPath (at "stoa-paths" bundle) ft))
                            (nodes:[string] (at "nodes" path))
                            (edges:[string] (at "edges" path))
                            (le:integer (length nodes))
                            (eligible:bool
                                (if (or (not (at "is-new" path)) (= nodes [BAR]))
                                    false
                                    (fold (and) true
                                        [
                                            (ref-SWPT::URC_ValidatePathStructure nodes edges)
                                            (= (at 0 nodes) ft)
                                            (= (at (- le 1) nodes) wstoa)
                                        ]
                                    )
                                )
                            )
                        )
                        (if eligible
                            (ref-SWPT::XE_RegisterPath ft wstoa nodes edges)
                            "stoa-path not registered (not new, invalid, or sentinel)"
                        )
                    )
                )
                (URC_DedupFirstTokens distinct-edges)
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SmartSwap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            account:string input-id:string input-amount:decimal output-id:string
            nodes:[string] edges:[string] stoa-pid:decimal boost-path:object{SwapperUsageV3.CachedPathOrMiss}
        )
        @doc "Executes the multi-hop Smart Swap. Transfers input from user, delegates hop iteration \
            \ to XI_SmartSwapCore, handles stoa-pid OURO price update, and returns final OutputCumulator. \
            \ #34 Phase 8: <boost-path> passthrough to XI_SmartSwapCore — NO_PATH sentinel from the \
            \ self-searching XI_SmartSwapRouter caller above, or a real bundle-supplied path from the \
            \ new dirty-read-injected XI_SmartSwapExplicitRoute caller. Shared unchanged by both — \
            \ nothing in this function searches for anything itself, so nothing here needed to change \
            \ beyond accepting and forwarding the one new parameter."
        (require-capability (SECURE))
        (let*
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (pp:string (ref-SWP::UR_PrimordialPool))
                (ico-input:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer patron account SWP|SC_NAME input-id input-amount true)
                )
                (hop-result:list
                    (XI_SmartSwapCore patron account input-amount ico-input nodes edges boost-path)
                )
                (final-netto:decimal (at 0 hop-result))
                (all-icos:[object{IgnisCollectorV3.OutputCumulator}] (at 1 hop-result))
                (hops:integer (length edges))
                (distinct-edges:[string] (distinct edges))
                (pools:integer (length distinct-edges))
                (final-ico:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators all-icos [final-netto hops pools distinct-edges])
                )
            )
            (if (> stoa-pid 0.0)
                (let
                    (
                        (iz-on-path:bool
                            (fold
                                (lambda (acc:bool edge:string) (or acc (= edge pp)))
                                false
                                edges
                            )
                        )
                    )
                    (if iz-on-path
                        (XI_STOA-PID|OPU pp stoa-pid)
                        true
                    )
                )
                true
            )
            final-ico
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SmartSwapCore:list
        (patron:string 
            account:string input-amount:decimal ico-input:object{IgnisCollectorV3.OutputCumulator}
            nodes:[string] edges:[string] boost-path:object{SwapperUsageV3.CachedPathOrMiss}
        )
        @doc "#34 Phase 8: <boost-path> — NO_PATH sentinel (self-searching caller, \
            \ XI_LiquidIndexPump searches internally as before) or a real bundle-supplied \
            \ id->SSTOA path (new dirty-read-injected caller) — passed through unchanged to \
            \ whichever XI_LiquidIndexPump call the last hop below fires (closure-captured \
            \ from this outer let, not threaded through the fold's own accumulator, since \
            \ it's a constant for the whole call, not something that varies per hop). \
            \ Iterates over all hops of a Smart Swap path. For each hop: computes fee-aware swap, fuels LP, \
            \ updates pool supplies, pays special targets, carries the Liquid Boost slice forward. \
            \ P0.6 direction 5 (SWP exhaustive-path-search HANDOFF doc): the Liquid Boost cut is no \
            \ longer priced-and-burned on every hop (6 independent full-graph searches on a 6-hop \
            \ route). Instead each hop converts the running carried amount into its own output token \
            \ via <SWPI::URCv_Swap> over the SAME <swpair> edge the hop's real swap already used (raw, \
            \ fee-free curve math, no search), adds this hop's own boost cut, and passes the total \
            \ forward. Only the LAST hop actually prices-and-burns, via <XI_LiquidIndexPump>, against \
            \ the single accumulated total — one graph search per SmartSwap instead of one per hop. \
            \ This intentionally does NOT reproduce the old per-hop totals (it follows the swap's own \
            \ route instead of each hop's individually-best route to SSTOA) — acceptable since this is \
            \ internal index-pump accounting, not user-facing swap output. \
            \ Returns [final-netto all-icos-list ...] — callers (<XI_SmartSwap>) only read indices \
            \ 0/1; the fold's own accumulator carries further elements (running carried-boost, and \
            \ the batched special-fee-target lists below) that have already been fully consumed by \
            \ the last hop by the time the fold finishes. \
            \ Special-fee-target batching (owner's design, 2026-08-21, P0.6-adjacent — same \
            \ HANDOFF doc; rebuilt after the original worst-case test was found to never have \
            \ exercised this path at all, since <fee-special> defaulted to 0.0): every hop still \
            \ emits its own <SWPU|S>FEED-SPECIAL-TARGETS> event (the per-hop audit trail is \
            \ unchanged), but only the LAST hop pays it — every earlier hop's targets/amounts are \
            \ appended to a running list instead, and the whole batch is paid in ONE combined \
            \ multi-token <TFT::C_MultiBulkTransfer> fired on the last hop, alongside (not instead \
            \ of) that hop's own unchanged netto+targets payout."
        (require-capability (SECURE))
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                (le:integer (length edges))
            )
            (fold
                (lambda
                    (acc:list idx:integer)
                    (let*
                        (
                            (current-input:decimal (at 0 acc))
                            (acc-icos:[object{IgnisCollectorV3.OutputCumulator}] (at 1 acc))
                            (carried-boost-in:decimal (at 2 acc))
                            (sp-id-lst-in:[string] (at 3 acc))
                            (sp-receiver-arr-in:[[string]] (at 4 acc))
                            (sp-amount-arr-in:[[decimal]] (at 5 acc))
                            (i-id:string (at idx nodes))
                            (o-id:string (at (+ idx 1) nodes))
                            (swpair:string (at idx edges))
                            (iz-last:bool (= idx (- le 1)))
                            ;;
                            (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                            (fees:object{UtilitySwpV2.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                            (A:decimal (ref-SWP::UR_Amplifier swpair))
                            (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                            (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                            (input-positions:[integer] (ref-SWPI::URCv_PoolTokenPositions swpair [i-id]))
                            (output-position:integer (ref-SWP::URv_PoolTokenPosition swpair o-id))
                            (W:[decimal] (ref-SWP::UR_Weigths swpair))
                            (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                (ref-U|SWP::UDC_DirectSwapInputData [i-id] [current-input] o-id)
                            )
                            (dtso:object{UtilitySwpV2.DirectTaxedSwapOutput}
                                (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                            )
                            (lp-fuel:[decimal] (at "lp-fuel" dtso))
                            (o-id-special:decimal (at "o-id-special" dtso))
                            (o-id-liquid:decimal (at "o-id-liquid" dtso))
                            (o-id-netto:decimal (at "o-id-netto" dtso))
                            ;;
                            (ico-fuel:object{IgnisCollectorV3.OutputCumulator}
                                (ref-SWPLC::C_Fuel patron account swpair lp-fuel false false)
                            )
                            (pt-amounts-after-fuel:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                            (dra:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [i-id] [current-input]))
                            (dra-o:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [o-id] [(fold (+) 0.0 [o-id-special o-id-liquid o-id-netto])]))
                            (remaining:[decimal] (zip (-) (zip (-) dra lp-fuel) dra-o))
                            (new-balances:[decimal] (zip (+) pt-amounts-after-fuel remaining))
                            ;;P0.6 direction 5: roll the running carried Liquid Boost amount
                            ;;(denominated in <i-id>, this hop's input token) forward into
                            ;;<o-id> terms over this SAME <swpair> edge, via raw fee-free
                            ;;curve math — no search, the edge is already known. Skipped when
                            ;;nothing has been carried yet (first hop, or Liquid Boost off).
                            (converted-carry:decimal
                                (if (= carried-boost-in 0.0)
                                    0.0
                                    (ref-SWPI::URCv_Swap
                                        swpair
                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [carried-boost-in] o-id)
                                        false
                                    )
                                )
                            )
                            (carried-boost-out:decimal (+ converted-carry o-id-liquid))
                            ;;Special-fee-target batching: on every NON-last hop, still emit the
                            ;;SAME <SWPU|S>FEED-SPECIAL-TARGETS> event as before (unchanged
                            ;;per-hop audit trail) but don't pay yet — append <o-id>/its
                            ;;filtered targets+amounts to the running batch instead. [[] []]
                            ;;(no-op, nothing appended) whenever this hop has no special cut, or
                            ;;is the last hop (whose own targets stay handled by <ico-special>
                            ;;below, unchanged).
                            (sp-hop-targets:list
                                (if (and (!= o-id-special 0.0) (not iz-last))
                                    (let*
                                        (
                                            (o-prec:integer (at output-position X-prec))
                                            (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                            (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                            (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                            (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                            (f-targets:[string] (at 0 fsft))
                                            (f-amounts:[decimal] (at 1 fsft))
                                        )
                                        (with-capability (SWPU|S>FEED-SPECIAL-TARGETS o-id o-id-special f-targets target-proportions f-amounts)
                                            [f-targets f-amounts]
                                        )
                                    )
                                    [[] []]
                                )
                            )
                            (hop-f-targets:[string] (at 0 sp-hop-targets))
                            (hop-f-amounts:[decimal] (at 1 sp-hop-targets))
                            (sp-id-lst-out:[string]
                                (if (!= (length hop-f-targets) 0) (+ sp-id-lst-in [o-id]) sp-id-lst-in)
                            )
                            (sp-receiver-arr-out:[[string]]
                                (if (!= (length hop-f-targets) 0) (+ sp-receiver-arr-in [hop-f-targets]) sp-receiver-arr-in)
                            )
                            (sp-amount-arr-out:[[decimal]]
                                (if (!= (length hop-f-targets) 0) (+ sp-amount-arr-in [hop-f-amounts]) sp-amount-arr-in)
                            )
                            ;;Flush: fires ONLY on the last hop, ONE combined multi-token
                            ;;transfer covering every earlier hop's batched targets — the
                            ;;whole reason for the accumulator above. <sp-id-lst-in> (not
                            ;;-out) is correct here: this hop's own targets, if any, are
                            ;;handled separately by <ico-special> below, never appended.
                            (sp-flush:object{IgnisCollectorV3.OutputCumulator}
                                (if (and iz-last (!= (length sp-id-lst-in) 0))
                                    (ref-TFT::C_MultiBulkTransfer patron SWP|SC_NAME sp-receiver-arr-in sp-id-lst-in sp-amount-arr-in)
                                    EOC
                                )
                            )
                            ;;<ico-special> now only ever pays THIS hop's own targets+netto,
                            ;;and only on the last hop — unchanged from the pre-batching logic
                            ;;for that one case. Every non-last hop's targets are handled above
                            ;;instead (event now, payment deferred to <sp-flush>).
                            (ico-special:object{IgnisCollectorV3.OutputCumulator}
                                (if iz-last
                                    (if (!= o-id-special 0.0)
                                        (let*
                                            (
                                                (o-prec:integer (at output-position X-prec))
                                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                                (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                                (f-targets:[string] (at 0 fsft))
                                                (f-amounts:[decimal] (at 1 fsft))
                                                (retained:decimal (at 2 fsft))
                                                (adjusted-netto:decimal (+ o-id-netto retained))
                                            )
                                            (with-capability (SWPU|S>FEED-SPECIAL-TARGETS o-id o-id-special f-targets target-proportions f-amounts)
                                                (if (!= (length f-targets) 0)
                                                    (ref-TFT::C_MultiBulkTransfer
                                                        patron
                                                        SWP|SC_NAME
                                                        [(+ [account] f-targets)]
                                                        [o-id]
                                                        [(+ [adjusted-netto] f-amounts)]
                                                    )
                                                    (ref-TFT::C_Transfer patron SWP|SC_NAME account o-id adjusted-netto true)
                                                )
                                            )
                                        )
                                        (ref-TFT::C_Transfer patron SWP|SC_NAME account o-id o-id-netto true)
                                    )
                                    EOC
                                )
                            )
                        )
                        (ref-SWP::XE_UpdateSupplies swpair new-balances)
                        [
                            o-id-netto
                            (+
                                acc-icos
                                [
                                    ico-fuel
                                    sp-flush
                                    ico-special
                                    ;;P0.6 direction 5: only the LAST hop actually prices-and-
                                    ;;burns, against the full accumulated <carried-boost-out> —
                                    ;;every earlier hop just carries it forward (above), no
                                    ;;search fired.
                                    (if (and iz-last (!= carried-boost-out 0.0))
                                        (XI_LiquidIndexPump patron o-id carried-boost-out boost-path)
                                        EOC
                                    )
                                ]
                            )
                            carried-boost-out
                            sp-id-lst-out
                            sp-receiver-arr-out
                            sp-amount-arr-out
                        ]
                    )
                )
                [input-amount [ico-input] 0.0 [] [] []]
                (enumerate 0 (- le 1))
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_Swap
    (defun XI_STOA-PID|Swap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}
            slippage:decimal stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage}
        )
        @doc "Swap with optional slippage. When slippage != -1.0, min/max are taken from client-supplied slippage-bounds (computed off-chain at quote time), so the check reflects pool state at execution time."
        (let
            (
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (if (= slippage -1.0)
                        (XI_Swap patron account swpair dsid)
                        (let
                            (
                                (ref-SWPI:module{SwapperIssueV4} SWPI)
                                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                                (max-toa:decimal
                                    ;; Actual output at execution time (pool may have changed since quote)
                                    (ref-SWPI::URCv_Swap swpair dsid true)
                                )
                                (min-max:[decimal] 
                                    ;; Bounds from client-supplied slippage object (quote time)
                                    (UC_SlippageMinMax slippage-bounds)
                                )
                                (min:decimal (at 0 min-max))
                                (max:decimal (at 1 min-max))
                                (exceed-message:string
                                    (format
                                        "Expected Output of {} out of Slippage bounds min of {} - max of {}"
                                        [max-toa min max]
                                    )
                                )
                            )
                            ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and`
                            ;;wrapper removed with it — Pact 5's `and` doesn't accept a single
                            ;;argument at runtime, confirmed the hard way via a real
                            ;;swap-execution test, not just load). Rejecting a swap for
                            ;;delivering MORE than quoted ("positive slippage") isn't how any
                            ;;major AMM works — checked Uniswap V2/V3, Curve, Balancer,
                            ;;SushiSwap, PancakeSwap: every one enforces a floor only on
                            ;;exact-input swaps, never a ceiling; several (CoW Protocol,
                            ;;UniswapX) are explicitly built to maximize/pass through favorable
                            ;;execution instead. To re-enable, restore
                            ;;`(and (>= max-toa min) (<= max-toa max))` — the `>= min` check
                            ;;below must never be touched, it's the real protection this whole
                            ;;check exists for.
                            ;;#26M/M9 fix: upper bound commented out, not deleted (and the `and`
                            ;;wrapper removed with it — Pact 5's `and` doesn't accept a single
                            ;;argument at runtime, confirmed the hard way via a real
                            ;;swap-execution test, not just load). Rejecting a swap for
                            ;;delivering MORE than quoted ("positive slippage") isn't how any
                            ;;major AMM works — checked Uniswap V2/V3, Curve, Balancer,
                            ;;SushiSwap, PancakeSwap: every one enforces a floor only on
                            ;;exact-input swaps, never a ceiling; several (CoW Protocol,
                            ;;UniswapX) are explicitly built to maximize/pass through favorable
                            ;;execution instead. To re-enable, restore
                            ;;`(and (>= max-toa min) (<= max-toa max))` — the `>= min` check
                            ;;below must never be touched, it's the real protection this whole
                            ;;check exists for.
                            (if
                                (>= max-toa min)
                                ;;(<= max-toa max)
                                (XI_Swap patron account swpair dsid)
                                ;;#66L fix: named UDC_* constructor instead of a hand-built object
                                ;;literal — trigger=true reproduces the exact same
                                ;;{"ignis":0.0,"interactor":BAR} shape.
                                (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 BAR true [exceed-message])
                            )
                        )
                    )
                )
            )
            (if (> stoa-pid 0.0)
                (XI_STOA-PID|OPU swpair stoa-pid)
                true
            )
            ico
        )
    )
    ;;Protection: Class 3 — Custom: SWPU|X>SWAP
    (defun XI_Swap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (require-capability (SWPU|X>SWAP swpair dsid))
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                ;;
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV2.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URCv_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::URv_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                ;;Do Swap Computation and Unwrap Object Data
                (dtso:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                (o-id-special:decimal (at "o-id-special" dtso))
                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                (o-id-netto:decimal (at "o-id-netto" dtso))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_MultiTransfer patron account SWP|SC_NAME input-ids input-amounts true)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-SWPLC::C_Fuel patron account swpair lp-fuel false false)
                )
                (pt-amounts-after-fuel-update:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (dra:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair input-ids input-amounts))
                (dra-o:[decimal] (ref-SWPI::URC_DirectRefillAmounts swpair [output-id] [(fold (+) 0.0 [o-id-special o-id-liquid o-id-netto])]))
                (remaining-amounts-for-update:[decimal] (zip (-) (zip (-) dra lp-fuel) dra-o))
                (new-balances:[decimal] (zip (+) pt-amounts-after-fuel-update remaining-amounts-for-update))
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (if (!= o-id-special 0.0)
                        (let*
                            (
                                (o-prec:integer (at output-position X-prec))
                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                (fsft:list (UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                (f-targets:[string] (at 0 fsft))
                                (f-amounts:[decimal] (at 1 fsft))
                                (retained:decimal (at 2 fsft))
                                (adjusted-netto:decimal (+ o-id-netto retained))
                            )
                            (with-capability (SWPU|S>FEED-SPECIAL-TARGETS output-id o-id-special f-targets target-proportions f-amounts)
                                (if (!= (length f-targets) 0)
                                    (ref-TFT::C_MultiBulkTransfer
                                        patron
                                        SWP|SC_NAME
                                        [(+ [account] f-targets)]
                                        [output-id]
                                        [(+ [adjusted-netto] f-amounts)]
                                    )
                                    (ref-TFT::C_Transfer patron SWP|SC_NAME account output-id adjusted-netto true)
                                )
                            )
                        )
                        (ref-TFT::C_Transfer patron SWP|SC_NAME account output-id o-id-netto true)
                    )
                )
            )
            ;;Execute Swap Exchange
            ;;1]Move all Input Tokens to SWP|SC_NAME via ico1
            ;;2]Fuel the <swpair> increasing LP Value, scaling with swpair <fee-lp> via ico2
            ;;3]Update <swpair> with the remaining Pool Token Amounts
            (ref-SWP::XE_UpdateSupplies swpair new-balances)
            ;;4]Handle Swap Client and Special Targets, if they exist, via ico3
            ;;5]Handle Liquid Boost via output-ico
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ico1 ico2 ico3
                    (if (!= o-id-liquid 0.0)
                        ;;#34 Phase 8: direct C_Swap has no bundle to source a boost-path
                        ;;from (that's a SmartSwap-only concept) — always the NO_PATH
                        ;;sentinel here, meaning "search internally", exactly matching
                        ;;this call's own pre-Phase-8 behavior unchanged.
                        (XI_LiquidIndexPump patron output-id o-id-liquid NO_PATH)
                        EOC
                    )
                ] 
                [o-id-netto]
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_LiquidIndexPump:object{IgnisCollectorV3.OutputCumulator}
        (patron:string id:string amount:decimal boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "#34 Phase 8: <boost-path> passthrough — NO_PATH sentinel from the \
            \ self-searching caller, or a real bundle-supplied path from the new \
            \ dirty-read-injected caller. See XI_RawLiquidPump's doc for validation."
        (require-capability (SECURE))
        (let
            (
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (XI_RawLiquidPump patron id amount boost-path)
                )
                (raw-liquid-pump-data:list (at "output" ico))
            )
            ;;Bug fix, #34 (found while fixing XI_RawLiquidPump's own crash — that fix
            ;;makes it legitimately return EOC, whose "output" is [], when <id> has no
            ;;active route to SSTOA; this caller's own unguarded (at 0 ...) into that
            ;;empty list would then crash the same way, just one level up). Nothing to
            ;;pump/report when there's nothing there — skip the event+pumpdate, return
            ;;<ico> (EOC) as-is. XI_Pumpdate already tolerates non-5-length input safely
            ;;(its own length check), this guard just avoids indexing before reaching it.
            (if (= (length raw-liquid-pump-data) 0)
                ico
                (let
                    (
                        (increment:decimal (at 0 raw-liquid-pump-data))
                    )
                    (with-capability (SWPU|S>LIQUID-BOOST id amount increment)
                        (XI_Pumpdate raw-liquid-pump-data)
                    )
                    ico
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RawLiquidPump:object{IgnisCollectorV3.OutputCumulator}
        (patron:string id:string amount:decimal boost-path:object{SwapperUsageV3.CachedPathOrMiss})
        @doc "Operation that pumps LiquidIndex, returns the Pump Increment in the output object \
            \ Can be used for a Pool Token that already exists in the SWP|SC_NAME. \
            \ P0.6 fix (SWP exhaustive-path-search HANDOFF doc): routes via \
            \ <SWPI::URC_HopperActiveShortest> (single shortest BFS route), not \
            \ <URC_HopperActive> (best-of-3 alternate-route search) — this fires once \
            \ per SmartSwap hop, so the best-of-3 search's cost was being multiplied \
            \ by hop-count x 3 to price a residual fee slice that only needs *a* \
            \ valid route to SSTOA, not the optimal one. \
            \ #34 Phase 8: <boost-path> is NO_PATH (the [BAR]-nodes sentinel) for the \
            \ self-searching CC_SmartSwap caller (searches internally, as above) or a \
            \ real bundle-supplied id->SSTOA path for the new dirty-read-injected caller \
            \ (validated here — active-required, same standard <URC_HopperActiveShortest> \
            \ already enforced — before being trusted; an invalid or malformed supplied \
            \ path degrades to 'no boost pumped this time', same graceful EOC fallback \
            \ as a genuine no-route-found case, never a crash or an aborted swap)."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (liquidindex:string (at 0 (ref-DPTF::UR_RewardBearingToken sstoa)))
                (lqi:decimal (ref-ATS::URC_Index liquidindex))
            )
            (if (= id sstoa)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [(ref-DPTF::C_Burn patron SWP|SC_NAME sstoa amount)]
                    [(- (ref-ATS::URC_Index liquidindex) lqi)]
                )
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (is-sentinel:bool (= (at "nodes" boost-path) [BAR]))
                        ;;#34 Phase 8: a bundle-supplied path is never trusted blindly —
                        ;;re-validated active-required (structural connectivity + every
                        ;;edge can-swap=true) every single use, matching P3.1's "even a
                        ;;cache hit always re-validates" rule and this call's own
                        ;;pre-existing active-required standard. Also enforces the
                        ;;endpoints actually match this call's own <id>/<sstoa> — a
                        ;;structurally-valid-but-wrong-pair path (e.g. leftover from a
                        ;;different hop) must never be silently accepted.
                        (is-valid-supplied:bool
                            (if is-sentinel
                                false
                                (and
                                    (ref-SWPI::URC_ValidatePathActive (at "nodes" boost-path) (at "edges" boost-path))
                                    (and
                                        (= (at 0 (at "nodes" boost-path)) id)
                                        (= (at (- (length (at "nodes" boost-path)) 1) (at "nodes" boost-path)) sstoa)
                                    )
                                )
                            )
                        )
                        (h-obj:object{SwapperIssueV4.Hopper}
                            (if is-sentinel
                                (ref-SWPI::URC_HopperActiveShortest id sstoa amount)
                                (if is-valid-supplied
                                    (ref-SWPI::URC_HopperForKnownRoute (at "nodes" boost-path) (at "edges" boost-path) amount)
                                    ;;Invalid/malformed supplied path — degrade to the
                                    ;;same empty-output-values shape a genuine
                                    ;;no-route-found search returns, so the existing
                                    ;;<(= (length ovs) 0)> EOC fallback below handles it
                                    ;;with zero new branching.
                                    {"nodes" : [], "edges" : [], "output-values" : []}
                                )
                            )
                        )
                        (path-to-sstoa:[string] (at "nodes" h-obj))
                        (edges:[string] (at "edges" h-obj))
                        (ovs:[decimal] (at "output-values" h-obj))
                    )
                    ;;Bug fix, #34 (SWP exhaustive-path-search HANDOFF doc, flagged during
                    ;;P0.5, fixed now): <ovs> is legitimately empty whenever <id> has no
                    ;;*active* route to SSTOA at all (EMPTY_HOPPER's own output-values is
                    ;;[]) — the original `(at 0 (take -1 ovs))` crashed with an
                    ;;out-of-bounds error in that case instead of failing cleanly. A
                    ;;token with no route to SSTOA simply doesn't get its boost pumped this
                    ;;time (EOC, no burn) — not a corruption, not a lost swap, the rest of
                    ;;the transaction is unaffected. Adversarially proven (SWP|TX 032z5):
                    ;;reverted this fix, confirmed the exact "Array index out of bounds.
                    ;;Length (0), Index (0)" crash reproduces, restored. Phase 8: the same
                    ;;empty-<ovs> fallback now also covers an invalid bundle-supplied path
                    ;;(<is-valid-supplied>=false) — identical safe degrade, no new branch
                    ;;needed.
                    (if (= (length ovs) 0)
                        EOC
                        (let
                            (
                                (final-boost-output:decimal (at 0 (take -1 ovs)))
                                (ico:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPTF::C_Burn patron SWP|SC_NAME sstoa final-boost-output)
                                )
                            )
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [ico]
                                [(- (ref-ATS::URC_Index liquidindex) lqi) path-to-sstoa edges ovs amount]
                            )
                        )
                    )
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_Pumpdate (raw-liquid-pump-data:list)
        (require-capability (SECURE))
        (if (= (length raw-liquid-pump-data) 5)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                    (path-to-sstoa:[string] (at 1 raw-liquid-pump-data))
                    (edges:[string] (at 2 raw-liquid-pump-data))
                    (ovs:[decimal] (at 3 raw-liquid-pump-data))
                    (amount:decimal (at 4 raw-liquid-pump-data))
                    (le:integer (length edges))
                )
                (map
                    (lambda
                        (idx:integer)
                        (let
                            (
                                (first-id:string (at idx path-to-sstoa))
                                (second-id:string (at (+ idx 1) path-to-sstoa))
                                (hop:string (at idx edges))
                                (first-amount:decimal
                                    (if (= idx 0)
                                        amount
                                        (at (- idx 1) ovs)
                                    )
                                )
                                (second-amount:decimal (at idx ovs))
                                (f-id-hop-a:decimal (ref-SWP::UR_PoolTokenSupply hop first-id))
                                (s-id-hop-a:decimal (ref-SWP::UR_PoolTokenSupply hop second-id))
                            )
                            (ref-SWP::XE_UpdateSupply hop first-id (+ f-id-hop-a first-amount))
                            (ref-SWP::XE_UpdateSupply hop second-id (- s-id-hop-a second-amount))
                        )
                    )
                    (enumerate 0 (- le 1))
                )
            )
            true
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_UpdateOuroPrice
    (defun XI_STOA-PID|OPU (swpair:string stoa-pid:decimal)
        @doc "If <swpair> is primordial, <ouro-auto-price-via-swaps> is true, and \
            \ Ouro price moves more that 1 promile, update price"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-auto:bool (ref-DALOS::UR_OuroAutoPriceUpdate))
            )
            (if iz-auto
                (let
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (ouro-id:string (ref-DALOS::UR_OuroborosID))
                        (ouro-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                        (stored-ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                        (current-ouro-price:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                        (dev:decimal 0.001)
                        (min:decimal (floor (* stored-ouro-price (- 1.0 dev)) ouro-prec))
                        (max:decimal (floor (* stored-ouro-price (+ 1.0 dev)) ouro-prec))
                        (iz-update:bool
                            (if (or (< current-ouro-price min) (> current-ouro-price max))
                                true false
                            )
                        )
                    )
                    (if iz-update
                        (ref-DALOS::XB_UpdateOuroPrice current-ouro-price)
                        true
                    )
                )
                true
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_ToggleSwapCapability:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string toggle:bool)
        @doc "Executor: ENFORCED INDIRECTLY, downstream, and nothing here proves it: SPWU|C>TOGGLE-SWAP \
            \ enforces only the pool-worth floor and takes no account at all. The proof is \
            \ SWP::C_ToggleAddOrSwap, whose UEV_ExecutorIsOwnerKonto binds <executor> to \
            \ (UR_OwnerKonto swpair) and whose SWP|C>ADD-OR-SWAP enforces CAP_Owner on that \
            \ same pool -- its own @doc names itself the ONLY ownership check in this chain. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (with-capability (SPWU|C>TOGGLE-SWAP swpair toggle)
                ;;PROVISIONAL EXECUTOR SLOT CLEARED at this module's own turn (2026-09-22),
                ;;the twin of the one in SWPLC::C_ToggleAddLiquidity. 15_SWP's turn left
                ;;(ref-SWP::UR_OwnerKonto swpair) here: the right VALUE, re-derived rather than
                ;;attributed. SPWU|C>TOGGLE-SWAP above enforces only the pool-worth floor -- it
                ;;proves nothing about any account -- so until now nothing in either module
                ;;recorded WHO asked for the toggle. SWP::C_ToggleAddOrSwap's
                ;;UEV_ExecutorIsOwnerKonto rejects the pair if the named account is not the owner.
                (ref-SWP::C_ToggleAddOrSwap patron executor swpair toggle false)
            )
        )
    )
    (defun CC_SmartSwap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string input-id:string input-amount:decimal output-id:string slippage:decimal stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @doc "Executes a Smart Swap from <input-id> to <output-id> across multiple pools using BFS path tracing. \
            \ Each hop executes a full swap with fees (LP, special, boost via Option B). \
            \ When slippage != -1.0, slippage-bounds must be the pre-computed object from UDC_SpawnSmartSwapSlippageBounds. \
            \ When slippage == -1.0, pass a dummy object (e.g. UDC_Slippage 0.0 0 0.0). \
            \ #34 Phase 8: renamed from C_SmartSwap — this is the self-searching (BFS in-transaction) \
            \ variant, kept for comparison/fallback. The bundle-based, dirty-read-injected variant \
            \ takes the freed C_SmartSwap name. \
            \ #65L fix: the BFS path search (<h-obj>) is computed exactly ONCE here and \
            \ threaded through the defcap and XI_SmartSwapRouter, instead of each \
            \ independently re-running SWPI::URC_HopperActive's full-graph search. \
            \ \
            \ Executor: ENFORCED INDIRECTLY. No capability here proves it -- the swap caps take the \
            \ account only to EXPOSE it in their @event, and SWPU|X>SWAP validates the swap SHAPE. \
            \ The proof is the DEBIT: XI_Swap calls TFT::C_MultiTransfer with <executor> in the \
            \ executor slot, moving the input tokens OUT of it, which enforces \
            \ CAP_EnforceAccountOwnership once per leg via DPTF|C>MULTI-TRANSFER -> \
            \ XB_DebitTrueFungible -> DPTF|C>DEBIT. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                (h-obj:object{SwapperIssueV4.Hopper} (ref-SWPI::URC_HopperActive input-id output-id input-amount))
            )
            (if (!= slippage -1.0)
                (with-capability (SWPU|C>SMART-SWAP-WITH-SLIPPAGE executor input-id input-amount output-id slippage slippage-bounds h-obj)
                    (XI_SmartSwapRouter patron executor input-id input-amount output-id slippage stoa-pid slippage-bounds h-obj)
                )
                (with-capability (SWPU|C>SMART-SWAP-NO-SLIPPAGE executor input-id input-amount output-id slippage h-obj)
                    (XI_SmartSwapRouter patron executor input-id input-amount output-id slippage stoa-pid slippage-bounds h-obj)
                )
            )
        )
    )
    (defun C_SmartSwap:list
        (patron:string 
            executor:string input-id:string input-amount:decimal output-id:string slippage:decimal
            stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage} bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8 — the bundle-based, dirty-read-injected SmartSwap: performs \
            \ ZERO internal searching. <bundle> (SmartSwapPathBundle) is assembled \
            \ entirely client-side per the exhaustive-path-search HANDOFF doc's P3.7 \
            \ orchestration sequence — swap-route (A->B), boost-path (B->SSTOA) and \
            \ stoa-paths (each distinct pool's first-token->WSTOA) are all dirty-read \
            \ off-chain before this transaction is ever submitted. Built ALONGSIDE, not \
            \ replacing, CC_SmartSwap (the original self-searching variant) for direct \
            \ A/B gas comparison (P3.5.2) — same slippage/no-slippage split, same \
            \ IGNIS-billing shape at the Talos layer. \
            \ Returns [ico stoa-results] — a WIDER container, not a schema change to the \
            \ shared IgnisCollectorV3.OutputCumulator (P3.10, settled 2026-08-21): <ico> \
            \ carries the same [final-netto hops pools distinct-edges] output shape \
            \ CC_SmartSwap already does (for like-for-like comparison), <stoa-results> is \
            \ the P3.4 dumb-writer's precomputed [{pool, stoa-value}, ...] list — Talos \
            \ maps it straight into XE_UpdateStoaValue with no URC_PoolValue re-derivation \
            \ at all, for every pool this call actually priced. \
            \ Cache self-warming: after a real execution, XI_RegisterBundlePaths \
            \ registers whichever of <swap-route>/<boost-path>/<stoa-paths> are valid \
            \ and actually used this round — via SWPT::XE_RegisterPath (the proper \
            \ forward-module writer), never a caller-side grant of SWPT's own SECURE \
            \ cap directly (see XE_RegisterPath's own doc for why that would be unsafe — \
            \ confirmed against this codebase's own ATS audit findings before landing). \
            \ #65bL fix: <swap-route> registration is new — see SwapRoute's own doc for \
            \ why it's now safe to cache (Phase 5 dropped the live default from best-of-3 \
            \ to first-found, making the structural route amount-independent). \
            \ Runs INSIDE the with-capability block below via XI_SmartSwapAndRegister — \
            \ a granted capability's scope is its own dynamic extent, not the rest of \
            \ the transaction (confirmed the hard way: 'require-capability: not granted' \
            \ when this was first tried as a separate call after the with-capability \
            \ block had already returned). \
            \ \
            \ Executor: ENFORCED INDIRECTLY, exactly as its CC_SmartSwap twin. No capability here \
            \ proves it. The proof is the DEBIT inside XI_Swap -- TFT::C_MultiTransfer with \
            \ <executor> in the executor slot -- reached through XI_STOA-PID|Swap. Note this is an \
            \ INTERNAL hop, so _executorenforced's FORWARDED branch cannot see it: that branch \
            \ matches cross-module `ref-X::` hand-offs, which is correct, because a foreign module \
            \ is what would do the proving. An internal hop has to be traced by a human and \
            \ written down, which is what this paragraph is. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (if (!= slippage -1.0)
            (with-capability
                (SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-WITH-SLIPPAGE executor input-id input-amount output-id slippage slippage-bounds bundle)
                (XI_SmartSwapAndRegister patron executor input-id input-amount output-id slippage stoa-pid slippage-bounds bundle)
            )
            (with-capability
                (SWPU|C>SMART-SWAP-EXPLICIT-ROUTE-NO-SLIPPAGE executor input-id input-amount output-id slippage bundle)
                (XI_SmartSwapAndRegister patron executor input-id input-amount output-id slippage stoa-pid slippage-bounds bundle)
            )
        )
    )
    (defun C_Swap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage:decimal stoa-pid:decimal slippage-bounds:object{SwapperUsageV3.Slippage})
        @doc "Execute swap. When slippage != -1.0, slippage-bounds must be the pre-computed slippage object from quote time (e.g. UDC_SlippageObject); when slippage == -1.0, pass a dummy object (e.g. UDC_Slippage 0.0 0 0.0). \
            \ \
            \ Executor: ENFORCED INDIRECTLY. No capability here proves it -- the swap caps take the \
            \ account only to EXPOSE it in their @event, and SWPU|X>SWAP validates the swap SHAPE. \
            \ The proof is the DEBIT: XI_Swap calls TFT::C_MultiTransfer with <executor> in the \
            \ executor slot, moving the input tokens OUT of it, which enforces \
            \ CAP_EnforceAccountOwnership once per leg via DPTF|C>MULTI-TRANSFER -> \
            \ XB_DebitTrueFungible -> DPTF|C>DEBIT. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
                (pp:string (ref-SWP::UR_PrimordialPool))
                (l:integer (length input-ids))
                (s-or-m:bool (if (= l 1) true false))
            )
            (if (= swpair pp)
                (if s-or-m
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|OPU|C>SINGL-SWAP-WITH-SLIPPAGE executor swpair dsid slippage slippage-bounds)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage stoa-pid slippage-bounds)
                        )
                        (with-capability (SWPU|OPU|C>SINGL-SWAP-NO-SLIPPAGE executor swpair dsid slippage)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage stoa-pid slippage-bounds)
                        )
                    )
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|OPU|C>MULTI-SWAP-WITH-SLIPPAGE executor swpair dsid slippage slippage-bounds)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage stoa-pid slippage-bounds)
                        )
                        (with-capability (SWPU|OPU|C>MULTI-SWAP-NO-SLIPPAGE executor swpair dsid slippage)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage stoa-pid slippage-bounds)
                        )
                    )
                )
                (if s-or-m
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|C>SINGL-SWAP-WITH-SLIPPAGE executor swpair dsid slippage slippage-bounds)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage -1.0 slippage-bounds)
                        )
                        (with-capability (SWPU|C>SINGL-SWAP-NO-SLIPPAGE executor swpair dsid slippage)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage -1.0 slippage-bounds)
                        )
                    )
                    (if (!= slippage -1.0)
                        (with-capability (SWPU|C>MULTI-SWAP-WITH-SLIPPAGE executor swpair dsid slippage slippage-bounds)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage -1.0 slippage-bounds)
                        )
                        (with-capability (SWPU|C>MULTI-SWAP-NO-SLIPPAGE executor swpair dsid slippage)
                            (XI_STOA-PID|Swap patron executor swpair dsid slippage -1.0 slippage-bounds)
                        )
                    )
                )
            )
        )
    )

)

;; --- tables for 19_SWPU.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperMtxV4
    @doc "Exposes SWP MultiStep (via defpact) Functions. \
        \ V3: issue pool caps use SwapperV4.PoolTokens (bumped with SwapperV4 row types)."

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
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_IssueStablePool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_IssueWeightedPool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    (defun C_IssueStandardPool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool))
    ;;
    (defun C_AddStandardLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddIcedLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddGlacialLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddFrozenLiquidity (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun C_AddSleepingLiquidity (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))

)
;;
;;HISTORICAL NOTE (owner, 2026-08-17, during SWP audit #C9): this module's whole reason to exist is
;;gas-limit-driven multi-step (defpact) issuance/liquidity flows, split across steps to stay under a
;;150k-gas-per-transaction ceiling that applied when this was written. StoaChain's actual live limit is
;;~2,000,000 gas per transaction (see OuronetInformational/pact5/SEMANTICS.md's gas table) — comfortably
;;enough headroom for even a 7-pool-token issuance to complete in a SINGLE transaction today. The
;;multi-step mechanism is therefore no longer technically required for gas reasons; it's kept live for
;;historical continuity (real pools — e.g. pool7 in the SWP audit's own REPL fixtures — were already
;;issued through it) and as a worked defpact/multi-step example elsewhere in the codebase. Any new
;;single-issuance flow does NOT need to be split into steps purely for gas headroom; that constraint no
;;longer applies. (This context is exactly what let #C9 slip through undetected for as long as it did:
;;SWPI::C_Issue, the single-tx path, remembered to call XE_AddLPTracker; this defpact path's own XE_Issue
;;call — added later, per the owner — never got the same follow-up wired in. Fixed by folding the
;;registration into XE_Issue itself, in 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact, so every issuance path
;;gets it "for free" and this class of per-caller-remembers-it gap can't recur here.)
(module MTX-SWP GOV
    @doc "MTX-SWP (SwapperMtxV4) provides multi-step (defpact) versions of SWP pool issuance \
        \ and liquidity addition, originally to split work under an old per-transaction gas \
        \ ceiling (now kept for continuity/example, no longer strictly required). Its \
        \ defpacts stage validation, IGNIS/STOA collection, LP minting, and LP \
        \ transfer/freeze/sleep across steps with rollback, delegating writes to SWPL and \
        \ SWPI::XE_IssueWrite."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperMtxV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_MTX-SWP                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|MTX-SWP_ADMIN)))
    (defcap GOV|MTX-SWP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_MTX-SWP)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "MTX-SWP Ownership not verified"
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
    (defcap P|MTX-SWP|CALLER ()
        @doc "This module's identity as an inter-module caller: the guard registered into other \
        \ modules' IMPs by <P|A_Define> is `(create-capability-guard (P|MTX-SWP|CALLER))`, so \
        \ `P|UEV_IMC` over there passes exactly when THIS is in scope over here. \
        \ \
        \ IT IS ACQUIRED DIRECTLY AT EVERY BILLING SITE IN THIS MODULE, and that is not \
        \ redundancy. The IGNIS collectors became `P|UEV_IMC`-protected on 2026-09-20. On the \
        \ ordinary path nothing has to do this: Talos acquires <P|TALOS-SUMMONER> at the top, \
        \ `P|UEV_IMC` is depth-invariant, and every nested core call inherits it. A DEFPACT \
        \ STEP INHERITS NOTHING -- it arrives in its own transaction through <continue-pact> \
        \ with an empty capability scope -- and this module is almost entirely defpacts that \
        \ bill. Hence the explicit acquire, scoped to the collect call and nothing wider."
        true
    )
    (defcap P|MTX-SWP|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|MTX-SWP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|MTX-SWP|REMOTE-GOV))
        (compose-capability (P|MTX-SWP|CALLER))
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
        (with-capability (GOV|MTX-SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|MTX-SWP_ADMIN)
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
        (with-capability (GOV|MTX-SWP_ADMIN)
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
        (with-capability (GOV|MTX-SWP_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                ;;#36M/M5 fix: MTX-SWP now calls SWPI::XE_IssueWrite (P|UEV_IMC-gated)
                ;;directly from MTX|C_Issue's Step 3, so MTX-SWP must register itself
                ;;as an approved IMC caller on SWPI too — same as every other module
                ;;it already calls into below.
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|MTX-SWP|CALLER)))
            )
            (ref-P|VST::P|A_Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;
    ;;The INITIATION slice of a multi-step add-liquidity. Owner design, restated 2026-09-14:
    ;;step 0 takes this much for opening the pact, and the step that actually SUCCEEDS takes
    ;;the remainder of the op's lp-churn deterrent. The TOTAL is unchanged and still equals
    ;;the single-tx twin in 18_SWPLC.pact, so no door is cheaper than the other -- what
    ;;changes is WHEN the money moves, so a pact killed by an altered pool state costs its
    ;;owner this slice instead of the whole deterrent. See UC_AddLiquidityChurnRemainder.
    (defconst LQ|INITIATION-FEE:decimal                  100.0)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap MTX-SWP|C>ISSUE-S-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-W-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-P-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|S>ADD-LQ (stoa-pid:decimal)
        @doc "Records the STOA-PID the MTX was initiated with"
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap MTX-SWP|C>ISSUE (p:bool)
        (compose-capability (P|DT))
        (if p
            (compose-capability (GOV|MTX-SWP_ADMIN))
            true
        )
    )
    ;;
    (defcap MTX-SWP|C>ADD-STANDARD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-ICED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-GLACIAL-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-FROZEN-LQ 
        (swpair:string frozen-dptf:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddFrozenLiquidity swpair frozen-dptf)
            (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>ADD-SLEEPING-LQ 
        (account:string swpair:string sleeping-dpof:string nonce:integer ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
            )
            (ref-SWPLC::UEV_AddSleepingLiquidity account swpair sleeping-dpof nonce)
            (compose-capability (MTX-SWP|C-ADD-DORMANT-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-DORMANT-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
            )
            (ref-SWPLC::UEV_AddDormantLiquidity swpair)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-CHILLED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddChilledLiquidity swpair ld)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>X-ADD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddLiquidity swpair ld)
            (compose-capability (P|DT))
        )
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_PoolState:object{SwapperLiquidityV2.PoolState} (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::UDC_PoolState
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWPL::UDC_PoolFees swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                (ref-SWP::UR_Weigths swpair)
                ;;
                (ref-SWP::URC_LpCapacity swpair)
                (ref-SWP::UR_SpecialFeeTargets swpair)
                (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_IssueStablePool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-S-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                amp p
            )
        )
    )
    (defun C_IssueWeightedPool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-W-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                weights
                -1.0 p
            )
        )
    )
    (defun C_IssueStandardPool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-P-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                -1.0 p
            )
        )
    )
    ;;
    (defun C_AddStandardLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts true true stoa-pid)
        )
    )
    (defun C_AddIcedLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts false true stoa-pid)
        )
    )
    (defun C_AddGlacialLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts false false stoa-pid)
        )
    )
    (defun C_AddFrozenLiquidity
        (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddFrozenLiquidity patron executor swpair frozen-dptf input-amount stoa-pid)
        )
    )
    (defun C_AddSleepingLiquidity
        (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddSleepingLiquidity patron executor swpair sleeping-dpof nonce stoa-pid)
        )
    )
    (defun UC_AddLiquidityChurnKey:string (asymmetric-collection:bool gaseous-collection:bool)
        @doc "The IGNIS price key MTX|C_AddLiquidity must bill, chosen by the SAME two collection \
            \ flags that decide which variant it is running -- (t,t) Standard, (f,t) Iced, \
            \ (f,f) Glacial, matching the C_Add*Liquidity wrappers above and SWPLC's twins. \
            \ ADDED 2026-09-14 with the lp-churn repair below; see the step-0 comment."
        (cond
            ((and asymmetric-collection gaseous-collection) "SWP|C_AddStandardLiquidity")
            ((and (not asymmetric-collection) gaseous-collection) "SWP|C_AddIcedLiquidity")
            "SWP|C_AddGlacialLiquidity"
        )
    )
    (defun URCi_AddLiquidityInitiation:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "The INITIATION slice every multi-step add-liquidity pays in step 0, before \
            \ anything is validated. Deliberately small: step 0 only QUOTES, and a quote \
            \ that a stranger's ordinary trade can invalidate must not cost the quoter the \
            \ whole deterrent. The remainder is taken by URCi_AddLiquidityChurnRemainder in \
            \ the step that succeeds, so the TOTAL is unchanged."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
            )
        )
    )
    (defun URCi_AddLiquidityChurnRemainder:object{IgnisCollectorV3.OutputCumulator}
        (op-key:string)
        @doc "The rest of OP-KEY's lp-churn deterrent, after the step-0 initiation slice. \
            \ Charged in the EXECUTION step, i.e. only once the pool state has been checked \
            \ and the liquidity is actually being added. LQ|INITIATION-FEE + this = the full \
            \ UC_IgnisPrice the single-tx twin in 18_SWPLC.pact bills in one go; the split is \
            \ a timing change, not a discount. Pinned by modules/SWP.repl <<SWPX-LQSPLIT>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (- (ref-IGNIS::UC_IgnisPrice op-key "lp-churn") LQ|INITIATION-FEE)
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
            )
        )
    )
    (defpact MTX|C_AddLiquidity 
        (
            patron:string account:string swpair:string input-amounts:[decimal] 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
        ;;Adds Standard,Iced or Glacial Liquidity, as an MTX in 3 steps
        ;;
        ;;Step 0 Computation and Validation
        (step
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair input-amounts)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD 
                            account swpair ld asymmetric-collection gaseous-collection stoa-pid
                        )
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad}
                )
                ;;LP-CHURN REPAIR (2026-09-14). This charged a flat literal 100.0 while the
                ;;single-tx twin for the SAME operation charged UC_IgnisPrice "..." "lp-churn"
                ;;= 1051.0. Both are live P|UEV_IMC-gated Talos clients -- TS01-CP reaches here,
                ;;TS01-C3 reaches SWPLC -- so a liquidity provider could DECLINE the churn
                ;;deterrent simply by choosing the other door, at a tenth of the price, on the
                ;;route the gas station subsidises. A deterrent that can be declined is not one.
                ;;The earlier repair that put every add-liquidity op onto UC_IgnisPrice landed in
                ;;18_SWPLC.pact only, and nothing compared the two modules afterwards: each route
                ;;was measured against ITS OWN preview and both agreed with themselves.
                ;;Measured, exploit-first, at RedTeam/[RT-A]_Economics.repl <<RT-A-001>>.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
                (format "MTX LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                        (secondary:decimal (at "secondary-lp" clad))
                        (sum-lp:decimal (+ primary secondary))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    ;;The lp-churn deterrent's REMAINDER is taken HERE, not in step 0, and only
                    ;;after the pool-state check above has passed. Step 0 takes the small
                    ;;LQ|INITIATION-FEE; the two sum to exactly what 18_SWPLC.pact's single-tx
                    ;;twin bills in one transaction. Before 2026-09-14 the whole deterrent was
                    ;;taken in step 0 -- ahead of the very check that decides whether the
                    ;;operation may happen at all -- so any stranger's ordinary swap moved the
                    ;;pool, failed this enforce, and destroyed the quoter's entire fee with no
                    ;;refund. Measured, exploit-first, at RedTeam/[RT-F]_Griefing.repl <<RT-F-001>>.
                    (with-capability (P|MTX-SWP|CALLER)
                        (ref-IGNIS::XE_CollectIgnis patron
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [(URCi_AddLiquidityChurnRemainder
                                    (UC_AddLiquidityChurnKey asymmetric-collection gaseous-collection))
                                 (at "perfect-ignis-fee" (at "clad-op" clad))]
                                []
                            )
                        )
                    )
                    (if (and asymmetric-collection gaseous-collection)
                        (with-capability (MTX-SWP|C>ADD-STANDARD-LQ swpair ld)
                            ;;<asymmetric-collection=true> <gaseous-collection=true>
                            (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                            )
                        )
                        (if gaseous-collection
                            (with-capability (MTX-SWP|C>ADD-ICED-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=true>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                                )
                            )
                            (with-capability (MTX-SWP|C>ADD-GLACIAL-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=false>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                                )
                            )
                        )
                    )
                    (yield
                        {"primary-lp-amount"    : primary
                        ,"secondary-lp-amount"  : secondary}
                    )
                    (format "Succesfully Added Liquidity on {} and minted {} LP; 2|3" [swpair sum-lp])
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; Stepped rolled back; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"primary-lp-amount"    := primary
                ,"secondary-lp-amount"  := secondary
                }
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-TFT:module{TrueFungibleTransferV2} TFT)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico1:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= primary 0.0)
                                    (ref-TFT::C_Transfer patron SWP|SC_NAME account lp-id primary true)
                                    EOC
                                )
                            )
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (if (not asymmetric-collection)
                                    (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id secondary)
                                    EOC
                                )
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [ico1 ico2] 
                                    []
                                ) 
                            )
                        )
                        (if (not asymmetric-collection)
                            (format "Succesfully moved {} Native LP and {} Frozen LP to client; 3|3" [primary secondary])
                            (format "Succesfully moved {} Native LP to client; 2|2" [primary])
                        )
                    )
                )
            )
        )
    )
    (defpact MTX|C_AddFrozenLiquidity
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                    (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid)
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad}
                )
                ;;LP-CHURN REPAIR (2026-09-14) -- same defect as MTX|C_AddLiquidity's step 0
                ;;above, in this variant. The single-tx twin bills UC_IgnisPrice
                ;;"SWP|C_AddFrozenLiquidity" "lp-churn"; this billed a flat literal.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
                (format "MTX Frozen LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (secondary:decimal (at "secondary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                                ;;
                                ;;Move F|DPTF to vst-sc and burn it
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-TFT::C_Transfer patron account vst-sc frozen-dptf input-amount true)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPTF::C_Burn patron vst-sc frozen-dptf input-amount)
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                            )
                            ;;lp-churn REMAINDER taken here, after validation -- see the twin
                            ;;comment in MTX|C_AddLiquidity's execution step.
                            (with-capability (P|MTX-SWP|CALLER)
                                (ref-IGNIS::XE_CollectIgnis patron 
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [(URCi_AddLiquidityChurnRemainder "SWP|C_AddFrozenLiquidity")
                                         ico1 ico2 ico3] []
                                    )
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair false false stoa-pid ld clad)
                            (yield
                                {"secondary-lp-amount"  : secondary}
                            )
                            (format "Succesfully Added Frozen Liquidity on {} and minted {} LP; Stepped rolled back; 2|3" [swpair secondary])
                        )
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"secondary-lp-amount"  := secondary}
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id secondary)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron ico)
                        )
                        (format "Succesfuly frozen {} LP to Client; 3|3" [secondary])
                    )
                )
            )
        )
    )
    (defpact MTX|C_AddSleepingLiquidity
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                    (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                    (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD account swpair ld true true stoa-pid)
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad
                    ,"ba"           : batch-amount}
                )
                ;;LP-CHURN REPAIR (2026-09-14) -- same defect as MTX|C_AddLiquidity's step 0
                ;;above, in this variant. The single-tx twin bills UC_IgnisPrice
                ;;"SWP|C_AddSleepingLiquidity" "lp-churn"; this billed a flat literal.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
                (format "MTX Sleeping LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                ,"ba"           := batch-amount
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-SLEEPING-LQ account swpair sleeping-dpof nonce ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                                ;;
                                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                ;;
                                (nonce-md:[object] (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))
                                (release-date:time (at "release-date" (at 0 nonce-md)))
                                (present-time:time (at "block-time" (chain-data)))
                                (dt:integer (floor (diff-time release-date present-time)))
                                ;;
                                ;;Move Z|DPOF to vst-sc and burn it
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPOF::C_Transfer patron account vst-sc sleeping-dpof [nonce] true)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPOF::C_Burn patron vst-sc sleeping-dpof nonce batch-amount)
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                                ;;
                                ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                                (ico4:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-TFT::C_Transfer patron account vst-sc ignis-id (at "total-ignis-tax-needed" clad) true)
                                )
                            )
                            ;;lp-churn REMAINDER taken here, after validation -- see the twin
                            ;;comment in MTX|C_AddLiquidity's execution step.
                            (with-capability (P|MTX-SWP|CALLER)
                                (ref-IGNIS::XE_CollectIgnis patron 
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [(URCi_AddLiquidityChurnRemainder "SWP|C_AddSleepingLiquidity")
                                         ico1 ico2 ico3 ico4] []
                                    )
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair true true stoa-pid ld clad)
                            (yield
                                {"primary-lp-amount"    : primary
                                ,"time-diff"            : dt}
                            )
                            (format "Succesfully Added Sleeping Liquidity on {} and minted {} LP; 2|3" [swpair primary])
                        )
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; Stepped rolled back; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"primary-lp-amount"    := primary
                ,"time-diff"            := dt}
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Sleep patron SWP|SC_NAME account lp-id primary dt)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron ico)
                        )
                        (format "Succesfuly put to sleep {} LP to Client; 3|3" [primary])
                    )
                )
            )
        )
    )
    (defpact MTX|C_Issue
        (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        ;;Issues an SWPair, as MultiStep Transaction, to be used in case <C_Issue> cant fit inside one TX.
        ;;
        ;;Step 1 Validation
        (step
            (let
                (
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                )
                (require-capability (SECURE))
                ;;M11 FIX (2026-09-17) — AUTHORISATION BEFORE THE MONEY, per the 2026-09-14 ruling.
                ;;This conditional admin gate used to live ONLY in step 3's <MTX-SWP|C>ISSUE>, which
                ;;runs AFTER step 2 has irreversibly collected IGNIS + STOA. Measured by execution:
                ;;a p=true issuance committed 2,919.77 IGNIS + 459.0 STOA in step 2 and was then
                ;;refused in step 3 with "MTX-SWP Ownership not verified" -- no refund, no cancel,
                ;;and rolling back costs a further 53.00 IGNIS. The SINGLE-TRANSACTION twin refuses
                ;;the identical operation for ZERO, because <SWPI|C>ISSUE> hoisted this same branch
                ;;above <UEV_Issue> during that sweep. Same operation, two live Talos doors, and
                ;;only one charged you for a refusal -- selected by <p>, an undocumented raw bool.
                ;;
                ;;THE WHOLE CONDITIONAL FORM IS HOISTED, not the bare acquire: only a PERMISSIONED
                ;;issuance needs the admin key, so unwrapping the branch would convert a conditional
                ;;gate into an unconditional one and lock out every ordinary pool issuance. That is
                ;;the exact mistake CLAUDE.md records a scripted reorder making during the sweep.
                ;;<with-capability> rather than <compose-capability> because this is a defpact step,
                ;;not a defcap body; acquiring <GOV|MTX-SWP_ADMIN> runs its enforce-one and nothing
                ;;else, and step 3 re-acquires it unchanged.
                (if p
                    (with-capability (GOV|MTX-SWP_ADMIN) true)
                    true
                )
                (ref-SWPI::UEV_Issue account pool-tokens fee-lp weights amp p)
            )
        )
        ;;Step 2 Ignis Collection and STOA Fuel Processing
        (step-with-rollback
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    ;;GS-04 REPAIR (2026-09-14). This step used to build its own cumulator inline
                    ;;while INFO_SWP|Issue*Pool previewed it through SWPI::URCi_Issue -- a reader
                    ;;tuned to the SINGLE-TX SWPI::C_Issue. Four preview legs totalling 6158 against
                    ;;this step's ONE leg of 5506: an over-quote of 652, and a leg-count mismatch
                    ;;that matters on its own because the cumulator discounts per leg. Both sides now
                    ;;read SWPI::URCi_IssuePool, so there is one source and no second place to drift.
                    (sum-ignis:decimal (ref-SWPI::URC_IssuePoolIgnis))
                    ;;
                    (stoa-costs:decimal 
                        (+ 
                            (ref-DALOS::UR_UsagePrice "dptf")
                            (ref-DALOS::UR_UsagePrice "swp")
                        )
                    )
                )
                ;;Collect IGNIS and STOA for Issuance.
                ;;
                ;;THE <with-capability> IS LORD-BEARING, NOT DECORATION. The IGNIS collectors
                ;;became `P|UEV_IMC`-protected on 2026-09-20, and that gate passes only when one
                ;;of IGNIS' registered capability guards is IN SCOPE. For the ordinary path that
                ;;is automatic -- Talos acquires <P|TALOS-SUMMONER> at the top and `P|UEV_IMC` is
                ;;depth-invariant, so every nested core call inherits it. A DEFPACT STEP INHERITS
                ;;NOTHING: step 2 arrives in its own transaction via <continue-pact>, with an
                ;;empty capability scope, so the guard this module registered in IGNIS' IMP
                ;;(<P|MTX-SWP|CALLER>) has to be acquired here or billing dies with "None of the
                ;;guards passed". Step 3 already does the same thing for SWPI::XE_IssueWrite,
                ;;via <MTX-SWP|C>ISSUE> -> <P|DT> -> <P|MTX-SWP|CALLER>; this is that, scoped to
                ;;the two calls that need it rather than borrowing the governance composite.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (ref-SWPI::URCi_IssuePool account pool-tokens))
                    (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                )
                (let
                    (
                        (ref-ORBR:module{OuroborosV2} OUROBOROS)
                        (auto-fuel:bool (ref-DALOS::UR_AutoFuel))
                    )
                    (if auto-fuel
                        (do
                            (with-capability (P|DT)
                                (ref-ORBR::C_Fuel patron)
                            )
                            (format "{} IGNIS and {} STOA collected (raising SSTOA Index) succesfully; 2|3" [sum-ignis stoa-costs])
                        )
                        (format "{} IGNIS collected, with {} STOA collected (in reserves) succesfully; 2|3" [sum-ignis stoa-costs])
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                ;;Same reason as the step body above: the rollback runs in its own transaction
                ;;with an empty capability scope, and it bills.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            100.0 SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
                    )
                )
                (format "Insufficient IGNIS and STOA for Collection; Stepped rolled back{} 2|3" [";"])
            )
        )
        ;;Step 3 Issuance
        ;;#36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in
        ;;SWPI::XE_IssueWrite — the shared forward-module entrypoint SWPI::C_Issue also
        ;;calls, instead of this step independently reimplementing it. Billing already
        ;;happened in Step 2, above, so only swpair/token-lp (indices 0/1) are needed
        ;;here — the sub-cumulators XE_IssueWrite also returns are for C_Issue's own
        ;;aggregation, not relevant to this already-billed path.
        (step
            (with-capability (MTX-SWP|C>ISSUE p)
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (write-result:list (ref-SWPI::XE_IssueWrite patron account pool-tokens fee-lp weights amp p))
                        (swpair:string (at 0 write-result))
                        (token-lp:string (at 1 write-result))
                    )
                    (format "Swpair with ID {} and LP Token {} ID created succesfully" [swpair token-lp])
                )
            )
        )
    )

)

;; --- tables for 20_MTX-SWP.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

