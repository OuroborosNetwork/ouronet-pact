;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EquityV2
    @doc "EquityV2 is the interface contract for the EQUITY shareholder/equity-collection \
        \ policy, declaring the signatures every implementer must provide. It specifies \
        \ compute helpers, read/cost-preview functions (tier supplies, share \
        \ package/per-million math, combine capacity, URCi_ cost readers), validators (share \
        \ package tier, share amounts, equity SF id, convert, morph), and the two user \
        \ entrypoints C_IssueShareholderCollection and C_MorphPackageShares. It defines no \
        \ tables or state, only the equity API surface."

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
    ;;
    ;;  [UC]
    ;;
    (defun UC_Name:[string] (collection-name:string))
    (defun UC_Description:[string] (collection-name:string))
    (defun UC_Convert:integer (id:string input-tier:integer input-tier-amount:integer output-tier:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_TierSupplies:[integer] (id:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer))
    (defun URC_SharesPerMillion:[integer] (id:string))
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer))
    (defun URC_CombineCapacity:integer (id:string))
    (defun URCi_MorphPackageShares:object{IgnisCollectorV2.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV2.OutputCumulator} ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_SharePackageTier (package-share-tier:integer))
    (defun UEV_ShareAmountsForMaking (id:string shares-amount:integer package-share-tier:integer))
    (defun UEV_EquitySemiFungibleID (id:string))
    (defun UEV_Convert (id:string input-tier:integer input-tier-amount:integer output-tier:integer))
    (defun UEV_Morph (input-nonce:integer output-nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_IssueShareholderCollection:object{IgnisCollectorV2.OutputCumulator}
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV2.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))

)
(module EQUITY GOV
    @doc "EQUITY implements OuronetPolicyV2 and EquityV2 to create and manage Shareholder \
        \ DPSF (SFT) collections representing company equity, where nonce 1 is the barebone \
        \ share and nonces 2-8 are packaged share tiers. Its main entrypoints are \
        \ C_IssueShareholderCollection (issues an Elite equity SFT collection via \
        \ DPDC-I/DPDC-C, populating 8 nonces with tiered royalties) and C_MorphPackageShares \
        \ (Make/Break/Convert between share tiers via SECURE-gated XI_ helpers over \
        \ DPDC-MNG/DPDC-T). It enforces packaging caps, tier/divisibility validators, owns \
        \ policy tables, acts as a remote DPDC governor, and returns IGNIS cost cumulators."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements EquityV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_EQUITY                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|EQUITY_ADMIN)))
    (defcap GOV|EQUITY_ADMIN ()                         (enforce-guard GOV|MD_EQUITY))
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
    (defcap P|EQUITY|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|EQUITY|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|EQUITY|REMOTE-GOV ()
        @doc "DPDC Remote Governor Capability"
        true
    )
    (defcap P|GOV-CALLER ()
        (compose-capability (P|EQUITY|CALLER))
        (compose-capability (P|EQUITY|REMOTE-GOV))
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
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
        (with-capability (GOV|EQUITY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|EQUITY_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|EQUITY|CALLER)))
            )
            (ref-P|DPDC::P|A_Add
                "EQUITY|RemoteDpdcGov"
                (create-capability-guard (P|EQUITY|REMOTE-GOV))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst P                                         ["0.1‰" "0.2‰" "0.5‰" "1‰" "2‰" "5‰" "1%"])
    (defconst S                                         [100 200 500 1000 2000 5000 10000])
    ;;ever be packaged into tradeable tier-units (nonces 2-8) at once; the remainder must stay as loose,
    ;;unpackaged barebone shares. See URC_CombineCapacity below, the sole consumer of this constant.
    (defconst PACKAGING_CAP_DIVISOR 2)
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
    (defcap EQUITY|C>MAKE (id:string shares-amount:integer package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareAmountsForMaking id shares-amount package-share-tier)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>BREAK (id:string package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_SharePackageTier package-share-tier)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>CONVERT (id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
        (compose-capability (P|GOV-CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_Name:[string] (collection-name:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (if (= idx 0)
                            (format "{} Share" [collection-name])
                            (format "{} {} Share Package" [collection-name (at (- idx 1) P)] )
                        )
                    )
                )
                []
                (enumerate 0 7 1)
            )
        )
    )
    (defun UC_Description:[string] (collection-name:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (if (= idx 0)
                            (format "An SFT representing 1 Share of {}" [collection-name])
                            (format "An SFT representing {} of all {} Shares" [(at (- idx 1) P) collection-name])
                        )
                    )
                )
                []
                (enumerate 0 7 1)
            )
        )
    )
    (defun UC_Convert:integer (id:string input-tier:integer input-tier-amount:integer output-tier:integer)
        (let
            (
                (spm:[integer] (URC_SharesPerMillion id))
            )
            (/
                (* (at (- input-tier 1) spm) input-tier-amount)
                (at (- output-tier 1) spm)
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_TierSupplies:[integer] (id:string)
        @doc "Total outstanding supply of each package tier (nonces 2-8, in tier-unit counts, not \
            \ share-equivalents), in tier order."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (ref-DPDC::UR_NonceSupply id true idx)
                    )
                )
                []
                (enumerate 2 8)
            )
        )
    )
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer)
        @doc "Converts a raw <shares-amount> into the equivalent whole number of <package-share-tier> \
            \ units. Assumes even divisibility -- UEV_ShareAmountsForMaking enforces that before this \
            \ result is trusted."
        (/ shares-amount (URC_SingleSharePerMillions id package-share-tier))
    )
    (defun URC_SharesPerMillion:[integer] (id:string)
        @doc "Computes Tier Shares; Example for 5 mil Company Shares it would output 5*[100 200 500 1000 2000 5000 10000]"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (tcs-in-millions:integer (/ (ref-DPDC::UR_NonceSupply id true 1) 1000000))
            )
            (map (* tcs-in-millions) S)
        )
    )
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer)
        @doc "Share-per-unit value for a single <package-share-tier> (1-7), scaled to this collection's \
            \ total share count. See URC_SharesPerMillion."
        (at (- package-share-tier 1) (URC_SharesPerMillion id))

    )
    (defun URC_CombineCapacity:integer (id:string)
        @doc "Remaining share-equivalent headroom that may still be packaged into tier-units (nonces \
            \ 2-8) before hitting the 1/PACKAGING_CAP_DIVISOR (50%) packaging cap on total shares \
            \ (nonce 1). DPDC Audit #29M."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (shares:integer (ref-DPDC::UR_NonceSupply id true 1))
                (half-shares:integer (/ shares PACKAGING_CAP_DIVISOR))
                (spm:[integer] (URC_SharesPerMillion id))
                (supplies:[integer] (UR_TierSupplies id))
                (supplies-as-shares:[integer] (zip (*) supplies spm))
                (shares-in-package-nonces:integer (fold (+) 0 supplies-as-shares))
            )
            (- half-shares shares-in-package-nonces)
        )
    )
    ;;
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV2.OutputCumulator} ()
        @doc "Cost preview for C_IssueShareholderCollection's IGNIS cumulator (the collection- \
            \ issue STOA price previews separately via DPDC-I::URCi_IssueCollectionStoa). Two legs, \
            \ ARG-INDEPENDENT: \
            \ ico1 = the digital-collection issue (URCi_IssueDigitalCollection son=true on the DPDC \
            \ SC, which owns every Equity collection — owner-account is C_IssueDigitalCollection's \
            \ 3rd arg = dpdc); \
            \ ico2 = the 8-nonce populate at the DISCOUNTED first-Elite-SFT price. \
            \ The discount is CODE-PROVEN to fire at exec time: XI_IssueDigitalCollection inits the \
            \ collection with nonces-used=0 and creates NO nonce, so the immediately-following \
            \ C_CreateNewNonces runs while nonces-used is still 0; the id is Elite (UC_EquityID forces \
            \ an 'E|' ticker and UDC_Makeid=concat[ticker '-' hash] so take-2 of the id is 'E|'); and \
            \ son=true. So URCi_RegisterCollectablesPrice's [ft='E|' & son & nu=0] branch applies the \
            \ /1000 discount: populate = smallest * 1,000,000 / 1000 = smallest * 1000 (only Nonce 1 \
            \ carries supply; Nonces 2-8 are 0). Output ([equity-id]) is empty here (write product). \
            \ NOTE: the SWPI-style ground-truth (compare vs the real reader post-issue) does NOT apply \
            \ — post-populate nonces-used=8, so a live URCi_CreateNewNonces reads the UNdiscounted \
            \ price; the equality is code-proven, not test-arbitrated. A GAS-delta harness on the \
            \ real C_DPSF|IssueCompany would confirm empirically. The discount itself (equity always \
            \ Elite) is intended-behavior to confirm under task #76 (IGNIS re-pricing)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                ;;
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (populate-price:decimal (/ (* (ref-DALOS::UR_UsagePrice "ignis|smallest") 1000000.0) 1000.0))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-I::URCi_IssueDigitalCollection true dpdc)
                    (ref-IGNIS::UDC_ConstructOutputCumulator populate-price dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                ]
                []
            )
        )
    )
    (defun URCi_MorphPackageShares:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Cost preview for C_MorphPackageShares, mirroring its three branches: Make \
            \ (input-nonce=1: transfer-in + add-quantity + transfer-out), Break (output-nonce=1: \
            \ transfer-in + burn + transfer-out) and Convert (transfer-in + burn + add-quantity + \
            \ transfer-out). Output matches exec ([[in-nonce out-nonce][in-amt out-amt]]). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (if (= input-nonce 1)
                ;;Make: shares (nonce 1) -> package-share-tier (output-nonce)
                (let
                    (
                        (output-amount:integer (URC_MakeSharePackage id input-amount (- output-nonce 1)))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[1]] [[input-amount]])
                            (ref-DPDC-MNG::URCi_AddQuantity id)
                            (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[output-nonce]] [[output-amount]])
                        ]
                        [[1 output-nonce] [input-amount output-amount]]
                    )
                )
                (if (= output-nonce 1)
                    ;;Break: package-share-tier (input-nonce) -> shares (nonce 1)
                    (let
                        (
                            (output-shares:integer (* (URC_SingleSharePerMillions id (- input-nonce 1)) input-amount))
                        )
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[input-nonce]] [[input-amount]])
                                (ref-DPDC-MNG::URCi_BurnSFT id)
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[1]] [[output-shares]])
                            ]
                            [[input-nonce 1] [input-amount output-shares]]
                        )
                    )
                    ;;Convert: package-share-tier (input-nonce) -> package-share-tier (output-nonce)
                    (let
                        (
                            (output-amount:integer (UC_Convert id (- input-nonce 1) input-amount (- output-nonce 1)))
                        )
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[input-nonce]] [[input-amount]])
                                (ref-DPDC-MNG::URCi_BurnSFT id)
                                (ref-DPDC-MNG::URCi_AddQuantity id)
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[output-nonce]] [[output-amount]])
                            ]
                            [[input-nonce output-nonce] [input-amount output-amount]]
                        )
                    )
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_SharePackageTier (package-share-tier:integer)
        (let
            (
                (share-tiers:[integer] (enumerate 1 7))
                (iz-contained:bool (contains package-share-tier share-tiers))
            )
            (enforce iz-contained "Invalid Package Share Tier")
        )
    )
    (defun UEV_ShareAmountsForMaking (id:string shares-amount:integer package-share-tier:integer)
        (UEV_SharePackageTier package-share-tier)
        (let
            (
                (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                (mod-check:integer (mod shares-amount sspm))
                (capacity:integer (URC_CombineCapacity id))
            )
            (enforce 
                (<= shares-amount capacity) 
                (format "Insufficient Capacity Left ({}) to combine {} Individual Shares" [capacity shares-amount])
            )
            (enforce 
                (= mod-check 0) 
                (format "{} Shares is an invalid amount for making a Tier {} Share Packge for EQUITY-SFT Collection {}" [shares-amount package-share-tier id])
            )
        )
    )
    (defun UEV_EquitySemiFungibleID (id:string)
        (let
            (
                (ft:string (take 2 id))
                (sh:string "E|")
            )
            (enforce (= ft sh) "Only EQUITY SFT Collections allowed")
        )
    )
    (defun UEV_Convert (id:string input-tier:integer input-tier-amount:integer output-tier:integer)
        (UEV_SharePackageTier input-tier)
        (UEV_SharePackageTier output-tier)
        (let
            (
                (spm:[integer] (URC_SharesPerMillion id))
                (input-share-value:integer (at (- input-tier 1) spm))
                (output-share-value:integer (at (- output-tier 1) spm))
                (total-input-shares:integer (* input-share-value input-tier-amount))
                (mod-check (mod total-input-shares output-share-value))
            )
            (enforce (!= input-tier output-tier) "Input Tier and Output Tier must be different for Conversion")
            (enforce 
                (= mod-check 0) 
                (format "{} Tier {} Shares cannot be completly Converted to Tier {} Shares For Equity ID {}" [input-tier input-tier-amount output-tier id])
            )
        )
    )
    (defun UEV_Morph (input-nonce:integer output-nonce:integer)
        (let
            (
                (allowed-nonces:[integer] (enumerate 1 8))
                (iz-input:bool (contains input-nonce allowed-nonces))
                (iz-output:bool (contains output-nonce allowed-nonces))
            )
            (enforce (and iz-input iz-output) "Invalid Input or Output Nonces for Morphing")
            (enforce (!= input-nonce output-nonce) "Input and Output Nonces must be different for Morphing")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XI_ConvertPackageShares:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @doc "Converts any Nonce to [2 3 4 5 6 7 8] to any Nonce [2 3 4 5 6 7 8]"
        (require-capability (SECURE))
        (with-capability (EQUITY|C>CONVERT id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (input-nonce:integer (+ 1 input-package-share-tier))
                    (output-nonce:integer (+ 1 output-package-share-tier))
                    (output-amount:integer (UC_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV2.OutputCumulator}
                        ;;1]Transfer <input-package-share-tier> with <input-package-share-tier-amount> to <dpdc>
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[input-nonce]] [[input-package-share-tier-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV2.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT dpdc id input-nonce input-package-share-tier-amount)
                    )
                    (ico3:object{IgnisCollectorV2.OutputCumulator}
                        ;;3]Add Quantity <output-quantity> for the <output-nonce> on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity dpdc id output-nonce output-amount)
                    )
                    (ico4:object{IgnisCollectorV2.OutputCumulator}
                        ;;4]Transfer it to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3 ico4] 
                    [[input-nonce output-nonce][input-package-share-tier-amount output-amount]]
                )
            )
        )
    )
    (defun XI_MakePackageShares:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string shares-amount:integer package-share-tier:integer)
        @doc "Combines Nonce 1 to Nonce 2,3,4,5,6,7,8. \
            \ DPDC Audit #49L: this is an intentionally separate, bespoke implementation of the \
            \ same conceptual pattern as DPDC-S::C_MakeSemiFungibleSet/C_BreakSemiFungibleSet -- EQUITY \
            \ wants freely-transferable tier tokens, not opaque set-bundles, so it shares no code with \
            \ DPDC-S. A future DPDC-S invariant fix will NOT automatically propagate here; cross-link \
            \ any such change to this pair of functions for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>MAKE id shares-amount package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (output-nonce:integer (+ 1 package-share-tier))
                    (output-amount:integer (URC_MakeSharePackage id shares-amount package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV2.OutputCumulator}
                        ;;1]Transfer Shares to <dpdc>
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[1]] [[shares-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV2.OutputCumulator}
                        ;;2]Add Quantity for the Package-Share on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity dpdc id output-nonce output-amount)
                    )
                    (ico3:object{IgnisCollectorV2.OutputCumulator}
                        ;;3]Transfer it to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[1 output-nonce][shares-amount output-amount]]
                )
            )
        )
    )
    (defun XI_BreakPackageShares:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string package-share-tier:integer amount:integer)
        @doc "Brakes Nonce 2,3,4,5,6,7,8 to Nonce 1. \
            \ DPDC Audit #49L: see XI_MakePackageShares's @doc -- intentionally bespoke vs. DPDC-S, \
            \ cross-link any DPDC-S Make/Break invariant change here for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>BREAK id package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                    (nonce-to-break:integer (+ package-share-tier 1))
                    (output-shares:integer (* sspm amount))
                    ;;
                    (ico1:object{IgnisCollectorV2.OutputCumulator}
                        ;;1]Transfer Package-Share-Tier nonce to dpdc
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[nonce-to-break]] [[amount]] true)
                    )
                    (ico2:object{IgnisCollectorV2.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT dpdc id nonce-to-break amount)
                    )
                    (ico3:object{IgnisCollectorV2.OutputCumulator}
                        ;;3]Release Shares to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[1]] [[output-shares]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[nonce-to-break 1][amount output-shares]]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_IssueShareholderCollection:object{IgnisCollectorV2.OutputCumulator}
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Royalty is the standard Royalty for the Whole Collection \
            \ While <ignis-royalty> is the ignis Royalty for 1% of Company Shares"
        (P|UEV_IMC)
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                ;;
                (special-sft:[string] (ref-U|VST::UC_EquityID collection-name collection-ticker))
                (name:string (at 0 special-sft))
                (ticker:string (at 1 special-sft))
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                ;;
                (b:string BAR)
                (zd:object{DpdcUdcV2.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
                (md:object{DpdcUdcV2.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (n:[string] (UC_Name collection-name))
                (d:[string] (UC_Description collection-name))
                (type:object{DpdcUdcV2.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                ;;
                (ico:object{IgnisCollectorV2.OutputCumulator}
                    ;;1]Issue Equity SFT Collection; <dpdc> automatically gets <role-nft-add-quantity> and <role-nft-burn>
                    (ref-DPDC-I::C_IssueDigitalCollection
                        patron true
                        dpdc creator-account name ticker
                        false false true true
                        true true true false
                        true
                    )
                )
                (equity-id:string (at 0 (at "output" ico)))
                (l:integer (length ipfs-links))
            )
            (enforce (= l 24) "24 IPFS links must be provided for an Equity Collection")
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ico
                    ;;2]Populate Equity SFT Collection
                    (ref-DPDC-C::C_CreateNewNonces
                        equity-id true [1000000 0 0 0 0 0 0 0]
                        [
                            ;;Barebone Share, Nonce 1
                            (ref-DPDC-UDC::UDC_NonceData royalty 0.001 (at 0 n) (at 0 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 0 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 8 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 16 ipfs-links) b b b b b b)
                            )
                            ;;0.1 Promille representing 100 Shares per Million, Nonce 2
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 100.0) (at 1 n) (at 1 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 1 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 9 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 17 ipfs-links) b b b b b b)
                            )
                            ;;0.2 Promille representing 200 Shares per Million, Nonce 3
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 50.0) (at 2 n) (at 2 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 2 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 10 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 18 ipfs-links) b b b b b b)
                            )
                            ;;0.5 Promille representing 500 Shares per Million, Nonce 4
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 20.0) (at 3 n) (at 3 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 3 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 11 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 19 ipfs-links) b b b b b b)
                            )
                            ;;1 Promille representing 1000 Shares per Million, Nonce 5
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 10.0) (at 4 n) (at 4 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 4 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 12 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 20 ipfs-links) b b b b b b)
                            )
                            ;;2 Promille representing 2000 Shares per Million, Nonce 6
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 5.0) (at 5 n) (at 5 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 5 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 13 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 21 ipfs-links) b b b b b b)
                            )
                            ;;5 Promille representing 5000 Shares per Million, Nonce 7
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 2.0) (at 6 n) (at 6 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 6 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 14 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 22 ipfs-links) b b b b b b)
                            )
                            ;;1 Percent representing 10000 Shares per Million, Nonce 8
                            (ref-DPDC-UDC::UDC_NonceData royalty ignis-royalty (at 7 n) (at 7 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 7 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 15 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 23 ipfs-links) b b b b b b)
                            )
                        ]
                    )
                ]
                [equity-id]
            )
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        (P|UEV_IMC)
        (UEV_Morph input-nonce output-nonce)
        (with-capability (SECURE)
            (if (= input-nonce 1)
                ;;Make Package Shares
                (XI_MakePackageShares account id input-amount (- output-nonce 1))
                (if (= output-nonce 1)
                    ;;Brake Package Shares
                    (XI_BreakPackageShares account id (- input-nonce 1) input-amount)
                    ;;Convert Package Shares
                    (XI_ConvertPackageShares account id (- input-nonce 1) input-amount (- output-nonce 1))
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)