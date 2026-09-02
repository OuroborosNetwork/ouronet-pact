;; Stage 01 Core Interface Registry — SHARED + HISTORICAL only.
;; Module-owned latest interfaces live in each 2_Core/*.pact file (deploy with module).
;; Do not add current single-implementer interfaces here — add to the module file instead.
;;
(interface OuronetPolicyV1
    @doc "Interface exposing OuronetPolicyV1 Functions, which are needed for intermodule communication \
        \ Each Module must have these Functions for these Purposes"

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
    ;;
    (defschema P|S
        policy:guard
    )
    (defschema P|MS
        m-policies:[guard]
    )
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions
    (defun P|UR:guard (policy-name:string)
        @doc "Reads a Policy from the local module Policy Table"
    )
    (defun P|UR_IMP:[guard] ()
        @doc "Reads the whole Intermodule Policy Guard Chain"
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        @doc "Adds a Policy in the local module Policy Table"
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Add a Policy in the local Policy Guard Chain"
    )
    (defun P|A_Define ()
        @doc "Defines in each module the policies that are needed for intermodule communication"
    )
    (defun P|UEV_IMC ()
        @doc "Defines the Intermodule Guards"
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
(interface IgnisCollectorV1

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
    ;;  SCHEMAS
    ;;
    (defschema PrimedCumulator
        primed-cumulator:object{CompressedCumulator}
    )
    (defschema CompressedCumulator
        ignis-prices:[decimal]
        interactors:[string]
    )
    (defschema OutputCumulator
        cumulator-chain:[object{ModularCumulator}]
        output:list
    )
    (defschema ModularCumulator
        ignis:decimal
        interactor:string
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
    (defun UDC_MakeIDP:string (ignis-discount:decimal))
    (defun UDC_ConstructOutputCumulator:object{OutputCumulator} (price:decimal active-account:string trigger:bool output-lst:list))
    (defun UDC_BrandingCumulator:object{OutputCumulator} (active-account:string multiplier:decimal))
    (defun UDC_SmallestCumulator:object{OutputCumulator} (active-account:string))
    (defun UDC_SmallCumulator:object{OutputCumulator} (active-account:string))
    (defun UDC_MediumCumulator:object{OutputCumulator} (active-account:string))
    (defun UDC_BigCumulator:object{OutputCumulator} (active-account:string))
    (defun UDC_BiggestCumulator:object{OutputCumulator} (active-account:string))
    (defun UDC_CustomCodeCumulator:object{OutputCumulator} ())
        ;;
    (defun UDC_MakeModularCumulator:object{ModularCumulator} (price:decimal active-account:string trigger:bool))
    (defun UDC_MakeOutputCumulator:object{OutputCumulator} (input-modular-cumulator-chain:[object{ModularCumulator}] output-lst:list))
    (defun UDC_ConcatenateOutputCumulators:object{OutputCumulator} (input-output-cumulator-chain:[object{OutputCumulator}] new-output-lst:list))
    (defun UDC_CompressOutputCumulator:object{CompressedCumulator} (input-output-cumulator:object{OutputCumulator}))
    (defun UDC_PrimeIgnisCumulator:object{PrimedCumulator} (patron:string input:object{CompressedCumulator}))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_Exception (account:string))
    (defun URC_ZeroEliteGAZ (sender:string receiver:string))
    (defun URC_ZeroGAZ:bool (id:string sender:string receiver:string))
    (defun URC_ZeroGAS:bool (id:string sender:string))
    (defun URC_IsVirtualGasZeroAbsolutely:bool (id:string))
    (defun URC_IsVirtualGasZero:bool ())
    (defun URC_IsNativeGasZero:bool ())
    ;;
    ;;  [DALOS-URCi] cost readers — single-source the tier choice for DALOS client ops.
    ;;  DALOS deploys below IGNIS so it hosts these here; Talos bills through them and the
    ;;  Z_Reads presentation derives its preview from the same source (kills tier-choice drift).
    (defun DALOS|URCi_ControlSmartAccount:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateGovernor:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateGuard:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateStoa:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateSovereign:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_UpdateEliteAccount:object{OutputCumulator} (patron:string))
    (defun DALOS|URCi_UpdateEliteAccountSquared:object{OutputCumulator} (patron:string))
    (defun DALOS|URCi_DeploySmartAccount:decimal ())
    (defun DALOS|URCi_DeployStandardAccount:decimal ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_TwentyFourPrecision (amount:decimal))
    (defun UEV_Patron (patron:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_TransferDalosFuel (sender:string receiver:string amount:decimal))
    (defun C_Collect  (patron:string input-output-cumulator:object{OutputCumulator}))
    (defun C_STOA|Collect (sender:string amount:decimal))
    (defun C_STOA|CollectWT (sender:string amount:decimal trigger:bool))
    (defun C_STOA|CollectWTEx (payer:string discount-account:string amount:decimal trigger:bool))

)
(interface OuronetInfoV1
    @doc "Holds Information Schemas"

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
    ;;  SCHEMAS
    ;;
    (defschema ClientInfo
        pre-text:[string]
        post-text:[string]
        ignis:object{ClientIgnisCosts}
        stoa:object{ClientStoaCosts}
        output:list
    )
    (defschema ClientIgnisCosts
        ignis-discount:decimal
        ignis-full:decimal
        ignis-need:decimal
        ignis-text:string
    )
    (defschema ClientStoaCosts
        stoa-discount:decimal
        stoa-full:decimal
        stoa-need:decimal
        stoa-split:[decimal]
        stoa-targets:[string]
        stoa-text:string
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
    ;;
    ;;  [UDC] Functions
    ;;
    (defun OI|UDC_ClientInfo:object{ClientInfo} (a:[string] b:[string] c:object{ClientIgnisCosts} d:object{ClientStoaCosts} e:list))
    (defun OI|UDC_ClientIgnisCosts:object{ClientIgnisCosts} (a:decimal b:decimal c:decimal d:string))
    (defun OI|UDC_ClientStoaCosts:object{ClientStoaCosts} (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string))
        ;;
    (defun OI|UDC_FullStoaCosts:object{ClientStoaCosts} (kfp:decimal))
    (defun OI|UDC_StoaCosts:object{ClientStoaCosts} (patron:string kfp:decimal))
    (defun OI|UDC_NoStoaCosts:object{ClientStoaCosts} ())
    (defun OI|UDC_DynamicStoaCost:object{ClientStoaCosts} (patron:string kfp:decimal))
        ;;
    (defun OI|UDC_IgnisCosts:object{ClientIgnisCosts} (patron:string ifp:decimal))
    (defun OI|UDC_NoIgnisCosts:object{ClientIgnisCosts} ())
    (defun OI|UDC_DynamicIgnisCost:object{ClientIgnisCosts} (patron:string ifp:decimal))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV1.OutputCumulator}))
    (defun OI|UC_ShortAccount:string (account:string))
    (defun OI|UC_ConvertPrice:string (input-price:decimal))
    (defun OI|UC_FormatIndex:string (index:decimal))
    (defun OI|UC_FormatTokenAmount:string (amount:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [UR] Functions
    ;;
    (defun OI|UR_StoaTargets:[string] ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
(interface BrandingV1
    @doc "Interface Exposing the Branding Functions needed to create the Branding Functionality \
        \ Entities are DPTF DPMF DPSF DPNF ATSPairs SWPairs \
        \ Should Future entities be added, they too can be branded via this module \
        \ UR(Utility-Read), URC(Utility-Read-Compute), UDC(Utility-Data-Composition) \
        \ are NOT sorted alphabetically"

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
    (defschema Schema
        logo:string
        description:string
        website:string
        social:[object{SocialSchema}]
        flag:integer
        genesis:time
        premium-until:time
    )
    (defschema SocialSchema
        social-media-name:string
        social-media-link:string
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
    (defun UDC_BrandingLogo:object{Schema} (input:object{Schema} logo:string))
    (defun UDC_BrandingDescription:object{Schema} (input:object{Schema} description:string))
    (defun UDC_BrandingWebsite:object{Schema} (input:object{Schema} website:string))
    (defun UDC_BrandingSocial:object{Schema} (input:object{Schema} social:[object{SocialSchema}]))
    (defun UDC_BrandingFlag:object{Schema} (input:object{Schema} flag:integer))
    (defun UDC_BrandingPremium:object{Schema} (input:object{Schema} premium:time))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_Branding:object{Schema} (id:string pending:bool))
    (defun UR_Logo:string (id:string pending:bool))
    (defun UR_Description:string (id:string pending:bool))
    (defun UR_Website:string (id:string pending:bool))
    (defun UR_Social:[object{SocialSchema}] (id:string pending:bool))
    (defun UR_Flag:integer (id:string pending:bool))
    (defun UR_Genesis:time (id:string pending:bool))
    (defun UR_PremiumUntil:time (id:string pending:bool))
    ;;
    (defun URC_MaxBluePayment (account:string))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    (defun XE_Issue (entity-id:string))
    (defun XE_UpdatePendingBranding (entity-id:string logo:string description:string website:string social:[object{SocialSchema}]))
    (defun XE_UpgradeBranding:decimal (entity-id:string entity-owner-account:string months:integer))
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Live (entity-id:string))
    (defun A_SetFlag (entity-id:string flag:integer))

)
(interface BrandingUsagePrimaryV1
    @doc "Exposes Branding Functions for True-Fungibles (T), Orto-Fungibles (M), ATS-Pairs (A) and SWP-Pairs (S)"

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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer))

)
(interface BrandingUsageTertiaryV1
    @doc "Exposes Branding Functions for Semi-Fungibles (S) and Non-Fungibles (N)"

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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string son:bool logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string entity-id:string son:bool  months:integer))

)
(interface DpofUdcV1
    @doc "Exposes DPOF UDC Constructors"

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
    ;;  SCHEMAS
    ;;
    (defschema DPOF|Properties
        id:string
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-add-special-role:bool
        can-transfer-oft-create-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        segmentation:bool
        ;;
        is-paused:bool
        nonces-used:integer
        nonces-excluded:integer
        ;;
        supply:decimal
        ;;
        reward-bearing-token:string
        vesting-link:string
        sleeping-link:string
        hibernation-link:string
        ;;
    )
    ;;Nonces cant be separated. A Ortofungible Nonce has one unique holder.
    (defschema DPOF|NonceElement
        holder:string                       ;;Stores the <OuronetAccount> holding the nonce - mutable
        id:string                           ;;ID of the Ortofungible - immutable.
        value:integer                       ;;Stores the Nonce value itself - immutable.
        supply:decimal                      ;;Nonce Supply - mutable
        meta-data-chain:[object]            ;;Stores Nonce Metadata - immutable
    )
    (defschema DPOF|VerumRoles
        a-frozen:[string]
        r-oft-add-quantity:[string]
        r-oft-burn:[string]
        r-oft-create:string
        r-transfer:[string]
    )
    (defschema DPOF|AccountRoles
        total-account-supply:decimal        ;; Holds the Total Account Supply for id
        frozen:bool                         ;; multiple
        role-oft-add-quantity:bool          ;; multiple
        role-oft-burn:bool                  ;; multiple
        role-oft-create:bool                ;; single
        role-transfer:bool                  ;; multiple
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema RemovableNonces
        @doc "Removable Nonces are Class 0 Nonces held by a given Account with greater than 0 supply \
        \ Given an <account>, a dpdc <id>, and a list of <nonces>, they can be filtered to Removable Nonces"
        r-nonces:[integer]
        r-amounts:[decimal]
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)