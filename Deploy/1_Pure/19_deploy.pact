;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 19 of 19
;; This is STEP 19 of 20 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-18 must have run first, including the init steps between deploys.
;; 4 module(s), 202,253 gas measured in the REPL gas model, 172,288 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;   2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;   1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;   2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SaleSnakesV2




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
    ;;  [UR]
    ;;
    (defun UR_AssetID ())
    (defun UR_DollarSharePrice:decimal ())
    (defun UR_NonceSaleAvailability:integer (nonce:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_NonceValueInShares:integer (nonce:integer))
    (defun URC_ShareCosts:object{DemiourgosLaunchpadV2.Costs} ())
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer))
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer))
    (defun URC_Acquire:[string] (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool))
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AcquisitionNonce (nonce:integer))
    (defun CAP_Acquire (buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A+C]
    ;;
    (defun A_UpdateSharePrice (price:decimal))
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-SNAKES GOV
    @doc "Module defining the Sale Mechanics for Demiourgos Share Holder Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleSnakesV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SNAKES                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SNAKES_ADMIN)))
    (defcap GOV|SNAKES_ADMIN ()                         (enforce-guard GOV|MD_SNAKES))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|SNAKES|CALLER ()
        true
    )
    (defcap P|SNAKES|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SNAKES|CALLER))
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
        (with-capability (GOV|SNAKES_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|SNAKES_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|SNAKES|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "SNAKES|RemoteGov"
                (create-capability-guard (P|SNAKES|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst SNAKES|INFO                               (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema SNAKES|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable SNAKES|T|Properties:{SNAKES|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SNAKES|C>INITIALISE ()
        @event
        (compose-capability (GOV|SNAKES_ADMIN))
    )
    (defcap SNAKES|ACQUIRE (nonce:integer amount:integer)
        @event
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            ;;nonce validity FIRST, so an unsellable nonce is named as such rather than reported as
            ;;a stock shortage it can never recover from. Order matters: UR_NonceSaleAvailability
            ;;answers 0 for an unknown nonce, so the supply check below would otherwise absorb it.
            (UEV_AcquisitionNonce nonce)
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|SNAKES|CALLER))
            (compose-capability (P|SNAKES|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Shareholders"]))
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
    (defun UR_AssetID ()
        (at "asset-id" (read SNAKES|T|Properties SNAKES|INFO ["asset-id"]))
    )
    (defun UR_DollarSharePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "price-per-share-in-dollars" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_NonceValueInShares:integer (nonce:integer)
        (if (= nonce 1)
            1
            (let
                (
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    (asset:string (UR_AssetID))
                    (tier:integer (- nonce 1))
                )
                (ref-EQUITY::URC_SingleSharePerMillions asset tier)
            )
        )
    )
    (defun URC_ShareCosts:object{DemiourgosLaunchpadV2.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (share-pid:decimal (UR_DollarSharePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                share-pid
                (floor (/ share-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (share-costs:object{DemiourgosLaunchpadV2.Costs} (URC_ShareCosts))
                (nonce-value-in-shares:integer (URC_NonceValueInShares nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" share-costs) (dec nonce-value-in-shares)) 2)
                (floor (* (at "wstoa" share-costs) (dec nonce-value-in-shares)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer. Amount-independent \
            \ deposit; the transfer cost depends only on the collectable fee class."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the SNAKES|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared in \
            \ the description as the good bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.SNAKES|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AcquisitionNonce (nonce:integer)
        @doc "The nonces this pad actually sells: 1 = Pure Shares, 2-8 = Tier 1-7 PackageShares. \
            \ ADDED 2026-09-14, mirroring the Custodians twin's UEV_AcquisitionNonce, which had it \
            \ from the start. Without it a nonexistent nonce was refused by the SUPPLY cap instead \
            \ -- UR_NonceSaleAvailability returns 0 for an unknown nonce, so any amount exceeds it \
            \ -- and reported \"Insufficient Assets for Acquisiton!\". That is actively misleading, \
            \ not merely terse: the implied remedy is to wait for restocking, which can NEVER work \
            \ for a nonce the pad does not sell, and the text was identical to a genuine over-buy, \
            \ so the two were indistinguishable to a client."
        (let
            (
                (acquisition-nonces:[integer] (enumerate 1 8))
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Snakes Acquisition Nonce")
        )
    )
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateSharePrice (price:decimal)
        @doc "Updates the Share Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|SNAKES|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|SNAKES|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                (ref-DEMIPAD::A_DefinePrice asset
                    {"price-per-share-in-dollars" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Nonce 1 are Pure Shares, Nonces 2-8 are Tier 1-7 PackageShares \
            \ When <iz-native> is set to true, Native STOA is used for buy, which must be wrapped to WSTOA \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        (with-capability (SNAKES|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV2} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 02_Snakes.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SNAKES|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact =======
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SaleCustodiansV2




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
    ;;
    ;;  [UC]
    ;;
    (defun UC_NonceQuintessence:integer (nonce:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_AssetID ())
    (defun UR_QuitessencePrice:decimal ())
    (defun UR_NonceSaleAvailability:integer (nonce:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_QuintessenceCosts:object{DemiourgosLaunchpadV2.Costs} ())
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer))
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer))
    (defun URC_Acquire:[string] (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool))
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string nonce:integer amount:integer iz-native:bool))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_AcquisitionNonce (nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A+C]
    ;;
    (defun A_UpdateQuintessencePrice (price:decimal))
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-CUSTODIANS GOV
    @doc "Module defining the Sale Mechanics for Ouronet Custodians Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleCustodiansV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CUSTODIANS                         (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CUSTODIANS_ADMIN)))
    (defcap GOV|CUSTODIANS_ADMIN ()                     (enforce-guard GOV|MD_CUSTODIANS))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|CUSTODIANS|CALLER ()
        true
    )
    (defcap P|CUSTODIANS|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|CUSTODIANS|CALLER))
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|CUSTODIANS|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "CUSTODIANS|RemoteGov"
                (create-capability-guard (P|CUSTODIANS|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst CUSTODIANS|INFO                           (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema CUSTODIANS|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable CUSTODIANS|T|Properties:{CUSTODIANS|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap CUSTODIANS|C>INITIALISE ()
        @event
        (compose-capability (GOV|CUSTODIANS_ADMIN))
    )
    (defcap CUSTODIANS|ACQUIRE (nonce:integer amount:integer)
        @event
        ;;#10M: nonce validation is enforced HERE (was buried in the UR_ read, which must not enforce).
        (UEV_AcquisitionNonce nonce)
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|CUSTODIANS|CALLER))
            (compose-capability (P|CUSTODIANS|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Custodians"]))
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
    (defun UC_NonceQuintessence:integer (nonce:integer)
        @doc "Pure nonce->quintessence mapping for the three Custodian fragment nonces: \
            \ -1 (Bronze) = 1, -2 (Silver) = 10, -3 (Golden) = 100. No enforce: nonce validity \
            \ is enforced by the CUSTODIANS|ACQUIRE cap on the mutation path (UEV_AcquisitionNonce)."
        (if (= nonce -1)
            1
            (if (= nonce -2)
                10
                100
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_AssetID ()
        (at "asset-id" (read CUSTODIANS|T|Properties CUSTODIANS|INFO ["asset-id"]))
    )
    (defun UR_QuitessencePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "quintessence-price" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        ;;#10M: pure DPDC supply read (no enforce — matches the Snakes twin). Nonce validity is enforced
        ;;      by the CUSTODIANS|ACQUIRE cap on the mutation path.
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;#4H: was the non-existent GOV|LAUNCHPAD|SC_NAME → the real member (matches Snakes twin)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_QuintessenceCosts:object{DemiourgosLaunchpadV2.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (q-pid:decimal (UR_QuitessencePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                q-pid
                (floor (/ q-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (q-costs:object{DemiourgosLaunchpadV2.Costs} (URC_QuintessenceCosts))
                (nonce-value-in-quintessence:integer (UC_NonceQuintessence nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" q-costs) (dec nonce-value-in-quintessence)) 2)
                (floor (* (at "wstoa" q-costs) (dec nonce-value-in-quintessence)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the CUSTODIANS|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared as \
            \ the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.CUSTODIANS|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    (defun UEV_AcquisitionNonce (nonce:integer)
        (let
            (
                (acquisition-nonces:[integer] [-3 -2 -1])
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Custodian Acquisition Nonce")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: GOV|CUSTODIANS_ADMIN
    (defun XI_I|AssetId (asset-id:string)
        (require-capability (GOV|CUSTODIANS_ADMIN))
        (insert CUSTODIANS|T|Properties CUSTODIANS|INFO
            {"asset-id"     : asset-id}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateQuintessencePrice (price:decimal)
        @doc "Updates the Quintessence Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|CUSTODIANS|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|CUSTODIANS|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                (ref-DEMIPAD::A_DefinePrice asset
                    {"quintessence-price" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Only Nonce -3 -2 -1 can be used, and these are Bronze/Silver/Golden Fragment Nonces. \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        ;;#3H: open CUSTODIANS|ACQUIRE (was missing — the twin Snakes wraps SNAKES|ACQUIRE). This restores
        ;;    the per-nonce supply cap (enforce amount <= available) + composes the P|CUSTODIANS caller
        ;;    policies the downstream DPDC-T transfer needs, and fires the @event.
        (with-capability (CUSTODIANS|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV2} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 03_Custodians.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table CUSTODIANS|T|Properties)

;; ===== 1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface InfoTwoV2
    @doc "Exposes the Stage-2 INFO (ClientInfo preview) surface — DPDC collectables, \
        \ DEMIPAD launchpad, EQUITY, AQP. Each function wraps a core URCi cost reader."

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
    ;;  [DPDC collectables]
    (defun INFO_DPSF|Make:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun INFO_DPNF|Make:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer))
    ;;  [DEMIPAD] — sovereign launchpad
    (defun INFO_DEMIPAD|Deposit:object{OuronetInfoV2.ClientInfo} (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal))
    (defun INFO_DEMIPAD|Withdraw:object{OuronetInfoV2.ClientInfo} (patron:string asset-id:string type:integer destination:string))
    (defun INFO_DEMIPAD|FuelTrueFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string amount:decimal))
    (defun INFO_DEMIPAD|RetrieveTrueFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string amount:decimal))
    (defun INFO_DEMIPAD|FuelOrtoFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer]))
    (defun INFO_DEMIPAD|RetrieveOrtoFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer]))
    (defun INFO_DEMIPAD|FuelSemiFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun INFO_DEMIPAD|RetrieveSemiFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun INFO_DEMIPAD|FuelNonFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun INFO_DEMIPAD|RetrieveNonFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    ;;  [EQUITY]
    (defun INFO_EQUITY|IssueCompany:object{OuronetInfoV2.ClientInfo} (patron:string creator-account:string collection-name:string))
    (defun INFO_EQUITY|MorphEquity:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
;;INFO_LIQUID|UnwrapStoa
;;INFO_LIQUID|WrapStoa
;;INFO_LIQUID|UnwrapUrStoa
(module INFO-TWO GOV
    @doc "INFO-TWO (InfoTwoV2) is the read-only Stage-2 UI info module exposing INFO_ \
        \ preview functions returning ClientInfo objects (description, result, IGNIS/STOA \
        \ cost) for Stage-2 client ops: DPDC collectables (roles, management, nonce/set \
        \ updates, wipes, burns, transfers, sets), the DEMIPAD sovereign launchpad, EQUITY, \
        \ and AQP. Each preview wraps the corresponding core module's URCi_ cost reader via \
        \ shared helpers; it holds no tables and does no writes."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;(implements InfoTwoV2)
    ;;
    (defconst GOV|MD_INFO|DPTF                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|INFO|DPTF_ADMIN)))
    (defcap GOV|INFO|DPTF_ADMIN ()                      (enforce-guard GOV|MD_INFO|DPTF))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
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
    ;;
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
    ;;
    ;;
    ;;  [SIP|URC] - Simple Ignis Price >> dependent on a single trigger
    ;;
    ;;
    ;;  [SKP|URC] - Simple Stoa Price 
    ;;
    ;;
    ;;  [INFO] - Informational URC Functions
    ;;
    ;;
    ;;  [DPDC roles/toggles] — DPDC-R (son = false for DPNF, true for DPSF)
    (defun INFO_DPDC-R|Toggle:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string son:bool label:string ico:object{IgnisCollectorV3.OutputCumulator} toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]) (format "Operation: Removes {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]))]
                [(if toggle (format "{} Role added for {} to {}" [label id sa]) (format "{} Role removed for {} to {}" [label id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])
        ))
    (defun INFO_DPNF|ToggleBurnRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Burn" (r::URCi_ToggleBurnRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleBurnRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Burn" (r::URCi_ToggleBurnRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleExemptionRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Fee-Exemption" (r::URCi_ToggleExemptionRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleExemptionRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Fee-Exemption" (r::URCi_ToggleExemptionRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleFreezeAccount:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Freeze" (r::URCi_ToggleFreezeAccount id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleFreezeAccount:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Freeze" (r::URCi_ToggleFreezeAccount id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleModifyCreatorRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleModifyCreatorRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleModifyRoyaltiesRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleModifyRoyaltiesRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleTransferRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Transfer" (r::URCi_ToggleTransferRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleTransferRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Transfer" (r::URCi_ToggleTransferRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleUpdateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Update" (r::URCi_ToggleUpdateRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleUpdateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Update" (r::URCi_ToggleUpdateRole id true) toggle)
        )
    )
    (defun INFO_DPSF|ToggleAddQuantityRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Add-Quantity" (r::URCi_ToggleAddQuantityRole id) toggle)
        )
    )
    ;;  [DPDC role moves] — DPDC-R Move* (patron id new-account)
    (defun INFO_DPDC-R|Move:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string son:bool label:string ico:object{IgnisCollectorV3.OutputCumulator})
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Moves the {} Role of {} {} to {}" [label (if son "SFT" "NFT") id sa])]
                [(format "{} Role of {} succesfully moved to {}" [label id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|MoveCreateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Create" (r::URCi_MoveCreateRole id false))
        )
    )
    (defun INFO_DPSF|MoveCreateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Create" (r::URCi_MoveCreateRole id true))
        )
    )
    (defun INFO_DPNF|MoveRecreateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Recreate" (r::URCi_MoveRecreateRole id false))
        )
    )
    (defun INFO_DPSF|MoveRecreateRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Recreate" (r::URCi_MoveRecreateRole id true))
        )
    )
    (defun INFO_DPNF|MoveSetUriRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Set-URI" (r::URCi_MoveSetUriRole id false))
        )
    )
    (defun INFO_DPSF|MoveSetUriRole:object{OuronetInfoV2.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV2} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Set-URI" (r::URCi_MoveSetUriRole id true))
        )
    )
    ;;  [DPDC management] — DPDC-MNG Control / Pause / Respawn / AddQuantity
    (defun INFO_DPDC-MNG|Simple:object{OuronetInfoV2.ClientInfo} (patron:string desc:string result:string ico:object{IgnisCollectorV3.OutputCumulator})
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo [desc] [result]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|Control:object{OuronetInfoV2.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of NFT {}" [id]) (format "Succesfully controlled Properties of NFT {}" [id]) (r::URCi_Control id false))
        )
    )
    (defun INFO_DPSF|Control:object{OuronetInfoV2.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of SFT {}" [id]) (format "Succesfully controlled Properties of SFT {}" [id]) (r::URCi_Control id true))
        )
    )
    (defun INFO_DPNF|TogglePause:object{OuronetInfoV2.ClientInfo} (patron:string id:string toggle:bool)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses NFT {}" [id]) (format "Operation: Unpauses NFT {}" [id])) (format "NFT {} pause toggled" [id]) (r::URCi_TogglePause id false))
        )
    )
    (defun INFO_DPSF|TogglePause:object{OuronetInfoV2.ClientInfo} (patron:string id:string toggle:bool)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses SFT {}" [id]) (format "Operation: Unpauses SFT {}" [id])) (format "SFT {} pause toggled" [id]) (r::URCi_TogglePause id true))
        )
    )
    (defun INFO_DPNF|Respawn:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Respawns NFT {} Nonce {}" [id nonce]) (format "Succesfully respawned NFT {} Nonce {}" [id nonce]) (r::URCi_RespawnNFT id))
        )
    )
    (defun INFO_DPSF|AddQuantity:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Adds {} quantity to SFT {} Nonce {}" [amount id nonce]) (format "Succesfully added {} quantity to SFT {} Nonce {}" [amount id nonce]) (r::URCi_AddQuantity id))
        )
    )
    ;;  [DPDC updates] — DPDC-N single-field (URCi_UpdateNonceField) + bulk (URCi_UpdateNonces)
    (defun INFO_DPDC-N|Field:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string son:bool label:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (r:module{DpdcNonceV2} DPDC-N)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates the {} of {} {}" [label (if son "SFT" "NFT") id])]
                [(format "{} of {} {} succesfully updated" [label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonceField account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPDC-N|Bulk:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string son:bool label:string count:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (r:module{DpdcNonceV2} DPDC-N)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates {} {} of {} {}" [count label (if son "SFT" "NFT") id])]
                [(format "{} {} of {} {} succesfully updated" [count label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonces account count)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    ;;   NF single-field
    (defun INFO_DPNF|UpdateNonceName:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account false (format "Name (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceDescription:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account false (format "Description (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Royalty (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceIgnisRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceURI:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account false (format "URI (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceMetaData:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account false (format "Meta-Data (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account false (format "Score (Nonce {})" [nonce])))
    (defun INFO_DPNF|RemoveNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (INFO_DPDC-N|Field patron id account false (format "Score-Removal (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateSetNonceName:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account false (format "Name (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceDescription:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account false (format "Description (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceURI:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account false (format "URI (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceMetaData:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account false (format "Meta-Data (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account false (format "Score (Set-Class {})" [set-class])))
    (defun INFO_DPNF|RemoveSetNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (INFO_DPDC-N|Field patron id account false (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   NF bulk
    (defun INFO_DPNF|UpdateNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account false "Nonce" 1))
    (defun INFO_DPNF|UpdateNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account false "Nonces" (length nonces)))
    (defun INFO_DPNF|UpdateSetNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account false "Set-Nonce" 1))
    (defun INFO_DPNF|UpdateSetNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account false "Set-Nonces" (length set-classes)))
    ;;   SF single-field
    (defun INFO_DPSF|UpdateNonceName:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account true (format "Name (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceDescription:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account true (format "Description (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Royalty (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceIgnisRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceURI:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account true (format "URI (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceMetaData:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account true (format "Meta-Data (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account true (format "Score (Nonce {})" [nonce])))
    (defun INFO_DPSF|RemoveNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (INFO_DPDC-N|Field patron id account true (format "Score-Removal (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateSetNonceName:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account true (format "Name (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceDescription:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account true (format "Description (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceURI:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account true (format "URI (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceMetaData:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account true (format "Meta-Data (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account true (format "Score (Set-Class {})" [set-class])))
    (defun INFO_DPSF|RemoveSetNonceScore:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (INFO_DPDC-N|Field patron id account true (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   SF bulk
    (defun INFO_DPSF|UpdateNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account true "Nonce" 1))
    (defun INFO_DPSF|UpdateNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account true "Nonces" (length nonces)))
    (defun INFO_DPSF|UpdateSetNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account true "Set-Nonce" 1))
    (defun INFO_DPSF|UpdateSetNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account true "Set-Nonces" (length set-classes)))
    ;;  [DPDC wipes] — DPDC-MNG single (URCi_WipeNonce/WipeSlim) + multi (URCi_WipeCumulator)
    (defun INFO_DPDC-MNG|WipeMulti:object{OuronetInfoV2.ClientInfo} (patron:string id:string son:bool obj:object{DpdcManagementV2.RemovableNonces} label:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (r:module{DpdcManagementV2} DPDC-MNG)
                (n:integer (length (at "r-nonces" obj)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: {} wipe of {} {} Nonces of {}" [label (if son "SFT" "NFT") n id])]
                [(format "{} wipe of {} {} Nonces of {} succesful" [label (if son "SFT" "NFT") n id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_WipeCumulator id son obj)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|WipeNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Wipes NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id false))
        )
    )
    (defun INFO_DPSF|WipeNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Wipes SFT {} Nonce {}" [id nonce]) (format "SFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id true))
        )
    )
    (defun INFO_DPSF|WipeNoncePartialy:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Partially wipes {} of SFT {} Nonce {}" [amount id nonce]) (format "Partially wiped {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_WipeSlim id))
        )
    )
    (defun INFO_DPNF|WipeHeavy:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::URHC_WipePure account id false) "Heavy")
        )
    )
    (defun INFO_DPSF|WipeHeavy:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::URHC_WipePure account id true) "Heavy")
        )
    )
    (defun INFO_DPNF|WipePure:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id false removable-nonces-obj "Pure"))
    (defun INFO_DPSF|WipePure:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id true removable-nonces-obj "Pure"))
    (defun INFO_DPNF|WipeClean:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
                (d:module{DpdcV2} DPDC)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id false nonces)) "Clean")
        )
    )
    (defun INFO_DPSF|WipeClean:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
                (d:module{DpdcV2} DPDC)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id true nonces)) "Clean")
        )
    )
    (defun INFO_DPNF|WipeDirty:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::URC_FilterAccountViableNonces account id false nonces) "Dirty")
        )
    )
    (defun INFO_DPSF|WipeDirty:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::URC_FilterAccountViableNonces account id true nonces) "Dirty")
        )
    )
    (defun INFO_DPNF|WipeSlice:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id false removable-nonces-obj "Hydra-Slice"))
    (defun INFO_DPSF|WipeSlice:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id true removable-nonces-obj "Hydra-Slice"))
    (defun INFO_DPDC-MNG|WipeFull:object{OuronetInfoV2.ClientInfo} (patron:string id:string son:bool plan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan})
        @doc "Hydra wipe FULL preview: grand-total IGNIS across the whole <URHC_BuildWipeSlicePlan> \
            \ plan = the sum of every slice's own ifp (mirrors the per-slice executor byte-for-byte)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (r:module{DpdcManagementV2} DPDC-MNG)
                (slice-count:integer (at "slice-count" plan))
                (total-ifp:decimal
                    (fold (+) 0.0
                        (map
                            (lambda
                                (slice:object{DpdcManagementV2.RemovableNonces})
                                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_WipeCumulator id son slice))
                            )
                            (at "slices" plan)
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Hydra wipe campaign of {} {} over {} slice tx(s)" [(if son "SFT" "NFT") id slice-count])]
                [(format "Hydra wipe campaign of {} {} over {} slice tx(s) succesful" [(if son "SFT" "NFT") id slice-count])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron total-ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [slice-count])
        ))
    (defun INFO_DPNF|WipeFull:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string plan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan}) (INFO_DPDC-MNG|WipeFull patron id false plan))
    (defun INFO_DPSF|WipeFull:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string plan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan}) (INFO_DPDC-MNG|WipeFull patron id true plan))
    ;;  [DPDC burn] — DPDC-MNG single-nonce burn
    (defun INFO_DPNF|Burn:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
                (d:module{DpdcV2} DPDC)
            )
            ;;STRUCTURAL check only -- the SAME function the exec's capability calls, so the two
            ;;refuse in one wording. Deliberately NOT the burn-ROLE check the exec also runs: a role
            ;;is transient state that changes between quote and submission, and family K's rule
            ;;(RT-K-002) is that previews validate what the caller cannot change, not what they can.
            ;;Without this the quote died on a raw DPNF|T|Properties read while the op refused
            ;;cleanly. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-004a>>.
            (d::UEV_id id false)
            (INFO_DPDC-MNG|Simple patron (format "Operation: Burns NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} burned" [id nonce]) (r::URCi_BurnNFT id))
        )
    )
    (defun INFO_DPSF|Burn:object{OuronetInfoV2.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV2} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Burns {} of SFT {} Nonce {}" [amount id nonce]) (format "Burned {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_BurnSFT id))
        )
    )
    ;;  [DPDC transfers] — DPDC-T Multi/Bulk transfer + Repurpose (DPDC-T / DPDC-F)
    (defun INFO_DPNF|TransferNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} of NFT {} Nonce {} to {}" [amount id nonce receiver]) (format "Transferred {} of NFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [[nonce]] [[amount]]))
        )
    )
    (defun INFO_DPSF|TransferNonce:object{OuronetInfoV2.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} of SFT {} Nonce {} to {}" [amount id nonce receiver]) (format "Transferred {} of SFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [[nonce]] [[amount]]))
        )
    )
    (defun INFO_DPNF|TransferNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of NFT {} to {}" [(length nonces) id receiver]) (format "Transferred {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [nonces] [amounts]))
        )
    )
    (defun INFO_DPSF|TransferNonces:object{OuronetInfoV2.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of SFT {} to {}" [(length nonces) id receiver]) (format "Transferred {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [nonces] [amounts]))
        )
    )
    (defun INFO_DPDC|MultiTransfer:object{OuronetInfoV2.ClientInfo} (patron:string ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Multi-transfers {} Collectable(s) to {}" [(length ids) receiver]) (format "Multi-transferred {} Collectable(s) to {}" [(length ids) receiver]) (t::URCi_MultiTransferCumulator ids sons sender receiver nonces-array amounts-array))
        )
    )
    (defun INFO_DPDC|BulkTransfer:object{OuronetInfoV2.ClientInfo} (patron:string id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers Collectable {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred Collectable {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id son sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPNF|BulkTransfer:object{OuronetInfoV2.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers NFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred NFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id false sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPSF|BulkTransfer:object{OuronetInfoV2.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers SFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred SFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id true sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPNF|Repurpose:object{OuronetInfoV2.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id false amounts))
        )
    )
    (defun INFO_DPSF|Repurpose:object{OuronetInfoV2.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (t:module{DpdcTransferV2} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id true amounts))
        )
    )
    (defun INFO_DPNF|RepurposeFragments:object{OuronetInfoV2.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of NFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id false amounts))
        )
    )
    (defun INFO_DPSF|RepurposeFragments:object{OuronetInfoV2.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of SFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id true amounts))
        )
    )
    ;;  [DPDC sets] — DpdcSetsV2 Make/Break/Define/Rename/Toggle
    (defun INFO_DPNF|Make:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes an NFT {} Set (class {}) from {} Nonces" [id set-class (length nonces)]) (format "NFT {} Set (class {}) made" [id set-class]) (s::URCi_MakeNonFungibleSet account id nonces))
        )
    )
    (defun INFO_DPSF|Make:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} SFT {} Sets (class {}) from {} Nonces" [how-many-sets id set-class (length nonces)]) (format "{} SFT {} Sets (class {}) made" [how-many-sets id set-class]) (s::URCi_MakeSemiFungibleSet account id nonces how-many-sets))
        )
    )
    (defun INFO_DPNF|Break:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Breaks NFT {} Set-Nonce {}" [id nonce]) (format "NFT {} Set-Nonce {} broken" [id nonce]) (s::URCi_BreakNonFungibleSet account id nonce))
        )
    )
    (defun INFO_DPSF|Break:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer how-many-sets:integer)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Breaks {} SFT {} Set-Nonce {}" [how-many-sets id nonce]) (format "{} SFT {} Set-Nonce {} broken" [how-many-sets id nonce]) (s::URCi_BreakSemiFungibleSet account id nonce how-many-sets))
        )
    )
    (defun INFO_DPNF|DefinePrimordialSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for NFT {}" [set-name id]) (format "Primordial Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id false))
        )
    )
    (defun INFO_DPSF|DefinePrimordialSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for SFT {}" [set-name id]) (format "Primordial Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id true))
        )
    )
    (defun INFO_DPNF|DefineCompositeSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for NFT {}" [set-name id]) (format "Composite Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineCompositeSet id false))
        )
    )
    (defun INFO_DPSF|DefineCompositeSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for SFT {}" [set-name id]) (format "Composite Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineCompositeSet id true))
        )
    )
    (defun INFO_DPNF|DefineHybridSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for NFT {}" [set-name id]) (format "Hybrid Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineHybridSet id false))
        )
    )
    (defun INFO_DPSF|DefineHybridSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for SFT {}" [set-name id]) (format "Hybrid Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineHybridSet id true))
        )
    )
    (defun INFO_DPNF|RenameSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer new-name:string)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Renames NFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "NFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id false))
        )
    )
    (defun INFO_DPSF|RenameSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer new-name:string)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Renames SFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "SFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id true))
        )
    )
    (defun INFO_DPNF|ToggleSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer toggle:bool)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Toggles NFT {} Set-Class {}" [id set-class]) (format "NFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id false))
        )
    )
    (defun INFO_DPSF|ToggleSet:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer toggle:bool)
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Toggles SFT {} Set-Class {}" [id set-class]) (format "SFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id true))
        )
    )
    ;;  [DPDC fragments] — DpdcFragmentsV2 (+ EnableSetClassFragmentation on DpdcSetsV2)
    (defun INFO_DPNF|EnableNonceFragmentation:object{OuronetInfoV2.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for NFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id false))
        )
    )
    (defun INFO_DPSF|EnableNonceFragmentation:object{OuronetInfoV2.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for SFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id true))
        )
    )
    (defun INFO_DPNF|EnableSetClassFragmentation:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for NFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id false))
        )
    )
    (defun INFO_DPSF|EnableSetClassFragmentation:object{OuronetInfoV2.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV2} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for SFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id true))
        )
    )
    (defun INFO_DPNF|MakeFragments:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id false))
        )
    )
    (defun INFO_DPSF|MakeFragments:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id true))
        )
    )
    (defun INFO_DPNF|MergeFragments:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id false))
        )
    )
    (defun INFO_DPSF|MergeFragments:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV2} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id true))
        )
    )
    ;;  [DPDC create/issue] — DpdcCreateV2 / DpdcIssueV2
    (defun INFO_DPNF|Create:object{OuronetInfoV2.ClientInfo} (patron:string id:string input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}])
        (let
            (
                (c:module{DpdcCreateV2} DPDC-C)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Creates {} new Nonces for NFT {}" [(length input-nonce-data) id]) (format "{} new Nonces created for NFT {}" [(length input-nonce-data) id]) (c::URCi_CreateNewNonces id false (make-list (length input-nonce-data) 1)))
        )
    )
    (defun INFO_DPSF|Create:object{OuronetInfoV2.ClientInfo} (patron:string id:string amount:[integer] input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}])
        (let
            (
                (c:module{DpdcCreateV2} DPDC-C)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Creates {} new Nonces for SFT {}" [(length input-nonce-data) id]) (format "{} new Nonces created for SFT {}" [(length input-nonce-data) id]) (c::URCi_CreateNewNonces id true amount))
        )
    )
    (defun INFO_DPDC-I|Issue:object{OuronetInfoV2.ClientInfo} (patron:string owner-account:string collection-name:string son:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (i:module{DpdcIssueV2} DPDC-I)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a new {} Collection '{}' for {}" [(if son "SemiFungible" "NonFungible") collection-name (ref-I|OURONET::OI|UC_ShortAccount owner-account)])]
                [(format "{} Collection '{}' succesfully issued" [(if son "SemiFungible" "NonFungible") collection-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (i::URCi_IssueDigitalCollection son owner-account)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (i::URCi_IssueCollectionStoa son)) [])
        ))
    (defun INFO_DPNF|Issue:object{OuronetInfoV2.ClientInfo} (patron:string owner-account:string creator-account:string collection-name:string collection-ticker:string can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool) (INFO_DPDC-I|Issue patron owner-account collection-name false))
    (defun INFO_DPSF|Issue:object{OuronetInfoV2.ClientInfo} (patron:string owner-account:string creator-account:string collection-name:string collection-ticker:string can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool) (INFO_DPDC-I|Issue patron owner-account collection-name true))
    ;;  [DPDC branding] — DpdcV2 UpdatePendingBranding (IGNIS) + UpgradeBranding (STOA)
    (defun INFO_DPNF|UpdatePendingBranding:object{OuronetInfoV2.ClientInfo} (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (let
            (
                (d:module{DpdcV2} DPDC)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Updates pending Branding of NFT {}" [entity-id]) (format "Pending Branding of NFT {} updated" [entity-id]) (d::URCi_UpdatePendingBranding entity-id false))
        )
    )
    (defun INFO_DPSF|UpdatePendingBranding:object{OuronetInfoV2.ClientInfo} (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (let
            (
                (d:module{DpdcV2} DPDC)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Updates pending Branding of SFT {}" [entity-id]) (format "Pending Branding of SFT {} updated" [entity-id]) (d::URCi_UpdatePendingBranding entity-id true))
        )
    )
    (defun INFO_DPDC|UpgradeBranding:object{OuronetInfoV2.ClientInfo} (patron:string entity-id:string months:integer son:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (d:module{DpdcV2} DPDC)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades Branding of {} {} for {} months" [(if son "SFT" "NFT") entity-id months])]
                [(format "Branding of {} {} upgraded for {} months" [(if son "SFT" "NFT") entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (d::URCi_UpgradeBranding months)) [])
        ))
    (defun INFO_DPNF|UpgradeBranding:object{OuronetInfoV2.ClientInfo} (patron:string entity-id:string months:integer) (INFO_DPDC|UpgradeBranding patron entity-id months false))
    (defun INFO_DPSF|UpgradeBranding:object{OuronetInfoV2.ClientInfo} (patron:string entity-id:string months:integer) (INFO_DPDC|UpgradeBranding patron entity-id months true))
    ;;  [DPSF equity aliases] — Talos surfaces EQUITY ops under the DPSF| client namespace
    (defun INFO_DPSF|IssueCompany:object{OuronetInfoV2.ClientInfo} (patron:string creator-account:string collection-name:string collection-ticker:string royalty:decimal ignis-royalty:decimal ipfs-links:[string]) (INFO_EQUITY|IssueCompany patron creator-account collection-name))
    (defun INFO_DPSF|MorphEquity:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer) (INFO_EQUITY|MorphEquity patron account id input-nonce input-amount output-nonce))
    ;;
    ;;  [DEMIPAD] — sovereign launchpad ops (deposit + fuel/retrieve TF/OF/SF/NF + withdraw)
    (defun INFO_DEMIPAD|Deposit:object{OuronetInfoV2.ClientInfo} (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (sd:string (ref-I|OURONET::OI|UC_ShortAccount donor))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Deposits {} $ worth against {} into the Launchpad from {}" [amount-in-dollars asset-id sd])]
                [(format "Succesfully deposited {} $ worth against {} into Demipad from {}" [amount-in-dollars asset-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_Deposit donor asset-id amount-in-dollars type direct-injection)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|Withdraw:object{OuronetInfoV2.ClientInfo} (patron:string asset-id:string type:integer destination:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (amount:decimal (ref-DEMIPAD::URv_Funds asset-id type))
                (working-id:string (if (= type 1) (ref-DALOS::UR_WrappedStoaID) (if (= type 2) (ref-DALOS::UR_SilverStoaID) (ref-DALOS::UR_OuroborosID))))
                (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Withdraws {} {} accumulated in the Launchpad to {}" [amount working-id sd])]
                [(format "Succesfully withdrawn {} {} from Demipad to {}" [amount working-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer working-id lpad destination amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|FuelTrueFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} {} (TrueFungible) to the Launchpad from {}" [amount asset-id sa])]
                [(format "Succesfully fueled {} {} to the Launchpad from {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id client lpad amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|RetrieveTrueFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} {} (TrueFungible) from the Launchpad to {}" [amount asset-id sa])]
                [(format "Succesfully retrieved {} {} from the Launchpad to {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id lpad client amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|FuelOrtoFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (OrtoFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|RetrieveOrtoFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (OrtoFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|FuelSemiFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} Amounts {} (SemiFungible) to the Launchpad from {}" [asset-id nonces amounts sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])
        ))
    (defun INFO_DEMIPAD|RetrieveSemiFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} Amounts {} (SemiFungible) from the Launchpad to {}" [asset-id nonces amounts sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])
        ))
    (defun INFO_DEMIPAD|FuelNonFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (NonFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|RetrieveNonFungible:object{OuronetInfoV2.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (NonFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    ;;
    ;;  [EQUITY] — shareholder/company SFT collection (exposed via DPSF Talos)
    (defun INFO_EQUITY|IssueCompany:object{OuronetInfoV2.ClientInfo} (patron:string creator-account:string collection-name:string)
        ;;MISSING STOA LEG FIXED (2026-09-14). This reported `OI|UDC_NoStoaCosts` -- a LITERAL ZERO,
        ;;rendered to the client as "Operation is free of native Stoa (STOA)". It is not free. The
        ;;exec charges TWO currencies (`01_TS02-C1.pact:1556-1560`):
        ;;    (ref-IGNIS::C_Collect patron ico)
        ;;    (ref-IGNIS::STOA|C_Collect patron (ref-IGNIS::UC_StoaPrice "issue-shareholder"))
        ;;with the source comment "Issuing a COMPANY is $100 in IGNIS deter and $100 in STOA (spec)".
        ;;
        ;;MEASURED, not inferred: a live `DPSF|C_IssueCompany` charged **918.0 STOA** while this
        ;;preview reported **0.0**. The IGNIS leg was already correct (6965.26 predicted == charged),
        ;;which is why the gap survived -- half the quote was right.
        ;;
        ;;A UI showing this preview told the user an Equity issue cost no STOA at all.
        ;;
        ;;THE CHARGE HAS TWO LEGS, which is why a first repair reporting only the premium still came
        ;;up short (765 quoted vs 918 charged). `DPDC-I::C_IssueDigitalCollection` runs its OWN
        ;;`STOA|C_Collect patron (URCi_IssueCollectionStoa son)` at `04_DPDC-I.pact:502`, nested
        ;;inside `C_IssueShareholderCollection`, and the Talos wrapper then adds the equity premium
        ;;on top. `11_EQUITY+.pact:385` already said so -- "the collection-issue STOA price previews
        ;;SEPARATELY via DPDC-I::URCi_IssueCollectionStoa" -- but nothing ever added the two together
        ;;for the client. Both legs are summed here, raw, before the patron discount is applied.
        ;;Pinned by REPL/modules/EQUITY.repl <<EQ-I1>>, which asserts BOTH currencies against a
        ;;measured charge.
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                (ref-EQUITY:module{EquityV2} EQUITY)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount creator-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues the 8-element Shareholder (Equity) SFT Collection '{}' on Account {}" [collection-name sa])]
                [(format "Shareholder Collection '{}' issued succesfully on Account {}" [collection-name sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_IssueShareholderCollection)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron
                    (+ (ref-DPDC-I::URCi_IssueCollectionStoa true)
                       (ref-IGNIS::UC_StoaPrice "issue-shareholder"))) [])
        ))
    (defun INFO_EQUITY|MorphEquity:object{OuronetInfoV2.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-EQUITY:module{EquityV2} EQUITY)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Morphs {} shares of {} Nonce {} into Nonce {} on Account {}" [input-amount id input-nonce output-nonce sa])]
                [(format "Succesfully morphed {} {} Nonce {} shares into Nonce {} on {}" [input-amount id input-nonce output-nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_MorphPackageShares account id input-nonce input-amount output-nonce)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact ===================
;; AQP-BOOT — live-chain AQP provisioning helpers.
;; Purpose: one-shot bootstrap writers for score/anchor/pool/fvt infra.
;;
;; HANDOFF PATTERN (mainnet + REPL)
;;   • Each C_StepN_* is intended as its own transaction (or REPL begin-tx block).
;;   • Functions that CREATE entities echo ids in a formatted return string — copy these
;;     into the NEXT step's arguments when steps run on separate txs.
;;   • Functions that WIRE existing entities take explicit id lists (Step 7) so mainnet
;;     ids from prior txs are passed in; REPL uses the same shape with REPL chain ids.
;;   • UDC_Makeid("<Name>") ids are deterministic from names (pool/score/anchor names).
;;   • Collection asset ids (DHCD-…, DHB-…, OURO-…, LP native ids) are ALWAYS inputs —
;;     never embedded in code; REPL examples live in ;; blocks only.
;;   • Full step chain table: 2_CITIZEN/Stage_02/README_AQP_BOOT.md
;;   • OURO LP user flow: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README.md § OURO LP onboarding
;;
;; STEP ORDER: 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12
;;   Step 0 — after sovereign AQP modules (ANK, SCR, AQP-POOL, FVT) are deployed: IMC + vault governor.
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AcquisitionPoolBootV2




    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|Demiurgoi ())

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
    (defun C_Step0_WireImcAndGovernor:string
        (patron:string)
    )
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string dh-asset-ids:[string] ouro-lp-asset-id:string dh-pool-ids:[string] ouro-lp-pool-id:string dh-score-ids:[string] ouro-triplet-score-ids:[string])
    )
    (defun C_Step8_IssueFvtEntities:string
        (patron:string owner-konto:string lp-denominator:string)
    )
    (defun C_Step9_AddFvtScoreEntities:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string subsidiary-score-ids:[string] coding-score-id:string snakes-score-id:string shares-score-id:string)
    )
    (defun C_Step10_IssueMultipletFamily:string
        (patron:string ouro-id:string auryn-id:string elite-auryn-id:string ats-0-1-id:string ats-1-2-id:string)
    )
    (defun C_Step11_WireFarmTriplet:string
        (patron:string farm-id:string bronze-score-id:string silver-score-id:string golden-score-id:string ouro-id:string multiplet-family-id:string)
    )
    (defun C_Step12_AddFvtRewardLinks:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string reward-auryn-id:string reward-ouroboros-id:string reward-wstoa-id:string)
    )

)

(module AQP-BOOT GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AcquisitionPoolBootV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-BOOT                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_BOOT_ADMIN)))
    (defcap GOV|AQP_BOOT_ADMIN ()                       (enforce-guard GOV|MD_AQP-BOOT))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst BOOT|SCORE_SILVER:string                  "SilverSnakePower")
    (defconst BOOT|SCORE_BRONZE:string                  "BronzeSnakePower")
    (defconst BOOT|SCORE_GOLDEN:string                  "GoldenSnakePower")
    (defconst BOOT|PRECISION:integer                    6)
    (defconst BOOT|MX_FROZEN:decimal                    2.0)
    (defconst BOOT|MX_SLEEPING:decimal                  2.0)
    (defconst BOOT|FVT_OURO_LP_FARM:string              "OuroLpFarm")
    (defconst BOOT|FVT_SUBSIDIARY_TREASURY:string "SubsidiaryTreasury")
    (defconst BOOT|FVT_CODING_TREASURY:string "CodingDivisionTreasury")
    (defconst BOOT|FVT_SNAKES_TREASURY:string "SnakesTreasury")
    (defconst BOOT|FVT_SHARES_TREASURY:string "CompanySharesTreasury")
    (defconst BOOT|TREASURY_COMMON:string               "|")
    (defconst BOOT|SCORE_ENTITY_SCORE:integer 1)
    (defconst BOOT|SCORE_ENTITY_TRIPLET:integer 3)
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
    ;;
    ;;Step 0 - Wire AQP sovereign IMC policies + AQP|SC_NAME vault governor (run once after module deploy)
    ;;Step 1 - Create the Bunny Set Definition
    ;;Step 2 - Create the BronzeSnakePower, SilverSnakePower and GoldenSnakePower Anchor-Class Definitions
    ;;Step 3 - Create the UnityBooster, StoaBooster and VestaBooster Anchor-Class Definitions
    ;;Step 4 - Create the TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes Score Definitions
    ;;Step 5 - Create the SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu and SubsidiaryBunnies Score Definitions
    ;;Step 6 - Create the Ouro LP Triplet Score Definition
    ;;Step 7 - Create six DH pools (class 3/4 by entity) + class-0 OURO LP pool; assign Step4/5/6 scores
    ;;Step 8 - Issue five FVT entities (farm + vault treasuries) — C_Issue only
    ;;Step 9 - C_AddScoreEntity (type 1) on vault/treasury FVT entities (not farm LP triplet)
    ;;Step 10 - C_IssueMultipletFamily (OURO / Auryn / Elite-Auryn ATS ladder)
    ;;Step 11 - C_IssueTriplet + C_AddScoreEntity (type 3) + C_AddRewardLink (OURO + multiplet-family) on OuroLpFarm
    ;;Step 12 - C_AddRewardLink on vault/treasury FVT entities (plain rewards)
    (defun C_Step0_WireImcAndGovernor:string
        (patron:string)
        @doc "Step 0 — AQP-POOL TFT + DPOF IMC + AQP|SC_NAME governor rotate. \
            \ Run once after all four sovereign AQP modules are on chain (before stake/unstake or Step 1+). \
            \ Prerequisite: AQP|SC_NAME smart account deployed (DALOS|A_DeploySmartAccount). \
            \ Talos TS02-C3 P|A_Define (P|TALOS-SUMMONER) is separate — sovereign executor / [4.0]. \
            \ FVT + VCT P|A_Define register IMP; FVT|RemoteAqpGov + VCT|RemoteAqpGov on AQP-POOL for vault legs."
        ;; INPUT
        ;;   patron — gas payer konto (REPL: KST.ANHD)
        ;; REPL: (AQP-BOOT.C_Step0_WireImcAndGovernor KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                    (ref-P|RPS:module{OuronetPolicyV2} RPS)
                    (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                    (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    ;;
                    (aqp-sc:string (ref-ANK::GOV|AQP|SC_NAME))
                )
                (ref-P|AQP::P|A_Define)
                (ref-P|RPS::P|A_Define)   ;; #75 B': RPS reward engine registers its guards on deps (royalty disposal)
                (ref-P|FVT::P|A_Define)
                (ref-P|VCT::P|A_Define)
                ;; C_RotateGovernor — AQP|SC_NAME: AQP-POOL.AQP|GOV (stake) + FVT|RemoteAqpGov + VCT|RemoteAqpGov.
                (ref-TS01-C1::DALOS|C_RotateGovernor patron aqp-sc
                    (let
                        (
                            (ref-U|G:module{OuronetGuardsV2} U|G)
                        )
                        (ref-U|G::UEV_GuardOfAny
                            [
                                (create-capability-guard (AQP-POOL.AQP|GOV))
                                (ref-P|AQP::P|UR "FVT|RemoteAqpGov")
                                (ref-P|AQP::P|UR "VCT|RemoteAqpGov")
                            ]
                        )
                    )
                )
                (format "AQP-BOOT Step 0 done. aqp-sc={}. TFT+DPOF IMC + gov wired. NEXT=Step1 or client txs." [aqp-sc])
            )
        )
    )
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
        @doc "Step 1 — Create Bunny set definition on KBN. INPUT: kbn-id from chain deploy. \
            \ OUTPUT echo: kbn-id. NEXT: Steps 2 and 3 use the same kbn-id."
        ;; INPUT
        ;;   patron   — gas payer konto (REPL: KST.ANHD)
        ;;   kbn-id   — KBN collection id already on chain (REPL: "KBN-98c486052a51")
        ;; OUTPUT (return string)
        ;;   kbn-id echoed — pass unchanged to Steps 2 and 3
        ;; REPL: (AQP-BOOT.C_Step1_CreateBunnySet KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (KBN.A_BunnyRGBSet patron kbn-id)
            (format "AQP-BOOT Step 1 done. kbn-id={}. NEXT=Step2,Step3:kbn-id={}." [kbn-id kbn-id])
        )
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 2 — SnakePower anchor classes (Bronze/Silver/Golden). INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: Step 6 boost-class-ids=[Silver Bronze Golden]."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[4]       — OuroborosRain, AurynRain, EliteAurynRain, LegendarySnakeTokenRain
        ;;   boost-class-ids[3]  — BronzeSnakePower, SilverSnakePower, GoldenSnakePower (UDC_Makeid order in format)
        ;; NEXT
        ;;   Step 6: boost-class-ids arg = [SilverSnakePower-id BronzeSnakePower-id GoldenSnakePower-id]
        ;;           i.e. indices [1 0 2] from this step's boost-class-ids list
        ;; REPL: (AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (bronze-boost-class-id:string (ref-U|DALOS::UDC_Makeid "BronzeSnakePower"))
                    (silver-boost-class-id:string (ref-U|DALOS::UDC_Makeid "SilverSnakePower"))
                    (golden-boost-class-id:string (ref-U|DALOS::UDC_Makeid "GoldenSnakePower"))
                    ;;
                    (anchor-ouroboros-rain-id:string (ref-U|DALOS::UDC_Makeid "OuroborosRain"))
                    (anchor-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "AurynRain"))
                    (anchor-elite-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "EliteAurynRain"))
                    (anchor-legendary-snake-token-rain-id:string (ref-U|DALOS::UDC_Makeid "LegendarySnakeTokenRain"))
                )
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "OuroborosRain" kbn-id true "BronzeSnakePower" 3 50.0 "Background" "Ouroboros Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "AurynRain" kbn-id true "SilverSnakePower" 3 100.0 "Background" "Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "EliteAurynRain" kbn-id true "GoldenSnakePower" 3 200.0 "Background" "Elite-Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendarySnakeTokenRain" kbn-id false golden-boost-class-id 3 400.0 "Rarity" "Legendary")
                (format "AQP-BOOT Step 2 done. kbn-id={}. anchor-ids=[{} {} {} {}]. boost-class-ids=[bronze={} silver={} golden={}]. NEXT=Step6:boost-class-ids=[{} {} {}]."
                    [
                        kbn-id
                        anchor-ouroboros-rain-id anchor-auryn-rain-id anchor-elite-auryn-rain-id anchor-legendary-snake-token-rain-id
                        bronze-boost-class-id silver-boost-class-id golden-boost-class-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 3 — Unity/Stoa/Vesta booster anchor classes. INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: none required for Steps 4–7 (user ANK boosting)."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[11], boost-class-ids[3] — UnityBooster, StoaBooster, VestaBooster
        ;; REPL: (AQP-BOOT.C_Step3_CreateBoosterAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (unity-boost-class-id:string (ref-U|DALOS::UDC_Makeid "UnityBooster"))
                    (stoa-boost-class-id:string (ref-U|DALOS::UDC_Makeid "StoaBooster"))
                    (vesta-boost-class-id:string (ref-U|DALOS::UDC_Makeid "VestaBooster"))
                    ;;
                    (anchor-elk0nite-id:string (ref-U|DALOS::UDC_Makeid "Elk0nite"))
                    (anchor-osmiridium-id:string (ref-U|DALOS::UDC_Makeid "Osmiridium"))
                    (anchor-titanium-id:string (ref-U|DALOS::UDC_Makeid "Titanium"))
                    (anchor-legendary-unity-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryUnityBooster"))
                    (anchor-vegold-eyes-id:string (ref-U|DALOS::UDC_Makeid "VegoldEyes"))
                    (anchor-legendary-stoa-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryStoaBooster"))
                    (anchor-red-eyes-id:string (ref-U|DALOS::UDC_Makeid "RedEyes"))
                    (anchor-green-eyes-id:string (ref-U|DALOS::UDC_Makeid "GreenEyes"))
                    (anchor-blue-eyes-id:string (ref-U|DALOS::UDC_Makeid "BlueEyes"))
                    (anchor-legendary-vesta-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryVestaBooster"))
                    (anchor-rgb-eyes-id:string (ref-U|DALOS::UDC_Makeid "RGBEyes"))
                )
                ;; Unity
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Elk0nite" kbn-id true "UnityBooster" 3 100.0 "Eyes" "Elk0nite Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Osmiridium" kbn-id false unity-boost-class-id 3 300.0 "Eyes" "Osmiridium Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Titanium" kbn-id false unity-boost-class-id 3 900.0 "Eyes" "Titaniumgold Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryUnityBooster" kbn-id false unity-boost-class-id 3 1000.0 "Rarity" "Legendary")
                ;; Stoa
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "VegoldEyes" kbn-id true "StoaBooster" 3 1000.0 "Eyes" "vEGLD Focus")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryStoaBooster" kbn-id false stoa-boost-class-id 3 3500.0 "Rarity" "Legendary")
                ;; Vesta
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "RedEyes" kbn-id true "VestaBooster" 3 250.0 "Eyes" "Red")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "GreenEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Green")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "BlueEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Blue")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryVestaBooster" kbn-id false vesta-boost-class-id 3 3500.0 "Rarity" "Legendary")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleSetAnchor patron "RGBEyes" kbn-id false vesta-boost-class-id 3 1000.0 1)
                (format "AQP-BOOT Step 3 done. kbn-id={}. anchor-ids=[{} {} {} {} {} {} {} {} {} {} {}]. boost-class-ids=[unity={} stoa={} vesta={}]. NEXT=none-for-Steps4-7."
                    [
                        kbn-id
                        anchor-elk0nite-id anchor-osmiridium-id anchor-titanium-id anchor-legendary-unity-booster-id
                        anchor-vegold-eyes-id anchor-legendary-stoa-booster-id
                        anchor-red-eyes-id anchor-green-eyes-id anchor-blue-eyes-id anchor-legendary-vesta-booster-id anchor-rgb-eyes-id
                        unity-boost-class-id stoa-boost-class-id vesta-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
        @doc "Step 4 — Core scores (SF/NF). OUTPUT: score-ids ×4. NEXT: Step7 dh-score-ids slots 0,2,4,5."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids (UDC_Makeid names):
        ;;   TheCodingDivision, Bloodshed, DemiourgosShareholder, DemiourgosSnakes
        ;; NEXT Step 7 dh-score-ids[0,2,4,5] = these four ids (see README_AQP_BOOT.md index map)
        ;; REPL: (AQP-BOOT.C_Step4_CreateCoreScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (score-coding:string (ref-U|DALOS::UDC_Makeid "TheCodingDivision"))
                    (score-bloodshed:string (ref-U|DALOS::UDC_Makeid "Bloodshed"))
                    (score-company-share:string (ref-U|DALOS::UDC_Makeid "DemiourgosShareholder"))
                    (score-company-snakes:string (ref-U|DALOS::UDC_Makeid "DemiourgosSnakes"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "TheCodingDivision" 3 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "Bloodshed" 6 0)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosShareholder" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosSnakes" 6 false)
                (format "AQP-BOOT Step 4 done. score-ids=[coding={} bloodshed={} company-share={} company-snakes={}]. NEXT=Step7:dh-score-ids[0,2,4,5]=[{} {} {} {}]."
                    [
                        score-coding score-bloodshed score-company-share score-company-snakes
                        score-coding score-bloodshed score-company-share score-company-snakes
                    ]
                )
            )
        )
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
        @doc "Step 5 — Subsidiary scores. OUTPUT: score-ids ×5. NEXT: Step7 dh-score-ids slots 1,3,6,7,8."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids:
        ;;   SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu, SubsidiaryBunnies
        ;; NEXT Step 7 dh-score-ids[1,3,6,7,8] = these five ids
        ;; REPL: (AQP-BOOT.C_Step5_CreateSubsidiaryScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (score-sub-coding:string (ref-U|DALOS::UDC_Makeid "SubsidiaryCodingDivision"))
                    (score-sub-wondercoach:string (ref-U|DALOS::UDC_Makeid "SubsidiaryWonderCoach"))
                    (score-sub-bloodshed:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBloodshed"))
                    (score-sub-nosferatu:string (ref-U|DALOS::UDC_Makeid "SubsidiaryNosferatu"))
                    (score-sub-bunnies:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBunnies"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryCodingDivision" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryWonderCoach" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBloodshed" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryNosferatu" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBunnies" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron score-sub-coding)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron score-sub-wondercoach)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron score-sub-bloodshed)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron score-sub-nosferatu)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron score-sub-bunnies)
                (format "AQP-BOOT Step 5 done. score-ids=[sub-coding={} sub-wondercoach={} sub-bloodshed={} sub-nosferatu={} sub-bunnies={}] deb-boost=enabled×5. NEXT=Step7:dh-score-ids[1,3,6,7,8]=[{} {} {} {} {}]."
                    [
                        score-sub-coding score-sub-wondercoach score-sub-bloodshed score-sub-nosferatu score-sub-bunnies
                        score-sub-coding score-sub-wondercoach score-sub-bloodshed score-sub-nosferatu score-sub-bunnies
                    ]
                )
            )
        )
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
        @doc "Step 6 — Issue OURO LP triplet **scores only** (Silver/Bronze/Golden class-0). \
            \ Does not create a pool or farm links — wire those in Step 7 (first LP) or manually per new LP line."
        ;;
        ;; WHAT THIS STEP DOES (scores only — no pool, no FVT)
        ;; Creates three class-0 liquidity scores sharing one lp-denominator (full OURO DPTF id):
        ;;   SilverSnakePower  — primary; owns user base-score for the triplet boost chain
        ;;   BronzeSnakePower  — foreign boost-link → Silver
        ;;   GoldenSnakePower  — foreign boost-link → Silver
        ;; Each score also gets a boost-class-link from Step 2 anchor classes.
        ;;
        ;; lp-denominator — full native DPTF id of the OURO pool leg (NOT ticker "OURO"):
        ;;   REPL example: "OURO-98c486052a51"
        ;;   Must match the Farm FVT common-denominator when scores are later admitted to a farm.
        ;;
        ;; boost-class-ids[0..2] — from Step 2 (SnakePower anchor classes), same tx or prior:
        ;;   0 silver-boost-class-id  e.g. (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   1 bronze-boost-class-id  e.g. (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   2 golden-boost-class-id  e.g. (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; Score ids created (fixed names — first OURO LP line only):
        ;;   (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; AFTER Step 6 — per LP line (full flow: README.md § OURO LP onboarding flow):
        ;;   1. C_Issue class-0 pool (DHOuroLp) with native LP asset-id  ← Step 7
        ;;   2. C_AddScore × 3 — employ triplet on that pool              ← Step 7
        ;;   3. Users stake LP into pool → SCORE user rows update
        ;;   4. C_AddScoreEntity (type 3) on shared Farm FVT                     ← Step 11
        ;;   5. C_AddRewardLink (OURO, multiplet-family-id) on farm    ← Step 11
        ;;
        ;; SECOND OURO LP: repeat score issuance with **new score names** (cannot reuse ids),
        ;; then new pool + C_AddScore × 3 + C_IssueTriplet + C_AddScoreEntity (type 3) on the same farm.
        ;;
        ;; REPL call (after Steps 2–3 anchor classes exist):
        ;; (AQP-BOOT.C_Step6_CreateOuroLpTriplet
        ;;   KST.ANHD
        ;;   KST.ANHD
        ;;   "OURO-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
            ;;It used to sit BELOW a `let` that already did `(at 0 boost-class-ids)`, `(at 1 …)` and
            ;;`(at 2 …)`. A `let` is EAGER, so for a SHORT list those indexes ran first and the
            ;;operator got `Array index out of bounds` instead of the sentence naming the argument.
            ;;The message only ever arrived for a list that was too LONG -- the one case the `at`s
            ;;survive. C_Step9 in this same file is the correctly-ordered twin, so the fix was
            ;;demonstrated in place. A length test needs nothing but the parameter, so it can run
            ;;before anything is derived. Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
            (enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (silver-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_SILVER))
                    (bronze-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_BRONZE))
                    (golden-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_GOLDEN))
                    ;;
                    (silver-boost-class-id:string (at 0 boost-class-ids))
                    (bronze-boost-class-id:string (at 1 boost-class-ids))
                    (golden-boost-class-id:string (at 2 boost-class-ids))
                )
                ;; [1..2] Silver
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_SILVER BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron silver-id silver-boost-class-id)
                ;; [3..5] Bronze
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_BRONZE BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron bronze-id bronze-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron bronze-id silver-id)
                ;; [6..8] Golden
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_GOLDEN BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron golden-id golden-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron golden-id silver-id)
                ;;
                (format "AQP-BOOT Step 6 done. lp-denominator={}. score-ids=[silver={} bronze={} golden={}]. boost-class-ids=[{} {} {}]. boost-links=[{}->{} {}->{}]. NEXT=Step7:ouro-triplet-score-ids=[{} {} {}]. NEXT=Step11:C_IssueTriplet+AddTriplet."
                    [
                        lp-denominator
                        silver-id bronze-id golden-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                        bronze-id silver-id golden-id silver-id
                        silver-id bronze-id golden-id
                    ]
                )
            )
        )
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string dh-asset-ids:[string] ouro-lp-asset-id:string dh-pool-ids:[string] ouro-lp-pool-id:string dh-score-ids:[string] ouro-triplet-score-ids:[string])
        @doc "Step 7 — Issue six DH pools (class 3 or 4 by entity) plus one class-0 OURO LP pool and assign existing scores. \
            \ All ids are caller-supplied so this step can run after Steps 4–6 in separate transactions. \
            \ Pool aqp-class is fixed per entity (see ;; block). This step does not create FVT links."
        ;;
        ;; POOL MAP (aqp-class is fixed in code — pass the matching native collection id in dh-asset-ids)
        ;; | Pool name         | aqp-class | pass in dh-asset-ids     | Scores attached                                         |
        ;; | DHCodingDivision  | 3 DPSF    | DHCD-… dpsf-id           | TheCodingDivision, SubsidiaryCodingDivision             |
        ;; | DHBloodshed       | 4 DPNF    | DHB-… dpnf-id            | Bloodshed, SubsidiaryBloodshed                          |
        ;; | DHCompany         | 3 DPSF    | E|DH-… dpsf-id           | DemiourgosShareholder, DemiourgosSnakes                 |
        ;; | DHWonderCoach     | 3 DPSF    | DHWC-… dpsf-id           | SubsidiaryWonderCoach                                   |
        ;; | DHNosferatu       | 4 DPNF    | DHN-… dpnf-id            | SubsidiaryNosferatu                                     |
        ;; | DHBunnies         | 4 DPNF    | KBN-… dpnf-id            | SubsidiaryBunnies                                       |
        ;; | DHOuroLp          | 0 LP      | native LP id             | SilverSnakePower, BronzeSnakePower, GoldenSnakePower    |
        ;;
        ;; dh-asset-ids[0..5] — REPL examples (replace suffix with mainnet hash):
        ;;   0 "DHCD-98c486052a51"
        ;;   1 "DHB-98c486052a51"
        ;;   2 "E|DH-98c486052a51"
        ;;   3 "DHWC-98c486052a51"
        ;;   4 "DHN-98c486052a51"
        ;;   5 "KBN-98c486052a51"
        ;; ouro-lp-asset-id — e.g. "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;
        ;; dh-pool-ids[0..5]:
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;; ouro-lp-pool-id — (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;
        ;; dh-score-ids[0..8] — from Steps 4–5 (UDC_Makeid of score names):
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed
        ;;    DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu SubsidiaryBunnies]
        ;; ouro-triplet-score-ids[0..2] — from Step 6:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;; REPL call (copy/paste; swap ids for mainnet):
        ;; (AQP-BOOT.C_Step7_CreatePoolsAndScores
        ;;   KST.ANHD
        ;;   ["DHCD-98c486052a51" "DHB-98c486052a51" "E|DH-98c486052a51" "DHWC-98c486052a51" "DHN-98c486052a51" "KBN-98c486052a51"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;;   (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision")
        ;;    (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed")
        ;;    (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu") (U|DALOS.UDC_Makeid "SubsidiaryBunnies")]
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: all FOUR length checks are enforced HERE, above the binding group.
            ;;They used to sit BELOW a `let` that indexes every one of these lists -- (at 0 dh-score-ids)
            ;;through (at 8 dh-score-ids), and so on. A `let` is EAGER, so for any list that was too
            ;;SHORT the indexes ran first and the operator got `Array index out of bounds` instead of
            ;;the sentence naming which argument was wrong. Six operator-facing messages in this file
            ;;arrived only when a list was too LONG -- the one case the `at`s survive.
            ;;C_Step9 in this same file is the correctly-ordered twin. Length tests need nothing but
            ;;the parameters, so they run before anything is derived.
            ;;Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
                (enforce (= (length dh-asset-ids) 6) "Step 7 expects dh-asset-ids=[coding bloodshed company wondercoach nosferatu bunnies].")
                (enforce (= (length dh-pool-ids) 6) "Step 7 expects dh-pool-ids=[pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies].")
                (enforce (= (length dh-score-ids) 9) "Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (asset-coding:string (at 0 dh-asset-ids))
                    (asset-bloodshed:string (at 1 dh-asset-ids))
                    (asset-company:string (at 2 dh-asset-ids))
                    (asset-wondercoach:string (at 3 dh-asset-ids))
                    (asset-nosferatu:string (at 4 dh-asset-ids))
                    (asset-bunnies:string (at 5 dh-asset-ids))
                    ;;
                    (pool-coding:string (at 0 dh-pool-ids))
                    (pool-bloodshed:string (at 1 dh-pool-ids))
                    (pool-company:string (at 2 dh-pool-ids))
                    (pool-wondercoach:string (at 3 dh-pool-ids))
                    (pool-nosferatu:string (at 4 dh-pool-ids))
                    (pool-bunnies:string (at 5 dh-pool-ids))
                    (pool-ouro-lp:string ouro-lp-pool-id)
                    ;;
                    (score-coding:string (at 0 dh-score-ids))
                    (score-sub-coding:string (at 1 dh-score-ids))
                    (score-bloodshed:string (at 2 dh-score-ids))
                    (score-sub-bloodshed:string (at 3 dh-score-ids))
                    (score-company-share:string (at 4 dh-score-ids))
                    (score-company-snakes:string (at 5 dh-score-ids))
                    (score-sub-wondercoach:string (at 6 dh-score-ids))
                    (score-sub-nosferatu:string (at 7 dh-score-ids))
                    (score-sub-bunnies:string (at 8 dh-score-ids))
                    (score-silver:string (at 0 ouro-triplet-score-ids))
                    (score-bronze:string (at 1 ouro-triplet-score-ids))
                    (score-golden:string (at 2 ouro-triplet-score-ids))
                )
                ;;
                ;; [1] DHCodingDivision — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHCodingDivision" asset-coding 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding score-coding)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding score-sub-coding)
                ;; [2] DHBloodshed — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHBloodshed" asset-bloodshed 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed score-bloodshed)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed score-sub-bloodshed)
                ;; [3] DHCompany — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHCompany" asset-company 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company score-company-share)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company score-company-snakes)
                ;; [4] DHWonderCoach — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHWonderCoach" asset-wondercoach 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach score-sub-wondercoach)
                ;; [5] DHNosferatu — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHNosferatu" asset-nosferatu 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu score-sub-nosferatu)
                ;; [6] DHBunnies — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHBunnies" asset-bunnies 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies score-sub-bunnies)
                ;; [7] DHOuroLp — aqp-class 0 (LP); triplet from Step 6 — see Step 6 ;; for OURO LP flow
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[coding={} bloodshed={} company={} wondercoach={} nosferatu={} bunnies={} ouro-lp={}]. ouro-lp-asset-id={}. score-slots-wired=12. NEXT=Step8:C_Step8_IssueFvtEntities."
                    [
                        pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies pool-ouro-lp
                        ouro-lp-asset-id
                    ]
                )
            )
        )
    )
    (defun C_Step8_IssueFvtEntities:string
        (patron:string owner-konto:string lp-denominator:string)
        @doc "Step 8 — Issue five production FVT entities (C_Issue only). \
            \ OuroLpFarm class 0 when lp-denominator non-empty (same OURO DPTF id as Step 6). \
            \ Four class-1 vault treasuries with common-denominator '|'. \
            \ Product names say Treasury; class 1 vault admits TF/SF/NF. Class 2 is OF-only. \
            \ NEXT=Step9 vault score links, Steps 10–11 farm triplet — pass fvt-ids from this output."
        ;;
        ;; INPUT
        ;;   patron, owner-konto — FVT owner (REPL: KST.ANHD)
        ;;   lp-denominator — full OURO DPTF id for OuroLpFarm; pass \"\" to skip farm (vault-only bootstrap)
        ;; OUTPUT — fvt-ids ×5 (farm skipped → echo farm=skipped)
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (farm-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_OURO_LP_FARM))
                    (sub-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SUBSIDIARY_TREASURY))
                    (coding-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CODING_TREASURY))
                    (snakes-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SNAKES_TREASURY))
                    (shares-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SHARES_TREASURY))
                )
                (if (!= lp-denominator "")
                    (ref-TS02-C3::AQP-FVT|C_Issue patron BOOT|FVT_OURO_LP_FARM owner-konto 0 lp-denominator)
                    true
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron BOOT|FVT_SUBSIDIARY_TREASURY owner-konto 1 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron BOOT|FVT_CODING_TREASURY owner-konto 1 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron BOOT|FVT_SNAKES_TREASURY owner-konto 1 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron BOOT|FVT_SHARES_TREASURY owner-konto 1 BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8 done. fvt-ids=[farm={} sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={}]. NEXT=Step9:C_AddScoreEntity."
                    [
                        (if (!= lp-denominator "") farm-id "skipped")
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step9_AddFvtScoreEntities:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string subsidiary-score-ids:[string] coding-score-id:string snakes-score-id:string shares-score-id:string)
        @doc "Step 9 — Admit score entities (type 1) on vault/treasury FVT entities only. \
            \ SubsidiaryTreasury: five subsidiary scores. \
            \ CodingDivisionTreasury: TheCodingDivision. SnakesTreasury: DemiourgosSnakes. \
            \ CompanySharesTreasury: DemiourgosShareholder. \
            \ Farm OURO LP triplet is wired in Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8 output; score ids from Steps 4–5
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                )
                (enforce (= (length subsidiary-score-ids) 5) "Step 9 expects subsidiary-score-ids×5.")
                (map
                    (lambda (score-id:string)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron sub-treasury-id BOOT|SCORE_ENTITY_SCORE score-id)
                    )
                    subsidiary-score-ids
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron coding-treasury-id BOOT|SCORE_ENTITY_SCORE coding-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron snakes-treasury-id BOOT|SCORE_ENTITY_SCORE snakes-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron shares-treasury-id BOOT|SCORE_ENTITY_SCORE shares-score-id)
                (format "AQP-BOOT Step 9 done. score-entities=[sub=5 coding=1 snakes=1 shares=1]. fvt-ids=[sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={}]. NEXT=Step10:C_IssueMultipletFamily."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step10_IssueMultipletFamily:string
        (patron:string ouro-id:string auryn-id:string elite-auryn-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Step 10 — Issue chain-wide MultipletFamily (rank 3) for OURO→Auryn→Elite-Auryn Coil/Curl ladder. \
            \ INPUT: live DPTF ids + ATS pair ids (token-0 RT on ats-0-1; token-1 RBT/RT; token-2 RBT)."
        ;;
        ;; family-id = F|ouro-id|auryn-id|elite-auryn-id (deterministic — pass to Step 11)
        ;; REPL: ouro-id, auryn-id, elite-auryn-id from DALOS; ats ids from deployed ATS pairs
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (family-id:string (concat ["F" "|" ouro-id "|" auryn-id "|" elite-auryn-id]))
                )
                (ref-TS02-C3::AQP-FVT|C_IssueMultipletFamily
                    patron ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id
                )
                (format "AQP-BOOT Step 10 done. multiplet-family-id={}. tokens=[ouro={} auryn={} elite={}] ats=[{} {}]. NEXT=Step11:C_IssueTriplet+AddScoreEntity."
                    [family-id ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id]
                )
            )
        )
    )
    (defun C_Step11_WireFarmTriplet:string
        (patron:string farm-id:string bronze-score-id:string silver-score-id:string golden-score-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 11 — Issue triplet bundle, admit to OuroLpFarm (type 3), register OURO MULTIPLET_BASE reward. \
            \ Skip when farm-id empty or 'skipped'. INPUT: score ids from Step 6; family id from Step 10 echo."
        ;;
        ;; triplet-id = T|bronze|silver|golden (deterministic from score ids)
        ;; REPL: farm-id from Step 8; ouro-id = lp-denominator; multiplet-family-id from Step 10
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (wire-farm:bool
                        (and
                            (!= farm-id "")
                            (!= farm-id "skipped")
                        )
                    )
                    (triplet-id:string (concat ["T" "|" bronze-score-id "|" silver-score-id "|" golden-score-id]))
                )
                (if wire-farm
                    (do
                        (ref-TS02-C3::AQP-SCR|C_IssueTriplet patron bronze-score-id silver-score-id golden-score-id)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron farm-id BOOT|SCORE_ENTITY_TRIPLET triplet-id)
                        (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron farm-id ouro-id false multiplet-family-id)
                    )
                    true
                )
                (format "AQP-BOOT Step 11 done. farm={} triplet-id={} multiplet-family-id={} ouro-reward={}. NEXT=Step12:C_AddRewardLink."
                    [
                        (if wire-farm farm-id "skipped")
                        (if wire-farm triplet-id "skipped")
                        (if wire-farm multiplet-family-id "skipped")
                        (if wire-farm ouro-id "skipped")
                    ]
                )
            )
        )
    )
    (defun C_Step12_AddFvtRewardLinks:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string reward-auryn-id:string reward-ouroboros-id:string reward-wstoa-id:string)
        @doc "Step 12 — Register reward tokens on treasury FVT entities via C_AddRewardLink (multiplet-family-id BAR). \
            \ SubsidiaryTreasury, SnakesTreasury → Auryn. CodingDivisionTreasury → Wstoa. \
            \ CompanySharesTreasury → Ouroboros. Farm OURO + family is Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8; reward DPTF ids from live chain
        ;; REPL: AURYN-98c486052a51, DALOS::UR_OuroborosID, DALOS::UR_WrappedStoaID
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron sub-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron coding-treasury-id reward-wstoa-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron snakes-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron shares-treasury-id reward-ouroboros-id false bar)
                (format "AQP-BOOT Step 12 done. reward-links=[sub={} coding={} snakes={} shares={}]. rewards=[auryn={} wstoa={} ouroboros={}]. Bootstrap complete — ready for inject/stake/collect."
                    [
                        reward-auryn-id reward-wstoa-id reward-auryn-id reward-ouroboros-id
                        reward-auryn-id reward-wstoa-id reward-ouroboros-id
                    ]
                )
            )
        )
    )

)

