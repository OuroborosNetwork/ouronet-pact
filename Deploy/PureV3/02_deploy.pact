;; TX 02/08 -- OUROBOROS, TS01-C2, TS01-C3, DPDC-S    (~265,996 B, ~116k gas)
;;
;; OUROBOROS 2.16.1: `IGNIS|XB>COMPRESS` was evented alongside `IGNIS|C>COMPRESS`, its own main-
;;           capability twin. With both evented an indexer counting compressions DOUBLE-COUNTS
;;           every one performed internally by another module. The clearest harm in the sweep.
;; TS01-C2   Six format defects -- not canon violations but real: ATS `C_AddSecondary` had its two
;;           arguments SWAPPED (it named the pair where the reward token belonged and vice versa);
;;           `CC_RemoveSecondary` and `C_DirectRecovery` passed the pair id to a string with no
;;           placeholder for it.
;; TS01-C3   The three `SWP|C_Toggle*` wrappers: zero placeholders, one argument. The pair id was
;;           discarded on every toggle.
;; DPDC-S    2.16.2, the CORE half: `set-class` was computed, used, and dropped into an empty
;;           cumulator output -- and `UDC_ConcatenateOutputCumulators` REPLACES output rather than
;;           merging, so `[]` actively discarded it. Surfacing it is what lets the six set-
;;           definition wrappers in TX 04 report it.
;;
;; ROUND V3 -- the StoicSyntax 2.16 canon sweep. EIGHT transactions, nineteen modules.
;;
;; TWO OWNER RULINGS, 2026-10-06, both from one observation: a score was issued, and the block
;; explorer could tell you neither what had happened nor what had been created.
;;
;;   2.16.1  Only the MAIN capability of a C_/A_ entrypoint may be @event; an internal
;;           XI_/XE_/XB_ capability may not. One operation emitting two events is
;;           indistinguishable, to anything reading the chain, from two operations. 8 fixed.
;;   2.16.2  An issuance must return the id it GENERATED. The name the caller typed is an INPUT;
;;           the id is the only thing the transaction produced. 11 fixed.
;;
;; WHY EIGHT AND NOT THREE. Gas scales as the SEVENTH POWER of transaction size on this network
;; (measured: 3 x ~256 KB = ~285,675 gas against ~202,525,154 for one 768 KB transaction), which
;; puts the per-transaction ceiling at ~395 KB / 2.00M gas. Consolidating this round into 3 files
;; of ~692 KB was tried and would have cost ~100,000,000 gas EACH -- fifty times the limit. Six
;; transactions is impossible; seven puts 80% of the budget on one of them. Eight is the smallest
;; count that keeps every transaction an order of magnitude clear, and totals ~1.17M gas.
;;
;; ORDER IS LOAD-BEARING, AND IT RUNS THROUGH THE FILES, NOT JUST BETWEEN THEM. Modules inside one
;; transaction deploy top to bottom, so a dot-callee need only PRECEDE its callers in the overall
;; sequence. Two cascades fix that sequence:
;;
;;   AcquisitionScoresV1 -> V2 (five URH_ definition-inspection readers). A module holding
;;   `module{AcquisitionScoresV1} AQP-SCORE` fails its modref check once AQP-SCORE implements only
;;   V2. The interface ships in 03; every module naming it ships in 04 or later.
;;
;;   DOT-PIN. A dot call resolves at the CALLER's deploy time, so a caller not redeployed keeps the
;;   old callee -- and because these callees own tables, it does not go stale, it ABORTS with
;;   "hash not blessed". `_purev3.py --check` re-derives the whole ordering and fails on a breach.
;;
;; DEPLOY IN NUMERIC ORDER. Seven of the nineteen modules contain no edit of their own and are here
;; purely to stay in step; skipping one breaks it.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev3.py

(namespace "ouronet-ns")

;; ---- source: 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact (module only -- its interface is already live)
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
        @doc "Autonomic management of <kadena-konto> of OUROBOROS Smart Account"
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
        (compose-capability (IGNIS|XB>CONVERT client))
    )
    (defcap IGNIS|XB>CONVERT (client:string)
        (UEV_Exchange)
        (compose-capability (ORBR|GOV))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap OUROBOROS|C>WITHDRAW (executor:string id:string target:string)
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-21). HANDOFF 4g, fifth instance: \
            \ <CAP_Owner id> proved the AUTHORITY -- the token owner may empty the fee purse -- \
            \ while the only account in the signature was <target>, the RECIPIENT. Authority \
            \ proven, actor unrecorded. <UEV_ExecutorIsKonto> supplies the missing half and the \
            \ ownership enforce is KEPT, not replaced: one proves the right exists, the other \
            \ proves who exercised it."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-DPTF::CAP_Owner id)
            (ref-DPTF::UEV_ExecutorIsKonto executor id)
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
        (executor:string ignis-amount:decimal)
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
            (with-capability (IGNIS|C>COMPRESS executor)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends GAS(Ignis) <ignis-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer executor executor ORBR|SC_NAME ignis-id ignis-amount true)
                        ;;02]Ouroboros burns GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Burn executor ORBR|SC_NAME ignis-id ignis-amount)
                        ;;03]Ouroboros mints OURO <ouro-remainder-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        ;;04]Ouroboros transfers OURO <ouro-remainder-amount> to <executor>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executor ouro-id ouro-remainder-amount true)
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
        (executor:string executee:string ouro-amount:decimal)
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
            (with-capability (IGNIS|C>SUBLIMATE executor executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends OURO <ouro-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer executor executor ORBR|SC_NAME ouro-id ouro-amount true)
                        ;;02]Ouroboros burns OURO <ouro-amount>
                        (ref-DPTF::C_Burn executor ORBR|SC_NAME ouro-id ouro-amount)
                        ;;03]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;04]Ouroboros transfers GAS(Ignis) <ignis-amount> to <executee>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executee ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_SublimateV2:object{IgnisCollectorV3.OutputCumulator}
        (executor:string executee:string ouro-amount:decimal)
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
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id executor))
            )
            (with-capability (IGNIS|C>SUBLIMATE executor executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Freeze Client Account for Ouro if not already frozen
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id true)
                            EOC
                        )
                        ;;02]Partialy wipe the required OURO
                        (ref-DPTF::C_WipeSlim executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id ouro-amount)
                        ;;03]Unfreeze Client Account
                        (ref-DPTF::C_ToggleFreezeAccount executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id false)
                        ;;04]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;05]Ouroboros transfers GAS(Ignis) <ignis-amount> to <executee>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executee ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_WithdrawFees:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        @doc "Withdraws the DPTF fees accrued on the OUROBOROS smart account for <id>. \
            \ Executor: the TOKEN OWNER, proven in OUROBOROS|C>WITHDRAW by CAP_Owner + \
            \ UEV_ExecutorIsKonto. Executee: the account CREDITED, enforced to be a standard \
            \ (non-smart) account -- it is merely credited and needs no signature, the same \
            \ conditional TFT::C_Transfer states for its own executee."
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
            (with-capability (OUROBOROS|C>WITHDRAW executor id executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;00]Compose base withdraw IGNIS Price
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                        ;;01]Fees move from the Ouroboros Smart DALOS Account to the executee's Normal Ouronet Account.
                        ;;PROVISIONAL PATRON SLOT CLEARED (2026-09-21, _patronslots.py): this read
                        ;;`C_Transfer target ...`, because at the time this module had no <patron>
                        ;;parameter to thread and the recipient was the only account in scope. That
                        ;;is invisible to _callarity (the arity was right) and to every assertion
                        ;;(no swept callee read the slot), which is exactly why the registry
                        ;;existed to remember it. It is now the real patron.
                        (ref-TFT::C_Transfer patron ORBR|SC_NAME executee id withdraw-amount true)
                    ]
                    []
                )
            )
        )
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact (module only -- its interface is already live)
(module TS01-C2 GOV
    @doc "TALOS Client Module for Stage 1, namely ATS VST LIQUID and OUROBOROS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientTwoV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C2                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C2))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
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
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|SWPU:module{OuronetPolicyV2} SWPU)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            ;;
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPLC::P|A_AddIMP mg)
            (ref-P|SWPU::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [ATS_Client]
    (defun ATS|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for ATSPair <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|ATS:module{BrandingUsagePrimaryV2} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|ATS::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|ATS:module{BrandingUsagePrimaryV2} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|ATS::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    (defun ATS|HOT-RBT|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for a HOT-RBT <entity-id> costing 150 IGNIS (Standard DPOF Costs)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-ATS::HOT-RBT|C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun ATS|HOT-RBT|C_Repurpose (patron:string executor:string executee:string hot-rbt:string nonce:integer)
        @doc "Repurposes a Hot-Rbt to a another Account, Can only be done by atspair owner"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_Repurpose patron executor executee hot-rbt nonce)
                )
                (format "Succesfully repurposed HOT-RBT {} Nonce {} to Account {}" [hot-rbt nonce srt])
            )
        )
    )
    ;;
    (defun ATS|C_Issue:list (patron:string executor:string ats:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string] rbt-nfr:[bool])
        @doc "Issues and Autostake Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATS::C_Issue patron executor ats index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun ATS|C_RotateOwnership (patron:string executor:string executee:string ats:string)
        @doc "Rotates ATSPair Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_RotateOwnership patron executor executee ats)
                )
                (format "Succesfully changed ownership for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_Control (patron:string executor:string ats:string can-change-owner:bool syphoning:bool hibernate:bool)
        @doc "Controls the Properties of an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_Control patron executor ats can-change-owner syphoning hibernate)
                )
                (format "Succesfully controlled ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_UpdateRoyalty (patron:string executor:string ats:string royalty:decimal)
        @doc "Updates the Royalty value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateRoyalty patron executor ats royalty)
                )
                (format "Royalty for ATS-Pair {} updated Succesfully to {} Promile" [ats royalty])
            )
        )
    )
    (defun ATS|C_UpdateSyphon (patron:string executor:string ats:string syphon:decimal)
        @doc "Updates the Syphoning Index value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateSyphon patron executor ats syphon)
                )
                (format "Syphon Index for ATS-Pair {} updated Succesfully to {}" [ats syphon])
            )
        )
    )
    (defun ATS|C_SetHibernationFees (patron:string executor:string ats:string peak:decimal decay:decimal)
        @doc "Updates the Hibernation Fees an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHibernationFees patron executor ats peak decay)
                )
                (format "Hibernation Fees for ATS-Pair {} set to {} Promile-Peak and {} Promile-Decay per Day" [ats peak decay])
            )
        )
    )
    ;;
    (defun ATS|C_ToggleParameterLock (patron:string executor:string ats:string toggle:bool)
        @doc "Toggle ATSPair Parameter Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATS::C_ToggleParameterLock patron executor ats toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
            )
        )
    )
    (defun ATS|C_AddSecondary (patron:string executor:string ats:string reward-token:string rt-nfr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddSecondary patron executor ats reward-token rt-nfr)
                )
                (if rt-nfr
                    (format "Succesfully Added {} as a secondary Reward Token for the ATS-Pair {} with Native-Fee-Recovery" [reward-token ats])
                    (format "Succesfully Added {} as a secondary Reward Token for the ATS-Pair {} without Native-Fee-Recovery" [reward-token ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_ControlColdRecoveryFees (patron:string executor:string ats:string c-nfr:bool c-fr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlColdRecoveryFees patron executor ats c-nfr c-fr)
                )
                (format "Succesfully controlled Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryFees (patron:string executor:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryFees patron executor ats fee-positions fee-thresholds fee-array)
                )
                (format "Succesfully set Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryDuration (patron:string executor:string ats:string soft-or-hard:bool base:integer growth:integer)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryDuration patron executor ats soft-or-hard base growth)
                )
                (format "Succesfully set Cold Recovery Duration for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_ToggleElite (patron:string executor:string ats:string toggle:bool)
        @doc "Toggles ATSPair Elite Functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleElite patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Elite Mode for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Elite Mode for ATS-Pair {}" [ats])
                )
            )
        )
    )
    (defun ATS|C_ToggleUpgrade (patron:string executor:string ats:string toggle:bool)
        @doc "Sets can-upgrade for an ATS-Pair (audit finding #21L / L3). Gates C_Control \
            \ (can-change-owner/syphoning/hibernate) - false blocks C_Control entirely \
            \ until set back to true."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleUpgrade patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully allowed further Property Upgrades (can-upgrade) for ATS-Pair {}" [ats])
                    (format "Succesfully blocked further Property Upgrades (can-upgrade) for ATS-Pair {} - C_Control is now disabled until this is turned back on" [ats])
                )
            )
        )
    )
    (defun ATS|C_SwitchColdRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Cold Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchColdRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Cold Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Cold Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_AddHotRBT (patron:string executor:string ats:string hot-rbt:string)
        @doc "Adds a Hot-RBT to an ATS-Pair immutably \
            \ Must be a non special DPOF Token with zero Supply \
            \ Ownership of this Token is transfered to the ATS|SC_NAME"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddHotRBT patron executor ats hot-rbt)
                )
                (format "Succesfully added DPOF {} as Hot-RBT for ATS-Pair {}" [hot-rbt ats])
            )
        )
    )
    (defun ATS|C_ControlHotRecoveryFee (patron:string executor:string ats:string h-fr:bool)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlHotRecoveryFee patron executor ats h-fr)
                )
                (format "Succesfully controlled Hot-Recovery Fee for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_SetHotRecoveryFee (patron:string executor:string ats:string promile:decimal decay:integer)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHotRecoveryFees patron executor ats promile decay)
                )
                (format "Succesfully set Hot-Recovery Fees for ATS-Pair {} to {} Promile and {} Days-Decay" [ats promile decay])
            )
        )
    )
    (defun ATS|C_SwitchHotRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchHotRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Hot Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Hot Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_SetDirectRecoveryFee (patron:string executor:string ats:string promile:decimal)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetDirectRecoveryFee patron executor ats promile)
                )
                (format "Succesfully set Direct-Recovery Fees for ATS-Pair {} to {} Promile" [ats promile])
            )
        )
    )
    (defun ATS|C_SwitchDirectRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchDirectRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Direct Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Direct Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    ;;
    (defun ATS|CC_RemoveSecondary (patron:string executor:string ats:string reward-token:string)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::CC_RemoveSecondary patron executor ats reward-token)
                )
                (format "Succesfully removed RT {} from ATS-Pair {}" [reward-token ats])
            )
        )
    )
    (defun ATS|C_WithdrawRoyalties (patron:string executor:string executee:string ats:string)
        @doc "Withdraws ATS-Pair Royalties, if non-zero"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_WithdrawRoyalties patron executor executee ats)
                )
                (format "Succesfully withdrawn Royalties from ATS-Pair {} to Account {}" [ats st])
            )
        )
    )
    (defun ATS|C_KickStart (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Kickstarst an ATSPair, so that it starts at a given Index \
            \ Can only be done on a freshly created ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_KickStart patron executor ats rt-amounts rbt-request-amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully Kickstarted ATS-Pair {} to an Index of {}" [ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Fuel (patron:string executor:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an ATSPair with RT Tokens, increasing its Index"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (prev-index:decimal (ref-ATS::URC_Index ats))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Fuel patron executor ats reward-token amount)
                )
                (format "Succesfully fueld ATS-Pair {} increasing its index by {}"
                    [ats (- (ref-ATS::URC_Index ats) prev-index)]
                )
            )
        )
    )
    (defun ATS|C_Coil (patron:string executor:string ats:string rt:string amount:decimal)
        @doc "Coils an RT Token from a specific ATS-Pair, generating a RBT Token \
        \ Only works if <ats> has hibernation off."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Coil patron executor ats rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} RBT Tokens" [amount rt ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Curl (patron:string executor:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Curl double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Both ATS-Pairs must have hibernation off for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Curl patron executor ats1 ats2 rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully curled {} {} on ATS-Pairs {} and {} generating {} RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_VestedCoil (patron:string executor:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Coils a DPTF Token and Vests its output to <target-account> \
            \ Requires that: \
            \ *]Input DPTF is part of an ATSPair, the <ats> \
            \ *]That the RBT of <ats> has a vested counterpart \
            \ \
            \ Outputs the resulted Vested Cold-RBT Amount \
            \ Only the Owner of <coil-token> can execute thi function, \
            \ as this is prerequisite for Vesting"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ref-VST:module{VestingV2} VST)
                    ;;
                    (coil-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats coil-token amount)
                    )
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Coil patron executor ats coil-token amount)
                            (ref-VST::C_Vest patron executor target-account c-rbt c-rbt-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} Vested RBT Tokens" [amount coil-token ats c-rbt-amount])
            )
        )
    )
    (defun ATS|C_VestedCurl (patron:string executor:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Same as <ATS|C_VestedCoil> but instead Curls the input Token. \
            \ Requires that : \
            \ *]Input DPTF is part of an ATSPair, the <ats1> \
            \ *]That the Cold-RBT Token of the <ats1> is RT in <ats2> \
            \ *]That Cold-RBT of <ats2> has a vested counterpat \
            \ \
            \ Outputs the resulted Vested Cold-RBT of <ats2>"
        (with-capability (P|TS)
            (let*
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ref-VST:module{VestingV2} VST)
                    ;;
                    (coil1-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 curl-token amount)
                    )
                    (coil2-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 (at "rbt-id" coil1-data) (at "rbt-amount" coil1-data))
                    )
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Curl patron executor ats1 ats2 curl-token amount)
                            (ref-VST::C_Vest patron executor target-account (at "rbt-id" coil2-data) c-rbt2-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully curled {} {} on ATS-Pair {} and {} generating {} Vested RBT Tokens of the second ATS-Pair" 
                    [amount curl-token ats1 ats2 c-rbt2-amount]
                )
            )
        )
    )
    (defun ATS|C_Constrict (patron:string executor:string ats:string rt:string amount:decimal dayz:integer)
        @doc "Constricts an RT Token from a specific ATS-Pair, generating a RBT Token in HIbernated Form \
        \ Only works if <ats> has hibernation on."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Constrict patron executor ats rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully constricted {} {} on ATS-Pair {} generating {} Hibernated RBT Tokens" 
                    [amount rt ats (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Brumate (patron:string executor:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Brumate double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Second ATS-Pair must have hibernation on for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Brumate patron executor ats1 ats2 rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully brumated {} {} on ATS-Pairs {} and {} generating {} Hibernated RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Syphon (patron:string executor:string executee:string ats:string syphon-amounts:[decimal])
        @doc "Syphons from an ATS Pair, extracting RTs and decreasing ATSPair Index. \
            \ Syphoning can be executed until the set up Syphon limit is achieved"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Syphon patron executor executee ats syphon-amounts)
                )
                (format "Succesfully syphoned {} RT Amount(s) from ATS-Pair {} to Target {}" [syphon-amounts ats st])
            )
        )
    )
    ;;
    (defun ATS|C_ColdRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Recovers Cold-RBT, disolving it, generating RTs cullable in the future. \
        \ Amount of RTs is determined by the ATS-Pair Index at the Cold Recovery Moment"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_ColdRecovery patron executor ats ra)
                )
                (format "Succesfully placed {} {} ATS-Pair RBT into Cold Recovery" [ra ats])
            )
        )
    )
    (defun ATS|C_Cull (patron:string executor:string ats:string)
        @doc "Culls an ATSPair, extracting RTs that are cullable. Fix (audit finding \
            \ #32N / N1): reports a distinct 'nothing to cull yet' message when nothing \
            \ was actually culled, instead of always claiming success - the underlying \
            \ crash-vs-graceful-empty-result fix lives in ATSU.URC_MultiCull."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ATSU::C_Cull patron executor ats)
                    )
                    (cw:[decimal] (at "output" ico))
                    (how-many-tokens:integer (length cw))
                    (total-culled:decimal (fold (+) 0.0 cw))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= total-culled 0.0)
                    (format "Nothing to Cull just yet for ATS-Pair {} - no positions have reached their cull-time" [ats])
                    (format "Succesfully Culled {} RT(s) Tokens with amounts of {} from ATS-Pair {}" [how-many-tokens cw ats])
                )
            )
        )
    )
    ;;
    (defun ATS|C_HotRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Converts a Cold-RBT to a Hot-RBT, preparing it for Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_HotRecovery patron executor ats ra)
                )
                (format "Succesfully converted {} RBT to Hot-RBT on ATS-Pair {}" [ra ats])
            )
        )
    )
    (defun ATS|C_Reverse (patron:string executor:string id:string nonce:integer)
        @doc "Reverses a Hot-RBT Nonce, converting it to Cold-RBT in its entirety \
            \ as the Hot-RBT doesnt have segmentation turned on"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Recover patron executor id nonce)
                )
                (format "Succesfully Converted Hot-RBT {} Nonce {} back into the Native RBT of ATS-Pair {}" [id nonce ats])
            )
        )
    )
    (defun ATS|C_Redeem (patron:string executor:string id:string nonce:integer)
        @doc "Redeems a Hot-RBT, recovering RTs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Redeem patron executor id nonce)
                )
                (format "Succesfully Redeemed Hot-RBT {} Nonce {} back in RTs for ATS-Pair {}" [id nonce ats])
            )
        )
    )
    ;;
    (defun ATS|C_DirectRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Directly Recovers RBT to RTs using Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_DirectRecovery patron executor ats ra)
                )
                (format "Succesfully recovered directly {} RBT Token on ATS-Pair {}" [ra ats])
            )
        )
    )
    ;;  [VST_Client]
    (defun VST|C_CreateFrozenLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Frozen Link, issuing a Special-DPTF as a frozen counterpart for another DPTF \
            \ A Frozen Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Frozen variety, is used for implementing the FROZEN Functionality for a DPTF Token \
            \ So called FROZEN Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Frozen Token. \
            \ Frozen Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ Only the <dptf> owner can create Frozen Tokens to Target Accounts, \
            \ or designate other Smart Ouronet Accounts to create them \
            \ \
            \ Frozen Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Frozen Token for adding Liquidity \
            \ generates a Frozen LP Token, which behaves similarly to the Frozen Token \
            \ that is, it can never be converted back to the SWPairs native LP, locking liquidity in place \
            \ Existing LPs can also be frozen, permanently locking liquidity \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateFrozenLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Frozen Link for the DPTF {}, issuing the Frozen DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateReservationLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Reservation Link, issuing a Special-DPTF as a reserved counterpart for another DPTF \
            \ A Reservation Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Reserved variety, is used for implementing the RESERVED Functionality for a DPTF Token \
            \ So called RESERVED Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Reserved Token. \
            \ Reserved Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ As opposed to frozen tokens, where only the <dptf> owner can generate them or designated Ouronet Accounts, \
            \ Reserved Tokens can be generated by clients, using as input the <dptf> Token, only when reservations are open by the <dptf> owner \
            \ That is, the <dptf> owner dictates when clients can generate reserved tokens from the input <dptf>, \
            \ and as such, reserved tokens can be used for special discounts when sales are planned with the main <dptf> Token, \
            \ as if they were the main <dptf> token. \
            \ \
            \ Reserved Tokens cannot be used to add liquidty on any Swpair. \
            \ \
            \ OURO will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateReservationLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Reservation Link for the DPTF {}, issuing the Reserved DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateVestingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Vesting Link, issuing a Special-DPOF as a vested counterpart for another DPTF \
            \ A Vesting Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Vested variety, is used for implementing the Vesting Functionality for a DPTF Token \
            \ The <dptf> owner has the ability to vest its <dptf> token into a vested counterpart \
            \ specifying a target account, an offset, a duration and a number of milestones as vesting parameters \
            \ \
            \ The Target account receives the vested token, and according to its input vested parameters, \
            \ can revert it back to the <dptf> counterpart, as vesting intervals expire \
            \ \
            \ Vested Tokens cannot be used to add liquidity on any Swpair \
            \ \
            \ If a Vested Counterpart is created for a Token that is a Cold-RBT in an ATS Pair, \
            \ the RT owner of that ATS Pair can <coil>|<curl> the RT Token, and subsequently <vest> the output Hot-RBT token, \
            \ thus creating an additional layer of locking, for the input <RT> token, by converting it in a Vested Hot-RBT \
            \ OURO, AURYN and ELITE-AURYN will be the first Tokens that will make use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateVestingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Vesting Link for the DPTF {}, issuing the Vested DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateSleepingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Sleeping Link, issuing a Special-DPOF as a sleeping counterpart for another DPTF \
            \ A Sleeping Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Sleeping variety, is used for implementing the Sleeping Functionality for a DPTF Token \
            \ A Sleeping DPOF is similar to a vested Token, however it has a single period after which it can be converted \
            \ in its entirety, at once, into the initial <dptf> \
            \ As opposed to Vested DPOF Tokens, multiple Sleeping DPOF Tokens, can be unified into a single Sleeping Token \
            \ using a weigthed mean to determine the final time when it can be converted back to the initial <dptf> \
            \ \
            \ As oposed to Vested Tokens, Sleeping Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Sleeping Token for adding Liquidity \
            \ generates a Sleeping LP Token, which behaves similarly to the Sleeping Token, inheriting its sleeping date, \
            \ that is, it can be converted back to the SWPairs native LP, when its sleeping interval expires \
            \ Existing LPs can also be put to sleep, locking liquidity for a given period \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateSleepingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Sleeping Link for the DPTF {}, issuing the Sleeping DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateHibernatingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Hibernating Link, issuing a Special-DPOF as a hibernating counterpart for another DPTF \
            \ A Hibernating Link is immutable, and noted in the Token Properties of both DPTF and the Special DPOF \
            \ A Special DPOF of the Hibernating variety, is used for implementing the Hibernating Functionality for a DPTF Token \
            \ A Hibernating DPOF is similar to a sleeping Token, with a few particularities. \
            \ It has a day granularity, and up to 100 years can be used for hibernating. \
            \ \
            \ In direct contrast to a Sleeping DPOF, which has to be waited up for it to be converted back to its original DPTF \
            \ the Hibernated DPOF can be converted on Demand back into its original DPTF, however there is a fee to do so, \
            \ if the hibernation period hasnt elaspsed. This fee decreases from 800 promile down to zero at its awakening time \
            \ The fee is automaticaly burned, and cannot be recovered by any means. \
            \ \
            \ Similarly to Sleeping DPOFs, multiple batches can be merged, using the same algoritm implemented for mergind of Sleeping DPOFs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_CreateHibernatingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Hibernation Link for the DPTF {}, issuing the Hibernated DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
            )
        )
    )
    ;;  [VST Freezing]
    (defun VST|C_Freeze (patron:string executor:string freeze-output:string dptf:string amount:decimal)
        @doc "Freezes a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sfa:string (ref-I|OURONET::OI|UC_ShortAccount freeze-output))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Freeze patron executor freeze-output dptf amount)
                )
                (format "Succesfully freeze {} DPTF {} to Account {}" [amount dptf sfa])
            )
        )
    )
    (defun VST|C_RepurposeFrozen (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        @doc "Repurposes a Frozen DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeFrozen patron executor executee dptf-to-repurpose repurpose-to)
                )
                (format "Succesfully repurposed Frozen DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleFrozenDPTF (patron:string executor:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Frozen DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleFrozenDPTF patron executor s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Frozen DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Reserving]
    (defun VST|C_Reserve (patron:string executor:string dptf:string amount:decimal)
        @doc "Reserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Reserve patron executor dptf amount)
                )
                (format "Account {} succesfully reserved {} {} Tokens" [sr amount dptf])
            )
        )
    )
    (defun VST|C_Unreserve (patron:string executor:string r-dptf:string amount:decimal)
        @doc "Unreserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unreserve patron executor r-dptf amount)
                )
                (format "Account {} succesfully unreserved {} {} Tokens" [su amount r-dptf])
            )
        )
    )
    (defun VST|C_RepurposeReserved (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        @doc "Repurposes a Reserved DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeReserved patron executor executee dptf-to-repurpose repurpose-to)
                )
                (format "Succesfully repurposed Reserved DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleReservedDPTF (patron:string executor:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Reserved DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleReservedDPTF patron executor s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Reserved DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Vesting]
    (defun VST|C_Vest (patron:string executor:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer)
        @doc "Vests a DPTF Token, generating ist Vested DPOF Counterspart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sv:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Vest patron executor target-account dptf amount offset seconds milestones)
                )
                (format "Succesfully vested DPTF {} From Account {} to Account {}" [dptf sv sta])
            )
        )
    )
    (defun VST|C_Unvest (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Vested DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unvest patron executor dpof nonce)
                )
                (format "Succesfully unvested DPOF {} Nonce {} to Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_RepurposeVested (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a Vested DPOF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeVested patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Vested DPTF {} Nonce {}from {} to {}" [dpof-to-repurpose nonce srf srt])
            )
        )
    )
    ;;  [VST Sleeping]
    (defun VST|C_Sleep (patron:string executor:string target-account:string dptf:string amount:decimal seconds:integer)
        @doc "Sleeps a DPTF Token, generating its Sleeping DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Sleep patron executor target-account dptf amount seconds)
                )
                (format "Sucesfully put to Sleep {} DPTF {} on Account {} for a Duration of {} seconds." [amount dptf sta seconds])
            )
        )
    )
    (defun VST|C_Unsleep (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Sleeping DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unsleep patron executor dpof nonce)
                )
                (format "Succesfully unsleeped DPOF {} Nonce {} on Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_Merge(patron:string executor:string dpof:string nonces:[integer])
        @doc "Merges selected sleeping Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Merge patron executor dpof nonces)
                )
                (format "Succesfully merged Sleeping DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeMerge (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        @doc "Repurposes multiple Sleeping DPOFs from <executee> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeMerge patron executor executee dpof-to-repurpose nonces repurpose-to)
                )
                (format "Succesfully repurposed and merged Sleeping DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeSleeping (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a single Sleeping DPOF from <executee> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSleeping patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Sleeping DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleSleepingDPOF (patron:string executor:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Sleeping DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleSleepingDPOF patron executor s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Sleeping DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [VST Hibernating]
    (defun VST|C_Hibernate (patron:string executor:string target-account:string dptf:string amount:decimal dayz:integer)
        @doc "Hibernates a DPTF Token, generating its Hibernated DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Hibernate patron executor target-account dptf amount dayz)
                )
                (format "Sucesfully hibernated {} {} on Account {} for a Duration of {} days." [amount dptf sta dayz])
            )
        )
    )
    (defun VST|C_Awake (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Hibernated DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-VST::C_Awake patron executor dpof nonce)
                    )
                    (output:list (at "output" ico))
                    (v1:decimal (at 0 output))
                    (v2:decimal (at 1 output))
                    (v3:decimal (at 2 output))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= v1 0.0)
                    (format "Awakend DPOF {} Nonce {} with no Hibernation Fee, getting the Full Amount of {} back" [dpof nonce v2])
                    (format "Awakend DPOF {} Nonce {} with a Hibernation Fee of {} Promile, relinquishing {} Tokens and getting only {} Tokens back" [dpof nonce v1 v3 v2])
                )
            )
        )
    )
    (defun VST|C_Slumber (patron:string executor:string dpof:string nonces:[integer])
        @doc "Merges selected hibernated Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Slumber patron executor dpof nonces)
                )
                (format "Succesfully merged Hibernated DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeSlumber (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        @doc "Repurposes multiple Hibernated DPOFs from <executee> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSlumber patron executor executee dpof-to-repurpose nonces repurpose-to)
                )
                (format "Succesfully repurposed and merged Hibernated DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeHibernating (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a single Hibernating DPOF from <executee> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeHibernating patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Hibernated DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleHibernatingDPOF (patron:string executor:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Hibernating DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VST:module{VestingV2} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleHibernatingDPOF patron executor s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Hibernating DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [LIQUID_Client]
    (defun LQD|C_UnwrapStoa (patron:string executor:string amount:decimal)
        @doc "Unwraps DPTF Stoa to Native Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapStoa patron executor amount)
                )
                (format "Succesfully Unwrapped {} STOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapStoa (patron:string executor:string amount:decimal)
        @doc "Wraps Native Stoa to DPTF Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapStoa patron executor amount)
                )
                (format "Succesfully Wrapped {} STOA on Account {}" [amount sw])
            )
        )
    )
    (defun LQD|C_UnwrapUrStoa (patron:string executor:string amount:decimal)
        @doc "Unwrapper is the Ouronet Account doing the Unwrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapUrStoa patron executor amount)
                )
                (format "Succesfully Unwrapped {} URSTOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapUrStoa (patron:string executor:string amount:decimal)
        @doc "Wrapper is the Ouronet Account doing the Wrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapUrStoa patron executor amount)
                )
                (format "Succesfully Wrapped {} URSTOA on Account {}" [amount sw])
            )
        )
    )
    ;;  [OUROBOROS_Client]
    (defun ORBR|C_Compress (executor:string ignis-amount:decimal)
        @doc "Compresses IGNIS - Ouronet Gas Token, generating OUROBOROS \
            \ Only whole IGNIS Amounts greater than or equal to 1.0 can be used for compression \
            \ Similar to Sublimation, the output amount is dependent on OUROBOROS price, set at a minimum of 1$ \
            \ Compression has 98.5% efficiency, 1.5% is lost as fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_Compress executor ignis-amount)
                    )
                )
                (format "Succesfully compressed {} IGNIS to {} OUROBOROS" [ignis-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_Sublimate (executor:string executee:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Needed for Sublimating negative Amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_Sublimate executor executee ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_SublimateV2 (executor:string executee:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Can be used for Sublimation when OURO Supply is Positive, also being used in Firestarter."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ORBR::C_SublimateV2 executor executee ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
                (at 0 (at "output" ico))
            )
        )
    )
    (defun ORBR|C_WithdrawFees (patron:string executor:string executee:string id:string)
        @doc "Withdraws collected DPTF Fees collected in standard mode \
        \ DPTF Fees collected in standard mode cumullate on the OUROBOROS Smart Account \
        \ Only the Token Owner can withdraw these fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ORBR::C_WithdrawFees patron executor executee id)
                )
                (format "Succesfully withdrawn DPTF Fees for DPTF {} to Account {}" [id st])
            )
        )
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_01/3_Talos/04_TS01-C3.pact (module only -- its interface is already live)
(module TS01-C3 GOV
    @doc "TALOS Administrator and Client Module for Stage 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientThreeV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C3                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C3))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
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
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|SWPU:module{OuronetPolicyV2} SWPU)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            ;;
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPLC::P|A_AddIMP mg)
            (ref-P|SWPU::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [Swapper_Client]
    (defun SWP|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for SWPair Token <entity-id> costing 400 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|SWP:module{BrandingUsagePrimaryV2} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|SWP::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun SWP|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF, ATS Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|SWP:module{BrandingUsagePrimaryV2} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|SWP::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun SWP|C_UpdatePendingBrandingLPs (patron:string executor:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for SWPair LPs (Native LP, Frozen LP or Sleeping LP) Token <entity-id> costing 200 IGNIS \
            \ <entity-pos> 1 = LP Token will be used \
            \ <entity-pos> 2 = Frozen-LP Token will be used \
            \ <entity-pos> 3 = Sleeping-LP Token will be used"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|SWPLC:module{BrandingUsageSecondaryV2} SWPLC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|SWPLC::C_UpdatePendingBrandingLPs patron executor swpair entity-pos logo description website social)
                )
            )
        )
    )
    (defun SWP|C_UpgradeBrandingLPs (patron:string executor:string swpair:string entity-pos:integer months:integer)
        @doc "Similar to its DPTF, DPOF, ATS SWP Variants, but for SWPair LPs"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|SWPLC:module{BrandingUsageSecondaryV2} SWPLC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|SWPLC::C_UpgradeBrandingLPs patron executor swpair entity-pos months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun SWP|C_ChangeOwnership (patron:string executor:string executee:string swpair:string)
        @doc "Changes Ownership of an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_ChangeOwnership patron executor executee swpair)
                )
                (format "Succesfully changed ownership for SWP-Pair {}" [swpair])
            )
        )
    )
    (defun SWP|C_EnableFrozenLP:string (patron:string executor:string swpair:string)
        @doc "Enables the posibility of using Frozen Tokens to add Liquidity for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    ;;
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWP::C_EnableFrozenLP patron executor swpair)
                    )
                    (issued-frozen-lp-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= current-frozen-link BAR)
                    (do
                        (ref-TS01-A::XB_DynamicFuelSTOA)
                        (format "Succesfully Issued Frozen LP {} and enabled Frozen LP Functionality on SWP-Pair {}" [issued-frozen-lp-id swpair])
                    )
                    (format 
                        "Succesfully enabled Frozen LP Functionality on SWP-Pair {}, without issuing a Frozen LP, as it allready exists with id {}" 
                        [swpair current-frozen-link]
                    )
                )
            )
        )
    )
    (defun SWP|C_EnableSleepingLP:string (patron:string executor:string swpair:string)
        @doc "Enables the posibility of using Sleeping Tokens to add Liquidity for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    ;;
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWP::C_EnableSleepingLP patron executor swpair)
                    )
                    (issued-sleeping-lp-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= current-sleeping-link BAR)
                    (do
                        (ref-TS01-A::XB_DynamicFuelSTOA)
                        (format "Succesfully Issued Sleeping LP {} and enabled Frozen LP Functionality on SWP-Pair {}" [issued-sleeping-lp-id swpair])
                    )
                    (format 
                        "Succesfully enabled Sleeping LP Functionality on SWP-Pair {}, without issuing a Frozen LP, as it allready exists with id {}" 
                        [swpair current-sleeping-link]
                    )
                )
            )
        )
    )
    (defun SWP|C_IssueStable:list (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        @doc "Issues a Stable Liquidity Pool. First Token in the liquidity Pool must have a connection to a principal Token \
            \ Stable Pools have the S designation. \
            \ Stable Pools can be created with up to 7 Tokens, and have by design equal weighting. \
            \ The <p> boolean defines if The Pool is a Principal Pools. \
            \ Principal Pools are always on, and cant be disabled by low-liquidity."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (weights:[decimal] (make-list (length pool-tokens) 1.0))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPI::C_Issue patron executor pool-tokens fee-lp weights amp p)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun SWP|C_IssueStandard:list (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool)
        @doc "Issues a Standard, Constant Product Pool. \
            \ Constant Product Pools have the P Designation, and they are by design equal weigthed \
            \ Can also be created with up to 7 Tokens, also the <p> boolean determines if its a Principal Pool or not \
            \ The First Token must be a Principal Token \
            \ \
            \ Executor: ENFORCED INDIRECTLY, one line below. This function is a thin alias -- it \
            \ delegates the whole operation to its SIBLING SWP|C_IssueStable with the amplifier \
            \ pinned to -1.0, and that sibling forwards <executor> to SWPI::C_Issue, where the \
            \ proof lives (XE_IssueWrite -> TFT::C_MultiTransfer, named in SWPI::C_Issue's own \
            \ @doc). \
            \ \
            \ The route has to be written down because the delegation is SAME-MODULE: \
            \ _executorenforced's FORWARDED branch matches `ref-X::` hand-offs, which is correct \
            \ -- a foreign module is what would do the proving, and the tool can go and look. An \
            \ internal hop proves nothing by itself. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (SWP|C_IssueStable patron executor pool-tokens fee-lp -1.0 p)
    )
    (defun SWP|C_IssueWeighted:list (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        @doc "Issues a Weigthed Constant Liquidity Pool \
            \ Weigthed Pools have the W Designation, and the weights can be changed at will. \
            \ Can also be created with up to 7 Tokens, <p> boolean determines if its a Principal Pool or not \
            \ The First Token must also be a Principal Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPI::C_Issue patron executor pool-tokens fee-lp weights -1.0 p)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun SWP|C_ModifyCanChangeOwner (patron:string executor:string swpair:string new-boolean:bool)
        @doc "Modifies the <can-change-owner> parameter of an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_ModifyCanChangeOwner patron executor swpair new-boolean)
                )
                (format "Succesfully updated SWP-Pair {} <can-change-owner> Parameter" [swpair])
            )
        )
    )
    (defun SWP|C_ModifyWeights (patron:string executor:string swpair:string new-weights:[decimal])
        @doc "Modify weights for an SWPair. Works only for W Pools"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_ModifyWeights patron executor swpair new-weights)
                )
                (format "Succesfully updated SWP-Pair {} Weigths Parameter" [swpair])
            )
        )
    )
    (defun SWP|C_ToggleAddLiquidity (patron:string executor:string swpair:string toggle:bool)
        @doc "Toggle on or off the Functionality of adding liquidity for an <swpair> \
            \ When <toggle> is <true>, ensures required Mint, Burn, Transfer Roles are set, if not, set them. \
            \ The Roles are: \
            \ Mint and Burn Roles for LP Token (requires LP Token Ownership) \
            \ Fee Exemption Roles for all Tokens of an S-Pool, or \
            \ for all Tokens of a W- or P-Pool, except its first Token (which is principal) \
            \ Roles are needed to SWP|SC_NAME \
            \ \
            \ Requires <swpair> ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWPLC::C_ToggleAddLiquidity patron executor swpair toggle)
                )
                (format "Succesfully toggled Liquidity Provisioning for SWP-Pair {}" [swpair])
            )
        )
    )
    (defun SWP|C_ToggleSwapCapability (patron:string executor:string swpair:string toggle:bool)
        @doc "Toggle on or off the Functionality of swapping for an <swpair> \
            \ When <toggle> is <true>, same setup for roles is executed as for <SWP|C_ToggleAddLiquidity> \
            \ \
            \ <On> Toggle can only be executed is <swpair> surpasses <(ref-SWP::UR_InactiveLimit)> \
            \ \
            \ Requires <swpair> ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWPU::C_ToggleSwapCapability patron executor swpair toggle)
                )
                (format "Succesfully toggled Swap Capability for SWP-Pair {}" [swpair])
            )
        )
    )
    (defun SWP|C_ToggleFeeLock (patron:string executor:string swpair:string toggle:bool)
        @doc "Locks the SPWPair fees in place. Modifying the SWPair fees requires them to be unlocked \
            \ Unlocking costs STOA and is financially discouraged"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWP::C_ToggleFeeLock patron executor swpair toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (format "Succesfully toggled the Fee Lock for the SWP-Pair {}" [swpair])
            )
        )
    )
    (defun SWP|C_UpdateAmplifier (patron:string executor:string swpair:string amp:decimal)
        @doc "Updates Amplifier Value; Only works on S-Pools (Stable Pools)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_UpdateAmplifier patron executor swpair amp)
                )
                (format "Succesfully updated SWP-Pair {} Amplifier Parameter" [swpair])
            )
        )
    )
    (defun SWP|C_UpdateFee (patron:string executor:string swpair:string new-fee:decimal lp-or-special:bool)
        @doc "Updates Fees Values for an SWPair \
            \ The <lp-or-special> boolean defines whether its the LP-Fee or Special-Fee that is changed \
            \ THe LP Fee is the amount of Swap Output kept by the Liquidity Pool, increasing the Value of its LP Token(s) \
            \ The Special-Fee is the Fee that is collected to the Special-Fee-Targets \
            \ The Fee must be between 0.0001 - 320.0 (promile, that would be 32%) \
            \ When <liquid-boost>, an universal SWP Parameter (that can be set only by the admin) is set to true \
            \   an amount equal to the LP-Fee is also used to boost the Liquid Stoa Index \
            \   which is why the fee must be capped at close a third of 100% (320 promile in this case)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_UpdateFee patron executor swpair new-fee lp-or-special)
                )
                (format "Succesfully updated SWP-Pair {} Fees" [swpair])
            )
        )
    )
    (defun SWP|C_UpdateSpecialFeeTargets (patron:string executor:string swpair:string targets:[object{SwapperV4.FeeSplit}])
        @doc "Updates the Special Fee Targets, along with their Split, for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWP::C_UpdateSpecialFeeTargets patron executor swpair targets)
                )
                (format "Succesfully updated SWP-Pair {} Special Fee Targets" [swpair])
            )
        )
    )
    ;;
    (defun SWP|C_Fuel
        (patron:string executor:string swpair:string input-amounts:[decimal])
        @doc "Fuels the <swpair> with <input-amounts> of Tokens. \
            \ Must contain values for all pool tokens, with zero for Tokens that arent used \
            \ Fueling increases Liquidity without issuing LP, therefore increasing LP Value"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SWPLC::C_Fuel patron executor swpair input-amounts true true)
                )
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully fueled SWP-Pair {} with Token Amounts {}" [swpair input-amounts])
            )
        )
    )
    (defun SWP|C_AddLiquidity:string (patron:string executor:string swpair:string input-amounts:[decimal])
        @doc "Adds Liquidity using <input-amounts> on <swpair>, in its default Standard Mode. \
            \ Must Contain 0.0 for Tokens not used; Pool Token Order must be followed for desired <input-amounts> \
            \ 1000 IGNIS Flat Fee Cost for adding liquidity to deincentivize addition of small values \
            \ \
            \ Liquidity can also be added on a completely empty pool, \
            \ if no asymetric liquidity exists in the <input-amounts> \
            \ In this case, the original Token Ratios are used, the SWPair was created with. \
            \ \
            \ DEFAULT MODE \
            \ \
            \ If Asymmetric LP is detected, further IGNIS costs are enforced \
            \ <ignis-gaseous-tax>, <deficit-ignis-tax>, <boost-ignis-tax> \
            \ Also a specific quantity of LP is relinquished as <fuel-lp-tax>"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::STOA-PID|C_AddStandardLiquidity patron executor swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun SWP|C_AddIcedLiquidity:string (patron:string executor:string swpair:string input-amounts:[decimal])
        @doc "Same as <SWP|C_AddLiquidity>, but using ICED Mode \
            \ \
            \ ICED MODE \
            \ Returns a part of the <asymmetric-lp-amount> as Frozen LP \
            \ <Swpair> must be enabled for Frozen LP for this feature \
            \ Only works when asymetric-liquidity exists in <input-amounts> \
            \ if <input-amounts> have balanced-liquidity, Native LP is returned for it \
            \ \
            \ In ICED MODE, only the IGNIS <ignis-gaseous-tax> is paid \
            \ Therefore the <asymmetric-lp-fee-amount> is returned as native LP \
            \ While the rest of the <asymmetric-lp-amount> is returned as Frozen LP"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::STOA-PID|C_AddIcedLiquidity patron executor swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native and {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) (at 1 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun SWP|C_AddGlacialLiquidity:string (patron:string executor:string swpair:string input-amounts:[decimal])
        @doc "Same as <SWP|C_AddLiquidity>, but using GLACIAL Mode \
            \ \
            \ GLACIAL MODE \
            \ Returns all of the <asymmetric-lp-amount> as Frozen LP \
            \ <Swpair> must be enabled for Frozen LP for this feature \
            \ Only works when asymetric-liquidity exists in <input-amounts> \
            \ if <input-amounts> have balanced-liquidity, Native LP is returned for it \
            \ \
            \ In GLACIAL MODE, no further IGNIS taxes are paid"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::STOA-PID|C_AddGlacialLiquidity patron executor swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native and {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) (at 1 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun SWP|C_AddFrozenLiquidity:string (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal)
        @doc "Adds Liquidity using a single <input-amount> of a single <frozen-dptf> \
            \ Since this is an asymetric-liquidity-amount, it is bound by max. deviation rules \
            \ 1000 IGNIS Flat Fee Cost for adding liquidity. \
            \ \
            \ FROZEN MODE \
            \ Returns all LP Tokens as Frozen LP Tokens \
            \ <Swpair> must be enabled for Frozen LP for this feature \
            \ Also, a frozen link for one of the <swpair> Pool Tokens must have been previously created."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::STOA-PID|C_AddFrozenLiquidity patron executor swpair frozen-dptf input-amount stoa-pid)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun SWP|C_AddSleepingLiquidity:string (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer)
        @doc "Adds Liquidity using a single <input-amount> of a single <sleeping-dpof> \
        \ Since this is an asymetric-liquidity-amount, it is bound by max. deviation rules \
        \ 1000 IGNIS Flat Fee Cost for adding liquidity. \
        \ \
        \ SLEEPING MODE \
        \ Returns all LP Tokens as Sleeping LP tokens \
        \ <Swpair> must be enabled for Sleeping LP for this feature \
        \ Also, a sleeping link for one of the <swpair> Pool Tokens must have been previously created."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::STOA-PID|C_AddSleepingLiquidity patron executor swpair sleeping-dpof nonce stoa-pid)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Leeping LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )  
            )
        )
    )
    (defun SWP|C_RemoveLiquidity (patron:string executor:string swpair:string lp-amount:decimal)
        @doc "Removes <swpair> Liquidity using <lp-amount> of LP Tokens \
            \ Always returns all Pool Tokens at current Pool Token Ratio \
            \ Removing Liquidty complety leaving the pool exactly empty (0.0 tokens) is fully supported"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPLC::C_RemoveLiquidity patron executor swpair lp-amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Removed {} LP Tokens from SWP-Pair {}, yielding {} of all Pool Tokens" [lp-amount swpair (at "output" ico)])
            )
        )
    )
    ;;Swaps
    (defun SWP|C_Firestarter (executor:string)
        @doc "Makes IGNIS for <executor> using 10 native Stoas"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    (ref-ORBR:module{OuroborosV2} OUROBOROS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    ;;
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (ignis:string (ref-DALOS::UR_IgnisID))
                    (primordial:string (ref-SWP::UR_PrimordialPool))
                    (fire-starter-ignis:decimal (ref-DPTF::UR_AccountSupply ignis executor))
                    (fire-starter-ouro:decimal (ref-DPTF::UR_AccountSupply ouro executor))
                )
                (enforce
                    (fold (and) true
                        [
                            (< fire-starter-ouro 1.0)
                            (>= fire-starter-ouro 0.0)
                            (< fire-starter-ignis 100.0)
                        ]
                    )
                    "Only empty or allmost empty Ouronet Accounts can firestart"
                )
                (let
                    (
                        (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                        (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-LIQUID::C_WrapStoa executor executor 10.0)
                        )
                        (slippage-bounds:object{SwapperUsageV3.Slippage}
                            (ref-SWPU::UDC_SpawnSlippageBounds primordial [wstoa] [10.0] ouro -1.0)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-SWPU::C_Swap 
                                executor executor primordial [wstoa] [10.0] ouro 
                                -1.0 stoa-pid slippage-bounds
                            )
                        )
                        (gained-ouro:decimal (at 0 (at "output" ico2)))
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-ORBR::C_SublimateV2 executor executor gained-ouro)
                        )
                    )
                    (ref-SWP::XE_UpdateStoaValue primordial (at 0 (ref-SWPI::URC_PoolValue primordial)))
                    (format "Used 10 native STOA to generate {} IGNIS with no IGNIS Costs!" [(at 0 (at "output" ico3))])              
                )
            )
        )
    )
    (defun SWP|CC_SmartSwapWithSlippage
        (
            patron:string
            executor:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV3.Slippage}
        )
        @doc "Executes a Smart Swap from <input-id> to <output-id> with slippage protection. \
            \ Path is traced automatically via BFS across all pool bases. \
            \ #34 Phase 8: renamed from SWP|C_SmartSwapWithSlippage. \
            \ #65bL Phase 4 fix: the STOA-repricing loop below (one URC_PoolValue call \
            \ per distinct pool touched) now fetches the whole topology's raw graph \
            \ ONCE via URC_PoolValueFromRaw's shared <raw-graph>, instead of each \
            \ pool's own URC_PoolValue call independently re-reading and rebuilding \
            \ it. Safe per SWPT::UC_MakeGraphNodes being input/output-independent — \
            \ one fetch against the full <all-swpairs> universe covers every distinct \
            \ pool's own first-token->WSTOA query, not just the one it happened to be \
            \ fetched for (see URCx_HopperFromRaw's own doc). \
            \ #65bL Phase 7 fix: also builds the [GraphNode] graph itself \
            \ (SWPT::UC_MakeGraphFromRaw) ONCE, alongside <raw-graph> — every \
            \ URC_PoolValueFromGraph call below now reuses that same built graph \
            \ instead of each one independently re-deriving it from <raw-graph> \
            \ (a linear scan per node in the whole topology), same reasoning one \
            \ layer deeper (see URC_HopperFromGraph's own doc)."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (ref-SWPT:module{SwapTracerV3} SWPT)
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::CC_SmartSwap
                            patron executor input-id input-amount output-id
                            slippage stoa-pid slippage-bounds
                        )
                    )
                    (out:list (at "output" ico))
                    ;;#27M/M13 fix: removed the dead `path-edges` binding that used to
                    ;;shadow-recompute this via a fresh `URC_Hopper` BFS call (unused here —
                    ;;this loop already correctly used <at 3 out>, the swap's own recorded
                    ;;`distinct-edges`). Pure gas cleanup, no behavior change.
                    ;;
                    ;;#65bL Phase 4: fetched ONCE, shared across every distinct pool
                    ;;below — this is TOPOLOGY only (SWPT|Graph), unaffected by the
                    ;;swap's own reserve changes, so nothing depends on fetching it
                    ;;before or after the swap. Each pool's own reserve-dependent reads
                    ;;still happen live, inside the loop, per pool, as before.
                    (all-swpairs:[string] (ref-SWP::URC_Swpairs))
                    (all-nodes:[string] (ref-U|SWP::UC_MakeGraphNodes BAR BAR all-swpairs))
                    (raw-graph:[object{SwapTracerV3.RawGraphNode}] (ref-SWPT::URC_FetchRawGraph all-nodes))
                    ;;#65bL Phase 7: built ONCE here too — every URC_PoolValueFromGraph
                    ;;call below reused to share the graph-BUILD step, not just the raw
                    ;;read Phase 4 already shared. See URC_HopperFromGraph's own doc.
                    (graph:[object{BreadthFirstSearchV2.GraphNode}]
                        (ref-SWPT::UC_MakeGraphFromRaw BAR BAR all-swpairs raw-graph)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (map
                    (lambda (sp:string)
                        (ref-SWP::XE_UpdateStoaValue sp (at 0 (ref-SWPI::URC_PoolValueFromGraph sp graph)))
                    )
                    ;;G-46: `SWPU`'s slippage floor SOFT-FAILS -- it RETURNS a 1-element cumulator
                    ;;carrying the exceed-message rather than raising. The success arm returns 4
                    ;;elements. Indexing `(at 3 out)` unconditionally therefore turned every refused
                    ;;swap into `Array index out of bounds. Length (1), Index (3)`, destroying the
                    ;;message the guard had already built. The bundle twins have always carried this
                    ;;guard (see C_SmartSwapWithSlippage); the self-searching CC_ twins never got it.
                    ;;Applied to the NoSlippage variant too: its floor branch is unreachable today
                    ;;(the wrapper hardcodes slippage = -1.0), but its bundle twin guards it anyway,
                    ;;and an unreachable branch is what a later change makes reachable.
                    (if (= (length out) 4) (at 3 out) [])
                )
                (if (= (length out) 4)
                    (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
                    (format "Smart Swap not executed: {}" [(at 0 out)])
                )
            )
        )
    )
    (defun SWP|CC_SmartSwapNoSlippage
        (
            patron:string
            executor:string
            input-id:string
            input-amount:decimal
            output-id:string
        )
        @doc "Executes a Smart Swap from <input-id> to <output-id> without slippage protection. \
            \ Path is traced automatically via BFS across all pool bases. \
            \ #34 Phase 8: renamed from SWP|C_SmartSwapNoSlippage. \
            \ #65bL Phase 4/7 fix: see SWP|CC_SmartSwapWithSlippage's own doc — same \
            \ shared-raw-graph/shared-graph-build STOA-repricing-loop fixes, \
            \ mirrored here."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (ref-SWPT:module{SwapTracerV3} SWPT)
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV3.Slippage}
                        (ref-SWPU::UDC_SpawnSmartSwapSlippageBounds input-id input-amount output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::CC_SmartSwap
                            patron executor input-id input-amount output-id
                            -1.0 stoa-pid slippage-bounds
                        )
                    )
                    (out:list (at "output" ico))
                    ;;#27M/M13 fix: was a post-swap `URC_Hopper` BFS recompute (`path-edges`)
                    ;;used to pick which pools get refreshed below — wrong, because it re-runs
                    ;;BFS against reserves the swap itself just mutated, so it can pick a
                    ;;different route than the one actually swapped (missed/stale refreshes,
                    ;;or spurious refreshes of untouched pools). Fixed to use <at 3 out>, the
                    ;;`distinct-edges` list XI_SmartSwap already recorded as the real traversed
                    ;;pools (19_SWPU.pact XI_SmartSwap) — matches SmartSwapWithSlippage's
                    ;;(already-correct) pattern above.
                    ;;
                    ;;#65bL Phase 4: fetched ONCE, shared across every distinct pool
                    ;;below — this is TOPOLOGY only (SWPT|Graph), unaffected by the
                    ;;swap's own reserve changes, so nothing depends on fetching it
                    ;;before or after the swap. Each pool's own reserve-dependent reads
                    ;;still happen live, inside the loop, per pool, as before.
                    (all-swpairs:[string] (ref-SWP::URC_Swpairs))
                    (all-nodes:[string] (ref-U|SWP::UC_MakeGraphNodes BAR BAR all-swpairs))
                    (raw-graph:[object{SwapTracerV3.RawGraphNode}] (ref-SWPT::URC_FetchRawGraph all-nodes))
                    ;;#65bL Phase 7: built ONCE here too — every URC_PoolValueFromGraph
                    ;;call below reused to share the graph-BUILD step, not just the raw
                    ;;read Phase 4 already shared. See URC_HopperFromGraph's own doc.
                    (graph:[object{BreadthFirstSearchV2.GraphNode}]
                        (ref-SWPT::UC_MakeGraphFromRaw BAR BAR all-swpairs raw-graph)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (map
                    (lambda (sp:string)
                        (ref-SWP::XE_UpdateStoaValue sp (at 0 (ref-SWPI::URC_PoolValueFromGraph sp graph)))
                    )
                    ;;G-46: `SWPU`'s slippage floor SOFT-FAILS -- it RETURNS a 1-element cumulator
                    ;;carrying the exceed-message rather than raising. The success arm returns 4
                    ;;elements. Indexing `(at 3 out)` unconditionally therefore turned every refused
                    ;;swap into `Array index out of bounds. Length (1), Index (3)`, destroying the
                    ;;message the guard had already built. The bundle twins have always carried this
                    ;;guard (see C_SmartSwapWithSlippage); the self-searching CC_ twins never got it.
                    ;;Applied to the NoSlippage variant too: its floor branch is unreachable today
                    ;;(the wrapper hardcodes slippage = -1.0), but its bundle twin guards it anyway,
                    ;;and an unreachable branch is what a later change makes reachable.
                    (if (= (length out) 4) (at 3 out) [])
                )
                (if (= (length out) 4)
                    (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
                    (format "Smart Swap not executed: {}" [(at 0 out)])
                )
            )
        )
    )
    (defun SWP|C_SmartSwapWithSlippage
        (
            patron:string
            executor:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV3.Slippage}
            bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: bundle-based Smart Swap with slippage protection — the route, \
            \ boost-path and stoa-paths are all supplied by <bundle> (assembled \
            \ client-side via dirty reads, HANDOFF doc P3.7), zero internal searching. \
            \ P3.4's dumb-writer: <stoa-results> (precomputed by \
            \ SWPU::URC_ComputeStoaValueResults inside SWPU::C_SmartSwap) is mapped \
            \ straight into XE_UpdateStoaValue below — no URC_PoolValue re-derivation \
            \ at the Talos layer at all, unlike SWP|CC_SmartSwapWithSlippage above."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (result:list
                        (ref-SWPU::C_SmartSwap
                            patron executor input-id input-amount output-id
                            slippage stoa-pid slippage-bounds bundle
                        )
                    )
                    (ico:object{IgnisCollectorV3.OutputCumulator} (at 0 result))
                    (stoa-results:list (at 1 result))
                    (out:list (at "output" ico))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (map
                    (lambda (pv:object) (ref-SWP::XE_UpdateStoaValue (at "pool" pv) (at "stoa-value" pv)))
                    stoa-results
                )
                (if (= (length out) 4)
                    (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
                    (format "Smart Swap not executed: {}" [(at 0 out)])
                )
            )
        )
    )
    (defun SWP|C_SmartSwapNoSlippage
        (
            patron:string
            executor:string
            input-id:string
            input-amount:decimal
            output-id:string
            bundle:object{SwapperUsageV3.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: bundle-based Smart Swap without slippage protection. Unlike \
            \ SWP|CC_SmartSwapNoSlippage above, the dummy slippage-bounds object is built \
            \ via SWPU::UDC_Slippage directly (not UDC_SpawnSmartSwapSlippageBounds, \
            \ which itself performs a live URC_HopperActive search — defeating the whole \
            \ point of the bundle-based path)."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV3.Slippage} (ref-SWPU::UDC_Slippage 0.0 0 0.0))
                    (result:list
                        (ref-SWPU::C_SmartSwap
                            patron executor input-id input-amount output-id
                            -1.0 stoa-pid slippage-bounds bundle
                        )
                    )
                    (ico:object{IgnisCollectorV3.OutputCumulator} (at 0 result))
                    (stoa-results:list (at 1 result))
                    (out:list (at "output" ico))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (map
                    (lambda (pv:object) (ref-SWP::XE_UpdateStoaValue (at "pool" pv) (at "stoa-value" pv)))
                    stoa-results
                )
                (if (= (length out) 4)
                    (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
                    (format "Smart Swap not executed: {}" [(at 0 out)])
                )
            )
        )
    )
    (defun SWP|C_SingleSwapWithSlippage
        (
            patron:string
            executor:string
            swpair:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV3.Slippage}
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> with <slippage>"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            patron executor swpair [input-id] [input-amount] output-id 
                            slippage stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                ;;G-47: the refusal payload is ALSO one element here, so `(at 0 ...)` does not
                ;;fault -- it silently interpolates the exceed-message into a sentence that starts
                ;;"Succesfully swapped". The transaction commits, the swap @event has already fired
                ;;(it sits on the `with-capability`, ahead of the floor check), and nothing moved.
                ;;Length cannot discriminate: success is `[o-id-netto]` (a decimal), refusal is
                ;;`[exceed-message]` (a string). The TYPE is the only thing that differs.
                (if (= (typeof (at 0 (at "output" ico))) "string")
                    (format "Swap not executed: {}" [(at 0 (at "output" ico))])
                    (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
                )
            )
        )
    )
    (defun SWP|C_SingleSwapNoSlippage
        (
            patron:string
            executor:string
            swpair:string
            input-id:string
            input-amount:decimal
            output-id:string
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> without slippage"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV3.Slippage}
                        (ref-SWPU::UDC_SpawnSlippageBounds swpair [input-id] [input-amount] output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            patron executor swpair [input-id] [input-amount] output-id 
                            -1.0 stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )
    (defun SWP|C_MultiSwapWithSlippage
        (
            patron:string
            executor:string
            swpair:string
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
            slippage-bounds:object{SwapperUsageV3.Slippage}
        )
        @doc "Executes A Swap from <input-ids> with <input-amounts> to <output-id> with <slippage>"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            patron executor swpair input-ids input-amounts output-id 
                            slippage stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                ;;G-47: the refusal payload is ALSO one element here, so `(at 0 ...)` does not
                ;;fault -- it silently interpolates the exceed-message into a sentence that starts
                ;;"Succesfully swapped". The transaction commits, the swap @event has already fired
                ;;(it sits on the `with-capability`, ahead of the floor check), and nothing moved.
                ;;Length cannot discriminate: success is `[o-id-netto]` (a decimal), refusal is
                ;;`[exceed-message]` (a string). The TYPE is the only thing that differs.
                (if (= (typeof (at 0 (at "output" ico))) "string")
                    (format "Swap not executed: {}" [(at 0 (at "output" ico))])
                    (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
                )
            )
        )
    )
    (defun SWP|C_MultiSwapNoSlippage
        (
            patron:string
            executor:string
            swpair:string
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> without slippage"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    (ref-SWPU:module{SwapperUsageV3} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV3.Slippage}
                        (ref-SWPU::UDC_SpawnSlippageBounds swpair input-ids input-amounts output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            patron executor swpair input-ids input-amounts output-id 
                            -1.0 stoa-pid slippage-bounds)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact (module only -- its interface is already live)
(module DPDC-S GOV
    @doc "DPDC-S is the Sets module of the DPDC collectables family, managing groups of \
        \ nonces composed into higher-order set-classes. It stores set definitions in \
        \ DPSF/DPNF SetsTables (Primordial, Composite, or Hybrid, each with a \
        \ score-multiplier). Owners define set-classes via \
        \ C_DefinePrimordialSet/C_DefineCompositeSet/C_DefineHybridSet and can enable \
        \ fragmentation, toggle and rename them. Users compose and decompose via \
        \ C_MakeSemiFungibleSet/CC_BreakSemiFungibleSet (SFT, quantity) and \
        \ C_MakeNonFungibleSet/C_BreakNonFungibleSet (NFT, minting/burning a set nonce whose \
        \ score sums its constituents)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcSetsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-S                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-S_ADMIN)))
    (defcap GOV|DPDC-S_ADMIN ()                         (enforce-guard GOV|MD_DPDC-S))
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
    (defcap P|DPDC-S|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-S|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DPDC-S|REMOTE-GOV ()
        @doc "DPDC Remote Governor Capability"
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
        (with-capability (GOV|DPDC-S_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-S_ADMIN)
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
        (with-capability (GOV|DPDC-S_ADMIN)
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
        (with-capability (GOV|DPDC-S_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|DPDC-S|CALLER)))
            )
            (ref-P|DPDC::P|A_Add
                "DPDC-S|RemoteDpdcGov"
                (create-capability-guard (P|DPDC-S|REMOTE-GOV))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;list previously crashed with an opaque out-of-bounds error, since (enumerate 0 -1) returns [0 -1],
    ;;not [] -- see UEV_PrimordialSetDefinition/UEV_CompositeSetDefinition) and at most this many, so an
    ;;unreasonably large definition can't push Make/Break gas past the practical ceiling and permanently
    ;;brick that set-class for its owner.
    (defconst MAX_SET_DEFINITION_SIZE 20)
    ;;{3.2}  schemas
    ;;{3.3}  tables
    ;;
    (deftable DPSF|SetsTable:{DpdcUdcV2.DPDC|Set})                ;;Key = <DPSF-id> + BAR + <set-class>
    ;;
    (deftable DPNF|SetsTable:{DpdcUdcV2.DPDC|Set})                ;;Key = <DPNF-id> + BAR + <set-class>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DPDC-S|C>MAKE (id:string son:bool nonces:[integer] set-class:integer how-many-sets:integer)
        @event
        ;;G-44 FIX (2026-09-17). This guard is ABOVE the let deliberately. <iz-active> binds
        ;;UR_IzSetActive, which funnels to UR_Set's bare <read>, and Pact evaluates let bindings
        ;;before the body -- so a set-class that does not exist aborted on the raw table key and the
        ;;"is not active" enforce below could never speak for it. Measured at 0 and at 99.
        (enforce (URC_SetExists id son set-class)
            (format "Set-Class {} does not exist for this DPDC" [set-class]))
        (let
            (
                (iz-active:bool (UR_IzSetActive id son set-class))
            )
            (enforce iz-active (format "Set-Class {} is not active for Set Composition" [set-class]))
            (enforce (> how-many-sets 0) "How-Many-Sets must be a positive, non-zero integer")
            (UEV_NoncesForSetClass id son nonces set-class)
            (compose-capability (P|DPDC-S|CALLER))
            (compose-capability (P|DPDC-S|REMOTE-GOV))
        )
    )
    (defcap DPDC-S|C>BREAK (id:string son:bool nonce:integer how-many-sets:integer)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
            )
            ;;Nonces of Inactive Sets can still be broken down.
            (enforce (!= nonce-class 0) "Only Class Non-0 Nonces can be broken Down")
            (enforce (> how-many-sets 0) "How-Many-Sets must be a positive, non-zero integer")
            (compose-capability (P|DPDC-S|CALLER))
            (compose-capability (P|DPDC-S|REMOTE-GOV))
        )
    )
    (defcap DPDC-S|C>DEFINE-PRIMORDIAL
        (
            id:string son:bool score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-COMPOSITE
        (
            id:string son:bool score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_CompositeSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-HYBRID
        (
            id:string son:bool score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son primordial-sd)
        (UEV_CompositeSetDefinition id son composite-sd)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|CX>DEFINE (id:string son:bool ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation ind)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPDC-S|C>ENABLE-FRAGMENTATION
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (iz-fragmented:bool (UEV_IzSetClassFragmented id son set-class))
            )
            (enforce (not iz-fragmented) "Set Class must not be fragmented in order to enable fragmentation for it !")
            (UEV_SetClass id son set-class)
            ;;DPDC Audit #30M: require the set-class be active, consistent with its C>TOGGLE/C>RENAME
            ;;siblings — this was the only one of the owner-gated set mutations that skipped the check.
            (UEV_SetActiveState id son set-class true)
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation fragmentation-ind)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC-S|C>TOGGLE (id:string son:bool set-class:integer toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (UEV_SetActiveState id son set-class (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC-S|C>RENAME (id:string son:bool set-class:integer new-name:string)
        @event
        ;;G-45 FIX (2026-09-17). RENAME had NO set-class domain guard: <current-name> binds
        ;;UR_SetName, the same bare read, so both a nonexistent class and the 1-based off-by-one 0
        ;;surfaced a raw table key rather than any sentence this module contains.
        (enforce (URC_SetExists id son set-class)
            (format "Set-Class {} does not exist for this DPDC" [set-class]))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (current-name:string (UR_SetName id son set-class))
            )
            (enforce (!= new-name current-name) (format "The Set Name of <{}> must be different from the current name of <{}> for operation" [new-name current-name]))
            (UEV_SetActiveState id son set-class true)
            (ref-DPDC::CAP_Owner id son)
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;; DPDC-S|C>MULTIPLIER removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun UC_FirstNoncesFromPSD:[integer] (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        @doc "Returns a list of Nonces that composed the PSD, only works for SFTs, \
            \ since the 1st Nonce of the <allowed-nonces> is used"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition} (at idx psd))
                            (allowed-nonces:[integer] (at "allowed-nonces" element))
                            (first-allowed-nonce:integer (at 0 allowed-nonces))
                        )
                        (ref-U|LST::UC_AppL acc first-allowed-nonce)
                    )
                )
                []
                (enumerate 0 (- (length psd) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;  [6] - [Set]
    (defun UR_Set:object{DpdcUdcV2.DPDC|Set} (id:string son:bool set-class:integer)
        (if son
            (read DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]))
            (read DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]))
        )
    )

    (defun URC_SetExists:bool (id:string son:bool set-class:integer)
        @doc "True when the <set-class> row exists for <id>. TOTAL: answers FALSE for a missing \
            \ row instead of aborting. UR_Set cannot do this -- it is a bare <read>, and every \
            \ set reader funnels through it, so a set-class that does not exist dies in the \
            \ reader before any guard written for it can speak. Set classes are 1-BASED, which \
            \ makes 0 the likeliest caller error and puts it squarely in that mute case. \
            \ Added 2026-09-17 for DEFECT-LEDGER G-44/G-45; URC_TripletExists is the precedent."
        (let
            (
                (k:string (concat [id BAR (format "{}" [set-class])]))
            )
            (if son
                (with-default-read DPSF|SetsTable k
                    { "set-name" : BAR } { "set-name" := sn } (!= sn BAR))
                (with-default-read DPNF|SetsTable k
                    { "set-name" : BAR } { "set-name" := sn } (!= sn BAR))
            )
        )
    )
    (defun UR_SetClass:integer (id:string son:bool set-class:integer)
        (at "set-class" (UR_Set id son set-class))
    )
    (defun UR_SetName:string (id:string son:bool set-class:integer)
        (at "set-name" (UR_Set id son set-class))
    )
    (defun UR_SetMultiplier:decimal (id:string son:bool set-class:integer)
        (at "set-score-multiplier" (UR_Set id son set-class))
    )
    (defun UR_NonceOfSet:integer (id:string set-class:integer)
        (at "nonce-of-set" (UR_Set id true set-class))
    )
    (defun UR_IzSetActive:bool (id:string son:bool set-class:integer)
        (at "iz-active" (UR_Set id son set-class))
    )
    (defun UR_IzSetPrimordial:bool (id:string son:bool set-class:integer)
        (at "iz-primordial" (UR_Set id son set-class))
    )
    (defun UR_IzSetComposite:bool (id:string son:bool set-class:integer)
        (at "iz-composite" (UR_Set id son set-class))
    )
    (defun UR_PSD:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
        (id:string son:bool set-class:integer)
        (at "primordial-set-definition" (UR_Set id son set-class))
    )
    (defun UR_CSD:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] 
        (id:string son:bool set-class:integer)
        (at "composite-set-definition" (UR_Set id son set-class))
    )
    (defun UR_SetNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer)
        (at "nonce-data" (UR_Set id son set-class))
    )
    (defun UR_SetSplitData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer)
        (at "split-data" (UR_Set id son set-class))
    )
    ;;Score Read for Nonce — renamed from UR_N|Score, DPDC Audit #19H follow-up: reads
    ;;UR_NonceClass/UR_N|RawScore/UR_SetMultiplier and derives a computed value from them
    ;;(sentinel check, multiply, fragment-divide) — the URC_* contract, not a plain UR_* read.
    (defun URC_N|Score:decimal (id:string son:bool nonce:integer)
        @doc "Cooked score reader: applies the Set-Class multiplier (for Set-member nonces) and the \
            \ 1/1000 fragment split (for negative/fragment nonces) to a nonce's raw stored score. \
            \ DPDC Audit #19H: the -1.0 <unscored> sentinel is now checked once, on the untouched raw \
            \ value, before any multiply/divide — the previous per-branch checks either omitted the \
            \ check entirely (fragment arms) or compared against the wrong constant (-1000.0 instead \
            \ of -1.0, a copy-paste leftover), letting the sentinel leak through as a real negative \
            \ score in 3 of the 4 branches."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                (raw-nonce-score:decimal (ref-DPDC::UR_N|RawScore (ref-DPDC::UR_NativeNonceData id son (abs nonce))))
            )
            (if (= raw-nonce-score -1.0)
                0.0
                (if (= nonce-class 0)
                    (if (< nonce 0)
                        (/ raw-nonce-score 1000.0)
                        raw-nonce-score
                    )
                    (let
                        (
                            (multiplier:decimal (UR_SetMultiplier id son nonce-class))
                            (multiplied-score:decimal (* raw-nonce-score multiplier))
                        )
                        (if (< nonce 0)
                            (/ multiplied-score 1000.0)
                            multiplied-score
                        )
                    )
                )
            )
        )
    )
    ;:Requires rethinking
    (defun URC_PrimordialOrComposite:[bool] (id:string son:bool set-class:integer)
        (UEV_SetClass id son set-class)
        [
            (UR_IzSetPrimordial id son set-class)
            (UR_IzSetComposite id son set-class)
        ]
    )
    (defun URC_NoncesSummedScore:decimal (id:string son:bool nonces:[integer])
        @doc "Bakes a new NFT set instance's own raw score from the RAW (unmultiplied) scores of its \
            \ constituent nonces -- deliberately via UR_N|RawScore, not the multiplier-applying \
            \ URC_N|Score. DPDC Audit #52L: confirmed intentional design, owner-verified against real \
            \ mainnet Bloodshed set-NFT scores. A set-class's own score-multiplier is meant to apply \
            \ exactly once, at that set's own level, when ITS score is later read (via URC_N|Score) -- \
            \ not per-constituent here at Make-time. For a Composite/Hybrid set whose constituent is \
            \ itself a previously-Made, already-multiplied set instance from another set-class, this \
            \ correctly sums that constituent's pre-multiplier raw value, so multipliers don't compound \
            \ across nested sets."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (summed-score:decimal
                    (fold
                        (lambda
                            (acc:decimal idx:integer)
                            (+ acc (ref-DPDC::UR_N|RawScore (ref-DPDC::UR_NativeNonceData id son (at idx nonces))))
                        )
                        0.0
                        (enumerate 0 (- (length nonces) 1))
                    )
                )
            )
            (if (< summed-score 0.0)
                0.0
                summed-score
            )
        )
    )
    ;;
    (defun URC_SemiFungibleConstituents:[integer] (id:string set-class:integer)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (UR_PSD id true set-class))
                (csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (UR_CSD id true set-class))
                (npsd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
                (l-psd:integer
                    (if (= psd npsd)
                        0
                        (length psd)
                    )
                )
                (l-csd:integer
                    (if (= csd ncsd)
                        0
                        (length csd)
                    )
                )
            )
            (if (= l-psd 0)
                ;;Composite Set
                (URH_NonceListFromCSD id csd)
                (if (= l-csd 0)
                    ;;Primordial Set
                    (UC_FirstNoncesFromPSD psd)
                    ;;Hybrid Set — DPDC Audit #32M: order must be [primordial..., composite...], matching
                    ;;the Make-time convention in UEV_NoncesForSetClass's hybrid branch below (which does
                    ;;(take l-psd nonces) for primordial, (drop l-psd nonces) for composite). The two were
                    ;;previously reversed relative to each other — harmless today only because every leg
                    ;;gets the same uniform <how-many-sets> scalar, but a future non-uniform per-position
                    ;;quantity would silently misattribute between legs. Keep both in this same order.
                    (+ (UC_FirstNoncesFromPSD psd) (URH_NonceListFromCSD id csd))
                )
            )
        )
    )
    (defun URH_NonceListFromCSD:[integer] (id:string csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        @doc "Returns a list of Nonces that composed the CSD, only works for SFTs \
            \ since SFTs save the Nonce of the Set Class"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV2.DPDC|AllowedClassForSetPosition} (at idx csd))
                            (allowed-sclass:integer (at "allowed-sclass" element))
                            (nonce-of-set:integer (UR_NonceOfSet id allowed-sclass))
                        )
                        (ref-U|LST::UC_AppL acc nonce-of-set)
                    )
                )
                []
                (enumerate 0 (- (length csd) 1))
            )
        )
    )
    (defun URCv_NonFungibleConstituents:[integer] (id:string nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id false nonce))
            )
            (enforce (!= nonce-class 0) "Invalid NFT Nonce to Read Constituents")
            (ref-DPDC::UR_N|Composition (ref-DPDC::UR_NativeNonceData id false nonce))
        )
    )
    ;;
    ;;
    (defun URCi_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer] how-many-sets:integer)
        @doc "Cost preview for C_MakeSemiFungibleSet: only the account->DPDC set-element transfer \
            \ is billed (the XB_CreditSFT-Nonce write's cumulator is discarded). Purely derived."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (ref-DPDC-T::URCi_MultiTransferCumulator
                [id] [true] account dpdc [nonces] [(make-list (length nonces) how-many-sets)])
        )
    )
    (defun URCi_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer how-many-sets:integer)
        @doc "Cost preview for CC_BreakSemiFungibleSet: account->DPDC set transfer + DPDC->account \
            \ constituents release (the XE_DebitSFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (constituents:[integer]
                    (URC_SemiFungibleConstituents id (ref-DPDC::UR_NonceClass id true nonce)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[nonce]] [[how-many-sets]])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [constituents] [(make-list (length constituents) how-many-sets)])
                ]
                []
            )
        )
    )
    (defun URCi_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer])
        @doc "Cost preview for C_MakeNonFungibleSet: account->DPDC transfer + creation of the new \
            \ set nonce + DPDC->account transfer of that new nonce. Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] account dpdc [nonces] [(make-list (length nonces) 1)])
                    (ref-DPDC-C::URCi_CreateNewNonces id false [1])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] dpdc account [[(+ 1 (ref-DPDC::UR_NoncesUsed id false))]] [[1]])
                ]
                []
            )
        )
    )
    (defun URCi_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer)
        @doc "Cost preview for C_BreakNonFungibleSet: account->DPDC transfer + DPDC->account \
            \ constituents release (the XE_DebitNFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (constituents:[integer] (URCv_NonFungibleConstituents id nonce))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] account dpdc [[nonce]] [[1]])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] dpdc account [constituents] [(make-list (length constituents) 1)])
                ]
                []
            )
        )
    )
    ;;
    (defun URCi_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefinePrimordialSet (same shape for Composite/Hybrid): the base \
            \ token-issue IGNIS price on the creator + (for SFT sets) the zero-supply set-nonce \
            \ creation; NFT sets add no nonce cost (EOC). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
                (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefinePrimordialSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefinePrimordialSet" "define-set")))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    (if son
                        (ref-DPDC-C::URCi_CreateNewNonces id son [0])
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineCompositeSet: identical cost shape to \
            \ URCi_DefinePrimordialSet."
        (URCi_DefinePrimordialSet id son)
    )
    (defun URCi_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineHybridSet: the same SHAPE as URCi_DefinePrimordialSet -- base \
            \ token-issue price on the creator + (SFT only) the zero-supply set-nonce creation, the NFT \
            \ XE_DeployAccountWNE leg being a free write -- but NOT the same PRICE. \
            \ PRICE-KEY FIX (2026-09-14): this delegated to URCi_DefinePrimordialSet, which reads the \
            \ <DP*|C_DefinePrimordialSet> key at 43.0, while C_DefineHybridSet bills its own \
            \ <DP*|C_DefineHybridSet> key at 45.0 (02_IGNIS.pact:682/764). The preview therefore \
            \ under-quoted a hybrid set-class definition by 2.0 raw IGNIS on BOTH fungibility sides. \
            \ Composite really is 43.0, so that sibling's delegation stays correct -- which is exactly \
            \ why only this one drifted and why the old @doc's claim of an identical cost read as true. \
            \ Measured against a real charge by modules/DPDC-S.repl <<DPDC-S-I27>> and <<DPDC-S-I33>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
                (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineHybridSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineHybridSet" "define-set")))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    (if son
                        (ref-DPDC-C::URCi_CreateNewNonces id son [0])
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_EnableSetClassFragmentation: the biggest IGNIS cumulator on the \
            \ set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_EnableSetClassFragmentation" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_EnableSetClassFragmentation" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleSet: the biggest IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleSet" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleSet" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RenameSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_RenameSet: the small IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_RenameSet" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_RenameSet" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_PrimordialSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        ;;DPDC Audit #51L: reject empty/oversized definitions with a clear message before any
        ;;enumerate-based fold runs (an empty list would otherwise crash with an opaque
        ;;out-of-bounds error several lines below).
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonces-used-in-set-definition:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (+ acc (at "allowed-nonces" (at idx set-definition)))
                        )
                        []
                        (enumerate 0 (- (length set-definition) 1))
                    )
                )
                (nu:integer (ref-DPDC::UR_NoncesUsed id son))
            )
            ;;DPDC Audit #31M: check every individual allowed-nonce value, not just the running max of
            ;;the whole list (the old (<= max nu) check let an out-of-range negative "fragment" value
            ;;hide behind any legitimately-small value elsewhere in the same definition, since a large
            ;;negative number is always <= a small positive max). A value is only plausible if it
            ;;references an existing native nonce (positive, 1..nu) or a fragment encoding of one
            ;;(negative, magnitude 1..nu) -- 0 is never valid either way.
            (enforce
                (fold (and) true
                    (map
                        (lambda (n:integer) (and (> (abs n) 0) (<= (abs n) nu)))
                        nonces-used-in-set-definition
                    )
                )
                (format "Invalid Set-Definition for a Primordial Set: every allowed-nonce must reference \
                    \ an existing native nonce (magnitude 1-{}) or its fragment encoding" [nu])
            )
            (map
                (lambda
                    (idx:integer)
                    (UEV_PrimordialSetElement son (at idx set-definition))
                )
                (enumerate 0 (- (length set-definition) 1))
            )
        )
    )
    (defun UEV_PrimordialSetElement (son:bool element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition})
        (let
            (
                (allowed-nonces:[integer] (at "allowed-nonces" element))
                (size:integer (length allowed-nonces))
            )
            (if son
                (enforce (= size 1) "SFT Set Elements must have only 1 allowed element")
                (enforce (> size 1) "NFT Set Elements must have more than 1 allowed element")
            )
        )
    )
    (defun UEV_CompositeSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        ;;DPDC Audit #51L: same empty/oversized-definition guard as UEV_PrimordialSetDefinition above.
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used-in-set-definition:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (+ acc [(at "allowed-sclass" (at idx set-definition))])
                        )
                        []
                        (enumerate 0 (- (length set-definition) 1))
                    )
                )
                (max:integer (ref-U|INT::UEV_MaxInteger (distinct set-classes-used-in-set-definition)))
                (scu:integer (ref-DPDC::UR_SetClassesUsed id son))
            )
            (enforce
                (fold (and) true (map (lambda (sc:integer) (> sc 0)) set-classes-used-in-set-definition))
                "Invalid Set-Definition: allowed-sclass must be greater than 0 for every position (0 is reserved)"
            )
            (enforce (<= max scu) "Invalid Set-Definition for a Composite Set with non existent Set-Classes")
        )
    )
    (defun UEV_SetClass (id:string son:bool set-class:integer)
        @doc "Validates <set-class> for the given DPDC id. \
            \ SHADOWED-GUARD FIX: the domain guard used to sit INSIDE the let, below the \
            \ <UR_SetClass> binding. Pact evaluates let bindings before the body, and \
            \ UR_Set does a HARD read keyed by <set-class> - so any out-of-domain value \
            \ aborted on 'row not found' and this enforce was unreachable for every input. \
            \ Hoisted above the let, matching UEV_IzSetClassFragmented directly below."
        (enforce (> set-class 0) "Invalid Set-Class Value")
        (let
            (
                (sc:integer (UR_SetClass id son set-class))
            )
            ;;Data-integrity assertion, not an input guard: <sc> is the set-class FIELD of the row
            ;;keyed BY set-class, so this can only fire on a corrupt row. Fail-closed by design.
            ;;UNREACHABLE: no argument can trip it. For any EXISTING row the two values are equal
            ;;by construction (the row is keyed by the field it is compared against), and for a
            ;;non-existent row UR_SetClass hard-reads and aborts on "row not found" before this
            ;;enforce runs. The only way to fire it is to corrupt the table, which no caller can
            ;;do. Worth keeping — it fails closed if a migration ever writes a mismatched row —
            ;;but it is not coverage.
            (enforce (= set-class sc) "Invalid DPDC Set Data")
        )
    )
    (defun UEV_IzSetClassFragmented:bool (id:string son:bool set-class:integer)
        (enforce (> set-class 0) "Only greater than 0 set-classes can be checked for fragmentation")
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (sd:object{DpdcUdcV2.DPDC|NonceData} (UR_SetSplitData id son set-class))
                (zd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
            )
            (if (!= sd zd) true false)
        )
    )
    (defun UEV_Fragmentation (id:string son:bool set-class:integer)
        (let
            (
                (iz-fragmented:bool (UEV_IzSetClassFragmented id son set-class))
            )
            (enforce iz-fragmented "Set-Class must be fragmented for operation")
        )
    )
    (defun UEV_SetActiveState (id:string son:bool set-class:integer state:bool)
        (let
            (
                (x:bool (UR_IzSetActive id son set-class))
            )
            (enforce (= x state) (format "Set Class {} of {} ID {} must be set to {} for operation" [set-class (if son "SFT" "NFT") id state]))
        )
    )
    (defun UEV_ScoreMultiplier (new-multiplier:decimal)
        @doc "Bounds a Set-Class score-multiplier: max 3 decimals precision (unchanged from the \
            \ original Update-time check), and a [1.0, 100.0] magnitude range — a multiplier can \
            \ boost a score (up to 100x) or leave it unchanged (1.0, the neutral no-op value), but \
            \ never reduce it below the raw score — to prevent an unbounded, instantly-retroactive \
            \ re-pricing of every outstanding member of the Set-Class. Enforced only at Define \
            \ (Primordial/Composite/Hybrid) — score-multiplier is immutable thereafter, see #15H \
            \ follow-up (Fix #14). See DPDC Audit #15H."
        (enforce
            (= (floor new-multiplier 3) new-multiplier)
            (format "Input Set-Multiplier of {} is not conform with its designed precision of only 3 decimals" [new-multiplier])
        )
        (enforce
            (and (>= new-multiplier 1.0) (<= new-multiplier 100.0))
            (format "Set-Multiplier of {} must be between 1.0 and 100.0 inclusive" [new-multiplier])
        )
    )
    ;;
    (defun UEV_NoncesForSetClass (id:string son:bool nonces:[integer] set-class:integer)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (UR_PSD id son set-class))
                (csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (UR_CSD id son set-class))
                (npsd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
                (l-psd:integer
                    (if (= psd npsd)
                        0
                        (length psd)
                    )
                )
                (l-csd:integer
                    (if (= csd ncsd)
                        0
                        (length csd)
                    )
                )
                (tl:integer (+ l-psd l-csd))
                (nl:integer (length nonces))
            )
            (enforce (= tl nl) (format "Nonces list {} are invalid for making a Set of Class {}" [nonces set-class]))
            (if (= l-psd 0)
                ;;Composite Set
                (UEV_Composite id son nonces csd)
                (if (= l-csd 0)
                    ;;Primordial Set
                    (UEV_Primordial nonces psd)
                    ;;Hybrid Set — expects <nonces> ordered [primordial..., composite...]. DPDC Audit
                    ;;#32M: URC_SemiFungibleConstituents's hybrid branch (Break-time reconstruction,
                    ;;above in [F1]) must keep the same ordering convention if either function's order
                    ;;ever changes.
                    (do
                        (UEV_Primordial (take l-psd nonces) psd)
                        (UEV_Composite id son (drop l-psd nonces) csd)
                    )
                )
            )
        )
    )
    (defun UEV_Primordial (nonces:[integer] psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        (let
            (
                (l1:integer (length nonces))
                (l2:integer (length psd))
            )
            (enforce (= l1 l2) "Incompatible Input for <UEV_Composite> Validation")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (set-element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition} (at idx psd))
                            (allowed-nonces:[integer] (at "allowed-nonces" set-element))
                            (nonce:integer (at idx nonces))
                            (iz-nonce-allowed:bool (contains nonce allowed-nonces))
                        )
                        (enforce iz-nonce-allowed (format "Nonce {} not compatible with Set-Element {} for Set Definition" [nonce set-element]))
                    )
                )
                (enumerate 0 (- (length psd) 1))
            )
        )
    )
    (defun UEV_Composite (id:string son:bool nonces:[integer] csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (l1:integer (length nonces))
                (l2:integer (length csd))
            )
            (enforce (= l1 l2) "Incompatible Input for <UEV_Composite> Validation")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (set-element:object{DpdcUdcV2.DPDC|AllowedClassForSetPosition} (at idx csd))
                            (allowed-sclass:integer (at "allowed-sclass" set-element))
                            (nonce:integer (at idx nonces))
                            (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                            (iz-nonce-allowed:bool (= nonce-class allowed-sclass))
                        )
                        (enforce iz-nonce-allowed (format "Nonce {} not compatible with Set-Element {} for Set Definition" [nonce set-element]))
                    )
                )
                (enumerate 0 (- (length csd) 1))
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-PRIMORDIAL
    (defun XI_PrimordialSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    true
                    false
                    set-definition
                    (ref-DPDC-UDC::UDC_NoCompositeSet)
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-COMPOSITE
    (defun XI_CompositeSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    false
                    true
                    (ref-DPDC-UDC::UDC_NoPrimordialSet)
                    set-definition
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-HYBRID
    (defun XI_HybridSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    true
                    true
                    primordial-sd
                    composite-sd
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>ENABLE-FRAGMENTATION
    (defun XI_FragmentSetClass
        (id:string son:bool set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (require-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind))
        (XB_U|NonceOrSplitData id son set-class false fragmentation-ind)
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>TOGGLE
    (defun XI_ToggleSetClass (id:string son:bool set-class:integer toggle:bool)
        (require-capability (DPDC-S|C>TOGGLE id son set-class toggle))
        (XI_U|IzActive id son set-class toggle)
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>RENAME
    (defun XI_RenameSet (id:string son:bool set-class:integer new-name:string)
        (require-capability (DPDC-S|C>RENAME id son set-class new-name))
        (XI_U|SetName id son set-class new-name)
    )
    ;; XI_Multiplier removed — DPDC Audit #15H.
    ;;
    ;; [<SetsTable> Writings] [3]
    ;;Protection: Class 2 — SECURE
    (defun XI_I|CollectionSet (id:string son:bool set-class:integer set:object{DpdcUdcV2.DPDC|Set})
        (require-capability (SECURE))
        (if son
            (insert DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
            (insert DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_U|NonceOrSplitData (id:string son:bool set-class:integer nos:bool nd:object{DpdcUdcV2.DPDC|NonceData})
        ;;(require-capability (SECURE))
        (P|UEV_IMC)
        (if nos
            (if son
                (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"nonce-data" : nd})
                (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"nonce-data" : nd})
            )
            (if son
                (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"split-data" : nd})
                (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"split-data" : nd})
            )
        )  
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|IzActive (id:string son:bool set-class:integer toggle:bool)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|SetName (id:string son:bool set-class:integer new-name:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        @doc "Assembles <how-many-sets> Class-<set-class> SFT sets for <executor> out of its own <nonces>. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing in DPDC-S proves an account -- DPDC-S|C>MAKE \
            \ runs shape and state checks only -- but the first leg below hands <executor> to \
            \ DPDC-T::C_Transfer in the executor slot, and DPDC-T|C>TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally. The custodial <dpdc> \
            \ smart account on the other side of that transfer is DERIVED, not a parameter, \
            \ so it is not an executee: it is where the pieces are parked while the set is \
            \ assembled, and it is the same account in every call. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
            )
            (with-capability (DPDC-S|C>MAKE id son nonces set-class how-many-sets)
                ;;1]SFT Set Nonce is already created with the Set Definition,
                ;;it only needs a quantity of <how-many-sets> to be added to target <account>
                (ref-DPDC-C::XB_CreditSFT-Nonce executor id (UR_NonceOfSet id set-class) how-many-sets)
                ;;2]Transfer <nonces> to <dpdc> last to return the cumulator.
                (ref-DPDC-T::C_Transfer patron executor dpdc [id] [son] [nonces] [(make-list (length nonces) how-many-sets)] true)
            )
        )
    )
    (defun CC_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer how-many-sets:integer)
        @doc "Dissolves <how-many-sets> of <executor>'s Class-non-0 SFT set nonces back into their constituents. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing in DPDC-S proves an account -- DPDC-S|C>BREAK \
            \ runs shape and state checks only -- but the first leg below hands <executor> to \
            \ DPDC-T::C_Transfer in the executor slot, and DPDC-T|C>TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally. The custodial <dpdc> \
            \ smart account on the other side of that transfer is DERIVED, not a parameter, \
            \ so it is not an executee: it is where the pieces are parked while the set is \
            \ assembled, and it is the same account in every call. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce how-many-sets)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer the SFT Sets from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer patron executor dpdc [id] [son] [[nonce]] [[how-many-sets]] true)
                        )
                        (constituents:[integer]
                            (URC_SemiFungibleConstituents id (ref-DPDC::UR_NonceClass id son nonce))
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]Release the Set Elements from <dpdc> to <account>
                            (ref-DPDC-T::C_Transfer patron dpdc executor [id] [son] [constituents] [(make-list (length constituents) how-many-sets)] true)
                        )
                    )
                    ;;3]Burn the Input SFT Set Nonces
                    (ref-DPDC-C::XE_DebitSFT-Nonce dpdc id nonce how-many-sets false)
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
                )
            )
        )
    )
    (defun C_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonces:[integer] set-class:integer)
        @doc "Assembles one Class-<set-class> NFT set for <executor> out of its own <nonces>, minting the set nonce. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing in DPDC-S proves an account -- DPDC-S|C>MAKE \
            \ runs shape and state checks only -- but the first leg below hands <executor> to \
            \ DPDC-T::C_Transfer in the executor slot, and DPDC-T|C>TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally. The custodial <dpdc> \
            \ smart account on the other side of that transfer is DERIVED, not a parameter, \
            \ so it is not an executee: it is where the pieces are parked while the set is \
            \ assembled, and it is the same account in every call. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>MAKE id son nonces set-class 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer <nonces> to <dpdc>
                            (ref-DPDC-T::C_Transfer patron executor dpdc [id] [son] [nonces] [(make-list (length nonces) 1)] true)
                        )
                        ;;
                        (set-nd:object{DpdcUdcV2.DPDC|NonceData} (UR_SetNonceData id son set-class))
                        (summed-score:decimal (URC_NoncesSummedScore id son nonces))
                        (spawned-nonce-md:object{DpdcUdcV2.NonceMetaData}
                            (ref-DPDC-UDC::UDC_NonceMetaData
                                summed-score
                                nonces
                                {}
                                )
                        )
                        (spawned-nd:object{DpdcUdcV2.DPDC|NonceData}
                            (+
                                {"meta-data" : spawned-nonce-md}
                                (remove "meta-data" set-nd)
                            )
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]When one nonce of class non-0 is created, is automatically created on <dpdc> account
                            ;;PROVISIONAL PATRON SLOT CLEARED (HANDOFF 4e) at this module's own
                            ;;turn, 2026-09-22. It read `account` because no patron existed here
                            ;;-- and the attempt to write `patron` anyway is what taught this
                            ;;programme that Pact reports an unbound name as "Cannot find module:
                            ;;ouronet-ns.patron". There is a real one now, so the payer is the
                            ;;payer. The EXECUTOR stays READ rather than threaded, and that is not
                            ;;a leftover: C_CreateNewNonce binds its executor to (UR_Verum5 id son),
                            ;;the create-role holder, and this is the branch where the SIGNATURE
                            ;;check is deliberately bypassed -- the module is minting the set
                            ;;nonce, not the role holder -- so naming that account is the only
                            ;;attribution available and it is exact.
                            (ref-DPDC-C::C_CreateNewNonce patron (ref-DPDC::UR_Verum5 id son) id son set-class 1 spawned-nd true)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            ;;3]Transfer new set nonce to <account>
                            (ref-DPDC-T::C_Transfer patron dpdc executor [id] [son] [[(ref-DPDC::UR_NoncesUsed id son)]] [[1]] true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
                )
            )
        )
    )
    (defun C_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer)
        @doc "Dissolves one of <executor>'s Class-non-0 NFT set nonces back into its constituents. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing in DPDC-S proves an account -- DPDC-S|C>BREAK \
            \ runs shape and state checks only -- but the first leg below hands <executor> to \
            \ DPDC-T::C_Transfer in the executor slot, and DPDC-T|C>TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally. The custodial <dpdc> \
            \ smart account on the other side of that transfer is DERIVED, not a parameter, \
            \ so it is not an executee: it is where the pieces are parked while the set is \
            \ assembled, and it is the same account in every call. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer the SFT|NFT from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer patron executor dpdc [id] [son] [[nonce]] [[1]] true)
                        )
                        (constituents:[integer]
                            (URCv_NonFungibleConstituents id nonce)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]Release the Set Elements from <dpdc> to <account>
                            (ref-DPDC-T::C_Transfer patron dpdc executor [id] [son] [constituents] [(make-list (length constituents) 1)] true)
                        )
                    )
                    ;;3]Burn the Input SFT Set Nonces
                    (ref-DPDC-C::XE_DebitNFT-Nonce dpdc id nonce 1 false)
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
                )
            )
        )
    )
    (defun UEV_ExecutorIsCollectionOwner (executor:string id:string son:bool)
        @doc "BINDS <executor> to the collection owner, (UR_OwnerKonto id son), via DPDC. \
            \ \
            \ Used by the SIX owner-gated entrypoints of this module -- the three C_Define*Set \
            \ variants, C_EnableSetClassFragmentation, C_ToggleSet and C_RenameSet -- and by \
            \ nothing else here. All six reach (ref-DPDC::CAP_Owner id son), which enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor: HANDOFF 4g. This supplies \
            \ the other half, that the account the caller NAMED is that owner. \
            \ \
            \ The FOUR set make/break entrypoints deliberately do NOT call it. Their authority \
            \ is the acting account's own signature, proven downstream by DPDC-T|C>TRANSFER, \
            \ and the collection owner has no say in whether a holder assembles a set. Same \
            \ module, two different authorities, and which one applies is decided by whether \
            \ the op touches the set DEFINITION or a holding of it. \
            \ \
            \ Named to match 06_DPDC-MNG's identical helper. 05_DPDC-R's was called \
            \ UEV_ExecutorIsOwnerKontoLocal and has been renamed to this, so one grep finds \
            \ every site in the DPDC family that makes this binding. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
        )
    )
    (defun C_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a new PRIMORDIAL set-class on <id> -- one composed of Class-0 nonces. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. DPDC-S|CX>DEFINE reaches \
            \ (ref-DPDC::CAP_Owner id son), ownership of the DERIVED collection owner and not \
            \ of any parameter -- HANDOFF 4g -- so UEV_ExecutorIsCollectionOwner binds the \
            \ declared executor to that same (UR_OwnerKonto id son). \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefinePrimordialSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefinePrimordialSet" "define-set")))
                    (set-class:integer (XI_PrimordialSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce patron (ref-DPDC::UR_Verum5 id son) id son set-class 0 ind true)
                            EOC
                        )
                    )
                )
                ;;THE SET-CLASS IS THE THING THIS CALL CREATED, so it rides out in `output`.
                ;;It used to be computed, used, and dropped into an empty output list -- and
                ;;`UDC_ConcatenateOutputCumulators` REPLACES output rather than merging it, so
                ;;`[]` actively discarded it. The Talos wrapper could then only report the
                ;;caller-typed set-name, leaving the owner with no way to address the set they
                ;;had just defined: set-class is an auto-increment integer, so unlike a
                ;;name-derived id it cannot be reconstructed after the fact.
                ;;StoicSyntax 2.16.2.
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [set-class])
            )
        )
    )
    (defun C_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a new COMPOSITE set-class on <id> -- one composed of other set-classes. \
            \ Executor: PROVEN INDIRECTLY via DPDC-S|CX>DEFINE's (CAP_Owner id son), a derived \
            \ account (HANDOFF 4g), bound by UEV_ExecutorIsCollectionOwner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineCompositeSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineCompositeSet" "define-set")))
                    (set-class:integer (XI_CompositeSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce patron (ref-DPDC::UR_Verum5 id son) id son set-class 0 ind true)
                            EOC
                        )
                    )
                )
                ;;THE SET-CLASS IS THE THING THIS CALL CREATED, so it rides out in `output`.
                ;;It used to be computed, used, and dropped into an empty output list -- and
                ;;`UDC_ConcatenateOutputCumulators` REPLACES output rather than merging it, so
                ;;`[]` actively discarded it. The Talos wrapper could then only report the
                ;;caller-typed set-name, leaving the owner with no way to address the set they
                ;;had just defined: set-class is an auto-increment integer, so unlike a
                ;;name-derived id it cannot be reconstructed after the fact.
                ;;StoicSyntax 2.16.2.
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [set-class])
            )
        )
    )
    (defun C_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a new HYBRID set-class on <id> -- Class-0 nonces AND other set-classes. \
            \ Executor: PROVEN INDIRECTLY via DPDC-S|CX>DEFINE's (CAP_Owner id son), a derived \
            \ account (HANDOFF 4g), bound by UEV_ExecutorIsCollectionOwner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineHybridSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineHybridSet" "define-set")))
                    (set-class:integer (XI_HybridSet id son set-name score-multiplier primordial-sd composite-sd ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce patron (ref-DPDC::UR_Verum5 id son) id son set-class 0 ind true)
                            (do
                                (ref-DPDC::XE_DeployAccountWNE dpdc id false)
                                EOC
                            )
                        )
                    )
                )
                ;;THE SET-CLASS IS THE THING THIS CALL CREATED, so it rides out in `output`.
                ;;It used to be computed, used, and dropped into an empty output list -- and
                ;;`UDC_ConcatenateOutputCumulators` REPLACES output rather than merging it, so
                ;;`[]` actively discarded it. The Talos wrapper could then only report the
                ;;caller-typed set-name, leaving the owner with no way to address the set they
                ;;had just defined: set-class is an auto-increment integer, so unlike a
                ;;name-derived id it cannot be reconstructed after the fact.
                ;;StoicSyntax 2.16.2.
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [set-class])
            )
        )
    )
    (defun C_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Turns fragmentation ON for one set-class -- a ONE-WAY switch. \
            \ Executor: PROVEN INDIRECTLY via the capability's (CAP_Owner id son), a derived \
            \ account (HANDOFF 4g), bound by UEV_ExecutorIsCollectionOwner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind)
            (XI_FragmentSetClass id son set-class fragmentation-ind)
            (URCi_EnableSetClassFragmentation id son)
        )
    )
    (defun C_ToggleSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string son:bool set-class:integer toggle:bool)
        @doc "Activates or deactivates a set-class for further composition. \
            \ Executor: PROVEN INDIRECTLY via the capability's (CAP_Owner id son), a derived \
            \ account (HANDOFF 4g), bound by UEV_ExecutorIsCollectionOwner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>TOGGLE id son set-class toggle)
            (XI_ToggleSetClass id son set-class toggle)
            (URCi_ToggleSet id son)
        )
    )
    (defun C_RenameSet:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string son:bool set-class:integer new-name:string)
        @doc "Renames a set-class. \
            \ Executor: PROVEN INDIRECTLY via the capability's (CAP_Owner id son), a derived \
            \ account (HANDOFF 4g), bound by UEV_ExecutorIsCollectionOwner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-S|C>RENAME id son set-class new-name)
            (XI_RenameSet id son set-class new-name)
            (URCi_RenameSet id son)
        )
    )

)



;;DPSF

;;DPNF

