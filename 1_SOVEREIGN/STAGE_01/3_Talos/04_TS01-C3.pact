;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;; #39M/M14 fix: prior live ClientThreeV2 frozen here, not in the central registry above —
;; V2's Smart Swap functions type against SwapperUsageV2.Slippage, a module-owned interface
;; (declared in 19_SWPU.pact) that isn't resolvable yet at the registry's early Interfaces-
;; load point (mirrors the same reason ClientFourV6 was left undocumented-in-full there, per
;; that file's own comment — module-owned-type dependency, not resolvable in the early registry).
;;
(interface TalosStageOne_ClientThreeV2
    @doc "Frozen — pre-V3 surface; Issue/fee-target functions typed against \
        \ SwapperV3.PoolTokens/SwapperV3.FeeSplit (superseded when SwapperV3 shipped, \
        \ interface bump per versioning rule — no functional surface change). \
        \ V2: Added Smart Swap entry points - C_SWP|SmartSwapWithSlippage and \
        \ C_SWP|SmartSwapNoSlippage for multi-hop token swaps across the entire pool \
        \ base using BFS path tracing."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
    (defun C_SWP|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_SWP|UpgradeBranding (patron:string entity-id:string months:integer))
    (defun C_SWP|UpdatePendingBrandingLPs (patron:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_SWP|UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer))
    ;;
    (defun C_SWP|ChangeOwnership (patron:string swpair:string new-owner:string))
    (defun C_SWP|EnableFrozenLP:string (patron:string swpair:string))
    (defun C_SWP|EnableSleepingLP:string (patron:string swpair:string))
    ;;Issue
    (defun C_SWP|IssueStable:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_SWP|IssueStandard:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool))
    (defun C_SWP|IssueWeighted:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    ;;Management
    (defun C_SWP|ModifyCanChangeOwner (patron:string swpair:string new-boolean:bool))
    (defun C_SWP|ModifyWeights (patron:string swpair:string new-weights:[decimal]))
    (defun C_SWP|ToggleAddLiquidity (patron:string swpair:string toggle:bool))
    (defun C_SWP|ToggleSwapCapability (patron:string swpair:string toggle:bool))
    (defun C_SWP|ToggleFeeLock (patron:string swpair:string toggle:bool))
    (defun C_SWP|UpdateAmplifier (patron:string swpair:string amp:decimal))
    (defun C_SWP|UpdateFee (patron:string swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_SWP|UpdateSpecialFeeTargets (patron:string swpair:string targets:[object{SwapperV3.FeeSplit}]))
    ;;Liquidity
    (defun C_SWP|AddLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddIcedLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddGlacialLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddFrozenLiquidity:string (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal))
    (defun C_SWP|AddSleepingLiquidity:string (patron:string account:string swpair:string sleeping-dpof:string nonce:integer))
    (defun C_SWP|RemoveLiquidity (patron:string account:string swpair:string lp-amount:decimal))
    ;;Smart Swap
    (defun C_SWP|SmartSwapWithSlippage (patron:string account:string input-id:string input-amount:decimal output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun C_SWP|SmartSwapNoSlippage (patron:string account:string input-id:string input-amount:decimal output-id:string))
    ;;Swap
    (defun C_SWP|SingleSwapWithSlippage (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun C_SWP|SingleSwapNoSlippage (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string))
    (defun C_SWP|MultiSwapWithSlippage (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun C_SWP|MultiSwapNoSlippage (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string))

)
;;
(interface TalosStageOne_ClientThreeV3
    @doc "Exposes Ouronet Stage One Third Batch of Client Functions \
        \ Modules: SWP are included in the Second Batch\
        \ V2: Added Smart Swap entry points - CC_SWP|SmartSwapWithSlippage and CC_SWP|SmartSwapNoSlippage \
        \ for multi-hop token swaps across the entire pool base using BFS path tracing. \
        \ V3: Issue and fee-target surfaces use SwapperV3.PoolTokens / SwapperV3.FeeSplit (interface bump per versioning rule). \
        \ #34 Phase 8: SWP|C_SmartSwap{With,No}Slippage renamed to SWP|CC_SmartSwap{With,No}Slippage \
        \ (self-searching BFS variant); SWP|C_SmartSwap{With,No}Slippage is reserved for the \
        \ bundle-based, dirty-read-injected variant."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
    (defun C_SWP|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_SWP|UpgradeBranding (patron:string entity-id:string months:integer))
    (defun C_SWP|UpdatePendingBrandingLPs (patron:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_SWP|UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer))
    ;;
    (defun C_SWP|ChangeOwnership (patron:string swpair:string new-owner:string))
    (defun C_SWP|EnableFrozenLP:string (patron:string swpair:string))
    (defun C_SWP|EnableSleepingLP:string (patron:string swpair:string))
    ;;Issue
    (defun C_SWP|IssueStable:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_SWP|IssueStandard:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool))
    (defun C_SWP|IssueWeighted:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    ;;Management
    (defun C_SWP|ModifyCanChangeOwner (patron:string swpair:string new-boolean:bool))
    (defun C_SWP|ModifyWeights (patron:string swpair:string new-weights:[decimal]))
    (defun C_SWP|ToggleAddLiquidity (patron:string swpair:string toggle:bool))
    (defun C_SWP|ToggleSwapCapability (patron:string swpair:string toggle:bool))
    (defun C_SWP|ToggleFeeLock (patron:string swpair:string toggle:bool))
    (defun C_SWP|UpdateAmplifier (patron:string swpair:string amp:decimal))
    (defun C_SWP|UpdateFee (patron:string swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_SWP|UpdateSpecialFeeTargets (patron:string swpair:string targets:[object{SwapperV3.FeeSplit}]))
    ;;Liquidity
    (defun C_SWP|AddLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddIcedLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddGlacialLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddFrozenLiquidity:string (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal))
    (defun C_SWP|AddSleepingLiquidity:string (patron:string account:string swpair:string sleeping-dpof:string nonce:integer))
    (defun C_SWP|RemoveLiquidity (patron:string account:string swpair:string lp-amount:decimal))
    ;;#70L fix: C_SWP|Fuel/C_SWP|Firestarter are real, public functions on the TS01-C3
    ;;module below but were missing from this interface (interface-completeness gap,
    ;;not a security issue — both were still reachable via the concrete module ref).
    (defun C_SWP|Fuel (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|Firestarter (fire-starter:string))
    ;;Smart Swap
    (defun CC_SWP|SmartSwapWithSlippage (patron:string account:string input-id:string input-amount:decimal output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun CC_SWP|SmartSwapNoSlippage (patron:string account:string input-id:string input-amount:decimal output-id:string))
    ;;#34 Phase 8: bundle-based, dirty-read-injected Smart Swap — built alongside, not
    ;;replacing, SWP|CC_SmartSwap{With,No}Slippage above, for direct gas comparison.
    (defun C_SWP|SmartSwapWithSlippage
        (patron:string account:string input-id:string input-amount:decimal output-id:string
         slippage-bounds:object{SwapperUsageV2.Slippage} bundle:object{SwapperUsageV2.SmartSwapPathBundle})
    )
    (defun C_SWP|SmartSwapNoSlippage
        (patron:string account:string input-id:string input-amount:decimal output-id:string
         bundle:object{SwapperUsageV2.SmartSwapPathBundle})
    )
    ;;Swap
    (defun C_SWP|SingleSwapWithSlippage (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun C_SWP|SingleSwapNoSlippage (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string))
    (defun C_SWP|MultiSwapWithSlippage (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string slippage-bounds:object{SwapperUsageV2.Slippage}))
    (defun C_SWP|MultiSwapNoSlippage (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string))

)
;;
(module TS01-C3 GOV
    @doc "TALOS Administrator and Client Module for Stage 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageOne_ClientThreeV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C3        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                  (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()    (enforce-guard GOV|MD_TS01-C3))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV1.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV1.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV1} IGNIS)
                (ref-P|LIQUID:module{OuronetPolicyV1} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV1} SWPT)
                (ref-P|SWP:module{OuronetPolicyV1} SWP)
                (ref-P|SWPI:module{OuronetPolicyV1} SWPI)
                (ref-P|SWPL:module{OuronetPolicyV1} SWPL)
                (ref-P|SWPLC:module{OuronetPolicyV1} SWPLC)
                (ref-P|SWPU:module{OuronetPolicyV1} SWPU)
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
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
    (defconst BAR                   (CT_Bar))
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
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [Swapper_Client]
    (defun C_SWP|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}])
        @doc "Updates <pending-branding> for SWPair Token <entity-id> costing 400 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-B|SWP:module{BrandingUsagePrimaryV1} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|SWP::C_UpdatePendingBranding entity-id logo description website social)
                )
            )
        )
    )
    (defun C_SWP|UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF, ATS Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|SWP:module{BrandingUsagePrimaryV1} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-B|SWP::C_UpgradeBranding patron entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun C_SWP|UpdatePendingBrandingLPs (patron:string swpair:string entity-pos:integer logo:string description:string website:string social:[object{BrandingV1.SocialSchema}])
        @doc "Updates <pending-branding> for SWPair LPs (Native LP, Frozen LP or Sleeping LP) Token <entity-id> costing 200 IGNIS \
            \ <entity-pos> 1 = LP Token will be used \
            \ <entity-pos> 2 = Frozen-LP Token will be used \
            \ <entity-pos> 3 = Sleeping-LP Token will be used"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-B|SWPLC:module{BrandingUsageSecondaryV1} SWPLC)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|SWPLC::C_UpdatePendingBrandingLPs swpair entity-pos logo description website social)
                )
            )
        )
    )
    (defun C_SWP|UpgradeBrandingLPs (patron:string swpair:string entity-pos:integer months:integer)
        @doc "Similar to its DPTF, DPOF, ATS SWP Variants, but for SWPair LPs"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|SWPLC:module{BrandingUsageSecondaryV1} SWPLC)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-B|SWPLC::C_UpgradeBrandingLPs patron swpair entity-pos months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun C_SWP|ChangeOwnership (patron:string swpair:string new-owner:string)
        @doc "Changes Ownership of an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_ChangeOwnership swpair new-owner)
                )
                (format "Succesfully changed ownership for SWP-Pair {}" [swpair])
            )
        )
    )
    (defun C_SWP|EnableFrozenLP:string (patron:string swpair:string)
        @doc "Enables the posibility of using Frozen Tokens to add Liquidity for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    ;;
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWP::C_EnableFrozenLP patron swpair)
                    )
                    (issued-frozen-lp-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::C_Collect patron ico)
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
    (defun C_SWP|EnableSleepingLP:string (patron:string swpair:string)
        @doc "Enables the posibility of using Sleeping Tokens to add Liquidity for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    ;;
                    (lp-id:string (ref-SWP::UR_TokenLP swpair))
                    (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWP::C_EnableSleepingLP patron swpair)
                    )
                    (issued-sleeping-lp-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::C_Collect patron ico)
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
    (defun C_SWP|IssueStable:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        @doc "Issues a Stable Liquidity Pool. First Token in the liquidity Pool must have a connection to a principal Token \
            \ Stable Pools have the S designation. \
            \ Stable Pools can be created with up to 7 Tokens, and have by design equal weighting. \
            \ The <p> boolean defines if The Pool is a Principal Pools. \
            \ Principal Pools are always on, and cant be disabled by low-liquidity."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (weights:[decimal] (make-list (length pool-tokens) 1.0))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPI::C_Issue patron account pool-tokens fee-lp weights amp p)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun C_SWP|IssueStandard:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool)
        @doc "Issues a Standard, Constant Product Pool. \
            \ Constant Product Pools have the P Designation, and they are by design equal weigthed \
            \ Can also be created with up to 7 Tokens, also the <p> boolean determines if its a Principal Pool or not \
            \ The First Token must be a Principal Token"
        (C_SWP|IssueStable patron account pool-tokens fee-lp -1.0 p)
    )
    (defun C_SWP|IssueWeighted:list (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        @doc "Issues a Weigthed Constant Liquidity Pool \
            \ Weigthed Pools have the W Designation, and the weights can be changed at will. \
            \ Can also be created with up to 7 Tokens, <p> boolean determines if its a Principal Pool or not \
            \ The First Token must also be a Principal Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPI::C_Issue patron account pool-tokens fee-lp weights -1.0 p)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun C_SWP|ModifyCanChangeOwner (patron:string swpair:string new-boolean:bool)
        @doc "Modifies the <can-change-owner> parameter of an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_ModifyCanChangeOwner swpair new-boolean)
                )
                (format "Succesfully updated SWP-Pair {} <can-change-owner> Parameter" [swpair])
            )
        )
    )
    (defun C_SWP|ModifyWeights (patron:string swpair:string new-weights:[decimal])
        @doc "Modify weights for an SWPair. Works only for W Pools"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_ModifyWeights swpair new-weights)
                )
                (format "Succesfully updated SWP-Pair {} Weigths Parameter" [swpair])
            )
        )
    )
    (defun C_SWP|ToggleAddLiquidity (patron:string swpair:string toggle:bool)
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWPLC::C_ToggleAddLiquidity swpair toggle)
                )
                (format "Succesfully toggled Liquidity Provisioning for SWP-Pair" [swpair])
            )
        )
    )
    (defun C_SWP|ToggleSwapCapability (patron:string swpair:string toggle:bool)
        @doc "Toggle on or off the Functionality of swapping for an <swpair> \
            \ When <toggle> is <true>, same setup for roles is executed as for <C_SWP|ToggleAddLiquidity> \
            \ \
            \ <On> Toggle can only be executed is <swpair> surpasses <(ref-SWP::UR_InactiveLimit)> \
            \ \
            \ Requires <swpair> ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWPU::C_ToggleSwapCapability swpair toggle)
                )
                (format "Succesfully toggled Swap Capability for SWP-Pair" [swpair])
            )
        )
    )
    (defun C_SWP|ToggleFeeLock (patron:string swpair:string toggle:bool)
        @doc "Locks the SPWPair fees in place. Modifying the SWPair fees requires them to be unlocked \
            \ Unlocking costs STOA and is financially discouraged"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWP::C_ToggleFeeLock patron swpair toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (format "Succesfully toggled the Fee Lock for the SWP-Pair" [swpair])
            )
        )
    )
    (defun C_SWP|UpdateAmplifier (patron:string swpair:string amp:decimal)
        @doc "Updates Amplifier Value; Only works on S-Pools (Stable Pools)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_UpdateAmplifier swpair amp)
                )
                (format "Succesfully updated SWP-Pair {} Amplifier Parameter" [swpair])
            )
        )
    )
    (defun C_SWP|UpdateFee (patron:string swpair:string new-fee:decimal lp-or-special:bool)
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_UpdateFee swpair new-fee lp-or-special)
                )
                (format "Succesfully updated SWP-Pair {} Fees" [swpair])
            )
        )
    )
    (defun C_SWP|UpdateSpecialFeeTargets (patron:string swpair:string targets:[object{SwapperV3.FeeSplit}])
        @doc "Updates the Special Fee Targets, along with their Split, for an SWPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWP::C_UpdateSpecialFeeTargets swpair targets)
                )
                (format "Succesfully updated SWP-Pair {} Special Fee Targets" [swpair])
            )
        )
    )
    ;;
    (defun C_SWP|Fuel
        (patron:string account:string swpair:string input-amounts:[decimal])
        @doc "Fuels the <swpair> with <input-amounts> of Tokens. \
            \ Must contain values for all pool tokens, with zero for Tokens that arent used \
            \ Fueling increases Liquidity without issuing LP, therefore increasing LP Value"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SWPLC::C_Fuel account swpair input-amounts true true)
                )
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully fueled SWP-Pair {} with Token Amounts {}" [swpair input-amounts])
            )
        )
    )
    (defun C_SWP|AddLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal])
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_STOA-PID|AddStandardLiquidity account swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun C_SWP|AddIcedLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal])
        @doc "Same as <C_SWP|AddLiquidity>, but using ICED Mode \
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_STOA-PID|AddIcedLiquidity account swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native and {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) (at 1 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun C_SWP|AddGlacialLiquidity:string (patron:string account:string swpair:string input-amounts:[decimal])
        @doc "Same as <C_SWP|AddLiquidity>, but using GLACIAL Mode \
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_STOA-PID|AddGlacialLiquidity account swpair input-amounts stoa-pid)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Native and {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) (at 1 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun C_SWP|AddFrozenLiquidity:string (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal)
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_STOA-PID|AddFrozenLiquidity account swpair frozen-dptf input-amount stoa-pid)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Frozen LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )
            )
        )
    )
    (defun C_SWP|AddSleepingLiquidity:string (patron:string account:string swpair:string sleeping-dpof:string nonce:integer)
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_STOA-PID|AddSleepingLiquidity account swpair sleeping-dpof nonce stoa-pid)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Generated {} Leeping LP Tokens for Swpair {}"
                    [(at 0 (at "output" ico)) swpair]
                )  
            )
        )
    )
    (defun C_SWP|RemoveLiquidity (patron:string account:string swpair:string lp-amount:decimal)
        @doc "Removes <swpair> Liquidity using <lp-amount> of LP Tokens \
            \ Always returns all Pool Tokens at current Pool Token Ratio \
            \ Removing Liquidty complety leaving the pool exactly empty (0.0 tokens) is fully supported"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPLC::C_RemoveLiquidity account swpair lp-amount)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Removed {} LP Tokens from SWP-Pair {}, yielding {} of all Pool Tokens" [lp-amount swpair (at "output" ico)])
            )
        )
    )
    ;;Swaps
    (defun C_SWP|Firestarter (fire-starter:string)
        @doc "Makes IGNIS for <fire-starter> using 10 native Stoas"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-LIQUID:module{StoaLiquidStakingV1} LIQUID)
                    (ref-ORBR:module{OuroborosV1} OUROBOROS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    ;;
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (ignis:string (ref-DALOS::UR_IgnisID))
                    (primordial:string (ref-SWP::UR_PrimordialPool))
                    (fire-starter-ignis:decimal (ref-DPTF::UR_AccountSupply ignis fire-starter))
                    (fire-starter-ouro:decimal (ref-DPTF::UR_AccountSupply ouro fire-starter))
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
                        (ref-SWPI:module{SwapperIssueV3} SWPI)
                        (ico1:object{IgnisCollectorV1.OutputCumulator}
                            (ref-LIQUID::C_WrapStoa fire-starter 10.0)
                        )
                        (slippage-bounds:object{SwapperUsageV2.Slippage}
                            (ref-SWPU::UDC_SpawnSlippageBounds primordial [wstoa] [10.0] ouro -1.0)
                        )
                        (ico2:object{IgnisCollectorV1.OutputCumulator}
                            (ref-SWPU::C_Swap 
                                fire-starter primordial [wstoa] [10.0] ouro 
                                -1.0 stoa-pid slippage-bounds
                            )
                        )
                        (gained-ouro:decimal (at 0 (at "output" ico2)))
                        (ico3:object{IgnisCollectorV1.OutputCumulator}
                            (ref-ORBR::C_SublimateV2 fire-starter fire-starter gained-ouro)
                        )
                    )
                    (ref-SWP::XE_UpdateStoaValue primordial (at 0 (ref-SWPI::URC_PoolValue primordial)))
                    (format "Used 10 native STOA to generate {} IGNIS with no IGNIS Costs!" [(at 0 (at "output" ico3))])              
                )
            )
        )
    )
    (defun CC_SWP|SmartSwapWithSlippage
        (
            patron:string
            account:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV2.Slippage}
        )
        @doc "Executes a Smart Swap from <input-id> to <output-id> with slippage protection. \
            \ Path is traced automatically via BFS across all pool bases. \
            \ #34 Phase 8: renamed from C_SWP|SmartSwapWithSlippage. \
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
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (ref-SWPT:module{SwapTracerV2} SWPT)
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::CC_SmartSwap
                            account input-id input-amount output-id
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
                    (raw-graph:[object{SwapTracerV2.RawGraphNode}] (ref-SWPT::URC_FetchRawGraph all-nodes))
                    ;;#65bL Phase 7: built ONCE here too — every URC_PoolValueFromGraph
                    ;;call below reused to share the graph-BUILD step, not just the raw
                    ;;read Phase 4 already shared. See URC_HopperFromGraph's own doc.
                    (graph:[object{BreadthFirstSearchV1.GraphNode}]
                        (ref-SWPT::UC_MakeGraphFromRaw BAR BAR all-swpairs raw-graph)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (map
                    (lambda (sp:string)
                        (ref-SWP::XE_UpdateStoaValue sp (at 0 (ref-SWPI::URC_PoolValueFromGraph sp graph)))
                    )
                    (at 3 out)
                )
                (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
            )
        )
    )
    (defun CC_SWP|SmartSwapNoSlippage
        (
            patron:string
            account:string
            input-id:string
            input-amount:decimal
            output-id:string
        )
        @doc "Executes a Smart Swap from <input-id> to <output-id> without slippage protection. \
            \ Path is traced automatically via BFS across all pool bases. \
            \ #34 Phase 8: renamed from C_SWP|SmartSwapNoSlippage. \
            \ #65bL Phase 4/7 fix: see CC_SWP|SmartSwapWithSlippage's own doc — same \
            \ shared-raw-graph/shared-graph-build STOA-repricing-loop fixes, \
            \ mirrored here."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (ref-SWPT:module{SwapTracerV2} SWPT)
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV2.Slippage}
                        (ref-SWPU::UDC_SpawnSmartSwapSlippageBounds input-id input-amount output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::CC_SmartSwap
                            account input-id input-amount output-id
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
                    (raw-graph:[object{SwapTracerV2.RawGraphNode}] (ref-SWPT::URC_FetchRawGraph all-nodes))
                    ;;#65bL Phase 7: built ONCE here too — every URC_PoolValueFromGraph
                    ;;call below reused to share the graph-BUILD step, not just the raw
                    ;;read Phase 4 already shared. See URC_HopperFromGraph's own doc.
                    (graph:[object{BreadthFirstSearchV1.GraphNode}]
                        (ref-SWPT::UC_MakeGraphFromRaw BAR BAR all-swpairs raw-graph)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (map
                    (lambda (sp:string)
                        (ref-SWP::XE_UpdateStoaValue sp (at 0 (ref-SWPI::URC_PoolValueFromGraph sp graph)))
                    )
                    (at 3 out)
                )
                (format "Succesfully smart-swapped {} {} to {} {} via {} Swaps over {} Pools" [input-amount input-id (at 0 out) output-id (at 1 out) (at 2 out)])
            )
        )
    )
    (defun C_SWP|SmartSwapWithSlippage
        (
            patron:string
            account:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV2.Slippage}
            bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: bundle-based Smart Swap with slippage protection — the route, \
            \ boost-path and stoa-paths are all supplied by <bundle> (assembled \
            \ client-side via dirty reads, HANDOFF doc P3.7), zero internal searching. \
            \ P3.4's dumb-writer: <stoa-results> (precomputed by \
            \ SWPU::URC_ComputeStoaValueResults inside SWPU::C_SmartSwap) is mapped \
            \ straight into XE_UpdateStoaValue below — no URC_PoolValue re-derivation \
            \ at the Talos layer at all, unlike CC_SWP|SmartSwapWithSlippage above."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (result:list
                        (ref-SWPU::C_SmartSwap
                            account input-id input-amount output-id
                            slippage stoa-pid slippage-bounds bundle
                        )
                    )
                    (ico:object{IgnisCollectorV1.OutputCumulator} (at 0 result))
                    (stoa-results:list (at 1 result))
                    (out:list (at "output" ico))
                )
                (ref-IGNIS::C_Collect patron ico)
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
    (defun C_SWP|SmartSwapNoSlippage
        (
            patron:string
            account:string
            input-id:string
            input-amount:decimal
            output-id:string
            bundle:object{SwapperUsageV2.SmartSwapPathBundle}
        )
        @doc "#34 Phase 8: bundle-based Smart Swap without slippage protection. Unlike \
            \ CC_SWP|SmartSwapNoSlippage above, the dummy slippage-bounds object is built \
            \ via SWPU::UDC_Slippage directly (not UDC_SpawnSmartSwapSlippageBounds, \
            \ which itself performs a live URC_HopperActive search — defeating the whole \
            \ point of the bundle-based path)."
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV2.Slippage} (ref-SWPU::UDC_Slippage 0.0 0 0.0))
                    (result:list
                        (ref-SWPU::C_SmartSwap
                            account input-id input-amount output-id
                            -1.0 stoa-pid slippage-bounds bundle
                        )
                    )
                    (ico:object{IgnisCollectorV1.OutputCumulator} (at 0 result))
                    (stoa-results:list (at 1 result))
                    (out:list (at "output" ico))
                )
                (ref-IGNIS::C_Collect patron ico)
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
    (defun C_SWP|SingleSwapWithSlippage
        (
            patron:string
            account:string
            swpair:string
            input-id:string
            input-amount:decimal
            output-id:string
            slippage-bounds:object{SwapperUsageV2.Slippage}
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> with <slippage>"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            account swpair [input-id] [input-amount] output-id 
                            slippage stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )
    (defun C_SWP|SingleSwapNoSlippage
        (
            patron:string
            account:string
            swpair:string
            input-id:string
            input-amount:decimal
            output-id:string
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> without slippage"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV2.Slippage}
                        (ref-SWPU::UDC_SpawnSlippageBounds swpair [input-id] [input-amount] output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            account swpair [input-id] [input-amount] output-id 
                            -1.0 stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )
    (defun C_SWP|MultiSwapWithSlippage
        (
            patron:string
            account:string
            swpair:string
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
            slippage-bounds:object{SwapperUsageV2.Slippage}
        )
        @doc "Executes A Swap from <input-ids> with <input-amounts> to <output-id> with <slippage>"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage:decimal (at "slippage-percent" slippage-bounds))
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            account swpair input-ids input-amounts output-id 
                            slippage stoa-pid slippage-bounds
                        )
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )
    (defun C_SWP|MultiSwapNoSlippage
        (
            patron:string
            account:string
            swpair:string
            input-ids:[string]
            input-amounts:[decimal]
            output-id:string
        )
        @doc "Executes A Swap from <input-id> with <input-amount> to <output-id> without slippage"
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    (ref-SWPU:module{SwapperUsageV2} SWPU)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (slippage-bounds:object{SwapperUsageV2.Slippage}
                        (ref-SWPU::UDC_SpawnSlippageBounds swpair input-ids input-amounts output-id -1.0)
                    )
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SWPU::C_Swap 
                            account swpair input-ids input-amounts output-id 
                            -1.0 stoa-pid slippage-bounds)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-SWP::XE_UpdateStoaValue swpair (at 0 (ref-SWPI::URC_PoolValue swpair)))
                (format "Succesfully swapped input(s) to {} {}" [(at 0 (at "output" ico)) output-id])
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)