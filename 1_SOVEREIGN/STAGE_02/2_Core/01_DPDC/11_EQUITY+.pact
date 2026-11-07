;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EquityV5
    @doc "EquityV5 is the interface contract for the EQUITY shareholder/equity-collection \
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
    ;; THE ONE PLACE THE "E|" RULE LIVES, from 2026-10-07. The prefix test was written out by hand
    ;; in three separate modules (DPDC-C and DPDC-T for pricing, and this module's own
    ;; UEV_EquitySemiFungibleID), and AQP-SCORE was about to be a fourth. A rule copied four times
    ;; is a rule that will be changed in three places.
    (defun URC_IzEquitySemiFungible:bool (id:string))
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer))
    (defun URC_SharesPerMillion:[integer] (id:string))
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer))
    (defun URC_CombineCapacity:integer (id:string))
    ;;THE BACKING INVARIANT, V5: escrow == m x K. See the module body for the full account.
    (defun UC_ShareSplit:[integer] (millions:integer k:integer))
    (defun URC_ShareMillions:integer (id:string))
    (defun URC_PackageConstant:integer (id:string))
    (defun URC_RequiredEscrow:integer (id:string))
    (defun URC_EscrowHeld:integer (id:string))
    (defun URCi_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator} ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_SharePackageTier (package-share-tier:integer))
    (defun UEV_ExecutorIzCompanyCreator (executor:string id:string))
    (defun UEV_ShareMillions (millions:integer))
    (defun UEV_EscrowBacked (id:string))
    (defun UEV_RetireFloor (id:string millions:integer))
    (defun UEV_RetireHolding (id:string account:string millions:integer))
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
    (defun C_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator}
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    ;;COMPANY GOVERNANCE, added at V5 (2026-11-07). An equity collection's owner-account is the
    ;;DPDC smart account, so every owner-gated DPDC operation names a contract rather than the
    ;;human who founded the company. These five prove the CREATOR and then act as <dpdc>.
    (defun C_IssueShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string millions:integer))
    (defun C_RetireShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string millions:integer))
    (defun C_TogglePauseShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string toggle:bool))
    (defun C_SetCompanyBranding:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}]))
    (defun C_UpgradeCompanyBranding (patron:string executor:string id:string months:integer))

)
(module EQUITY GOV
    @doc "EQUITY implements OuronetPolicyV2 and EquityV5 to create and manage Shareholder \
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
    (implements EquityV5)

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
        (with-capability (GOV|EQUITY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|EQUITY_ADMIN)
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
        (with-capability (GOV|EQUITY_ADMIN)
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
        (with-capability (GOV|EQUITY_ADMIN)
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
    ;;ONE MILLION. The share unit: issuance and retirement move whole millions and nothing else.
    ;;It is not a style choice -- `URC_SharesPerMillion` divides the share count by this with
    ;;INTEGER division, so a supply that is not a whole number of millions truncates and every
    ;;tier value collapses with it. The divisibility rule is what keeps that division exact.
    (defconst SHARE_UNIT 1000000)
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
    (defcap EQUITY|C>ISSUE-SHARES (id:string executor:string millions:integer)
        @doc "Authorises creating <millions> million new shares. \
            \ \
            \ THE CREATOR, NOT THE OWNER. An equity collection's owner-account is the DPDC smart \
            \ account -- that is how the collection is automanaged and how its nonce set stays \
            \ sealed -- so owner-gated management names an account no company director can sign \
            \ for. The creator is the only party to the company that is not a contract."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareMillions millions)
        (UEV_EscrowBacked id)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>RETIRE-SHARES (id:string executor:string millions:integer)
        @doc "Authorises retiring <millions> million shares -- a permissioned burn, split \
            \ pro-rata between the retirer's own holding and the escrow."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareMillions millions)
        (UEV_EscrowBacked id)
        (UEV_RetireFloor id millions)
        (UEV_RetireHolding id executor millions)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>COMPANY-ACT (executor:string id:string)
        @doc "Authorises a COMPANY-bucket act on an equity collection -- one the creator must be \
            \ able to perform and the DPDC smart account must be the one to execute. \
            \ \
            \ WHY A WRAPPER AND NOT A RE-GATE. These operations are owner-gated inside DPDC, and \
            \ for an equity collection the owner is <dpdc>. Rather than teach six DPDC modules \
            \ about `E|` -- which would mean publishing the predicate through DpdcV3 and \
            \ rebinding twenty-four modules -- EQUITY proves the CREATOR here and then ACTS AS \
            \ <dpdc>, which it may do because `P|EQUITY|REMOTE-GOV` is registered as a DPDC \
            \ governor guard (see P|A_Define). \
            \ \
            \ The consequence is the valuable part: every DPDC management operation NOT wrapped \
            \ here stays sealed BY CONSTRUCTION. Wipes, forced repurposes, set definitions and \
            \ fragmentation remain unreachable to a company director, because confiscating or \
            \ redefining shareholders' shares is not a directorial power."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (compose-capability (P|GOV-CALLER))
    )
    ;;{C4}  Ownership [gold]
    (defun CAP_EquityCreator (executor:string id:string)
        @doc "Proves the company's creator: BOTH that <executor> IS the creator and that the \
            \ caller owns that account. Either half alone is a hole -- see \
            \ UEV_ExecutorIzCompanyCreator. \
            \ \
            \ A defun, not a defcap, for the reason AQP-VCT's CAP_VctVacatePoolOwner records: a \
            \ defcap bare-called does NOT run its body, which silently no-ops the gate on the \
            \ whole surface that calls it that way."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (UEV_ExecutorIzCompanyCreator executor id)
            (ref-DPDC::CAP_Creator id true)
        )
    )

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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    ;; ─────────────────────────────────────────────────────────────────────────────────────────
    ;; THE BACKING INVARIANT:  escrow  ==  m x K
    ;;
    ;; Making a package does NOT burn shares -- `XI_MakePackageShares` TRANSFERS them to <dpdc>
    ;; and mints the tier units against them. So nonce 1's total supply is the company's share
    ;; count at all times, and <dpdc>'s nonce-1 balance is the collateral behind every
    ;; outstanding package.
    ;;
    ;;   m = total shares / SHARE_UNIT          (the scale)
    ;;   K = SUM over tiers (units x S_tier)    (the PERCENTAGE -- invariant under supply change)
    ;;
    ;; A tier unit is worth `m x S_tier` shares (URC_SharesPerMillion), so all outstanding
    ;; packages redeem for `m x K`. That is exactly what <dpdc> must hold.
    ;;
    ;; WHY K IS THE RIGHT ABSTRACTION. It is constant under issuance and retirement, which is the
    ;; formal content of "a package is a percentage of the company". Two consequences follow:
    ;;
    ;;   - the 50% packaging cap becomes `K <= SHARE_UNIT / 2`, with no reference to m at all,
    ;;     so issuing or retiring shares can never breach it;
    ;;   - escrow is always a multiple of m, so the pro-rata split below is always whole shares.
    ;;     No rounding, no dust, no truncation.
    ;;
    ;; MAKE, BREAK AND CONVERT ALREADY MAINTAIN IT. Make moves `shares-amount` into escrow and
    ;; raises K by `shares-amount / m`, so d(escrow) = m x dK exactly; Break is its mirror; and
    ;; Convert leaves K alone because `UEV_Convert` enforces `mod(total-input-shares,
    ;; output-share-value) = 0`, making the tier division exact. Issue and Retire were the only
    ;; two operations missing -- which is why the model was incomplete rather than wrong.
    ;; ─────────────────────────────────────────────────────────────────────────────────────────
    (defun UC_ShareSplit:[integer] (millions:integer k:integer)
        @doc "How <millions> million shares divide when issued or retired: [to-escrow, to-holder]. \
            \ Per million, K goes to or from the escrow and (SHARE_UNIT - K) to or from the \
            \ holder -- which is what keeps `escrow = m x K` true across the change. Both legs \
            \ are whole shares because K is an integer."
        [(* millions k) (* millions (- SHARE_UNIT k))]
    )
    (defun URC_ShareMillions:integer (id:string)
        @doc "m -- the company's share count in whole millions."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (/ (ref-DPDC::UR_NonceSupply id true 1) SHARE_UNIT)
        )
    )
    (defun URC_PackageConstant:integer (id:string)
        @doc "K -- SUM over tiers of (outstanding units x S_tier). The packaged PERCENTAGE of the \
            \ company, in share-equivalents per million. Invariant under issuance and retirement."
        (fold (+) 0 (zip (*) (UR_TierSupplies id) S))
    )
    (defun URC_RequiredEscrow:integer (id:string)
        @doc "m x K -- what <dpdc> must hold of nonce 1 to back every outstanding package."
        (* (URC_ShareMillions id) (URC_PackageConstant id))
    )
    (defun URC_EscrowHeld:integer (id:string)
        @doc "What <dpdc> actually holds of nonce 1."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-DPDC::UR_AccountNonceSupply (ref-DPDC::GOV|DPDC|SC_NAME) id true 1)
        )
    )
    (defun URC_IzEquitySemiFungible:bool (id:string)
        @doc "True when <id> names an EQUITY (shareholder) SFT collection. \
            \ \
            \ PREDICATE, NOT AN ENFORCE -- which is why it is not UEV_EquitySemiFungibleID. A caller \
            \ that must DISPATCH on the answer (AQP-SCORE weights an equity collection by live share \
            \ value and everything else by its own tables) needs a boolean; an enforce can only \
            \ abort, and wrapping one in `try` to recover the boolean would make an ordinary branch \
            \ look like an error path. \
            \ \
            \ Identity is the NAME PREFIX, which is the same test the three existing sites use; \
            \ there is no flag on the collection row to consult."
        (= (take 2 id) "E|")
    )
    (defun URC_CombineCapacity:integer (id:string)
        @doc "Remaining share-equivalent headroom that may still be packaged into tier-units (nonces \
            \ 2-8) before hitting the 1/PACKAGING_CAP_DIVISOR (50%) packaging cap on total shares \
            \ (nonce 1). DPDC Audit #29M."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator} ()
        @doc "Cost preview for C_IssueShareholderCollection's IGNIS cumulator (the collection- \
            \ issue STOA price previews separately via DPDC-I::URCi_IssueCollectionStoa). Three legs, \
            \ ARG-INDEPENDENT: \
            \ ico1 = the digital-collection issue (URCi_IssueDigitalCollection son=true on the DPDC \
            \ SC, which owns every Equity collection — owner-account is C_IssueDigitalCollection's \
            \ 3rd arg = dpdc); \
            \ ico2 = the $100 equity premium (central IG|DETER key issue-shareholder, owner 2026-09-05); \
            \ ico3 = the 8-nonce populate at the DISCOUNTED first-Elite-SFT price. \
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
            \ real DPSF|C_IssueCompany would confirm empirically. The discount itself (equity always \
            \ Elite) is intended-behavior to confirm under task #76 (IGNIS re-pricing)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
                ;;
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (populate-price:decimal (/ (* (ref-IGNIS::UC_IgnisLeg "tier-smallest") 1000000.0) 1000.0))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-I::URCi_IssueDigitalCollection true dpdc)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_IssueCompany" "issue-shareholder")
                dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-IGNIS::UDC_ConstructOutputCumulator populate-price dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                ]
                []
            )
        )
    )
    (defun URCi_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Cost preview for C_MorphPackageShares, mirroring its three branches: Make \
            \ (input-nonce=1: transfer-in + add-quantity + transfer-out), Break (output-nonce=1: \
            \ transfer-in + burn + transfer-out) and Convert (transfer-in + burn + add-quantity + \
            \ transfer-out). Output matches exec ([[in-nonce out-nonce][in-amt out-amt]]). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
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
    (defun UEV_ExecutorIzCompanyCreator (executor:string id:string)
        @doc "Binds the DECLARED executor to the collection's creator. \
            \ \
            \ WITHOUT THIS, `CAP_EquityCreator` PROVES A KEY AND NOT AN ACTOR. It enforces \
            \ ownership of the DERIVED creator account and names nobody, so any caller could \
            \ pass any <executor> and the gate would pass as long as the creator's key happened \
            \ to be in the signing environment -- which it is, routinely, because the creator is \
            \ usually also the patron. \
            \ \
            \ MEASURED, NOT REASONED: `EQUITY-MANAGEMENT.repl` <<EQM-2>> had a stranger issue \
            \ shares successfully against the first cut of this code. The two halves are the \
            \ patron/executor canon's point -- the account a function NAMES is the account it \
            \ must prove."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (enforce
                (= executor (ref-DPDC::UR_CreatorKonto id true))
                (format "Executor is not the Creator of Company {}" [id])
            )
        )
    )
    (defun UEV_ShareMillions (millions:integer)
        @doc "Issuance and retirement move WHOLE MILLIONS. Not a rounding convenience: \
            \ `URC_SharesPerMillion` divides the share count by SHARE_UNIT with integer \
            \ division, so any other amount truncates and every tier value collapses."
        (enforce (> millions 0) "Share millions must be a positive whole number of millions")
    )
    (defun UEV_EscrowBacked (id:string)
        @doc "The backing invariant, enforced as a PRECONDITION: <dpdc>'s nonce-1 balance must \
            \ equal m x K before shares move. \
            \ \
            \ Checked rather than assumed because a silent drift here is unrecoverable -- the \
            \ packages would outlive their collateral and a Break would fail for whoever broke \
            \ last, which is the worst possible party to discover it."
        (let
            (
                (held:integer (URC_EscrowHeld id))
                (needed:integer (URC_RequiredEscrow id))
            )
            (enforce
                (= held needed)
                (format "Equity escrow is not backed for {}: dpdc holds {} shares, outstanding packages require {}"
                    [id held needed])
            )
        )
    )
    (defun UEV_RetireFloor (id:string millions:integer)
        @doc "A company cannot be retired out of existence: the founding million is the floor."
        (let
            (
                (m:integer (URC_ShareMillions id))
            )
            (enforce
                (>= (- m millions) 1)
                (format "Retiring {} million would leave {} million shares; {} must keep at least 1 million"
                    [millions (- m millions) id])
            )
        )
    )
    (defun UEV_RetireHolding (id:string account:string millions:integer)
        @doc "To retire shares you must HOLD the holder's leg of them. \
            \ \
            \ Not the whole amount: the escrow's leg comes out of <dpdc>, because package holders \
            \ own a PERCENTAGE and a percentage does not change when the company shrinks. At a \
            \ packaged fraction of 30%, retiring 1 million costs the retirer 700,000 of their own \
            \ shares and 300,000 of the collateral."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                (needed:integer (at 1 (UC_ShareSplit millions (URC_PackageConstant id))))
                (held:integer (ref-DPDC::UR_AccountNonceSupply account id true 1))
            )
            (enforce
                (>= held needed)
                (format "Retiring {} million requires holding {} shares; {} holds {}"
                    [millions needed account held])
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
    ;;Protection: Class 2 — SECURE
    (defun XI_ConvertPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @doc "Converts any Nonce to [2 3 4 5 6 7 8] to any Nonce [2 3 4 5 6 7 8]"
        (require-capability (SECURE))
        (with-capability (EQUITY|C>CONVERT id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (input-nonce:integer (+ 1 input-package-share-tier))
                    (output-nonce:integer (+ 1 output-package-share-tier))
                    (output-amount:integer (UC_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer <input-package-share-tier> with <input-package-share-tier-amount> to <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[input-nonce]] [[input-package-share-tier-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Burn it These three XI_
                        ;;helpers have NO <patron> -- I assumed one and the module stopped
                        ;;loading with "Cannot find module: ouronet-ns.patron", the second time
                        ;;that assumption has cost a load in this sweep. They do have <executor>,
                        ;;the user whose shares are being converted, which is the executor that
                        ;;actually initiates. It becomes this module's own <patron> at its turn.
                        (ref-DPDC-MNG::C_BurnSFT patron dpdc id input-nonce input-package-share-tier-amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Add Quantity <output-quantity> for the <output-nonce> on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity patron dpdc id output-nonce output-amount)
                    )
                    (ico4:object{IgnisCollectorV4.OutputCumulator}
                        ;;4]Transfer it to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3 ico4] 
                    [[input-nonce output-nonce][input-package-share-tier-amount output-amount]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MakePackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string shares-amount:integer package-share-tier:integer)
        @doc "Combines Nonce 1 to Nonce 2,3,4,5,6,7,8. \
            \ DPDC Audit #49L: this is an intentionally separate, bespoke implementation of the \
            \ same conceptual pattern as DPDC-S::C_MakeSemiFungibleSet/CC_BreakSemiFungibleSet -- EQUITY \
            \ wants freely-transferable tier tokens, not opaque set-bundles, so it shares no code with \
            \ DPDC-S. A future DPDC-S invariant fix will NOT automatically propagate here; cross-link \
            \ any such change to this pair of functions for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>MAKE id shares-amount package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (output-nonce:integer (+ 1 package-share-tier))
                    (output-amount:integer (URC_MakeSharePackage id shares-amount package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer Shares to <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[1]] [[shares-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Add Quantity for the Package-Share on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity patron dpdc id output-nonce output-amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Transfer it to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[1 output-nonce][shares-amount output-amount]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BreakPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string package-share-tier:integer amount:integer)
        @doc "Brakes Nonce 2,3,4,5,6,7,8 to Nonce 1. \
            \ DPDC Audit #49L: see XI_MakePackageShares's @doc -- intentionally bespoke vs. DPDC-S, \
            \ cross-link any DPDC-S Make/Break invariant change here for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>BREAK id package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                    (nonce-to-break:integer (+ package-share-tier 1))
                    (output-shares:integer (* sspm amount))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer Package-Share-Tier nonce to dpdc
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[nonce-to-break]] [[amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT patron dpdc id nonce-to-break amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Release Shares to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[1]] [[output-shares]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[nonce-to-break 1][amount output-shares]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IssueShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million shares, split so the backing invariant survives. \
            \ \
            \ MINT ALL TO <dpdc>, THEN RELEASE THE HOLDER'S LEG. The whole amount is added on the \
            \ DPDC account because <dpdc> is the only holder of role-nft-add-quantity on an \
            \ equity collection; what stays behind IS the escrow's share, so the invariant is \
            \ maintained by what is NOT transferred rather than by a second write. \
            \ \
            \ The holder's leg is always positive -- K <= SHARE_UNIT/2 by the packaging cap -- so \
            \ there is no empty-transfer branch to get wrong."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>ISSUE-SHARES id executor millions)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (split:[integer] (UC_ShareSplit millions (URC_PackageConstant id)))
                    (to-holder:integer (at 1 split))
                    (total:integer (* millions SHARE_UNIT))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Mint the whole issuance on <dpdc>
                        (ref-DPDC-MNG::C_AddQuantity patron dpdc id 1 total)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Release the holder's leg; the escrow's leg stays where it was minted
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[1]] [[to-holder]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [[1][total]])
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RetireShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million shares -- a permissioned burn against the retirer's own \
            \ holding plus the escrow's proportional leg. \
            \ \
            \ COLLECT THEN BURN ONCE. The holder's leg is moved to <dpdc> first and the whole \
            \ amount burned there, because <dpdc> is the only holder of role-nft-burn. What \
            \ remains on <dpdc> afterwards is exactly the new m x K."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>RETIRE-SHARES id executor millions)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (split:[integer] (UC_ShareSplit millions (URC_PackageConstant id)))
                    (from-holder:integer (at 1 split))
                    (total:integer (* millions SHARE_UNIT))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Collect the retirer's leg into <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[1]] [[from-holder]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Burn both legs in one write
                        (ref-DPDC-MNG::C_BurnSFT patron dpdc id 1 total)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [[1][total]])
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_IssueShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million new company shares. One of exactly TWO doors through \
            \ which an equity collection's share count may ever change; the other is \
            \ C_RetireShares. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_IssueShares patron executor id millions)
        )
    )
    (defun C_RetireShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million company shares. The retirer must hold the holder's leg \
            \ of the amount; the escrow's leg is burned from <dpdc> alongside it, so every \
            \ package holder's PERCENTAGE is unchanged by the operation. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RetireShares patron executor id millions)
        )
    )
    (defun C_TogglePauseShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        @doc "Halts or resumes all movement of a company's shares -- a trading halt. \
            \ \
            \ Pausing stops TRANSFERS and, with them, Make, Break and Convert: all three move \
            \ shares or tier units through <dpdc> with DPDC-T::C_Transfer, so a halt that left \
            \ packaging running would not be a halt. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                )
                (ref-DPDC-MNG::C_TogglePause patron (ref-DPDC::GOV|DPDC|SC_NAME) id true toggle)
            )
        )
    )
    (defun C_SetCompanyBranding:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string logo:string description:string website:string
         social:[object{BrandingV3.SocialSchema}])
        @doc "Sets the company's public identity -- logo, description, website, socials. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-DPDC::C_UpdatePendingBranding
                    patron (ref-DPDC::GOV|DPDC|SC_NAME) id true logo description website social)
            )
        )
    )
    (defun C_UpgradeCompanyBranding
        (patron:string executor:string id:string months:integer)
        @doc "Extends the company's branding subscription by <months>. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-DPDC::C_UpgradeBranding
                    patron (ref-DPDC::GOV|DPDC|SC_NAME) id true months)
            )
        )
    )
    (defun C_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator}
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Issues an eight-element Equity SFT collection -- a tokenised company. Royalty is \
            \ the standard royalty for the whole collection, <ignis-royalty> the IGNIS royalty \
            \ for 1% of company shares. \
            \ \
            \ Executor: ENFORCED DIRECTLY, and THE ENFORCE IS NEW (2026-09-22). It changes \
            \ WHEN and WITH WHAT MESSAGE the wrong caller is refused, NOT WHETHER -- and that \
            \ distinction is measured, not assumed. See EQUITY.repl <<EQ-G2>>. \
            \ \
            \ WHAT WAS ALREADY TRUE. This module contains no ownership check of any kind -- not \
            \ one CAP_EnforceAccountOwnership, not one CAP_Owner -- and DPDC-I|C>ISSUE runs its \
            \ on the collection OWNER, which for an equity collection is <dpdc>, the DPDC smart \
            \ account, because the collection is automanaged. So that check proves a MODULE. But \
            \ the named creator was reached anyway, three modules later: the ico3 leg calls \
            \ DPDC-C::C_CreateNewNonces, whose authority is CAP_EnforceAccountOwnership on the \
            \ DERIVED (UR_Verum5 id son) -- the create-role account -- and on a freshly issued \
            \ collection that resolves to the creator. Disabling this enforce and re-running \
            \ <<EQ-G2>> still produced a keys-all keyset failure naming EMMA's own key. \
            \ \
            \ WHY IT IS STILL WORTH HAVING. That proof is incidental and late. It is incidental \
            \ because it holds only while the create-role account IS the named creator -- an \
            \ invariant of issuance, not of this function -- and late because it fires after the \
            \ collection has been issued and its branding written. The new enforce makes the \
            \ refusal direct, first, and by name, which is what the canon asks for: the account \
            \ this function NAMES is the account it proves. It also runs ahead of the \
            \ ipfs-links shape check, per the 2026-09-14 ruling that authorisation precedes \
            \ validation; <<EQ-G1>> signs as the account it names, so that fixture still \
            \ exercises the shape guard rather than being shadowed by this one. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14). See the @doc:
        ;;this is the only account-ownership check on the entire equity-issuance path.
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        ;;MUTE-GUARD FIX: this check used to live BELOW the let, and the let's <ico> binding ISSUES
        ;;the collection (DPDC-I::C_IssueDigitalCollection). Pact evaluates let bindings eagerly, so a
        ;;caller who passed the wrong number of links paid for a full collection issuance before the
        ;;link count was ever looked at -- and whenever that issuance failed first for its own reasons
        ;;(a duplicate collection name being the common one) this message could never be the one the
        ;;caller saw. It is a pure argument-shape check on a parameter, so it belongs here, ahead of
        ;;every read and every write. Pinned by REPL/modules/DPDC.repl <<DPDC-G20>>.
        (enforce (= (length ipfs-links) 24)
            "24 IPFS links must be provided for an Equity Collection")
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
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
                (ico:object{IgnisCollectorV4.OutputCumulator}
                    ;;1]Issue Equity SFT Collection; <dpdc> automatically gets <role-nft-add-quantity> and <role-nft-burn>
                    (ref-DPDC-I::C_IssueDigitalCollection
                        ;;FLAGS, in signature order (04_DPDC-I.pact:448-466):
                        ;;  can-upgrade                  FALSE -- the spec is sealed; C_Control is dead
                        ;;  can-change-owner             FALSE -- the DPDC smart account owns it forever
                        ;;  can-change-creator           TRUE  -- a company outlives its founder
                        ;;  can-add-special-role         TRUE
                        ;;  can-transfer-nft-create-role FALSE (2026-11-07) -- was TRUE. The nonce set
                        ;;    is sealed at issuance (DPDC-C|C>REGISTER-NONCES), so a movable create
                        ;;    role could only ever be a way to argue with that seal.
                        ;;  can-freeze                   TRUE
                        ;;  can-wipe                     TRUE
                        ;;  can-pause                    TRUE  (2026-11-07) -- was FALSE, which made
                        ;;    C_TogglePause dead for EVERYONE and a trading halt impossible. Now
                        ;;    routed to the creator through C_TogglePauseShares.
                        ;;  iz-special                   TRUE
                        patron dpdc executor true
                        name ticker
                        false false true true
                        false true true true
                        true
                    )
                )
                (equity-id:string (at 0 (at "output" ico)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ico
                    ;;2]Equity premium: $100 flat in IGNIS (owner 2026-09-05), central IG|DETER
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_IssueCompany" "issue-shareholder")
                dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;3]Populate Equity SFT Collection
                    ;;PROVISIONAL PATRON/EXECUTOR SLOTS (HANDOFF 4e, 2026-09-22). 03_DPDC-C's
                    ;;turn gave C_CreateNewNonces a <patron> and an <executor> bound to
                    ;;(UR_Verum5 id son). This module's own turn has not come, so <patron> stands
                    ;;in and the executor is READ -- the same expression the binder evaluates, on
                    ;;a collection this function has just issued, so it is exact rather than a
                    ;;placeholder. Both become real parameters at 11_EQUITY+'s turn.
                    (ref-DPDC-C::C_CreateNewNonces
                        patron (ref-DPDC::UR_Verum5 equity-id true)
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
    (defun C_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Combines, breaks or converts <executor>'s equity share tiers. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing here or in the three XI_ helpers proves an \
            \ account; each helper moves the shares through the <dpdc> custodial account with \
            \ DPDC-T::C_Transfer, whose capability opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally, and <executor> occupies \
            \ that slot on the outbound leg of every branch. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_Morph input-nonce output-nonce)
        (with-capability (SECURE)
            (if (= input-nonce 1)
                ;;Make Package Shares
                (XI_MakePackageShares patron executor id input-amount (- output-nonce 1))
                (if (= output-nonce 1)
                    ;;Brake Package Shares
                    (XI_BreakPackageShares patron executor id (- input-nonce 1) input-amount)
                    ;;Convert Package Shares
                    (XI_ConvertPackageShares patron executor id (- input-nonce 1) input-amount (- output-nonce 1))
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)