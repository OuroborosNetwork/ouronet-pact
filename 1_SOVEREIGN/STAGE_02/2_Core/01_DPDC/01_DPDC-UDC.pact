(module DPDC-UDC GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements DpdcUdcV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-UDC               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|DPDC-UDC_ADMIN)))
    (defcap GOV|DPDC-UDC_ADMIN ()           (enforce-guard GOV|MD_DPDC-UDC))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-UDC|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-UDC|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-UDC_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-UDC_ADMIN)
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
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|DPDC-UDC|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                   (CT_Bar))
    ;;{3.2}  schemas
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
    ;;
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;
    ;;Properties UDCs
    ;;
    ;;  [1]
    ;;
    (defun UDC_DPDC|Properties:object{DpdcUdcV1.DPDC|Properties}
        (
            a:string b:string c:string d:string e:string
            f:bool g:bool h:bool i:bool
            j:bool k:bool l:bool m:bool
            n:bool o:integer p:integer
        )
        {"id"                           : a
        ,"owner-konto"                  : b
        ,"creator-konto"                : c
        ,"name"                         : d
        ,"ticker"                       : e
        ,"can-upgrade"                  : f
        ,"can-change-owner"             : g
        ,"can-change-creator"           : h
        ,"can-add-special-role"         : i
        ,"can-transfer-nft-create-role" : j
        ,"can-freeze"                   : k
        ,"can-wipe"                     : l
        ,"can-pause"                    : m
        ,"is-paused"                    : n
        ,"nonces-used"                  : o
        ,"set-classes-used"             : p}
    )
    ;;
    ;;  [2]
    ;;
    (defun UDC_NonceElement:object{DpdcUdcV1.DPDC|NonceElement} 
        (   
            a:integer b:integer c:integer d:string
            e:object{DpdcUdcV1.DPDC|NonceData}
            f:object{DpdcUdcV1.DPDC|NonceData}
        )
        {"nonce-class"      : a
        ,"nonce-value"      : b
        ,"nonce-supply"     : c
        ,"nonce-holder"     : d
        ,"nonce-data"       : e
        ,"split-data"       : f}
    )
    (defun UDC_NonceData:object{DpdcUdcV1.DPDC|NonceData} 
        (
            a:decimal b:decimal c:string d:string 
            e:object{DpdcUdcV1.NonceMetaData}
            f:object{DpdcUdcV1.URI|Type}
            g:object{DpdcUdcV1.URI|Data}
            h:object{DpdcUdcV1.URI|Data}
            i:object{DpdcUdcV1.URI|Data}
        )
        {"royalty"          : a
        ,"ignis"            : b
        ,"name"             : c
        ,"description"      : d
        ,"meta-data"        : e
        ,"asset-type"       : f
        ,"uri-primary"      : g
        ,"uri-secondary"    : h
        ,"uri-tertiary"     : i}
    )
    (defun UDC_NonceMetaData:object{DpdcUdcV1.NonceMetaData}
        (a:decimal b:[integer] c:object)
        {"score"            : a
        ,"composition"      : b
        ,"meta-data"        : c}
    )
    (defun UDC_URI|Type:object{DpdcUdcV1.URI|Type}
        (a:bool b:bool c:bool d:bool e:bool f:bool g:bool)
        {"image"            : a
        ,"audio"            : b
        ,"video"            : c
        ,"document"         : d
        ,"archive"          : e
        ,"model"            : f
        ,"exotic"           : g}
    )
    (defun UDC_URI|Data:object{DpdcUdcV1.URI|Data}
        (a:string b:string c:string d:string e:string f:string g:string)
        {"image"            : a
        ,"audio"            : b
        ,"video"            : c
        ,"document"         : d
        ,"archive"          : e
        ,"model"            : f
        ,"exotic"           : g}
    )
    ;;
    ;;  [3]
    ;;
    (defun UDC_DPDC|VerumRoles:object{DpdcUdcV1.DPDC|VerumRoles}
        (a:[string] b:[string] c:[string] d:[string] e:string f:string g:[string] h:[string] i:[string] j:string k:[string])
        {"a-frozen"                 : a
        ,"r-exemption"              : b
        ,"r-nft-add-quantity"       : c
        ,"r-nft-burn"               : d
        ,"r-nft-create"             : e
        ,"r-nft-recreate"           : f
        ,"r-nft-update"             : g
        ,"r-modify-creator"         : h
        ,"r-modify-royalties"       : i
        ,"r-set-new-uri"            : j
        ,"r-transfer"               : k}
    )
    ;;
    ;;  [4]
    ;;
    (defun UDC_DPSF|AccountRoles:object{DpdcUdcV1.DPSF|AccountRoles}
        (a:object{DpdcUdcV1.AccountRoles} b:bool c:string d:string)
        {"roles"                : a
        ,"role-nft-add-quantity": b
        ,"id"                   : c
        ,"account"              : d}
    )
    (defun UDC_DPNF|AccountRoles:object{DpdcUdcV1.DPNF|AccountRoles}
        (a:object{DpdcUdcV1.AccountRoles} b:string c:string)
        {"roles"                : a
        ,"id"                   : b
        ,"account"              : c}
    )
    (defun UDC_AccountRoles:object{DpdcUdcV1.AccountRoles}
        (a:bool b:bool c:bool d:bool e:bool f:bool g:bool h:bool i:bool j:bool)
        {"frozen"               : a
        ,"role-exemption"       : b
        ,"role-nft-burn"        : c
        ,"role-nft-create"      : d
        ,"role-nft-recreate"    : e
        ,"role-nft-update"      : f
        ,"role-modify-creator"  : g
        ,"role-modify-royalties": h
        ,"role-set-new-uri"     : i
        ,"role-transfer"        : j}
    )
    ;;
    ;;  [5]
    ;;
    (defun UDC_DPDC|AccountSupply:object{DpdcUdcV1.DPDC|AccountSupply} 
        (a:string b:string c:integer d:integer)
        {"account"  : a
        ,"id"       : b
        ,"nonce"    : c
        ,"supply"   : d}
    )
    ;;
    ;;  [6]
    ;;
    (defun UDC_DPDC|AllowedClassForSetPosition:object{DpdcUdcV1.DPDC|AllowedClassForSetPosition} 
        (a:integer)
        @doc "<C> = AllowedClassForSetPosition"
        {"allowed-sclass"   : a}
    )
    (defun UDC_DPDC|AllowedNonceForSetPosition:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition} 
        (a:[integer])
        @doc "<N> = AllowedNonceForSetPosition"
        {"allowed-nonces"   : a}
    )
    (defun UDC_DPDC|Set:object{DpdcUdcV1.DPDC|Set}
        (
            a:integer b:string c:decimal d:integer e:bool f:bool g:bool
            h:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            i:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            j:object{DpdcUdcV1.DPDC|NonceData}
            k:object{DpdcUdcV1.DPDC|NonceData}
        )
        @doc "<S> = Set"
        {"set-class"                    : a
        ,"set-name"                     : b
        ,"set-score-multiplier"         : c
        ,"nonce-of-set"                 : d
        ,"iz-active"                    : e
        ,"primordial"                   : f
        ,"composite"                    : g
        ,"primordial-set-definition"    : h
        ,"composite-set-definition"     : i
        ,"nonce-data"                   : j
        ,"split-data"                   : k}
    )
    ;;
    ;;  [CUSTOM]
    ;;
    ;;  [2]
    ;;
    (defun UDC_ZeroNonceElement:object{DpdcUdcV1.DPDC|NonceElement} ()
        (UDC_NonceElement
            0 0 0 BAR
            (UDC_ZeroNonceData)
            (UDC_ZeroNonceData)
        )
    )
    (defun UDC_ZeroNonceData:object{DpdcUdcV1.DPDC|NonceData} ()
        (UDC_NonceData
            0.0 0.0 BAR BAR (UDC_NoMetaData)
            (UDC_ZeroURI|Type) (UDC_ZeroURI|Data)
            (UDC_ZeroURI|Data) (UDC_ZeroURI|Data)
        )
    )
    (defun UDC_NoMetaData:object{DpdcUdcV1.NonceMetaData} ()
        (UDC_MetaData {})
    )
    (defun UDC_MetaData:object{DpdcUdcV1.NonceMetaData}
        (meta-data:object)
        (UDC_NonceMetaData -1.0 [0] meta-data)
    )
    ;; UDC_ScoreMetaData removed — DPDC Audit #45L: see interface-side removal note above.
    (defun UDC_ZeroURI|Type:object{DpdcUdcV1.URI|Type} ()
        (UDC_URI|Type false false false false false false false)
    )
    (defun UDC_ZeroURI|Data:object{DpdcUdcV1.URI|Data} ()
        (UDC_URI|Data BAR BAR BAR BAR BAR BAR BAR)
    )
    ;;
    ;;  [6]
    ;;
    (defun UDC_NoPrimordialSet:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] ()
        [(UDC_DPDC|AllowedNonceForSetPosition [0])]
    )
    (defun UDC_NoCompositeSet:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] ()
        [(UDC_DPDC|AllowedClassForSetPosition -1)]
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(create-table P|T)
(create-table P|MT)