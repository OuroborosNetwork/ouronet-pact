;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 19
;; PUiOneV1 (interface) + P-UI-ONE (module) -- restore three reads PureV2/14 should not
;; have deleted
;; =========================================================================================
;; INDEPENDENT of the other PureV2 files. Both are FIRST deploys: namespace keyset only.
;;
;; *** THIS REPAIRS A BREAKAGE I CAUSED. *** PureV2/14 put DPL-UR into archive mode and deleted
;; URC_0031, URC_0033_DualApiKeyMapper and URC_0034_PythiaPrices on the stated grounds that
;; nothing called them. Something does: `@ancientpantheon/codex` calls all three, from its
;; bundled chunks. Pythia API-key management in the Codex UI has been broken since that
;; transaction landed.
;;
;; HOW THE CENSUS MISSED IT, which is the part worth keeping. The search that produced "no
;; application calls them" swept `.ts`, `.tsx`, `.js`, `.json` and `.md` across daimons/,
;; _libs/, websites/ and _onchain/ -- and never entered `node_modules`. The caller is a
;; COMPILED DEPENDENCY. A grep over source trees cannot see one, so "no callers found" meant
;; only that none were found where it looked, and that was read as though it meant none exist.
;;
;; Before deleting a deployed function, search the DEPENDENCY SET too: `node_modules/**/dist`
;; is where a package's calls actually live. The rule this broke -- never delete a function
;; anything still calls -- was never in doubt; the evidence behind "anything" was.
;;
;; WHY HERE AND NOT BACK INTO DPL-UR. DPL-UR is archived; returning reads to it would undo the
;; one property archive mode buys, that there is exactly one place each read lives. These
;; belong in AppReads under the app that consumes them, which is what this module is.
;;
;; AND WHY THEY PORT CLEANLY DESPITE HAVING NO SCREEN IN THIS WORKSPACE. The folder's rule --
;; reads are pulled by a UI -- guards against inventing a SHAPE, and applies to composed reads
;; where what to bundle is a design decision. These are passthroughs: two map a PYTHIA row
;; reader across a list, one returns two config prices with their display text. The shape is
;; PYTHIA's, so there is nothing to guess. The deferral was the wrong call on its own terms,
;; before the census turned out to be wrong as well.
;;
;; KEY-FOR-KEY AND ARGUMENT-FOR-ARGUMENT with the functions they replace, so the consumer
;; changes a name and nothing else:
;;     DPL-UR::URC_0031                   -> P-UI-ONE::URC_01|ApiKeys
;;     DPL-UR::URC_0033_DualApiKeyMapper  -> P-UI-ONE::URC_02|DualLinks
;;     DPL-UR::URC_0034_PythiaPrices      -> P-UI-ONE::URC_03|Prices
;;
;; SEPARATELY, AND NOT CAUSED BY THIS: URC_03|Prices fails on mainnet today because
;; DALOS|PricesTable has no `stoa|price` row -- the LIVE PYTHIA's UR_DeployPrice reads it. That
;; predates the migration (DPL-UR::URC_0034 failed identically).
;;
;; CORRECTED 2026-10-02: this called it "an init gap, not a code one", and it is the reverse.
;; The PYTHIA IN THIS TREE reads `(at "deploy-price" (UR_Config))` -- its own config row, no
;; usage-price key anywhere. Only the DEPLOYED PYTHIA still reaches for `stoa|price`. So the
;; repair is to ship the current PYTHIA, not to write a row into a table that, after the
;; 2026-10-02 owner ruling, nothing in the tree reads at all:
;;
;;     (ouronet-ns.PYTHIA.UR_DeployPrice)    -> failure ... for key: stoa|price   [live]
;;     (at "deploy-price" (UR_Config))                                            [tree]
;;
;; Writing the row would have made the console work and left two modules reading a key the
;; sources had already abandoned -- which is exactly the trap IGNIS::UC_StoaPrice was in.
;;
;; SIGNING -- namespace keyset only. First deploys check no governance; a later UPGRADE will
;; check GOV|P_UI_ONE_ADMIN.
;;
;; MEASURED in the REPL fixture: deploy 2,654 gas.
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/Pythia/01_P-UI-ONE.pact
(interface PUiOneV1
    @doc "Pythia console reads: Apollo API-key rows, dual-link rows, and the deploy/rename \
        \ prices from PYTHIA config. Complete surface."

    ;;{5.3}  Read [UR/URC/URH]
    ;;  CLIENT READS -- see the banner in the module body.
    (defun URC_01|ApiKeys:[object] (apollo-accounts:[string]))
    (defun URC_02|DualLinks:[object] (dual-api-keys:[string]))
    (defun URC_03|Prices:object ())
)

(module P-UI-ONE GOV

    ;;{0}  IMPLEMENTERS
    (implements PUiOneV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_P-UI-ONE               (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|P_UI_ONE_ADMIN)))
    (defcap GOV|P_UI_ONE_ADMIN ()           (enforce-guard GOV|MD_P-UI-ONE))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH]
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- called BY NAME from @ancientpantheon/codex. The `NN|` designator is the
    ;; pin: argument list and key shape are a wire contract.
    ;; ---------------------------------------------------------------------------------------
    (defun URC_01|ApiKeys:[object] (apollo-accounts:[string])
        @doc "The API-key row for each Apollo account (₱. / Π.). A row that does not exist \
            \ comes back as PYTHIA's own null form rather than throwing, which is what makes \
            \ this usable as a selector over accounts a user is still typing. \
            \ \
            \ Replaces DPL-UR::URC_0031."
        (let
            (
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
            )
            (map
                (lambda (apollo-account:string)
                    (ref-PYTHIA::UR_ApiKeyRowOrNull apollo-account))
                apollo-accounts
            )
        )
    )
    (defun URC_02|DualLinks:[object] (dual-api-keys:[string])
        @doc "The dual-link row for each composite Standard|Smart key. Same null-tolerant \
            \ contract as URC_01|ApiKeys. \
            \ \
            \ Replaces DPL-UR::URC_0033_DualApiKeyMapper."
        (let
            (
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
            )
            (map
                (lambda (dual-api-key:string)
                    (ref-PYTHIA::UR_DualLinkRowOrNull dual-api-key))
                dual-api-keys
            )
        )
    )
    (defun URC_03|Prices:object ()
        @doc "The two STOA prices PYTHIA config carries, each with the sentence the console \
            \ renders. The text is part of the wire format, not a convenience -- it ships the \
            \ UNITS with the number, which is the difference between `500.0` and `500.0 STOA \
            \ per Apollo half deploy`. \
            \ \
            \ Replaces DPL-UR::URC_0034_PythiaPrices, key-for-key."
        (let
            (
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
                ;;
                (deploy-price:decimal (ref-PYTHIA::UR_DeployPrice))
                (rename-price:decimal (ref-PYTHIA::UR_RenamePrice))
            )
            {"deploy-price"         : deploy-price
            ,"rename-price"         : rename-price
            ,"deploy-price-text"    : (format "{} STOA per Apollo half deploy" [deploy-price])
            ,"rename-price-text"    : (format "{} STOA to rename dual-link consumer lane" [rename-price])
            }
        )
    )
)

