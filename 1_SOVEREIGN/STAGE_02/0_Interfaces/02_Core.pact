;; Stage 02 Core Interface Registry — SHARED schemas only.
;; DpdcUdcV1 types are referenced by all DPDC slice interfaces — keep here.
;; Module-owned latest interfaces live in 2_Core/**/*.pact (deploy with module).
;;
(interface DpdcUdcV1
    @doc "Exposes Collectables UDC Constructors"

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
    ;;
    ;;  [1]
    ;;
    (defschema DPDC|Properties
        id:string
        owner-konto:string
        creator-konto:string
        name:string
        ticker:string
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-change-creator:bool
        can-add-special-role:bool
        can-transfer-nft-create-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        ;;
        is-paused:bool
        nonces-used:integer
        set-classes-used:integer
    )
    ;;
    ;;  [2]
    ;;
    (defschema DPDC|NonceElement
        nonce-class:integer                 ;;Class 0 for Primordial Nonces, non-zero for Composite Nonces
                                            ;;For Composite Nonces, <nonce-class> is the <set-class>
        nonce-value:integer                 ;;Nonce Value of the Collection Element.
        nonce-supply:integer                ;;Collection Element Supply; Always 1 for NFT, even when burned or wiped.
        nonce-holder:string                 ;;Stores the <OuronetAccount> holding the Nonce
                                            ;;Only Applies to NFT Nonces, SFT Nonces cant have an unique Holder, and would store BAR instead (unmodifieable for SFTs)
                                            ;;For an NFT, storing <BAR> here, means the nonce is inactivated.
                                            ;;Once an NFT Nonce is inactivated, in can only be activated again bz the Colletion owner if its <nonce-class> is 0
                                            ;;This Creates the NFT on the Creator Account
        ;;
        nonce-data:object{DPDC|NonceData}   ;;Data of the Nonce Element
        split-data:object{DPDC|NonceData}   ;;Data of the Nonce Fragment Elements
    )
    (defschema DPDC|NonceData
        royalty:decimal   ;;Forward-looking hook for the upcoming Escrow/NFT marketplace (not yet built) —
                          ;;no on-chain consumer reads this today, unlike its sibling <ignis> below, which
                          ;;is actively consumed by DPDC-T's transfer pricing. DPDC Audit #26M.
        ignis:decimal
        name:string
        description:string
        meta-data:object{NonceMetaData}
        asset-type:object{URI|Type}
        uri-primary:object{URI|Data}
        uri-secondary:object{URI|Data}
        uri-tertiary:object{URI|Data}
    )
    (defschema NonceMetaData
        score:decimal
        composition:[integer]
        meta-data:object
    )
    (defschema URI|Type
        image:bool
        audio:bool
        video:bool
        document:bool
        archive:bool
        model:bool
        exotic:bool
    )
    (defschema URI|Data
        image:string
        audio:string
        video:string
        document:string
        archive:string
        model:string
        exotic:string
    )
    ;;
    ;;  [3]
    ;;
    (defschema DPDC|VerumRoles
        a-frozen:[string]
        r-exemption:[string]
        r-nft-add-quantity:[string]
        r-nft-burn:[string]
        r-nft-create:string
        r-nft-recreate:string
        r-nft-update:[string]
        r-modify-creator:[string]
        r-modify-royalties:[string]
        r-set-new-uri:string
        r-transfer:[string]
    )
    ;;
    ;;  [4]
    ;;
    (defschema DPSF|AccountRoles
        @doc "Key = <DPSF-id> + BAR + <account>"
        roles:object{AccountRoles}
        role-nft-add-quantity:bool
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema DPNF|AccountRoles
        @doc "Key = <DPNF-id> + BAR + <account>"
        roles:object{AccountRoles}
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema AccountRoles
        frozen:bool                         ;; multiple
        role-exemption:bool                 ;; multiple
        role-nft-burn:bool                  ;; multiple
        role-nft-create:bool                ;; single       ;;new
        role-nft-recreate:bool              ;; single       ;;whole nonce-data
        role-nft-update:bool                ;; multiple     ;;name, description, score, meta-data
        role-modify-creator:bool            ;; multiple     ;;change-cretor-account
        role-modify-royalties:bool          ;; multiple     ;;royalty ignis-royalty
        role-set-new-uri:bool               ;; single       ;;uri
        role-transfer:bool                  ;; multiple
    )
    ;;
    ;;  [5]
    ;;
    (defschema DPDC|AccountSupply
        @doc "Key = <account> + BAR + <DPSF|DPNF-id> + BAR + <nonce>"
        account:string
        id:string
        nonce:integer
        supply:integer
    )
    ;;
    ;;  [6]
    ;;
    (defschema DPDC|Set
        set-class:integer
        set-name:string
        set-score-multiplier:decimal        ;;Stores Set NFT Score Multiplier, default to 1.0
        nonce-of-set:integer                ;;Saves the Nonce of the Set; 
                                            ;;Only for SFT, since they get their own nonce at definition
                                            ;;For NFT has no use and is filled with 0
        ;;                                  
        iz-active:bool                      ;;Inactive Sets cannot be composed, but can be decomposed
        primordial:bool                     ;;primordial sets are composed of specific class 0 nonces
        composite:bool                      ;;composite  sets are composed of non-specific class non-zero nonces
                                            ;;if both are true, the set is hybrid, and then both of the field below
                                            ;;would have to be filled with correct data.
        ;;
        primordial-set-definition:[object{DPDC|AllowedNonceForSetPosition}]
        ;;If <primordial> is true, a valid object will be stored here, otherwise [[0]] will be stored
        composite-set-definition:[object{DPDC|AllowedClassForSetPosition}]
        ;;If <composite> is true, a valid object will be stored here, otherwise [[-1]] will be stored
        ;;
        nonce-data:object{DPDC|NonceData}   ;;Data for the Set Nonce
        split-data:object{DPDC|NonceData}   ;;Data for the Fragment of the Set Nonce
    )
    (defschema DPDC|AllowedNonceForSetPosition
        allowed-nonces:[integer]
    )
    (defschema DPDC|AllowedClassForSetPosition
        allowed-sclass:integer
    )
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
    ;;  [UDC]
    ;;
    ;;  [1]
    ;;
    (defun UDC_DPDC|Properties:object{DPDC|Properties}
        (
            a:string b:string c:string d:string e:string
            f:bool g:bool h:bool i:bool
            j:bool k:bool l:bool m:bool
            n:bool o:integer p:integer
        )
    )
    ;;
    ;;  [2]
    ;;
    (defun UDC_NonceElement:object{DPDC|NonceElement} 
        (   
            a:integer b:integer c:integer d:string
            e:object{DPDC|NonceData}
            f:object{DPDC|NonceData}
        )
    )
    (defun UDC_NonceData:object{DPDC|NonceData} 
        (
            a:decimal b:decimal c:string d:string 
            e:object{NonceMetaData}
            f:object{URI|Type}
            g:object{URI|Data}
            h:object{URI|Data}
            i:object{URI|Data}
        )
    )
    (defun UDC_NonceMetaData:object{NonceMetaData} (a:decimal b:[integer] c:object))
    (defun UDC_URI|Type:object{URI|Type} (a:bool b:bool c:bool d:bool e:bool f:bool g:bool))
    (defun UDC_URI|Data:object{URI|Data} (a:string b:string c:string d:string e:string f:string g:string))
    ;;
    ;;  [3]
    ;;
    (defun UDC_DPDC|VerumRoles:object{DPDC|VerumRoles} 
        (a:[string] b:[string] c:[string] d:[string] e:string f:string g:[string] h:[string] i:[string] j:string k:[string])
    )
    ;;
    ;;  [4]
    ;;
    (defun UDC_DPSF|AccountRoles:object{DPSF|AccountRoles} (a:object{AccountRoles} b:bool c:string d:string))
    (defun UDC_DPNF|AccountRoles:object{DPNF|AccountRoles} (a:object{AccountRoles} b:string c:string))
    (defun UDC_AccountRoles:object{AccountRoles} (a:bool b:bool c:bool d:bool e:bool f:bool g:bool h:bool i:bool j:bool))
    ;;
    ;;  [5]
    ;;
    (defun UDC_DPDC|AccountSupply:object{DPDC|AccountSupply}  (a:string b:string c:integer d:integer))
    ;;
    ;;  [6]
    ;;
    (defun UDC_DPDC|AllowedClassForSetPosition:object{DPDC|AllowedClassForSetPosition}  (a:integer))
    (defun UDC_DPDC|AllowedNonceForSetPosition:object{DPDC|AllowedNonceForSetPosition}  (a:[integer]))
    (defun UDC_DPDC|Set:object{DPDC|Set}
        (
            a:integer b:string c:decimal d:integer e:bool f:bool g:bool
            h:[object{DPDC|AllowedNonceForSetPosition}]
            i:[object{DPDC|AllowedClassForSetPosition}]
            j:object{DPDC|NonceData}
            k:object{DPDC|NonceData}
        )
    )
    ;;
    ;;  [CUSTOM]
    ;;
    ;;  [2]
    (defun UDC_ZeroNonceElement:object{DPDC|NonceElement} ())
    (defun UDC_ZeroNonceData:object{DPDC|NonceData} ())
    (defun UDC_NoMetaData:object{NonceMetaData} ())
    (defun UDC_MetaData:object{NonceMetaData} (meta-data:object))
    ;; UDC_ScoreMetaData removed — DPDC Audit #45L: dead code, zero callers. The real score-mutation
    ;; path (DPDC-N::XI_U|NonceScore) correctly preserves an existing nonce's composition via a targeted
    ;; merge; this constructor hardcoded composition=[0], which would have silently reset a real set
    ;; instance's composition if ever wired in as originally suggested — removal, not rewiring, is safe.
    (defun UDC_ZeroURI|Type:object{URI|Type} ())
    (defun UDC_ZeroURI|Data:object{URI|Data} ())
    ;;  [6]
    (defun UDC_NoPrimordialSet:[object{DPDC|AllowedNonceForSetPosition}] ())
    (defun UDC_NoCompositeSet:[object{DPDC|AllowedClassForSetPosition}] ())
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
