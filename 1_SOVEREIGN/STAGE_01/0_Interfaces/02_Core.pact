;; Stage 01 Core Interface Registry — SHARED + HISTORICAL only.
;; Module-owned latest interfaces live in each 2_Core/*.pact file (deploy with module).
;; Do not add current single-implementer interfaces here — add to the module file instead.
;;
(interface OuronetPolicyV1
    @doc "Interface exposing OuronetPolicyV1 Functions, which are needed for intermodule communication \
        \ Each Module must have these Functions for these Purposes"
    ;;
    (defschema P|S
        policy:guard
    )
    (defschema P|MS
        m-policies:[guard]
    )
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
    (defun UEV_IMC ()
        @doc "Defines the Intermodule Guards"
    )
)
(interface IgnisCollectorV1
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
    ;;  [UEV]
    ;;
    (defun UEV_TwentyFourPrecision (amount:decimal))
    (defun UEV_Patron (patron:string))
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
    ;;
    ;;  [C]
    ;;
    (defun C_TransferDalosFuel (sender:string receiver:string amount:decimal))
    (defun C_Collect  (patron:string input-output-cumulator:object{OutputCumulator}))
    (defun KDA|C_Collect (sender:string amount:decimal))
    (defun KDA|C_CollectWT (sender:string amount:decimal trigger:bool))
    ;;
)
(interface IgnisCollectorV2
    @doc "Additive IGNIS surface — opt-in per consumer; does not replace IgnisCollectorV1."
    (defun KDA|C_CollectWTEx (payer:string discount-account:string amount:decimal trigger:bool))
)
(interface OuronetInfoV1
    @doc "Holds Information Schemas"
    ;;
    ;;  SCHEMAS
    ;;
    (defschema ClientInfo
        pre-text:[string]
        post-text:[string]
        ignis:object{ClientIgnisCosts}
        kadena:object{ClientKadenaCosts}
        output:list
    )
    (defschema ClientIgnisCosts
        ignis-discount:decimal
        ignis-full:decimal
        ignis-need:decimal
        ignis-text:string
    )
    (defschema ClientKadenaCosts
        kadena-discount:decimal
        kadena-full:decimal
        kadena-need:decimal
        kadena-split:[decimal]
        kadena-targets:[string]
        kadena-text:string
    )
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV1.OutputCumulator}))
    (defun OI|UC_ShortAccount:string (account:string))
    (defun OI|UC_ConvertPrice:string (input-price:decimal))
    (defun OI|UC_FormatIndex:string (index:decimal))
    (defun OI|UC_FormatTokenAmount:string (amount:decimal))
    ;;
    ;;
    ;;  [UR] Functions
    ;;
    (defun OI|UR_KadenaTargets:[string] ())
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun OI|UDC_ClientInfo:object{ClientInfo} (a:[string] b:[string] c:object{ClientIgnisCosts} d:object{ClientKadenaCosts} e:list))
    (defun OI|UDC_ClientIgnisCosts:object{ClientIgnisCosts} (a:decimal b:decimal c:decimal d:string))
    (defun OI|UDC_ClientKadenaCosts:object{ClientKadenaCosts} (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string))
        ;;
    (defun OI|UDC_FullKadenaCosts:object{ClientKadenaCosts} (kfp:decimal))
    (defun OI|UDC_KadenaCosts:object{ClientKadenaCosts} (patron:string kfp:decimal))
    (defun OI|UDC_NoKadenaCosts:object{ClientKadenaCosts} ())
    (defun OI|UDC_DynamicKadenaCost:object{ClientKadenaCosts} (patron:string kfp:decimal))
        ;;
    (defun OI|UDC_IgnisCosts:object{ClientIgnisCosts} (patron:string ifp:decimal))
    (defun OI|UDC_NoIgnisCosts:object{ClientIgnisCosts} ())
    (defun OI|UDC_DynamicIgnisCost:object{ClientIgnisCosts} (patron:string ifp:decimal))
)
(interface BrandingV1
    @doc "Interface Exposing the Branding Functions needed to create the Branding Functionality \
        \ Entities are DPTF DPMF DPSF DPNF ATSPairs SWPairs \
        \ Should Future entities be added, they too can be branded via this module \
        \ UR(Utility-Read), URC(Utility-Read-Compute), UDC(Utility-Data-Composition) \
        \ are NOT sorted alphabetically"
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
    ;;
    (defun UDC_BrandingLogo:object{Schema} (input:object{Schema} logo:string))
    (defun UDC_BrandingDescription:object{Schema} (input:object{Schema} description:string))
    (defun UDC_BrandingWebsite:object{Schema} (input:object{Schema} website:string))
    (defun UDC_BrandingSocial:object{Schema} (input:object{Schema} social:[object{SocialSchema}]))
    (defun UDC_BrandingFlag:object{Schema} (input:object{Schema} flag:integer))
    (defun UDC_BrandingPremium:object{Schema} (input:object{Schema} premium:time))
    ;;
    (defun A_Live (entity-id:string))
    (defun A_SetFlag (entity-id:string flag:integer))
    ;;
    (defun XE_Issue (entity-id:string))
    (defun XE_UpdatePendingBranding (entity-id:string logo:string description:string website:string social:[object{SocialSchema}]))
    (defun XE_UpgradeBranding:decimal (entity-id:string entity-owner-account:string months:integer))
)
(interface BrandingUsagePrimaryV1
    @doc "Exposes Branding Functions for True-Fungibles (T), Orto-Fungibles (M), ATS-Pairs (A) and SWP-Pairs (S)"
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer))
)
(interface BrandingUsageTertiaryV1
    @doc "Exposes Branding Functions for Semi-Fungibles (S) and Non-Fungibles (N)"
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string son:bool logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string entity-id:string son:bool  months:integer))
)
(interface DpofUdcV1
    @doc "Exposes DPOF UDC Constructors"
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
)
(interface AutostakeV1
    @doc "Brings not only Improved Autostake Architecture but also added Functionality: \
        \ \
        \ \
        \ 1]Autostake Pools can be configured with a Royalty on deposit. This remains in the ATS|SC-NAME \
        \ and can be withdrawn by Pool Owner \
        \ \
        \ 2]Third Recovery Method added, the Direct Recovery, where the RBT is realeased immediatly. \
        \ This option has its own Fee system. This fee ALWAYS increases Pool Index \
        \ \
        \ 3]Adds a new Mode, <Hibernation> Mode, \
        \ Using this mode, the RT is coiled directly into the Hibernating Counterpart of the Output RBT \
        \ Allows Participation into Autostake Pools to generate directly locked-tokens. \
        \ \
        \ 4]At most, the Autostake Pools can be configured with 7 Reward Tokens (RTs) \
        \ \
        \ 5]Position 0, instead of unlimited uncoil Positions, has an upper limitd number of positions \
        \ This is due to increase gas costs as the used positions increase in number \
        \ This number will be increased in the future to reflect the Max Gas per TX available.\
        \ \
        \ 6]Updated code such that Autostake Pools use Orto Fungibles instead of Meta Fungibles. \
        \ \
        \ \
        \ 7]PERMISSION ROLES \
        \ for DPTF and DPMF (now DPOF) that used to exist in this module, are moved \
        \ in their respective Modules. Instead a new mechanics is used in the Autostake Code, \
        \ such that these functions dont need to be here any more. \
        \ This was related to how the Autostake ATS|SC_NAME needed Token Permissions to function \
        \ Now the ATS|SC_NAME is granted the required permissions to function in a different manner \
        \ \
        \ \
        \ For DPTFs \
        \ ATS|SC_NAME hat innate <role-burn> <role-mint> <role-fee-exemption> for any DPTF and cannot be frozen \
        \ This is to allow its unrestricted operation with any DPTFs \
        \ \
        \ For DPOFs \
        \ The DPOF in relation to an ATS-Pair is its Hot-RBT \
        \ While the DPMF had a single <role-nft-create> and this had to be given to the ATS-Pair in  \
        \ order for it to function as the ATS-Pair Hot RBT, now a different functionality is used: \
        \ The DPOF can have up to 2 distinct <role-oft-create> Roles, first by its owner as innate, \
        \ the 2nd one given to a distinct designated account. Now the ATS-Pair must be the owner of the DPOF \
        \ designated as the Hot-RBT, solving the issue of this permission. \
        \ Also, while a DPOF is owned by the ATS|SC_NAME, its second <role-oft-create> if given to another account \
        \ isnt taken into consideration, making the ATS|SC_NAME the only account allowed to mint its Hot-RBT DPOF \
        \ \
        \ Also, similar as for DPTFs, the ATS|SC_NAME has innate <role-burn> <role-mint> for any DPOF \
        \ completly solving the Permission Issues for its functioning, which allows discarding of complex Logic \
        \ that was used prior to DPOFs \
        \ \
        \ \
        \ \
        \ Also brings table optimisations for use with <select>"
    ;;
    ;;  SCHEMAS
    ;;
    (defschema ATS|RewardTokenSchemaV2
        token:string
        nfr:bool
        resident:decimal
        unbonding:decimal
        royalty:decimal
    )
    (defschema ATS|Hot
        mint-time:time
    )
    (defschema CoilData
        primal-input-amount:decimal
        first-input-amount:decimal
        royalty-fee:decimal
        last-input-amount:decimal
        hibernation-fee:decimal
        rbt-amount:decimal
        rbt-id:string
    )
    ;;
    ;;  [UC]
    ;;
    (defun URU_UpgradeAtspairToV2 (atspairs:[string]))
    (defun UC_AtspairAccount:string (atspair:string account:string))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [UR]
    ;;
    ;;  [0    ATS|Pairs:{ATS|PropertiesSchema}
    (defun UR_OwnerKonto:string (atspair:string))
    (defun UR_CanUpgrade:bool (atspair:string))
    (defun UR_CanChangeOwner:bool (atspair:string))
    (defun UR_Syphoning:bool (atspair:string))
    (defun UR_Hibernate:bool (atspair:string))
    (defun UR_IndexName:string (atspair:string))
    (defun UR_IndexDecimals:integer (atspair:string))
    (defun UR_Royalty:decimal (atspair:string))
    (defun UR_Syphon:decimal (atspair:string))
        ;;
    (defun UR_PeakHibernatePromile:decimal (atspair:string))
    (defun UR_HibernateDecay:decimal (atspair:string))
        ;;
    (defun UR_Lock:bool (atspair:string))
    (defun UR_Unlocks:integer (atspair:string))
        ;;
    (defun UR_RewardTokens:[object{ATS|RewardTokenSchemaV2}] (atspair:string))
    (defun UR_RewardTokenList:[string] (atspair:string))
    (defun UR_RewardTokenNFR:[bool] (atspair:string))
    (defun UR_RewardTokenRUR:[decimal] (atspair:string rur:integer))
    (defun UR_SingleRewardTokenNFR:bool (atspair:string rt:string))
    (defun UR_SingleRewardTokenRUR:decimal (atspair:string rt:string rur:integer))
        ;;
    (defun UR_ColdRewardBearingToken:string (atspair:string))
    (defun UR_ColdNativeFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryPositions:integer (atspair:string))
    (defun UR_ColdRecoveryFeeThresholds:[decimal] (atspair:string))
    (defun UR_ColdRecoveryFeeTable:[[decimal]] (atspair:string))
    (defun UR_ColdRecoveryFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryDuration:[integer] (atspair:string))
    (defun UR_EliteMode:bool (atspair:string))
        ;;
    (defun UR_HotRewardBearingToken:string (atspair:string))
    (defun UR_HotRecoveryStartingFeePromile:decimal (atspair:string))
    (defun UR_HotRecoveryDecayPeriod:integer (atspair:string))
    (defun UR_HotRecoveryFeeRedirection:bool (atspair:string))
        ;;
    (defun UR_DirectRecoveryFee:decimal (atspair:string))
        ;;
    (defun UR_ToggleColdRecovery:bool (atspair:string))
    (defun UR_ToggleHotRecovery:bool (atspair:string))
    (defun UR_ToggleDirectRecovery:bool (atspair:string))
    ;;
    (defun UR_RtPrecisions:[integer] (atspair:string))
    (defun UR_P0:[object{UtilityAtsV1.Awo}] (atspair:string account:string))
    (defun UR_P1-7:object{UtilityAtsV1.Awo} (atspair:string account:string position:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_Index (atspair:string))
    (defun URC_ResidentSum:decimal (atspair:string))
    (defun URC_PairRBTSupply:decimal (atspair:string))
    (defun URC_RBT:decimal (atspair:string rt:string rt-amount:decimal))
    (defun URC_RTSplitAmounts:[decimal] (atspair:string rbt-amount:decimal))
    (defun URC_MaxSyphon:[decimal] (atspair:string))
        ;;
    (defun URC_RewardTokenPosition:integer (atspair:string reward-token:string))
        ;;
    (defun URC_AccountUnbondingBalance:decimal (atspair:string account:string reward-token:string))
    (defun URC_CullValue:[decimal] (atspair:string input:object{UtilityAtsV1.Awo}))
    (defun URC_WhichPosition:integer (atspair:string c-rbt-amount:decimal account:string))
    (defun URC_ColdRecoveryFee (atspair:string c-rbt-amount:decimal input-position:integer))
    (defun URC_CullColdRecoveryTime:time (atspair:string account:string))
    (defun URC_IzPresentHotRBT:bool (atspair:string))
        ;;
    (defun URC_RewardBearingTokenAmounts:object{CoilData} (ats:string rt:string amount:decimal))
    (defun URC_RewardBearingTokenAmountsWithHibernation:object{CoilData} (ats:string rt:string amount:decimal hibernation-dayz:integer))
    ;;
    ;;  [URD]
    ;;
    (defun URD_HeldAutostakePairs:[string] (account:string))
    (defun URD_ExistingAutostakePairs:[string] (ats:string))
    (defun URD_OwnedAutostakePairs:[string] (account:string))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_id (atspair:string))
    (defun UEV_CanUpgradeON (atspair:string))
    (defun UEV_CanChangeOwnerON (atspair:string))
    (defun UEV_RewardTokenExistance (atspair:string reward-token:string existance:bool))
    (defun UEV_RewardBearingTokenExistance (atspair:string reward-bearing-token:string existance:bool cold-or-hot:bool))
    (defun UEV_ParameterLockState (atspair:string state:bool))
    (defun UEV_EliteState (atspair:string state:bool))
    (defun UEV_ColdRecoveryState (atspair:string state:bool))
    (defun UEV_HotRecoveryState (atspair:string state:bool))
    (defun UEV_DirectRecoveryState (atspair:string state:bool))
    (defun UEV_IssueData (atspair:string index-decimals:integer reward-token:string reward-bearing-token:string))
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_MakeUnstakeObject:object{UtilityAtsV1.Awo} (atspair:string tm:time))
    (defun UDC_MakeZeroUnstakeObject:object{UtilityAtsV1.Awo} (atspair:string))
    (defun UDC_MakeNegativeUnstakeObject:object{UtilityAtsV1.Awo} (atspair:string))
    (defun UDC_ComposePrimaryRewardToken:object{ATS|RewardTokenSchemaV2} (token:string nfr:bool))
    (defun UDC_RT:object{ATS|RewardTokenSchemaV2} (a:string b:bool c:decimal d:decimal e:decimal))
    (defun UDC_CoilData:object{CoilData} (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal g:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    ;;
    ;;  [C]
    ;;
    (defun C_HOT-RBT|UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}]))
    (defun C_HOT-RBT|UpgradeBranding (patron:string entity-id:string months:integer))
    (defun C_HOT-RBT|Repurpose:object{IgnisCollectorV1.OutputCumulator} (hot-rbt:string nonce:integer repurpose-to:string))
        ;;
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (
            patron:string
            account:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator} (atspair:string new-owner:string))
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator} (atspair:string can-change-owner:bool syphoning:bool hibernate:bool))
    (defun C_UpdateRoyalty:object{IgnisCollectorV1.OutputCumulator} (atspair:string royalty:decimal))
    (defun C_UpdateSyphon:object{IgnisCollectorV1.OutputCumulator} (atspair:string syphon:decimal))
    (defun C_SetHibernationFees:object{IgnisCollectorV1.OutputCumulator} (atspair:string peak:decimal decay:decimal))
        ;;
    (defun C_ToggleParameterLock:object{IgnisCollectorV1.OutputCumulator} (patron:string atspair:string toggle:bool))
    (defun C_AddSecondary:object{IgnisCollectorV1.OutputCumulator} (atspair:string reward-token:string rt-nfr:bool))
        ;;
    (defun C_ControlColdRecoveryFees:object{IgnisCollectorV1.OutputCumulator} (atspair:string c-nfr:bool c-fr:bool))
    (defun C_SetColdRecoveryFees:object{IgnisCollectorV1.OutputCumulator} (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun C_SetColdRecoveryDuration:object{IgnisCollectorV1.OutputCumulator} (atspair:string soft-or-hard:bool base:integer growth:integer))
    (defun C_ToggleElite:object{IgnisCollectorV1.OutputCumulator} (atspair:string toggle:bool))
    (defun C_SwitchColdRecovery:object{IgnisCollectorV1.OutputCumulator} (atspair:string toggle:bool))
        ;;
    (defun C_AddHotRBT:object{IgnisCollectorV1.OutputCumulator} (atspair:string hot-rbt:string))
    (defun C_ControlHotRecoveryFee:object{IgnisCollectorV1.OutputCumulator} (atspair:string h-fr:bool))
    (defun C_SetHotRecoveryFees:object{IgnisCollectorV1.OutputCumulator} (atspair:string promile:decimal decay:integer))
    (defun C_SwitchHotRecovery:object{IgnisCollectorV1.OutputCumulator} (atspair:string toggle:bool))
        ;;
    (defun C_SetDirectRecoveryFee:object{IgnisCollectorV1.OutputCumulator} (atspair:string promile:decimal))
    (defun C_SwitchDirectRecovery:object{IgnisCollectorV1.OutputCumulator} (atspair:string toggle:bool))
    ;;
    ;;  [X]
    ;;
    (defun XE_RemoveSecondary (atspair:string reward-token:string))
    (defun XE_UpdateRUR (atspair:string reward-token:string rur:integer direction:bool amount:decimal))
    (defun XE_SpawnAutostakeAccount (atspair:string account:string))
    (defun XE_ReshapeUnstakeAccount (atspair:string account:string rp:integer))
    (defun XE_UpP0 (atspair:string account:string obj:[object{UtilityAtsV1.Awo}]))
    (defun XE_UpP1 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP2 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP3 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP4 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP5 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP6 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    (defun XE_UpP7 (atspair:string account:string obj:object{UtilityAtsV1.Awo}))
    ;;
)
(interface SwapperV2
    @doc "Exposes Swapper Related Functions, except those related to adding and swapping liquidity \
        \ V2: Added URC_AllPoolTokens - returns all unique tokens across all pools"
    ;;
    (defschema PoolTokens
        token-id:string
        token-supply:decimal
    )
    (defschema FeeSplit
        target:string
        value:integer
    )
    (defun SWP|Info ())
    ;;
    ;;
    (defun UC_ExtractTokens:[string] (input:[object{PoolTokens}]))
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{PoolTokens}]))
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{FeeSplit}]))
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{FeeSplit}]))
    ;;
    (defun UR_Asymetric:bool ())
    (defun UR_Principals:[string] ())
    (defun UR_PrimordialPool:string ())
    (defun UR_LiquidBoost:bool ())
    (defun UR_SpawnLimit:decimal ())
    (defun UR_InactiveLimit:decimal ())
        ;;
    (defun UR_OwnerKonto:string (swpair:string))
    (defun UR_CanChangeOwner:bool (swpair:string))
    (defun UR_CanAdd:bool (swpair:string))
    (defun UR_CanSwap:bool (swpair:string))
    (defun UR_GenesisWeigths:[decimal] (swpair:string))
    (defun UR_Weigths:[decimal] (swpair:string))
    (defun UR_GenesisRatio:[object{PoolTokens}] (swpair:string))
    (defun UR_PoolTokenObject:[object{PoolTokens}] (swpair:string))
    (defun UR_TokenLP:string (swpair:string))
    (defun UR_FeeLP:decimal (swpair:string))
    (defun UR_FeeSP:decimal (swpair:string))
    (defun UR_FeeSPT:[object{FeeSplit}] (swpair:string))
    (defun UR_FeeLock:bool (swpair:string))
    (defun UR_FeeUnlocks:integer (swpair:string))
    (defun UR_Amplifier:decimal (swpair:string))
    (defun UR_Primality:bool (swpair:string))
    (defun UR_IzFrozenLP:bool (swpair:string))
    (defun UR_IzSleepingLP:bool (swpair:string))
    (defun UR_Pools:[string] (pool-category:string))
        ;;
    (defun UR_PoolTokens:[string] (swpair:string))
    (defun UR_GetLpSwpair:string (lp-id:string))
    (defun UR_PoolTokenSupplies:[decimal] (swpair:string))
    (defun UR_PoolGenesisSupplies:[decimal] (swpair:string))
    (defun UR_PoolTokenPosition:integer (swpair:string id:string))
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string))
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string))
    (defun UR_SpecialFeeTargets:[string] (swpair:string))
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string))
    ;;
    (defun URC_LpCapacity:decimal (swpair:string))
    (defun URC_CheckID:bool (swpair:string))
    (defun URC_PoolTotalFee:decimal (swpair:string))
    (defun URC_LiquidityFee:decimal (swpair:string))
    (defun URC_AllPoolTokens:[string] ())
    (defun URC_Swpairs:[string] ())
    (defun URC_LpComposer:[string] (pool-tokens:[object{PoolTokens}] weights:[decimal] amp:decimal))
    ;;
    (defun URD_OwnedSwapPairs:[string] (account:string))
    ;;
    (defun UEV_FeeSplit (input:object{FeeSplit}))
    (defun UEV_id (swpair:string))
    (defun UEV_CanChangeOwnerON (swpair:string))
    (defun UEV_FeeLockState (swpair:string state:bool))
    (defun UEV_PoolFee (fee:decimal))
    (defun UEV_New (t-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckTwo (token-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckAgainstMass:bool (token-ids:[string] present-pools:[string]))
    (defun UEV_CheckAgainst:bool (token-ids:[string] pool-tokens:[string]))
    (defun UEV_FrozenLP (swpair:string state:bool))
    (defun UEV_SleepingLP (swpair:string state:bool))
    ;;
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun A_UpdateLimit (limit:decimal spawn:bool))
    (defun A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun A_DefinePrimordialPool (primordial-pool:string))
    (defun A_ToggleAsymetricLiquidityAddition (toggle:bool))
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-owner:string))
    (defun C_EnableFrozenLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun C_EnableSleepingLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-boolean:bool))
    (defun C_ModifyWeights:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-weights:[decimal]))
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool add-or-swap:bool))
    (defun C_ToggleFeeLock:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string toggle:bool))
    (defun C_UpdateAmplifier:object{IgnisCollectorV1.OutputCumulator} (swpair:string amp:decimal))
    (defun C_UpdateFee:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV1.OutputCumulator} (swpair:string targets:[object{FeeSplit}]))
    ;;
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal]))
    ;;
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal]))
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal))
    (defun XE_Issue:string (account:string pool-tokens:[object{PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool))
    ;;
)
(interface PythiaV1
    @doc "Frozen — initial PYTHIA surface (deploy/rename INFO only; no deactivate IGNIS toll INFO)."
    (defun GOV|CronotonKey ())
    ;;
    ;;
    (defun UC_DeployPrice:decimal ())
    (defun UC_RenamePrice:decimal ())
    (defun UC_IsStandardApollo:bool (apollo-account:string))
    (defun UC_FeeDiscountAnchor:string ())
    ;;
    (defun A_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun A_ActivateApiKey:string (apollo-account:string))
    (defun A_DeactivateApiKey:string (apollo-account:string))
    (defun A_UpdateDeployPrice:string (new-price:decimal))
    (defun A_UpdateRenamePrice:string (new-price:decimal))
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun C_DeactivateApiKey:string (owner-account:string apollo-account:string))
    (defun C_UpdateApiConsumerName:string
        ( owner-account:string
          apollo-account:string
          new-name:string ))
    ;;
    ;; [UR] PYTHIA|S|ApiKey — field accessors + DataOrNull (UR_AKY|Data is module-only)
    (defun UR_IsActivated:bool (apollo-account:string))
    (defun UR_Public:string (apollo-account:string))
    (defun UR_ConsumerLane:string (apollo-account:string))
    (defun UR_OwnerAccount:string (apollo-account:string))
    (defun UR_RegisteredAt:time (apollo-account:string))
    (defun UR_UpdatedAt:time (apollo-account:string))
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string))
    ;;
    ;; [URC]
    (defun URC_IsStandardApollo:bool (apollo-account:string))
    (defun URC_IsActivatedOrFalse:bool (apollo-account:string))
    (defun URC_ActivatedSet:[string] ())
    ;;
    ;; [URD] — directory scans for Pythia website
    (defun URD_ApiKeyCount:integer ())
    (defun URD_ApiKeyCountStr:string ())
    (defun URD_ListAllApiKeys:[object] ())
    (defun URD_ListActivatedApiKeys:[object] ())
    (defun URD_ListInactiveApiKeys:[object] ())
    ;;
    ;; [INFO] UI previews — deploy/rename: STOA via KDA|C_CollectWTEx in TS01-C4
    (defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|INFO_UpdateApiConsumerName:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
)
(interface PythiaV2
    @doc "PYTHIA V2 — adds UC_DeactivateIgnisFee + PYTHIA|INFO_DeactivateApiKey (1 IGNIS deactivate toll)."
    (defun GOV|CronotonKey ())
    ;;
    ;;
    (defun UC_DeployPrice:decimal ())
    (defun UC_RenamePrice:decimal ())
    (defun UC_DeactivateIgnisFee:decimal ())
    (defun UC_IsStandardApollo:bool (apollo-account:string))
    (defun UC_FeeDiscountAnchor:string ())
    ;;
    (defun A_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun A_ActivateApiKey:string (apollo-account:string))
    (defun A_DeactivateApiKey:string (apollo-account:string))
    (defun A_UpdateDeployPrice:string (new-price:decimal))
    (defun A_UpdateRenamePrice:string (new-price:decimal))
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        ( owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun C_DeactivateApiKey:string (owner-account:string apollo-account:string))
    (defun C_UpdateApiConsumerName:string
        ( owner-account:string
          apollo-account:string
          new-name:string ))
    ;;
    ;; [UR] PYTHIA|S|ApiKey — field accessors + DataOrNull (UR_AKY|Data is module-only)
    (defun UR_IsActivated:bool (apollo-account:string))
    (defun UR_Public:string (apollo-account:string))
    (defun UR_ConsumerLane:string (apollo-account:string))
    (defun UR_OwnerAccount:string (apollo-account:string))
    (defun UR_RegisteredAt:time (apollo-account:string))
    (defun UR_UpdatedAt:time (apollo-account:string))
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string))
    ;;
    ;; [URC]
    (defun URC_IsStandardApollo:bool (apollo-account:string))
    (defun URC_IsActivatedOrFalse:bool (apollo-account:string))
    (defun URC_ActivatedSet:[string] ())
    ;;
    ;; [URD] — directory scans for Pythia website
    (defun URD_ApiKeyCount:integer ())
    (defun URD_ApiKeyCountStr:string ())
    (defun URD_ListAllApiKeys:[object] ())
    (defun URD_ListActivatedApiKeys:[object] ())
    (defun URD_ListInactiveApiKeys:[object] ())
    ;;
    ;; [INFO] UI previews — deploy/rename: STOA via KDA|C_CollectWTEx; deactivate: IGNIS via C_Collect
    (defun PYTHIA|INFO_DeployApiKey:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|INFO_UpdateApiConsumerName:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
    (defun PYTHIA|INFO_DeactivateApiKey:object{OuronetInfoV1.ClientInfo}
        ( patron:string
          apollo-account:string ))
)
(interface PythiaLedgerV1
    @doc "Frozen — insert-only daily flush; caller passes day + flushed-at (pre-Khronoton)."
    ;;
    (defschema PYTHIA|S|PythMetrics
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythDaily
        day:integer
        flushed-at:time
        metrics:object{PYTHIA|S|PythMetrics}
    )
    (defschema PYTHIA|S|PythTotal
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
    ;;
    (defun A_Flush:string
        (
            day:integer
            flushed-at:time
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
    )
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URD_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
)
(interface PythiaLedgerV2BlockTime
    @doc "Frozen — never deployed. Block-time calendar day; single six-metric flush (superseded by batch PythiaLedgerV2 in 23_PYTHIA.pact)."
    ;;
    (defschema PYTHIA|S|PythMetrics
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythDaily
        day:integer
        flushed-at:time
        iz-sealed:bool
        metrics:object{PYTHIA|S|PythMetrics}
    )
    (defschema PYTHIA|S|PythTotal
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
    ;;
    (defun A_Flush:string
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
    )
    (defun UR_PythCurrentDay:integer ())
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URD_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
)
