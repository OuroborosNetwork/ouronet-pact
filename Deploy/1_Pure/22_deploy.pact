;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 22 of 24
;; This is STEP 22 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-21 must have run first, including the init steps between deploys.
;; 8 source file(s), 175,977 gas measured in the REPL gas model, 268,449 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact
;;   2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;   2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;   2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact
;;   2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact
;;   2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact
;;   1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;   2_CITIZEN/4_BunniesMinter/02_KBunnies.pact
;;
;; TOTAL: 6 interface(s), 8 module(s), 18 table(s)
;; What it DEPLOYS, in load order:
;;   -- 2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact
;;      interface  SparksV2
;;      module     DEMIPAD-SPARK
;;      table      P|T
;;      table      P|MT
;;      table      SPARK|T|Properties
;;   -- 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;      interface  SaleSnakesV2
;;      module     DEMIPAD-SNAKES
;;      table      P|T
;;      table      P|MT
;;      table      SNAKES|T|Properties
;;   -- 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;      interface  SaleCustodiansV2
;;      module     DEMIPAD-CUSTODIANS
;;      table      P|T
;;      table      P|MT
;;      table      CUSTODIANS|T|Properties
;;   -- 2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact
;;      interface  StoicPayV3
;;      module     DEMIPAD-STOICPAY
;;      table      P|T
;;      table      P|MT
;;      table      KPAY|T|Properties
;;   -- 2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact
;;      module     STOAICO
;;      table      P|T
;;      table      P|MT
;;      table      STOAICO|T|User
;;      table      STOAICO|T|General
;;   -- 2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact
;;      interface  CitizenLaunchpadTalosV1
;;      module     TS02-CPAD
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;      interface  InfoTwoV2
;;      module     INFO-TWO
;;   -- 2_CITIZEN/4_BunniesMinter/02_KBunnies.pact
;;      module     KBN
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact =================
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SparksV2




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
    (defun UR_SparkID:string ())
    (defun UR_IzOpenForBusiness:bool ())
    (defun UR_FrozenSparkID:string ())
    (defun UR_Sparks (account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    (defun URC_SparkCost:decimal ())
    (defun URC_SparkRedemptionCost:decimal ())
    (defun URC_AccountRedemptionAmount:decimal (account:string))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool))
    (defun INFO_BuySparks:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool))
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun INFO_RedeemSparks:object{OuronetInfoV2.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal))
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string))
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal))
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal))

)
(module DEMIPAD-SPARK GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SparksV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SPARK                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SPARK_ADMIN)))
    (defcap GOV|SPARK_ADMIN ()                          (enforce-guard GOV|MD_SPARK))
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
    (defcap P|SPARK|CALLER ()
        true
    )
    (defcap P|PAD-SPARK|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SPARK|CALLER))
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
        (with-capability (GOV|SPARK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SPARK_ADMIN)
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
        (with-capability (GOV|SPARK_ADMIN)
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
        (with-capability (GOV|SPARK_ADMIN)
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
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|SPARK|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "SPARK|RemoteGov"
                (create-capability-guard (P|PAD-SPARK|REMOTE-GOV))
            )
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst SPARK|INFO                                (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema SPARK|PropertiesSchema
        spark-id:string
    )
    ;;{3.3}  tables
    (deftable SPARK|T|Properties:{SPARK|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SPARK|C>BUY (sparks-amount:integer)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (remaining-supply:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                (amount:decimal (dec sparks-amount))
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap SPARK|C>REEDEM-ALL (account-to-redeem:string)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (compose-capability (SPARK|C>X_REEDEM account-to-redeem supply))
        )
    )
    (defcap SPARK|C>REEDEM-FEW (account-to-redeem:string redemption-quantity:decimal)
        @event
        (compose-capability (SPARK|C>X_REEDEM account-to-redeem redemption-quantity))
    )
    (defcap SPARK|C>X_REEDEM (account-to-redeem:string redemption-quantity:decimal)
        (compose-capability (GOV|SPARK_ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (ref-DPTF::CAP_Owner spark-id)
            (enforce 
                (and
                    (> redemption-quantity 0.0)
                    (<= redemption-quantity supply)
                )
                "Invalid Redemmption Amount"
            )
            (compose-capability (P|SECURE-CALLER))
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["spark-data-key"]))
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
    (defun UR_SparkID:string ()
        (at "spark-id" (read SPARK|T|Properties SPARK|INFO ["spark-id"]))
    )
    (defun UR_BoostPromille:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "boost" (ref-DEMIPAD::UR_Price (UR_SparkID)))
        )
    )
    (defun UR_IzOpenForBusiness:bool ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::UR_OpenForBusiness (UR_SparkID))
        )
    )
    (defun UR_FrozenSparkID:string ()
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Frozen (UR_SparkID))
        )
    )
    (defun UR_Sparks (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (f-spark-id:string (UR_FrozenSparkID))
            )
            {"spark-id"         : spark-id
            ,"f-spark-id"       : f-spark-id
            ,"spark-supply"     : (ref-DPTF::UR_AccountSupply spark-id account)
            ,"f-spark-supply"   : (ref-DPTF::UR_AccountSupply f-spark-id account)
            ;;
            ,"iz-sale"          : (UR_IzOpenForBusiness)
            ,"boost-promile"    : (UR_BoostPromille)
            ;;
            ,"left-for-sale"    : (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME)
            ,"sparks-supply"    : (ref-DPTF::UR_Supply spark-id)
            ,"f-sparks-supply"  : (ref-DPTF::UR_Supply f-spark-id)
            ;;
            ,"stoa-spark-cost"   : (URC_SparkCost)
            ,"redemption-value" : (URC_SparkRedemptionCost)
            ;;
            ,"native-max"       : (URC_GetMaxBuy account true)
            ,"wstoa-max"         : (URC_GetMaxBuy account false)
            ;;
            ,"account-ignis"    : (ref-DPTF::UR_AccountSupply (ref-DALOS::UR_IgnisID) account)
            ,"ignis-collection" : (ref-DALOS::UR_VirtualToggle)}
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds"
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
                (still-for-sale:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:decimal (floor (/ client-stoa-value-in-dollarz spark-price)))
            )
            (floor
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URC_SparkCost:decimal ()
        @doc "Returns the amount of STOA that is needed to pay for one Token"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (floor (/ spark-price stoa-pid) stoa-prec)
        )
    )
    (defun URC_SparkRedemptionCost:decimal ()
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) stoa-pid) stoa-prec)
        )
    )
    (defun URC_CustomSparkRedemptionCost:decimal (custom-stoa-pid:decimal)
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) custom-stoa-pid) stoa-prec)
        )
    )
    (defun URC_AccountRedemptionAmount:decimal (account:string)
        @doc "Returns Account Redemption Amount"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account))
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (rc:decimal (URC_SparkRedemptionCost))
            )
            (floor (* supply rc) stoa-prec)
        )
    )
    (defun URC_SparkAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) spark-price)
                (floor (* (/ spark-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuySparks = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPTF Sparks-out transfer. The deposit is \
            \ amount-independent; the transfer cost depends only on the DPTF fee class of Sparks."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (spark-id:string (UR_SparkID))
                (pid:decimal (at "pid" (URC_SparkAmountCosts sparks-amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer spark-id pid type false))
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_Transfer spark-id DEMIPAD|SC_NAME buyer (dec sparks-amount))))
        )
    )
    (defun INFO_BuySparks:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool)
        @doc "Cost preview for the SPARK|C_BuySparks pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuySparks (Sigma of the two Talos ops). Launchpad \
            \ ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared \
            \ in the description as the good being bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (spark-id:string (UR_SparkID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_SparkAmountCosts sparks-amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} Sparks for {} (pure-citizen, Sigma-billed)." [sparks-amount spark-id sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.SPARK|C_BuySparks (the sole gas-funded path)." ]
                [ (format "Acquired {} {} Sparks." [sparks-amount spark-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuySparks buyer sparks-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Pure-citizen IGNIS cost preview for C_Redem*Sparks = Sigma of the six SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): wSTOA transfer + freeze + wipe + unfreeze + remint + VST re-freeze. \
            \ Per-op costs are fee-class based; fed the same redemption-quantity the exec receives."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer wstoa-id redemption-payer account-to-redeem redemption-value))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_WipeSlim spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint spark-id DEMIPAD|SC_NAME false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-VST::URCi_Freeze DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)) ])
        )
    )
    (defun INFO_RedeemSparks:object{OuronetInfoV2.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Cost preview for the SPARK|C_RedemAll/FewSparks pure-citizen redeem (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_RedeemSparks (Sigma of the six Talos ops). No \
            \ protocol STOA fee; the redeem RETURNS wSTOA to the account (a refund, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Redeem {} {} from {} (pure-citizen, Sigma-billed)." [redemption-quantity spark-id sa])
                  (format "Returns {} {} to the account (a refund, not a cost)." [redemption-value wstoa-id]) ]
                [ (format "Redeemed {} {} for {} {}." [redemption-quantity spark-id redemption-value wstoa-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_RedeemSparks redemption-payer account-to-redeem redemption-quantity))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_RedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_SparkRedemptionCost))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::DPTF|C_Transfer patron redemption-payer account-to-redeem wstoa-id redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::DPTF|C_WipeSlim patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME spark-id redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::VST|C_Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CustomRedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_CustomSparkRedemptionCost custom-stoa-pid))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::DPTF|C_Transfer patron redemption-payer account-to-redeem wstoa-id redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::DPTF|C_WipeSlim patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron (DPTF.UR_Konto spark-id) account-to-redeem spark-id false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME spark-id redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::VST|C_Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal)
        @doc "PURE CITIZEN buy. Composes two SOVEREIGN Talos ops — DEMIPAD|C_Deposit (buyer STOA -> \
            \ Launchpad) then DPTF|C_Transfer (Sparks Launchpad -> buyer) — each self-collecting IGNIS \
            \ on <patron>. A citizen cannot fold cumulators (no permission for the bare uncollected \
            \ core funcs), so IGNIS is billed Sigma-wise (once per op). <max-cost> is the buyer's dollar \
            \ slippage ceiling (sentinel < 0 = slippage off). Preview: URCi_BuySparks / INFO_BuySparks."
        (with-capability (SPARK|C>BUY sparks-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    ;;
                    (spark-id:string (UR_SparkID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_SparkAmountCosts sparks-amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer spark-id pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — Sparks from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME buyer spark-id (dec sparks-amount) true)
                (format "User {} succesfuly acquired {} {} Tokens" [sb sparks-amount spark-id])
            )
        )
    )
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_RedeemSparks patron redemption-payer account-to-redeem supply)
            )
        )
    )
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_CustomRedeemSparks patron redemption-payer account-to-redeem supply custom-stoa-pid)
            )
        )
    )
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_RedeemSparks patron redemption-payer account-to-redeem redemption-quantity)
        )
    )
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_CustomRedeemSparks patron redemption-payer account-to-redeem redemption-quantity custom-stoa-pid)
        )
    )

)

;; --- tables for 01_Spark.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SPARK|T|Properties)

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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
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
                (ref-TS02-C1::DPDC|C_MultiTransfer patron DEMIPAD|SC_NAME buyer [asset] [true] [[nonce]] [[amount]] true)
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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
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
                (ref-TS02-C1::DPDC|C_MultiTransfer patron DEMIPAD|SC_NAME buyer [asset] [true] [[nonce]] [[amount]] true)
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

;; ===== 2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact ===========
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface StoicPayV3




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
    (defun UR_KpayID:string ())
    (defun UR_KpayLeft:decimal ())
    (defun UR_KpayPID:decimal (offset:decimal))
    (defun UR_GetPeriod:integer ())
    (defun URv_PeriodAllocation:decimal (period:integer))
    (defun UR_PAD_LEDGER_ACCOUNT:string ())
    ;;
    ;;  [URC]
    ;;
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer offset:decimal))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool))
    (defun INFO_BuyStoicPay:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-STOICPAY GOV
    @doc "StoicPay sale mechanics (DEMIPAD). UI read aggregate lives in DPL-UR as URC_0030_StoicPay."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements StoicPayV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_KPAY                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|KPAY_ADMIN)))
    (defcap GOV|KPAY_ADMIN ()                           (enforce-guard GOV|MD_KPAY))
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
    ;;Team allocation recipients (LIVE deployed set — identical to on-chain ouronet-ns.DEMIPAD-STOICPAY).
    ;;60% team share = COMPANY (30%) + VENTURE1..4 (7.5% each) = 1.5x the buyer amount per sale (40/60 split;
    ;;250M end supply). The REPL fixture creates these five accounts so the buy-side MultiBulkTransfer resolves.
    (defun GOV|COMPANY ()                               (at 0 ["Ѻ.ъΦĞρλξäFφVПÉЫÍЬÙGěЭыц¥ĄïsKзŤ8£ΞδĚãlÍŃÝþáΩĘΞȘĎĄЛδůÖîĎĄΠДÈrЪqyςkѺδKłĄρțØänÀŚxчtÍςÃΩ₳9ť7ÇяŠΛδÓdťЗΞŻÛπΩ∇цжuлiØłÛáYπOкæáYoùχmŒуŞËЛΞьPĘáÛÝaBÑБžя₳țςhrĚë₱dÑLÞЛεñeîÓУłëΦ"]))
    (defun GOV|VENTURE1 ()                              (at 0 ["Ѻ.CЭΞŸNGúůρhãmИΘÛ¢₳šШдìAÚwŚGýηЗПAÊУÔȘřŽÍζЗηmΔφDmcдΛъ₳tĂýăŮsПÞ$öœGθeBŽvąαÃfçл¢ĎĆď$şbsЦэΘNÄëÍĂνуãöž¥àZjÆůšÁœôñχŽâЩåτâн4μфAOçĎΓuЗŮnøЙãĚè6Дżîþż$цÑûρψŻïZÉλûæřΨeèÎígςeL"]))
    (defun GOV|VENTURE2 ()                              (at 0 ["Ѻ.ĄÀтмωωàŹČлďÜhÍηЛνÙνûĘõțЫåÒÛHážNÍЧψξïžŹЬΛξП¥ЮςĄEйNĄЧ9óпиÃЗ2äÔвœ₿£ČóΩÞдréě7νшDÅЬXтBørŸĂBςąЙęìvÆлμЛáΩγĘЗôåУțτжéδÚνpÍżȘĘï4ąŹȘkφNθþÀωΞÀWžIи5ь€ÊOôΣëñэÔÿνÜw1юÔzźцξńѺfś"]))
    (defun GOV|VENTURE3 ()                              (at 0 ["Ѻ.ìѺďΘčμЮÚşŁì92lźřWмPòíFùЛgßCÊȚδğďŘTπΠrπмЮ6ŁYŘэHóęÀSăλьПO€ЮrØòш2ΓεîțůOÂŁŻДÍ¥ôWxí4ïçдå₿ЙÒεЗzÝăÚÆπБцìcÕyьΘæěЖù₱фщđÝKÚßzUÉÍЬŒΠYvVŻUЫýčWŘвůćCČΦú2ãбşèуÓçË€ïmôrýмúüÄЬáó"]))
    (defun GOV|VENTURE4 ()                              (at 0 ["Ѻ.BPΩÉ5eønDMRзΣÛł4áÃÄПNΩFзÌõãBЙĞńŒμЗŽτЯÈЙÓDд5țσÆďΔÂиĂqtVŒ3ЦтòȚиåâ8юđhýZNтě∇ŹÀĂkÖѺζEğOüбĆ6мθÈSoш∇ŠmHŒДiÖĎďнÈèTuĎSжğĎЫěIťčç$ÇíżùàĐZξÁτÞFxPÎÎπÿWÖàыДŤγEψàýÔу€эjĆ2ĎżÃς"]))

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
    (defcap P|KPAY|CALLER ()
        true
    )
    (defcap P|PAD-KPAY|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|KPAY|CALLER))
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
        (with-capability (GOV|KPAY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|KPAY_ADMIN)
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
        (with-capability (GOV|KPAY_ADMIN)
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
        (with-capability (GOV|KPAY_ADMIN)
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
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|KPAY|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "KPAY|RemoteGov"
                (create-capability-guard (P|PAD-KPAY|REMOTE-GOV))
            )
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst KPAY|INFO                                 (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema KPAY|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable KPAY|T|Properties:{KPAY|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap KPAY|C>BUY (kpay-amount:integer)
        @event
        (let
            (
                (KpayID:string (UR_KpayID))
                (remaining-supply:decimal (UR_KpayLeft))
                (amount:decimal (dec kpay-amount))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (kpay-price:decimal
                    (if (= future-ten-minute-price -1.0)
                        (UR_KpayPID 0.0)
                        (UR_KpayPID 600.0)
                    )
                )
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            ;;VESTIGIAL SENTINEL. Both the -1.0 branch above and this enforce are dead, and they are
            ;;dead for the same reason: UR_KpayPID is TOTAL and strictly positive. It returns 0.01
            ;;before the sale opens, 1.0 after three years, and floor(0.01 + 0.99*elapsed/3y, 24) in
            ;;between — a value in (0.01, 1.0). It has no failure mode and never yields -1.0, so
            ;;<future-ten-minute-price> can never equal the sentinel, the `if` always takes its else
            ;;branch, and <kpay-price> is always > 0.0. "Kpay Sale has Concluded!" can never be the
            ;;reason a buyer is refused; the sale's real terminator is the supply check on the line
            ;;above. Left in place rather than deleted because removing it changes a live sale
            ;;contract for no functional gain — but it is documented here so nobody reads it as an
            ;;active gate. Backed by REPL/modules/LAUNCHPAD.repl <<TX-SPK-KPAY-PRICE>>, which pins
            ;;the price function's bounds across the whole domain instead.
            ;;UNREACHABLE
            (enforce (> kpay-price 0.0) "Kpay Sale has Concluded!")
            (compose-capability (P|PAD-KPAY|REMOTE-GOV))
            (compose-capability (P|KPAY|CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["StoicPayV3"]))
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
    (defun UR_KpayID:string ()
        (at "asset-id" (read KPAY|T|Properties KPAY|INFO ["asset-id"]))
    )
    (defun UR_GetPeriod:integer ()
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (at "block-time" (chain-data)))
                (three-years:decimal 94608000.0)
                (period-length:decimal (/ three-years 25.0))  ; 3,784,320 seconds
                (elapsed:decimal (diff-time present-tm starting-tm))  ; Seconds between present and start
            )
            (if (< elapsed 0.0)
                -1 ;;Before Starting Time
                (if (>= elapsed three-years)
                    0 ;;After three years
                    (if (= elapsed 0.0)
                        1
                        (let
                            (
                                (p:integer (ceiling (/ elapsed period-length)))
                            )
                            (if (> p 25)
                                25
                                p
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URv_PeriodAllocation:decimal (period:integer)
        (enforce (and (>= period -1) (<= period 25)) "Invalid Period")
        (if (or (= period -1) (= period 0))
            0.0
            (let
                (
                    (a1:decimal 4.4)
                    (ak:decimal (- 4.5 (* 0.1 (dec period))))
                    (sk:decimal (* (/ (dec period) 2.0)(+ a1 ak)))
                )
                (+ 20000000 (* sk 1000000.0))
            )
        )
    )
    (defun UR_KpayLeft:decimal ()
        @doc "Computes how much KPAY can still be bought this Period"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (KpayID:string (UR_KpayID))
                (resident-amount:decimal (ref-DPTF::UR_AccountSupply KpayID DEMIPAD|SC_NAME))
                (left-for-sale:decimal (* 0.4 resident-amount))
                (sold:decimal (- 100000000.0 left-for-sale))
                ;;
                (period:integer (UR_GetPeriod))
                (period-allocation:decimal (URv_PeriodAllocation period))
            )
            (if (or (= period -1)(= period 0))
                0.0
                (- period-allocation sold)
            )
        )
    )
    (defun UR_KpayPID:decimal (offset:decimal)
        @doc "Offset is used to compute the time with a future offset in seconds"
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (add-time (at "block-time" (chain-data)) offset))
                (elapsed-tm:decimal (diff-time present-tm starting-tm))
                (three-years:decimal 94608000.0)
            )
            (if (<= elapsed-tm 0.0)
                0.01
                (if (> elapsed-tm three-years)
                    1.0
                    (floor (+ 0.01 (* 0.99 (/ elapsed-tm three-years))) 24)
                )
            )
        )
    )
    (defun UR_PAD_LEDGER_ACCOUNT:string ()
        @doc "Launchpad ledger account (DPTF holder) for StoicPay inventory."
        DEMIPAD|SC_NAME
    )
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer offset:decimal)
        @doc "Computes Prices;"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (KpayID:string (UR_KpayID))
                (Kpay-price:decimal (UR_KpayPID offset))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) Kpay-price)
                (floor (* (/ Kpay-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — returns the coin.TRANSFER caps the UI signs, padded by \
            \ (1 + slippage/100). An offset of 15 minutes (900.0 s) computes the values."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::URC_Acquire buyer KpayID pid type slippage)
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds \
            \ A price of 10 minutes in the future is used to compute price.\
            \ If there are less than 10 minutes left, the present price is used."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)

                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (KpayID:string (UR_KpayID))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (present-price:decimal (UR_KpayPID 0.0))
                (kpay-price:decimal
                    (if (= present-price future-ten-minute-price)
                        present-price
                        future-ten-minute-price
                    )
                )
                (still-for-sale:integer (floor (UR_KpayLeft)))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:integer 
                    (if (= kpay-price -1.0)
                        0
                        (floor (/ client-stoa-value-in-dollarz kpay-price))
                    )
                )
                (period:integer (UR_GetPeriod))
            )
            (if (or (= period -1) (= period 0))
                0
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuyStoicPay = Sigma of the three SOVEREIGN Talos \
            \ ops' IGNIS (each self-collects): DEMIPAD deposit + DPTF StoicPay-out transfer + DPTF \
            \ multi-bulk venture-split transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (KpayID:string (UR_KpayID))
                (pid:decimal (at "pid" (URC_KpayAmountCosts kpay-amount 0.0)))
                (type:integer (if iz-native 0 1))
                (ten-p:decimal (* 0.25 (dec kpay-amount)))
                (twenty-p:decimal (* 0.5 (dec kpay-amount)))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer KpayID pid type false))
               (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount)))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_MultiBulkTransferCumulator [KpayID] DEMIPAD|SC_NAME
                          [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                          [[twenty-p ten-p ten-p ten-p ten-p]]))))
        )
    )
    (defun INFO_BuyStoicPay:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool)
        @doc "Cost preview for the KPAY|C_BuyStoicPay pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuyStoicPay (Sigma of the three Talos ops). \
            \ Launchpad ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) \
            \ is declared as the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (KpayID:string (UR_KpayID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} StoicPay for {} (pure-citizen, Sigma-billed)." [kpay-amount KpayID sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.KPAY|C_BuyStoicPay (the sole gas-funded path)." ]
                [ (format "Acquired {} {} StoicPay." [kpay-amount KpayID]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuyStoicPay buyer kpay-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price; the \
            \ UI does NOT sign them and warns the buyer the mined price may differ."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer KpayID pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> is the buyer's slippage ceiling in dollars (Variant 1); pass a sentinel below \
            \ zero for the slippage-off path (Variant 2)."
        (with-capability (KPAY|C>BUY kpay-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    ;;
                    (KpayID:string (UR_KpayID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (ten-p:decimal (* 0.25 (dec kpay-amount)))
                    (twenty-p:decimal (* 0.5 (dec kpay-amount)))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                    (present-kpay-price:decimal (UR_KpayPID 0.0))
                    (paid:decimal (at "wstoa" costs))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer KpayID pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — StoicPay from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME buyer KpayID (dec kpay-amount) true)
                ;;3] SOVEREIGN DPTF multi-bulk transfer Talos op — venture split (company 50% + 4 ventures); self-collects IGNIS
                (ref-TS01-C1::DPTF|C_MultiBulkTransfer patron DEMIPAD|SC_NAME [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]] [KpayID] [[twenty-p ten-p ten-p ten-p ten-p]])
                (if iz-native
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} Native STOA"
                        [sb kpay-amount present-kpay-price paid]
                    )
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} OWS"
                        [sb kpay-amount present-kpay-price paid]
                    )
                )
            )
        )
    )

)

;; --- tables for 04_STOICPAY.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table KPAY|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact ============
(module STOAICO GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_STOAICO                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|STOAICO_ADMIN)))
    (defcap GOV|STOAICO_ADMIN ()                        (enforce-guard GOV|MD_STOAICO))
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
        (with-capability (GOV|STOAICO_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|STOAICO|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "STOAICO|RemoteGov"
                (create-capability-guard (P|PAD-STOAICO|REMOTE-GOV))
            )
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst STOAICO|INFO                              (CT_Info))
    (defconst STOA_PREC                                 12)
    ;;{3.2}  schemas
    ;;
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
    ;;{3.3}  tables
    (deftable STOAICO|T|User:{UserContributionSchema})          ;;Key = <Ouronet-Account>
    (deftable STOAICO|T|General:{GeneralContributionSchema})    ;;Key = <STOAICO|INFO>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap INIT-ICO-DISTRIBUTION ()
        @event
        (compose-capability (SECURE))
        (compose-capability (GOV))
    )
    (defcap STOAICO|INJECT (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|ADD-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (v-usd-id:string (UR_Global10))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|REMOVE-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (compose-capability (STOAICO|ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (v-usd-id:string (UR_Global10))
                (user-score:decimal (UR_User1 account))
            )
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (enforce 
                (<= v-usd-amount user-score) 
                (format "Removing {} from Account {} exceeds its existing balance" [v-usd-amount account])
            )
        )
    )
    (defcap STOAICO|REDEEM-CONTRIBUTION (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun CT_Info ()                                   (at 0 ["StoaIcoInformation"]))
    ;;
    (defun UDC_UserData:object{UserContributionSchema}
        (a:decimal b:integer c:decimal d:decimal f:integer e:string)
        {"dollarz"              : a
        ,"urstoa-earned"        : b
        ,"last-rps"             : c
        ,"pending-rewards"      : d
        ,"last-collected-round" : f
        ,"owner-id"             : e}
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
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
    (defun URC_IzDustSweepClaimant:bool (account:string)
        @doc "Is ACCOUNT the one remaining unclaimed claimant, and therefore the one the dust \
            \ sweep should pay the whole vault to? Three conditions, all O(1): exactly one \
            \ unclaimed position remains; this account is a real staker; and this account has \
            \ not already collected in the current distribution-round. \
            \ ADDED 2026-09-14. URC_ClaimableRewards used to test only the FIRST of the three, \
            \ so it answered a question about the VAULT and used it as an answer about the \
            \ ACCOUNT -- see the comment there."
        (fold (and) true
            [
                (= (UR_Global7) 1)
                (> (UR_User1 account) 0.0)
                (< (UR_User5 account) (UR_Global11))
            ]
        )
    )
    (defun URC_ClaimableRewards (account:string)
        @doc "Computes Claimable Reward of Account. When exactly one unclaimed position remains, \
            \ that claimant is paid the WHOLE remaining vault -- a dust sweep, so rounding \
            \ residue is never stranded."
        ;;DEFECT FIXED 2026-09-14 (red team RT-E-001). This read:
        ;;
        ;;    (if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
        ;;
        ;;<UR_Global7> is unclaimed-count -- a property of the VAULT. The branch asked "is exactly
        ;;one claimant left?" and never "is THIS account that claimant?", so it offered the entire
        ;;vault to ANY caller whenever the count happened to be 1. The guard tested a global and
        ;;returned a per-account figure.
        ;;
        ;;It was reachable by a LEGITIMATE admin action, not an attack: unclaimed-count is set to
        ;;nzs-count only at inject, so recording a late contribution moves nzs-count and leaves
        ;;unclaimed-count behind. Measured at RedTeam/[RT-E]_Sequencing.repl <<RT-E-001>> --
        ;;counters diverged to 1 vs 3, and an account owed 0.000000000000 was offered
        ;;690.525983513596.
        ;;
        ;;NO THEFT WAS POSSIBLE, and the reason is worth keeping: A_Stake stamps a new contributor's
        ;;<last-collected-round> to the CURRENT round, and the collect capability enforces
        ;;(< last-collected-round distribution-round) -- a newcomer is born already-collected for
        ;;the round they joined. So the money never moved. But this reader also feeds URCi_Collect
        ;;and INFO_Collect, which told such an account it would receive the whole vault; and the
        ;;theft was prevented by a stamp written in a DIFFERENT function, with nothing connecting
        ;;the two. A number that is wrong everywhere except where one unrelated guard happens to
        ;;stop it is a defect, not a defence.
        (if (URC_IzDustSweepClaimant account)
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
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
            )
            ;;PREVIEW/EXEC PARITY FIX (2026-09-17). The mint leg used to sit OUTSIDE this `if`,
            ;;added unconditionally — exactly where `XI_CollectFor`'s mint used to sit before the
            ;;2026-09-14 vault-deadlock fix moved it INSIDE the `(!= urSTOA-supply 0.0)` guard.
            ;;That fix repaired the EXECUTOR and left this READER alone, so the two disagreed on
            ;;every collect after an account's first — and the first collect is what zeroes urSTOA,
            ;;which makes the disagreeing case the NORMAL one, not an edge.
            ;;
            ;;Measured before the fix: preview 88.0 (mint 87.0 + transfer 1.0) for an operation
            ;;that charged 1.0. An 88x overstatement in the number a client is shown BEFORE
            ;;committing. Pinned by REPL/RedTeam/[RT-K]_PreviewParity.repl <<RT-K-008>>.
            (if (!= urSTOA-supply 0.0)
                (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint urSTOA-id DEMIPAD|SC_NAME false))
                   (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                       (ref-TFT::URCi_MultiTransferCumulator [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account [wSTOA-supply urSTOA-supply])))
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_Transfer wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply)))
        )
    )
    (defun INFO_Collect:object{OuronetInfoV2.ClientInfo} (patron:string account:string)
        @doc "Cost preview for the STOAICO|C_Collect pure-citizen reward collect (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_Collect. No protocol STOA fee; the collect DELIVERS \
            \ wSTOA + urSTOA rewards to the account (a payout, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_CollectFor:string (patron:string account:string)
        @doc "#1C shared settle+deliver core: pays <account> its OWN wSTOA (its RPS delta, or the whole \
            \ remaining wstoa-supply when it is the round's last unclaimed staker — the dust sweep) plus its \
            \ urSTOA, then stamps it collected for the current distribution-round and decrements \
            \ unclaimed-count. Used by C_Collect (self-collect, gated by STOAICO|REDEEM-CONTRIBUTION) and by \
            \ the admin flush (push-collect on behalf of a straggler, gated by STOAICO|FLUSH). SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            ;;1]Collect wSTOA and URSTOA Rewards — delivered to <account>, the rightful owner
            ;;
            ;;VAULT-DEADLOCK FIX (2026-09-14). The urSTOA mint used to sit ABOVE this `if`,
            ;;UNCONDITIONAL, while only the DELIVERY was guarded on (!= urSTOA-supply 0.0). But a
            ;;zero-amount mint is refused: C_Mint -> DPTF|C>MINT -> DPTF|C>CREDIT -> UEV_Amount ->
            ;;(enforce (> amount 0.0)). And step 6 below (XI_ResetUrstoaEarned) zeroes the account's
            ;;urSTOA entitlement as part of its FIRST collect. So on the account's SECOND
            ;;distribution-round -- when a fresh A_Inject has advanced <current-rps> and real wSTOA
            ;;IS owed -- the whole transaction aborted on the mint.
            ;;
            ;;It was a DEADLOCK, not a nuisance, because all three exits share this core and shut
            ;;together: C_Collect aborts; AA_FlushUncollected maps XI_CollectFor over the stragglers
            ;;and fails identically; and A_Inject refuses to open a new round while
            ;;(!= unclaimed-count 0). The vault stops paying and cannot be restarted from ANY
            ;;entrypoint. IGNIS::XB_MoveDalosFuel documents this exact lesson in its own @doc --
            ;;it simply was not applied here.
            ;;
            ;;The fix is the guard the delivery already had, moved to cover the mint as well. The
            ;;wSTOA leg is guarded on the same principle: a staker whose RPS delta is zero has
            ;;nothing to transfer either, and a zero transfer is refused by the same UEV_Amount.
            ;;Steps 2-6 still run in every branch, which is what actually clears the straggler out
            ;;of <unclaimed-count> and lets the next round open.
            (if (!= urSTOA-supply 0.0)
                (do
                    (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME urSTOA-id urSTOA-supply false)
                    (if (!= wSTOA-supply 0.0)
                        (ref-TS01-C1::DPTF|C_MultiTransfer patron DEMIPAD|SC_NAME account [wSTOA-id urSTOA-id] [wSTOA-supply urSTOA-supply] true)
                        (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME account urSTOA-id urSTOA-supply true)
                    )
                )
                (if (!= wSTOA-supply 0.0)
                    (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME account wSTOA-id wSTOA-supply true)
                    "STOAICO: nothing owed this round -- settle-only, no delivery"
                )
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
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetPendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : 0.0}
        )
    )
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUserRPS (account:string new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MarkCollected (account:string)
        @doc "#1C: stamp the account as having collected the CURRENT distribution-round."
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-collected-round" : (UR_Global11)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdatePendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : (URC_AvailableRewards account)}
        )
    )
    ;;D-Vault
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultRPS (new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"current-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUnclaimedCount ()
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"unclaimed-count" : (UR_Global5)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementDistributionRound ()
        @doc "#1C: advance the vault to the next distribution-round (called by A_Inject)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"distribution-round" : (+ 1 (UR_Global11))}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SetZombieRewards (amount:decimal)
        @doc "#5M: set the escrowed zombie-rewards (escrow adds to it; a flush zeroes it)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"zombie-rewards" : amount}
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUrstoaEarned (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"urstoa-earned"    : 0}
        )
    )
    ;;Protection: Class 2 — SECURE
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
    ;;{5.7}  User [A/C]
    ;;
    (defun A_InitialiseDistributionVault (account:string)
        @doc "Initialises the Distribuition Vault by creating and filling all necesary prerequisites"
        (with-capability (INIT-ICO-DISTRIBUTION)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (dptf-ids:list 
                        (ref-TS01-C1::DPTF|C_Issue account account
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
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto vusd-id) DEMIPAD|SC_NAME vusd-id true)
                (ref-TS01-C1::DPTF|C_ToggleBurnRole account (DPTF.UR_Konto vusd-id) DEMIPAD|SC_NAME vusd-id true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto wstoa-id) account wstoa-id true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto wurstoa-id) DEMIPAD|SC_NAME wurstoa-id true)
                ;;4]Mint 10 mil wSTOA (injection will follow after ICO concludes)    
                (ref-TS01-C1::DPTF|C_Mint account account wstoa-id 10000000.0 true)
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
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
                        (ref-TS01-C1::DPTF|C_Transfer patron account DEMIPAD|SC_NAME wSTOA-ID wstoa-amount true)
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
                        (ref-TS01-C1::DPTF|C_Transfer patron account DEMIPAD|SC_NAME wSTOA-ID wstoa-amount true)
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
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Mint the v-USD amount to the <DEMIPAD|SC_NAME>
                (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME v-usd-id v-usd-amount false)
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
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (remaining:decimal (- user-score v-usd-amount))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Burn the v-USD amount from the <DEMIPAD|SC_NAME> that is to be removed
                (ref-TS01-C1::DPTF|C_Burn patron DEMIPAD|SC_NAME v-usd-id v-usd-amount)
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
    (defun C_Collect (patron:string account:string)
        @doc "Self-collect from the distribution Vault — once per distribution-round, by the <account> owner. \
            \ A new A_Inject opens the next round and re-enables collection (the RPS delta since last collect)."
        (with-capability (STOAICO|REDEEM-CONTRIBUTION account)
            (XI_CollectFor patron account)
        )
    )

)

;; --- tables for 05_STOAICO.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table STOAICO|T|User)
;; (create-table STOAICO|T|General)

;; ===== 2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact =====================
;; Deploy: load THIS file — interface(s) + module ship together. LAST module of the
;; launchpad: the CITIZEN Talos. Deployed AFTER the citizen sales (Spark..StoicIco)
;; and after the sovereign launchpad Talos (1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact).
;;
;; Holds ALL citizen user wrappers in one place so they can be granted free gas-station
;; access. The kicker: the citizen C_ funcs stay callable directly from their own module,
;; but ONLY these Talos wrappers are the gas-funded path — a direct citizen-module call
;; would not have its gas paid.
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface CitizenLaunchpadTalosV1
    @doc "Exposes the Ouronet Stage Two CITIZEN launchpad user Client Functions (sole gas-funded path)."

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
    ;;  [C]
    ;;
    (defun SPARK|C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal))
    (defun SPARK|C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string))
    (defun SPARK|C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun SNAKES|C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))
    (defun CUSTODIANS|C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))
    (defun KPAY|C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal))
    (defun STOAICO|C_Collect (patron:string account:string))

)
;;
(module TS02-CPAD GOV
    @doc "TALOS Stage 2 CITIZEN Launchpad User Functions (Spark/Snakes/Custodians/StoicPay/StoicIco)"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements CitizenLaunchpadTalosV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-CPAD                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-CPAD_ADMIN)))
    (defcap GOV|TS02-CPAD_ADMIN ()                      (enforce-guard GOV|MD_TS02-CPAD))
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
        (with-capability (GOV|TS02-CPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-CPAD_ADMIN)
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
        (with-capability (GOV|TS02-CPAD_ADMIN)
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
        (with-capability (GOV|TS02-CPAD_ADMIN)
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
        @doc "Registers THIS citizen Talos' summoner guard as a trusted IMP peer of the per-sale \
            \ citizen modules it wraps (Spark/Snakes/Custodians/StoicPay/StoicIco), so their P|UEV_IMC \
            \ recognizes calls from this Talos."
        (let
            (
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|SPARK:module{OuronetPolicyV2} DEMIPAD-SPARK)
                (ref-P|SNAKES:module{OuronetPolicyV2} DEMIPAD-SNAKES)
                (ref-P|CUSTODIANS:module{OuronetPolicyV2} DEMIPAD-CUSTODIANS)
                (ref-P|KPAY:module{OuronetPolicyV2} DEMIPAD-STOICPAY)
                (ref-P|STOAICO:module{OuronetPolicyV2} STOAICO)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            ;;register into the sale modules (their P|UEV_IMC recognizes this Talos)
            (ref-P|SPARK::P|A_AddIMP mg)
            (ref-P|SNAKES::P|A_AddIMP mg)
            (ref-P|CUSTODIANS::P|A_AddIMP mg)
            (ref-P|KPAY::P|A_AddIMP mg)
            (ref-P|STOAICO::P|A_AddIMP mg)
            ;;register into TS01-A so the wrappers' XB_DynamicFuelSTOA gas-station refuel passes P|UEV_IMC
            (ref-P|TS01-A::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun SPARK|C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Pass a sentinel < 0 for slippage \
            \ off (Variant 2, live price via install-capability, UI-warned)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_BuySparks patron buyer sparks-amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun SPARK|C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_RedemAllSparks patron redemption-payer account-to-redeem)
            )
        )
    )
    (defun SPARK|C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-SPARK:module{SparksV2} DEMIPAD-SPARK)
                )
                (ref-SPARK::C_RedemFewSparks patron redemption-payer account-to-redeem redemption-quantity)
            )
        )
    )
    ;;
    (defun SNAKES|C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-SNAKES:module{SaleSnakesV2} DEMIPAD-SNAKES)
                )
                (ref-SNAKES::C_Acquire patron buyer nonce amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun CUSTODIANS|C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-CUSTODIANS:module{SaleCustodiansV2} DEMIPAD-CUSTODIANS)
                )
                (ref-CUSTODIANS::C_Acquire patron buyer nonce amount iz-native max-cost)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun KPAY|C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> = buyer's dollar slippage ceiling (Variant 1). Sentinel < 0 = slippage off (Variant 2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-KPAY:module{StoicPayV3} DEMIPAD-STOICPAY)
                    (acquisition-text:string (ref-KPAY::C_BuyStoicPay patron buyer kpay-amount iz-native max-cost))
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                acquisition-text
            )
        )
    )
    (defun STOAICO|C_Collect (patron:string account:string)
        @doc "Gas-funded entry for the StoicIco reward self-collect. No STOA inflow (it is a payout), so \
            \ no XB_DynamicFuelSTOA refuel. Cost preview: STOAICO.URCi_Collect / STOAICO.INFO_Collect."
        (with-capability (P|TS)
            (STOAICO.C_Collect patron account)
        )
    )

)

;; --- tables for 99_TS02-CPAD.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

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
        ;;    (ref-IGNIS::XE_CollectIgnis patron ico)
        ;;    (ref-IGNIS::XE_CollectStoa patron (ref-IGNIS::UC_StoaPrice "issue-shareholder"))
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
        ;;`XE_CollectStoa patron (URCi_IssueCollectionStoa son)` at `04_DPDC-I.pact:502`, nested
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

;; ===== 2_CITIZEN/4_BunniesMinter/02_KBunnies.pact ==================
(module KBN GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;
    (defconst GOV|MD_KBN                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|DPL_NFT_ADMIN)))
    (defcap GOV|DPL_NFT_ADMIN ()                        (enforce-guard GOV|MD_KBN))
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
    (defconst B                                         (CT_Bar))
    ;;
    (defconst R                                         100.0)  ;;Native Bunny Royalty
    (defconst IR-L                                      1600.0) ;;Legendary Ignis Royalty
    (defconst IR-C                                      20.0)   ;;Common Ignis Royalty
    ;;
    (defconst T true)
    (defconst F false)
    ;;
    (defconst D-L "Golden Bunnies, the most precious Bunnies in the whole of Existance, makes the dreams come true for their Owners")
    (defconst D-C "Born on MultiversX, fled to Ouronet, ready for Unity, primed for Cryptoplasm, the Bunny Collection is here to make your dreams come true.")
    ;;
    (defconst TYPE
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_URI|Type T F F F F F F)
        )
    )
    (defconst ZD
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_ZeroURI|Data)
        )
    )
    ;;{3.2}  schemas
    ;;
    ;;
    (defschema BunnyMetaData
        Rarity:string
        Background:string
        Clothes:string
        Ear:string
        Eyes:string
        Hats:string
        Mouth:string
    )
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
    (defun UDC_MetaData:object{BunnyMetaData} (a:[string])
        {"Rarity"       : (at 0 a)
        ,"Background"   : (at 1 a)
        ,"Clothes"      : (at 2 a)
        ,"Ear"          : (at 3 a)
        ,"Eyes"         : (at 4 a)
        ,"Hats"         : (at 5 a)
        ,"Mouth"        : (at 6 a)
        }
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IpfsLink:string (starting-position:integer idx:integer small-or-big:bool)
        (let
            (
                (ipfs:string "https://ipfs.io/ipfs/QmYjHPWPxCeHGu9vgYUbzjmWo34A2z3CNuYmU6MEzgUSzP/")
                (type:string (if small-or-big "512x512" "FULL"))
                (folder:string "/06_DemiBunnies/")
                (number:integer (+ starting-position idx))
                (num-str:string (format "{}" [number]))
                (padded-num:string
                    (if (< number 1000)
                        (if (< number 100)
                            (if (< number 10)
                                (+ "000" num-str)
                                (+ "00" num-str)
                            )
                            (+ "0" num-str)
                        )
                        num-str
                    )
                )
                (jpg:string ".jpg")
            )
            (concat [ipfs type folder padded-num jpg])
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Step01 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 1 70 mdm)
    )
    (defun A_Step02 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 71 70 mdm)
    )
    (defun A_Step03 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 141 70 mdm)
    )
    (defun A_Step04 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 211 70 mdm)
    )
    (defun A_Step05 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 281 70 mdm)
    )
    (defun A_Step06 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 351 70 mdm)
    )
    (defun A_Step07 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 421 70 mdm)
    )
    (defun A_Step08 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 491 70 mdm)
    )
    (defun A_Step09 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 561 70 mdm)
    )
    (defun A_Step10 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 631 70 mdm)
    )
    (defun A_Step11 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 701 70 mdm)
    )
    (defun A_Step12 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 771 70 mdm)
    )
    (defun A_Step13 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 841 70 mdm)
    )
    (defun A_Step14 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 911 70 mdm)
    )
    (defun A_Step15 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 981 70 mdm)
    )
    (defun A_Step16 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 1051 70 mdm)
    )
    ;;
    (defun A_BunnyRGBSet (patron:string kbn-id:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)
                ;;
                (native-royalty:decimal (* 0.9R))
                (ignis-royalty:decimal (fold (*) 1.0 [0.9 3.0 IR-C]))
                (md:object{DpdcUdcV2.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (ipfs-link-one:string "SmallPhoto-IPFS-Link")
                (ipfs-link-two:string "BiggrPhoto-IPFS-Link")
            )
            ;;Set Class 1
            (ref-TS02-C2::DPNF|C_DefinePrimordialSet
                patron kbn-id
                "Bunny RGB Set"
                1.0
                [
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [26 56 81 110 132 138 148 197 231 242 293 315 318 404 416 490 529 656 676 680 688 693 711 725 799 808 812 823 867 887 926 927 950 965 970 998 1031 1034 1094 1108])
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [29 84 113 120 152 169 193 245 262 296 338 346 357 359 366 380 389 410 426 459 499 513 542 586 607 642 647 653 704 721 724 766 810 813 855 861 912 931 933 1008])
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [9 55 74 111 140 151 157 246 276 300 327 341 376 425 431 435 464 517 530 596 603 630 648 662 671 684 699 731 768 803 830 884 897 907 918 935 996 1014 1032 1096])
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    native-royalty
                    ignis-royalty
                    "Bunny RGB Set"
                    "Red, Green and Blue eyed Bunnies in a Set. 9.0% (90% of Native Bunny Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data ipfs-link-one B B B B B B)
                    (ref-DPDC-UDC::UDC_URI|Data ipfs-link-one B B B B B B)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    ;;
    (defun C_Spawn (patron:string kbn-id:string starting-position:integer number-of-positions:integer mdm:[[string]])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)
                ;;
                (l:integer (length mdm))
                (legendary:[integer] [25 175 274 388 407 873 880 954 1033 1095])
                (iz-legendary ())
            )
            (enforce (= l number-of-positions) "Invalid Number of Positions")
            (ref-TS02-C2::DPNF|C_Create
                patron (DPDC.UR_Verum5 kbn-id false) kbn-id
                (fold
                    (lambda
                        (acc:[object{DpdcUdcV2.DPDC|NonceData}] idx:integer)
                        (let
                            (
                                (element-number:integer (+ starting-position idx))
                                (iz-legendary:bool (contains element-number legendary))
                                (rarity:string (if iz-legendary "Legendary" "Common"))
                                (ignis-royalty:decimal (if iz-legendary IR-L IR-C))
                                (element-name:string (format "{} Bunny #{}" [rarity element-number]))
                                (description:string (if iz-legendary D-L D-C))
                            )
                            (ref-U|LST::UC_AppL acc
                                (ref-DPDC-UDC::UDC_NonceData
                                    R
                                    ignis-royalty
                                    element-name
                                    description
                                    (ref-DPDC-UDC::UDC_MetaData (UDC_MetaData (at idx mdm)))
                                    TYPE
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_IpfsLink starting-position idx true) B B B B B B)
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_IpfsLink starting-position idx false) B B B B B B)
                                    ZD
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length mdm) 1))
                )
            )
        )
    )

)

