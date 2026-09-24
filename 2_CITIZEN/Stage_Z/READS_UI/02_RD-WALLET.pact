;; ===========================================================================================
;; RD-WALLET -- the dashboard body: primordial asset cards and the net-worth total.
;; ===========================================================================================
;; Second module of the READS_UI split. Template: 01_RD-HEADER.pact. Rules: READS_UI/README.md.
;;
;; REPLACES DPL-UR::URC_0002_Primordials / _PrimordialsSingle / _PrimordialsMulti, which are the
;; same defect as URC_0001_HeaderV3 at twice the size: ONE eager `let` with roughly SIXTY
;; bindings feeding one flat object of ~70 keys. Every asset card in the dashboard body depends
;; on every other one loading. A single missing token row blanks the whole wallet view.
;;
;; The split is BY ASSET CARD, because that is both how it renders and how it fails: OURO, IGNIS,
;; AURYN, ELITEAURYN, UrStoa, Stoa, SilverStoa, GoldenStoa, plus the aggregate and the Codex
;; balance. Ten functions, each independently callable, composed by URC_Wallet with `try`.
;;
;; ------------------------------------------------------------------------------------------
;; WHY EACH CARD RECOMPUTES ITS OWN PRICE
;; ------------------------------------------------------------------------------------------
;; URC_Prices is public and every card calls it, rather than a composer computing it once and
;; passing it down. That is deliberate and it is the same reasoning as RD-HEADER's zones: a
;; shared prelude restores exactly the all-or-nothing coupling the split removes. Prices depend
;; on live SWP pools and the STOA PID oracle -- the two most fragile dependencies in the module --
;; so a shared price prelude would mean any pricing failure blanks all eight cards again.
;;
;; MEASURED 2026-09-24, because the cost worry above deserved a number rather than a caveat:
;;     URC_Prices alone      8,280 gas
;;     one card             19,916 gas
;;     URC_Wallet (all 10)  94,269 gas   -- under 1% of the 10,000,000 /local ceiling
;;     module deploy        45,143 gas   -- against DPL-UR's 211,588 for all 71 reads
;; So the duplication is free at this scale and the caveat was overcautious. Kept as a figure
;; rather than deleted: if a future card is expensive the composer is where it will show, and
;; the remedy is already available -- the UI calls only the cards it displays, which it can do
;; because every one of them is public.
;;
;; ------------------------------------------------------------------------------------------
;; TWO THINGS CARRIED OVER THAT ARE NOT MINE TO FIX IN A READ SPLIT
;; ------------------------------------------------------------------------------------------
;;  1. THE URSTOA VAULT ADDRESS IS A HARDCODED PRINCIPAL --
;;     "c:GjYbBFM0vxMs5FcmnFUW-LFoycd3Ef8wuP28vR6FG3k". It is a `coin` account, not an Ouronet
;;     entity id, so OuronetIdsV1 is the wrong home and _hardcodedids.py does not match its
;;     shape. Ported verbatim and named here so it is at least VISIBLE. It wants a decision:
;;     either a second registry for chain-level principals, or a reader on the module that owns
;;     the vault.
;;  2. `coin` IS REACHED TWO WAYS in the original -- a `ref-coin` modref AND a direct
;;     `coin.URC_URV|ClaimableRewards` call in the same `let`. Preserved as-is; changing which
;;     form is used is a behaviour question, not a split question.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface ReadsWalletV1
    @doc "Dashboard-body reads: one function per primordial asset card, plus the aggregate, the \
        \ Codex balance and a composer. Complete surface."

    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal))
    (defun UC_Price:string (input-price:decimal))
    (defun UC_PickId:string (derived:[string] fallback:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Value:decimal (id:string amount:decimal price:decimal))
    (defun URC_Prices:[decimal] ())
    (defun URC_Ouro:object (account:string))
    (defun URC_Ignis:object (account:string))
    (defun URC_Auryn:object (account:string))
    (defun URC_EliteAuryn:object (account:string))
    (defun URC_UrStoa:object (account:string))
    (defun URC_Stoa:object (account:string))
    (defun URC_SilverStoa:object (account:string))
    (defun URC_GoldenStoa:object (account:string))
    (defun URH_GoldenStoaNonces:object (account:string))

    (defun URC_Totals:object (account:string))
    (defun URC_Codex:object (codex-accounts:[string]))
    (defun URC_Wallet:object (account:string codex-accounts:[string]))
)

(module RD-WALLET GOV

    ;;{0}  IMPLEMENTERS
    (implements ReadsWalletV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_RD-WALLET              (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|RD_WALLET_ADMIN)))
    (defcap GOV|RD_WALLET_ADMIN ()          (enforce-guard GOV|MD_RD-WALLET))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{3}  CST
    (defconst URSTOA-VAULT "c:GjYbBFM0vxMs5FcmnFUW-LFoycd3Ef8wuP28vR6FG3k")

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ()
        @doc "What a failing card yields from URC_Wallet. `card-ok` false distinguishes a DEAD \
            \ card from one whose balances are legitimately zero -- a distinction the original \
            \ flat object could not express, because a failure produced no object at all."
        {"card-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold reads as <0.0001 rather than 0.0."
        (let ((v:string (format "{}" [(floor amount 4)])))
            (if (= v "0.0") "<0.0001" v)
        )
    )
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form with a floor below which a price reads as <0.001c."
        (if (< input-price 0.00001)
            "<0.001c"
            (if (< input-price 1.00)
                (format "{}c" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )
    (defun UC_PickId:string (derived:[string] fallback:string)
        @doc "Derived first, registry as fallback. See RD-HEADER's copy for the full reasoning: \
            \ a derived id is the only form a sandbox can test, a registry id is the only form \
            \ proven on mainnet, and an unset reverse index returns [\"|\"] rather than [] -- a \
            \ sentinel, which is why this is an explicit check and not a `try`."
        (let ((ref-U|CT:module{OuronetConstantsV2} U|CT))
            (if (= (length derived) 0)
                fallback
                (if (= (at 0 derived) (ref-U|CT::CT_BAR)) fallback (at 0 derived))
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Value:decimal (id:string amount:decimal price:decimal)
        @doc "Amount times price, floored to the token's own precision."
        (let ((ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF))
            (floor (* amount price) (ref-DPTF::UR_Decimals id))
        )
    )

    (defun URC_Prices:[decimal] ()
        @doc "Dollar prices for the seven priced primordials, in order: \
            \ OURO, IGNIS, AURYN, ELITEAURYN, WSTOA, SSTOA, GSTOA. \
            \ \
            \ Public and called per card rather than computed once and passed down -- see the \
            \ file header. IGNIS is a fixed 0.01 by definition, not a market price."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ATS:module{AutostakeV3} ATS)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ref-DIA:module{DiaStoaPidV2} U|CT)
              (idx-a:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_AurynID))
                                       OuronetIdsV1.IDX_AURYNDEX))
              (idx-e:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_EliteAurynID))
                                       OuronetIdsV1.IDX_EAURYNDEX))
              (idx-s:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_SILVERPILLAR))
              (idx-g:string (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_GOLDENPILLAR))
              (p-ouro:decimal (ref-SWPI::URC_OuroPrimordialPrice))
              (p-auryn:decimal (floor (* p-ouro (ref-ATS::URC_Index idx-a)) 24))
              (p-eauryn:decimal (floor (* p-auryn (ref-ATS::URC_Index idx-e)) 24))
              (p-wstoa:decimal (ref-DIA::UR_STOA-PID|Price))
              (p-sstoa:decimal (floor (* p-wstoa (ref-ATS::URC_Index idx-s)) 24))
              (p-gstoa:decimal (floor (* p-sstoa (ref-ATS::URC_Index idx-g)) 24)) )
            [p-ouro 0.01 p-auryn p-eauryn p-wstoa p-sstoa p-gstoa]
        )
    )

    (defun URC_Ouro:object (account:string)
        @doc "The OURO card: held, virtual, dispo capacity, and global supply. \
            \ `dispo-capacity` is the ABSOLUTE value of URC_MinimumOuro -- a negative minimum \
            \ is a credit, and the card shows it as a positive capacity."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (id:string (ref-DALOS::UR_OuroborosID))
              (p:decimal (at 0 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (virtual:decimal (ref-TFT::URC_VirtualOuro account))
              (dispo:decimal (abs (ref-TFT::URC_MinimumOuro account)))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)      , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"v-balance" : (UC_Amount virtual) , "v-balance-hover" : virtual
            ,"v-balance-vid" : (UC_Price (URC_Value id virtual p))
            ,"dispo-capacity" : (UC_Amount dispo), "dispo-capacity-hover" : dispo
            ,"dispo-capacity-vid" : (UC_Price (URC_Value id dispo p))
            ,"supply" : (UC_Amount supply)     , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_Ignis:object (account:string)
        @doc "The IGNIS card, plus both gas-discount strings. IGNIS is priced at a flat 0.01 by \
            \ definition rather than by a pool, so this card cannot fail on pricing."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_IgnisID))
              (p:decimal 0.01)
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id))
              (i-d:decimal (ref-DALOS::URC_IgnisGasDiscount account))
              (s-d:decimal (ref-DALOS::URC_StoaGasDiscount account)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))
            ,"ignis-discount-text" :
                (format "IGNIS Discount {}% (You pay only {}% of IGNIS costs)"
                        [(* (- 1.0 i-d) 100.0) (* i-d 100.0)])
            ,"stoa-discount-text" :
                (format "STOA Discount {}% (You pay only {}% of STOA costs)"
                        [(* (- 1.0 s-d) 100.0) (* s-d 100.0)])}
        )
    )

    (defun URC_Auryn:object (account:string)
        @doc "The AURYN card: held and global supply."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_AurynID))
              (p:decimal (at 2 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_EliteAuryn:object (account:string)
        @doc "The ELITEAURYN card, including how much more is needed for the next Elite tier. \
            \ `next` counts across ALL Elite-Auryn variants (ELITE::URC_EliteAurynzSupply), not \
            \ just the native balance on this card -- which is why the two numbers differ."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ELITE:module{EliteV2} ELITE)
              (id:string (ref-DALOS::UR_EliteAurynID))
              (p:decimal (at 3 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id))
              (total:decimal (ref-ELITE::URC_EliteAurynzSupply account))
              (et:[decimal] (ref-U|CT::CT_ET))
              (et-last:decimal (at (- (length et) 1) et))
              (next:decimal
                (if (>= total et-last)
                    0.0
                    (- (fold (lambda (acc:decimal tier:decimal)
                                (if (and (> tier total) (< tier acc)) tier acc))
                             et-last et)
                       total))) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"next" : (UC_Amount next)     , "next-hover" : next
            ,"next-vid" : (UC_Price (URC_Value id next p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_UrStoa:object (account:string)
        @doc "The UrStoa card: the vault's claimable rewards and total STOA, plus this \
            \ account's wrapped UrStoa. \
            \ \
            \ THE VAULT ADDRESS IS A HARDCODED PRINCIPAL (URSTOA-VAULT). It is a `coin` account, \
            \ not an Ouronet entity id, so OuronetIdsV1 is the wrong home for it and \
            \ _hardcodedids.py does not match its shape. Carried over from \
            \ DPL-UR::URC_0002_PrimordialsSingle verbatim and named so it is visible."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (ref-urcoin:module{stoa-ns.ur-stoic-fungible-v1} coin)
              (id:string (ref-DALOS::UR_UrStoaID))
              (payment-key:string (ref-DALOS::UR_AccountStoa account))
              (earnings:decimal (coin.URC_URV|ClaimableRewards payment-key))
              (vault-supply:decimal (ref-coin::UR_Balance URSTOA-VAULT)) )
            {"card-ok" : true, "id" : id
            ,"payment-key-balance" : (try 0.0 (ref-urcoin::UR_UR|Balance payment-key))
            ,"vault-balance" : (coin.UR_URV|UserSupply payment-key)
            ,"vault-earnings" : (UC_Amount earnings), "vault-earnings-hover" : earnings
            ,"vault-stoa-supply" : (UC_Amount vault-supply)
            ,"vault-stoa-supply-hover" : vault-supply
            ,"wrapped-balance" : (ref-DPTF::UR_AccountSupply id account)}
        )
    )

    (defun URC_Stoa:object (account:string)
        @doc "The STOA card: the NATIVE coin balance on the account's payment key and the \
            \ WRAPPED WSTOA balance inside Ouronet. Two different ledgers, one card -- which is \
            \ why the native read is wrapped in `try`: an account with no coin row is normal, \
            \ not an error."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (id:string (ref-DALOS::UR_WrappedStoaID))
              (p:decimal (at 4 (URC_Prices)))
              (payment-key:string (ref-DALOS::UR_AccountStoa account))
              (native:decimal (try 0.0 (ref-coin::UR_Balance payment-key)))
              (wrapped:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"native-balance" : (UC_Amount native), "native-balance-hover" : native
            ,"native-balance-vid" : (UC_Price (URC_Value id native p))
            ,"wrapped-balance" : (UC_Amount wrapped), "wrapped-balance-hover" : wrapped
            ,"wrapped-balance-vid" : (UC_Price (URC_Value id wrapped p))
            ,"wrapped-total-supply" : (UC_Amount supply)
            ,"wrapped-total-supply-hover" : supply
            ,"wrapped-total-supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_SilverStoa:object (account:string)
        @doc "The SSTOA card: held and global supply."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_SilverStoaID))
              (p:decimal (at 5 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_GoldenStoa:object (account:string)
        @doc "The GSTOA card: liquid held, HIBERNATED held (a DPOF, counted across nonces), and \
            \ the two summed. \
            \ \
            \ GSTOA IS DERIVED THROUGH THE POOL, not DALOS::UR_GoldenStoaID, and that is \
            \ deliberate -- UR_GoldenStoaID reads BAR in the REPL fixture, so the DALOS route \
            \ leaves this card unrunnable in test. Measured 2026-09-24: \
            \ SSTOA -> KORIndex -> PSTOA -> H|PSTOA resolves in the fixture and on chain alike. \
            \ \
            \ THE NONCE COUNT IS NOT HERE. It needs DPOF::URH_AccountNonces, which is a `select`, \
            \ and a `select` cannot run inside a `try` -- see URH_GoldenStoaNonces below. Keeping \
            \ it here would make this card untriable and take the whole composer down with it."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ATS:module{AutostakeV3} ATS)
              (idx-g:string (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_GOLDENPILLAR))
              (id:string (ref-ATS::UR_ColdRewardBearingToken idx-g))
              (hid:string (ref-DPTF::UR_Hibernation id))
              (p:decimal (at 6 (URC_Prices)))
              (liquid:decimal (ref-DPTF::UR_AccountSupply id account))
              (hib:decimal (ref-DPOF::UR_AccountSupply hid account))
              (total:decimal (+ liquid hib))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "hibernated-id" : hid
            ,"name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount liquid), "balance-hover" : liquid
            ,"balance-vid" : (UC_Price (URC_Value id liquid p))
            ,"hibernated-balance" : (UC_Amount hib), "hibernated-balance-hover" : hib
            ,"hibernated-balance-vid" : (UC_Price (URC_Value id hib p))
            ,"total-balance" : (UC_Amount total), "total-balance-hover" : total
            ,"total-balance-vid" : (UC_Price (URC_Value id total p))
            ,"supply" : (UC_Amount supply), "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URH_GoldenStoaNonces:object (account:string)
        @doc "How many distinct nonces the account's hibernated GoldenStoa is spread across. \
            \ \
            \ SEPARATE, AND `URH_` PREFIXED, FOR A HARD REASON. This calls \
            \ DPOF::URH_AccountNonces, which is a `select` -- a full table scan. Pact evaluates \
            \ a `try` body in READ-ONLY mode, and `select` and `keys` are disallowed there. So \
            \ any card containing this could not be wrapped in `try`, and an untriable card in \
            \ the composer aborts the WHOLE object -- which is exactly the all-or-nothing \
            \ behaviour this module exists to remove. \
            \ \
            \ Measured 2026-09-24: with the scan inline, URC_Wallet died on \
            \ \"Operation disallowed in read-only or sys-only mode\" at 06_DPOF.pact:1857, while \
            \ every card still passed when called individually. \
            \ \
            \ Deliberately NOT in URC_Wallet. A caller that wants the count asks for it, and \
            \ pays a scan to get it."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ATS:module{AutostakeV3} ATS)
              (id:string (ref-ATS::UR_ColdRewardBearingToken
                           (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                      OuronetIdsV1.IDX_GOLDENPILLAR)))
              (hid:string (ref-DPTF::UR_Hibernation id))
              (hib:decimal (ref-DPOF::UR_AccountSupply hid account))
              (n:integer (length (ref-DPOF::URH_AccountNonces account hid))) )
            {"card-ok" : true
            ,"hibernated-id" : hid
            ,"nonces" : n
            ,"balance-nonces" : (format "{} ({})" [(UC_Amount hib) n])
            ,"balance-nonces-hover" :
                (format "Exactly {} Hibernated GoldenStoa over {} {}"
                        [hib n (if (= 1 n) "single Nonce" "Nonces")])}
        )
    )

    (defun URC_Totals:object (account:string)
        @doc "Net worth, in the two forms the original produced: with OURO, and with OURO plus \
            \ the dispo credit. \
            \ \
            \ This recomputes every balance rather than summing the cards, and that is the one \
            \ place in this module where duplication is load-bearing: a total assembled from \
            \ cards would silently UNDERCOUNT whenever a card failed, reporting a smaller net \
            \ worth as though it were a real one. Recomputing means the total either is correct \
            \ or fails outright -- and a failed total is visible, where a quiet undercount is not."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (ref-ATS:module{AutostakeV3} ATS)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (pp:[decimal] (URC_Prices))
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (ignis:string (ref-DALOS::UR_IgnisID))
              (auryn:string (ref-DALOS::UR_AurynID))
              (eauryn:string (ref-DALOS::UR_EliteAurynID))
              (wstoa:string (ref-DALOS::UR_WrappedStoaID))
              (sstoa:string (ref-DALOS::UR_SilverStoaID))
              (gstoa:string (ref-ATS::UR_ColdRewardBearingToken
                              (UC_PickId (ref-DPTF::UR_RewardToken sstoa)
                                         OuronetIdsV1.IDX_GOLDENPILLAR)))
              (gstoa-total:decimal (+ (ref-DPTF::UR_AccountSupply gstoa account)
                                      (ref-DPOF::UR_AccountSupply
                                        (ref-DPTF::UR_Hibernation gstoa) account)))
              (core:decimal
                (fold (+) 0.0
                    [ (URC_Value ignis  (ref-DPTF::UR_AccountSupply ignis account)  (at 1 pp))
                      (URC_Value auryn  (ref-DPTF::UR_AccountSupply auryn account)  (at 2 pp))
                      (URC_Value eauryn (ref-DPTF::UR_AccountSupply eauryn account) (at 3 pp))
                      (URC_Value wstoa  (try 0.0 (ref-coin::UR_Balance
                                          (ref-DALOS::UR_AccountStoa account)))     (at 4 pp))
                      (URC_Value wstoa  (ref-DPTF::UR_AccountSupply wstoa account)  (at 4 pp))
                      (URC_Value sstoa  (ref-DPTF::UR_AccountSupply sstoa account)  (at 5 pp))
                      (URC_Value gstoa  gstoa-total                                 (at 6 pp)) ]))
              (with-ouro:decimal
                (+ core (URC_Value ouro (ref-DPTF::UR_AccountSupply ouro account) (at 0 pp))))
              (with-vouro:decimal
                (+ with-ouro
                   (URC_Value ouro (abs (ref-TFT::URC_MinimumOuro account)) (at 0 pp)))) )
            {"card-ok" : true
            ,"total-value" : (UC_Price with-ouro)
            ,"total-value-with-vouro" : (UC_Price with-vouro)}
        )
    )

    (defun URC_Codex:object (codex-accounts:[string])
        @doc "Aggregate resident IGNIS across a Codex's accounts. Takes the account LIST from \
            \ the caller -- the Codex membership lives client-side, and a read module has no \
            \ business scanning for it."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (id:string (ref-DALOS::UR_IgnisID))
              (total:decimal
                (fold (+) 0.0
                    (map (lambda (a:string) (ref-DALOS::UR_TF_AccountSupply a false))
                         codex-accounts))) )
            {"card-ok" : true
            ,"codex-balance" : (UC_Amount total)
            ,"codex-balance-hover" : total
            ,"codex-balance-vid" : (UC_Price (URC_Value id total 0.01))}
        )
    )

    (defun URC_Wallet:object (account:string codex-accounts:[string])
        @doc "Every card in one call, each under `try`. A failing card yields UDC_ZeroCard \
            \ (card-ok false) and the rest still render -- so the card that comes back dead IS \
            \ the diagnosis, at no extra query. \
            \ \
            \ Callers wanting a hard failure should call the card directly; callers wanting to \
            \ minimise reads should call only the cards they display, which is the reason every \
            \ one of them is public."
        {"ouro"        : (try (UDC_ZeroCard) (URC_Ouro account))
        ,"ignis"       : (try (UDC_ZeroCard) (URC_Ignis account))
        ,"auryn"       : (try (UDC_ZeroCard) (URC_Auryn account))
        ,"eliteauryn"  : (try (UDC_ZeroCard) (URC_EliteAuryn account))
        ,"urstoa"      : (try (UDC_ZeroCard) (URC_UrStoa account))
        ,"stoa"        : (try (UDC_ZeroCard) (URC_Stoa account))
        ,"silverstoa"  : (try (UDC_ZeroCard) (URC_SilverStoa account))
        ,"goldenstoa"  : (try (UDC_ZeroCard) (URC_GoldenStoa account))
        ,"totals"      : (try (UDC_ZeroCard) (URC_Totals account))
        ,"codex"       : (try (UDC_ZeroCard) (URC_Codex codex-accounts))}
    )
)
