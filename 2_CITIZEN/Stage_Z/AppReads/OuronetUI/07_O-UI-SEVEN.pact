;; ===========================================================================================
;; O-UI-SEVEN -- the Codex: account selectors, StoicTag selectors, and the account overview.
;; ===========================================================================================
;; OuronetUI entity 7. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;;
;; REPLACES DPL-UR::URC_0027_AccountSelectorMapper / _0027a_AccountSelectorSingle /
;; _0027b_StoicTagSelectorMapper / _0027c_StoicTagSelectorSingle /
;; _0028_StoaAccountSelectorMapper / _0028a_StoaAccountSelectorSingle / _0029_AccountOverview.
;;
;; This module needs no page composer. Its reads are ALREADY batched -- three of the seven are
;; mappers that take a list and answer in one round trip, which is the shape the rest of
;; AppReads is being pushed towards. Adding a composer over a batch read would only nest one
;; list inside another.
;;
;; ------------------------------------------------------------------------------------------
;; EVERY READ HERE MUST ANSWER FOR AN ACCOUNT THAT DOES NOT EXIST
;; ------------------------------------------------------------------------------------------
;; That is not a degradation story, it is the FEATURE. A selector's job is to tell a user
;; whether the thing they just typed is real, so "not found" is a legitimate answer and must
;; come back as data, never as a thrown transaction. Hence the `try`-to-sentinel bindings
;; throughout, and hence the three-way `iz-smart` (-1 for non-existence, distinct from the
;; booleans), the -1.0 balances and the BAR strings. Preserve these exactly: the UI reads them
;; as discriminators, so a "tidier" 0.0 or false would silently merge "empty" with "absent".
;;
;; Note the `try`s are safe here for the reason ../RULES.md rule 5 gives: none of these reads
;; is a `select` or a `keys`. `try` runs its body in READ-ONLY mode, which permits `read` and
;; `with-default-read` and nothing wider.
;;
;; ------------------------------------------------------------------------------------------
;; ONE COIN READ INSTEAD OF THREE
;; ------------------------------------------------------------------------------------------
;; URC_0027a sampled the payment key with `get-balance` inside a `try`, then -- on success --
;; called `get-balance` AGAIN for the number and `details` a third time for the guard. Three
;; round trips into the coin contract for one row. URC_02|Account samples `details` once and
;; reads both fields off the sample, which is the pattern URC_0028a in the same file already
;; used. Identical output, verified field-by-field against DPL-UR in the fixture.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiSevenV1
    @doc "Codex reads: Ouronet account selectors, Stoa account selectors, StoicTag selectors, \
        \ and the pre-transaction account overview. Every one answers for a non-existent \
        \ subject rather than throwing."

    ;;{5.3}  Read [UR/URC/URH]
    ;;  CLIENT READS -- see the banner in the module body.
    (defun URC_01|Accounts:[object] (accounts:[string]))
    (defun URC_02|Account:object (account:string))
    (defun URC_03|StoicTags:[object] (tag-names:[string]))
    (defun URC_04|StoicTag:object (tag-name:string))
    (defun URC_05|StoaAccounts:[object] (stoa-accounts:[string]))
    (defun URC_06|StoaAccount:object (stoa-account:string))
    (defun URC_07|Overview:object (selected-ouronet-account:string))
)

(module O-UI-SEVEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiSevenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-SEVEN             (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_SEVEN_ADMIN)))
    (defcap GOV|O_UI_SEVEN_ADMIN ()         (enforce-guard GOV|MD_O-UI-SEVEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH]
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- everything below is called BY NAME from OuronetUI. The `NN|` designator
    ;; is the pin: argument list and key shape are a wire contract.
    ;; ---------------------------------------------------------------------------------------
    (defun URC_01|Accounts:[object] (accounts:[string])
        @doc "URC_02|Account across a list -- the account picker's one round trip. \
            \ \
            \ Replaces DPL-UR::URC_0027_AccountSelectorMapper."
        (map (lambda (account:string) (URC_02|Account account)) accounts)
    )
    (defun URC_02|Account:object (account:string)
        @doc "Everything the picker shows about one Ouronet account: whether it exists at all, \
            \ its guard and type, OURO and IGNIS balances, its Stoa payment key with that \
            \ key's own balance and guard, both gas discounts, sovereign and governor, and its \
            \ StoicTag. \
            \ \
            \ Replaces DPL-UR::URC_0027a_AccountSelectorSingle, key-for-key."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (let
                (
                    (bar:string (ref-U|CT::CT_BAR))
                    (public-key:string
                        (try (ref-U|CT::CT_BAR) (ref-DALOS::UR_AccountPublicKey account)))
                )
                (let
                    (
                        (iz-activated:bool (!= public-key bar))
                    )
                    (let
                        (
                            (ref-coin:module{stoa-ns.fungible-v1} coin)
                            (ref-CODEX:module{CodexV2} CODEX)
                            ;;
                            (payment-key:string
                                (if iz-activated (ref-DALOS::UR_AccountStoa account) bar))
                            (stba-data:object
                                (if iz-activated
                                    (ref-CODEX::UR_STBA|DataOrNull account)
                                    {"has-stoictag": false, "tag-name": bar}
                                )
                            )
                        )
                        (let
                            (
                                ;;ONE coin read, not three -- see the module header.
                                (pke-sample
                                    (if (= payment-key bar)
                                        false
                                        (try false (ref-coin::details payment-key))
                                    )
                                )
                                (stoic-tag-has:bool (at "has-stoictag" stba-data))
                            )
                            (let
                                (
                                    (pke:bool (!= (typeof pke-sample) "bool"))
                                )
                                {"iz-activated"             : iz-activated
                                ,"ouronet-account"          : account
                                ,"ouronet-account-guard"    :
                                    (if iz-activated (ref-DALOS::UR_AccountGuard account) false)
                                ,"iz-smart"                 :
                                    (if iz-activated (ref-DALOS::UR_AccountType account) -1)
                                ,"ouro-balance"             :
                                    (if iz-activated
                                        (ref-DALOS::UR_TF_AccountSupply account true) 0.0)
                                ,"ignis-balance"            :
                                    (if iz-activated
                                        (ref-DALOS::UR_TF_AccountSupply account false) 0.0)
                                ,"payment-key-existance"    : pke
                                ,"payment-key"              : payment-key
                                ,"payment-key-balance"      :
                                    (if pke (at "balance" pke-sample) -1.0)
                                ,"payment-key-guard"        :
                                    (if pke (at "guard" pke-sample) false)
                                ,"ignis-discount"           :
                                    (if iz-activated
                                        (ref-DALOS::URC_IgnisGasDiscount account) false)
                                ,"stoa-discount"            :
                                    (if iz-activated
                                        (ref-DALOS::URC_StoaGasDiscount account) false)
                                ;;
                                ,"public-key"               : public-key
                                ,"sovereign"                :
                                    (if iz-activated
                                        (ref-DALOS::UR_AccountSovereign account) bar)
                                ,"governor"                 :
                                    (if iz-activated
                                        (ref-DALOS::UR_AccountGovernor account) false)
                                ;;
                                ,"stoic-tag-has"            : stoic-tag-has
                                ,"stoic-tag"                :
                                    (if stoic-tag-has (at "tag-name" stba-data)
                                                      "No StoicTag yet")
                                ,"stoic-tag-registered-at"  :
                                    (if stoic-tag-has
                                        (ref-CODEX::UR_STG|RegisteredAt (at "tag-name" stba-data))
                                        false)
                                }
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URC_03|StoicTags:[object] (tag-names:[string])
        @doc "URC_04|StoicTag across a list -- the Mnemosyne tag picker's one round trip. \
            \ \
            \ Replaces DPL-UR::URC_0027b_StoicTagSelectorMapper."
        (map (lambda (tag-name:string) (URC_04|StoicTag tag-name)) tag-names)
    )
    (defun URC_04|StoicTag:object (tag-name:string)
        @doc "The inverse selector: given a tag, is it taken, was it released, and which \
            \ account holds it. \
            \ \
            \ THREE STATES, not two, and the UI needs all three: never registered, registered \
            \ and active, registered and released. A released tag has a row and no account -- \
            \ collapsing it into `iz-active false` would make a released tag look free."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-CODEX:module{CodexV2} CODEX)
                ;;
                (row-exists:bool (!= (try false (ref-CODEX::UR_STG|Data tag-name)) false))
            )
            (let
                (
                    (iz-active:bool
                        (if row-exists (ref-CODEX::UR_STG|IzActive tag-name) false))
                )
                {"stoic-tag"            : tag-name
                ,"iz-row-exists"        : row-exists
                ,"iz-active"            : iz-active
                ,"iz-released"          : (and row-exists (not iz-active))
                ,"iz-never-registered"  : (not row-exists)
                ,"ouronet-account"      :
                    (if iz-active
                        (ref-CODEX::UR_STG|AccountAddress tag-name)
                        (ref-U|CT::CT_BAR))
                ,"registered-at"        :
                    (if row-exists (ref-CODEX::UR_STG|RegisteredAt tag-name) false)
                }
            )
        )
    )
    (defun URC_05|StoaAccounts:[object] (stoa-accounts:[string])
        @doc "URC_06|StoaAccount across a list. \
            \ \
            \ Replaces DPL-UR::URC_0028_StoaAccountSelectorMapper."
        (map (lambda (stoa-account:string) (URC_06|StoaAccount stoa-account)) stoa-accounts)
    )
    (defun URC_06|StoaAccount:object (stoa-account:string)
        @doc "One native Stoa account: does it exist in the coin table, and if so its balance \
            \ and guard. A -1.0 balance means ABSENT, which is distinct from a real zero. \
            \ \
            \ Replaces DPL-UR::URC_0028a_StoaAccountSelectorSingle, key-for-key."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                ;;
                (stoa-sample (try false (ref-coin::details stoa-account)))
            )
            (let
                (
                    (iz-activated:bool (!= (typeof stoa-sample) "bool"))
                )
                {"iz-activated" : iz-activated
                ,"account"      : stoa-account
                ,"balance"      : (if iz-activated (at "balance" stoa-sample) -1.0)
                ,"guard"        : (if iz-activated (at "guard" stoa-sample) false)
                }
            )
        )
    )
    (defun URC_07|Overview:object (selected-ouronet-account:string)
        @doc "The pre-transaction banner: is the network paused, does the selected account \
            \ exist, and what native STOA would it cost to bring it into being. \
            \ \
            \ An ACTIVATED account costs nothing, and so does an unactivated one while native \
            \ gas is free -- those two zero paths are different reasons for the same number, \
            \ which is why the read returns the cost rather than a boolean. \
            \ \
            \ Replaces DPL-UR::URC_0029_AccountOverview, key-for-key."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (let
                (
                    (iz-activated:bool
                        (!= (try (ref-U|CT::CT_BAR)
                                 (ref-DALOS::UR_AccountPublicKey selected-ouronet-account))
                            (ref-U|CT::CT_BAR)))
                    (no-costs:object{OuronetInfoV2.ClientStoaCosts}
                        (ref-I|OURONET::OI|UDC_NoStoaCosts))
                )
                (let
                    (
                        (stoa-costs:object{OuronetInfoV2.ClientStoaCosts}
                            (if (or iz-activated (ref-IGNIS::URC_IsNativeGasZero))
                                no-costs
                                (ref-I|OURONET::OI|UDC_FullStoaCosts
                                    (ref-DALOS::UR_UsagePrice "standard"))
                            )
                        )
                    )
                    {"global-administrative-pause"  : (ref-DALOS::UR_GAP)
                    ,"iz-selected-activated"        : iz-activated
                    ,"stoa-costs"                   : (at "stoa-need" stoa-costs)}
                )
            )
        )
    )
)
