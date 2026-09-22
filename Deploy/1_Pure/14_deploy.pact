;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 14 of 24
;; This is STEP 14 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-13 must have run first, including the init steps between deploys.
;; 3 source file(s), 102,008 gas measured in the REPL gas model, 270,737 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact
;;
;; TOTAL: 3 interface(s), 2 module(s), 12 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact
;;      interface  DemiourgosLaunchpadV2
;;      module     DEMIPAD
;;      table      P|T
;;      table      P|MT
;;      table      DEMIPAD|T|Ledger
;;      table      DEMIPAD|T|Properties
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact
;;      interface  AcquisitionSchemasV1
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact
;;      interface  AcquisitionAnchorsV1
;;      module     AQP-ANK
;;      table      P|T
;;      table      P|MT
;;      table      ANK|T|Anchor
;;      table      ANK|T|BoostClass
;;      table      ANK|T|AssetAnchors
;;      table      ANK|T|BoostClassScoreLinks
;;      table      ANK|T|Anchors
;;      table      ANK|T|UserBoost
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact ======
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosLaunchpadV2
    @doc "Sovereign interface defining the API for the DemiPad launchpad, a permissioned \
        \ venue where Demiourgos.Holdings sells assets (true/orto/semi/non-fungibles) for \
        \ WSTOA, SSTOA or OURO while retaining a decreasing royalty fee. It declares schemas \
        \ for Costs, launchpad Properties, per-asset Holdings, Prices and RoyaltyInterval, \
        \ plus constructors, compute helpers (royalty intervals, deposit royalty, \
        \ environment split), and readers for launchpad and asset state. It also exposes \
        \ acquire/price computation, IGNIS cost-preview deposit/transmit functions, \
        \ fungibility validators, owner capabilities, admin operations (register asset, \
        \ toggle sale/retrieval, define price), and client deposit/withdraw/transmit \
        \ entrypoints."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|DEMIPAD|SC_NAME ())

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
    ;;  [Schemas]
    ;;
    (defschema Costs
        pid:decimal
        wstoa:decimal
    )
    ;;
    (defschema DEMIPAD|Properties
        direct-injection:bool
        resident-wstoa:decimal
        resident-sstoa:decimal
        resident-ouro:decimal
    )
    (defschema DEMIPAD|Holdings
        total-dollarz-raised:decimal
        total-wstoa-raised:decimal
        total-sstoa-raised:decimal
        total-ouro-raised:decimal
        funds-wstoa:decimal
        funds-sstoa:decimal
        funds-ouro:decimal
        ;;
        iz-sstoa:bool
        iz-ouro:bool
        ;;
        fungibility:[bool]
        open-for-business:bool
        price:object
        retrieval:bool
    )
    (defschema DEMIPAD|Prices
        receiver-one:string
        receiver-two:string
        receiver-three:string
        receiver-four:string
        amount-one:decimal
        amount-two:decimal
        amount-three:decimal
        amount-four:decimal
        enviroment-amount:decimal
        coding-amount:decimal
        remainder-amount:decimal
    )
    (defschema RoyaltyInterval
        "Schema for fee intervals"
        start:decimal
        end:decimal
        fee-promille:decimal
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
    ;;  [UDC]
    ;;
    (defun UDC_Costs:object{Costs} (a:decimal b:decimal))
    (defun UDC_DEMIPAD|Holdings:object{DEMIPAD|Holdings}
        (
            a:decimal b:decimal c:decimal d:decimal
            e:decimal f:decimal g:decimal
            h:bool i:bool
            j:[bool] k:bool l:object m:bool
        )
    )
    (defun UDC_LaunchpadPrices:object{DEMIPAD|Prices}
        (
            a:string b:string c:string d:string
            e:decimal f:decimal g:decimal h:decimal
            j:decimal k:decimal l:decimal
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_Type:string (asset-id:string fungibility:[bool]))
    (defun UC_GenerateRoyaltyIntervals:[object{RoyaltyInterval}] ())
    (defun UCv_ComputeDepositRoyalty:decimal (current-balance:decimal deposit-amount:decimal))
    (defun UC_LaunchpadEnviromentSplit:[decimal] (amount-in-stoa:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_LaunchpadState:object{DEMIPAD|Properties} ())
    (defun UR_DirectInjection:bool ())
    (defun UR_WSTOA:decimal ())
    (defun UR_SSTOA:decimal ())
    (defun UR_OURO:decimal ())
        ;;
    (defun UR_AssetState:object{DEMIPAD|Holdings} (asset-id:string))
    (defun UR_TotalDollarzRaised:decimal (asset-id:string))
    (defun UR_TotalWSTOARaised:decimal (asset-id:string))
    (defun UR_TotalSSTOARaised:decimal (asset-id:string))
    (defun UR_TotalOURORaised:decimal (asset-id:string))
    (defun UR_WSTOA|Funds:decimal (asset-id:string))
    (defun UR_SSTOA|Funds:decimal (asset-id:string))
    (defun UR_OURO|Funds:decimal (asset-id:string))
        ;;
    (defun UR_IzSSTOA:bool (asset-id:string))
    (defun UR_IzOURO:bool (asset-id:string))
    (defun UR_Fungibility:[bool] (asset-id:string))
    (defun UR_OpenForBusiness:bool (asset-id:string))
    (defun UR_Price:object (asset-id:string))
    (defun UR_Retrieval:bool (asset-id:string))
    (defun UR_CheckRegistration:bool (asset-id:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_Prices:object{DEMIPAD|Prices} (asset-id:string amount-in-dollars:decimal type:integer))
    (defun URC_Acquire:[string] (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer slippage:decimal))
    (defun URCi_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool)
    )
    (defun URCi_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    (defun URCi_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_AssetFungibility (asset-id:string fungibility-to-check:[bool]))
    (defun UEV_Fungibility (fungibility:[bool]))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (asset-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string executor:string asset-id:string fungibility:[bool]))
    (defun A_ToggleOpenForBusiness (patron:string executor:string asset-id:string toggle:bool))
    (defun A_DefinePrice (patron:string executor:string asset-id:string price:object))
    (defun A_ToggleRetrieval (patron:string executor:string asset-id:string toggle:bool))
    ;;
    ;;  [C]
    ;;
    (defun C_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
    )
    (defun C_Withdraw (patron:string executor:string asset-id:string type:integer destination:string)
    )
    ;;
    (defun C_TransmitTrueFungible (patron:string executor:string asset-id:string amount:decimal fuel-or-retrieve:bool))
    (defun C_TransmitOrtoFungible (patron:string executor:string asset-id:string nonces:[integer] fuel-or-retrieve:bool))
    (defun C_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator} 
        (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    (defun C_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )

)
(module DEMIPAD GOV
    @doc "Demiourgos Launchpad, is a permissioned Launchpad operated by Demiourgos.Holdings  \
        \ allowing the Company to sell Assets (DPTFs, DPMFs, DPSFs and DPNFs) \
        \ \
        \ HOW IT WORKS: \
        \ The Launchpad Admin registers an Asset for Sale, this Asset is then Permanently registered to the Launchpad \
        \ Sale is executed via Functions, in Modules created by Demiourgos Holdings, specific to each Asset \
        \ \
        \ For Sale, both Native STOA and WSTOA are accepted, but also SSTOA or OURO \
        \ \
        \ From the incoming funds, The Launchpad Retains a Royalty Fee. This starts at 15%. \
        \ The Royalty Decreases going as low as 0.3% the more an asset sales for. \
        \ One THIRD of Royalty goes to the Enviroment as Native STOA (Unwrap would be executed if WSTOA Input is used): \
        \       = 10% to Ouronet Gas Station \
        \       = 20% to Demiourgos.Holdings Treasury \
        \       = 30$ to Launchpad Maintanance \
        \       = 40% to Liquid Staking \
        \ TWO THIRDS is injected to Coding Division Pot (half to Coding Division Collection, half to Shareholders Collection) \
        \       when acquisitions pool are coming Live \
        \       Until then, it will be retained in the Pool as Resident WSTOA, SSTOA or OURO \
        \ \
        \ If Assets are Sold for SSTOA or OURO, then a third of the Royalty Fee, must be supplied as Native Stoa to satisfy the Enviroment \
        \ \
        \ Remaining Tokens (after Royalty deduction) can be withdrawn by Asset Owner or Creator (for SFTs and NFTs), or Launchpad Admin \
        \ \
        \ Launchpad Admin can update <open-for-business>, <price> and <retrieval> for each registered Asset \
        \ \
        \ <open-for-business>   = Determines if the Asset is on sale and if it can be bought by those that want to acquire it \
        \ <price> object        = Holds information regarding the Sale Price. This is then used by the Individual Asset Modules in the Sale Function \
        \ <retrieval> parameter = Defines if Asset Owners or Creators can withdraw their Assets from the Launchpad (default false) \
        \                       If set to <false> the only way to retrieve Assets is to execute a buy(sale). \
        \ \
        \ Each Asset has its own Sale Module, that defines the logic of the Buy Functions, allowing for individual custom logic to be implemented for each Sale \
        \ Which is the reason this is a permissioned Launchpad, as each Sale can have its own specific logic regarding Asset Acquisition \
        \ \
        \ \
        \ \
        \ Permissioned Launchpad, means its part of the Core Modules from Stage 2 \
        \ A permissionless Launchpad, in the form of the IGNIS Market Place will be launched after the Acquisition Pools Deployment"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DemiourgosLaunchpadV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DEMIPAD                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DEMIPAD_ADMIN)))
    (defcap GOV|DEMIPAD_ADMIN ()                        (enforce-guard GOV|MD_DEMIPAD))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LaunchpadKey ()                          (+ (CT_Namespace) ".dh_sc_mb-keyset"))
    ;;(defun GOV|LaunchpadKey ()              (+ (CT_Namespace) ".dh_sc_demipad-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DEMIPAD|SC_NAME ()                       (at 0 ["Σ.Îäć$ЬчýφVεÎÿůпΨÖůηüηŞйnюŽXΣşpЩß5ςĂκ£RäbE₳èËłŹŘYшÆgлoюýRαѺÑÏρζt∇ŹÏýжIŒațэVÞÛщŹЭδźvëȘĂтPЖÃÇЭiërđÈÝДÖšжzČđзUĚĂsкιnãñOÔIKпŞΛI₳zÄû$ρśθ6ΨЬпYпĞHöÝйÏюşí2ćщÞΔΔŻTж€₿ŞhTțŽ"]))
    ;;
    ;; [PBLs]
    (defun GOV|DEMIPAD|PBL ()                           (at 0 ["9F.gGCkuc2wMAnFAjuFphikftLdl6qFqBD4yfeMEe9u65yMqf4r340Jd6dphh1d7E1cE20btMwl4HJ2cBEMvp209GA1eD4syB96hu4nmpFbB7dKnJEMz4p8fGLcmhvrBCfDmM0axnGin8qedl5vDtwbgL3l1aK5BsmjkEEJartqCH8qG8ialtjxwCcIMf50t2lkeww6Dct5LlmmLG25FmfpcgnwMMnkJl4Gfn9gwoA6vm0jKebjhodeJLjxnh9L11ss8f26866dqv1tEphxFFqutGetH4Itj3rHkrcrGsnlqpf4gfJp94b0gBwIBe4vCj6ha8jm6kd3f8B6pEaJtkJ3fbs6rCcGibltz1BAMn0vvKME5ddFyGBnzssk1s2s0vFzwxs6vjC61Ma2l1xDxqdg1thAk2u01hDiGndLhzK73HAfgtk7bxscn0qKhymG6JAqnEFt282pyHAq5nIthK9bA8nH76x7FEpLz4eK9tLIBsyjb8M5DxaeEei6pEnLxFCAg7ulacgtjjpjMiAaqhpmM1jEHqjt4G85q4L33zrME7whgIkIpIgwnF2qKd4"]))

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
    (defcap P|DEMIPAD|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DEMIPAD|CALLER))
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
        (with-capability (GOV|DEMIPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DEMIPAD_ADMIN)
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
        (with-capability (GOV|DEMIPAD_ADMIN)
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
        (with-capability (GOV|DEMIPAD_ADMIN)
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
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|DEMIPAD|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_KEY                            (GOV|LaunchpadKey))
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst MB|SC_STOA-NAME                           "k:xxx")
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst TF                                        [true true])
    (defconst OF                                        [true false])
    (defconst SF                                        [false true])
    (defconst NF                                        [false false])
    ;;
    (defconst PP                                        "Launchpad-Properties")
    ;;{3.2}  schemas
    ;;{3.3}  tables
    ;;
    (deftable DEMIPAD|T|Properties:{DemiourgosLaunchpadV2.DEMIPAD|Properties})
    (deftable DEMIPAD|T|Ledger:{DemiourgosLaunchpadV2.DEMIPAD|Holdings})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DEMIPAD|GOV ()
        @doc "Governor Capability for the DEMIPAD Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;
    ;;#2H: the retrieval lock the launchpad advertises to buyers. A non-admin Owner/Creator may pull
    ;;    deposited assets back out ONLY when retrieval is enabled; the Launchpad admin may always
    ;;    retrieve. FUEL (deposit) is never gated — only RETRIEVE composes this. (Option A: admin override.)
    (defcap DEMIPAD|C>RETRIEVAL-GATE (asset-id:string)
        (enforce-one
            (format "Asset {} retrieval is LOCKED (retrieval=false) — only the Launchpad admin may retrieve until a sale or an admin re-enable" [asset-id])
            [
                (enforce-guard GOV|MD_DEMIPAD)
                (enforce (UR_Retrieval asset-id) "retrieval disabled")
            ]
        )
    )
    ;;{C3}  Composed
    (defcap DEMIPAD|C>REGISTER (asset-id:string fungibility:[bool])
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (UEV_Fungibility fungibility)
    )
    (defcap DEMIPAD|C>SECURE-ADMIN ()
        (compose-capability (GOV|DEMIPAD_ADMIN))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DEMIPAD|C>TOGGLE-SALE (asset-id:string toggle:bool)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (let
            (
                (ofb:bool (UR_OpenForBusiness asset-id))
            )
            (enforce (!= toggle ofb) (format "Open for business is already {} for Asset {}" [toggle asset-id]))
        )
    )
    (defcap DEMIPAD|C>DEFINE-PRICE (asset-id:string price:object)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
    )
    (defcap DEMIPAD|C>TOGGLE-RETRIEVAL (asset-id:string toggle:bool)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (let
            (
                (rtr:bool (UR_Retrieval asset-id))
            )
            (enforce (!= toggle rtr) (format "Retrieval is already {} for Asset {}" [toggle asset-id]))
        )
    )
    ;;
    ;;
    (defcap DEMIPAD|C>FUEL-TRUE-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true true]))
    )
    (defcap DEMIPAD|C>FUEL-ORTO-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true false]))
    )
    (defcap DEMIPAD|C>FUEL-SEMI-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false true]))
    )
    (defcap DEMIPAD|C>FUEL-NON-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false false]))
    )
    ;;
    (defcap DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true true]))
    )
    (defcap DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true false]))
    )
    (defcap DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false true]))
    )
    (defcap DEMIPAD|C>RETRIEVE-NON-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false false]))
    )
    ;;
    (defcap DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE (asset-id:string fungibility:[bool])
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS asset-id))
        (UEV_AssetFungibility asset-id fungibility)
    )
    ;;
    (defcap DEMIPAD|C>REGISTERED-ACCESS (asset-id:string)
        @doc "Fails is <asset-id> is not registered to Launchpad"
        (enforce-one
            (format "Only LPAD Admin or {} Owner|Creator may acces the Launchpad" [asset-id])
            [
                (enforce-guard (create-user-guard (CAP_Owner asset-id)))
                (enforce-guard GOV|MD_DEMIPAD)
            ]
        )
        (compose-capability (DEMIPAD|GOV))
        (compose-capability (SECURE))
    )
    ;;Deposti and Withdrawal
    ;;Module-local (no interface change): the single source for "is this a spendable dollar
    ;;amount". Shared by DEMIPAD|C>DEPOSIT and URCi_Deposit so every launchpad quote and the
    ;;deposit it previews refuse the same inputs, in the same words.
    ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-006b/c>>.
    (defun UEV_DepositDollarAmount (amount-in-dollars:decimal)
        (enforce
            (and
                (= (floor amount-in-dollars 24) amount-in-dollars)
                (> amount-in-dollars 0.0)
            )
            "Invalid Dollar Amount for Deposit"
        )
    )
    (defcap DEMIPAD|C>DEPOSIT (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-type:bool (contains type [0 1 2 3]))
                (iz-registered:bool (UR_CheckRegistration asset-id))
                (ofb:bool (UR_OpenForBusiness asset-id))
                (iz-sstoa:bool (UR_IzSSTOA asset-id))
                (iz-ouro:bool (UR_IzOURO asset-id))
            )
            ;;Validate <donor> to be Standard Ouronet Account
            (ref-DALOS::UEV_EnforceAccountType donor false)
            ;;Validate <asset-id> to be a Launchpad registered Asset
            ;;FIXED 2026-09-12, owner-ruled. This message used to be UNREACHABLE: the `let` above
            ;;binds FOUR reads of this same Ledger row and a `let` is EAGER, so `ofb`, `iz-sstoa` and
            ;;`iz-ouro` -- then bare `read`s -- ran BEFORE this enforce and aborted the transaction
            ;;with `No value found in table ... DEMIPAD|T|Ledger for key: <asset>`. The deposit was
            ;;still refused (never a funds hole), but the sentence written for exactly that case
            ;;never arrived. Owner ruling: make every reader SUCCEED to true/false rather than abort.
            ;;All three are now `with-default-read`, matching what UR_CheckRegistration already did
            ;;with its `(try false ...)`. Pinned by REPL/Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>
            ;;01b. See memories/2026-09-12-eager-let-mute-guards.md
            (enforce iz-registered (format "Asset {} is not registered to the Demiourgos Lauchpad. Deposit unallowed" [asset-id]))
            ;;Validate the <amount-in-dollars> to be greater than zero with 3 decimals.
            ;;REFUSAL PARITY (family K, 2026-09-16): this enforce used to be written out here, so
            ;;URCi_Deposit -- and therefore EVERY launchpad preview that prices a purchase through
            ;;it -- had no way to share it. INFO_BuySparks quoted a buy of ZERO Sparks that this
            ;;line refuses, and for a NEGATIVE amount the preview refused with someone else's
            ;;message ("Deposit amount must be non-negative", reached incidentally from
            ;;UCv_ComputeDepositRoyalty). Now in UEV_DepositDollarAmount, called by both.
            (UEV_DepositDollarAmount amount-in-dollars)
            ;;Slippage bound (Variant 1): the live-computed dollar cost must not exceed the buyer's
            ;;signed ceiling <max-cost>. Sentinel <max-cost> < 0 = no bound (Variant 2, slippage off).
            (UEV_SlippageCost amount-in-dollars max-cost)
            ;;Validate <type> to be either 0, 1, 2 or 3, and that the required Token Deposit is turned on
            (enforce iz-type "Invalid Deposit type")
            ;;MESSAGE FIXED 2026-09-14. The type-3 branch enforces <iz-ouro> and used to report
            ;;"SSTOA Deposits must be turned on" -- naming a DIFFERENT, separately-togglable admin
            ;;flag. That is the actively-misleading shape, not merely a terse one: the operator CAN
            ;;carry out the suggested remedy, turn SSTOA deposits on, observe nothing change, and
            ;;retry forever. Same class as DALOS GOV|MIGRATE's inverted pause message, fixed the
            ;;same day. Each branch now names the flag it actually reads.
            (if (not (or (= type 0) (= type 1)))
                (if (= type 2)
                    (enforce iz-sstoa "SSTOA Deposits must be turned on for exec")
                    (enforce iz-ouro "OURO Deposits must be turned on for exec")
                )
                true
            )
            ;;Direct-Injection is an unbuilt feature (routes the <cod> royalty into an
            ;;injection profile once AQP vaults are live). It is HARD-BLOCKED here so no
            ;;admin flag can half-enable the unfinished path (prevents phantom seller funds).
            (UEV_DirectInjection direct-injection)
            ;;<open-for-business> must be turned on to allow Deposits
            (enforce ofb (format "{} is not open for business, to allow deposits" [asset-id]))
            ;;Acces Capabilities
            (compose-capability (DEMIPAD|GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DEMIPAD|C>WITHDRAW (asset-id:string type:integer retrieval-amount:decimal destination:string )
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-type:bool (contains type [1 2 3]))
            )
            ;;Validate <type> to be either 1, 2 or 3, and that the required Token Deposit is on.
            ;;
            ;;SHADOWED AT TODAY'S ONLY CALL SITE - kept deliberately. C_Withdraw binds
            ;;(URv_Funds asset-id type) BEFORE acquiring this capability, and URv_Funds opens with
            ;;the IDENTICAL predicate under a different message, so an out-of-range <type> always
            ;;aborts there with "Invalid Read Type" and this line never fires. It is NOT a hole:
            ;;the input is still rejected, only the message is less specific.
            ;;
            ;;Not removed, and not "fixed" by restructuring: <retrieval-amount> is a parameter of
            ;;this @event capability and the body needs it for the transfer, so the read must
            ;;happen first - and moving it inside would change an EVENT SIGNATURE that indexers
            ;;consume. This enforce is the defence-in-depth that makes the capability correct on
            ;;its own terms for any FUTURE caller that does not read first. Pinned as-is in
            ;;REPL/Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>.
            ;;UNREACHABLE (shadowed) -- the analysis above is the proof; this marker is what keeps
            ;;it out of the pinning worklist. Same category as 05_DPTF:1004: not dead, not a hole,
            ;;simply answered earlier by an identical predicate on every path that exists today.
            ;;Revisit if a call site is ever added that does NOT read URv_Funds first.
            (enforce iz-type "Invalid Withdrawal type")
            ;;Validate <retrieval-amount> to be non-zero
            (enforce 
                (> retrieval-amount 0.0) 
                (format "There is nothing to retrieve for Asset-Id {} and Token Type {} ({})." 
                    [
                        asset-id
                        type
                        (if (= type 1) "WSTOA" (if (= type 2) "SSTOA" "OURO"))
                    ]
                )
            )
            ;;Validate <destination> to be Standard Ouronet Account
            (ref-DALOS::UEV_EnforceAccountType destination false)
            ;;Only <asset-id> Owner|Creator, or Launchpad Admin can retrieve Launchpad Funds
            (compose-capability (DEMIPAD|C>REGISTERED-ACCESS asset-id))
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;;
    (defun UDC_Costs:object{DemiourgosLaunchpadV2.Costs} 
        (a:decimal b:decimal)
        {"pid"  : a
        ,"wstoa" : b}
    )
    (defun UDC_DEMIPAD|Holdings:object{DemiourgosLaunchpadV2.DEMIPAD|Holdings}
        (
            a:decimal b:decimal c:decimal d:decimal
            e:decimal f:decimal g:decimal
            h:bool i:bool
            j:[bool] k:bool l:object m:bool
        )
        {"total-dollarz-raised"         : a
        ,"total-wstoa-raised"            : b
        ,"total-sstoa-raised"            : c
        ,"total-ouro-raised"            : d
        ,"funds-wstoa"                   : e
        ,"funds-sstoa"                   : f
        ,"funds-ouro"                   : g
        ;;
        ,"iz-sstoa"                      : h
        ,"iz-ouro"                      : i
        ;;
        ,"fungibility"                  : j
        ,"open-for-business"            : k
        ,"price"                        : l
        ,"retrieval"                    : m
        }
    )
    (defun UDC_LaunchpadPrices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices}
        (
            a:string b:string c:string d:string
            e:decimal f:decimal g:decimal h:decimal
            j:decimal k:decimal l:decimal
        )
        {"receiver-one"         : a
        ,"receiver-two"         : b
        ,"receiver-three"       : c
        ,"receiver-four"        : d
        ,"amount-one"           : e
        ,"amount-two"           : f
        ,"amount-three"         : g
        ,"amount-four"          : h
        ,"enviroment-amount"    : j
        ,"coding-amount"        : k
        ,"remainder-amount"     : l}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_Type:string (asset-id:string fungibility:[bool])
        (cond
            ((= fungibility TF) "True Fungible")
            ((= fungibility OF) "Orto-Fungible")
            ((= fungibility SF) "Semi-Fungible")
            ((= fungibility NF) "Non-Fungible")
            ""
        )
    )
    (defun UC_GenerateRoyaltyIntervals:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] ()
        @doc "Generate list of fee intervals until fee reaches 3 promille"
        (let* 
            (
                (first-interval-size:decimal 10000.0)
                (initial-increment:decimal 5000.0)
                (fee-decrement:decimal 3.0)
                (min-fee:decimal 3.0)
            )
            (fold
                (lambda 
                    (acc:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] idx:integer)
                    (let* 
                        (
                            (start:decimal
                                (if (= idx 0)
                                    0.0
                                    (at "end" (at 0 (take -1 acc)))
                                )
                            )
                            (increment-velocity:decimal 
                                (if (= idx 0)
                                    0.0
                                    (+ initial-increment (* 100.0 (dec (- idx 1)))))
                                )
                                
                            (prev-interval-size:decimal
                                (if (= idx 0)
                                    first-interval-size
                                    (-
                                        (at "end" (at 0 (take -1 acc)))
                                        (at "start" (at 0 (take -1 acc)))
                                    )
                                )
                            )
                            (increment:decimal (+ increment-velocity prev-interval-size))
                            (end:decimal 
                                (if (= idx 0)
                                    first-interval-size
                                    (+ start increment)
                                )
                            )
                            (fee-promille (- 150.0 (* fee-decrement (dec idx))))
                        )
                        (if (>= fee-promille min-fee)
                            (+ acc [{"start": start, "end": end, "fee-promille": fee-promille}])
                            acc
                        )
                    )
                )
                []
                (enumerate 0 49)
            )
        )
    )
    (defun UC_SlippageFactor:decimal (slippage:decimal)
        @doc "Pure slippage multiplier: (1 + slippage/100). slippage is a percent (1.0 = 1%). Used to pad \
            \ the signed coin.TRANSFER cap ceilings in URC_Acquire (Variant 1)."
        (+ 1.0 (/ slippage 100.0))
    )
    (defun UCv_ComputeDepositRoyalty:decimal (current-balance:decimal deposit-amount:decimal)
        @doc "Compute fee for a deposit given current balance and deposit amount"
        (enforce (>= current-balance 0.0) "Current balance must be non-negative")
        (enforce (>= deposit-amount 0.0) "Deposit amount must be non-negative")
        (let* 
            (
                (deposit-start:decimal current-balance)
                (deposit-end:decimal (+ current-balance deposit-amount))
                (intervals:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] (UC_GenerateRoyaltyIntervals))
                (last-interval:object{DemiourgosLaunchpadV2.RoyaltyInterval} (at (- (length intervals) 1) intervals) )
                (last-interval-end:decimal (at "end" last-interval))
                (min-fee:decimal (at "fee-promille" last-interval))
                (min-fee-rate:decimal (/ min-fee 1000.0))
            )
            (+
                ;;Interval Fees
                (fold
                    (lambda (total-fee:decimal interval:object{DemiourgosLaunchpadV2.RoyaltyInterval})
                        (let 
                            (
                                (interval-start (at "start" interval))
                                (interval-end (at "end" interval))
                                (fee-rate (/ (at "fee-promille" interval) 1000.0))
                            )
                            (if (and (< deposit-start interval-end) (> deposit-end interval-start))
                                (+ 
                                    total-fee
                                    (* 
                                        fee-rate
                                        (- 
                                            (if (<= deposit-end interval-end) deposit-end interval-end)
                                            (if (>= deposit-start interval-start) deposit-start interval-start)
                                        )
                                    )
                                )
                                total-fee
                            )
                        )
                    )
                    0.0
                    intervals
                )
                ;;Beyond Fees
                (if (> deposit-end last-interval-end)
                    (* 
                        min-fee-rate
                        (- 
                            deposit-end 
                            (if (>= deposit-start last-interval-end) deposit-start last-interval-end)
                        )
                    )
                    0.0
                )
            )
        )
    )
    (defun UC_LaunchpadEnviromentSplit:[decimal] (amount-in-stoa:decimal)
        @doc "Outputs the Launchpad Enviroment Split, whic is a \
        \ 10%, 20%, 30%, 40% Split, outputed as a 4 element list."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
            )
            (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit amount-in-stoa stoa-prec)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_LaunchpadState:object{DemiourgosLaunchpadV2.DEMIPAD|Properties} ()
        (read DEMIPAD|T|Properties PP)
    )
    (defun UR_DirectInjection:bool ()
        (at "direct-injection" (UR_LaunchpadState))
    )
    (defun UR_WSTOA:decimal ()
        (at "resident-wstoa" (UR_LaunchpadState))
    )
    (defun UR_SSTOA:decimal ()
        (at "resident-sstoa" (UR_LaunchpadState))
    )
    (defun UR_OURO:decimal ()
        (at "resident-ouro" (UR_LaunchpadState))
    )
    ;;
    (defun UR_AssetState:object{DemiourgosLaunchpadV2.DEMIPAD|Holdings} (asset-id:string)
        (read DEMIPAD|T|Ledger asset-id)
    )
    (defun UR_TotalDollarzRaised:decimal (asset-id:string)
        (at "total-dollarz-raised" (read DEMIPAD|T|Ledger asset-id ["total-dollarz-raised"]))
    )
    (defun URv_TotalRaised:decimal (asset-id:string type:integer)
        (enforce (contains type [1 2 3]) "Invalid Read Type")
        (cond
            ((= type 1) (UR_TotalWSTOARaised asset-id))
            ((= type 2) (UR_TotalSSTOARaised asset-id))
            ((= type 3) (UR_TotalOURORaised asset-id))
            0.0
        )
    )
    (defun URv_Funds:decimal (asset-id:string type:integer)
        (enforce (contains type [1 2 3]) "Invalid Read Type")
        (cond
            ((= type 1) (UR_WSTOA|Funds asset-id))
            ((= type 2) (UR_SSTOA|Funds asset-id))
            ((= type 3) (UR_OURO|Funds asset-id))
            0.0
        )
    )
    (defun UR_TotalWSTOARaised:decimal (asset-id:string)
        (at "total-wstoa-raised" (read DEMIPAD|T|Ledger asset-id ["total-wstoa-raised"]))
    )
    (defun UR_TotalSSTOARaised:decimal (asset-id:string)
        (at "total-sstoa-raised" (read DEMIPAD|T|Ledger asset-id ["total-sstoa-raised"]))
    )
    (defun UR_TotalOURORaised:decimal (asset-id:string)
        (at "total-ouro-raised" (read DEMIPAD|T|Ledger asset-id ["total-ouro-raised"]))
    )
    (defun UR_WSTOA|Funds:decimal (asset-id:string)
        (at "funds-wstoa" (read DEMIPAD|T|Ledger asset-id ["funds-wstoa"]))
    )
    (defun UR_SSTOA|Funds:decimal (asset-id:string)
        (at "funds-sstoa" (read DEMIPAD|T|Ledger asset-id ["funds-sstoa"]))
    )
    (defun UR_OURO|Funds:decimal (asset-id:string)
        (at "funds-ouro" (read DEMIPAD|T|Ledger asset-id ["funds-ouro"]))
    )
    ;;
    (defun UR_IzSSTOA:bool (asset-id:string)
        ;;with-default-read, not read: an UNREGISTERED asset has no row, and a bare read would abort
        ;;the transaction before any caller's `enforce` could speak. See the note on UR_CheckRegistration.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "iz-sstoa" : false } { "iz-sstoa" := x } x)
    )
    (defun UR_IzOURO:bool (asset-id:string)
        ;;with-default-read, not read -- same reason as UR_IzSSTOA above.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "iz-ouro" : false } { "iz-ouro" := x } x)
    )
    (defun UR_Fungibility:[bool] (asset-id:string)
        (at "fungibility" (read DEMIPAD|T|Ledger asset-id ["fungibility"]))
    )
    (defun UR_OpenForBusiness:bool (asset-id:string)
        ;;with-default-read, not read. FALSE is the semantically correct answer for an asset with no
        ;;Ledger row -- a thing that is not registered is certainly not open for business -- and it
        ;;lets DEMIPAD|C>DEPOSIT's registration enforce actually be reached. All four call sites were
        ;;checked: the two in this module, 2_CITIZEN/.../01_Spark.pact and Stage_Z/01_DPL-UR.pact;
        ;;every one of them is better served by `false` than by an aborted transaction.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "open-for-business" : false } { "open-for-business" := x } x)
    )
    (defun UR_Price:object (asset-id:string)
        (at "price" (read DEMIPAD|T|Ledger asset-id ["price"]))
    )
    (defun UR_Retrieval:bool (asset-id:string)
        (at "retrieval" (read DEMIPAD|T|Ledger asset-id ["retrieval"]))
    )
    ;;
    (defun UR_CheckRegistration:bool (asset-id:string)
        (try
            false
            (with-read DEMIPAD|T|Ledger asset-id 
                { "price" := dummy }
                true
            )
        )
    )
    (defun URC_Prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} 
        (asset-id:string amount-in-dollars:decimal type:integer)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                ;;
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
                (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa-id))
                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (total-dollarz-raised:decimal (UR_TotalDollarzRaised asset-id))
                (deposit-royalty:decimal (UCv_ComputeDepositRoyalty total-dollarz-raised amount-in-dollars))
                (five-percent-dollarz:decimal (floor (/ deposit-royalty 3.0) 5))
                (ten-percent-dollarz:decimal (- deposit-royalty five-percent-dollarz))
                (remainder-percent-dollarz:decimal (- amount-in-dollars deposit-royalty))

                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (wstoa-pid:decimal (ref-SWPI::URC_TokenDollarPrice wstoa-id stoa-pid))
                (sstoa-pid:decimal (ref-SWPI::URC_TokenDollarPrice sstoa-id stoa-pid))
                (ouro-pid:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                ;;
                (five-percent-dollarz-as-stoa:decimal (floor (/ five-percent-dollarz wstoa-pid) wstoa-prec))
                (env-split:[decimal] (UC_LaunchpadEnviromentSplit five-percent-dollarz-as-stoa))
                ;;
                (type-pid:decimal 
                    (if (or (= type 0) (= type 1))
                        wstoa-pid
                        (if (= type 2)
                            sstoa-pid
                            ouro-pid
                        )
                    )
                )
                (type-prec:integer
                    (if (or (= type 0) (= type 1))
                        wstoa-prec
                        (if (= type 2)
                            sstoa-prec
                            ouro-prec
                        )
                    )
                )
            )
            (UDC_LaunchpadPrices
                ;;Enviroment Split with native STOA amounts
                (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|DALOS|SC_NAME))      ;;Gas-Station 10%
                (ref-DALOS::UR_AccountStoa (at 2 (ref-DALOS::UR_DemiurgoiID)))  ;;HOV 20%
                (ref-DALOS::UR_AccountStoa (at 1 (ref-DALOS::UR_DemiurgoiID)))  ;;CTO 30%
                (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|OUROBOROS|SC_NAME))  ;;Liquid Staking 40%
                (at 0 env-split)
                (at 1 env-split)
                (at 2 env-split)
                (at 3 env-split)
                ;;Total Enviroment Amount in native STOA
                five-percent-dollarz-as-stoa
                ;;CodingDivision and Remainder Split in WSTOA, SSTOA or OURO, depending on <type>
                (floor (/ ten-percent-dollarz type-pid) type-prec)
                (floor (/ remainder-percent-dollarz type-pid) type-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer slippage:decimal)
        @doc "Variant 1 (with slippage) — returns the coin.TRANSFER cap descriptions the UI must SIGN. \
            \ Each leg is padded by (1 + slippage/100) so the signed managed cap is a ceiling with \
            \ headroom: at execution the launchpad transfers the real (possibly-moved) price <= the \
            \ padded cap, succeeding within tolerance and failing safely beyond it. Pass slippage 0.0 \
            \ for exact caps. The buyer's on-chain cost ceiling is enforced separately by <max-cost> in \
            \ C_Deposit; the UI sets max-cost = displayed-cost x (1 + slippage/100), slippage <= 50 by UI \
            \ policy. The install-based, no-ceiling counterpart is CAP_Acquire (Variant 2, slippage off)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                ;;
                (buyer-stoa:string (ref-DALOS::UR_AccountStoa buyer))
                (lq-stoa:string (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id buy-amount-in-dollarz type))
                (kp:integer (ref-U|CT::CT_STOA_PRECISION))
                (f:decimal (UC_SlippageFactor slippage))
                ;;Slippage-padded per-leg ceilings (floored to STOA precision so the signed caps are valid)
                (a1:decimal (floor (* (at "amount-one" prices) f) kp))
                (a2:decimal (floor (* (at "amount-two" prices) f) kp))
                (a3:decimal (floor (* (at "amount-three" prices) f) kp))
                (a4:decimal (floor (* (at "amount-four" prices) f) kp))
                (non-env:decimal (floor (* (+ (at "coding-amount" prices) (at "remainder-amount" prices)) f) kp))
                (env-amt:decimal (floor (* (at "enviroment-amount" prices) f) kp))
                ;;
                (s1:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-one" prices) a1]))
                (s2:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-two" prices) a2]))
                (s3:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-three" prices) a3]))
                (s4:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-four" prices) a4]))
            )
            (if (= type 0)
                [
                    (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa lq-stoa non-env])
                    s1 s2 s3 s4
                ]
                (if (= type 1)
                    [
                        (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [lq-stoa buyer-stoa env-amt])
                        s1 s2 s3 s4
                    ]
                    [s1 s2 s3 s4]
                )
            )
        )
    )
    (defun URCi_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool)
        @doc "Cost preview for C_Deposit: (type 0) wrap-STOA of the non-environment amount, \
            \ (type 1) unwrap-STOA of the environment amount, and (unless direct-injection) the \
            \ donor->launchpad transfer of the working token. The Satisfy/Deposit writes are \
            \ free. Re-derived purely from URC_Prices."
        ;;The op's own gate, not a copy of it -- see UEV_DepositDollarAmount above.
        (UEV_DepositDollarAmount amount-in-dollars)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                ;;
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id amount-in-dollars type))
                (working-id:string
                    (if (or (= type 0) (= type 1))
                        (ref-DALOS::UR_WrappedStoaID)
                        (if (= type 2)
                            (ref-DALOS::UR_SilverStoaID)
                            (ref-DALOS::UR_OuroborosID)
                        )
                    )
                )
                (env:decimal (at "enviroment-amount" prices))
                (non-enviroment:decimal (+ (at "coding-amount" prices) (at "remainder-amount" prices)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (= type 0)
                        (ref-LIQUID::URCi_WrapStoa donor non-enviroment)
                        EOC
                    )
                    (if (= type 1)
                        (ref-LIQUID::URCi_UnwrapStoa donor env)
                        EOC
                    )
                    (if (not direct-injection)
                        (ref-TFT::URCi_Transfer working-id donor DEMIPAD|SC_NAME non-enviroment)
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Cost preview for C_TransmitSemiFungibles: the single collectable multi-transfer \
            \ (client->launchpad on fuel, launchpad->client on retrieve), son=true."
        (URCi_TransmitCollectables client asset-id true nonces amounts fuel-or-retrieve)
    )
    (defun URCi_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Cost preview for C_TransmitNonFungibles: as URCi_TransmitSemiFungibles with son=false."
        (URCi_TransmitCollectables client asset-id false nonces amounts fuel-or-retrieve)
    )
    (defun URCi_TransmitCollectables:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string son:bool nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Shared cost preview for the collectable transmit legs (mirrors XI_TransmitCollectables): \
            \ one DPDC-T multi-transfer, sender/receiver flipped by fuel-or-retrieve."
        (let
            (
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (lpad:string DEMIPAD|SC_NAME)
            )
            (if fuel-or-retrieve
                (ref-DPDC-T::URCi_MultiTransferCumulator [asset-id] [son] client lpad [nonces] [amounts])
                (ref-DPDC-T::URCi_MultiTransferCumulator [asset-id] [son] lpad client [nonces] [amounts])
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                ;;
                (buyer-stoa:string (ref-DALOS::UR_AccountStoa buyer))
                (lq-stoa:string (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id buy-amount-in-dollarz type))
                ;;

                (r1:string (at "receiver-one" prices))
                (r2:string (at "receiver-two" prices))
                (r3:string (at "receiver-three" prices))
                (r4:string (at "receiver-four" prices))
                (a1:decimal (at "amount-one" prices))
                (a2:decimal (at "amount-two" prices))
                (a3:decimal (at "amount-three" prices))
                (a4:decimal (at "amount-four" prices))
                (enviroment:decimal (at "enviroment-amount" prices))
                (coding:decimal (at "coding-amount" prices))
                (remainder:decimal (at "remainder-amount" prices))
            )
            (if (= type 0)
                (do
                    (install-capability (ref-coin::TRANSFER buyer-stoa lq-stoa (+ coding remainder)))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))

                )
                (if (= type 1)
                    (do
                        (install-capability (ref-coin::TRANSFER lq-stoa buyer-stoa enviroment))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))
                    )
                    (do
                        (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))
                    )
                )
            )
        )
    )
    (defun UEV_AssetFungibility (asset-id:string fungibility-to-check:[bool])
        (let
            (
                (type:string (UC_Type asset-id fungibility-to-check))
                (fungibility:[bool] (UR_Fungibility asset-id))
            )
            (enforce (= fungibility fungibility-to-check) (format "ID {} fungibility as {} is invalid" [asset-id type]))
        )
    )
    (defun UEV_Fungibility (fungibility:[bool])
        (let
            (
                (l:integer (length fungibility))
            )
            (enforce (= l 2) "Invalid Fungibility variable")
        )
    )
    (defun UEV_DirectInjection (direct-injection:bool)
        @doc "Direct-Injection is an unbuilt feature: once AQP vaults are live it will route the \
            \ <cod> royalty portion of a deposit into an injection profile (or collect-then-drip \
            \ once/day via an automaton). Until it is built it is HARD-BLOCKED here — this enforces \
            \ a deposit does not request it, UNCONDITIONALLY (no admin flag can enable the \
            \ unfinished path). This is what prevents the half-wired branch from crediting seller \
            \ funds with no tokens in custody (phantom funds). The <UR_DirectInjection> state is \
            \ kept reserved to gate the real path when it is implemented."
        (enforce (not direct-injection) "Direct Injection is not yet available")
    )
    (defun UEV_SlippageCost (amount-in-dollars:decimal max-cost:decimal)
        @doc "Slippage guard for a buy (Variant 1). The dollar cost computed live at execution \
            \ (<amount-in-dollars>) must not exceed the buyer's signed ceiling <max-cost>, which the UI \
            \ sets to displayed-cost x (1 + slippage/100). A sentinel <max-cost> below zero means NO \
            \ bound — the slippage-off path (Variant 2), where the buyer accepts the live price via \
            \ install-capability and is warned by the UI. Mirrors SWP's slippage protection, adapted to \
            \ bound a cost instead of a min output; the 50%% tolerance ceiling is a UI policy (the \
            \ on-chain code holds no poll-time baseline to recover the percent from)."
        (enforce
            (or (< max-cost 0.0) (<= amount-in-dollars max-cost))
            (format "Slippage: live cost {} exceeds the accepted maximum {}" [amount-in-dollars max-cost])
        )
    )
    (defun CAP_Owner (asset-id:string)
        @doc "Enforces <asset-id> ownership \
        \ Automaticaly enforces <asset-id> is registered, via <UR_Fungibility>"
        (let
            (
                (fungibility:[bool] (UR_Fungibility asset-id))
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (cond
                ((= fungibility TF) (ref-DPTF::CAP_Owner asset-id))
                ((= fungibility OF) (ref-DPOF::CAP_Owner asset-id))
                ((= fungibility SF) (ref-DPDC::CAP_OwnerOrCreator asset-id true))
                ((= fungibility NF) (ref-DPDC::CAP_OwnerOrCreator asset-id false))
                true
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_RegisterAsset (asset-id:string fungibility:[bool])
        (require-capability (SECURE))
        (insert DEMIPAD|T|Ledger asset-id 
            (UDC_DEMIPAD|Holdings 
                0.0 0.0 0.0 0.0
                0.0 0.0 0.0
                false false
                fungibility false {} false
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalDollarzRaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-dollarz-raised" : value})
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|TotalWSTOARaised,
    ;;Protection:          XI_U|TotalSSTOARaised, XI_U|TotalOURORaised
    (defun XI_U|TotalRaised (asset-id:string value:decimal type:integer)
        (cond
            ((= type 1) (XI_U|TotalWSTOARaised asset-id value))
            ((= type 2) (XI_U|TotalSSTOARaised asset-id value))
            ((= type 3) (XI_U|TotalOURORaised asset-id value))
            true
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|FundsWSTOA, XI_U|FundsSSTOA,
    ;;Protection:          XI_U|FundsOURO
    (defun XI_U|Funds (asset-id:string value:decimal type:integer)
        (cond
            ((= type 1) (XI_U|FundsWSTOA asset-id value))
            ((= type 2) (XI_U|FundsSSTOA asset-id value))
            ((= type 3) (XI_U|FundsOURO asset-id value))
            true
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalWSTOARaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-wstoa-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalSSTOARaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-sstoa-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalOURORaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-ouro-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsWSTOA (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-wstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsSSTOA (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-sstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsOURO (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-ouro" : value})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_U|OpenForBusiness (asset-id:string toggle:bool)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"open-for-business" : toggle})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|Price (asset-id:string price:object)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"price" : price})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|Retrieval (asset-id:string retrieval:bool)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"retrieval" : retrieval})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_W|DirectInjection (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"direct-injection" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|WSTOA (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-wstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|SSTOA (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-sstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|OURO (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-ouro" : value})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_SatisfyEnviroment (donor:string prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices})
        (require-capability (SECURE))
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (donor-stoa:string (ref-DALOS::UR_AccountStoa donor))
            )
            (ref-coin::transfer donor-stoa (at "receiver-one" prices)    (at "amount-one" prices))       ;;for GasStation
            (ref-coin::transfer donor-stoa (at "receiver-two" prices)    (at "amount-two" prices))       ;;for HOV
            (ref-coin::transfer donor-stoa (at "receiver-three" prices)  (at "amount-three" prices))     ;;for CTO
            (ref-coin::transfer donor-stoa (at "receiver-four" prices)   (at "amount-four" prices))      ;;for LQ-St
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DepositResidents (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} type:integer)
        (require-capability (SECURE))
        (with-capability (SECURE)
            (let
                (
                    (v0:decimal (at "coding-amount" prices))
                    (v1:decimal (UR_WSTOA))
                    (v2:decimal (UR_SSTOA))
                    (v3:decimal (UR_OURO))
                )
                (if (or (= type 0) (= type 1))
                    (XI_U|WSTOA (+ v0 v1))
                    (if (= type 2)
                        (XI_U|SSTOA (+ v0 v2))
                        (XI_U|OURO (+ v0 v3))
                    )
                )
            )
        ) 
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|TotalDollarzRaised
    (defun XI_DepositForAsset 
        (asset-id:string amount-in-dollars:decimal remainder:decimal type:integer)
        (let
            (
                (used-type:integer (if (= type 0) 1 type))
            )
            (XI_U|TotalDollarzRaised asset-id (+ (UR_TotalDollarzRaised asset-id) amount-in-dollars))
            (XI_U|TotalRaised asset-id (+ remainder (URv_TotalRaised asset-id used-type)) used-type)
            (XI_U|Funds asset-id (+ remainder (URv_Funds asset-id used-type)) used-type)
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_TransmitCollectables:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string son:bool nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
            )
            ;;#7M: open the capability matching the collectable KIND (son true = Semi-Fungible [false true],
            ;;     false = Non-Fungible [false false]). Previously both branches hardcoded the SEMI cap, so a
            ;;     real NF asset always failed UEV_AssetFungibility (dead) and an SF routed via the NF entry
            ;;     transferred with son=false (type mismatch). The NON caps existed but were wired to nothing.
            (if fuel-or-retrieve
                ;;FUEL — deposit collectables INTO the launchpad
                (if son
                    (with-capability (DEMIPAD|C>FUEL-SEMI-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer patron executor lpad [asset-id] [son] [nonces] [amounts] true)
                    )
                    (with-capability (DEMIPAD|C>FUEL-NON-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer patron executor lpad [asset-id] [son] [nonces] [amounts] true)
                    )
                )
                ;;RETRIEVE — withdraw collectables FROM the launchpad (NF path now also inherits the #2H lock)
                (if son
                    (with-capability (DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer patron lpad executor [asset-id] [son] [nonces] [amounts] true)
                    )
                    (with-capability (DEMIPAD|C>RETRIEVE-NON-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer patron lpad executor [asset-id] [son] [nonces] [amounts] true)
                    )
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string executor:string asset-id:string fungibility:[bool])
        @doc "Registers <asset-id> with the Launchpad, opening its ledger row. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: DEMIPAD|C>SECURE-ADMIN composes GOV|DEMIPAD_ADMIN, and that is what decides \
            \ whether the call proceeds. The EXECUTOR is the ACTOR among the keyholders, proven \
            \ by CAP_EnforceAccountOwnership -- authority and attribution are orthogonal and \
            \ neither substitutes for the other. Same treatment as LIQUID::A_MigrateLiquidFunds \
            \ and DALOS's admin band. Without it the event records that AN admin acted and \
            \ never which one, which HANDOFF 4f calls worse than no executor at all."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (DEMIPAD|C>REGISTER asset-id fungibility)
            (XI_RegisterAsset asset-id fungibility)
            (format "{} {} registered succesfuly to Demiourgos Launchpad!" [(UC_Type asset-id fungibility) asset-id])
        )
    )
    ;;
    (defun A_ToggleOpenForBusiness (patron:string executor:string asset-id:string toggle:bool)
        @doc "Opens or closes <asset-id>'s sale. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: DEMIPAD|C>SECURE-ADMIN composes GOV|DEMIPAD_ADMIN, and that is what decides \
            \ whether the call proceeds. The EXECUTOR is the ACTOR among the keyholders, proven \
            \ by CAP_EnforceAccountOwnership -- authority and attribution are orthogonal and \
            \ neither substitutes for the other. Same treatment as LIQUID::A_MigrateLiquidFunds \
            \ and DALOS's admin band. Without it the event records that AN admin acted and \
            \ never which one, which HANDOFF 4f calls worse than no executor at all."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (DEMIPAD|C>TOGGLE-SALE asset-id toggle)
            (XI_U|OpenForBusiness asset-id toggle)
            (format "Asset {} sale succesfully toggled to {}" [asset-id toggle])
        )
    )
    (defun A_DefinePrice (patron:string executor:string asset-id:string price:object)
        @doc "Sets <asset-id>'s price object. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: DEMIPAD|C>SECURE-ADMIN composes GOV|DEMIPAD_ADMIN, and that is what decides \
            \ whether the call proceeds. The EXECUTOR is the ACTOR among the keyholders, proven \
            \ by CAP_EnforceAccountOwnership -- authority and attribution are orthogonal and \
            \ neither substitutes for the other. Same treatment as LIQUID::A_MigrateLiquidFunds \
            \ and DALOS's admin band. Without it the event records that AN admin acted and \
            \ never which one, which HANDOFF 4f calls worse than no executor at all."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (DEMIPAD|C>DEFINE-PRICE asset-id price)
            (XI_U|Price asset-id price)
            (format "Asset {} price succesfully updated with the Price Object {}" [asset-id price])
        )
    )
    (defun A_ToggleRetrieval (patron:string executor:string asset-id:string toggle:bool)
        @doc "Enables or disables retrieval of <asset-id> from the Launchpad. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: DEMIPAD|C>SECURE-ADMIN composes GOV|DEMIPAD_ADMIN, and that is what decides \
            \ whether the call proceeds. The EXECUTOR is the ACTOR among the keyholders, proven \
            \ by CAP_EnforceAccountOwnership -- authority and attribution are orthogonal and \
            \ neither substitutes for the other. Same treatment as LIQUID::A_MigrateLiquidFunds \
            \ and DALOS's admin band. Without it the event records that AN admin acted and \
            \ never which one, which HANDOFF 4f calls worse than no executor at all."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (DEMIPAD|C>TOGGLE-RETRIEVAL asset-id toggle)
            (XI_U|Retrieval asset-id toggle)
            (format "Asset {} Retrieval succesfuly set to {}" [asset-id toggle])
        )
    )
    (defun C_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @doc "Deposits Funds into the Launchpad, for a registered Asset \
            \ \
            \ Executor: PROVEN FORWARDED. DEMIPAD|C>DEPOSIT only TYPE-checks the account \
            \ (UEV_EnforceAccountType executor false) -- it never proves ownership. The proof \
            \ comes from the leg that actually spends: every branch hands <executor> to \
            \ TFT::C_Transfer or LIQUID::C_WrapStoa / C_UnwrapStoa in the executor slot, and \
            \ those open on CAP_EnforceAccountOwnership. A deposit that did not move the \
            \ depositor's own funds would not be a deposit. \
            \ (patron/executor canon 2.2, 2026-09-22.) \
            \ Type 0 = Native Stoa \
            \ Type 1 = WSTOA \
            \ Type 2 = SSTOA \
            \ Type 3 = OURO \
            \ \
            \ <max-cost> is the buyer's slippage ceiling in dollars (Variant 1): the live-computed \
            \ <amount-in-dollars> must be <= <max-cost>. Pass a sentinel below zero for the slippage-off \
            \ path (Variant 2). \
            \ \
            \ Outputs: \
            \ <type 0> = STOA Split ENV + WSTOA for CD (needs wrapping) + WSTOA for Sale (needs wrapping) \
            \ <type 1> = STOA Split ENV (needs unwrapping) + WSTOA for CD + WSTOA for Sale \
            \ <type 2> = STOA Split ENV + SSTOA for CD + SSTOA for Sale \
            \ <type 3> = STOA Split ENV + OURO for CD + OURO for Sale "
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>DEPOSIT executor asset-id amount-in-dollars type direct-injection max-cost)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    ;;
                    (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices}  (URC_Prices asset-id amount-in-dollars type))
                    (working-id:string
                        (if (or (= type 0) (= type 1))
                            (ref-DALOS::UR_WrappedStoaID)
                            (if (= type 2)
                                (ref-DALOS::UR_SilverStoaID)
                                (ref-DALOS::UR_OuroborosID)
                            )
                        )
                    )
                    ;;
                    (env:decimal (at "enviroment-amount" prices))
                    (cod:decimal (at "coding-amount" prices))
                    (rem:decimal (at "remainder-amount" prices))
                    (non-enviroment:decimal (+ cod rem))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if (= type 0)
                            (ref-LIQUID::C_WrapStoa patron executor non-enviroment)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (if (= type 1)
                            (ref-LIQUID::C_UnwrapStoa patron executor env)
                            EOC
                        )
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (if (not direct-injection)
                            (ref-TFT::C_Transfer patron executor DEMIPAD|SC_NAME working-id non-enviroment true)
                            EOC
                            ;;When AQP LIVE, to be replaced by:
                            ;;(ref-AQP::C_Inject <pool-id> <working-id> <cod> <injection-type>)
                            ;;(ref-TFT::C_Transfer patron executor DEMIPAD|SC_NAME working-id rem true)
                        )
                    )
                )
                ;;1]Satisfy Enviroment (Stoa was Unwraped prior if <type> = 1)
                (XI_SatisfyEnviroment executor prices)
                ;;2]Update Internal Launchpad with deposit Data
                    ;;2.1]When (not direct-injection) save <cod> amount in Launchpad Properties
                (if (not direct-injection)
                    ;;Update Resident Amounts in DEMIPAD|Properties (they may be later injected to Acquisition Pool)
                    (XI_DepositResidents prices type)
                    true
                )
                    ;;2.2]Save <rem> in <DEMIPAD|T|Ledger> (so that it may be withdrawed by Asset Seller)
                    ;;    Guarded on (not direct-injection): crediting the seller ledger is only
                    ;;    valid once <rem> tokens actually enter custody (ico3 above). The cap
                    ;;    hard-blocks direct-injection today, so this branch is unreachable; the
                    ;;    guard stays as defense-in-depth so the future direct-injection build
                    ;;    must wire the <rem> transfer before this credit can ever fire (no
                    ;;    phantom funds).
                (if (not direct-injection)
                    (XI_DepositForAsset asset-id amount-in-dollars rem type)
                    true
                )
                ;;3]Output Cumulator
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
            )
        )
    )
    (defun C_Withdraw
        (patron:string executor:string asset-id:string type:integer destination:string)
        @doc "Withdraws all cumulated Tokens in the Launchpad, gathered through sale \
        \ Type 1 = WSTOA \
        \ Type 2 = SSTOA \
        \ Type 3 = OURO \
        \ \
        \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). DEMIPAD|C>WITHDRAW composes \
        \ DEMIPAD|C>REGISTERED-ACCESS, whose authority is an enforce-one over TWO guards: the \
        \ asset owner (a DERIVED account, via a user-guard on CAP_Owner) or the Launchpad admin \
        \ keyset. Either may withdraw, so no single binder can name the actor -- HANDOFF 4g with \
        \ a disjunction. The executor is therefore proven on its OWN terms, by \
        \ CAP_EnforceAccountOwnership, which says the named account signed WITHOUT claiming \
        \ which of the two branches it satisfied. That is the honest statement and it is the \
        \ one the ledger needs: the funds leave the Launchpad, and the event should say who \
        \ sent them where."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (let
            (
                (retrieval-amount:decimal (URv_Funds asset-id type))
            )
            (with-capability (DEMIPAD|C>WITHDRAW asset-id type retrieval-amount destination)
                (let
                    (
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                        (working-id:string
                            (if (= type 1)
                                (ref-DALOS::UR_WrappedStoaID)
                                (if (= type 2)
                                    (ref-DALOS::UR_SilverStoaID)
                                    (ref-DALOS::UR_OuroborosID)
                                )
                            )
                        )
                    )
                    ;;1]Withdraw Tokens to Destination
                    (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME destination working-id retrieval-amount true)
                    ;;2]Reset Holdings to 0.0 after withdrawal
                    (XI_U|Funds asset-id 0.0 type)
                )
            )
        )
    )
    ;;Fuel|Retrieve Assets to|from Launchpad to be made after Upgrade.
    (defun C_TransmitTrueFungible (patron:string executor:string asset-id:string amount:decimal fuel-or-retrieve:bool)
        @doc "Moves <amount> of true-fungible <asset-id> into or out of the Launchpad. \
            \ \
            \ Executor: PROVEN FORWARDED. The DEMIPAD|C>FUEL-* / C>RETRIEVE-* capabilities gate \
            \ on the ASSET (registration and fungibility) and prove no account. <executor> is \
            \ handed to TS01-C1::DPTF|C_Transfer in the executor slot on the fuel leg, and that call opens on \
            \ CAP_EnforceAccountOwnership. On the RETRIEVE leg the Launchpad account is the \
            \ sender and <executor> is the recipient, which is why the asset-side capability \
            \ carries the authority there. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
            )
            (if fuel-or-retrieve
                (with-capability (DEMIPAD|C>FUEL-TRUE-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPTF|C_Transfer patron executor lpad asset-id amount true)
                    (format "Succesfuly fueled {} {} to Demiourgos Launchpad from Account {}" [amount asset-id sa-s])
                )
                (with-capability (DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPTF|C_Transfer patron lpad executor asset-id amount true)
                    (format "Succesfuly retrieved {} {} from Demiourgos Launchpad to Account {}" [amount asset-id sa-s])
                )
            )
        )
    )
    (defun C_TransmitOrtoFungible (patron:string executor:string asset-id:string nonces:[integer] fuel-or-retrieve:bool)
        @doc "Moves <nonces> of orto-fungible <asset-id> into or out of the Launchpad. \
            \ \
            \ Executor: PROVEN FORWARDED. The DEMIPAD|C>FUEL-* / C>RETRIEVE-* capabilities gate \
            \ on the ASSET (registration and fungibility) and prove no account. <executor> is \
            \ handed to TS01-C1::DPOF|C_Transfer in the executor slot on the fuel leg, and that call opens on \
            \ CAP_EnforceAccountOwnership. On the RETRIEVE leg the Launchpad account is the \
            \ sender and <executor> is the recipient, which is why the asset-side capability \
            \ carries the authority there. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
            )
            (if fuel-or-retrieve
                (with-capability (DEMIPAD|C>FUEL-ORTO-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPOF|C_Transfer patron executor lpad asset-id nonces true)
                    (format "Succesfuly fueled {} Nonces {} to Demiourgos Launchpad from Account {}" [asset-id nonces sa-s])
                )
                (with-capability (DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPOF|C_Transfer patron lpad executor asset-id nonces true)
                    (format "Succesfuly retrieved {} Nonces {} from Demiourgos Launchpad to Account {}" [asset-id nonces sa-s])
                )
            )
        )
    )
    (defun C_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Moves <nonces>/<amounts> of semi-fungible collectable <asset-id> into or out of the Launchpad. \
            \ \
            \ Executor: PROVEN FORWARDED. The DEMIPAD|C>FUEL-* / C>RETRIEVE-* capabilities gate \
            \ on the ASSET (registration and fungibility) and prove no account. <executor> is \
            \ handed to DPDC-T::C_Transfer (through XI_TransmitCollectables) in the executor slot on the fuel leg, and that call opens on \
            \ CAP_EnforceAccountOwnership. On the RETRIEVE leg the Launchpad account is the \
            \ sender and <executor> is the recipient, which is why the asset-side capability \
            \ carries the authority there. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_TransmitCollectables patron executor asset-id true nonces amounts fuel-or-retrieve)
        )
    )
    (defun C_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Moves <nonces>/<amounts> of non-fungible collectable <asset-id> into or out of the \
            \ Launchpad. \
            \ \
            \ Executor: PROVEN FORWARDED. The DEMIPAD|C>FUEL-* / C>RETRIEVE-* capabilities gate \
            \ on the ASSET (registration and fungibility) and prove no account. <executor> is \
            \ handed to DPDC-T::C_Transfer (through XI_TransmitCollectables) in the executor \
            \ slot on the fuel leg, and that call opens on CAP_EnforceAccountOwnership. On the \
            \ RETRIEVE leg the Launchpad account is the sender and <executor> is the recipient, \
            \ which is why the asset-side capability carries the authority there. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_TransmitCollectables patron executor asset-id false nonces amounts fuel-or-retrieve)
        )
    )

)

;; --- tables for 00_Demipad.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DEMIPAD|T|Ledger)
;; (create-table DEMIPAD|T|Properties)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact ======
;;<=============================================================================>
;;{0}  ACQUISITION SCHEMAS — the one place every AQP row shape is declared
;;
;; Generated by REPL/tools/_aqpschemas.py. Edit the SCHEMAS here, never a copy.
;;
;; WHY THIS FILE EXISTS
;;   The seven AQP core modules used to declare these 74 schemas between them, 11 of
;;   them twice (RPS and FVT both carried identical copies). A schema that lives in a
;;   module cannot appear in that module's interface, so every function returning one
;;   was locked out of the interface -- 106 of them across the family, unreachable
;;   through a modref. The duplication was a symptom: RPS keeps 10 UDC_ constructors
;;   and declares none of them, so FVT could not call them and copied the shapes.
;;
;;   Hoisting them here is the same shape as DpdcUdcV2 (01_DPDC-UDC.pact), which the
;;   DPDC family already deploys first for exactly this reason.
;;
;; DEPLOY ORDER: this interface loads BEFORE 01_ANK.pact and every AQP module after it.
;;
;; NOT DONE HERE, DELIBERATELY: tables that share a key are NOT merged. Row existence
;;   is used as a boolean signal in this family, so folding a sparse table into a dense
;;   one changes meaning silently. Moving a schema changes no stored bytes; merging a
;;   table changes the data layout. One axis at a time.
;;<=============================================================================>

(namespace "ouronet-ns")

(interface AcquisitionSchemasV1

    ;;<=========================================================================>
    ;;{1}  ANK   — anchors, boost classes, user boost
    ;;      source: 01_ANK.pact
    ;;
    (defschema ANK|Schema
        @doc "General Anchor Definition \
            \ Each Anchor is defined via a so called Anchored-Asset \
            \ This may be a DPTF, DPSF or DPNF; It designation is stored here; \
            \ Along with the Anchor Precision and the Anchor ID itself \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <CAP_Owner>"
        ank-asset:string            ;;[.]   ID of the the Anchored Asset
        ank-fungibility:[bool]      ;;[.]   Stores the fungibility of the Asset the Anchor is based on.
        boost-class-id:string       ;;[.]   BoostClass this anchor belongs to
        ank-precision:integer       ;;[.]   Precision of the Anchor Variable [min 2 - max 8]
        ank-active:bool             ;;[M]   Stores if the Anchor is active or not. It can be inactivated by revoking it
        ank-promile:decimal         ;;[.]   Promile-value of Anchor
        ;;
        ;;DPTF Anchor ONLY
        dptf-amount:decimal         ;;[.]   DPTF Amount for the defined <promile> [0.0 when not DPTF Anchor]
        ;;
        ;;DPSF Anchor ONLY
        dpsf-nonce:integer          ;;[.]   DPSF Nonce for the defined <promile> [0 when not DPSF Anchor]
        ;;
        ;;DPNF Anchor ONLY
        dpnf-trait-key:string       ;;[.]   DPNF Trait-Key for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-trait-value:string     ;;[.]   DPNF Trait-Value for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-nonce-class:integer    ;;[.]   DPNF Nonce-Class for set anchors [-1 when trait mode, 0 all native NFTs, >0 specific set class]
        ;;
        ;;Select Keys
        anchor-id:string
    )
    (defschema ANK|BoostClass
        @doc "Heterogeneous anchor grouping for score boosting. \
            \ Not tied to any asset-id. Up to 7 anchor slots from different asset types."
        anchor-primary:string       ;;[M]   1st anchor slot
        anchor-secondary:string     ;;[M]   2nd anchor slot
        anchor-tertiary:string      ;;[M]   3rd anchor slot
        anchor-quaternary:string    ;;[M]   4th anchor slot
        anchor-quinary:string       ;;[M]   5th anchor slot
        anchor-senary:string        ;;[M]   6th anchor slot
        anchor-septenary:string     ;;[M]   7th anchor slot
        ;;
        anchors:integer             ;;[M]   Count of active anchors (0-7)
        class-active:bool           ;;[M]   Active flag
        ;;ADDED 2026-09-19. A BoostClass had NO owner at all, so attaching an anchor to an existing
        ;;class (acnoi=false) validated only "class active" and "a slot is free (max 7)". Issuing
        ;;the anchor itself is gated on CAP_OwnerOrCreator of the ANCHORED ASSET -- but that is the
        ;;attacker's own asset. So anyone owning any anchorable asset could anchor it into someone
        ;;else's class and hand their holders a boost inside that vault's scoring. Six free slots on
        ;;a 7-slot class is six such grants. The class now carries its creator, and the
        ;;acnoi=false path enforces it.
        class-owner:string          ;;[.]   Ouronet account that created the class; only it may attach anchors
        ;;
        ;;Select Keys
        boost-class-id:string       ;;[.]   Self-referential ID
    )
    (defschema ANK|InternalGroup
        @doc "Nested schema for ANK|AssetAnchors group slots (not a table). Up to 7 anchor slots per group."
        anchor-primary:string
        anchor-secondary:string
        anchor-tertiary:string
        anchor-quaternary:string
        anchor-quinary:string
        anchor-senary:string
        anchor-septenary:string
        anchors:integer             ;;Count within this group (0-7)
    )
    (defschema ANK|AssetAnchors
        @doc "Tracks all anchors for one asset-id. 7 internal groups x 7 slots = 49 cap. \
            \ Single read gives all anchor-ids for an asset."
        group-primary:object{ANK|InternalGroup}
        group-secondary:object{ANK|InternalGroup}
        group-tertiary:object{ANK|InternalGroup}
        group-quaternary:object{ANK|InternalGroup}
        group-quinary:object{ANK|InternalGroup}
        group-senary:object{ANK|InternalGroup}
        group-septenary:object{ANK|InternalGroup}
        ;;
        groups-active:integer       ;;[M]   Groups in use (0-7)
        anchors-active:integer      ;;[M]   Total anchors across all groups (0-49)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Self-referential asset-id
    )
    (defschema ANK|UserSchema
        @doc "Stores the cumulate promile of a given <ouronet-account> for a given <anchor-id> \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <ouronet-account> Ownership"
        promile:decimal             ;;[M]   Promile of User with Anchor
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   Stores the Ouronet Account for which the Anchor Value is saved
        anchor-id:string            ;;[.]   Stores the Anchor-ID
    )
    (defschema ANK|UserBoostSchema
        @doc "Aggregate promile for one user across all anchors in one BoostClass. \
            \ Eagerly updated whenever any member anchor promile changes for this user."
        aggregate-promile:decimal   ;;[M]   Sum of user promiles across member anchors
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   User account
        boost-class-id:string       ;;[.]   BoostClass reference
    )
    (defschema ANK|BoostClassScoreLinks
        @doc "Key = <Boost-Class-ID>. The SET of SCORE ids whose boost-class-link references this class — the H4 \
            \ REVERSE INDEX (sweep phase 1): enumerable (the re-score sweep walks it to find every score/position \
            \ an anchor change touches) AND the #9 revoke lock (the class's anchors are locked while the set is \
            \ non-empty). AQP-SCORE maintains it in XI_CreateBoostClassLink: add on link, remove on re-point/unlink. \
            \ The lock count = (length score-links) — this set is the single source of truth."
        score-links:[string]
        boost-class-id:string
    )

    ;;<=========================================================================>
    ;;{2}  SCORE — scores, per-asset score definitions, triplets
    ;;      source: 02_SCORE.pact
    ;;
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
            \ [.] semantic fields (score-class, multipliers, sft/nft models), \
            \ links [..], or deb-boost [.t] after positions \
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
        boost-class-link:string     ;;[..]  Specifies the BoostClass-ID for boosting. BAR if not in use.
        ;; Foreign boost-link: promile uses linked score user base; UserScore boosted/deb may hold surplus only (README_SCORE.md). Never self: SCR|C>CREATE-BOOST-LINK-SCORE.
        boost-link:string           ;;[..]  BAR = own base for promile; else other score-id (≠ this score-id per SCR|C>CREATE-BOOST-LINK-SCORE).
        aqpool-link:string          ;;[..]  Specifies the Pool that employs the Score. BAR if not in use.
        fvt-link:string             ;;[..]  Specifies the FVT the Score is part of. BAR if not in use.
        triplet:bool                ;;[..]  false at issue; true once bundled in SCR|T|Triplet (immutable).
        triplet-id:string           ;;[..]  BAR until triplet issue; then T|bronze|silver|golden (immutable).
        ;;Score Information
        deb-boost:bool              ;;[.t]  Specifies if DEB boosting occurs.
        precision:integer           ;;[.]   Decimal places for per-user weights and aggregate total-* fields on this score; range enforced at issuance; forward writers must respect it.
        total-base-score:decimal    ;;[M]   Sum of user base-scores; same decimal precision as precision field
        total-boosted-score:decimal ;;[M]   Sum of user boosted-scores; same decimal precision as precision field
        total-deb-score:decimal     ;;[M]   Sum of user deb-scores; same decimal precision as precision field
        total-base-deb-score:decimal    ;;[M] M3: Σ user base-deb-scores (aggregate base×deb decomposition)
        total-boosted-deb-score:decimal ;;[M] M3: Σ user boosted-deb-scores. total-base-deb + total-boosted-deb = total-deb-score.
        nzs-count:integer           ;;[M]   Store the amount of Non-Zero-Scores
        vacate-generation:integer   ;;[M]   Vacate-v2 lazy-invalidation counter (§5). Bumped once at fast-vacate
        ;;                                  finalize (nuke). A SCR|T|UserScore row whose stamped-generation < this
        ;;                                  reads as 0 (stale); re-stake stamps the current value. Default 0.
        ;;
        ;;Score Class
        score-class:integer         ;;[.]   Defines the Score Class, there are 5
        ;;                                  Class 0 = LP Score (LP - native|sleeping|freezing)
        ;;                                  Class 1 = DPTF Score (non LP) 
        ;;                                  Class 2 = DPOF Score (non LP)
        ;;                                  Class 3 = DPSF Score (SFTs)
        ;;                                  Class 4 = DPNF Score (NFTs)
        ;;
        ;;LP, DPTF, DPOF
        lp-denominator:string       ;;[.]   Class-0 only: native DPTF token-id of the common pool leg (e.g. OURO-98c486052a51); BAR for classes 1-4.
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
        ;;                                  Model  1 = NFTs scored from SCR|T|NF|TraitScore / SCR|T|NF|ClassScore rows
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
        base-deb-score:decimal      ;;[M]  M3: base × deb (deb applied to the base part)
        boosted-deb-score:decimal   ;;[M]  M3: boost × deb (deb applied to the boost part). base-deb + boosted-deb = deb-score.
        stamped-generation:integer  ;;[M]  Vacate-v2 (§5): the SCR|Schema.vacate-generation this row was written under.
        ;;                                 When < the score's current vacate-generation, readers treat this row as 0
        ;;                                 (stale after a fast-vacate); a fresh stake re-stamps it live. Default 0.
        ;;
        ;;Select Keys
        ouronet-account:string
        pool-id:string
        score-id:string
    )
    (defschema SCR|SingularUserScoreDelta
        @doc "Result of applying one signed user-base delta at score precision: new user triple, nz-count delta, and deltas to SCR|T|Score aggregate totals \
            \ (LP stake legs are one consumer; other forward paths can reuse the same derivation object). Aggregate totals are floored at the score precision field in XI."
        new-user-base-score:decimal
        new-user-boosted-score:decimal
        new-user-deb-score:decimal
        new-user-base-deb-score:decimal
        new-user-boosted-deb-score:decimal
        nz-delta:integer
        delta-global-base-score:decimal
        delta-global-boosted-score:decimal
        delta-global-deb-score:decimal
        delta-global-base-deb-score:decimal
        delta-global-boosted-deb-score:decimal
    )
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
    (defschema SCR|NF|TraitSchema
        @doc "Per (score-id, dpnf-id, trait-key, trait-value). trait-score-value is mutable."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        trait-key:string
        trait-value:string
    )
    (defschema SCR|NF|ClassSchema
        @doc "Per (score-id, dpnf-id, dpnf-nonce-class). trait-score-value is mutable (set-mode class weights)."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        dpnf-nonce-class:integer    ;;[.]   0 = all native NFTs in class model; >0 = specific set class (AQP-ANK DPNF anchors)
    )
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
        @doc "Per (score-id, dpnf-id). global-revision-nonce bumps on any trait or class definition change; \
            \ trait-revision-nonce only on SCR|T|NF|TraitScore change; class-revision-nonce only on SCR|T|NF|ClassScore change."
        global-revision-nonce:integer   ;;[M]
        trait-revision-nonce:integer    ;;[M]
        class-revision-nonce:integer     ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
    )
    (defschema SCR|NF|TraitKeys
        @doc "Per (score-id, dpnf-id): the DISTINCT trait-keys with any SCR|T|NF|TraitScore definition. Lets model-1 \
            \ trait scoring point-read each defined key against a staked nonce's metadata instead of scanning."
        trait-keys:[string]         ;;[M]   distinct defined trait-keys
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
    )
    (defschema SCR|Triplet
        @doc "Key = T|<bronze-score-id>|<silver-score-id>|<golden-score-id>. Bundles three SCORE rows for FVT TripletLink membership. \
            \ Positions bronze/silver/golden are id slots only (not boost roles). true-triplet when one score has BAR boost-link and the other two boost-link to it. \
            \ Tags: [.] fixed at issue."
        bronze-score-id:string                               ;;[.]   First score id slot
        silver-score-id:string                               ;;[.]   Second score id slot
        golden-score-id:string                               ;;[.]   Third score id slot
        triplet-category:string                              ;;[.]   LP | VAULT_TF | TREASURY_SF_NF (from shared score-class)
        triplet-id:string                                    ;;[.]   Select key T|bronze|silver|golden
        true-triplet:bool                                    ;;[.]   Boost-anchored bundle (one BAR hub, two satellites)
    )
    (defschema SCR|ScoreEntityModel
        @doc "Key = <Model-ID>. A reusable score-entity TEMPLATE so many entities issue IDENTICALLY (DSA: every \
            \ agency scores the same). single (entity-type 1): the scoring spec — issue 1 score + its SF definition \
            \ from it. triplet (entity-type 3): references three single model-ids — issue the 3 singles, then \
            \ C_IssueTriplet. Tags: [.] fixed at define."
        entity-type:integer                                  ;;[.]   CT_SCORE_MODEL_SINGLE (1) | CT_SCORE_MODEL_TRIPLET (3)
        score-class:integer                                  ;;[.]   single: 3 = SemiFungible (DPSF), v1 SF only. triplet: 0.
        collectable-id:string                                ;;[.]   single: the DPSF id the definition scores. triplet: BAR.
        precision:integer                                    ;;[.]   single: score precision. triplet: 0.
        nonces:[integer]                                     ;;[.]   single: SF definition nonces (incl. fragment negatives). triplet: [].
        nonce-score-values:[decimal]                         ;;[.]   single: parallel values. triplet: [].
        ;;ADDED 2026-09-19 — ANCHORS IN DELEGATION VAULTS. A score's boost-class link used to be
        ;;settable only AFTER issue, by whoever owns the score — which in a delegation vault is the
        ;;AGENCY OPERATOR, not the vault admin. That inverted the intended authority: an agency
        ;;could decline the vault's anchor, or point at a different class, and every agency on one
        ;;vault could score by different rules. Carrying it on the MODEL puts the decision where it
        ;;belongs: the vault admin defines how a score behaves, the agency merely opens under those
        ;;rules. XI_IssueOneFromModel applies it at issue; BAR means "no boost class", which is the
        ;;pre-existing behaviour and what every model written before this field defaulted to.
        boost-class-id:string                                ;;[.]   single: ANK boost class applied at issue (BAR = none). triplet: BAR.
        bronze-model-id:string                               ;;[.]   triplet: the 3 sub single-model ids. single: BAR.
        silver-model-id:string
        golden-model-id:string
        ;;Select Keys
        model-id:string                                      ;;[.]
    )

    ;;<=========================================================================>
    ;;{3}  AQP   — pools, per-fungibility trackers, beneficiary totals
    ;;      source: 03_AQP.pact
    ;;
    (defschema AQP|Schema
        @doc "One aqp-class and one canonical asset-id per pool; employed \
            \ scores must match that class. Staking asset identity is \
            \ authoritative here (SCORE: Score -> aqpool-link -> this pool \
            \ -> asset-id). Class 0: asset-id is the primary LP key; stake \
            \ paths may accept additional linked LP token ids (native / \
            \ sleeping OF / frozen TF) when verified as the same LP family; \
            \ all credit the same pool score slots. Fix wrong pool economics \
            \ by issuing a new pool and new scores, not by mutating class or \
            \ primary asset-id after stake exists."
        ;;
        aqp-class:integer                                       ;;Defines the Pool Class, there are 5
        ;;                                                        Class 0 = LP family pool (issue native LP; stake native|F||Z| LP)
        ;;                                                        Class 1 = DPTF family pool (issue native DPTF; stake native|F| + linked sleep/hib DPOF)
        ;;                                                        Class 2 = standalone DPOF (issue one dpof; no sleep/hib satellites — use class 0/1)
        ;;                                                        Class 3 = DPSF collection pool
        ;;                                                        Class 4 = DPNF collection pool
        asset-id:string                                         ;;ID of the Asset that is allowed to be staked in the Pool.
        ;;                                                        This must be in accordance with the <aqp-class> and together with it
        ;;                                                        Defines which assets can be staked in the Pool
        ;;
        ;;Score - Links
        score-primary:string
        score-secondary:string
        score-tertiary:string
        score-quaternary:string
        score-quinary:string
        score-senary:string
        score-septenary:string
        ;;
        stake-enabled:bool                                      ;;[M]   Gates new stakes when false; default true at issue. Unstake/vacate ignore.
        vacate-in-progress:bool                                 ;;[M]   True while AQP-VCT session active on this pool.
        sweep-in-progress:bool                                  ;;[M]   True while a re-score sweep (anchor retire/re-price) runs; blocks stake + collect (D3).
        nns:integer                                             ;;[M]   #FP1: number of OCCUPIED nonce positions in the pool tracker (occupancy oracle,
        ;;                                                        counts ghost nonces that nzs misses). -1 for amount-based pools (class 0/1, N/A);
        ;;                                                        0 at issue for nonce-based pools (class 2/3/4). +1 on a position going empty->occupied,
        ;;                                                        -1 on occupied->empty (last amount removed). Finalize uses nns==0 for nonce pools.
        ;;
        ;;Select Keys
        aqp-id:string
    )
    (defschema AQP|TrueFungibleTracker
        balance:decimal                                         ;;Store DPTF Balance Amount
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dptf-id:string                                          ;;DPTF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
    )
    (defschema AQP|OrtoFungibleTracker
        balance:decimal                                         ;;Staked DPOF amount for this nonce slot
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpof-id:string                                          ;;DPOF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|SemiFungibleTracker
        @doc "DPSF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPSF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpsf-id:string                                          ;;DPSF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|NonFungibleTracker
        @doc "DPNF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPNF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpnf-id:string                                          ;;DPNF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|BenDptfTotal
        @doc "Cross-pool rollup: total DPTF staked by one beneficiary on one exact dptf-id leg \
            \ (native X and F|X are separate rows). Maintained on every TF stake/unstake POOL leg \
            \ (FVT::CC_TrueFungibleStakeFlow → XE_TrueFungible* legs → XI bump). Input to \
            \ ANK::XE_UpdateTrueFungibleUserAnchorValues without scanning AQP|T|DPTFTracker keys. \
            \ last-ank-sync-count stores AQP-ANK::UR_AA|AnchorsActive(dptf-id) after the last successful \
            \ anchor refresh; URC_BenDptfAnchorsNeedSync compares it to the live count so the UI can \
            \ prompt C_SyncTrueFungibleAnchors when new anchors are issued after stake. Per-pool detail \
            \ remains in AQP|T|DPTFTracker; this row is the single O(1) read for anchor promile."
        total-balance:decimal                                           ;;[M] Sum of tracker balances for (beneficiary, dptf-id) across all pools
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last C_Sync* / stake ANK leg (0 = never synced)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dptf-id:string                                                  ;;[.] Exact DPTF id leg (native or F|); must match ANK ank-asset for sync call
    )
    (defschema AQP|BenDpsfNonceTotal
        @doc "Cross-pool per-nonce DPSF rollup for one beneficiary. Separate table from DPNF so SELECT inventory \
            \ does not scan NFT rows. Maintained on DPSF stake/unstake POOL legs (phase 1.3, planned). amount is \
            \ integer supply staked on that nonce across all pools; 0 means fully unstaked (row may remain)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dpsf-id:string                                                  ;;[.] DPSF collection id (ANK ank-asset for SF sync)
        nonce:integer                                                   ;;[.] DPSF nonce
    )
    (defschema AQP|BenDpnfNonceTotal
        @doc "Cross-pool per-nonce DPNF rollup for one beneficiary. Separate table from DPSF — same id string may \
            \ exist on both collections when minted in one tx, but rows live in disjoint tables. Maintained on DPNF \
            \ stake/unstake POOL legs (phase 1.3, planned)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.] DPNF collection id
        nonce:integer                                                   ;;[.] DPNF nonce
    )
    (defschema AQP|BenDpsfAnkMeta
        @doc "Per (beneficiary, dpsf-id) ANK sync metadata. last-ank-sync-count is leg-wide, not per nonce — \
            \ mirrors AQP|BenDptfTotal for TF. active-nonce-count is O(1) has-stake for defcaps (no select). \
            \ Bumped when BenDpsfNonceTotal crosses 0↔positive; preserved on sync stamp."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpsfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpsf-id:string                                                  ;;[.]
    )
    (defschema AQP|BenDpnfAnkMeta
        @doc "Per (beneficiary, dpnf-id) ANK sync metadata — DPNF counterpart of AQP|BenDpsfAnkMeta."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpnfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.]
    )
    (defschema AQP|UserOccupancy
        @doc "Vacate-v2 §4: per (pool, beneficiary) occupancy — the count of this beneficiary's OCCUPIED \
            \ tracker positions in the pool (nonce rows for class 2/3/4; the single TF leg contributes 1 for \
            \ class 1). Maintained alongside the pool nns on every tracker 0<->occupied transition (stake / \
            \ unstake / vacate-drain). The fast-vacate drain settles a beneficiary exactly once, the moment \
            \ this hits 0 (their last position drained). Point-readable so the drain never scans tracker keys."
        unn:integer                                                     ;;[M] User-Nonces-in-pool: occupied tracker positions for this beneficiary
        ;;
        ;;Select Keys
        pool-id:string                                                  ;;[.] Pool
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE / reward recipient)
    )

    ;;<=========================================================================>
    ;;{4}  RPS   — reward engine: global/member/user/stream ledgers
    ;;      source: 04_RPS.pact
    ;;
    (defschema FVT|RPS|Global
        @doc "Key = <FVT-ID> | <DPTF-ID>. One registered reward DPTF on this FVT."
        reward-enabled:bool
        current-rps:decimal
        available-rewards:decimal
        unclaimed-count:integer
        ;; Escrow-on-empty (zombie/limbo): reward tokens injected while the inject denominator is 0 (no stakers)
        ;; are held here — physically in AQP|SC_NAME custody, counted, but NOT yet routed into G / available-rewards.
        ;; The next inject at a NON-zero denominator adds this on top of its amount, distributes the sum to whoever
        ;; is staked at that instant (pro-rata via G / farm-split), and zeroes it. Kept OUT of available-rewards so
        ;; the M1 last-claimant dust sweep can never pay a prior cohort the pending escrow. No owner reclaim: it
        ;; stays until a normal non-zero inject flushes it.
        zombie-rewards:decimal
        segmentation:bool
        reward-kind:string                                      ;;[.]   PLAIN | MULTIPLET_BASE
        multiplet-family-id:string                              ;;[.]   BAR or F|t0|t1|t2
        ;; Time-streamed inject (linear vesting) — the lane's active-stream ledger cursor. stream-count = live
        ;; stream positions (0 = none; the drip fast-returns). stream-last-release = shared lane checkpoint (every
        ;; active stream's start <= this, since a new stream is only added AFTER a drip). stream-unreleased =
        ;; custodied-but-not-yet-dripped total (held in AQP|SC_NAME, kept OUT of available-rewards / the M1 sweep
        ;; until the drip releases it). See Audit/STREAMED-INJECT-DESIGN.md.
        stream-count:integer
        stream-last-release:time
        stream-unreleased:decimal
        ;; DSA royalty pool: the uptime-shortfall slice of a delegation inject that no agency captured
        ;; (Σ capture-units − Σ effective capture-weight, worth A×that/Σunits). Custodied in AQP|SC_NAME, kept
        ;; OUT of available-rewards / G / the M1 sweep until the owner disposes it (withdraw / burn / fuel).
        ;; Always 0.0 on a non-delegation lane (Σ capture-weight == Σ capture-units ⇒ no shortfall).
        royalty-rewards:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Member
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Member reward line per score-entity × reward DPTF."
        last-farm-rps-g:decimal
        member-deb-rps:decimal
        pending-member-rewards:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|User
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Per-staker row."
        last-rps:decimal
        pending-rewards:decimal
        user-id:string
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Stream
        @doc "Key = <FVT-ID> | <DPTF-ID> | <position 1..49>. One live linear-release stream on a reward lane. \
            \ Positions are kept COMPACT (occupied = 1..stream-count); a finished stream is pruned and later \
            \ positions shift down. UI renders position n as tier-style major.minor (major = ceil(n/7), \
            \ minor = ((n-1) mod 7) + 1). rate = amount/duration (token-per-second, high precision); finish = \
            \ block-time the stream stops; amount = original streamed amount; released = cumulative released so \
            \ far, so the finish drip flushes (amount - released) and per-stream conservation is exact."
        rate:decimal
        finish:time
        amount:decimal
        released:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        position:integer
    )
    (defschema FVT|MemberVault
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID> (base ATS token). The per-member mini-vault for the \
            \ Tier-1 dust sweep (M1 / #10): available-rewards = rewards routed to this member (farm split-at-inject \
            \ slice, or vault Tier-2 earned) minus what its users have been paid; unclaimed-count = users in this \
            \ member with a live claim. When unclaimed-count hits 1, the member's last user is paid available-rewards \
            \ (sweeping the member's floor dust). Mirrors FVT|RPS|Global's available-rewards/unclaimed-count one tier down."
        available-rewards:decimal
        unclaimed-count:integer
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|MemberUserWeight
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>. Farm-triplet per-user Level-1 weight snapshot — \
            \ w-user (Σ lanes) as of the user's last score stake/unstake. Summed into \
            \ ScoreEntityLink.total-lane-weight and used as the user's Tier-1 numerator, so numerator and \
            \ divisor share one snapshot basis (reward conservation), exactly like a singular score uses \
            \ stored deb-score + maintained total-deb-score."
        contrib-weight:decimal
        ;;
        ;;Select Keys
        user-id:string
        fvt-id:string
        score-entity-id:string
    )
    (defschema FVT|ForcedFixCount
        @doc "Key = <FVT-ID> | <DPTF-ID> | <User-ID>. M3 #12 2e penalty: how many of this user's stale scores an \
            \ enforced inject (CC_Inject / MTX|n|C_Inject) FORCE-fixed on this reward lane since the user last \
            \ collected it. At collect the user pays `count × RATE` NON-discountable IGNIS (a gas reimbursement — \
            \ the inject did N fixes for him; reward paid is untouched) and the count is zeroed. Self-fixing at \
            \ collect (PHASE 6 backstop) does NOT bump this — only inject-forced fixes do, so self-fixing stays \
            \ the cheaper path."
        count:integer
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        user-id:string
    )
    (defschema FVT|RewardAggregate
        @doc "Key = <FVT-ID>. Reward-computation aggregates split out of FVT|Schema (#75 B' Stage 1) so \
            \ the reward orchestration owns them; identity/config stays in FVT|Schema."
        fvt-class:integer                                       ;;[.]   0=Farm · 1=Vault · 2=Treasury (moved here #75 B' Stage 2)
        owner-konto:string                                      ;;      entity owner (moved #75 B' Stage 2b)
        mosaic:bool                                             ;;[Mu]  mix score + triplet entities when true
        membership-mode:string                                  ;;[Mu]  BAR | SCORE | TRUE-TRIPLET | STANDARD-TRIPLET
        split-mode:string                                       ;;[M]   Farm reward-split: SPLIT|STAKED | SPLIT|TVL
        total-ghost-tvl-weight:decimal                          ;;[M]   Farm S = sum enabled ScoreEntityLink W_i
        total-base-score:decimal
        total-boosted-score:decimal
        total-deb-score:decimal
        total-nzs-count:integer
        enabled-reward-count:integer
        member-link-count:integer                               ;;[M]   ScoreEntityLink rows (gates C_SetMosaic)
        ;;Select Keys
        fvt-id:string
    )
    (defschema FVT|ScoreEntityLink
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. Unified membership — score (type 1) or triplet (type 3)."
        score-entity-type:integer                               ;;[.]   CT_SCORE_ENTITY_SCORE=1, CT_SCORE_ENTITY_TRIPLET=3
        enabled:bool                                            ;;[M]
        swpair:string                                           ;;[..]
        ghost-tvl-weight:decimal                                ;;[M]   Level-2 W_i (SWP staked value)
        total-lane-weight:decimal                               ;;[M]   Farm-triplet Level-1 divisor Σ w-user;
        ;;                                                              snapshot-maintained at stake/unstake (phase 4.6),
        ;;                                                              point-read as the L_i divisor (no staker scan).
        ;; DSA (Delegated Staking Agencies) — set only for a delegation member (= an agency); default
        ;; false/0.0/0.0/EPOCH for every normal member. DSA maintains them (delegator stake/unstake + the daily
        ;; oracle) via an XE_; FVT only ever READS its own fields at inject (dependency DSA -> FVT). See
        ;; Audit/DSA-DELEGATED-STAKING-DESIGN.md §3.
        delegation:bool                                         ;;[M]   is this member a DSA agency?
        capture-units:decimal                                   ;;[M]   ideal capacity = min(floor(Q/unit-score), nodes) — the IDEAL denominator term
        capture-weight:decimal                                  ;;[M]   actual = capture-units × uptime/1000 — the inject NUMERATOR
        oracle-ts:time                                          ;;[M]   timestamp of the last oracle write (now − ts > 25h ⇒ effective capture 0)
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]
        score-entity-id:string                                  ;;[.]   score-id or triplet-id T|…
    )
    (defschema FVT|MultipletFamily
        @doc "Key = F|<token-0-id>|<token-1-id>|<token-2-id>. Reward ladder for MULTIPLET_BASE collect."
        token-0-id:string
        token-1-id:string
        token-2-id:string
        ats-0-1-id:string
        ats-1-2-id:string
        rank:integer                                            ;;[.]   Lane count at issue (v1 = 3)
        active:bool
        ;;
        ;;Select Keys
        multiplet-family-id:string
    )
    (defschema FVT|UserPresence
        @doc "Key = <FVT-ID> | <Ouronet-ID>. Membership marker (M3 #12 / shared with the H4 anchor sweep): \
            \ is-present = true while the user holds a live position (nonzero weight) in AT LEAST ONE of this \
            \ FVT's score-entities. Written true (add-only) on every stake; recomputed to false on the unstake \
            \ that drops the user's LAST position in the FVT. Maintained for ALL FVT classes. Lets a sweep \
            \ enumerate one FVT's users with a single `select` over a small purpose-built table (no giant \
            \ RPS|User scan). A stale `true` is harmless — the sweep no-ops on a zero-weight user."
        is-present:bool
        ;;
        ;;Select Keys
        fvt-id:string
        ouronet-id:string
    )
    (defschema FVT|AgencyFee
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. DSA operator fee for a delegation member (the agency), mirrored \
            \ from DSA|Agency so the FVT inject settle can read it locally (FVT can't reach DSA). At inject the \
            \ member-slice is split: the delegator-facing index L_i advances by member-slice·(1−fee) (so ALL \
            \ stakers accrue net), and the whole member-slice·fee is credited DIRECTLY to the operator's pending — \
            \ giving the operator its own weighted share + the fee (effective weight own + fee·Σdelegators), \
            \ delegators (1−fee), conserved. The fee is never baked into a stored weight, so a fee change is O(1) \
            \ (it only reprices the NEXT inject). Set by DSA at open + C_SetAgencyFee."
        operator-konto:string
        fee-per-mille:integer
    )
    (defschema FVT|QualitySplit
        @doc "Key = <FVT-ID> | <DPTF-ID> (same as RPS|Global). Round B: the per-FVT reward MODE + heterogeneous \
            \ split MATRIX for a MULTIPLET_BASE triplet reward. HOMOGENEOUS ⇒ each lane routes to its one ladder \
            \ token (bronze→t0, silver→t1, gold→t2) — the default when this row is absent. HETEROGENEOUS ⇒ each \
            \ lane splits across ALL 3 ladder tokens per its row [to-t0 to-t1 to-t2] (per-mille, sums to 1000): \
            \ bronze-split for the bronze lane, silver-split for silver, gold-split for gold. Per-FVT-reward + \
            \ owner-tunable (unlike the chain-wide immutable FVT|MultipletFamily ladder)."
        mode:string                                             ;;[M]   HOMOGENEOUS | HETEROGENEOUS
        bronze-split:[integer]                                  ;;[M]   [to-t0 to-t1 to-t2] per-mille, sums 1000
        silver-split:[integer]                                  ;;[M]
        gold-split:[integer]                                    ;;[M]
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|DsaOracleConfig
        @doc "Single GLOBAL row (key = FVT|DSA-ORACLE-KEY). The protocol-wide DSA external-oracle switch + validity \
            \ window, replacing the per-FVT oracle-on + the DSA_ORACLE_TTL constant. `external-oracle` = is external \
            \ oracling on at all: ON ⇒ a delegation member captures its weight only while its last oracle write is \
            \ fresher than `oracle-validity` seconds (no/stale entry ⇒ effective 0); OFF ⇒ oracling is bypassed \
            \ entirely and the stored capture-weight is trusted as-is. Read lazily (defaults: on=true, \
            \ validity=DSA_ORACLE_TTL) so no init is needed; written only by A_ToggleExternalOracle / \
            \ A_SetOracleValidity (DSA module admin) via the FVT XE_ setters."
        external-oracle:bool
        oracle-validity:integer
    )
    (defschema FVT|ScorePreNzFlag
        @doc "Pre-SCORE snapshot for one employed score."
        score-id:string
        was-nz:bool
    )
    (defschema FVT|SettleFvtRewards
        @doc "One distinct FVT row in URH_FVT|SettleFvtRewardBundle."
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|SettleScorePlan
        @doc "One score-entity row in URC_SettleScorePlanRows — entity + fvt + reward list."
        score-entity-type:integer
        score-entity-id:string
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|MemberPreDeb
        @doc "Pre-SCORE live deb-weight snapshot for one settled member (M2/#11 incremental total-deb mirror). \
            \ Self-describing (carries its keys) so no positional alignment with settle-plans is needed."
        fvt-id:string
        score-entity-type:integer
        score-entity-id:string
        pre-deb:decimal
    )
    (defschema FVT|StakeSettleBundle
        @doc "Precomputed stake/unstake settle scope."
        settle-scores:[string]
        distinct-fvts:[string]
        settle-plans:[object{FVT|SettleScorePlan}]
        pre-nz-flags:[object{FVT|ScorePreNzFlag}]
        pre-member-debs:[object{FVT|MemberPreDeb}]
    )

    ;;<=========================================================================>
    ;;{5}  FVT   — farms, vaults, treasuries
    ;;      source: 05_FVT.pact
    ;;
    (defschema FVT|Schema
        @doc "Key = <FVT-ID>. One farm, vault, or treasury (FVT) entity: class, owner, enabled-reward-count, SCORE aggregate mirrors. \
            \ Farm (fvt-class 0): common-denominator + total-ghost-tvl-weight S is inject denominator. \
            \ Vault/Treasury: total-deb-score mirror for inject; common-denominator sentinel \"|\"; total-ghost-tvl-weight 0.0. \
            \ UrStoa analogue: vault header (urstoa-supply on SCORE side; S or total-deb here is FVT-side denominator). \
            \ Field tags: [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade."
        can-upgrade:bool
        can-change-owner:bool
        common-denominator:string                               ;;[Mu]  unsafe to change after ScoreEntityLinks
        oracle-on:bool                                          ;;[M]   DSA: node/uptime oracle governs capture. Default false.
        ;; fvt-class, owner-konto, mosaic, membership-mode, split-mode + the reward aggregates
        ;; live in FVT|RewardAggregate (#75 B' Stage 1/2) — the reward engine reads/owns them.
        ;;Select Keys
        fvt-id:string
    )
    (defschema FVT|VacateFreeze
        @doc "Key = <FVT-ID>. True while a pool this FVT serves is mid-vacate — blocks collect + inject on the FVT \
            \ so the owner-forced vacate is not interfered with (stake/unstake are frozen pool-side via \
            \ PoolVacateInProgress). Set by AQP-VCT begin (XI_EnsureVacateBegun) on each of the vacating pool's \
            \ employed-score FVTs; cleared by VCT finalize. Read via UR_FVT|VacateFrozen (with-default-read false)."
        frozen:bool
    )
    (defschema FVT|SweepProgress
        @doc "Key = <Anchor-ID>. Cursor for the paginated defun+gate re-score sweep (CC_SweepBegin → \
            \ CCp_SweepRecomputeChunk*), the scalable twin of the fixed 2-step MTX|2|C_SweepRevokeAnchor defpact. \
            \ `total` = the recompute-set size captured at BEGIN (sweep-in-progress freeze holds URH_FvtPresentUsers \
            \ fixed across the batch's separate txs); `offset` = holders recomputed so far over the GLOBAL flattened \
            \ present set (present users concatenated across the boost-class's score-ids in order); `active` = a \
            \ sweep is open. The finalizing chunk (win-hi reaches total) unfreezes every affected pool + clears \
            \ active — completeness is ENFORCED (pools cannot unfreeze until offset reaches total). Read via \
            \ UR_FVT|SweepProgress / UR_FVT|SweepActive (with-default-read inactive)."
        total:integer
        offset:integer
        active:bool
    )

    ;;<=========================================================================>
    ;;{6}  VCT   — vacate planning
    ;;      source: 06_VCT.pact
    ;;
    (defschema VCT|SlicePayload
        @doc "Vacate slice payload for plan OC and hash commitment. \
            \ TF (vacate-asset-kind=1): amounts populated; nonces-array and amounts-array empty. \
            \ OF/DPSF/DPNF: nonces-array + amounts-array populated; amounts empty. \
            \ OF uses zero-sentinel amounts-array; collectables use full tracker balances per nonce."
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        owner-ids:[string]
        beneficiary-ids:[string]
        amounts:[decimal]
        nonces-array:[[integer]]
        amounts-array:[[integer]]
    )
    (defschema VCT|VacateSlicePlan
        @doc "Offline Legs split plan — full slice payloads for UI (no on-chain job writes). \
            \ vacate-job-id is unused under Legs (always \"\")."
        vacate-job-id:string
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        slice-count:integer
        slices:[object{VCT|SlicePayload}]
    )
    (defschema VCT|VacateTfLeg
        owner-id:string
        beneficiary-id:string
        balance:decimal
    )
    (defschema VCT|VacateNonceRow
        owner-id:string
        beneficiary-id:string
        nonce:integer
        balance:decimal
    )
    (defschema VCT|VacateNonceLeg
        owner-id:string
        beneficiary-id:string
        nonces:[integer]
        amounts:[decimal]
    )
    (defschema VCT|VacateTfInventory
        @doc "UI pre-flight bundle: TF vacate legs + leg-count."
        legs:[object{VCT|VacateTfLeg}]
        leg-count:integer
    )
    (defschema VCT|VacateNonceLegInventory
        @doc "UI pre-flight bundle: grouped nonce vacate legs + leg-count."
        legs:[object{VCT|VacateNonceLeg}]
        leg-count:integer
    )
    (defschema VCT|VacateTfLane
        @doc "One DPTF asset-lane of a pool + its TF vacate legs (PHASE-1 scan output; consumed per asset)."
        asset-id:string
        legs:[object{VCT|VacateTfLeg}]
    )
    (defschema VCT|VacateNonceLane
        @doc "One DPOF/DPSF/DPNF asset-lane of a pool + its nonce vacate legs (PHASE-1 scan output)."
        asset-id:string
        legs:[object{VCT|VacateNonceLeg}]
    )

    ;;<=========================================================================>
    ;;{7}  DSA   — delegated staking agencies
    ;;      source: 08_DSA.pact
    ;;
    (defschema DSA|Template
        @doc "Key = <FVT-ID>. Per DSA vault: binds a class-0 FVT to the score-entity MODEL every agency \
            \ instantiates (SCR|ScoreEntityModel) + the unit-score (1 staking unit = 1 node; open gate = \
            \ unit-score/2). The model fixes the scoring (Custodians nonce→quintessence) so all agencies are comparable."
        model-id:string                                         ;;[.]   the SCR|ScoreEntityModel agencies instantiate (SCORE)
        unit-score:integer                                      ;;[.]   quintessence per capture unit (e.g. 20000)
        active:bool                                             ;;[M]
        ;;Select Keys
        fvt-id:string
    )
    (defschema DSA|Agency
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. One agency = one FVT member (its triplet). Operator is an \
            \ ownership role independent of stake; fee is skimmed from delegators only. nodes + uptime are the \
            \ oracle inputs to the capture transform (the derived capture-units/weight live on the FVT member)."
        operator-konto:string                                   ;;[..]  the agency operator (runs nodes, takes the fee)
        fee-per-mille:integer                                   ;;[M]   flat fee 10..500 (= 1%..50%) on delegators
        nodes:integer                                           ;;[M]   oracle: nodes the operator runs (capture cap)
        uptime:integer                                          ;;[M]   oracle: promile 1..1000 (1000 = full)
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
    )
    (defschema DSA|OracleAuth
        @doc "Key = <FVT-ID>. The FVT-owner-delegated key allowed to write the daily {nodes, uptime} oracle values \
            \ for every agency on this vault."
        oracle-guard:guard                                      ;;[M]
        ;;Select Keys
        fvt-id:string
    )

)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AcquisitionAnchorsV1
    @doc "Interface for the AQP anchor layer. Declares the public surface for \
        \ issuing/revoking anchors (per-user boost multipliers on DPTF/DPSF/DPNF holdings) \
        \ and heterogeneous BoostClasses that group up to 7 anchors for score boosting. \
        \ Exposes UR_/URC_ readers of anchor definitions, per-user promile, and boost-class \
        \ score-links, plus XE_ update/sync/sweep hooks and C_Issue/C_Revoke client \
        \ entrypoints returning IGNIS OutputCumulators."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|AqpKey ())
    (defun GOV|AQP|SC_NAME ())
    (defun GOV|AQP|PBL ())

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions
    ;;
    (defun P|UEV_IMC ())

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap AQP|GOV ())
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    ;;
    (defun UCk_Anchors:string (account:string anchor-id:string))
    (defun UCk_UserBoost:string (account:string boost-class-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;;
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string))
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string))
    (defun UR_ANK|BoostClassId:string (anchor-id:string))
    (defun UR_ANK|Precision:decimal (anchor-id:string))
    (defun UR_ANK|State:bool (anchor-id:string))
    (defun UR_ANK|Promile:decimal (anchor-id:string))
    (defun UR_ANK|TFAmount:decimal (anchor-id:string))
    (defun UR_ANK|SFNonce:integer (anchor-id:string))
    (defun UR_ANK|NFTraitKey:string (anchor-id:string))
    (defun UR_ANK|NFTraitValue:string (anchor-id:string))
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string))
    (defun UR_ANK|ID:string (anchor-id:string))
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string))
    (defun UR_BC|Anchors:integer (boost-class-id:string))
    (defun UR_BC|Active:bool (boost-class-id:string))
    (defun UR_BC|ScoreLinks:[string] (boost-class-id:string))
    (defun UR_BC|ScoreLinkCount:integer (boost-class-id:string))
    (defun UR_BC|ID:string (boost-class-id:string))
    (defun UR_AA|GroupsActive:integer (asset-id:string))
    (defun UR_AA|AnchorsActive:integer (asset-id:string))
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string))
    (defun UR_ANK-U|Account:string (account:string anchor-id:string))
    (defun UR_ANK-U|ID:string (account:string anchor-id:string))
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string))
    ;;
    (defun URC_TrueFungibleAnchorPromile:decimal
        (anchor-id:string total-dptf-amount:decimal)
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
    )
    (defun URC_TraitOrClass:bool (anchor-id:string))
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string))
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer))
    (defun URC_TrueFungibleStakeAnchorRefreshIgnis:decimal (n-live:integer))
    ;; [URH] heavy-read
    (defun URH_ANK|AllAnchorIds:[string] ())
    (defun URH_BC|AllBoostClassIds:[string] ())
    ;;
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_IssueAnchor:object{IgnisCollectorV3.OutputCumulator} (op-key:string output:[string]))
    (defun URCi_IssueAnchorStoa:decimal (acnoi:bool))
    (defun URCi_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URC_AnchorableAssetOwner:string (ank-asset:string asset-fungibility:[bool]))
    (defun URCv_CoreDptf:string (dptf-id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_AnkFungibility (asset-fungibility:[bool]))
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal))
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string))
    (defun UEV_ExecutorIzAssetAuthority (executor:string ank-asset:string asset-fungibility:[bool]))
    (defun UEV_ExecutorIzAnchorAuthority (executor:string anchor-id:string))
    (defun UEV_AssetAnchorCap (ank-asset:string))
    (defun UEV_LiveAnchor (anchor-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XE]
    ;;
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
    )
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
    )
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
    )
    (defun XE_BumpBoostClassScoreLinks:string (boost-class-id:string score-id:string))
    (defun XE_UnbumpBoostClassScoreLinks:string (boost-class-id:string score-id:string))
    (defun XE_RecomputeUserBoostAggregates:string (account:string boost-class-ids:[string]))
    (defun XE_SweepRevokeAnchor:string (anchor-id:string))
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
    )
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
    )
    ;;{5.7}  User [A/C]
    ;; [C]   client
    ;;
    (defun C_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator}
        (boost-class-id:string)
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator} (anchor-id:string))

)
(module AQP-ANK GOV
    @doc "Sovereign anchor module for AQP. Stores anchor definitions, BoostClasses (7-slot \
        \ groupings), per-asset anchor bookkeeping, per-user anchor promile, \
        \ per-user/boost-class aggregates, and a reverse score-link index. Issues \
        \ true/semi/non-fungible (trait or set) anchors, revokes anchors/BoostClasses, and \
        \ updates each holder's aggregate promile on stake/unstake. Includes the revoke-lock \
        \ and re-score sweep hooks; anchors feed score boosting in AQP-SCORE."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;; REPL observability: REPL/Stage_02/[6.2.1]_AQP-ANK.repl tags each intra-tx group as TXnnn · mm · <slug> in ;;==== … ==== and (print "--- [TXnnn · mm · …] ---"); mm is 01.. within each begin-tx.
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionAnchorsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-ANK                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ANK_ADMIN)))
    (defcap GOV|ANK_ADMIN ()                            (enforce-guard GOV|MD_AQP-ANK))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        @doc "Resolves the governance keyset from DALOS."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AqpKey ()
        @doc "Governance keyset name for the AQP smart account (canonical — sibling AQP modules ref AQP-ANK)."
        (+ (CT_Namespace) ".dh_sc_aqp-keyset")
    )
    (defun GOV|AQP|SC_NAME ()
        @doc "Symbolic name of the AQP sovereign smart DALOS account (canonical)."
        (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"])
    )
    (defun GOV|AQP|PBL ()
        @doc "Public branding/license payload for AQP|SC_NAME smart account deploy (canonical)."
        (at 0 ["9G.632vHq208xaznBw9AfwrFGmLBqkr7tqEzf2Msq389xqEknmfAk8qI5MM1MaszdgMtEBpo6rbuC09Do7F6pjc91jzy3JxI6fjCkyuIbDpDD5i8CxeCBL0dKdDu3d2uAAwl6wE6npnm4Mjxx6JhiFq1sKddsGjLH9BjHF0ljtegHrn39qIADru76Ftr9Kgxh6Ds2aj4EufG07uK9sFG38ej5vooDMr0wp8alqGdnIiJxbhmwEKEg44l8pI5LDq2EotoM2jq86x1EJ5hM4wkfhtq4ye610tkAMIdLrDD87Euk14aJgMwnrLmytzcCc3Kakrnhs8Jxy5dFeowGxzlx1bGHqfwEen0pLcd6nl9udGE9hfFucLjM1seKzv542nwzz5jrpKmvzebI4BLK00Br1ocvxs4uor2nEv2Fng1l6qAiLcbv0hMnbLDEEcLpF1bD55gw55of7H2c3ieozahorkuCe5FEkAkEAhcGwJ35HCletrbcn2Ebo0fsD0tf2zxKsbzinpcJCtpv4EF4AyyhwD1LbtEd6qsEbgyJkA2DqdGBE5Fuqudzf8082Ei88d"])
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
    (defcap P|ANK|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ANK|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        @doc "Returns policy metadata key from DALOS policy module."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        @doc "Reads one policy guard by policy name."
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        @doc "Reads imported policy guards list."
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
        @doc "Enforces that caller matches an imported policy guard."
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        @doc "Writes or updates one local policy guard entry."
        (with-capability (GOV|ANK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        @doc "No IMP registration, and that is a MEASURED conclusion rather than an omission. \
            \ \
            \ This module bills -- `C_Issue*Anchor` all end on IGNIS' STOA collector, which became \
            \ `P|UEV_IMC`-gated on 2026-09-20. It still needs no guard of its own in IGNIS' IMP, \
            \ because every one of those call sites is a plain `C_` reached through TS02-C3, and \
            \ `P|UEV_IMC` is DEPTH-INVARIANT: the `P|TALOS-SUMMONER` capability TS02-C3 acquires \
            \ at the top is still in scope when the collector is reached. TS02-C3's guard is \
            \ registered; this module's would be a second answer to a question already answered. \
            \ \
            \ That is not free to add. `P|UEV_IMC` -> `U|G::UEV_Any` maps `UC_Try` over the WHOLE \
            \ guard list with no short-circuit, so every entry in IGNIS' IMP costs gas on EVERY \
            \ billed operation on the chain. A redundant registration is a permanent tax. \
            \ \
            \ WHAT WOULD CHANGE THIS: a billing call site inside a `defpact` step. A step arrives \
            \ in its own transaction via `continue-pact` with an EMPTY capability scope and \
            \ inherits nothing -- which is exactly what caught MTX-SWP. If one is ever added here, \
            \ this module needs its own guard registered, or that step must acquire `P|ANK|CALLER` \
            \ itself. Verified 2026-09-20 by `REPL/tools/_impdiff.py`: this registration never \
            \ landed in the genesis chain and the full gate was green regardless."
        true
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst AQP|SC_KEY                                (GOV|AqpKey))
    (defconst AQP|SC_NAME                               (GOV|AQP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst E-ANK
        {"promile"                  : 0.0
        ,"ouronet-account"          : BAR
        ,"anchor-id"                : BAR}
    )
    ;; M6 #15 — anchor-definition sanity bounds enforced at issue (UEV_Promile + ANK|C>ISSUE-DPTF).
    (defconst CT_ANK_PRECISION:integer                  3)          ;; anchors use exactly 3 decimals of promile precision
    (defconst CT_ANK_MIN_PROMILE:decimal                1.0)        ;; minimum anchor promile
    (defconst CT_ANK_MAX_PROMILE:decimal                10000.0)    ;; maximum anchor promile (caps a single anchor's boost)
    (defconst CT_ANK_MIN_DPTF_AMOUNT:decimal            1000.0)     ;; minimum TF-anchor denominated amount
    (defconst CT_ANK_MAX_DPTF_AMOUNT:decimal            1000000.0)  ;; maximum TF-anchor denominated amount
    ;;{3.2}  schemas
    ;;
    ;;1]General Anchor Definition
    ;;2]BoostClass Definition
    ;;3]Per-Asset Bookkeeping
    ;;4]User Anchor Values
    ;;5]Per-User Per-BoostClass Aggregate
    ;;{3.3}  tables
    ;;
    (deftable ANK|T|Anchor:{AcquisitionSchemasV1.ANK|Schema})                        ;;Key = <Anchor-ID>
    (deftable ANK|T|BoostClass:{AcquisitionSchemasV1.ANK|BoostClass})                ;;Key = <Boost-Class-ID>
    (deftable ANK|T|AssetAnchors:{AcquisitionSchemasV1.ANK|AssetAnchors})            ;;Key = <Asset-ID>
    (deftable ANK|T|BoostClassScoreLinks:{AcquisitionSchemasV1.ANK|BoostClassScoreLinks}) ;;Key = <Boost-Class-ID>
    ;;
    (deftable ANK|T|Anchors:{AcquisitionSchemasV1.ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    (deftable ANK|T|UserBoost:{AcquisitionSchemasV1.ANK|UserBoostSchema})            ;;Key = <Ouronet-Account> | <Boost-Class-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap ANK|C>BUMP-BOOST-CLASS-LINKS (boost-class-id:string)
        @doc "Authorizes AQP-SCORE (forward) to +1 a BoostClass score-link count — the H4 (#9) revoke lock."
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP ()
        @doc "Forward (re-score sweep · MTX-AQP): authorize the anchor-retire sweep's ANK writes — per-holder \
            \ aggregate-promile refold + swept anchor removal. NO fund movement. Composes SECURE."
        (compose-capability (SECURE))
    )
    ;;{C2}  Simple
    (defcap AQP|GOV ()
        @doc "Interface/deploy surface for AQP|SC_NAME governor rotate. Runtime compose: AQP-POOL.AQP|GOV only — \
            \ do not compose this cap from other modules."
        true
    )
    ;;{C3}  Composed
    (defcap ANK|C>UPDATE-DPTF (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Authorizes updating user promile for all live DPTF-backed anchors on <dptf-id> after stake/unstake."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]<total-dptf-amount> must be non-negative (0.0 allowed — vacate/unstake refresh)
            ;;
            ;;DATA-INTEGRITY BACKSTOP, NOT A CLIENT-FACING CHECK. The value is never caller-supplied.
            ;;The only caller is FVT::XI_RefreshTrueFungibleStakeAnchors, reaching this cap through
            ;;AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues, which opens with (P|UEV_IMC) — so no
            ;;external account can present an argument here at all. What FVT passes is the post-stake
            ;;tracker total, a sum over AQP|T|DPTFTracker balances, each of which is itself non-negative
            ;;by the custody cap (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY refuses an unstake larger than the
            ;;staked balance, so a row can reach 0.0 but never go below it). A negative therefore cannot
            ;;be constructed from any sequence of user actions; only a corrupt tracker write could
            ;;produce one, which is precisely what this line exists to catch. Kept deliberately at >=
            ;;rather than >: 0.0 is the legal vacate/unstake refresh value.
            ;;Backed by REPL/modules/AQP.repl <<AQP-G45>>, which asserts the IMC gate and the
            ;;non-negativity of the derivation rather than pretending to drive the guard.
            ;;UNREACHABLE
            (enforce (>= total-dptf-amount 0.0) "total-dptf-amount must be non-negative")
            ;;2]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;3]<dptf-id> must exist
            (ref-DPTF::UEV_id dptf-id)
            ;;4] when positive, <total-dptf-amount> must conform to DPTF precision
            (if (> total-dptf-amount 0.0)
                (ref-DPTF::UEV_Amount dptf-id total-dptf-amount)
                true
            )
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>UPDATE-DPSF (account:string dpsf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPSF-backed anchors on one asset (delegates to UPDATE-DPDC, SF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpsf-id nonces true))
    )
    (defcap ANK|C>UPDATE-DPNF (account:string dpnf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPNF-backed anchors on one asset (delegates to UPDATE-DPDC, NF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpnf-id nonces false))
    )
    (defcap ANK|C>UPDATE-DPDC (account:string asset-id:string nonces:[integer] son:bool)
        @doc "Authorizes a DPDC anchor-value update for <account> on <asset-id>'s <nonces> \
            \ (<son> discriminates the set / non-set collectable fungibility mode). Validates the \
            \ account exists and the nonces exist for the target DPDC asset; composes SECURE for the write."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<nonces> must exist for the target DPDC asset + fungibility mode
            (ref-DPDC::UEV_NonceMapper asset-id son nonces)
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-BOOST-CLASS (boost-class-id:string)
        @doc "Authorizes revoking an empty BoostClass."
        @event
        (let
            (
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
            )
            (enforce (= (at "anchors" bc) 0) (format "{} BoostClass {} not empty" [E-ANK boost-class-id]))
            (enforce (at "class-active" bc) (format "{} BoostClass {} already inactive" [E-ANK boost-class-id]))
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>ISSUE-DPTF
        (executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Validates DPTF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fourth:string (drop 3 (take 4 dptf-id)))
                (first-two:string (take 2 dptf-id))
            )
            (enforce
                (fold (and) true 
                    [
                        (!= fourth BAR)
                        (!= first-two "S|")
                        (!= first-two "W|")
                        (!= first-two "P|")
                    ]
                )
                (format "Anchor cannot be issued for the DPTF {}." [dptf-id])
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPTF::UEV_id dptf-id)
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
            ;; M6 #15: TF-anchor denominated amount must sit within [1000, 1,000,000] so a tiny denominator can't
            ;; leverage the pro-rated promile into an insane boost.
            (enforce
                (and (>= dptf-amount CT_ANK_MIN_DPTF_AMOUNT) (<= dptf-amount CT_ANK_MAX_DPTF_AMOUNT))
                "TF anchor denominated amount (dptf-amount) must be within [1000, 1,000,000]"
            )
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (CAP_TF|Owner dptf-id)
            (UEV_ExecutorIzAssetAuthority executor dptf-id [true true])
            (if acnoi
                (UEV_AssetAnchorCap dptf-id)
                (UEV_IssueAnchor dptf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPSF
        (executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Validates DPSF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpsf-id true)
            (ref-DPDC::UEV_Nonce dpsf-id true dpsf-nonce)
            (ref-DPDC::CAP_OwnerOrCreator dpsf-id true)
            (UEV_ExecutorIzAssetAuthority executor dpsf-id [false true])
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpsf-id)
                (UEV_IssueAnchor dpsf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPNF
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Validates DPNF trait-anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            (enforce
                (fold (and) true 
                    [
                        iz-key-present
                        (>= l 2)
                        (<= l 256)
                        (!= dpnf-trait-value BAR)
                    ]
                )
                "Invalid Non-Fungible Key or Invalid Promile DPNF Trait-Value"
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|C>ISSUE-DPNF-SET
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Validates DPNF set-anchor issuance via nonce-class model. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            (enforce
                (and (>= dpnf-nonce-class 0) (<= dpnf-nonce-class classes-used))
                (format "Invalid DPNF nonce-class {} for collection {}." [dpnf-nonce-class dpnf-id])
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|XI>ISSUE-DPNF-COMMON
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal)
        @doc "Common DPNF issuance checks shared by trait and set modes."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;AUTHORISATION FIRST (2026-09-14 ruling), and it is NEW here. Until 2026-09-20 the two
            ;;DPNF anchor paths reached NO ownership enforce at all, while their DPTF sibling ran
            ;;CAP_TF|Owner and their DPSF sibling ran CAP_OwnerOrCreator. The asymmetry mattered:
            ;;UEV_AssetAnchorCap caps an asset at 49 anchors, so a stranger could mint 49 anchors
            ;;against a collection he did not own, exhaust the cap permanently, and own every
            ;;resulting boost class. Bounded by STOA cost, but cheap next to blocking a collection
            ;;forever. Closed here because AQP is pre-mainnet and the gap is free to close now.
            (ref-DPDC::CAP_OwnerOrCreator dpnf-id false)
            (UEV_ExecutorIzAssetAuthority executor dpnf-id [false false])
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpnf-id false)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpnf-id)
                (UEV_IssueAnchor dpnf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (anchor-id:string)
        @doc "Authorizes anchor revocation for <anchor-id>; requires the anchor to be ALIVE + owned. H4 (#9) \
            \ temp-patch: blocked while the anchor's BoostClass is linked by any score — vacate/unlink first (the \
            \ re-score-sweep unwind is not built yet; see Audit/ANCHOR-STALENESS-INVENTORY.md)."
        @event
        ;; L4 #17: reject a dead/never-existed anchor up front (revoke sets State→false), so a double-revoke aborts
        ;; cleanly here instead of deep in UC_RemoveItemAt — and the H4 lock below never reads a revoked anchor.
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        ;; #9 lock: cannot revoke an anchor whose BoostClass is employed by ≥1 score (stale-boost prevention).
        (enforce
            (= (UR_BC|ScoreLinkCount (UR_ANK|BoostClassId anchor-id)) 0)
            "Anchor's BoostClass is in use by a score — revoke locked until scores are vacated/unlinked"
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP-REVOKE (anchor-id:string)
        @doc "Forward (re-score sweep terminal): authorize SWEPT revocation of an EMPLOYED anchor — liveness + \
            \ owner enforced, but NOT the #9 score-link lock (the sweep has already refreshed every affected \
            \ holder, so no staleness remains). Distinct from ANK|C>REVOKE (gated on set==0 for UNemployed anchors)."
        @event
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    ;;UNUSED and REDUNDANT -- harmless. The live revoke path (XI at ~2280) acquires
    ;;ANK|C>REVOKE-BOOST-CLASS directly, and that cap is itself @event and carries both real
    ;;guards (empty class, still active). This wrapper only re-emits around it, so nothing is
    ;;lost by it never being reached: no guard is skipped and the inner event still fires.
    ;;Contrast ATS|S>CONTROL-DIRECT-RECOVERY, whose orphaning DOES skip a guard. Flagged 2026-09-10.
    (defcap ANK|C>REVOKE-BOOST-CLASS-ENTRY (boost-class-id:string)
        @doc "Authorizes revoking a BoostClass entity."
        @event
        (compose-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        @doc "Namespace prefix for AQP governance keyset name."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_ANK|Schema:object{AcquisitionSchemasV1.ANK|Schema}
        (a:string b:[bool] c:string d:integer e:bool f:decimal g:decimal h:integer i:string j:string k:integer l:string)
        @doc "Constructs anchor definition row for ANK|T|Anchor."
        {"ank-asset"            : a
        ,"ank-fungibility"      : b
        ,"boost-class-id"       : c
        ,"ank-precision"        : d
        ,"ank-active"           : e
        ,"ank-promile"          : f
        ,"dptf-amount"          : g
        ,"dpsf-nonce"           : h
        ,"dpnf-trait-key"       : i
        ,"dpnf-trait-value"     : j
        ,"dpnf-nonce-class"     : k
        ,"anchor-id"            : l}
    )
    (defun UDC_BoostClass:object{AcquisitionSchemasV1.ANK|BoostClass}
        (a:string b:string c:string d:string e:string f:string g:string h:integer i:bool j:string k:string)
        @doc "Constructs BoostClass object. `k` is the class-owner (creator); only it may attach anchors."
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"anchors"              : h
        ,"class-active"         : i
        ,"boost-class-id"       : j
        ,"class-owner"          : k}
    )
    (defun UDC_EmptyInternalGroup:object{AcquisitionSchemasV1.ANK|InternalGroup} ()
        @doc "Constructs empty InternalGroup (all BAR, anchors=0)."
        {"anchor-primary"       : BAR
        ,"anchor-secondary"     : BAR
        ,"anchor-tertiary"      : BAR
        ,"anchor-quaternary"    : BAR
        ,"anchor-quinary"       : BAR
        ,"anchor-senary"        : BAR
        ,"anchor-septenary"     : BAR
        ,"anchors"              : 0}
    )
    (defun UDC_IG|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in an InternalGroup."
        (let
            (
                (a1:string (at "anchor-primary" ig))
                (a2:string (at "anchor-secondary" ig))
                (a3:string (at "anchor-tertiary" ig))
                (a4:string (at "anchor-quaternary" ig))
                (a5:string (at "anchor-quinary" ig))
                (a6:string (at "anchor-senary" ig))
                (a7:string (at "anchor-septenary" ig))
                (n:integer (at "anchors" ig))
            )
            (cond
                ((= a1 BAR) {"anchor-primary": new-anchor-id, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a2 BAR) {"anchor-primary": a1, "anchor-secondary": new-anchor-id, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a3 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": new-anchor-id, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a4 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": new-anchor-id, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a5 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": new-anchor-id, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a6 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": new-anchor-id, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a7 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": new-anchor-id, "anchors": (+ n 1)})
                ig
            )
        )
    )
    (defun UDC_IG|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} revoked-anchor-id:string)
        @doc "Removes anchor-id from group, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" ig)
                     (at "anchor-secondary" ig)
                     (at "anchor-tertiary" ig)
                     (at "anchor-quaternary" ig)
                     (at "anchor-quinary" ig)
                     (at "anchor-senary" ig)
                     (at "anchor-septenary" ig)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" ig))
            )
            {"anchor-primary"   : (at 0 lst-v2)
            ,"anchor-secondary" : (at 1 lst-v2)
            ,"anchor-tertiary"  : (at 2 lst-v2)
            ,"anchor-quaternary": (at 3 lst-v2)
            ,"anchor-quinary"   : (at 4 lst-v2)
            ,"anchor-senary"    : (at 5 lst-v2)
            ,"anchor-septenary" : (at 6 lst-v2)
            ,"anchors"          : (- n 1)}
        )
    )
    (defun UDC_BC|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in a BoostClass."
        (let
            (
                (a1:string (at "anchor-primary" bc))
                (a2:string (at "anchor-secondary" bc))
                (a3:string (at "anchor-tertiary" bc))
                (a4:string (at "anchor-quaternary" bc))
                (a5:string (at "anchor-quinary" bc))
                (a6:string (at "anchor-senary" bc))
                (a7:string (at "anchor-septenary" bc))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (cond
                ((= a1 BAR) (UDC_BoostClass new-anchor-id a2 a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a2 BAR) (UDC_BoostClass a1 new-anchor-id a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a3 BAR) (UDC_BoostClass a1 a2 new-anchor-id a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a4 BAR) (UDC_BoostClass a1 a2 a3 new-anchor-id a5 a6 a7 (+ n 1) ca bcid co))
                ((= a5 BAR) (UDC_BoostClass a1 a2 a3 a4 new-anchor-id a6 a7 (+ n 1) ca bcid co))
                ((= a6 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 new-anchor-id a7 (+ n 1) ca bcid co))
                ((= a7 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 a6 new-anchor-id (+ n 1) ca bcid co))
                bc
            )
        )
    )
    (defun UDC_BC|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} revoked-anchor-id:string)
        @doc "Removes anchor-id from BoostClass, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" bc)
                     (at "anchor-secondary" bc)
                     (at "anchor-tertiary" bc)
                     (at "anchor-quaternary" bc)
                     (at "anchor-quinary" bc)
                     (at "anchor-senary" bc)
                     (at "anchor-septenary" bc)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (UDC_BoostClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (- n 1) ca bcid co
            )
        )
    )
    (defun UDC_AA|PlaceAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} new-anchor-id:string)
        @doc "Places anchor in first group with a free slot; creates new group if needed. \
            \ Pure constructor — no enforce. Caller (issue caps via UEV_*) must ensure \
            \ anchors-active < 49 (implies a free group slot exists under 7×7)."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (let
                (
                    (result:list
                        (fold
                            (lambda (acc:list gi:integer)
                                (if (= (at 1 acc) 1)
                                    acc
                                    (let
                                        (
                                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                            (gn:integer (at "anchors" grp))
                                        )
                                        (if (< gn 7)
                                            [(UDC_IG|WithAddedAnchor grp new-anchor-id) 1 gi]
                                            acc
                                        )
                                    )
                                )
                            )
                            [(UDC_EmptyInternalGroup) 0 -1]
                            (enumerate 0 6)
                        )
                    )
                    (placed:integer (at 1 result))
                )
                (if (= placed 1)
                    (let
                        (
                            (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (at 0 result))
                            (slot:integer (at 2 result))
                            (prev-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa slot))
                            (new-ga:integer
                                (if (and (= (at "anchors" prev-grp) 0) (> (at "anchors" updated-grp) 0))
                                    (if (> ga (+ slot 1)) ga (+ slot 1))
                                    ga
                                )
                            )
                        )
                        (URC_AA|SetGroupAtSlot aa updated-grp slot (+ ta 1) new-ga false)
                    )
                    (let
                        (
                            (new-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithAddedAnchor (UDC_EmptyInternalGroup) new-anchor-id))
                        )
                        (URC_AA|SetGroupAtSlot aa new-grp ga (+ ta 1) ga true)
                    )
                )
            )
        )
    )
    (defun UDC_AA|RemoveAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} revoked-anchor-id:string)
        @doc "Removes anchor from its group in AssetAnchors."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (fold
                (lambda (acc:object{AcquisitionSchemasV1.ANK|AssetAnchors} gi:integer)
                    (let
                        (
                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot acc gi))
                        )
                        (if (URC_IG|ContainsAnchor grp revoked-anchor-id)
                            (let
                                (
                                    (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithRemovedAnchor grp revoked-anchor-id))
                                    (was-ga:integer (at "groups-active" acc))
                                    (was-ta:integer (at "anchors-active" acc))
                                    (grp-now-empty:bool (= (at "anchors" updated-grp) 0))
                                )
                                (URC_AA|SetGroupAtSlot acc updated-grp gi (- was-ta 1) was-ga grp-now-empty)
                            )
                            acc
                        )
                    )
                )
                aa
                (enumerate 0 6)
            )
        )
    )
    (defun UDC_AccountAnchor:object{AcquisitionSchemasV1.ANK|UserSchema}
        (a:decimal b:string c:string)
        @doc "Constructs user-anchor contribution object."
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
    (defun UDC_UserBoost:object{AcquisitionSchemasV1.ANK|UserBoostSchema}
        (aggregate-promile:decimal ouronet-account:string boost-class-id:string)
        @doc "Constructs user-boost aggregate row for ANK|T|UserBoost."
        {"aggregate-promile"   : aggregate-promile
        ,"ouronet-account"     : ouronet-account
        ,"boost-class-id"      : boost-class-id}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_Anchors:string
        (account:string anchor-id:string)
        @doc "Composite key for ANK|T|Anchors (account BAR anchor-id)."
        (concat [account BAR anchor-id])
    )
    (defun UCk_UserBoost:string
        (account:string boost-class-id:string)
        @doc "Composite key for ANK|T|UserBoost (account BAR boost-class-id)."
        (concat [account BAR boost-class-id])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; Reads follow schema order: (1) ANK|Schema (2) ANK|BoostClass (3) ANK|AssetAnchors (4) ANK|UserSchema (5) ANK|UserBoostSchema
    ;; Policy P|T, P|MT — not ANK rows; use P|Info, P|UR, P|UR_IMP above.
    ;;
    ;; Core row: UR_ANK|Data
    (defun UR_ANK|Data:object{AcquisitionSchemasV1.ANK|Schema} (anchor-id:string)
        @doc "Reads full anchor definition row from ANK|T|Anchor."
        (read ANK|T|Anchor anchor-id)
    )
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string)
        @doc "Reads anchored asset id from anchor row."
        (at "ank-asset" (read ANK|T|Anchor anchor-id ["ank-asset"]))
    )
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string)
        @doc "Reads anchor fungibility marker."
        (at "ank-fungibility" (read ANK|T|Anchor anchor-id ["ank-fungibility"]))
    )
    (defun UR_ANK|BoostClassId:string (anchor-id:string)
        @doc "Reads the BoostClass-ID this anchor belongs to."
        (at "boost-class-id" (read ANK|T|Anchor anchor-id ["boost-class-id"]))
    )
    (defun UR_ANK|Precision:decimal (anchor-id:string)
        @doc "Reads anchor precision as decimal."
        (dec (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"])))
    )
    (defun UR_ANK|State:bool (anchor-id:string)
        @doc "Reads anchor active flag. DEFAULTED: an anchor that does not exist is not active, \
            \ which is what every caller means by this question."
        ;;This was a bare `read`, so for an anchor that does not exist it raised
        ;;`No value found in table ouronet-ns.AQP-ANK_ANK|T|Anchor for key: <id>` -- and
        ;;`UEV_LiveAnchor`, the validator built on it, could therefore never deliver its own
        ;;message ("Anchor <id> must be alive for operation") for the one input that most needs it.
        ;;Both callers are correct under the default: UEV_LiveAnchor wants false, and the anchor
        ;;filter at ~1193 already screens BAR and wants false for anything not alive.
        ;;Same shape as DPTF's UEV_id, which defaults <supply> to -1.0 for exactly this reason.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-007a/b>>.
        (with-default-read ANK|T|Anchor anchor-id
            { "ank-active" : false }
            { "ank-active" := a }
            a
        )
    )
    (defun UR_ANK|Promile:decimal (anchor-id:string)
        @doc "Reads anchor promile value."
        (at "ank-promile" (read ANK|T|Anchor anchor-id ["ank-promile"]))
    )
    ;;
    (defun UR_ANK|TFAmount:decimal (anchor-id:string)
        @doc "Reads DPTF amount for TF anchor."
        (at "dptf-amount" (read ANK|T|Anchor anchor-id ["dptf-amount"]))
    )
    (defun UR_ANK|SFNonce:integer (anchor-id:string)
        @doc "Reads DPSF nonce for SF anchor."
        (at "dpsf-nonce" (read ANK|T|Anchor anchor-id ["dpsf-nonce"]))
    )
    (defun UR_ANK|NFTraitKey:string (anchor-id:string)
        @doc "Reads DPNF trait key for NF anchor."
        (at "dpnf-trait-key" (read ANK|T|Anchor anchor-id ["dpnf-trait-key"]))
    )
    (defun UR_ANK|NFTraitValue:string (anchor-id:string)
        @doc "Reads DPNF trait value for NF anchor."
        (at "dpnf-trait-value" (read ANK|T|Anchor anchor-id ["dpnf-trait-value"]))
    )
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string)
        @doc "Reads DPNF nonce-class for NF set-anchor mode."
        (at "dpnf-nonce-class" (read ANK|T|Anchor anchor-id ["dpnf-nonce-class"]))
    )
    (defun UR_ANK|ID:string (anchor-id:string)
        @doc "Reads anchor-id field from anchor row."
        (at "anchor-id" (UR_ANK|Data anchor-id))
    )
    ;;
    (defun UR_BC|Data:object{AcquisitionSchemasV1.ANK|BoostClass} (boost-class-id:string)
        @doc "Reads full BoostClass row."
        (read ANK|T|BoostClass boost-class-id)
    )
    (defun UR_BC|Anchors:integer (boost-class-id:string)
        @doc "Reads anchor count from BoostClass."
        (at "anchors" (read ANK|T|BoostClass boost-class-id ["anchors"]))
    )
    (defun UR_BC|Active:bool (boost-class-id:string)
        @doc "Reads active flag from BoostClass."
        (at "class-active" (read ANK|T|BoostClass boost-class-id ["class-active"]))
    )
    (defun UR_BC|ScoreLinks:[string] (boost-class-id:string)
        @doc "The SET of score-ids employing this BoostClass — the H4 reverse index (sweep phase 1). Empty when \
            \ absent. Enumerated by the re-score sweep to find every score/position an anchor change touches."
        (with-default-read ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links": []}
            {"score-links" := sl}
            sl
        )
    )
    (defun UR_BC|ScoreLinkCount:integer (boost-class-id:string)
        @doc "Count of SCORE links referencing this BoostClass (H4 #9 revoke lock) = length of the reverse-index \
            \ set; 0 when absent. Single source of truth is UR_BC|ScoreLinks."
        (length (UR_BC|ScoreLinks boost-class-id))
    )
    (defun UR_BC|ID:string (boost-class-id:string)
        @doc "Reads boost-class-id from BoostClass row."
        (at "boost-class-id" (read ANK|T|BoostClass boost-class-id ["boost-class-id"]))
    )
    ;;
    (defun UR_AA|Data:object{AcquisitionSchemasV1.ANK|AssetAnchors} (asset-id:string)
        @doc "Reads full per-asset bookkeeping row (with-default-read when absent)."
        (let
            (
                (eg:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_EmptyInternalGroup))
            )
            (with-default-read ANK|T|AssetAnchors asset-id
                {"group-primary"     : eg
                ,"group-secondary"   : eg
                ,"group-tertiary"    : eg
                ,"group-quaternary"  : eg
                ,"group-quinary"     : eg
                ,"group-senary"      : eg
                ,"group-septenary"   : eg
                ,"groups-active"     : 0
                ,"anchors-active"    : 0
                ,"asset-id"          : asset-id}
                {"group-primary"     := g1
                ,"group-secondary"   := g2
                ,"group-tertiary"    := g3
                ,"group-quaternary"  := g4
                ,"group-quinary"     := g5
                ,"group-senary"      := g6
                ,"group-septenary"   := g7
                ,"groups-active"     := ga
                ,"anchors-active"    := aa
                ,"asset-id"          := aid}
                {"group-primary"     : g1
                ,"group-secondary"   : g2
                ,"group-tertiary"    : g3
                ,"group-quaternary"  : g4
                ,"group-quinary"     : g5
                ,"group-senary"      : g6
                ,"group-septenary"   : g7
                ,"groups-active"     : ga
                ,"anchors-active"    : aa
                ,"asset-id"          : aid}
            )
        )
    )
    (defun UR_AA|GroupsActive:integer (asset-id:string)
        @doc "Reads groups-active from asset anchors row."
        (at "groups-active" (UR_AA|Data asset-id))
    )
    (defun UR_AA|AnchorsActive:integer (asset-id:string)
        @doc "Reads anchors-active from asset anchors row."
        (at "anchors-active" (UR_AA|Data asset-id))
    )
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string)
        @doc "Live anchor-ids for an asset. Reads the single AssetAnchors row, \
            \ iterates all groups and slots, collects non-BAR active anchors."
        (let
            (
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
                (ga:integer (at "groups-active" aa))
            )
            (if (<= ga 0)
                []
                (fold
                    (lambda (acc:[string] gi:integer)
                        (let
                            (
                                (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                (q:integer (at "anchors" grp))
                            )
                            (if (<= q 0)
                                acc
                                (fold
                                    (lambda (acc2:[string] ai:integer)
                                        (let
                                            (
                                                (aid:string (URC_IG|AnchorIdAtSlot grp ai))
                                            )
                                            (if (and (!= aid BAR) (UR_ANK|State aid))
                                                (+ acc2 [aid])
                                                acc2
                                            )
                                        )
                                    )
                                    acc
                                    (enumerate 0 (- q 1))
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 6)
                )
            )
        )
    )
    ;;
    ;; Core row: UR_ANK-U|Data
    (defun UR_ANK-U|Data:object{AcquisitionSchemasV1.ANK|UserSchema} (account:string anchor-id:string)
        @doc "Core read: user cumulative promile row for account x anchor."
        (with-default-read ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor 0.0 account anchor-id)
            {"promile"                  := p
            ,"ouronet-account"          := oa
            ,"anchor-id"                := aid}
            (UDC_AccountAnchor p oa aid)
        )
    )
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string)
        @doc "Reads promile from user-anchor row."
        (at "promile" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|Account:string (account:string anchor-id:string)
        @doc "Reads account id from user-anchor row."
        (at "ouronet-account" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|ID:string (account:string anchor-id:string)
        @doc "Reads anchor id from user-anchor row."
        (at "anchor-id" (UR_ANK-U|Data account anchor-id))
    )
    ;;
    (defun UR_UB|Data:object{AcquisitionSchemasV1.ANK|UserBoostSchema} (account:string boost-class-id:string)
        @doc "Reads user-boost aggregate row (with-default-read when absent)."
        (with-default-read ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost 0.0 account boost-class-id)
            {"aggregate-promile"   := ap
            ,"ouronet-account"     := oa
            ,"boost-class-id"      := bcid}
            (UDC_UserBoost ap oa bcid)
        )
    )
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string)
        @doc "Reads aggregate promile for user in a BoostClass."
        (at "aggregate-promile" (UR_UB|Data account boost-class-id))
    )
    ;;
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dptf-amount:decimal (UR_ANK|TFAmount anchor-id))
            )
            (if (<= dptf-amount 0.0)
                0.0
                (floor (* (/ total-dptf-amount dptf-amount) ank-promile) ank-precision)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Computes SF anchor promile from nonce equality model."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-nonces:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
        @doc "Computes NF anchor promile using trait mode or nonce-class mode."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Absolute SF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-amount:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
            )
            (floor (* (dec conform-amount) ank-promile) ank-precision)
        )
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
        @doc "Absolute NF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
            )
            (floor (* (dec conform-nonces) ank-promile) ank-precision)
        )
    )
    (defun URC_TraitOrClass:bool (anchor-id:string)
        @doc "Returns true for trait-mode; false for nonce-class mode."
        (fold (and) true
            [
                (!= (UR_ANK|NFTraitKey anchor-id) BAR)
                (!= (UR_ANK|NFTraitValue anchor-id) BAR)
                (= (UR_ANK|NFNonceClass anchor-id) -1)
            ]
        )
    )
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string)
        @doc "Outputs how many nonces from <nonces> have the proper MetaData Trait"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (nonce-meta-data:object 
                                (ref-DPDC::UR_N|RawMetaData 
                                    (ref-DPDC::UR_NativeNonceData dpnf-id false nonce)
                                )
                            )
                            (has-trait-key:bool (contains trait-key nonce-meta-data))
                            (output:integer
                                (if (or (< nonce 0) (not has-trait-key))
                                    0
                                    (if (= trait-value (at trait-key nonce-meta-data))
                                        1
                                        0
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer)
        @doc "Outputs how many nonces from <nonces> conform to nonce-class mode."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (output:integer
                                (if (< nonce 0)
                                    0
                                    (if (= nonce-class 0)
                                        1
                                        (if (= (ref-DPDC::UR_NonceClass dpnf-id false nonce) nonce-class)
                                            1
                                            0
                                        )
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_TrueFungibleStakeAnchorRefreshIgnis:decimal (n-live:integer)
        @doc "Internal: ignis|small per live TF anchor refreshed (n_live = length UR_ANK|AnchorsForAsset). Zero when n_live ≤ 0."
        (if (<= n-live 0)
            0.0
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (unit:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                )
                (* (dec n-live) unit)
            )
        )
    )
    ;; --- AssetAnchors / BoostClass slot helpers (in-memory; UDC_AA|* and XI_2|Recompute*) ---
    (defun URC_BC|AnchorIdAtSlot:string (bc:object{AcquisitionSchemasV1.ANK|BoostClass} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from a BoostClass object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" bc))
            ((= idx 1) (at "anchor-secondary" bc))
            ((= idx 2) (at "anchor-tertiary" bc))
            ((= idx 3) (at "anchor-quaternary" bc))
            ((= idx 4) (at "anchor-quinary" bc))
            ((= idx 5) (at "anchor-senary" bc))
            ((= idx 6) (at "anchor-septenary" bc))
            BAR
        )
    )
    (defun URC_AA|GroupAtSlot:object{AcquisitionSchemasV1.ANK|InternalGroup} (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} idx:integer)
        @doc "URC: reads internal group at slot idx (0..6) from an AssetAnchors object (in-memory)."
        (cond
            ((= idx 0) (at "group-primary" aa))
            ((= idx 1) (at "group-secondary" aa))
            ((= idx 2) (at "group-tertiary" aa))
            ((= idx 3) (at "group-quaternary" aa))
            ((= idx 4) (at "group-quinary" aa))
            ((= idx 5) (at "group-senary" aa))
            ((= idx 6) (at "group-septenary" aa))
            (UDC_EmptyInternalGroup)
        )
    )
    (defun URC_IG|AnchorIdAtSlot:string (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from an InternalGroup object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" ig))
            ((= idx 1) (at "anchor-secondary" ig))
            ((= idx 2) (at "anchor-tertiary" ig))
            ((= idx 3) (at "anchor-quaternary" ig))
            ((= idx 4) (at "anchor-quinary" ig))
            ((= idx 5) (at "anchor-senary" ig))
            ((= idx 6) (at "anchor-septenary" ig))
            BAR
        )
    )
    (defun URC_IG|ContainsAnchor:bool (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} anchor-id:string)
        @doc "URC: true when InternalGroup contains anchor-id (in-memory scan of seven slots)."
        (or (= anchor-id (at "anchor-primary" ig))
        (or (= anchor-id (at "anchor-secondary" ig))
        (or (= anchor-id (at "anchor-tertiary" ig))
        (or (= anchor-id (at "anchor-quaternary" ig))
        (or (= anchor-id (at "anchor-quinary" ig))
        (or (= anchor-id (at "anchor-senary" ig))
            (= anchor-id (at "anchor-septenary" ig))))))))
    )
    (defun URC_AA|SetGroupAtSlot:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} grp:object{AcquisitionSchemasV1.ANK|InternalGroup} slot:integer ta:integer ga:integer adjust-ga:bool)
        @doc "URC: returns updated AssetAnchors with group replaced at slot (in-memory; used by UDC_AA|PlaceAnchor / RemoveAnchor)."
        (let
            (
                (g1:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 0) grp (at "group-primary" aa)))
                (g2:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 1) grp (at "group-secondary" aa)))
                (g3:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 2) grp (at "group-tertiary" aa)))
                (g4:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 3) grp (at "group-quaternary" aa)))
                (g5:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 4) grp (at "group-quinary" aa)))
                (g6:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 5) grp (at "group-senary" aa)))
                (g7:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 6) grp (at "group-septenary" aa)))
                (new-ta:integer ta)
                (new-ga:integer
                    (if adjust-ga
                        (if (= (at "anchors" grp) 0)
                            (- ga 1)
                            (+ ga 1)
                        )
                        ga
                    )
                )
            )
            {"group-primary"    : g1
            ,"group-secondary"  : g2
            ,"group-tertiary"   : g3
            ,"group-quaternary" : g4
            ,"group-quinary"    : g5
            ,"group-senary"     : g6
            ,"group-septenary"  : g7
            ,"groups-active"    : new-ga
            ,"anchors-active"   : new-ta
            ,"asset-id"         : (at "asset-id" aa)}
        )
    )
    ;; [URH] heavy-read
    (defun URH_ANK|AllAnchorIds:[string] ()
        @doc "Returns all row keys from ANK|T|Anchor."
        (keys ANK|T|Anchor)
    )
    (defun URH_BC|AllBoostClassIds:[string] ()
        @doc "Returns all row keys from ANK|T|BoostClass."
        (keys ANK|T|BoostClass)
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_IssueAnchor:object{IgnisCollectorV3.OutputCumulator} (op-key:string output:[string])
        @doc "IGNIS cost for the 4 anchor-issue ops: a FLAT 500 deterrence for every anchor type \
            \ plus that op's own component cost (owner 2026-09-06). This supersedes the \
            \ 2026-09-05 rule of half the anchored asset's issuance price, which is why the \
            \ caller now passes its TALOS OP KEY (AQP-ANK|C_Issue…Anchor) rather than a deter \
            \ tier — the tier is the same for all four. <output> carries \
            \ anchor-id[+boost-class-id]. Shared by exec and the INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice op-key "anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueAnchorStoa:decimal (acnoi:bool)
        @doc "STOA cost for anchor-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (anchor = $5 => 50 STOA). Previously read the raw \
            \ 'standard' usage price (0.01), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely. Doubled when <acnoi>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (ref-IGNIS::UC_StoaPrice "anchor") (if acnoi 2.0 1.0))
        ))
    (defun URCi_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeAnchor — owner-priced 100 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeAnchor" "revoke-anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeBoostClass — owner-priced 500 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeBoostClass" "revoke-boost") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URC_AnchorableAssetOwner:string (ank-asset:string asset-fungibility:[bool])
        @doc "The OWNER konto of an anchorable asset -- the account an anchor issuance must name as \
            \ its executor. For a DPTF this resolves F|/R| to the core token first; for a collectable \
            \ it is the owner (the CREATOR is also an authority -- see UEV_ExecutorIzAssetAuthority -- \
            \ but only one of the two can be 'the' owner, and this reader answers that). \
            \ Exists because the answer is frequently NOT the obvious account: sovereign assets such \
            \ as OURO are owned by a SMART account, and the human admin merely holds its key. Before \
            \ the executor was named, that distinction was invisible at every call site."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if (= asset-fungibility [true true])
                (ref-DPTF::UR_Konto (URCv_CoreDptf ank-asset))
                (ref-DPDC::UR_OwnerKonto ank-asset (= asset-fungibility [false true]))
            )
        )
    )
    (defun URCv_CoreDptf:string (dptf-id:string)
        @doc "The CORE DPTF behind an anchored DPTF id: an `F|` frozen or `R|` reserved token \
            \ resolves to its parent, anything else is already core. Extracted from CAP_TF|Owner \
            \ (2026-09-20) so the executor check and the ownership gate read the SAME rule -- two \
            \ copies of a resolution that must agree is the failure class this refactor's own \
            \ tooling was built to prevent."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (first-two:string (take 2 dptf-id))
            )
            (cond
                ((= first-two "F|") (ref-DPTF::UR_Frozen dptf-id))
                ((= first-two "R|") (ref-DPTF::UR_Reservation dptf-id))
                dptf-id
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_AnkFungibility (asset-fungibility:[bool])
        @doc "Validates asset-fungibility tuple (TF/SF/NF discriminator) for anchor-class / asset-summary tables."
        (let
            (
                (l:integer (length asset-fungibility))
            )
            (enforce (and (= l 2) (!= asset-fungibility [true false])) "Invalid Fungibility")
        )
    )
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal)
        @doc "M6 #15: anchor precision is exactly CT_ANK_PRECISION (3); anchor-promile is conform to that precision \
            \ and within [CT_ANK_MIN_PROMILE, CT_ANK_MAX_PROMILE] = [1, 10000] (caps a single anchor's boost)."
        (enforce
            (fold (and) true
                [
                    (= anchor-precision CT_ANK_PRECISION)                             ;;<anchor-precision> must be exactly 3
                    (= (floor anchor-promile CT_ANK_PRECISION) anchor-promile)        ;;<anchor-promile> conform to precision 3
                    (>= anchor-promile CT_ANK_MIN_PROMILE)                            ;;<anchor-promile> must be >= 1.0
                    (<= anchor-promile CT_ANK_MAX_PROMILE)                            ;;<anchor-promile> must be <= 10000.0
                ]
            )
            "Invalid Promile Variables: precision must be 3 and promile within [1, 10000]"
        )
    )
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string)
        @doc "Validates BoostClass exists, is active, has a free slot, and IS OWNED BY THE CALLER; also \
            \ validates asset 49-anchor cap. Used when acnoi=false (attaching to an EXISTING class)."
        ;;OWNERSHIP ADDED 2026-09-19. Issuing an anchor is gated on CAP_OwnerOrCreator of the
        ;;ANCHORED ASSET -- but on this path that is the caller's OWN asset, which gates nothing
        ;;about the class being joined. A BoostClass had no owner at all, so anyone holding any
        ;;anchorable asset could attach it to someone else's class and hand their holders a boost
        ;;inside that vault's scoring; a 7-slot class with one anchor used offered six such grants.
        ;;Enforced via account ownership rather than a passed patron so no defcap signature moves:
        ;;CAP_EnforceAccountOwnership checks the transaction is signed by that account's guard.
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (at "class-owner" bc))
            (enforce (at "class-active" bc) (format "{} BoostClass {} must be active" [E-ANK boost-class-id]))
            (enforce (< (at "anchors" bc) 7) (format "{} BoostClass {} full (7 anchors)" [E-ANK boost-class-id]))
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_ExecutorIzAssetAuthority (executor:string ank-asset:string asset-fungibility:[bool])
        @doc "Enforces that <executor> IS the anchored asset's authority, mirroring -- never replacing \
            \ -- the CAP_ gate running alongside it. The authority differs by asset kind, and that \
            \ difference is why this is one helper rather than three inline checks: a DPTF has exactly \
            \ ONE authority (its owner, resolved through F|/R| to the core token), a collectable has \
            \ TWO (owner OR creator) and is therefore a DISJUNCTION, not a value. Band 1's usual \
            \ prescription -- 'enforce executor equals the derived owner' -- has no single owner to \
            \ equal in the collectable case, which is exactly why MTX-AQP's C_2|SweepRevokeAnchor \
            \ could not be done inline and waited for this."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (enforce
                (if (= asset-fungibility [true true])
                    (= executor (ref-DPTF::UR_Konto (URCv_CoreDptf ank-asset)))
                    (let
                        (
                            (son:bool (= asset-fungibility [false true]))
                        )
                        (or (= executor (ref-DPDC::UR_OwnerKonto ank-asset son))
                            (= executor (ref-DPDC::UR_CreatorKonto ank-asset son)))
                    )
                )
                (format "Executor {} is not an authority for anchored asset {}; authority is {}"
                    [executor ank-asset
                        (if (= asset-fungibility [true true])
                            [(ref-DPTF::UR_Konto (URCv_CoreDptf ank-asset))]
                            (let
                                (
                                    (son:bool (= asset-fungibility [false true]))
                                )
                                [(ref-DPDC::UR_OwnerKonto ank-asset son)
                                 (ref-DPDC::UR_CreatorKonto ank-asset son)]
                            )
                        )
                    ]
                )
            )
        )
    )
    (defun UEV_ExecutorIzAnchorAuthority (executor:string anchor-id:string)
        @doc "Anchor-level form of UEV_ExecutorIzAssetAuthority: resolves the anchored asset and its \
            \ fungibility from the anchor row, then defers. This is the shape MTX-AQP needs for \
            \ C_2|SweepRevokeAnchor, which holds an anchor-id and no asset."
        (UEV_ExecutorIzAssetAuthority executor
            (UR_ANK|AnchoredAsset anchor-id) (UR_ANK|Fungibility anchor-id))
    )
    (defun UEV_AssetAnchorCap (ank-asset:string)
        @doc "Validates asset 49-anchor cap. Used when acnoi=true (BoostClass is new)."
        (let
            (
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_LiveAnchor (anchor-id:string)
        @doc "Validates anchor exists and is active."
        (let
            (
                (iz-anchor-active:bool (UR_ANK|State anchor-id))
            )
            (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))
        )
    )
    ;; WU_UserBoost|AggregatePromile — not used: mutates via WW_UserBoost (full row).
    ;; WU_UserBoost|Account — select key; WU not needed.
    ;; WU_UserBoost|BoostClassId — select key; WU not needed.
    (defun CAP_Owner (anchor-id:string)
        @doc "Enforces Anchor Ownership; This is computed as: \
        \ 1] For DPTFs Computed via <CAP_TF|Owner> \
        \ 2] For DPSFs and DPNFs can be either its Owner or Creator"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_ANK|Fungibility anchor-id))
            )
            (if (= ank-fungibility [true true])
                (CAP_TF|Owner ank-asset)
                (if (= ank-fungibility [false true])
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset true)
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset false)
                )
            )
        )
    )
    (defun CAP_TF|Owner (dptf-id:string)
        @doc "Enforces dptf-id Ownership, as underlying Dptf-Based Anchor Ownership \
        \ 3 DPTF variants can exist as underlying anchored asset: \
        \ 1] Pure DPTF      = Its Owner \
        \ 2] Frozen DPTF    = DPTF Parent Ownership \
        \ 3] Reserved DPTF  = DPTF Parent Ownership \
        \ \
        \ \
        \ 4] LP DPTF        = Cannot exist as underlaying DPTF-Based Anchor \
        \ 5] Frozen LP DPTF = Cannot exist as underlaying DPTF-Based Anchor"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (owner:string (ref-DPTF::UR_Konto (URCv_CoreDptf dptf-id)))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Anchor:string
        (anchor-id:string row:object{AcquisitionSchemasV1.ANK|Schema})
        @doc "Insert ANK|T|Anchor full row (issue only)."
        (require-capability (SECURE))
        (insert ANK|T|Anchor anchor-id row)
    )
    ;; WW_Anchor — not used: issue path is WI_Anchor; revoke uses WU_Anchor|State.
    ;; WU_Anchor|AnchoredAsset — not mutable [.]
    ;; WU_Anchor|Fungibility — not mutable [.]
    ;; WU_Anchor|BoostClassId — not mutable [.]
    ;; WU_Anchor|Precision — not mutable [.]
    (defun WU_Anchor|State:string
        (anchor-id:string ank-active:bool)
        @doc "Update ank-active on ANK|T|Anchor."
        (require-capability (SECURE))
        (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
    )
    (defun WU_BC|AddScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Add score-id to the BoostClass reverse-index set (idempotent — no-op if already present). Upsert. \
            \ H4 reverse index + #9 revoke lock (locked while the set is non-empty)."
        (require-capability (SECURE))
        (let
            (
                (sl:[string] (UR_BC|ScoreLinks boost-class-id))
            )
            (write ANK|T|BoostClassScoreLinks boost-class-id
                {"score-links"     : (if (contains score-id sl) sl (+ sl [score-id]))
                ,"boost-class-id"  : boost-class-id})
        )
    )
    (defun WU_BC|RemoveScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Remove score-id from the BoostClass reverse-index set (a score re-pointed/unlinked its \
            \ boost-class-link AWAY — M4 #13 / sweep unlink). Upsert. Releases the class's revoke lock once empty."
        (require-capability (SECURE))
        (write ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links"     : (filter (lambda (s:string) (!= s score-id)) (UR_BC|ScoreLinks boost-class-id))
            ,"boost-class-id"  : boost-class-id})
    )
    ;; WU_Anchor|Promile — not mutable [.]
    ;; WU_Anchor|TFAmount — not mutable [.]
    ;; WU_Anchor|SFNonce — not mutable [.]
    ;; WU_Anchor|NFTraitKey — not mutable [.]
    ;; WU_Anchor|NFTraitValue — not mutable [.]
    ;; WU_Anchor|NFNonceClass — not mutable [.]
    ;; WU_Anchor|ID — select key; WU not needed.
    ;;
    (defun WI_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
        @doc "Insert ANK|T|BoostClass full row (inline issue when acnoi)."
        (require-capability (SECURE))
        (insert ANK|T|BoostClass boost-class-id row)
    )
    (defun WW_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
        @doc "Upsert full ANK|T|BoostClass row (bookkeeping add/remove anchor slots)."
        (require-capability (SECURE))
        (write ANK|T|BoostClass boost-class-id row)
    )
    ;; WU_BoostClass|Primary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Secondary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Tertiary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quaternary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quinary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Senary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Septenary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Anchors — not used: mutates via WW_BoostClass (full row).
    (defun WU_BoostClass|Active:string
        (boost-class-id:string class-active:bool)
        @doc "Update class-active on ANK|T|BoostClass."
        (require-capability (SECURE))
        (update ANK|T|BoostClass boost-class-id {"class-active": class-active})
    )
    ;; WU_BoostClass|ID — select key; WU not needed.
    ;;
    ;; WI_AssetAnchors — not used: first row touch is WW_AssetAnchors (upsert path).
    (defun WW_AssetAnchors:string
        (asset-id:string row:object{AcquisitionSchemasV1.ANK|AssetAnchors})
        @doc "Upsert full ANK|T|AssetAnchors row (place/remove anchor in groups)."
        (require-capability (SECURE))
        (write ANK|T|AssetAnchors asset-id row)
    )
    ;; WU_AssetAnchors|GroupPrimary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSecondary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupTertiary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuaternary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuinary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSeptenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AnchorsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AssetId — select key; WU not needed.
    ;;
    ;; WI_Anchors — not used: first row touch is WW_Anchors (upsert path).
    (defun WW_Anchors:string
        (account:string anchor-id:string promile:decimal)
        @doc "Upsert user promile on ANK|T|Anchors for (account, anchor-id). L6 #18: floors the stored promile at \
            \ 0 — this is the SOLE write chokepoint for per-anchor user promile (every TF/SF/NF, incremental AND \
            \ absolute, path routes here), so an incremental delta can never persist a negative. The trigger is \
            \ real and outside AQP's control (NFT metadata on a trait-anchor is mutable at the DPDC layer, even by \
            \ module admin), so AQP guards its own accounting at its boundary. The aggregate (Σ of these) is then \
            \ non-negative too; the …PromileAbsolute resync recomputes the true value. Floor, not enforce — a hard \
            \ abort would strand a staker's assets; the clamp lets unstake always succeed."
        (require-capability (SECURE))
        (write ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor (if (< promile 0.0) 0.0 promile) account anchor-id)
        )
    )
    ;; WU_Anchors|Promile — not used: mutates via WW_Anchors (full row).
    ;; WU_Anchors|Account — select key; WU not needed.
    ;; WU_Anchors|ID — select key; WU not needed.
    ;;
    ;; WI_UserBoost — not used: first row touch is WW_UserBoost (upsert path).
    (defun WW_UserBoost:string
        (account:string boost-class-id:string aggregate-promile:decimal)
        @doc "Upsert aggregate-promile on ANK|T|UserBoost."
        (require-capability (SECURE))
        (write ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost aggregate-promile account boost-class-id)
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* … ; XE_* / XB_* → XI_1|* (depth 1) → XI_2|* …
    ;; Blocks: map first, then functions in map order (entry → children → shared leaves).
    ;;
    ;; --- Block A · C_Issue*Anchor ---
    ;;   C_Issue*Anchor
    ;;     ├ XI_IssueBoostClass (optional)
    ;;     └ XI_IssueAnchor
    ;;          └ XI_PlaceAnchorInBookkeeping
    ;; --- Block B · C_RevokeAnchor ---
    ;;   C_RevokeAnchor → XI_RevokeAnchorBookkeeping
    ;; --- Block C · TF user promile (FVT phase 2.2 backward) ---
    ;;   XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ XI_1|UpdateTrueFungibleUserAnchorValues
    ;; --- Block D · SF user promile ---
    ;;   XE_UpdateSemiFungibleUserAnchorValues
    ;;     └ XI_1|UpdateSemiFungibleUserAnchorValues
    ;; --- Block E · NF user promile ---
    ;;   XE_UpdateNonFungibleUserAnchorValues
    ;;     └ XI_1|UpdateNonFungibleUserAnchorValues
    ;; --- Block F · shared leaf ---
    ;;   XI_2|RecomputeAffectedBoostAggregates (TF / SF / NF / resync)
    ;;
    ;;Protection: Class 1 — Innate protection offered by WI_BoostClass
    (defun XI_IssueBoostClass:string
        (boost-class-name:string class-owner:string)
        @doc "Internal (C_Issue*Anchor · depth 0]): create BoostClass inline when acnoi; returns boost-class-id. \
            \ `class-owner` is recorded so only the creator may later attach anchors (2026-09-19)."
        ;; SECURE: granted by WI_BoostClass (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (boost-class-id:string (ref-U|DALOS::UDC_Makeid boost-class-name))
            )
            (WI_BoostClass boost-class-id
                (UDC_BoostClass BAR BAR BAR BAR BAR BAR BAR 0 true boost-class-id class-owner)
            )
            boost-class-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WI_Anchor
    (defun XI_IssueAnchor:string
        (
            ank-name:string ank-asset:string ank-fungibility:[bool] boost-class-id:string ank-precision:integer ank-promile:decimal
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
        )
        @doc "Internal (C_Issue*Anchor · depth 0]): insert ANK|T|Anchor row; returns anchor-id."
        ;; SECURE: granted by WI_Anchor (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (anchor-id:string (ref-U|DALOS::UDC_Makeid ank-name))
            )
            (WI_Anchor anchor-id
                (UDC_ANK|Schema
                    ank-asset ank-fungibility boost-class-id ank-precision true ank-promile
                    dptf-amount dpsf-nonce dpnf-trait-key dpnf-trait-value dpnf-nonce-class anchor-id
                )
            )
            anchor-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BoostClass, WW_AssetAnchors
    (defun XI_PlaceAnchorInBookkeeping (anchor-id:string asset-id:string boost-class-id:string)
        @doc "Internal (C_Issue*Anchor · depth 1]): place anchor in BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithAddedAnchor bc anchor-id))
            (WW_AssetAnchors asset-id (UDC_AA|PlaceAnchor aa anchor-id))
        )
    )
    ;;
    ;; --- Block B · C_RevokeAnchor ---
    ;;Protection: Class 1 — Innate protection offered by C_RevokeAnchor, WW_BoostClass,
    ;;Protection:          WW_AssetAnchors
    (defun XI_RevokeAnchorBookkeeping (anchor-id:string)
        @doc "Internal (C_RevokeAnchor · depth 0]): remove anchor from BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (boost-class-id:string (UR_ANK|BoostClassId anchor-id))
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithRemovedAnchor bc anchor-id))
            (WW_AssetAnchors ank-asset (UDC_AA|RemoveAnchor aa anchor-id))
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateTrueFungibleUserAnchorValues
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Internal (XE_Update*TF · depth 1]): rewrite user promile for each live TF anchor on dptf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPTF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_TrueFungibleAnchorPromile aid total-dptf-amount))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Internal (XE_Update*SF · depth 1]): rewrite user promile for each live SF anchor on dpsf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPSF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_SemiFungibleAnchorPromile account aid nonces nonce-amounts direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Internal (XE_Update*NF · depth 1]): rewrite user promile for each live NF anchor on dpnf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPNF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_NonFungibleAnchorPromile account aid nonces direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Internal (XE_ResyncSemiFungible* · depth 1]): absolute promile per live SF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_SemiFungibleAnchorPromileAbsolute aid nonces nonce-amounts)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer])
        @doc "Internal (XE_ResyncNonFungible* · depth 1]): absolute promile per live NF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_NonFungibleAnchorPromileAbsolute aid nonces)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block F · shared leaf ---
    ;;Protection: Class 1 — Innate protection offered by WW_UserBoost
    (defun XI_2|RecomputeAffectedBoostAggregates (account:string boost-class-ids:[string])
        @doc "Internal (user promile update · depth 2 · shared leaf]): recompute ANK|T|UserBoost aggregate-promile per boost-class-id."
        ;; SECURE: granted by WW_UserBoost (underlying W_).
        ;; map: distinct boost-class-ids touched by anchor promile refresh
        (map
            (lambda (bcid:string)
                (let
                    (
                        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data bcid))
                        (n:integer (at "anchors" bc))
                    )
                    (if (<= n 0)
                        ;; class has NO anchors left ⇒ aggregate-promile is 0. Must WRITE it (not skip) — the sweep
                        ;; can remove the LAST anchor from a class, and a skipped write would leave a stale nonzero
                        ;; aggregate (surfaced by the re-score sweep proof). Normal stake/unstake never hits n<=0.
                        (WW_UserBoost account bcid 0.0)
                        (let
                            (
                                (agg:decimal
                                    ;; fold: anchor slots 0..n-1 in this BoostClass (sum user promile)
                                    (fold
                                        (lambda (acc:decimal idx:integer)
                                            (let
                                                (
                                                    (aid:string (URC_BC|AnchorIdAtSlot bc idx))
                                                )
                                                (if (= aid BAR)
                                                    acc
                                                    (+ acc (UR_ANK-U|Promile account aid))
                                                )
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- n 1))
                                    )
                                )
                            )
                            (WW_UserBoost account bcid agg)
                        )
                    )
                )
            )
            boost-class-ids
        )
    )
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP-REVOKE
    (defun XE_SweepRevokeAnchor:string
        (anchor-id:string)
        @doc "Forward (re-score sweep terminal · MTX-AQP): revoke an EMPLOYED anchor after the sweep has refreshed \
            \ every affected holder — set state false + remove it from its BoostClass/AssetAnchors, SKIPPING the #9 \
            \ score-link lock (which C_RevokeAnchor enforces for UNemployed anchors). The reverse-index set is \
            \ UNCHANGED: scores keep employing the class (via its other anchors, or an emptied class contributing \
            \ 0 boost). No IGNIS (the sweep defpact bills). P|UEV_IMC + ANK|XE>SWEEP-REVOKE (liveness + owner + SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP-REVOKE anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
        )
        anchor-id
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_BumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink): register score-id in the BoostClass reverse-index set, \
            \ locking revoke of any anchor in this class while the set is non-empty (H4 #9 lock + the sweep's \
            \ enumerable index). Idempotent. P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|AddScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_UnbumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink re-point/unlink): remove score-id from the BoostClass \
            \ reverse-index set (M4 #13 / sweep unlink). Releases the class's revoke lock once the set empties. \
            \ P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|RemoveScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP
    (defun XE_RecomputeUserBoostAggregates:string
        (account:string boost-class-ids:[string])
        @doc "Forward (re-score sweep): refold this user's aggregate-promile for the given boost-classes from the \
            \ anchors CURRENTLY in each class. After a sweep removes (or re-prices) an anchor GLOBALLY, this \
            \ re-derives each holder's stored aggregate-promile so it no longer reflects the retired anchor — the \
            \ DEEPER recompute (the deb refresh alone assumes the aggregate is correct). NO fund movement; the \
            \ sweep defpact bills IGNIS. P|UEV_IMC + ANK|XE>SWEEP (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP)
            (XI_2|RecomputeAffectedBoostAggregates account boost-class-ids)
            (format "ANK sweep: refolded {} boost aggregate(s) for {}" [(length boost-class-ids) account])
        )
    )
    ;;
    ;; --- Block C · TF user promile ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Backward (FVT::XI_RefreshTrueFungibleStakeAnchors / C_Sync*): P|UEV_IMC + XI_1|UpdateTrueFungibleUserAnchorValues \
            \ when n_live > 0; IGNIS = ignis|small × n_live (live anchors on dptf-id). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPTF account dptf-id total-dptf-amount)
                    (XI_1|UpdateTrueFungibleUserAnchorValues account dptf-id total-dptf-amount)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dptf-id]
            )
        )
    )
    ;;
    ;; --- Block D · SF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPSF
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates user promile for each live SF anchor on dpsf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
            (XI_1|UpdateSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts direction)
        )
    )
    ;;
    ;; --- Block E · NF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPNF
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Updates user promile for each live NF anchor on dpnf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
            (XI_1|UpdateNonFungibleUserAnchorValues account dpnf-id nonces direction)
        )
    )
    ;;
    ;; --- Block D′ · SF resync (C_SyncCollectableAnchors · son=true) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite SF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
                    (XI_1|ResyncSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpsf-id]
            )
        )
    )
    ;;
    ;; --- Block E′ · NF resync (C_SyncCollectableAnchors · son=false) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite NF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
                    (XI_1|ResyncNonFungibleUserAnchorValues account dpnf-id nonces)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpnf-id]
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;;
    (defun C_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator}
        (boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (P|UEV_IMC)
        (with-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id)
            (WU_BoostClass|Active boost-class-id false)
            (URCi_RevokeBoostClass)
        )
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [true true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility boost-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dptf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueTrueFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpsf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueSemiFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 dpnf-trait-key dpnf-trait-value -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 BAR BAR dpnf-nonce-class
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleSetAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator}
        (anchor-id:string)
        @doc "Revokes an anchor and updates BoostClass and AssetAnchors bookkeeping."
        (P|UEV_IMC)
        (with-capability (ANK|C>REVOKE anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
            (URCi_RevokeAnchor)
        )
    )

)



;;

;; --- tables for 01_ANK.pact (8 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)
(create-table ANK|T|Anchor)
(create-table ANK|T|BoostClass)
(create-table ANK|T|AssetAnchors)
(create-table ANK|T|BoostClassScoreLinks)
(create-table ANK|T|Anchors)
(create-table ANK|T|UserBoost)

