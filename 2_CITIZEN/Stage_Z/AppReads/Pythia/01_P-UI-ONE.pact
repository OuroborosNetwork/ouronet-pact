;; ===========================================================================================
;; P-UI-ONE -- the Pythia oracle console: Apollo API keys, dual links, and the config prices.
;; ===========================================================================================
;; Pythia entity 1. Template: ../OuronetUI/01_O-UI-ONE.pact. Rules: ../RULES.md.
;;
;; REPLACES DPL-UR::URC_0031 / _0033_DualApiKeyMapper / _0034_PythiaPrices, key-for-key and
;; argument-for-argument, so a consumer changes a name and nothing else.
;;
;; ------------------------------------------------------------------------------------------
;; THIS MODULE EXISTS BECAUSE THE CENSUS THAT DEFERRED IT WAS WRONG
;; ------------------------------------------------------------------------------------------
;; These three were deliberately NOT ported. The reasoning was the folder's own rule -- reads
;; are PULLED by a UI, and no oracle console exists in this workspace to pull them -- backed by
;; a search that reported "two hits, both of them this migration's own paperwork. No application
;; calls them." On that basis PureV2/14 deleted them from DPL-UR.
;;
;; THE SEARCH WAS WRONG. It swept `.ts`, `.tsx`, `.js`, `.json` and `.md` across daimons/,
;; _libs/, websites/ and _onchain/ -- and never looked inside `node_modules`. The consumer is
;; `@ancientpantheon/codex`, a COMPILED DEPENDENCY, which calls all three from its bundled
;; chunks. So archive mode broke Pythia API-key management in the Codex UI, and it broke the
;; one rule that was supposed to make archive mode safe: never delete a function anything still
;; calls.
;;
;; THE LESSON IS ABOUT THE SEARCH, NOT THE READS. A compiled dependency is a caller. A grep
;; over source trees cannot see one, and "no callers found" from such a grep means only that
;; none were found where it looked. Before deleting a deployed function, search the DEPENDENCY
;; SET as well -- `node_modules/**/dist` is where a package's calls actually live.
;;
;; ------------------------------------------------------------------------------------------
;; WHY THESE PORT CLEANLY DESPITE NEVER HAVING A SCREEN
;; ------------------------------------------------------------------------------------------
;; The pull-from-the-screen rule guards against inventing a SHAPE. It applies to composed reads,
;; where what to bundle is a design decision -- URC_0001_HeaderV3's seventy-key object is the
;; warning. These three are passthroughs: two map a PYTHIA row reader across a list, one returns
;; two config prices with their display text. There is no shape to guess, because the shape is
;; PYTHIA's. Porting them carries no design risk, which is why the deferral was the wrong call
;; even before the census turned out to be wrong.
;;
;; The value they add over calling PYTHIA directly is the mapper: one round trip for N keys
;; instead of N. That is worth a module on its own.
;; ===========================================================================================

(namespace "ouronet-ns")

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
