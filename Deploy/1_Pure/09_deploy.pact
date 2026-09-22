;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 9 of 24
;; This is STEP 9 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-8 must have run first, including the init steps between deploys.
;; 4 source file(s), 252,440 gas measured in the REPL gas model, 266,871 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
;;
;; TOTAL: 5 interface(s), 4 module(s), 18 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact
;;      interface  CodexV2
;;      module     CODEX
;;      table      P|T
;;      table      P|MT
;;      table      CODEX|T|Identities
;;      table      CODEX|T|ArweaveTracker
;;      table      CODEX|T|StoicTags
;;      table      CODEX|T|StoicTagsByAccount
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
;;      interface  PythiaV5
;;      interface  PythiaLedgerV3
;;      module     PYTHIA
;;      table      P|T
;;      table      P|MT
;;      table      PYTHIA|T|ApiKeys
;;      table      PYTHIA|T|Config
;;      table      PYTHIA|T|DualLinks
;;      table      PYTHIA|T|Revocation
;;      table      PYTHIA|T|PythDaily
;;      table      PYTHIA|T|PythTotal
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;      interface  TalosStageOne_AdminV2
;;      module     TS01-A
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
;;      interface  TalosStageOne_ClientOneV2
;;      module     TS01-C1
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact ===================
;; CODEX — Codex Identity registry + Arweave upload tracker + StoicTags (Stage 01 core #22).
;; Spec: OuronetInformational/01-mnemosyne-codex-pact-module.md
;; Nomenclature: OuronetInformational/MODULE_ARCHITECTURE.md
;; Client entrypoints: Talos TS01-C4 (StoicTag: 1 native STOA per glyph; fee wiring in TS01-C4).
;; Mnemosyne operator: ouronet-ns.codex-keyset (define before A_RegisterCodexIdentity).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface CodexV2
    @doc "CodexV2 is the interface for the CODEX module — the on-chain Codex Identity \
        \ registry, Arweave upload audit log, and StoicTag name registry. It declares UC \
        \ validators (Apollo composite id, Arweave tx-id, StoicTag name/fee), UR field \
        \ accessors and DataOrNull readers over the CODEX tables, URCi cost single-sources \
        \ for StoicTag register/release, plus A_/C_ entrypoints to \
        \ register identities, rotate codex guards, record Arweave uploads, and \
        \ register/release StoicTags. Client entrypoints are wired through Talos TS01-C4."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|CodexKey ())

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
    ;;
    (defun UC_ValidateArweaveTxId:bool (tx-id:string))
    (defun UC_StoicTagStoaFee:decimal (tag-name:string))
    (defun UC_ValidateStoicTagName:bool (tag-name:string))
    (defun UC_CodexIdStandard:string (codex-id:string))
    (defun UC_CodexIdSmart:string (codex-id:string))
    (defun UC_ValidateCompositeCodexId:bool (codex-id:string))
    (defun UC_ArweaveTrackerKey:string (codex-id:string arweave-tx-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_RegisterStoicTag:decimal (tag-name:string))
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string))
    (defun URCi_RotateCodexGuard:object{IgnisCollectorV3.OutputCumulator} (patron:string))
    (defun URCi_RecordArweaveUpload:object{IgnisCollectorV3.OutputCumulator} (patron:string))
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
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_ExecutorIsTagAccount (executor:string tag-name:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;; NOTE: INFO_CODEX|* previews are UI-only → NOT declared here (canon: INFO not in
    ;; interfaces); they live in the CODEX module's {5.3} Read block.
    ;;
    (defun A_RegisterCodexIdentity:string
        ( patron:string
          executor:string
          codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    ;;
    ;;#24H fix: these four were already live/actively-called via TS01-C4's module{CodexV2}-typed
    ;;ref, but missing from the interface itself. Added here, purely additive - the module already
    ;;implements all four with matching signatures.
    ;; [C]
    (defun C_RotateCodexGuard:string (patron:string executor:string codex-id:string new-codex-guard:guard))
    (defun C_RecordArweaveUpload:string (patron:string executor:string codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_RegisterStoicTag:string (patron:string executor:string tag-name:string))
    (defun C_ReleaseStoicTag:string (patron:string executor:string tag-name:string))

)

(module CODEX GOV
    @doc "On-chain Codex Identity registry, Arweave upload audit log, and StoicTag \
         \ name registry. Apollo cosign is off-chain only; chain enforces Stoa guards."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements CodexV2)
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CODEX                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CODEX_ADMIN)))
    (defcap GOV|CODEX_ADMIN ()                          (enforce-guard GOV|MD_CODEX))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CodexKey ()                              (+ (CT_Namespace) ".codex-keyset"))

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
    (defcap P|CODEX|CALLER ()
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
        (with-capability (GOV|CODEX_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|CODEX_ADMIN)
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
        (with-capability (GOV|CODEX_ADMIN)
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
        (with-capability (GOV|CODEX_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (mg:guard (create-capability-guard (P|CODEX|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst CODEX|EPOCH:time                          (time "1970-01-01T00:00:00Z"))
    (defconst CODEX|APOLLO-HALF-LEN:integer             162)
    (defconst CODEX|COMPOSITE-SEP:string                ":")
    (defconst CODEX|APOLLO-COMPOSITE-LEN:integer
        (fold (+) 0 [CODEX|APOLLO-HALF-LEN 1 CODEX|APOLLO-HALF-LEN])
    )
    ;;{3.2}  schemas
    ;;
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
    ;;{3.3}  tables
    (deftable CODEX|T|Identities:{CODEX|S|Identity})                    ;;Key = <codex-id>
    (deftable CODEX|T|ArweaveTracker:{CODEX|S|ArweaveTracker})          ;;Key = <codex-id> | <arweave-tx-id>
    (deftable CODEX|T|StoicTags:{CODEX|S|StoicTag})                     ;;Key = <tag-name>
    (deftable CODEX|T|StoicTagsByAccount:{CODEX|S|StoicTagByAccount})   ;;Key = <account-address>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap CODEX|ADMIN ()                              (enforce-guard (keyset-ref-guard (GOV|CodexKey))))
    (defcap CODEX|OWNER (codex-id:string)
        (let 
            (
                (codex-guard:guard (UR_CIX|CodexGuard codex-id))
            )
            (enforce-guard codex-guard)
        )
    )
    ;;{C3}  Composed
    (defcap CODEX|A>REGISTER-IDENTITY
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Mnemosyne operator registers a new codex identity. Derives Apollo halves from composite codex-id."
        @event
        ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
        ;;It used to be computed inside the `let` below as `iz-composite-len` and folded in with the
        ;;other six conditions -- but a `let` is EAGER and `fold (and)` does not short-circuit, so for
        ;;an id too short to split, `iz-standard-valid` ran anyway, indexed into an empty derived half
        ;;and raised `Array index out of bounds. Length (0), Index (0)`. Being false in the FIRST
        ;;conjunct saved nothing, and a truncated or hand-typed id -- the likeliest bad input on this
        ;;path -- got no message at all.
        ;;A length test needs nothing but the parameter, so it can run before anything is derived.
        ;;The fold below is unchanged and still answers for every other way to be invalid.
        ;;Pinned by REPL/modules/CODEX.repl <<CODEX-G3>>.
        (compose-capability (CODEX|ADMIN))
        (enforce
            (= (length codex-id) CODEX|APOLLO-COMPOSITE-LEN)
            "Invalid codex identity: composite Apollo codex-id must be 325 characters"
        )
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defcap CODEX|C>RELEASE-STOICTAG (executor:string tag-name:string)
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
            ;;THE BINDER RUNS HERE, NOT IN THE DEFUN, AND THE ORDER IS THE POINT (2026-09-22).
            ;;UEV_ExecutorIsTagAccount reads the tag row through a RAW `read`, which RAISES on a
            ;;missing key. Called before <tag-row-found> it would kill the transaction with a
            ;;table error on any unknown tag -- replacing the "StoicTag not found" refusal the
            ;;suite asserts, and leaving a green test that no longer tests what it says. Behind
            ;;the two enforces above the row is known to exist, so the binder is safe.
            ;;Same class as the VST-07 eager-read trap, reached from the opposite direction:
            ;;there a derived executor was computed too early in a TEST, here in the MODULE.
            (UEV_ExecutorIsTagAccount executor tag-name)
            (compose-capability (CODEX|STOICTAG-DALOS-OWNER account-address))
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]
    (defcap CODEX|STOICTAG-DALOS-OWNER (account-address:string)
        @doc "Caller controls the Ouronet (DALOS) account — Standard or Smart, not Stoa coin.details."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account-address)
        )
    )

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
    ;;{5.2}  Compute [UC]
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
        @doc "Native STOA due for registering <tag-name>: exactly 1 STOA per glyph (= string \
            \ length). E.g. bytales -> 7.0 STOA. DELIBERATE EXCEPTION to the dollar rule (owner \
            \ 2026-09-07): this toll is FIXED IN STOA UNITS, not denominated in dollars and \
            \ converted, so a glyph always costs one STOA whatever the oracle says. It is also \
            \ non-discountable. Do NOT change it to derive from IG|DETER."
        (dec (length tag-name))
    )
    (defun UC_ValidateStoicTagName:bool (tag-name:string)
        @doc "True when tag-name is 3–256 glyphs from DALOS|CHARSET (U|DALOS)."
        (let 
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
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
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_RegisterStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for CODEX|C_RegisterStoicTag — RAW native STOA toll \
            \ (1/glyph). Elite discount is applied at collect against the tagged account, \
            \ so this returns the pre-discount amount. Consumed by TS01-C4 exec + INFO."
        (UC_StoicTagStoaFee tag-name)
    )
    (defun URCi_RotateCodexGuard:object{IgnisCollectorV3.OutputCumulator} (patron:string)
        @doc "Cost single-source for CODEX|C_RotateCodexGuard — deter(usage) + components, on the \
            \ patron (the codex row carries no konto of its own). USAGE tier (deterrence 1x, owner \
            \ 2026-09-07): CODEX ops pay what they structurally cost and carry no deterrent premium. \
            \ Consumed by the TS01-C4 exec path + INFO, so the two cannot drift."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "CODEX|C_RotateCodexGuard" "usage")
                patron (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RecordArweaveUpload:object{IgnisCollectorV3.OutputCumulator} (patron:string)
        @doc "Cost single-source for CODEX|C_RecordArweaveUpload — deter(usage) + components, on \
            \ the patron. USAGE tier: recording an upload is routine activity, not a config \
            \ change. Consumed by the TS01-C4 exec path + INFO."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "CODEX|C_RecordArweaveUpload" "usage")
                patron (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for CODEX|C_ReleaseStoicTag — flat IGNIS toll (1/glyph), \
            \ collected via IGNIS::XE_CollectIgnis in TS01-C4. Consumed by exec + INFO."
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
    (defun INFO_CODEX|RegisterStoicTag:object{OuronetInfoV2.ClientInfo}
        (patron:string tag-name:string account-address:string)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_RegisterStoicTag — STOA from patron; Elite discount on account-address."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;single-source: the SAME reader the TS01-C4 exec path collects from
                (stoa-fee:decimal (URCi_RegisterStoicTag tag-name))
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
    (defun INFO_CODEX|RotateCodexGuard:object{OuronetInfoV2.ClientInfo}
        (patron:string codex-id:string)
        
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Rotate the Codex Guard of Codex {}." [codex-id])]
                [(format "Codex Guard of Codex {} rotated." [codex-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_RotateCodexGuard patron)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_CODEX|RecordArweaveUpload:object{OuronetInfoV2.ClientInfo}
        (patron:string codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_RecordArweaveUpload — deter(usage) + \
            \ components via URCi_RecordArweaveUpload, so preview and execution cannot drift. \
            \ Records the Arweave transaction id and the uploaded byte count."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Record Arweave upload {} ({} bytes) for Codex {}."
                    [arweave-tx-id uploaded-bytes codex-id])]
                [(format "Arweave upload {} recorded for Codex {}." [arweave-tx-id codex-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_RecordArweaveUpload patron)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_CODEX|ReleaseStoicTag:object{OuronetInfoV2.ClientInfo}
        (patron:string tag-name:string)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_ReleaseStoicTag (IGNIS = UC_StoicTagStoaFee per glyph)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;single-source: the SAME reader the TS01-C4 exec path collects from
                (tag-fee:decimal (URCi_ReleaseStoicTag tag-name))
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
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_ExecutorIsTagAccount (executor:string tag-name:string)
        @doc "BINDS <executor> to the account that holds StoicTag <tag-name>. \
            \ \
            \ Ownership is proven INDIRECTLY: CODEX|C>RELEASE-STOICTAG composes \
            \ CODEX|STOICTAG-DALOS-OWNER on (UR_STG|AccountAddress tag-name), which is \
            \ CAP_EnforceAccountOwnership. This supplies the other half -- that the account the \
            \ caller NAMED is that same holder. Without it the executor would be a name the \
            \ function never reads, which is worse than absent because it reads as verified. \
            \ \
            \ Reads the row through UR_STG|AccountAddress rather than re-deriving it, so the \
            \ binder and the capability cannot disagree about which account the tag belongs to. \
            \ (patron/executor canon 2.2, indirect route named.)"
        (enforce (= executor (UR_STG|AccountAddress tag-name))
            "Executor is not the StoicTag account")
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Under SECURE (from CODEX|C>ROTATE-GUARD): update codex-guard only. Write only."
        (require-capability (SECURE))
        (update CODEX|T|Identities codex-id (UDC_CIX|GuardUpdate new-codex-guard))
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_InsertArweaveTracker:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Under SECURE (from CODEX|C>RECORD-ARWEAVE): append tracker row. Write only."
        (require-capability (SECURE))
        (insert CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id)
            (UDC_AWT|Tracker
                codex-id arweave-tx-id (at "block-time" (chain-data)) uploaded-bytes
            )
        )
    )
    ;;Protection: Class 2 — SECURE
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
    ;;Protection: Class 2 — SECURE
    (defun XI_DeactivateStoicTag:string (tag-name:string)
        @doc "Under SECURE (from CODEX|C>RELEASE-STOICTAG): set iz-active false on both tables. Write only."
        (require-capability (SECURE))
        (let
            (
                (account-address:string (UR_STG|AccountAddress tag-name))
            )
            (update CODEX|T|StoicTags tag-name (UDC_STG|IzActiveUpdate false))
            (update CODEX|T|StoicTagsByAccount account-address (UDC_STBA|IzActiveUpdate false))
        )
    )
    ;;{5.7}  User [A/C]
    (defun A_RegisterCodexIdentity:string
        ( patron:string
          executor:string
          codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "ADMIN-only insert into CODEX|T|Identities; standard/smart halves derived from codex-id. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the Mnemosyne \
            \ keyset, composed as CODEX|ADMIN; <executor> is the ACTOR among its holders and is \
            \ proven by CAP_EnforceAccountOwnership. Authority and attribution are orthogonal. \
            \ \
            \ <registered-by> IS NOT THE EXECUTOR, despite reading like one. It is a free-form \
            \ operator LABEL -- the schema calls it an \"Operator observability string\" and the \
            \ suite passes a human name -- and NOTHING enforces it: it appears in this \
            \ capability's parameter list and nowhere in its body. It is nonetheless PERSISTED \
            \ and readable via UR_CIX|RegisteredBy, which makes it the worst version of a \
            \ decorative actor: a self-declared provenance field that looks verified and is \
            \ not. It is deliberately left alone rather than promoted -- enforcing it would \
            \ change its TYPE (an Ouronet account, not a label) and require every Mnemosyne \
            \ operator to hold one. Treat the ROW's provenance as unverified; the executor \
            \ above is the verified half."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (CODEX|A>REGISTER-IDENTITY codex-id public-standard public-smart codex-guard registered-by)
            (XI_InsertIdentity
                codex-id public-standard public-smart codex-guard registered-by
            )
        )
        (format "Codex Identity {} registered" [codex-id])
    )
    (defun C_RotateCodexGuard:string (patron:string executor:string codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard; validation in CODEX|C>ROTATE-GUARD; XI writes only. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY here is a raw \
            \ GUARD -- CODEX|OWNER enforce-guards (UR_CIX|CodexGuard codex-id) -- so there is no \
            \ account in the authority path at all, and no account for a binder to bind to. \
            \ <executor> is therefore proven DIRECTLY, by CAP_EnforceAccountOwnership: it records \
            \ which Ouronet account drove the rotation, which the guard alone cannot say. \
            \ Orthogonal by construction -- holding the codex guard and owning the executor \
            \ account are two separate proofs, and BOTH are now required."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (CODEX|C>ROTATE-GUARD codex-id new-codex-guard)
            (XI_UpdateCodexGuard codex-id new-codex-guard)
        )
        (format "Codex {} guard rotated" [codex-id])
    )
    ;;
    (defun C_RecordArweaveUpload:string (patron:string executor:string codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append one row to CODEX|T|ArweaveTracker; validation in CODEX|C>RECORD-ARWEAVE. \
            \ \
            \ ATTRIBUTION: as C_RotateCodexGuard -- the authority is the codex GUARD, which names \
            \ no account, so <executor> is proven directly by CAP_EnforceAccountOwnership. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (CODEX|C>RECORD-ARWEAVE codex-id arweave-tx-id uploaded-bytes)
            (XI_InsertArweaveTracker codex-id arweave-tx-id uploaded-bytes)
        )
        (format "Upload recorded: {} -> {}" [codex-id arweave-tx-id])
    )
    ;;
    (defun C_RegisterStoicTag:string (patron:string executor:string tag-name:string)
        @doc "Register StoicTag; validation in CODEX|C>REGISTER-STOICTAG; XI writes only (1 STOA/glyph fee in TS01-C4). \
            \ \
            \ A RENAME, not an addition (patron/executor canon 2.2, 2026-09-22): the old \
            \ <account-address> was ALREADY the executor. CODEX|C>REGISTER-STOICTAG composes \
            \ CODEX|STOICTAG-DALOS-OWNER on it, which is CAP_EnforceAccountOwnership -- a \
            \ PARAMETER, directly proven, which is the rarest shape in this sweep. \
            \ \
            \ It is the EXECUTOR and not an executee even though the tag is bestowed upon it, \
            \ because an executee is merely credited and needs no signature, whereas this \
            \ account must own itself to the chain. Actor and subject coincide here."
        (P|UEV_IMC)
        (with-capability (CODEX|C>REGISTER-STOICTAG tag-name executor)
            (XI_UpsertStoicTag tag-name executor)
        )
        (format "StoicTag §{} registered to account {}" [tag-name executor])
    )
    ;;
    (defun C_ReleaseStoicTag:string (patron:string executor:string tag-name:string)
        @doc "Release StoicTag (iz-active false); validation in CODEX|C>RELEASE-STOICTAG; XI updates only. \
            \ \
            \ HANDOFF 4g, and the contrast with its own sibling is the clearest illustration of \
            \ the shape in this codebase. C_RegisterStoicTag takes the account as a PARAMETER \
            \ and CAP_EnforceAccountOwnership proves that parameter. This function takes only \
            \ <tag-name>, and CODEX|C>RELEASE-STOICTAG DERIVES the account from the tag row -- \
            \ (UR_STG|AccountAddress tag-name) -- then proves ownership of THAT. Same authority, \
            \ same enforce, and the actor vanishes from the signature. Two functions on the same \
            \ table, one attributed and one not, differing only in whether the account was \
            \ passed or looked up. \
            \ \
            \ UEV_ExecutorIsTagAccount supplies the missing half; the derived enforce is KEPT."
        (P|UEV_IMC)
        (with-capability (CODEX|C>RELEASE-STOICTAG executor tag-name)
            (XI_DeactivateStoicTag tag-name)
        )
        (format "StoicTag §{} released" [tag-name])
    )

)

;; --- tables for 21_CODEX.pact (6 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table CODEX|T|Identities)
;; (create-table CODEX|T|ArweaveTracker)
;; (create-table CODEX|T|StoicTags)
;; (create-table CODEX|T|StoicTagsByAccount)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact ==================
;; PYTHIA — Apollo Pythia dual-Apollo API-key registry (Stage 01 core #23).
;; Spec: OuronetInformational/HANDOFFS/HANDOFF-pact-apollo-pythia-key-module.md
;; Deploy: load THIS file — PythiaV5 + PythiaLedgerV3 interfaces + PYTHIA module ship together.
;; Shared/historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact (PythiaV1–V3, PythiaLedger V1/V2BlockTime).
;; Talos client: 1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact (TalosStageOne_ClientFourV8 embedded).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;; Cronoton: ouronet-ns.pythia-cronoton-keyset (A_Link / A_RevokeLink / A_Flush).
;;
;; TABLES (deftable) — vs PYTHIA V1/V2 single-key model:
;;   PYTHIA|T|ApiKeys     — carryover table name; V3 schema (counterpart; no per-half consumer-lane)
;;   PYTHIA|T|Config      — carryover (deploy/rename prices)
;;   PYTHIA|T|DualLinks   — NEW V3 (pair row: lane + iz-active)
;;   PYTHIA|T|Revocation  — NEW V3 (revoked-at-height fast-lane anchor)
;;   PYTHIA|T|PythDaily   — Pyth ledger calendar-day snapshots (key = day ordinal string; iz-sealed)
;;   PYTHIA|T|PythTotal   — Pyth ledger running totals (key = "stoachain")
;;   P|T / P|MT           — standard Ouronet policy tables
;;
;; Spec (ledger): OuronetInformational/HANDOFFS/HANDOFF-pact-pyth-ledger.md
;; (create-table ...) at module bottom runs on **first module install** (greenfield).
;; You do not submit separate create-table txs. All eight fire in the PYTHIA deploy tx.
;; If PYTHIA were already on-chain at V3, only PythDaily + PythTotal are additive create-tables.
;;
;; net: v4   ·   dev: v5   ;; bumped by the StoicSyntax refactor — deploy v5 then set net: v5
(interface PythiaV5
    @doc "PYTHIA V4 — V3 dual-Apollo + Config UR prices; select-based inventory is URH_."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|CronotonKey ())

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
    (defun UC_DeployPrice:decimal ())
    (defun UC_RenamePrice:decimal ())
    (defun UC_RevokeIgnisFee:decimal ())
    (defun UC_IsStandardApollo:bool (apollo-account:string))
    (defun UC_FeeDiscountAnchor:string ())
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string))
    (defun UC_DualLinkStandard:string (dual-link-key:string))
    (defun UC_DualLinkSmart:string (dual-link-key:string))
    (defun UC_ChainEpoch:integer (block-height:integer))
    (defun UC_CurrentChainEpoch:integer ())
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_DeployApiKey:decimal ())
    (defun URCi_UpdateDualConsumerLane:decimal ())
    (defun URCi_RevokeLink:decimal ())
    ;;
    ;; [UR] PYTHIA|S|ApiKey + DualLink + Config + Revocation
    (defun UR_Public:string (apollo-account:string))
    (defun UR_Counterpart:string (apollo-account:string))
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string))
    (defun UR_OwnerAccount:string (apollo-account:string))
    (defun UR_RegisteredAt:time (apollo-account:string))
    (defun UR_UpdatedAt:time (apollo-account:string))
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string))
    (defun UR_DualLinkIzActive:bool (dual-link-key:string))
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string))
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string))
    (defun UR_Config ())
    (defun UR_DeployPrice:decimal ())
    (defun UR_RenamePrice:decimal ())
    (defun UR_RevocationAtHeight:integer ())
    (defun UR_RevocationEpoch:integer ())
    (defun UR_ApiKeyBySlot:object (standard-apollo:string))
    ;;
    ;; [URD] — select / keys inventory
    (defun URH_ApiKeyCount:integer ())
    (defun URH_ApiKeyCountStr:string ())
    (defun URH_DualLinkCount:integer ())
    (defun URH_ListAllApiKeys:[object] ())
    (defun URH_ListAllDualLinks:[object] ())
    (defun URH_ListActiveDualLinks:[object] ())
    (defun URH_ListInactiveDualLinks:[object] ())
    (defun URH_ActiveDualLinkSet:[string] ())
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;; NOTE: INFO_PYTHIA|* previews are UI-only → NOT declared here (canon: INFO not in
    ;; interfaces); they live in the PYTHIA module's {5.3} Read block.
    ;;
    (defun A_LinkDualApiKey:string (patron:string executor:string standard-apollo:string smart-apollo:string))
        ;; Cronoton: create+activate (auto PYTHIA-<hash12> lane) or flip inactive→true
    (defun A_RevokeDualLink:string (patron:string executor:string dual-link-key:string))
    (defun A_UpdateDeployPrice:string (patron:string executor:string new-price:decimal))
    (defun A_UpdateRenamePrice:string (patron:string executor:string new-price:decimal))
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            patron:string
            executor:string
            apollo-account:string
            public:string
        ))
    (defun C_LinkDualApiKey:string
        (
            executor:string
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun C_RevokeDualLink:string (patron:string executor:string dual-link-key:string))
    (defun C_UpdateDualConsumerLane:string
        (
            patron:string
            executor:string
            dual-link-key:string
            new-name:string
        ))

)
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface PythiaLedgerV3
    @doc "Pyth ledger V2 — batch flush entries (explicit day, iz-complete); order-independent txs."

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
    ;;
    (defschema PYTHIA|S|PythMetrics
        @doc "Six Pyth work counters — nested on daily and total rows."
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythFlushAcc
        @doc "Internal fold state for batch XI_FlushPythLedger."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
    (defschema PYTHIA|S|PythFlushEntry
        @doc "One calendar day in a batch A_Flush (metrics cumulative for that UTC day)."
        day:integer
        iz-complete:bool
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythDaily
        @doc "One calendar-day snapshot. Table key = day ordinal string."
        day:integer
        flushed-at:time
        iz-sealed:bool
        metrics:object{PYTHIA|S|PythMetrics}
    )
    (defschema PYTHIA|S|PythTotal
        @doc "Running totals. Key = stoachain. last-day = highest day ordinal written."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
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
    (defun UR_PythMaxFlushBatch:integer ())
    (defun UR_PythLedgerEpochStart:time ())
    (defun UR_PythCurrentDay:integer ())
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URH_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Flush:string (patron:string executor:string entries:[object{PYTHIA|S|PythFlushEntry}]))

)
;;
(module PYTHIA GOV
    @doc "Dual-Apollo Pythia registry + on-chain Pyth work ledger (daily flush / running total)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements PythiaV5)
    (implements PythiaLedgerV3)
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_PYTHIA                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|PYTHIA_ADMIN)))
    (defcap GOV|PYTHIA_ADMIN ()                         (enforce-guard GOV|MD_PYTHIA))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CronotonKey ()                           (+ (CT_Namespace) ".pythia-cronoton-keyset"))

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
    (defcap P|PYTHIA|CALLER ()
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
        (with-capability (GOV|PYTHIA_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|PYTHIA_ADMIN)
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
        (with-capability (GOV|PYTHIA_ADMIN)
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
        (with-capability (GOV|PYTHIA_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (mg:guard (create-capability-guard (P|PYTHIA|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR:string                                (CT_Bar))
    (defconst PYTHIA|EPOCH:time                         (time "1970-01-01T00:00:00Z"))
    (defconst PYTHIA|LEDGER-EPOCH-START:time            (time "2026-08-01T00:00:00Z"))
    (defconst PYTHIA|SECONDS-PER-DAY:decimal            86400.0)
    (defconst PYTHIA|APOLLO-LEN:integer                 162)
    (defconst PYTHIA|DUAL-LINK-LEN:integer              325)
    (defconst PYTHIA|INFO:string                        "config")
    (defconst PYTHIA|REVOCATION:string                  "revocation")
    (defconst PYTHIA|STOACHAIN:string                   "stoachain")
    (defconst PYTHIA|REVOKE-IGNIS-FEE:decimal           1.0)
    (defconst PYTHIA|EPOCH-BLOCKS:integer               120)
    (defconst PYTHIA|APOLLO-STANDARD:string             "₱")
    (defconst PYTHIA|APOLLO-SMART:string                "Π")
    (defconst PYTHIA|MAX-DAILY-RANGE:integer            365)
    (defconst PYTHIA|MAX-FLUSH-BATCH:integer            1000)
    ;;{3.2}  schemas
    ;;
    (defschema PYTHIA|S|ApiKey
        @doc "One Apollo half (₱. slot or Π. consumer). Table key = apollo-account."
        public:string                                   ;;[.]   Canonical Apollo public-key material
        counterpart:string                              ;;[.]   Other half; BAR until linked (immutable once set)
        owner-account:string                            ;;[.]   Ouronet DALOS account that deployed + paid
        registered-at:time                              ;;[.]   Block time at deploy
        updated-at:time                                 ;;[M]   Block time at last mutation
        ;;
        ;;Select Keys
        apollo-account:string                           ;;[.]   Apollo account string (= table key)
    )
    (defschema PYTHIA|S|DualLink
        @doc "Dual-Apollo pair. Table key = standard + BAR + smart composite (325 chars)."
        standard-apollo:string                          ;;[.]   Standard ₱. slot half
        smart-apollo:string                             ;;[.]   Smart Π. consumer half
        consumer-lane:string                            ;;[M]   Stoic lane (C_Link) or auto PYTHIA-<hash12> (A_Link create); rename via C_UpdateDualConsumerLane
        iz-active:bool                                  ;;[M]   Live auth only when true (Cronoton or pre-linked false row)
        linked-at:time                                  ;;[.]   Block time at first link insert
        updated-at:time                                 ;;[M]   Block time at last iz-active mutation
        ;;
        ;;Select Keys
        dual-link-key:string                            ;;[.]   Composite key (= table key)
    )
    (defschema PYTHIA|S|Config
        deploy-price:decimal
        rename-price:decimal
    )
    (defschema PYTHIA|S|Revocation
        @doc "Last dual-link revoke anchor: block height at revoke (epoch = floor(height / 120))."
        revoked-at-height:integer
    )
    ;;{3.3}  tables
    (deftable PYTHIA|T|ApiKeys:{PYTHIA|S|ApiKey})                       ;;Key = <apollo-account>
    (deftable PYTHIA|T|DualLinks:{PYTHIA|S|DualLink})                   ;;Key = <dual-link-key>
    (deftable PYTHIA|T|Config:{PYTHIA|S|Config})                        ;;Key = PYTHIA|INFO
    (deftable PYTHIA|T|Revocation:{PYTHIA|S|Revocation})                ;;Key = PYTHIA|REVOCATION
    (deftable PYTHIA|T|PythDaily:{PythiaLedgerV3.PYTHIA|S|PythDaily})   ;;Key = <day ordinal string>
    (deftable PYTHIA|T|PythTotal:{PythiaLedgerV3.PYTHIA|S|PythTotal})   ;;Key = PYTHIA|STOACHAIN

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;#68L fix: removed PYTHIA|FLUSH-GAS-TARGET - dead constant, confirmed zero references
    ;;anywhere; likely a leftover from an earlier gas-based batching design later replaced by
    ;;the count-based PYTHIA|MAX-FLUSH-BATCH cap. No functional change.
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap PYTHIA|CRONOTON ()                          (enforce-guard (keyset-ref-guard (GOV|CronotonKey))))
    ;;{C3}  Composed
    (defcap PYTHIA|C>DEPLOY-API-KEY
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Composes SECURE for WI_ApiKey."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (is-smart:bool (not (UC_IsStandardApollo apollo-account)))
            )
            (enforce (!= public "") "Public key material must be non-empty")
            (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account is-smart)
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>LINK-DUAL
        (
            executor:string
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both Apollo half-owners link deployed halves into inactive dual row with lane label."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
            )
            (ref-U|DALOS::UEV_StoicTagName consumer-lane)
            (UEV_DualPairForLink standard-apollo smart-apollo)
            (UEV_ExecutorIsHalfOwner executor standard-apollo smart-apollo)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard-apollo)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart-apollo)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>LINK-DUAL (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate: insert active dual row (auto lane) or flip inactive→true."
        @event
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (if row-missing
                (UEV_DualPairForLink standard-apollo smart-apollo)
                (enforce
                    (fold (and) true
                        [
                            (not (UR_DualLinkIzActive dlk))
                            (= (UR_Counterpart standard-apollo) smart-apollo)
                            (= (UR_Counterpart smart-apollo) standard-apollo)
                        ]
                    )
                    "Dual link not ready for Cronoton activate (must exist inactive with counterparts)"
                )
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>REVOKE-DUAL (executor:string dual-link-key:string)
        @doc "Both Apollo half-owners revoke active dual link (iz-active false)."
        @event
        (let
            (
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (iz-active:bool (at "iz-active" row))
            )
            (enforce iz-active "Dual link is already inactive")
            (UEV_ExecutorIsHalfOwner executor standard smart)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>REVOKE-DUAL (dual-link-key:string)
        @doc "Cronoton revokes active dual link (Pythia authority)."
        @event
        (let
            (
                (iz-active:bool (UR_DualLinkIzActive dual-link-key))
            )
            (enforce iz-active "Dual link is already inactive")
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>UPDATE-DUAL-LANE (executor:string dual-link-key:string new-name:string)
        @doc "Both half-owners rename consumer-lane on the dual link row."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
            )
            (ref-U|DALOS::UEV_StoicTagName new-name)
            (UEV_ExecutorIsHalfOwner executor standard smart)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>FLUSH
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch Pyth ledger flush; each entry is one calendar day (order-independent across txs)."
        @event
        (let
            (
                (entry-count:integer (length entries))
            )
            (enforce
                (fold (and) true
                    [
                        (> entry-count 0)
                        (<= entry-count PYTHIA|MAX-FLUSH-BATCH)
                        (UEV_FlushEntries entries)
                    ]
                )
                (format "Pyth flush batch invalid or exceeds max {} entries per tx" [PYTHIA|MAX-FLUSH-BATCH])
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]
    (defun UEV_ExecutorIsHalfOwner (executor:string standard-apollo:string smart-apollo:string)
        @doc "BINDS <executor> to ONE of the two Apollo half-owners. \
            \ \
            \ Every dual-link operation requires BOTH halves' owners to sign -- the capability \
            \ composes PYTHIA|OWNER twice, on two DERIVED accounts read out of the ApiKeys \
            \ table. That proves the AUTHORITY completely and records no ACTOR at all: the two \
            \ signatures say the operation was permitted, not which side asked for it. \
            \ \
            \ So the binder is a DISJUNCTION, deliberately. Requiring the executor to be a \
            \ specific half would be a new business rule -- either owner may legitimately \
            \ initiate -- while requiring it to be BOTH is impossible. What it rules out is the \
            \ thing worth ruling out: naming a THIRD account, unrelated to the link, as the \
            \ actor on an operation two other people authorised. \
            \ (patron/executor canon 2.2; authority is unchanged, attribution is added.)"
        (enforce
            (or (= executor (UR_OwnerAccount standard-apollo))
                (= executor (UR_OwnerAccount smart-apollo)))
            "Executor owns neither Apollo half"
        )
    )
    (defcap PYTHIA|OWNER (owner-account:string)
        @doc "Caller controls the Ouronet (DALOS) account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
        )
    )

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
    ;;
    (defun UDC_AKY|ApiKey:object{PYTHIA|S|ApiKey}
        (
            public:string
            counterpart:string
            owner-account:string
            apollo-account:string
        )
        @doc "Constructor for object{PYTHIA|S|ApiKey}; WI_ApiKey stamps registered-at/updated-at."
        { "public"         : public
        , "counterpart"    : counterpart
        , "owner-account"  : owner-account
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "apollo-account" : apollo-account
        }
    )
    (defun UDC_AKY|Unregistered:object ()
        @doc "Sentinel for UR_ApiKeyRowOrNull when apollo-account is absent."
        { "apollo-account" : ""
        , "public"         : ""
        , "counterpart"    : BAR
        , "owner-account"  : ""
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "is-registered"  : false
        }
    )
    (defun UDC_AKY|WithRegisteredFlag:object (row:object{PYTHIA|S|ApiKey})
        (+ row { "is-registered": true })
    )
    (defun UDC_DLK|DualLink:object{PYTHIA|S|DualLink}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
            iz-active:bool
            dual-link-key:string
        )
        @doc "Constructor for object{PYTHIA|S|DualLink}; WI_DualLink stamps linked-at/updated-at."
        { "standard-apollo" : standard-apollo
        , "smart-apollo"    : smart-apollo
        , "consumer-lane"   : consumer-lane
        , "iz-active"       : iz-active
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "dual-link-key"   : dual-link-key
        }
    )
    (defun UDC_DLK|Unregistered:object ()
        @doc "Sentinel for UR_DualLinkRowOrNull when dual-link-key is absent."
        { "dual-link-key"   : ""
        , "standard-apollo" : ""
        , "smart-apollo"    : ""
        , "consumer-lane"   : BAR
        , "iz-active"       : false
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "is-registered"   : false
        }
    )
    (defun UDC_DLK|WithRegisteredFlag:object (row:object{PYTHIA|S|DualLink})
        (+ row { "is-registered": true })
    )
    (defun UDC_DualLinkView:object
        (
            dual-link-key:string
            standard-apollo:string
            smart-apollo:string
            iz-active:bool
            standard-owner:string
            smart-owner:string
            consumer-lane:string
        )
        @doc "Composite dual-link view (owners from ApiKeys halves)."
        { "dual-link-key"    : dual-link-key
        , "standard-apollo"  : standard-apollo
        , "smart-apollo"     : smart-apollo
        , "consumer-apollo"  : smart-apollo
        , "iz-active"        : iz-active
        , "standard-owner"   : standard-owner
        , "smart-owner"      : smart-owner
        , "consumer-lane"    : consumer-lane
        }
    )
    (defun UDC_PythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythMetrics}."
        { "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    (defun UDC_PythMetrics|Zero:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Zeroed six-metric blob."
        (UDC_PythMetrics 0 0.0 0 0 0 0)
    )
    (defun UDC_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal}
        (
            total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            last-day:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythTotal}."
        { "total-metrics": total-metrics
        , "last-day": last-day
        }
    )
    (defun UDC_PythTotal|Zero:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Zeroed Pyth running total (default before first flush)."
        (UDC_PythTotal (UDC_PythMetrics|Zero) 0)
    )
    (defun UDC_PythDaily:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        (
            day:integer
            flushed-at:time
            iz-sealed:bool
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythDaily}."
        { "day": day
        , "flushed-at": flushed-at
        , "iz-sealed": iz-sealed
        , "metrics": metrics
        }
    )
    (defun UDC_PythFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
        (
            day:integer
            iz-complete:bool
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}."
        { "day": day
        , "iz-complete": iz-complete
        , "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    ;;{5.2}  Compute [UC]
    (defun UC_DeployPrice:decimal ()
        @doc "Alias → UR_DeployPrice (kept for Talos/INFO call sites)."
        (UR_DeployPrice)
    )
    (defun UC_RenamePrice:decimal ()
        @doc "Alias → UR_RenamePrice (kept for Talos/INFO call sites)."
        (UR_RenamePrice)
    )
    (defun UC_IsStandardApollo:bool (apollo-account:string)
        @doc "True when apollo-account begins with Standard ₱. (false = Smart Π.)."
        (= PYTHIA|APOLLO-STANDARD (take 1 apollo-account))
    )
    (defun UC_FeeDiscountAnchor:string ()
        @doc "STOA fee discount anchor — BAR yields tier 0.0; Elite discounts never apply."
        BAR
    )
    (defun UC_RevokeIgnisFee:decimal ()
        @doc "Fixed IGNIS toll for owner or Cronoton dual-link revoke (1 IGNIS; collected in TS01-C4)."
        PYTHIA|REVOKE-IGNIS-FEE
    )
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string)
        @doc "Composite dual-link key: Standard ₱. + BAR + Smart Π."
        (+ standard-apollo (+ BAR smart-apollo))
    )
    (defun UC_DualLinkStandard:string (dual-link-key:string)
        @doc "Standard ₱. half of composite dual-link key."
        (take PYTHIA|APOLLO-LEN dual-link-key)
    )
    (defun UC_DualLinkSmart:string (dual-link-key:string)
        @doc "Smart Π. half of composite dual-link key."
        (drop (+ PYTHIA|APOLLO-LEN (length BAR)) dual-link-key)
    )
    (defun UC_ChainEpoch:integer (block-height:integer)
        @doc "Stoa chain epoch: block-height / 120 (int div) — matches explorer (e.g. 378734 → 3156)."
        (/ block-height PYTHIA|EPOCH-BLOCKS)
    )
    (defun UC_CurrentChainEpoch:integer ()
        @doc "Chain epoch for the executing block."
        (UC_ChainEpoch (at "block-height" (chain-data)))
    )
    (defun UC_AutonomousConsumerLane:string ()
        @doc "Token-style auto lane PYTHIA-<first 12 of prev-block-hash> via U|DALOS.UDC_Makeid; rename later via C_UpdateDualConsumerLane."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UDC_Makeid "PYTHIA")
        )
    )
    ;;
    (defun UCk_PythDaily:string (day:integer)
        @doc "PYTHIA|T|PythDaily key = decimal string of day ordinal."
        (int-to-str 10 day)
    )
    (defun UC_PythDayOrdinal:integer (stamp:time)
        @doc "Calendar operating day: 1 = PYTHIA|LEDGER-EPOCH-START (UTC midnight boundary)."
        (+ 1 (floor (/ (diff-time stamp PYTHIA|LEDGER-EPOCH-START) PYTHIA|SECONDS-PER-DAY)))
    )
    (defun UC_AddPythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            a:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            b:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Element-wise sum — A_Flush ADDs each entry (gateway drain delta) onto day row and grand total."
        { "petitions": (+ (at "petitions" a) (at "petitions" b))
        , "pondus": (+ (at "pondus" a) (at "pondus" b))
        , "transactions": (+ (at "transactions" a) (at "transactions" b))
        , "gas-reserved": (+ (at "gas-reserved" a) (at "gas-reserved" b))
        , "failed-transactions": (+ (at "failed-transactions" a) (at "failed-transactions" b))
        , "wasted-gas-reserved": (+ (at "wasted-gas-reserved" a) (at "wasted-gas-reserved" b))
        }
    )
    (defun UC_FlushAccFromTotal:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Seed batch fold from current PYTHIA|T|PythTotal row."
        { "total-metrics": (at "total-metrics" tot)
        , "last-day": (at "last-day" tot) }
    )
    (defun UC_FlushEntryMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
        @doc "Extract six-metric blob from a flush entry."
        (UDC_PythMetrics
            (at "petitions" entry)
            (at "pondus" entry)
            (at "transactions" entry)
            (at "gas-reserved" entry)
            (at "failed-transactions" entry)
            (at "wasted-gas-reserved" entry)
        )
    )
    (defun UC_MaxDay:integer (a:integer b:integer)
        @doc "Greater of two day ordinals."
        (if (> a b) a b)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_DeployApiKey:decimal ()
        @doc "Cost single-source for PYTHIA|C_DeployApiKey — RAW native STOA toll \
            \ (UC_DeployPrice, default 500). Discount anchor is BAR (no Elite discount). \
            \ Consumed by TS01-C4 exec collect + INFO preview."
        (UC_DeployPrice)
    )
    (defun URCi_UpdateDualConsumerLane:decimal ()
        @doc "Cost single-source for PYTHIA|C_UpdateDualConsumerLane — RAW native STOA \
            \ rename toll (UC_RenamePrice). Consumed by exec collect + INFO preview."
        (UC_RenamePrice)
    )
    (defun URCi_RevokeLink:decimal ()
        @doc "Cost single-source for PYTHIA|C_RevokeLink — flat IGNIS toll \
            \ (UC_RevokeIgnisFee), collected via IGNIS::XE_CollectIgnis in TS01-C4. \
            \ Consumed by exec + INFO."
        (UC_RevokeIgnisFee)
    )
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun UR_AKY|Data:object{PYTHIA|S|ApiKey} (apollo-account:string)
        @doc "Full Apollo half row."
        (read PYTHIA|T|ApiKeys apollo-account)
    )
    (defun UR_Public:string (apollo-account:string)
        (at "public" (read PYTHIA|T|ApiKeys apollo-account ["public"]))
    )
    (defun UR_Counterpart:string (apollo-account:string)
        (at "counterpart" (read PYTHIA|T|ApiKeys apollo-account ["counterpart"]))
    )
    (defun UR_OwnerAccount:string (apollo-account:string)
        (at "owner-account" (read PYTHIA|T|ApiKeys apollo-account ["owner-account"]))
    )
    (defun UR_RegisteredAt:time (apollo-account:string)
        (at "registered-at" (read PYTHIA|T|ApiKeys apollo-account ["registered-at"]))
    )
    (defun UR_UpdatedAt:time (apollo-account:string)
        (at "updated-at" (read PYTHIA|T|ApiKeys apollo-account ["updated-at"]))
    )
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string)
        @doc "ApiKey row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_AKY|Data apollo-account)) false)
            (UDC_AKY|Unregistered)
            (UDC_AKY|WithRegisteredFlag (UR_AKY|Data apollo-account))
        )
    )
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun UR_DLK|Data:object{PYTHIA|S|DualLink} (dual-link-key:string)
        @doc "Full dual-link row."
        (read PYTHIA|T|DualLinks dual-link-key)
    )
    (defun UR_DualLinkIzActive:bool (dual-link-key:string)
        (at "iz-active" (read PYTHIA|T|DualLinks dual-link-key ["iz-active"]))
    )
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string)
        @doc "DualLink row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_DLK|Data dual-link-key)) false)
            (UDC_DLK|Unregistered)
            (UDC_DLK|WithRegisteredFlag (UR_DLK|Data dual-link-key))
        )
    )
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string)
        @doc "iz-active when dual row exists; false when absent (default-read)."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"iz-active" : false}
            {"iz-active" := iz}
            iz
        )
    )
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string)
        @doc "Stoic lane on dual link row; BAR when row absent."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"consumer-lane" : BAR}
            {"consumer-lane" := lane}
            lane
        )
    )
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    (defun UR_Config ()
        @doc "Full Config row (deploy-price + rename-price); defaults when unset. The defaults \
            \ are DERIVED, not hardcoded: every Ouronet price is denominated in DOLLARS and \
            \ converted to STOA at the oracle, so these read $50 deploy / $10 rename out of \
            \ IG|DETER through UC_StoaPrice (= 500 / 100 STOA at the $0.10 peg, unchanged from \
            \ the raw constants they replace). Governance may still override either in-table."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-default-read PYTHIA|T|Config PYTHIA|INFO
                {"deploy-price" : (ref-IGNIS::UC_StoaPrice "pythia-deploy")
                ,"rename-price" : (ref-IGNIS::UC_StoaPrice "pythia-rename")}
                {"deploy-price" := d, "rename-price" := r}
                {"deploy-price" : d, "rename-price" : r}
            )
        )
    )
    (defun UR_DeployPrice:decimal ()
        @doc "Governance-tunable deploy toll (default $50 = 500 STOA per Apollo half; collected in TS01-C4)."
        (at "deploy-price" (UR_Config))
    )
    (defun UR_RenamePrice:decimal ()
        @doc "Governance-tunable consumer-lane rename toll (default $10 = 100 STOA; collected in TS01-C4)."
        (at "rename-price" (UR_Config))
    )
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    (defun UR_RevocationAtHeight:integer ()
        @doc "Block height recorded at last dual-link revoke; 0 when never revoked."
        (with-default-read PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height" : 0}
            {"revoked-at-height" := h}
            h
        )
    )
    (defun UR_RevocationEpoch:integer ()
        @doc "Chain epoch at last revoke: floor(revoked-at-height / 120); 0 when never revoked."
        (let
            (
                (h:integer (UR_RevocationAtHeight))
            )
            (if (= h 0)
                0
                (UC_ChainEpoch h)
            )
        )
    )
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun UR_PythDay:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (day:integer)
        @doc "Full Pyth daily delta row for day ordinal; zeroed row for un-flushed / gap \
            \ days (never aborts, so range reads survive holes in the ledger)."
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day":         day
            , "flushed-at":  PYTHIA|LEDGER-EPOCH-START
            , "iz-sealed":   false
            , "metrics":     (UDC_PythMetrics|Zero) }
            { "day"        := d
            , "flushed-at" := fa
            , "iz-sealed"  := iz
            , "metrics"    := m }
            (UDC_PythDaily d fa iz m)
        )
    )
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    (defun UR_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Running Pyth ledger totals; zeros when never flushed."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            { "total-metrics":
                { "petitions": 0
                , "pondus": 0.0
                , "transactions": 0
                , "gas-reserved": 0
                , "failed-transactions": 0
                , "wasted-gas-reserved": 0 }
            , "last-day": 0 }
            { "total-metrics" := total-metrics
            , "last-day" := last-day }
            (UDC_PythTotal total-metrics last-day)
        )
    )
    (defun UR_PythTotal|TotalMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Six-metric running totals blob; zeros when never flushed."
        (at "total-metrics" (UR_PythTotal))
    )
    (defun UR_PythTotal|LastDay:integer ()
        @doc "Highest calendar day ordinal with a daily row; 0 before first flush."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            {"last-day": 0}
            {"last-day" := last-day}
            last-day
        )
    )
    (defun UR_PythCurrentDay:integer ()
        @doc "Calendar day ordinal for the executing block-time (UTC; helper for Khronoton)."
        (UC_PythDayOrdinal (at "block-time" (chain-data)))
    )
    (defun UR_PythLedgerEpochStart:time ()
        @doc "UTC midnight anchor for calendar day 1; keyless read for off-chain day math."
        PYTHIA|LEDGER-EPOCH-START
    )
    (defun UR_PythMaxFlushBatch:integer ()
        @doc "Max calendar-day entries per A_Flush tx (tuned for ~2M gas; see HANDOFF)."
        PYTHIA|MAX-FLUSH-BATCH
    )
    (defun UR_PythDailyExists:bool (day:integer)
        @doc "True when PYTHIA|T|PythDaily has a row for day ordinal."
        ;; Avoid (keys ...) enumeration (disallowed in some capability/guard modes) AND
        ;; do not rely on UR_PythDay throwing (it now defaults). Probe a sentinel `day`
        ;; of -1: a real row always carries day >= 1, so present <=> read day != -1.
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day": -1 }
            { "day" := d }
            (!= d -1)
        )
    )
    ;;
    ;; [7] Composite reads (dual-link views)
    (defun UR_ApiKeyBySlot:object (standard-apollo:string)
        @doc "Dual-link view keyed by Standard ₱. slot (owner/status reads)."
        (let
            (
                (counterpart:string (UR_Counterpart standard-apollo))
                (dlk:string
                    (if (= counterpart BAR)
                        BAR
                        (UC_DualLinkKey standard-apollo counterpart)
                    )
                )
            )
            (if (= dlk BAR)
                (UDC_DualLinkView BAR standard-apollo BAR false BAR BAR BAR)
                (let
                    (
                        (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dlk))
                        (standard:string (at "standard-apollo" row))
                        (smart:string (at "smart-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart)
                        lane
                    )
                )
            )
        )
    )
    ;; WU_PythTotal|TotalMetrics — not used: mutates via WW_PythTotal (full row).
    ;; WU_PythTotal|LastDay — not used: mutates via WW_PythTotal (full row).
    ;;
    (defun URH_ApiKeyCount:integer ()
        (length (keys PYTHIA|T|ApiKeys))
    )
    (defun URH_ApiKeyCountStr:string ()
        (format "Pythia Apollo halves registered: {}" [(URH_ApiKeyCount)])
    )
    (defun URH_DualLinkCount:integer ()
        (length (keys PYTHIA|T|DualLinks))
    )
    (defun URH_ListAllApiKeys:[object] ()
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "counterpart" "owner-account"
              "registered-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListAllDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListActiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= true))
        )
    )
    (defun URH_ListInactiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= false))
        )
    )
    (defun URH_ActiveDualLinkSet:[string] ()
        @doc "Active dual-link-key strings for Pythia cache mirror."
        (map
            (lambda (row:object) (at "dual-link-key" row))
            (select PYTHIA|T|DualLinks ["dual-link-key"] (where "iz-active" (= true)))
        )
    )
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string)
        @doc "Auth-path lookup by Smart Π. consumer half (select on DualLinks)."
        (let
            (
                (rows:[object] (select PYTHIA|T|DualLinks
                    [ "dual-link-key" "standard-apollo" "smart-apollo" "iz-active" "consumer-lane" ]
                    (where "smart-apollo" (= smart-apollo))
                ))
            )
            (if (= (length rows) 0)
                (UDC_DualLinkView BAR BAR smart-apollo false BAR BAR BAR)
                (let
                    (
                        (row:object (at 0 rows))
                        (dlk:string (at "dual-link-key" row))
                        (standard:string (at "standard-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart-apollo
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart-apollo)
                        lane
                    )
                )
            )
        )
    )
    (defun URH_ListPythDaily:[object{PythiaLedgerV3.PYTHIA|S|PythDaily}] (from:integer to:integer)
        @doc "Bounded daily delta rows for charting (inclusive range; empty when invalid)."
        (if
            (fold (or) false
                [
                    (< from 1)
                    (< to from)
                    (> (- to from) PYTHIA|MAX-DAILY-RANGE)
                ]
            )
            []
            (map
                (lambda (d:integer) (UR_PythDay d))
                (enumerate from to)
            )
        )
    )
    ;;
    (defun INFO_PYTHIA|DeployApiKey:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_DeployApiKey (500 STOA per half)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (deploy-fee:decimal (UR_DeployPrice))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
                (kind:string
                    (if (UC_IsStandardApollo apollo-account) "Standard (₱.)" "Smart (Π.)")
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploy {} Pythia Apollo half (unlinked)." [kind])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "Native STOA deploy fee: {} per half (full price; Elite discounts do not apply)." [deploy-fee])
                    "Consumer lane is set at C_Link when both halves are paired."
                ]
                [(format "Pythia {} Apollo half registered (unlinked)." [kind])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) deploy-fee)
                []
            )
        )
    )
    (defun INFO_PYTHIA|Link:object{OuronetInfoV2.ClientInfo}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_Link (inactive dual row; no fee)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (std-owner:string (UR_OwnerAccount standard-apollo))
                (smt-owner:string (UR_OwnerAccount smart-apollo))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount std-owner))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount smt-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Link Standard {} to Smart {} for lane {} (inactive dual row)." [standard-apollo smart-apollo consumer-lane])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Dual link key: {}." [dlk])
                    "No STOA or IGNIS fee. Cronoton activates after off-chain proof."
                ]
                [(format "Pythia dual link {} created for lane {} (inactive)." [dlk consumer-lane])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|RevokeLink:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_RevokeLink / A_RevokeLink (1 IGNIS)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (revoke-fee:decimal (UC_RevokeIgnisFee))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Revoke (deactivate) dual link {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "IGNIS fee: {} (minimum unit)." [revoke-fee])
                    "Counterpart fields remain immutable; deploy fresh halves to re-pair."
                ]
                [(format "Pythia dual link {} deactivated." [dual-link-key])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron revoke-fee)
                )
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|UpdateDualConsumerLane:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
            new-name:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_UpdateDualConsumerLane."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (rename-fee:decimal (UR_RenamePrice))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Rename Pythia dual link consumer-lane to {}." [new-name])
                    (format "Dual link key: {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Native STOA rename fee: {} (full price; Elite discounts do not apply)." [rename-fee])
                ]
                [(format "Pythia dual link lane renamed to {}." [new-name])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) rename-fee)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_FlushEntries:bool (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Validate flush batch: fold over entries; pure bool (no enforce)."
        (fold
            (lambda (acc:bool entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
                (let
                    (
                        (day:integer (at "day" entry))
                        (pondus:decimal (at "pondus" entry))
                        (sealed-ok:bool
                            (if (UR_PythDailyExists day)
                                (= (at "iz-sealed" (UR_PythDay day)) false)
                                true
                            )
                        )
                        (entry-ok:bool
                            (fold (and) true
                                [
                                    (> day 0)
                                    (>= (at "petitions" entry) 0)
                                    (>= pondus 0.0)
                                    (= pondus (floor pondus 3))
                                    (>= (at "transactions" entry) 0)
                                    (>= (at "gas-reserved" entry) 0)
                                    (>= (at "failed-transactions" entry) 0)
                                    (>= (at "wasted-gas-reserved" entry) 0)
                                    sealed-ok
                                ]
                            )
                        )
                    )
                    (and acc entry-ok)
                )
            )
            true
            entries
        )
    )
    (defun UEV_ValidateCompositeDualLinkKey:bool (dual-link-key:string)
        @doc "Dual-link-key is 325 chars: valid ₱. standard + BAR + valid Π. smart."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (standard:string (UC_DualLinkStandard dual-link-key))
                (smart:string (UC_DualLinkSmart dual-link-key))
                (sep:string (take (length BAR) (drop PYTHIA|APOLLO-LEN dual-link-key)))
            )
            (enforce (= (length dual-link-key) PYTHIA|DUAL-LINK-LEN) "Dual link key length must be 325")
            (enforce (= sep BAR) "Dual link key separator must be BAR")
            (and
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck standard false)
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck smart true)
            )
        )
    )
    (defun UEV_DualPairForLink
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves deployed, unlinked, valid glyphs, dual row absent."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (UEV_ValidateCompositeDualLinkKey dlk)
            (enforce (= (UR_Counterpart standard-apollo) BAR) "Standard half is already linked")
            (enforce (= (UR_Counterpart smart-apollo) BAR) "Smart half is already linked")
            ;;UNREACHABLE: the DLK row exists only if the pair was linked, and both link paths
            ;;(A_LinkDualApiKey / C_LinkDualApiKey) call XI_ApplyDualCounterparts -- which sets
            ;;BOTH counterparts -- immediately before WI_DualLink, in one transaction. So the
            ;;row's existence implies the counterpart enforces above already fired. Counterparts
            ;;are never cleared (C_RevokeDualLink deactivates only). Fail-closed backstop that
            ;;would start earning its keep if a non-atomic write path were ever introduced.
            ;;Demonstrated in REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce
                (= (try false (UR_DLK|Data dlk)) false)
                "Dual link row already exists for this pair"
            )
        )
    )
    (defun UEV_DualPairReadyForActivate
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves exist and counterparts match (linked metadata present)."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (enforce (= (UR_Counterpart standard-apollo) smart-apollo) "Standard half not linked to Smart")
            ;;UNREACHABLE for the same reason as the backstop in UEV_DualPairForLink above: the
            ;;two counterparts are written as one atomic pair by XI_ApplyDualCounterparts, so
            ;;they cannot disagree, and any genuine mismatch trips the STANDARD-side enforce on
            ;;the line above. Pinned as unreachable, not as coverage, in
            ;;REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce (= (UR_Counterpart smart-apollo) standard-apollo) "Smart half not linked to Standard")
            dlk
        )
    )
    ;;{5.5}  Write [W]
    ;;
    ;; Six blocks — one per deftable (table order). Within each block: WI → WW → WU (all fields).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_* / sibling WU_*.
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun WI_ApiKey:string
        (
            apollo-account:string
            row:object{PYTHIA|S|ApiKey}
        )
        @doc "Insert PYTHIA|T|ApiKeys full row (deploy only); stamps registered-at/updated-at from block time."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|ApiKeys apollo-account
                (+ {"registered-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_ApiKey — not used: deploy path is WI_ApiKey.
    ;; WU_ApiKey|Public — not mutable [.]
    (defun WU_ApiKey|Counterpart:string (apollo-account:string counterpart:string)
        @doc "Set counterpart on PYTHIA|T|ApiKeys (link only; immutability enforced in event caps)."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account
            { "counterpart": counterpart
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_ApiKey|OwnerAccount — not mutable [.]
    ;; WU_ApiKey|RegisteredAt — not mutable [.]
    ;; WU_ApiKey|UpdatedAt — not used: mutates via WU_ApiKey|Counterpart.
    ;; WU_ApiKey|ApolloAccount — select key; WU not needed.
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun WI_DualLink:string
        (
            dual-link-key:string
            row:object{PYTHIA|S|DualLink}
        )
        @doc "Insert PYTHIA|T|DualLinks full row (C_Link inactive or A_Link create+active); stamps linked-at/updated-at."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|DualLinks dual-link-key
                (+ {"linked-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_DualLink — not used: link path is WI_DualLink; revoke uses WU_DualLink|IzActive.
    ;; WU_DualLink|StandardApollo — not mutable [.]
    ;; WU_DualLink|SmartApollo — not mutable [.]
    (defun WU_DualLink|ConsumerLane:string (dual-link-key:string consumer-lane:string)
        @doc "Update consumer-lane on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "consumer-lane": consumer-lane
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    (defun WU_DualLink|IzActive:string (dual-link-key:string iz-active:bool)
        @doc "Update iz-active on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "iz-active": iz-active
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_DualLink|LinkedAt — not mutable [.]
    ;; WU_DualLink|UpdatedAt — not used: mutates via WU_DualLink|ConsumerLane / WU_DualLink|IzActive.
    ;; WU_DualLink|DualLinkKey — select key; WU not needed.
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    ;; WI_Config — not used: first row touch is WW_Config (upsert path).
    (defun WW_Config:string (deploy-price:decimal rename-price:decimal)
        @doc "Upsert PYTHIA|T|Config full row (governance price updates)."
        (require-capability (SECURE))
        (write PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price": deploy-price, "rename-price": rename-price}
        )
    )
    ;; WU_Config|DeployPrice — not used: mutates via WW_Config (full row).
    ;; WU_Config|RenamePrice — not used: mutates via WW_Config (full row).
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    ;; WI_Revocation — not used: first row touch is WW_Revocation (upsert path).
    (defun WW_Revocation:string (revoked-at-height:integer)
        @doc "Upsert PYTHIA|T|Revocation block height anchor (set on each revoke)."
        (require-capability (SECURE))
        (write PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height": revoked-at-height}
        )
    )
    ;; WU_Revocation|RevokedAtHeight — not used: mutates via WW_Revocation (full row).
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun WI_PythDaily:string
        (
            day:integer
            row:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        )
        @doc "Insert PYTHIA|T|PythDaily full row (first flush of calendar day only)."
        (require-capability (SECURE))
        (insert PYTHIA|T|PythDaily (UCk_PythDaily day) row)
    )
    (defun WU_PythDaily|Metrics:string
        (
            day:integer
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Replace same-day metrics snapshot (open day re-flush)."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"metrics": metrics})
    )
    (defun WU_PythDaily|FlushedAt:string (day:integer flushed-at:time)
        @doc "Stamp latest flush time on the open calendar day row."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"flushed-at": flushed-at})
    )
    (defun WU_PythDaily|IzSealed:string (day:integer iz-sealed:bool)
        @doc "Seal a calendar day when advancing to the next day."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"iz-sealed": iz-sealed})
    )
    ;; WU_PythDaily|Day — not mutable [.]
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    ;; WI_PythTotal — not used: first row touch is WW_PythTotal (upsert path).
    (defun WW_PythTotal:string (row:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Upsert PYTHIA|T|PythTotal full row (A_Flush total-metrics + last-day)."
        (require-capability (SECURE))
        (write PYTHIA|T|PythTotal PYTHIA|STOACHAIN row)
    )
    ;;{5.6}  Aux/X
    ;;
    ;;Protection: Class 1 — Innate protection offered by WW_Revocation
    (defun XI_RecordRevocationAtHeight:integer ()
        @doc "Record executing block height at revoke (fast-lane poll via UR_RevocationAtHeight)."
        ;; SECURE: granted by WW_Revocation (underlying W_).
        (let
            (
                (bh:integer (at "block-height" (chain-data)))
            )
            (WW_Revocation bh)
            bh
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_ApiKey|Counterpart
    (defun XI_ApplyDualCounterparts:string
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Fill immutable counterpart fields on both Apollo halves."
        ;; SECURE: granted by WU_ApiKey|Counterpart; BAR validated in PYTHIA|C>LINK-DUAL cap.
        (WU_ApiKey|Counterpart standard-apollo smart-apollo)
        (WU_ApiKey|Counterpart smart-apollo standard-apollo)
        (format "Counterparts linked: {} <-> {}" [standard-apollo smart-apollo])
    )
    ;;Protection: Class 1 — Innate protection offered by WW_PythTotal
    (defun XI_FlushPythLedger:string
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Process batch entries; commit running total once (entries may land in any tx order)."
        ;; SECURE: granted by WW_PythTotal (underlying W_).
        (let
            (
                (now:time (at "block-time" (chain-data)))
                (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal} (UR_PythTotal))
                (init:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc} (UC_FlushAccFromTotal tot))
                (final:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                    (fold
                        (lambda
                            (
                                acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                                entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
                            )
                            (XI_1|ApplyOneFlushEntry acc entry now)
                        )
                        init
                        entries
                    )
                )
            )
            (WW_PythTotal
                (UDC_PythTotal
                    (at "total-metrics" final)
                    (at "last-day" final)
                )
            )
            (format "batch {} entries" [(length entries)])
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_PythDaily|Metrics,
    ;;Protection:          WU_PythDaily|FlushedAt, WU_PythDaily|IzSealed, WI_PythDaily
    (defun XI_1|ApplyOneFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (
            acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
            entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
            now:time
        )
        @doc "Fold step: ADD entry metrics (gateway drain delta) onto day row + grand total; seal flag only."
        ;; SECURE: granted by WI_/WU_PythDaily (underlying W_).
        (let
            (
                (day:integer (at "day" entry))
                (iz-complete:bool (at "iz-complete" entry))
                (delta:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_FlushEntryMetrics entry)
                )
                (total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (at "total-metrics" acc)
                )
                (last-day:integer (at "last-day" acc))
                (next-last:integer (UC_MaxDay last-day day))
                (next-total:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_AddPythMetrics total-metrics delta)
                )
            )
            (if (UR_PythDailyExists day)
                (let
                    (
                        (old-row:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (UR_PythDay day))
                        (day-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                            (UC_AddPythMetrics (at "metrics" old-row) delta)
                        )
                    )
                    (WU_PythDaily|Metrics day day-metrics)
                    (WU_PythDaily|FlushedAt day now)
                    (if iz-complete (WU_PythDaily|IzSealed day true) true)
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
                (let
                    (
                        (_:string (WI_PythDaily day (UDC_PythDaily day now iz-complete delta)))
                    )
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_LinkDualApiKey:string (patron:string executor:string standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate (no fee): create active dual with auto PYTHIA-<hash12> lane, or flip inactive C_Link row to true. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the CRONOTON \
            \ KEYSET -- PYTHIA|CRONOTON enforce-guards it -- so there is no account anywhere in \
            \ the authority path and nothing for a binder to bind to. <executor> is therefore \
            \ proven DIRECTLY, and records which Ouronet account drove an automaton action that \
            \ the keyset alone cannot attribute. Both proofs are now required."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (with-capability (PYTHIA|A>LINK-DUAL standard-apollo smart-apollo)
                (if row-missing
                    (let
                        (
                            (lane:string (UC_AutonomousConsumerLane))
                        )
                        (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                        (WI_DualLink dlk
                            (UDC_DLK|DualLink
                                standard-apollo smart-apollo lane true dlk
                            )
                        )
                        (format "Pythia dual link {} created+activated with lane {}" [dlk lane])
                    )
                    (let
                        (
                            (msg:string
                                (format "Pythia dual link {} activated" [dlk])
                            )
                        )
                        (WU_DualLink|IzActive dlk true)
                        msg
                    )
                )
            )
        )
    )
    (defun A_RevokeDualLink:string (patron:string executor:string dual-link-key:string)
        @doc "Cronoton revokes active dual link. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the CRONOTON \
            \ KEYSET -- PYTHIA|CRONOTON enforce-guards it -- so there is no account anywhere in \
            \ the authority path and nothing for a binder to bind to. <executor> is therefore \
            \ proven DIRECTLY, and records which Ouronet account drove an automaton action that \
            \ the keyset alone cannot attribute. Both proofs are now required."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (PYTHIA|A>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by Cronoton" [dual-link-key])
    )
    (defun A_UpdateDeployPrice:string (patron:string executor:string new-price:decimal)
@doc "Sets the Pythia DEPLOY price. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is GOV|PYTHIA_ADMIN, \
            \ a Demiurgoi keyset guard naming no account; <executor> is the ACTOR among its holders \
            \ and is proven by CAP_EnforceAccountOwnership. This function had NO @doc at all before \
            \ this turn -- one of two in the module -- so the price surface was undocumented as well \
            \ as unattributed."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config new-price (UR_RenamePrice))
            )
        )
        (format "Pythia deploy price set to {}" [new-price])
    )
    (defun A_UpdateRenamePrice:string (patron:string executor:string new-price:decimal)
@doc "Sets the Pythia RENAME price. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is GOV|PYTHIA_ADMIN, \
            \ a Demiurgoi keyset guard naming no account; <executor> is the ACTOR among its holders \
            \ and is proven by CAP_EnforceAccountOwnership. This function had NO @doc at all before \
            \ this turn -- one of two in the module -- so the price surface was undocumented as well \
            \ as unattributed."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config (UR_DeployPrice) new-price)
            )
        )
        (format "Pythia rename price set to {}" [new-price])
    )
    (defun A_Flush:string (patron:string executor:string entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch flush: each entry is a drain DELTA — ADD onto day row + grand total; iz-complete seals only. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the CRONOTON \
            \ KEYSET -- PYTHIA|CRONOTON enforce-guards it -- so there is no account anywhere in \
            \ the authority path and nothing for a binder to bind to. <executor> is therefore \
            \ proven DIRECTLY, and records which Ouronet account drove an automaton action that \
            \ the keyset alone cannot attribute. Both proofs are now required."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (PYTHIA|A>FLUSH entries)
            (XI_FlushPythLedger entries)
        )
        (format "Pythia ledger flushed {} day entries" [(length entries)])
    )
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            patron:string
            executor:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Fee in TS01-C4. \
            \ \
            \ A RENAME, not an addition (patron/executor canon 2.2, 2026-09-22): the old \
            \ <owner-account> was ALREADY the executor. PYTHIA|C>DEPLOY-API-KEY composes \
            \ PYTHIA|OWNER on it, which is CAP_EnforceAccountOwnership -- a PARAMETER, proven \
            \ directly. \
            \ \
            \ THIS IS THE FUNCTION THAT CREATES THE DERIVED ACCOUNT EVERY OTHER PYTHIA \
            \ ENTRYPOINT LATER READS. The value is written into the ApiKeys row and comes back \
            \ as (UR_OwnerAccount apollo-account), which is what PYTHIA|OWNER is composed on in \
            \ the three dual-link capabilities. So the one place the account is a parameter is \
            \ the place it is first recorded; everywhere after, it is a lookup, and the actor \
            \ went missing with it. That progression -- passed once, derived forever -- is the \
            \ mechanism behind HANDOFF 4g, visible end to end in one module."
        (P|UEV_IMC)
        (let
            (
                (kind:string (if (UC_IsStandardApollo apollo-account) "Standard" "Smart"))
            )
            (with-capability (PYTHIA|C>DEPLOY-API-KEY executor apollo-account public)
                (WI_ApiKey apollo-account
                    (UDC_AKY|ApiKey public BAR executor apollo-account)
                )
            )
            (format "Pythia {} Apollo half {} registered (unlinked)" [kind apollo-account])
        )
    )
    (defun C_LinkDualApiKey:string
        (
            executor:string
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both half-owners link deployed halves into inactive dual row with lane (no fee). \
            \ \
            \ PATRONLESS BY DESIGN, and it is the only client op in this module that is. Its \
            \ Talos wrapper PYTHIA|C_Link takes no patron and collects nothing, while all three \
            \ of its siblings charge. That is safe because it is BOUNDED, not because it is \
            \ cheap: linking needs two already-deployed Apollo halves at 500 native STOA each, \
            \ UEV_DualPairForLink refuses a half whose counterpart is set, and counterparts are \
            \ never cleared -- so the free call is one-shot per pair, forever. Pinned by \
            \ modules/PYTHIA.repl <<PYTHIA-LINK-ECON>>; if counterparts ever become clearable, \
            \ the patronless design stops being safe. \
            \ \
            \ The executor is bound by UEV_ExecutorIsHalfOwner inside PYTHIA|C>LINK-DUAL. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (with-capability (PYTHIA|C>LINK-DUAL executor standard-apollo smart-apollo consumer-lane)
                (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                (WI_DualLink dlk
                    (UDC_DLK|DualLink
                        standard-apollo smart-apollo consumer-lane false dlk
                    )
                )
            )
            (format "Pythia dual link {} created for lane {} (inactive)" [dlk consumer-lane])
        )
    )
    (defun C_RevokeDualLink:string (patron:string executor:string dual-link-key:string)
        @doc "Both half-owners revoke active dual link. Fee in TS01-C4 (IGNIS). \
            \ \
            \ HANDOFF 4g, in its two-signature form. The capability composes PYTHIA|OWNER TWICE, on \
            \ two accounts DERIVED from the link row -- (UR_OwnerAccount standard) and \
            \ (UR_OwnerAccount smart) -- so the authority is fully proven and the ACTOR is absent. \
            \ Two signatures say the operation was permitted; they do not say which side asked. \
            \ UEV_ExecutorIsHalfOwner, inside the capability, supplies that half as a DISJUNCTION. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>REVOKE-DUAL executor dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by owner" [dual-link-key])
    )
    (defun C_UpdateDualConsumerLane:string
        (
            patron:string
            executor:string
            dual-link-key:string
            new-name:string
        )
        @doc "Both half-owners rename consumer-lane on dual link row. Fee in TS01-C4. \
            \ \
            \ HANDOFF 4g, in its two-signature form. The capability composes PYTHIA|OWNER TWICE, on \
            \ two accounts DERIVED from the link row -- (UR_OwnerAccount standard) and \
            \ (UR_OwnerAccount smart) -- so the authority is fully proven and the ACTOR is absent. \
            \ Two signatures say the operation was permitted; they do not say which side asked. \
            \ UEV_ExecutorIsHalfOwner, inside the capability, supplies that half as a DISJUNCTION. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>UPDATE-DUAL-LANE executor dual-link-key new-name)
            (WU_DualLink|ConsumerLane dual-link-key new-name)
        )
        (format "Pythia dual link {} lane renamed to {}" [dual-link-key new-name])
    )

)

;; Module install — (create-table ...) runs in the same tx as (module PYTHIA …) on greenfield deploy.
                    ;; policy
                   ;; policy meta
       ;; V1 name; V3 schema
        ;; carryover
     ;; V3 NEW
    ;; V3 NEW
     ;; Ledger NEW
     ;; Ledger NEW

;; --- tables for 22_PYTHIA.pact (8 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table PYTHIA|T|ApiKeys)
;; (create-table PYTHIA|T|Config)
;; (create-table PYTHIA|T|DualLinks)
;; (create-table PYTHIA|T|Revocation)
;; (create-table PYTHIA|T|PythDaily)
;; (create-table PYTHIA|T|PythTotal)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_AdminV2
    @doc "Exposes Ouronet Administrative Functions"

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
    ;;
    ;;
    ;;Fueling Functions
    (defun XB_DynamicFuelSTOA ())
    (defun XE_ConditionalFuelSTOA (condition:bool))
    ;;{5.7}  User [A/C]
    ;;
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string))
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool))
    (defun DALOS|A_ToggleGAP (executor:string gap:bool))
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool))
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool))
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal))
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool))
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string))
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal))
    ;;
    ;;
    (defun BRD|A_Live (executor:string entity-id:string))
    (defun BRD|A_SetFlag (executor:string entity-id:string flag:integer))
    ;;
    ;;
    (defun DPTF|A_UpdateTreasuryDispoParameters (executor:string type:integer tdp:decimal tds:decimal))
    (defun DPTF|A_WipeTreasuryDebt (executor:string))
    (defun DPTF|A_WipeTreasuryDebtPartial (executor:string debt-to-be-wiped:decimal))
    (defun DPTF|A_DeployAccount (patron:string executor:string executee:string id:string))
    ;;
    (defun DPOF|A_DeployAccount (patron:string executor:string executee:string id:string))
    ;;
    (defun ATS|AA_RemoveSecondary (patron:string executor:string ats:string reward-token:string accounts-with-ats-data:[string]))
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    ;;
    (defun LIQUID|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string))
    ;;
    ;;
    (defun ORBR|A_Fuel (executor:string))
    ;;
    ;;
    (defun SWP|A_UpdatePrincipal (executor:string principal:string add-or-remove:bool))
    (defun SWP|A_RotatePrincipal (executor:string old:string new:string))
    (defun SWP|A_UpdateLimit (executor:string limit:decimal spawn:bool))
    (defun SWP|A_UpdateLiquidBoost (executor:string new-boost-variable:bool))
    (defun SWP|A_DefinePrimordialPool (executor:string primordial-pool:string))
    (defun SWP|A_ToggleAsymetricLiquidityAddition (executor:string toggle:bool))

)
;;
(module TS01-A GOV
    @doc "TALOS Stage 1 Administrator Functions \
        \ Contains All Administrator functions [DALOS BRD ORBR SWP]\
        \ Also contains Fueling Functions needed in all subsequent TALOS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_AdminV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-A                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-A_ADMIN)))
    (defcap GOV|TS01-A_ADMIN ()                         (enforce-guard GOV|MD_TS01-A))
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
        @doc "Talos Summoner Capability"
        true
    )
    (defcap P|TRG ()
        @doc "Talos Remote Governor Capability"
        true
    )
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (GOV|TS01-A_ADMIN))
    )
    (defcap P|GOVERNING-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (P|TRG))
    )
    (defcap P|SECURE-SUMMONER ()
        (compose-capability (P|TS))
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
        (with-capability (GOV|TS01-A_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-A_ADMIN)
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
        (with-capability (GOV|TS01-A_ADMIN)
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
        (with-capability (GOV|TS01-A_ADMIN)
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
        @doc "Fix (audit finding #22L test-coverage sweep): ATS and ATSU were never \
            \ registered as permitted callers here (ATS was even bound - ref-P|ATS - \
            \ but never used), so any TS01-A admin function routing into either module \
            \ (e.g. ATS|AA_RemoveSecondary, ATS|A_KickStart) always failed P|UEV_IMC's \
            \ whitelist check - unconditionally, regardless of caller/key. Never caught \
            \ because those functions had zero test coverage. Every other Talos module's \
            \ own P|A_Define already registers into both ATS and ATSU; this just matches \
            \ that existing pattern."
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|TS)))
            )
            (ref-P|DALOS::P|A_Add
                "TS01-A|RemoteDalosGov"
                (create-capability-guard (P|TRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst GASLESS-PATRON                            (URC_Gassless))
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_Gassless ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [Fueling Functions]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DynamicFuelSTOA ()
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (ref-DALOS::UR_AutoFuel)
                (with-capability (SECURE)
                    (XI_DirectFuelSTOA)
                )
                true
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ConditionalFuelSTOA (condition:bool)
        (P|UEV_IMC)
        (if condition
            (with-capability (SECURE)
                (XB_DynamicFuelSTOA)
            )
            true
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_DirectFuelSTOA ()
        (require-capability (SECURE))
        (let
            (
                (ref-ORBR:module{OuroborosV2} OUROBOROS)
            )
            (with-capability (P|TS)
                (ref-ORBR::C_Fuel GASLESS-PATRON)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;  [DALOS_Administrator]
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string)
        @doc "Migrates Ouronet Gas Station Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_MigrateLiquidFunds GASLESS-PATRON executor migration-target-stoa-account)
            )
        )
    )
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool)
        @doc "Toggles the Ouroboros Autonomous Price Update to <oapu>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleOAPU GASLESS-PATRON executor oapu)
                (if oapu
                    "Ouroboros Autonomous Price Update successfully turned ON"
                    "Ouroboros Autonomous Price Update successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_ToggleGAP (executor:string gap:bool)
        @doc "Toggles the Global administrative Pause, the GAP, to <toggle>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGAP GASLESS-PATRON executor gap)
                (if gap
                    "Global Administrative Pause successfully turned ON"
                    "Global Administrative Pause successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Smart Ouronet Account in Administrator Mode, without collection STOA. \
            \ \
            \ Executor: SELF-PROVING, the base case of the attribution rule (owner ruling, \
            \ 2026-09-21). The executor IS the account being created, so its ownership cannot be \
            \ read from a table -- there is no row yet. It does not need to be. The <guard> the \
            \ account will be governed by travels in the same call, and \
            \ DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT enforces it through U|G::UEV_Any -- an \
            \ enforce-ONE over [guard, (create-capability-guard (GOV))] -- FIRST, before the glyph \
            \ and format checks. Same proof UEV_SmartAccOwn performs on an existing account, same \
            \ key; the guard is supplied in the call because at creation there is nowhere else it \
            \ could come from. The second list element is the governance door genesis uses to \
            \ make the first account. \
            \ \
            \ That the UEV_Any runs FIRST is not incidental -- it is what makes the proof a proof \
            \ rather than a check some other refusal could shadow -- and it is pinned by \
            \ <<DALOS-G4b>>, which pairs a held guard (format refusal) against an unheld one \
            \ (guard refusal). \
            \ (patron/executor canon 2.2; route named here because check 7 requires it to be, and \
            \ found it missing at 01_TS01-A's own turn, 2026-09-22.)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeploySmartAccount executor guard stoa sovereign public)
                (format "Succesfuly deployed Smart Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account in Administrator Mode, without collection STOA. \
            \ \
            \ Executor: SELF-PROVING, the base case of the attribution rule (owner ruling, \
            \ 2026-09-21). The executor IS the account being created, so its ownership cannot be \
            \ read from a table -- there is no row yet. It does not need to be. The <guard> the \
            \ account will be governed by travels in the same call, and \
            \ DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT enforces it through U|G::UEV_Any -- an \
            \ enforce-ONE over [guard, (create-capability-guard (GOV))] -- FIRST, before the glyph \
            \ and format checks. Same proof UEV_StandardAccOwn performs on an existing account, same \
            \ key; the guard is supplied in the call because at creation there is nowhere else it \
            \ could come from. The second list element is the governance door genesis uses to \
            \ make the first account. \
            \ \
            \ That the UEV_Any runs FIRST is not incidental -- it is what makes the proof a proof \
            \ rather than a check some other refusal could shadow -- and it is pinned by \
            \ <<DALOS-G4b>>, which pairs a held guard (format refusal) against an unheld one \
            \ (guard refusal). \
            \ (patron/executor canon 2.2; route named here because check 7 requires it to be, and \
            \ found it missing at 01_TS01-A's own turn, 2026-09-22.)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeployStandardAccount executor guard stoa public)
                (format "Succesfuly deployed Standard Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool)
        @doc "ADMIN: switch STOA collection on Ouronet ACCOUNT CREATION on/off, INDEPENDENTLY \
            \ of the global STOA switch (DALOS|A_IgnisToggle native=true). OFF — the default — \
            \ keeps onboarding free while global STOA collection is ON. Admin op, so this \
            \ entrypoint is itself IGNIS+STOA exempt."
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleAccountCreationStoa GASLESS-PATRON executor toggle)
                (if toggle
                    "Account-Creation STOA Collection succesfully turned ON"
                    "Account-Creation STOA Collection succesfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool)
        @doc "Toggles Ouronet Gas Collection \
        \ <native> true is STOA Collection for Specific Usage Actions \
        \ <native> false is IGNIS Collection for Client Functions"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGasCollection GASLESS-PATRON executor native toggle)
                (if native
                    (if toggle
                        "STOA Collection succesfully turned ON"
                        "STOA Collection succesfully turned OFF"
                    )
                    (if toggle
                        "IGNIS Collection succesfully turned ON"
                        "IGNIS Collection succesfully turned OFF"
                    )
                )
            )
        )
    )
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal)
        @doc "Sets OUROBOROS Price in $. Used in Compresion and Sublimation"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetIgnisSourcePrice GASLESS-PATRON executor price)
                (format "Succesfuly set IGNIS price to {}" [price])
            )
        )
    )
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool)
        @doc "Sets Automatic fueling of Collected STOA for the Increase of the <StoaLiquindex>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetAutoFueling GASLESS-PATRON executor toggle)
                (if toggle
                    "LiquidStaking Autofueling successfully turned ON"
                    "LiquidStaking Autofueling successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string)
        @doc "Updates Public Key; To be used only as failsafe by the Admin"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_UpdatePublicKey GASLESS-PATRON executor new-public)
                (format "Public Key for Account {} successfully updated!" [sa])
            )
        )
    )
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal)
        @doc "Updates specific Usage Price in STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_UpdateUsagePrice GASLESS-PATRON executor action new-price)
                (format "Price for Action {} successfully updated with {}" [action new-price])
            )
        )
    )
    ;;  [BRD_Administrator]
    (defun BRD|A_Live (executor:string entity-id:string)
        @doc "Sets <pending-branding> for an <entity-id> to <live-branding>, reseting <pending-branding> data \
            \ Resetting <pending-branding> data does not reset its last 3 keys \
            \ Can only be done by Branding Administrator"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_Live GASLESS-PATRON executor entity-id)
            )
        )
    )
    (defun BRD|A_SetFlag (executor:string entity-id:string flag:integer)
        @doc "Forcibly (in administrator mode) sets a Branding Flag for <entity-id> \
            \ <0> Flag = Golden Flag        Premium Flag reserved for Demiourgos Entity IDs \
            \ <1> Flag = Blue Flag          Premium Flag for Entity IDs (non-Demiourgos); \
            \                               Premium Flags are paid live branded Entity-IDs that are not labeled as problematic \
            \                               Paid live branded Entity IDs can still be flaged Red by the Branding Administrator \
            \ <2> Flag = Green Flag         Standard Flag for Entity IDs (non-Demiourgos) that have their Branding set to Live \
            \ <3> Flag = Gray Flag          Default Flag for newly-issued Entity-IDs (non-Demiourgos) that dont have their Branding Live yet \
            \ <4> Flag = Red Flag           Problem Flag for Entity IDs, marking potential dangerous or scam Entity IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_SetFlag GASLESS-PATRON executor entity-id flag)
            )
        )
    )
    ;;  [DPTF_Administrator]
    (defun DPTF|A_UpdateTreasuryDispoParameters (executor:string type:integer tdp:decimal tds:decimal)
        @doc "Updates Treasury Dispo Parameters, that dictate how much OURO Debt the Treasury can incurr \
            \ Type can only be 0 1 2 3 \
            \ Type 0 = No Treasury Dispo \
            \ Type 1 = Maximum Dispo equal to Total Supply \
            \ Type 2 = Promile Based Dispo; A <tdp> value of 320.0 means up to 32% of Total Supply can be overspent\
            \ Type 3 = Absolute Value Dispo in Thousands; A <tds> value of 250.0 means up to 250 Thousands can be overspent"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_UpdateTreasury GASLESS-PATRON executor type tdp tds)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebt (executor:string)
        @doc "Wipes all Treasury Debt, increasing OURO supply by the Debt Amount, \
            \ and setting Treasury Dispo Parameters to neutral (no overspend capability)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebt GASLESS-PATRON executor)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebtPartial (executor:string debt-to-be-wiped:decimal)
        @doc "Wipes all partialy the Treasury Debt, increasing OURO supply by the <debt-to-be-wiped> amount \
        \ Treasury Dispo Parameters are left as they are, this function simply wipe a part of the Treasury Debt through mint."
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebtPartial GASLESS-PATRON executor debt-to-be-wiped)
            )
        )
    )
    (defun DPTF|A_DeployAccount (patron:string executor:string executee:string id:string)
        @doc "Administrative variant of DPTF|C_DeployAccount (TS01-C1) - deploys a DPTF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPTF|C_DeployAccount instead. \
            \ ONLY THE ADMIN may deploy for someone else (owner, 2026-09-21); the absence of an \
            \ ownership check on <account> is the entire reason this door exists, and \
            \ P|ADMINISTRATIVE-SUMMONER is what confines it. \
            \ Wraps XB_DeployAccount -- the core was reclassified out of the C_ band, since it \
            \ builds no cumulator and was called from inside its own module. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin keyset, \
            \ composed as P|ADMINISTRATIVE-SUMMONER, which names no account; <executor> is the ACTOR \
            \ among its holders and is proven HERE by CAP_EnforceAccountOwnership, because the core \
            \ this forwards to is an XB_ outside the canon and proves nothing about any caller. \
            \ \
            \ <account> became <executee>: it is the account the deployment is BESTOWED UPON, and \
            \ this variant exists PRECISELY so that no ownership check runs on it. It satisfies the \
            \ executee test exactly -- acted upon, needing no signature -- and calling it the \
            \ executor would have named the beneficiary as the actor on the one door in the system \
            \ built to let somebody else act for them. \
            \ \
            \ THIS WRAPPER KEEPS ITS PATRON. The rule that a Talos A_ has none is a statement about \
            \ GASLESS ops -- the blessed path supplying GASLESS-PATRON -- not about admin ops. This \
            \ one ends in XE_CollectIgnis on a real patron, so it has all three."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership executor)
                (ref-DPTF::XBv_DeployAccount id executee)
                (ref-IGNIS::XE_CollectIgnis patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPTF|C_DeployAccount's price
                    (ref-DPTF::URCi_DeployAccount executee)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully! (admin)" [id sa])
            )
        )
    )
    ;;
    ;;  [DPOF_Administrator]
    (defun DPOF|A_DeployAccount (patron:string executor:string executee:string id:string)
        @doc "Administrative variant of DPOF|C_DeployAccount (TS01-C1) - deploys a DPOF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPOF|C_DeployAccount instead. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin keyset, \
            \ composed as P|ADMINISTRATIVE-SUMMONER, which names no account; <executor> is the ACTOR \
            \ among its holders and is proven HERE by CAP_EnforceAccountOwnership, because the core \
            \ this forwards to is an XB_ outside the canon and proves nothing about any caller. \
            \ \
            \ <account> became <executee>: it is the account the deployment is BESTOWED UPON, and \
            \ this variant exists PRECISELY so that no ownership check runs on it. It satisfies the \
            \ executee test exactly -- acted upon, needing no signature -- and calling it the \
            \ executor would have named the beneficiary as the actor on the one door in the system \
            \ built to let somebody else act for them. \
            \ \
            \ THIS WRAPPER KEEPS ITS PATRON. The rule that a Talos A_ has none is a statement about \
            \ GASLESS ops -- the blessed path supplying GASLESS-PATRON -- not about admin ops. This \
            \ one ends in XE_CollectIgnis on a real patron, so it has all three."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership executor)
                (ref-DPOF::XBv_DeployAccount id executee)
                (ref-IGNIS::XE_CollectIgnis patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPOF|C_DeployAccount's price
                    (ref-DPOF::URCi_DeployAccount executee)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {} (admin)" [id sa])
            )
        )
    )
    ;;  [ATS_Administrator]
    (defun ATS|AA_RemoveSecondary (patron:string executor:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant, queries <accounts-with-ats-data> via <DPTF-DPOF-ATS|UR_FilterKeysForInfo>"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::AA_RemoveSecondary patron executor ats reward-token accounts-with-ats-data)
                )
            )
        )
    )
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative Variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance, with no upper bound on the resulting KickStart \
            \ index (still subject to the shared 0.1 floor) - for legitimate ratios \
            \ above the owner-facing ATS|C_KickStart's 100.0 ceiling."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                ;;A_ on the blessed path: the collection runs EXACTLY as any C_'s does -- it is
                ;;simply served by GASLESS-PATRON, the one account IGNIS::XE_CollectIgnis exempts. The
                ;;path is preserved, not skipped; that is what makes an A_ gasless.
                (ref-IGNIS::XE_CollectIgnis GASLESS-PATRON
                    (ref-ATSU::A_KickStart GASLESS-PATRON executor ats rt-amounts rbt-request-amount)
                )
            )
        )
    )
    ;;  [LIQUID_Administrator]
    (defun LIQUID|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string)
        @doc "Migrates Stoa Liquid Staking STOA Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                )
                (ref-LIQUID::A_MigrateLiquidFunds GASLESS-PATRON executor migration-target-stoa-account)
            )
        )
    )
    ;;  [OUROBOROS_Administrator]
    (defun ORBR|A_Fuel (executor:string)
        @doc "Uses up all collected Native STOA on the Ouroboros Account, wraps it, and fuels the Stoa Liquid Index \
            \ Transaction fee must be paid for by the Ouronet Gas Station, so that all available balance may be used. \
            \ Is Part of all the Functions that collect native STOA as fee, \
            \ boosting the STOA Liquid Index, from 40% of the collected STOA \
            \ As Stand-Alone Function, can only be used by the Admin. \
            \ In normal condition, there is no need for using it on itself, as all collected STOA is automatically used up \
            \ by implementing this function at the end of those funtions that collect the STOA. \
            \ Dalos-Patron is the only gass"
        ;;GATE FIX (P3.3 sweep): this was (with-capability (SECURE)), and SECURE in this module
        ;;is (defcap SECURE () true) -- a C1 trivial cap. So the function's own @doc above ("As
        ;;Stand-Alone Function, can only be used by the Admin") was not enforced by anything:
        ;;ANY signer could call it and force the STOA fuelling at a moment of their choosing.
        ;;Every other |A_ entrypoint in this module already gates on P|ADMINISTRATIVE-SUMMONER
        ;;(P|TS + GOV|TS01-A_ADMIN); this one was the single outlier. The only live caller,
        ;;REPL/Stage_01/[6.3]_SWP.repl:2443, already signs with a Demiurgoi key, so no legitimate
        ;;caller loses access.
        ;;
        ;;SECURE is still ACQUIRED rather than replaced: XI_DirectFuelSTOA require-capability's it,
        ;;so swapping the two caps outright breaks the call (it did -- the suite caught it). The
        ;;admin cap gates, SECURE grants. Same shape as XB_DynamicFuelSTOA, the automatic path,
        ;;which gates on P|UEV_IMC and then grants SECURE inside it.
        ;;
        ;;Pinned by REPL/modules/CONFORMANCE.repl <<CONF-05>>; the class is linted by
        ;;_conformance.py [admin-gate-terminal], which was written FROM this defect and verified
        ;;against it by reverting the fix and watching the rule fire.
        ;;ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). Proven HERE rather than
        ;;forwarded, and that is forced: ORBR::C_Fuel is registered EXECUTORLESS because its
        ;;actor is ORBR|SC_NAME, a module constant. So there is nothing downstream to carry an
        ;;executor to, and without a local proof this parameter would be decorative -- which the
        ;;canon rates worse than absent.
        ;;
        ;;It earns its place on THIS function specifically. CONF-05 found ORBR|A_Fuel gated only
        ;;by a self-granting SECURE, and the value an attacker got was not theft but TIMING --
        ;;the ability to force the index move at a moment of their choosing. An operation whose
        ;;abuse is about WHEN it ran is exactly one where WHO ran it is worth recording.
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (with-capability (SECURE)
                (XI_DirectFuelSTOA)
            )
        )
    )
    ;;  [SWP_Administrator]
    (defun SWP|A_UpdatePrincipal (executor:string principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
        \ least 2 would remain defined, and <principal> isn't a 'major' principal \
        \ — #65eL). A principal is a token that must exist once in every W or P \
        \ Swpiar, on the first position. Also, the S Pools, must have at least \
        \ one Token dtied directly to a principal Token. SWPT's storage is \
        \ principal-agnostic (#21H), so removal of a minor principal is safe — it \
        \ only affects future pool-issuance principal-anchoring validation, never \
        \ existing routing. A major principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice) can never be removed \
        \ this way; retiring one requires redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool). SWP|A_RotatePrincipal remains available as \
        \ an atomic, count-preserving alternative for minor principals — it never \
        \ touches the floor or cap, but is equally blocked from rotating a major \
        \ principal away."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdatePrincipal GASLESS-PATRON executor principal add-or-remove)
            )
        )
    )
    (defun SWP|A_RotatePrincipal (executor:string old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one step, without \
        \ touching the 2-minimum floor or 7-maximum cap. Safe with respect to \
        \ SWPT's routing graph (#21H fix): SWPT's storage is principal-agnostic, \
        \ so this never orphans anything there — the only effect is on future \
        \ pool-issuance principal-anchoring validation. Rejects rotating a \
        \ principal into itself, rejects <new> already being a principal, and \
        \ rejects <old> being a 'major' principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice, #65eL) — majors are \
        \ fixed, retirable only by redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool)."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_RotatePrincipal GASLESS-PATRON executor old new)
            )
        )
    )
    (defun SWP|A_UpdateLimit (executor:string limit:decimal spawn:bool)
        @doc "Updates either the <spawn-limit> or <inactive-limit> for the SWP Module \
        \ The <spawn-limit> is the minimum number in STOA that a pool must be created with, in order to be opened for swap \
        \ The <inactive-limit> is the minimum number in STOA as total pool liquidity value, that trigger autonomic disable of the swap mechanism"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLimit GASLESS-PATRON executor limit spawn)
            )
        )
    )
    (defun SWP|A_UpdateLiquidBoost (executor:string new-boost-variable:bool)
        @doc "Updates Liquid Boost switch. When set to true, every swap is set to pump the Index for Stoa Liquid Staking"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLiquidBoost GASLESS-PATRON executor new-boost-variable)
            )
        )
    )
    (defun SWP|A_DefinePrimordialPool (executor:string primordial-pool:string)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_DefinePrimordialPool GASLESS-PATRON executor primordial-pool)
            )
        )
    )
    (defun SWP|A_ToggleAsymetricLiquidityAddition (executor:string toggle:bool)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_ToggleAsymetricLiquidityAddition GASLESS-PATRON executor toggle)
            )
        )
    )

)

;; --- tables for 01_TS01-A.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_ClientOneV2
    @doc "Exposes Ouronets Stage One First Batch of Client Functions \
        \ Modules: DALOS, DPTF and DPOF are included in the First Batch"

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
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool))
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard))
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool))
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string))
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string))
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string))
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string))
    ;;
    ;;
    (defun DPTF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPTF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    (defun DPTF|C_Issue:list (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPTF|C_RotateOwnership (patron:string executor:string executee:string id:string))
    (defun DPTF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun DPTF|C_TogglePause (patron:string executor:string id:string toggle:bool))
    (defun DPTF|C_ToggleReservation (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPTF|C_ToggleFee (patron:string executor:string id:string toggle:bool))
    (defun DPTF|C_SetMinMove (patron:string executor:string id:string min-move-value:decimal))
    (defun DPTF|C_SetFee (patron:string executor:string id:string fee:decimal))
    (defun DPTF|C_SetFeeTarget (patron:string executor:string id:string target:string))
    (defun DPTF|C_DonateFees (patron:string executor:string id:string))
    (defun DPTF|C_ResetFeeTarget (patron:string executor:string id:string))
    (defun DPTF|C_ToggleFeeLock (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPTF|C_DeployAccount (patron:string executor:string id:string))
    (defun DPTF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleMintRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPTF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun DPTF|C_ClearDispo (patron:string executor:string))
    (defun DPTF|C_ClearDispoForeign (patron:string executor:string executee:string))
    (defun DPTF|C_Burn (patron:string executor:string id:string amount:decimal))
    (defun DPTF|C_Mint (patron:string executor:string id:string amount:decimal origin:bool))
    (defun DPTF|C_WipeSlim (patron:string executor:string executee:string id:string amtbw:decimal))
    (defun DPTF|C_Wipe (patron:string executor:string executee:string id:string))
        ;;
    (defun DPTF|C_Transmute (patron:string executor:string id:string transmute-amount:decimal))
    (defun DPTF|C_Transfer (patron:string executor:string executee:string id:string transfer-amount:decimal method:bool))
    (defun DPTF|C_MultiTransfer (patron:string executor:string executee:string id-lst:[string] transfer-amount-lst:[decimal] method:bool))
    (defun DPTF|C_BulkTransfer (patron:string executor:string executee-lst:[string] id:string transfer-amount-lst:[decimal]))
    (defun DPTF|C_MultiBulkTransfer (patron:string executor:string executee-array:[[string]] id-lst:[string] transfer-amount-array:[[decimal]]))
    ;;
    ;;
    (defun DPOF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPOF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    (defun DPOF|C_Issue:list (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPOF|C_RotateOwnership (patron:string executor:string executee:string id:string))
    (defun DPOF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun DPOF|C_TogglePause (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPOF|C_DeployAccount (patron:string executor:string id:string))
    (defun DPOF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPOF|C_MoveCreateRole (patron:string executor:string executee:string id:string))
    (defun DPOF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun DPOF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun DPOF|C_Burn (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun DPOF|C_Mint (patron:string executor:string id:string amount:decimal meta-data-chain:[object]))
    (defun DPOF|C_WipeSlim (patron:string executor:string executee:string id:string nonce:integer amount:decimal))
    (defun DPOF|CC_WipeHeavy (patron:string executor:string executee:string id:string))
    (defun DPOF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun DPOF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun DPOF|C_Transmit (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool))
    (defun DPOF|C_Transfer (patron:string executor:string executee:string id:string nonces:[integer] method:bool))    
    (defun DPOF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
    )

)
;;
(module TS01-C1 GOV
    @doc "TALOS Stage 1 Client Functiones Part 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientOneV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C1                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C1))
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
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ELITE:module{OuronetPolicyV2} ELITE)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ELITE::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [DALOS_Client]
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        @doc "Controls Smart Ouronet Account properties via boolean triggers"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_ControlSmartAccount patron executor payable-as-smart-contract payable-by-smart-contract payable-by-method)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_ControlSmartAccount executor))
                (format "Smart Ouronet Account {} controlled succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Smart Ouronet Account, taxing for STOA. CORRECTED 2026-09-22: this @doc said \"Standard\", a copy-paste from its twin. \
            \ \
            \ Executor: SELF-PROVING, the base case of the attribution rule (owner ruling, \
            \ 2026-09-21). The executor IS the account being created, so its ownership cannot be \
            \ read from a table -- there is no row yet, and there is no earlier call in which it \
            \ could have been recorded. It does not need to be. The <guard> the account will be \
            \ governed by travels in this same call, and DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT \
            \ enforces it through U|G::UEV_Any -- an enforce-ONE over \
            \ [guard, (create-capability-guard (GOV))] -- FIRST, before the glyph and format \
            \ checks. Same proof UEV_SmartAccOwn performs on an existing account, same key. The \
            \ second list element is the governance door genesis uses to make the very first \
            \ account, when not even a guard-holder exists yet. \
            \ \
            \ That the UEV_Any runs FIRST is what makes it a proof rather than a check some other \
            \ refusal could shadow, and <<DALOS-G4b>> pins exactly that by pairing a held guard \
            \ (format refusal) against an unheld one (guard refusal). \
            \ (patron/executor canon 2.2; route named at 02_TS01-C1's own turn, 2026-09-22 -- \
            \ fifth and sixth time check 7 has caught a cascade-added executor whose \
            \ justification was never written down.)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeploySmartAccount executor guard stoa sovereign public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::XE_CollectStoa executor (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Smart Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA. \
            \ \
            \ Executor: SELF-PROVING, the base case of the attribution rule (owner ruling, \
            \ 2026-09-21). The executor IS the account being created, so its ownership cannot be \
            \ read from a table -- there is no row yet, and there is no earlier call in which it \
            \ could have been recorded. It does not need to be. The <guard> the account will be \
            \ governed by travels in this same call, and DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT \
            \ enforces it through U|G::UEV_Any -- an enforce-ONE over \
            \ [guard, (create-capability-guard (GOV))] -- FIRST, before the glyph and format \
            \ checks. Same proof UEV_StandardAccOwn performs on an existing account, same key. The \
            \ second list element is the governance door genesis uses to make the very first \
            \ account, when not even a guard-holder exists yet. \
            \ \
            \ That the UEV_Any runs FIRST is what makes it a proof rather than a check some other \
            \ refusal could shadow, and <<DALOS-G4b>> pins exactly that by pairing a held guard \
            \ (format refusal) against an unheld one (guard refusal). \
            \ (patron/executor canon 2.2; route named at 02_TS01-C1's own turn, 2026-09-22 -- \
            \ fifth and sixth time check 7 has caught a cascade-added executor whose \
            \ justification was never written down.)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeployStandardAccount executor guard stoa public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::XE_CollectStoa executor (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Standard Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard)
        @doc "Rotates the governor of a Smart Ouronet Account \
        \ The Governor acts as a governing entity for the Smart Ouronet Account allowing fine control of its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGovernor patron executor governor)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateGovernor executor))
                (format "Ouronet Account {} Governor-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool)
        @doc "Rotates the guard of an Ouronet Safe. Boolean <safe> also enforces the <new-guard>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGuard patron executor new-guard safe)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateGuard executor))
                (format "Ouronet Account {} Primary-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string)
        @doc "Rotates the STOA Account attached to an Ouronet Account. \
        \ The attached STOA Account is the account that makes STOA Payments for specific Ouronet Actions"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateStoa patron executor stoa)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateStoa executor))
                (format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string)
        @doc "Rotates the Sovereign of a Smart Ouronet Account \
        \ The Sovereign of a Smart Ouronet Account acts as its owner, allowing dominion over its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateSovereign patron executor new-sovereign)
                (ref-IGNIS::XE_CollectIgnis patron (ref-IGNIS::DALOS|URCi_RotateSovereign executor))
                (format "Smart Ouronet Account {} Sovereign rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string)
        @doc "Manualy Updates the Demiourgos Elite Account for one Ouronet Account in case of emergency. \
        \ Can be used without account ownership by anyone. \
        \ \
        \ EXECUTORLESS BY DESIGN (patron/executor canon 2.2, 2026-09-22), and the line above is \
        \ the reason. Verified rather than taken on trust: ELITE::XE_UpdateEliteSingle enforces \
        \ NOTHING on the named account -- only P|UEV_IMC and P|ELITE|CALLER, both module-caller \
        \ gates. The op recomputes DERIVED elite data from state already on chain, is idempotent, \
        \ and is deliberately permissionless so anyone can repair a stale row. \
        \ \
        \ So the accounts here are SUBJECTS, not actors, and the only authenticated account in \
        \ the call is <patron>, who pays. Renaming a subject to `executor` would have \
        \ manufactured attribution out of a parameter nobody checks -- which the canon rates \
        \ WORSE than having none, because the returned message would then name whoever the \
        \ caller typed. Read this function's output as \"this account was refreshed\", never as \
        \ \"this account refreshed it\"."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateEliteSingle ea-id account)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)
                )
                (format "Elite Account Data for {} updated succesfully!" [account])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string)
        @doc "Manualy Updates the Demiourgos Elite Account for two Ouronet Accounts in case of emergency. \
        \ Can be used without account ownership by anyone. \
        \ \
        \ EXECUTORLESS BY DESIGN (patron/executor canon 2.2, 2026-09-22), and the line above is \
        \ the reason. Verified rather than taken on trust: ELITE::XE_UpdateEliteSingle enforces \
        \ NOTHING on the named account -- only P|UEV_IMC and P|ELITE|CALLER, both module-caller \
        \ gates. The op recomputes DERIVED elite data from state already on chain, is idempotent, \
        \ and is deliberately permissionless so anyone can repair a stale row. \
        \ \
        \ So the accounts here are SUBJECTS, not actors, and the only authenticated account in \
        \ the call is <patron>, who pays. Renaming a subject to `executor` would have \
        \ manufactured attribution out of a parameter nobody checks -- which the canon rates \
        \ WORSE than having none, because the returned message would then name whoever the \
        \ caller typed. Read this function's output as \"this account was refreshed\", never as \
        \ \"this account refreshed it\"."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateElite ea-id sender receiver)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)
                )
                (format "Elite Account Data for {} and {} updated succesfully!" [sender receiver])
            )
        )
    )
    ;;  [DPTF_Client]
    (defun DPTF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPTF Token <entity-id> costing 100 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|DPTF::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
                (format "Pending Branding for DPTF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPTF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPTF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPTF::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPTF|C_Issue:list (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Issues a new DPTF Token in Bulk, can also be used to issue a single DPTF \
        \ Outputs a string list with the issed DPTF IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Issue patron executor name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPTF|C_RotateOwnership (patron:string executor:string executee:string id:string)
        @doc "Rotates DPTF ID Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_RotateOwnership patron executor executee id)
                )
                (format "ID {} Ownership succesfully set to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        @doc "Controls the properties of a DPTF Token \
            \ <can-change-owner> <can-upgrade> <can-add-special-role> <can-freeze> <can-wipe> <can-pause>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Control patron executor id cu cco casr cf cw cp)
                )
                (format "Succesfully controlled Properties of {}" [id])
            )
        )
    )
    (defun DPTF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Pause for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_TogglePause patron executor id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleReservation (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Reservations for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleReservation patron executor id toggle)
                )
                (if toggle
                    (format "Reservations succesfully opened for {}" [id])
                    (format "Reservations succesfully closed for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ToggleFee (patron:string executor:string id:string toggle:bool)
        @doc "Toggles Fee collection for a DPTF Token. When a DPTF Token is setup with a transfer fee, \
            \ it will come in effect only when the toggle is on(true)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFee patron executor id toggle)
                )
                (if toggle
                    (format "Fee Collection activated succesfully for {}" [id])
                    (format "Fee Collection deactivated succesfully for {}" [id])
                )
            )
        )
    )
    (defun DPTF|C_SetMinMove (patron:string executor:string id:string min-move-value:decimal)
        @doc "Sets the minimum amount needed to transfer a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetMinMove patron executor id min-move-value)
                )
                (format "MinMove Value succesfully set for {} to {}" [id min-move-value])
            )
        )
    )
    (defun DPTF|C_SetFee (patron:string executor:string id:string fee:decimal)
        @doc "Sets a transfer fee for the DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFee patron executor id fee)
                )
                (format "Fee Promille succesfully set to {} Promille for {}" [fee id])
            )
        )
    )
    (defun DPTF|C_SetFeeTarget (patron:string executor:string id:string target:string)
        @doc "Sets the Fee Collection Target for a DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id target)
                )
                (format "Fee Target succesfully set for {} to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_DonateFees (patron:string executor:string id:string)
        @doc "Sets the Fee Collection target to the DALOS|SC_NAME \
        \ When DPTF Fees collect here, the will be earned by Ouronet Custodians"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id (ref-DALOS::GOV|DALOS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ResetFeeTarget (patron:string executor:string id:string)
        @doc "Sets the Fee Collection target to the OUROBOROS|SC_NAME \
        \ Fees can then be collected by <DPTF|C_WithdrawFees>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_SetFeeTarget patron executor id (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ToggleFeeLock (patron:string executor:string id:string toggle:bool)
        @doc "Toggles DPTF Fee Settings Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_ToggleFeeLock patron executor id toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (if toggle
                    (format "Fee Settings succesfully locked for {}" [id])
                    (format "Fee Settings succesfully unlocked  for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_DeployAccount (patron:string executor:string id:string)
        @doc "Deploys a DPTF Account. Self-service activation only - the caller must own \
            \ <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure account \
            \ setup (a smart account governed by another module) must use the admin variant \
            \ DPTF|A_DeployAccount in TS01-A instead. \
            \ The core it wraps is now XB_DeployAccount, not C_DeployAccount: that function \
            \ builds no cumulator and was being called from inside its own module, which is \
            \ what a C_ may never be. The BILLING is unchanged and stays here -- a user who \
            \ activates their own token account PAYS, even though the account is normally \
            \ created automatically and they need not do this at all. \
            \ \
            \ A RENAME AND A MOVE, not an addition (patron/executor canon 2.2, 2026-09-22): \
            \ <account> was ALREADY the executor. The line above enforces \
            \ CAP_EnforceAccountOwnership on it directly, which is the whole difference between this \
            \ function and its admin twin. \
            \ \
            \ CONTRAST WITH DPTF|A_DeployAccount IN 01_TS01-A, WHICH IS THE POINT. Same parameter \
            \ name, same position, OPPOSITE role -- there <account> is unchecked by design and \
            \ became the EXECUTEE; here it is checked and became the EXECUTOR. Nothing about the \
            \ name or the shape distinguishes them. The only thing that does is whether ownership \
            \ is enforced on it, which is the test the canon actually asks and the reason a blind \
            \ rename across both would have got one of them exactly backwards."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership executor)
                (ref-DPTF::XBv_DeployAccount id executor)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::URCi_DeployAccount executor)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])
            )
        )
    )
    (defun DPTF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Freezing of a DPTF Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFreezeAccount patron executor executee id toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <burn-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleBurnRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleMintRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <mint-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleMintRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <fee-exemption-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleFeeExemptionRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <transfer-role> for a DPTF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_ToggleTransferRole patron executor executee id toggle)
                )
                (if toggle
                    (format "Transfer Role succesfuly added for {} to {}" [id sa])
                    (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ClearDispo (patron:string executor:string)
        @doc "SELF clear: <executor> settles their OWN OURO dispo by leveraging their existing \
        \ Elite-Auryn. This is the variant every real user wants, and the reason it exists as \
        \ its own name is that the core takes three roles while the self case has only two -- \
        \ making the caller write the same account twice would be an invitation to write two \
        \ different ones by accident. Ownership of <executor> is enforced in TFT's \
        \ DPTF|C>CLEAR-DISPO. See DPTF|C_ClearDispoForeign for the delegated variant."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_ClearDispo patron executor executor)
                )
            )
        )
    )
    (defun DPTF|C_ClearDispoForeign (patron:string executor:string executee:string)
        @doc "FOREIGN clear: <executor> settles <executee>'s OURO dispo. BOTH ownerships are \
        \ enforced in TFT's DPTF|C>CLEAR-DISPO, because clearing a dispo force-spends the \
        \ executee's Elite-Auryn at 2.5x the debt -- so this is not a favour the executor can \
        \ do unilaterally, it is one the executee must sign for. \
        \ \
        \ The use case is narrow and the owner named it: the executee is stranded without \
        \ connectivity and has handed their key to someone who can execute for them. Anyone \
        \ able to run this could equally run DPTF|C_ClearDispo as the executee, so it adds no \
        \ authority -- what it adds is an AUDIT TRAIL naming who actually executed."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_ClearDispo patron executor executee)
                )
            )
        )
    )
    (defun DPTF|C_Burn (patron:string executor:string id:string amount:decimal)
        @doc "Burns a DPTF Token from an executor"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Burn patron executor id amount)
                )
                (format "Succesfully burned {} {} on Account {}" [amount id sa])
            )
        )
    )
    (defun DPTF|C_Mint (patron:string executor:string id:string amount:decimal origin:bool)
        @doc "Mints a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Mint patron executor id amount origin)
                )
                (if origin
                    (format "Succesfully premined {} {} on Account {}" [amount id sa])
                    (format "Succesfully minted {} {} on Account {}" [amount id sa])
                )
            )
        )
    )
    (defun DPTF|C_WipeSlim (patron:string executor:string executee:string id:string amtbw:decimal)
        @doc "Similar to <DPTF|C_Wipe>, but doesnt wipe the whole existing amount"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_WipeSlim patron executor executee id amtbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
                (format "Succesfully wiped {} {} from account {}" [amtbw id sa])
            )
        )
    )
    (defun DPTF|C_Wipe (patron:string executor:string executee:string id:string)
        @doc "Wipes a DPTF Token from a given account in its entirety \
        \ Only works for positive existing amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPTF::C_Wipe patron executor executee id)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
                (format "Succesfully wiped all {} from account {}" [id sa])
            )
        )
    )
    ;;
    (defun DPTF|C_Transmute (patron:string executor:string id:string transmute-amount:decimal)
        @doc "Transmutes a DPTF Token. Transmuting Uses the whole amount as it if were Primary Fee \
        \ without adding to the Primary Fee Counter. \
        \ Thus it can either be collected to the Fee Target Collector \
        \ or to increase Autostake Indices, if the Id is part of any Autostake Pools \
        \ (and these have the neccesary setting set up in the  required manner) \
        \ Only works for DPTFs that have been setup up with transfer fees. \
        \ One of 3 Variants is automatically chosen for transmutation \
        \   Simple  >> For DPTFs that are not Elite Auryn Class \
        \   Elite   >> For Elite Auryn Class DPTFs that require Elite Account Update"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_Transmute patron executor id transmute-amount)
                )
            )
        )
    )
    (defun DPTF|C_Transfer (patron:string executor:string executee:string id:string transfer-amount:decimal method:bool)
        @doc "Transfers a DPTF Token from <executor> to <executee>, using the <transfer-amount> and <method> \
        \ It autonomously choose between the 6 Transfer Variants spread over 3 Classes. \
        \ \
        \   Class 1 >> 1 IGNIS Cost \
        \           [CX_Class1Transfer]             Transfers a DPTF with no transfer Fees (also for VTT amounts < 10.0) \
        \           [CX_Class1TransferUnity]        Transfers UNITY with no transfer Fees (amount < 10.0) \
        \   Class 2 >> 2 IGNIS Cost \
        \           [CX_Class2Transfer]             Transfer a DPTF with a transfer Fee \
        \           [CX_Class2TransferUnity]        Transfers Unity with transfer Fee \
        \           [CX_Class2TransferElite]        Transfers EA Class DPTFs with no Fees \
        \   Class 3 >> 3 IGNIS Cost \
        \           [CX_Class3TransferElite]        Transfers EA Class DPTFs with transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id executor executee transfer-amount))
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_Transfer patron executor executee id transfer-amount method)
                )
                (if (= receiver-amount transfer-amount)
                    (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                    (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                )
            )
        )
    )
    (defun DPTF|C_MultiTransfer (patron:string executor:string executee:string id-lst:[string] transfer-amount-lst:[decimal] method:bool)
        @doc "Transfers Multiple DPTF Tokens from <executor> to <executee>, each token having its own amount specified \
        \ Receiver, as it is only one, can also be a Smart Ouronet Account \
        \ 150k Gas can support between 10 and 20 Transfers, depending on DPTF Token (Simple, Complex, Elite, Unity)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiTransfer patron executor executee id-lst transfer-amount-lst method)
                )
                (format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])
            )
        )
    )
    (defun DPTF|C_BulkTransfer (patron:string executor:string executee-lst:[string] id:string transfer-amount-lst:[decimal])
        @doc "Transfers a DPTF in Bulk, from <executor> to the multiple receivers in <executee-lst>, each with its own amount \
        \ Because <receivers> cannot be Smart Ouronet Accounts, no <method> parameter is needed \
        \ When the Token <id> is set up with a Transfer Fee, and its receiver is on the receiver list, \
        \ it is not exempted from the transfer fee, as is normally the case \
        \ \
        \ It autonomously choose between the 6 Transfer Variants spread over 4 Classes. \
        \ \
        \   Class 0 >> VTT (Volumetric Transfer Tax) Class: (1xL IGNIS or Variable IGNIS Cost for UNITY)\
        \           [CX_Class0BulkTransfer]         Bulk Transfers DPTFs with VTT \
        \           [CX_Class0BulkTransferUnity]    Bulk Transfers UNITY, which also has VTT \
        \   Class 1 >> 1xL IGNIS Cost \
        \           [CX_Class1BulkTransfer]         Bulk Transfers DPTFs with no transfer Fees \
        \   Class 2 >> 2xL IGNIS Cost \
        \           [CX_Class2BulkTransfer]         Bulk Transfers DPTFs with transfer Fees \
        \           [CX_Class2BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with no Transfer Fees \
        \   Class 3 >> 3xL IGNIS Cost \
        \           [CX_Class3BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with Transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiBulkTransfer patron executor [executee-lst] [id] [transfer-amount-lst])
                )
                (format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length executee-lst)])
            )
        )
    )
    (defun DPTF|C_MultiBulkTransfer (patron:string executor:string executee-array:[[string]] id-lst:[string] transfer-amount-array:[[decimal]])
        @doc "Executes Multiple Bulk Transfers in a single Function"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-TFT::C_MultiBulkTransfer patron executor executee-array id-lst transfer-amount-array)
                )
                (format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id-lst) sa-s (length executee-array)])
            )
        )
    )
    ;;  [DPOF_Client]
    (defun DPOF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPOF Token <entity-id> costing 150 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|DPOF::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
                (format "Pending Branding for DPOF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPOF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPOF::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPOF|C_Issue:list (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPOF::C_Issue patron executor name ticker decimals can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPOF|C_RotateOwnership (patron:string executor:string executee:string id:string)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_RotateOwnership patron executor executee id)
                )
            )
        )
    )
    (defun DPOF|C_Control (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        @doc "Similar to its DPTF Variant, has an extra boolean trigger for <can-transfer-nft-create-role>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Control patron executor id cu cco casr ctocr cf cw cp sg)
                )
                (format "Succesfully controlled DPOF {} Boolean Properties" [id])
            )
        )
    )
    (defun DPOF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_TogglePause patron executor id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    ;;
    (defun DPOF|C_DeployAccount (patron:string executor:string id:string)
        @doc "Similar to its DPTF Variant. Self-service activation only - the caller must \
            \ own <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure \
            \ account setup (a smart account governed by another module) must use the \
            \ admin variant DPOF|A_DeployAccount in TS01-A instead. \
            \ \
            \ A RENAME AND A MOVE, not an addition (patron/executor canon 2.2, 2026-09-22): \
            \ <account> was ALREADY the executor. The line above enforces \
            \ CAP_EnforceAccountOwnership on it directly, which is the whole difference between this \
            \ function and its admin twin. \
            \ \
            \ CONTRAST WITH DPOF|A_DeployAccount IN 01_TS01-A, WHICH IS THE POINT. Same parameter \
            \ name, same position, OPPOSITE role -- there <account> is unchecked by design and \
            \ became the EXECUTEE; here it is checked and became the EXECUTOR. Nothing about the \
            \ name or the shape distinguishes them. The only thing that does is whether ownership \
            \ is enforced on it, which is the test the canon actually asks and the reason a blind \
            \ rename across both would have got one of them exactly backwards."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership executor)
                (ref-DPOF::XBv_DeployAccount id executor)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::URCi_DeployAccount executor)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])
            )
        )
    )
    (defun DPOF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleFreezeAccount patron executor executee id toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPOF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <add-quantity-role> for a DPOF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleAddQuantityRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPOF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles <burn-role> for a DPOF Token <id> on a specific <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleBurnRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPOF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves <create-role> for a DPOF Token <id> to <executee> \
        \ Only a single account may have this role"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_MoveCreateRole patron executor executee id)
                )
            )
        )
    )
    (defun DPOF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_ToggleTransferRole patron executor executee id toggle)
                )
            )
        )
    )
    ;;
    (defun DPOF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_AddQuantity patron executor id nonce amount)
                )
                (format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])
            )
        )
    )
    (defun DPOF|C_Burn (patron:string executor:string id:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Burn patron executor id nonce amount)
                )
                (format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])
            )
        )
    )
    (defun DPOF|C_Mint (patron:string executor:string id:string amount:decimal meta-data-chain:[object])
        @doc "Mints a DPOF Token, creating it and adding quantity to it \
        \ Outputs the nonce of the created DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (with-capability (P|TS)
                            (ref-DPOF::C_Mint patron executor id amount meta-data-chain)
                        )
                    )
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully minted {} {} on Account {}, on the new Nonce {}" [amount id sa (at 0 (at "output" ico))])
            )
        )
    )
    (defun DPOF|C_WipeSlim (patron:string executor:string executee:string id:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <executee> by <amount> \
            \ Amount may be lower or equal to the nonce amount. \
            \ Requires <id> has <segmentation> set to true"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipeSlim patron executor executee id nonce amount)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <executee> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::CC_WipeHeavy patron executor executee id)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <executee>, presented via an <removable-nonces-obj> object \
        \ \
        \ The object must be pre-read (dirty read) \
        \ \
        \ Example to retrieve the <removable-nonces-obj> \
        \ <(URHC_WipePure executee id)> ; to get the whole object \
        \ <(UCv_TakePureWipe (URHC_WipePure executee id) 165)> ; to get only the first 165 units \
        \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipePure patron executor executee id removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_WipeClean patron executor executee id nonces)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id executee)
            )
        )
    )
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of <account>'s \
            \ <id> nonces. The UI dirty-reads the plan and fires one such tx per slice, all in \
            \ parallel; slices are disjoint, order-independent and retryable (replay REVERTS). \
            \ Elite re-rank runs per slice — it recomputes from live state, so whichever slice \
            \ lands last leaves the correct final rank under any arrival order."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::Cp_WipeSlice id account removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    ;;
    (defun DPOF|C_Transmit (patron:string executor:string executee:string id:string nonces:[integer] amounts:[decimal] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by a specific <amount> \
            \ This debits the <executor> nonces by <amount> and creates new nonces on executee of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Transmit patron executor executee id nonces amounts method)
                )
                (ref-ELITE::XE_UpdateElite id executor executee)
                (format "Succesfuly Transmited DPOF {} Nonces {} with Amounts {} from Sender {} to Receiver {}"
                    [id nonces amounts ss sr]
                )
            )
        )
    )
    (defun DPOF|C_Transfer (patron:string executor:string executee:string id:string nonces:[integer] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <executor> to <executee> by changing their Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_Transfer patron executor executee id nonces method)
                )
                (ref-ELITE::XE_UpdateElite id executor executee)
                (format "Succesfuly Transmited DPOF {} Nonces {} from Sender {} to Receiver {}"
                    [id nonces ss sr]
                )
            )
        )
    )
    (defun DPOF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] method:bool)
        @doc "Bulk whole-nonce DPOF transfer — one executor, many standard-account receivers (TalosStageOne_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (l:integer (length executee-lst))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPOF::C_BulkTransfer patron executor executee-lst id nonces-array method)
                )
                (map
                    (lambda (idx:integer)
                        (ref-ELITE::XE_UpdateElite id executor (at idx executee-lst))
                    )
                    (enumerate 0 (- l 1))
                )
                (format "Succesfully bulk-transferred DPOF {} from {} to {} receivers"
                    [id sa-s l]
                )
            )
        )
    )

)

;; --- tables for 02_TS01-C1.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

