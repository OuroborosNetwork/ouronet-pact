;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 6 of 24
;; This is STEP 6 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-5 must have run first, including the init steps between deploys.
;; 3 source file(s), 231,586 gas measured in the REPL gas model, 220,327 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact
;;
;; TOTAL: 3 interface(s), 3 module(s), 14 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;      interface  OuroborosV2
;;      module     OUROBOROS
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact
;;      interface  SwapTracerV3
;;      module     SWPT
;;      table      P|T
;;      table      P|MT
;;      table      SWPT|Graph
;;      table      SWPT|PathCache
;;      table      SWPT|TopologyVersion
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact
;;      interface  SwapperV4
;;      module     SWP
;;      table      P|T
;;      table      P|MT
;;      table      SWP|Properties
;;      table      SWP|Asymmetry
;;      table      SWP|Pairs
;;      table      SWP|Pools
;;      table      SWP|LP
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact ===============
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuroborosV2
    @doc "Exposes Functions related to the OUROBOROS Module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|ORBR|SC_STOA-NAME ())
    (defun GOV|ORBR|GUARD ())

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
    (defun URC_ProjectedStoaLiquindex:[decimal] ())
    (defun URCv_Compress:[decimal] (ignis-amount:decimal))
    (defun URCv_Sublimate:decimal (ouro-amount:decimal))
    (defun URCi_Compress:object{IgnisCollectorV3.OutputCumulator} (client:string ignis-amount:decimal))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_Sublimate:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun URCi_SublimateV2:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun URCi_WithdrawFees:object{IgnisCollectorV3.OutputCumulator} (id:string target:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_Exchange ())
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XB_Compress:object{IgnisCollectorV3.OutputCumulator} (patron:string client:string ignis-amount:decimal))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun C_Compress:object{IgnisCollectorV3.OutputCumulator} (client:string ignis-amount:decimal))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (patron:string ))
    (defun C_Sublimate:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    ;;#23H fix: C_SublimateV2 was already live/actively-used (TS01-C2's ORBR|C_SublimateV2,
    ;;TS01-C3's Firestarter path) but missing from its own interface. Cheaper alternative to
    ;;C_Sublimate (freeze+C_WipeSlim+unfreeze instead of transfer+burn) - added here, no
    ;;behavioral change, the module already implements this exact signature.
    (defun C_SublimateV2:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun C_WithdrawFees:object{IgnisCollectorV3.OutputCumulator} (id:string target:string))

)
;;
(module OUROBOROS GOV
    @doc "OUROBOROS — the OURO token / exchange core at the top of the Stage 1 stack, \
        \ implementing OuroborosV2. It compresses IGNIS gas into OURO and sublimates OURO \
        \ back out (C_Compress, C_Sublimate/C_SublimateV2), fuels the liquid Stoa index, \
        \ projects the Stoa liquindex and withdraws fees (C_Fuel, C_WithdrawFees). It acts \
        \ as the protocol's gas-to-token sink and treasury exchange."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements OuroborosV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ORBR                               (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ORBR                               (keyset-ref-guard ORBR|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ORBR_ADMIN)))
    (defcap GOV|ORBR_ADMIN ()
        (enforce-one
            "ORBR Admin not satisfed"
            [
                (enforce-guard GOV|MD_ORBR)
                (enforce-guard GOV|SC_ORBR)
            ]
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
    (defun GOV|OuroborosKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|OuroborosKey)
        )
    )
    (defun GOV|ORBR|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|OUROBOROS|SC_NAME)
        )
    )
    (defun GOV|ORBR|SC_STOA-NAME ()                     (create-principal (GOV|ORBR|GUARD)))
    (defun GOV|ORBR|GUARD ()                            (create-capability-guard (ORBR|NATIVE-AUTOMATIC)))

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
    (defcap P|ORBR|CALLER ()
        true
    )
    (defcap P|DALOS|REMOTE-GOV ()
        @doc "Dalos Remote Governor Capability"
        true
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
        (with-capability (GOV|ORBR_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ORBR_ADMIN)
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
        (with-capability (GOV|ORBR_ADMIN)
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
        (with-capability (GOV|ORBR_ADMIN)
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
                (mg:guard (create-capability-guard (P|ORBR|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "ORBR|RemoteDalosGov"
                (create-capability-guard (P|DALOS|REMOTE-GOV))
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
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst ORBR|SC_KEY                               (GOV|OuroborosKey))
    (defconst ORBR|SC_NAME                              (GOV|ORBR|SC_NAME))
    (defconst ORBR|SC_STOA-NAME                         (GOV|ORBR|SC_STOA-NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap ORBR|GOV ()
        @doc "Governor Capability for the Ouroboros Smart DALOS Account"
        true
    )
    (defcap ORBR|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of OUROBOROS Smart Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap LIQUIDFUEL|C>ADMIN_FUEL ()
        @event
        (compose-capability (ORBR|GOV))
        (compose-capability (ORBR|NATIVE-AUTOMATIC))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap IGNIS|C>SUBLIMATE (client:string target:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (compose-capability (IGNIS|C>CONVERT client))
            (compose-capability (P|DALOS|REMOTE-GOV))
        )
    )
    (defcap IGNIS|C>COMPRESS (client:string)
        @event
        (compose-capability (IGNIS|C>CONVERT client))
    )
    (defcap IGNIS|C>CONVERT(client:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountType client false)
            (UEV_Exchange)
            (compose-capability (ORBR|GOV))
            (compose-capability (P|ORBR|CALLER))
        )
    )
    (defcap IGNIS|XB>COMPRESS (client:string)
        @doc "SC-account-tolerant compress authorization for INTERNAL module callers (registered OUROBOROS IMC — \
            \ e.g. AQP-FVT normalizing an IGNIS royalty leg to OURO before disposal). Same conversion as \
            \ IGNIS|C>COMPRESS but WITHOUT the standard-account restriction; the caller-module IMC gate (P|UEV_IMC in \
            \ XB_Compress) is the trust boundary."
        @event
        (compose-capability (IGNIS|XB>CONVERT client))
    )
    (defcap IGNIS|XB>CONVERT (client:string)
        (UEV_Exchange)
        (compose-capability (ORBR|GOV))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap OUROBOROS|C>WITHDRAW (id:string target:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-DPTF::CAP_Owner id)
            (compose-capability (ORBR|GOV))
            (compose-capability (P|ORBR|CALLER))
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
    (defun URC_ProjectedStoaLiquindex:[decimal] ()
        @doc "Computes the Projected STOA Liquindex, considering STOA amount in reserves ready to be used as Fuel"
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (orb-sc ORBR|SC_NAME)
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
                (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                (liquid-idx:string (at 0 w-stoa-as-rt))
                (present-index-value:decimal (ref-ATS::URC_Index liquid-idx))

                (p:integer (ref-ATS::UR_IndexDecimals liquid-idx))
                (rs:decimal (ref-ATS::URC_ResidentSum liquid-idx))
                (projected-sum:decimal (+ rs present-stoa-balance))
                (rbt-supply:decimal (ref-ATS::URC_PairRBTSupply liquid-idx))
                (projected-index-value:decimal
                    (if
                        (= rbt-supply 0.0)
                        -1.0
                        (floor (/ projected-sum rbt-supply) p)
                    )
                )
            )
            [present-index-value projected-index-value present-stoa-balance]
        )
    )
    (defun URCv_Compress:[decimal] (ignis-amount:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (enforce (= (floor ignis-amount 0) ignis-amount) "Only whole Units of GAS(Ignis) can be compressed")
            (enforce (>= ignis-amount 1.00) "Only amounts greater than or equal to 1.0 can be used to compress gas")
            (ref-DPTF::UEV_Amount (ref-DALOS::UR_IgnisID) ignis-amount)
            (let
                (
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                    (ouro-price-used:decimal (if (<= ouro-price 1.00) 1.00 ouro-price))
                    (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                    (raw-ouro-amount:decimal (floor (/ ignis-amount (* ouro-price-used 100.0)) ouro-precision))
                    (promile-split:[decimal] (ref-U|ATS::UC_PromilleSplit 15.0 raw-ouro-amount ouro-precision))
                    (ouro-remainder-amount:decimal (floor (at 0 promile-split) ouro-precision))
                    (ouro-fee-amount:decimal (at 1 promile-split))
                )
                [ouro-remainder-amount ouro-fee-amount]
            )
        )
    )
    (defun URCv_Sublimate:decimal (ouro-amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;NOTE: the constant is 0.99, not the 1.0 the message advertises. Pinned AS WRITTEN
            ;;in REPL/modules/OUROBOROS.repl <<ORBR-G1>> (0.99 accepted, 0.98 refused) so the
            ;;test states what the code does rather than what the text claims. Left as-is: the
            ;;tolerance is deliberate (it absorbs a floor() at the caller), but the message is
            ;;misleading and should say 0.99 the next time this interface is bumped.
            (enforce (>= ouro-amount 0.99) "Only amounts greater than or equal to 1.0 can be used to make gas!")
            (ref-DPTF::UEV_Amount (ref-DALOS::UR_OuroborosID) ouro-amount)
            (let
                (
                    (ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                    (ouro-price-used:decimal (if (<= ouro-price 1.00) 1.00 ouro-price))
                    (ignis-id:string (ref-DALOS::UR_IgnisID))
                )
                (enforce (!= ignis-id BAR) "Gas Token isnt properly set")
                (let
                    (
                        (ignis-precision:integer (ref-DPTF::UR_Decimals ignis-id))
                        (raw-ignis-amount-per-unit:decimal (floor (* ouro-price-used 100.0) ignis-precision))
                        (raw-ignis-amount:decimal (floor (* raw-ignis-amount-per-unit ouro-amount) ignis-precision))
                        (output-ignis-amount:decimal (floor raw-ignis-amount 0))
                    )
                    output-ignis-amount
                )
            )
        )
    )
    ;;
    (defun URCi_Compress:object{IgnisCollectorV3.OutputCumulator}
        (client:string ignis-amount:decimal)
        @doc "Cost preview for C_Compress (and cost-identical XB_Compress): client->ORBR IGNIS \
            \ transfer + IGNIS burn + OURO mint + ORBR->client OURO transfer. Output == \
            \ [ouro-remainder-amount], re-derived purely."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-remainder-amount:decimal (at 0 (URCv_Compress ignis-amount)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer ignis-id client ORBR|SC_NAME ignis-amount)
                    (ref-DPTF::URCi_Burn ignis-id ORBR|SC_NAME)
                    (ref-DPTF::URCi_Mint ouro-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ouro-id ORBR|SC_NAME client ouro-remainder-amount)
                ]
                [ouro-remainder-amount]
            )
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "Cost preview for C_Fuel: when wrapped-STOA exists and the ORBR STOA balance is \
            \ positive, the wrap + ATSU fuel legs; otherwise EOC (no-op). Re-derived purely."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATSU:module{AutostakeUsageV2} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                (orb-sc ORBR|SC_NAME)
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
            )
            (if (and (!= w-stoa BAR) (> present-stoa-balance 0.0))
                (let
                    (
                        (liquid-idx:string (at 0 (ref-DPTF::UR_RewardToken w-stoa)))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-LIQUID::URCi_WrapStoa orb-sc present-stoa-balance)
                            (ref-ATSU::URCi_Fuel orb-sc liquid-idx w-stoa present-stoa-balance)
                        ]
                        []
                    )
                )
                EOC
            )
        )
    )
    (defun URCi_Sublimate:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_Sublimate: client->ORBR OURO transfer + OURO burn + IGNIS mint \
            \ + ORBR->target IGNIS transfer. Output == [ignis-amount], re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-remainder-amount:decimal (at 0 (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision)))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer ouro-id client ORBR|SC_NAME ouro-amount)
                    (ref-DPTF::URCi_Burn ouro-id ORBR|SC_NAME)
                    (ref-DPTF::URCi_Mint ignis-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ignis-id ORBR|SC_NAME target ignis-amount)
                ]
                [ignis-amount]
            )
        )
    )
    (defun URCi_SublimateV2:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_SublimateV2: (conditional) freeze client + wipe-slim the OURO \
            \ + unfreeze + IGNIS mint + ORBR->target IGNIS transfer. Output == [ignis-amount], \
            \ re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-remainder-amount:decimal (at 0 (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision)))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id client))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (not frozen-state)
                        (ref-DPTF::URCi_ToggleFreezeAccount ouro-id)
                        EOC
                    )
                    (ref-DPTF::URCi_WipeSlim ouro-id)
                    (ref-DPTF::URCi_ToggleFreezeAccount ouro-id)
                    (ref-DPTF::URCi_Mint ignis-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ignis-id ORBR|SC_NAME target ignis-amount)
                ]
                [ignis-amount]
            )
        )
    )
    (defun URCi_WithdrawFees:object{IgnisCollectorV3.OutputCumulator}
        (id:string target:string)
        @doc "Cost preview for C_WithdrawFees: the base token-issue IGNIS price + the ORBR-> \
            \ target transfer of the accrued fee supply, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (withdraw-amount:decimal (ref-DPTF::UR_AccountSupply id ORBR|SC_NAME))
                (price:decimal (ref-IGNIS::UC_IgnisDeter "fee-withdraw"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                    (ref-TFT::URCi_Transfer id ORBR|SC_NAME target withdraw-amount)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Exchange ()
        ;;FIXED 2026-09-12: the two BAR checks are enforced in an OUTER let, above the role reads.
        ;;They used to sit BELOW a single binding group that already did
        ;;`(o-rm (UR_AccountRoleMint ouro-id orb-sc))`, and a `let` is EAGER -- so when ouro-id was
        ;;still BAR that read raised `DPTF ID | does not exist` before either enforce was consulted.
        ;;Setting OURO alone did not help: the gas-id read then aborted the same way. Both written
        ;;sentences were unreachable on the only chain state where they mean anything -- the boot
        ;;window, before the two ids are configured.
        ;;Splitting the group is enough: the id reads depend on nothing, the ROLE reads depend on the
        ;;ids, so the enforces go between them. Pinned by
        ;;REPL/Stage_01/[4.0]_Sovereign-Executor.repl <<TX4.0-CONFIG>>.
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (gas-id:string (ref-DALOS::UR_IgnisID))
            )
            (enforce (!= ouro-id BAR) "Ouroboros is not set")
            (enforce (!= gas-id BAR) "Ignis is not set")
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (orb-sc ORBR|SC_NAME)

                (o-rm:bool (ref-DPTF::UR_AccountRoleMint ouro-id orb-sc))
                (o-rb:bool (ref-DPTF::UR_AccountRoleBurn ouro-id orb-sc))
                (t1:bool (and o-rm o-rb))
                (g-rm:bool (ref-DPTF::UR_AccountRoleMint gas-id orb-sc))
                (g-rb:bool (ref-DPTF::UR_AccountRoleBurn gas-id orb-sc))
                (t2:bool (and g-rm g-rb))
                (t3:bool (and t1 t2))
            )
            ;;Checks Exchange Permission (the two BAR checks now live in the outer let above)
            ;;t3 = t1 AND t2, over four reads of the shape (UR_AccountRoleMint <id> orb-sc). Each of
            ;;those ends in
            ;;    (or <the account's role flag> (DALOS::UR_AutonomicRoles account))
            ;;and `UR_AutonomicRoles` is a PURE fold over a hardcoded list of smart-contract account
            ;;names -- not a table read. `ORBR|SC_NAME` resolves to `DALOS::GOV|OUROBOROS|SC_NAME`,
            ;;which IS one of the entries. So the right-hand side is a compile-time `true`, the `or`
            ;;short-circuits, and t1/t2/t3 hold for every possible chain state. Writing the role flags
            ;;with env-module-admin does not help -- they are ORed away.
            ;;Both facts are asserted in REPL/modules/OUROBOROS.repl <<ORB-G1>>, so this annotation
            ;;cannot rot silently: if the autonomic list ever drops OUROBOROS, that test goes red and
            ;;this guard becomes live. Kept as a fail-closed backstop for exactly that day.
            ;;UNREACHABLE BY CONSTRUCTION -- unlike the two BAR guards above (which were MUTE and were
            ;;repaired by splitting the binding group), no STATE can reach this one at all.
            (enforce t3 "Permission invalid for Ignis Exchange")
        ))
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_Compress:object{IgnisCollectorV3.OutputCumulator}
        (patron:string client:string ignis-amount:decimal)
        @doc "SC-account-tolerant IGNIS→OURO compress for INTERNAL module callers (registered OUROBOROS IMC). Same \
            \ conversion + fee as C_Compress (98.5% efficiency), but authorized by IGNIS|XB>COMPRESS which OMITS the \
            \ standard-account restriction — so a SMART account (e.g. AQP|SC_NAME custody) may normalize an IGNIS \
            \ royalty leg to OURO before disposal. P|UEV_IMC gates the caller module. The <client>'s IGNIS→ORBR \
            \ transfer is authorized by whatever cap the caller holds for <client> (e.g. P|FVT|REMOTE-GOV)."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-to-ouro:[decimal] (URCv_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
            )
            (with-capability (IGNIS|XB>COMPRESS client)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        (ref-TFT::C_Transfer patron client ORBR|SC_NAME ignis-id ignis-amount true)
                        (ref-DPTF::C_Burn patron ORBR|SC_NAME ignis-id ignis-amount)
                        (ref-DPTF::C_Mint patron ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        (ref-TFT::C_Transfer patron ORBR|SC_NAME client ouro-id ouro-remainder-amount true)
                    ]
                    [ouro-remainder-amount]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_Compress:object{IgnisCollectorV3.OutputCumulator}
        (client:string ignis-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-to-ouro:[decimal] (URCv_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
                ;;#61L fix: removed the dead `total-ouro` binding (bound, never referenced
                ;;anywhere in the function body - only `ouro-remainder-amount`, the first
                ;;element, is actually minted/transferred). No functional change.
            )
            (with-capability (IGNIS|C>COMPRESS client)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends GAS(Ignis) <ignis-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer client client ORBR|SC_NAME ignis-id ignis-amount true)
                        ;;02]Ouroboros burns GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ignis-id ignis-amount)
                        ;;03]Ouroboros mints OURO <ouro-remainder-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        ;;04]Ouroboros transfers OURO <ouro-remainder-amount> to <client>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME client ouro-id ouro-remainder-amount true)
                    ]
                    [ouro-remainder-amount]
                )
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (patron:string )
        (P|UEV_IMC)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATSU:module{AutostakeUsageV2} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                (orb-sc ORBR|SC_NAME)
                (orb-stoa ORBR|SC_STOA-NAME)
                (lq-stoa (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
            )
            (if (!= w-stoa BAR)
                (let
                    (
                        (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                        (liquid-idx:string (at 0 w-stoa-as-rt))
                    )
                    (if (> present-stoa-balance 0.0)
                        (with-capability (LIQUIDFUEL|C>ADMIN_FUEL)
                            (install-capability (ref-coin::TRANSFER orb-stoa lq-stoa present-stoa-balance))
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-LIQUID::C_WrapStoa patron orb-sc present-stoa-balance)
                                    (ref-ATSU::C_Fuel patron orb-sc liquid-idx w-stoa present-stoa-balance)
                                ]
                                []
                            )
                        )
                        EOC
                    )
                )
                EOC
            )
        )
    )
    (defun C_Sublimate:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
            )
            (with-capability (IGNIS|C>SUBLIMATE client target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends OURO <ouro-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer client client ORBR|SC_NAME ouro-id ouro-amount true)
                        ;;02]Ouroboros burns OURO <ouro-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ouro-id ouro-amount)
                        ;;03]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;04]Ouroboros transfers GAS(Ignis) <ignis-amount> to <target>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME target ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_SublimateV2:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id client))
            )
            (with-capability (IGNIS|C>SUBLIMATE client target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Freeze Client Account for Ouro if not already frozen
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount client (ref-DPTF::UR_Konto ouro-id) client ouro-id true)
                            EOC
                        )
                        ;;02]Partialy wipe the required OURO
                        (ref-DPTF::C_WipeSlim client (ref-DPTF::UR_Konto ouro-id) client ouro-id ouro-amount)
                        ;;03]Unfreeze Client Account
                        (ref-DPTF::C_ToggleFreezeAccount client (ref-DPTF::UR_Konto ouro-id) client ouro-id false)
                        ;;04]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;05]Ouroboros transfers GAS(Ignis) <ignis-amount> to <target>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME target ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_WithdrawFees:object{IgnisCollectorV3.OutputCumulator}
        (id:string target:string)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (withdraw-amount:decimal (ref-DPTF::UR_AccountSupply id ORBR|SC_NAME))
                (price:decimal (ref-IGNIS::UC_IgnisDeter "fee-withdraw"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (enforce (> withdraw-amount 0.0) (format "There are no {} fees to be withdrawn from {}" [id ORBR|SC_NAME]))
            (with-capability (OUROBOROS|C>WITHDRAW id target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;00]Compose base withdraw IGNIS Price
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                        ;;01]Patron withdraws Fees from Ouroboros Smart DALOS Account to a target Normal Ouronet Account
                        (ref-TFT::C_Transfer target ORBR|SC_NAME target id withdraw-amount true)
                    ]
                    []
                )
            )
        )
    )

)

;; --- tables for 13_OUROBOROS.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface SwapTracerV3
    @doc "Exposes Tracer Functions, needed to compute Paths between Tokens existing on \
        \ Liquidity Pools. \
        \ \
        \ #21H redesign (V1 -> V2): V1 stored adjacency keyed by PRINCIPAL identity — \
        \ every swpair got filed under one Edges entry per principal it touched, at \
        \ trace time. That broke the moment a principal was removed or replaced: every \
        \ entry filed under the retired principal became permanently unreachable to \
        \ every normal read path, silently, system-wide, for every token ever pooled \
        \ against it — with no resync mechanism anywhere. It also duplicated storage \
        \ (a swpair touching 2 principals got recorded twice) and grew read cost with \
        \ every read via repeated concatenate-then-dedup over all principal buckets. \
        \ \
        \ V2 stores plain token-to-token adjacency instead — principal identity plays \
        \ no role anywhere in this module's storage, keys, or reads. Principal changes \
        \ (SWP::A_UpdatePrincipal or its future replacement-only successor) never touch \
        \ this module at all; there is nothing here that could go stale."

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
    (defschema NeighbourEdge
        token:string
        swpairs:[string]
    )
    (defschema PathCacheRow
        @doc "#34 Phase 6/7: a cached route between two tokens, keyed by <token-a>|\
            \ <token-b> in whichever direction was first registered — no \
            \ canonicalization, readers check both directions and reverse on a miss in \
            \ one of them. Stores only the route STRUCTURE, never a computed value — \
            \ every real use re-derives the current value from live reserves, so a \
            \ stale-but-structurally-valid entry can only ever point at the wrong-but- \
            \ still-real edges, which per-edge validation on every read catches and \
            \ falls back from. Same <nodes>/<edges> shape as <URC_ComputeGraphPath>'s \
            \ own return (both endpoints included in <nodes>). Declared on this \
            \ interface, not the module, since interface function signatures below \
            \ reference it and interfaces load before module schemas exist. \
            \ #65bL Phase 1 fix: added <topology-version>, the global topology-version \
            \ counter's value at the moment this entry was written — WITHOUT it, \
            \ 'first-write-wins, never overwritten' meant a cached entry could never be \
            \ refreshed even after new pools made a better route possible; a reader \
            \ now compares this against the live counter (<UR_TopologyVersion>) to tell \
            \ a genuinely-current entry from a stale one, and a stale entry can be \
            \ overwritten instead of permanently blocking any future improvement."
        nodes:[string]
        edges:[string]
        topology-version:integer
    )
    (defschema TopologyVersionRow
        @doc "#65bL Phase 1: single counter, bumped once per genuinely new token-pair \
            \ connection or genuinely new parallel pool (see <XI_UpdatePair>'s own \
            \ <did-change> logic) — never bumped on an idempotent replay (e.g. \
            \ <A_RebuildGraph> re-running over already-registered pools). A coarse \
            \ generation number, not an exact change-count: a single multi-token pool \
            \ issuance bumps it once per ordered token-pair it introduces, not once per \
            \ pool. That's fine — its only job is 'has anything changed since a given \
            \ read', not precise counting."
        version:integer
    )
    (defschema RawGraphNode
        @doc "#65bL Phase 2: one token's raw, unfiltered neighbour data — exactly what \
            \ <UR_Graph> returns for it, paired with its own name. The point of this \
            \ shape is to let a caller read a whole node universe's raw rows ONCE \
            \ (<URC_FetchRawGraph>) and reuse them across multiple best-of-K attempts \
            \ via a purely in-memory filter (<UC_MakeGraphFromRaw>) instead of each \
            \ attempt independently re-reading and rebuilding the whole graph."
        node:string
        neighbours:[object{NeighbourEdge}]
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
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV2.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Graph:[object{NeighbourEdge}] (token:string))
    (defun URC_TokenNeighbours:[string] (token:string))
    (defun URC_Edges:[string] (t1:string t2:string))
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string]))
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string]))
    ;;#45L fix: renamed from URC_AllGraphPaths — misleading, doesn't return all
    ;;paths (one shortest BFS chain per reached node, not every simple path).
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string]))
    (defun URC_MakeGraph:[object{BreadthFirstSearchV2.GraphNode}] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 2: raw-fetch/pure-filter split, used by URC_ComputeAlternateRoutes/
    ;;per transaction and reuse it across every best-of-K attempt, instead of each
    ;;attempt calling URC_MakeGraph (a fresh read per node, every time).
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string]))
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#65bL Phase 7: one layer deeper than Phase 2's raw-fetch/pure-filter split — a
    ;;caller making MULTIPLE Hopper queries against the SAME <swpairs> universe in one
    ;;transaction (the STOA-repricing loop: one query per distinct pool touched, each a
    ;;different source token but the same WSTOA destination) was still calling
    ;;UC_MakeGraphFromRaw (a linear-scan-per-node graph BUILD) fresh on every query,
    ;;even though that build's output is byte-identical every time for the same
    ;;<raw-graph>/<swpairs> universe (UC_MakeGraphFromRaw is input/output-independent,
    ;;same as UC_MakeGraphNodes underneath it — Phase 4's own finding). These let a
    ;;caller build the [GraphNode] graph ONCE (UC_MakeGraphFromRaw) and reuse it across
    ;;every query — only the BFS traversal itself (genuinely <input>-dependent) still
    ;;runs per query.
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV2.GraphNode}])
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
    )
    ;;#34M/M2 fix: additive — finds up to 3 edge-disjoint candidate routes instead
    ;;of just the single first-found one; see the defun's own @doc for the full
    ;;rationale.
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 4: URC_ComputeAlternateRoutes, sourcing its graph via an
    ;;multiple unrelated best-of-K searches in one transaction (the STOA-repricing
    ;;loop, one search per distinct pool) share ONE raw-graph fetch across all of them.
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#34 Phase 11 (the original #34 ask): generalizes URC_ComputeAlternateRoutes' fixed
    ;;3-attempt cap into a real parameterized search — see the defun's own @doc for the
    ;;full mechanics (early-exit, depth-cap filter, outer hard stop).
    (defun URC_ComputeAllRoutes:[[string]] (input:string output:string swpairs:[string] max-attempts:integer))
    ;;#34 Phase 7: dirty-read path-cache core functions — exists-only (structural) side.
    ;;The active-required wrapper (adds SWP::UR_CanSwap per edge) lives in SWPI instead,
    ;;same reason URC_EdgesActive's own whitelist check couldn't live here either — SWPT
    ;;deploys before SWP, can't reach it.
    (defun URC_ReadPathCache:object{PathCacheRow} (token-a:string token-b:string))
    ;;#65bL Phase 1: current global topology-version counter — one point read.
    (defun UR_TopologyVersion:integer ())
    ;;#65bL Phase 1: URC_ReadPathCache, additionally collapsing a STALE entry (its
    ;;topology-version behind the current one) to the same [BAR] miss sentinel a
    ;;genuinely-absent entry already returns — callers never need to know the
    ;;difference between "never cached" and "cached but outdated."
    (defun URC_ReadPathCacheFresh:object{PathCacheRow} (token-a:string token-b:string))
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string))
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))
    ;;#34 Phase 8: forward-module entrypoint for XI_RegisterPath — mirrors XE_UpdateGraph
    ;;exactly (P|UEV_IMC gate + internal SECURE composition). Cross-module callers (SWPU)
    ;;must go through this, never grant SWPT.SECURE directly themselves — SECURE's body
    ;;is unconditionally true, so a caller-side `(with-capability (SWPT.SECURE) ...)`
    ;;would grant it to literally anyone, not just legitimate Ouronet modules (confirmed
    ;;against this exact class of issue in this codebase's own ATS audit findings).
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))
    (defun XE_UpdateGraph (swpair:string))
    ;;{5.7}  User [A/C]

)
;;
(module SWPT GOV
    @doc "SWPT (SwapTracerV3) is the swap-graph tracer for the SWP liquidity-pool family. It \
        \ stores plain token-to-token adjacency (SWPT|Graph), a first-write path cache \
        \ (SWPT|PathCache), and a global topology-version counter, and exposes BFS-based \
        \ routing helpers (URC_ComputeGraphPath, alternate/exhaustive route discovery, \
        \ raw-graph fetch/filter variants) plus XE_/XI_ entrypoints to register paths and \
        \ update the graph. It computes multi-hop swap routes between tokens without holding \
        \ value data, so every real swap re-derives outputs from live reserves."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapTracerV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPT                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPT_ADMIN)))
    (defcap GOV|SWPT_ADMIN ()                           (enforce-guard GOV|MD_SWPT))
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPT|CALLER ()
        true
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
        (with-capability (GOV|SWPT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPT_ADMIN)
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
        (with-capability (GOV|SWPT_ADMIN)
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
        (with-capability (GOV|SWPT_ADMIN)
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
                (mg:guard (create-capability-guard (P|SWPT|CALLER)))
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
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;#65bL Phase 1: singleton key for SWPT|TopologyVersion — same pattern as this
    ;;codebase's other singleton-row tables (e.g. policy's P|I).
    (defconst TOPOLOGY_VERSION_KEY                      "topology-version")
    ;;#34 Phase 11: P0.4's depth cap (7 tokens / 6 hops, "the sexy number 7") — same
    ;;value URC_ValidatePathStructure already enforces on submitted bundles, reused
    ;;here as a post-discovery filter in URC_ComputeAllRoutes (see that function's own
    ;;doc for why post-filter, not baked into U|BFS's traversal itself).
    (defconst MAX_ROUTE_NODES                           7)
    ;;#34 Phase 11: P0.2's genuine outer hard stop on max-attempts, independent of
    ;;whatever a caller requests — placeholder value, not researched/considered,
    ;;owner may override. URC_ComputeAllRoutes clamps to this regardless of the
    ;;caller's own max-attempts argument.
    (defconst MAX_ATTEMPTS_HARD_CAP                     50000)
    ;;{3.2}  schemas
    ;;
    (defschema SWPT|GraphSchema
        neighbours:[object{SwapTracerV3.NeighbourEdge}]
    )
    ;;{3.3}  tables
    (deftable SWPT|Graph:{SWPT|GraphSchema})                    ;;Key = <token>
    (deftable SWPT|PathCache:{SwapTracerV3.PathCacheRow})       ;;Key = <token-a>|<token-b> (insertion-order, reversed-lookup at read time)
    ;;#65bL Phase 1: own table per this codebase's storage-pattern rule (never
    ;;co-locate a row read for other reasons — segregated so only the path that
    ;;needs the counter pays to deserialize it).
    (deftable SWPT|TopologyVersion:{SwapTracerV3.TopologyVersionRow})  ;;Key = TOPOLOGY_VERSION_KEY (singleton)

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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_FindNeighbourIndex:[integer] (neighbours:[object{SwapTracerV3.NeighbourEdge}] token:string)
        @doc "Returns [idx] of the entry in <neighbours> whose token field matches \
            \ <token>, or [] if no such entry exists yet."
        (let
            (
                (l:integer (length neighbours))
            )
            (if (= l 0)
                []
                (fold
                    (lambda
                        (acc:[integer] idx:integer)
                        (if (!= acc [])
                            acc
                            (if (= (at "token" (at idx neighbours)) token) [idx] [])
                        )
                    )
                    []
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun UC_ExcludeEdges:[string] (swpairs:[string] exclude:[string])
        @doc "Removes every entry of <exclude> from <swpairs> — pure list-difference. \
            \ Used to build a reduced routing universe for #34M/M2's best-of-K \
            \ alternate-route search: each retry excludes the edges of every route \
            \ already found, forcing a genuinely different one instead of \
            \ rediscovering the same route."
        (filter (lambda (s:string) (not (contains s exclude))) swpairs)
    )
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV2.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: pure (zero table reads) equivalent of <URC_MakeGraph> — \
            \ builds the identical active-filtered [GraphNode] shape, but derives \
            \ every node's links from an ALREADY-FETCHED <raw-graph> \
            \ (<URC_FetchRawGraph>) instead of re-reading SWPT|Graph per node, and \
            \ also skips the double-read <URC_MakeGraph> itself has (one read via \
            \ <URC_TokenNeighbours> to list neighbour tokens, another via \
            \ <URC_EdgesActive>/<URC_Edges> per neighbour to re-derive the exact \
            \ same swpairs already sitting in that first read's result) — the \
            \ per-neighbour <swpairs> field is already right there on each \
            \ <NeighbourEdge>, filtered directly, no re-read or re-derivation \
            \ needed either way. <raw-graph> must cover every node <swpairs> could \
            \ ever produce here — always true when it was fetched against a \
            \ swpairs universe that's a SUPERSET of this one (e.g. the original, \
            \ unshrunk universe a best-of-K search started from, reused unchanged \
            \ across every attempt's own shrinking exclusion universe)."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV2.GraphNode}] idx:integer)
                        (let*
                            (
                                (this-node:string (at idx nodes))
                                ;;#65bL Phase 3 investigated a binary-search replacement for
                                ;;this scan (see URC_FetchRawGraph's own doc) — measured as a
                                ;;real regression on the actual integrated call, not shipped.
                                ;;Linear filter stays, unchanged from Phase 2.
                                (raw-matches:[object{RawGraphNode}]
                                    (filter (lambda (rg:object{RawGraphNode}) (= (at "node" rg) this-node)) raw-graph)
                                )
                                (neighbours:[object{NeighbourEdge}]
                                    (if (= 0 (length raw-matches)) [] (at "neighbours" (at 0 raw-matches)))
                                )
                            )
                            (ref-U|LST::UC_AppL
                                acc
                                {
                                    "node": this-node,
                                    "links":
                                        (map (at "token")
                                            (filter
                                                (lambda (ne:object{NeighbourEdge})
                                                    (!=
                                                        (filter
                                                            (lambda (sp:string) (contains sp swpairs))
                                                            (at "swpairs" ne)
                                                        )
                                                        []
                                                    )
                                                )
                                                neighbours
                                            )
                                        )
                                }
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Graph:[object{SwapTracerV3.NeighbourEdge}] (token:string)
        (with-default-read SWPT|Graph token
            {"neighbours" : []}
            {"neighbours" := n}
            n
        )
    )
    (defun UR_PathCacheRaw:object{SwapTracerV3.PathCacheRow} (key:string)
        @doc "#34 Phase 7: raw keyed read against SWPT|PathCache, [BAR]-sentinel default \
            \ for a missing row. Internal — callers go through <URC_ReadPathCache> for the \
            \ reversed-lookup logic, never this directly. \
            \ #65bL Phase 1: default <topology-version> is -1 — always older than any \
            \ real counter value (starts at 0, only ever increases), so a missing row \
            \ is automatically treated as stale by any freshness check, same as a \
            \ genuinely-absent entry always was structurally."
        (with-default-read SWPT|PathCache key
            {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
            {"nodes" := n, "edges" := e, "topology-version" := tv}
            {"nodes" : n, "edges" : e, "topology-version" : tv}
        )
    )
    (defun UR_TopologyVersion:integer ()
        @doc "#65bL Phase 1: current global topology-version counter — one point read, \
            \ default 0 for the pre-first-bump state."
        (with-default-read SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version" : 0}
            {"version" := v}
            v
        )
    )
    (defun URC_TokenNeighbours:[string] (token:string)
        (map (at "token") (UR_Graph token))
    )
    (defun URC_Edges:[string] (t1:string t2:string)
        @doc "All swpairs directly connecting <t1> and <t2> — regardless of can-swap \
            \ state. Direct keyed lookup against <t1>'s own row; O(deg(t1)), never a \
            \ table scan."
        (let*
            (
                (neighbours:[object{SwapTracerV3.NeighbourEdge}] (UR_Graph t1))
                (idx:[integer] (UC_FindNeighbourIndex neighbours t2))
            )
            (if (= (length idx) 0)
                []
                (at "swpairs" (at (at 0 idx) neighbours))
            )
        )
    )
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string])
        @doc "Same as <URC_Edges>, but the result is restricted to swpairs also \
            \ present in <whitelist> (e.g. <SWP::URC_ActiveSwpairs>) — so a disabled \
            \ parallel pool between the same token pair is never offered as an edge \
            \ candidate to <SWPI::URC_BestEdgeFiltered>. #19H fix, carried over \
            \ unchanged by the #21H storage redesign."
        (filter (lambda (swpair:string) (contains swpair whitelist)) (URC_Edges t1 t2))
    )
    (defun URCx_ShortestChainToTarget:[[string]] (input:string output:string swpairs:[string])
        @doc "#65hL: <URC_ShortestChainPerNode>, but stops doing real BFS-expansion \
            \ work once <output> is reached, via <U|BFS::UC_BFSTargeted> — see that \
            \ function's own doc for the full rationale and correctness argument \
            \ (a node's shortest chain is fixed the first time BFS visits it, so \
            \ stopping early never changes <output>'s own chain, only skips \
            \ recording chains for nodes the caller's post-filter would have \
            \ discarded anyway). Internal only, used exclusively by \
            \ <URC_ComputeGraphPath> — <URC_ShortestChainPerNode> itself is \
            \ unchanged, still available for any caller genuinely wanting chains to \
            \ every reachable node, not just one target."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string])
        @doc "Computes the path between an <input> and <output> using BFS via \
        \ <URC_ShortestChainPerNode> from a passed down list of existing <swpairs>. \
        \ #20H fix: returns the clean [BAR] sentinel — never a bare out-of-bounds \
        \ <at> crash — whenever no chain reaches <output>, including the case of a \
        \ genuinely disconnected pair once <swpairs> has been narrowed upstream \
        \ (e.g. to active-only pools, #19H). \
        \ #65hL fix: sources its chains via <URCx_ShortestChainToTarget> instead of \
        \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic \
        \ below, unchanged, just fed from a BFS that stops once <output> is \
        \ actually found instead of exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]] (URCx_ShortestChainToTarget input output swpairs))

            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    ;;#20H fix: guard against fp coming back empty (no chain
                    ;;reached output — e.g. a genuinely disconnected pair after
                    ;;active-only filtering) instead of a bare out-of-bounds `at`.
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string])
        @doc "#45L fix: renamed from URC_AllGraphPaths — the old name claimed 'all paths' \
            \ but this runs a single BFS traversal from <input> and keeps exactly one \
            \ shortest chain per node BFS reaches, not every simple path through the \
            \ graph (that's <URC_ComputeAllRoutes>, a different function entirely, added \
            \ in #34 Phase 11). <output> is accepted for signature symmetry with its only \
            \ caller (<URC_ComputeGraphPath>, which post-filters this result down to \
            \ chains actually ending at <output>) — it plays no role in the BFS itself, \
            \ which explores every reachable node from <input> regardless of <output>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_RouteEdges:[string] (nodes:[string] swpairs:[string])
        @doc "For a <nodes> path (as returned by <URC_ComputeGraphPath>), returns the \
            \ union of every swpair actually usable to traverse it within <swpairs>'s \
            \ universe — one <URC_EdgesActive> lookup per hop. Used to build the \
            \ exclusion set for #34M/M2's best-of-K route comparison."
        (if (or (= nodes [BAR]) (< (length nodes) 2))
            []
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (+ acc (URC_EdgesActive (at idx nodes) (at (+ idx 1) nodes) swpairs))
                )
                []
                (enumerate 0 (- (length nodes) 2))
            )
        )
    )
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string])
        @doc "#34M/M2 fix: <URC_ComputeGraphPath> alone only ever returns the single \
            \ first-discovered route — BFS's global once-per-node visited marking \
            \ means an equally valid alternate route (e.g. a diamond A->{B,C}->D \
            \ graph) is silently lost, and nothing ever compared candidate routes by \
            \ value anyway. This finds up to 3 edge-disjoint candidate routes by \
            \ re-running <URC_ComputeGraphPath> with each previously-found route's \
            \ edges excluded from the universe, forcing genuinely different routes \
            \ rather than the same route with a different parallel pool (that choice \
            \ is already optimal per-hop via <URC_BestEdgeFiltered>/<URC_BestEdgeOf>'s \
            \ own argmax, so re-exploring it would be wasted work). \
            \ Fixed cap of 3 attempts — Pact has no dynamic-length/convergence loops, \
            \ so the count must be a number decided in advance, not a runtime \
            \ condition; measured sufficient against this codebase's actual pool \
            \ topology (see the SWP audit's adversarial REPL proof for #34M/M2). \
            \ Returns only the routes genuinely found (drops [BAR] no-route results), \
            \ so the result can have 0-3 entries; the caller picks the best by value. \
            \ #65bL Phase 4 fix: now a thin wrapper — fetches the raw graph for this \
            \ call's own node universe, then delegates to \
            \ <URC_ComputeAlternateRoutesFromRaw>. A caller who's already fetched a \
            \ raw graph covering this <swpairs> universe (e.g. the STOA-repricing \
            \ loop, sharing one fetch across many unrelated calls) should call that \
            \ function directly instead, to skip this self-fetch."
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (full-nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
                (raw-graph:[object{RawGraphNode}] (URC_FetchRawGraph full-nodes))
            )
            (URC_ComputeAlternateRoutesFromRaw input output swpairs raw-graph)
        )
    )
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2/4 fix: <URC_ComputeAlternateRoutes>'s real logic, \
            \ parameterized on an ALREADY-FETCHED <raw-graph> instead of fetching its \
            \ own — see <URC_ComputeAlternateRoutes>'s own doc for the full best-of-3 \
            \ rationale (unchanged here) and <URCx_HopperFromRaw>'s doc for why one \
            \ fetch can safely serve many different (input,output) queries against \
            \ the same <swpairs> universe (<UC_MakeGraphNodes> is input/output- \
            \ independent by construction). An exhausted-universe guard (empty \
            \ <swpairsN>) short-circuits to [BAR] instead of calling \
            \ <URC_ComputeGraphPathFromRaw> — that function's own downstream \
            \ graph-building (M3, a separate tracked finding) crashes rather than \
            \ cleanly returning no-route on an empty list, and this is the first \
            \ caller able to legitimately produce one (a fully-excluded, single-pool \
            \ universe after route1/route2 already claimed it)."
        (let*
            (
                (route1:[string]
                    (if (= swpairs []) [BAR] (URC_ComputeGraphPathFromRaw input output swpairs raw-graph))
                )
                (swpairs2:[string]
                    (if (= route1 [BAR])
                        swpairs
                        (UC_ExcludeEdges swpairs (URC_RouteEdges route1 swpairs))
                    )
                )
                (route2:[string]
                    (if (or (= route1 [BAR]) (= swpairs2 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs2 raw-graph)
                    )
                )
                (swpairs3:[string]
                    (if (= route2 [BAR])
                        swpairs2
                        (UC_ExcludeEdges swpairs2 (URC_RouteEdges route2 swpairs2))
                    )
                )
                (route3:[string]
                    (if (or (= route2 [BAR]) (= swpairs3 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs3 raw-graph)
                    )
                )
            )
            (filter (lambda (r:[string]) (!= r [BAR])) [route1 route2 route3])
        )
    )
    (defun URC_ComputeAllRoutes:[[string]]
        (input:string output:string swpairs:[string] max-attempts:integer)
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not the fixed best-of-3 approximation URC_ComputeAlternateRoutes settled \
            \ for. Generalizes that function's hardcoded 3-attempt let* chain into a \
            \ real fold over up to <max-attempts> attempts, same edge-exclusion-per-\
            \ found-route mechanism (URC_RouteEdges + UC_ExcludeEdges), same \
            \ early-exit-once-empty short-circuit already proven correct in that \
            \ function. Meant to be called via off-chain dirty read only (P3 — this is \
            \ what fills a SmartSwapPathBundle's swap-route component before \
            \ submission), never on the paid execution path; the whole point of the \
            \ #34/#34M redesign is to remove exactly this kind of search from paid \
            \ transactions. \
            \ P0.2's max-attempts escalation (try 1000, then 2000, then 3000... flat \
            \ +1000 steps, no doubling) is a CALLER-side retry pattern — this function \
            \ takes a fixed <max-attempts> and does exactly that many attempts (or \
            \ fewer, via early-exit), it does not escalate itself. A caller who gets \
            \ back exactly <max-attempts> routes with no natural exhaustion should \
            \ retry with a larger <max-attempts>; fewer than requested means the \
            \ search is genuinely exhausted (every route already found). \
            \ P0.2's outer hard stop (MAX_ATTEMPTS_HARD_CAP) is enforced here \
            \ regardless of what the caller requests — a caller cannot force an \
            \ unbounded search by passing an enormous <max-attempts>. \
            \ P0.4's depth cap (MAX_ROUTE_NODES, 7 tokens / 6 hops) is enforced as a \
            \ POST-DISCOVERY filter here, not baked into <U|BFS>'s own traversal — a \
            \ deliberate, documented deviation from P0.4's stated preference \
            \ ('ideally baked into the BFS/graph-walk itself... rather than only as a \
            \ post-discovery filter, wasteful'). Reasoning: baking a depth bound into \
            \ <U|BFS> would mean modifying a SHARED lower-layer utility module with \
            \ callers beyond this one feature, a broader and riskier change than this \
            \ phase's scope justifies; the 'wasteful — pay to explore and discard' \
            \ downside the preference is guarding against does not actually apply here, \
            \ since this function is dirty-read-only (free off-chain compute, never \
            \ paid gas) — the efficiency concern the baked-in preference exists for is \
            \ moot in this function's real deployment context. An over-cap route still \
            \ has its edges excluded from the remaining search universe before the next \
            \ attempt (without this, the deterministic BFS would just rediscover the \
            \ exact same over-cap route every remaining attempt, wasting the whole \
            \ budget making zero progress) — only whether it's ADDED to the returned \
            \ results is filtered. \
            \ Reuses the already-shipped URCx_HopperForNodes/UC_BestHopper unchanged \
            \ for picking the best candidate by actual computed output value (P1.8's \
            \ requirement) — that value-computation logic lives in SWPI (16_SWPI.pact), \
            \ not here; this function only discovers node-path candidates, same \
            \ division of labor URC_ComputeAlternateRoutes already established."
        (let
            (
                (capped-attempts:integer (if (> max-attempts MAX_ATTEMPTS_HARD_CAP) MAX_ATTEMPTS_HARD_CAP max-attempts))
            )
            (if (or (= swpairs []) (<= capped-attempts 0))
                []
                (at 0
                    (fold
                        (lambda
                            (acc:list idx:integer)
                            ;;acc = [routes-found:[[string]] remaining-universe:[string] stopped:bool]
                            (if (at 2 acc)
                                acc
                                (let*
                                    (
                                        (remaining:[string] (at 1 acc))
                                        (route:[string]
                                            (if (= remaining [])
                                                [BAR]
                                                (URC_ComputeGraphPath input output remaining)
                                            )
                                        )
                                    )
                                    (if (= route [BAR])
                                        ;;Genuinely exhausted — no route findable in the
                                        ;;remaining universe. Stop; every further attempt
                                        ;;would find the identical nothing.
                                        [(at 0 acc) remaining true]
                                        (let*
                                            (
                                                (route-edges:[string] (URC_RouteEdges route remaining))
                                                (new-remaining:[string] (UC_ExcludeEdges remaining route-edges))
                                                (within-depth-cap:bool (<= (length route) MAX_ROUTE_NODES))
                                                (new-routes:[[string]]
                                                    (if within-depth-cap
                                                        (+ (at 0 acc) [route])
                                                        (at 0 acc)
                                                    )
                                                )
                                            )
                                            [new-routes new-remaining false]
                                        )
                                    )
                                )
                            )
                        )
                        [[] swpairs false]
                        (enumerate 0 (- capped-attempts 1))
                    )
                )
            )
        )
    )
    (defun URC_MakeGraph:[object{BreadthFirstSearchV2.GraphNode}] (input:string output:string swpairs:[string])
        @doc "#13C fix + #19H fix, carried over unchanged by the #21H storage redesign: \
            \ a node's links must be genuine active edges (<URC_EdgesActive> non-empty), \
            \ not just 'is this token a valid node somewhere' — a neighbor token can be \
            \ a perfectly valid node overall while the ONLY swpair directly connecting \
            \ it to THIS node is outside <swpairs> (e.g. disabled). Requiring a real \
            \ <URC_EdgesActive> match subsumes plain node-membership (a real active edge \
            \ implies both endpoints are already valid nodes) and closes both problems \
            \ with one condition. \
            \ #37M/M3 fix: <nodes> can genuinely be [] (e.g. <swpairs> is [] \
            \ before the first pool is ever issued) — previously unguarded here, \
            \ a case not named by the original finding but sharing its exact \
            \ <enumerate 0 -1> / <at 0 []> root cause, directly downstream of \
            \ <UC_MakeGraphNodes>. Short-circuits to [] instead of crashing."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV2.GraphNode}] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            {
                                "node": (at idx nodes),
                                "links":
                                    (filter
                                        (lambda (n:string) (!= (URC_EdgesActive (at idx nodes) n swpairs) []))
                                        (URC_TokenNeighbours (at idx nodes))
                                    )
                            }
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string])
        @doc "#65bL Phase 2: reads each of <nodes>'s SWPT|Graph row exactly once — \
            \ the read-fetch half of the raw-fetch/pure-filter split. A caller doing \
            \ multiple best-of-K attempts over the SAME node universe calls this \
            \ ONCE, then reuses the result via <UC_MakeGraphFromRaw> for every \
            \ attempt instead of each attempt independently re-reading and \
            \ rebuilding the whole graph the way <URC_MakeGraph> does. \
            \ #65bL Phase 3 investigated: a sorted-list + binary-search lookup was \
            \ built and measured against the linear scan <UC_MakeGraphFromRaw> uses \
            \ — an isolated synthetic benchmark showed binary search winning at \
            \ 100-300 elements, but the REAL integrated measurement (this exact \
            \ function, the real P2-scale 143-node universe) showed it as a net \
            \ REGRESSION (+27,527 gas on the SWP|TX 032z2 checkpoint), isolated and \
            \ confirmed by reverting only the lookup call. Trusted the real \
            \ measurement over the synthetic one and dropped it — recorded in \
            \ ROUND-01-OWNER-FEEDBACK.md as a real, deliberately-not-shipped result, \
            \ not silently discarded."
        (map
            (lambda (n:string) {"node": n, "neighbours": (UR_Graph n)})
            nodes
        )
    )
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ShortestChainPerNode>, sourcing its graph via \
            \ <UC_MakeGraphFromRaw> (an already-fetched <raw-graph>) instead of \
            \ <URC_MakeGraph> (a fresh read per node, every call)."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTarget>, sourcing its graph via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — same \
            \ early-exit-on-<output> shape as <UC_BFSTargeted>, mirroring \
            \ <URC_ShortestChainPerNodeFromRaw>'s own raw-graph sourcing. Internal \
            \ only, used exclusively by <URC_ComputeGraphPathFromRaw>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ComputeGraphPath>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromRaw> instead of \
            \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic, \
            \ unchanged, just fed from an already-fetched raw graph. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromRaw> instead — same raw-graph sourcing, \
            \ but stops once <output> is actually found instead of exploring the \
            \ whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromRaw input output swpairs raw-graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7: <URC_ShortestChainPerNodeFromRaw>, sourcing an \
            \ ALREADY-BUILT <graph> (<UC_MakeGraphFromRaw>) instead of building it \
            \ fresh from <raw-graph>/<swpairs> on every call — for a caller making \
            \ MULTIPLE Hopper queries against the SAME <swpairs> universe in one \
            \ transaction (the STOA-repricing loop), who builds the graph ONCE and \
            \ reuses it across every query. Safe per the same input/output- \
            \ independence <UC_MakeGraphFromRaw>'s own doc records — one graph \
            \ built against a given <swpairs> universe is valid for EVERY query \
            \ against that same universe, not just the one it happened to be built \
            \ for. Only the BFS traversal itself (genuinely <input>-dependent) \
            \ still runs per query."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromGraph:[[string]]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTargetFromRaw>, sourcing an ALREADY-BUILT \
            \ <graph> instead of rebuilding it from <raw-graph>/<swpairs> — same \
            \ early-exit-on-<output> shape, mirroring \
            \ <URC_ShortestChainPerNodeFromGraph>'s own already-built-graph sourcing. \
            \ Internal only, used exclusively by <URC_ComputeGraphPathFromGraph>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7: <URC_ComputeGraphPathFromRaw>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromGraph> (an already-built <graph>) \
            \ instead of rebuilding it from <raw-graph>/<swpairs> on every call — \
            \ same post-filter-down-to-<output> logic, unchanged. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromGraph> instead — same already-built- \
            \ graph sourcing, but stops once <output> is actually found instead of \
            \ exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromGraph input output graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    ;;#34 Phase 7: dirty-read path-cache core functions.
    (defun URC_ReadPathCache:object{SwapTracerV3.PathCacheRow} (token-a:string token-b:string)
        @doc "Reversed-lookup read: checks <token-a>|<token-b> first, then \
            \ <token-b>|<token-a> reversed (the graph is confirmed bidirectional — \
            \ XI_UpdateGraphForSwpair's symmetric i×j registration), before concluding \
            \ no cached path exists. Returns {nodes:[BAR], edges:[], topology-version:-1} \
            \ on a genuine miss in both directions — never a crash, always a clean \
            \ sentinel. No trust implied: every caller still runs \
            \ <URC_ValidatePathStructure> (or SWPI's active-required wrapper) on \
            \ whatever this returns before using it — a hit here is not itself proof of \
            \ current validity, only of prior registration. Raw registration status \
            \ only — callers wanting freshness too go through \
            \ <URC_ReadPathCacheFresh> instead (#65bL Phase 1)."
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (row-fwd:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-fwd))
            )
            (if (!= (at "nodes" row-fwd) [BAR])
                row-fwd
                (let*
                    (
                        (key-rev:string (+ (+ token-b "|") token-a))
                        (row-rev:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-rev))
                    )
                    (if (!= (at "nodes" row-rev) [BAR])
                        {
                            "nodes" : (reverse (at "nodes" row-rev)),
                            "edges" : (reverse (at "edges" row-rev)),
                            "topology-version" : (at "topology-version" row-rev)
                        }
                        {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                    )
                )
            )
        )
    )
    (defun URC_ReadPathCacheFresh:object{SwapTracerV3.PathCacheRow} (token-a:string token-b:string)
        @doc "#65bL Phase 1: <URC_ReadPathCache>, additionally collapsing a STALE entry \
            \ (its <topology-version> behind the live counter) to the same [BAR] miss \
            \ sentinel a genuinely-absent entry already returns. Callers never need to \
            \ distinguish 'never cached' from 'cached but topology has moved on since' — \
            \ both mean 'don't trust this, go search live instead'."
        (let*
            (
                (row:object{SwapTracerV3.PathCacheRow} (URC_ReadPathCache token-a token-b))
                (current-version:integer (UR_TopologyVersion))
            )
            (if (< (at "topology-version" row) current-version)
                {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                row
            )
        )
    )
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string)
        @doc "Structural legitimacy check for ONE claimed hop: is <swpair> a real, \
            \ registered edge that actually connects <i-id> to <o-id> — not just some \
            \ active pool that happens to exist somewhere. Prevents a submitted bundle \
            \ from containing genuinely-real-but-unrelated edges that don't actually \
            \ form a connected path."
        (contains swpair (URC_Edges i-id o-id))
    )
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string])
        @doc "Exists-only structural validation (P3.1): every claimed hop genuinely \
            \ connects its claimed node pair, and the whole path respects the P0.4 depth \
            \ cap (7 tokens / 6 hops) — checked here directly rather than assumed of the \
            \ off-chain search that produced it, since a malformed or adversarial bundle \
            \ could otherwise submit a structurally-valid-per-hop but far-too-long route. \
            \ [BAR] (the 'no path found' sentinel) is explicitly rejected, not treated as \
            \ a trivial 1-node path. Does NOT check can-swap — SWPI wraps this with that \
            \ additional check for the active-required (real execution) case; this \
            \ module can't reach SWP to check it directly (deploy order)."
        (if (= nodes [BAR])
            false
            (if
                ;;Pact 5's <or> is strictly binary, not variadic — 3+ conditions need
                ;;fold, per this codebase's own documented convention (same class of
                ;;gotcha as the #26M/M9 single-arg <and> bug found earlier this session).
                (fold (or) false
                    [
                        (> (length nodes) 7)
                        (> (length edges) 6)
                        (!= (length edges) (- (length nodes) 1))
                    ]
                )
                false
                ;;#20H-style guard: (enumerate 0 -1) is [0 -1], NOT empty, in Pact 5 — a
                ;;0-hop path (single-node, edges=[]) would otherwise crash on an
                ;;out-of-bounds <at>. Explicit empty-edges short-circuit avoids it.
                (if (= (length edges) 0)
                    true
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (and acc (URC_EdgeConnects (at idx nodes) (at (+ idx 1) nodes) (at idx edges)))
                        )
                        true
                        (enumerate 0 (- (length edges) 1))
                    )
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateGraph (swpair:string)
        @doc "Records <swpair> in the adjacency graph: every token in <swpair> gets \
            \ every OTHER token in <swpair> appended to its neighbour list (idempotent \
            \ — safe to call more than once for the same swpair). Called once at \
            \ issuance from both SWPI::C_Issue and the MTX-SWP defpact path."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateGraphForSwpair swpair)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateGraphForSwpair (swpair:string)
        (require-capability (SECURE))
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (n:integer (length tokens))
            )
            (map
                (lambda (i:integer)
                    (map
                        (lambda (j:integer)
                            (if (= i j)
                                BAR
                                (XI_UpdatePair (at i tokens) (at j tokens) swpair)
                            )
                        )
                        (enumerate 0 (- n 1))
                    )
                )
                (enumerate 0 (- n 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdatePair (from:string to:string swpair:string)
        @doc "Adds <to> as a neighbour of <from> via <swpair>, creating the neighbour \
            \ entry if this is the first connection between them, or appending \
            \ <swpair> to the existing entry's swpairs list if not already present. \
            \ #65bL Phase 1 fix: also bumps the global topology-version counter, but \
            \ ONLY when this call genuinely changes something — a new token-pair \
            \ connection, or a new parallel pool on an already-connected pair — never \
            \ on an idempotent replay of an already-registered pair+swpair (e.g. \
            \ A_RebuildGraph re-running over every existing pool). <did-change> below \
            \ is exactly the same condition the pre-existing branching already computed \
            \ implicitly; this just names it so it can also gate the version bump."
        (require-capability (SECURE))
        (let*
            (
                (existing:[object{SwapTracerV3.NeighbourEdge}] (UR_Graph from))
                (idx:[integer] (UC_FindNeighbourIndex existing to))
                (is-new-pair:bool (= (length idx) 0))
                (old-swpairs:[string]
                    (if is-new-pair
                        []
                        (at "swpairs" (at (at 0 idx) existing))
                    )
                )
                (is-new-swpair:bool (not (contains swpair old-swpairs)))
                (did-change:bool (or is-new-pair is-new-swpair))
                (new-neighbours:[object{SwapTracerV3.NeighbourEdge}]
                    (if is-new-pair
                        (+ existing [{"token": to, "swpairs": [swpair]}])
                        (let*
                            (
                                (i:integer (at 0 idx))
                                (new-swpairs:[string]
                                    (if is-new-swpair
                                        (+ old-swpairs [swpair])
                                        old-swpairs
                                    )
                                )
                            )
                            (+ (+ (take i existing) [{"token": to, "swpairs": new-swpairs}]) (drop (+ i 1) existing))
                        )
                    )
                )
            )
            (write SWPT|Graph from {"neighbours": new-neighbours})
            (if did-change (XI_BumpTopologyVersion) "no-op")
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BumpTopologyVersion ()
        @doc "#65bL Phase 1: increments the global topology-version counter by 1. \
            \ Called only from <XI_UpdatePair> when it detects a genuine change — \
            \ never unconditionally."
        (require-capability (SECURE))
        (write SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version": (+ (UR_TopologyVersion) 1)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 7: registration into SWPT|PathCache. Self-verifying (owner's \
            \ final-check catch, 2026-08-21) — checks whether a row already exists in \
            \ EITHER direction before writing, rather than trusting a caller's is-new \
            \ claim as the write authority. Structural validation is the CALLER's \
            \ responsibility (URC_ValidatePathStructure/SWPI's active-required wrapper) \
            \ — this function only handles the write-safety half, matching this \
            \ codebase's XI_* convention of writes-only, no enforce/validation here. \
            \ #65bL Phase 1 fix: was strictly first-write-wins/insert-only, meaning a \
            \ cached entry could never be refreshed even after new topology made a \
            \ better route possible — permanent staleness by construction. Now \
            \ version-checked: a genuinely absent entry still inserts; an existing \
            \ entry only gets overwritten if its own <topology-version> is behind the \
            \ current counter (topology has moved on since it was cached), otherwise \
            \ still a no-op — never a redundant write for an already-current entry."
        (require-capability (SECURE))
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (key-rev:string (+ (+ token-b "|") token-a))
                (row-fwd:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-fwd))
                (row-rev:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-rev))
                (already-fwd:bool (!= (at "nodes" row-fwd) [BAR]))
                (already-rev:bool (!= (at "nodes" row-rev) [BAR]))
                (current-version:integer (UR_TopologyVersion))
                (new-row:object{SwapTracerV3.PathCacheRow}
                    {"nodes": nodes, "edges": edges, "topology-version": current-version}
                )
            )
            (if (and (not already-fwd) (not already-rev))
                (insert SWPT|PathCache key-fwd new-row)
                (if already-fwd
                    (if (< (at "topology-version" row-fwd) current-version)
                        (write SWPT|PathCache key-fwd new-row)
                        "already fresh, no-op"
                    )
                    (if (< (at "topology-version" row-rev) current-version)
                        (write SWPT|PathCache key-rev new-row)
                        "already fresh, no-op"
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 8: forward-module entrypoint for XI_RegisterPath, mirroring \
            \ XE_UpdateGraph exactly — P|UEV_IMC gate, then internal SECURE composition. \
            \ Cross-module callers (SWPU::C_SmartSwap, once wired) go through THIS, never \
            \ a caller-side (with-capability (SWPT.SECURE) ...) directly — SECURE's own \
            \ body is unconditionally true, so a direct outside grant would hand it to \
            \ any caller at all, not just legitimate Ouronet modules (this exact class of \
            \ issue is already documented, empirically, in this codebase's own ATS audit \
            \ findings)."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RegisterPath token-a token-b nodes edges)
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 14_SWPT.pact (5 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SWPT|Graph)
;; (create-table SWPT|PathCache)
;; (create-table SWPT|TopologyVersion)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperV4
    @doc "Swapper forward surface for module SWP (successor to SwapperV4). \
        \ Row shapes use this interface's PoolTokens and FeeSplit schemas (field-compatible with SwapperV4). \
        \ V3: UR_StoaValue and XE_UpdateStoaValue for STOA pool ledger on SWP|Pairs."

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
    (defschema PoolTokens
        token-id:string
        token-supply:decimal
    )
    (defschema FeeSplit
        target:string
        value:integer
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
    (defun CT_Info ())
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_ExtractTokens:[string] (input:[object{PoolTokens}]))
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{PoolTokens}]))
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{FeeSplit}]))
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{FeeSplit}]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_Asymetric:bool ())
    (defun UR_Principals:[string] ())
    (defun UR_PrimordialPool:string ())
    (defun UR_LiquidBoost:bool ())
    (defun UR_SpawnLimit:decimal ())
    (defun UR_InactiveLimit:decimal ())
        ;;
    (defun UR_OwnerKonto:string (swpair:string))
    (defun UR_CanChangeOwner:bool (swpair:string))
    (defun UR_CanAdd:bool (swpair:string))
    (defun UR_CanSwap:bool (swpair:string))
    (defun UR_GenesisWeigths:[decimal] (swpair:string))
    (defun UR_Weigths:[decimal] (swpair:string))
    (defun UR_GenesisRatio:[object{PoolTokens}] (swpair:string))
    (defun UR_PoolTokenObject:[object{PoolTokens}] (swpair:string))
    (defun UR_TokenLP:string (swpair:string))
    (defun UR_FeeLP:decimal (swpair:string))
    (defun UR_FeeSP:decimal (swpair:string))
    (defun UR_FeeSPT:[object{FeeSplit}] (swpair:string))
    (defun UR_FeeLock:bool (swpair:string))
    (defun UR_FeeUnlocks:integer (swpair:string))
    (defun UR_Amplifier:decimal (swpair:string))
    (defun UR_Primality:bool (swpair:string))
    (defun UR_IzFrozenLP:bool (swpair:string))
    (defun UR_IzSleepingLP:bool (swpair:string))
    (defun UR_StoaValue:decimal (swpair:string))
    (defun UR_Pools:[string] (pool-category:string))
        ;;
    (defun UR_PoolTokens:[string] (swpair:string))
    (defun UR_GetLpSwpair:string (lp-id:string))
    (defun UR_PoolTokenSupplies:[decimal] (swpair:string))
    (defun UR_PoolGenesisSupplies:[decimal] (swpair:string))
    (defun URv_PoolTokenPosition:integer (swpair:string id:string))
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string))
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string))
    (defun UR_SpecialFeeTargets:[string] (swpair:string))
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string))
    ;;
    ;;#65eL: "major" principal = currently a member of the primordial pool's own
    ;;token list (always exactly OURO/WSTOA/SSTOA in practice, enforced at
    ;;A_DefinePrimordialPool's own capability gate) — fixed, never
    ;;removable/rotatable via A_UpdatePrincipal/A_RotatePrincipal. Any other
    ;;principal is "minor" and unaffected by this distinction.
    (defun URC_IsMajorPrincipal:bool (token:string))
    (defun URC_LpCapacity:decimal (swpair:string))
    (defun URC_CheckID:bool (swpair:string))
    (defun URC_PoolTotalFee:decimal (swpair:string))
    (defun URC_LiquidityFee:decimal (swpair:string))
    (defun URC_AllPoolTokens:[string] ())
    (defun URC_Swpairs:[string] ())
    (defun URC_LpComposer:[string] (pool-tokens:[object{PoolTokens}] weights:[decimal] amp:decimal))
    ;;
    (defun URH_OwnedSwapPairs:[string] (account:string))
    ;;  [URCi] cost readers — single source per op (EnableFrozen/Sleeping/ToggleAddOrSwap composers -> Phase 1.2)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_ToggleFeeLockStoa:decimal (swpair:string toggle:bool))
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool add-or-swap:bool))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string))
    (defun UEV_FeeSplit (input:object{FeeSplit}))
    (defun UEV_id (swpair:string))
    (defun UEV_CanChangeOwnerON (swpair:string))
    (defun UEV_FeeLockState (swpair:string state:bool))
    (defun UEV_PoolFee (fee:decimal))
    (defun UEV_New (t-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckTwo (token-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckAgainstMass:bool (token-ids:[string] present-pools:[string]))
    (defun UEV_CheckAgainst:bool (token-ids:[string] pool-tokens:[string]))
    (defun UEV_FrozenLP (swpair:string state:bool))
    (defun UEV_SleepingLP (swpair:string state:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XE_AddLPTracker (lp-id:string swpair:string))
    ;;
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal]))
    ;;
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal]))
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal))
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal))
    (defun XE_Issue:string (account:string pool-tokens:[object{PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun A_RotatePrincipal (old:string new:string))
    (defun A_UpdateLimit (limit:decimal spawn:bool))
    (defun A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun A_DefinePrimordialPool (primordial-pool:string))
    (defun A_ToggleAsymetricLiquidityAddition (patron:string toggle:bool))
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-owner:string))
    (defun C_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun C_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-boolean:bool))
    (defun C_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-weights:[decimal]))
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string toggle:bool add-or-swap:bool))
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string toggle:bool))
    (defun C_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string amp:decimal))
    (defun C_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string targets:[object{FeeSplit}]))

)
;;
(module SWP GOV
    @doc "SWP (SwapperV4) is the core swapper/liquidity-pool module holding all per-pool \
        \ state in SWP|Pairs (owner, weights, token supplies, fees, amplifier, STOA value, \
        \ flags) plus global properties (principals, primordial pool, limits) and pool/LP \
        \ indexes. It provides the pool read surface (UR_/URC_ for tokens, supplies, fees, \
        \ LP capacity, swpairs) and admin/owner client ops: change ownership, modify \
        \ weights/amplifier/fees/special-fee targets, toggle add-or-swap, enable \
        \ frozen/sleeping LP, and manage principals and the primordial pool. Serves Stable, \
        \ Weighted, and standard pool curves."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements SwapperV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_SWP                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_SWP                                (keyset-ref-guard SWP|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWP_ADMIN)))
    (defcap GOV|SWP_ADMIN ()
        (enforce-one
            "SWP Swapper Admin not satisfed"
            [
                (enforce-guard GOV|MD_SWP)
                (enforce-guard GOV|SC_SWP)
            ]
        )
    )
    ;;{G5}  functions
    ;;
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|SwapKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SwapKey)
        )
    )
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
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
    (defcap P|SWP|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|GOVERNING-CALLER ()
        (compose-capability (P|SWP|CALLER))
        (compose-capability (SWP|GOV))
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
        (with-capability (GOV|SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWP_ADMIN)
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
        (with-capability (GOV|SWP_ADMIN)
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
        (with-capability (GOV|SWP_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWP|CALLER)))
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
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst SWP|SC_KEY                                (GOV|SwapKey))
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst SWP|INFO                                  (CT_Info))
    (defconst P2 "P2")
    (defconst P3 "P3")
    (defconst P4 "P4")
    (defconst P5 "P5")
    (defconst P6 "P6")
    (defconst P7 "P7")
    (defconst S2 "S2")
    (defconst S3 "S3")
    (defconst S4 "S4")
    (defconst S5 "S5")
    (defconst S6 "S6")
    (defconst S7 "S7")
    (defconst SWP|EMPTY-TARGET
        { "target": BAR
        , "value": 1 }
    )
    ;;{3.2}  schemas
    ;;
    (defschema SWP|PropertiesSchema
        principals:[string]
        primordial-pool:string
        liquid-boost:bool
        spawn-limit:decimal
        inactive-limit:decimal
    )
    (defschema SWP|PairsSchemaV3
        @doc "Per liquidity pool. Table row key is <swpair> (see UC_PoolID in UtilitySwpV2); \
            \ stored <id> equals that key. V3 adds stoa-value for STOA ledger attribution on \
            \ the pool; legacy V2 rows omit the column until UR_StoaValue backfills 0.0."
        ;;
        ;;Management
        owner-konto:string                              ;;[M]   Pool owner konto
        can-change-owner:bool                           ;;[M]
        can-add:bool                                    ;;[M]
        can-swap:bool                                   ;;[M]
        ;;
        ;;Weights and token composition
        genesis-weights:[decimal]                       ;;[.]   Weights at issue
        weights:[decimal]                               ;;[M]   Current weights
        genesis-ratio:[object{SwapperV4.PoolTokens}]    ;;[.]   Token supplies at issue
        pool-tokens:[object{SwapperV4.PoolTokens}]      ;;[M]   Current per-token supplies
        token-lp:string                                 ;;[.]   LP DPTF id for this pool
        ;;
        ;;Fees
        fee-lp:decimal                                  ;;[M]   LP fee (promille semantics per module)
        fee-special:decimal                             ;;[M]
        fee-special-targets:[object{SwapperV4.FeeSplit}];;[M]
        fee-lock:bool                                   ;;[M]
        unlocks:integer                                 ;;[M]   Fee-target edit generation counter
        ;;
        ;;Curve / flags
        amplifier:decimal                               ;;[M]
        primality:bool                                  ;;[.]   Pool construction (primality) at issue
        frozen-lp:bool                                  ;;[.]   Once true, frozen LP path enabled
        sleeping-lp:bool                                ;;[.]   Once true, sleeping LP path enabled
        ;;
        ;;STOA (V3)
        stoa-value:decimal                              ;;[M]   STOA amount attributed to this pool; 0.0 at issue
        ;;
        ;;Select Keys
        id:string                                       ;;[.]   Pool id (= SWP|Pairs row key <swpair>)
    )
    (defschema SWP|PoolsSchema
        pools:[string]
    )
    (defschema SWP|AsymmetrySchema
        asymmetric:bool
    )
    (defschema SWP|LpTracker
        swpair:string
    )
    ;;{3.3}  tables
    (deftable SWP|Properties:{SWP|PropertiesSchema})    ;;Key = SWP|INFO
    (deftable SWP|Pairs:{SWP|PairsSchemaV3})            ;;Key = <swpair>
    (deftable SWP|Pools:{SWP|PoolsSchema})              ;;Key = <pool-category>
    (deftable SWP|Asymmetry:{SWP|AsymmetrySchema})      ;;Key = SWP|INFO
    (deftable SWP|LP:{SWP|LpTracker})                   ;;Key = <LP-string>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap SWP|GOV ()
        @doc "Governor Capability for the Swapper Smart DALOS Account"
        true
    )
    ;;UNUSED -- a leftover of a pattern SWP did not adopt. DALOS, LIQUID and OUROBOROS each pair
    ;;an X|NATIVE-AUTOMATIC cap with a GOV|X|GUARD that turns it into the smart account's guard via
    ;;<create-capability-guard>. SWP has no such guard function: it builds its account guards from
    ;;(create-capability-guard (SECURE)) and (create-capability-guard (P|SWP|CALLER)) instead, so
    ;;nothing ever reaches this cap. Left in place rather than deleted -- unlike ATS's orphan
    ;;(ATS|S>CONTROL-DIRECT-RECOVERY) it guards nothing and its removal changes no behaviour, but
    ;;it is also not evidence of a gap. Flagged 2026-09-10.
    (defcap SWP|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of SWAPPER Smart Account"
        true
    )
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap SWP|S>RT_OWN (swpair:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (current-owner:string (UR_OwnerKonto swpair))
                (current-special-targets:integer (length (UR_FeeSPT swpair)))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major new-owner))
                (max-new-owner:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) true [(= major 5)(= major 6)(= major 7)]) 7)
                        1
                    )
                )
            )
            (enforce 
                (>= max-new-owner current-special-targets) 
                (format "Insufficient Major Elite Tier for NewOwner to support CurrentOwner \
                        \existing SpecialFeeTargets of {}" [current-special-targets])
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_OwnerKonto swpair) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (UEV_CanChangeOwnerON swpair)
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>RT_CAN-CHANGE (swpair:string new-boolean:bool)
        @event
        (let
            (
                (current:bool (UR_CanChangeOwner swpair))
            )
            (enforce (!= current new-boolean) "Similar boolean unallowed for <can-change-owner>")
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>WEIGHTS (swpair:string new-weights:[decimal])
        @event
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (pp:string (take 1 swpair))
                (ws:decimal (fold (+) 0.0 new-weights))
                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
                (l0:integer (length (UR_PoolTokens swpair)))
                (l1:integer (length new-weights))
            )
            ;;C7 fix: length-parity, mirroring the sibling SWP|S>UPDATE-SUPPLIES cap.
            (ref-U|INT::UEV_UniformList [l0 l1])
            ;;C7 fix: real per-weight enforce inside the map lambda (the original code computed this exact
            ;;check via `=` and threw the result away — matching UEV_UniformList's working idiom, not the
            ;;original dead-map one). Combines the precision check with a >= 0.1 floor per weight (also
            ;;rules out negative weights) into a single `enforce` per element.
            (map
                (lambda
                    (w:decimal)
                    (enforce
                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
                    )
                )
                new-weights
            )
            (enforce (= pp "W") "Changing weights available only for weighted Pools")
            (enforce (= ws 1.0) "All weights must add to exactly 1.0")
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>UPDATE-SUPPLIES (swpair:string new-supplies:[decimal])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (l0:integer (length pool-tokens))
                (l1:integer (length new-supplies))
                (lengths:[integer] [l0 l1])
            )
            (UEV_id swpair)
            (ref-U|INT::UEV_UniformList lengths)
            ;;H12 fix: the old code only validated a new supply when it was already > 0.0, silently
            ;;skipping any check at all for <= 0.0 (letting a negative supply persist unenforced). Added
            ;;an unconditional non-negativity enforce inside the lambda, real-guard-style (matches the
            ;;C7/UEV_UniformList idiom), on top of the pre-existing positive-value precision check.
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (val:decimal (at idx new-supplies))
                        )
                        (enforce
                            (>= val 0.0)
                            (format "New supply {} for pool token {} cannot be negative" [val (at idx pool-tokens)])
                        )
                        (if (> val 0.0)
                            (ref-DPTF::UEV_Amount (at idx pool-tokens) val)
                            true
                        )
                    )
                )
                (enumerate 0 (- l0 1))
            )
        )
    )
    (defcap SWP|S>UPDATE-SUPPLY (swpair:string id:string new-supply:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UEV_Amount id new-supply)
            (UEV_id swpair)
        )
    )
    (defcap SWP|S>UPDATE-FEE (swpair:string new-fee:decimal )
        @event
        (UEV_FeeLockState swpair false)
        (UEV_PoolFee new-fee)
        (CAP_Owner swpair)
    )
    (defcap SWP|S>UPDATE-AMPLIFIER (swpair:string new-amplifier:decimal)
        @event
        (CAP_Owner swpair)
        (let
            (
                (current-amp:decimal (UR_Amplifier swpair))
            )
            (enforce (> current-amp 0.0) "Amplifier can only be updated for Stable Pools")
            ;;C8 fix: <new-amplifier> was never validated at all — no bound, and critically no exclusion
            ;;of the module's own -1.0 "not a stable pool" sentinel. Mirrors UEV_Issue's own >= 1.0 floor
            ;;at creation (16_SWPI.pact:1267); ceiling of 2000.0 is evidence-backed, not arbitrary — REPL-
            ;;verified: round-trip convergence on a skewed pool stays excellent (~1e-13) through the low
            ;;hundreds, then measurably degrades (~1e-7 by A=5000+) because the Newton solver's fixed
            ;;11-iteration limit (H1, separately tracked, still open) stops fully converging at high A on
            ;;skewed reserves. 2000.0 covers realistic real-world stable-pool ranges with margin to spare
            ;;below that degradation. A single range check also excludes -1.0/0.0/negatives with no
            ;;separate sentinel check needed.
            (enforce
                (and (>= new-amplifier 1.0) (<= new-amplifier 2000.0))
                (format "Amplifier {} must be between 1.0 and 2000.0" [new-amplifier])
            )
        )
    )
    (defcap SPW|S>UPDATE_SPECIAL-FEE-TARGETS (swpair:string targets:[object{SwapperV4.FeeSplit}])
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (target-no:integer (length targets))
                (owner:string (UR_OwnerKonto swpair))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major owner))
                (max:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) true [(= major 5)(= major 6)(= major 7)]) 7)
                        1
                    )
                )
            )
            (enforce (and (>= target-no 1) (<= target-no max)) "Increase Major Elite Tier to add more Special Targets")
            (CAP_Owner swpair)
            (map
                (lambda
                    (obj:object{SwapperV4.FeeSplit})
                    (UEV_FeeSplit obj)
                )
                targets
            )
        )
    )
    (defcap SWP|C>ADD-OR-SWAP (swpair:string toggle:bool add-or-swap:bool)
        @event
        (let
            (
                (add:bool (UR_CanAdd swpair))
                (swap:bool (UR_CanSwap swpair))
            )
            (if add-or-swap
                (enforce (!= add toggle) "Similar boolean unallowed for <can-add> or <can-swap>")
                (enforce (!= swap toggle) "Similar boolean unallowed for <can-add> or <can-swap>")
            )
            (CAP_Owner swpair)
        )
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
    ;{C3}
    ;{C4}
    (defcap SWP|C>UPDATE-BRD (swpair:string)
        @event
        (CAP_Owner swpair)
        (compose-capability (P|SWP|CALLER))
    )
    (defcap SWP|C>UPGRADE-BRD (swpair:string)
        @event
        (CAP_Owner swpair)
        (compose-capability (P|SWP|CALLER))
    )
    (defcap SWP|C>PRINCIPAL (principal:string add-or-remove:bool)
        @doc "Adds are capped at 7 total and must not duplicate an existing \
            \ principal. Removes must leave at least 2 principals defined — SWPT's \
            \ storage is principal-agnostic (#21H), so removal itself is safe; the \
            \ floor exists so issuance-time principal-anchoring validation \
            \ (SWPI::UEV_Issue) always has somewhere real to anchor a new W/P pool. \
            \ #65eL: removal also rejects a 'major' principal (currently a member \
            \ of the primordial pool — URC_IsMajorPrincipal) outright, regardless \
            \ of the floor — major principals are fixed, retirable only by \
            \ redefining the primordial pool itself (SWP|C>DEFINE-PRIMORDIAL-POOL), \
            \ never by this function. A 'minor' principal is unaffected. Gated by \
            \ the same GOV|SWP_ADMIN admin capability as SWP|C>ROTATE-PRINCIPAL."
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (current:[string] (UR_Principals))
                (current-count:integer (if (= current [BAR]) 0 (length current)))
            )
            (ref-DPTF::UEV_id principal)
            (if add-or-remove
                (and
                    (enforce (not (contains principal current)) (format "{} is already a principal" [principal]))
                    (enforce (< current-count 7) (format "Cannot add principal — {} of 7 maximum already defined" [current-count]))
                )
                (and
                    (enforce (contains principal current) (format "{} is not currently a principal" [principal]))
                    (and
                        (enforce (> current-count 2) (format "Cannot remove principal — at least 2 must remain defined ({} currently)" [current-count]))
                        (enforce (not (URC_IsMajorPrincipal principal)) (format "{} is a major (primordial-pool) principal — cannot be removed" [principal]))
                    )
                )
            )
        )
    )
    (defcap SWP|C>ROTATE-PRINCIPAL (old:string new:string)
        @doc "Validates an atomic principal replacement. Each rejection reason gets \
            \ its own distinct enforce, not a combined boolean, since they're \
            \ separate concerns with separate causes: <old> must currently be a \
            \ principal, <old> must not be a 'major' (primordial-pool) principal \
            \ (#65eL — majors are fixed, retirable only by redefining the \
            \ primordial pool itself, never by rotation), <new> must not already \
            \ be one, and rotating a principal into itself is never allowed \
            \ regardless of whether it's already a principal (it always would be, \
            \ since <old> = <new>). Count-preserving — never interacts with the \
            \ 7-principal cap. Gated by the same GOV|SWP_ADMIN admin capability as \
            \ SWP|C>PRINCIPAL."
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (current:[string] (UR_Principals))
            )
            (ref-DPTF::UEV_id new)
            (ref-U|LST::UEV_StringPresence old current)
            (enforce (not (URC_IsMajorPrincipal old)) (format "{} is a major (primordial-pool) principal — cannot be rotated" [old]))
            (enforce (!= old new) "Cannot rotate a principal into itself")
            (enforce (not (contains new current)) (format "{} is already a principal" [new]))
        )
    )
    (defcap SWP|C>LQBOOST (new-boost-variable:bool)
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (lqb:bool (UR_LiquidBoost))
            )
            (enforce (!= new-boost-variable lqb) (format "Liquid Boost already set to {}" [new-boost-variable]))
        )
    )
    (defcap SWP|C>LIMIT ()
        @event
        (compose-capability (GOV|SWP_ADMIN))
    )
    (defcap SWP|C>TG_FEE-LOCK (swpair:string toggle:bool)
        @event
        (UEV_FeeLockState swpair (not toggle))
        (CAP_Owner swpair)
        (compose-capability (SECURE))
    )
    (defcap SWP|C>ENABLE-FROZEN (swpair:string)
        @event
        ;;#31M/M7 fix: was missing CAP_Owner — any caller routed through
        ;;P|GOVERNING-CALLER could permanently enable Frozen LP on any pool,
        ;;not just their own. Only the pool's own owner may trigger this
        ;;(and it's irreversible by design — no XI ever writes it back to
        ;;false).
        (UEV_FrozenLP swpair false)
        (CAP_Owner swpair)
        (compose-capability (P|GOVERNING-CALLER))
    )
    (defcap SWP|C>ENABLE-SLEEPING (swpair:string)
        @event
        ;;#31M/M7 fix: same as SWP|C>ENABLE-FROZEN above — owner-only,
        ;;irreversible.
        (UEV_SleepingLP swpair false)
        (CAP_Owner swpair)
        (compose-capability (P|GOVERNING-CALLER))
    )
    (defcap SWP|C>DEFINE-PRIMORDIAL-POOL (primordial-pool:string)
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (primality:bool (UR_Primality primordial-pool))
                (pt:[string] (UR_PoolTokens primordial-pool))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (pool-type:string (ref-U|SWP::UC_PoolType primordial-pool))
                (iz-weigthed:bool (= pool-type "W"))
                (has-ouro:bool (contains ouro pt))
                (has-wstoa:bool (contains wstoa pt))
                (has-sstoa:bool (contains sstoa pt))
                (iz-three:bool (= (length pt) 3))
            )
            ;;H6 fix: <primality> was bound above but never included in this fold, so the only checks
            ;;actually enforced were the 5 composable "does it look like the right shape" conditions —
            ;;the issuance-time eligibility flag that's supposed to gate this (owner: also means exempt
            ;;from low-liquidity gates / never autonomously disabled) was read and silently unused.
            (enforce (fold (and) true [iz-weigthed has-ouro has-wstoa has-sstoa iz-three primality]) "Pool is not the primordial pool")
        )
    )
    (defcap SWP|C>TG-ASYMETRIC-LQ (toggle:bool)
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (pp:string (UR_PrimordialPool))
            )
            (enforce (!= pp BAR) "PrimordialPool must be set for this operation")
            (UEV_AsymetricState (not toggle))
            (compose-capability (P|SWP|CALLER))
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    (defun CT_Info ()                                   (at 0 ["SwapperInformation"]))
    ;;{5.2}  Compute [UC]
    (defun UC_ExtractTokens:[string] (input:[object{SwapperV4.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] item:object{SwapperV4.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-id" item))
                )
                []
                input
            )
        )
    )
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{SwapperV4.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] item:object{SwapperV4.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-supply" item))
                )
                []
                input
            )
        )
    )
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{SwapperV4.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (at "target" (at idx io))
                    )
                )
                []
                (enumerate 0 (- (length io) 1))
            )
        )
    )
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{SwapperV4.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (dec (at "value" (at idx io)))
                    )
                )
                []
                (enumerate 0 (- (length io) 1))
            )
        )
    )
    (defun UCv_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of the Pool String {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UC_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (l:integer (length pool-tokens))
                (Xp:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Decimals (at idx pool-tokens))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            Xp
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Asymetric:bool ()
        (at "asymmetric" (read SWP|Asymmetry SWP|INFO ["asymmetric"]))
    )
    (defun UR_Principals:[string] ()
        (at "principals" (read SWP|Properties SWP|INFO ["principals"]))
    )
    (defun UR_PrimordialPool:string ()
        (at "primordial-pool" (read SWP|Properties SWP|INFO ["primordial-pool"]))
    )
    (defun UR_LiquidBoost:bool ()
        (at "liquid-boost" (read SWP|Properties SWP|INFO ["liquid-boost"]))
    )
    (defun UR_SpawnLimit:decimal ()
        (at "spawn-limit" (read SWP|Properties SWP|INFO ["spawn-limit"]))
    )
    (defun UR_InactiveLimit:decimal ()
        (at "inactive-limit" (read SWP|Properties SWP|INFO ["inactive-limit"]))
    )
    ;;
    (defun UR_OwnerKonto:string (swpair:string)
        (at "owner-konto" (read SWP|Pairs swpair ["owner-konto"]))
    )
    (defun UR_CanChangeOwner:bool (swpair:string)
        (at "can-change-owner" (read SWP|Pairs swpair ["can-change-owner"]))
    )
    (defun UR_CanAdd:bool (swpair:string)
        (at "can-add" (read SWP|Pairs swpair ["can-add"]))
    )
    (defun UR_CanSwap:bool (swpair:string)
        (at "can-swap" (read SWP|Pairs swpair ["can-swap"]))
    )
    (defun UR_GenesisWeigths:[decimal] (swpair:string)
        (at "genesis-weights" (read SWP|Pairs swpair ["genesis-weights"]))
    )
    (defun UR_Weigths:[decimal] (swpair:string)
        (at "weights" (read SWP|Pairs swpair ["weights"]))
    )
    (defun UR_GenesisRatio:[object{SwapperV4.PoolTokens}] (swpair:string)
        (at "genesis-ratio" (read SWP|Pairs swpair ["genesis-ratio"]))
    )
    (defun UR_PoolTokenObject:[object{SwapperV4.PoolTokens}] (swpair:string)
        (at "pool-tokens" (read SWP|Pairs swpair ["pool-tokens"]))
    )
    (defun UR_TokenLP:string (swpair:string)
        (at "token-lp" (read SWP|Pairs swpair ["token-lp"]))
    )
    (defun UR_FeeLP:decimal (swpair:string)
        (at "fee-lp" (read SWP|Pairs swpair ["fee-lp"]))
    )
    (defun UR_FeeSP:decimal (swpair:string)
        (at "fee-special" (read SWP|Pairs swpair ["fee-special"]))
    )
    (defun UR_FeeSPT:[object{SwapperV4.FeeSplit}] (swpair:string)
        (at "fee-special-targets" (read SWP|Pairs swpair ["fee-special-targets"]))
    )
    (defun UR_FeeLock:bool (swpair:string)
        (at "fee-lock" (read SWP|Pairs swpair ["fee-lock"]))
    )
    (defun UR_FeeUnlocks:integer (swpair:string)
        (at "unlocks" (read SWP|Pairs swpair ["unlocks"]))
    )
    (defun UR_Amplifier:decimal (swpair:string)
        (at "amplifier" (read SWP|Pairs swpair ["amplifier"]))
    )
    (defun UR_Primality:bool (swpair:string)
        (at "primality" (read SWP|Pairs swpair ["primality"]))
    )
    (defun UR_IzFrozenLP:bool (swpair:string)
        (at "frozen-lp" (read SWP|Pairs swpair ["frozen-lp"]))
    )
    (defun UR_IzSleepingLP:bool (swpair:string)
        (at "sleeping-lp" (read SWP|Pairs swpair ["sleeping-lp"]))
    )
    (defun UR_StoaValue:decimal (swpair:string)
        @doc "STOA pool ledger scalar. Same row existence semantics as other UR_* on SWP|Pairs: \
            \ <read SWP|Pairs swpair …> fails if <swpair> is not a pool. Legacy V2 rows without \
            \ stoa-value (narrow read returns {}) return 0.0 directly, computed fresh on every \
            \ read — never persisted here. \
            \ #50L fix: this used to backfill 0.0 into storage on first read as a migration \
            \ artifact/optimization — a real ungated write as a side effect of a nominal UR_* \
            \ read, at the caller's own gas expense. Confirmed safe to drop: traced every read \
            \ of \"stoa-value\" anywhere in the codebase (including cross-module, AQP's FVT) — \
            \ this function is the only one that ever reads the field directly, so nothing \
            \ depends on it being physically present in storage. A real price update \
            \ (<XE_UpdateStoaValue>) still writes the genuine value whenever one actually \
            \ occurs; genesis pools already seed the field from day one, so this only ever \
            \ applied to pre-V3 legacy rows anyway."
        (let
            (
                (temp (read SWP|Pairs swpair ["stoa-value"]))
            )
            (if (= temp {}) 0.0 (at "stoa-value" temp))
        )
    )
    (defun UR_Pools:[string] (pool-category:string)
        (at "pools" (read SWP|Pools pool-category ["pools"]))
    )
    (defun UR_PoolTokens:[string] (swpair:string)
        (UC_ExtractTokens (UR_PoolTokenObject swpair))
    )
    (defun UR_PoolTokenSupplies:[decimal] (swpair:string)
        (UC_ExtractTokenSupplies (UR_PoolTokenObject swpair))
    )
    (defun UR_PoolGenesisSupplies:[decimal] (swpair:string)
        (UC_ExtractTokenSupplies (UR_GenesisRatio swpair))
    )
    (defun URv_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of Pool {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string)
        (at (URv_PoolTokenPosition swpair id) (UR_PoolTokenSupplies swpair))
    )
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (l:integer (length pool-tokens))
                (Xp:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Decimals (at idx pool-tokens))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            Xp
        )
    )
    (defun UR_SpecialFeeTargets:[string] (swpair:string)
        (UC_CustomSpecialFeeTargets (UR_FeeSPT swpair))
    )
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string)
        (UC_CustomSpecialFeeTargetsProportions (UR_FeeSPT swpair))
    )
    (defun UR_GetLpSwpair:string (lp-id:string)
        (at "swpair" (read SWP|LP lp-id ["swpair"]))
    )
    (defun URC_IsMajorPrincipal:bool (token:string)
        @doc "True if <token> is currently a member of the primordial pool's own \
            \ token list — the 'major principal' concept: fixed, always exactly \
            \ OURO/WSTOA/SSTOA in practice (A_DefinePrimordialPool's own capability \
            \ gate enforces exactly these 3 tokens, always, regardless of which \
            \ physical pool backs it), never removable or rotatable-away via \
            \ A_UpdatePrincipal/A_RotatePrincipal — as opposed to any other \
            \ ('minor') principal, which both freely allow. Returns false (never \
            \ major) if no primordial pool has been defined yet, or if <token> \
            \ isn't currently a member of the one that has been — this doesn't \
            \ require <token> to already be a registered principal at all, callers \
            \ combine that check separately where it matters."
        (let
            (
                (pp:string (UR_PrimordialPool))
            )
            (if (= pp BAR)
                false
                (contains token (UR_PoolTokens pp))
            )
        )
    )
    (defun URC_LpCapacity:decimal (swpair:string)
        @doc "Computes the LP Capacity of a Given Swap Pair"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Supply (UR_TokenLP swpair))
        )
    )
    (defun URC_CheckID:bool (swpair:string)
        (with-default-read SWP|Pairs swpair
            { "unlocks" : -1 }
            { "unlocks" := u }
            (if (< u 0)
                false
                true
            )
        )
    )
    (defun URC_PoolTotalFee:decimal (swpair:string)
        @doc "Computes Total Pool Fee in Promille"
        (let
            (
                (lb:bool (UR_LiquidBoost))
                (current-fee-lp:decimal (UR_FeeLP swpair))
                (current-fee-special:decimal (UR_FeeSP swpair))
                (tf1:decimal (+ current-fee-lp current-fee-special))
                (tf2:decimal (+ (* current-fee-lp 2.0) current-fee-special))
            )
            (if lb
                tf2
                tf1
            )
        )
    )
    (defun URC_LiquidityFee:decimal (swpair:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (n:decimal (dec (length (UR_PoolTokens swpair))))
                (swap-fee:decimal (URC_PoolTotalFee swpair))
            )
            (floor (/ (* n swap-fee) (* 4.0 (- n 1.0))) (ref-U|CT::CT_FEE_PRECISION))
        )
    )
    (defun URC_AllPoolTokens:[string] ()
        @doc "Outputs all unique tokens existing across all Swap Pools"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_UniqueTokens (URC_Swpairs))
        )
    )
    (defun URC_Swpairs:[string] ()
        @doc "Outputs all current Existing Swpairs. Cheaper than <keys SWP|Pairs>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pl:[string] [P2 P3 P4 P5 P6 P7 S2 S3 S4 S5 S6 S7])
                (fl:[[string]]
                    (fold
                        (lambda
                            (acc:[[string]] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (UR_Pools (at idx pl))
                            )
                        )
                        []
                        (enumerate 0 (- (length pl) 1))
                    )
                )
            )
            (fold (+) [] (ref-U|LST::UC_RemoveItem fl [BAR]))
        )
    )
    (defun URC_ActiveSwpairs:[string] ()
        @doc "Outputs all current Existing Swpairs where <can-swap> = true. Used by \
            \ routing (<SWPI::URC_Hopper>) so a disabled pool never enters the BFS \
            \ graph as a hop candidate in the first place, instead of being picked \
            \ by BFS and only rejected afterwards deep inside \
            \ <SPWU|X>SMART-SWAP> with no fallback. Audit ref: #19H."
        (filter (lambda (swpair:string) (UR_CanSwap swpair)) (URC_Swpairs))
    )
    (defun URC_LpComposer:[string] (pool-tokens:[object{SwapperV4.PoolTokens}] weights:[decimal] amp:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pool-token-ids:[string] (UC_ExtractTokens pool-tokens))
                (l:integer (length pool-token-ids))
                (pool-token-names:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Name (at idx pool-token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
                (pool-token-tickers:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Ticker (at idx pool-token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-U|SWP::UC_LpID pool-token-names pool-token-tickers weights amp)
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1]Returns a List of SWPPairs that are owned by a given Account for Management Purposes
    (defun URH_OwnedSwapPairs:[string] (account:string)
        @doc "Returns all SWPPairs that can be managed by the given <account>"
        (map (at "id")
            (select SWP|Pairs ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;[URCi] cost readers — single cost source per op. Enable*/ToggleAddOrSwap composers -> Phase 1.2.
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_OwnerKonto entity-id) 4.0)
        )
    )
    (defun URCi_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ChangeOwnership" "auth")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ModifyCanChangeOwner" "auth")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ModifyWeights" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateAmplifier" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateFee" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateSpecialFeeTargets" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    (defun URCi_ToggleFeeLockStoa:decimal (swpair:string toggle:bool)
        @doc "STOA leg of a fee-lock toggle: locking is free, unlocking costs the fee-unlock \
            \ price. Read-only twin of the <XI_ToggleFeeLock> return that <C_ToggleFeeLock> \
            \ hands to <XE_CollectStoa>, so the INFO_ preview and the charge move as one. \
            \ Mirrors DPTF's <URCi_ToggleFeeLockStoa>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
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
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableFrozenLP: if no frozen link exists yet, the VST \
            \ create-frozen-link cost; otherwise the medium IGNIS price on the pool owner \
            \ (output == existing link). Re-derived purely (XI_EnableFrozenLP is a free write)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-VST:module{VestingV2} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
            )
            (if (= current-frozen-link BAR)
                (ref-VST::URCi_CreateSpecialTrueFungibleLink lp-id)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-IGNIS::UC_IgnisLeg "tier-medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-frozen-link]
                )
            )
        )
    )
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableSleepingLP: if no sleeping link exists yet, the VST \
            \ create-sleeping-link (vzh-tag 2) cost; otherwise the medium IGNIS price on the \
            \ pool owner (output == existing link). Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-VST:module{VestingV2} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
            )
            (if (= current-sleeping-link BAR)
                (ref-VST::URCi_CreateSpecialOrtoFungibleLink lp-id 2)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-IGNIS::UC_IgnisLeg "tier-medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-sleeping-link]
                )
            )
        )
    )
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string toggle:bool add-or-swap:bool)
        @doc "Cost preview for C_ToggleAddOrSwap: the base 5x-biggest IGNIS price (ico0) plus, \
            \ when enabling add-liquidity (toggle), the one-time LP burn/mint + per-pool-token \
            \ fee-exemption role bootstrap that only bills for roles not already set (ico1). \
            \ Role costs use DPTF's own toggle-role cumulators; XE_CanAddOrSwapToggle is a free \
            \ write. Re-derived purely from the live role states."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (if toggle
                        (let
                            (
                                (pt-ids:[string] (UR_PoolTokens swpair))
                                (amp:decimal (UR_Amplifier swpair))
                                (ptts:[string]
                                    (if (= amp -1.0)
                                        (drop 1 pt-ids)
                                        pt-ids
                                    )
                                )
                                (lp-id:string (UR_TokenLP swpair))
                                (lp-burn-role:bool (ref-DPTF::UR_AccountRoleBurn lp-id SWP|SC_NAME))
                                (lp-mint-role:bool (ref-DPTF::UR_AccountRoleMint lp-id SWP|SC_NAME))
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (if (not lp-burn-role)
                                        (ref-DPTF::URCi_ToggleBurnRole lp-id)
                                        EOC
                                    )
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (if (not lp-mint-role)
                                        (ref-DPTF::URCi_ToggleMintRole lp-id)
                                        EOC
                                    )
                                )
                                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                                    (fold
                                        (lambda
                                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                            (ref-U|LST::UC_AppL
                                                acc
                                                (if (not (ref-DPTF::UR_AccountRoleFeeExemption (at idx ptts) SWP|SC_NAME))
                                                    (ref-DPTF::URCi_ToggleFeeExemptionRole (at idx ptts))
                                                    EOC
                                                )
                                            )
                                        )
                                        []
                                        (enumerate 0 (- (length ptts) 1))
                                    )
                                )
                                (ico4:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                )
                            )
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico2 ico3 ico4] [])
                        )
                        EOC
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_FeeSplit (input:object{SwapperV4.FeeSplit})
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (tg:string (at "target" input))
                (v:integer (at "value" input))
            )
            (ref-DALOS::UEV_EnforceAccountExists tg)
            (enforce (and (>= v 1)(<= v 100000)) "Invalid Splitting Value in Split Object")
        )
    )
    (defun UEV_id (swpair:string)
        (with-default-read SWP|Pairs swpair
            { "unlocks" : -1 }
            { "unlocks" := u }
            (enforce
                (>= u 0)
                (format "SWP-Pair {} does not exist." [swpair])
            )
        )
    )
    (defun UEV_CanChangeOwnerON (swpair:string)
        (UEV_id swpair)
        (let
            (
                (x:bool (UR_CanChangeOwner swpair))
            )
            (enforce (= x true) (format "SWP Pair {} ownership cannot be changed" [swpair]))
        )
    )
    (defun UEV_AsymetricState (state:bool)
        (let
            (
                (x:bool (UR_Asymetric))
            )
            (enforce (= x state) (format "Asymetric Liquidity must be set to {} for this operation" [state]))
        )
    )
    (defun UEV_FeeLockState (swpair:string state:bool)
        (let
            (
                (x:bool (UR_FeeLock swpair))
            )
            (enforce (= x state) (format "Fee-lock for SWP Pair {} must be set to {} for this operation" [swpair state]))
        )
    )
    (defun UEV_PoolFee (fee:decimal)
        @doc "Enforces <fee> is a valid pool fee amount. \
            \ #53L fix: units are per-mille (parts per 1000) — the actual swap math \
            \ (16_SWPI.pact's <fselp>/<ofs>) treats 1000.0 as the full-fee basis, so \
            \ e.g. fee=10.0 means 1%. The 320.0 max (32%) is deliberate, not arbitrary: \
            \ this same bound gates all three fee components a pool can carry — LP fee, \
            \ special-target fee, and liquid-boost fee — mirrored to the identical cap, \
            \ so their combined worst case is 320.0*3 = 960 promille, always leaving at \
            \ least 40 promille (4%) of every swap that fees can never fully consume."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (fee-prec:integer (ref-U|CT::CT_FEE_PRECISION))
            )
            (enforce
                (= (floor fee fee-prec) fee)
                (format "SWP Pool Fee amount of {} is invalid decimal wise" [fee])
            )
            (enforce (and (>= fee 0.0001) (<= fee 320.0)) (format "SWP Pool Fee amount of {} is invalid size wise" [fee]))
        )
    )
    (defun UEV_New (t-ids:[string] w:[decimal] amp:decimal)
        (let
            (
                (n:integer (length t-ids))
                (SP3:[string] (if (= amp -1.0) (UR_Pools P3) (UR_Pools S3)))
                (SP4:[string] (if (= amp -1.0) (UR_Pools P4) (UR_Pools S4)))
                (SP5:[string] (if (= amp -1.0) (UR_Pools P5) (UR_Pools S5)))
                (SP6:[string] (if (= amp -1.0) (UR_Pools P6) (UR_Pools S6)))
                (SP7:[string] (if (= amp -1.0) (UR_Pools P7) (UR_Pools S7)))
                (msg:string "Pool already exists for given Tokens!")
            )
            (cond
                ((= n 2) (UEV_CheckTwo t-ids w amp))
                ((= n 3) (enforce (not (UEV_CheckAgainstMass t-ids SP3)) msg))
                ((= n 4) (enforce (not (UEV_CheckAgainstMass t-ids SP4)) msg))
                ((= n 5) (enforce (not (UEV_CheckAgainstMass t-ids SP5)) msg))
                ((= n 6) (enforce (not (UEV_CheckAgainstMass t-ids SP6)) msg))
                ((= n 7) (enforce (not (UEV_CheckAgainstMass t-ids SP7)) msg))
                true
            )
        )
    )
    (defun UEV_CheckTwo (token-ids:[string] w:[decimal] amp:decimal)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (e0:string (at 0 token-ids))
                (e1:string (at 1 token-ids))
                (swp1:string (ref-U|SWP::UC_PoolID token-ids w amp))
                (swp2:string (ref-U|SWP::UC_PoolID [e1 e0] w amp))
                (t1:bool (URC_CheckID swp1))
                (t2:bool (URC_CheckID swp2))
            )
            (enforce (not t1) (format "Pair {} must not exist" [swp1]))
            (enforce (not t2) (format "Pair {} must not exist" [swp2]))
        )
    )
    (defun UEV_CheckAgainstMass:bool (token-ids:[string] present-pools:[string])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (fold
                (lambda
                    (acc:bool idx:integer)
                    (or
                        acc
                        (UEV_CheckAgainst token-ids (ref-U|SWP::UC_TokensFromSwpairString (at idx present-pools)))
                    )
                )
                false
                (enumerate 0 (- (length present-pools) 1))
            )
        )
    )
    (defun UEV_CheckAgainst:bool (token-ids:[string] pool-tokens:[string])
        (fold
            (lambda
                (acc:bool idx:integer)
                (and acc (contains (at idx token-ids) pool-tokens))
            )
            true
            (enumerate 0 (- (length token-ids) 1))
        )
    )
    (defun UEV_FrozenLP (swpair:string state:bool)
        (let
            (
                (frozen-lp:bool (UR_IzFrozenLP swpair))
            )
            (enforce (= state frozen-lp) (format "Swpair {} must have its Frozen-LP set to {} for this operation" [swpair state]))
        )
    )
    (defun UEV_SleepingLP (swpair:string state:bool)
        (let
            (
                (sleeping-lp:bool (UR_IzSleepingLP swpair))
            )
            (enforce (= state sleeping-lp) (format "Swpair {} must have its Sleeping-LP set to {} for this operation" [swpair state]))
        )
    )
    (defun CAP_Owner (swpair:string)
        @doc "Enforces SWPair Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto swpair))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWP|S>WEIGHTS
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal])
        (P|UEV_IMC)
        (with-capability (SWP|S>WEIGHTS swpair new-weights)
            (update SWP|Pairs swpair
                {"weights"  : new-weights}
            )
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWP|S>UPDATE-SUPPLIES
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal])
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-SUPPLIES swpair new-supplies)
            (let
                (
                    (pool-tokens:[string] (UR_PoolTokens swpair))
                    (new-pool-tokens:[object{SwapperV4.PoolTokens}]
                        (zip (lambda (x:string y:decimal) { "token-id": x, "token-supply": y }) pool-tokens new-supplies)
                    )
                )
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (current-pool-tokens:[object{SwapperV4.PoolTokens}] (UR_PoolTokenObject swpair))
                (id-pos:integer (URv_PoolTokenPosition swpair id))
                (new:object{SwapperV4.PoolTokens} { "token-id" : id, "token-supply" : new-supply})
                (new-pool-tokens:[object{SwapperV4.PoolTokens}] (ref-U|LST::UC_ReplaceAt current-pool-tokens id-pos new))
            )
            (with-capability (SWP|S>UPDATE-SUPPLY swpair id new-supply)
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal)
        @doc "Forward writer: sets stoa-value on SWP|Pairs. Requires P|UEV_IMC; pool row must exist (UEV_id)."
        (P|UEV_IMC)
        (update SWP|Pairs swpair
            {"stoa-value" : new-stoa-value}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_Issue:string (account:string pool-tokens:[object{SwapperV4.PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Forward writer: inserts the new SWP|Pairs row, registers the LP tracker \
            \ (C9 fix), saves the pool, and deploys token accounts. \
            \ #52L fix (R4): returns the newly-constructed <swpair> ID — callers \
            \ (e.g. SWPI::C_Issue, MTX-SWP::MTX|C_Issue) need it back to finish \
            \ building their own response/continue the issuance flow."
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (n:integer (length pool-tokens))
                (what:bool (if (= amp -1.0) true false))
                (pool-token-ids:[string] (UC_ExtractTokens pool-tokens))
                (swpair:string (ref-U|SWP::UC_PoolID pool-token-ids weights amp))
                (ptte:[string]
                    (if (= amp -1.0)
                        (drop 1 pool-token-ids)
                        pool-token-ids
                    )
                )
            )
            (insert SWP|Pairs swpair
                {"id"                   : swpair
                ,"owner-konto"          : account
                ,"can-change-owner"     : true
                ,"can-add"              : false
                ,"can-swap"             : false

                ,"genesis-weights"      : weights
                ,"weights"              : weights
                ,"genesis-ratio"        : pool-tokens
                ,"pool-tokens"          : pool-tokens
                ,"token-lp"             : token-lp

                ,"fee-lp"               : fee-lp
                ,"fee-special"          : 0.0
                ,"fee-special-targets"  : [SWP|EMPTY-TARGET]
                ,"fee-lock"             : false
                ,"unlocks"              : 0

                ,"amplifier"            : amp
                ,"primality"            : p
                ,"frozen-lp"            : false
                ,"sleeping-lp"          : false
                ,"stoa-value"           : 0.0
                }
            )
            ;;C9 fix: SWP|LP must be populated by EVERY issuance path. Folded here (both <token-lp> and
            ;;<swpair> are already in scope) instead of leaving it a standalone call each caller must
            ;;remember — 16_SWPI.pact::C_Issue did remember; 20_MTX-SWP.pact::MTX|C_Issue (the defpact
            ;;path, which also calls XE_Issue) never did, so every pool issued through it had an LP token
            ;;that could never be resolved back to its swpair (UR_GetLpSwpair hard-aborts on the missing
            ;;row), permanently blocking AQP LP-stake admission for that pool.
            (XE_AddLPTracker token-lp swpair)
            (with-capability (P|SECURE-CALLER)
                (XI_SavePool n what swpair)
                (ref-DPTF::XBv_DeployAccount token-lp account)
                (map
                    (lambda
                        (id:string)
                        (ref-DPTF::XBv_DeployAccount id SWP|SC_NAME)
                    )
                    ptte
                )
                swpair
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool)
        @doc "#55L fix: removed a redundant second guard check that used to sit here — \
            \ it re-ran UEV_Any against [local-guard] + (P|UR_IMP), the exact same list \
            \ P|UEV_IMC (above) already checked, plus one extra local guard. Since P|UEV_IMC \
            \ is a bare statement (not wrapped in try) and aborts the whole tx on \
            \ failure, reaching this point already proves (P|UR_IMP) alone contains a \
            \ passing guard — adding local-guard to an already-guaranteed-passing OR-set \
            \ can never change the outcome. Pure dead weight, safely removed."
        (P|UEV_IMC)
        (if add-or-swap
            (update SWP|Pairs swpair
                {"can-add"                      : toggle}
            )
            (update SWP|Pairs swpair
                {"can-swap"                     : toggle}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_AddLPTracker (lp-id:string swpair:string)
        (P|UEV_IMC)
        (insert SWP|LP lp-id
            {"swpair"                           : swpair}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: SWP|S>RT_OWN
    (defun XI_ChangeOwnership (swpair:string new-owner:string)
        (require-capability (SWP|S>RT_OWN swpair new-owner))
        (update SWP|Pairs swpair
            {"owner-konto"                      : new-owner}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementFeeUnlocks (swpair:string)
        (require-capability (SECURE))
        (with-read SWP|Pairs swpair
            { "unlocks" := u }
            (update SWP|Pairs swpair
                {"unlocks" : (+ u 1)}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>RT_CAN-CHANGE
    (defun XI_ModifyCanChangeOwner (swpair:string new-boolean:bool)
        (require-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean))
        (update SWP|Pairs swpair
            {"can-change-owner"                 : new-boolean}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SavePool (n:integer what:bool swpair:string)
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (vars
                    (cond
                        ((= n 2) (if what [(UR_Pools P2) P2] [(UR_Pools S2) S2]))
                        ((= n 3) (if what [(UR_Pools P3) P3] [(UR_Pools S3) S3]))
                        ((= n 4) (if what [(UR_Pools P4) P4] [(UR_Pools S4) S4]))
                        ((= n 5) (if what [(UR_Pools P5) P5] [(UR_Pools S5) S5]))
                        ((= n 6) (if what [(UR_Pools P6) P6] [(UR_Pools S6) S6]))
                        ((= n 7) (if what [(UR_Pools P7) P7] [(UR_Pools S7) S7]))
                        true
                    )
                )
                (sp-n:[string] (at 0 vars))
                (SPN:string (at 1 vars))
            )
            (if (= sp-n [BAR])
                (update SWP|Pools SPN
                    {"pools" : [swpair]}
                )
                (update SWP|Pools SPN
                    {"pools" : (ref-U|LST::UC_AppL sp-n swpair)}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>TG_FEE-LOCK
    (defun XI_ToggleFeeLock:[decimal] (swpair:string toggle:bool)
        @doc "Writes the new fee-lock state. \
            \ #52L fix (R4): returns [virtual-gas-cost(IGNIS) native-gas-cost(STOA)] — \
            \ [0.0 0.0] when locking (toggle=true, free); the unlock price when unlocking \
            \ (toggle=false). The caller (C_ToggleFeeLock) bills this back to the patron. \
            \ NOT scaled by <UR_FeeUnlocks>: the escalating ladder was retired 2026-09-06 for \
            \ a FLAT IGNIS::UC_FeeUnlockPrice, and this doc described the dead model."
        (require-capability (SWP|C>TG_FEE-LOCK swpair toggle))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (update SWP|Pairs swpair
                { "fee-lock" : toggle}
            )
            (if (= toggle true)
                [0.0 0.0]
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>UPDATE-AMPLIFIER
    (defun XI_UpdateAmplifier (swpair:string new-amplifier:decimal)
        (with-capability (SWP|S>UPDATE-AMPLIFIER swpair new-amplifier)
            (update SWP|Pairs swpair
                {"amplifier" : new-amplifier}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>UPDATE-FEE
    (defun XI_UpdateFee (swpair:string new-fee:decimal lp-or-special:bool)
        (require-capability (SWP|S>UPDATE-FEE swpair new-fee))
        (if lp-or-special
            (update SWP|Pairs swpair
                {"fee-lp"                         : new-fee}
            )
            (update SWP|Pairs swpair
                {"fee-special"                    : new-fee}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SPW|S>UPDATE_SPECIAL-FEE-TARGETS
    (defun XI_UpdateSpecialFeeTargets (swpair:string targets:[object{SwapperV4.FeeSplit}])
        (require-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets))
        (update SWP|Pairs swpair
            {"fee-special-targets"                : targets}
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>ENABLE-FROZEN
    (defun XI_EnableFrozenLP (swpair:string)
        (require-capability (SWP|C>ENABLE-FROZEN swpair))
        (update SWP|Pairs swpair
            {"frozen-lp"    : true}
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>ENABLE-SLEEPING
    (defun XI_EnableSleepingLP (swpair:string)
        (require-capability (SWP|C>ENABLE-SLEEPING swpair))
        (update SWP|Pairs swpair
            {"sleeping-lp"    : true}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
            \ least 2 would remain defined, AND <principal> isn't currently a \
            \ 'major' principal — #65eL, URC_IsMajorPrincipal). SWPT's storage is \
            \ principal-agnostic (#21H), so removal of a minor principal is safe \
            \ — it only affects future SWPI::UEV_Issue principal-anchoring \
            \ validation, never existing routing. Major principals (currently a \
            \ member of the primordial pool — always OURO/WSTOA/SSTOA in practice) are \
            \ never removable here regardless of the floor; retiring one requires \
            \ redefining the primordial pool itself (SWP|A_DefinePrimordialPool). \
            \ A_RotatePrincipal remains available as an atomic, count-preserving \
            \ alternative for minor principals — it never touches the floor or \
            \ cap, but is equally blocked from rotating a major principal away."
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read SWP|Properties SWP|INFO
                { "principals" := pp }
                (with-capability (SWP|C>PRINCIPAL principal add-or-remove)
                    (if add-or-remove
                        (if (= pp [BAR])
                            (update SWP|Properties SWP|INFO
                                {"principals" : [principal]}
                            )
                            (update SWP|Properties SWP|INFO
                                {"principals" : (ref-U|LST::UC_AppL pp principal)}
                            )
                        )
                        (let
                            (
                                (pp-position:integer (at 0 (ref-U|LST::UC_Search pp principal)))
                            )
                            (update SWP|Properties SWP|INFO
                                {"principals" : (ref-U|LST::UC_RemoveItem pp (at pp-position pp))}
                            )
                        )
                    )
                )
            )
        )
    )
    (defun A_RotatePrincipal (old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one call — the \
            \ count-preserving alternative to a separate remove-then-add via \
            \ A_UpdatePrincipal (Fix #14/#21H second follow-up re-allowed standalone \
            \ removal, floor-gated at 2 remaining; this doc previously claimed \
            \ removal was disabled entirely, stale since that fix — #65dL). Never \
            \ interacts with the 7-principal cap either way. Safe with respect to \
            \ SWPT's routing graph (#21H fix) — SWPT's storage is principal-agnostic, \
            \ so rotating (or removing) a MINOR principal never orphans anything \
            \ there; the only effect is on future SWPI::UEV_Issue principal- \
            \ anchoring validation. <old> being a 'major' principal (currently a \
            \ member of the primordial pool — always OURO/WSTOA/SSTOA in practice) is \
            \ rejected outright regardless of everything else (#65eL, \
            \ URC_IsMajorPrincipal) — majors are fixed, retirable only by \
            \ redefining the primordial pool itself (SWP|A_DefinePrimordialPool)."
        (P|UEV_IMC)
        (with-read SWP|Properties SWP|INFO
            { "principals" := pp }
            (with-capability (SWP|C>ROTATE-PRINCIPAL old new)
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (pos:integer (at 0 (ref-U|LST::UC_Search pp old)))
                    )
                    (update SWP|Properties SWP|INFO
                        {"principals" : (ref-U|LST::UC_ReplaceAt pp pos new)}
                    )
                )
            )
        )
    )
    (defun A_UpdateLimit (limit:decimal spawn:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>LIMIT)
            (if spawn
                (update SWP|Properties SWP|INFO
                    {"spawn-limit" : limit}
                )
                (update SWP|Properties SWP|INFO
                    {"inactive-limit" : limit}
                )
            )
        )
    )
    (defun A_UpdateLiquidBoost (new-boost-variable:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>LQBOOST new-boost-variable)
            (update SWP|Properties SWP|INFO
                {"liquid-boost" : new-boost-variable}
            )
        )
    )
    (defun A_DefinePrimordialPool (primordial-pool:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>DEFINE-PRIMORDIAL-POOL primordial-pool)
            (update SWP|Properties SWP|INFO
                {"primordial-pool" : primordial-pool}
            )
        )
    )
    (defun A_ToggleAsymetricLiquidityAddition (patron:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>TG-ASYMETRIC-LQ toggle)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    (ignis-id:string (ref-DALOS::UR_IgnisID))
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                    ;;
                    (ignis-burn-role:bool (ref-DPTF::UR_AccountRoleBurn ignis-id SWP|SC_NAME))
                    (ouro-mint-role:bool (ref-DPTF::UR_AccountRoleMint ouro-id SWP|SC_NAME))
                    (ignis-fee-exemption-role:bool (ref-DPTF::UR_AccountRoleFeeExemption ignis-id SWP|SC_NAME))
                    (ignis-fee-exemption-roleV2:bool (ref-DPTF::UR_AccountRoleFeeExemption ignis-id vst-sc))
                )
                (if (not ignis-burn-role)
                    (ref-DPTF::C_ToggleBurnRole patron (ref-DPTF::UR_Konto ignis-id) SWP|SC_NAME ignis-id true)
                    true
                )
                (if (not ouro-mint-role)
                    (ref-DPTF::C_ToggleMintRole patron (ref-DPTF::UR_Konto ouro-id) SWP|SC_NAME ouro-id true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto ignis-id) SWP|SC_NAME ignis-id true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto ignis-id) vst-sc ignis-id true)
                    true
                )
                (update SWP|Asymmetry SWP|INFO
                    {"asymmetric" : toggle}
                )
            )
        )
    )
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string)
        @doc "BINDS <executor> to <entity-id>'s owner. Ownership is proven INDIRECTLY by the \
            \ branding capability; this supplies the other half -- that the account the caller \
            \ NAMED is that owner. (patron/executor canon 2.2, indirect route named.)"
        (enforce (= executor (UR_OwnerKonto entity-id)) "Executor is not the Entity Owner")
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <entity-id>'s pending branding. <executor> is bound to the entity OWNER; \
            \ ownership itself is proven by SWP|C>UPDATE-BRD. The binding is what keeps the \
            \ parameter from being a name nobody reads."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (SWP|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (SWP|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id executor months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-owner:string)
        (P|UEV_IMC)
        (with-capability (SWP|S>RT_OWN swpair new-owner)
            (XI_ChangeOwnership swpair new-owner)
            (URCi_ChangeOwnership swpair)
        )
    )
    (defun C_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>ENABLE-FROZEN swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-VST:module{VestingV2} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                )
                (XI_EnableFrozenLP swpair)
                (if (= current-frozen-link BAR)
                    ;;PROVISIONAL EXECUTOR SLOT (HANDOFF 4e) -- twin of the one in
                    ;;C_EnableSleepingLP below; same reasoning, same account (the LP TOKEN's
                    ;;owner, not the pool's -- see there). Found by
                    ;;_callarity.py, NOT by the grep that found its twin: that grep was truncated
                    ;;with `head -4` and this line sat past the cut. Re-pointed at 15_SWP's turn.
                    (ref-VST::C_CreateFrozenLink patron (ref-DPTF::UR_Konto lp-id) lp-id)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisLeg "tier-medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-frozen-link]
                    )
                )
            )
        )
    )
    (defun C_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>ENABLE-SLEEPING swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-VST:module{VestingV2} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                )
                (XI_EnableSleepingLP swpair)
                (if (= current-sleeping-link BAR)
                    ;;PROVISIONAL EXECUTOR SLOT (HANDOFF 4e) -- 15_SWP's own turn is module 13
                    ;;and has not come, so there is no `executor` here to thread. The rule is to
                    ;;pass the account that actually INITIATES, never a placeholder: that is the
                    ;;LP TOKEN's owner. NOT the pool owner -- that was the first guess and the
                    ;;suite refused it with "Executor is not the Token Owner": VST's binder
                    ;;enforces executor == (UR_Konto lp-id), and an LP token is held by a SMART
                    ;;account while the swpair's owner-konto is the human. Exactly the handoff's
                    ;;"executor = patron is not a safe default" warning, one level along.
                    ;;Re-pointed at 15_SWP's turn; listed in AUDIT-V2-DELTA.
                    (ref-VST::C_CreateSleepingLink patron (ref-DPTF::UR_Konto lp-id) lp-id)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisLeg "tier-medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-sleeping-link]
                    )
                )
            )
        )
    )
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-boolean:bool)
        (P|UEV_IMC)
        (with-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean)
            (XI_ModifyCanChangeOwner swpair new-boolean)
            (URCi_ModifyCanChangeOwner swpair)
        )
    )
    (defun C_ModifyWeights:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-weights:[decimal])
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XB_ModifyWeights swpair new-weights)
            (URCi_ModifyWeights swpair)
        )
    )
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string toggle:bool add-or-swap:bool)
        @doc "#71L: called directly (cross-module C_->C_) by SWPU::C_ToggleSwapCapability and \
            \ SWPLC::C_ToggleAddLiquidity, instead of through an XE_* forward entrypoint — \
            \ intentional, DESIGN-accepted, not an oversight. This function is not a plain \
            \ toggle write: it bills real IGNIS (ico0), bootstraps LP burn/mint/fee-exemption \
            \ roles the first time add-liquidity is enabled (ico1-ico4), and — critically — is \
            \ the ONLY place in this call chain that enforces pool ownership, via \
            \ SWP|C>ADD-OR-SWAP's composed CAP_Owner. The existing XE_CanAddOrSwapToggle does \
            \ none of that (only P|UEV_IMC + a raw update, no ownership check) and would need to \
            \ replicate all of the above to be a safe drop-in replacement for either caller — \
            \ neither SWPU::SPWU|C>TOGGLE-SWAP nor SWPLC::P|SWPLC|CALLER re-derives ownership \
            \ independently, so rerouting through the bare XE_* today would silently strip \
            \ authorization. Left as-is; a properly-capped XE_* replacement is real design work, \
            \ not a mechanical rename — deferred, not attempted here."
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (P|GOVERNING-CALLER)
                        (if toggle
                            (let
                                (
                                    (pt-ids:[string] (UR_PoolTokens swpair))
                                    (amp:decimal (UR_Amplifier swpair))
                                    (ptts:[string]
                                        (if (= amp -1.0)
                                            (drop 1 pt-ids)
                                            pt-ids
                                        )
                                    )
                                    (lp-id:string (UR_TokenLP swpair))
                                    (lp-burn-role:bool (ref-DPTF::UR_AccountRoleBurn lp-id SWP|SC_NAME))
                                    (lp-mint-role:bool (ref-DPTF::UR_AccountRoleMint lp-id SWP|SC_NAME))
                                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                                        (if (not lp-burn-role)
                                            (ref-DPTF::C_ToggleBurnRole patron (ref-DPTF::UR_Konto lp-id) SWP|SC_NAME lp-id true)
                                            EOC
                                        )
                                    )
                                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                                        (if (not lp-mint-role)
                                            (ref-DPTF::C_ToggleMintRole patron (ref-DPTF::UR_Konto lp-id) SWP|SC_NAME lp-id true)
                                            EOC
                                        )
                                    )
                                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                                        (fold
                                            (lambda
                                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                                (ref-U|LST::UC_AppL
                                                    acc
                                                    (if (not (ref-DPTF::UR_AccountRoleFeeExemption (at idx ptts) SWP|SC_NAME))
                                                        (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto (at idx ptts)) SWP|SC_NAME (at idx ptts) true)
                                                        EOC
                                                    )
                                                )
                                            )
                                            []
                                            (enumerate 0 (- (length ptts) 1))
                                        )
                                    )
                                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                    )
                                )
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico2 ico3 ico4] [])
                            )
                            EOC
                        )
                    )
                )
            )
            (with-capability (SWP|C>ADD-OR-SWAP swpair toggle add-or-swap)
                (XE_CanAddOrSwapToggle swpair toggle add-or-swap)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
        )
    )
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>TG_FEE-LOCK swpair toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleFeeLock swpair toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads fee-unlocks BEFORE XI_IncrementFeeUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleFeeLock swpair toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XI_IncrementFeeUnlocks swpair)
                        (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    (defun C_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string amp:decimal)
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-AMPLIFIER swpair amp)
            (XI_UpdateAmplifier swpair amp)
            (URCi_UpdateAmplifier swpair)
        )
    )
    (defun C_UpdateFee:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-fee:decimal lp-or-special:bool)
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-FEE swpair new-fee)
            (XI_UpdateFee swpair new-fee lp-or-special)
            (URCi_UpdateFee swpair)
        )
    )
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string targets:[object{SwapperV4.FeeSplit}])
        (P|UEV_IMC)
        (with-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets)
            (XI_UpdateSpecialFeeTargets swpair targets)
            (URCi_UpdateSpecialFeeTargets swpair)
        )
    )
    (defun AU_SwapPairs (ids:[string])
        @doc "Get <ids> with <(keys SWP|Pairs)>, or update one a time"
        (with-capability (AHU)
            (map (AU_SwapPair) ids)
        )
    )
    (defun AU_SwapPair (id:string)
        (require-capability (SECURE))
        (update SWP|Pairs id
            {"id"       : id}
        )
    )

)

;; --- tables for 15_SWP.pact (7 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SWP|Properties)
;; (create-table SWP|Asymmetry)
;; (create-table SWP|Pairs)
;; (create-table SWP|Pools)
;; (create-table SWP|LP)

