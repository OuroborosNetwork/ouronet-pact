;; ===========================================================================================
;; O-UI-TEN -- the Collectables page: semi- and non-fungible entries, nonce data, sets,
;; class filters, and the button map.
;; ===========================================================================================
;; OuronetUI entity 10. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;;
;; REPLACES DPL-UR::URC_0021 / _0022_CollectableEntry / _0022a_SemifungibleEntryMapper /
;; _0022a_NonfungibleEntryMapper / _0023 / _0024 / _0025 / _0025a / _0026 and the helper
;; UCx_NonFungibleNonceExistance -- nine reads and a predicate, the second-largest group.
;;
;; ------------------------------------------------------------------------------------------
;; A DEFECT FOUND WHILE PORTING, AND FIXED HERE -- the unreachable Wipe button
;; ------------------------------------------------------------------------------------------
;; URC_0026 opens its `let` with
;;
;;     (fn:integer (at 0 selected-nonces))
;;
;; and Pact evaluates `let` bindings EAGERLY. So calling it with an empty selection does not
;; return a map of mostly-false flags -- it THROWS, at the first binding, before any flag is
;; computed.
;;
;; Now read what `wipe` requires:
;;
;;     "wipe" : (fold (and) true [iz-empty can-wipe iz-owner])
;;
;; `iz-empty` is `(= (length selected-nonces) 0)`. The ONLY input that can make `wipe` true is
;; the exact input that crashes the function. The Wipe button is therefore UNREACHABLE -- not
;; mis-computed, not sometimes wrong: it has never once been returned as true, and an owner
;; who may wipe their collection has never been shown the button. The same crash takes `mint`'s
;; sibling flags down with it, so the whole action bar goes blank on an empty selection, which
;; is the page's INITIAL state.
;;
;; FIXED by binding `fn` defensively: `(if iz-empty 0 (at 0 selected-nonces))`. The value is
;; irrelevant when nothing is selected -- every flag that consults `fn` is already gated behind
;; `iz-single` or `(> fn 0)` -- so the fix changes no non-empty result. Pinned by the fixture,
;; which calls the read with `[]` and asserts it answers.
;;
;; ------------------------------------------------------------------------------------------
;; THE HEADER IS `URH_` AND UNCOMPOSABLE
;; ------------------------------------------------------------------------------------------
;; URC_0021 holds FOUR cross-module `keys` scans. Same quarantine as O-UI-EIGHT and O-UI-NINE:
;; nothing here calls URH_01|Header. A scan cannot sit inside `try` (read-only mode), and
;; `_conformance.py` tolerates a cross-module scan only in a function with zero Pact callers.
;;
;; ------------------------------------------------------------------------------------------
;; WHY THE ENTRY LISTS ARE NOT `try`-GUARDED
;; ------------------------------------------------------------------------------------------
;; URC_02|Entry reads DPDC::URH_AccountNoncesWithSupplies, a `select`. `try` runs its body in
;; read-only mode where `select` is disallowed (../RULES.md rule 5), so the per-row guard used
;; in O-UI-EIGHT is unavailable, and unlike O-UI-NINE there is no priced half to split out --
;; the entry is the nonce list plus a name. The residual risk is one unnamed collection
;; blanking the list, which is what DPL-UR does today; it is recorded here rather than papered
;; over.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiTenV1
    @doc "Collectables page reads: the header, per-collection entries for both fungibility \
        \ classes, nonce metadata, set definitions, class filters, and the button map."

    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_IzNonceTaken:bool (dpdc-id:string nonce:integer existance:bool))
    ;;  CLIENT READS -- see the banner in the module body.
    (defun URH_01|Header:object (account:string))
    (defun URC_02|Entry:object (account:string dpdc-id:string son:bool))
    (defun URC_03|SemiFungibleList:[object] (account:string dpdc-ids:[string]))
    (defun URC_04|NonFungibleList:[object] (account:string dpdc-ids:[string]))
    (defun URC_05|NonceData:[object] (dpdc-id:string son:bool nonces:[integer]))
    (defun URC_06|Sets:[object{DpdcUdcV2.DPDC|Set}] (dpdc-id:string son:bool))
    (defun URC_07|FilterByClass:[integer]
        (dpdc-id:string son:bool nonces:[integer] nonce-class:integer))
    (defun URC_08|FilterByClasses:[[integer]]
        (dpdc-id:string son:bool nonces:[integer] nonce-classes:[integer]))
    (defun URC_09|Buttons:object
        (account:string dpdc-id:string son:bool selected-nonces:[integer]))
    (defun URC_10|Wallet:object (account:string))
)

(module O-UI-TEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiTenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-TEN               (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_TEN_ADMIN)))
    (defcap GOV|O_UI_TEN_ADMIN ()           (enforce-guard GOV|MD_O-UI-TEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_IzNonceTaken:bool (dpdc-id:string nonce:integer existance:bool)
        @doc "Does this non-fungible nonce exist? `existance` flips the sense, so one function \
            \ answers both `burn` (must exist) and `respawn` (must not). \
            \ \
            \ A POSITIVE nonce is answered by its holder: an unheld nonce reads back as the \
            \ BAR sentinel. A nonce at or below zero is a FRAGMENT, which has no holder, so it \
            \ is answered by comparing its split-data against the zero object. \
            \ \
            \ Replaces DPL-UR::UCx_NonFungibleNonceExistance. RENAMED, and the rename is the \
            \ point: `UCx_` claims pure compute, and this reads two tables. The prefix is the \
            \ contract (StoicSyntax-Prefixes.md), so a table-reading predicate is `URC_`."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if (> nonce 0)
                (let
                    (
                        (held:bool
                            (!= (ref-U|CT::CT_BAR)
                                (ref-DPDC::UR_NonceHolder dpdc-id false nonce)))
                    )
                    (if existance held (not held))
                )
                (let
                    (
                        (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                        ;;
                        (defined:bool
                            (!= (ref-DPDC::UR_SplitNonceData dpdc-id false nonce)
                                (ref-DPDC-UDC::UDC_ZeroNonceData)))
                    )
                    (if existance defined (not defined))
                )
            )
        )
    )
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- everything below is called BY NAME from OuronetUI. The `NN|` designator
    ;; is the pin: argument list and key shape are a wire contract.
    ;; ---------------------------------------------------------------------------------------
    (defun URH_01|Header:object (account:string)
        @doc "Page header, both fungibility classes. HEAVY and UNCOMPOSABLE -- holds four \
            \ cross-module `keys` scans; see the module header. \
            \ \
            \ Replaces DPL-UR::URC_0021_CollectablesHeader, key-for-key -- including the two \
            \ inconsistent key names it ships with (`held-sf-number` but `mngd-sf-no`). Those \
            \ are WIRE FORMAT: the UI indexes them by string, so tidying them here would break \
            \ the page while looking like a cleanup."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (held-sf:[string] (ref-DPDC::URH_HeldCollectables account true))
                (mngd-sf:[string] (ref-DPDC::URH_OwnedCollectables account true))
                (held-nf:[string] (ref-DPDC::URH_HeldCollectables account false))
                (mngd-nf:[string] (ref-DPDC::URH_OwnedCollectables account false))
            )
            {"total-semi-fungible-number"       : (length (keys DPDC.DPSF|T|Properties))
            ,"total-semi-fungible-nonces"       : (length (keys DPDC.DPSF|T|Nonces))
            ,"held-sf"                          : held-sf
            ,"held-sf-number"                   : (length held-sf)
            ,"mngd-sf"                          : mngd-sf
            ,"mngd-sf-no"                       : (length mngd-sf)
            ;;
            ,"total-non-fungible-number"        : (length (keys DPDC.DPNF|T|Properties))
            ,"total-non-fungible-nonces"        : (length (keys DPDC.DPNF|T|Nonces))
            ,"held-nf"                          : held-nf
            ,"held-nf-number"                   : (length held-nf)
            ,"mngd-nf"                          : mngd-nf
            ,"mngd-nf-no"                       : (length mngd-nf)
            }
        )
    )
    (defun URC_02|Entry:object (account:string dpdc-id:string son:bool)
        @doc "One collection row: its name and every nonce this account holds of it, with \
            \ supplies. \
            \ \
            \ Replaces DPL-UR::URC_0022_CollectableEntry, key-for-key."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (wallet-nonces:[object]
                    (ref-DPDC::URH_AccountNoncesWithSupplies account dpdc-id son))
            )
            {"t1"               : (ref-DPDC::UR_Name dpdc-id son)
            ,"t2"               : dpdc-id
            ,"wallet-nonces"    : wallet-nonces
            ,"wallet-nonces-no" : (length wallet-nonces)
            }
        )
    )
    (defun URC_03|SemiFungibleList:[object] (account:string dpdc-ids:[string])
        @doc "URC_02|Entry across the semi-fungible collections. \
            \ \
            \ Replaces DPL-UR::URC_0022a_SemifungibleEntryMapper."
        (map (lambda (dpdc-id:string) (URC_02|Entry account dpdc-id true)) dpdc-ids)
    )
    (defun URC_04|NonFungibleList:[object] (account:string dpdc-ids:[string])
        @doc "URC_02|Entry across the non-fungible collections. \
            \ \
            \ Replaces DPL-UR::URC_0022a_NonfungibleEntryMapper."
        (map (lambda (dpdc-id:string) (URC_02|Entry account dpdc-id false)) dpdc-ids)
    )
    (defun URC_05|NonceData:[object] (dpdc-id:string son:bool nonces:[integer])
        @doc "Metadata for a list of nonces. A NEGATIVE nonce asks for a FRAGMENT and yields \
            \ its split-data; a positive one yields ordinary nonce-data. The sign is the \
            \ discriminator, which is why the two never mix in one list read. \
            \ \
            \ Replaces DPL-UR::URC_0023_CollectablesNonceData. The fold-with-UC_AppL is now a \
            \ `map` -- same result, one pass, no per-element list rebuild."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (map
                (lambda (nonce:integer)
                    (if (< nonce 0)
                        (at "split-data" (ref-DPDC::UR_NonceElement dpdc-id son (abs nonce)))
                        (at "nonce-data"  (ref-DPDC::UR_NonceElement dpdc-id son nonce))
                    )
                )
                nonces
            )
        )
    )
    (defun URC_06|Sets:[object{DpdcUdcV2.DPDC|Set}] (dpdc-id:string son:bool)
        @doc "Every set class defined on a collection, in class order. \
            \ \
            \ Replaces DPL-UR::URC_0024_SetReader."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
            )
            (map
                (lambda (set-class:integer) (ref-DPDC-S::UR_Set dpdc-id son set-class))
                (enumerate 1 (ref-DPDC::UR_SetClassesUsed dpdc-id son))
            )
        )
    )
    (defun URC_07|FilterByClass:[integer]
        (dpdc-id:string son:bool nonces:[integer] nonce-class:integer)
        @doc "Keeps only the nonces belonging to one set class. Returns [] when none match. \
            \ \
            \ Replaces DPL-UR::URC_0025_FilterNoncesByClass."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (filter
                (lambda (nonce:integer)
                    (= (ref-DPDC::UR_NonceClass dpdc-id son nonce) nonce-class))
                nonces
            )
        )
    )
    (defun URC_08|FilterByClasses:[[integer]]
        (dpdc-id:string son:bool nonces:[integer] nonce-classes:[integer])
        @doc "URC_07|FilterByClass for several classes at once; result[i] belongs to \
            \ nonce-classes[i]. One round trip instead of one per class, which is the whole \
            \ reason it exists alongside the singular form. \
            \ \
            \ Replaces DPL-UR::URC_0025a_FilterNoncesByClasses."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (map
                (lambda (nonce-class:integer)
                    (filter
                        (lambda (nonce:integer)
                            (= (ref-DPDC::UR_NonceClass dpdc-id son nonce) nonce-class))
                        nonces
                    )
                )
                nonce-classes
            )
        )
    )
    (defun URC_09|Buttons:object
        (account:string dpdc-id:string son:bool selected-nonces:[integer])
        @doc "Which collectable actions the chain will accept, given the account, the \
            \ collection and the nonces the user has ticked. \
            \ \
            \ Replaces DPL-UR::URC_0026_CollectablesButtons, key-for-key, and FIXES its \
            \ eager-binding crash on an empty selection -- see the module header for why that \
            \ made the Wipe button unreachable."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                ;;
                (l:integer (length selected-nonces))
                (first-two:string (take 2 dpdc-id))
                (can-wipe:bool (ref-DPDC::UR_CanWipe dpdc-id son))
                (iz-owner:bool (= account (ref-DPDC::UR_OwnerKonto dpdc-id son)))
                (burn-role:bool (ref-DPDC::UR_CA|R-Burn dpdc-id son account))
            )
            (let
                (
                    (iz-empty:bool (= l 0))
                    (iz-single:bool (= l 1))
                    (iz-multiple:bool (> l 1))
                    (iz-equity:bool (= first-two "E|"))
                )
                (let
                    (
                        ;;THE FIX. `(at 0 [])` throws, and Pact binds eagerly, so the original
                        ;;could not survive the page's own initial state. Guarded here; every
                        ;;consumer of `fn` below is gated behind `iz-single` or `(> fn 0)`, so
                        ;;no non-empty answer changes.
                        (fn:integer (if iz-empty 0 (at 0 selected-nonces)))
                    )
                    {"morph"        : (fold (and) true [iz-equity iz-single son])
                    ,"add-quantity" :
                        (if (or (not iz-single) (not son))
                            false
                            (fold (and) true
                                [(> fn 0)
                                 (= (ref-DPDC::UR_NonceClass dpdc-id true fn) 0)
                                 (ref-DPDC::UR_CA|R-AddQuantity dpdc-id account)])
                        )
                    ,"burn"         :
                        (if (not iz-single)
                            false
                            (if son
                                burn-role
                                (and burn-role (URC_IzNonceTaken dpdc-id fn true))
                            )
                        )
                    ,"respawn"      :
                        (if (or (not iz-single) son)
                            false
                            (and (ref-DPDC::UR_CA|R-Create dpdc-id son account)
                                 (URC_IzNonceTaken dpdc-id fn false))
                        )
                    ,"wipe"         : (fold (and) true [iz-empty can-wipe iz-owner])
                    ,"fuse"         :
                        (if (not iz-single)
                            false
                            (and (< fn 0)
                                 (>= (ref-DPDC::UR_AccountNonceSupply account dpdc-id son fn)
                                     1000))
                        )
                    ,"split"        :
                        (if (or (not iz-single) (< fn 0))
                            false
                            (ref-DPDC-F::UEV_IzNonceFragmented dpdc-id son fn)
                        )
                    ,"break-set"    :
                        (if (not iz-single)
                            false
                            (> (ref-DPDC::UR_NonceClass dpdc-id son fn) 0)
                        )
                    ,"transfer"     : (fold (or) false [iz-single iz-multiple])
                    }
                )
            )
        )
    )
    (defun URC_10|Wallet:object (account:string)
        @doc "THE ONE READ FOR THE PAGE. Held and managed collections of both fungibility \
            \ classes, their counts, and the populated rows for every held collection -- what \
            \ today costs three round trips. \
            \ \
            \ It does NOT carry the four `total-*` counts, which are the only header fields \
            \ needing the cross-module `keys` scans; fetch those from URH_01|Header."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (held-sf:[string] (ref-DPDC::URH_HeldCollectables account true))
                (mngd-sf:[string] (ref-DPDC::URH_OwnedCollectables account true))
                (held-nf:[string] (ref-DPDC::URH_HeldCollectables account false))
                (mngd-nf:[string] (ref-DPDC::URH_OwnedCollectables account false))
            )
            {"held-sf"          : held-sf
            ,"held-sf-number"   : (length held-sf)
            ,"mngd-sf"          : mngd-sf
            ,"mngd-sf-no"       : (length mngd-sf)
            ,"sf-entries"       : (URC_03|SemiFungibleList account held-sf)
            ;;
            ,"held-nf"          : held-nf
            ,"held-nf-number"   : (length held-nf)
            ,"mngd-nf"          : mngd-nf
            ,"mngd-nf-no"       : (length mngd-nf)
            ,"nf-entries"       : (URC_04|NonFungibleList account held-nf)
            ,"list-ok"          : true}
        )
    )
)
