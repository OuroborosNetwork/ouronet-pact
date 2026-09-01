;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface OuronetDalosV1
    ;;
    ;;  SCHEMAS
    ;;
    (defschema DPTF|BalanceSchema
        @doc "Schema that Stores Account Balances for DPTF Tokens (True Fungibles)\
            \ Key for the Table is a string composed of: <DPTF id> + BAR + <account> \
            \ This ensure a single entry per DPTF id per account. \
            \ As an Exception OUROBOROS and IGNIS Account Data is Stored at the DALOS Account Level"
        balance:decimal
        frozen:bool
        role-burn:bool
        role-mint:bool
        role-fee-exemption:bool
        role-transfer:bool
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema CanonicalStoaIds
        @doc "#65fL Phase 8b: OURO/WSTOA/SSTOA's canonical token ids, all 3 read together \
            \ in ONE table read (all 3 live on the same DALOS|PropertiesTable row) — \
            \ for a caller (SWPI::URC_WorthWSTOA and its FromRaw/FromGraph siblings) that \
            \ previously needed all 3 identities via 3 separate UR_OuroborosID/ \
            \ UR_WrappedStoaID/UR_SilverStoaID calls, each independently re-reading the \
            \ same row. Field names match DALOS|PropertiesSchema's own field names \
            \ exactly, so the read is a pure passthrough — no renaming/reconstruction."
        gas-source-id:string      ;;OUROBOROS
        wrapped-stoa-id:string    ;;OWS - Ouronet Wrapped Stoa
        silver-stoa-id:string     ;;OSS - Ouronet Silver (Liquid) Stoa
    )
    ;;
    ;;  [GOV]
    ;;
    (defun GOV|DALOS|SC_STOA-NAME ())
    (defun GOV|DALOS|GUARD ())
    ;;
    (defun GOV|Demiurgoi ())
    (defun GOV|DalosKey ())
    (defun GOV|AutostakeKey ())
    (defun GOV|VestingKey ())
    (defun GOV|LiquidKey ())
    (defun GOV|OuroborosKey ())
    (defun GOV|SwapKey ())
    (defun GOV|DHVKey ())
    ;;
    (defun GOV|DALOS|SC_NAME ())
    (defun GOV|ATS|SC_NAME ())
    (defun GOV|VST|SC_NAME ())
    (defun GOV|LIQUID|SC_NAME ())
    (defun GOV|OUROBOROS|SC_NAME ())
    (defun GOV|SWP|SC_NAME ())
    (defun GOV|DHV1|SC_NAME ())
    (defun GOV|DHV2|SC_NAME ())
    ;;
    (defun GOV|DALOS|PBL ())
    (defun GOV|ATS|PBL ())
    (defun GOV|VST|PBL ())
    (defun GOV|LIQUID|PBL ())
    (defun GOV|OUROBOROS|PBL ())
    (defun GOV|SWP|PBL ())
    (defun GOV|DHV|PBL ())
    ;;
    (defun DALOS|Info ())
    (defun DALOS|VirtualGasData ())
    ;;
    ;;
    ;;  [UR]
    ;;
    ;;  [0]     DALOS|StoaLedger:{DALOS|StoaSchema}
    (defun UR_StoaLedger:[string] (stoa:string))
    ;;  [1]     DALOS|PropertiesTable:{DALOS|PropertiesSchema}
    (defun UR_GAP:bool ())
    (defun UR_DemiurgoiID:[string] ())
    (defun UR_UnityID:string ())
    (defun UR_OuroborosID:string ())
    (defun UR_OuroborosPrice:decimal ())
    (defun UR_IgnisID:string ())
    (defun UR_AurynID:string ())
    (defun UR_EliteAurynID:string ())
    (defun UR_WrappedStoaID:string ())
    (defun UR_SilverStoaID:string ())
    ;;#65fL Phase 8b: OURO/WSTOA/SSTOA together, one read instead of 3 — see the
    ;;CanonicalStoaIds schema's own doc.
    (defun UR_CanonicalStoaIds:object{CanonicalStoaIds} ())
    (defun UR_GoldenStoaID:string ())
    (defun UR_UrStoaID:string ())
    (defun UR_DispoType:integer ())
    (defun UR_DispoTDP:decimal ())
    (defun UR_DispoTDS:decimal ())
    (defun UR_OuroAutoPriceUpdate:bool ())
    ;;  [2]     DALOS|GasManagementTable:{DALOS|GasManagementSchema}
    (defun UR_Tanker:string ())
    (defun UR_VirtualToggle:bool ())
    (defun UR_VirtualSpent:decimal ())
    (defun UR_NativeToggle:bool ())
    (defun UR_NativeSpent:decimal ())
    (defun UR_AutoFuel:bool ())
    ;; [3]      DALOS|PricesTable:{DALOS|PricesSchema}
    (defun UR_UsagePrice:decimal (action:string))
    ;; [4]      DALOS|AccountTable:{DALOS|AccountSchema}
    (defun UR_AccountPublicKey:string (account:string))
    (defun UR_AccountGuard:guard (account:string))
    (defun UR_AccountStoa:string (account:string))
    (defun UR_AccountSovereign:string (account:string))
    (defun UR_AccountGovernor:guard (account:string))
    (defun UR_AccountProperties:[bool] (account:string))
    (defun UR_AccountType:bool (account:string))
    (defun UR_AccountPayableAs:bool (account:string))
    (defun UR_AccountPayableBy:bool (account:string))
    (defun UR_AccountPayableByMethod:bool (account:string))
    (defun UR_AccountNonce:integer (account:string))
    (defun UR_Elite (account:string))
    ;;  [4.1]   ELITE Info
    (defun UR_Elite-Class (account:string))
    (defun UR_Elite-Name (account:string))
    (defun UR_Elite-Tier (account:string))
    (defun UR_Elite-Tier-Major:integer (account:string))
    (defun UR_Elite-Tier-Minor:integer (account:string))
    (defun UR_Elite-DEB (account:string))
    ;;  [4.2]   TrueFungible INFO
    (defun UR_TrueFungible:object{DPTF|BalanceSchema} (account:string snake-or-gas:bool))
    (defun UR_TF_AccountSupply:decimal (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleBurn:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleMint:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleTransfer:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountRoleFeeExemption:bool (account:string snake-or-gas:bool))
    (defun UR_TF_AccountFreezeState:bool (account:string snake-or-gas:bool))
    (defun UR_AutonomicRoles:bool (account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_IgnisGasDiscount:decimal (account:string))
    (defun URC_StoaGasDiscount:decimal (account:string))
    (defun URC_GasDiscount:decimal (account:string native:bool))
    (defun URC_SplitSTOAPrices:[decimal] (account:string stoa-price:decimal))
    (defun URC_Transferability:bool (sender:string receiver:string method:bool))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_NotSmartOuronetAccount (account:string))
    (defun UEV_StandardAccOwn (account:string))
    (defun UEV_SmartAccOwn (account:string))
    (defun UEV_EnforceAccountExists (dalos-account:string))
    (defun UEV_EnforceAccountType (account:string smart:bool))
    (defun UEV_EnforceTransferability (sender:string receiver:string method:bool))
    (defun UEV_SenderWithReceiver (sender:string receiver:string))
        ;;
    (defun UEV_StoaCollectionState (state:bool))
    (defun UEV_IgnisCollectionState (state:bool))
    (defun UEV_IgnisCollectionRequirements ())
        ;;
    (defun UEV_Glyph (account:string))
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_TrueFungibleAccount:object{DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
    )
    (defun UDC_BlankTrueFungible:object{DPTF|BalanceSchema} (account:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_EnforceAccountOwnership (account:string))
    ;;
    ;;  [A]
    ;;
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string))
    (defun A_ToggleOAPU (oapu:bool))
    (defun A_ToggleGAP (gap:bool))
    (defun A_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string))
    (defun A_DeployStandardAccount (account:string guard:guard stoa:string public:string))
    (defun A_ToggleGasCollection (native:bool toggle:bool))
    (defun A_SetIgnisSourcePrice (price:decimal))
    (defun A_SetAutoFueling (toggle:bool))
    (defun A_UpdatePublicKey (account:string new-public:string))
    (defun A_UpdateUsagePrice (action:string new-price:decimal))
    ;;
    ;;  [C]
    ;;
    (defun C_ControlSmartAccount
        (account:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
    )
    (defun C_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string))
    (defun C_DeployStandardAccount (account:string guard:guard stoa:string public:string))
    (defun C_RotateGovernor (account:string governor:guard))
    (defun C_RotateGuard (account:string new-guard:guard safe:bool))
    (defun C_RotateStoa (account:string stoa:string))
    (defun C_RotateSovereign (account:string new-sovereign:string))
    ;;
    ;;  [X]
    ;;
    (defun XB_UpdateOuroPrice (price:decimal))
    (defun XE_UpdateTreasury (type:integer tdp:decimal tds:decimal))
    (defun XE_IgnisIncrement (native:bool increment:decimal))
    (defun XE_IncrementOuronetAccountNonce (account:string))
    (defun XE_UpdateElite (account:string amount:decimal))
    (defun XB_UpdateBalance (account:string snake-or-gas:bool new-balance:decimal))
    (defun XE_UpdateFreeze (account:string snake-or-gas:bool new-freeze:bool))
    (defun XE_UpdateBurnRole (account:string snake-or-gas:bool new-burn:bool))
    (defun XE_UpdateMintRole (account:string snake-or-gas:bool new-mint:bool))
    (defun XE_UpdateFeeExemptionRole (account:string snake-or-gas:bool new-fee-exemption:bool))
    (defun XE_UpdateTransferRole (account:string snake-or-gas:bool new-transfer:bool))
)
;;
(module DALOS GOV
    ;;
    ;;Ouronet DALOS Gas-Station
    ;;
    (defcap GAS_PAYER:bool (user:string limit:integer price:decimal)
        (let
            (
                (ref-U|ST:module{OuronetGasStationV1} U|ST)
                (iz-single:bool (contains "exec-code" (read-msg)))
                (exec-lines:[string] (at "exec-code" (read-msg)))
                (n:integer (length exec-lines))
            )
            ;;GENERAL CHECKS
            ;;2]Enforce either GOV|MD_DALOS guard or maximum gas notional 0.02
            (enforce-one
                "Add multiple conditions needed to use Ouronet DALOS Gas-Station"
                [
                    (enforce-guard GOV|MD_DALOS)
                    (enforce-guard (ref-U|ST::UEV_max-gas-notional 0.02))
                ]
            )
            (enforce iz-single "Only for transactions with code")
            ;; Exec-code: 1 = single allowed form; 2 = only both coin.C_; 3 = namespace+IGNIS+(let
            (enforce (>= n 1) "Empty exec code")
            (enforce (fold (or) false [(= n 1) (= n 2) (>= n 3)]) "Exec code must be 1 form, 2 coin forms, or namespace+IGNIS+let (3+ lines)")
            (enforce-one
                "Payable Modules / form count not satisfied"
                [
                    ;; Case 1: single top-level form — coin.C_, ouronet-ns.TS, or ouronet-ns.DSP only
                    (enforce 
                        (fold (and) true
                            [
                                (enforce (= n 1) "Single form required for coin/TS/DSP")
                                (enforce-one "First form must be coin.C_, ouronet-ns.TS, or ouronet-ns.DSP"
                                    [
                                        (enforce (= "(coin.C_" (take 8 (at 0 exec-lines))) "Only STOA coin Client Functions allowed")
                                        (enforce (= "(ouronet-ns.TS" (take 14 (at 0 exec-lines))) "Only TALOS or DSP Modules allowed")
                                        (enforce (= "(ouronet-ns.DSP" (take 15 (at 0 exec-lines))) "Only TALOS or DSP Modules allowed")
                                        (enforce (= "(ouronet-ns.STOAICO." (take 20 (at 0 exec-lines))) "Only STOAICO Modules allowed")
                                    ]
                                )
                            ]
                        )
                        "Ouronet GasStation Case 1 Enforcement Fail!"
                    )
                    ;; Case 2: two top-level forms — both must be coin.C_ (e.g. CreateAccount + Collect)
                    (enforce
                        (fold (and) true
                            [
                                (enforce (= n 2) "Two forms only allowed when both are coin.C_")
                                (enforce (= "(coin.C_" (take 8 (at 0 exec-lines))) "First form must be coin.C_")
                                (enforce (= "(coin.C_" (take 8 (at 1 exec-lines))) "Second form must be coin.C_")
                            ]
                        )
                        "Ouronet GasStation Case 2 Enforcement Fail!"
                    )
                    ;; Case 3: three top-level forms — namespace + IGNIS.C_Collect + (let ...)
                    (enforce
                        (fold (and) true
                            [
                                (enforce (>= n 3) "Three+ lines only for namespace+IGNIS+let pattern")
                                (enforce (= "(namespace \"ouronet-ns\")" (at 0 exec-lines)) "Namespace entry must be (namespace \"ouronet-ns\")")
                                (enforce (= "(IGNIS.C_Collect \"Ѻ." (take 20 (at 1 exec-lines))) "Second form must be IGNIS.C_Collect with UDC")
                                (enforce (= "(IGNIS.UDC_CustomCodeCumulator))" (take -32 (at 1 exec-lines))) "Second form must end with CustomCodeCumulator")
                                (enforce (= "(let" (take 4 (at 2 exec-lines))) "Third form must start with (let")
                            ]
                        )
                        "Ouronet GasStation Case 3 Enforcement Fail!"
                    )
                ]
            )
            ;;
            (compose-capability (DALOS|NATIVE-AUTOMATIC))
        )
    )
    (defun create-gas-payer-guard:guard ()
        GOV|DALOS|GUARD
    )
    ;;
    (implements stoa-ns.gas-payer-v1)
    (implements OuronetPolicyV1)
    (implements OuronetDalosV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_DALOS                  (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_DALOS                  (keyset-ref-guard DALOS|SC_KEY))
    ;;
    (defconst DALOS|SC_KEY                  (GOV|DalosKey))
    (defconst DALOS|SC_NAME                 (GOV|DALOS|SC_NAME))
    (defconst DALOS|SC_STOA-NAME             (GOV|DALOS|SC_STOA-NAME))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|DALOS_ADMIN)))
    (defcap GOV|DALOS_ADMIN ()
        @event
        (enforce-one
            "DALOS Admin not satisfed"
            [
                (enforce-guard GOV|MD_DALOS)
                (enforce-guard GOV|SC_DALOS)
            ]
        )
    )
    (defcap GOV|GAP (gap:bool)
        @event
        (let
            (
                (current-gap:bool (UR_GAP))
            )
            (enforce (!= gap current-gap) (format "GAP is already toggled to {}" [gap]))
            (compose-capability (GOV|DALOS_ADMIN))
        )
    )
    (defcap DALOS|NATIVE-AUTOMATIC  ()
        @doc "Autonomic management of <stoa-konto> of the DALOS Smart Ouronet Account"
        true
    )
    ;;{G3}
    (defun GOV|DALOS|SC_STOA-NAME ()         (create-principal (GOV|DALOS|GUARD)))
    (defun GOV|DALOS|GUARD ()               (create-capability-guard (DALOS|NATIVE-AUTOMATIC)))
    ;;
    ;; [Keys]
    (defun GOV|NS_Use ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|Demiurgoi ()                 (+ (GOV|NS_Use) ".dh_master-keyset"))
    (defun GOV|DalosKey ()                  (+ (GOV|NS_Use) ".dh_sc_dalos-keyset"))
    (defun GOV|AutostakeKey ()              (+ (GOV|NS_Use) ".dh_sc_autostake-keyset"))
    (defun GOV|VestingKey ()                (+ (GOV|NS_Use) ".dh_sc_vesting-keyset"))
    (defun GOV|LiquidKey ()                 (+ (GOV|NS_Use) ".dh_sc_stoaliquidstaking-keyset"))
    (defun GOV|OuroborosKey ()              (+ (GOV|NS_Use) ".dh_sc_ouroboros-keyset"))
    (defun GOV|SwapKey ()                   (+ (GOV|NS_Use) ".dh_sc_swapper-keyset"))
    (defun GOV|DHVKey ()                    (+ (GOV|NS_Use) ".dh_sc_dhvault-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DALOS|SC_NAME ()             (at 0 ["Σ.W∇ЦwÏξБØnζΦψÕłěîбηжÛśTã∇țâĆã4ЬĚIŽȘØíÕlÛřбΩцμCšιÄиMkλ€УщшàфGřÞыÎäY8È₳BDÏÚmßOozBτòÊŸŹjПкцğ¥щóиś4h4ÑþююqςA9ÆúÛȚβжéÑψéУoЭπÄЩψďşõшżíZtZuψ4ѺËxЖψУÌбЧλüșěđΔjÈt0ΛŽZSÿΞЩŠ"]))
    (defun GOV|ATS|SC_NAME ()               (at 0 ["Σ.ëŤΦșźUÉM89ŹïuÆÒÕ£żíëцΘЯнŹÿxжöwΨ¥Пууhďíπ₱nιrŹÅöыыidõd7ì₿ипΛДĎĎйĄшΛŁPMȘïõμîμŻIцЖljÃαbäЗŸÖéÂЫèpAДuÿPσ8ÎoŃЮнsŤΞìтČ₿Ñ8üĞÕPșчÌșÄG∇MZĂÒЖь₿ØDCПãńΛЬõŞŤЙšÒŸПĘЛΠws9€ΦуêÈŽŻ"]))
    (defun GOV|VST|SC_NAME ()               (at 0 ["Σ.şZïζhЛßdяźπПЧDΞZülΦпφßΣитœŸ4ó¥ĘкÌЦ₱₱AÚюłćβρèЬÍŠęgĎwтäъνFf9źdûъtJCλúp₿ÌнË₿₱éåÔŽvCOŠŃpÚKюρЙΣΩìsΞτWpÙŠŹЩпÅθÝØpтŮыØșþшу6GтÃêŮĞбžŠΠŞWĆLτЙđнòZЫÏJÿыжU6ŽкЫVσ€ьqθtÙѺSô€χ"]))
    (defun GOV|LIQUID|SC_NAME ()            (at 0 ["Σ.śκν9₿ŻşYЙΣJΘÊO9jпF₿wŻ¥уPэõΣÑïoγΠθßÙzěŃ∇éÖиțșφΦτşэßιBιśiĘîéòюÚY$êFЬŤØ$868дyβT0ςъëÁwRγПŠτËMĚRПMaäЗэiЪiςΨoÞDŮěŠβLé4čØHπĂŃŻЫΣÀmăĐЗżłÄăiĞ₿йÎEσțłGΛЖΔŞx¥ÁiÙNğÅÌlγ¢ĎwдŃ"]))
    (defun GOV|OUROBOROS|SC_NAME ()         (at 0 ["Σ.4M0èÞbøXśαiΠ€NùÇèφqλËãØÓNCнÌπпЬ4γTмыżěуàđЫъмéLUœa₿ĞЬŒѺrËQęíùÅЬ¥τ9£φď6pÙ8ìжôYиșîŻøbğůÞχEшäΞúзêŻöŃЮüŞöućЗßřьяÉżăŹCŸNÅìŸпĐżwüăŞãiÜą1ÃγänğhWg9ĚωG₳R0EùçGΨфχЗLπшhsMτξ"]))
    (defun GOV|SWP|SC_NAME ()               (at 0 ["Σ.fĘĐżØиmΞüȚÓ0âGœȘйцań₿ѺĐЦãúα0šwř4QąйZЛgãŽ₿ßÇöđ2zFtмÄäþťûκpíČX₳ĂBÞãÅhλÚțqýвáêйâ₳ЫDżfÙŃλыêąйíâβPЫůjыáaπÕpnýOĄåęümÚJηğȘôρ8şnνEβęůйΛÑćλòxЧUdÑĎÈčVΞÌFAx£Ы2τżŻzДŽYуRČñÜ"]))
    (defun GOV|DHV1|SC_NAME ()              (at 0 ["Ѻ.ъΦĞρλξäFφVПÉЫÍЬÙGěЭыц¥ĄïsKзŤ8£ΞδĚãlÍŃÝþáΩĘΞȘĎĄЛδůÖîĎĄΠДÈrЪqyςkѺδKłĄρțØänÀŚxчtÍςÃΩ₳9ť7ÇяŠΛδÓdťЗΞŻÛπΩ∇цжuлiØłÛáYπOкæáYoùχmŒуŞËЛΞьPĘáÛÝaBÑБžя₳țςhrĚë₱dÑLÞЛεñeîÓУłëΦ"]))
    (defun GOV|DHV2|SC_NAME ()              (+ "Σ" (drop 1 (GOV|DHV1|SC_NAME))))
    (defun GOV|AQP|SC_NAME ()               (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"]))
    ;;
    ;; [PBLs]
    (defun GOV|DALOS|PBL ()                 (at 0 ["9G.DwF3imJMCp4ht88DD1vx6pdjEkLM4j7Fvzso8zJF7Ixe1p2oKfGb53a5svtEF0Lz1q4MjvHaMrgqCfjlA1cBj2bzvs86EeLIMg2fmutzwbA5vI4woKoqq0acDHllAonxC4qLBulsLclMGwcw9iGxiw919t4tfD8FpcIc4MJ059ki7giFIAyCghgMwwr199v3qiDfIon426rbz1jMLmCe4jhHwD3sEarwMlmzLJ5li43J70CEDzouh7x8pu4u1GxJHa6Cabrsc147gIlzIdDmCC2j87LFpEdvqLge9o0w4av8mLr0lDAfalpnEabfkl0E6zE9KMG7LH2w7uvBIup3Hxxxu2Giwu29Cqye3fJ5ihcjacop4vtcLsi33ip742uAhGzjHaDLwAh933ntp8tEC1zkt9yi6n89JtsDLk477p80rscbGtsi14nxsMf7y0d7GxzE8FFmljElu5yE3vx25cEvc9574Hw4iIi23FFKfdhGF77LMqaBkDB9hJKmpc1B2rM1a8mfilyvLAdzpj57Ae5FG5vvm1n1nzgau373dBF7CuBAu2zbts09du55"]))
    (defun GOV|ATS|PBL ()                   (at 0 ["9H.9I8veD6Lqmcd5nKlb1vlHkg976FhdtooE3iH73h8i2Gq9tLKdclnpo07sC29i2yvMeuB0ikkKghiIgdAfkfDiM57o2phj2quCD8gutjIgDs6AlecMtw2lG6kMMBxBH4B5d1xqhpzA7AHkgEqF7Hgqwpx6E5aIMAtqxIpMhjyqziDiwLA69dKlhlwpjoze34Bwz6swBjlA880ItKfwxtulKEJG9oI3Gjmwgn6bbAgL7xy4brdbgK5DukMBHc0K1jIs1DjcDzhJz2liKultB67rKaBf3nMHMkbzhwl1hdu2wBCeHMLLphug2kE3tDtpxw6kLcj80qfBxvwmuxbeHjk349Md2B7eB4brt8fldi2CxGltfj41KA7GkgmtMa6szivDl5aCk9ozab9ohrsfBHikGL7GJ5Az4A2a8ufnIAJIz2mAgwGDmsAl7yyavbx12e5KhFFupclbKadmiFx8dvqkqwziu4vtt3AcKDhl96EzhuiKAF49vGoaAMo5vxM4h0t94nscG8IGl33De5MJGCpdf3g23D13eJ9BDi034wECutafzao4zzCe9IyvD3E"]))
    (defun GOV|VST|PBL ()                   (at 0 ["9G.5s5hoiGo96tMqyh3JBklmsvo8Lc3ol9m6zavJcCuqg4mBvkbDfcv5gEorMit8v8Mj9Jc18EI36Gq7cJ1IyA4e4wvl199KuCx3chsDKGDdfsvzk8mo317ulGk00pbxu7MLc2zw7joouaxt3Ax1KnlJz153ko0JtIxz7pqylfis45pDo2vvm1MH2kA2wmE2crxiEo6oEckuGqzz8oEaa9ez8ADLyqnj48lq4jGp4slkKo6a06ElezH619fsihIdmiMdfB036CJAr0rlzA2b5DgvEJcoyIFioru7vynBjLMLv3pvLFnbFeswrlyLjF8ry7kB52cD7bD7xaamCEjgIC2DsKMv5Mrd69BIKn2yKHC86f0hme9zs5dwMekAd6mc4wM4bDAk6Jrsl6s74ykKLF71pk45rIE1xxzFC4EjykBf6G0neBdaExI32HufaE5mEloDtvnC6vJ7HA9akkI3616MnLErA8eMIn7Kr2wI4l9CvGpKcF9HilzJmdqMa4kzJwqzuFc9LhDnrKcu0LvBHqsx2CrCM9EwHqpkkGe7w8eK8x0xK6K8drLaoBKmaB1"]))
    (defun GOV|LIQUID|PBL ()                (at 0 ["9H.b49lfzLzvC25g87fst6MqCkfbuqq39iGu50gDqi9jBEk6Cn86w54b91zDxeGgLdCxIjJDfyi6gBBwA93lyGLcdfggf0LzwKu405piavx0nEnqpzyHK125h2BhECnobmDBAps61c7mGmw5GrczBjvBMLxHwl2avt5jwhKeGxh7Ibm1ui6wI6lpAKBMay4tvEwHK0EibhbeaA2lLqjIwqMKnldp22txeje3DFLautFC798ExbLxG7q3om8l1f9qpMJkw9f5nmHsHGJcrcIF2mou9lmpr3hbz64La6nF9w26h7osABLMLlK9Glp48yrj4h1MkI7xjftytKDnJFyqvoMFqKvA43cJ81bJCvmn63eJ9jx5n3GxFbc9H4v400iFwtyIilmhKymsa1iCnwL29g21DvkaE6JJyxl5eLCiGH3Ml1nb0jkg16zJbf9cfg41KHA0IGFIvLj9LBhj7okL6wspCEBfkc5Aui6DAM7dvAqH54LApEaAzIgyMloEmqvBgt5wF0lyd05xHxz4Mtb3ItGb5fLpzbMGqGKBffi4dElI7Hbs6Id0hCKGaeIg9JL"]))
    (defun GOV|OUROBOROS|PBL ()             (at 0 ["9H.28jB2BBny4op601Cfqz9brFJKAEo67jbEDJi91i00pGjcD1Mpn0y0A1CxcAwGgBu35Ix3bG4e4p56Mu6x7Mmd50nKfmpDGtLy1ywyCjoDD5xiHBb0y5dAjB0fuokrqyx3ula9rtxyEHK1A4gkG4g3GEyysMtgF40IBgKjm7t8ffGshICIypFeF3gA5x0MixA0soiCx9tBnMDzI6G5xC8yIJJ3Bt2sCvJHAp7HAEA3rKK6Bgnx8hK94oDbgrpCkxw3zpo7tbeHhcakzbg0ELG3EJvk19hyd9LC73t2gizl0B6puq3Ljji5EDAhzno7K32x8vCagc5D2GLiMfdzEzsj5KEe1c2p7hxj76lMvp40r9F56vzlK8Kb7mrKt90ILEMqCghLrok7D4uH8h28EGqbK75wiyguimc1jDGxthyBJFfApClymKA57ehqbv2Lyv323w44b0kIItu35fjmhe2DCBMwjn67ffDII97b6AdyG010wvAHf55xFt25Mbm2pflsggL4D5jHtokl7qn6g4ltM5ilvHvsxn7jHe23Cfgoxn1JssdFMBpcDvB2xki7"]))
    (defun GOV|SWP|PBL ()                   (at 0 ["9G.4Bl3bJ5o1eIoBkhynF39lFdvkA3E0n8m5fBr9iG4D6Ahj3xfop72b98rr33vFFLjqaiozE1btl7lgzKcjHwjzu5GuFqvMb43v9CHHe8je3buLbHMkcAyKdEMD85yIHsb9ty58Kzyado3ho1n1mf9GzpeegMrpK9wDFteeKexdL7HHq8GF7ptD2w45IkMf2A8j4pm7E6vJ1ytCckhclD9nd3JzL2j5cyLxawnE76leKmEmFaxqnF76yyJe5Mu6yLkg2yonJa6vx6jd1kr0hdEf81o42Asr8EcCDeeqD4nAehC3w3pFDMwbln4Mbl6t55GHGephx99LJKH1ojhlMlnyC4bbJFAiyD1h6vs0o7mKAaazFG9y0vfbvM9imcs1vCMmpk2cGDAAAqH6iJe32ugHA3AECEgCvxCskw4Mfx6Cc4rx2BkmKMlxeHqyDceI6wa2qjzuyI80vKg6H6tMwEg48H0ywIMDyxteDfHav08eEJE2lljEIAc1jxLlLcosbiknAyxJvu8g7kA4oAlcio2jI8lMxp76vosd5FxpatowuFktILfyCFyHvKfcozy"]))
    (defun GOV|DHV|PBL ()                   (at 0 ["9G.7G3mkhkk34Bg37uslsu3M7psBc40xsKFibE9DL0jb43JcJ7fzDh9cz3Edn8uvlkh0bCeFafFntCKt0HvJsmczx3Lek9d3mqr38BbIwmBrDkd8sordjr4L7tJ5Fnqj39F6s55hD3rEFvMGors4sws3lDcKiEHkMEE7kHuuB31gGe3F5HsI0yHbwsm2IcspsB1ICiD1g73vup127pjLauIc6gxl3sJy0lAml1uA9g18Btcl6prinGmo3uFomeoyvx9oLGlf6ctFsfavKa5vFrvaw2FB1KsAiejqqjaeMu1I1cEey3m55allFm5pg9LaFK307qnmjxfmqv38vvr2wBerI4BnvFKLgpB7e7pCCmarDJq1l6nHEIv6wl3d96iwAqEHxKEwpH7ljzqnsnBpcEFlpKu6xjc5o78DiwzrltiDxa5c9ug7wML3MGqDEH9tzIj2IreF5yEnw4M15yy38z7gqKbd7l3Fb3qc7kvrgHKG8cpq9M54kg6v5a1k7Laqea07ynccK6r2bjwl7L8IkE7EsAep77M1kb4455klFFH2qx2uEuGBlfsu1rztiMa"]))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (at 0 ["InterModulePolicies"]))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DALOS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DALOS_ADMIN)
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
        true
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
    (defschema DALOS|StoaSchema
        dalos:[string]
    )
    (defschema DALOS|PropertiesSchema
        global-administrative-pause:bool    ;;Stores the GAP Boolean
        demiurgoi:[string]                  ;;Stores Demiurgoi DALOS Accounts
        unity-id:string                     ;;Unity
        gas-source-id:string                ;;OUROBOROS
        gas-source-id-price:decimal         ;;OUROBOROS Price
        gas-id:string                       ;;IGNIS
        ats-gas-source-id:string            ;;AURYN
        elite-ats-gas-source-id:string      ;;ELITE-AURYN
        wrapped-stoa-id:string              ;;OWS - Ouronet Wrapped Stoa
        silver-stoa-id:string               ;;OSS - Ouronet Silver (Liquid) Stoa
        golden-stoa-id:string               ;;OGS - Ouronet Golden (Pension) Stoa
        ur-stoa-id:string                   ;;OUS - Ouronet UrStoa
        ;;
        treasury-dispo-type:integer
        treasury-dynamic-promille:decimal
        treasury-static-tds:decimal
        ;;
        ouro-auto-price-via-swaps:bool      ;;Determines if Ouro Price Auto Update Via Swaps is on
    )
    (defschema DALOS|GasManagementSchema
        virtual-gas-tank:string             ;;IGNIS|SC_NAME = "GasTanker"
        virtual-gas-toggle:bool             ;;IGNIS collection toggle
        virtual-gas-spent:decimal           ;;IGNIS spent
        native-gas-toggle:bool              ;;STOA collection toggle
        native-gas-spent:decimal            ;;STOA spent
        native-gas-pump:bool                ;;controls automatic LiquidStaking fueling
    )
    (defschema DALOS|PricesSchema
        price:decimal                       ;;Stores price for action
    )
    (defschema DALOS|AccountSchemaV2
        @doc "Schema that stores Ouronet (DALOS) Account Information"
        public:string
        guard:guard
        stoa-konto:string
        sovereign:string
        governor:guard
        ;;
        smart-contract:bool
        payable-as-smart-contract:bool
        payable-by-smart-contract:bool
        payable-by-method:bool
        ;;
        nonce:integer
        elite:object{DALOS|EliteSchema}
        ouroboros:object{OuronetDalosV1.DPTF|BalanceSchema}
        ignis:object{OuronetDalosV1.DPTF|BalanceSchema}
    )
    (defschema DALOS|EliteSchema
        class:string
        name:string
        tier:string
        deb:decimal
    )
    ;;{2}
    (deftable DALOS|StoaLedger:{DALOS|StoaSchema})              ;;Key = <k:account>
    (deftable DALOS|PropertiesTable:{DALOS|PropertiesSchema})       ;;Key = DALOS|INFO
    (deftable DALOS|GasManagementTable:{DALOS|GasManagementSchema}) ;;Key = DALOS|VGD
    (deftable DALOS|PricesTable:{DALOS|PricesSchema})               ;;Key = <action>
    (deftable DALOS|AccountTable:{DALOS|AccountSchemaV2})           ;;Key = <account>
    ;;{3}
    (defun CT_Bar ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun DALOS|Info ()                    (at 0 ["DalosInformation"]))
    (defun DALOS|VirtualGasData ()          (at 0 ["VirtualGasData"]))
    (defconst BAR                           (CT_Bar))
    (defconst DALOS|INFO                    (DALOS|Info))
    (defconst DALOS|VGD                     (DALOS|VirtualGasData))
    (defconst DALOS|PLEB
        {"class"    : "NOVICE"
        ,"name"     : "Infidel"
        ,"tier"     : "0.0"
        ,"deb"      : 1.0 }
    )
    (defconst DALOS|VOID
        {"class"    : "VOID"
        ,"name"     : "Undead"
        ,"tier"     : "0.0"
        ,"deb"      : 0.0 }
    )
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap SECURE-ADMIN ()
        (compose-capability (SECURE))
        (compose-capability (GOV|DALOS_ADMIN))
    )
    ;;{C2}
    (defcap DALOS|S>SET-OURO-PRICE (price:decimal)
        @event
        (let
            (
                (dalos-guard:guard (UR_AccountGuard DALOS|SC_NAME))
                (dalos-sov-guard:guard (UR_AccountGuard (UR_AccountSovereign DALOS|SC_NAME)))
                (dalos-gov-guard:guard (UR_AccountGovernor DALOS|SC_NAME))
            )
            (enforce-one
                "Permission not granted to Update OURO Price !"
                [
                    (enforce-guard dalos-guard)
                    (enforce-guard dalos-sov-guard)
                    (enforce-guard dalos-gov-guard)
                    (enforce-guard GOV|MD_DALOS)
                    (enforce-guard GOV|SC_DALOS)
                ]
            )
        )
    )
    (defcap DALOS|S>ROTATE-OA-SOVEREIGN (account:string new-sovereign:string)
        @event
        (CAP_EnforceAccountOwnership account)
        (UEV_EnforceAccountType account true)
        (UEV_EnforceAccountType new-sovereign false)
        (UEV_SenderWithReceiver (UR_AccountSovereign account) new-sovereign)
    )
    ;;{C3}
    (defcap DALOS|F>OWNER (account:string)
        (CAP_EnforceAccountOwnership account)
    )
    (defcap DALOS|F>GOV (account:string)
        (CAP_EnforceAccountOwnership account)
        (UEV_EnforceAccountType account true)
    )
    ;;{C4}
    (defcap GOV|MIGRATE (migration-target-stoa-account:string)
        @event
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (target-balance:decimal (ref-coin::get-balance migration-target-stoa-account))
                (gap:bool (UR_GAP))
            )
            (enforce gap (format "Migration can only be executed when Global Administrative Pause is offline"))
            (enforce (= target-balance 0.0) "Migration can only be executed to an empty stoa account")
            (compose-capability (GOV|DALOS_ADMIN))
            (compose-capability (DALOS|NATIVE-AUTOMATIC))
        )
    )
    (defcap DALOS|C>TOGGLE-GAS-COLLECTION (native:bool toggle:bool)
        (compose-capability (GOV|DALOS_ADMIN))
        (if native
            (UEV_StoaCollectionState (not toggle))
            (UEV_IgnisCollectionState (not toggle))
        )
    )
    (defcap DALOS|C>CONTROL-SMART-OURONET-ACCOUNT (account:string pasc:bool pbsc:bool pbm:bool)
        @event
        (compose-capability (DALOS|F>GOV account))
        (enforce (= (or (or pasc pbsc) pbm) true) "At least one Smart DALOS Account parameter must be true")
    )
    (defcap DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT (account:string guard:guard stoa:string)
        @event
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
                (first:string (take 1 account))
                (ouroboros:string "Ѻ")
            )
            (ref-U|G::UEV_Any
                [
                    guard
                    (create-capability-guard (GOV))
                ]
            )
            (enforce (= first ouroboros) (format "Account {} doesn|t have the corrrect Format for a Standard DALOS Account" [account]))
            (UEV_Glyph account)
            (UEV_EnforceGuardProtocol guard true)
            (compose-capability (SECURE))
        )
    )
    (defcap DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT (account:string guard:guard stoa:string sovereign:string)
        @event
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
                (first:string (take 1 account))
                (sigma:string "Σ")
            )
            (ref-U|G::UEV_Any
                [
                    guard
                    (create-capability-guard (GOV))
                ]
            )
            (enforce (= first sigma) (format "Account {} doesn|t have the corrrect Format for a Smart DALOS Account" [account]))
            (UEV_Glyph account)
            (UEV_EnforceAccountType sovereign false)
            (UEV_EnforceGuardProtocol guard true)
            (compose-capability (SECURE))
        )
    )
    ;;#26M fix: dedicated client cap for the admin (fee-free) deploy path, composing the shared
    ;;validation above rather than duplicating it - keeps A_DeploySmartAccount's own admin gate
    ;;(GOV|DALOS_ADMIN) distinct from C_DeploySmartAccount's, while both funnel into the same
    ;;single definition of the account-format/guard validation.
    (defcap DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT (account:string guard:guard stoa:string sovereign:string)
        @event
        (compose-capability (GOV|DALOS_ADMIN))
        (compose-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign))
    )
    (defcap DALOS|C>ROTATE-OA_GOVERNOR (account:string governor:guard)
        @event
        (UEV_EnforceGuardProtocol governor false)
        (compose-capability (DALOS|F>GOV account))
    )
    (defcap DALOS|C>ROTATE-OA-GUARD (account:string new-guard:guard safe:bool)
        @event
        (UEV_EnforceGuardProtocol new-guard true)
        (if safe
            (enforce-guard new-guard)
            true
        )
        (compose-capability (SECURE))
        (compose-capability (DALOS|F>OWNER account))
    )
    (defcap DALOS|C>ROTATE-OA-STOA (account:string)
        @event
        (compose-capability (SECURE))
        (compose-capability (DALOS|F>OWNER account))
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_GuardProtocol:string (g:guard)
        @doc "Principal protocol prefix for a guard (k:/w:/r:/u:/c:/m:/p:)."
        (typeof-principal (create-principal g))
    )
    ;;{F0}  [UR]
    (defun URH_AccountCounter ()
        (format "Ouronet has {} real Accounts!"
            [(length (keys DALOS|AccountTable))]
        )
    )
    ;;[0]   DALOS|StoaLedger:{DALOS|StoaSchema}
    (defun UR_StoaLedger:[string] (stoa:string)
        (with-default-read DALOS|StoaLedger stoa
            { "dalos"    : [BAR] }
            { "dalos"    := d }
            d
        )
    )
    ;;[1]   DALOS|PropertiesTable:{DALOS|PropertiesSchema}
    (defun UR_GAP:bool ()
        (at "global-administrative-pause" (read DALOS|PropertiesTable DALOS|INFO ["global-administrative-pause"]))
    )
    (defun UR_DemiurgoiID:[string] ()
        (at "demiurgoi" (read DALOS|PropertiesTable DALOS|INFO ["demiurgoi"]))
    )
    (defun UR_UnityID:string ()
        (at "unity-id" (read DALOS|PropertiesTable DALOS|INFO ["unity-id"]))
    )
    (defun UR_OuroborosID:string ()
        (at "gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id"]))
    )
    (defun UR_OuroborosPrice:decimal ()
        (at "gas-source-id-price" (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id-price"]))
    )
    (defun UR_IgnisID:string ()
        (with-default-read DALOS|PropertiesTable DALOS|INFO
            { "gas-id" :  BAR }
            { "gas-id" := gas-id}
            gas-id
        )
    )
    (defun UR_AurynID:string ()
        (at "ats-gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["ats-gas-source-id"]))
    )
    (defun UR_EliteAurynID:string ()
        (at "elite-ats-gas-source-id" (read DALOS|PropertiesTable DALOS|INFO ["elite-ats-gas-source-id"]))
    )
    (defun UR_WrappedStoaID:string ()
        (at "wrapped-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["wrapped-stoa-id"]))
    )
    (defun UR_SilverStoaID:string ()
        (at "silver-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["silver-stoa-id"]))
    )
    (defun UR_CanonicalStoaIds:object{CanonicalStoaIds} ()
        @doc "#65fL Phase 8b: OURO/WSTOA/SSTOA together in ONE read, for a caller that \
            \ needs all 3 identities to check against a single <id> (e.g. \
            \ SWPI::URC_WorthWSTOA's 3-way WSTOA/SSTOA/OURO shortcut dispatch) — replaces \
            \ 3 independent single-field reads of the same row with 1 multi-field \
            \ read of it."
        (read DALOS|PropertiesTable DALOS|INFO ["gas-source-id" "wrapped-stoa-id" "silver-stoa-id"])
    )
    (defun UR_GoldenStoaID:string ()
        (at "golden-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["golden-stoa-id"]))
    )
    (defun UR_UrStoaID:string ()
        (at "ur-stoa-id" (read DALOS|PropertiesTable DALOS|INFO ["ur-stoa-id"]))
    )
    (defun UR_DispoType:integer ()
        (at "treasury-dispo-type" (read DALOS|PropertiesTable DALOS|INFO ["treasury-dispo-type"]))
    )
    (defun UR_DispoTDP:decimal ()
        (at "treasury-dynamic-promille" (read DALOS|PropertiesTable DALOS|INFO ["treasury-dynamic-promille"]))
    )
    (defun UR_DispoTDS:decimal ()
        (at "treasury-static-tds" (read DALOS|PropertiesTable DALOS|INFO ["treasury-static-tds"]))
    )
    (defun UR_OuroAutoPriceUpdate:bool ()
        (at "ouro-auto-price-via-swaps" (read DALOS|PropertiesTable DALOS|INFO ["ouro-auto-price-via-swaps"]))
    )
    ;;[2]   DALOS|GasManagementTable:{DALOS|GasManagementSchema}
    (defun UR_Tanker:string ()
        (at "virtual-gas-tank" (read DALOS|GasManagementTable DALOS|VGD ["virtual-gas-tank"]))
    )
    (defun UR_VirtualToggle:bool ()
        (with-default-read DALOS|GasManagementTable DALOS|VGD
            {"virtual-gas-toggle" : false}
            {"virtual-gas-toggle" := tg}
            tg
        )
    )
    (defun UR_VirtualSpent:decimal ()
        (at "virtual-gas-spent" (read DALOS|GasManagementTable DALOS|VGD ["virtual-gas-spent"]))
    )
    (defun UR_NativeToggle:bool ()
        (with-default-read DALOS|GasManagementTable DALOS|VGD
            {"native-gas-toggle" : false}
            {"native-gas-toggle" := tg}
            tg
        )
    )
    (defun UR_NativeSpent:decimal ()
        (at "native-gas-spent" (read DALOS|GasManagementTable DALOS|VGD ["native-gas-spent"]))
    )
    (defun UR_AutoFuel:bool ()
        (at "native-gas-pump" (read DALOS|GasManagementTable DALOS|VGD ["native-gas-pump"]))
    )
    ;;[3]   DALOS|PricesTable:{DALOS|PricesSchema}
    (defun UR_UsagePrice:decimal (action:string)
        (at "price" (read DALOS|PricesTable action ["price"]))
    )
    ;;[4]   DALOS|AccountTable:{DALOS|AccountSchemaV2}
    (defun UR_AccountPublicKey:string (account:string)
        (at "public" (read DALOS|AccountTable account ["public"]))
    )
    (defun UR_AccountGuard:guard (account:string)
        (at "guard" (read DALOS|AccountTable account ["guard"]))
    )
    (defun UR_AccountStoa:string (account:string)
        (at "stoa-konto" (read DALOS|AccountTable account ["stoa-konto"]))
    )
    (defun UR_AccountSovereign:string (account:string)
        (at "sovereign" (read DALOS|AccountTable account ["sovereign"]))
    )
    (defun UR_AccountGovernor:guard (account:string)
        (at "governor" (read DALOS|AccountTable account ["governor"]))
    )
    (defun UR_AccountProperties:[bool] (account:string)
        (with-default-read DALOS|AccountTable account
            { "smart-contract" : false, "payable-as-smart-contract" : false, "payable-by-smart-contract" : false, "payable-by-method" : false}
            { "smart-contract" := sc, "payable-as-smart-contract" := pasc, "payable-by-smart-contract" := pbsc, "payable-by-method" := pbm }
            [sc pasc pbsc pbm]
        )
    )
    (defun UR_AccountType:bool (account:string)
        (at 0 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableAs:bool (account:string)
        (at 1 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableBy:bool (account:string)
        (at 2 (UR_AccountProperties account))
    )
    (defun UR_AccountPayableByMethod:bool (account:string)
        (at 3 (UR_AccountProperties account))
    )
    (defun UR_AccountNonce:integer (account:string)
        @doc "Patron transaction counter on DALOS|AccountTable (incremented by IGNIS C_Collect when virtual gas is charged)."
        (with-default-read DALOS|AccountTable account
            { "nonce" : 0 }
            { "nonce" := n }
            n
        )
    )
    (defun UR_Elite (account:string)
        (with-default-read DALOS|AccountTable account
            { "elite" : DALOS|PLEB }
            { "elite" := e}
            e
        )
    )
    ;;[4.1] ELITE Info
    (defun UR_Elite-Class (account:string)
        (at "class" (UR_Elite account))
    )
    (defun UR_Elite-Name (account:string)
        (at "name" (UR_Elite account))
    )
    (defun UR_Elite-Tier (account:string)
        (at "tier" (UR_Elite account))
    )
    (defun UR_Elite-Tier-Major:integer (account:string)
        (str-to-int (take 1 (UR_Elite-Tier account)))
    )
    (defun UR_Elite-Tier-Minor:integer (account:string)
        (str-to-int (take -1 (UR_Elite-Tier account)))
    )
    (defun UR_Elite-DEB (account:string)
        (at "deb" (UR_Elite account))
    )
    ;;[4.2] TrueFungible INFO
    (defun UR_TrueFungible:object{OuronetDalosV1.DPTF|BalanceSchema}
        (account:string snake-or-gas:bool)
        (if snake-or-gas
            (with-default-read DALOS|AccountTable account
                { "ouroboros" : (UDC_BlankTrueFungible account) }
                { "ouroboros" := o}
                o
            )
            (with-default-read DALOS|AccountTable account
                { "ignis" : (UDC_BlankTrueFungible account) }
                { "ignis" := i}
                i
            )
        )
    )
    (defun UR_TF_AccountSupply:decimal (account:string snake-or-gas:bool)
        (at "balance" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleBurn:bool (account:string snake-or-gas:bool)
        (at "role-burn" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleMint:bool (account:string snake-or-gas:bool)
        (at "role-mint" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleTransfer:bool (account:string snake-or-gas:bool)
        (at "role-transfer" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountRoleFeeExemption:bool (account:string snake-or-gas:bool)
        (at "role-fee-exemption" (UR_TrueFungible account snake-or-gas))
    )
    (defun UR_TF_AccountFreezeState:bool (account:string snake-or-gas:bool)
        (at "frozen" (UR_TrueFungible account snake-or-gas))
    )
    ;;
    (defun UR_AutonomicRoles:bool (account:string)
        (fold (or) false 
            [
                (= account DALOS|SC_NAME)
                (= account (GOV|ATS|SC_NAME))
                (= account (GOV|VST|SC_NAME))
                (= account (GOV|LIQUID|SC_NAME))
                (= account (GOV|OUROBOROS|SC_NAME))
                (= account (GOV|SWP|SC_NAME))
                (= account (GOV|DHV2|SC_NAME))
                (= account (GOV|AQP|SC_NAME))
            ]
        )
    )
    ;;{F1}  [URC]
    ;;
    (defun URC_IgnisGasDiscount:decimal (account:string)
        @doc "Computes the Discount for Ignis Gas Costs. A value of 1.00 means no discount"
        (URC_GasDiscount account false)
    )
    (defun URC_StoaGasDiscount:decimal (account:string)
        @doc "Computes the Discount for Stoa Gas Costs. A value of 1.00 means no discount"
        (URC_GasDiscount account true)
    )
    (defun URC_GasDiscount:decimal (account:string native:bool)
        @doc "Computes Gas Discount Values, a value of 1.00 means no discount"
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (major:integer (UR_Elite-Tier-Major account))
                (minor:integer (UR_Elite-Tier-Minor account))
            )
            (ref-U|DALOS::UC_GasCost 1.00 major minor native)
        )
    )
    (defun URC_SplitSTOAPrices:[decimal] (account:string stoa-price:decimal)
        @doc "Computes the STOA Split required for Native Gas Collection \
          \ This is 10% 20% 30% and 40% split, outputed as 4 element list \
          \ Takes in consideration the Discounted STOA for <account>"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-discount:decimal (URC_StoaGasDiscount account))
                (discounted-stoa:decimal (* stoa-discount stoa-price))
            )
            (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit discounted-stoa stoa-prec)
        )
    )
    (defun URC_Transferability:bool (sender:string receiver:string method:bool)
        @doc "Computes Transferability of Assets between a <sender> and a <receiver> with the given <method>"
        (UEV_SenderWithReceiver sender receiver)
        (let
            (
                (s-sc:bool (UR_AccountType sender))
                (r-sc:bool (UR_AccountType receiver))
                (r-pasc:bool (UR_AccountPayableAs receiver))
                (r-pbsc:bool (UR_AccountPayableBy receiver))
                (r-mt:bool (UR_AccountPayableByMethod receiver))
            )
            (if (= s-sc false)
                (if (= r-sc false)              ;;sender is normal
                    true                        ;;receiver is normal (Normal => Normal | Case 1)
                    (if (= method true)         ;;receiver is smart  (Normal => Smart | Case 3)
                        r-mt
                        r-pasc
                    )
                )
                (if (= r-sc false)              ;;sender is smart
                    true                        ;;receiver is normal (Smart => Normal | Case 4)
                    (if (= method true)         ;;receiver is false (Smart => Smart | Case 2)
                        r-mt
                        r-pbsc
                    )
                )
            )
        )
    )
    ;;{F2}  [UEV]
    (defun UEV_NotSmartOuronetAccount (account:string)
        (enforce (not (UR_AutonomicRoles account)) "Non Smart Ouronet Accounts required for exec")
    )
    (defun UEV_StandardAccOwn (account:string)
        @doc "Validates Ownership for a Standard Ouronet Account"
        (let
            (
                (account-guard:guard (UR_AccountGuard account))
                (sovereign:string (UR_AccountSovereign account))
                (governor:guard (UR_AccountGovernor account))
            )
            (enforce (= sovereign account) "Incompatible Sovereign detected for a Standard DALOS Account")
            (enforce (= account-guard governor) "Incompatible Governer Guard detected for Standard DALOS Account")
            (enforce-guard account-guard)
        )
    )
    (defun UEV_SmartAccOwn (account:string)
        @doc "Validates Ownership for a Smart Ouronet Account"
        (let
            (
                (account-guard:guard (UR_AccountGuard account))
                (sovereign:string (UR_AccountSovereign account))
                (sovereign-guard:guard (UR_AccountGuard sovereign))
                (governor:guard (UR_AccountGovernor account))
            )
            (enforce (!= sovereign account) "Incompatible Sovereign detected for Smart DALOS Account")
            (enforce-one
                (format "Smart DALOS Account {} Ownership could not be verified!" [account])
                [
                    (enforce-guard account-guard)
                    (enforce-guard sovereign-guard)
                    (enforce-guard governor)
                ]
            )
        )
    )
    (defun UEV_EnforceAccountExists (dalos-account:string)
        @doc "Enforces a given <dalos-account> exists by reading its DEB"
        (with-default-read DALOS|AccountTable dalos-account
            { "elite" : DALOS|VOID }
            { "elite" := e }
            (let
                (
                    (deb:decimal (at "deb" e))
                )
                (enforce
                    (>= deb 1.0)
                    (format "The {} DALOS Account doesnt exist" [dalos-account])
                )
            )
        )
    )
    (defun UEV_EnforceAccountType (account:string smart:bool)
        @doc "Enforces that <account> is of type <smart> (either Standard or Smart Ouronet Account)"
        (let
            (
                (x:bool (UR_AccountType account))
                (first:string (take 1 account))
                (ouroboros:string "Ѻ")
                (sigma:string "Σ")
            )
            (if smart
                (enforce (and (= first sigma) (= x true)) (format "Operation requires a Smart DALOS Account; Account {} isnt" [account]))
                (enforce (and (= first ouroboros) (= x false)) (format "Operation requires a Standard DALOS Account; Account {} isnt" [account]))
            )
        )
    )
    (defun UEV_EnforceTransferability (sender:string receiver:string method:bool)
        @doc "Enforces transferability between <sender> and <receiver> with <method>"
        (let
            (
                (x:bool (URC_Transferability sender receiver method))
            )
            (enforce (= x true) (format "Transferability between {} and {} with {} Method is not ensured" [sender receiver method]))
        )
    )
    (defun UEV_SenderWithReceiver (sender:string receiver:string)
        @doc "Enforces <sender> and <receiver> are valid for a transfer event"
        (UEV_EnforceAccountExists sender)
        (UEV_EnforceAccountExists receiver)
        (enforce (!= sender receiver) "Sender and Receiver must be different")
    )
    (defun UEV_StoaCollectionState (state:bool)
        (let
            (
                (t:bool (UR_NativeToggle))
            )
            (enforce (= t state) "Invalid native gas collection state!")
        )
    )
    (defun UEV_IgnisCollectionState (state:bool)
        (let
            (
                (t:bool (UR_VirtualToggle))
            )
            (enforce (= t state) "Invalid virtual gas collection state!")
            (if (not state)
                (UEV_IgnisCollectionRequirements)
                true
            )
        )
    )
    (defun UEV_IgnisCollectionRequirements ()
        (let
            (
                (ouro-id:string (UR_OuroborosID))
                (gas-id:string (UR_IgnisID))
            )
            (enforce (!= ouro-id BAR) "OURO Id must be set for IGNIS Collection to turn ON!")
            (enforce (!= gas-id BAR) "IGNIS Id must be set for IGNIS Collection to turn ON!")
            (enforce (!= gas-id ouro-id) "OURO and IGNIS id must be different for the IGNIS Collection to turn ON!")
        )
    )
    (defun UEV_Glyph (account:string)
        (let
            (
                (ref-U|GLYPHS:module{UtilityDalosGlyphsV2} U|DALOS)
            )
            (ref-U|GLYPHS::GLYPH|UEV_DalosAccount account)
        )
    )
    (defun UEV_EnforceGuardProtocol (g:guard is-keyset-based:bool)
        @doc "When is-keyset-based is true, guard must be k:/w:/r:. When false, must be u:/c:/m:/p:."
        (let ((proto (UC_GuardProtocol g)))
            (if is-keyset-based
                (enforce (contains proto ["k:" "w:" "r:"])
                    (format "Guard must be key-based (keyset/keyset-ref); got '{}'" [proto]))
                (enforce (contains proto ["u:" "c:" "m:" "p:"])
                    (format "Governor must be non-key-based (user/capability/module/pact); got '{}'" [proto])))))
    ;;{F3}  [UDC]
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV1.DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        {"balance"              : a
        ,"frozen"               : b
        ,"role-burn"            : c
        ,"role-mint"            : d
        ,"role-fee-exemption"   : e
        ,"role-transfer"        : f
        ,"id"                   : g
        ,"account"              : h}
    )
    (defun UDC_BlankTrueFungible:object{OuronetDalosV1.DPTF|BalanceSchema} (account:string)
        (UDC_TrueFungibleAccount 0.0 false false false false false BAR account)
    )
    ;;
    ;;{F4}  [CAP]
    (defun CAP_EnforceAccountOwnership (account:string)
        @doc "Enforces OuroNet Account Ownership"
        (if (UR_AccountType account)
            (UEV_SmartAccOwn account)
            (UEV_StandardAccOwn account)
        )
    )
    ;;
    ;;{F5}  [A]
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string)
        (UEV_IMC)
        (with-capability (GOV|MIGRATE migration-target-stoa-account)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)    
                    (dalos-stoa:string DALOS|SC_STOA-NAME)
                    (present-stoa-balance:decimal (ref-coin::get-balance dalos-stoa))
                )
                (install-capability (ref-coin::TRANSFER dalos-stoa migration-target-stoa-account present-stoa-balance))
                (ref-coin::transfer dalos-stoa migration-target-stoa-account present-stoa-balance)
                present-stoa-balance
            )
        )
    )
    (defun A_ToggleOAPU (oapu:bool)
        (UEV_IMC)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|PropertiesTable DALOS|INFO
                {"ouro-auto-price-via-swaps"    : oapu}
            )
        )
    )
    (defun A_ToggleGAP (gap:bool)
        (UEV_IMC)
        (with-capability (GOV|GAP gap)
            (update DALOS|PropertiesTable DALOS|INFO
                {"global-administrative-pause"  : gap}
            )
        )
    )
    (defun A_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string)
        (with-capability (DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign)
            (XI_DeploySmartAccount account guard stoa sovereign public)
        )
    )
    (defun A_DeployStandardAccount (account:string guard:guard stoa:string public:string)
        (with-capability (SECURE-ADMIN)
            (XI_DeployStandardAccount account guard stoa public)
        )
    )
    (defun A_ToggleGasCollection (native:bool toggle:bool)
        @doc "Enables or disable GAS Collection. \
            \ <native> true reffers to STOA Collection \
            \ <native> false reffers to IGNIS Collection"
        (UEV_IMC)
        (with-capability (DALOS|C>TOGGLE-GAS-COLLECTION native toggle)
            (XI_GasToggle native toggle)
        )
    )
    (defun A_SetIgnisSourcePrice (price:decimal)
        (UEV_IMC)
        (with-capability (DALOS|S>SET-OURO-PRICE price)
            (XB_UpdateOuroPrice price)
        )
    )
    (defun A_SetAutoFueling (toggle:bool)
        (UEV_IMC)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-pump" : toggle}
            )
        )
    )
    (defun A_UpdatePublicKey (account:string new-public:string)
        (UEV_IMC)
        (with-capability (GOV|DALOS_ADMIN)
            (update DALOS|AccountTable account
                {"public"     : new-public}
            )
        )
    )
    ;;#53L fix: added a non-negative bound check on <new-price> - defense-in-depth for an
    ;;admin-only fat-finger, not a security gate (GOV|DALOS_ADMIN already fully trusted). A
    ;;stray 0/negative price here was flagged as a contributing cause of #8H (IGNIS C_Collect's
    ;;since-fixed zero-leg abort) - purely additive, no change to the existing valid-price path.
    (defun A_UpdateUsagePrice (action:string new-price:decimal)
        (UEV_IMC)
        (with-capability (GOV|DALOS_ADMIN)
            (enforce (> new-price 0.0) "New price must be a positive amount")
            (let
                (
                    (ref-U|CT:module{OuronetConstantsV1} U|CT)
                    (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                )
                (write DALOS|PricesTable action
                    {"price"     : (floor new-price stoa-prec)}
                )
            )
        )
    )
    ;;{F6}  [C]
    (defun C_ControlSmartAccount
        (account:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        (UEV_IMC)
        (with-capability (DALOS|C>CONTROL-SMART-OURONET-ACCOUNT account payable-as-smart-contract payable-by-smart-contract payable-by-method)
            (XI_UpdateSmartAccountParameters account payable-as-smart-contract payable-by-smart-contract payable-by-method)
        )
    )
    (defun C_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string)
        (UEV_IMC)
        (with-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign)
            (XI_DeploySmartAccount account guard stoa sovereign public)
        )
    )
    (defun C_DeployStandardAccount (account:string guard:guard stoa:string public:string)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_DeployStandardAccount account guard stoa public)
        )
    )
    (defun C_RotateGovernor
        (account:string governor:guard)
        (UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA_GOVERNOR account governor)
            (XI_RotateGovernor account governor)
        )
    )
    (defun C_RotateGuard
        (account:string new-guard:guard safe:bool)
        (UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA-GUARD account new-guard safe)
            (XI_RotateGuard account new-guard safe)
        )
    )
    (defun C_RotateStoa
        (account:string stoa:string)
        (UEV_IMC)
        (with-capability (DALOS|C>ROTATE-OA-STOA account)
            ;;#25M fix: read the OLD stoa address before XI_RotateStoa overwrites it -
            ;;otherwise UR_AccountStoa returns the already-rotated NEW address, the ledger
            ;;cleanup targets the wrong key, and the old address's ledger row is orphaned forever.
            (let
                (
                    (old-stoa:string (UR_AccountStoa account))
                )
                (XI_RotateStoa account stoa)
                (XI_UpdateStoaLedger old-stoa account false)
                (XI_UpdateStoaLedger stoa account true)
            )
        )
    )
    (defun C_RotateSovereign
        (account:string new-sovereign:string)
        (UEV_IMC)
        (with-capability (DALOS|S>ROTATE-OA-SOVEREIGN account new-sovereign)
            (XI_RotateSovereign account new-sovereign)
        )
    )
    ;;
    ;;{F7}  [X]
    ;;
    ;;      [X-A]
    (defun XI_DeploySmartAccount (account:string guard:guard stoa:string sovereign:string public:string)
        ;;#26M fix: validation now happens in the caller's own client cap
        ;;(A_DeploySmartAccount composes DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT,
        ;;C_DeploySmartAccount composes DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT directly) - this
        ;;writer only requires the shared validating cap is already active, it doesn't compose
        ;;or enforce anything itself.
        (require-capability (DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT account guard stoa sovereign))
        (insert DALOS|AccountTable account
            { "public"                      : public
            , "guard"                       : guard
            , "stoa-konto"                : stoa
            , "sovereign"                   : sovereign
            , "governor"                    : guard
            ;;
            , "smart-contract"              : true
            , "payable-as-smart-contract"   : false
            , "payable-by-smart-contract"   : false
            , "payable-by-method"           : true
            ;;
            , "nonce"                       : 0
            , "elite"                       : DALOS|PLEB
            , "ouroboros"                   : (UDC_BlankTrueFungible account)
            , "ignis"                       : (UDC_BlankTrueFungible account)
            }
        )
        (XI_UpdateStoaLedger stoa account true)
    )
    (defun XI_DeployStandardAccount (account:string guard:guard stoa:string public:string)
        (require-capability (SECURE))
        (with-capability (DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT account guard stoa)
            (insert DALOS|AccountTable account
                { "public"                      : public
                , "guard"                       : guard
                , "stoa-konto"                : stoa
                , "sovereign"                   : account
                , "governor"                    : guard
                ;;
                , "smart-contract"              : false
                , "payable-as-smart-contract"   : false
                , "payable-by-smart-contract"   : false
                , "payable-by-method"           : false
                ;;
                , "nonce"                       : 0
                , "elite"                       : DALOS|PLEB
                , "ouroboros"                   : (UDC_BlankTrueFungible account)
                , "ignis"                       : (UDC_BlankTrueFungible account)
                }
            )
            (XI_UpdateStoaLedger stoa account true)
        )
    )
    (defun XI_GasToggle (native:bool toggle:bool)
        (require-capability (GOV|DALOS_ADMIN))
        (if (= native true)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-toggle" : toggle}
            )
            (update DALOS|GasManagementTable DALOS|VGD
                {"virtual-gas-toggle" : toggle}
            )
        )
    )
    (defun XB_UpdateOuroPrice (price:decimal)
        (UEV_IMC)
        (update DALOS|PropertiesTable DALOS|INFO
            {"gas-source-id-price" : price}
        )
    )
    ;;      [X-C]
    (defun XI_UpdateSmartAccountParameters (account:string pasc:bool pbsc:bool pbm:bool)
        (require-capability (DALOS|C>CONTROL-SMART-OURONET-ACCOUNT account pasc pbsc pbm))
        (update DALOS|AccountTable account
            {"payable-as-smart-contract"    : pasc
            ,"payable-by-smart-contract"    : pbsc
            ,"payable-by-method"            : pbm}
        )
    )
    (defun XI_RotateGovernor (account:string governor:guard)
        @doc "Under DALOS|C>ROTATE-OA_GOVERNOR: update governor only. Write only."
        (require-capability (DALOS|C>ROTATE-OA_GOVERNOR account governor))
        (update DALOS|AccountTable account
            {"governor" : governor}
        )
    )
    (defun XI_RotateGuard (account:string new-guard:guard safe:bool)
        @doc "Under DALOS|C>ROTATE-OA-GUARD: update guard (and governor on standard accounts). Write only."
        (require-capability (DALOS|C>ROTATE-OA-GUARD account new-guard safe))
        (if (UR_AccountType account)
            (update DALOS|AccountTable account
                {"guard"    : new-guard}
            )
            (update DALOS|AccountTable account
                {"guard"    : new-guard
                ,"governor" : new-guard}
            )
        )
    )
    (defun XI_RotateStoa (account:string stoa:string)
        @doc "Under DALOS|C>ROTATE-OA-STOA: update stoa-konto only. Write only."
        (require-capability (DALOS|C>ROTATE-OA-STOA account))
        (update DALOS|AccountTable account
            {"stoa-konto"                  : stoa}
        )
    )
    (defun XI_UpdateStoaLedger (stoa:string dalos:string direction:bool)
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (with-default-read DALOS|StoaLedger stoa
                { "dalos"    : [BAR] }
                { "dalos"    := d }
                (let
                    (
                        (add-lst:[string]
                            (if (= d [BAR])
                                [dalos]
                                (if (contains dalos d)
                                    d
                                    (ref-U|LST::UC_AppL d dalos)
                                )
                            )
                        )
                        (data-len:integer (length d))
                        (first:string (at 0 d))
                        (rmv-lst:[string]
                            (if (and (= data-len 1)(!= first BAR))
                                [BAR]
                                (ref-U|LST::UC_RemoveItem d dalos)
                            )
                        )
                    )
                    (if direction
                        (write DALOS|StoaLedger stoa
                            { "dalos" : add-lst}
                        )
                        (write DALOS|StoaLedger stoa
                            { "dalos" : rmv-lst}
                        )
                    )

                )
            )
        )
    )
    (defun XI_RotateSovereign (account:string new-sovereign:string)
        (require-capability (DALOS|S>ROTATE-OA-SOVEREIGN account new-sovereign))
        (update DALOS|AccountTable account
            {"sovereign"                        : new-sovereign}
        )
    )
    ;;      [X-DALOS|PropertiesTable]
    (defun XE_UpdateTreasury (type:integer tdp:decimal tds:decimal)
        (UEV_IMC)
        (update DALOS|PropertiesTable DALOS|INFO
            {"treasury-dispo-type"          : type
            ,"treasury-dynamic-promille"    : tdp
            ,"treasury-static-tds"          : tds}

        )
    );;     [X-DALOS|GasManagementTable]
    (defun XE_IgnisIncrement (native:bool increment:decimal)
        (UEV_IMC)
        (if (= native true)
            (update DALOS|GasManagementTable DALOS|VGD
                {"native-gas-spent" : (+ (UR_NativeSpent) increment)}
            )
            (update DALOS|GasManagementTable DALOS|VGD
                {"virtual-gas-spent" : (+ (UR_VirtualSpent) increment)}
            )
        )
    )
    ;;      [X-DALOS|AccountTable]
    (defun XE_IncrementOuronetAccountNonce (account:string)
        (UEV_IMC)
        (with-read DALOS|AccountTable account
            { "nonce" := n }
            (update DALOS|AccountTable account { "nonce" : (+ n 1)})
        )
    )
    (defun XE_UpdateElite (account:string amount:decimal)
        (UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
            )
            (if (= (UR_AccountType account) false)
                (update DALOS|AccountTable account
                    { "elite" : (ref-U|ATS::UDC_Elite amount)}
                )
                true
            )
        )
    )
    (defun XI_UpdateTF (account:string snake-or-gas:bool new-obj:object{OuronetDalosV1.DPTF|BalanceSchema})
        (require-capability (SECURE))
        (if snake-or-gas
            (update DALOS|AccountTable account
                {"ouroboros" : new-obj}
            )
            (update DALOS|AccountTable account
                {"ignis" : new-obj}
            )
        )
    )
    (defun XB_UpdateBalance (account:string snake-or-gas:bool new-balance:decimal)
        (UEV_IMC)
        (with-capability (SECURE)
            (let
                (
                    (data-obj:object (UR_TrueFungible account snake-or-gas))
                    (has-removable:bool (contains "exist" data-obj))
                    (new-balance-obj:object
                        (+
                            {"balance" : new-balance}
                            (remove "balance" data-obj)
                        )
                    )
                )
                (XI_UpdateTF account snake-or-gas
                    (if has-removable
                        (remove "exist" new-balance-obj)
                        new-balance-obj
                    )
                )
            )
        )
    )
    (defun XE_UpdateFreeze (account:string snake-or-gas:bool new-freeze:bool)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"frozen" : new-freeze}
                    (remove "frozen" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    (defun XE_UpdateBurnRole (account:string snake-or-gas:bool new-burn:bool)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas 
                (+
                    {"role-burn" : new-burn}
                    (remove "role-burn" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    (defun XE_UpdateMintRole (account:string snake-or-gas:bool new-mint:bool)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-mint" : new-mint}
                    (remove "role-mint" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    (defun XE_UpdateFeeExemptionRole (account:string snake-or-gas:bool new-fee-exemption:bool)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-fee-exemption" : new-fee-exemption}
                    (remove "role-fee-exemption" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    (defun XE_UpdateTransferRole (account:string snake-or-gas:bool new-transfer:bool)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateTF account snake-or-gas
                (+
                    {"role-transfer" : new-transfer}
                    (remove "role-transfer" (UR_TrueFungible account snake-or-gas))
                )
            )
        )
    )
    ;;
    ;;{F8}  [AUP - Admin Update Functions]
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    (defun AU_OuronetAccounts (accounts:[string])
        @doc "Get Accounts with <(keys DALOS|AccountTable)>"
        (with-capability (AHU)
            (map (AU_OuronetAccount) accounts)
        )
    )
    (defun AU_OuronetAccount (account:string)
        (require-capability (SECURE))
        (update DALOS|AccountTable account
            {"ouroboros"    : (AUx_UpdateTrueFungibleObject (UR_TrueFungible account true) account)
            ,"ignis"        : (AUx_UpdateTrueFungibleObject (UR_TrueFungible account false) account)}
        )
    )
    (defun AUx_UpdateTrueFungibleObject:object{OuronetDalosV1.DPTF|BalanceSchema}
        (input-obj:object account:string)
        (let
            (
                (has-exist:bool (contains "exist" input-obj))
                (v1:object
                    (+
                        {"id" : BAR}
                        (remove "id" input-obj)
                    )
                )
                (v2:object
                    (+
                        {"account" : account}
                        (remove "account" v1)
                    )
                )
            )
            (if has-exist
                (remove "exist" v2)
                v2
            )
        )
    )
    ;;
)

;;Tables exist from initial DALOS
(create-table P|T)
(create-table P|MT)
(create-table DALOS|PropertiesTable)
(create-table DALOS|GasManagementTable)
(create-table DALOS|PricesTable)
(create-table DALOS|AccountTable)
(create-table DALOS|StoaLedger)