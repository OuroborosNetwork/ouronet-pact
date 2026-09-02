;; CODEX — Codex Identity registry + Arweave upload tracker + StoicTags (Stage 01 core #22).
;; Spec: OuronetInformational/01-mnemosyne-codex-pact-module.md
;; Nomenclature: OuronetInformational/MODULE_ARCHITECTURE.md
;; Client entrypoints: Talos TS01-C4 (StoicTag: 1 native STOA per glyph; fee wiring in TS01-C4).
;; Mnemosyne operator: ouronet-ns.codex-keyset (define before A_RegisterCodexIdentity).
;;
(interface CodexV1
    (defun GOV|CodexKey ())
    ;;
    ;;
    (defun UC_ValidateArweaveTxId:bool (tx-id:string))
    (defun UC_StoicTagStoaFee:decimal (tag-name:string))
    (defun UC_ValidateStoicTagName:bool (tag-name:string))
    (defun UC_CodexIdStandard:string (codex-id:string))
    (defun UC_CodexIdSmart:string (codex-id:string))
    (defun UC_ValidateCompositeCodexId:bool (codex-id:string))
    (defun UC_ArweaveTrackerKey:string (codex-id:string arweave-tx-id:string))
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_RegisterStoicTag:decimal (tag-name:string))
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string))
    ;;
    (defun A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    ;;
    ;; [UR] CODEX|S|Identity — field accessors + DataOrNull (UR_CIX|Data is module-only; schema not in interface)
    (defun UR_CIX|CodexIdStandard:string (codex-id:string))
    (defun UR_CIX|CodexIdSmart:string (codex-id:string))
    (defun UR_CIX|PublicStandard:string (codex-id:string))
    (defun UR_CIX|PublicSmart:string (codex-id:string))
    (defun UR_CIX|CodexGuard:guard (codex-id:string))
    (defun UR_CIX|RegisteredAt:time (codex-id:string))
    (defun UR_CIX|RegisteredBy:string (codex-id:string))
    (defun UR_CIX|CodexId:string (codex-id:string))
    (defun UR_CIX|DataOrNull:object (codex-id:string))
    ;;
    ;; [UR] CODEX|S|ArweaveTracker — field accessors (UR_AWT|Data is module-only)
    (defun UR_AWT|UploadTime:time (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|UploadedBytes:integer (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|CodexId:string (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|ArweaveTxId:string (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|ListByCodex:[object] (codex-id:string))
    ;;
    ;; [UR] CODEX|S|StoicTag — field accessors + DataOrNull (UR_STG|Data is module-only)
    (defun UR_STG|AccountAddress:string (tag-name:string))
    (defun UR_STG|RegisteredAt:time (tag-name:string))
    (defun UR_STG|IzActive:bool (tag-name:string))
    (defun UR_STG|TagName:string (tag-name:string))
    (defun UR_STG|DataOrNull:object (tag-name:string))
    ;;
    ;; [UR] CODEX|S|StoicTagByAccount — field accessors + DataOrNull (UR_STBA|Data is module-only)
    (defun UR_STBA|TagName:string (account-address:string))
    (defun UR_STBA|AccountAddress:string (account-address:string))
    (defun UR_STBA|IzActive:bool (account-address:string))
    (defun UR_STBA|DataOrNull:object (account-address:string))
    ;;
    ;; [URC]
    (defun URC_AWT|LatestUpload:object (codex-id:string))
    ;;
    ;;#24H fix: these four were already live/actively-called via TS01-C4's module{CodexV1}-typed
    ;;ref, but missing from the interface itself. Added here, purely additive - the module already
    ;;implements all four with matching signatures.
    ;; [C]
    (defun C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_RegisterStoicTag:string (tag-name:string account-address:string))
    (defun C_ReleaseStoicTag:string (tag-name:string))
    ;;
    ;; [INFO] UI previews — register: STOA always (C_STOA|CollectWT false); release: IGNIS per virtual-gas rules
    (defun INFO_CODEX|RegisterStoicTag:object{OuronetInfoV1.ClientInfo}
        (patron:string tag-name:string account-address:string))
    (defun INFO_CODEX|ReleaseStoicTag:object{OuronetInfoV1.ClientInfo}
        (patron:string tag-name:string))
)

(module CODEX GOV
    @doc "On-chain Codex Identity registry, Arweave upload audit log, and StoicTag \
         \ name registry. Apollo cosign is off-chain only; chain enforces Stoa guards."
    ;;
    (implements CodexV1)
    (implements OuronetPolicyV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_CODEX                  (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|CODEX_ADMIN)))
    (defcap GOV|CODEX_ADMIN ()              (enforce-guard GOV|MD_CODEX))
    (defcap CODEX|ADMIN ()                  (enforce-guard (keyset-ref-guard (GOV|CodexKey))))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|NS_Use ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    (defun GOV|CodexKey ()                  (+ (GOV|NS_Use) ".codex-keyset"))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|CODEX|CALLER ()
        true
    )
    ;;{P4}
    (defconst P|I                           (P|Info))
    (defun P|Info ()                        (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|CODEX_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|CODEX_ADMIN)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (mg:guard (create-capability-guard (P|CODEX|CALLER)))
            )
            (ref-P|DALOS::A_P|AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let ((ref-U|G:module{OuronetGuardsV1} U|G))
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    (defschema CODEX|S|Identity
        @doc "One Mnemosyne-registered codex identity. Immutable except codex-guard."
        codex-id-standard:string            ;;[.]   Apollo Standard half (₱. + 160 charset chars, len 162)
        codex-id-smart:string               ;;[.]   Apollo Smart half (Π. + 160 charset chars, len 162)
        public-standard:string              ;;[.]   Canonical Standard Apollo pubkey material
        public-smart:string                 ;;[.]   Canonical Smart Apollo pubkey material
        codex-guard:guard                   ;;[M]   Stoa CodexGuard keyset (rotatable)
        registered-at:time                  ;;[.]   Block time at registration
        registered-by:string                ;;[.]   Operator observability string
        ;;
        ;;Select Keys
        codex-id:string                     ;;[.]   Composite Apollo id: standard + ':' + smart (len 325)
    )
    (defschema CODEX|S|ArweaveTracker
        @doc "Append-only Arweave backup row for one codex."
        upload-time:time                    ;;[.]   Block time at insert
        uploaded-bytes:integer              ;;[.]   Encrypted blob size on Arweave
        ;;
        ;;Select Keys
        codex-id:string                     ;;[.]   Parent identity (FK to CODEX|T|Identities)
        arweave-tx-id:string                ;;[.]   Arweave transaction id (43-char base64url)
    )
    (defschema CODEX|S|StoicTag
        @doc "Human-readable name → Ouronet account (codex-agnostic). Release sets iz-active false."
        account-address:string              ;;[M]   Ouronet DALOS account (Ѻ.* or Σ.*), not a Stoa k: account
        registered-at:time                  ;;[M]   Block time at last activation
        iz-active:bool                      ;;[M]   true = name in use; false = released (re-register updates row)
        ;;
        ;;Select Keys
        tag-name:string                     ;;[.]   Bare name without § prefix (table key)
    )
    (defschema CODEX|S|StoicTagByAccount
        @doc "Reverse index: one active StoicTag per account when iz-active is true."
        tag-name:string                     ;;[M]   StoicTag registered to account
        iz-active:bool                      ;;[M]   Mirrors CODEX|T|StoicTags.iz-active for this account slot
        ;;
        ;;Select Keys
        account-address:string              ;;[.]   Ouronet DALOS account (table key; Ѻ.* or Σ.*)
    )
    ;;{2}
    (deftable CODEX|T|Identities:{CODEX|S|Identity})                    ;;Key = <codex-id>
    (deftable CODEX|T|ArweaveTracker:{CODEX|S|ArweaveTracker})          ;;Key = <codex-id> | <arweave-tx-id>
    (deftable CODEX|T|StoicTags:{CODEX|S|StoicTag})                     ;;Key = <tag-name>
    (deftable CODEX|T|StoicTagsByAccount:{CODEX|S|StoicTagByAccount})   ;;Key = <account-address>
    ;;{3}
    (defun CT_Bar ()                          (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                             (CT_Bar))
    (defconst CODEX|EPOCH:time                (time "1970-01-01T00:00:00Z"))
    (defconst CODEX|APOLLO-HALF-LEN:integer   162)
    (defconst CODEX|COMPOSITE-SEP:string      ":")
    (defconst CODEX|APOLLO-COMPOSITE-LEN:integer
        (fold (+) 0 [CODEX|APOLLO-HALF-LEN 1 CODEX|APOLLO-HALF-LEN])
    )
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    (defcap CODEX|OWNER (codex-id:string)
        (let 
            (
                (codex-guard:guard (UR_CIX|CodexGuard codex-id))
            )
            (enforce-guard codex-guard)
        )
    )
    (defcap CODEX|STOICTAG-DALOS-OWNER (account-address:string)
        @doc "Caller controls the Ouronet (DALOS) account — Standard or Smart, not Stoa coin.details."
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS))
            (ref-DALOS::CAP_EnforceAccountOwnership account-address)
        )
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap CODEX|A>REGISTER-IDENTITY
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Mnemosyne operator registers a new codex identity. Derives Apollo halves from composite codex-id."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
                (codex-len:integer (length codex-id))
                (codex-id-standard:string (UC_CodexIdStandard codex-id))
                (codex-id-smart:string (UC_CodexIdSmart codex-id))
                (iz-composite-len:bool (= codex-len CODEX|APOLLO-COMPOSITE-LEN))
                (iz-separator:bool
                    (= CODEX|COMPOSITE-SEP (take 1 (drop CODEX|APOLLO-HALF-LEN codex-id)))
                )
                (iz-standard-valid:bool
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck codex-id-standard false)
                )
                (iz-smart-valid:bool
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck codex-id-smart true)
                )
                (iz-reconcat:bool
                    (= codex-id (format "{}{}{}" [codex-id-standard CODEX|COMPOSITE-SEP codex-id-smart]))
                )
                (iz-nonempty-pub-std:bool (!= public-standard ""))
                (iz-nonempty-pub-smt:bool (!= public-smart ""))
            )
            (compose-capability (CODEX|ADMIN))
            (enforce
                (fold (and) true
                    [
                        iz-composite-len
                        iz-separator
                        iz-standard-valid
                        iz-smart-valid
                        iz-reconcat
                        iz-nonempty-pub-std
                        iz-nonempty-pub-smt
                    ]
                )
                "Invalid codex identity: composite Apollo codex-id or pubkey material"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>ROTATE-GUARD (codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard: current owner + new guard must sign. Composes SECURE for XI."
        @event
        (compose-capability (CODEX|OWNER codex-id))
        (enforce-guard new-codex-guard)
        (compose-capability (SECURE))
    )
    (defcap CODEX|C>RECORD-ARWEAVE (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append Arweave tracker row for registered codex. Composes OWNER + SECURE for XI."
        @event
        (let
            (
                (iz-valid-tx-id:bool (UC_ValidateArweaveTxId arweave-tx-id))
                (iz-positive-bytes:bool (> uploaded-bytes 0))
            )
            (compose-capability (CODEX|OWNER codex-id))
            (enforce
                (and iz-valid-tx-id iz-positive-bytes)
                "Invalid arweave upload: bad tx-id format or non-positive uploaded-bytes"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>REGISTER-STOICTAG (tag-name:string account-address:string)
        @doc "Register or re-activate StoicTag. Fails if name or account slot is already active. Composes SECURE for XI."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (tag-row-found:bool (not (= (try false (UR_STG|Data tag-name)) false)))
                (tag-iz-active:bool
                    (if tag-row-found
                        (UR_STG|IzActive tag-name)
                        false
                    )
                )
                (acct-row-found:bool (not (= (try false (UR_STBA|Data account-address)) false)))
                (acct-iz-active:bool
                    (if acct-row-found
                        (UR_STBA|IzActive account-address)
                        false
                    )
                )
            )
            (ref-U|DALOS::UEV_StoicTagName tag-name)
            (ref-DALOS::UEV_EnforceAccountExists account-address)
            (enforce (not tag-iz-active) "StoicTag name is already active")
            (enforce (not acct-iz-active) "Account already has an active StoicTag")
            (compose-capability (CODEX|STOICTAG-DALOS-OWNER account-address))
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>RELEASE-STOICTAG (tag-name:string)
        @doc "Release (deactivate) StoicTag: must exist and be active. Composes SECURE for XI."
        @event
        (let
            (
                (tag-row-found:bool (not (= (try false (UR_STG|Data tag-name)) false)))
                (tag-iz-active:bool
                    (if tag-row-found
                        (UR_STG|IzActive tag-name)
                        false
                    )
                )
                (account-address:string
                    (if tag-row-found
                        (UR_STG|AccountAddress tag-name)
                        ""
                    )
                )
            )
            (enforce tag-row-found "StoicTag not found")
            (enforce tag-iz-active "StoicTag is not active")
            (compose-capability (CODEX|STOICTAG-DALOS-OWNER account-address))
            (compose-capability (SECURE))
        )
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    (defun UDC_CIX|Identity:object{CODEX|S|Identity}
        ( codex-id-standard:string
          codex-id-smart:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-at:time
          registered-by:string
          codex-id:string )
        @doc "Constructor for object{CODEX|S|Identity}."
        { "codex-id-standard": codex-id-standard
        , "codex-id-smart":    codex-id-smart
        , "public-standard":   public-standard
        , "public-smart":      public-smart
        , "codex-guard":       codex-guard
        , "registered-at":     registered-at
        , "registered-by":     registered-by
        , "codex-id":          codex-id
        }
    )
    (defun UDC_CIX|GuardUpdate:object (new-codex-guard:guard)
        @doc "Partial update object for codex-guard rotation."
        { "codex-guard": new-codex-guard }
    )
    (defun UDC_CIX|Unregistered:object ()
        @doc "Sentinel for UR_CIX|DataOrNull when codex-id is absent."
        { "codex-id":           ""
        , "codex-id-standard":  ""
        , "codex-id-smart":     ""
        , "public-standard":    ""
        , "public-smart":       ""
        , "registered-at":      CODEX|EPOCH
        , "registered-by":      ""
        , "is-registered":      false
        }
    )
    (defun UDC_CIX|WithRegisteredFlag:object (row:object{CODEX|S|Identity})
        (+ row { "is-registered": true })
    )
    (defun UDC_AWT|Tracker:object{CODEX|S|ArweaveTracker}
        ( codex-id:string
          arweave-tx-id:string
          upload-time:time
          uploaded-bytes:integer )
        { "codex-id":       codex-id
        , "arweave-tx-id":  arweave-tx-id
        , "upload-time":    upload-time
        , "uploaded-bytes": uploaded-bytes
        }
    )
    (defun UDC_AWT|EmptyLatest:object (codex-id:string)
        (UDC_AWT|Tracker codex-id "" CODEX|EPOCH 0)
    )
    (defun UDC_STG|StoicTag:object{CODEX|S|StoicTag}
        ( account-address:string registered-at:time iz-active:bool tag-name:string )
        { "account-address": account-address
        , "registered-at":   registered-at
        , "iz-active":         iz-active
        , "tag-name":        tag-name
        }
    )
    (defun UDC_STG|IzActiveUpdate:object (iz-active:bool)
        { "iz-active": iz-active }
    )
    (defun UDC_STG|Unregistered:object ()
        { "tag-name":        ""
        , "account-address": ""
        , "registered-at":   CODEX|EPOCH
        , "iz-active":         false
        , "is-registered":   false
        }
    )
    (defun UDC_STG|WithRegisteredFlag:object (row:object{CODEX|S|StoicTag})
        (+ row { "is-registered": true })
    )
    (defun UDC_STBA|StoicTagByAccount:object{CODEX|S|StoicTagByAccount}
        ( tag-name:string iz-active:bool account-address:string )
        { "tag-name":        tag-name
        , "iz-active":         iz-active
        , "account-address": account-address
        }
    )
    (defun UDC_STBA|IzActiveUpdate:object (iz-active:bool)
        { "iz-active": iz-active }
    )
    (defun UDC_STBA|Unregistered:object ()
        { "account-address": ""
        , "tag-name":        ""
        , "iz-active":         false
        , "has-stoictag":    false
        }
    )
    (defun UDC_STBA|WithHasStoicTagFlag:object (row:object{CODEX|S|StoicTagByAccount})
        (+ row { "has-stoictag": true })
    )
    ;;{F2}  Compute [UC]
    (defun UC_IsBase64urlChar:bool (c:string)
        (or (and (>= c "A") (<= c "Z"))
            (or (and (>= c "a") (<= c "z"))
                (or (and (>= c "0") (<= c "9"))
                    (contains c ["_" "-"])
                )
            )
        )
    )
    (defun UC_ValidateArweaveTxId:bool (tx-id:string)
        @doc "True when tx-id is 43-char Arweave base64url (length + charset)."
        (and (= (length tx-id) 43)
            (fold
                (lambda (ok:bool c:string) (and ok (UC_IsBase64urlChar c)))
                true
                (str-to-list tx-id)
            )
        )
    )
    (defun UC_StoicTagStoaFee:decimal (tag-name:string)
        @doc "Native STOA due for registering <tag-name>: exactly 1 STOA per glyph (= string length). E.g. bytales → 7.0 STOA."
        (dec (length tag-name))
    )
    (defun UC_ValidateStoicTagName:bool (tag-name:string)
        @doc "True when tag-name is 3–256 glyphs from DALOS|CHARSET (U|DALOS)."
        (let 
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
            )
            (ref-U|DALOS::UC_IzStoicTagName tag-name)
        )
    )
    (defun UC_CodexIdStandard:string (codex-id:string)
        @doc "Standard Apollo half of composite codex-id (first 162 chars)."
        (take CODEX|APOLLO-HALF-LEN codex-id)
    )
    (defun UC_CodexIdSmart:string (codex-id:string)
        @doc "Smart Apollo half of composite codex-id (chars after separator ':')."
        (drop (+ CODEX|APOLLO-HALF-LEN 1) codex-id)
    )
    (defun UC_ValidateCompositeCodexId:bool (codex-id:string)
        @doc "True when codex-id is 325 chars: valid ₱. standard + ':' + valid Π. smart Apollo strings."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS)
                (standard:string (UC_CodexIdStandard codex-id))
                (smart:string (UC_CodexIdSmart codex-id))
            )
            (fold (and) true
                [
                    (= (length codex-id) CODEX|APOLLO-COMPOSITE-LEN)
                    (= CODEX|COMPOSITE-SEP (take 1 (drop CODEX|APOLLO-HALF-LEN codex-id)))
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck standard false)
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck smart true)
                    (= codex-id (format "{}{}{}" [standard CODEX|COMPOSITE-SEP smart]))
                ]
            )
        )
    )
    (defun UC_ArweaveTrackerKey:string (codex-id:string arweave-tx-id:string)
        @doc "Composite table key for CODEX|T|ArweaveTracker."
        (format "{}|{}" [codex-id arweave-tx-id])
    )
    ;;{F3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_RegisterStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for C_CODEX|RegisterStoicTag — RAW native STOA toll \
            \ (1/glyph). Elite discount is applied at collect against the tagged account, \
            \ so this returns the pre-discount amount. Consumed by TS01-C4 exec + INFO."
        (UC_StoicTagStoaFee tag-name)
    )
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for C_CODEX|ReleaseStoicTag — flat IGNIS toll (1/glyph), \
            \ collected via IGNIS::C_Collect in TS01-C4. Consumed by exec + INFO."
        (UC_StoicTagStoaFee tag-name)
    )
    ;;
    ;; [1] CODEX|T|Identities  (CODEX|S|Identity)  Key = <codex-id>
    (defun UR_CIX|Data:object{CODEX|S|Identity} (codex-id:string)
        @doc "Full codex identity row."
        (read CODEX|T|Identities codex-id)
    )
    (defun UR_CIX|CodexIdStandard:string (codex-id:string)
        (at "codex-id-standard" (read CODEX|T|Identities codex-id ["codex-id-standard"]))
    )
    (defun UR_CIX|CodexIdSmart:string (codex-id:string)
        (at "codex-id-smart" (read CODEX|T|Identities codex-id ["codex-id-smart"]))
    )
    (defun UR_CIX|PublicStandard:string (codex-id:string)
        (at "public-standard" (read CODEX|T|Identities codex-id ["public-standard"]))
    )
    (defun UR_CIX|PublicSmart:string (codex-id:string)
        (at "public-smart" (read CODEX|T|Identities codex-id ["public-smart"]))
    )
    (defun UR_CIX|CodexGuard:guard (codex-id:string)
        (at "codex-guard" (read CODEX|T|Identities codex-id ["codex-guard"]))
    )
    (defun UR_CIX|RegisteredAt:time (codex-id:string)
        (at "registered-at" (read CODEX|T|Identities codex-id ["registered-at"]))
    )
    (defun UR_CIX|RegisteredBy:string (codex-id:string)
        (at "registered-by" (read CODEX|T|Identities codex-id ["registered-by"]))
    )
    (defun UR_CIX|CodexId:string (codex-id:string)
        (at "codex-id" (UR_CIX|Data codex-id))
    )
    (defun UR_CIX|DataOrNull:object (codex-id:string)
        @doc "Like UR_CIX|Data but returns is-registered:false when absent."
        (if (= (try false (UR_CIX|Data codex-id)) false)
            (UDC_CIX|Unregistered)
            (UDC_CIX|WithRegisteredFlag (UR_CIX|Data codex-id))
        )
    )
    ;;
    ;; [2] CODEX|T|ArweaveTracker  (CODEX|S|ArweaveTracker)  Key = <codex-id> | <arweave-tx-id>
    (defun UR_AWT|Data:object{CODEX|S|ArweaveTracker} (codex-id:string arweave-tx-id:string)
        @doc "One Arweave tracker row."
        (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id))
    )
    (defun UR_AWT|UploadTime:time (codex-id:string arweave-tx-id:string)
        (at "upload-time"
            (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id) ["upload-time"])
        )
    )
    (defun UR_AWT|UploadedBytes:integer (codex-id:string arweave-tx-id:string)
        (at "uploaded-bytes"
            (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id) ["uploaded-bytes"])
        )
    )
    (defun UR_AWT|CodexId:string (codex-id:string arweave-tx-id:string)
        (at "codex-id" (UR_AWT|Data codex-id arweave-tx-id))
    )
    (defun UR_AWT|ArweaveTxId:string (codex-id:string arweave-tx-id:string)
        (at "arweave-tx-id" (UR_AWT|Data codex-id arweave-tx-id))
    )
    (defun UR_AWT|ListByCodex:[object] (codex-id:string)
        @doc "All tracker rows for codex-id (select scan)."
        (select CODEX|T|ArweaveTracker
            ["codex-id" "arweave-tx-id" "upload-time" "uploaded-bytes"]
            (where "codex-id" (= codex-id))
        )
    )
    ;;
    ;; [3] CODEX|T|StoicTags  (CODEX|S|StoicTag)  Key = <tag-name>
    (defun UR_STG|Data:object{CODEX|S|StoicTag} (tag-name:string)
        (read CODEX|T|StoicTags tag-name)
    )
    (defun UR_STG|AccountAddress:string (tag-name:string)
        (at "account-address" (read CODEX|T|StoicTags tag-name ["account-address"]))
    )
    (defun UR_STG|RegisteredAt:time (tag-name:string)
        (at "registered-at" (read CODEX|T|StoicTags tag-name ["registered-at"]))
    )
    (defun UR_STG|IzActive:bool (tag-name:string)
        (at "iz-active" (read CODEX|T|StoicTags tag-name ["iz-active"]))
    )
    (defun UR_STG|TagName:string (tag-name:string)
        (at "tag-name" (UR_STG|Data tag-name))
    )
    (defun UR_STG|DataOrNull:object (tag-name:string)
        (if (= (try false (UR_STG|Data tag-name)) false)
            (UDC_STG|Unregistered)
            (if (UR_STG|IzActive tag-name)
                (UDC_STG|WithRegisteredFlag (UR_STG|Data tag-name))
                (UDC_STG|Unregistered)
            )
        )
    )
    ;;
    ;; [4] CODEX|T|StoicTagsByAccount  (CODEX|S|StoicTagByAccount)  Key = <account-address>
    (defun UR_STBA|Data:object{CODEX|S|StoicTagByAccount} (account-address:string)
        (read CODEX|T|StoicTagsByAccount account-address)
    )
    (defun UR_STBA|TagName:string (account-address:string)
        (at "tag-name" (read CODEX|T|StoicTagsByAccount account-address ["tag-name"]))
    )
    (defun UR_STBA|AccountAddress:string (account-address:string)
        (at "account-address" (UR_STBA|Data account-address))
    )
    (defun UR_STBA|IzActive:bool (account-address:string)
        (at "iz-active" (read CODEX|T|StoicTagsByAccount account-address ["iz-active"]))
    )
    (defun UR_STBA|DataOrNull:object (account-address:string)
        (if (= (try false (UR_STBA|Data account-address)) false)
            (UDC_STBA|Unregistered)
            (if (UR_STBA|IzActive account-address)
                (UDC_STBA|WithHasStoicTagFlag (UR_STBA|Data account-address))
                (UDC_STBA|Unregistered)
            )
        )
    )
    ;;
    (defun URC_AWT|LatestUpload:object (codex-id:string)
        @doc "Newest arweave-tracker row for codex-id, or empty object if none."
        (let 
            (
                (rows:[object] (UR_AWT|ListByCodex codex-id))
            )
            (if (= (length rows) 0)
                (UDC_AWT|EmptyLatest codex-id)
                (fold
                    (lambda (best:object row:object)
                        (if (> (at "upload-time" row) (at "upload-time" best))
                            row
                            best
                        )
                    )
                    (at 0 rows)
                    (drop 1 rows)
                )
            )
        )
    )
    ;;
    (defun INFO_CODEX|RegisterStoicTag:object{OuronetInfoV1.ClientInfo}
        (patron:string tag-name:string account-address:string)
        @doc "ClientInfo preview for TS01-C4 C_CODEX|RegisterStoicTag — STOA from patron; Elite discount on account-address."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (stoa-fee:decimal (UC_StoicTagStoaFee tag-name))
                (glyph-count:integer (length tag-name))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account-address))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Register StoicTag §{} to Ouronet account {}." [tag-name sa])
                    (format "Native STOA fee: {} (1 per glyph, {} glyphs; Elite discount on tagged account)." [stoa-fee glyph-count])
                ]
                [(format "StoicTag §{} registered to account {}." [tag-name account-address])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts account-address stoa-fee)
                []
            )
        )
    )
    (defun INFO_CODEX|ReleaseStoicTag:object{OuronetInfoV1.ClientInfo}
        (patron:string tag-name:string)
        @doc "ClientInfo preview for TS01-C4 C_CODEX|ReleaseStoicTag (IGNIS = UC_StoicTagStoaFee per glyph)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (tag-fee:decimal (UC_StoicTagStoaFee tag-name))
                (glyph-count:integer (length tag-name))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Release StoicTag §{}." [tag-name])
                    (format "IGNIS fee: {} (1 per glyph, {} glyphs)." [tag-fee glyph-count])
                ]
                [(format "StoicTag §{} released." [tag-name])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron tag-fee)
                )
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{F4}  Validate [UEV/CAP]
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    (defun XI_InsertIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Under SECURE (from CODEX|A>REGISTER-IDENTITY): insert identity row. Write only."
        (require-capability (SECURE))
        (insert CODEX|T|Identities codex-id
            (UDC_CIX|Identity
                (UC_CodexIdStandard codex-id)
                (UC_CodexIdSmart codex-id)
                public-standard public-smart
                codex-guard (at "block-time" (chain-data)) registered-by codex-id
            )
        )
    )
    (defun XI_UpdateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Under SECURE (from CODEX|C>ROTATE-GUARD): update codex-guard only. Write only."
        (require-capability (SECURE))
        (update CODEX|T|Identities codex-id (UDC_CIX|GuardUpdate new-codex-guard))
    )
    (defun XI_InsertArweaveTracker:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Under SECURE (from CODEX|C>RECORD-ARWEAVE): append tracker row. Write only."
        (require-capability (SECURE))
        (insert CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id)
            (UDC_AWT|Tracker
                codex-id arweave-tx-id (at "block-time" (chain-data)) uploaded-bytes
            )
        )
    )
    (defun XI_UpsertStoicTag:string (tag-name:string account-address:string)
        @doc "Under SECURE (from CODEX|C>REGISTER-STOICTAG): insert new or re-activate released rows. Write only."
        (require-capability (SECURE))
        (let 
            (
                (now:time (at "block-time" (chain-data)))
            )
            (if (= (try false (UR_STG|Data tag-name)) false)
                (insert CODEX|T|StoicTags tag-name
                    (UDC_STG|StoicTag account-address now true tag-name))
                (update CODEX|T|StoicTags tag-name
                    (UDC_STG|StoicTag account-address now true tag-name))
            )
            (if (= (try false (UR_STBA|Data account-address)) false)
                (insert CODEX|T|StoicTagsByAccount account-address
                    (UDC_STBA|StoicTagByAccount tag-name true account-address))
                (update CODEX|T|StoicTagsByAccount account-address
                    (UDC_STBA|StoicTagByAccount tag-name true account-address))
            )
        )
    )
    (defun XI_DeactivateStoicTag:string (tag-name:string)
        @doc "Under SECURE (from CODEX|C>RELEASE-STOICTAG): set iz-active false on both tables. Write only."
        (require-capability (SECURE))
        (let ((account-address:string (UR_STG|AccountAddress tag-name)))
            (update CODEX|T|StoicTags tag-name (UDC_STG|IzActiveUpdate false))
            (update CODEX|T|StoicTagsByAccount account-address (UDC_STBA|IzActiveUpdate false))
        )
    )
    ;;{F7}  User [A]
    (defun A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "ADMIN-only insert into CODEX|T|Identities; standard/smart halves derived from codex-id."
        (UEV_IMC)
        (with-capability (CODEX|A>REGISTER-IDENTITY codex-id public-standard public-smart codex-guard registered-by)
            (XI_InsertIdentity
                codex-id public-standard public-smart codex-guard registered-by
            )
        )
        (format "Codex Identity {} registered" [codex-id])
    )
    ;;{F8}  User [C]
    (defun C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard; validation in CODEX|C>ROTATE-GUARD; XI writes only."
        (UEV_IMC)
        (with-capability (CODEX|C>ROTATE-GUARD codex-id new-codex-guard)
            (XI_UpdateCodexGuard codex-id new-codex-guard)
        )
        (format "Codex {} guard rotated" [codex-id])
    )
    ;;
    (defun C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append one row to CODEX|T|ArweaveTracker; validation in CODEX|C>RECORD-ARWEAVE."
        (UEV_IMC)
        (with-capability (CODEX|C>RECORD-ARWEAVE codex-id arweave-tx-id uploaded-bytes)
            (XI_InsertArweaveTracker codex-id arweave-tx-id uploaded-bytes)
        )
        (format "Upload recorded: {} -> {}" [codex-id arweave-tx-id])
    )
    ;;
    (defun C_RegisterStoicTag:string (tag-name:string account-address:string)
        @doc "Register StoicTag; validation in CODEX|C>REGISTER-STOICTAG; XI writes only (1 STOA/glyph fee in TS01-C4)."
        (UEV_IMC)
        (with-capability (CODEX|C>REGISTER-STOICTAG tag-name account-address)
            (XI_UpsertStoicTag tag-name account-address)
        )
        (format "StoicTag §{} registered to account {}" [tag-name account-address])
    )
    ;;
    (defun C_ReleaseStoicTag:string (tag-name:string)
        @doc "Release StoicTag (iz-active false); validation in CODEX|C>RELEASE-STOICTAG; XI updates only."
        (UEV_IMC)
        (with-capability (CODEX|C>RELEASE-STOICTAG tag-name)
            (XI_DeactivateStoicTag tag-name)
        )
        (format "StoicTag §{} released" [tag-name])
    )
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table CODEX|T|Identities)
(create-table CODEX|T|ArweaveTracker)
(create-table CODEX|T|StoicTags)
(create-table CODEX|T|StoicTagsByAccount)
