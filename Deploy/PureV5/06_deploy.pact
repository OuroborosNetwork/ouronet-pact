;; -------------------------------------------------------------------------
;; TX 06/06 -- AQP-INFO + AQP-BOOT + O-UI-FOURTEEN  (re-pin + corrected comments)
;;
;; ROUND V5 PART TWO -- THE TRUE-TRIPLET WEIGHT DEFECT.  Deploy 02 -> 06 IN ORDER.
;;
;; THE RULING THIS ROUND IMPLEMENTS (owner, 2026-10-08).  A true triplet is not three scores that
;; happen to be bundled.  It is "one base score, the others are additive satellites which are there
;; for boosting purposes ... in essence it's like a single score, which has boosters that generate
;; their boost as a different quality."  Worked through by the owner:
;;
;;     stake 100 LP at 2x DEB   ->  silver (the hub) 200,  bronze 0,  golden 0
;;     add a bunny giving 10% to bronze's boost class
;;       the bronze score is tied NOT to its own base but to the SILVER base,
;;       so 10% of 100 = 10, times 2x DEB = 20 bronze
;;     total lane weight 200 + 20 + 0 = 220
;;
;;     "otherwise staking LP would have meant 100 silver and 100 bronze and 100 golden score"
;;
;; TWO DEFECTS STOOD BETWEEN THE CODE AND THAT MODEL.
;;
;;   D1  02_SCORE.pact -- a satellite's stored boosted/deb score subtracted the hub's WHOLE base
;;       from a boost part that was ALREADY the increment, so it clamped to 0 unless
;;       prom x deb > 1000 permille.  Pre-M3 the subtraction was right, because `boosted-score`
;;       then meant the boosted TOTAL.  M3 redefined it as the increment and left this branch
;;       alone on purpose -- the comment said it "keeps the nominal-* surplus math unchanged".
;;       A half-finished migration, and the half left behind was the value that gets stored.
;;
;;   D2  04_RPS.pact -- `URC_ComputeTripletLanes` recomputed each lane as
;;       `silver base-score x that slot's own ANK promile`.  Three things wrong, and only the
;;       third is obvious: the HUB's lane became the base times a FRACTION of itself instead of
;;       the base, so a holder with NO boosters had w-user = 0; DEB never entered the lane at
;;       all; and it assumed the hub is the SILVER slot when the triplet rules only say the hub
;;       is the leg whose boost-link is BAR.
;;
;; WHAT IT COST ON MAINNET.  Every holder of the Snake triplet had w-user = 0, so
;; total-lane-weight was 0 and the member's ENTIRE Tier-2 tranche was undistributable:
;;
;;     holder            silver base   stored contrib   live w-user
;;     7KCRz3DHtgiA            2.5            0              0
;;     dwkXniNMFH2F           12.5            0              0
;;     7KGD4QrlzMu1          100.0            0              0
;;
;; The SCORE rows were CORRECT throughout -- hub base 12.5, DEB 4.5, deb-score 56.25.  Only the
;; derivation on top of them was wrong, which is exactly why no admin correction is required.
;;
;; HOW IT HID, which is the part worth keeping.  `[6.4]_AQP-TRIPLET-DIAG.repl` OBSERVED D1 and
;; printed a NOTE -- "foreign surplus needs aggregate promile >500 permille" -- turning the clamp
;; into a documented threshold; `DEPLOY_TEST_MATRIX.md` recorded SCR-50 as PASS because the only
;; thing it asserted was base = 0.  D2 cannot fail loudly at all: a zero divisor short-circuits
;; to "nothing to pay".  A conditional assertion is indistinguishable from an absent one.  The
;; replacement asserts the FIXTURE PRECONDITION first, so a fixture that stops producing a
;; promile fails instead of excusing a zero.
;;
;; NO CORRECTIVE TRANSACTION AFTER THIS ROUND, and that follows from the fix's shape.  The Tier-1
;; numerator and the Tier-2 divisor now BOTH read the SCORE deb basis live -- `URC_TripletUserDebSum`
;; and Sigma total-deb -- which SCORE maintains itself.  The zeroed contrib-weight /
;; total-lane-weight snapshots are still maintained for inspection but are no longer paid from,
;; so they cannot mis-pay anyone.  Weights become correct the moment 03 lands.
;;
;; WHY EIGHT MODULES FOR A TWO-FILE CHANGE -- the dot-pin cascade.  A dot call resolves at the
;; CALLER's deploy time and a stale caller of a table-owning callee ABORTS with "hash not
;; blessed" rather than going quietly stale.  AQP-SCORE is dot-called by RPS and AQP-INFO; RPS by
;; AQP-FVT, AQP-VCT, MTX-AQP, AQP-DSA and AQP-INFO; AQP-FVT by AQP-INFO and AQP-BOOT.  So six of
;; the eight ship BYTE-IDENTICAL to what is already live.  Ground truth:
;; `python3 REPL/tools/_dotpin.py`.  This is the same closure round V4 shipped and measured.
;;
;; NO `create-table` SURVIVES INTO ANY FILE.  Every module here has been live since round V1 or
;; earlier, and re-sending one aborts the whole transaction on a table that already exists.
;; `_purev5.py` strips them and `--check` asserts on the EMITTED bytes that none came back.
;;
;; SIGNING.  All upgrades, so `GOV` is evaluated -- the admin key, not the namespace keyset.
;; Mainnet.  One transaction at a time, in order; do not run two concurrently.
;;
;; NEITHER CHANGED.  AQP-INFO dot-calls AQP-SCORE, RPS, AQP-FVT, AQP-VCT and AQP-DSA -- every
;; module this round touches -- so it is necessarily LAST.  AQP-BOOT dot-calls AQP-FVT.
;;
;; AQP-BOOT APPEARS TWICE IN ROUND V5, here and in 01, and that is correct rather than an error to
;; reconcile.  01 shipped its four late steps and is already on chain; this re-sends the SAME
;; module source so it re-pins AQP-FVT's new hash.  Re-sending identical source is the only way a
;; dot-caller picks up a callee's new hash.
;;
;; O-UI-FOURTEEN RIDES ALONG FOR A DIFFERENT REASON. It has NO dot call into anything this round
;; touches -- it reaches AQP through modrefs, which resolve against the unchanged interfaces -- so
;; the cascade does not require it. Its comments asserted that a true triplet "is deb-independent,
;; cannot go stale, and `CC_UnstaleMyScores` no-ops on it", and all three clauses are now false. A
;; false comment on a live module is a defect with a delay; this is the cheapest file in the round
;; to carry it in, and shipping it keeps the repo byte-identical to the chain.
;;
;; MUST SHIP LAST.
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev5.py

(namespace "ouronet-ns")

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact (module only -- its interface is already live)
(module AQP-INFO GOV
    @doc "Read-only pre-execution cost-preview module for the AQP family. Each INFO_ \
        \ function mirrors a TS02-C3 execution wrapper and returns an \
        \ OuronetInfoV2.ClientInfo describing the operation, its execution function, and the \
        \ exact IGNIS+STOA price for an account — sourced from each AQP module's URCi_ cost \
        \ readers so previews match execution byte-for-byte. A leaf module with no \
        \ interface; never writes; deploys after all AQP cores and TS02-C3."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_INFO|AQP                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|INFO|AQP_ADMIN)))
    (defcap GOV|INFO|AQP_ADMIN ()                       (enforce-guard GOV|MD_INFO|AQP))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
    ;;
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;   (AQP-{ANK,SCORE,POOL,FVT,VCT,DSA}.URCi_*, via OI|UC_IfpFromOutputCumulator / OI|UDC_DynamicStoaCost),
    ;;   so the local price-tier gates (UC_GasPrice / SIP|URC_* / SKP|URC_*) are no longer used here.
    ;;
    ;;[AQP-ANK] Anchors
    (defun INFO_AQP-ANK|IssueTrueFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for AQP-ANK|C_IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a True-Fungible (DPTF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueTrueFungibleAnchor."]
                [(format "Anchor '{}' issued on DPTF {}." [anchor-name dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueTrueFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueSemiFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for AQP-ANK|C_IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Semi-Fungible (DPSF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueSemiFungibleAnchor."]
                [(format "Anchor '{}' issued on DPSF {} nonce {}." [anchor-name dpsf-id dpsf-nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueSemiFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) trait-anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleAnchor."]
                [(format "Anchor '{}' issued on DPNF {} trait {}={}." [anchor-name dpnf-id dpnf-trait-key dpnf-trait-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleSetAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) set-anchor (by nonce-class) for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleSetAnchor."]
                [(format "Anchor '{}' issued on DPNF {} nonce-class {}." [anchor-name dpnf-id dpnf-nonce-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleSetAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an anchor and update its BoostClass bookkeeping."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeAnchor."]
                [(format "Anchor {} revoked." [anchor-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeAnchor)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeBoostClass:object{OuronetInfoV2.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an empty BoostClass."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeBoostClass."]
                [(format "BoostClass {} revoked." [boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeBoostClass)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;[AQP-SCR] Scores
    (defun INFO_AQP-SCR|IssueLiquidityScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.AQP-SCR|C_IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTrueFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueOrtoFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.AQP-SCR|C_IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|RotateScoreOwnership:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-SCR|C_RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.AQP-SCR|C_RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_RotateOwnership score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|ControlScore:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-SCR|C_ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-SCR|C_ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_Control score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostClassLink:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostClassLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostLink:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|EnableDebBoost:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.AQP-SCR|C_EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_EnableDebBoost score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTriplet:object{OuronetInfoV2.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for AQP-SCR|C_IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.AQP-SCR|C_IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueTriplet silver-score-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSingleScoreModel:object{OuronetInfoV2.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.AQP-SCR|C_IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueSingleScoreModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CombineTripletScoreModel:object{OuronetInfoV2.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for AQP-SCR|C_CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.AQP-SCR|C_CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CombineTripletModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueScoreFromModel:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for AQP-SCR|C_IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.AQP-SCR|C_IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueScoreFromModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueSemiFungibleScoreDefinition score-id nonces)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleScoreDefinition score-id trait-keys)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible SET score definition rows (one per nonce-class)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleSetScoreDefinition."]
                [(format "Wrote {} NF set score-definition rows on score {}." [(length dpnf-nonce-classes) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleSetScoreDefinition score-id dpnf-nonce-classes)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-POOL] Pools (config)
    (defun INFO_AQP-POOL|Issue:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for AQP-POOL|C_Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.AQP-POOL|C_Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_Issue [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-POOL.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-POOL|AddScore:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.AQP-POOL|C_AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_AddScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|RevokeScore:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.AQP-POOL|C_RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_RevokeScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|EnablePoolStake:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|DisablePoolStake:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncTrueFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncTrueFungibleAnchors. FULL IGNIS: GAS|SYNC-TF-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live TF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [beneficiary-id dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncTrueFungibleAnchorsFull beneficiary-id dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncSemiFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncSemiFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live SF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [beneficiary-id dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncNonFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncNonFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live NF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [beneficiary-id dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;<---- stake / unstake (multi-leg reconstructed cost) ---->
    (defun INFO_AQP-POOL|StakeTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_StakeTrueFungible. Full multi-leg IGNIS (transfer + tracker + rollup \
            \ + RPS + anchor + score-delta + book + checkpoint); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake a True-Fungible amount into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeTrueFungible."]
                [(format "Staked {} of {} into pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|UnstakeTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_UnstakeTrueFungible. Same legs as stake with the custody transfer \
            \ reversed (vault→owner); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake a True-Fungible amount from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeTrueFungible."]
                [(format "Unstaked {} of {} from pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|StakeOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeOrtoFungible. Multi-leg IGNIS (transfer + tracker×|nonces| + RPS \
            \ + class-matched score-delta + book + checkpoint); no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake whole Orto-Fungible nonces into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeOrtoFungible."]
                [(format "Staked {} nonces of {} into pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeOrtoFungible. Same legs as OF stake; no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake whole Orto-Fungible nonces from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeOrtoFungible."]
                [(format "Unstaked {} nonces of {} from pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeSemiFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeSemiFungibleCollectable (DPSF, son=true / class-3). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-3 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Semi-Fungible collectable nonces (DPSF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeSemiFungibleCollectable."]
                [(format "Staked {} DPSF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id true nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeSemiFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeSemiFungibleCollectable (DPSF, son=true / class-3). Same legs as SF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Semi-Fungible collectable nonces (DPSF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeSemiFungibleCollectable."]
                [(format "Unstaked {} DPSF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeNonFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeNonFungibleCollectable (DPNF, son=false / class-4). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-4 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Non-Fungible collectable nonces (DPNF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeNonFungibleCollectable."]
                [(format "Staked {} DPNF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id false nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeNonFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeNonFungibleCollectable (DPNF, son=false / class-4). Same legs as NF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Non-Fungible collectable nonces (DPNF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeNonFungibleCollectable."]
                [(format "Unstaked {} DPNF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    ;;<---- vacate lifecycle (fixed-cost endpoints) ---->
    (defun INFO_AQP-POOL|BatchVacateTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateTrueFungible. Multi-leg IGNIS (per-leg \
            \ tracker-zero + per-beneficiary unwind + one bulk transfer); no STOA. Fed the same \
            \ dirty-read <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPTF asset's owner-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateTrueFungible."]
                [(format "Batch-vacated {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchVacateOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateOrtoFungible. Multi-leg IGNIS (bulk DPOF \
            \ transfer + per-nonce tracker + per-beneficiary score unwind); no STOA. Fed the same \
            \ dirty-read nonce <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPOF asset's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateOrtoFungible."]
                [(format "Batch-vacated {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchVacateCollectables:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateCollectables (son=DPSF true / DPNF false). \
            \ Multi-leg IGNIS (bulk transfer + per-nonce tracker + rollup + flat anchor + per- \
            \ beneficiary class-matched score unwind); no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one collectable collection's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateCollectables."]
                [(format "Batch-vacated {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateCollectables pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainTrueFungible. Score-free drain: per-leg \
            \ tracker-zero + rollup, settle-on-last-drain only for beneficiaries fully drained \
            \ this round (live UserUnn), then one bulk transfer; no STOA. Fed the dirty-read legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPTF asset's owner-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainTrueFungible."]
                [(format "Batch-drained {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainOrtoFungible. Score-free drain: bulk DPOF \
            \ transfer + per-nonce tracker + settle-on-last-drain (no anchor); no STOA. Fed the legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPOF asset's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainOrtoFungible."]
                [(format "Batch-drained {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainCollectable (son=DPSF true / DPNF false). \
            \ Score-free drain: bulk transfer + per-leg tracker + rollup + flat anchor + settle- \
            \ on-last-drain; no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one collectable collection's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainCollectable."]
                [(format "Batch-drained {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainCollectable pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateTrueFungible -- the pool's WHOLE TrueFungible \
            \ side, every live DPTF lane including the F| frozen ones. No STOA. \
            \ \
            \ TAKES ONLY A POOL ID, unlike INFO_AQP-POOL|FullVacate, which is handed its lane \
            \ plan because its caller has already scanned. `URCi_VacateTrueFungible` performs \
            \ the same scan the exec does, so this is previewable from what the user has in \
            \ front of them."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate every TrueFungible lane of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateTrueFungible."]
                [(format "Vacated the TrueFungible side of Pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateTrueFungible pool-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpof-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateOrtoFungible -- ONE OrtoFungible satellite of a \
            \ pool, not the pool. A class-1 pool has a TF leg plus one or more OF satellites; \
            \ this prices one of them. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE OrtoFungible satellite of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateOrtoFungible."]
                [(format "Vacated OrtoFungible {} of Pool {}." [dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateOrtoFungible pool-id dpof-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateSemiFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateSemiFungible -- ONE DPSF collection of a pool. \
            \ The DPSF and DPNF previews differ only in which side of the shared reader they \
            \ select, so they are separate functions rather than one with a flag: a client that \
            \ passed the wrong flag would quote the other asset's cost and never know."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE semi-fungible collection of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateSemiFungible."]
                [(format "Vacated SemiFungible {} of Pool {}." [dpsf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateSemiFungible pool-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateNonFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateNonFungible -- ONE DPNF collection of a pool. \
            \ See the DPSF sibling for why these are two functions and not one."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE non-fungible collection of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateNonFungible."]
                [(format "Vacated NonFungible {} of Pool {}." [dpnf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateNonFungible pool-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|FullVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string
         tf-lanes:[object{AcquisitionSchemasV1.VCT|VacateTfLane}]
         of-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-son:bool)
        @doc "Cost preview for AQP-POOL|CC_FullVacate — the single-tx whole-pool vacate. Sums the \
            \ per-asset vacate cost across every dirty-read lane (TF + OF satellites + collectables); \
            \ no STOA. Fed the same lane plan the exec's phase-1 scan builds."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fully vacate a pool in a single transaction (all assets, all owners)."
                 "Executes via TS02-C3.AQP-POOL|CC_FullVacate."]
                [(format "Fully vacated pool {} ({} TF + {} OF + {} collectable lanes)."
                    [pool-id (length tf-lanes) (length of-lanes) (length coll-lanes)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_FullVacate pool-id tf-lanes of-lanes coll-lanes coll-son))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|FinalizeVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_FinalizeVacate. IGNIS one flat 'ignis|medium' tier (05_VCT:3016); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a vacate — nuke employed scores, unfreeze FVTs, re-enable stake."
                 "Executes via TS02-C3.AQP-POOL|C_FinalizeVacate."]
                [(format "Finalized vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-VCT.URCi_FinalizeVacate)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|AbortVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_AbortVacate. Empty cumulator (05_VCT:2989) — costs you nothing."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Abort an in-progress vacate (clear the in-progress flag; stake stays disabled)."
                 "Costs you nothing."
                 "Executes via TS02-C3.AQP-POOL|C_AbortVacate."]
                [(format "Aborted vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-FVT] Farms / Vaults / Treasuries (config + rewards)
    (defun INFO_AQP-FVT|Issue:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_Issue. IGNIS GAS|ISSUE-FVT + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a Farm / Vault / Treasury." "Executes via TS02-C3.AQP-FVT|C_Issue."]
                [(format "FVT '{}' created (class {}) for {}." [fvt-name fvt-class owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Issue owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-FVT.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-FVT|RotateOwnership:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer an FVT's owner-konto." "Executes via TS02-C3.AQP-FVT|C_RotateOwnership."]
                [(format "FVT {} ownership moved to {}." [fvt-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_RotateOwnership fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Control:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-FVT|C_Control. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set an FVT's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-FVT|C_Control."]
                [(format "FVT {} control flags updated." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_Control fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetCommonDenominator:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_SetCommonDenominator. IGNIS GAS|SET-COMMON-DENOMINATOR; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's common-denominator (before any links)." "Executes via TS02-C3.AQP-FVT|C_SetCommonDenominator."]
                [(format "FVT {} common-denominator set to {}." [fvt-id common-denominator])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetCommonDenominator fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetMosaic:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Cost preview for AQP-FVT|C_SetMosaic. IGNIS GAS|SET-MOSAIC; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a farm's mosaic membership policy." "Executes via TS02-C3.AQP-FVT|C_SetMosaic."]
                [(format "FVT {} mosaic set to {}." [fvt-id mosaic])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetMosaic fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetSplitMode:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string split-mode:string)
        @doc "Cost preview for AQP-FVT|C_SetSplitMode. IGNIS GAS|SET-SPLIT-MODE; no STOA. Reports the farm's current \
            \ reward-split mode alongside the requested one."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size)." "Executes via TS02-C3.AQP-FVT|C_SetSplitMode."]
                [(format "Farm {} reward-split mode: {} -> {}." [fvt-id (RPS.UR_FVT|SplitMode fvt-id) split-mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetSplitMode fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|AddScoreEntity:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Cost preview for AQP-FVT|C_AddScoreEntity. IGNIS GAS|ADD-SCORE-ENTITY; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a score (type 1) or triplet (type 3) on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddScoreEntity."]
                [(format "Score-entity {} (type {}) registered on FVT {}." [score-entity-id score-entity-type fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_AddScoreEntity fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleScoreEntityLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleScoreEntityLink. IGNIS GAS|TOGGLE-SCORE-ENTITY-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable/disable a ScoreEntityLink on an FVT." "Executes via TS02-C3.AQP-FVT|C_ToggleScoreEntityLink."]
                [(format "FVT {} score-entity {} enabled={}." [fvt-id score-entity-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_ToggleScoreEntityLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueMultipletFamily:object{OuronetInfoV2.ClientInfo}
        (patron:string token-0-id:string token-1-id:string token-2-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueMultipletFamily. IGNIS GAS|ISSUE-MULTIPLET-FAMILY; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a chain-wide MultipletFamily reward ladder." "Executes via TS02-C3.AQP-FVT|C_IssueMultipletFamily."]
                [(format "MultipletFamily issued: {} -> {} -> {}." [token-0-id token-1-id token-2-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_IssueMultipletFamily patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueGenericEarningVault:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueGenericEarningVault -- the whole six-operation vault \
            \ as ONE charge. IGNIS only; no STOA."
        ;;The cost comes from TS02-C3.URCi_IssueGenericEarningVault, which concatenates the SAME six
        ;;component readers the operation's own cumulators come from. Preview and charge therefore
        ;;agree by construction rather than by a number kept in step by hand.
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stand up a complete earning Vault in one transaction -- score, pool, pool-score link, FVT entity, score admission and reward link."
                 "Executes via TS02-C3.AQP-FVT|C_IssueGenericEarningVault."]
                [(format "Vault {}: stake {} to earn {}. Creates {}Score, {}Pool, {}Vault."
                    [vault-name stake-dptf-id reward-dptf-id vault-name vault-name vault-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (TS02-C3.URCi_IssueGenericEarningVault owner-konto vault-name stake-dptf-id reward-dptf-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|AddRewardLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Cost preview for AQP-FVT|C_AddRewardLink. IGNIS GAS|ADD-REWARD-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a reward DPTF on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddRewardLink."]
                [(format "Reward {} linked on FVT {} (family {})." [reward-dptf-id fvt-id multiplet-family-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_AddRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleRewardLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleRewardLink. IGNIS GAS|TOGGLE-REWARD-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a reward link's enabled flag." "Executes via TS02-C3.AQP-FVT|C_ToggleRewardLink."]
                [(format "FVT {} reward {} enabled={}." [fvt-id reward-dptf-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_ToggleRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetQualitySplit:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Cost preview for AQP-FVT|C_SetQualitySplit. IGNIS GAS|SET-QUALITY-SPLIT; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a MULTIPLET_BASE reward's quality-split mode + matrix." "Executes via TS02-C3.AQP-FVT|C_SetQualitySplit."]
                [(format "FVT {} reward {} quality-split mode={}." [fvt-id reward-dptf-id mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetQualitySplit fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|InjectStream:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Cost preview for AQP-FVT|CC_InjectStream. IGNIS GAS|INJECT; STOA none (custody transfer)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Inject reward tokens as a linear time-stream over the given duration."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectStream."]
                [(format "Streaming {} of {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XIv_FvtAddStream PHASE 1 runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_InjectStream" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|Inject:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_Inject (enforced-fresh single-tx inject). IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enforced-fresh single-tx inject (fixes all stale members first)."
                 "Executes via TS02-C3.AQP-FVT|CC_Inject."]
                [(format "Fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14). This quoted only RPS.URCi_Inject -- the gas leg --
                    ;;while CC_Inject also collects the custody transfer of the reward principal
                    ;;(XI_FvtInjectCore PHASE 1, 04_RPS.pact). Measured short by exactly the transfer
                    ;;cumulator. URCi_InjectFull counts both, matching how URCi_CollectFull and
                    ;;URCi_TrueFungibleStakeFlow already count theirs. Pinned by
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFinalize:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_InjectFinalize. IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a paginated fresh inject (zero-stale gate, then inject)."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectFinalize."]
                [(format "Finalized fresh inject of {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XE_XI_FvtInjectCore runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_InjectFinalize" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFixChunk:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_InjectFixChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page the enforced-fresh FIX phase (up to `chunk` stale members)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_InjectFixChunk."]
                [(format "Fixed up to {} stale members on FVT {} reward {}." [chunk fvt-id reward-dptf-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|UnstaleAll:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_UnstaleAll. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Owner mass deb-unstale (make injection-ready; no inject)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_UnstaleAll."]
                [(format "Unstaled up to {} members on FVT {}." [chunk fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|UnstaleMyScores:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-ids:[string])
        @doc "Cost preview for AQP-FVT|CC_UnstaleMyScores. IGNIS GAS|UNSTALE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Self-service deb-unstale of your own scores across FVTs." "Executes via TS02-C3.AQP-FVT|CC_UnstaleMyScores."]
                [(format "Unstaled your scores across {} FVTs." [(length fvt-ids)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_UnstaleMyScores patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Collect:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|CC_Collect. FULL IGNIS: reward-payout leg (plain TFT transfer, or a \
            \ MULTIPLET_BASE triplet Coil/Curl ladder) + Phase-7 forced-fix penalty + GAS|COLLECT; STOA none. \
            \ Reconstructed on the current claimable state (exact for un-streamed / settled lanes)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Collect your claimable reward from this FVT membership."
                 "Full IGNIS shown: payout transfer/ladder + any forced-fix penalty + gas (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-FVT|CC_Collect."]
                [(format "Collected reward token {} from score-entity {}." [reward-dptf-id score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (RPS.URCi_CollectFull patron fvt-id score-entity-type score-entity-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepRevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Single-tx re-score sweep retiring an employed anchor."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepRevokeAnchor."]
                [(format "Swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepBegin:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepBegin. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a paginated re-score sweep (freeze + swept-revoke + cursor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepBegin."]
                [(format "Opened sweep on anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepRecomputeChunk:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_SweepRecomputeChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page a re-score sweep (recompute the next `chunk` holders; final page unfreezes)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_SweepRecomputeChunk."]
                [(format "Recomputed up to {} holders on anchor {}'s sweep." [chunk anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-DSA] Delegated Staking Agencies
    (defun INFO_AQP-DSA|DefineDelegationVault:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Cost preview for AQP-DSA|C_DefineDelegationVault. IGNIS GAS|DEFINE-VAULT; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bind a class-0 FVT as a DSA delegation vault." "Executes via TS02-C3.AQP-DSA|C_DefineDelegationVault."]
                [(format "FVT {} bound as delegation vault (model {})." [fvt-id model-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_DefineDelegationVault patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OpenAgency:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer collectable-id:string stake-nonces:[integer])
        @doc "Cost preview for AQP-DSA|CC_OpenAgency. IGNIS GAS|OPEN-AGENCY base; the atomic open also stakes the \
            \ operator's collateral (staking legs added at execution). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a delegation agency (admit + operator-stake + terminal gate)."
                 "Base IGNIS shown; the operator collateral stake adds its legs at execution."
                 "Executes via TS02-C3.AQP-DSA|CC_OpenAgency."]
                [(format "Agency {} opened on vault {} (fee {} per-mille)." [score-entity-id fvt-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OpenAgency patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|RecomputeCapture:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Cost preview for AQP-DSA|C_RecomputeCapture. IGNIS GAS|RECOMPUTE-CAPTURE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Recompute an agency's capture (permissionless; preserves oracle-ts)." "Executes via TS02-C3.AQP-DSA|C_RecomputeCapture."]
                [(format "Agency {} capture recomputed on vault {}." [score-entity-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_RecomputeCapture patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetOracleAuth:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Cost preview for AQP-DSA|C_SetOracleAuth. IGNIS GAS|SET-ORACLE-AUTH; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Authorize the delegated oracle key + arm the capture expiry." "Executes via TS02-C3.AQP-DSA|C_SetOracleAuth."]
                [(format "Oracle authority set on vault {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetOracleAuth patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OracleWrite:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Cost preview for AQP-DSA|C_OracleWrite. IGNIS GAS|ORACLE-WRITE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Oracle writes an agency's daily {nodes, uptime} + recomputes its capture." "Executes via TS02-C3.AQP-DSA|C_OracleWrite."]
                [(format "Oracle wrote nodes {} / uptime {} for agency {}." [nodes uptime score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OracleWrite patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|ToggleExternalOracle:object{OuronetInfoV2.ClientInfo}
        (on:bool)
        @doc "Cost preview for AQP-DSA|A_ToggleExternalOracle. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Flip the SINGULAR GLOBAL external-oracle switch for ALL agencies (governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_ToggleExternalOracle."]
                [(format "Global external-oracle switch set to {}." [on])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetOracleValidity:object{OuronetInfoV2.ClientInfo}
        (seconds:integer)
        @doc "Cost preview for AQP-DSA|A_SetOracleValidity. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set the GLOBAL oracle-validity window (freshness horizon; governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_SetOracleValidity."]
                [(format "Global oracle-validity window set to {} seconds." [seconds])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|WithdrawRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_WithdrawRoyalty. FULL IGNIS: GAS|WITHDRAW-ROYALTY gas leg + the state- \
            \ dependent custody-move leg (normalize + TFT transfer of the live royalty pool to the FVT owner); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Withdraw the whole royalty pool to the FVT owner."
                 "Full IGNIS shown: gas + custody move (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_WithdrawRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} withdrawn to owner." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_WithdrawRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|BurnRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_BurnRoyalty. FULL IGNIS: GAS|BURN-ROYALTY gas leg + the state-dependent \
            \ custody-burn leg (normalize + DPTF burn of the live royalty pool); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Burn the whole royalty pool."
                 "Full IGNIS shown: gas + custody burn (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_BurnRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} burned." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_BurnRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|FuelRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Cost preview for AQP-DSA|C_FuelRoyalty. FULL IGNIS: GAS|FUEL-ROYALTY gas leg + the state-dependent \
            \ custody-fuel leg (normalize + SWPLC fuel of the live royalty pool into the swpair); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fuel a swap pair with the whole royalty pool (no LP mint)."
                 "Full IGNIS shown: gas + custody fuel (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_FuelRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} fueled into {}." [reward-dptf-id fvt-id swpair])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_FuelRoyaltyFull patron fvt-id reward-dptf-id swpair))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetAgencyFee:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Cost preview for AQP-DSA|C_SetAgencyFee. IGNIS GAS|SET-AGENCY-FEE; no STOA. O(1) reprice."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Change a delegation agency's operator fee (reprices only future injects)." "Executes via TS02-C3.AQP-DSA|C_SetAgencyFee."]
                [(format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetAgencyFee patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-MTX] Matrix drivers (spike-fallback defpacts)
    (defun INFO_AQP-MTX|2Inject:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for MTX-AQP|2|CC_Inject (2-step enforced-fresh inject). IGNIS GAS|INJECT (inner XB_FvtInject); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step enforced-fresh inject (spike fallback for CC_Inject on vault/treasury)."
                 "Executes via TS02-C3.MTX-AQP|2|CC_Inject."]
                [(format "2-step fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XB_FvtInject runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "MTX-AQP|2|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-MTX|2SweepRevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for MTX-AQP|2|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step paginated sweep retiring an employed anchor (spike fallback for CC_SweepRevokeAnchor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.MTX-AQP|2|CC_SweepRevokeAnchor."]
                [(format "2-step swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ---- source: 2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact (module only -- its interface is already live)
(module AQP-BOOT GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AcquisitionPoolBootV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-BOOT                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_BOOT_ADMIN)))
    (defcap GOV|AQP_BOOT_ADMIN ()                       (enforce-guard GOV|MD_AQP-BOOT))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst BOOT|SCORE_SILVER:string                  "SilverSnakePower")
    (defconst BOOT|SCORE_BRONZE:string                  "BronzeSnakePower")
    (defconst BOOT|SCORE_GOLDEN:string                  "GoldenSnakePower")
    (defconst BOOT|PRECISION:integer                    6)
    (defconst BOOT|MX_FROZEN:decimal                    2.0)
    (defconst BOOT|MX_SLEEPING:decimal                  2.0)
    (defconst BOOT|FVT_OURO_LP_FARM:string              "OuroLpFarm")
    (defconst BOOT|FVT_SUBSIDIARY_TREASURY:string       "SubsidiaryTreasury")
    (defconst BOOT|FVT_CODING_TREASURY:string           "CodingDivisionTreasury")
    (defconst BOOT|FVT_SNAKES_TREASURY:string           "SnakesTreasury")
    (defconst BOOT|FVT_SHARES_TREASURY:string           "CompanySharesTreasury")
    ;;ADDED 2026-09-19. The fifth treasury. C_Step4 creates FOUR core scores and three of them
    ;;had a treasury of their own -- TheCodingDivision, DemiourgosSnakes, DemiourgosShareholder --
    ;;while `Bloodshed` had none, even though C_Step7 attaches it to DHBloodshed and so makes it
    ;;EMPLOYED. An employed score with no FVT link and no reward DPTF aborts every stake at
    ;;05_FVT.pact:1031. Owner ruling 2026-09-19: "staking bloodshed assets determines the pure
    ;;bloodshed score, and we need to be able to earn stuff via that score alone" -- so it earns,
    ;;and it earns through its own class-2 Treasury (the score is NF, and treasuries take SF/NF).
    (defconst BOOT|FVT_BLOODSHED_TREASURY:string "BloodshedTreasury")
    ;;THE THREE LATE ENTITIES, added 2026-10-08. Steps 8/9/12 were written when the boot ladder
    ;;owned every score it wired. Three scores exist that it does not:
    ;;
    ;;  NosferatuDracula  class 4 (DPNF)  pool DHNosferatu     -- issued from the UI
    ;;  WonderCoach       class 3 (DPSF)  pool DHWonderCoach   -- issued from the UI
    ;;  StoicPower        class 1 (DPTF)  pool NONE            -- issued from the UI
    ;;
    ;;Step 7 already attaches the first two to their pools (dh-score-ids[9..10]); what it has
    ;;never had is an FVT for either, so Step 9 could not admit them and their pools would stay
    ;;unstakeable however many aggregators existed. StoicPower has neither pool nor FVT.
    (defconst BOOT|FVT_NOSFERATU_TREASURY:string        "NosferatuTreasury")
    (defconst BOOT|FVT_WONDERCOACH_TREASURY:string      "WonderCoachTreasury")
    (defconst BOOT|FVT_STOICISM_VAULT:string            "StoicismVault")
    (defconst BOOT|POOL_STOICISM:string                 "StoicismPool")
    ;;CLASS CONSTANTS, named rather than written as digits at the call site. The two sovereign
    ;;admission rules disagree about SF/NF (see Step 8's @doc), so the one thing that must not be
    ;;a bare literal is the class.
    ;;  treasury(2) admits score-class 3/4  -- NosferatuDracula(4), WonderCoach(3)
    ;;  vault(1)    admits score-class 1/2  -- StoicPower(1)
    ;;TF-in/TF-out is the case BOTH rules describe identically, so the Stoicism vault does not
    ;;depend on how that dispute is settled; the two treasuries follow the same class the four
    ;;existing ones were issued at.
    (defconst BOOT|FVT_CLASS_VAULT:integer              1)
    (defconst BOOT|FVT_CLASS_TREASURY:integer           2)
    (defconst BOOT|POOL_CLASS_TF:integer                1)

    ;;<---------------------------------------------------------------------->
    ;; CUSTODIANS DELEGATED-STAKING VAULT (Steps 13-14). Added 2026-09-19.
    ;;
    ;; WHY THIS IS A CLASS-0 FVT AND NOT A TREASURY. It was specified as "a DSA Treasury",
    ;; and it behaves like one -- users stake an SFT collection, no LP is involved. But
    ;; 08_DSA.pact:292 refuses anything else outright:
    ;;     (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
    ;; and AQP.repl <<AQP-G20b>> pins that refusal for a class-1 vault. The reason is in that
    ;; test's own note: capture arithmetic is denominated in an LP denominator, which classes
    ;; 1 and 2 do not have. Delegation members are then admitted through
    ;; RPS::XE_AdmitDelegationMember with swpair "|" and ghost-tvl 0.0, which SKIPS every LP
    ;; rule and the triplet-category<->fvt-class check. So class 0 is the container; the
    ;; behaviour is vault-like. Same shape as OuroLpFarm, which is the working precedent for
    ;; triplet + MULTIPLET_BASE + quality split.
    (defconst BOOT|FVT_CUSTODIANS_VAULT:string          "CustodiansVault")
    (defconst BOOT|POOL_CUSTODIANS:string               "CustodiansPool")
    (defconst BOOT|MODEL_CUSTODIANS_BRONZE:string       "CustodiansBronzeQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_SILVER:string       "CustodiansSilverQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_GOLDEN:string       "CustodiansGoldenQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_TRIPLET:string      "CustodiansQuintessenceTriplet")

    ;; ONE number sets both published thresholds. `unit-score` is quintessence per capture
    ;; unit -- "1 staking unit = 1 node" -- and UEV_OpenGate (08_DSA.pact:672) requires only
    ;; HALF of it to open an agency:
    ;;     (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec unit-score) 2.0)))
    ;; So 20000 => a node at 20000 and an agency at 10000. Do not add a second constant for
    ;; the agency gate; there is no second knob, and inventing one would let the two drift.
    (defconst BOOT|CUSTODIANS_UNIT_SCORE:integer        20000)

    ;; HETEROGENEOUS quality split, per-mille, each row summing to 1000. Rows are read as
    ;; [to-t0 to-t1 to-t2] against the MULTIPLET ladder, which for this vault is the
    ;; OURO|AURYN|ELITEAURYN family from Step 10 -- so t0=OURO, t1=Auryn, t2=Elite-Auryn.
    ;;   bronze  20% OURO / 40% Auryn / 40% Elite-Auryn
    ;;   silver  40% / 30% / 30%
    ;;   golden  60% / 20% / 20%
    (defconst BOOT|CUSTODIANS_SPLIT_BRONZE:[integer]    [200 400 400])
    (defconst BOOT|CUSTODIANS_SPLIT_SILVER:[integer]    [400 300 300])
    (defconst BOOT|CUSTODIANS_SPLIT_GOLDEN:[integer]    [600 200 200])

    ;; QUINTESSENCE PER CUSTODIANS UNIT — owner values, 2026-09-19.
    ;;     nonce 1 Bronze   1 000 whole   ·  1  per fragment
    ;;     nonce 2 Silver  10 000 whole   ·  10 per fragment
    ;;     nonce 3 Golden 100 000 whole   ·  100 per fragment
    ;;     nonce 4 OG      1 000, GOLDEN type, NOT fragmentable — plus a 5% anchor boost (below)
    ;;
    ;; WHY WHOLE AND FRAGMENT CARRY THE SAME NUMBER. URCx_SfStakeDefinitionWeightedRawWeight
    ;; scales a NEGATIVE (fragment) nonce by 0.001 and a whole by 1.0, and one whole splits into
    ;; exactly 1000 fragments. So a single value per tier expresses both:
    ;;     1 whole bronze      = 1000 x 1.000 x 1    = 1000
    ;;     1000 bronze frags   = 1000 x 0.001 x 1000 = 1000
    ;;     1 bronze fragment   = 1000 x 0.001 x 1    = 1
    ;; Listing only the negatives (as the Kursan DSA fixtures do) would make a WHOLE nonce score
    ;; ZERO. <<TX-BOOT-14>> stakes whole nonces precisely to keep that path honest.
    ;;
    ;; CORRECTED 2026-09-19: these were 1.0 / 10.0 / 100.0 — the right RATIO but 1000x too small,
    ;; taken from the collection's "a third of ownership over 10000/1000/100 units" description
    ;; rather than from the quintessence schedule. The ratio held, so every test still passed;
    ;; only the absolute scale was wrong, which is the kind of error a ratio-preserving fixture
    ;; cannot see. It matters: the whole collection is 30,000,000 quintessence, not 30,000, so at
    ;; unit-score 20000 it supports ~1500 capture units rather than one.
    (defconst BOOT|CUSTODIANS_NONCES_BRONZE:[integer]   [1 -1])
    (defconst BOOT|CUSTODIANS_NONCES_SILVER:[integer]   [2 -2])
    (defconst BOOT|CUSTODIANS_NONCES_GOLDEN:[integer]   [3 -3 4])
    (defconst BOOT|CUSTODIANS_VALUE_BRONZE:[decimal]    [1000.0 1000.0])
    (defconst BOOT|CUSTODIANS_VALUE_SILVER:[decimal]    [10000.0 10000.0])
    ;; Golden carries nonce 4 as a THIRD entry: the OG Founder SFT scores 1000 of the golden
    ;; type. It has no fragment negative because nonce 4 is not fragmentable.
    (defconst BOOT|CUSTODIANS_VALUE_GOLDEN:[decimal]    [100000.0 100000.0 1000.0])

    ;; NONCE 4 IS ALSO AN ANCHOR — +5% on the staked quintessence, owner ruling 2026-09-19.
    ;; ank-promile is per-mille and the boost is ADDITIVE (02_SCORE.pact: boosted = base x
    ;; promile/1000, stored as the boost PART, not a replacement), so 5% is 50.0.
    ;; The anchor is issued ONCE with the vault (Step 13); each agency's three scores link to
    ;; the class in Step 14, which is why the boost lands on the user's WHOLE staked
    ;; quintessence and not just the golden lane.
    (defconst BOOT|CUSTODIANS_OG_ANCHOR:string          "CustodiansOgFounder")
    (defconst BOOT|CUSTODIANS_OG_BOOST_CLASS:string     "CustodiansOgBoost")
    (defconst BOOT|CUSTODIANS_OG_PROMILE:decimal        50.0)
    (defconst BOOT|CUSTODIANS_OG_NONCE:integer          4)
    (defconst BOOT|CUSTODIANS_ANK_PRECISION:integer     3)
    (defconst BOOT|CUSTODIANS_PRECISION:integer         24)
    ;;Mirrors AQP-FVT/RPS CT_REWARD_MODE_HETEROGENEOUS. Restated rather than referenced because a
    ;;defconst is not reachable through a module reference -- (ref-FVT::CT_...) is "Cannot apply
    ;;value to non-closure". Pinned against the real thing by <<TX-BOOT-13>>, which reads the mode
    ;;back out of RPS after Step 13 writes it, so a drift in either spelling fails the suite.
    (defconst BOOT|REWARD_MODE_HETEROGENEOUS:string     "HETEROGENEOUS")
    (defconst BOOT|TREASURY_COMMON:string               "|")
    (defconst BOOT|SCORE_ENTITY_SCORE:integer           1)
    (defconst BOOT|SCORE_ENTITY_TRIPLET:integer         3)
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
    ;;
    ;;Step 0 - Wire AQP sovereign IMC policies + AQP|SC_NAME vault governor (run once after module deploy)
    ;;Step 1 - Create the Bunny Set Definition
    ;;Step 2 - Create the BronzeSnakePower, SilverSnakePower and GoldenSnakePower Anchor-Class Definitions
    ;;Step 3 - Create the UnityBooster, StoaBooster and VestaBooster Anchor-Class Definitions
    ;;Step 4 - Create the TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes Score Definitions
    ;;Step 5 - Create the SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu and SubsidiaryBunnies Score Definitions
    ;;Step 6 - Create the Ouro LP Triplet Score Definition
    ;;Step 7 - Create six DH pools (class 3/4 by entity) + class-0 OURO LP pool; assign Step4/5/6 scores
    ;;Step 8 - Issue five FVT entities (farm + vault treasuries) — C_Issue only
    ;;Step 9 - C_AddScoreEntity (type 1) on vault/treasury FVT entities (not farm LP triplet)
    ;;Step 10 - C_IssueMultipletFamily (OURO / Auryn / Elite-Auryn ATS ladder)
    ;;Step 11 - C_IssueTriplet + C_AddScoreEntity (type 3) + C_AddRewardLink (OURO + multiplet-family) on OuroLpFarm
    ;;Step 12 - C_AddRewardLink on vault/treasury FVT entities (plain rewards)

    ;;<=========================================================================>
    ;;{5.4}  Validate [UEV]
    ;;
    (defun UEV_BootStepState (step-name:string what:string actual:integer expected:integer)
        @doc "Refuses a bootstrap step whose CHAIN STATE says it has already completed. \
            \ \
            \ WHY THIS EXISTS, 2026-10-02. These steps are one-shot populators and none of \
            \ them was re-run-safe. Every id they create comes from U|DALOS::UDC_Makeid, \
            \ which seeds on <prev-block-hash> -- block-level, not per-tx. A second run in \
            \ the SAME block collides on a raw insert and aborts, which looks like protection \
            \ and is not: a second run in a LATER block gets fresh ids, inserts cleanly, and \
            \ leaves a COMPLETE DUPLICATE set of entities with no error anywhere. \
            \ \
            \ Observed on mainnet. C_DefinePrimordialSet computes (set-class = used + 1) and \
            \ inserts at that fresh key, so re-running Step 1 does not fail -- it adds a \
            \ second <Bunny RGB Set> at class 2, identically named, with the same recipe, and \
            \ the same 120 nonces then compose into either. \
            \ \
            \ A CHAIN-STATE CHECK, NOT A STEP LEDGER, and the difference is the point. A \
            \ ledger records that this module ran something; the state records that the THING \
            \ EXISTS. Only the second is true retroactively -- it refuses Step 1 on a chain \
            \ where the set was created before this guard was written, which no ledger row \
            \ could do. It also cannot drift from reality, which a ledger can."
        (enforce (= actual expected)
            (format
                "AQP-BOOT {} refused: {} is {}, expected {}. Either this step already ran -- \
                \ it is NOT re-runnable, a second run creates DUPLICATE entities rather than \
                \ failing -- or its predecessor step has not."
                [step-name what actual expected]
            )
        )
    )

    (defun C_Step0_WireImcAndGovernor:string
        (patron:string)
        @doc "Step 0 — AQP-POOL TFT + DPOF IMC + AQP|SC_NAME governor rotate. \
            \ Run once after all four sovereign AQP modules are on chain (before stake/unstake or Step 1+). \
            \ Prerequisite: AQP|SC_NAME smart account deployed (DALOS|A_DeploySmartAccount). \
            \ Talos TS02-C3 P|A_Define (P|TALOS-SUMMONER) is separate — sovereign executor / [4.0]. \
            \ FVT + VCT P|A_Define register IMP; FVT|RemoteAqpGov + VCT|RemoteAqpGov on AQP-POOL for vault legs."
        ;; INPUT
        ;;   patron — gas payer konto (REPL: KST.ANHD)
        ;; REPL: (AQP-BOOT.C_Step0_WireImcAndGovernor KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                    (ref-P|RPS:module{OuronetPolicyV2} RPS)
                    (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                    (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (aqp-sc:string (ref-ANK::GOV|AQP|SC_NAME))
                )
                (ref-P|AQP::P|A_Define)
                (ref-P|RPS::P|A_Define)   ;; #75 B': RPS reward engine registers its guards on deps (royalty disposal)
                (ref-P|FVT::P|A_Define)
                (ref-P|VCT::P|A_Define)
                ;; C_RotateGovernor — AQP|SC_NAME: AQP-POOL.AQP|GOV (stake) + FVT|RemoteAqpGov + VCT|RemoteAqpGov.
                (ref-TS01-C1::DALOS|C_RotateGovernor patron aqp-sc
                    (let
                        (
                            (ref-U|G:module{OuronetGuardsV2} U|G)
                        )
                        (ref-U|G::UEV_GuardOfAny
                            [
                                (create-capability-guard (AQP-POOL.AQP|GOV))
                                (ref-P|AQP::P|UR "FVT|RemoteAqpGov")
                                (ref-P|AQP::P|UR "VCT|RemoteAqpGov")
                            ]
                        )
                    )
                )
                (format "AQP-BOOT Step 0 done. aqp-sc={}. TFT+DPOF IMC + gov wired. NEXT=Step1 or client txs." [aqp-sc])
            )
        )
    )
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
        @doc "Step 1 — Create Bunny set definition on KBN. INPUT: kbn-id from chain deploy. \
            \ OUTPUT echo: kbn-id. NEXT: Steps 2 and 3 use the same kbn-id."
        ;; INPUT
        ;;   patron   — gas payer konto (REPL: KST.ANHD)
        ;;   kbn-id   — KBN collection id already on chain (REPL: "KBN-98c486052a51")
        ;; OUTPUT (return string)
        ;;   kbn-id echoed — pass unchanged to Steps 2 and 3
        ;; REPL: (AQP-BOOT.C_Step1_CreateBunnySet KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;AUTHORISATION FIRST (2026-09-14 ruling): the admin gate is acquired by the
            ;;with-capability above, so a non-admin is refused before this business check is
            ;;reached and the check can never be what shadows the gate.
            (UEV_BootStepState "Step1" "set-classes-used on the collection"
                (DPDC.UR_SetClassesUsed kbn-id false) 0)
            ;;A DOT CALL, AND IT PINS KBN'S CODE INTO THIS MODULE at AQP-BOOT's deploy time.
            ;;KBN implements no interface, so there is nothing to modref -- which is why this is
            ;;the only non-modref call in the file. The consequence is not theoretical:
            ;;
            ;;  block 621,458  KBN upgraded to write the Arweave artwork
            ;;  block 621,472  THIS step ran and wrote the OLD placeholder strings
            ;;
            ;;because AQP-BOOT had not been redeployed and was still carrying the KBN it was
            ;;compiled against. The set had to be repaired by hand with C_UpdateSetNonceURI.
            ;;
            ;;SO: ANY KBN CHANGE REQUIRES REDEPLOYING AQP-BOOT. `_dotpin.py --upgrade KBN` says
            ;;so mechanically, and `--check` is gate-fatal on a new unregistered dot edge.
            (KBN.A_BunnyRGBSet patron kbn-id)
            (format "AQP-BOOT Step 1 done. kbn-id={}. NEXT=Step2,Step3:kbn-id={}." [kbn-id kbn-id])
        )
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 2 — SnakePower anchor classes (Bronze/Silver/Golden). INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: Step 6 boost-class-ids=[Silver Bronze Golden]."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[4]       — OuroborosRain, AurynRain, EliteAurynRain, LegendarySnakeTokenRain
        ;;   boost-class-ids[3]  — emitted ONCE, in Step 6 order: silver, bronze, golden
        ;; NEXT
        ;;   Step 6: paste the bracketed list at the end of the output string directly into the
        ;;           `boost-class-ids` argument. It is already in Step 6 order (silver, bronze,
        ;;           golden) and already quoted. No reordering, no re-quoting.
        ;; REPL: (AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;Step 2 issues the collection's FIRST four anchors, so the asset's bookkeeping row
            ;;must still be empty. UR_AA|AnchorsActive is a with-default-read, so a collection
            ;;that has never been anchored answers 0 rather than aborting on a missing row.
            (UEV_BootStepState "Step2" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 0)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (bronze-boost-class-id:string (ref-U|DALOS::UDC_Makeid "BronzeSnakePower"))
                    (silver-boost-class-id:string (ref-U|DALOS::UDC_Makeid "SilverSnakePower"))
                    (golden-boost-class-id:string (ref-U|DALOS::UDC_Makeid "GoldenSnakePower"))
                    ;;
                    (anchor-ouroboros-rain-id:string (ref-U|DALOS::UDC_Makeid "OuroborosRain"))
                    (anchor-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "AurynRain"))
                    (anchor-elite-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "EliteAurynRain"))
                    (anchor-legendary-snake-token-rain-id:string (ref-U|DALOS::UDC_Makeid "LegendarySnakeTokenRain"))
                    ;;The EXECUTOR of an anchor issuance is the ANCHORED ASSET's owner, which is not
                    ;;necessarily the patron paying for it -- sovereign assets are owned by SMART
                    ;;accounts whose key the admin merely holds. Read it, never assume it.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "OuroborosRain" kbn-id true "BronzeSnakePower" 3 50.0 "Background" "Ouroboros Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "AurynRain" kbn-id true "SilverSnakePower" 3 100.0 "Background" "Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "EliteAurynRain" kbn-id true "GoldenSnakePower" 3 200.0 "Background" "Elite-Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendarySnakeTokenRain" kbn-id false golden-boost-class-id 3 400.0 "Rarity" "Legendary")
                ;;OUTPUT SHAPE CHANGED 2026-09-18, for deployment use.
                ;;
                ;;It used to print the three boost classes TWICE, in two different orders: first
                ;;`boost-class-ids=[bronze silver golden]` (creation order) and then
                ;;`NEXT=Step6:[silver bronze golden]` (consumption order). An operator copying the
                ;;first list into Step 6 would wire the 50.0-weight class where the 100.0 belongs,
                ;;and NOTHING WOULD ERROR -- the pools would simply pay the wrong boosts forever.
                ;;
                ;;Now it prints them ONCE, in Step 6's order, as a QUOTED PACT LIST that can be
                ;;pasted straight into the `boost-class-ids` argument with no reordering and no
                ;;re-quoting. A format an operator has to transform is a format that will
                ;;eventually be transformed wrongly.
                ;;
                ;;No test asserts on this string -- both call sites are `print` -- so the change
                ;;breaks nothing. Verified before editing.
                (format "AQP-BOOT Step 2 done. kbn-id={}. anchors issued=[{} {} {} {}]. \
                        \ PASTE INTO Step6 boost-class-ids (silver bronze golden, already ordered): \
                        \ [\"{}\" \"{}\" \"{}\"]"
                    [
                        kbn-id
                        anchor-ouroboros-rain-id anchor-auryn-rain-id
                        anchor-elite-auryn-rain-id anchor-legendary-snake-token-rain-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 3 — Unity/Stoa/Vesta booster anchor classes. INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: none required for Steps 4–7 (user ANK boosting)."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[11], boost-class-ids[3] — UnityBooster, StoaBooster, VestaBooster
        ;; REPL: (AQP-BOOT.C_Step3_CreateBoosterAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;EXACTLY FOUR, not "at least four". Step 2 leaves 4 and Step 3 adds 11, so 4 is the
            ;;only count that means "Step 2 done, Step 3 not" -- it pins the predecessor and the
            ;;re-run in one check. A >= would admit a second run of Step 3 at 15.
            (UEV_BootStepState "Step3" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 4)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (unity-boost-class-id:string (ref-U|DALOS::UDC_Makeid "UnityBooster"))
                    (stoa-boost-class-id:string (ref-U|DALOS::UDC_Makeid "StoaBooster"))
                    (vesta-boost-class-id:string (ref-U|DALOS::UDC_Makeid "VestaBooster"))
                    ;;
                    (anchor-elk0nite-id:string (ref-U|DALOS::UDC_Makeid "Elk0nite"))
                    (anchor-osmiridium-id:string (ref-U|DALOS::UDC_Makeid "Osmiridium"))
                    (anchor-titanium-id:string (ref-U|DALOS::UDC_Makeid "Titanium"))
                    (anchor-legendary-unity-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryUnityBooster"))
                    (anchor-vegold-eyes-id:string (ref-U|DALOS::UDC_Makeid "VegoldEyes"))
                    (anchor-legendary-stoa-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryStoaBooster"))
                    (anchor-red-eyes-id:string (ref-U|DALOS::UDC_Makeid "RedEyes"))
                    (anchor-green-eyes-id:string (ref-U|DALOS::UDC_Makeid "GreenEyes"))
                    (anchor-blue-eyes-id:string (ref-U|DALOS::UDC_Makeid "BlueEyes"))
                    (anchor-legendary-vesta-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryVestaBooster"))
                    (anchor-rgb-eyes-id:string (ref-U|DALOS::UDC_Makeid "RGBEyes"))
                    ;;Anchor executor = the anchored asset's owner, read not assumed.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                ;; Unity
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Elk0nite" kbn-id true "UnityBooster" 3 100.0 "Eyes" "Elk0nite Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Osmiridium" kbn-id false unity-boost-class-id 3 300.0 "Eyes" "Osmiridium Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Titanium" kbn-id false unity-boost-class-id 3 900.0 "Eyes" "Titaniumgold Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryUnityBooster" kbn-id false unity-boost-class-id 3 1000.0 "Rarity" "Legendary")
                ;; Stoa
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "VegoldEyes" kbn-id true "StoaBooster" 3 1000.0 "Eyes" "vEGLD Focus")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryStoaBooster" kbn-id false stoa-boost-class-id 3 3500.0 "Rarity" "Legendary")
                ;; Vesta
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "RedEyes" kbn-id true "VestaBooster" 3 250.0 "Eyes" "Red")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "GreenEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Green")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "BlueEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Blue")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryVestaBooster" kbn-id false vesta-boost-class-id 3 3500.0 "Rarity" "Legendary")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleSetAnchor patron kbn-owner "RGBEyes" kbn-id false vesta-boost-class-id 3 1000.0 1)
                (format "AQP-BOOT Step 3 done. kbn-id={}. anchor-ids=[{} {} {} {} {} {} {} {} {} {} {}]. boost-class-ids=[unity={} stoa={} vesta={}]. NEXT=none-for-Steps4-7."
                    [
                        kbn-id
                        anchor-elk0nite-id anchor-osmiridium-id anchor-titanium-id anchor-legendary-unity-booster-id
                        anchor-vegold-eyes-id anchor-legendary-stoa-booster-id
                        anchor-red-eyes-id anchor-green-eyes-id anchor-blue-eyes-id anchor-legendary-vesta-booster-id anchor-rgb-eyes-id
                        unity-boost-class-id stoa-boost-class-id vesta-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
        @doc "Step 4 — Core scores (SF/NF). OUTPUT: score-ids ×4. NEXT: Step7 dh-score-ids slots 0,2,4,5."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids (UDC_Makeid names):
        ;;   TheCodingDivision, Bloodshed, DemiourgosShareholder, DemiourgosSnakes
        ;; NEXT Step 7 dh-score-ids[0,2,4,5] = these four ids (see README_AQP_BOOT.md index map)
        ;; REPL: (AQP-BOOT.C_Step4_CreateCoreScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (score-coding:string (ref-U|DALOS::UDC_Makeid "TheCodingDivision"))
                    (score-bloodshed:string (ref-U|DALOS::UDC_Makeid "Bloodshed"))
                    (score-company-share:string (ref-U|DALOS::UDC_Makeid "DemiourgosShareholder"))
                    (score-company-snakes:string (ref-U|DALOS::UDC_Makeid "DemiourgosSnakes"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "TheCodingDivision" 3 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "Bloodshed" 6 0)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosShareholder" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosSnakes" 6 false)
                (format "AQP-BOOT Step 4 done. score-ids=[coding={} bloodshed={} company-share={} company-snakes={}]. NEXT=Step7:dh-score-ids[0,2,4,5]=[{} {} {} {}]."
                    [
                        score-coding score-bloodshed score-company-share score-company-snakes
                        score-coding score-bloodshed score-company-share score-company-snakes
                    ]
                )
            )
        )
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
        @doc "Step 5 — Subsidiary scores. OUTPUT: score-ids ×5. NEXT: Step7 dh-score-ids slots 1,3,6,7,8."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids:
        ;;   SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu, SubsidiaryBunnies
        ;; NEXT Step 7 dh-score-ids[1,3,6,7,8] = these five ids
        ;; REPL: (AQP-BOOT.C_Step5_CreateSubsidiaryScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (score-sub-coding:string (ref-U|DALOS::UDC_Makeid "SubsidiaryCodingDivision"))
                    (score-sub-wondercoach:string (ref-U|DALOS::UDC_Makeid "SubsidiaryWonderCoach"))
                    (score-sub-bloodshed:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBloodshed"))
                    (score-sub-nosferatu:string (ref-U|DALOS::UDC_Makeid "SubsidiaryNosferatu"))
                    (score-sub-bunnies:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBunnies"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryCodingDivision" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryWonderCoach" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBloodshed" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryNosferatu" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBunnies" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-coding)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-wondercoach)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bloodshed)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-nosferatu)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bunnies)
                ;;ORDERING BUG FIXED 2026-09-18. The `NEXT=Step7:dh-score-ids[1,3,6,7,8]` list used
                ;;to be emitted in CREATION order -- coding, wondercoach, bloodshed, nosferatu,
                ;;bunnies -- while slots [1,3,6,7,8] are coding, BLOODSHED, WONDERCOACH, nosferatu,
                ;;bunnies. Positions 2 and 3 were transposed against the slots the same string
                ;;names. An operator pasting it into Step 7 would put SubsidiaryWonderCoach in slot
                ;;3 and SubsidiaryBloodshed in slot 6, so DHBloodshed would carry the WonderCoach
                ;;subsidiary score and DHWonderCoach the Bloodshed one -- PERMANENTLY, and WITHOUT
                ;;ERRORING, because both are valid score ids.
                ;;Now emitted in slot order, and as a quoted pasteable list. Same defect class as
                ;;Step 2's boost-class ordering, fixed the same day.
                (format "AQP-BOOT Step 5 done. score-ids=[sub-coding={} sub-wondercoach={} sub-bloodshed={} sub-nosferatu={} sub-bunnies={}] deb-boost=enabled×5. \
                        \ PASTE INTO Step7 dh-score-ids slots [1,3,6,7,8] IN THIS ORDER: \
                        \ [\"{}\" \"{}\" \"{}\" \"{}\" \"{}\"]"
                    [
                        score-sub-coding score-sub-wondercoach score-sub-bloodshed score-sub-nosferatu score-sub-bunnies
                        score-sub-coding score-sub-bloodshed score-sub-wondercoach score-sub-nosferatu score-sub-bunnies
                    ]
                )
            )
        )
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
        @doc "Step 6 — Issue OURO LP triplet **scores only** (Silver/Bronze/Golden class-0). \
            \ Does not create a pool or farm links — wire those in Step 7 (first LP) or manually per new LP line."
        ;;
        ;; WHAT THIS STEP DOES (scores only — no pool, no FVT)
        ;; Creates three class-0 liquidity scores sharing one lp-denominator (full OURO DPTF id):
        ;;   SilverSnakePower  — primary; owns user base-score for the triplet boost chain
        ;;   BronzeSnakePower  — foreign boost-link → Silver
        ;;   GoldenSnakePower  — foreign boost-link → Silver
        ;; Each score also gets a boost-class-link from Step 2 anchor classes.
        ;;
        ;; lp-denominator — full native DPTF id of the OURO pool leg (NOT ticker "OURO"):
        ;;   REPL example: "OURO-98c486052a51"
        ;;   Must match the Farm FVT common-denominator when scores are later admitted to a farm.
        ;;
        ;; boost-class-ids[0..2] — from Step 2 (SnakePower anchor classes).
        ;;
        ;; !! MAINNET: PASTE THESE FROM STEP 2's OUTPUT. DO NOT RECOMPUTE THEM.
        ;; The `UDC_Makeid` forms shown below are the REPL shape, and they are correct ONLY when
        ;; Step 2 ran in the same block -- which is true in the REPL (one prev-block-hash for the
        ;; whole suite) and false on mainnet, where Step 2 is its own transaction. Recomputing here
        ;; yields three ids that do not exist, the triplet wires to nothing, and no test can catch
        ;; it. Step 2's output ends with a ready-to-paste `["silver" "bronze" "golden"]` list for
        ;; exactly this argument.
        ;;
        ;;   0 silver-boost-class-id  e.g. (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   1 bronze-boost-class-id  e.g. (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   2 golden-boost-class-id  e.g. (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; Score ids created (fixed names — first OURO LP line only):
        ;;   (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; AFTER Step 6 — per LP line (full flow: README.md § OURO LP onboarding flow):
        ;;   1. C_Issue class-0 pool (DHOuroLp) with native LP asset-id  ← Step 7
        ;;   2. C_AddScore × 3 — employ triplet on that pool              ← Step 7
        ;;   3. Users stake LP into pool → SCORE user rows update
        ;;   4. C_AddScoreEntity (type 3) on shared Farm FVT                     ← Step 11
        ;;   5. C_AddRewardLink (OURO, multiplet-family-id) on farm    ← Step 11
        ;;
        ;; SECOND OURO LP: repeat score issuance with **new score names** (cannot reuse ids),
        ;; then new pool + C_AddScore × 3 + C_IssueTriplet + C_AddScoreEntity (type 3) on the same farm.
        ;;
        ;; REPL call (after Steps 2–3 anchor classes exist):
        ;; (AQP-BOOT.C_Step6_CreateOuroLpTriplet
        ;;   KST.ANHD
        ;;   KST.ANHD
        ;;   "OURO-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
            ;;It used to sit BELOW a `let` that already did `(at 0 boost-class-ids)`, `(at 1 …)` and
            ;;`(at 2 …)`. A `let` is EAGER, so for a SHORT list those indexes ran first and the
            ;;operator got `Array index out of bounds` instead of the sentence naming the argument.
            ;;The message only ever arrived for a list that was too LONG -- the one case the `at`s
            ;;survive. C_Step9 in this same file is the correctly-ordered twin, so the fix was
            ;;demonstrated in place. A length test needs nothing but the parameter, so it can run
            ;;before anything is derived. Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
            (enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    ;;
                    (silver-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_SILVER))
                    (bronze-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_BRONZE))
                    (golden-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_GOLDEN))
                    ;;
                    (silver-boost-class-id:string (at 0 boost-class-ids))
                    (bronze-boost-class-id:string (at 1 boost-class-ids))
                    (golden-boost-class-id:string (at 2 boost-class-ids))
                )
                ;; [1..2] Silver
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_SILVER BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto silver-id silver-boost-class-id)
                ;; [3..5] Bronze
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_BRONZE BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto bronze-id bronze-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto bronze-id silver-id)
                ;; [6..8] Golden
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_GOLDEN BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto golden-id golden-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto golden-id silver-id)
                ;;
                (format "AQP-BOOT Step 6 done. lp-denominator={}. score-ids=[silver={} bronze={} golden={}]. \
                        \ boost-class-ids-IN=[{} {} {}]. boost-links=[{}->{} {}->{}]. \
                        \ PASTE INTO Step7 ouro-triplet-score-ids (these are the SCORES made here, \
                        \ NOT the Step 2 boost classes of the same name): [\"{}\" \"{}\" \"{}\"]."
                    [
                        lp-denominator
                        silver-id bronze-id golden-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                        bronze-id silver-id golden-id silver-id
                        silver-id bronze-id golden-id
                    ]
                )
            )
        )
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string dh-asset-ids:[string] ouro-lp-asset-id:string dh-score-ids:[string] ouro-triplet-score-ids:[string])
        @doc "Step 7 — Issue six DH pools (class 3 or 4 by entity) plus one class-0 OURO LP pool and assign existing scores. \
            \ All ids are caller-supplied so this step can run after Steps 4–6 in separate transactions. \
            \ Pool aqp-class is fixed per entity (see ;; block). This step does not create FVT links."
        ;;
        ;; POOL MAP (aqp-class is fixed in code — pass the matching native collection id in dh-asset-ids)
        ;; | Pool name         | aqp-class | pass in dh-asset-ids     | Scores attached                                         |
        ;; | DHCodingDivision  | 3 DPSF    | DHCD-… dpsf-id           | TheCodingDivision, SubsidiaryCodingDivision             |
        ;; | DHBloodshed       | 4 DPNF    | DHB-… dpnf-id            | Bloodshed, SubsidiaryBloodshed                          |
        ;; | DHCompany         | 3 DPSF    | E|DH-… dpsf-id           | DemiourgosShareholder, DemiourgosSnakes                 |
        ;; | DHWonderCoach     | 3 DPSF    | DHWC-… dpsf-id           | SubsidiaryWonderCoach + the UI-issued CORE WonderCoach  |
        ;; | DHNosferatu       | 4 DPNF    | DHN-… dpnf-id            | SubsidiaryNosferatu + the UI-issued CORE Nosferatu      |
        ;; | DHBunnies         | 4 DPNF    | KBN-… dpnf-id            | SubsidiaryBunnies                                       |
        ;; | DHOuroLp          | 0 LP      | native LP id             | SilverSnakePower, BronzeSnakePower, GoldenSnakePower    |
        ;;
        ;; dh-asset-ids[0..5] — REPL examples (replace suffix with mainnet hash):
        ;;   0 "DHCD-98c486052a51"
        ;;   1 "DHB-98c486052a51"
        ;;   2 "E|DH-98c486052a51"
        ;;   3 "DHWC-98c486052a51"
        ;;   4 "DHN-98c486052a51"
        ;;   5 "SBN-98c486052a51"   (the Bunnies collection is SBN-, not KBN-)
        ;; ouro-lp-asset-id — e.g. "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;
        ;; dh-pool-ids[0..5]:
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;; ouro-lp-pool-id — (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;
        ;; !! MAINNET, AND THE TWO HALVES OF THIS STEP BEHAVE DIFFERENTLY:
        ;;
        ;;   dh-pool-ids / ouro-lp-pool-id  -- SAFE to recompute with UDC_Makeid. This step CREATES
        ;;      those pools, in this transaction, so the id it derives is the id it makes. The
        ;;      `UDC_Makeid "DHCodingDivision"` forms above are correct on mainnet.
        ;;
        ;;   dh-score-ids / ouro-triplet-score-ids  -- MUST BE PASTED FROM EARLIER OUTPUTS. The
        ;;      nine scores are created in Steps 4 and 5, the three triplet scores in Step 2, all
        ;;      in their own transactions and therefore their own blocks. The `UDC_Makeid` forms
        ;;      below are the REPL shape and are WRONG on mainnet. They look right, they typecheck,
        ;;      and the suite passes -- because the REPL runs every step under one prev-block-hash.
        ;;      Take these ids from the return strings of Steps 2, 4 and 5.
        ;;
        ;; dh-score-ids[0..10] — 0-8 from Steps 4-5; 9-10 are the UI-issued CORE scores:
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed
        ;;    DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu
        ;;    SubsidiaryBunnies  <core-wondercoach>  <core-nosferatu>]
        ;; ouro-triplet-score-ids[0..2] — from Step 6:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;; !! THE CALL TAKES FIVE ARGUMENTS. This example used to show SEVEN -- it still passed
        ;; !! `dh-pool-ids` and `ouro-lp-pool-id`, which were removed when this step started MINTING
        ;; !! those pools and deriving their ids itself. Pasting the old shape gives an arity error,
        ;; !! and the example is the thing an operator actually copies. Corrected 2026-10-06.
        ;;
        ;; REPL call (copy/paste; swap ids for mainnet):
        ;; (AQP-BOOT.C_Step7_CreatePoolsAndScores
        ;;   KST.ANHD
        ;;   ["DHCD-98c486052a51" "DHB-98c486052a51" "E|DH-98c486052a51" "DHWC-98c486052a51" "DHN-98c486052a51" "SBN-98c486052a51"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision")
        ;;    (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed")
        ;;    (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryBunnies")
        ;;    (U|DALOS.UDC_Makeid "WonderCoach") (U|DALOS.UDC_Makeid "Nosferatu")]
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: all FOUR length checks are enforced HERE, above the binding group.
            ;;They used to sit BELOW a `let` that indexes every one of these lists -- (at 0 dh-score-ids)
            ;;through (at 8 dh-score-ids), and so on. A `let` is EAGER, so for any list that was too
            ;;SHORT the indexes ran first and the operator got `Array index out of bounds` instead of
            ;;the sentence naming which argument was wrong. Six operator-facing messages in this file
            ;;arrived only when a list was too LONG -- the one case the `at`s survive.
            ;;C_Step9 in this same file is the correctly-ordered twin. Length tests need nothing but
            ;;the parameters, so they run before anything is derived.
            ;;Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
                (enforce (= (length dh-asset-ids) 6) "Step 7 expects dh-asset-ids=[coding bloodshed company wondercoach nosferatu bunnies].")
                (enforce (= (length dh-score-ids) 11) "Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies core-wondercoach core-nosferatu].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    ;;
                    (asset-coding:string (at 0 dh-asset-ids))
                    (asset-coding-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-coding))
                    (asset-bloodshed:string (at 1 dh-asset-ids))
                    (asset-bloodshed-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bloodshed))
                    (asset-company:string (at 2 dh-asset-ids))
                    (asset-company-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-company))
                    (asset-wondercoach:string (at 3 dh-asset-ids))
                    (asset-wondercoach-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-wondercoach))
                    (asset-nosferatu:string (at 4 dh-asset-ids))
                    (asset-nosferatu-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-nosferatu))
                    (asset-bunnies:string (at 5 dh-asset-ids))
                    (asset-bunnies-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bunnies))
                    ;;
                    ;;POOL IDS ARE DERIVED HERE, NOT PASSED IN. Changed 2026-09-18.
                    ;;They used to be two arguments -- `dh-pool-ids` (6) and `ouro-lp-pool-id` --
                    ;;which the caller had to supply. But this step MINTS these seven pools, from
                    ;;the very name literals used in the C_Issue calls below, in this transaction.
                    ;;`UDC_Makeid` on the same literal in the same transaction therefore returns
                    ;;exactly the id C_Issue is about to create. Passing them in could only ever
                    ;;match or be wrong; it could never be MORE right.
                    ;;
                    ;;Removing them takes seven values off the caller, removes one of the four
                    ;;length guards, and removes an entire class of operator error on mainnet.
                    ;;What remains as arguments is precisely what this step CANNOT know: the six
                    ;;live collection assets, and the twelve scores created in earlier blocks.
                    ;;THE POOL OWNERS ARE RESOLVED FROM THE ASSET, NOT READ FROM THE POOL ROW.
                    ;;
                    ;;FIXED 2026-10-06. These seven were `(AQP-POOL.URC_AqpOwnerKonto pool-X)` --
                    ;;a read of `AQP|T|Pool` for a pool THIS TRANSACTION HAS NOT CREATED YET. A
                    ;;Pact `let` is EAGER, so all seven ran before the `C_Issue` calls in the body
                    ;;below, and the step aborted on the first one:
                    ;;
                    ;;    No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: DHCodingDi...
                    ;;
                    ;;Step 7 could therefore never have succeeded, on any chain, since the day it
                    ;;was written.
                    ;;
                    ;;THE VALUE IS IDENTICAL, which is why this is a fix and not a workaround:
                    ;;`URC_AqpOwnerKonto` is DEFINED as
                    ;;`(URC_AqpOwnerKontoFromClassAndAsset (UR_AQP|PoolAqpClass p) (UR_AQP|PoolAssetId p))`
                    ;;-- it resolves the governor from the pool's class and asset, having first
                    ;;read those two fields off the row. We already hold both as literals here, so
                    ;;the row lookup is the only thing being removed. The sibling resolver is
                    ;;documented for exactly this case: "issue-time or PRE-POOL-ROW".
                    ;;
                    ;;These are now the same bindings the `C_Issue` executor uses one block below,
                    ;;which is also the honest statement of the fact: the pool's governor IS the
                    ;;asset's governor.
                    (pool-coding:string (ref-U|DALOS::UDC_Makeid "DHCodingDivision"))
                    (pool-coding-owner:string asset-coding-owner)
                    (pool-bloodshed:string (ref-U|DALOS::UDC_Makeid "DHBloodshed"))
                    (pool-bloodshed-owner:string asset-bloodshed-owner)
                    (pool-company:string (ref-U|DALOS::UDC_Makeid "DHCompany"))
                    (pool-company-owner:string asset-company-owner)
                    (pool-wondercoach:string (ref-U|DALOS::UDC_Makeid "DHWonderCoach"))
                    (pool-wondercoach-owner:string asset-wondercoach-owner)
                    (pool-nosferatu:string (ref-U|DALOS::UDC_Makeid "DHNosferatu"))
                    (pool-nosferatu-owner:string asset-nosferatu-owner)
                    (pool-bunnies:string (ref-U|DALOS::UDC_Makeid "DHBunnies"))
                    (pool-bunnies-owner:string asset-bunnies-owner)
                    (pool-ouro-lp:string (ref-U|DALOS::UDC_Makeid "DHOuroLp"))
                    ;;
                    (score-coding:string (at 0 dh-score-ids))
                    (score-sub-coding:string (at 1 dh-score-ids))
                    (score-bloodshed:string (at 2 dh-score-ids))
                    (score-sub-bloodshed:string (at 3 dh-score-ids))
                    (score-company-share:string (at 4 dh-score-ids))
                    (score-company-snakes:string (at 5 dh-score-ids))
                    (score-sub-wondercoach:string (at 6 dh-score-ids))
                    (score-sub-nosferatu:string (at 7 dh-score-ids))
                    ;;THE TWO CORE SCORES, added 2026-10-06. They are NOT created by any boot step --
                    ;;the owner issues them from the UI, because they are deliberately NOT DEB-enhanced
                    ;;and carry hand-built weight tables (WonderCoach: per-nonce, rarity x set
                    ;;completeness; Nosferatu: one rarity worth twice the last). Steps 4-5 make the nine
                    ;;Subsidiary/primary scores; these two ride in beside them so the pool that stakes
                    ;;their collection scores BOTH -- the subsidiary weighting and the core one.
                    ;;Passed in rather than derived: UDC_Makeid would be wrong, exactly as it is for the
                    ;;other nine, because they were issued in their own blocks.
                    (score-core-wondercoach:string (at 9 dh-score-ids))
                    (score-core-nosferatu:string (at 10 dh-score-ids))
                    (score-sub-bunnies:string (at 8 dh-score-ids))
                    (score-silver:string (at 0 ouro-triplet-score-ids))
                    (score-bronze:string (at 1 ouro-triplet-score-ids))
                    (score-golden:string (at 2 ouro-triplet-score-ids))
                    ;;The LP pool's executor is the LP token's owner konto -- read, not assumed.
                    (ouro-lp-asset-owner:string
                        (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 0 ouro-lp-asset-id))
                )
                ;;
                ;; [1] DHCodingDivision — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-coding-owner "DHCodingDivision" asset-coding 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-coding)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-sub-coding)
                ;; [2] DHBloodshed — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bloodshed-owner "DHBloodshed" asset-bloodshed 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-bloodshed)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-sub-bloodshed)
                ;; [3] DHCompany — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-company-owner "DHCompany" asset-company 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-share)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-snakes)
                ;; [4] DHWonderCoach — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-wondercoach-owner "DHWonderCoach" asset-wondercoach 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach-owner pool-wondercoach score-sub-wondercoach)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach-owner pool-wondercoach score-core-wondercoach)
                ;; [5] DHNosferatu — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-nosferatu-owner "DHNosferatu" asset-nosferatu 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-sub-nosferatu)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-core-nosferatu)
                ;; [6] DHBunnies — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bunnies-owner "DHBunnies" asset-bunnies 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies-owner pool-bunnies score-sub-bunnies)
                ;; [7] DHOuroLp — aqp-class 0 (LP); triplet from Step 6 — see Step 6 ;; for OURO LP flow
                (ref-TS02-C3::AQP-POOL|C_Issue patron ouro-lp-asset-owner "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[coding={} bloodshed={} company={} wondercoach={} nosferatu={} bunnies={} ouro-lp={}]. ouro-lp-asset-id={}. score-slots-wired=14. NEXT=Step8:C_Step8_IssueFvtEntities."
                    [
                        pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies pool-ouro-lp
                        ouro-lp-asset-id
                    ]
                )
            )
        )
    )
    (defun C_Step8_IssueFvtEntities:string
        (patron:string owner-konto:string lp-denominator:string)
        @doc "Step 8 — Issue five production FVT entities (C_Issue only). \
            \ OuroLpFarm class 0 when lp-denominator non-empty (same OURO DPTF id as Step 6). \
            \ Four class-1 vault treasuries with common-denominator '|'. \
            \ Product names say Treasury; they are issued at fvt-class 1. \
            \ !! 2026-09-19: TWO SOVEREIGN ADMISSION RULES DISAGREE ABOUT WHAT CLASS 1 MEANS. \
            \ URC_ScoreClassMatchesFvtClass (05_FVT.pact) says vault(1) admits score-class 1/3/4 \
            \ = TF/SF/NF and treasury(2) admits 2 = OF. URC_TripletCategoryMatchesFvtClass \
            \ (02_SCORE.pact) says VAULT_TF<->1 and TREASURY_SF_NF<->2, i.e. vault = TF only and \
            \ treasury = SF/NF. The schema comment at 05_FVT.pact:580 reads 0=Farm 1=Vault \
            \ 2=Treasury. Owner intent (2026-09-19): vaults take TF and OF, treasuries take SF \
            \ and NF -- which the TRIPLET rule matches and the SCORE rule does not. \
            \ This step issues four entities NAMED Treasury at class 1, and Step 9 links SF/NF \
            \ subsidiary scores to them; that passes only because the score rule permits 3/4 at \
            \ class 1. UNRESOLVED -- do not treat either rule as authoritative until ruled on. \
            \ NEXT=Step9 vault score links, Steps 10–11 farm triplet — pass fvt-ids from this output."
        ;;
        ;; INPUT
        ;;   patron, owner-konto — FVT owner (REPL: KST.ANHD)
        ;;   lp-denominator — full OURO DPTF id for OuroLpFarm; pass \"\" to skip farm (vault-only bootstrap)
        ;; OUTPUT — fvt-ids ×6 (farm skipped → echo farm=skipped)
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (farm-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_OURO_LP_FARM))
                    (sub-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SUBSIDIARY_TREASURY))
                    (coding-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CODING_TREASURY))
                    (snakes-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SNAKES_TREASURY))
                    (shares-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SHARES_TREASURY))
                    (bloodshed-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_BLOODSHED_TREASURY))
                )
                (if (!= lp-denominator "")
                    (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_OURO_LP_FARM 0 lp-denominator)
                    true
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SUBSIDIARY_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CODING_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SNAKES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SHARES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_BLOODSHED_TREASURY 2 BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8 done. fvt-ids=[farm={} sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={} bloodshed-treasury={}]. NEXT=Step9:C_AddScoreEntity."
                    [
                        (if (!= lp-denominator "") farm-id "skipped")
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step9_AddFvtScoreEntities:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string subsidiary-score-ids:[string] coding-score-id:string snakes-score-id:string shares-score-id:string bloodshed-score-id:string)
        @doc "Step 9 — Admit score entities (type 1) on vault/treasury FVT entities only. \
            \ SubsidiaryTreasury: five subsidiary scores. \
            \ CodingDivisionTreasury: TheCodingDivision. SnakesTreasury: DemiourgosSnakes. \
            \ CompanySharesTreasury: DemiourgosShareholder. BloodshedTreasury: Bloodshed \
            \ (the PURE score from Step 4, not the subsidiary -- that one is in the five). \
            \ Farm OURO LP triplet is wired in Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8 output; score ids from Steps 4–5
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                )
                (enforce (= (length subsidiary-score-ids) 5) "Step 9 expects subsidiary-score-ids×5.")
                (map
                    (lambda (score-id:string)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id BOOT|SCORE_ENTITY_SCORE score-id)
                    )
                    subsidiary-score-ids
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id BOOT|SCORE_ENTITY_SCORE coding-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id BOOT|SCORE_ENTITY_SCORE snakes-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id BOOT|SCORE_ENTITY_SCORE shares-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id BOOT|SCORE_ENTITY_SCORE bloodshed-score-id)
                (format "AQP-BOOT Step 9 done. score-entities=[sub=5 coding=1 snakes=1 shares=1]. fvt-ids=[sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={}]. NEXT=Step10:C_IssueMultipletFamily."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step10_IssueMultipletFamily:string
        (patron:string ouro-id:string auryn-id:string elite-auryn-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Step 10 — Issue chain-wide MultipletFamily (rank 3) for OURO→Auryn→Elite-Auryn Coil/Curl ladder. \
            \ INPUT: live DPTF ids + ATS pair ids (token-0 RT on ats-0-1; token-1 RBT/RT; token-2 RBT)."
        ;;
        ;; family-id = F|ouro-id|auryn-id|elite-auryn-id (deterministic — pass to Step 11)
        ;; REPL: ouro-id, auryn-id, elite-auryn-id from DALOS; ats ids from deployed ATS pairs
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (family-id:string (concat ["F" "|" ouro-id "|" auryn-id "|" elite-auryn-id]))
                )
                (ref-TS02-C3::AQP-FVT|C_IssueMultipletFamily
                    patron patron ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id
                )
                (format "AQP-BOOT Step 10 done. multiplet-family-id={}. tokens=[ouro={} auryn={} elite={}] ats=[{} {}]. NEXT=Step11:C_IssueTriplet+AddScoreEntity."
                    [family-id ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id]
                )
            )
        )
    )
    (defun C_Step11_WireFarmTriplet:string
        (patron:string farm-id:string bronze-score-id:string silver-score-id:string golden-score-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 11 — Issue triplet bundle, admit to OuroLpFarm (type 3), register OURO MULTIPLET_BASE reward. \
            \ Skip when farm-id empty or 'skipped'. INPUT: score ids from Step 6; family id from Step 10 echo."
        ;;
        ;; triplet-id = T|bronze|silver|golden (deterministic from score ids)
        ;; REPL: farm-id from Step 8; ouro-id = lp-denominator; multiplet-family-id from Step 10
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (wire-farm:bool
                        (and
                            (!= farm-id "")
                            (!= farm-id "skipped")
                        )
                    )
                    (triplet-id:string (concat ["T" "|" bronze-score-id "|" silver-score-id "|" golden-score-id]))
                )
                (if wire-farm
                    (do
                        (ref-TS02-C3::AQP-SCR|C_IssueTriplet patron patron bronze-score-id silver-score-id golden-score-id)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id BOOT|SCORE_ENTITY_TRIPLET triplet-id)
                        (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id ouro-id false multiplet-family-id)
                    )
                    true
                )
                (format "AQP-BOOT Step 11 done. farm={} triplet-id={} multiplet-family-id={} ouro-reward={}. NEXT=Step12:C_AddRewardLink."
                    [
                        (if wire-farm farm-id "skipped")
                        (if wire-farm triplet-id "skipped")
                        (if wire-farm multiplet-family-id "skipped")
                        (if wire-farm ouro-id "skipped")
                    ]
                )
            )
        )
    )
    (defun C_Step12_AddFvtRewardLinks:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string reward-auryn-id:string reward-ouroboros-id:string reward-wstoa-id:string)
        @doc "Step 12 — Register reward tokens on treasury FVT entities via C_AddRewardLink (multiplet-family-id BAR). \
            \ SubsidiaryTreasury, SnakesTreasury → Auryn. CodingDivisionTreasury → Wstoa. \
            \ CompanySharesTreasury → Ouroboros. BloodshedTreasury → Auryn AND Wstoa (the only \
            \ multi-reward FVT here). Farm OURO + family is Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8; reward DPTF ids from live chain
        ;; REPL: AURYN-98c486052a51, DALOS::UR_OuroborosID, DALOS::UR_WrappedStoaID
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id reward-wstoa-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id reward-ouroboros-id false bar)
                ;;BloodshedTreasury earns TWO tokens -- owner ruling 2026-09-19: "add wstoa and
                ;;auryn for now on the pure bloodshed score vault". It is the only FVT here with
                ;;more than one reward; the other four take a single token each.
                ;;
                ;;This is supported by construction, not a workaround: FVT|T|RPS|Global is keyed
                ;;`fvt-id | dptf-id` (RPS::UCk_RpsGlobal), so reward state is per (FVT, token) and
                ;;UR_FVT|EnabledRewardCount exists to count them. Two links are two rows.
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-wstoa-id false bar)
                ;;LABELLING FIXED 2026-09-18. This read
                ;;  reward-links=[sub={} coding={} snakes={} shares={}]
                ;;fed with the REWARD TOKEN ids, so `sub=<auryn-id>` looked like it was naming the
                ;;sub-treasury when it was naming what the sub-treasury was linked TO -- and the
                ;;same three reward ids were then printed again under `rewards=`. Arity was always
                ;;correct; the labels were not, and the treasury ids the links actually attach to
                ;;did not appear at all. Now each link is printed as the PAIR it is.
                (format "AQP-BOOT Step 12 done. reward-links=[{}<-auryn {}<-wstoa {}<-auryn {}<-ouroboros {}<-auryn+wstoa]. rewards=[auryn={} wstoa={} ouroboros={}]. Bootstrap complete — ready for inject/stake/collect."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                        reward-auryn-id reward-wstoa-id reward-ouroboros-id
                    ]
                )
            )
        )
    )

    (defun C_Step13_CreateCustodiansVault:string
        (patron:string owner-konto:string custodians-dpsf-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 13 — stand up the Custodians DELEGATED-STAKING vault: three quintessence score \
            \ MODELS (bronze/silver/golden) + the triplet model every agency instantiates, a class-0 \
            \ FVT, a MULTIPLET_BASE OURO reward on the Step-10 ladder, the HETEROGENEOUS quality \
            \ split, the DSA template, and the pool the Custodians SFT stakes into. \
            \ Issues NO agency — that is Step 14, once per operator."
        ;;
        ;; INPUT
        ;;   custodians-dpsf-id  — the live Custodians DPSF collection id (REPL: DHOC-98c486052a51)
        ;;   ouro-id             — OURO DPTF id; BOTH the FVT common-denominator and the reward token
        ;;   multiplet-family-id — from Step 10. MUST be the OURO|AURYN|ELITEAURYN family: the
        ;;                         quality split routes per-mille across t0/t1/t2 OF THIS LADDER, so
        ;;                         a different family silently redirects every payout.
        ;; OUTPUT — fvt-id, pool-id, the four model ids. Step 14 needs the triplet model id.
        ;;
        ;; ORDER IS FORCED, not stylistic:
        ;;   * C_SetQualitySplit's own guard (04_RPS.pact UEV_QualitySplitContext) demands the reward
        ;;     link already exist, BE MULTIPLET_BASE, and carry an ACTIVE family. A reward link is
        ;;     MULTIPLET_BASE precisely when C_AddRewardLink is passed a family id instead of BAR.
        ;;     So: family (Step 10) -> reward link -> split. It cannot be reordered.
        ;;   * C_DefineDelegationVault requires the FVT to exist and be class 0, owned by patron.
        ;;   * The pool is issued here but its scores are added in Step 14 — they do not exist until
        ;;     an agency instantiates the model.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (bronze-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_BRONZE))
                    (silver-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_SILVER))
                    (golden-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_GOLDEN))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                    ;;Anchor executor = the anchored SFT collection's owner, read not assumed.
                    (custodians-dpsf-owner:string
                        (AQP-ANK.URC_AnchorableAssetOwner custodians-dpsf-id [false true]))
                )
                ;; 1. the OG-Founder ANCHOR (+5%) and the boost class it creates. `acnoi` true means
                ;;    the next argument is a NAME to create rather than an existing class id.
                ;;    Issued once, here: the class is shared by every agency's scores (Step 14
                ;;    links them), which is what makes the 5% apply to a user's WHOLE staked
                ;;    quintessence rather than only the golden lane.
                (ref-TS02-C3::AQP-ANK|C_IssueSemiFungibleAnchor patron custodians-dpsf-owner BOOT|CUSTODIANS_OG_ANCHOR
                    custodians-dpsf-id true BOOT|CUSTODIANS_OG_BOOST_CLASS
                    BOOT|CUSTODIANS_ANK_PRECISION BOOT|CUSTODIANS_OG_PROMILE BOOT|CUSTODIANS_OG_NONCE)
                ;; 2. the three single models — score-class 3 (SemiFungible); v1 models are SF-only.
                ;;    Each carries og-boost-class-id, so every score minted from them is boost-linked
                ;;    AT ISSUE by the vault's rule. The agency never chooses.
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_BRONZE
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_BRONZE BOOT|CUSTODIANS_VALUE_BRONZE og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_SILVER
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_SILVER BOOT|CUSTODIANS_VALUE_SILVER og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_GOLDEN
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_GOLDEN BOOT|CUSTODIANS_VALUE_GOLDEN og-boost-class-id)
                ;; 3. the triplet model — what every agency instantiates, so all agencies score alike
                (ref-TS02-C3::AQP-SCR|C_CombineTripletScoreModel patron patron BOOT|MODEL_CUSTODIANS_TRIPLET
                    bronze-model-id silver-model-id golden-model-id)
                ;; 4. the class-0 FVT. common-denominator is a REAL DPTF here, not BAR: DSA capture
                ;;    arithmetic is denominated in it, which is the whole reason class 1/2 is refused.
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CUSTODIANS_VAULT 0 ouro-id)
                ;; 5. MULTIPLET_BASE reward — the family id is what makes it so
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id false multiplet-family-id)
                ;; 6. the heterogeneous split across the OURO|AURYN|ELITEAURYN ladder
                (ref-TS02-C3::AQP-FVT|C_SetQualitySplit patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id
                    BOOT|REWARD_MODE_HETEROGENEOUS
                    BOOT|CUSTODIANS_SPLIT_BRONZE BOOT|CUSTODIANS_SPLIT_SILVER BOOT|CUSTODIANS_SPLIT_GOLDEN)
                ;; 7. the DSA template — unit-score sets the node bar AND, at half, the agency bar
                (ref-TS02-C3::AQP-DSA|C_DefineDelegationVault patron patron fvt-id triplet-model-id
                    BOOT|CUSTODIANS_UNIT_SCORE)
                ;; 8. the pool the Custodians SFT stakes into — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron custodians-dpsf-owner BOOT|POOL_CUSTODIANS custodians-dpsf-id 3)
                (format "AQP-BOOT Step 13 done. fvt={} pool={} triplet-model={} models=[bronze={} silver={} golden={}] og-boost-class={} (+5%% on nonce 4) unit-score={} (agency gate {}). NEXT=Step14:CC_Step14_OpenCustodiansAgency."
                    [
                        fvt-id pool-id triplet-model-id
                        bronze-model-id silver-model-id golden-model-id
                        (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS)
                        BOOT|CUSTODIANS_UNIT_SCORE (/ (dec BOOT|CUSTODIANS_UNIT_SCORE) 2.0)
                    ]
                )
            )
        )
    )
    (defun CC_Step14_OpenCustodiansAgency:string
        (patron:string agency-name:string custodians-dpsf-id:string stake-nonces:[integer] fee-per-mille:integer)
        @doc "Step 14 — open ONE Custodians agency: instantiate the triplet model for this operator, \
            \ HEAVY (CC_): reaches RPS::URH_FvtEnabledScoreEntityIdsForFvt through CC_OpenAgency's \
            \ stake leg, so its cost scales with the vault's score-entity count, not with a constant. \
            \ employ its three scores in the Custodians pool, then open the agency and stake in one \
            \ atomic Talos call. Run once per operator; the first run is the vault's first agency."
        ;;
        ;; INPUT
        ;;   patron         — THE OPERATOR. There is deliberately no separate operator parameter:
        ;;                    the operator is whoever calls. C_AdmitAgency admits with
        ;;                    `XE_AdmitDelegationMember fvt-id score-entity-id PATRON`, and
        ;;                    FVT|XE>ADMIT-DELEGATION then enforces `silver-owner == operator` plus
        ;;                    that operator's account ownership -- while CC_OpenAgency stakes from
        ;;                    patron too. An earlier draft took an `operator-konto` alongside
        ;;                    `patron`; it could only ever be the same value, and passing anything
        ;;                    else failed inside RPS with a message naming neither parameter. The
        ;;                    test passed because both were KST.ANHD, which is exactly how a
        ;;                    parameter that cannot vary looks like one that can.
        ;;                    The operator need NOT be the vault owner -- only the caller.
        ;;   agency-name    — names the three scores <agency-name>Bronze/Silver/Golden, so it must be
        ;;                    unique per agency or the second one collides on the branding table.
        ;;   stake-nonces   — the operator's OWN opening stake, e.g. [-1 -2 -3] for fragments of all
        ;;                    three tiers. This is not optional: UEV_OpenGate is TERMINAL inside
        ;;                    CC_OpenAgency, so a stake too small to reach unit-score/2 reverts the
        ;;                    whole open rather than leaving a half-built agency.
        ;;   fee-per-mille  — 10..500 (1%..50%), skimmed from DELEGATORS only, never the operator.
        ;;
        ;; WHY THE POOL LINKS HAPPEN HERE AND NOT IN STEP 13: the scores do not exist until this
        ;; call mints them, and RPS's FVT|XE>ADMIT-DELEGATION requires the SILVER score to carry a
        ;; pool link before it will admit the triplet. Employ-then-open, per agency.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (pool-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-id))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                )
                ;; 1. the factory: 3 scores + their SF definitions + the triplet, in one call
                (ref-TS02-C3::AQP-SCR|C_IssueScoreFromModel patron patron triplet-model-id agency-name)
                (let
                    (
                        (bronze-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Bronze"])))
                        (silver-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Silver"])))
                        (golden-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Golden"])))
                    )
                    ;; 2. employ all three in the Custodians pool (silver's link is the one admission reads).
                    ;;    NOTE what is NOT here: boost-class links. Those used to be three explicit
                    ;;    C_CreateScoreBoostClassLink calls at this point, which was the defect --
                    ;;    they were made by the AGENCY, so an agency could decline the vault's anchor
                    ;;    or point at another class. The class now rides on the MODEL and is applied
                    ;;    by XI_IssueOneFromModel at issue, so step 1 above already linked all three.
                    ;;    The vault admin defines how a score behaves; the agency just opens.
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id bronze-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id silver-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id golden-id)
                    ;; 3. admit + stake + gate, atomically
                    (ref-TS02-C3::AQP-DSA|CC_OpenAgency patron patron fvt-id pool-id
                        (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                        fee-per-mille custodians-dpsf-id stake-nonces)
                    (format "AQP-BOOT Step 14 done. agency={} triplet={} operator={} fee={}/1000 scores=[bronze={} silver={} golden={}]. NEXT: C_SetOracleAuth then C_OracleWrite — capture stays 0 until an oracle reports nodes."
                        [
                            agency-name
                            (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                            patron fee-per-mille bronze-id silver-id golden-id
                        ]
                    )
                )
            )
        )
    )
    ;;<=========================================================================>
    ;;  THE LATE STEPS — 7b, 8b, 9b, 12b   (added 2026-10-08)
    ;;
    ;;  WHY SEPARATE STEPS AND NOT EDITS TO 7/8/9/12.
    ;;    Steps 7 and 8 HAVE ALREADY RUN ON MAINNET. Step 8 minted six FVT entities, and
    ;;    `C_Issue` aborts on a duplicate name, so adding three entities to Step 8 would make
    ;;    that step permanently unrunnable rather than usefully extended. Step 7 likewise
    ;;    already created its seven pools. An additive step can run NOW, against the chain as
    ;;    it actually is; an edited one could only run on a chain that no longer exists.
    ;;
    ;;    Steps 9 and 12 have NOT run, so they COULD have been widened -- but Step 9 already
    ;;    takes 11 arguments and Step 12 nine, and both are hand-fed on mainnet from earlier
    ;;    transactions' output strings. Widening them to 17 and 15 would put the new work and
    ;;    the old work in one irreversible paste. These stay small and are run beside them.
    ;;
    ;;  ORDER: 7b and 8b are independent of each other and of everything else. 9b needs 8b
    ;;  (and, for StoicPower, 7b). 12b needs 8b. Nothing here needs 9 or 12 to have run.
    ;;<=========================================================================>
    (defun C_Step7b_CreateStoicismPool:string
        (patron:string stoicism-dptf-id:string stoic-power-score-id:string)
        @doc "Step 7b — The one pool Step 7 never made. Issues <StoicismPool> at aqp-class 1 \
            \ (non-LP true fungible) over the STOICISM DPTF and employs the existing StoicPower \
            \ score in it. Step 7 builds pools for the six DH collections and the OURO LP; \
            \ StoicPower is a true-fungible score over a plain token and belongs to neither \
            \ group, so it was left with no pool at all -- the only score on chain in that state. \
            \ NEXT=Step8b (the vault), then Step9b (admit), then Step12b (reward link)."
        ;;
        ;; INPUT
        ;;   stoicism-dptf-id    — the STOICISM DPTF id (the token users stake)
        ;;   stoic-power-score-id — the EXISTING StoicPower score, carried from its issue tx
        ;;
        ;; WHY NOT `C_IssueGenericEarningVault`, WHICH DOES ALL OF THIS IN ONE CALL:
        ;;   because it MINTS ITS OWN SCORE (`<name>Score`). StoicPower already exists, with its
        ;;   own weighting, and the request is to build a pool FOR IT. Calling the generic vault
        ;;   would stand up a second, empty `StoicismScore` beside it and leave StoicPower exactly
        ;;   as orphaned as it is now. The generic function remains the right tool for a vault
        ;;   that has no score yet; this is the variant for one that does.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_STOICISM))
                    ;;THE STAKED ASSET'S OWNER, DERIVED -- not read from the pool row, which this
                    ;;transaction has not created yet. Step 7 aborted for exactly that reason on
                    ;;every chain until 2026-10-06: a Pact `let` is EAGER, so a read of
                    ;;`AQP|T|Pool` for a pool created later in the same body runs first and fails.
                    ;;`URC_AqpOwnerKontoFromClassAndAsset` is documented for the pre-pool-row case
                    ;;and resolves the same value the row would have held.
                    (stake-asset-owner:string
                        (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset
                            BOOT|POOL_CLASS_TF stoicism-dptf-id))
                )
                (ref-TS02-C3::AQP-POOL|C_Issue
                    patron stake-asset-owner BOOT|POOL_STOICISM stoicism-dptf-id BOOT|POOL_CLASS_TF)
                ;;The executor on C_AddScore is the ASSET's owner, matching the issue above and
                ;;`AQP-FVT|C_IssueGenericEarningVault`'s own sequence -- a vault operator may
                ;;stake a token somebody else issued, so this is not necessarily `patron`.
                (ref-TS02-C3::AQP-POOL|C_AddScore
                    patron stake-asset-owner pool-id stoic-power-score-id)
                (format "AQP-BOOT Step 7b done. pool={} asset={} score={}. NEXT=Step8b:C_IssueLateFvtEntities."
                    [pool-id stoicism-dptf-id stoic-power-score-id]
                )
            )
        )
    )
    (defun C_Step8b_IssueLateFvtEntities:string
        (patron:string owner-konto:string)
        @doc "Step 8b — The three FVT entities Step 8 never issued. NosferatuTreasury and \
            \ WonderCoachTreasury at fvt-class 2 (treasury), matching the four Step 8 issued for \
            \ the other collection cores; StoicismVault at fvt-class 1 (vault), because \
            \ StoicPower is a true fungible and treasury admits only SF/NF. All three take the \
            \ BAR common denominator -- only a farm carries a real one. \
            \ SAFE TO RUN AFTER STEP 8: these are three NEW names, so nothing collides. \
            \ NEXT=Step9b with the three ids below."
        ;;
        ;; INPUT — patron, owner-konto (the FVT owner; the same account Step 8 used)
        ;; OUTPUT — three fvt-ids, to be pasted into Step 9b AND Step 12b
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (nosferatu-treasury-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_NOSFERATU_TREASURY))
                    (wondercoach-treasury-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_WONDERCOACH_TREASURY))
                    (stoicism-vault-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_STOICISM_VAULT))
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_NOSFERATU_TREASURY BOOT|FVT_CLASS_TREASURY BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_WONDERCOACH_TREASURY BOOT|FVT_CLASS_TREASURY BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_STOICISM_VAULT BOOT|FVT_CLASS_VAULT BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8b done. fvt-ids=[nosferatu-treasury={} wondercoach-treasury={} stoicism-vault={}]. NEXT=Step9b:C_AddLateFvtScoreEntities."
                    [nosferatu-treasury-id wondercoach-treasury-id stoicism-vault-id]
                )
            )
        )
    )
    (defun C_Step9b_AddLateFvtScoreEntities:string
        (patron:string nosferatu-treasury-id:string wondercoach-treasury-id:string stoicism-vault-id:string core-nosferatu-score-id:string core-wondercoach-score-id:string stoic-power-score-id:string)
        @doc "Step 9b — Admit the three late scores (score-entity type 1) on the three Step 8b \
            \ entities: NosferatuDracula -> NosferatuTreasury, WonderCoach -> WonderCoachTreasury, \
            \ StoicPower -> StoicismVault. Independent of Step 9, which admits the nine scores \
            \ the boot ladder itself created. \
            \ A SCORE MAY BE ADMITTED ONCE: fvt-link is written once and never re-pointed, so \
            \ running this twice aborts rather than moving anything."
        ;;
        ;; INPUT — fvt-ids from Step 8b's output; the three score ids from their issue txs
        ;;
        ;; HARD PRECONDITION — EVERY SCORE HERE MUST ALREADY BE EMPLOYED IN A POOL.
        ;;   CORRECTED 2026-10-08. This note used to say Step 7b "must have run, or it has no
        ;;   pool and the aggregate still refuses its stakes" -- i.e. that admitting a pool-less
        ;;   score merely under-earns. It does not. It ABORTS:
        ;;
        ;;     No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: |
        ;;
        ;;   `URC_ResolveScoreEntitySwpair` (05_FVT.pact:1334) binds
        ;;   `(asset-id (UR_AQP|PoolAssetId pool-id))` in an EAGER `let`, so the pool row is read
        ;;   even at fvt-class 1/2 where the value is never used. A BAR pool-link is therefore
        ;;   fatal at admission, not at earning time.
        ;;
        ;;   On chain the two core scores are already pooled by Step 7; StoicPower is not, so
        ;;   STEP 7b MUST LAND BEFORE THIS STEP. Found by the REPL fixture, which minted the three
        ;;   scores and went straight here -- the error above is verbatim from that run.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto nosferatu-treasury-id)
                    nosferatu-treasury-id BOOT|SCORE_ENTITY_SCORE core-nosferatu-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto wondercoach-treasury-id)
                    wondercoach-treasury-id BOOT|SCORE_ENTITY_SCORE core-wondercoach-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto stoicism-vault-id)
                    stoicism-vault-id BOOT|SCORE_ENTITY_SCORE stoic-power-score-id)
                (format "AQP-BOOT Step 9b done. admitted=[{}->{} {}->{} {}->{}]. NEXT=Step12b:C_AddLateFvtRewardLinks."
                    [
                        core-nosferatu-score-id nosferatu-treasury-id
                        core-wondercoach-score-id wondercoach-treasury-id
                        stoic-power-score-id stoicism-vault-id
                    ]
                )
            )
        )
    )
    (defun C_Step12b_AddLateFvtRewardLinks:string
        (patron:string nosferatu-treasury-id:string wondercoach-treasury-id:string stoicism-vault-id:string nosferatu-reward-id:string wondercoach-reward-id:string stoicism-reward-id:string)
        @doc "Step 12b — Register one reward token on each Step 8b entity. \
            \ NOT OPTIONAL: an employed score whose FVT has no enabled reward token makes every \
            \ stake abort in the FVT pipeline (05_FVT.pact:1210), so Steps 7b/8b/9b without this \
            \ one build three aggregators nobody can stake into. \
            \ THE REWARD TOKENS ARE PARAMETERS, NOT BAKED IN. Step 12 hardcodes its mapping \
            \ (sub/snakes->Auryn, coding->Wstoa, shares->Ouroboros, bloodshed->both) because \
            \ those were ruled on. Only the Stoicism one has been: owner, 2026-10-08 -- stake \
            \ Stoicism, earn WSTOA. What NosferatuTreasury and WonderCoachTreasury should pay \
            \ has not, so this step asks rather than guessing."
        ;;
        ;; INPUT — fvt-ids from Step 8b; three reward DPTF ids chosen by the operator
        ;;   stoicism-reward-id — WSTOA, per the owner ruling above
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto nosferatu-treasury-id)
                    nosferatu-treasury-id nosferatu-reward-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto wondercoach-treasury-id)
                    wondercoach-treasury-id wondercoach-reward-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto stoicism-vault-id)
                    stoicism-vault-id stoicism-reward-id false bar)
                (format "AQP-BOOT Step 12b done. reward-links=[{}<-{} {}<-{} {}<-{}]. The three late entities are now stakeable."
                    [
                        nosferatu-treasury-id nosferatu-reward-id
                        wondercoach-treasury-id wondercoach-reward-id
                        stoicism-vault-id stoicism-reward-id
                    ]
                )
            )
        )
    )
    (defun C_IssueGenericEarningVault:string
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Thin delegate to TS02-C3.AQP-FVT|C_IssueGenericEarningVault. Kept so existing callers \
            \ keep working; the operation itself moved to Talos on 2026-09-19."
        ;;WHY THE BODY MOVED. This used to compose the six TS02-C3 wrappers directly, and each of
        ;;those collects IGNIS on its own -- six collections for one logical operation. The work now
        ;;lives in TS02-C3, composing the six CORE C_ functions and concatenating their cumulators
        ;;into ONE collection. Single-collection billing is a Talos concern, not a citizen one, and
        ;;putting it there also makes the operation a public client feature rather than something
        ;;only the AQP-BOOT admin can reach.
        (TS02-C3.AQP-FVT|C_IssueGenericEarningVault
            patron owner-konto vault-name stake-dptf-id reward-dptf-id)
    )

)

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact (module only -- its interface is already live)
(module O-UI-FOURTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiFourteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-FOURTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_FOURTEEN_ADMIN)))
    (defcap GOV|O_UI_FOURTEEN_ADMIN ()      (enforce-guard GOV|MD_O-UI-FOURTEEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{2}  CONSTANTS
    ;;The five score classes, in the order `C_Issue*Score` assigns them. Named here because the
    ;;chain stores an integer and a client showing "class 3" tells a user nothing.
    (defconst CT_14_SCORE_KINDS:[string] ["lp" "dptf" "dpof" "dpsf" "dpnf"])

    ;;{5.3}  Read

    (defun URC_14|ScoreKind:string (score-class:integer)
        @doc "The score's asset kind, named. 0 LP, 1 DPTF, 2 DPOF, 3 DPSF, 4 DPNF -- the order \
            \ `C_IssueLpScore` .. `C_IssueNonFungibleScore` assign. An out-of-range class answers \
            \ \"unknown\" rather than aborting: this is a display label, and a reader that kills \
            \ the whole page over one odd row is worse than one that says so."
        (if (and (>= score-class 0) (< score-class (length CT_14_SCORE_KINDS)))
            (at score-class CT_14_SCORE_KINDS)
            "unknown")
    )

    (defun URC_14|PoolLabel:string (pool-id:string)
        @doc "A pool's human label. THE CHAIN STORES NONE -- `AQP|Schema` has no name field, and \
            \ the id's stem is what the operator typed at issuance, so it is the only human \
            \ string there is. Same rule the anchors slice uses for an anchor's label."
        (let ((ref-U|LST:module{StringProcessorV2} U|LST))
            ;;`UC_SplitString` takes the SPLITTER first and the subject second -- the opposite
            ;;order to the obvious guess, and an argument order a type checker cannot catch
            ;;because both are strings.
            (at 0 (ref-U|LST::UC_SplitString "-" pool-id))
        )
    )

    (defun URC_14|ScoreDefinition:object (score-id:string)
        @doc "A score's DEFINITION -- what it is, independent of any account. Shared by the \
            \ catalogue and by every per-user row, so the two can never disagree about what a \
            \ score is while disagreeing only about whose numbers are shown."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (let
                (
                    (triplet-id:string (ref-SCR::UR_SCR|ScoreTripletId score-id))
                    (aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
                )
                {"score-id"        : score-id
                ;;The id IS the name. `SCR|Schema` has no name field and the issuing entrypoints
                ;;take a human string as the id's stem.
                ,"label"           : (URC_14|PoolLabel score-id)
                ,"owner"           : (ref-SCR::UR_SCR|ScoreOwnerKonto score-id)
                ,"score-class"     : (ref-SCR::UR_SCR|ScoreClass score-id)
                ,"kind"            : (URC_14|ScoreKind (ref-SCR::UR_SCR|ScoreClass score-id))
                ,"precision"       : (ref-SCR::UR_SCR|ScorePrecision score-id)
                ;;SINGULAR AND PERMANENT. A BAR fvt-link means this score is admitted NOWHERE and
                ;;therefore earns nobody anything -- a state the catalogue must be able to show,
                ;;because a perfectly well-defined score can be economically inert.
                ,"fvt-link"        : (ref-SCR::UR_SCR|ScoreFvtLink score-id)
                ,"boost-class-link": (ref-SCR::UR_SCR|ScoreBoostClassLink score-id)
                ;;THE FOREIGN BOOST LINK -- the score whose BASE this score's boost is computed
                ;;from, or BAR when it is its own primary. This is NOT the boost-class link above:
                ;;that names a group of boosters, this names another SCORE.
                ;;
                ;;IT IS THE ONLY RELATIONSHIP THREE SIBLING SCORES HAVE BEFORE A TRIPLET EXISTS.
                ;;`AQP-BOOT` Step 6 issues Bronze/Silver/Golden as three class-0 scores pointing
                ;;their boost-links at Silver; `C_IssueTriplet` is Step 11, so between the two the
                ;;chain holds a boost CHAIN and no triplet row at all -- measured on mainnet
                ;;2026-10-05: `SCR|T|Triplet` has zero keys while the three links are live. A
                ;;client with only `triplet-id` to go on can show those three only as unrelated
                ;;singles, which is exactly what they are not.
                ,"boost-link"      : (ref-SCR::UR_SCR|ScoreBoostLink score-id)
                ;;The LP leg these class-0 scores are denominated in. BAR for classes 1-4 by
                ;;construction (`UEV` on issuance enforces it), so it doubles as the second half
                ;;of a chain's identity: siblings share a denominator.
                ,"lp-denominator"  : (ref-SCR::UR_SCR|ScoreLpDenominator score-id)
                ,"deb-boost"       : (ref-SCR::UR_SCR|ScoreDebBoost score-id)
                ,"in-triplet"      : (ref-SCR::UR_SCR|ScoreTriplet score-id)
                ,"triplet-id"      : triplet-id
                ;;A DIRECT READER, NOT A DERIVATION. A TRUE triplet is one whose rungs form a
                ;;closed boost ring: ONE HUB carrying the staked base and two ADDITIVE SATELLITES
                ;;whose base is 0 and which earn only what their own boosters make against the
                ;;hub's base. That is what a client needs it for -- a zero on a satellite is
                ;;EXPECTED, not a missing position.
                ;;CORRECTED 2026-10-09. This said a true triplet's weight "comes from maintained
                ;;LANE WEIGHTS rather than a deb product, so it is deb-independent, cannot go
                ;;stale, and `CC_UnstaleMyScores` no-ops on it". All three clauses are now false:
                ;;`URC_ComputeTripletLanes` reads the legs' deb-scores, `URC_ScoreEntityUserWeight`
                ;;reads that sum LIVE, and the true-triplet short-circuit was removed from
                ;;`URC_FvtMemberDebNeedsFix` -- so a true triplet CAN go stale and IS repaired.
                ;;The first draft of this field inferred the property from the three rungs'
                ;;boost-links; `UR_SCR|TripletTrueTriplet` answers it outright.
                ,"true-triplet"    : (if (ref-SCR::URC_TripletExists triplet-id)
                                         (ref-SCR::UR_SCR|TripletTrueTriplet triplet-id)
                                         false)
                ;;THE STAKING ASSET IS NOT ON THE SCORE. `SCR|Schema` says so in as many words:
                ;;"No separate scr-asset on the score. Staking asset is defined on the AQP pool.
                ;;Resolve Score -> aqpool-link -> Pool -> asset-id." So this is a two-hop
                ;;resolution, and it is done HERE so that four clients cannot each get it wrong.
                ;;
                ;;A BAR aqpool-link means the score is employed by no pool, which is a real and
                ;;showable state -- not an error -- so the asset answers BAR rather than aborting.
                ,"aqpool-link"     : aqpool
                ,"asset-id"        : (if (= aqpool (ref-U|CT::CT_BAR))
                                         (ref-U|CT::CT_BAR)
                                         (ref-AQP::UR_AQP|PoolAssetId aqpool))
                ;;THE AGGREGATOR'S CLASS -- farm(0) / vault(1) / treasury(2). Read from RPS,
                ;;which owns the FVT row. Guarded on the link for the same reason as the asset:
                ;;a score admitted nowhere has no aggregator to have a class.
                ;;
                ;;THERE IS NO FVT NAME ON CHAIN, anywhere -- no field and no reader. The client
                ;;derives a label from the id's stem, exactly as it does for pools and scores.
                ,"fvt-class"       : (if (= (ref-SCR::UR_SCR|ScoreFvtLink score-id)
                                            (ref-U|CT::CT_BAR))
                                         -1
                                         (ref-RPS::UR_FVT|FvtClass
                                             (ref-SCR::UR_SCR|ScoreFvtLink score-id)))
                ;;TOTALS ACROSS EVERYBODY, not this account's. Shown so a holder can see what
                ;;share of a score they hold, which a bare personal figure cannot convey.
                ,"total-base"      : (ref-SCR::UR_SCR|ScoreTotalBaseScore score-id)
                ,"total-deb"       : (ref-SCR::UR_SCR|ScoreTotalDebScore score-id)
                ,"holders"         : (ref-SCR::UR_SCR|ScoreNzsCount score-id)}
            )
        )
    )

    (defun URC_14|TripletRungs:[string] (triplet-id:string)
        @doc "A triplet's three score ids in SLOT order. The slots are ids only, NOT boost roles \
            \ -- the schema says so in as many words -- so bronze/silver/golden here name \
            \ positions and imply no ranking. Answers an empty list for a non-triplet rather \
            \ than aborting, so a caller can ask unconditionally."
        (let ((ref-SCR:module{AcquisitionScoresV2} AQP-SCORE))
            (if (ref-SCR::URC_TripletExists triplet-id)
                [(ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id)
                 (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id)
                 (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id)]
                [])
        )
    )

    (defun URH_14|AllScoreEntities:[object] ()
        @doc "B view -- every score entity on chain, with its definition and its triplet \
            \ membership. \
            \ \
            \ TRIPLETS ARE DERIVED, NOT ENUMERATED. `SCR|T|Triplet` has no enumerator, but every \
            \ score carries `triplet-id`, so walking the scores finds every triplet that has a \
            \ member -- which is every triplet that can matter to anyone. A triplet with no \
            \ member scores would be invisible here and is also inert."
        (let ((ref-SCR:module{AcquisitionScoresV2} AQP-SCORE))
            (map (lambda (s:string)
                     (let ((def:object (URC_14|ScoreDefinition s)))
                         (+ def {"rungs": (URC_14|TripletRungs (at "triplet-id" def))})))
                 (ref-SCR::URH_SCR|AllScoreIds))
        )
    )

    (defun URC_14|MyScoreInPool:object (account:string pool-id:string score-id:string)
        @doc "One account's standing in ONE score of ONE pool, with the definition alongside. \
            \ \
            \ The three figures are BASE, BOOST and the deb-multiplied TOTAL -- see the module \
            \ header: `boosted-score` is the BOOST, not a running total. `deb-multiplier` is \
            \ derived rather than read because the chain stores no such field; it is what the \
            \ tier did to (base + boost), and 1.0 when there is nothing to divide."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (let
                (
                    (base:decimal (ref-SCR::UR_U-SCR|UserScoreBaseScore account pool-id score-id))
                    (boost:decimal (ref-SCR::UR_U-SCR|UserScoreBoostedScore account pool-id score-id))
                    (deb:decimal (ref-SCR::UR_U-SCR|UserScoreDebScore account pool-id score-id))
                )
                (+ (URC_14|ScoreDefinition score-id)
                   {"pool-id"        : pool-id
                   ,"pool-label"     : (URC_14|PoolLabel pool-id)
                   ,"base"           : base
                   ,"boost"          : boost
                   ,"final"          : deb
                   ,"deb-multiplier" : (if (> (+ base boost) 0.0)
                                           (/ deb (+ base boost))
                                           1.0)
                   ;;THE RUNGS, so a per-user row is as identifiable as a catalogue row. The
                   ;;slots are IDS ONLY and imply no ranking -- the schema is explicit that
                   ;;bronze/silver/golden are positions, not boost roles. Empty for a single
                   ;;score, which is what `URC_14|TripletRungs` answers for a BAR triplet-id.
                   ,"rungs"          : (URC_14|TripletRungs
                                           (ref-SCR::UR_SCR|ScoreTripletId score-id))
                   ;;THE REPAIR FLAG, read rather than inferred. A client that guessed staleness
                   ;;from the numbers would be wrong both ways: a legitimately zero score looks
                   ;;stale, and a stale one that happens to match looks fresh.
                   ,"needs-sync"     : (ref-SCR::URC_U-SCR|UserScoreDebStale account pool-id score-id)})
            )
        )
    )

    (defun URC_14|ScoreEntityFull:object (account:string pool-id:string score-id:string)
        @doc "ONE score entity, in full -- the screen behind a row click. \
            \ \
            \ It is `URC_14|MyScoreInPool` plus the fields that only a detail view needs, and \
            \ it is a SEPARATE function for a cost reason rather than a tidiness one: these \
            \ extra reads are per-entity, and folding them into the shared definition would \
            \ multiply them across every row of the catalogue and of the A view. \
            \ \
            \ WHAT IT CANNOT ANSWER, and the client must not pretend otherwise: \
            \ \
            \ - `my-stamped-generation`. `AcquisitionScoresV2` declares \
            \   `UR_SCR|ScoreVacateGeneration` for the SCORE but no stamped-generation reader \
            \   for the USER row, so the pair cannot be shown side by side. This is not a loss: \
            \   `URC_U-SCR|UserScoreDebStale` already answers the only decidable question -- is \
            \   my row invalidated -- and the raw counters were informational either way. \
            \ \
            \ - the BOOST SOURCES and the account's aggregate promille. Those live in AQP-ANK \
            \   and are the anchors slice's subject; `O-UI-THIRTEEN` answers them. A client \
            \   wanting both asks for both in ONE request, which costs one round trip, rather \
            \   than this module reaching across a boundary it has no reason to own."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (+ (URC_14|MyScoreInPool account pool-id score-id)
               {;;THE [Mu] MANAGEMENT FLAGS. `can-upgrade` false means the score's settings are
                ;;frozen for good -- a manager pressing an edit button would be refused by the
                ;;chain, so the client disables it instead of charging for the refusal.
                "can-upgrade"       : (ref-SCR::UR_SCR|ScoreCanUpgrade score-id)
               ,"can-change-owner"  : (ref-SCR::UR_SCR|ScoreCanChangeOwner score-id)
               ,"i-am-owner"        : (= account (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                ;;A FOREIGN BOOST-LINK CHANGES WHAT EVERY NUMBER MEANS. When non-BAR this score
                ;;is an ADDITIVE SATELLITE: its own base is stored as 0 and the promille applies
                ;;to the HUB's user base, so the row holds boost ONLY. A client showing
                ;;base+boost without saying so is showing a figure that does not mean what the
                ;;label claims -- and specifically must not imply a staked unit is worth anything
                ;;here, because without a booster in this score's own class it is worth zero.
                ;;BAR = own base, the normal case, and never this score itself
                ;;(`SCR|C>CREATE-BOOST-LINK-SCORE` forbids it).
               ,"boost-link"        : (ref-SCR::UR_SCR|ScoreBoostLink score-id)
                ;;THE THIRD TOTAL. The definition carries total-base and total-deb; the boosted
                ;;total completes the decomposition the module header spells out:
                ;;   base-deb + boosted-deb = deb-score.
               ,"total-boosted"     : (ref-SCR::UR_SCR|ScoreTotalBoostedScore score-id)
                ;;VACATE-v2, SHOWN BECAUSE A USER WHOSE WEIGHT VANISHED HAS NO OTHER EXPLANATION.
                ;;A fast-vacate bumps this counter and every user row stamped below it reads as
                ;;zero until re-staked. Without the counter on screen the page just shows zero.
               ,"vacate-generation" : (ref-SCR::UR_SCR|ScoreVacateGeneration score-id)
                ;;MY SHARE OF THE WHOLE SCORE, in promille, derived here so four clients cannot
                ;;each divide differently. -1.0 when the score's total is zero: there is no
                ;;share of nothing, and 0.0 would read as "you hold none of a populated score".
               ,"my-share-promille" : (let
                                          (
                                              (mine:decimal (ref-SCR::UR_U-SCR|UserScoreDebScore
                                                                account pool-id score-id))
                                              (whole:decimal (ref-SCR::UR_SCR|ScoreTotalDebScore
                                                                score-id))
                                          )
                                          (if (> whole 0.0)
                                              (* 1000.0 (/ mine whole))
                                              -1.0))
                ;;ECHOED so a detail response is self-describing: a client that cached it knows
                ;;which account it belongs to without keeping the request alongside.
               ,"account"           : account
               ,"bar"               : (ref-U|CT::CT_BAR)}
            )
        )
    )

    (defun URH_14|MyPoolIds:[string] (account:string)
        @doc "Every pool this account is a BENEFICIARY in, across all four asset kinds, deduped. \
            \ Four scans, one per tracker table -- there is no single staking table and a pool \
            \ can hold legs of more than one kind, so a stake in any of them puts the account in \
            \ that pool exactly once."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (distinct
                (map (lambda (r:object) (at "pool-id" r))
                     (+ (+ (ref-AQP::URH_AQP|DptfStakesByBeneficiary account)
                           (ref-AQP::URH_AQP|DpofStakesByBeneficiary account))
                        (+ (ref-AQP::URH_AQP|DpsfStakesByBeneficiary account)
                           (ref-AQP::URH_AQP|DpnfStakesByBeneficiary account)))))
        )
    )

    (defun URH_14|MyScoreEntities:[object] (account:string)
        @doc "A view -- every score this account holds a position in, one row per \
            \ (pool, score) pair. \
            \ \
            \ ONE ROW PER PAIR, NOT PER SCORE, because the chain keys the standing that way: the \
            \ same score in two pools is two independent positions with two independent numbers, \
            \ and summing them here would hide which pool to act on. \
            \ \
            \ VERY HEAVY -- four cross-pool scans, then a point read per (pool x score slot). \
            \ `/local` only, and it needs a generous gas limit; the anchors slice's \
            \ `URH_13|MyAnchorableAssets` measured above 150,000 and this reaches further."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            ;;ZERO ROWS ARE DROPPED. An account that has unstaked keeps a row at 0 until it is
            ;;swept, and a list of scores you do not hold is noise on the one screen whose whole
            ;;job is "what am I earning".
            (filter (lambda (r:object) (> (at "final" r) 0.0))
                (fold (+) []
                    (map (lambda (p:string)
                             (map (lambda (s:string) (URC_14|MyScoreInPool account p s))
                                  (ref-AQP::URC_PoolActiveScoreIds p)))
                         (URH_14|MyPoolIds account))))
        )
    )
)

